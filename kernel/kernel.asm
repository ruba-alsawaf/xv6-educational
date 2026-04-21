
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
    80000004:	94010113          	addi	sp,sp,-1728 # 80008940 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ff9cb27>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	dee78793          	addi	a5,a5,-530 # 80000e6e <main>
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
    800000ea:	85a50513          	addi	a0,a0,-1958 # 80010940 <conswlock>
    800000ee:	0be040ef          	jal	800041ac <acquiresleep>

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
    8000011e:	1a0020ef          	jal	800022be <either_copyin>
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
    80000166:	7de50513          	addi	a0,a0,2014 # 80010940 <conswlock>
    8000016a:	088040ef          	jal	800041f2 <releasesleep>
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
    800001a4:	7d050513          	addi	a0,a0,2000 # 80010970 <cons>
    800001a8:	259000ef          	jal	80000c00 <acquire>

  while(n > 0){
    while(cons.r == cons.w){
    800001ac:	00010497          	auipc	s1,0x10
    800001b0:	79448493          	addi	s1,s1,1940 # 80010940 <conswlock>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	00010997          	auipc	s3,0x10
    800001b8:	7bc98993          	addi	s3,s3,1980 # 80010970 <cons>
    800001bc:	00011917          	auipc	s2,0x11
    800001c0:	84c90913          	addi	s2,s2,-1972 # 80010a08 <cons+0x98>
  while(n > 0){
    800001c4:	0b405e63          	blez	s4,80000280 <consoleread+0x100>
    while(cons.r == cons.w){
    800001c8:	0c84a783          	lw	a5,200(s1)
    800001cc:	0cc4a703          	lw	a4,204(s1)
    800001d0:	0af71363          	bne	a4,a5,80000276 <consoleread+0xf6>
      if(killed(myproc())){
    800001d4:	734010ef          	jal	80001908 <myproc>
    800001d8:	779010ef          	jal	80002150 <killed>
    800001dc:	e12d                	bnez	a0,8000023e <consoleread+0xbe>
      sleep(&cons.r, &cons.lock);
    800001de:	85ce                	mv	a1,s3
    800001e0:	854a                	mv	a0,s2
    800001e2:	537010ef          	jal	80001f18 <sleep>
    while(cons.r == cons.w){
    800001e6:	0c84a783          	lw	a5,200(s1)
    800001ea:	0cc4a703          	lw	a4,204(s1)
    800001ee:	fef703e3          	beq	a4,a5,800001d4 <consoleread+0x54>
    800001f2:	e862                	sd	s8,16(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001f4:	00010717          	auipc	a4,0x10
    800001f8:	74c70713          	addi	a4,a4,1868 # 80010940 <conswlock>
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
    80000226:	04e020ef          	jal	80002274 <either_copyout>
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
    80000242:	73250513          	addi	a0,a0,1842 # 80010970 <cons>
    80000246:	253000ef          	jal	80000c98 <release>
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
    8000026e:	78f72f23          	sw	a5,1950(a4) # 80010a08 <cons+0x98>
    80000272:	6c42                	ld	s8,16(sp)
    80000274:	a031                	j	80000280 <consoleread+0x100>
    80000276:	e862                	sd	s8,16(sp)
    80000278:	bfb5                	j	800001f4 <consoleread+0x74>
    8000027a:	6c42                	ld	s8,16(sp)
    8000027c:	a011                	j	80000280 <consoleread+0x100>
    8000027e:	6c42                	ld	s8,16(sp)
  release(&cons.lock);
    80000280:	00010517          	auipc	a0,0x10
    80000284:	6f050513          	addi	a0,a0,1776 # 80010970 <cons>
    80000288:	211000ef          	jal	80000c98 <release>
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
    800002d8:	69c50513          	addi	a0,a0,1692 # 80010970 <cons>
    800002dc:	125000ef          	jal	80000c00 <acquire>

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
    800002f6:	012020ef          	jal	80002308 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	67650513          	addi	a0,a0,1654 # 80010970 <cons>
    80000302:	197000ef          	jal	80000c98 <release>
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
    8000031c:	62870713          	addi	a4,a4,1576 # 80010940 <conswlock>
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
    80000342:	60278793          	addi	a5,a5,1538 # 80010940 <conswlock>
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
    80000370:	69c7a783          	lw	a5,1692(a5) # 80010a08 <cons+0x98>
    80000374:	9f1d                	subw	a4,a4,a5
    80000376:	08000793          	li	a5,128
    8000037a:	f8f710e3          	bne	a4,a5,800002fa <consoleintr+0x32>
    8000037e:	a07d                	j	8000042c <consoleintr+0x164>
    80000380:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000382:	00010717          	auipc	a4,0x10
    80000386:	5be70713          	addi	a4,a4,1470 # 80010940 <conswlock>
    8000038a:	0d072783          	lw	a5,208(a4)
    8000038e:	0cc72703          	lw	a4,204(a4)
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    80000392:	00010497          	auipc	s1,0x10
    80000396:	5ae48493          	addi	s1,s1,1454 # 80010940 <conswlock>
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
    800003d8:	56c70713          	addi	a4,a4,1388 # 80010940 <conswlock>
    800003dc:	0d072783          	lw	a5,208(a4)
    800003e0:	0cc72703          	lw	a4,204(a4)
    800003e4:	f0f70be3          	beq	a4,a5,800002fa <consoleintr+0x32>
      cons.e--;
    800003e8:	37fd                	addiw	a5,a5,-1
    800003ea:	00010717          	auipc	a4,0x10
    800003ee:	62f72323          	sw	a5,1574(a4) # 80010a10 <cons+0xa0>
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
    8000040c:	53878793          	addi	a5,a5,1336 # 80010940 <conswlock>
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
    80000430:	5ec7a023          	sw	a2,1504(a5) # 80010a0c <cons+0x9c>
        wakeup(&cons.r);
    80000434:	00010517          	auipc	a0,0x10
    80000438:	5d450513          	addi	a0,a0,1492 # 80010a08 <cons+0x98>
    8000043c:	329010ef          	jal	80001f64 <wakeup>
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
    80000456:	51e50513          	addi	a0,a0,1310 # 80010970 <cons>
    8000045a:	726000ef          	jal	80000b80 <initlock>
  initsleeplock(&conswlock, "consw");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	bb258593          	addi	a1,a1,-1102 # 80008010 <etext+0x10>
    80000466:	00010517          	auipc	a0,0x10
    8000046a:	4da50513          	addi	a0,a0,1242 # 80010940 <conswlock>
    8000046e:	509030ef          	jal	80004176 <initsleeplock>

  uartinit();
    80000472:	400000ef          	jal	80000872 <uartinit>

  devsw[CONSOLE].read = consoleread;
    80000476:	00020797          	auipc	a5,0x20
    8000047a:	66a78793          	addi	a5,a5,1642 # 80020ae0 <devsw>
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
    800004b4:	32060613          	addi	a2,a2,800 # 800087d0 <digits>
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
    8000054e:	3ba7a783          	lw	a5,954(a5) # 80008904 <panicking>
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
    80000596:	48650513          	addi	a0,a0,1158 # 80010a18 <pr>
    8000059a:	666000ef          	jal	80000c00 <acquire>
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
    8000075e:	076b8b93          	addi	s7,s7,118 # 800087d0 <digits>
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
    800007f2:	1167a783          	lw	a5,278(a5) # 80008904 <panicking>
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
    80000808:	21450513          	addi	a0,a0,532 # 80010a18 <pr>
    8000080c:	48c000ef          	jal	80000c98 <release>
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
    80000826:	0f27a123          	sw	s2,226(a5) # 80008904 <panicking>
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
    80000848:	0b27ae23          	sw	s2,188(a5) # 80008900 <panicked>
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
    80000862:	1ba50513          	addi	a0,a0,442 # 80010a18 <pr>
    80000866:	31a000ef          	jal	80000b80 <initlock>
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
    800008ba:	17a50513          	addi	a0,a0,378 # 80010a30 <tx_lock>
    800008be:	2c2000ef          	jal	80000b80 <initlock>
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
    800008de:	15650513          	addi	a0,a0,342 # 80010a30 <tx_lock>
    800008e2:	31e000ef          	jal	80000c00 <acquire>

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
    800008fc:	01448493          	addi	s1,s1,20 # 8000890c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000900:	00010997          	auipc	s3,0x10
    80000904:	13098993          	addi	s3,s3,304 # 80010a30 <tx_lock>
    80000908:	00008917          	auipc	s2,0x8
    8000090c:	00090913          	mv	s2,s2
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
    8000091c:	5fc010ef          	jal	80001f18 <sleep>
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
    8000094a:	0ea50513          	addi	a0,a0,234 # 80010a30 <tx_lock>
    8000094e:	34a000ef          	jal	80000c98 <release>
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
    8000096e:	f9a7a783          	lw	a5,-102(a5) # 80008904 <panicking>
    80000972:	cf95                	beqz	a5,800009ae <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000974:	00008797          	auipc	a5,0x8
    80000978:	f8c7a783          	lw	a5,-116(a5) # 80008900 <panicked>
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
    8000099e:	f6a7a783          	lw	a5,-150(a5) # 80008904 <panicking>
    800009a2:	cb91                	beqz	a5,800009b6 <uartputc_sync+0x58>
    pop_off();
}
    800009a4:	60e2                	ld	ra,24(sp)
    800009a6:	6442                	ld	s0,16(sp)
    800009a8:	64a2                	ld	s1,8(sp)
    800009aa:	6105                	addi	sp,sp,32
    800009ac:	8082                	ret
    push_off();
    800009ae:	212000ef          	jal	80000bc0 <push_off>
    800009b2:	b7c9                	j	80000974 <uartputc_sync+0x16>
    for(;;)
    800009b4:	a001                	j	800009b4 <uartputc_sync+0x56>
    pop_off();
    800009b6:	28e000ef          	jal	80000c44 <pop_off>
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
    800009fa:	03a50513          	addi	a0,a0,58 # 80010a30 <tx_lock>
    800009fe:	202000ef          	jal	80000c00 <acquire>
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
    80000a16:	01e50513          	addi	a0,a0,30 # 80010a30 <tx_lock>
    80000a1a:	27e000ef          	jal	80000c98 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a1e:	54fd                	li	s1,-1
    80000a20:	a831                	j	80000a3c <uartintr+0x5a>
    tx_busy = 0;
    80000a22:	00008797          	auipc	a5,0x8
    80000a26:	ee07a523          	sw	zero,-278(a5) # 8000890c <tx_busy>
    wakeup(&tx_chan);
    80000a2a:	00008517          	auipc	a0,0x8
    80000a2e:	ede50513          	addi	a0,a0,-290 # 80008908 <tx_chan>
    80000a32:	532010ef          	jal	80001f64 <wakeup>
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
    80000a4e:	1101                	addi	sp,sp,-32
    80000a50:	ec06                	sd	ra,24(sp)
    80000a52:	e822                	sd	s0,16(sp)
    80000a54:	e426                	sd	s1,8(sp)
    80000a56:	e04a                	sd	s2,0(sp)
    80000a58:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a5a:	03451793          	slli	a5,a0,0x34
    80000a5e:	e7a9                	bnez	a5,80000aa8 <kfree+0x5a>
    80000a60:	84aa                	mv	s1,a0
    80000a62:	00061797          	auipc	a5,0x61
    80000a66:	27678793          	addi	a5,a5,630 # 80061cd8 <end>
    80000a6a:	02f56f63          	bltu	a0,a5,80000aa8 <kfree+0x5a>
    80000a6e:	47c5                	li	a5,17
    80000a70:	07ee                	slli	a5,a5,0x1b
    80000a72:	02f57b63          	bgeu	a0,a5,80000aa8 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a76:	6605                	lui	a2,0x1
    80000a78:	4585                	li	a1,1
    80000a7a:	25a000ef          	jal	80000cd4 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a7e:	00010917          	auipc	s2,0x10
    80000a82:	fca90913          	addi	s2,s2,-54 # 80010a48 <kmem>
    80000a86:	854a                	mv	a0,s2
    80000a88:	178000ef          	jal	80000c00 <acquire>
  r->next = kmem.freelist;
    80000a8c:	01893783          	ld	a5,24(s2)
    80000a90:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a92:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a96:	854a                	mv	a0,s2
    80000a98:	200000ef          	jal	80000c98 <release>
}
    80000a9c:	60e2                	ld	ra,24(sp)
    80000a9e:	6442                	ld	s0,16(sp)
    80000aa0:	64a2                	ld	s1,8(sp)
    80000aa2:	6902                	ld	s2,0(sp)
    80000aa4:	6105                	addi	sp,sp,32
    80000aa6:	8082                	ret
    panic("kfree");
    80000aa8:	00007517          	auipc	a0,0x7
    80000aac:	59850513          	addi	a0,a0,1432 # 80008040 <etext+0x40>
    80000ab0:	d63ff0ef          	jal	80000812 <panic>

0000000080000ab4 <freerange>:
{
    80000ab4:	7179                	addi	sp,sp,-48
    80000ab6:	f406                	sd	ra,40(sp)
    80000ab8:	f022                	sd	s0,32(sp)
    80000aba:	ec26                	sd	s1,24(sp)
    80000abc:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000abe:	6785                	lui	a5,0x1
    80000ac0:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ac4:	00e504b3          	add	s1,a0,a4
    80000ac8:	777d                	lui	a4,0xfffff
    80000aca:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000acc:	94be                	add	s1,s1,a5
    80000ace:	0295e263          	bltu	a1,s1,80000af2 <freerange+0x3e>
    80000ad2:	e84a                	sd	s2,16(sp)
    80000ad4:	e44e                	sd	s3,8(sp)
    80000ad6:	e052                	sd	s4,0(sp)
    80000ad8:	892e                	mv	s2,a1
    kfree(p);
    80000ada:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000adc:	6985                	lui	s3,0x1
    kfree(p);
    80000ade:	01448533          	add	a0,s1,s4
    80000ae2:	f6dff0ef          	jal	80000a4e <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae6:	94ce                	add	s1,s1,s3
    80000ae8:	fe997be3          	bgeu	s2,s1,80000ade <freerange+0x2a>
    80000aec:	6942                	ld	s2,16(sp)
    80000aee:	69a2                	ld	s3,8(sp)
    80000af0:	6a02                	ld	s4,0(sp)
}
    80000af2:	70a2                	ld	ra,40(sp)
    80000af4:	7402                	ld	s0,32(sp)
    80000af6:	64e2                	ld	s1,24(sp)
    80000af8:	6145                	addi	sp,sp,48
    80000afa:	8082                	ret

0000000080000afc <kinit>:
{
    80000afc:	1141                	addi	sp,sp,-16
    80000afe:	e406                	sd	ra,8(sp)
    80000b00:	e022                	sd	s0,0(sp)
    80000b02:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b04:	00007597          	auipc	a1,0x7
    80000b08:	54458593          	addi	a1,a1,1348 # 80008048 <etext+0x48>
    80000b0c:	00010517          	auipc	a0,0x10
    80000b10:	f3c50513          	addi	a0,a0,-196 # 80010a48 <kmem>
    80000b14:	06c000ef          	jal	80000b80 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b18:	45c5                	li	a1,17
    80000b1a:	05ee                	slli	a1,a1,0x1b
    80000b1c:	00061517          	auipc	a0,0x61
    80000b20:	1bc50513          	addi	a0,a0,444 # 80061cd8 <end>
    80000b24:	f91ff0ef          	jal	80000ab4 <freerange>
}
    80000b28:	60a2                	ld	ra,8(sp)
    80000b2a:	6402                	ld	s0,0(sp)
    80000b2c:	0141                	addi	sp,sp,16
    80000b2e:	8082                	ret

0000000080000b30 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b30:	1101                	addi	sp,sp,-32
    80000b32:	ec06                	sd	ra,24(sp)
    80000b34:	e822                	sd	s0,16(sp)
    80000b36:	e426                	sd	s1,8(sp)
    80000b38:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b3a:	00010497          	auipc	s1,0x10
    80000b3e:	f0e48493          	addi	s1,s1,-242 # 80010a48 <kmem>
    80000b42:	8526                	mv	a0,s1
    80000b44:	0bc000ef          	jal	80000c00 <acquire>
  r = kmem.freelist;
    80000b48:	6c84                	ld	s1,24(s1)
  if(r)
    80000b4a:	c485                	beqz	s1,80000b72 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b4c:	609c                	ld	a5,0(s1)
    80000b4e:	00010517          	auipc	a0,0x10
    80000b52:	efa50513          	addi	a0,a0,-262 # 80010a48 <kmem>
    80000b56:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b58:	140000ef          	jal	80000c98 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b5c:	6605                	lui	a2,0x1
    80000b5e:	4595                	li	a1,5
    80000b60:	8526                	mv	a0,s1
    80000b62:	172000ef          	jal	80000cd4 <memset>
  return (void*)r;
}
    80000b66:	8526                	mv	a0,s1
    80000b68:	60e2                	ld	ra,24(sp)
    80000b6a:	6442                	ld	s0,16(sp)
    80000b6c:	64a2                	ld	s1,8(sp)
    80000b6e:	6105                	addi	sp,sp,32
    80000b70:	8082                	ret
  release(&kmem.lock);
    80000b72:	00010517          	auipc	a0,0x10
    80000b76:	ed650513          	addi	a0,a0,-298 # 80010a48 <kmem>
    80000b7a:	11e000ef          	jal	80000c98 <release>
  if(r)
    80000b7e:	b7e5                	j	80000b66 <kalloc+0x36>

0000000080000b80 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b80:	1141                	addi	sp,sp,-16
    80000b82:	e422                	sd	s0,8(sp)
    80000b84:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b86:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b88:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b8c:	00053823          	sd	zero,16(a0)
}
    80000b90:	6422                	ld	s0,8(sp)
    80000b92:	0141                	addi	sp,sp,16
    80000b94:	8082                	ret

0000000080000b96 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b96:	411c                	lw	a5,0(a0)
    80000b98:	e399                	bnez	a5,80000b9e <holding+0x8>
    80000b9a:	4501                	li	a0,0
  return r;
}
    80000b9c:	8082                	ret
{
    80000b9e:	1101                	addi	sp,sp,-32
    80000ba0:	ec06                	sd	ra,24(sp)
    80000ba2:	e822                	sd	s0,16(sp)
    80000ba4:	e426                	sd	s1,8(sp)
    80000ba6:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ba8:	6904                	ld	s1,16(a0)
    80000baa:	543000ef          	jal	800018ec <mycpu>
    80000bae:	40a48533          	sub	a0,s1,a0
    80000bb2:	00153513          	seqz	a0,a0
}
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret

0000000080000bc0 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bc0:	1101                	addi	sp,sp,-32
    80000bc2:	ec06                	sd	ra,24(sp)
    80000bc4:	e822                	sd	s0,16(sp)
    80000bc6:	e426                	sd	s1,8(sp)
    80000bc8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bca:	100024f3          	csrr	s1,sstatus
    80000bce:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bd2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bd4:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000bd8:	515000ef          	jal	800018ec <mycpu>
    80000bdc:	5d3c                	lw	a5,120(a0)
    80000bde:	cb99                	beqz	a5,80000bf4 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000be0:	50d000ef          	jal	800018ec <mycpu>
    80000be4:	5d3c                	lw	a5,120(a0)
    80000be6:	2785                	addiw	a5,a5,1
    80000be8:	dd3c                	sw	a5,120(a0)
}
    80000bea:	60e2                	ld	ra,24(sp)
    80000bec:	6442                	ld	s0,16(sp)
    80000bee:	64a2                	ld	s1,8(sp)
    80000bf0:	6105                	addi	sp,sp,32
    80000bf2:	8082                	ret
    mycpu()->intena = old;
    80000bf4:	4f9000ef          	jal	800018ec <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bf8:	8085                	srli	s1,s1,0x1
    80000bfa:	8885                	andi	s1,s1,1
    80000bfc:	dd64                	sw	s1,124(a0)
    80000bfe:	b7cd                	j	80000be0 <push_off+0x20>

0000000080000c00 <acquire>:
{
    80000c00:	1101                	addi	sp,sp,-32
    80000c02:	ec06                	sd	ra,24(sp)
    80000c04:	e822                	sd	s0,16(sp)
    80000c06:	e426                	sd	s1,8(sp)
    80000c08:	1000                	addi	s0,sp,32
    80000c0a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c0c:	fb5ff0ef          	jal	80000bc0 <push_off>
  if(holding(lk))
    80000c10:	8526                	mv	a0,s1
    80000c12:	f85ff0ef          	jal	80000b96 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c16:	4705                	li	a4,1
  if(holding(lk))
    80000c18:	e105                	bnez	a0,80000c38 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c1a:	87ba                	mv	a5,a4
    80000c1c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c20:	2781                	sext.w	a5,a5
    80000c22:	ffe5                	bnez	a5,80000c1a <acquire+0x1a>
  __sync_synchronize();
    80000c24:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c28:	4c5000ef          	jal	800018ec <mycpu>
    80000c2c:	e888                	sd	a0,16(s1)
}
    80000c2e:	60e2                	ld	ra,24(sp)
    80000c30:	6442                	ld	s0,16(sp)
    80000c32:	64a2                	ld	s1,8(sp)
    80000c34:	6105                	addi	sp,sp,32
    80000c36:	8082                	ret
    panic("acquire");
    80000c38:	00007517          	auipc	a0,0x7
    80000c3c:	41850513          	addi	a0,a0,1048 # 80008050 <etext+0x50>
    80000c40:	bd3ff0ef          	jal	80000812 <panic>

0000000080000c44 <pop_off>:

void
pop_off(void)
{
    80000c44:	1141                	addi	sp,sp,-16
    80000c46:	e406                	sd	ra,8(sp)
    80000c48:	e022                	sd	s0,0(sp)
    80000c4a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c4c:	4a1000ef          	jal	800018ec <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c50:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c54:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c56:	e78d                	bnez	a5,80000c80 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c58:	5d3c                	lw	a5,120(a0)
    80000c5a:	02f05963          	blez	a5,80000c8c <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c5e:	37fd                	addiw	a5,a5,-1
    80000c60:	0007871b          	sext.w	a4,a5
    80000c64:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c66:	eb09                	bnez	a4,80000c78 <pop_off+0x34>
    80000c68:	5d7c                	lw	a5,124(a0)
    80000c6a:	c799                	beqz	a5,80000c78 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c6c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c70:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c74:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c78:	60a2                	ld	ra,8(sp)
    80000c7a:	6402                	ld	s0,0(sp)
    80000c7c:	0141                	addi	sp,sp,16
    80000c7e:	8082                	ret
    panic("pop_off - interruptible");
    80000c80:	00007517          	auipc	a0,0x7
    80000c84:	3d850513          	addi	a0,a0,984 # 80008058 <etext+0x58>
    80000c88:	b8bff0ef          	jal	80000812 <panic>
    panic("pop_off");
    80000c8c:	00007517          	auipc	a0,0x7
    80000c90:	3e450513          	addi	a0,a0,996 # 80008070 <etext+0x70>
    80000c94:	b7fff0ef          	jal	80000812 <panic>

0000000080000c98 <release>:
{
    80000c98:	1101                	addi	sp,sp,-32
    80000c9a:	ec06                	sd	ra,24(sp)
    80000c9c:	e822                	sd	s0,16(sp)
    80000c9e:	e426                	sd	s1,8(sp)
    80000ca0:	1000                	addi	s0,sp,32
    80000ca2:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ca4:	ef3ff0ef          	jal	80000b96 <holding>
    80000ca8:	c105                	beqz	a0,80000cc8 <release+0x30>
  lk->cpu = 0;
    80000caa:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cae:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cb2:	0f50000f          	fence	iorw,ow
    80000cb6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cba:	f8bff0ef          	jal	80000c44 <pop_off>
}
    80000cbe:	60e2                	ld	ra,24(sp)
    80000cc0:	6442                	ld	s0,16(sp)
    80000cc2:	64a2                	ld	s1,8(sp)
    80000cc4:	6105                	addi	sp,sp,32
    80000cc6:	8082                	ret
    panic("release");
    80000cc8:	00007517          	auipc	a0,0x7
    80000ccc:	3b050513          	addi	a0,a0,944 # 80008078 <etext+0x78>
    80000cd0:	b43ff0ef          	jal	80000812 <panic>

0000000080000cd4 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd4:	1141                	addi	sp,sp,-16
    80000cd6:	e422                	sd	s0,8(sp)
    80000cd8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cda:	ca19                	beqz	a2,80000cf0 <memset+0x1c>
    80000cdc:	87aa                	mv	a5,a0
    80000cde:	1602                	slli	a2,a2,0x20
    80000ce0:	9201                	srli	a2,a2,0x20
    80000ce2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cea:	0785                	addi	a5,a5,1
    80000cec:	fee79de3          	bne	a5,a4,80000ce6 <memset+0x12>
  }
  return dst;
}
    80000cf0:	6422                	ld	s0,8(sp)
    80000cf2:	0141                	addi	sp,sp,16
    80000cf4:	8082                	ret

0000000080000cf6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf6:	1141                	addi	sp,sp,-16
    80000cf8:	e422                	sd	s0,8(sp)
    80000cfa:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfc:	ca05                	beqz	a2,80000d2c <memcmp+0x36>
    80000cfe:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d02:	1682                	slli	a3,a3,0x20
    80000d04:	9281                	srli	a3,a3,0x20
    80000d06:	0685                	addi	a3,a3,1
    80000d08:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d0a:	00054783          	lbu	a5,0(a0)
    80000d0e:	0005c703          	lbu	a4,0(a1)
    80000d12:	00e79863          	bne	a5,a4,80000d22 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d16:	0505                	addi	a0,a0,1
    80000d18:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d1a:	fed518e3          	bne	a0,a3,80000d0a <memcmp+0x14>
  }

  return 0;
    80000d1e:	4501                	li	a0,0
    80000d20:	a019                	j	80000d26 <memcmp+0x30>
      return *s1 - *s2;
    80000d22:	40e7853b          	subw	a0,a5,a4
}
    80000d26:	6422                	ld	s0,8(sp)
    80000d28:	0141                	addi	sp,sp,16
    80000d2a:	8082                	ret
  return 0;
    80000d2c:	4501                	li	a0,0
    80000d2e:	bfe5                	j	80000d26 <memcmp+0x30>

0000000080000d30 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d30:	1141                	addi	sp,sp,-16
    80000d32:	e422                	sd	s0,8(sp)
    80000d34:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d36:	c205                	beqz	a2,80000d56 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d38:	02a5e263          	bltu	a1,a0,80000d5c <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3c:	1602                	slli	a2,a2,0x20
    80000d3e:	9201                	srli	a2,a2,0x20
    80000d40:	00c587b3          	add	a5,a1,a2
{
    80000d44:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d46:	0585                	addi	a1,a1,1
    80000d48:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ff9d329>
    80000d4a:	fff5c683          	lbu	a3,-1(a1)
    80000d4e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d52:	feb79ae3          	bne	a5,a1,80000d46 <memmove+0x16>

  return dst;
}
    80000d56:	6422                	ld	s0,8(sp)
    80000d58:	0141                	addi	sp,sp,16
    80000d5a:	8082                	ret
  if(s < d && s + n > d){
    80000d5c:	02061693          	slli	a3,a2,0x20
    80000d60:	9281                	srli	a3,a3,0x20
    80000d62:	00d58733          	add	a4,a1,a3
    80000d66:	fce57be3          	bgeu	a0,a4,80000d3c <memmove+0xc>
    d += n;
    80000d6a:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6c:	fff6079b          	addiw	a5,a2,-1
    80000d70:	1782                	slli	a5,a5,0x20
    80000d72:	9381                	srli	a5,a5,0x20
    80000d74:	fff7c793          	not	a5,a5
    80000d78:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d7a:	177d                	addi	a4,a4,-1
    80000d7c:	16fd                	addi	a3,a3,-1
    80000d7e:	00074603          	lbu	a2,0(a4)
    80000d82:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d86:	fef71ae3          	bne	a4,a5,80000d7a <memmove+0x4a>
    80000d8a:	b7f1                	j	80000d56 <memmove+0x26>

0000000080000d8c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8c:	1141                	addi	sp,sp,-16
    80000d8e:	e406                	sd	ra,8(sp)
    80000d90:	e022                	sd	s0,0(sp)
    80000d92:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d94:	f9dff0ef          	jal	80000d30 <memmove>
}
    80000d98:	60a2                	ld	ra,8(sp)
    80000d9a:	6402                	ld	s0,0(sp)
    80000d9c:	0141                	addi	sp,sp,16
    80000d9e:	8082                	ret

0000000080000da0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da0:	1141                	addi	sp,sp,-16
    80000da2:	e422                	sd	s0,8(sp)
    80000da4:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da6:	ce11                	beqz	a2,80000dc2 <strncmp+0x22>
    80000da8:	00054783          	lbu	a5,0(a0)
    80000dac:	cf89                	beqz	a5,80000dc6 <strncmp+0x26>
    80000dae:	0005c703          	lbu	a4,0(a1)
    80000db2:	00f71a63          	bne	a4,a5,80000dc6 <strncmp+0x26>
    n--, p++, q++;
    80000db6:	367d                	addiw	a2,a2,-1
    80000db8:	0505                	addi	a0,a0,1
    80000dba:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbc:	f675                	bnez	a2,80000da8 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbe:	4501                	li	a0,0
    80000dc0:	a801                	j	80000dd0 <strncmp+0x30>
    80000dc2:	4501                	li	a0,0
    80000dc4:	a031                	j	80000dd0 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	addi	sp,sp,16
    80000dd4:	8082                	ret

0000000080000dd6 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd6:	1141                	addi	sp,sp,-16
    80000dd8:	e422                	sd	s0,8(sp)
    80000dda:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000ddc:	87aa                	mv	a5,a0
    80000dde:	86b2                	mv	a3,a2
    80000de0:	367d                	addiw	a2,a2,-1
    80000de2:	02d05563          	blez	a3,80000e0c <strncpy+0x36>
    80000de6:	0785                	addi	a5,a5,1
    80000de8:	0005c703          	lbu	a4,0(a1)
    80000dec:	fee78fa3          	sb	a4,-1(a5)
    80000df0:	0585                	addi	a1,a1,1
    80000df2:	f775                	bnez	a4,80000dde <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df4:	873e                	mv	a4,a5
    80000df6:	9fb5                	addw	a5,a5,a3
    80000df8:	37fd                	addiw	a5,a5,-1
    80000dfa:	00c05963          	blez	a2,80000e0c <strncpy+0x36>
    *s++ = 0;
    80000dfe:	0705                	addi	a4,a4,1
    80000e00:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e04:	40e786bb          	subw	a3,a5,a4
    80000e08:	fed04be3          	bgtz	a3,80000dfe <strncpy+0x28>
  return os;
}
    80000e0c:	6422                	ld	s0,8(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e18:	02c05363          	blez	a2,80000e3e <safestrcpy+0x2c>
    80000e1c:	fff6069b          	addiw	a3,a2,-1
    80000e20:	1682                	slli	a3,a3,0x20
    80000e22:	9281                	srli	a3,a3,0x20
    80000e24:	96ae                	add	a3,a3,a1
    80000e26:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e28:	00d58963          	beq	a1,a3,80000e3a <safestrcpy+0x28>
    80000e2c:	0585                	addi	a1,a1,1
    80000e2e:	0785                	addi	a5,a5,1
    80000e30:	fff5c703          	lbu	a4,-1(a1)
    80000e34:	fee78fa3          	sb	a4,-1(a5)
    80000e38:	fb65                	bnez	a4,80000e28 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e3e:	6422                	ld	s0,8(sp)
    80000e40:	0141                	addi	sp,sp,16
    80000e42:	8082                	ret

0000000080000e44 <strlen>:

int
strlen(const char *s)
{
    80000e44:	1141                	addi	sp,sp,-16
    80000e46:	e422                	sd	s0,8(sp)
    80000e48:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4a:	00054783          	lbu	a5,0(a0)
    80000e4e:	cf91                	beqz	a5,80000e6a <strlen+0x26>
    80000e50:	0505                	addi	a0,a0,1
    80000e52:	87aa                	mv	a5,a0
    80000e54:	86be                	mv	a3,a5
    80000e56:	0785                	addi	a5,a5,1
    80000e58:	fff7c703          	lbu	a4,-1(a5)
    80000e5c:	ff65                	bnez	a4,80000e54 <strlen+0x10>
    80000e5e:	40a6853b          	subw	a0,a3,a0
    80000e62:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e64:	6422                	ld	s0,8(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6a:	4501                	li	a0,0
    80000e6c:	bfe5                	j	80000e64 <strlen+0x20>

0000000080000e6e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e6e:	1141                	addi	sp,sp,-16
    80000e70:	e406                	sd	ra,8(sp)
    80000e72:	e022                	sd	s0,0(sp)
    80000e74:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e76:	267000ef          	jal	800018dc <cpuid>
    fslog_init();
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e7a:	00008717          	auipc	a4,0x8
    80000e7e:	a9670713          	addi	a4,a4,-1386 # 80008910 <started>
  if(cpuid() == 0){
    80000e82:	c51d                	beqz	a0,80000eb0 <main+0x42>
    while(started == 0)
    80000e84:	431c                	lw	a5,0(a4)
    80000e86:	2781                	sext.w	a5,a5
    80000e88:	dff5                	beqz	a5,80000e84 <main+0x16>
      ;
    __sync_synchronize();
    80000e8a:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e8e:	24f000ef          	jal	800018dc <cpuid>
    80000e92:	85aa                	mv	a1,a0
    80000e94:	00007517          	auipc	a0,0x7
    80000e98:	20c50513          	addi	a0,a0,524 # 800080a0 <etext+0xa0>
    80000e9c:	e90ff0ef          	jal	8000052c <printf>
    kvminithart();    // turn on paging
    80000ea0:	088000ef          	jal	80000f28 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ea4:	596010ef          	jal	8000243a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ea8:	0b1040ef          	jal	80005758 <plicinithart>
  }

  scheduler();        
    80000eac:	6cf000ef          	jal	80001d7a <scheduler>
    consoleinit();
    80000eb0:	d92ff0ef          	jal	80000442 <consoleinit>
    printfinit();
    80000eb4:	99bff0ef          	jal	8000084e <printfinit>
    printf("\n");
    80000eb8:	00007517          	auipc	a0,0x7
    80000ebc:	1c850513          	addi	a0,a0,456 # 80008080 <etext+0x80>
    80000ec0:	e6cff0ef          	jal	8000052c <printf>
    printf("xv6 kernel is booting\n");
    80000ec4:	00007517          	auipc	a0,0x7
    80000ec8:	1c450513          	addi	a0,a0,452 # 80008088 <etext+0x88>
    80000ecc:	e60ff0ef          	jal	8000052c <printf>
    printf("\n");
    80000ed0:	00007517          	auipc	a0,0x7
    80000ed4:	1b050513          	addi	a0,a0,432 # 80008080 <etext+0x80>
    80000ed8:	e54ff0ef          	jal	8000052c <printf>
    kinit();         // physical page allocator
    80000edc:	c21ff0ef          	jal	80000afc <kinit>
    kvminit();       // create kernel page table
    80000ee0:	2d2000ef          	jal	800011b2 <kvminit>
    kvminithart();   // turn on paging
    80000ee4:	044000ef          	jal	80000f28 <kvminithart>
    procinit();      // process table
    80000ee8:	13f000ef          	jal	80001826 <procinit>
    trapinit();      // trap vectors
    80000eec:	52a010ef          	jal	80002416 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ef0:	54a010ef          	jal	8000243a <trapinithart>
    plicinit();      // set up interrupt controller
    80000ef4:	04b040ef          	jal	8000573e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ef8:	061040ef          	jal	80005758 <plicinithart>
    binit();         // buffer cache
    80000efc:	415010ef          	jal	80002b10 <binit>
    iinit();         // inode table
    80000f00:	3e8020ef          	jal	800032e8 <iinit>
    fileinit();      // file table
    80000f04:	370030ef          	jal	80004274 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f08:	141040ef          	jal	80005848 <virtio_disk_init>
    cslog_init();
    80000f0c:	5ef040ef          	jal	80005cfa <cslog_init>
    fslog_init();
    80000f10:	17e050ef          	jal	8000608e <fslog_init>
    userinit();      // first user process
    80000f14:	4bb000ef          	jal	80001bce <userinit>
    __sync_synchronize();
    80000f18:	0ff0000f          	fence
    started = 1;
    80000f1c:	4785                	li	a5,1
    80000f1e:	00008717          	auipc	a4,0x8
    80000f22:	9ef72923          	sw	a5,-1550(a4) # 80008910 <started>
    80000f26:	b759                	j	80000eac <main+0x3e>

0000000080000f28 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f28:	1141                	addi	sp,sp,-16
    80000f2a:	e422                	sd	s0,8(sp)
    80000f2c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f2e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f32:	00008797          	auipc	a5,0x8
    80000f36:	9e67b783          	ld	a5,-1562(a5) # 80008918 <kernel_pagetable>
    80000f3a:	83b1                	srli	a5,a5,0xc
    80000f3c:	577d                	li	a4,-1
    80000f3e:	177e                	slli	a4,a4,0x3f
    80000f40:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f42:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f46:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f4a:	6422                	ld	s0,8(sp)
    80000f4c:	0141                	addi	sp,sp,16
    80000f4e:	8082                	ret

0000000080000f50 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f50:	7139                	addi	sp,sp,-64
    80000f52:	fc06                	sd	ra,56(sp)
    80000f54:	f822                	sd	s0,48(sp)
    80000f56:	f426                	sd	s1,40(sp)
    80000f58:	f04a                	sd	s2,32(sp)
    80000f5a:	ec4e                	sd	s3,24(sp)
    80000f5c:	e852                	sd	s4,16(sp)
    80000f5e:	e456                	sd	s5,8(sp)
    80000f60:	e05a                	sd	s6,0(sp)
    80000f62:	0080                	addi	s0,sp,64
    80000f64:	84aa                	mv	s1,a0
    80000f66:	89ae                	mv	s3,a1
    80000f68:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f6a:	57fd                	li	a5,-1
    80000f6c:	83e9                	srli	a5,a5,0x1a
    80000f6e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f70:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f72:	02b7fc63          	bgeu	a5,a1,80000faa <walk+0x5a>
    panic("walk");
    80000f76:	00007517          	auipc	a0,0x7
    80000f7a:	14250513          	addi	a0,a0,322 # 800080b8 <etext+0xb8>
    80000f7e:	895ff0ef          	jal	80000812 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f82:	060a8263          	beqz	s5,80000fe6 <walk+0x96>
    80000f86:	babff0ef          	jal	80000b30 <kalloc>
    80000f8a:	84aa                	mv	s1,a0
    80000f8c:	c139                	beqz	a0,80000fd2 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f8e:	6605                	lui	a2,0x1
    80000f90:	4581                	li	a1,0
    80000f92:	d43ff0ef          	jal	80000cd4 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f96:	00c4d793          	srli	a5,s1,0xc
    80000f9a:	07aa                	slli	a5,a5,0xa
    80000f9c:	0017e793          	ori	a5,a5,1
    80000fa0:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000fa4:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ff9d31f>
    80000fa6:	036a0063          	beq	s4,s6,80000fc6 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000faa:	0149d933          	srl	s2,s3,s4
    80000fae:	1ff97913          	andi	s2,s2,511
    80000fb2:	090e                	slli	s2,s2,0x3
    80000fb4:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fb6:	00093483          	ld	s1,0(s2)
    80000fba:	0014f793          	andi	a5,s1,1
    80000fbe:	d3f1                	beqz	a5,80000f82 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fc0:	80a9                	srli	s1,s1,0xa
    80000fc2:	04b2                	slli	s1,s1,0xc
    80000fc4:	b7c5                	j	80000fa4 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fc6:	00c9d513          	srli	a0,s3,0xc
    80000fca:	1ff57513          	andi	a0,a0,511
    80000fce:	050e                	slli	a0,a0,0x3
    80000fd0:	9526                	add	a0,a0,s1
}
    80000fd2:	70e2                	ld	ra,56(sp)
    80000fd4:	7442                	ld	s0,48(sp)
    80000fd6:	74a2                	ld	s1,40(sp)
    80000fd8:	7902                	ld	s2,32(sp)
    80000fda:	69e2                	ld	s3,24(sp)
    80000fdc:	6a42                	ld	s4,16(sp)
    80000fde:	6aa2                	ld	s5,8(sp)
    80000fe0:	6b02                	ld	s6,0(sp)
    80000fe2:	6121                	addi	sp,sp,64
    80000fe4:	8082                	ret
        return 0;
    80000fe6:	4501                	li	a0,0
    80000fe8:	b7ed                	j	80000fd2 <walk+0x82>

0000000080000fea <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fea:	57fd                	li	a5,-1
    80000fec:	83e9                	srli	a5,a5,0x1a
    80000fee:	00b7f463          	bgeu	a5,a1,80000ff6 <walkaddr+0xc>
    return 0;
    80000ff2:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000ff4:	8082                	ret
{
    80000ff6:	1141                	addi	sp,sp,-16
    80000ff8:	e406                	sd	ra,8(sp)
    80000ffa:	e022                	sd	s0,0(sp)
    80000ffc:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000ffe:	4601                	li	a2,0
    80001000:	f51ff0ef          	jal	80000f50 <walk>
  if(pte == 0)
    80001004:	c105                	beqz	a0,80001024 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80001006:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001008:	0117f693          	andi	a3,a5,17
    8000100c:	4745                	li	a4,17
    return 0;
    8000100e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001010:	00e68663          	beq	a3,a4,8000101c <walkaddr+0x32>
}
    80001014:	60a2                	ld	ra,8(sp)
    80001016:	6402                	ld	s0,0(sp)
    80001018:	0141                	addi	sp,sp,16
    8000101a:	8082                	ret
  pa = PTE2PA(*pte);
    8000101c:	83a9                	srli	a5,a5,0xa
    8000101e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001022:	bfcd                	j	80001014 <walkaddr+0x2a>
    return 0;
    80001024:	4501                	li	a0,0
    80001026:	b7fd                	j	80001014 <walkaddr+0x2a>

0000000080001028 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001028:	715d                	addi	sp,sp,-80
    8000102a:	e486                	sd	ra,72(sp)
    8000102c:	e0a2                	sd	s0,64(sp)
    8000102e:	fc26                	sd	s1,56(sp)
    80001030:	f84a                	sd	s2,48(sp)
    80001032:	f44e                	sd	s3,40(sp)
    80001034:	f052                	sd	s4,32(sp)
    80001036:	ec56                	sd	s5,24(sp)
    80001038:	e85a                	sd	s6,16(sp)
    8000103a:	e45e                	sd	s7,8(sp)
    8000103c:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000103e:	03459793          	slli	a5,a1,0x34
    80001042:	e7a9                	bnez	a5,8000108c <mappages+0x64>
    80001044:	8aaa                	mv	s5,a0
    80001046:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001048:	03461793          	slli	a5,a2,0x34
    8000104c:	e7b1                	bnez	a5,80001098 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000104e:	ca39                	beqz	a2,800010a4 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001050:	77fd                	lui	a5,0xfffff
    80001052:	963e                	add	a2,a2,a5
    80001054:	00b609b3          	add	s3,a2,a1
  a = va;
    80001058:	892e                	mv	s2,a1
    8000105a:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000105e:	6b85                	lui	s7,0x1
    80001060:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001064:	4605                	li	a2,1
    80001066:	85ca                	mv	a1,s2
    80001068:	8556                	mv	a0,s5
    8000106a:	ee7ff0ef          	jal	80000f50 <walk>
    8000106e:	c539                	beqz	a0,800010bc <mappages+0x94>
    if(*pte & PTE_V)
    80001070:	611c                	ld	a5,0(a0)
    80001072:	8b85                	andi	a5,a5,1
    80001074:	ef95                	bnez	a5,800010b0 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001076:	80b1                	srli	s1,s1,0xc
    80001078:	04aa                	slli	s1,s1,0xa
    8000107a:	0164e4b3          	or	s1,s1,s6
    8000107e:	0014e493          	ori	s1,s1,1
    80001082:	e104                	sd	s1,0(a0)
    if(a == last)
    80001084:	05390863          	beq	s2,s3,800010d4 <mappages+0xac>
    a += PGSIZE;
    80001088:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000108a:	bfd9                	j	80001060 <mappages+0x38>
    panic("mappages: va not aligned");
    8000108c:	00007517          	auipc	a0,0x7
    80001090:	03450513          	addi	a0,a0,52 # 800080c0 <etext+0xc0>
    80001094:	f7eff0ef          	jal	80000812 <panic>
    panic("mappages: size not aligned");
    80001098:	00007517          	auipc	a0,0x7
    8000109c:	04850513          	addi	a0,a0,72 # 800080e0 <etext+0xe0>
    800010a0:	f72ff0ef          	jal	80000812 <panic>
    panic("mappages: size");
    800010a4:	00007517          	auipc	a0,0x7
    800010a8:	05c50513          	addi	a0,a0,92 # 80008100 <etext+0x100>
    800010ac:	f66ff0ef          	jal	80000812 <panic>
      panic("mappages: remap");
    800010b0:	00007517          	auipc	a0,0x7
    800010b4:	06050513          	addi	a0,a0,96 # 80008110 <etext+0x110>
    800010b8:	f5aff0ef          	jal	80000812 <panic>
      return -1;
    800010bc:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010be:	60a6                	ld	ra,72(sp)
    800010c0:	6406                	ld	s0,64(sp)
    800010c2:	74e2                	ld	s1,56(sp)
    800010c4:	7942                	ld	s2,48(sp)
    800010c6:	79a2                	ld	s3,40(sp)
    800010c8:	7a02                	ld	s4,32(sp)
    800010ca:	6ae2                	ld	s5,24(sp)
    800010cc:	6b42                	ld	s6,16(sp)
    800010ce:	6ba2                	ld	s7,8(sp)
    800010d0:	6161                	addi	sp,sp,80
    800010d2:	8082                	ret
  return 0;
    800010d4:	4501                	li	a0,0
    800010d6:	b7e5                	j	800010be <mappages+0x96>

00000000800010d8 <kvmmap>:
{
    800010d8:	1141                	addi	sp,sp,-16
    800010da:	e406                	sd	ra,8(sp)
    800010dc:	e022                	sd	s0,0(sp)
    800010de:	0800                	addi	s0,sp,16
    800010e0:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010e2:	86b2                	mv	a3,a2
    800010e4:	863e                	mv	a2,a5
    800010e6:	f43ff0ef          	jal	80001028 <mappages>
    800010ea:	e509                	bnez	a0,800010f4 <kvmmap+0x1c>
}
    800010ec:	60a2                	ld	ra,8(sp)
    800010ee:	6402                	ld	s0,0(sp)
    800010f0:	0141                	addi	sp,sp,16
    800010f2:	8082                	ret
    panic("kvmmap");
    800010f4:	00007517          	auipc	a0,0x7
    800010f8:	02c50513          	addi	a0,a0,44 # 80008120 <etext+0x120>
    800010fc:	f16ff0ef          	jal	80000812 <panic>

0000000080001100 <kvmmake>:
{
    80001100:	1101                	addi	sp,sp,-32
    80001102:	ec06                	sd	ra,24(sp)
    80001104:	e822                	sd	s0,16(sp)
    80001106:	e426                	sd	s1,8(sp)
    80001108:	e04a                	sd	s2,0(sp)
    8000110a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000110c:	a25ff0ef          	jal	80000b30 <kalloc>
    80001110:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001112:	6605                	lui	a2,0x1
    80001114:	4581                	li	a1,0
    80001116:	bbfff0ef          	jal	80000cd4 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000111a:	4719                	li	a4,6
    8000111c:	6685                	lui	a3,0x1
    8000111e:	10000637          	lui	a2,0x10000
    80001122:	100005b7          	lui	a1,0x10000
    80001126:	8526                	mv	a0,s1
    80001128:	fb1ff0ef          	jal	800010d8 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000112c:	4719                	li	a4,6
    8000112e:	6685                	lui	a3,0x1
    80001130:	10001637          	lui	a2,0x10001
    80001134:	100015b7          	lui	a1,0x10001
    80001138:	8526                	mv	a0,s1
    8000113a:	f9fff0ef          	jal	800010d8 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000113e:	4719                	li	a4,6
    80001140:	040006b7          	lui	a3,0x4000
    80001144:	0c000637          	lui	a2,0xc000
    80001148:	0c0005b7          	lui	a1,0xc000
    8000114c:	8526                	mv	a0,s1
    8000114e:	f8bff0ef          	jal	800010d8 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001152:	00007917          	auipc	s2,0x7
    80001156:	eae90913          	addi	s2,s2,-338 # 80008000 <etext>
    8000115a:	4729                	li	a4,10
    8000115c:	80007697          	auipc	a3,0x80007
    80001160:	ea468693          	addi	a3,a3,-348 # 8000 <_entry-0x7fff8000>
    80001164:	4605                	li	a2,1
    80001166:	067e                	slli	a2,a2,0x1f
    80001168:	85b2                	mv	a1,a2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f6dff0ef          	jal	800010d8 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001170:	46c5                	li	a3,17
    80001172:	06ee                	slli	a3,a3,0x1b
    80001174:	4719                	li	a4,6
    80001176:	412686b3          	sub	a3,a3,s2
    8000117a:	864a                	mv	a2,s2
    8000117c:	85ca                	mv	a1,s2
    8000117e:	8526                	mv	a0,s1
    80001180:	f59ff0ef          	jal	800010d8 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001184:	4729                	li	a4,10
    80001186:	6685                	lui	a3,0x1
    80001188:	00006617          	auipc	a2,0x6
    8000118c:	e7860613          	addi	a2,a2,-392 # 80007000 <_trampoline>
    80001190:	040005b7          	lui	a1,0x4000
    80001194:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001196:	05b2                	slli	a1,a1,0xc
    80001198:	8526                	mv	a0,s1
    8000119a:	f3fff0ef          	jal	800010d8 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000119e:	8526                	mv	a0,s1
    800011a0:	5ee000ef          	jal	8000178e <proc_mapstacks>
}
    800011a4:	8526                	mv	a0,s1
    800011a6:	60e2                	ld	ra,24(sp)
    800011a8:	6442                	ld	s0,16(sp)
    800011aa:	64a2                	ld	s1,8(sp)
    800011ac:	6902                	ld	s2,0(sp)
    800011ae:	6105                	addi	sp,sp,32
    800011b0:	8082                	ret

00000000800011b2 <kvminit>:
{
    800011b2:	1141                	addi	sp,sp,-16
    800011b4:	e406                	sd	ra,8(sp)
    800011b6:	e022                	sd	s0,0(sp)
    800011b8:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011ba:	f47ff0ef          	jal	80001100 <kvmmake>
    800011be:	00007797          	auipc	a5,0x7
    800011c2:	74a7bd23          	sd	a0,1882(a5) # 80008918 <kernel_pagetable>
}
    800011c6:	60a2                	ld	ra,8(sp)
    800011c8:	6402                	ld	s0,0(sp)
    800011ca:	0141                	addi	sp,sp,16
    800011cc:	8082                	ret

00000000800011ce <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800011ce:	1101                	addi	sp,sp,-32
    800011d0:	ec06                	sd	ra,24(sp)
    800011d2:	e822                	sd	s0,16(sp)
    800011d4:	e426                	sd	s1,8(sp)
    800011d6:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800011d8:	959ff0ef          	jal	80000b30 <kalloc>
    800011dc:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011de:	c509                	beqz	a0,800011e8 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011e0:	6605                	lui	a2,0x1
    800011e2:	4581                	li	a1,0
    800011e4:	af1ff0ef          	jal	80000cd4 <memset>
  return pagetable;
}
    800011e8:	8526                	mv	a0,s1
    800011ea:	60e2                	ld	ra,24(sp)
    800011ec:	6442                	ld	s0,16(sp)
    800011ee:	64a2                	ld	s1,8(sp)
    800011f0:	6105                	addi	sp,sp,32
    800011f2:	8082                	ret

00000000800011f4 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011f4:	7139                	addi	sp,sp,-64
    800011f6:	fc06                	sd	ra,56(sp)
    800011f8:	f822                	sd	s0,48(sp)
    800011fa:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011fc:	03459793          	slli	a5,a1,0x34
    80001200:	e38d                	bnez	a5,80001222 <uvmunmap+0x2e>
    80001202:	f04a                	sd	s2,32(sp)
    80001204:	ec4e                	sd	s3,24(sp)
    80001206:	e852                	sd	s4,16(sp)
    80001208:	e456                	sd	s5,8(sp)
    8000120a:	e05a                	sd	s6,0(sp)
    8000120c:	8a2a                	mv	s4,a0
    8000120e:	892e                	mv	s2,a1
    80001210:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001212:	0632                	slli	a2,a2,0xc
    80001214:	00b609b3          	add	s3,a2,a1
    80001218:	6b05                	lui	s6,0x1
    8000121a:	0535f963          	bgeu	a1,s3,8000126c <uvmunmap+0x78>
    8000121e:	f426                	sd	s1,40(sp)
    80001220:	a015                	j	80001244 <uvmunmap+0x50>
    80001222:	f426                	sd	s1,40(sp)
    80001224:	f04a                	sd	s2,32(sp)
    80001226:	ec4e                	sd	s3,24(sp)
    80001228:	e852                	sd	s4,16(sp)
    8000122a:	e456                	sd	s5,8(sp)
    8000122c:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000122e:	00007517          	auipc	a0,0x7
    80001232:	efa50513          	addi	a0,a0,-262 # 80008128 <etext+0x128>
    80001236:	ddcff0ef          	jal	80000812 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000123a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000123e:	995a                	add	s2,s2,s6
    80001240:	03397563          	bgeu	s2,s3,8000126a <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001244:	4601                	li	a2,0
    80001246:	85ca                	mv	a1,s2
    80001248:	8552                	mv	a0,s4
    8000124a:	d07ff0ef          	jal	80000f50 <walk>
    8000124e:	84aa                	mv	s1,a0
    80001250:	d57d                	beqz	a0,8000123e <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001252:	611c                	ld	a5,0(a0)
    80001254:	0017f713          	andi	a4,a5,1
    80001258:	d37d                	beqz	a4,8000123e <uvmunmap+0x4a>
    if(do_free){
    8000125a:	fe0a80e3          	beqz	s5,8000123a <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    8000125e:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001260:	00c79513          	slli	a0,a5,0xc
    80001264:	feaff0ef          	jal	80000a4e <kfree>
    80001268:	bfc9                	j	8000123a <uvmunmap+0x46>
    8000126a:	74a2                	ld	s1,40(sp)
    8000126c:	7902                	ld	s2,32(sp)
    8000126e:	69e2                	ld	s3,24(sp)
    80001270:	6a42                	ld	s4,16(sp)
    80001272:	6aa2                	ld	s5,8(sp)
    80001274:	6b02                	ld	s6,0(sp)
  }
}
    80001276:	70e2                	ld	ra,56(sp)
    80001278:	7442                	ld	s0,48(sp)
    8000127a:	6121                	addi	sp,sp,64
    8000127c:	8082                	ret

000000008000127e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000127e:	1101                	addi	sp,sp,-32
    80001280:	ec06                	sd	ra,24(sp)
    80001282:	e822                	sd	s0,16(sp)
    80001284:	e426                	sd	s1,8(sp)
    80001286:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001288:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000128a:	00b67d63          	bgeu	a2,a1,800012a4 <uvmdealloc+0x26>
    8000128e:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001290:	6785                	lui	a5,0x1
    80001292:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001294:	00f60733          	add	a4,a2,a5
    80001298:	76fd                	lui	a3,0xfffff
    8000129a:	8f75                	and	a4,a4,a3
    8000129c:	97ae                	add	a5,a5,a1
    8000129e:	8ff5                	and	a5,a5,a3
    800012a0:	00f76863          	bltu	a4,a5,800012b0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012a4:	8526                	mv	a0,s1
    800012a6:	60e2                	ld	ra,24(sp)
    800012a8:	6442                	ld	s0,16(sp)
    800012aa:	64a2                	ld	s1,8(sp)
    800012ac:	6105                	addi	sp,sp,32
    800012ae:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012b0:	8f99                	sub	a5,a5,a4
    800012b2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012b4:	4685                	li	a3,1
    800012b6:	0007861b          	sext.w	a2,a5
    800012ba:	85ba                	mv	a1,a4
    800012bc:	f39ff0ef          	jal	800011f4 <uvmunmap>
    800012c0:	b7d5                	j	800012a4 <uvmdealloc+0x26>

00000000800012c2 <uvmalloc>:
  if(newsz < oldsz)
    800012c2:	08b66f63          	bltu	a2,a1,80001360 <uvmalloc+0x9e>
{
    800012c6:	7139                	addi	sp,sp,-64
    800012c8:	fc06                	sd	ra,56(sp)
    800012ca:	f822                	sd	s0,48(sp)
    800012cc:	ec4e                	sd	s3,24(sp)
    800012ce:	e852                	sd	s4,16(sp)
    800012d0:	e456                	sd	s5,8(sp)
    800012d2:	0080                	addi	s0,sp,64
    800012d4:	8aaa                	mv	s5,a0
    800012d6:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800012d8:	6785                	lui	a5,0x1
    800012da:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012dc:	95be                	add	a1,a1,a5
    800012de:	77fd                	lui	a5,0xfffff
    800012e0:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012e4:	08c9f063          	bgeu	s3,a2,80001364 <uvmalloc+0xa2>
    800012e8:	f426                	sd	s1,40(sp)
    800012ea:	f04a                	sd	s2,32(sp)
    800012ec:	e05a                	sd	s6,0(sp)
    800012ee:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012f0:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012f4:	83dff0ef          	jal	80000b30 <kalloc>
    800012f8:	84aa                	mv	s1,a0
    if(mem == 0){
    800012fa:	c515                	beqz	a0,80001326 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800012fc:	6605                	lui	a2,0x1
    800012fe:	4581                	li	a1,0
    80001300:	9d5ff0ef          	jal	80000cd4 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001304:	875a                	mv	a4,s6
    80001306:	86a6                	mv	a3,s1
    80001308:	6605                	lui	a2,0x1
    8000130a:	85ca                	mv	a1,s2
    8000130c:	8556                	mv	a0,s5
    8000130e:	d1bff0ef          	jal	80001028 <mappages>
    80001312:	e915                	bnez	a0,80001346 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001314:	6785                	lui	a5,0x1
    80001316:	993e                	add	s2,s2,a5
    80001318:	fd496ee3          	bltu	s2,s4,800012f4 <uvmalloc+0x32>
  return newsz;
    8000131c:	8552                	mv	a0,s4
    8000131e:	74a2                	ld	s1,40(sp)
    80001320:	7902                	ld	s2,32(sp)
    80001322:	6b02                	ld	s6,0(sp)
    80001324:	a811                	j	80001338 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    80001326:	864e                	mv	a2,s3
    80001328:	85ca                	mv	a1,s2
    8000132a:	8556                	mv	a0,s5
    8000132c:	f53ff0ef          	jal	8000127e <uvmdealloc>
      return 0;
    80001330:	4501                	li	a0,0
    80001332:	74a2                	ld	s1,40(sp)
    80001334:	7902                	ld	s2,32(sp)
    80001336:	6b02                	ld	s6,0(sp)
}
    80001338:	70e2                	ld	ra,56(sp)
    8000133a:	7442                	ld	s0,48(sp)
    8000133c:	69e2                	ld	s3,24(sp)
    8000133e:	6a42                	ld	s4,16(sp)
    80001340:	6aa2                	ld	s5,8(sp)
    80001342:	6121                	addi	sp,sp,64
    80001344:	8082                	ret
      kfree(mem);
    80001346:	8526                	mv	a0,s1
    80001348:	f06ff0ef          	jal	80000a4e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000134c:	864e                	mv	a2,s3
    8000134e:	85ca                	mv	a1,s2
    80001350:	8556                	mv	a0,s5
    80001352:	f2dff0ef          	jal	8000127e <uvmdealloc>
      return 0;
    80001356:	4501                	li	a0,0
    80001358:	74a2                	ld	s1,40(sp)
    8000135a:	7902                	ld	s2,32(sp)
    8000135c:	6b02                	ld	s6,0(sp)
    8000135e:	bfe9                	j	80001338 <uvmalloc+0x76>
    return oldsz;
    80001360:	852e                	mv	a0,a1
}
    80001362:	8082                	ret
  return newsz;
    80001364:	8532                	mv	a0,a2
    80001366:	bfc9                	j	80001338 <uvmalloc+0x76>

0000000080001368 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001368:	7179                	addi	sp,sp,-48
    8000136a:	f406                	sd	ra,40(sp)
    8000136c:	f022                	sd	s0,32(sp)
    8000136e:	ec26                	sd	s1,24(sp)
    80001370:	e84a                	sd	s2,16(sp)
    80001372:	e44e                	sd	s3,8(sp)
    80001374:	e052                	sd	s4,0(sp)
    80001376:	1800                	addi	s0,sp,48
    80001378:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000137a:	84aa                	mv	s1,a0
    8000137c:	6905                	lui	s2,0x1
    8000137e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001380:	4985                	li	s3,1
    80001382:	a819                	j	80001398 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001384:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001386:	00c79513          	slli	a0,a5,0xc
    8000138a:	fdfff0ef          	jal	80001368 <freewalk>
      pagetable[i] = 0;
    8000138e:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001392:	04a1                	addi	s1,s1,8
    80001394:	01248f63          	beq	s1,s2,800013b2 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001398:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000139a:	00f7f713          	andi	a4,a5,15
    8000139e:	ff3703e3          	beq	a4,s3,80001384 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800013a2:	8b85                	andi	a5,a5,1
    800013a4:	d7fd                	beqz	a5,80001392 <freewalk+0x2a>
      panic("freewalk: leaf");
    800013a6:	00007517          	auipc	a0,0x7
    800013aa:	d9a50513          	addi	a0,a0,-614 # 80008140 <etext+0x140>
    800013ae:	c64ff0ef          	jal	80000812 <panic>
    }
  }
  kfree((void*)pagetable);
    800013b2:	8552                	mv	a0,s4
    800013b4:	e9aff0ef          	jal	80000a4e <kfree>
}
    800013b8:	70a2                	ld	ra,40(sp)
    800013ba:	7402                	ld	s0,32(sp)
    800013bc:	64e2                	ld	s1,24(sp)
    800013be:	6942                	ld	s2,16(sp)
    800013c0:	69a2                	ld	s3,8(sp)
    800013c2:	6a02                	ld	s4,0(sp)
    800013c4:	6145                	addi	sp,sp,48
    800013c6:	8082                	ret

00000000800013c8 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
    800013d2:	84aa                	mv	s1,a0
  if(sz > 0)
    800013d4:	e989                	bnez	a1,800013e6 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800013d6:	8526                	mv	a0,s1
    800013d8:	f91ff0ef          	jal	80001368 <freewalk>
}
    800013dc:	60e2                	ld	ra,24(sp)
    800013de:	6442                	ld	s0,16(sp)
    800013e0:	64a2                	ld	s1,8(sp)
    800013e2:	6105                	addi	sp,sp,32
    800013e4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013e6:	6785                	lui	a5,0x1
    800013e8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013ea:	95be                	add	a1,a1,a5
    800013ec:	4685                	li	a3,1
    800013ee:	00c5d613          	srli	a2,a1,0xc
    800013f2:	4581                	li	a1,0
    800013f4:	e01ff0ef          	jal	800011f4 <uvmunmap>
    800013f8:	bff9                	j	800013d6 <uvmfree+0xe>

00000000800013fa <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800013fa:	ce49                	beqz	a2,80001494 <uvmcopy+0x9a>
{
    800013fc:	715d                	addi	sp,sp,-80
    800013fe:	e486                	sd	ra,72(sp)
    80001400:	e0a2                	sd	s0,64(sp)
    80001402:	fc26                	sd	s1,56(sp)
    80001404:	f84a                	sd	s2,48(sp)
    80001406:	f44e                	sd	s3,40(sp)
    80001408:	f052                	sd	s4,32(sp)
    8000140a:	ec56                	sd	s5,24(sp)
    8000140c:	e85a                	sd	s6,16(sp)
    8000140e:	e45e                	sd	s7,8(sp)
    80001410:	0880                	addi	s0,sp,80
    80001412:	8aaa                	mv	s5,a0
    80001414:	8b2e                	mv	s6,a1
    80001416:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001418:	4481                	li	s1,0
    8000141a:	a029                	j	80001424 <uvmcopy+0x2a>
    8000141c:	6785                	lui	a5,0x1
    8000141e:	94be                	add	s1,s1,a5
    80001420:	0544fe63          	bgeu	s1,s4,8000147c <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    80001424:	4601                	li	a2,0
    80001426:	85a6                	mv	a1,s1
    80001428:	8556                	mv	a0,s5
    8000142a:	b27ff0ef          	jal	80000f50 <walk>
    8000142e:	d57d                	beqz	a0,8000141c <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    80001430:	6118                	ld	a4,0(a0)
    80001432:	00177793          	andi	a5,a4,1
    80001436:	d3fd                	beqz	a5,8000141c <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    80001438:	00a75593          	srli	a1,a4,0xa
    8000143c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001440:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001444:	eecff0ef          	jal	80000b30 <kalloc>
    80001448:	89aa                	mv	s3,a0
    8000144a:	c105                	beqz	a0,8000146a <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000144c:	6605                	lui	a2,0x1
    8000144e:	85de                	mv	a1,s7
    80001450:	8e1ff0ef          	jal	80000d30 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001454:	874a                	mv	a4,s2
    80001456:	86ce                	mv	a3,s3
    80001458:	6605                	lui	a2,0x1
    8000145a:	85a6                	mv	a1,s1
    8000145c:	855a                	mv	a0,s6
    8000145e:	bcbff0ef          	jal	80001028 <mappages>
    80001462:	dd4d                	beqz	a0,8000141c <uvmcopy+0x22>
      kfree(mem);
    80001464:	854e                	mv	a0,s3
    80001466:	de8ff0ef          	jal	80000a4e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000146a:	4685                	li	a3,1
    8000146c:	00c4d613          	srli	a2,s1,0xc
    80001470:	4581                	li	a1,0
    80001472:	855a                	mv	a0,s6
    80001474:	d81ff0ef          	jal	800011f4 <uvmunmap>
  return -1;
    80001478:	557d                	li	a0,-1
    8000147a:	a011                	j	8000147e <uvmcopy+0x84>
  return 0;
    8000147c:	4501                	li	a0,0
}
    8000147e:	60a6                	ld	ra,72(sp)
    80001480:	6406                	ld	s0,64(sp)
    80001482:	74e2                	ld	s1,56(sp)
    80001484:	7942                	ld	s2,48(sp)
    80001486:	79a2                	ld	s3,40(sp)
    80001488:	7a02                	ld	s4,32(sp)
    8000148a:	6ae2                	ld	s5,24(sp)
    8000148c:	6b42                	ld	s6,16(sp)
    8000148e:	6ba2                	ld	s7,8(sp)
    80001490:	6161                	addi	sp,sp,80
    80001492:	8082                	ret
  return 0;
    80001494:	4501                	li	a0,0
}
    80001496:	8082                	ret

0000000080001498 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001498:	1141                	addi	sp,sp,-16
    8000149a:	e406                	sd	ra,8(sp)
    8000149c:	e022                	sd	s0,0(sp)
    8000149e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014a0:	4601                	li	a2,0
    800014a2:	aafff0ef          	jal	80000f50 <walk>
  if(pte == 0)
    800014a6:	c901                	beqz	a0,800014b6 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014a8:	611c                	ld	a5,0(a0)
    800014aa:	9bbd                	andi	a5,a5,-17
    800014ac:	e11c                	sd	a5,0(a0)
}
    800014ae:	60a2                	ld	ra,8(sp)
    800014b0:	6402                	ld	s0,0(sp)
    800014b2:	0141                	addi	sp,sp,16
    800014b4:	8082                	ret
    panic("uvmclear");
    800014b6:	00007517          	auipc	a0,0x7
    800014ba:	c9a50513          	addi	a0,a0,-870 # 80008150 <etext+0x150>
    800014be:	b54ff0ef          	jal	80000812 <panic>

00000000800014c2 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800014c2:	c6dd                	beqz	a3,80001570 <copyinstr+0xae>
{
    800014c4:	715d                	addi	sp,sp,-80
    800014c6:	e486                	sd	ra,72(sp)
    800014c8:	e0a2                	sd	s0,64(sp)
    800014ca:	fc26                	sd	s1,56(sp)
    800014cc:	f84a                	sd	s2,48(sp)
    800014ce:	f44e                	sd	s3,40(sp)
    800014d0:	f052                	sd	s4,32(sp)
    800014d2:	ec56                	sd	s5,24(sp)
    800014d4:	e85a                	sd	s6,16(sp)
    800014d6:	e45e                	sd	s7,8(sp)
    800014d8:	0880                	addi	s0,sp,80
    800014da:	8a2a                	mv	s4,a0
    800014dc:	8b2e                	mv	s6,a1
    800014de:	8bb2                	mv	s7,a2
    800014e0:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800014e2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014e4:	6985                	lui	s3,0x1
    800014e6:	a825                	j	8000151e <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014e8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014ec:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014ee:	37fd                	addiw	a5,a5,-1
    800014f0:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014f4:	60a6                	ld	ra,72(sp)
    800014f6:	6406                	ld	s0,64(sp)
    800014f8:	74e2                	ld	s1,56(sp)
    800014fa:	7942                	ld	s2,48(sp)
    800014fc:	79a2                	ld	s3,40(sp)
    800014fe:	7a02                	ld	s4,32(sp)
    80001500:	6ae2                	ld	s5,24(sp)
    80001502:	6b42                	ld	s6,16(sp)
    80001504:	6ba2                	ld	s7,8(sp)
    80001506:	6161                	addi	sp,sp,80
    80001508:	8082                	ret
    8000150a:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    8000150e:	9742                	add	a4,a4,a6
      --max;
    80001510:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001514:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001518:	04e58463          	beq	a1,a4,80001560 <copyinstr+0x9e>
{
    8000151c:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000151e:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001522:	85a6                	mv	a1,s1
    80001524:	8552                	mv	a0,s4
    80001526:	ac5ff0ef          	jal	80000fea <walkaddr>
    if(pa0 == 0)
    8000152a:	cd0d                	beqz	a0,80001564 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    8000152c:	417486b3          	sub	a3,s1,s7
    80001530:	96ce                	add	a3,a3,s3
    if(n > max)
    80001532:	00d97363          	bgeu	s2,a3,80001538 <copyinstr+0x76>
    80001536:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001538:	955e                	add	a0,a0,s7
    8000153a:	8d05                	sub	a0,a0,s1
    while(n > 0){
    8000153c:	c695                	beqz	a3,80001568 <copyinstr+0xa6>
    8000153e:	87da                	mv	a5,s6
    80001540:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001542:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001546:	96da                	add	a3,a3,s6
    80001548:	85be                	mv	a1,a5
      if(*p == '\0'){
    8000154a:	00f60733          	add	a4,a2,a5
    8000154e:	00074703          	lbu	a4,0(a4)
    80001552:	db59                	beqz	a4,800014e8 <copyinstr+0x26>
        *dst = *p;
    80001554:	00e78023          	sb	a4,0(a5)
      dst++;
    80001558:	0785                	addi	a5,a5,1
    while(n > 0){
    8000155a:	fed797e3          	bne	a5,a3,80001548 <copyinstr+0x86>
    8000155e:	b775                	j	8000150a <copyinstr+0x48>
    80001560:	4781                	li	a5,0
    80001562:	b771                	j	800014ee <copyinstr+0x2c>
      return -1;
    80001564:	557d                	li	a0,-1
    80001566:	b779                	j	800014f4 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001568:	6b85                	lui	s7,0x1
    8000156a:	9ba6                	add	s7,s7,s1
    8000156c:	87da                	mv	a5,s6
    8000156e:	b77d                	j	8000151c <copyinstr+0x5a>
  int got_null = 0;
    80001570:	4781                	li	a5,0
  if(got_null){
    80001572:	37fd                	addiw	a5,a5,-1
    80001574:	0007851b          	sext.w	a0,a5
}
    80001578:	8082                	ret

000000008000157a <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000157a:	1141                	addi	sp,sp,-16
    8000157c:	e406                	sd	ra,8(sp)
    8000157e:	e022                	sd	s0,0(sp)
    80001580:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001582:	4601                	li	a2,0
    80001584:	9cdff0ef          	jal	80000f50 <walk>
  if (pte == 0) {
    80001588:	c519                	beqz	a0,80001596 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    8000158a:	6108                	ld	a0,0(a0)
    8000158c:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    8000158e:	60a2                	ld	ra,8(sp)
    80001590:	6402                	ld	s0,0(sp)
    80001592:	0141                	addi	sp,sp,16
    80001594:	8082                	ret
    return 0;
    80001596:	4501                	li	a0,0
    80001598:	bfdd                	j	8000158e <ismapped+0x14>

000000008000159a <vmfault>:
{
    8000159a:	7179                	addi	sp,sp,-48
    8000159c:	f406                	sd	ra,40(sp)
    8000159e:	f022                	sd	s0,32(sp)
    800015a0:	ec26                	sd	s1,24(sp)
    800015a2:	e44e                	sd	s3,8(sp)
    800015a4:	1800                	addi	s0,sp,48
    800015a6:	89aa                	mv	s3,a0
    800015a8:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    800015aa:	35e000ef          	jal	80001908 <myproc>
  if (va >= p->sz)
    800015ae:	653c                	ld	a5,72(a0)
    800015b0:	00f4ea63          	bltu	s1,a5,800015c4 <vmfault+0x2a>
    return 0;
    800015b4:	4981                	li	s3,0
}
    800015b6:	854e                	mv	a0,s3
    800015b8:	70a2                	ld	ra,40(sp)
    800015ba:	7402                	ld	s0,32(sp)
    800015bc:	64e2                	ld	s1,24(sp)
    800015be:	69a2                	ld	s3,8(sp)
    800015c0:	6145                	addi	sp,sp,48
    800015c2:	8082                	ret
    800015c4:	e84a                	sd	s2,16(sp)
    800015c6:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    800015c8:	77fd                	lui	a5,0xfffff
    800015ca:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    800015cc:	85a6                	mv	a1,s1
    800015ce:	854e                	mv	a0,s3
    800015d0:	fabff0ef          	jal	8000157a <ismapped>
    return 0;
    800015d4:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    800015d6:	c119                	beqz	a0,800015dc <vmfault+0x42>
    800015d8:	6942                	ld	s2,16(sp)
    800015da:	bff1                	j	800015b6 <vmfault+0x1c>
    800015dc:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    800015de:	d52ff0ef          	jal	80000b30 <kalloc>
    800015e2:	8a2a                	mv	s4,a0
  if(mem == 0)
    800015e4:	c90d                	beqz	a0,80001616 <vmfault+0x7c>
  mem = (uint64) kalloc();
    800015e6:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800015e8:	6605                	lui	a2,0x1
    800015ea:	4581                	li	a1,0
    800015ec:	ee8ff0ef          	jal	80000cd4 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800015f0:	4759                	li	a4,22
    800015f2:	86d2                	mv	a3,s4
    800015f4:	6605                	lui	a2,0x1
    800015f6:	85a6                	mv	a1,s1
    800015f8:	05093503          	ld	a0,80(s2)
    800015fc:	a2dff0ef          	jal	80001028 <mappages>
    80001600:	e501                	bnez	a0,80001608 <vmfault+0x6e>
    80001602:	6942                	ld	s2,16(sp)
    80001604:	6a02                	ld	s4,0(sp)
    80001606:	bf45                	j	800015b6 <vmfault+0x1c>
    kfree((void *)mem);
    80001608:	8552                	mv	a0,s4
    8000160a:	c44ff0ef          	jal	80000a4e <kfree>
    return 0;
    8000160e:	4981                	li	s3,0
    80001610:	6942                	ld	s2,16(sp)
    80001612:	6a02                	ld	s4,0(sp)
    80001614:	b74d                	j	800015b6 <vmfault+0x1c>
    80001616:	6942                	ld	s2,16(sp)
    80001618:	6a02                	ld	s4,0(sp)
    8000161a:	bf71                	j	800015b6 <vmfault+0x1c>

000000008000161c <copyout>:
  while(len > 0){
    8000161c:	c2cd                	beqz	a3,800016be <copyout+0xa2>
{
    8000161e:	711d                	addi	sp,sp,-96
    80001620:	ec86                	sd	ra,88(sp)
    80001622:	e8a2                	sd	s0,80(sp)
    80001624:	e4a6                	sd	s1,72(sp)
    80001626:	f852                	sd	s4,48(sp)
    80001628:	f05a                	sd	s6,32(sp)
    8000162a:	ec5e                	sd	s7,24(sp)
    8000162c:	e862                	sd	s8,16(sp)
    8000162e:	1080                	addi	s0,sp,96
    80001630:	8c2a                	mv	s8,a0
    80001632:	8b2e                	mv	s6,a1
    80001634:	8bb2                	mv	s7,a2
    80001636:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80001638:	74fd                	lui	s1,0xfffff
    8000163a:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    8000163c:	57fd                	li	a5,-1
    8000163e:	83e9                	srli	a5,a5,0x1a
    80001640:	0897e163          	bltu	a5,s1,800016c2 <copyout+0xa6>
    80001644:	e0ca                	sd	s2,64(sp)
    80001646:	fc4e                	sd	s3,56(sp)
    80001648:	f456                	sd	s5,40(sp)
    8000164a:	e466                	sd	s9,8(sp)
    8000164c:	e06a                	sd	s10,0(sp)
    8000164e:	6d05                	lui	s10,0x1
    80001650:	8cbe                	mv	s9,a5
    80001652:	a015                	j	80001676 <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001654:	409b0533          	sub	a0,s6,s1
    80001658:	0009861b          	sext.w	a2,s3
    8000165c:	85de                	mv	a1,s7
    8000165e:	954a                	add	a0,a0,s2
    80001660:	ed0ff0ef          	jal	80000d30 <memmove>
    len -= n;
    80001664:	413a0a33          	sub	s4,s4,s3
    src += n;
    80001668:	9bce                	add	s7,s7,s3
  while(len > 0){
    8000166a:	040a0363          	beqz	s4,800016b0 <copyout+0x94>
    if(va0 >= MAXVA)
    8000166e:	055cec63          	bltu	s9,s5,800016c6 <copyout+0xaa>
    80001672:	84d6                	mv	s1,s5
    80001674:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80001676:	85a6                	mv	a1,s1
    80001678:	8562                	mv	a0,s8
    8000167a:	971ff0ef          	jal	80000fea <walkaddr>
    8000167e:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001680:	e901                	bnez	a0,80001690 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001682:	4601                	li	a2,0
    80001684:	85a6                	mv	a1,s1
    80001686:	8562                	mv	a0,s8
    80001688:	f13ff0ef          	jal	8000159a <vmfault>
    8000168c:	892a                	mv	s2,a0
    8000168e:	c139                	beqz	a0,800016d4 <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001690:	4601                	li	a2,0
    80001692:	85a6                	mv	a1,s1
    80001694:	8562                	mv	a0,s8
    80001696:	8bbff0ef          	jal	80000f50 <walk>
    if((*pte & PTE_W) == 0)
    8000169a:	611c                	ld	a5,0(a0)
    8000169c:	8b91                	andi	a5,a5,4
    8000169e:	c3b1                	beqz	a5,800016e2 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    800016a0:	01a48ab3          	add	s5,s1,s10
    800016a4:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    800016a8:	fb3a76e3          	bgeu	s4,s3,80001654 <copyout+0x38>
    800016ac:	89d2                	mv	s3,s4
    800016ae:	b75d                	j	80001654 <copyout+0x38>
  return 0;
    800016b0:	4501                	li	a0,0
    800016b2:	6906                	ld	s2,64(sp)
    800016b4:	79e2                	ld	s3,56(sp)
    800016b6:	7aa2                	ld	s5,40(sp)
    800016b8:	6ca2                	ld	s9,8(sp)
    800016ba:	6d02                	ld	s10,0(sp)
    800016bc:	a80d                	j	800016ee <copyout+0xd2>
    800016be:	4501                	li	a0,0
}
    800016c0:	8082                	ret
      return -1;
    800016c2:	557d                	li	a0,-1
    800016c4:	a02d                	j	800016ee <copyout+0xd2>
    800016c6:	557d                	li	a0,-1
    800016c8:	6906                	ld	s2,64(sp)
    800016ca:	79e2                	ld	s3,56(sp)
    800016cc:	7aa2                	ld	s5,40(sp)
    800016ce:	6ca2                	ld	s9,8(sp)
    800016d0:	6d02                	ld	s10,0(sp)
    800016d2:	a831                	j	800016ee <copyout+0xd2>
        return -1;
    800016d4:	557d                	li	a0,-1
    800016d6:	6906                	ld	s2,64(sp)
    800016d8:	79e2                	ld	s3,56(sp)
    800016da:	7aa2                	ld	s5,40(sp)
    800016dc:	6ca2                	ld	s9,8(sp)
    800016de:	6d02                	ld	s10,0(sp)
    800016e0:	a039                	j	800016ee <copyout+0xd2>
      return -1;
    800016e2:	557d                	li	a0,-1
    800016e4:	6906                	ld	s2,64(sp)
    800016e6:	79e2                	ld	s3,56(sp)
    800016e8:	7aa2                	ld	s5,40(sp)
    800016ea:	6ca2                	ld	s9,8(sp)
    800016ec:	6d02                	ld	s10,0(sp)
}
    800016ee:	60e6                	ld	ra,88(sp)
    800016f0:	6446                	ld	s0,80(sp)
    800016f2:	64a6                	ld	s1,72(sp)
    800016f4:	7a42                	ld	s4,48(sp)
    800016f6:	7b02                	ld	s6,32(sp)
    800016f8:	6be2                	ld	s7,24(sp)
    800016fa:	6c42                	ld	s8,16(sp)
    800016fc:	6125                	addi	sp,sp,96
    800016fe:	8082                	ret

0000000080001700 <copyin>:
  while(len > 0){
    80001700:	c6c9                	beqz	a3,8000178a <copyin+0x8a>
{
    80001702:	715d                	addi	sp,sp,-80
    80001704:	e486                	sd	ra,72(sp)
    80001706:	e0a2                	sd	s0,64(sp)
    80001708:	fc26                	sd	s1,56(sp)
    8000170a:	f84a                	sd	s2,48(sp)
    8000170c:	f44e                	sd	s3,40(sp)
    8000170e:	f052                	sd	s4,32(sp)
    80001710:	ec56                	sd	s5,24(sp)
    80001712:	e85a                	sd	s6,16(sp)
    80001714:	e45e                	sd	s7,8(sp)
    80001716:	e062                	sd	s8,0(sp)
    80001718:	0880                	addi	s0,sp,80
    8000171a:	8baa                	mv	s7,a0
    8000171c:	8aae                	mv	s5,a1
    8000171e:	8932                	mv	s2,a2
    80001720:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001722:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001724:	6b05                	lui	s6,0x1
    80001726:	a035                	j	80001752 <copyin+0x52>
    80001728:	412984b3          	sub	s1,s3,s2
    8000172c:	94da                	add	s1,s1,s6
    if(n > len)
    8000172e:	009a7363          	bgeu	s4,s1,80001734 <copyin+0x34>
    80001732:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001734:	413905b3          	sub	a1,s2,s3
    80001738:	0004861b          	sext.w	a2,s1
    8000173c:	95aa                	add	a1,a1,a0
    8000173e:	8556                	mv	a0,s5
    80001740:	df0ff0ef          	jal	80000d30 <memmove>
    len -= n;
    80001744:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001748:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000174a:	01698933          	add	s2,s3,s6
  while(len > 0){
    8000174e:	020a0163          	beqz	s4,80001770 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001752:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001756:	85ce                	mv	a1,s3
    80001758:	855e                	mv	a0,s7
    8000175a:	891ff0ef          	jal	80000fea <walkaddr>
    if(pa0 == 0) {
    8000175e:	f569                	bnez	a0,80001728 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001760:	4601                	li	a2,0
    80001762:	85ce                	mv	a1,s3
    80001764:	855e                	mv	a0,s7
    80001766:	e35ff0ef          	jal	8000159a <vmfault>
    8000176a:	fd5d                	bnez	a0,80001728 <copyin+0x28>
        return -1;
    8000176c:	557d                	li	a0,-1
    8000176e:	a011                	j	80001772 <copyin+0x72>
  return 0;
    80001770:	4501                	li	a0,0
}
    80001772:	60a6                	ld	ra,72(sp)
    80001774:	6406                	ld	s0,64(sp)
    80001776:	74e2                	ld	s1,56(sp)
    80001778:	7942                	ld	s2,48(sp)
    8000177a:	79a2                	ld	s3,40(sp)
    8000177c:	7a02                	ld	s4,32(sp)
    8000177e:	6ae2                	ld	s5,24(sp)
    80001780:	6b42                	ld	s6,16(sp)
    80001782:	6ba2                	ld	s7,8(sp)
    80001784:	6c02                	ld	s8,0(sp)
    80001786:	6161                	addi	sp,sp,80
    80001788:	8082                	ret
  return 0;
    8000178a:	4501                	li	a0,0
}
    8000178c:	8082                	ret

000000008000178e <proc_mapstacks>:
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl) {
    8000178e:	7139                	addi	sp,sp,-64
    80001790:	fc06                	sd	ra,56(sp)
    80001792:	f822                	sd	s0,48(sp)
    80001794:	f426                	sd	s1,40(sp)
    80001796:	f04a                	sd	s2,32(sp)
    80001798:	ec4e                	sd	s3,24(sp)
    8000179a:	e852                	sd	s4,16(sp)
    8000179c:	e456                	sd	s5,8(sp)
    8000179e:	e05a                	sd	s6,0(sp)
    800017a0:	0080                	addi	s0,sp,64
    800017a2:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800017a4:	0000f497          	auipc	s1,0xf
    800017a8:	6f448493          	addi	s1,s1,1780 # 80010e98 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017ac:	8b26                	mv	s6,s1
    800017ae:	04fa5937          	lui	s2,0x4fa5
    800017b2:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800017b6:	0932                	slli	s2,s2,0xc
    800017b8:	fa590913          	addi	s2,s2,-91
    800017bc:	0932                	slli	s2,s2,0xc
    800017be:	fa590913          	addi	s2,s2,-91
    800017c2:	0932                	slli	s2,s2,0xc
    800017c4:	fa590913          	addi	s2,s2,-91
    800017c8:	040009b7          	lui	s3,0x4000
    800017cc:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017ce:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800017d0:	00015a97          	auipc	s5,0x15
    800017d4:	0c8a8a93          	addi	s5,s5,200 # 80016898 <tickslock>
    char *pa = kalloc();
    800017d8:	b58ff0ef          	jal	80000b30 <kalloc>
    800017dc:	862a                	mv	a2,a0
    if (pa == 0)
    800017de:	cd15                	beqz	a0,8000181a <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int)(p - proc));
    800017e0:	416485b3          	sub	a1,s1,s6
    800017e4:	858d                	srai	a1,a1,0x3
    800017e6:	032585b3          	mul	a1,a1,s2
    800017ea:	2585                	addiw	a1,a1,1
    800017ec:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017f0:	4719                	li	a4,6
    800017f2:	6685                	lui	a3,0x1
    800017f4:	40b985b3          	sub	a1,s3,a1
    800017f8:	8552                	mv	a0,s4
    800017fa:	8dfff0ef          	jal	800010d8 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    800017fe:	16848493          	addi	s1,s1,360
    80001802:	fd549be3          	bne	s1,s5,800017d8 <proc_mapstacks+0x4a>
  }
}
    80001806:	70e2                	ld	ra,56(sp)
    80001808:	7442                	ld	s0,48(sp)
    8000180a:	74a2                	ld	s1,40(sp)
    8000180c:	7902                	ld	s2,32(sp)
    8000180e:	69e2                	ld	s3,24(sp)
    80001810:	6a42                	ld	s4,16(sp)
    80001812:	6aa2                	ld	s5,8(sp)
    80001814:	6b02                	ld	s6,0(sp)
    80001816:	6121                	addi	sp,sp,64
    80001818:	8082                	ret
      panic("kalloc");
    8000181a:	00007517          	auipc	a0,0x7
    8000181e:	94650513          	addi	a0,a0,-1722 # 80008160 <etext+0x160>
    80001822:	ff1fe0ef          	jal	80000812 <panic>

0000000080001826 <procinit>:

// initialize the proc table.
void procinit(void) {
    80001826:	7139                	addi	sp,sp,-64
    80001828:	fc06                	sd	ra,56(sp)
    8000182a:	f822                	sd	s0,48(sp)
    8000182c:	f426                	sd	s1,40(sp)
    8000182e:	f04a                	sd	s2,32(sp)
    80001830:	ec4e                	sd	s3,24(sp)
    80001832:	e852                	sd	s4,16(sp)
    80001834:	e456                	sd	s5,8(sp)
    80001836:	e05a                	sd	s6,0(sp)
    80001838:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    8000183a:	00007597          	auipc	a1,0x7
    8000183e:	92e58593          	addi	a1,a1,-1746 # 80008168 <etext+0x168>
    80001842:	0000f517          	auipc	a0,0xf
    80001846:	22650513          	addi	a0,a0,550 # 80010a68 <pid_lock>
    8000184a:	b36ff0ef          	jal	80000b80 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000184e:	00007597          	auipc	a1,0x7
    80001852:	92258593          	addi	a1,a1,-1758 # 80008170 <etext+0x170>
    80001856:	0000f517          	auipc	a0,0xf
    8000185a:	22a50513          	addi	a0,a0,554 # 80010a80 <wait_lock>
    8000185e:	b22ff0ef          	jal	80000b80 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001862:	0000f497          	auipc	s1,0xf
    80001866:	63648493          	addi	s1,s1,1590 # 80010e98 <proc>
    initlock(&p->lock, "proc");
    8000186a:	00007b17          	auipc	s6,0x7
    8000186e:	916b0b13          	addi	s6,s6,-1770 # 80008180 <etext+0x180>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001872:	8aa6                	mv	s5,s1
    80001874:	04fa5937          	lui	s2,0x4fa5
    80001878:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    8000187c:	0932                	slli	s2,s2,0xc
    8000187e:	fa590913          	addi	s2,s2,-91
    80001882:	0932                	slli	s2,s2,0xc
    80001884:	fa590913          	addi	s2,s2,-91
    80001888:	0932                	slli	s2,s2,0xc
    8000188a:	fa590913          	addi	s2,s2,-91
    8000188e:	040009b7          	lui	s3,0x4000
    80001892:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001894:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001896:	00015a17          	auipc	s4,0x15
    8000189a:	002a0a13          	addi	s4,s4,2 # 80016898 <tickslock>
    initlock(&p->lock, "proc");
    8000189e:	85da                	mv	a1,s6
    800018a0:	8526                	mv	a0,s1
    800018a2:	adeff0ef          	jal	80000b80 <initlock>
    p->state = UNUSED;
    800018a6:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800018aa:	415487b3          	sub	a5,s1,s5
    800018ae:	878d                	srai	a5,a5,0x3
    800018b0:	032787b3          	mul	a5,a5,s2
    800018b4:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ff9d329>
    800018b6:	00d7979b          	slliw	a5,a5,0xd
    800018ba:	40f987b3          	sub	a5,s3,a5
    800018be:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    800018c0:	16848493          	addi	s1,s1,360
    800018c4:	fd449de3          	bne	s1,s4,8000189e <procinit+0x78>
  }
}
    800018c8:	70e2                	ld	ra,56(sp)
    800018ca:	7442                	ld	s0,48(sp)
    800018cc:	74a2                	ld	s1,40(sp)
    800018ce:	7902                	ld	s2,32(sp)
    800018d0:	69e2                	ld	s3,24(sp)
    800018d2:	6a42                	ld	s4,16(sp)
    800018d4:	6aa2                	ld	s5,8(sp)
    800018d6:	6b02                	ld	s6,0(sp)
    800018d8:	6121                	addi	sp,sp,64
    800018da:	8082                	ret

00000000800018dc <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid() {
    800018dc:	1141                	addi	sp,sp,-16
    800018de:	e422                	sd	s0,8(sp)
    800018e0:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018e2:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018e4:	2501                	sext.w	a0,a0
    800018e6:	6422                	ld	s0,8(sp)
    800018e8:	0141                	addi	sp,sp,16
    800018ea:	8082                	ret

00000000800018ec <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *mycpu(void) {
    800018ec:	1141                	addi	sp,sp,-16
    800018ee:	e422                	sd	s0,8(sp)
    800018f0:	0800                	addi	s0,sp,16
    800018f2:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018f4:	2781                	sext.w	a5,a5
    800018f6:	079e                	slli	a5,a5,0x7
  return c;
}
    800018f8:	0000f517          	auipc	a0,0xf
    800018fc:	1a050513          	addi	a0,a0,416 # 80010a98 <cpus>
    80001900:	953e                	add	a0,a0,a5
    80001902:	6422                	ld	s0,8(sp)
    80001904:	0141                	addi	sp,sp,16
    80001906:	8082                	ret

0000000080001908 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *myproc(void) {
    80001908:	1101                	addi	sp,sp,-32
    8000190a:	ec06                	sd	ra,24(sp)
    8000190c:	e822                	sd	s0,16(sp)
    8000190e:	e426                	sd	s1,8(sp)
    80001910:	1000                	addi	s0,sp,32
  push_off();
    80001912:	aaeff0ef          	jal	80000bc0 <push_off>
    80001916:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001918:	2781                	sext.w	a5,a5
    8000191a:	079e                	slli	a5,a5,0x7
    8000191c:	0000f717          	auipc	a4,0xf
    80001920:	14c70713          	addi	a4,a4,332 # 80010a68 <pid_lock>
    80001924:	97ba                	add	a5,a5,a4
    80001926:	7b84                	ld	s1,48(a5)
  pop_off();
    80001928:	b1cff0ef          	jal	80000c44 <pop_off>
  return p;
}
    8000192c:	8526                	mv	a0,s1
    8000192e:	60e2                	ld	ra,24(sp)
    80001930:	6442                	ld	s0,16(sp)
    80001932:	64a2                	ld	s1,8(sp)
    80001934:	6105                	addi	sp,sp,32
    80001936:	8082                	ret

0000000080001938 <forkret>:
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void) {
    80001938:	7179                	addi	sp,sp,-48
    8000193a:	f406                	sd	ra,40(sp)
    8000193c:	f022                	sd	s0,32(sp)
    8000193e:	ec26                	sd	s1,24(sp)
    80001940:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001942:	fc7ff0ef          	jal	80001908 <myproc>
    80001946:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001948:	b50ff0ef          	jal	80000c98 <release>

  if (first) {
    8000194c:	00007797          	auipc	a5,0x7
    80001950:	fa47a783          	lw	a5,-92(a5) # 800088f0 <first.1>
    80001954:	cf8d                	beqz	a5,8000198e <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001956:	4505                	li	a0,1
    80001958:	679010ef          	jal	800037d0 <fsinit>

    first = 0;
    8000195c:	00007797          	auipc	a5,0x7
    80001960:	f807aa23          	sw	zero,-108(a5) # 800088f0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001964:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001968:	00007517          	auipc	a0,0x7
    8000196c:	82050513          	addi	a0,a0,-2016 # 80008188 <etext+0x188>
    80001970:	fca43823          	sd	a0,-48(s0)
    80001974:	fc043c23          	sd	zero,-40(s0)
    80001978:	fd040593          	addi	a1,s0,-48
    8000197c:	7c9020ef          	jal	80004944 <kexec>
    80001980:	6cbc                	ld	a5,88(s1)
    80001982:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001984:	6cbc                	ld	a5,88(s1)
    80001986:	7bb8                	ld	a4,112(a5)
    80001988:	57fd                	li	a5,-1
    8000198a:	02f70d63          	beq	a4,a5,800019c4 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    8000198e:	2c5000ef          	jal	80002452 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001992:	68a8                	ld	a0,80(s1)
    80001994:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001996:	04000737          	lui	a4,0x4000
    8000199a:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000199c:	0732                	slli	a4,a4,0xc
    8000199e:	00005797          	auipc	a5,0x5
    800019a2:	6fe78793          	addi	a5,a5,1790 # 8000709c <userret>
    800019a6:	00005697          	auipc	a3,0x5
    800019aa:	65a68693          	addi	a3,a3,1626 # 80007000 <_trampoline>
    800019ae:	8f95                	sub	a5,a5,a3
    800019b0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019b2:	577d                	li	a4,-1
    800019b4:	177e                	slli	a4,a4,0x3f
    800019b6:	8d59                	or	a0,a0,a4
    800019b8:	9782                	jalr	a5
}
    800019ba:	70a2                	ld	ra,40(sp)
    800019bc:	7402                	ld	s0,32(sp)
    800019be:	64e2                	ld	s1,24(sp)
    800019c0:	6145                	addi	sp,sp,48
    800019c2:	8082                	ret
      panic("exec");
    800019c4:	00006517          	auipc	a0,0x6
    800019c8:	7cc50513          	addi	a0,a0,1996 # 80008190 <etext+0x190>
    800019cc:	e47fe0ef          	jal	80000812 <panic>

00000000800019d0 <allocpid>:
int allocpid() {
    800019d0:	1101                	addi	sp,sp,-32
    800019d2:	ec06                	sd	ra,24(sp)
    800019d4:	e822                	sd	s0,16(sp)
    800019d6:	e426                	sd	s1,8(sp)
    800019d8:	e04a                	sd	s2,0(sp)
    800019da:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019dc:	0000f917          	auipc	s2,0xf
    800019e0:	08c90913          	addi	s2,s2,140 # 80010a68 <pid_lock>
    800019e4:	854a                	mv	a0,s2
    800019e6:	a1aff0ef          	jal	80000c00 <acquire>
  pid = nextpid;
    800019ea:	00007797          	auipc	a5,0x7
    800019ee:	f0a78793          	addi	a5,a5,-246 # 800088f4 <nextpid>
    800019f2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019f4:	0014871b          	addiw	a4,s1,1
    800019f8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019fa:	854a                	mv	a0,s2
    800019fc:	a9cff0ef          	jal	80000c98 <release>
}
    80001a00:	8526                	mv	a0,s1
    80001a02:	60e2                	ld	ra,24(sp)
    80001a04:	6442                	ld	s0,16(sp)
    80001a06:	64a2                	ld	s1,8(sp)
    80001a08:	6902                	ld	s2,0(sp)
    80001a0a:	6105                	addi	sp,sp,32
    80001a0c:	8082                	ret

0000000080001a0e <proc_pagetable>:
pagetable_t proc_pagetable(struct proc *p) {
    80001a0e:	1101                	addi	sp,sp,-32
    80001a10:	ec06                	sd	ra,24(sp)
    80001a12:	e822                	sd	s0,16(sp)
    80001a14:	e426                	sd	s1,8(sp)
    80001a16:	e04a                	sd	s2,0(sp)
    80001a18:	1000                	addi	s0,sp,32
    80001a1a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a1c:	fb2ff0ef          	jal	800011ce <uvmcreate>
    80001a20:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a22:	cd05                	beqz	a0,80001a5a <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a24:	4729                	li	a4,10
    80001a26:	00005697          	auipc	a3,0x5
    80001a2a:	5da68693          	addi	a3,a3,1498 # 80007000 <_trampoline>
    80001a2e:	6605                	lui	a2,0x1
    80001a30:	040005b7          	lui	a1,0x4000
    80001a34:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a36:	05b2                	slli	a1,a1,0xc
    80001a38:	df0ff0ef          	jal	80001028 <mappages>
    80001a3c:	02054663          	bltz	a0,80001a68 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001a40:	4719                	li	a4,6
    80001a42:	05893683          	ld	a3,88(s2)
    80001a46:	6605                	lui	a2,0x1
    80001a48:	020005b7          	lui	a1,0x2000
    80001a4c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a4e:	05b6                	slli	a1,a1,0xd
    80001a50:	8526                	mv	a0,s1
    80001a52:	dd6ff0ef          	jal	80001028 <mappages>
    80001a56:	00054f63          	bltz	a0,80001a74 <proc_pagetable+0x66>
}
    80001a5a:	8526                	mv	a0,s1
    80001a5c:	60e2                	ld	ra,24(sp)
    80001a5e:	6442                	ld	s0,16(sp)
    80001a60:	64a2                	ld	s1,8(sp)
    80001a62:	6902                	ld	s2,0(sp)
    80001a64:	6105                	addi	sp,sp,32
    80001a66:	8082                	ret
    uvmfree(pagetable, 0);
    80001a68:	4581                	li	a1,0
    80001a6a:	8526                	mv	a0,s1
    80001a6c:	95dff0ef          	jal	800013c8 <uvmfree>
    return 0;
    80001a70:	4481                	li	s1,0
    80001a72:	b7e5                	j	80001a5a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a74:	4681                	li	a3,0
    80001a76:	4605                	li	a2,1
    80001a78:	040005b7          	lui	a1,0x4000
    80001a7c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a7e:	05b2                	slli	a1,a1,0xc
    80001a80:	8526                	mv	a0,s1
    80001a82:	f72ff0ef          	jal	800011f4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a86:	4581                	li	a1,0
    80001a88:	8526                	mv	a0,s1
    80001a8a:	93fff0ef          	jal	800013c8 <uvmfree>
    return 0;
    80001a8e:	4481                	li	s1,0
    80001a90:	b7e9                	j	80001a5a <proc_pagetable+0x4c>

0000000080001a92 <proc_freepagetable>:
void proc_freepagetable(pagetable_t pagetable, uint64 sz) {
    80001a92:	1101                	addi	sp,sp,-32
    80001a94:	ec06                	sd	ra,24(sp)
    80001a96:	e822                	sd	s0,16(sp)
    80001a98:	e426                	sd	s1,8(sp)
    80001a9a:	e04a                	sd	s2,0(sp)
    80001a9c:	1000                	addi	s0,sp,32
    80001a9e:	84aa                	mv	s1,a0
    80001aa0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aa2:	4681                	li	a3,0
    80001aa4:	4605                	li	a2,1
    80001aa6:	040005b7          	lui	a1,0x4000
    80001aaa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aac:	05b2                	slli	a1,a1,0xc
    80001aae:	f46ff0ef          	jal	800011f4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ab2:	4681                	li	a3,0
    80001ab4:	4605                	li	a2,1
    80001ab6:	020005b7          	lui	a1,0x2000
    80001aba:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001abc:	05b6                	slli	a1,a1,0xd
    80001abe:	8526                	mv	a0,s1
    80001ac0:	f34ff0ef          	jal	800011f4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ac4:	85ca                	mv	a1,s2
    80001ac6:	8526                	mv	a0,s1
    80001ac8:	901ff0ef          	jal	800013c8 <uvmfree>
}
    80001acc:	60e2                	ld	ra,24(sp)
    80001ace:	6442                	ld	s0,16(sp)
    80001ad0:	64a2                	ld	s1,8(sp)
    80001ad2:	6902                	ld	s2,0(sp)
    80001ad4:	6105                	addi	sp,sp,32
    80001ad6:	8082                	ret

0000000080001ad8 <freeproc>:
static void freeproc(struct proc *p) {
    80001ad8:	1101                	addi	sp,sp,-32
    80001ada:	ec06                	sd	ra,24(sp)
    80001adc:	e822                	sd	s0,16(sp)
    80001ade:	e426                	sd	s1,8(sp)
    80001ae0:	1000                	addi	s0,sp,32
    80001ae2:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001ae4:	6d28                	ld	a0,88(a0)
    80001ae6:	c119                	beqz	a0,80001aec <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001ae8:	f67fe0ef          	jal	80000a4e <kfree>
  p->trapframe = 0;
    80001aec:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001af0:	68a8                	ld	a0,80(s1)
    80001af2:	c501                	beqz	a0,80001afa <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001af4:	64ac                	ld	a1,72(s1)
    80001af6:	f9dff0ef          	jal	80001a92 <proc_freepagetable>
  p->pagetable = 0;
    80001afa:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001afe:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b02:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b06:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b0a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b0e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b12:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b16:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b1a:	0004ac23          	sw	zero,24(s1)
}
    80001b1e:	60e2                	ld	ra,24(sp)
    80001b20:	6442                	ld	s0,16(sp)
    80001b22:	64a2                	ld	s1,8(sp)
    80001b24:	6105                	addi	sp,sp,32
    80001b26:	8082                	ret

0000000080001b28 <allocproc>:
static struct proc *allocproc(void) {
    80001b28:	1101                	addi	sp,sp,-32
    80001b2a:	ec06                	sd	ra,24(sp)
    80001b2c:	e822                	sd	s0,16(sp)
    80001b2e:	e426                	sd	s1,8(sp)
    80001b30:	e04a                	sd	s2,0(sp)
    80001b32:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b34:	0000f497          	auipc	s1,0xf
    80001b38:	36448493          	addi	s1,s1,868 # 80010e98 <proc>
    80001b3c:	00015917          	auipc	s2,0x15
    80001b40:	d5c90913          	addi	s2,s2,-676 # 80016898 <tickslock>
    acquire(&p->lock);
    80001b44:	8526                	mv	a0,s1
    80001b46:	8baff0ef          	jal	80000c00 <acquire>
    if (p->state == UNUSED) {
    80001b4a:	4c9c                	lw	a5,24(s1)
    80001b4c:	cb91                	beqz	a5,80001b60 <allocproc+0x38>
      release(&p->lock);
    80001b4e:	8526                	mv	a0,s1
    80001b50:	948ff0ef          	jal	80000c98 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b54:	16848493          	addi	s1,s1,360
    80001b58:	ff2496e3          	bne	s1,s2,80001b44 <allocproc+0x1c>
  return 0;
    80001b5c:	4481                	li	s1,0
    80001b5e:	a089                	j	80001ba0 <allocproc+0x78>
  p->pid = allocpid();
    80001b60:	e71ff0ef          	jal	800019d0 <allocpid>
    80001b64:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b66:	4785                	li	a5,1
    80001b68:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001b6a:	fc7fe0ef          	jal	80000b30 <kalloc>
    80001b6e:	892a                	mv	s2,a0
    80001b70:	eca8                	sd	a0,88(s1)
    80001b72:	cd15                	beqz	a0,80001bae <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b74:	8526                	mv	a0,s1
    80001b76:	e99ff0ef          	jal	80001a0e <proc_pagetable>
    80001b7a:	892a                	mv	s2,a0
    80001b7c:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001b7e:	c121                	beqz	a0,80001bbe <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b80:	07000613          	li	a2,112
    80001b84:	4581                	li	a1,0
    80001b86:	06048513          	addi	a0,s1,96
    80001b8a:	94aff0ef          	jal	80000cd4 <memset>
  p->context.ra = (uint64)forkret;
    80001b8e:	00000797          	auipc	a5,0x0
    80001b92:	daa78793          	addi	a5,a5,-598 # 80001938 <forkret>
    80001b96:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b98:	60bc                	ld	a5,64(s1)
    80001b9a:	6705                	lui	a4,0x1
    80001b9c:	97ba                	add	a5,a5,a4
    80001b9e:	f4bc                	sd	a5,104(s1)
}
    80001ba0:	8526                	mv	a0,s1
    80001ba2:	60e2                	ld	ra,24(sp)
    80001ba4:	6442                	ld	s0,16(sp)
    80001ba6:	64a2                	ld	s1,8(sp)
    80001ba8:	6902                	ld	s2,0(sp)
    80001baa:	6105                	addi	sp,sp,32
    80001bac:	8082                	ret
    freeproc(p);
    80001bae:	8526                	mv	a0,s1
    80001bb0:	f29ff0ef          	jal	80001ad8 <freeproc>
    release(&p->lock);
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	8e2ff0ef          	jal	80000c98 <release>
    return 0;
    80001bba:	84ca                	mv	s1,s2
    80001bbc:	b7d5                	j	80001ba0 <allocproc+0x78>
    freeproc(p);
    80001bbe:	8526                	mv	a0,s1
    80001bc0:	f19ff0ef          	jal	80001ad8 <freeproc>
    release(&p->lock);
    80001bc4:	8526                	mv	a0,s1
    80001bc6:	8d2ff0ef          	jal	80000c98 <release>
    return 0;
    80001bca:	84ca                	mv	s1,s2
    80001bcc:	bfd1                	j	80001ba0 <allocproc+0x78>

0000000080001bce <userinit>:
void userinit(void) {
    80001bce:	1101                	addi	sp,sp,-32
    80001bd0:	ec06                	sd	ra,24(sp)
    80001bd2:	e822                	sd	s0,16(sp)
    80001bd4:	e426                	sd	s1,8(sp)
    80001bd6:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bd8:	f51ff0ef          	jal	80001b28 <allocproc>
    80001bdc:	84aa                	mv	s1,a0
  initproc = p;
    80001bde:	00007797          	auipc	a5,0x7
    80001be2:	d4a7b123          	sd	a0,-702(a5) # 80008920 <initproc>
  p->cwd = namei("/");
    80001be6:	00006517          	auipc	a0,0x6
    80001bea:	5b250513          	addi	a0,a0,1458 # 80008198 <etext+0x198>
    80001bee:	104020ef          	jal	80003cf2 <namei>
    80001bf2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bf6:	478d                	li	a5,3
    80001bf8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	89cff0ef          	jal	80000c98 <release>
}
    80001c00:	60e2                	ld	ra,24(sp)
    80001c02:	6442                	ld	s0,16(sp)
    80001c04:	64a2                	ld	s1,8(sp)
    80001c06:	6105                	addi	sp,sp,32
    80001c08:	8082                	ret

0000000080001c0a <growproc>:
int growproc(int n) {
    80001c0a:	1101                	addi	sp,sp,-32
    80001c0c:	ec06                	sd	ra,24(sp)
    80001c0e:	e822                	sd	s0,16(sp)
    80001c10:	e426                	sd	s1,8(sp)
    80001c12:	e04a                	sd	s2,0(sp)
    80001c14:	1000                	addi	s0,sp,32
    80001c16:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c18:	cf1ff0ef          	jal	80001908 <myproc>
    80001c1c:	892a                	mv	s2,a0
  sz = p->sz;
    80001c1e:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c20:	02905963          	blez	s1,80001c52 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c24:	00b48633          	add	a2,s1,a1
    80001c28:	020007b7          	lui	a5,0x2000
    80001c2c:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c2e:	07b6                	slli	a5,a5,0xd
    80001c30:	02c7ea63          	bltu	a5,a2,80001c64 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c34:	4691                	li	a3,4
    80001c36:	6928                	ld	a0,80(a0)
    80001c38:	e8aff0ef          	jal	800012c2 <uvmalloc>
    80001c3c:	85aa                	mv	a1,a0
    80001c3e:	c50d                	beqz	a0,80001c68 <growproc+0x5e>
  p->sz = sz;
    80001c40:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c44:	4501                	li	a0,0
}
    80001c46:	60e2                	ld	ra,24(sp)
    80001c48:	6442                	ld	s0,16(sp)
    80001c4a:	64a2                	ld	s1,8(sp)
    80001c4c:	6902                	ld	s2,0(sp)
    80001c4e:	6105                	addi	sp,sp,32
    80001c50:	8082                	ret
  } else if (n < 0) {
    80001c52:	fe04d7e3          	bgez	s1,80001c40 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c56:	00b48633          	add	a2,s1,a1
    80001c5a:	6928                	ld	a0,80(a0)
    80001c5c:	e22ff0ef          	jal	8000127e <uvmdealloc>
    80001c60:	85aa                	mv	a1,a0
    80001c62:	bff9                	j	80001c40 <growproc+0x36>
      return -1;
    80001c64:	557d                	li	a0,-1
    80001c66:	b7c5                	j	80001c46 <growproc+0x3c>
      return -1;
    80001c68:	557d                	li	a0,-1
    80001c6a:	bff1                	j	80001c46 <growproc+0x3c>

0000000080001c6c <kfork>:
int kfork(void) {
    80001c6c:	7139                	addi	sp,sp,-64
    80001c6e:	fc06                	sd	ra,56(sp)
    80001c70:	f822                	sd	s0,48(sp)
    80001c72:	f04a                	sd	s2,32(sp)
    80001c74:	e456                	sd	s5,8(sp)
    80001c76:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c78:	c91ff0ef          	jal	80001908 <myproc>
    80001c7c:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001c7e:	eabff0ef          	jal	80001b28 <allocproc>
    80001c82:	0e050a63          	beqz	a0,80001d76 <kfork+0x10a>
    80001c86:	e852                	sd	s4,16(sp)
    80001c88:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001c8a:	048ab603          	ld	a2,72(s5)
    80001c8e:	692c                	ld	a1,80(a0)
    80001c90:	050ab503          	ld	a0,80(s5)
    80001c94:	f66ff0ef          	jal	800013fa <uvmcopy>
    80001c98:	04054a63          	bltz	a0,80001cec <kfork+0x80>
    80001c9c:	f426                	sd	s1,40(sp)
    80001c9e:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001ca0:	048ab783          	ld	a5,72(s5)
    80001ca4:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ca8:	058ab683          	ld	a3,88(s5)
    80001cac:	87b6                	mv	a5,a3
    80001cae:	058a3703          	ld	a4,88(s4)
    80001cb2:	12068693          	addi	a3,a3,288
    80001cb6:	0007b803          	ld	a6,0(a5)
    80001cba:	6788                	ld	a0,8(a5)
    80001cbc:	6b8c                	ld	a1,16(a5)
    80001cbe:	6f90                	ld	a2,24(a5)
    80001cc0:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001cc4:	e708                	sd	a0,8(a4)
    80001cc6:	eb0c                	sd	a1,16(a4)
    80001cc8:	ef10                	sd	a2,24(a4)
    80001cca:	02078793          	addi	a5,a5,32
    80001cce:	02070713          	addi	a4,a4,32
    80001cd2:	fed792e3          	bne	a5,a3,80001cb6 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001cd6:	058a3783          	ld	a5,88(s4)
    80001cda:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001cde:	0d0a8493          	addi	s1,s5,208
    80001ce2:	0d0a0913          	addi	s2,s4,208
    80001ce6:	150a8993          	addi	s3,s5,336
    80001cea:	a831                	j	80001d06 <kfork+0x9a>
    freeproc(np);
    80001cec:	8552                	mv	a0,s4
    80001cee:	debff0ef          	jal	80001ad8 <freeproc>
    release(&np->lock);
    80001cf2:	8552                	mv	a0,s4
    80001cf4:	fa5fe0ef          	jal	80000c98 <release>
    return -1;
    80001cf8:	597d                	li	s2,-1
    80001cfa:	6a42                	ld	s4,16(sp)
    80001cfc:	a0b5                	j	80001d68 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001cfe:	04a1                	addi	s1,s1,8
    80001d00:	0921                	addi	s2,s2,8
    80001d02:	01348963          	beq	s1,s3,80001d14 <kfork+0xa8>
    if (p->ofile[i])
    80001d06:	6088                	ld	a0,0(s1)
    80001d08:	d97d                	beqz	a0,80001cfe <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d0a:	5ec020ef          	jal	800042f6 <filedup>
    80001d0e:	00a93023          	sd	a0,0(s2)
    80001d12:	b7f5                	j	80001cfe <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001d14:	150ab503          	ld	a0,336(s5)
    80001d18:	778010ef          	jal	80003490 <idup>
    80001d1c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d20:	4641                	li	a2,16
    80001d22:	158a8593          	addi	a1,s5,344
    80001d26:	158a0513          	addi	a0,s4,344
    80001d2a:	8e8ff0ef          	jal	80000e12 <safestrcpy>
  pid = np->pid;
    80001d2e:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001d32:	8552                	mv	a0,s4
    80001d34:	f65fe0ef          	jal	80000c98 <release>
  acquire(&wait_lock);
    80001d38:	0000f497          	auipc	s1,0xf
    80001d3c:	d4848493          	addi	s1,s1,-696 # 80010a80 <wait_lock>
    80001d40:	8526                	mv	a0,s1
    80001d42:	ebffe0ef          	jal	80000c00 <acquire>
  np->parent = p;
    80001d46:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d4a:	8526                	mv	a0,s1
    80001d4c:	f4dfe0ef          	jal	80000c98 <release>
  acquire(&np->lock);
    80001d50:	8552                	mv	a0,s4
    80001d52:	eaffe0ef          	jal	80000c00 <acquire>
  np->state = RUNNABLE;
    80001d56:	478d                	li	a5,3
    80001d58:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d5c:	8552                	mv	a0,s4
    80001d5e:	f3bfe0ef          	jal	80000c98 <release>
  return pid;
    80001d62:	74a2                	ld	s1,40(sp)
    80001d64:	69e2                	ld	s3,24(sp)
    80001d66:	6a42                	ld	s4,16(sp)
}
    80001d68:	854a                	mv	a0,s2
    80001d6a:	70e2                	ld	ra,56(sp)
    80001d6c:	7442                	ld	s0,48(sp)
    80001d6e:	7902                	ld	s2,32(sp)
    80001d70:	6aa2                	ld	s5,8(sp)
    80001d72:	6121                	addi	sp,sp,64
    80001d74:	8082                	ret
    return -1;
    80001d76:	597d                	li	s2,-1
    80001d78:	bfc5                	j	80001d68 <kfork+0xfc>

0000000080001d7a <scheduler>:
void scheduler(void) {
    80001d7a:	715d                	addi	sp,sp,-80
    80001d7c:	e486                	sd	ra,72(sp)
    80001d7e:	e0a2                	sd	s0,64(sp)
    80001d80:	fc26                	sd	s1,56(sp)
    80001d82:	f84a                	sd	s2,48(sp)
    80001d84:	f44e                	sd	s3,40(sp)
    80001d86:	f052                	sd	s4,32(sp)
    80001d88:	ec56                	sd	s5,24(sp)
    80001d8a:	e85a                	sd	s6,16(sp)
    80001d8c:	e45e                	sd	s7,8(sp)
    80001d8e:	e062                	sd	s8,0(sp)
    80001d90:	0880                	addi	s0,sp,80
    80001d92:	8792                	mv	a5,tp
  int id = r_tp();
    80001d94:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d96:	00779b13          	slli	s6,a5,0x7
    80001d9a:	0000f717          	auipc	a4,0xf
    80001d9e:	cce70713          	addi	a4,a4,-818 # 80010a68 <pid_lock>
    80001da2:	975a                	add	a4,a4,s6
    80001da4:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001da8:	0000f717          	auipc	a4,0xf
    80001dac:	cf870713          	addi	a4,a4,-776 # 80010aa0 <cpus+0x8>
    80001db0:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001db2:	4c11                	li	s8,4
        c->proc = p;
    80001db4:	079e                	slli	a5,a5,0x7
    80001db6:	0000fa17          	auipc	s4,0xf
    80001dba:	cb2a0a13          	addi	s4,s4,-846 # 80010a68 <pid_lock>
    80001dbe:	9a3e                	add	s4,s4,a5
        found = 1;
    80001dc0:	4b85                	li	s7,1
    for (p = proc; p < &proc[NPROC]; p++) {
    80001dc2:	00015997          	auipc	s3,0x15
    80001dc6:	ad698993          	addi	s3,s3,-1322 # 80016898 <tickslock>
    80001dca:	a091                	j	80001e0e <scheduler+0x94>
      release(&p->lock);
    80001dcc:	8526                	mv	a0,s1
    80001dce:	ecbfe0ef          	jal	80000c98 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001dd2:	16848493          	addi	s1,s1,360
    80001dd6:	03348863          	beq	s1,s3,80001e06 <scheduler+0x8c>
      acquire(&p->lock);
    80001dda:	8526                	mv	a0,s1
    80001ddc:	e25fe0ef          	jal	80000c00 <acquire>
      if (p->state == RUNNABLE) {
    80001de0:	4c9c                	lw	a5,24(s1)
    80001de2:	ff2795e3          	bne	a5,s2,80001dcc <scheduler+0x52>
        p->state = RUNNING;
    80001de6:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001dea:	029a3823          	sd	s1,48(s4)
        cslog_run_start(p);
    80001dee:	8526                	mv	a0,s1
    80001df0:	795030ef          	jal	80005d84 <cslog_run_start>
        swtch(&c->context, &p->context);
    80001df4:	06048593          	addi	a1,s1,96
    80001df8:	855a                	mv	a0,s6
    80001dfa:	5b2000ef          	jal	800023ac <swtch>
        c->proc = 0;
    80001dfe:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e02:	8ade                	mv	s5,s7
    80001e04:	b7e1                	j	80001dcc <scheduler+0x52>
    if (found == 0) {
    80001e06:	000a9463          	bnez	s5,80001e0e <scheduler+0x94>
      asm volatile("wfi");
    80001e0a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e0e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e12:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e16:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e1a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001e1e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e20:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e24:	4a81                	li	s5,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e26:	0000f497          	auipc	s1,0xf
    80001e2a:	07248493          	addi	s1,s1,114 # 80010e98 <proc>
      if (p->state == RUNNABLE) {
    80001e2e:	490d                	li	s2,3
    80001e30:	b76d                	j	80001dda <scheduler+0x60>

0000000080001e32 <sched>:
void sched(void) {
    80001e32:	7179                	addi	sp,sp,-48
    80001e34:	f406                	sd	ra,40(sp)
    80001e36:	f022                	sd	s0,32(sp)
    80001e38:	ec26                	sd	s1,24(sp)
    80001e3a:	e84a                	sd	s2,16(sp)
    80001e3c:	e44e                	sd	s3,8(sp)
    80001e3e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e40:	ac9ff0ef          	jal	80001908 <myproc>
    80001e44:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001e46:	d51fe0ef          	jal	80000b96 <holding>
    80001e4a:	c92d                	beqz	a0,80001ebc <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e4c:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001e4e:	2781                	sext.w	a5,a5
    80001e50:	079e                	slli	a5,a5,0x7
    80001e52:	0000f717          	auipc	a4,0xf
    80001e56:	c1670713          	addi	a4,a4,-1002 # 80010a68 <pid_lock>
    80001e5a:	97ba                	add	a5,a5,a4
    80001e5c:	0a87a703          	lw	a4,168(a5)
    80001e60:	4785                	li	a5,1
    80001e62:	06f71363          	bne	a4,a5,80001ec8 <sched+0x96>
  if (p->state == RUNNING)
    80001e66:	4c98                	lw	a4,24(s1)
    80001e68:	4791                	li	a5,4
    80001e6a:	06f70563          	beq	a4,a5,80001ed4 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e6e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e72:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001e74:	e7b5                	bnez	a5,80001ee0 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e76:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e78:	0000f917          	auipc	s2,0xf
    80001e7c:	bf090913          	addi	s2,s2,-1040 # 80010a68 <pid_lock>
    80001e80:	2781                	sext.w	a5,a5
    80001e82:	079e                	slli	a5,a5,0x7
    80001e84:	97ca                	add	a5,a5,s2
    80001e86:	0ac7a983          	lw	s3,172(a5)
    80001e8a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e8c:	2781                	sext.w	a5,a5
    80001e8e:	079e                	slli	a5,a5,0x7
    80001e90:	0000f597          	auipc	a1,0xf
    80001e94:	c1058593          	addi	a1,a1,-1008 # 80010aa0 <cpus+0x8>
    80001e98:	95be                	add	a1,a1,a5
    80001e9a:	06048513          	addi	a0,s1,96
    80001e9e:	50e000ef          	jal	800023ac <swtch>
    80001ea2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ea4:	2781                	sext.w	a5,a5
    80001ea6:	079e                	slli	a5,a5,0x7
    80001ea8:	993e                	add	s2,s2,a5
    80001eaa:	0b392623          	sw	s3,172(s2)
}
    80001eae:	70a2                	ld	ra,40(sp)
    80001eb0:	7402                	ld	s0,32(sp)
    80001eb2:	64e2                	ld	s1,24(sp)
    80001eb4:	6942                	ld	s2,16(sp)
    80001eb6:	69a2                	ld	s3,8(sp)
    80001eb8:	6145                	addi	sp,sp,48
    80001eba:	8082                	ret
    panic("sched p->lock");
    80001ebc:	00006517          	auipc	a0,0x6
    80001ec0:	2e450513          	addi	a0,a0,740 # 800081a0 <etext+0x1a0>
    80001ec4:	94ffe0ef          	jal	80000812 <panic>
    panic("sched locks");
    80001ec8:	00006517          	auipc	a0,0x6
    80001ecc:	2e850513          	addi	a0,a0,744 # 800081b0 <etext+0x1b0>
    80001ed0:	943fe0ef          	jal	80000812 <panic>
    panic("sched RUNNING");
    80001ed4:	00006517          	auipc	a0,0x6
    80001ed8:	2ec50513          	addi	a0,a0,748 # 800081c0 <etext+0x1c0>
    80001edc:	937fe0ef          	jal	80000812 <panic>
    panic("sched interruptible");
    80001ee0:	00006517          	auipc	a0,0x6
    80001ee4:	2f050513          	addi	a0,a0,752 # 800081d0 <etext+0x1d0>
    80001ee8:	92bfe0ef          	jal	80000812 <panic>

0000000080001eec <yield>:
void yield(void) {
    80001eec:	1101                	addi	sp,sp,-32
    80001eee:	ec06                	sd	ra,24(sp)
    80001ef0:	e822                	sd	s0,16(sp)
    80001ef2:	e426                	sd	s1,8(sp)
    80001ef4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ef6:	a13ff0ef          	jal	80001908 <myproc>
    80001efa:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001efc:	d05fe0ef          	jal	80000c00 <acquire>
  p->state = RUNNABLE;
    80001f00:	478d                	li	a5,3
    80001f02:	cc9c                	sw	a5,24(s1)
  sched();
    80001f04:	f2fff0ef          	jal	80001e32 <sched>
  release(&p->lock);
    80001f08:	8526                	mv	a0,s1
    80001f0a:	d8ffe0ef          	jal	80000c98 <release>
}
    80001f0e:	60e2                	ld	ra,24(sp)
    80001f10:	6442                	ld	s0,16(sp)
    80001f12:	64a2                	ld	s1,8(sp)
    80001f14:	6105                	addi	sp,sp,32
    80001f16:	8082                	ret

0000000080001f18 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void sleep(void *chan, struct spinlock *lk) {
    80001f18:	7179                	addi	sp,sp,-48
    80001f1a:	f406                	sd	ra,40(sp)
    80001f1c:	f022                	sd	s0,32(sp)
    80001f1e:	ec26                	sd	s1,24(sp)
    80001f20:	e84a                	sd	s2,16(sp)
    80001f22:	e44e                	sd	s3,8(sp)
    80001f24:	1800                	addi	s0,sp,48
    80001f26:	89aa                	mv	s3,a0
    80001f28:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f2a:	9dfff0ef          	jal	80001908 <myproc>
    80001f2e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80001f30:	cd1fe0ef          	jal	80000c00 <acquire>
  release(lk);
    80001f34:	854a                	mv	a0,s2
    80001f36:	d63fe0ef          	jal	80000c98 <release>

  // Go to sleep.
  p->chan = chan;
    80001f3a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f3e:	4789                	li	a5,2
    80001f40:	cc9c                	sw	a5,24(s1)

  sched();
    80001f42:	ef1ff0ef          	jal	80001e32 <sched>

  // Tidy up.
  p->chan = 0;
    80001f46:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	d4dfe0ef          	jal	80000c98 <release>
  acquire(lk);
    80001f50:	854a                	mv	a0,s2
    80001f52:	caffe0ef          	jal	80000c00 <acquire>
}
    80001f56:	70a2                	ld	ra,40(sp)
    80001f58:	7402                	ld	s0,32(sp)
    80001f5a:	64e2                	ld	s1,24(sp)
    80001f5c:	6942                	ld	s2,16(sp)
    80001f5e:	69a2                	ld	s3,8(sp)
    80001f60:	6145                	addi	sp,sp,48
    80001f62:	8082                	ret

0000000080001f64 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void wakeup(void *chan) {
    80001f64:	7139                	addi	sp,sp,-64
    80001f66:	fc06                	sd	ra,56(sp)
    80001f68:	f822                	sd	s0,48(sp)
    80001f6a:	f426                	sd	s1,40(sp)
    80001f6c:	f04a                	sd	s2,32(sp)
    80001f6e:	ec4e                	sd	s3,24(sp)
    80001f70:	e852                	sd	s4,16(sp)
    80001f72:	e456                	sd	s5,8(sp)
    80001f74:	0080                	addi	s0,sp,64
    80001f76:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001f78:	0000f497          	auipc	s1,0xf
    80001f7c:	f2048493          	addi	s1,s1,-224 # 80010e98 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    80001f80:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f82:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f84:	00015917          	auipc	s2,0x15
    80001f88:	91490913          	addi	s2,s2,-1772 # 80016898 <tickslock>
    80001f8c:	a801                	j	80001f9c <wakeup+0x38>
      }
      release(&p->lock);
    80001f8e:	8526                	mv	a0,s1
    80001f90:	d09fe0ef          	jal	80000c98 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f94:	16848493          	addi	s1,s1,360
    80001f98:	03248263          	beq	s1,s2,80001fbc <wakeup+0x58>
    if (p != myproc()) {
    80001f9c:	96dff0ef          	jal	80001908 <myproc>
    80001fa0:	fea48ae3          	beq	s1,a0,80001f94 <wakeup+0x30>
      acquire(&p->lock);
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	c5bfe0ef          	jal	80000c00 <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    80001faa:	4c9c                	lw	a5,24(s1)
    80001fac:	ff3791e3          	bne	a5,s3,80001f8e <wakeup+0x2a>
    80001fb0:	709c                	ld	a5,32(s1)
    80001fb2:	fd479ee3          	bne	a5,s4,80001f8e <wakeup+0x2a>
        p->state = RUNNABLE;
    80001fb6:	0154ac23          	sw	s5,24(s1)
    80001fba:	bfd1                	j	80001f8e <wakeup+0x2a>
    }
  }
}
    80001fbc:	70e2                	ld	ra,56(sp)
    80001fbe:	7442                	ld	s0,48(sp)
    80001fc0:	74a2                	ld	s1,40(sp)
    80001fc2:	7902                	ld	s2,32(sp)
    80001fc4:	69e2                	ld	s3,24(sp)
    80001fc6:	6a42                	ld	s4,16(sp)
    80001fc8:	6aa2                	ld	s5,8(sp)
    80001fca:	6121                	addi	sp,sp,64
    80001fcc:	8082                	ret

0000000080001fce <reparent>:
void reparent(struct proc *p) {
    80001fce:	7179                	addi	sp,sp,-48
    80001fd0:	f406                	sd	ra,40(sp)
    80001fd2:	f022                	sd	s0,32(sp)
    80001fd4:	ec26                	sd	s1,24(sp)
    80001fd6:	e84a                	sd	s2,16(sp)
    80001fd8:	e44e                	sd	s3,8(sp)
    80001fda:	e052                	sd	s4,0(sp)
    80001fdc:	1800                	addi	s0,sp,48
    80001fde:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001fe0:	0000f497          	auipc	s1,0xf
    80001fe4:	eb848493          	addi	s1,s1,-328 # 80010e98 <proc>
      pp->parent = initproc;
    80001fe8:	00007a17          	auipc	s4,0x7
    80001fec:	938a0a13          	addi	s4,s4,-1736 # 80008920 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001ff0:	00015997          	auipc	s3,0x15
    80001ff4:	8a898993          	addi	s3,s3,-1880 # 80016898 <tickslock>
    80001ff8:	a029                	j	80002002 <reparent+0x34>
    80001ffa:	16848493          	addi	s1,s1,360
    80001ffe:	01348b63          	beq	s1,s3,80002014 <reparent+0x46>
    if (pp->parent == p) {
    80002002:	7c9c                	ld	a5,56(s1)
    80002004:	ff279be3          	bne	a5,s2,80001ffa <reparent+0x2c>
      pp->parent = initproc;
    80002008:	000a3503          	ld	a0,0(s4)
    8000200c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000200e:	f57ff0ef          	jal	80001f64 <wakeup>
    80002012:	b7e5                	j	80001ffa <reparent+0x2c>
}
    80002014:	70a2                	ld	ra,40(sp)
    80002016:	7402                	ld	s0,32(sp)
    80002018:	64e2                	ld	s1,24(sp)
    8000201a:	6942                	ld	s2,16(sp)
    8000201c:	69a2                	ld	s3,8(sp)
    8000201e:	6a02                	ld	s4,0(sp)
    80002020:	6145                	addi	sp,sp,48
    80002022:	8082                	ret

0000000080002024 <kexit>:
void kexit(int status) {
    80002024:	7179                	addi	sp,sp,-48
    80002026:	f406                	sd	ra,40(sp)
    80002028:	f022                	sd	s0,32(sp)
    8000202a:	ec26                	sd	s1,24(sp)
    8000202c:	e84a                	sd	s2,16(sp)
    8000202e:	e44e                	sd	s3,8(sp)
    80002030:	e052                	sd	s4,0(sp)
    80002032:	1800                	addi	s0,sp,48
    80002034:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002036:	8d3ff0ef          	jal	80001908 <myproc>
    8000203a:	89aa                	mv	s3,a0
  if (p == initproc)
    8000203c:	00007797          	auipc	a5,0x7
    80002040:	8e47b783          	ld	a5,-1820(a5) # 80008920 <initproc>
    80002044:	0d050493          	addi	s1,a0,208
    80002048:	15050913          	addi	s2,a0,336
    8000204c:	00a79f63          	bne	a5,a0,8000206a <kexit+0x46>
    panic("init exiting");
    80002050:	00006517          	auipc	a0,0x6
    80002054:	19850513          	addi	a0,a0,408 # 800081e8 <etext+0x1e8>
    80002058:	fbafe0ef          	jal	80000812 <panic>
      fileclose(f);
    8000205c:	2e0020ef          	jal	8000433c <fileclose>
      p->ofile[fd] = 0;
    80002060:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++) {
    80002064:	04a1                	addi	s1,s1,8
    80002066:	01248563          	beq	s1,s2,80002070 <kexit+0x4c>
    if (p->ofile[fd]) {
    8000206a:	6088                	ld	a0,0(s1)
    8000206c:	f965                	bnez	a0,8000205c <kexit+0x38>
    8000206e:	bfdd                	j	80002064 <kexit+0x40>
  begin_op();
    80002070:	667010ef          	jal	80003ed6 <begin_op>
  iput(p->cwd);
    80002074:	1509b503          	ld	a0,336(s3)
    80002078:	5e0010ef          	jal	80003658 <iput>
  end_op();
    8000207c:	6d1010ef          	jal	80003f4c <end_op>
  p->cwd = 0;
    80002080:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002084:	0000f497          	auipc	s1,0xf
    80002088:	9fc48493          	addi	s1,s1,-1540 # 80010a80 <wait_lock>
    8000208c:	8526                	mv	a0,s1
    8000208e:	b73fe0ef          	jal	80000c00 <acquire>
  reparent(p);
    80002092:	854e                	mv	a0,s3
    80002094:	f3bff0ef          	jal	80001fce <reparent>
  wakeup(p->parent);
    80002098:	0389b503          	ld	a0,56(s3)
    8000209c:	ec9ff0ef          	jal	80001f64 <wakeup>
  acquire(&p->lock);
    800020a0:	854e                	mv	a0,s3
    800020a2:	b5ffe0ef          	jal	80000c00 <acquire>
  p->xstate = status;
    800020a6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020aa:	4795                	li	a5,5
    800020ac:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020b0:	8526                	mv	a0,s1
    800020b2:	be7fe0ef          	jal	80000c98 <release>
  sched();
    800020b6:	d7dff0ef          	jal	80001e32 <sched>
  panic("zombie exit");
    800020ba:	00006517          	auipc	a0,0x6
    800020be:	13e50513          	addi	a0,a0,318 # 800081f8 <etext+0x1f8>
    800020c2:	f50fe0ef          	jal	80000812 <panic>

00000000800020c6 <kkill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kkill(int pid) {
    800020c6:	7179                	addi	sp,sp,-48
    800020c8:	f406                	sd	ra,40(sp)
    800020ca:	f022                	sd	s0,32(sp)
    800020cc:	ec26                	sd	s1,24(sp)
    800020ce:	e84a                	sd	s2,16(sp)
    800020d0:	e44e                	sd	s3,8(sp)
    800020d2:	1800                	addi	s0,sp,48
    800020d4:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800020d6:	0000f497          	auipc	s1,0xf
    800020da:	dc248493          	addi	s1,s1,-574 # 80010e98 <proc>
    800020de:	00014997          	auipc	s3,0x14
    800020e2:	7ba98993          	addi	s3,s3,1978 # 80016898 <tickslock>
    acquire(&p->lock);
    800020e6:	8526                	mv	a0,s1
    800020e8:	b19fe0ef          	jal	80000c00 <acquire>
    if (p->pid == pid) {
    800020ec:	589c                	lw	a5,48(s1)
    800020ee:	01278b63          	beq	a5,s2,80002104 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020f2:	8526                	mv	a0,s1
    800020f4:	ba5fe0ef          	jal	80000c98 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800020f8:	16848493          	addi	s1,s1,360
    800020fc:	ff3495e3          	bne	s1,s3,800020e6 <kkill+0x20>
  }
  return -1;
    80002100:	557d                	li	a0,-1
    80002102:	a819                	j	80002118 <kkill+0x52>
      p->killed = 1;
    80002104:	4785                	li	a5,1
    80002106:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002108:	4c98                	lw	a4,24(s1)
    8000210a:	4789                	li	a5,2
    8000210c:	00f70d63          	beq	a4,a5,80002126 <kkill+0x60>
      release(&p->lock);
    80002110:	8526                	mv	a0,s1
    80002112:	b87fe0ef          	jal	80000c98 <release>
      return 0;
    80002116:	4501                	li	a0,0
}
    80002118:	70a2                	ld	ra,40(sp)
    8000211a:	7402                	ld	s0,32(sp)
    8000211c:	64e2                	ld	s1,24(sp)
    8000211e:	6942                	ld	s2,16(sp)
    80002120:	69a2                	ld	s3,8(sp)
    80002122:	6145                	addi	sp,sp,48
    80002124:	8082                	ret
        p->state = RUNNABLE;
    80002126:	478d                	li	a5,3
    80002128:	cc9c                	sw	a5,24(s1)
    8000212a:	b7dd                	j	80002110 <kkill+0x4a>

000000008000212c <setkilled>:

void setkilled(struct proc *p) {
    8000212c:	1101                	addi	sp,sp,-32
    8000212e:	ec06                	sd	ra,24(sp)
    80002130:	e822                	sd	s0,16(sp)
    80002132:	e426                	sd	s1,8(sp)
    80002134:	1000                	addi	s0,sp,32
    80002136:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002138:	ac9fe0ef          	jal	80000c00 <acquire>
  p->killed = 1;
    8000213c:	4785                	li	a5,1
    8000213e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002140:	8526                	mv	a0,s1
    80002142:	b57fe0ef          	jal	80000c98 <release>
}
    80002146:	60e2                	ld	ra,24(sp)
    80002148:	6442                	ld	s0,16(sp)
    8000214a:	64a2                	ld	s1,8(sp)
    8000214c:	6105                	addi	sp,sp,32
    8000214e:	8082                	ret

0000000080002150 <killed>:

int killed(struct proc *p) {
    80002150:	1101                	addi	sp,sp,-32
    80002152:	ec06                	sd	ra,24(sp)
    80002154:	e822                	sd	s0,16(sp)
    80002156:	e426                	sd	s1,8(sp)
    80002158:	e04a                	sd	s2,0(sp)
    8000215a:	1000                	addi	s0,sp,32
    8000215c:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000215e:	aa3fe0ef          	jal	80000c00 <acquire>
  k = p->killed;
    80002162:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002166:	8526                	mv	a0,s1
    80002168:	b31fe0ef          	jal	80000c98 <release>
  return k;
}
    8000216c:	854a                	mv	a0,s2
    8000216e:	60e2                	ld	ra,24(sp)
    80002170:	6442                	ld	s0,16(sp)
    80002172:	64a2                	ld	s1,8(sp)
    80002174:	6902                	ld	s2,0(sp)
    80002176:	6105                	addi	sp,sp,32
    80002178:	8082                	ret

000000008000217a <kwait>:
int kwait(uint64 addr) {
    8000217a:	715d                	addi	sp,sp,-80
    8000217c:	e486                	sd	ra,72(sp)
    8000217e:	e0a2                	sd	s0,64(sp)
    80002180:	fc26                	sd	s1,56(sp)
    80002182:	f84a                	sd	s2,48(sp)
    80002184:	f44e                	sd	s3,40(sp)
    80002186:	f052                	sd	s4,32(sp)
    80002188:	ec56                	sd	s5,24(sp)
    8000218a:	e85a                	sd	s6,16(sp)
    8000218c:	e45e                	sd	s7,8(sp)
    8000218e:	e062                	sd	s8,0(sp)
    80002190:	0880                	addi	s0,sp,80
    80002192:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002194:	f74ff0ef          	jal	80001908 <myproc>
    80002198:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000219a:	0000f517          	auipc	a0,0xf
    8000219e:	8e650513          	addi	a0,a0,-1818 # 80010a80 <wait_lock>
    800021a2:	a5ffe0ef          	jal	80000c00 <acquire>
    havekids = 0;
    800021a6:	4b81                	li	s7,0
        if (pp->state == ZOMBIE) {
    800021a8:	4a15                	li	s4,5
        havekids = 1;
    800021aa:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021ac:	00014997          	auipc	s3,0x14
    800021b0:	6ec98993          	addi	s3,s3,1772 # 80016898 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800021b4:	0000fc17          	auipc	s8,0xf
    800021b8:	8ccc0c13          	addi	s8,s8,-1844 # 80010a80 <wait_lock>
    800021bc:	a871                	j	80002258 <kwait+0xde>
          pid = pp->pid;
    800021be:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021c2:	000b0c63          	beqz	s6,800021da <kwait+0x60>
    800021c6:	4691                	li	a3,4
    800021c8:	02c48613          	addi	a2,s1,44
    800021cc:	85da                	mv	a1,s6
    800021ce:	05093503          	ld	a0,80(s2)
    800021d2:	c4aff0ef          	jal	8000161c <copyout>
    800021d6:	02054b63          	bltz	a0,8000220c <kwait+0x92>
          freeproc(pp);
    800021da:	8526                	mv	a0,s1
    800021dc:	8fdff0ef          	jal	80001ad8 <freeproc>
          release(&pp->lock);
    800021e0:	8526                	mv	a0,s1
    800021e2:	ab7fe0ef          	jal	80000c98 <release>
          release(&wait_lock);
    800021e6:	0000f517          	auipc	a0,0xf
    800021ea:	89a50513          	addi	a0,a0,-1894 # 80010a80 <wait_lock>
    800021ee:	aabfe0ef          	jal	80000c98 <release>
}
    800021f2:	854e                	mv	a0,s3
    800021f4:	60a6                	ld	ra,72(sp)
    800021f6:	6406                	ld	s0,64(sp)
    800021f8:	74e2                	ld	s1,56(sp)
    800021fa:	7942                	ld	s2,48(sp)
    800021fc:	79a2                	ld	s3,40(sp)
    800021fe:	7a02                	ld	s4,32(sp)
    80002200:	6ae2                	ld	s5,24(sp)
    80002202:	6b42                	ld	s6,16(sp)
    80002204:	6ba2                	ld	s7,8(sp)
    80002206:	6c02                	ld	s8,0(sp)
    80002208:	6161                	addi	sp,sp,80
    8000220a:	8082                	ret
            release(&pp->lock);
    8000220c:	8526                	mv	a0,s1
    8000220e:	a8bfe0ef          	jal	80000c98 <release>
            release(&wait_lock);
    80002212:	0000f517          	auipc	a0,0xf
    80002216:	86e50513          	addi	a0,a0,-1938 # 80010a80 <wait_lock>
    8000221a:	a7ffe0ef          	jal	80000c98 <release>
            return -1;
    8000221e:	59fd                	li	s3,-1
    80002220:	bfc9                	j	800021f2 <kwait+0x78>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002222:	16848493          	addi	s1,s1,360
    80002226:	03348063          	beq	s1,s3,80002246 <kwait+0xcc>
      if (pp->parent == p) {
    8000222a:	7c9c                	ld	a5,56(s1)
    8000222c:	ff279be3          	bne	a5,s2,80002222 <kwait+0xa8>
        acquire(&pp->lock);
    80002230:	8526                	mv	a0,s1
    80002232:	9cffe0ef          	jal	80000c00 <acquire>
        if (pp->state == ZOMBIE) {
    80002236:	4c9c                	lw	a5,24(s1)
    80002238:	f94783e3          	beq	a5,s4,800021be <kwait+0x44>
        release(&pp->lock);
    8000223c:	8526                	mv	a0,s1
    8000223e:	a5bfe0ef          	jal	80000c98 <release>
        havekids = 1;
    80002242:	8756                	mv	a4,s5
    80002244:	bff9                	j	80002222 <kwait+0xa8>
    if (!havekids || killed(p)) {
    80002246:	cf19                	beqz	a4,80002264 <kwait+0xea>
    80002248:	854a                	mv	a0,s2
    8000224a:	f07ff0ef          	jal	80002150 <killed>
    8000224e:	e919                	bnez	a0,80002264 <kwait+0xea>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002250:	85e2                	mv	a1,s8
    80002252:	854a                	mv	a0,s2
    80002254:	cc5ff0ef          	jal	80001f18 <sleep>
    havekids = 0;
    80002258:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000225a:	0000f497          	auipc	s1,0xf
    8000225e:	c3e48493          	addi	s1,s1,-962 # 80010e98 <proc>
    80002262:	b7e1                	j	8000222a <kwait+0xb0>
      release(&wait_lock);
    80002264:	0000f517          	auipc	a0,0xf
    80002268:	81c50513          	addi	a0,a0,-2020 # 80010a80 <wait_lock>
    8000226c:	a2dfe0ef          	jal	80000c98 <release>
      return -1;
    80002270:	59fd                	li	s3,-1
    80002272:	b741                	j	800021f2 <kwait+0x78>

0000000080002274 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len) {
    80002274:	7179                	addi	sp,sp,-48
    80002276:	f406                	sd	ra,40(sp)
    80002278:	f022                	sd	s0,32(sp)
    8000227a:	ec26                	sd	s1,24(sp)
    8000227c:	e84a                	sd	s2,16(sp)
    8000227e:	e44e                	sd	s3,8(sp)
    80002280:	e052                	sd	s4,0(sp)
    80002282:	1800                	addi	s0,sp,48
    80002284:	84aa                	mv	s1,a0
    80002286:	892e                	mv	s2,a1
    80002288:	89b2                	mv	s3,a2
    8000228a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000228c:	e7cff0ef          	jal	80001908 <myproc>
  if (user_dst) {
    80002290:	cc99                	beqz	s1,800022ae <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002292:	86d2                	mv	a3,s4
    80002294:	864e                	mv	a2,s3
    80002296:	85ca                	mv	a1,s2
    80002298:	6928                	ld	a0,80(a0)
    8000229a:	b82ff0ef          	jal	8000161c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000229e:	70a2                	ld	ra,40(sp)
    800022a0:	7402                	ld	s0,32(sp)
    800022a2:	64e2                	ld	s1,24(sp)
    800022a4:	6942                	ld	s2,16(sp)
    800022a6:	69a2                	ld	s3,8(sp)
    800022a8:	6a02                	ld	s4,0(sp)
    800022aa:	6145                	addi	sp,sp,48
    800022ac:	8082                	ret
    memmove((char *)dst, src, len);
    800022ae:	000a061b          	sext.w	a2,s4
    800022b2:	85ce                	mv	a1,s3
    800022b4:	854a                	mv	a0,s2
    800022b6:	a7bfe0ef          	jal	80000d30 <memmove>
    return 0;
    800022ba:	8526                	mv	a0,s1
    800022bc:	b7cd                	j	8000229e <either_copyout+0x2a>

00000000800022be <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len) {
    800022be:	7179                	addi	sp,sp,-48
    800022c0:	f406                	sd	ra,40(sp)
    800022c2:	f022                	sd	s0,32(sp)
    800022c4:	ec26                	sd	s1,24(sp)
    800022c6:	e84a                	sd	s2,16(sp)
    800022c8:	e44e                	sd	s3,8(sp)
    800022ca:	e052                	sd	s4,0(sp)
    800022cc:	1800                	addi	s0,sp,48
    800022ce:	892a                	mv	s2,a0
    800022d0:	84ae                	mv	s1,a1
    800022d2:	89b2                	mv	s3,a2
    800022d4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022d6:	e32ff0ef          	jal	80001908 <myproc>
  if (user_src) {
    800022da:	cc99                	beqz	s1,800022f8 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022dc:	86d2                	mv	a3,s4
    800022de:	864e                	mv	a2,s3
    800022e0:	85ca                	mv	a1,s2
    800022e2:	6928                	ld	a0,80(a0)
    800022e4:	c1cff0ef          	jal	80001700 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800022e8:	70a2                	ld	ra,40(sp)
    800022ea:	7402                	ld	s0,32(sp)
    800022ec:	64e2                	ld	s1,24(sp)
    800022ee:	6942                	ld	s2,16(sp)
    800022f0:	69a2                	ld	s3,8(sp)
    800022f2:	6a02                	ld	s4,0(sp)
    800022f4:	6145                	addi	sp,sp,48
    800022f6:	8082                	ret
    memmove(dst, (char *)src, len);
    800022f8:	000a061b          	sext.w	a2,s4
    800022fc:	85ce                	mv	a1,s3
    800022fe:	854a                	mv	a0,s2
    80002300:	a31fe0ef          	jal	80000d30 <memmove>
    return 0;
    80002304:	8526                	mv	a0,s1
    80002306:	b7cd                	j	800022e8 <either_copyin+0x2a>

0000000080002308 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
    80002308:	715d                	addi	sp,sp,-80
    8000230a:	e486                	sd	ra,72(sp)
    8000230c:	e0a2                	sd	s0,64(sp)
    8000230e:	fc26                	sd	s1,56(sp)
    80002310:	f84a                	sd	s2,48(sp)
    80002312:	f44e                	sd	s3,40(sp)
    80002314:	f052                	sd	s4,32(sp)
    80002316:	ec56                	sd	s5,24(sp)
    80002318:	e85a                	sd	s6,16(sp)
    8000231a:	e45e                	sd	s7,8(sp)
    8000231c:	0880                	addi	s0,sp,80
      [UNUSED] "unused",   [USED] "used",      [SLEEPING] "sleep ",
      [RUNNABLE] "runble", [RUNNING] "run   ", [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000231e:	00006517          	auipc	a0,0x6
    80002322:	d6250513          	addi	a0,a0,-670 # 80008080 <etext+0x80>
    80002326:	a06fe0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000232a:	0000f497          	auipc	s1,0xf
    8000232e:	cc648493          	addi	s1,s1,-826 # 80010ff0 <proc+0x158>
    80002332:	00014917          	auipc	s2,0x14
    80002336:	6be90913          	addi	s2,s2,1726 # 800169f0 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000233a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000233c:	00006997          	auipc	s3,0x6
    80002340:	ecc98993          	addi	s3,s3,-308 # 80008208 <etext+0x208>
    printf("%d %s %s", p->pid, state, p->name);
    80002344:	00006a97          	auipc	s5,0x6
    80002348:	ecca8a93          	addi	s5,s5,-308 # 80008210 <etext+0x210>
    printf("\n");
    8000234c:	00006a17          	auipc	s4,0x6
    80002350:	d34a0a13          	addi	s4,s4,-716 # 80008080 <etext+0x80>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002354:	00006b97          	auipc	s7,0x6
    80002358:	494b8b93          	addi	s7,s7,1172 # 800087e8 <states.0>
    8000235c:	a829                	j	80002376 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000235e:	ed86a583          	lw	a1,-296(a3)
    80002362:	8556                	mv	a0,s5
    80002364:	9c8fe0ef          	jal	8000052c <printf>
    printf("\n");
    80002368:	8552                	mv	a0,s4
    8000236a:	9c2fe0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000236e:	16848493          	addi	s1,s1,360
    80002372:	03248263          	beq	s1,s2,80002396 <procdump+0x8e>
    if (p->state == UNUSED)
    80002376:	86a6                	mv	a3,s1
    80002378:	ec04a783          	lw	a5,-320(s1)
    8000237c:	dbed                	beqz	a5,8000236e <procdump+0x66>
      state = "???";
    8000237e:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002380:	fcfb6fe3          	bltu	s6,a5,8000235e <procdump+0x56>
    80002384:	02079713          	slli	a4,a5,0x20
    80002388:	01d75793          	srli	a5,a4,0x1d
    8000238c:	97de                	add	a5,a5,s7
    8000238e:	6390                	ld	a2,0(a5)
    80002390:	f679                	bnez	a2,8000235e <procdump+0x56>
      state = "???";
    80002392:	864e                	mv	a2,s3
    80002394:	b7e9                	j	8000235e <procdump+0x56>
  }
}
    80002396:	60a6                	ld	ra,72(sp)
    80002398:	6406                	ld	s0,64(sp)
    8000239a:	74e2                	ld	s1,56(sp)
    8000239c:	7942                	ld	s2,48(sp)
    8000239e:	79a2                	ld	s3,40(sp)
    800023a0:	7a02                	ld	s4,32(sp)
    800023a2:	6ae2                	ld	s5,24(sp)
    800023a4:	6b42                	ld	s6,16(sp)
    800023a6:	6ba2                	ld	s7,8(sp)
    800023a8:	6161                	addi	sp,sp,80
    800023aa:	8082                	ret

00000000800023ac <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800023ac:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800023b0:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800023b4:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800023b6:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800023b8:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800023bc:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800023c0:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800023c4:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800023c8:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800023cc:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800023d0:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800023d4:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800023d8:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800023dc:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800023e0:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800023e4:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800023e8:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800023ea:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800023ec:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800023f0:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800023f4:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800023f8:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800023fc:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002400:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002404:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002408:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000240c:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002410:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002414:	8082                	ret

0000000080002416 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002416:	1141                	addi	sp,sp,-16
    80002418:	e406                	sd	ra,8(sp)
    8000241a:	e022                	sd	s0,0(sp)
    8000241c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000241e:	00006597          	auipc	a1,0x6
    80002422:	e3258593          	addi	a1,a1,-462 # 80008250 <etext+0x250>
    80002426:	00014517          	auipc	a0,0x14
    8000242a:	47250513          	addi	a0,a0,1138 # 80016898 <tickslock>
    8000242e:	f52fe0ef          	jal	80000b80 <initlock>
}
    80002432:	60a2                	ld	ra,8(sp)
    80002434:	6402                	ld	s0,0(sp)
    80002436:	0141                	addi	sp,sp,16
    80002438:	8082                	ret

000000008000243a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000243a:	1141                	addi	sp,sp,-16
    8000243c:	e422                	sd	s0,8(sp)
    8000243e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002440:	00003797          	auipc	a5,0x3
    80002444:	2a078793          	addi	a5,a5,672 # 800056e0 <kernelvec>
    80002448:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000244c:	6422                	ld	s0,8(sp)
    8000244e:	0141                	addi	sp,sp,16
    80002450:	8082                	ret

0000000080002452 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002452:	1141                	addi	sp,sp,-16
    80002454:	e406                	sd	ra,8(sp)
    80002456:	e022                	sd	s0,0(sp)
    80002458:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000245a:	caeff0ef          	jal	80001908 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000245e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002462:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002464:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002468:	04000737          	lui	a4,0x4000
    8000246c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000246e:	0732                	slli	a4,a4,0xc
    80002470:	00005797          	auipc	a5,0x5
    80002474:	b9078793          	addi	a5,a5,-1136 # 80007000 <_trampoline>
    80002478:	00005697          	auipc	a3,0x5
    8000247c:	b8868693          	addi	a3,a3,-1144 # 80007000 <_trampoline>
    80002480:	8f95                	sub	a5,a5,a3
    80002482:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002484:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002488:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000248a:	18002773          	csrr	a4,satp
    8000248e:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002490:	6d38                	ld	a4,88(a0)
    80002492:	613c                	ld	a5,64(a0)
    80002494:	6685                	lui	a3,0x1
    80002496:	97b6                	add	a5,a5,a3
    80002498:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000249a:	6d3c                	ld	a5,88(a0)
    8000249c:	00000717          	auipc	a4,0x0
    800024a0:	0f870713          	addi	a4,a4,248 # 80002594 <usertrap>
    800024a4:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800024a6:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800024a8:	8712                	mv	a4,tp
    800024aa:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024ac:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024b0:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024b4:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024b8:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024bc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800024be:	6f9c                	ld	a5,24(a5)
    800024c0:	14179073          	csrw	sepc,a5
}
    800024c4:	60a2                	ld	ra,8(sp)
    800024c6:	6402                	ld	s0,0(sp)
    800024c8:	0141                	addi	sp,sp,16
    800024ca:	8082                	ret

00000000800024cc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024cc:	1101                	addi	sp,sp,-32
    800024ce:	ec06                	sd	ra,24(sp)
    800024d0:	e822                	sd	s0,16(sp)
    800024d2:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800024d4:	c08ff0ef          	jal	800018dc <cpuid>
    800024d8:	cd11                	beqz	a0,800024f4 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800024da:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024de:	000f4737          	lui	a4,0xf4
    800024e2:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024e6:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800024e8:	14d79073          	csrw	stimecmp,a5
}
    800024ec:	60e2                	ld	ra,24(sp)
    800024ee:	6442                	ld	s0,16(sp)
    800024f0:	6105                	addi	sp,sp,32
    800024f2:	8082                	ret
    800024f4:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024f6:	00014497          	auipc	s1,0x14
    800024fa:	3a248493          	addi	s1,s1,930 # 80016898 <tickslock>
    800024fe:	8526                	mv	a0,s1
    80002500:	f00fe0ef          	jal	80000c00 <acquire>
    ticks++;
    80002504:	00006517          	auipc	a0,0x6
    80002508:	42450513          	addi	a0,a0,1060 # 80008928 <ticks>
    8000250c:	411c                	lw	a5,0(a0)
    8000250e:	2785                	addiw	a5,a5,1
    80002510:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002512:	a53ff0ef          	jal	80001f64 <wakeup>
    release(&tickslock);
    80002516:	8526                	mv	a0,s1
    80002518:	f80fe0ef          	jal	80000c98 <release>
    8000251c:	64a2                	ld	s1,8(sp)
    8000251e:	bf75                	j	800024da <clockintr+0xe>

0000000080002520 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002520:	1101                	addi	sp,sp,-32
    80002522:	ec06                	sd	ra,24(sp)
    80002524:	e822                	sd	s0,16(sp)
    80002526:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002528:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000252c:	57fd                	li	a5,-1
    8000252e:	17fe                	slli	a5,a5,0x3f
    80002530:	07a5                	addi	a5,a5,9
    80002532:	00f70c63          	beq	a4,a5,8000254a <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002536:	57fd                	li	a5,-1
    80002538:	17fe                	slli	a5,a5,0x3f
    8000253a:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000253c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000253e:	04f70763          	beq	a4,a5,8000258c <devintr+0x6c>
  }
}
    80002542:	60e2                	ld	ra,24(sp)
    80002544:	6442                	ld	s0,16(sp)
    80002546:	6105                	addi	sp,sp,32
    80002548:	8082                	ret
    8000254a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000254c:	240030ef          	jal	8000578c <plic_claim>
    80002550:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002552:	47a9                	li	a5,10
    80002554:	00f50963          	beq	a0,a5,80002566 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002558:	4785                	li	a5,1
    8000255a:	00f50963          	beq	a0,a5,8000256c <devintr+0x4c>
    return 1;
    8000255e:	4505                	li	a0,1
    } else if(irq){
    80002560:	e889                	bnez	s1,80002572 <devintr+0x52>
    80002562:	64a2                	ld	s1,8(sp)
    80002564:	bff9                	j	80002542 <devintr+0x22>
      uartintr();
    80002566:	c7cfe0ef          	jal	800009e2 <uartintr>
    if(irq)
    8000256a:	a819                	j	80002580 <devintr+0x60>
      virtio_disk_intr();
    8000256c:	6e6030ef          	jal	80005c52 <virtio_disk_intr>
    if(irq)
    80002570:	a801                	j	80002580 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002572:	85a6                	mv	a1,s1
    80002574:	00006517          	auipc	a0,0x6
    80002578:	ce450513          	addi	a0,a0,-796 # 80008258 <etext+0x258>
    8000257c:	fb1fd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    80002580:	8526                	mv	a0,s1
    80002582:	22a030ef          	jal	800057ac <plic_complete>
    return 1;
    80002586:	4505                	li	a0,1
    80002588:	64a2                	ld	s1,8(sp)
    8000258a:	bf65                	j	80002542 <devintr+0x22>
    clockintr();
    8000258c:	f41ff0ef          	jal	800024cc <clockintr>
    return 2;
    80002590:	4509                	li	a0,2
    80002592:	bf45                	j	80002542 <devintr+0x22>

0000000080002594 <usertrap>:
{
    80002594:	1101                	addi	sp,sp,-32
    80002596:	ec06                	sd	ra,24(sp)
    80002598:	e822                	sd	s0,16(sp)
    8000259a:	e426                	sd	s1,8(sp)
    8000259c:	e04a                	sd	s2,0(sp)
    8000259e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025a0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800025a4:	1007f793          	andi	a5,a5,256
    800025a8:	eba5                	bnez	a5,80002618 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025aa:	00003797          	auipc	a5,0x3
    800025ae:	13678793          	addi	a5,a5,310 # 800056e0 <kernelvec>
    800025b2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025b6:	b52ff0ef          	jal	80001908 <myproc>
    800025ba:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025bc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025be:	14102773          	csrr	a4,sepc
    800025c2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025c4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800025c8:	47a1                	li	a5,8
    800025ca:	04f70d63          	beq	a4,a5,80002624 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800025ce:	f53ff0ef          	jal	80002520 <devintr>
    800025d2:	892a                	mv	s2,a0
    800025d4:	e945                	bnez	a0,80002684 <usertrap+0xf0>
    800025d6:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800025da:	47bd                	li	a5,15
    800025dc:	08f70863          	beq	a4,a5,8000266c <usertrap+0xd8>
    800025e0:	14202773          	csrr	a4,scause
    800025e4:	47b5                	li	a5,13
    800025e6:	08f70363          	beq	a4,a5,8000266c <usertrap+0xd8>
    800025ea:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025ee:	5890                	lw	a2,48(s1)
    800025f0:	00006517          	auipc	a0,0x6
    800025f4:	ca850513          	addi	a0,a0,-856 # 80008298 <etext+0x298>
    800025f8:	f35fd0ef          	jal	8000052c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025fc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002600:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002604:	00006517          	auipc	a0,0x6
    80002608:	cc450513          	addi	a0,a0,-828 # 800082c8 <etext+0x2c8>
    8000260c:	f21fd0ef          	jal	8000052c <printf>
    setkilled(p);
    80002610:	8526                	mv	a0,s1
    80002612:	b1bff0ef          	jal	8000212c <setkilled>
    80002616:	a035                	j	80002642 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002618:	00006517          	auipc	a0,0x6
    8000261c:	c6050513          	addi	a0,a0,-928 # 80008278 <etext+0x278>
    80002620:	9f2fe0ef          	jal	80000812 <panic>
    if(killed(p))
    80002624:	b2dff0ef          	jal	80002150 <killed>
    80002628:	ed15                	bnez	a0,80002664 <usertrap+0xd0>
    p->trapframe->epc += 4;
    8000262a:	6cb8                	ld	a4,88(s1)
    8000262c:	6f1c                	ld	a5,24(a4)
    8000262e:	0791                	addi	a5,a5,4
    80002630:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002632:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002636:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000263a:	10079073          	csrw	sstatus,a5
    syscall();
    8000263e:	246000ef          	jal	80002884 <syscall>
  if(killed(p))
    80002642:	8526                	mv	a0,s1
    80002644:	b0dff0ef          	jal	80002150 <killed>
    80002648:	e139                	bnez	a0,8000268e <usertrap+0xfa>
  prepare_return();
    8000264a:	e09ff0ef          	jal	80002452 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000264e:	68a8                	ld	a0,80(s1)
    80002650:	8131                	srli	a0,a0,0xc
    80002652:	57fd                	li	a5,-1
    80002654:	17fe                	slli	a5,a5,0x3f
    80002656:	8d5d                	or	a0,a0,a5
}
    80002658:	60e2                	ld	ra,24(sp)
    8000265a:	6442                	ld	s0,16(sp)
    8000265c:	64a2                	ld	s1,8(sp)
    8000265e:	6902                	ld	s2,0(sp)
    80002660:	6105                	addi	sp,sp,32
    80002662:	8082                	ret
      kexit(-1);
    80002664:	557d                	li	a0,-1
    80002666:	9bfff0ef          	jal	80002024 <kexit>
    8000266a:	b7c1                	j	8000262a <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000266c:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002670:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002674:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002676:	00163613          	seqz	a2,a2
    8000267a:	68a8                	ld	a0,80(s1)
    8000267c:	f1ffe0ef          	jal	8000159a <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002680:	f169                	bnez	a0,80002642 <usertrap+0xae>
    80002682:	b7a5                	j	800025ea <usertrap+0x56>
  if(killed(p))
    80002684:	8526                	mv	a0,s1
    80002686:	acbff0ef          	jal	80002150 <killed>
    8000268a:	c511                	beqz	a0,80002696 <usertrap+0x102>
    8000268c:	a011                	j	80002690 <usertrap+0xfc>
    8000268e:	4901                	li	s2,0
    kexit(-1);
    80002690:	557d                	li	a0,-1
    80002692:	993ff0ef          	jal	80002024 <kexit>
  if(which_dev == 2)
    80002696:	4789                	li	a5,2
    80002698:	faf919e3          	bne	s2,a5,8000264a <usertrap+0xb6>
    yield();
    8000269c:	851ff0ef          	jal	80001eec <yield>
    800026a0:	b76d                	j	8000264a <usertrap+0xb6>

00000000800026a2 <kerneltrap>:
{
    800026a2:	7179                	addi	sp,sp,-48
    800026a4:	f406                	sd	ra,40(sp)
    800026a6:	f022                	sd	s0,32(sp)
    800026a8:	ec26                	sd	s1,24(sp)
    800026aa:	e84a                	sd	s2,16(sp)
    800026ac:	e44e                	sd	s3,8(sp)
    800026ae:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026b0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026b8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800026bc:	1004f793          	andi	a5,s1,256
    800026c0:	c795                	beqz	a5,800026ec <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026c2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026c6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800026c8:	eb85                	bnez	a5,800026f8 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800026ca:	e57ff0ef          	jal	80002520 <devintr>
    800026ce:	c91d                	beqz	a0,80002704 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800026d0:	4789                	li	a5,2
    800026d2:	04f50a63          	beq	a0,a5,80002726 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026d6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026da:	10049073          	csrw	sstatus,s1
}
    800026de:	70a2                	ld	ra,40(sp)
    800026e0:	7402                	ld	s0,32(sp)
    800026e2:	64e2                	ld	s1,24(sp)
    800026e4:	6942                	ld	s2,16(sp)
    800026e6:	69a2                	ld	s3,8(sp)
    800026e8:	6145                	addi	sp,sp,48
    800026ea:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026ec:	00006517          	auipc	a0,0x6
    800026f0:	c0450513          	addi	a0,a0,-1020 # 800082f0 <etext+0x2f0>
    800026f4:	91efe0ef          	jal	80000812 <panic>
    panic("kerneltrap: interrupts enabled");
    800026f8:	00006517          	auipc	a0,0x6
    800026fc:	c2050513          	addi	a0,a0,-992 # 80008318 <etext+0x318>
    80002700:	912fe0ef          	jal	80000812 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002704:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002708:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000270c:	85ce                	mv	a1,s3
    8000270e:	00006517          	auipc	a0,0x6
    80002712:	c2a50513          	addi	a0,a0,-982 # 80008338 <etext+0x338>
    80002716:	e17fd0ef          	jal	8000052c <printf>
    panic("kerneltrap");
    8000271a:	00006517          	auipc	a0,0x6
    8000271e:	c4650513          	addi	a0,a0,-954 # 80008360 <etext+0x360>
    80002722:	8f0fe0ef          	jal	80000812 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002726:	9e2ff0ef          	jal	80001908 <myproc>
    8000272a:	d555                	beqz	a0,800026d6 <kerneltrap+0x34>
    yield();
    8000272c:	fc0ff0ef          	jal	80001eec <yield>
    80002730:	b75d                	j	800026d6 <kerneltrap+0x34>

0000000080002732 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002732:	1101                	addi	sp,sp,-32
    80002734:	ec06                	sd	ra,24(sp)
    80002736:	e822                	sd	s0,16(sp)
    80002738:	e426                	sd	s1,8(sp)
    8000273a:	1000                	addi	s0,sp,32
    8000273c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000273e:	9caff0ef          	jal	80001908 <myproc>
  switch (n) {
    80002742:	4795                	li	a5,5
    80002744:	0497e163          	bltu	a5,s1,80002786 <argraw+0x54>
    80002748:	048a                	slli	s1,s1,0x2
    8000274a:	00006717          	auipc	a4,0x6
    8000274e:	0ce70713          	addi	a4,a4,206 # 80008818 <states.0+0x30>
    80002752:	94ba                	add	s1,s1,a4
    80002754:	409c                	lw	a5,0(s1)
    80002756:	97ba                	add	a5,a5,a4
    80002758:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000275a:	6d3c                	ld	a5,88(a0)
    8000275c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000275e:	60e2                	ld	ra,24(sp)
    80002760:	6442                	ld	s0,16(sp)
    80002762:	64a2                	ld	s1,8(sp)
    80002764:	6105                	addi	sp,sp,32
    80002766:	8082                	ret
    return p->trapframe->a1;
    80002768:	6d3c                	ld	a5,88(a0)
    8000276a:	7fa8                	ld	a0,120(a5)
    8000276c:	bfcd                	j	8000275e <argraw+0x2c>
    return p->trapframe->a2;
    8000276e:	6d3c                	ld	a5,88(a0)
    80002770:	63c8                	ld	a0,128(a5)
    80002772:	b7f5                	j	8000275e <argraw+0x2c>
    return p->trapframe->a3;
    80002774:	6d3c                	ld	a5,88(a0)
    80002776:	67c8                	ld	a0,136(a5)
    80002778:	b7dd                	j	8000275e <argraw+0x2c>
    return p->trapframe->a4;
    8000277a:	6d3c                	ld	a5,88(a0)
    8000277c:	6bc8                	ld	a0,144(a5)
    8000277e:	b7c5                	j	8000275e <argraw+0x2c>
    return p->trapframe->a5;
    80002780:	6d3c                	ld	a5,88(a0)
    80002782:	6fc8                	ld	a0,152(a5)
    80002784:	bfe9                	j	8000275e <argraw+0x2c>
  panic("argraw");
    80002786:	00006517          	auipc	a0,0x6
    8000278a:	bea50513          	addi	a0,a0,-1046 # 80008370 <etext+0x370>
    8000278e:	884fe0ef          	jal	80000812 <panic>

0000000080002792 <fetchaddr>:
{
    80002792:	1101                	addi	sp,sp,-32
    80002794:	ec06                	sd	ra,24(sp)
    80002796:	e822                	sd	s0,16(sp)
    80002798:	e426                	sd	s1,8(sp)
    8000279a:	e04a                	sd	s2,0(sp)
    8000279c:	1000                	addi	s0,sp,32
    8000279e:	84aa                	mv	s1,a0
    800027a0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027a2:	966ff0ef          	jal	80001908 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800027a6:	653c                	ld	a5,72(a0)
    800027a8:	02f4f663          	bgeu	s1,a5,800027d4 <fetchaddr+0x42>
    800027ac:	00848713          	addi	a4,s1,8
    800027b0:	02e7e463          	bltu	a5,a4,800027d8 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800027b4:	46a1                	li	a3,8
    800027b6:	8626                	mv	a2,s1
    800027b8:	85ca                	mv	a1,s2
    800027ba:	6928                	ld	a0,80(a0)
    800027bc:	f45fe0ef          	jal	80001700 <copyin>
    800027c0:	00a03533          	snez	a0,a0
    800027c4:	40a00533          	neg	a0,a0
}
    800027c8:	60e2                	ld	ra,24(sp)
    800027ca:	6442                	ld	s0,16(sp)
    800027cc:	64a2                	ld	s1,8(sp)
    800027ce:	6902                	ld	s2,0(sp)
    800027d0:	6105                	addi	sp,sp,32
    800027d2:	8082                	ret
    return -1;
    800027d4:	557d                	li	a0,-1
    800027d6:	bfcd                	j	800027c8 <fetchaddr+0x36>
    800027d8:	557d                	li	a0,-1
    800027da:	b7fd                	j	800027c8 <fetchaddr+0x36>

00000000800027dc <fetchstr>:
{
    800027dc:	7179                	addi	sp,sp,-48
    800027de:	f406                	sd	ra,40(sp)
    800027e0:	f022                	sd	s0,32(sp)
    800027e2:	ec26                	sd	s1,24(sp)
    800027e4:	e84a                	sd	s2,16(sp)
    800027e6:	e44e                	sd	s3,8(sp)
    800027e8:	1800                	addi	s0,sp,48
    800027ea:	892a                	mv	s2,a0
    800027ec:	84ae                	mv	s1,a1
    800027ee:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027f0:	918ff0ef          	jal	80001908 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027f4:	86ce                	mv	a3,s3
    800027f6:	864a                	mv	a2,s2
    800027f8:	85a6                	mv	a1,s1
    800027fa:	6928                	ld	a0,80(a0)
    800027fc:	cc7fe0ef          	jal	800014c2 <copyinstr>
    80002800:	00054c63          	bltz	a0,80002818 <fetchstr+0x3c>
  return strlen(buf);
    80002804:	8526                	mv	a0,s1
    80002806:	e3efe0ef          	jal	80000e44 <strlen>
}
    8000280a:	70a2                	ld	ra,40(sp)
    8000280c:	7402                	ld	s0,32(sp)
    8000280e:	64e2                	ld	s1,24(sp)
    80002810:	6942                	ld	s2,16(sp)
    80002812:	69a2                	ld	s3,8(sp)
    80002814:	6145                	addi	sp,sp,48
    80002816:	8082                	ret
    return -1;
    80002818:	557d                	li	a0,-1
    8000281a:	bfc5                	j	8000280a <fetchstr+0x2e>

000000008000281c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000281c:	1101                	addi	sp,sp,-32
    8000281e:	ec06                	sd	ra,24(sp)
    80002820:	e822                	sd	s0,16(sp)
    80002822:	e426                	sd	s1,8(sp)
    80002824:	1000                	addi	s0,sp,32
    80002826:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002828:	f0bff0ef          	jal	80002732 <argraw>
    8000282c:	c088                	sw	a0,0(s1)
}
    8000282e:	60e2                	ld	ra,24(sp)
    80002830:	6442                	ld	s0,16(sp)
    80002832:	64a2                	ld	s1,8(sp)
    80002834:	6105                	addi	sp,sp,32
    80002836:	8082                	ret

0000000080002838 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002838:	1101                	addi	sp,sp,-32
    8000283a:	ec06                	sd	ra,24(sp)
    8000283c:	e822                	sd	s0,16(sp)
    8000283e:	e426                	sd	s1,8(sp)
    80002840:	1000                	addi	s0,sp,32
    80002842:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002844:	eefff0ef          	jal	80002732 <argraw>
    80002848:	e088                	sd	a0,0(s1)
}
    8000284a:	60e2                	ld	ra,24(sp)
    8000284c:	6442                	ld	s0,16(sp)
    8000284e:	64a2                	ld	s1,8(sp)
    80002850:	6105                	addi	sp,sp,32
    80002852:	8082                	ret

0000000080002854 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002854:	7179                	addi	sp,sp,-48
    80002856:	f406                	sd	ra,40(sp)
    80002858:	f022                	sd	s0,32(sp)
    8000285a:	ec26                	sd	s1,24(sp)
    8000285c:	e84a                	sd	s2,16(sp)
    8000285e:	1800                	addi	s0,sp,48
    80002860:	84ae                	mv	s1,a1
    80002862:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002864:	fd840593          	addi	a1,s0,-40
    80002868:	fd1ff0ef          	jal	80002838 <argaddr>
  return fetchstr(addr, buf, max);
    8000286c:	864a                	mv	a2,s2
    8000286e:	85a6                	mv	a1,s1
    80002870:	fd843503          	ld	a0,-40(s0)
    80002874:	f69ff0ef          	jal	800027dc <fetchstr>
}
    80002878:	70a2                	ld	ra,40(sp)
    8000287a:	7402                	ld	s0,32(sp)
    8000287c:	64e2                	ld	s1,24(sp)
    8000287e:	6942                	ld	s2,16(sp)
    80002880:	6145                	addi	sp,sp,48
    80002882:	8082                	ret

0000000080002884 <syscall>:

};

void
syscall(void)
{
    80002884:	1101                	addi	sp,sp,-32
    80002886:	ec06                	sd	ra,24(sp)
    80002888:	e822                	sd	s0,16(sp)
    8000288a:	e426                	sd	s1,8(sp)
    8000288c:	e04a                	sd	s2,0(sp)
    8000288e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002890:	878ff0ef          	jal	80001908 <myproc>
    80002894:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002896:	05853903          	ld	s2,88(a0)
    8000289a:	0a893783          	ld	a5,168(s2)
    8000289e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800028a2:	37fd                	addiw	a5,a5,-1
    800028a4:	4759                	li	a4,22
    800028a6:	00f76f63          	bltu	a4,a5,800028c4 <syscall+0x40>
    800028aa:	00369713          	slli	a4,a3,0x3
    800028ae:	00006797          	auipc	a5,0x6
    800028b2:	f8278793          	addi	a5,a5,-126 # 80008830 <syscalls>
    800028b6:	97ba                	add	a5,a5,a4
    800028b8:	639c                	ld	a5,0(a5)
    800028ba:	c789                	beqz	a5,800028c4 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028bc:	9782                	jalr	a5
    800028be:	06a93823          	sd	a0,112(s2)
    800028c2:	a829                	j	800028dc <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800028c4:	15848613          	addi	a2,s1,344
    800028c8:	588c                	lw	a1,48(s1)
    800028ca:	00006517          	auipc	a0,0x6
    800028ce:	aae50513          	addi	a0,a0,-1362 # 80008378 <etext+0x378>
    800028d2:	c5bfd0ef          	jal	8000052c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800028d6:	6cbc                	ld	a5,88(s1)
    800028d8:	577d                	li	a4,-1
    800028da:	fbb8                	sd	a4,112(a5)
  }
}
    800028dc:	60e2                	ld	ra,24(sp)
    800028de:	6442                	ld	s0,16(sp)
    800028e0:	64a2                	ld	s1,8(sp)
    800028e2:	6902                	ld	s2,0(sp)
    800028e4:	6105                	addi	sp,sp,32
    800028e6:	8082                	ret

00000000800028e8 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800028e8:	1101                	addi	sp,sp,-32
    800028ea:	ec06                	sd	ra,24(sp)
    800028ec:	e822                	sd	s0,16(sp)
    800028ee:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028f0:	fec40593          	addi	a1,s0,-20
    800028f4:	4501                	li	a0,0
    800028f6:	f27ff0ef          	jal	8000281c <argint>
  kexit(n);
    800028fa:	fec42503          	lw	a0,-20(s0)
    800028fe:	f26ff0ef          	jal	80002024 <kexit>
  return 0;  // not reached
}
    80002902:	4501                	li	a0,0
    80002904:	60e2                	ld	ra,24(sp)
    80002906:	6442                	ld	s0,16(sp)
    80002908:	6105                	addi	sp,sp,32
    8000290a:	8082                	ret

000000008000290c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000290c:	1141                	addi	sp,sp,-16
    8000290e:	e406                	sd	ra,8(sp)
    80002910:	e022                	sd	s0,0(sp)
    80002912:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002914:	ff5fe0ef          	jal	80001908 <myproc>
}
    80002918:	5908                	lw	a0,48(a0)
    8000291a:	60a2                	ld	ra,8(sp)
    8000291c:	6402                	ld	s0,0(sp)
    8000291e:	0141                	addi	sp,sp,16
    80002920:	8082                	ret

0000000080002922 <sys_fork>:

uint64
sys_fork(void)
{
    80002922:	1141                	addi	sp,sp,-16
    80002924:	e406                	sd	ra,8(sp)
    80002926:	e022                	sd	s0,0(sp)
    80002928:	0800                	addi	s0,sp,16
  return kfork();
    8000292a:	b42ff0ef          	jal	80001c6c <kfork>
}
    8000292e:	60a2                	ld	ra,8(sp)
    80002930:	6402                	ld	s0,0(sp)
    80002932:	0141                	addi	sp,sp,16
    80002934:	8082                	ret

0000000080002936 <sys_wait>:

uint64
sys_wait(void)
{
    80002936:	1101                	addi	sp,sp,-32
    80002938:	ec06                	sd	ra,24(sp)
    8000293a:	e822                	sd	s0,16(sp)
    8000293c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000293e:	fe840593          	addi	a1,s0,-24
    80002942:	4501                	li	a0,0
    80002944:	ef5ff0ef          	jal	80002838 <argaddr>
  return kwait(p);
    80002948:	fe843503          	ld	a0,-24(s0)
    8000294c:	82fff0ef          	jal	8000217a <kwait>
}
    80002950:	60e2                	ld	ra,24(sp)
    80002952:	6442                	ld	s0,16(sp)
    80002954:	6105                	addi	sp,sp,32
    80002956:	8082                	ret

0000000080002958 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002958:	7179                	addi	sp,sp,-48
    8000295a:	f406                	sd	ra,40(sp)
    8000295c:	f022                	sd	s0,32(sp)
    8000295e:	ec26                	sd	s1,24(sp)
    80002960:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002962:	fd840593          	addi	a1,s0,-40
    80002966:	4501                	li	a0,0
    80002968:	eb5ff0ef          	jal	8000281c <argint>
  argint(1, &t);
    8000296c:	fdc40593          	addi	a1,s0,-36
    80002970:	4505                	li	a0,1
    80002972:	eabff0ef          	jal	8000281c <argint>
  addr = myproc()->sz;
    80002976:	f93fe0ef          	jal	80001908 <myproc>
    8000297a:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    8000297c:	fdc42703          	lw	a4,-36(s0)
    80002980:	4785                	li	a5,1
    80002982:	02f70763          	beq	a4,a5,800029b0 <sys_sbrk+0x58>
    80002986:	fd842783          	lw	a5,-40(s0)
    8000298a:	0207c363          	bltz	a5,800029b0 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    8000298e:	97a6                	add	a5,a5,s1
    80002990:	0297ee63          	bltu	a5,s1,800029cc <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002994:	02000737          	lui	a4,0x2000
    80002998:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    8000299a:	0736                	slli	a4,a4,0xd
    8000299c:	02f76a63          	bltu	a4,a5,800029d0 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    800029a0:	f69fe0ef          	jal	80001908 <myproc>
    800029a4:	fd842703          	lw	a4,-40(s0)
    800029a8:	653c                	ld	a5,72(a0)
    800029aa:	97ba                	add	a5,a5,a4
    800029ac:	e53c                	sd	a5,72(a0)
    800029ae:	a039                	j	800029bc <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    800029b0:	fd842503          	lw	a0,-40(s0)
    800029b4:	a56ff0ef          	jal	80001c0a <growproc>
    800029b8:	00054863          	bltz	a0,800029c8 <sys_sbrk+0x70>
  }
  return addr;
}
    800029bc:	8526                	mv	a0,s1
    800029be:	70a2                	ld	ra,40(sp)
    800029c0:	7402                	ld	s0,32(sp)
    800029c2:	64e2                	ld	s1,24(sp)
    800029c4:	6145                	addi	sp,sp,48
    800029c6:	8082                	ret
      return -1;
    800029c8:	54fd                	li	s1,-1
    800029ca:	bfcd                	j	800029bc <sys_sbrk+0x64>
      return -1;
    800029cc:	54fd                	li	s1,-1
    800029ce:	b7fd                	j	800029bc <sys_sbrk+0x64>
      return -1;
    800029d0:	54fd                	li	s1,-1
    800029d2:	b7ed                	j	800029bc <sys_sbrk+0x64>

00000000800029d4 <sys_pause>:

uint64
sys_pause(void)
{
    800029d4:	7139                	addi	sp,sp,-64
    800029d6:	fc06                	sd	ra,56(sp)
    800029d8:	f822                	sd	s0,48(sp)
    800029da:	f04a                	sd	s2,32(sp)
    800029dc:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029de:	fcc40593          	addi	a1,s0,-52
    800029e2:	4501                	li	a0,0
    800029e4:	e39ff0ef          	jal	8000281c <argint>
  if(n < 0)
    800029e8:	fcc42783          	lw	a5,-52(s0)
    800029ec:	0607c763          	bltz	a5,80002a5a <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800029f0:	00014517          	auipc	a0,0x14
    800029f4:	ea850513          	addi	a0,a0,-344 # 80016898 <tickslock>
    800029f8:	a08fe0ef          	jal	80000c00 <acquire>
  ticks0 = ticks;
    800029fc:	00006917          	auipc	s2,0x6
    80002a00:	f2c92903          	lw	s2,-212(s2) # 80008928 <ticks>
  while(ticks - ticks0 < n){
    80002a04:	fcc42783          	lw	a5,-52(s0)
    80002a08:	cf8d                	beqz	a5,80002a42 <sys_pause+0x6e>
    80002a0a:	f426                	sd	s1,40(sp)
    80002a0c:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a0e:	00014997          	auipc	s3,0x14
    80002a12:	e8a98993          	addi	s3,s3,-374 # 80016898 <tickslock>
    80002a16:	00006497          	auipc	s1,0x6
    80002a1a:	f1248493          	addi	s1,s1,-238 # 80008928 <ticks>
    if(killed(myproc())){
    80002a1e:	eebfe0ef          	jal	80001908 <myproc>
    80002a22:	f2eff0ef          	jal	80002150 <killed>
    80002a26:	ed0d                	bnez	a0,80002a60 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002a28:	85ce                	mv	a1,s3
    80002a2a:	8526                	mv	a0,s1
    80002a2c:	cecff0ef          	jal	80001f18 <sleep>
  while(ticks - ticks0 < n){
    80002a30:	409c                	lw	a5,0(s1)
    80002a32:	412787bb          	subw	a5,a5,s2
    80002a36:	fcc42703          	lw	a4,-52(s0)
    80002a3a:	fee7e2e3          	bltu	a5,a4,80002a1e <sys_pause+0x4a>
    80002a3e:	74a2                	ld	s1,40(sp)
    80002a40:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a42:	00014517          	auipc	a0,0x14
    80002a46:	e5650513          	addi	a0,a0,-426 # 80016898 <tickslock>
    80002a4a:	a4efe0ef          	jal	80000c98 <release>
  return 0;
    80002a4e:	4501                	li	a0,0
}
    80002a50:	70e2                	ld	ra,56(sp)
    80002a52:	7442                	ld	s0,48(sp)
    80002a54:	7902                	ld	s2,32(sp)
    80002a56:	6121                	addi	sp,sp,64
    80002a58:	8082                	ret
    n = 0;
    80002a5a:	fc042623          	sw	zero,-52(s0)
    80002a5e:	bf49                	j	800029f0 <sys_pause+0x1c>
      release(&tickslock);
    80002a60:	00014517          	auipc	a0,0x14
    80002a64:	e3850513          	addi	a0,a0,-456 # 80016898 <tickslock>
    80002a68:	a30fe0ef          	jal	80000c98 <release>
      return -1;
    80002a6c:	557d                	li	a0,-1
    80002a6e:	74a2                	ld	s1,40(sp)
    80002a70:	69e2                	ld	s3,24(sp)
    80002a72:	bff9                	j	80002a50 <sys_pause+0x7c>

0000000080002a74 <sys_kill>:

uint64
sys_kill(void)
{
    80002a74:	1101                	addi	sp,sp,-32
    80002a76:	ec06                	sd	ra,24(sp)
    80002a78:	e822                	sd	s0,16(sp)
    80002a7a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a7c:	fec40593          	addi	a1,s0,-20
    80002a80:	4501                	li	a0,0
    80002a82:	d9bff0ef          	jal	8000281c <argint>
  return kkill(pid);
    80002a86:	fec42503          	lw	a0,-20(s0)
    80002a8a:	e3cff0ef          	jal	800020c6 <kkill>
}
    80002a8e:	60e2                	ld	ra,24(sp)
    80002a90:	6442                	ld	s0,16(sp)
    80002a92:	6105                	addi	sp,sp,32
    80002a94:	8082                	ret

0000000080002a96 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a96:	1101                	addi	sp,sp,-32
    80002a98:	ec06                	sd	ra,24(sp)
    80002a9a:	e822                	sd	s0,16(sp)
    80002a9c:	e426                	sd	s1,8(sp)
    80002a9e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002aa0:	00014517          	auipc	a0,0x14
    80002aa4:	df850513          	addi	a0,a0,-520 # 80016898 <tickslock>
    80002aa8:	958fe0ef          	jal	80000c00 <acquire>
  xticks = ticks;
    80002aac:	00006497          	auipc	s1,0x6
    80002ab0:	e7c4a483          	lw	s1,-388(s1) # 80008928 <ticks>
  release(&tickslock);
    80002ab4:	00014517          	auipc	a0,0x14
    80002ab8:	de450513          	addi	a0,a0,-540 # 80016898 <tickslock>
    80002abc:	9dcfe0ef          	jal	80000c98 <release>
  return xticks;
}
    80002ac0:	02049513          	slli	a0,s1,0x20
    80002ac4:	9101                	srli	a0,a0,0x20
    80002ac6:	60e2                	ld	ra,24(sp)
    80002ac8:	6442                	ld	s0,16(sp)
    80002aca:	64a2                	ld	s1,8(sp)
    80002acc:	6105                	addi	sp,sp,32
    80002ace:	8082                	ret

0000000080002ad0 <buf_lru_pos>:
  return (int)(b - bcache.buf);
}

static int
buf_lru_pos(struct buf *target)
{
    80002ad0:	1141                	addi	sp,sp,-16
    80002ad2:	e422                	sd	s0,8(sp)
    80002ad4:	0800                	addi	s0,sp,16
  int pos = 0;
  struct buf *b;

  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ad6:	0001c797          	auipc	a5,0x1c
    80002ada:	0927b783          	ld	a5,146(a5) # 8001eb68 <bcache+0x82b8>
    80002ade:	0001c697          	auipc	a3,0x1c
    80002ae2:	03a68693          	addi	a3,a3,58 # 8001eb18 <bcache+0x8268>
    80002ae6:	02d78163          	beq	a5,a3,80002b08 <buf_lru_pos+0x38>
    80002aea:	872a                	mv	a4,a0
    if(b == target)
    80002aec:	02a78063          	beq	a5,a0,80002b0c <buf_lru_pos+0x3c>
  int pos = 0;
    80002af0:	4501                	li	a0,0
      return pos;
    pos++;
    80002af2:	2505                	addiw	a0,a0,1
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002af4:	6bbc                	ld	a5,80(a5)
    80002af6:	00d78563          	beq	a5,a3,80002b00 <buf_lru_pos+0x30>
    if(b == target)
    80002afa:	fef71ce3          	bne	a4,a5,80002af2 <buf_lru_pos+0x22>
    80002afe:	a011                	j	80002b02 <buf_lru_pos+0x32>
  }
  return -1;
    80002b00:	557d                	li	a0,-1
}
    80002b02:	6422                	ld	s0,8(sp)
    80002b04:	0141                	addi	sp,sp,16
    80002b06:	8082                	ret
  return -1;
    80002b08:	557d                	li	a0,-1
    80002b0a:	bfe5                	j	80002b02 <buf_lru_pos+0x32>
      return pos;
    80002b0c:	4501                	li	a0,0
    80002b0e:	bfd5                	j	80002b02 <buf_lru_pos+0x32>

0000000080002b10 <binit>:
{
    80002b10:	7179                	addi	sp,sp,-48
    80002b12:	f406                	sd	ra,40(sp)
    80002b14:	f022                	sd	s0,32(sp)
    80002b16:	ec26                	sd	s1,24(sp)
    80002b18:	e84a                	sd	s2,16(sp)
    80002b1a:	e44e                	sd	s3,8(sp)
    80002b1c:	e052                	sd	s4,0(sp)
    80002b1e:	1800                	addi	s0,sp,48
  initlock(&bcache.lock, "bcache");
    80002b20:	00006597          	auipc	a1,0x6
    80002b24:	87858593          	addi	a1,a1,-1928 # 80008398 <etext+0x398>
    80002b28:	00014517          	auipc	a0,0x14
    80002b2c:	d8850513          	addi	a0,a0,-632 # 800168b0 <bcache>
    80002b30:	850fe0ef          	jal	80000b80 <initlock>
  bcache.head.prev = &bcache.head;
    80002b34:	0001c797          	auipc	a5,0x1c
    80002b38:	d7c78793          	addi	a5,a5,-644 # 8001e8b0 <bcache+0x8000>
    80002b3c:	0001c717          	auipc	a4,0x1c
    80002b40:	fdc70713          	addi	a4,a4,-36 # 8001eb18 <bcache+0x8268>
    80002b44:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b48:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b4c:	00014497          	auipc	s1,0x14
    80002b50:	d7c48493          	addi	s1,s1,-644 # 800168c8 <bcache+0x18>
    b->next = bcache.head.next;
    80002b54:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b56:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b58:	00006a17          	auipc	s4,0x6
    80002b5c:	848a0a13          	addi	s4,s4,-1976 # 800083a0 <etext+0x3a0>
    b->next = bcache.head.next;
    80002b60:	2b893783          	ld	a5,696(s2)
    80002b64:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b66:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b6a:	85d2                	mv	a1,s4
    80002b6c:	01048513          	addi	a0,s1,16
    80002b70:	606010ef          	jal	80004176 <initsleeplock>
    bcache.head.next->prev = b;
    80002b74:	2b893783          	ld	a5,696(s2)
    80002b78:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b7a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b7e:	45848493          	addi	s1,s1,1112
    80002b82:	fd349fe3          	bne	s1,s3,80002b60 <binit+0x50>
}
    80002b86:	70a2                	ld	ra,40(sp)
    80002b88:	7402                	ld	s0,32(sp)
    80002b8a:	64e2                	ld	s1,24(sp)
    80002b8c:	6942                	ld	s2,16(sp)
    80002b8e:	69a2                	ld	s3,8(sp)
    80002b90:	6a02                	ld	s4,0(sp)
    80002b92:	6145                	addi	sp,sp,48
    80002b94:	8082                	ret

0000000080002b96 <bread>:
{
    80002b96:	7175                	addi	sp,sp,-144
    80002b98:	e506                	sd	ra,136(sp)
    80002b9a:	e122                	sd	s0,128(sp)
    80002b9c:	fca6                	sd	s1,120(sp)
    80002b9e:	f8ca                	sd	s2,112(sp)
    80002ba0:	f4ce                	sd	s3,104(sp)
    80002ba2:	f0d2                	sd	s4,96(sp)
    80002ba4:	ecd6                	sd	s5,88(sp)
    80002ba6:	e8da                	sd	s6,80(sp)
    80002ba8:	e4de                	sd	s7,72(sp)
    80002baa:	e0e2                	sd	s8,64(sp)
    80002bac:	fc66                	sd	s9,56(sp)
    80002bae:	f86a                	sd	s10,48(sp)
    80002bb0:	f46e                	sd	s11,40(sp)
    80002bb2:	0900                	addi	s0,sp,144
    80002bb4:	8aaa                	mv	s5,a0
    80002bb6:	f8b43423          	sd	a1,-120(s0)
  fslog_bread_req(dev, blockno);
    80002bba:	00050b1b          	sext.w	s6,a0
    80002bbe:	00058b9b          	sext.w	s7,a1
    80002bc2:	85de                	mv	a1,s7
    80002bc4:	855a                	mv	a0,s6
    80002bc6:	5ae030ef          	jal	80006174 <fslog_bread_req>
  acquire(&bcache.lock);
    80002bca:	00014517          	auipc	a0,0x14
    80002bce:	ce650513          	addi	a0,a0,-794 # 800168b0 <bcache>
    80002bd2:	82efe0ef          	jal	80000c00 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002bd6:	0001c497          	auipc	s1,0x1c
    80002bda:	f924b483          	ld	s1,-110(s1) # 8001eb68 <bcache+0x82b8>
    80002bde:	0001c797          	auipc	a5,0x1c
    80002be2:	f3a78793          	addi	a5,a5,-198 # 8001eb18 <bcache+0x8268>
    80002be6:	0cf48263          	beq	s1,a5,80002caa <bread+0x114>
  int step = 0;
    80002bea:	4981                	li	s3,0
  return (int)(b - bcache.buf);
    80002bec:	00014d17          	auipc	s10,0x14
    80002bf0:	cdcd0d13          	addi	s10,s10,-804 # 800168c8 <bcache+0x18>
    80002bf4:	003afa37          	lui	s4,0x3af
    80002bf8:	f6da0a13          	addi	s4,s4,-147 # 3aef6d <_entry-0x7fc51093>
    80002bfc:	0a32                	slli	s4,s4,0xc
    80002bfe:	a97a0a13          	addi	s4,s4,-1385
    80002c02:	0a3e                	slli	s4,s4,0xf
    80002c04:	2c3a0a13          	addi	s4,s4,707
    80002c08:	0a36                	slli	s4,s4,0xd
    80002c0a:	723a0a13          	addi	s4,s4,1827
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c0e:	8dbe                	mv	s11,a5
    80002c10:	a015                	j	80002c34 <bread+0x9e>
    fslog_bget_scan(dev, blockno, buf_id(b),
    80002c12:	e03a                	sd	a4,0(sp)
    80002c14:	88ce                	mv	a7,s3
    80002c16:	4805                	li	a6,1
    80002c18:	8766                	mv	a4,s9
    80002c1a:	86e2                	mv	a3,s8
    80002c1c:	864a                	mv	a2,s2
    80002c1e:	85de                	mv	a1,s7
    80002c20:	855a                	mv	a0,s6
    80002c22:	59e030ef          	jal	800061c0 <fslog_bget_scan>
    if(b->dev == dev && b->blockno == blockno){
    80002c26:	449c                	lw	a5,8(s1)
    80002c28:	03578f63          	beq	a5,s5,80002c66 <bread+0xd0>
    step++;
    80002c2c:	2985                	addiw	s3,s3,1
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c2e:	68a4                	ld	s1,80(s1)
    80002c30:	07b48d63          	beq	s1,s11,80002caa <bread+0x114>
  return (int)(b - bcache.buf);
    80002c34:	41a48933          	sub	s2,s1,s10
    80002c38:	40395913          	srai	s2,s2,0x3
    80002c3c:	0349093b          	mulw	s2,s2,s4
    fslog_bget_scan(dev, blockno, buf_id(b),
    80002c40:	0404ac03          	lw	s8,64(s1)
    80002c44:	0004ac83          	lw	s9,0(s1)
    80002c48:	8526                	mv	a0,s1
    80002c4a:	e87ff0ef          	jal	80002ad0 <buf_lru_pos>
    80002c4e:	87aa                	mv	a5,a0
    80002c50:	4494                	lw	a3,8(s1)
    80002c52:	4701                	li	a4,0
    80002c54:	fb569fe3          	bne	a3,s5,80002c12 <bread+0x7c>
    80002c58:	44d8                	lw	a4,12(s1)
    80002c5a:	f8843683          	ld	a3,-120(s0)
    80002c5e:	8f15                	sub	a4,a4,a3
    80002c60:	00173713          	seqz	a4,a4
    80002c64:	b77d                	j	80002c12 <bread+0x7c>
    if(b->dev == dev && b->blockno == blockno){
    80002c66:	44dc                	lw	a5,12(s1)
    80002c68:	f8843703          	ld	a4,-120(s0)
    80002c6c:	fce790e3          	bne	a5,a4,80002c2c <bread+0x96>
      int old_ref = b->refcnt;
    80002c70:	0404aa03          	lw	s4,64(s1)
      int lru = buf_lru_pos(b);
    80002c74:	8526                	mv	a0,s1
    80002c76:	e5bff0ef          	jal	80002ad0 <buf_lru_pos>
    80002c7a:	89aa                	mv	s3,a0
      b->refcnt++;
    80002c7c:	001a079b          	addiw	a5,s4,1
    80002c80:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c82:	00014517          	auipc	a0,0x14
    80002c86:	c2e50513          	addi	a0,a0,-978 # 800168b0 <bcache>
    80002c8a:	80efe0ef          	jal	80000c98 <release>
      acquiresleep(&b->lock);
    80002c8e:	01048513          	addi	a0,s1,16
    80002c92:	51a010ef          	jal	800041ac <acquiresleep>
      fslog_bget_hit(dev, blockno, buf_id(b),
    80002c96:	884e                	mv	a6,s3
    80002c98:	409c                	lw	a5,0(s1)
    80002c9a:	40b8                	lw	a4,64(s1)
    80002c9c:	86d2                	mv	a3,s4
    80002c9e:	864a                	mv	a2,s2
    80002ca0:	85de                	mv	a1,s7
    80002ca2:	855a                	mv	a0,s6
    80002ca4:	5b6030ef          	jal	8000625a <fslog_bget_hit>
      return b;
    80002ca8:	a0f9                	j	80002d76 <bread+0x1e0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002caa:	0001c497          	auipc	s1,0x1c
    80002cae:	eb64b483          	ld	s1,-330(s1) # 8001eb60 <bcache+0x82b0>
    80002cb2:	0001c797          	auipc	a5,0x1c
    80002cb6:	e6678793          	addi	a5,a5,-410 # 8001eb18 <bcache+0x8268>
    80002cba:	06f48563          	beq	s1,a5,80002d24 <bread+0x18e>
  step = 0;
    80002cbe:	4a01                	li	s4,0
  return (int)(b - bcache.buf);
    80002cc0:	00014d17          	auipc	s10,0x14
    80002cc4:	c08d0d13          	addi	s10,s10,-1016 # 800168c8 <bcache+0x18>
    80002cc8:	003afcb7          	lui	s9,0x3af
    80002ccc:	f6dc8c93          	addi	s9,s9,-147 # 3aef6d <_entry-0x7fc51093>
    80002cd0:	0cb2                	slli	s9,s9,0xc
    80002cd2:	a97c8c93          	addi	s9,s9,-1385
    80002cd6:	0cbe                	slli	s9,s9,0xf
    80002cd8:	2c3c8c93          	addi	s9,s9,707
    80002cdc:	0cb6                	slli	s9,s9,0xd
    80002cde:	723c8c93          	addi	s9,s9,1827
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ce2:	8dbe                	mv	s11,a5
  return (int)(b - bcache.buf);
    80002ce4:	41a48933          	sub	s2,s1,s10
    80002ce8:	40395913          	srai	s2,s2,0x3
    80002cec:	0399093b          	mulw	s2,s2,s9
                    b->refcnt, b->valid, buf_lru_pos(b),
    80002cf0:	0404a983          	lw	s3,64(s1)
    fslog_bget_scan(dev, blockno, buf_id(b),
    80002cf4:	0004ac03          	lw	s8,0(s1)
    80002cf8:	8526                	mv	a0,s1
    80002cfa:	dd7ff0ef          	jal	80002ad0 <buf_lru_pos>
    80002cfe:	87aa                	mv	a5,a0
    80002d00:	0019b713          	seqz	a4,s3
    80002d04:	e03a                	sd	a4,0(sp)
    80002d06:	88d2                	mv	a7,s4
    80002d08:	587d                	li	a6,-1
    80002d0a:	8762                	mv	a4,s8
    80002d0c:	86ce                	mv	a3,s3
    80002d0e:	864a                	mv	a2,s2
    80002d10:	85de                	mv	a1,s7
    80002d12:	855a                	mv	a0,s6
    80002d14:	4ac030ef          	jal	800061c0 <fslog_bget_scan>
    if(b->refcnt == 0) {
    80002d18:	40bc                	lw	a5,64(s1)
    80002d1a:	cb99                	beqz	a5,80002d30 <bread+0x19a>
    step++;
    80002d1c:	2a05                	addiw	s4,s4,1
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d1e:	64a4                	ld	s1,72(s1)
    80002d20:	fdb492e3          	bne	s1,s11,80002ce4 <bread+0x14e>
  panic("bget: no buffers");
    80002d24:	00005517          	auipc	a0,0x5
    80002d28:	68450513          	addi	a0,a0,1668 # 800083a8 <etext+0x3a8>
    80002d2c:	ae7fd0ef          	jal	80000812 <panic>
      int old_block = b->blockno;
    80002d30:	00c4aa03          	lw	s4,12(s1)
      int old_valid = b->valid;
    80002d34:	0004ac03          	lw	s8,0(s1)
      int lru = buf_lru_pos(b);
    80002d38:	8526                	mv	a0,s1
    80002d3a:	d97ff0ef          	jal	80002ad0 <buf_lru_pos>
    80002d3e:	89aa                	mv	s3,a0
      b->dev = dev;
    80002d40:	0154a423          	sw	s5,8(s1)
      b->blockno = blockno;
    80002d44:	f8843783          	ld	a5,-120(s0)
    80002d48:	c4dc                	sw	a5,12(s1)
      b->valid = 0;
    80002d4a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d4e:	4785                	li	a5,1
    80002d50:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d52:	00014517          	auipc	a0,0x14
    80002d56:	b5e50513          	addi	a0,a0,-1186 # 800168b0 <bcache>
    80002d5a:	f3ffd0ef          	jal	80000c98 <release>
      acquiresleep(&b->lock);
    80002d5e:	01048513          	addi	a0,s1,16
    80002d62:	44a010ef          	jal	800041ac <acquiresleep>
      fslog_bget_miss(dev, blockno, old_block, buf_id(b),
    80002d66:	87ce                	mv	a5,s3
    80002d68:	8762                	mv	a4,s8
    80002d6a:	86ca                	mv	a3,s2
    80002d6c:	8652                	mv	a2,s4
    80002d6e:	85de                	mv	a1,s7
    80002d70:	855a                	mv	a0,s6
    80002d72:	57c030ef          	jal	800062ee <fslog_bget_miss>
  if(!b->valid) {
    80002d76:	409c                	lw	a5,0(s1)
    80002d78:	c38d                	beqz	a5,80002d9a <bread+0x204>
}
    80002d7a:	8526                	mv	a0,s1
    80002d7c:	60aa                	ld	ra,136(sp)
    80002d7e:	640a                	ld	s0,128(sp)
    80002d80:	74e6                	ld	s1,120(sp)
    80002d82:	7946                	ld	s2,112(sp)
    80002d84:	79a6                	ld	s3,104(sp)
    80002d86:	7a06                	ld	s4,96(sp)
    80002d88:	6ae6                	ld	s5,88(sp)
    80002d8a:	6b46                	ld	s6,80(sp)
    80002d8c:	6ba6                	ld	s7,72(sp)
    80002d8e:	6c06                	ld	s8,64(sp)
    80002d90:	7ce2                	ld	s9,56(sp)
    80002d92:	7d42                	ld	s10,48(sp)
    80002d94:	7da2                	ld	s11,40(sp)
    80002d96:	6149                	addi	sp,sp,144
    80002d98:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d9a:	4581                	li	a1,0
    80002d9c:	8526                	mv	a0,s1
    80002d9e:	4a3020ef          	jal	80005a40 <virtio_disk_rw>
    b->valid = 1;
    80002da2:	4785                	li	a5,1
    80002da4:	c09c                	sw	a5,0(s1)
    fslog_bread_fill(b->dev, b->blockno, buf_id(b), b->refcnt, buf_lru_pos(b));
    80002da6:	8526                	mv	a0,s1
    80002da8:	d29ff0ef          	jal	80002ad0 <buf_lru_pos>
    80002dac:	872a                	mv	a4,a0
  return (int)(b - bcache.buf);
    80002dae:	00014617          	auipc	a2,0x14
    80002db2:	b1a60613          	addi	a2,a2,-1254 # 800168c8 <bcache+0x18>
    80002db6:	40c48633          	sub	a2,s1,a2
    80002dba:	860d                	srai	a2,a2,0x3
    80002dbc:	003af7b7          	lui	a5,0x3af
    80002dc0:	f6d78793          	addi	a5,a5,-147 # 3aef6d <_entry-0x7fc51093>
    80002dc4:	07b2                	slli	a5,a5,0xc
    80002dc6:	a9778793          	addi	a5,a5,-1385
    80002dca:	07be                	slli	a5,a5,0xf
    80002dcc:	2c378793          	addi	a5,a5,707
    80002dd0:	07b6                	slli	a5,a5,0xd
    80002dd2:	72378793          	addi	a5,a5,1827
    fslog_bread_fill(b->dev, b->blockno, buf_id(b), b->refcnt, buf_lru_pos(b));
    80002dd6:	40b4                	lw	a3,64(s1)
    80002dd8:	02f6063b          	mulw	a2,a2,a5
    80002ddc:	44cc                	lw	a1,12(s1)
    80002dde:	4488                	lw	a0,8(s1)
    80002de0:	5a0030ef          	jal	80006380 <fslog_bread_fill>
  return b;
    80002de4:	bf59                	j	80002d7a <bread+0x1e4>

0000000080002de6 <bwrite>:
{
    80002de6:	1101                	addi	sp,sp,-32
    80002de8:	ec06                	sd	ra,24(sp)
    80002dea:	e822                	sd	s0,16(sp)
    80002dec:	e426                	sd	s1,8(sp)
    80002dee:	e04a                	sd	s2,0(sp)
    80002df0:	1000                	addi	s0,sp,32
    80002df2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002df4:	0541                	addi	a0,a0,16
    80002df6:	434010ef          	jal	8000422a <holdingsleep>
    80002dfa:	cd29                	beqz	a0,80002e54 <bwrite+0x6e>
  virtio_disk_rw(b, 1);
    80002dfc:	4585                	li	a1,1
    80002dfe:	8526                	mv	a0,s1
    80002e00:	441020ef          	jal	80005a40 <virtio_disk_rw>
  fslog_bwrite_ev(b->dev, b->blockno, buf_id(b),
    80002e04:	0004a903          	lw	s2,0(s1)
    80002e08:	8526                	mv	a0,s1
    80002e0a:	cc7ff0ef          	jal	80002ad0 <buf_lru_pos>
    80002e0e:	87aa                	mv	a5,a0
  return (int)(b - bcache.buf);
    80002e10:	00014597          	auipc	a1,0x14
    80002e14:	ab858593          	addi	a1,a1,-1352 # 800168c8 <bcache+0x18>
    80002e18:	40b485b3          	sub	a1,s1,a1
    80002e1c:	858d                	srai	a1,a1,0x3
    80002e1e:	003af637          	lui	a2,0x3af
    80002e22:	f6d60613          	addi	a2,a2,-147 # 3aef6d <_entry-0x7fc51093>
    80002e26:	0632                	slli	a2,a2,0xc
    80002e28:	a9760613          	addi	a2,a2,-1385
    80002e2c:	063e                	slli	a2,a2,0xf
    80002e2e:	2c360613          	addi	a2,a2,707
    80002e32:	0636                	slli	a2,a2,0xd
    80002e34:	72360613          	addi	a2,a2,1827
  fslog_bwrite_ev(b->dev, b->blockno, buf_id(b),
    80002e38:	874a                	mv	a4,s2
    80002e3a:	40b4                	lw	a3,64(s1)
    80002e3c:	02c5863b          	mulw	a2,a1,a2
    80002e40:	44cc                	lw	a1,12(s1)
    80002e42:	4488                	lw	a0,8(s1)
    80002e44:	5c0030ef          	jal	80006404 <fslog_bwrite_ev>
}
    80002e48:	60e2                	ld	ra,24(sp)
    80002e4a:	6442                	ld	s0,16(sp)
    80002e4c:	64a2                	ld	s1,8(sp)
    80002e4e:	6902                	ld	s2,0(sp)
    80002e50:	6105                	addi	sp,sp,32
    80002e52:	8082                	ret
    panic("bwrite");
    80002e54:	00005517          	auipc	a0,0x5
    80002e58:	56c50513          	addi	a0,a0,1388 # 800083c0 <etext+0x3c0>
    80002e5c:	9b7fd0ef          	jal	80000812 <panic>

0000000080002e60 <brelse>:
{
    80002e60:	715d                	addi	sp,sp,-80
    80002e62:	e486                	sd	ra,72(sp)
    80002e64:	e0a2                	sd	s0,64(sp)
    80002e66:	fc26                	sd	s1,56(sp)
    80002e68:	f84a                	sd	s2,48(sp)
    80002e6a:	f44e                	sd	s3,40(sp)
    80002e6c:	f052                	sd	s4,32(sp)
    80002e6e:	ec56                	sd	s5,24(sp)
    80002e70:	e85a                	sd	s6,16(sp)
    80002e72:	e45e                	sd	s7,8(sp)
    80002e74:	e062                	sd	s8,0(sp)
    80002e76:	0880                	addi	s0,sp,80
    80002e78:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e7a:	01050913          	addi	s2,a0,16
    80002e7e:	854a                	mv	a0,s2
    80002e80:	3aa010ef          	jal	8000422a <holdingsleep>
    80002e84:	c961                	beqz	a0,80002f54 <brelse+0xf4>
  old_ref = b->refcnt;
    80002e86:	0404aa83          	lw	s5,64(s1)
  old_lru = buf_lru_pos(b);
    80002e8a:	8526                	mv	a0,s1
    80002e8c:	c45ff0ef          	jal	80002ad0 <buf_lru_pos>
    80002e90:	89aa                	mv	s3,a0
  releasesleep(&b->lock);
    80002e92:	854a                	mv	a0,s2
    80002e94:	35e010ef          	jal	800041f2 <releasesleep>
  acquire(&bcache.lock);
    80002e98:	00014517          	auipc	a0,0x14
    80002e9c:	a1850513          	addi	a0,a0,-1512 # 800168b0 <bcache>
    80002ea0:	d61fd0ef          	jal	80000c00 <acquire>
  b->refcnt--;
    80002ea4:	40bc                	lw	a5,64(s1)
    80002ea6:	37fd                	addiw	a5,a5,-1
    80002ea8:	0007871b          	sext.w	a4,a5
    80002eac:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002eae:	e71d                	bnez	a4,80002edc <brelse+0x7c>
    b->next->prev = b->prev;
    80002eb0:	68b8                	ld	a4,80(s1)
    80002eb2:	64bc                	ld	a5,72(s1)
    80002eb4:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002eb6:	68b8                	ld	a4,80(s1)
    80002eb8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002eba:	0001c797          	auipc	a5,0x1c
    80002ebe:	9f678793          	addi	a5,a5,-1546 # 8001e8b0 <bcache+0x8000>
    80002ec2:	2b87b703          	ld	a4,696(a5)
    80002ec6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ec8:	0001c717          	auipc	a4,0x1c
    80002ecc:	c5070713          	addi	a4,a4,-944 # 8001eb18 <bcache+0x8268>
    80002ed0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ed2:	2b87b703          	ld	a4,696(a5)
    80002ed6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ed8:	2a97bc23          	sd	s1,696(a5)
  new_ref = b->refcnt;
    80002edc:	0404ab83          	lw	s7,64(s1)
  new_lru = buf_lru_pos(b);
    80002ee0:	8526                	mv	a0,s1
    80002ee2:	befff0ef          	jal	80002ad0 <buf_lru_pos>
    80002ee6:	892a                	mv	s2,a0
  dev_now = b->dev;
    80002ee8:	0084aa03          	lw	s4,8(s1)
  blockno_now = b->blockno;
    80002eec:	00c4ab03          	lw	s6,12(s1)
  valid_now = b->valid;
    80002ef0:	0004ac03          	lw	s8,0(s1)
  release(&bcache.lock);
    80002ef4:	00014517          	auipc	a0,0x14
    80002ef8:	9bc50513          	addi	a0,a0,-1604 # 800168b0 <bcache>
    80002efc:	d9dfd0ef          	jal	80000c98 <release>
  return (int)(b - bcache.buf);
    80002f00:	00014797          	auipc	a5,0x14
    80002f04:	9c878793          	addi	a5,a5,-1592 # 800168c8 <bcache+0x18>
    80002f08:	8c9d                	sub	s1,s1,a5
    80002f0a:	848d                	srai	s1,s1,0x3
    80002f0c:	003af637          	lui	a2,0x3af
    80002f10:	f6d60613          	addi	a2,a2,-147 # 3aef6d <_entry-0x7fc51093>
    80002f14:	0632                	slli	a2,a2,0xc
    80002f16:	a9760613          	addi	a2,a2,-1385
    80002f1a:	063e                	slli	a2,a2,0xf
    80002f1c:	2c360613          	addi	a2,a2,707
    80002f20:	0636                	slli	a2,a2,0xd
    80002f22:	72360613          	addi	a2,a2,1827
  fslog_brelease_ev(dev_now, blockno_now, bufid_now,
    80002f26:	88ca                	mv	a7,s2
    80002f28:	884e                	mv	a6,s3
    80002f2a:	87e2                	mv	a5,s8
    80002f2c:	875e                	mv	a4,s7
    80002f2e:	86d6                	mv	a3,s5
    80002f30:	02c4863b          	mulw	a2,s1,a2
    80002f34:	85da                	mv	a1,s6
    80002f36:	8552                	mv	a0,s4
    80002f38:	556030ef          	jal	8000648e <fslog_brelease_ev>
}
    80002f3c:	60a6                	ld	ra,72(sp)
    80002f3e:	6406                	ld	s0,64(sp)
    80002f40:	74e2                	ld	s1,56(sp)
    80002f42:	7942                	ld	s2,48(sp)
    80002f44:	79a2                	ld	s3,40(sp)
    80002f46:	7a02                	ld	s4,32(sp)
    80002f48:	6ae2                	ld	s5,24(sp)
    80002f4a:	6b42                	ld	s6,16(sp)
    80002f4c:	6ba2                	ld	s7,8(sp)
    80002f4e:	6c02                	ld	s8,0(sp)
    80002f50:	6161                	addi	sp,sp,80
    80002f52:	8082                	ret
    panic("brelse");
    80002f54:	00005517          	auipc	a0,0x5
    80002f58:	47450513          	addi	a0,a0,1140 # 800083c8 <etext+0x3c8>
    80002f5c:	8b7fd0ef          	jal	80000812 <panic>

0000000080002f60 <bpin>:
bpin(struct buf *b) {
    80002f60:	1101                	addi	sp,sp,-32
    80002f62:	ec06                	sd	ra,24(sp)
    80002f64:	e822                	sd	s0,16(sp)
    80002f66:	e426                	sd	s1,8(sp)
    80002f68:	1000                	addi	s0,sp,32
    80002f6a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f6c:	00014517          	auipc	a0,0x14
    80002f70:	94450513          	addi	a0,a0,-1724 # 800168b0 <bcache>
    80002f74:	c8dfd0ef          	jal	80000c00 <acquire>
  b->refcnt++;
    80002f78:	40bc                	lw	a5,64(s1)
    80002f7a:	2785                	addiw	a5,a5,1
    80002f7c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f7e:	00014517          	auipc	a0,0x14
    80002f82:	93250513          	addi	a0,a0,-1742 # 800168b0 <bcache>
    80002f86:	d13fd0ef          	jal	80000c98 <release>
}
    80002f8a:	60e2                	ld	ra,24(sp)
    80002f8c:	6442                	ld	s0,16(sp)
    80002f8e:	64a2                	ld	s1,8(sp)
    80002f90:	6105                	addi	sp,sp,32
    80002f92:	8082                	ret

0000000080002f94 <bunpin>:
bunpin(struct buf *b) {
    80002f94:	1101                	addi	sp,sp,-32
    80002f96:	ec06                	sd	ra,24(sp)
    80002f98:	e822                	sd	s0,16(sp)
    80002f9a:	e426                	sd	s1,8(sp)
    80002f9c:	1000                	addi	s0,sp,32
    80002f9e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fa0:	00014517          	auipc	a0,0x14
    80002fa4:	91050513          	addi	a0,a0,-1776 # 800168b0 <bcache>
    80002fa8:	c59fd0ef          	jal	80000c00 <acquire>
  b->refcnt--;
    80002fac:	40bc                	lw	a5,64(s1)
    80002fae:	37fd                	addiw	a5,a5,-1
    80002fb0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fb2:	00014517          	auipc	a0,0x14
    80002fb6:	8fe50513          	addi	a0,a0,-1794 # 800168b0 <bcache>
    80002fba:	cdffd0ef          	jal	80000c98 <release>
}
    80002fbe:	60e2                	ld	ra,24(sp)
    80002fc0:	6442                	ld	s0,16(sp)
    80002fc2:	64a2                	ld	s1,8(sp)
    80002fc4:	6105                	addi	sp,sp,32
    80002fc6:	8082                	ret

0000000080002fc8 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
    80002fc8:	7179                	addi	sp,sp,-48
    80002fca:	f406                	sd	ra,40(sp)
    80002fcc:	f022                	sd	s0,32(sp)
    80002fce:	ec26                	sd	s1,24(sp)
    80002fd0:	e84a                	sd	s2,16(sp)
    80002fd2:	e44e                	sd	s3,8(sp)
    80002fd4:	e052                	sd	s4,0(sp)
    80002fd6:	1800                	addi	s0,sp,48
    80002fd8:	89aa                	mv	s3,a0
    80002fda:	8a2e                	mv	s4,a1
  struct inode *ip, *empty;

  acquire(&itable.lock);
    80002fdc:	0001c517          	auipc	a0,0x1c
    80002fe0:	fb450513          	addi	a0,a0,-76 # 8001ef90 <itable>
    80002fe4:	c1dfd0ef          	jal	80000c00 <acquire>

  // Is the inode already in the table?
  empty = 0;
    80002fe8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002fea:	0001c497          	auipc	s1,0x1c
    80002fee:	fbe48493          	addi	s1,s1,-66 # 8001efa8 <itable+0x18>
    80002ff2:	0001e697          	auipc	a3,0x1e
    80002ff6:	a4668693          	addi	a3,a3,-1466 # 80020a38 <log>
    80002ffa:	a039                	j	80003008 <iget+0x40>
      ip->ref++;
      fslog_iupdate(ip);
      release(&itable.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002ffc:	02090c63          	beqz	s2,80003034 <iget+0x6c>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003000:	08848493          	addi	s1,s1,136
    80003004:	02d48b63          	beq	s1,a3,8000303a <iget+0x72>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003008:	449c                	lw	a5,8(s1)
    8000300a:	fef059e3          	blez	a5,80002ffc <iget+0x34>
    8000300e:	4098                	lw	a4,0(s1)
    80003010:	ff3716e3          	bne	a4,s3,80002ffc <iget+0x34>
    80003014:	40d8                	lw	a4,4(s1)
    80003016:	ff4713e3          	bne	a4,s4,80002ffc <iget+0x34>
      ip->ref++;
    8000301a:	2785                	addiw	a5,a5,1
    8000301c:	c49c                	sw	a5,8(s1)
      fslog_iupdate(ip);
    8000301e:	8526                	mv	a0,s1
    80003020:	04f030ef          	jal	8000686e <fslog_iupdate>
      release(&itable.lock);
    80003024:	0001c517          	auipc	a0,0x1c
    80003028:	f6c50513          	addi	a0,a0,-148 # 8001ef90 <itable>
    8000302c:	c6dfd0ef          	jal	80000c98 <release>
      return ip;
    80003030:	8926                	mv	s2,s1
    80003032:	a02d                	j	8000305c <iget+0x94>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003034:	f7f1                	bnez	a5,80003000 <iget+0x38>
      empty = ip;
    80003036:	8926                	mv	s2,s1
    80003038:	b7e1                	j	80003000 <iget+0x38>
  }

  // Recycle an inode entry.
  if(empty == 0)
    8000303a:	02090a63          	beqz	s2,8000306e <iget+0xa6>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
    8000303e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003042:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003046:	4785                	li	a5,1
    80003048:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000304c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003050:	0001c517          	auipc	a0,0x1c
    80003054:	f4050513          	addi	a0,a0,-192 # 8001ef90 <itable>
    80003058:	c41fd0ef          	jal	80000c98 <release>

  return ip;
}
    8000305c:	854a                	mv	a0,s2
    8000305e:	70a2                	ld	ra,40(sp)
    80003060:	7402                	ld	s0,32(sp)
    80003062:	64e2                	ld	s1,24(sp)
    80003064:	6942                	ld	s2,16(sp)
    80003066:	69a2                	ld	s3,8(sp)
    80003068:	6a02                	ld	s4,0(sp)
    8000306a:	6145                	addi	sp,sp,48
    8000306c:	8082                	ret
    panic("iget: no inodes");
    8000306e:	00005517          	auipc	a0,0x5
    80003072:	36250513          	addi	a0,a0,866 # 800083d0 <etext+0x3d0>
    80003076:	f9cfd0ef          	jal	80000812 <panic>

000000008000307a <bfree>:
{
    8000307a:	1101                	addi	sp,sp,-32
    8000307c:	ec06                	sd	ra,24(sp)
    8000307e:	e822                	sd	s0,16(sp)
    80003080:	e426                	sd	s1,8(sp)
    80003082:	e04a                	sd	s2,0(sp)
    80003084:	1000                	addi	s0,sp,32
    80003086:	84ae                	mv	s1,a1
  bp = bread(dev, BBLOCK(b, sb));
    80003088:	00d5d59b          	srliw	a1,a1,0xd
    8000308c:	0001c797          	auipc	a5,0x1c
    80003090:	f007a783          	lw	a5,-256(a5) # 8001ef8c <sb+0x1c>
    80003094:	9dbd                	addw	a1,a1,a5
    80003096:	b01ff0ef          	jal	80002b96 <bread>
  m = 1 << (bi % 8);
    8000309a:	0074f793          	andi	a5,s1,7
    8000309e:	4705                	li	a4,1
    800030a0:	00f7173b          	sllw	a4,a4,a5
  if((bp->data[bi/8] & m) == 0)
    800030a4:	03349793          	slli	a5,s1,0x33
    800030a8:	93d9                	srli	a5,a5,0x36
    800030aa:	00f506b3          	add	a3,a0,a5
    800030ae:	0586c683          	lbu	a3,88(a3)
    800030b2:	00d77633          	and	a2,a4,a3
    800030b6:	c615                	beqz	a2,800030e2 <bfree+0x68>
    800030b8:	892a                	mv	s2,a0
  bp->data[bi/8] &= ~m;
    800030ba:	97aa                	add	a5,a5,a0
    800030bc:	fff74713          	not	a4,a4
    800030c0:	8ef9                	and	a3,a3,a4
    800030c2:	04d78c23          	sb	a3,88(a5)
  log_write(bp);
    800030c6:	7cd000ef          	jal	80004092 <log_write>
  brelse(bp);
    800030ca:	854a                	mv	a0,s2
    800030cc:	d95ff0ef          	jal	80002e60 <brelse>
  fslog_bfree(b);
    800030d0:	8526                	mv	a0,s1
    800030d2:	666030ef          	jal	80006738 <fslog_bfree>
}
    800030d6:	60e2                	ld	ra,24(sp)
    800030d8:	6442                	ld	s0,16(sp)
    800030da:	64a2                	ld	s1,8(sp)
    800030dc:	6902                	ld	s2,0(sp)
    800030de:	6105                	addi	sp,sp,32
    800030e0:	8082                	ret
    panic("freeing free block");
    800030e2:	00005517          	auipc	a0,0x5
    800030e6:	2fe50513          	addi	a0,a0,766 # 800083e0 <etext+0x3e0>
    800030ea:	f28fd0ef          	jal	80000812 <panic>

00000000800030ee <balloc>:
{
    800030ee:	711d                	addi	sp,sp,-96
    800030f0:	ec86                	sd	ra,88(sp)
    800030f2:	e8a2                	sd	s0,80(sp)
    800030f4:	e4a6                	sd	s1,72(sp)
    800030f6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800030f8:	0001c797          	auipc	a5,0x1c
    800030fc:	e7c7a783          	lw	a5,-388(a5) # 8001ef74 <sb+0x4>
    80003100:	10078263          	beqz	a5,80003204 <balloc+0x116>
    80003104:	e0ca                	sd	s2,64(sp)
    80003106:	fc4e                	sd	s3,56(sp)
    80003108:	f852                	sd	s4,48(sp)
    8000310a:	f456                	sd	s5,40(sp)
    8000310c:	f05a                	sd	s6,32(sp)
    8000310e:	ec5e                	sd	s7,24(sp)
    80003110:	e862                	sd	s8,16(sp)
    80003112:	e466                	sd	s9,8(sp)
    80003114:	8baa                	mv	s7,a0
    80003116:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003118:	0001cb17          	auipc	s6,0x1c
    8000311c:	e58b0b13          	addi	s6,s6,-424 # 8001ef70 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003120:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003122:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003124:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003126:	6c89                	lui	s9,0x2
    80003128:	a88d                	j	8000319a <balloc+0xac>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000312a:	97ca                	add	a5,a5,s2
    8000312c:	8e55                	or	a2,a2,a3
    8000312e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003132:	854a                	mv	a0,s2
    80003134:	75f000ef          	jal	80004092 <log_write>
        brelse(bp);
    80003138:	854a                	mv	a0,s2
    8000313a:	d27ff0ef          	jal	80002e60 <brelse>
  bp = bread(dev, bno);
    8000313e:	85a6                	mv	a1,s1
    80003140:	855e                	mv	a0,s7
    80003142:	a55ff0ef          	jal	80002b96 <bread>
    80003146:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003148:	40000613          	li	a2,1024
    8000314c:	4581                	li	a1,0
    8000314e:	05850513          	addi	a0,a0,88
    80003152:	b83fd0ef          	jal	80000cd4 <memset>
  log_write(bp);
    80003156:	854a                	mv	a0,s2
    80003158:	73b000ef          	jal	80004092 <log_write>
  brelse(bp);
    8000315c:	854a                	mv	a0,s2
    8000315e:	d03ff0ef          	jal	80002e60 <brelse>
        fslog_balloc(b + bi);
    80003162:	8526                	mv	a0,s1
    80003164:	592030ef          	jal	800066f6 <fslog_balloc>
        return b + bi;
    80003168:	6906                	ld	s2,64(sp)
    8000316a:	79e2                	ld	s3,56(sp)
    8000316c:	7a42                	ld	s4,48(sp)
    8000316e:	7aa2                	ld	s5,40(sp)
    80003170:	7b02                	ld	s6,32(sp)
    80003172:	6be2                	ld	s7,24(sp)
    80003174:	6c42                	ld	s8,16(sp)
    80003176:	6ca2                	ld	s9,8(sp)
}
    80003178:	8526                	mv	a0,s1
    8000317a:	60e6                	ld	ra,88(sp)
    8000317c:	6446                	ld	s0,80(sp)
    8000317e:	64a6                	ld	s1,72(sp)
    80003180:	6125                	addi	sp,sp,96
    80003182:	8082                	ret
    brelse(bp);
    80003184:	854a                	mv	a0,s2
    80003186:	cdbff0ef          	jal	80002e60 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000318a:	015c87bb          	addw	a5,s9,s5
    8000318e:	00078a9b          	sext.w	s5,a5
    80003192:	004b2703          	lw	a4,4(s6)
    80003196:	04eaff63          	bgeu	s5,a4,800031f4 <balloc+0x106>
    bp = bread(dev, BBLOCK(b, sb));
    8000319a:	41fad79b          	sraiw	a5,s5,0x1f
    8000319e:	0137d79b          	srliw	a5,a5,0x13
    800031a2:	015787bb          	addw	a5,a5,s5
    800031a6:	40d7d79b          	sraiw	a5,a5,0xd
    800031aa:	01cb2583          	lw	a1,28(s6)
    800031ae:	9dbd                	addw	a1,a1,a5
    800031b0:	855e                	mv	a0,s7
    800031b2:	9e5ff0ef          	jal	80002b96 <bread>
    800031b6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031b8:	004b2503          	lw	a0,4(s6)
    800031bc:	000a849b          	sext.w	s1,s5
    800031c0:	8762                	mv	a4,s8
    800031c2:	fca4f1e3          	bgeu	s1,a0,80003184 <balloc+0x96>
      m = 1 << (bi % 8);
    800031c6:	00777693          	andi	a3,a4,7
    800031ca:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031ce:	41f7579b          	sraiw	a5,a4,0x1f
    800031d2:	01d7d79b          	srliw	a5,a5,0x1d
    800031d6:	9fb9                	addw	a5,a5,a4
    800031d8:	4037d79b          	sraiw	a5,a5,0x3
    800031dc:	00f90633          	add	a2,s2,a5
    800031e0:	05864603          	lbu	a2,88(a2)
    800031e4:	00c6f5b3          	and	a1,a3,a2
    800031e8:	d1a9                	beqz	a1,8000312a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031ea:	2705                	addiw	a4,a4,1
    800031ec:	2485                	addiw	s1,s1,1
    800031ee:	fd471ae3          	bne	a4,s4,800031c2 <balloc+0xd4>
    800031f2:	bf49                	j	80003184 <balloc+0x96>
    800031f4:	6906                	ld	s2,64(sp)
    800031f6:	79e2                	ld	s3,56(sp)
    800031f8:	7a42                	ld	s4,48(sp)
    800031fa:	7aa2                	ld	s5,40(sp)
    800031fc:	7b02                	ld	s6,32(sp)
    800031fe:	6be2                	ld	s7,24(sp)
    80003200:	6c42                	ld	s8,16(sp)
    80003202:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003204:	00005517          	auipc	a0,0x5
    80003208:	1f450513          	addi	a0,a0,500 # 800083f8 <etext+0x3f8>
    8000320c:	b20fd0ef          	jal	8000052c <printf>
  return 0;
    80003210:	4481                	li	s1,0
    80003212:	b79d                	j	80003178 <balloc+0x8a>

0000000080003214 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003214:	7179                	addi	sp,sp,-48
    80003216:	f406                	sd	ra,40(sp)
    80003218:	f022                	sd	s0,32(sp)
    8000321a:	ec26                	sd	s1,24(sp)
    8000321c:	e84a                	sd	s2,16(sp)
    8000321e:	e44e                	sd	s3,8(sp)
    80003220:	1800                	addi	s0,sp,48
    80003222:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003224:	47ad                	li	a5,11
    80003226:	02b7e663          	bltu	a5,a1,80003252 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    8000322a:	02059793          	slli	a5,a1,0x20
    8000322e:	01e7d593          	srli	a1,a5,0x1e
    80003232:	00b504b3          	add	s1,a0,a1
    80003236:	0504a903          	lw	s2,80(s1)
    8000323a:	06091a63          	bnez	s2,800032ae <bmap+0x9a>
      addr = balloc(ip->dev);
    8000323e:	4108                	lw	a0,0(a0)
    80003240:	eafff0ef          	jal	800030ee <balloc>
    80003244:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003248:	06090363          	beqz	s2,800032ae <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    8000324c:	0524a823          	sw	s2,80(s1)
    80003250:	a8b9                	j	800032ae <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003252:	ff45849b          	addiw	s1,a1,-12
    80003256:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000325a:	0ff00793          	li	a5,255
    8000325e:	06e7ee63          	bltu	a5,a4,800032da <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003262:	08052903          	lw	s2,128(a0)
    80003266:	00091d63          	bnez	s2,80003280 <bmap+0x6c>
      addr = balloc(ip->dev);
    8000326a:	4108                	lw	a0,0(a0)
    8000326c:	e83ff0ef          	jal	800030ee <balloc>
    80003270:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003274:	02090d63          	beqz	s2,800032ae <bmap+0x9a>
    80003278:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000327a:	0929a023          	sw	s2,128(s3)
    8000327e:	a011                	j	80003282 <bmap+0x6e>
    80003280:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003282:	85ca                	mv	a1,s2
    80003284:	0009a503          	lw	a0,0(s3)
    80003288:	90fff0ef          	jal	80002b96 <bread>
    8000328c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000328e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003292:	02049713          	slli	a4,s1,0x20
    80003296:	01e75593          	srli	a1,a4,0x1e
    8000329a:	00b784b3          	add	s1,a5,a1
    8000329e:	0004a903          	lw	s2,0(s1)
    800032a2:	00090e63          	beqz	s2,800032be <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800032a6:	8552                	mv	a0,s4
    800032a8:	bb9ff0ef          	jal	80002e60 <brelse>
    return addr;
    800032ac:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800032ae:	854a                	mv	a0,s2
    800032b0:	70a2                	ld	ra,40(sp)
    800032b2:	7402                	ld	s0,32(sp)
    800032b4:	64e2                	ld	s1,24(sp)
    800032b6:	6942                	ld	s2,16(sp)
    800032b8:	69a2                	ld	s3,8(sp)
    800032ba:	6145                	addi	sp,sp,48
    800032bc:	8082                	ret
      addr = balloc(ip->dev);
    800032be:	0009a503          	lw	a0,0(s3)
    800032c2:	e2dff0ef          	jal	800030ee <balloc>
    800032c6:	0005091b          	sext.w	s2,a0
      if(addr){
    800032ca:	fc090ee3          	beqz	s2,800032a6 <bmap+0x92>
        a[bn] = addr;
    800032ce:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800032d2:	8552                	mv	a0,s4
    800032d4:	5bf000ef          	jal	80004092 <log_write>
    800032d8:	b7f9                	j	800032a6 <bmap+0x92>
    800032da:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800032dc:	00005517          	auipc	a0,0x5
    800032e0:	13450513          	addi	a0,a0,308 # 80008410 <etext+0x410>
    800032e4:	d2efd0ef          	jal	80000812 <panic>

00000000800032e8 <iinit>:
{
    800032e8:	7179                	addi	sp,sp,-48
    800032ea:	f406                	sd	ra,40(sp)
    800032ec:	f022                	sd	s0,32(sp)
    800032ee:	ec26                	sd	s1,24(sp)
    800032f0:	e84a                	sd	s2,16(sp)
    800032f2:	e44e                	sd	s3,8(sp)
    800032f4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800032f6:	00005597          	auipc	a1,0x5
    800032fa:	13258593          	addi	a1,a1,306 # 80008428 <etext+0x428>
    800032fe:	0001c517          	auipc	a0,0x1c
    80003302:	c9250513          	addi	a0,a0,-878 # 8001ef90 <itable>
    80003306:	87bfd0ef          	jal	80000b80 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000330a:	0001c497          	auipc	s1,0x1c
    8000330e:	cae48493          	addi	s1,s1,-850 # 8001efb8 <itable+0x28>
    80003312:	0001d997          	auipc	s3,0x1d
    80003316:	73698993          	addi	s3,s3,1846 # 80020a48 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000331a:	00005917          	auipc	s2,0x5
    8000331e:	11690913          	addi	s2,s2,278 # 80008430 <etext+0x430>
    80003322:	85ca                	mv	a1,s2
    80003324:	8526                	mv	a0,s1
    80003326:	651000ef          	jal	80004176 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000332a:	08848493          	addi	s1,s1,136
    8000332e:	ff349ae3          	bne	s1,s3,80003322 <iinit+0x3a>
}
    80003332:	70a2                	ld	ra,40(sp)
    80003334:	7402                	ld	s0,32(sp)
    80003336:	64e2                	ld	s1,24(sp)
    80003338:	6942                	ld	s2,16(sp)
    8000333a:	69a2                	ld	s3,8(sp)
    8000333c:	6145                	addi	sp,sp,48
    8000333e:	8082                	ret

0000000080003340 <ialloc>:
{
    80003340:	715d                	addi	sp,sp,-80
    80003342:	e486                	sd	ra,72(sp)
    80003344:	e0a2                	sd	s0,64(sp)
    80003346:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003348:	0001c717          	auipc	a4,0x1c
    8000334c:	c3472703          	lw	a4,-972(a4) # 8001ef7c <sb+0xc>
    80003350:	4785                	li	a5,1
    80003352:	06e7f463          	bgeu	a5,a4,800033ba <ialloc+0x7a>
    80003356:	fc26                	sd	s1,56(sp)
    80003358:	f84a                	sd	s2,48(sp)
    8000335a:	f44e                	sd	s3,40(sp)
    8000335c:	f052                	sd	s4,32(sp)
    8000335e:	ec56                	sd	s5,24(sp)
    80003360:	e85a                	sd	s6,16(sp)
    80003362:	e45e                	sd	s7,8(sp)
    80003364:	8b2a                	mv	s6,a0
    80003366:	8bae                	mv	s7,a1
    80003368:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000336a:	0001ca97          	auipc	s5,0x1c
    8000336e:	c06a8a93          	addi	s5,s5,-1018 # 8001ef70 <sb>
    80003372:	00090a1b          	sext.w	s4,s2
    80003376:	00495593          	srli	a1,s2,0x4
    8000337a:	018aa783          	lw	a5,24(s5)
    8000337e:	9dbd                	addw	a1,a1,a5
    80003380:	855a                	mv	a0,s6
    80003382:	815ff0ef          	jal	80002b96 <bread>
    80003386:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003388:	05850993          	addi	s3,a0,88
    8000338c:	00fa7793          	andi	a5,s4,15
    80003390:	079a                	slli	a5,a5,0x6
    80003392:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003394:	00099783          	lh	a5,0(s3)
    80003398:	cf85                	beqz	a5,800033d0 <ialloc+0x90>
    brelse(bp);
    8000339a:	ac7ff0ef          	jal	80002e60 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000339e:	0905                	addi	s2,s2,1
    800033a0:	00caa703          	lw	a4,12(s5)
    800033a4:	0009079b          	sext.w	a5,s2
    800033a8:	fce7e5e3          	bltu	a5,a4,80003372 <ialloc+0x32>
    800033ac:	74e2                	ld	s1,56(sp)
    800033ae:	7942                	ld	s2,48(sp)
    800033b0:	79a2                	ld	s3,40(sp)
    800033b2:	7a02                	ld	s4,32(sp)
    800033b4:	6ae2                	ld	s5,24(sp)
    800033b6:	6b42                	ld	s6,16(sp)
    800033b8:	6ba2                	ld	s7,8(sp)
  printf("ialloc: no inodes\n");
    800033ba:	00005517          	auipc	a0,0x5
    800033be:	07e50513          	addi	a0,a0,126 # 80008438 <etext+0x438>
    800033c2:	96afd0ef          	jal	8000052c <printf>
  return 0;
    800033c6:	4501                	li	a0,0
}
    800033c8:	60a6                	ld	ra,72(sp)
    800033ca:	6406                	ld	s0,64(sp)
    800033cc:	6161                	addi	sp,sp,80
    800033ce:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800033d0:	04000613          	li	a2,64
    800033d4:	4581                	li	a1,0
    800033d6:	854e                	mv	a0,s3
    800033d8:	8fdfd0ef          	jal	80000cd4 <memset>
      dip->type = type;
    800033dc:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800033e0:	8526                	mv	a0,s1
    800033e2:	4b1000ef          	jal	80004092 <log_write>
      brelse(bp);
    800033e6:	8526                	mv	a0,s1
    800033e8:	a79ff0ef          	jal	80002e60 <brelse>
      fslog_ialloc(inum, type);
    800033ec:	85de                	mv	a1,s7
    800033ee:	8552                	mv	a0,s4
    800033f0:	38a030ef          	jal	8000677a <fslog_ialloc>
      return iget(dev, inum);
    800033f4:	85d2                	mv	a1,s4
    800033f6:	855a                	mv	a0,s6
    800033f8:	bd1ff0ef          	jal	80002fc8 <iget>
    800033fc:	74e2                	ld	s1,56(sp)
    800033fe:	7942                	ld	s2,48(sp)
    80003400:	79a2                	ld	s3,40(sp)
    80003402:	7a02                	ld	s4,32(sp)
    80003404:	6ae2                	ld	s5,24(sp)
    80003406:	6b42                	ld	s6,16(sp)
    80003408:	6ba2                	ld	s7,8(sp)
    8000340a:	bf7d                	j	800033c8 <ialloc+0x88>

000000008000340c <iupdate>:
{
    8000340c:	1101                	addi	sp,sp,-32
    8000340e:	ec06                	sd	ra,24(sp)
    80003410:	e822                	sd	s0,16(sp)
    80003412:	e426                	sd	s1,8(sp)
    80003414:	e04a                	sd	s2,0(sp)
    80003416:	1000                	addi	s0,sp,32
    80003418:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000341a:	415c                	lw	a5,4(a0)
    8000341c:	0047d79b          	srliw	a5,a5,0x4
    80003420:	0001c597          	auipc	a1,0x1c
    80003424:	b685a583          	lw	a1,-1176(a1) # 8001ef88 <sb+0x18>
    80003428:	9dbd                	addw	a1,a1,a5
    8000342a:	4108                	lw	a0,0(a0)
    8000342c:	f6aff0ef          	jal	80002b96 <bread>
    80003430:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003432:	05850793          	addi	a5,a0,88
    80003436:	40d8                	lw	a4,4(s1)
    80003438:	8b3d                	andi	a4,a4,15
    8000343a:	071a                	slli	a4,a4,0x6
    8000343c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000343e:	04449703          	lh	a4,68(s1)
    80003442:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003446:	04649703          	lh	a4,70(s1)
    8000344a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000344e:	04849703          	lh	a4,72(s1)
    80003452:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003456:	04a49703          	lh	a4,74(s1)
    8000345a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000345e:	44f8                	lw	a4,76(s1)
    80003460:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003462:	03400613          	li	a2,52
    80003466:	05048593          	addi	a1,s1,80
    8000346a:	00c78513          	addi	a0,a5,12
    8000346e:	8c3fd0ef          	jal	80000d30 <memmove>
  log_write(bp);
    80003472:	854a                	mv	a0,s2
    80003474:	41f000ef          	jal	80004092 <log_write>
  brelse(bp);
    80003478:	854a                	mv	a0,s2
    8000347a:	9e7ff0ef          	jal	80002e60 <brelse>
  fslog_iupdate(ip);
    8000347e:	8526                	mv	a0,s1
    80003480:	3ee030ef          	jal	8000686e <fslog_iupdate>
}
    80003484:	60e2                	ld	ra,24(sp)
    80003486:	6442                	ld	s0,16(sp)
    80003488:	64a2                	ld	s1,8(sp)
    8000348a:	6902                	ld	s2,0(sp)
    8000348c:	6105                	addi	sp,sp,32
    8000348e:	8082                	ret

0000000080003490 <idup>:
{
    80003490:	1101                	addi	sp,sp,-32
    80003492:	ec06                	sd	ra,24(sp)
    80003494:	e822                	sd	s0,16(sp)
    80003496:	e426                	sd	s1,8(sp)
    80003498:	1000                	addi	s0,sp,32
    8000349a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000349c:	0001c517          	auipc	a0,0x1c
    800034a0:	af450513          	addi	a0,a0,-1292 # 8001ef90 <itable>
    800034a4:	f5cfd0ef          	jal	80000c00 <acquire>
  ip->ref++;
    800034a8:	449c                	lw	a5,8(s1)
    800034aa:	2785                	addiw	a5,a5,1
    800034ac:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034ae:	0001c517          	auipc	a0,0x1c
    800034b2:	ae250513          	addi	a0,a0,-1310 # 8001ef90 <itable>
    800034b6:	fe2fd0ef          	jal	80000c98 <release>
}
    800034ba:	8526                	mv	a0,s1
    800034bc:	60e2                	ld	ra,24(sp)
    800034be:	6442                	ld	s0,16(sp)
    800034c0:	64a2                	ld	s1,8(sp)
    800034c2:	6105                	addi	sp,sp,32
    800034c4:	8082                	ret

00000000800034c6 <ilock>:
{
    800034c6:	1101                	addi	sp,sp,-32
    800034c8:	ec06                	sd	ra,24(sp)
    800034ca:	e822                	sd	s0,16(sp)
    800034cc:	e426                	sd	s1,8(sp)
    800034ce:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800034d0:	c11d                	beqz	a0,800034f6 <ilock+0x30>
    800034d2:	84aa                	mv	s1,a0
    800034d4:	451c                	lw	a5,8(a0)
    800034d6:	02f05063          	blez	a5,800034f6 <ilock+0x30>
  acquiresleep(&ip->lock);
    800034da:	0541                	addi	a0,a0,16
    800034dc:	4d1000ef          	jal	800041ac <acquiresleep>
  fslog_ilock(ip->inum, 1);
    800034e0:	4585                	li	a1,1
    800034e2:	40c8                	lw	a0,4(s1)
    800034e4:	33c030ef          	jal	80006820 <fslog_ilock>
  if(ip->valid == 0){
    800034e8:	40bc                	lw	a5,64(s1)
    800034ea:	cf89                	beqz	a5,80003504 <ilock+0x3e>
}
    800034ec:	60e2                	ld	ra,24(sp)
    800034ee:	6442                	ld	s0,16(sp)
    800034f0:	64a2                	ld	s1,8(sp)
    800034f2:	6105                	addi	sp,sp,32
    800034f4:	8082                	ret
    800034f6:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800034f8:	00005517          	auipc	a0,0x5
    800034fc:	f5850513          	addi	a0,a0,-168 # 80008450 <etext+0x450>
    80003500:	b12fd0ef          	jal	80000812 <panic>
    80003504:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003506:	40dc                	lw	a5,4(s1)
    80003508:	0047d79b          	srliw	a5,a5,0x4
    8000350c:	0001c597          	auipc	a1,0x1c
    80003510:	a7c5a583          	lw	a1,-1412(a1) # 8001ef88 <sb+0x18>
    80003514:	9dbd                	addw	a1,a1,a5
    80003516:	4088                	lw	a0,0(s1)
    80003518:	e7eff0ef          	jal	80002b96 <bread>
    8000351c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000351e:	05850593          	addi	a1,a0,88
    80003522:	40dc                	lw	a5,4(s1)
    80003524:	8bbd                	andi	a5,a5,15
    80003526:	079a                	slli	a5,a5,0x6
    80003528:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000352a:	00059783          	lh	a5,0(a1)
    8000352e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003532:	00259783          	lh	a5,2(a1)
    80003536:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000353a:	00459783          	lh	a5,4(a1)
    8000353e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003542:	00659783          	lh	a5,6(a1)
    80003546:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000354a:	459c                	lw	a5,8(a1)
    8000354c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000354e:	03400613          	li	a2,52
    80003552:	05b1                	addi	a1,a1,12
    80003554:	05048513          	addi	a0,s1,80
    80003558:	fd8fd0ef          	jal	80000d30 <memmove>
    brelse(bp);
    8000355c:	854a                	mv	a0,s2
    8000355e:	903ff0ef          	jal	80002e60 <brelse>
    ip->valid = 1;
    80003562:	4785                	li	a5,1
    80003564:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003566:	04449783          	lh	a5,68(s1)
    8000356a:	c399                	beqz	a5,80003570 <ilock+0xaa>
    8000356c:	6902                	ld	s2,0(sp)
    8000356e:	bfbd                	j	800034ec <ilock+0x26>
      panic("ilock: no type");
    80003570:	00005517          	auipc	a0,0x5
    80003574:	ee850513          	addi	a0,a0,-280 # 80008458 <etext+0x458>
    80003578:	a9afd0ef          	jal	80000812 <panic>

000000008000357c <iunlock>:
{
    8000357c:	1101                	addi	sp,sp,-32
    8000357e:	ec06                	sd	ra,24(sp)
    80003580:	e822                	sd	s0,16(sp)
    80003582:	e426                	sd	s1,8(sp)
    80003584:	e04a                	sd	s2,0(sp)
    80003586:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003588:	c905                	beqz	a0,800035b8 <iunlock+0x3c>
    8000358a:	84aa                	mv	s1,a0
    8000358c:	01050913          	addi	s2,a0,16
    80003590:	854a                	mv	a0,s2
    80003592:	499000ef          	jal	8000422a <holdingsleep>
    80003596:	c10d                	beqz	a0,800035b8 <iunlock+0x3c>
    80003598:	449c                	lw	a5,8(s1)
    8000359a:	00f05f63          	blez	a5,800035b8 <iunlock+0x3c>
  fslog_ilock(ip->inum, 0);
    8000359e:	4581                	li	a1,0
    800035a0:	40c8                	lw	a0,4(s1)
    800035a2:	27e030ef          	jal	80006820 <fslog_ilock>
  releasesleep(&ip->lock);
    800035a6:	854a                	mv	a0,s2
    800035a8:	44b000ef          	jal	800041f2 <releasesleep>
}
    800035ac:	60e2                	ld	ra,24(sp)
    800035ae:	6442                	ld	s0,16(sp)
    800035b0:	64a2                	ld	s1,8(sp)
    800035b2:	6902                	ld	s2,0(sp)
    800035b4:	6105                	addi	sp,sp,32
    800035b6:	8082                	ret
    panic("iunlock");
    800035b8:	00005517          	auipc	a0,0x5
    800035bc:	eb050513          	addi	a0,a0,-336 # 80008468 <etext+0x468>
    800035c0:	a52fd0ef          	jal	80000812 <panic>

00000000800035c4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800035c4:	7179                	addi	sp,sp,-48
    800035c6:	f406                	sd	ra,40(sp)
    800035c8:	f022                	sd	s0,32(sp)
    800035ca:	ec26                	sd	s1,24(sp)
    800035cc:	e84a                	sd	s2,16(sp)
    800035ce:	e44e                	sd	s3,8(sp)
    800035d0:	1800                	addi	s0,sp,48
    800035d2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800035d4:	05050493          	addi	s1,a0,80
    800035d8:	08050913          	addi	s2,a0,128
    800035dc:	a021                	j	800035e4 <itrunc+0x20>
    800035de:	0491                	addi	s1,s1,4
    800035e0:	01248b63          	beq	s1,s2,800035f6 <itrunc+0x32>
    if(ip->addrs[i]){
    800035e4:	408c                	lw	a1,0(s1)
    800035e6:	dde5                	beqz	a1,800035de <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800035e8:	0009a503          	lw	a0,0(s3)
    800035ec:	a8fff0ef          	jal	8000307a <bfree>
      ip->addrs[i] = 0;
    800035f0:	0004a023          	sw	zero,0(s1)
    800035f4:	b7ed                	j	800035de <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800035f6:	0809a583          	lw	a1,128(s3)
    800035fa:	ed89                	bnez	a1,80003614 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800035fc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003600:	854e                	mv	a0,s3
    80003602:	e0bff0ef          	jal	8000340c <iupdate>
}
    80003606:	70a2                	ld	ra,40(sp)
    80003608:	7402                	ld	s0,32(sp)
    8000360a:	64e2                	ld	s1,24(sp)
    8000360c:	6942                	ld	s2,16(sp)
    8000360e:	69a2                	ld	s3,8(sp)
    80003610:	6145                	addi	sp,sp,48
    80003612:	8082                	ret
    80003614:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003616:	0009a503          	lw	a0,0(s3)
    8000361a:	d7cff0ef          	jal	80002b96 <bread>
    8000361e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003620:	05850493          	addi	s1,a0,88
    80003624:	45850913          	addi	s2,a0,1112
    80003628:	a021                	j	80003630 <itrunc+0x6c>
    8000362a:	0491                	addi	s1,s1,4
    8000362c:	01248963          	beq	s1,s2,8000363e <itrunc+0x7a>
      if(a[j])
    80003630:	408c                	lw	a1,0(s1)
    80003632:	dde5                	beqz	a1,8000362a <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003634:	0009a503          	lw	a0,0(s3)
    80003638:	a43ff0ef          	jal	8000307a <bfree>
    8000363c:	b7fd                	j	8000362a <itrunc+0x66>
    brelse(bp);
    8000363e:	8552                	mv	a0,s4
    80003640:	821ff0ef          	jal	80002e60 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003644:	0809a583          	lw	a1,128(s3)
    80003648:	0009a503          	lw	a0,0(s3)
    8000364c:	a2fff0ef          	jal	8000307a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003650:	0809a023          	sw	zero,128(s3)
    80003654:	6a02                	ld	s4,0(sp)
    80003656:	b75d                	j	800035fc <itrunc+0x38>

0000000080003658 <iput>:
{
    80003658:	1101                	addi	sp,sp,-32
    8000365a:	ec06                	sd	ra,24(sp)
    8000365c:	e822                	sd	s0,16(sp)
    8000365e:	e426                	sd	s1,8(sp)
    80003660:	1000                	addi	s0,sp,32
    80003662:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003664:	0001c517          	auipc	a0,0x1c
    80003668:	92c50513          	addi	a0,a0,-1748 # 8001ef90 <itable>
    8000366c:	d94fd0ef          	jal	80000c00 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003670:	4498                	lw	a4,8(s1)
    80003672:	4785                	li	a5,1
    80003674:	02f70363          	beq	a4,a5,8000369a <iput+0x42>
  ip->ref--;
    80003678:	449c                	lw	a5,8(s1)
    8000367a:	37fd                	addiw	a5,a5,-1
    8000367c:	c49c                	sw	a5,8(s1)
  fslog_iupdate(ip);
    8000367e:	8526                	mv	a0,s1
    80003680:	1ee030ef          	jal	8000686e <fslog_iupdate>
  release(&itable.lock);
    80003684:	0001c517          	auipc	a0,0x1c
    80003688:	90c50513          	addi	a0,a0,-1780 # 8001ef90 <itable>
    8000368c:	e0cfd0ef          	jal	80000c98 <release>
}
    80003690:	60e2                	ld	ra,24(sp)
    80003692:	6442                	ld	s0,16(sp)
    80003694:	64a2                	ld	s1,8(sp)
    80003696:	6105                	addi	sp,sp,32
    80003698:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000369a:	40bc                	lw	a5,64(s1)
    8000369c:	dff1                	beqz	a5,80003678 <iput+0x20>
    8000369e:	04a49783          	lh	a5,74(s1)
    800036a2:	fbf9                	bnez	a5,80003678 <iput+0x20>
    800036a4:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800036a6:	01048913          	addi	s2,s1,16
    800036aa:	854a                	mv	a0,s2
    800036ac:	301000ef          	jal	800041ac <acquiresleep>
    release(&itable.lock);
    800036b0:	0001c517          	auipc	a0,0x1c
    800036b4:	8e050513          	addi	a0,a0,-1824 # 8001ef90 <itable>
    800036b8:	de0fd0ef          	jal	80000c98 <release>
    itrunc(ip);
    800036bc:	8526                	mv	a0,s1
    800036be:	f07ff0ef          	jal	800035c4 <itrunc>
    ip->type = 0;
    800036c2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800036c6:	8526                	mv	a0,s1
    800036c8:	d45ff0ef          	jal	8000340c <iupdate>
    ip->valid = 0;
    800036cc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800036d0:	854a                	mv	a0,s2
    800036d2:	321000ef          	jal	800041f2 <releasesleep>
    acquire(&itable.lock);
    800036d6:	0001c517          	auipc	a0,0x1c
    800036da:	8ba50513          	addi	a0,a0,-1862 # 8001ef90 <itable>
    800036de:	d22fd0ef          	jal	80000c00 <acquire>
    800036e2:	6902                	ld	s2,0(sp)
    800036e4:	bf51                	j	80003678 <iput+0x20>

00000000800036e6 <iunlockput>:
{
    800036e6:	1101                	addi	sp,sp,-32
    800036e8:	ec06                	sd	ra,24(sp)
    800036ea:	e822                	sd	s0,16(sp)
    800036ec:	e426                	sd	s1,8(sp)
    800036ee:	1000                	addi	s0,sp,32
    800036f0:	84aa                	mv	s1,a0
  iunlock(ip);
    800036f2:	e8bff0ef          	jal	8000357c <iunlock>
  iput(ip);
    800036f6:	8526                	mv	a0,s1
    800036f8:	f61ff0ef          	jal	80003658 <iput>
}
    800036fc:	60e2                	ld	ra,24(sp)
    800036fe:	6442                	ld	s0,16(sp)
    80003700:	64a2                	ld	s1,8(sp)
    80003702:	6105                	addi	sp,sp,32
    80003704:	8082                	ret

0000000080003706 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003706:	0001c717          	auipc	a4,0x1c
    8000370a:	87672703          	lw	a4,-1930(a4) # 8001ef7c <sb+0xc>
    8000370e:	4785                	li	a5,1
    80003710:	0ae7ff63          	bgeu	a5,a4,800037ce <ireclaim+0xc8>
{
    80003714:	7139                	addi	sp,sp,-64
    80003716:	fc06                	sd	ra,56(sp)
    80003718:	f822                	sd	s0,48(sp)
    8000371a:	f426                	sd	s1,40(sp)
    8000371c:	f04a                	sd	s2,32(sp)
    8000371e:	ec4e                	sd	s3,24(sp)
    80003720:	e852                	sd	s4,16(sp)
    80003722:	e456                	sd	s5,8(sp)
    80003724:	e05a                	sd	s6,0(sp)
    80003726:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003728:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000372a:	00050a1b          	sext.w	s4,a0
    8000372e:	0001ca97          	auipc	s5,0x1c
    80003732:	842a8a93          	addi	s5,s5,-1982 # 8001ef70 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003736:	00005b17          	auipc	s6,0x5
    8000373a:	d3ab0b13          	addi	s6,s6,-710 # 80008470 <etext+0x470>
    8000373e:	a099                	j	80003784 <ireclaim+0x7e>
    80003740:	85ce                	mv	a1,s3
    80003742:	855a                	mv	a0,s6
    80003744:	de9fc0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    80003748:	85ce                	mv	a1,s3
    8000374a:	8552                	mv	a0,s4
    8000374c:	87dff0ef          	jal	80002fc8 <iget>
    80003750:	89aa                	mv	s3,a0
    brelse(bp);
    80003752:	854a                	mv	a0,s2
    80003754:	f0cff0ef          	jal	80002e60 <brelse>
    if (ip) {
    80003758:	00098f63          	beqz	s3,80003776 <ireclaim+0x70>
      begin_op();
    8000375c:	77a000ef          	jal	80003ed6 <begin_op>
      ilock(ip);
    80003760:	854e                	mv	a0,s3
    80003762:	d65ff0ef          	jal	800034c6 <ilock>
      iunlock(ip);
    80003766:	854e                	mv	a0,s3
    80003768:	e15ff0ef          	jal	8000357c <iunlock>
      iput(ip);
    8000376c:	854e                	mv	a0,s3
    8000376e:	eebff0ef          	jal	80003658 <iput>
      end_op();
    80003772:	7da000ef          	jal	80003f4c <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003776:	0485                	addi	s1,s1,1
    80003778:	00caa703          	lw	a4,12(s5)
    8000377c:	0004879b          	sext.w	a5,s1
    80003780:	02e7fd63          	bgeu	a5,a4,800037ba <ireclaim+0xb4>
    80003784:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003788:	0044d593          	srli	a1,s1,0x4
    8000378c:	018aa783          	lw	a5,24(s5)
    80003790:	9dbd                	addw	a1,a1,a5
    80003792:	8552                	mv	a0,s4
    80003794:	c02ff0ef          	jal	80002b96 <bread>
    80003798:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000379a:	05850793          	addi	a5,a0,88
    8000379e:	00f9f713          	andi	a4,s3,15
    800037a2:	071a                	slli	a4,a4,0x6
    800037a4:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800037a6:	00079703          	lh	a4,0(a5)
    800037aa:	c701                	beqz	a4,800037b2 <ireclaim+0xac>
    800037ac:	00679783          	lh	a5,6(a5)
    800037b0:	dbc1                	beqz	a5,80003740 <ireclaim+0x3a>
    brelse(bp);
    800037b2:	854a                	mv	a0,s2
    800037b4:	eacff0ef          	jal	80002e60 <brelse>
    if (ip) {
    800037b8:	bf7d                	j	80003776 <ireclaim+0x70>
}
    800037ba:	70e2                	ld	ra,56(sp)
    800037bc:	7442                	ld	s0,48(sp)
    800037be:	74a2                	ld	s1,40(sp)
    800037c0:	7902                	ld	s2,32(sp)
    800037c2:	69e2                	ld	s3,24(sp)
    800037c4:	6a42                	ld	s4,16(sp)
    800037c6:	6aa2                	ld	s5,8(sp)
    800037c8:	6b02                	ld	s6,0(sp)
    800037ca:	6121                	addi	sp,sp,64
    800037cc:	8082                	ret
    800037ce:	8082                	ret

00000000800037d0 <fsinit>:
fsinit(int dev) {
    800037d0:	7179                	addi	sp,sp,-48
    800037d2:	f406                	sd	ra,40(sp)
    800037d4:	f022                	sd	s0,32(sp)
    800037d6:	ec26                	sd	s1,24(sp)
    800037d8:	e84a                	sd	s2,16(sp)
    800037da:	e44e                	sd	s3,8(sp)
    800037dc:	1800                	addi	s0,sp,48
    800037de:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800037e0:	4585                	li	a1,1
    800037e2:	bb4ff0ef          	jal	80002b96 <bread>
    800037e6:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800037e8:	0001b997          	auipc	s3,0x1b
    800037ec:	78898993          	addi	s3,s3,1928 # 8001ef70 <sb>
    800037f0:	02000613          	li	a2,32
    800037f4:	05850593          	addi	a1,a0,88
    800037f8:	854e                	mv	a0,s3
    800037fa:	d36fd0ef          	jal	80000d30 <memmove>
  brelse(bp);
    800037fe:	854a                	mv	a0,s2
    80003800:	e60ff0ef          	jal	80002e60 <brelse>
  if(sb.magic != FSMAGIC)
    80003804:	0009a703          	lw	a4,0(s3)
    80003808:	102037b7          	lui	a5,0x10203
    8000380c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003810:	02f71363          	bne	a4,a5,80003836 <fsinit+0x66>
  initlog(dev, &sb);
    80003814:	0001b597          	auipc	a1,0x1b
    80003818:	75c58593          	addi	a1,a1,1884 # 8001ef70 <sb>
    8000381c:	8526                	mv	a0,s1
    8000381e:	63a000ef          	jal	80003e58 <initlog>
  ireclaim(dev);
    80003822:	8526                	mv	a0,s1
    80003824:	ee3ff0ef          	jal	80003706 <ireclaim>
}
    80003828:	70a2                	ld	ra,40(sp)
    8000382a:	7402                	ld	s0,32(sp)
    8000382c:	64e2                	ld	s1,24(sp)
    8000382e:	6942                	ld	s2,16(sp)
    80003830:	69a2                	ld	s3,8(sp)
    80003832:	6145                	addi	sp,sp,48
    80003834:	8082                	ret
    panic("invalid file system");
    80003836:	00005517          	auipc	a0,0x5
    8000383a:	c5a50513          	addi	a0,a0,-934 # 80008490 <etext+0x490>
    8000383e:	fd5fc0ef          	jal	80000812 <panic>

0000000080003842 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003842:	1141                	addi	sp,sp,-16
    80003844:	e422                	sd	s0,8(sp)
    80003846:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003848:	411c                	lw	a5,0(a0)
    8000384a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000384c:	415c                	lw	a5,4(a0)
    8000384e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003850:	04451783          	lh	a5,68(a0)
    80003854:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003858:	04a51783          	lh	a5,74(a0)
    8000385c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003860:	04c56783          	lwu	a5,76(a0)
    80003864:	e99c                	sd	a5,16(a1)
}
    80003866:	6422                	ld	s0,8(sp)
    80003868:	0141                	addi	sp,sp,16
    8000386a:	8082                	ret

000000008000386c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000386c:	457c                	lw	a5,76(a0)
    8000386e:	0ed7eb63          	bltu	a5,a3,80003964 <readi+0xf8>
{
    80003872:	7159                	addi	sp,sp,-112
    80003874:	f486                	sd	ra,104(sp)
    80003876:	f0a2                	sd	s0,96(sp)
    80003878:	eca6                	sd	s1,88(sp)
    8000387a:	e0d2                	sd	s4,64(sp)
    8000387c:	fc56                	sd	s5,56(sp)
    8000387e:	f85a                	sd	s6,48(sp)
    80003880:	f45e                	sd	s7,40(sp)
    80003882:	1880                	addi	s0,sp,112
    80003884:	8b2a                	mv	s6,a0
    80003886:	8bae                	mv	s7,a1
    80003888:	8a32                	mv	s4,a2
    8000388a:	84b6                	mv	s1,a3
    8000388c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000388e:	9f35                	addw	a4,a4,a3
    return 0;
    80003890:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003892:	0cd76063          	bltu	a4,a3,80003952 <readi+0xe6>
    80003896:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003898:	00e7f463          	bgeu	a5,a4,800038a0 <readi+0x34>
    n = ip->size - off;
    8000389c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038a0:	080a8f63          	beqz	s5,8000393e <readi+0xd2>
    800038a4:	e8ca                	sd	s2,80(sp)
    800038a6:	f062                	sd	s8,32(sp)
    800038a8:	ec66                	sd	s9,24(sp)
    800038aa:	e86a                	sd	s10,16(sp)
    800038ac:	e46e                	sd	s11,8(sp)
    800038ae:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800038b0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800038b4:	5c7d                	li	s8,-1
    800038b6:	a80d                	j	800038e8 <readi+0x7c>
    800038b8:	020d1d93          	slli	s11,s10,0x20
    800038bc:	020ddd93          	srli	s11,s11,0x20
    800038c0:	05890613          	addi	a2,s2,88
    800038c4:	86ee                	mv	a3,s11
    800038c6:	963a                	add	a2,a2,a4
    800038c8:	85d2                	mv	a1,s4
    800038ca:	855e                	mv	a0,s7
    800038cc:	9a9fe0ef          	jal	80002274 <either_copyout>
    800038d0:	05850763          	beq	a0,s8,8000391e <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800038d4:	854a                	mv	a0,s2
    800038d6:	d8aff0ef          	jal	80002e60 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038da:	013d09bb          	addw	s3,s10,s3
    800038de:	009d04bb          	addw	s1,s10,s1
    800038e2:	9a6e                	add	s4,s4,s11
    800038e4:	0559f763          	bgeu	s3,s5,80003932 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800038e8:	00a4d59b          	srliw	a1,s1,0xa
    800038ec:	855a                	mv	a0,s6
    800038ee:	927ff0ef          	jal	80003214 <bmap>
    800038f2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800038f6:	c5b1                	beqz	a1,80003942 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800038f8:	000b2503          	lw	a0,0(s6)
    800038fc:	a9aff0ef          	jal	80002b96 <bread>
    80003900:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003902:	3ff4f713          	andi	a4,s1,1023
    80003906:	40ec87bb          	subw	a5,s9,a4
    8000390a:	413a86bb          	subw	a3,s5,s3
    8000390e:	8d3e                	mv	s10,a5
    80003910:	2781                	sext.w	a5,a5
    80003912:	0006861b          	sext.w	a2,a3
    80003916:	faf671e3          	bgeu	a2,a5,800038b8 <readi+0x4c>
    8000391a:	8d36                	mv	s10,a3
    8000391c:	bf71                	j	800038b8 <readi+0x4c>
      brelse(bp);
    8000391e:	854a                	mv	a0,s2
    80003920:	d40ff0ef          	jal	80002e60 <brelse>
      tot = -1;
    80003924:	59fd                	li	s3,-1
      break;
    80003926:	6946                	ld	s2,80(sp)
    80003928:	7c02                	ld	s8,32(sp)
    8000392a:	6ce2                	ld	s9,24(sp)
    8000392c:	6d42                	ld	s10,16(sp)
    8000392e:	6da2                	ld	s11,8(sp)
    80003930:	a831                	j	8000394c <readi+0xe0>
    80003932:	6946                	ld	s2,80(sp)
    80003934:	7c02                	ld	s8,32(sp)
    80003936:	6ce2                	ld	s9,24(sp)
    80003938:	6d42                	ld	s10,16(sp)
    8000393a:	6da2                	ld	s11,8(sp)
    8000393c:	a801                	j	8000394c <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000393e:	89d6                	mv	s3,s5
    80003940:	a031                	j	8000394c <readi+0xe0>
    80003942:	6946                	ld	s2,80(sp)
    80003944:	7c02                	ld	s8,32(sp)
    80003946:	6ce2                	ld	s9,24(sp)
    80003948:	6d42                	ld	s10,16(sp)
    8000394a:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000394c:	0009851b          	sext.w	a0,s3
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
    8000396a:	10d7e063          	bltu	a5,a3,80003a6a <writei+0x102>
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
    8000398e:	0ed7e063          	bltu	a5,a3,80003a6e <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003992:	00043737          	lui	a4,0x43
    80003996:	0cf76e63          	bltu	a4,a5,80003a72 <writei+0x10a>
    8000399a:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000399c:	0a0b0f63          	beqz	s6,80003a5a <writei+0xf2>
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
    800039c6:	953a                	add	a0,a0,a4
    800039c8:	8f7fe0ef          	jal	800022be <either_copyin>
    800039cc:	05850a63          	beq	a0,s8,80003a20 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800039d0:	8526                	mv	a0,s1
    800039d2:	6c0000ef          	jal	80004092 <log_write>
    brelse(bp);
    800039d6:	8526                	mv	a0,s1
    800039d8:	c88ff0ef          	jal	80002e60 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039dc:	013d09bb          	addw	s3,s10,s3
    800039e0:	012d093b          	addw	s2,s10,s2
    800039e4:	9a6e                	add	s4,s4,s11
    800039e6:	0569f063          	bgeu	s3,s6,80003a26 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800039ea:	00a9559b          	srliw	a1,s2,0xa
    800039ee:	8556                	mv	a0,s5
    800039f0:	825ff0ef          	jal	80003214 <bmap>
    800039f4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800039f8:	c59d                	beqz	a1,80003a26 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800039fa:	000aa503          	lw	a0,0(s5)
    800039fe:	998ff0ef          	jal	80002b96 <bread>
    80003a02:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a04:	3ff97713          	andi	a4,s2,1023
    80003a08:	40ec87bb          	subw	a5,s9,a4
    80003a0c:	413b06bb          	subw	a3,s6,s3
    80003a10:	8d3e                	mv	s10,a5
    80003a12:	2781                	sext.w	a5,a5
    80003a14:	0006861b          	sext.w	a2,a3
    80003a18:	f8f67ee3          	bgeu	a2,a5,800039b4 <writei+0x4c>
    80003a1c:	8d36                	mv	s10,a3
    80003a1e:	bf59                	j	800039b4 <writei+0x4c>
      brelse(bp);
    80003a20:	8526                	mv	a0,s1
    80003a22:	c3eff0ef          	jal	80002e60 <brelse>
  }

  if(off > ip->size)
    80003a26:	04caa783          	lw	a5,76(s5)
    80003a2a:	0327fa63          	bgeu	a5,s2,80003a5e <writei+0xf6>
    ip->size = off;
    80003a2e:	052aa623          	sw	s2,76(s5)
    80003a32:	64e6                	ld	s1,88(sp)
    80003a34:	7c02                	ld	s8,32(sp)
    80003a36:	6ce2                	ld	s9,24(sp)
    80003a38:	6d42                	ld	s10,16(sp)
    80003a3a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003a3c:	8556                	mv	a0,s5
    80003a3e:	9cfff0ef          	jal	8000340c <iupdate>

  return tot;
    80003a42:	0009851b          	sext.w	a0,s3
    80003a46:	69a6                	ld	s3,72(sp)
}
    80003a48:	70a6                	ld	ra,104(sp)
    80003a4a:	7406                	ld	s0,96(sp)
    80003a4c:	6946                	ld	s2,80(sp)
    80003a4e:	6a06                	ld	s4,64(sp)
    80003a50:	7ae2                	ld	s5,56(sp)
    80003a52:	7b42                	ld	s6,48(sp)
    80003a54:	7ba2                	ld	s7,40(sp)
    80003a56:	6165                	addi	sp,sp,112
    80003a58:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a5a:	89da                	mv	s3,s6
    80003a5c:	b7c5                	j	80003a3c <writei+0xd4>
    80003a5e:	64e6                	ld	s1,88(sp)
    80003a60:	7c02                	ld	s8,32(sp)
    80003a62:	6ce2                	ld	s9,24(sp)
    80003a64:	6d42                	ld	s10,16(sp)
    80003a66:	6da2                	ld	s11,8(sp)
    80003a68:	bfd1                	j	80003a3c <writei+0xd4>
    return -1;
    80003a6a:	557d                	li	a0,-1
}
    80003a6c:	8082                	ret
    return -1;
    80003a6e:	557d                	li	a0,-1
    80003a70:	bfe1                	j	80003a48 <writei+0xe0>
    return -1;
    80003a72:	557d                	li	a0,-1
    80003a74:	bfd1                	j	80003a48 <writei+0xe0>

0000000080003a76 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003a76:	1141                	addi	sp,sp,-16
    80003a78:	e406                	sd	ra,8(sp)
    80003a7a:	e022                	sd	s0,0(sp)
    80003a7c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a7e:	4639                	li	a2,14
    80003a80:	b20fd0ef          	jal	80000da0 <strncmp>
}
    80003a84:	60a2                	ld	ra,8(sp)
    80003a86:	6402                	ld	s0,0(sp)
    80003a88:	0141                	addi	sp,sp,16
    80003a8a:	8082                	ret

0000000080003a8c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a8c:	7139                	addi	sp,sp,-64
    80003a8e:	fc06                	sd	ra,56(sp)
    80003a90:	f822                	sd	s0,48(sp)
    80003a92:	f426                	sd	s1,40(sp)
    80003a94:	f04a                	sd	s2,32(sp)
    80003a96:	ec4e                	sd	s3,24(sp)
    80003a98:	e852                	sd	s4,16(sp)
    80003a9a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003a9c:	04451703          	lh	a4,68(a0)
    80003aa0:	4785                	li	a5,1
    80003aa2:	00f71a63          	bne	a4,a5,80003ab6 <dirlookup+0x2a>
    80003aa6:	892a                	mv	s2,a0
    80003aa8:	89ae                	mv	s3,a1
    80003aaa:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aac:	457c                	lw	a5,76(a0)
    80003aae:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ab0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ab2:	e39d                	bnez	a5,80003ad8 <dirlookup+0x4c>
    80003ab4:	a095                	j	80003b18 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003ab6:	00005517          	auipc	a0,0x5
    80003aba:	9f250513          	addi	a0,a0,-1550 # 800084a8 <etext+0x4a8>
    80003abe:	d55fc0ef          	jal	80000812 <panic>
      panic("dirlookup read");
    80003ac2:	00005517          	auipc	a0,0x5
    80003ac6:	9fe50513          	addi	a0,a0,-1538 # 800084c0 <etext+0x4c0>
    80003aca:	d49fc0ef          	jal	80000812 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ace:	24c1                	addiw	s1,s1,16
    80003ad0:	04c92783          	lw	a5,76(s2)
    80003ad4:	04f4f163          	bgeu	s1,a5,80003b16 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ad8:	4741                	li	a4,16
    80003ada:	86a6                	mv	a3,s1
    80003adc:	fc040613          	addi	a2,s0,-64
    80003ae0:	4581                	li	a1,0
    80003ae2:	854a                	mv	a0,s2
    80003ae4:	d89ff0ef          	jal	8000386c <readi>
    80003ae8:	47c1                	li	a5,16
    80003aea:	fcf51ce3          	bne	a0,a5,80003ac2 <dirlookup+0x36>
    if(de.inum == 0)
    80003aee:	fc045783          	lhu	a5,-64(s0)
    80003af2:	dff1                	beqz	a5,80003ace <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003af4:	fc240593          	addi	a1,s0,-62
    80003af8:	854e                	mv	a0,s3
    80003afa:	f7dff0ef          	jal	80003a76 <namecmp>
    80003afe:	f961                	bnez	a0,80003ace <dirlookup+0x42>
      if(poff)
    80003b00:	000a0463          	beqz	s4,80003b08 <dirlookup+0x7c>
        *poff = off;
    80003b04:	009a2023          	sw	s1,0(s4) # 2000 <_entry-0x7fffe000>
      return iget(dp->dev, inum);
    80003b08:	fc045583          	lhu	a1,-64(s0)
    80003b0c:	00092503          	lw	a0,0(s2)
    80003b10:	cb8ff0ef          	jal	80002fc8 <iget>
    80003b14:	a011                	j	80003b18 <dirlookup+0x8c>
  return 0;
    80003b16:	4501                	li	a0,0
}
    80003b18:	70e2                	ld	ra,56(sp)
    80003b1a:	7442                	ld	s0,48(sp)
    80003b1c:	74a2                	ld	s1,40(sp)
    80003b1e:	7902                	ld	s2,32(sp)
    80003b20:	69e2                	ld	s3,24(sp)
    80003b22:	6a42                	ld	s4,16(sp)
    80003b24:	6121                	addi	sp,sp,64
    80003b26:	8082                	ret

0000000080003b28 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b28:	711d                	addi	sp,sp,-96
    80003b2a:	ec86                	sd	ra,88(sp)
    80003b2c:	e8a2                	sd	s0,80(sp)
    80003b2e:	e4a6                	sd	s1,72(sp)
    80003b30:	e0ca                	sd	s2,64(sp)
    80003b32:	fc4e                	sd	s3,56(sp)
    80003b34:	f852                	sd	s4,48(sp)
    80003b36:	f456                	sd	s5,40(sp)
    80003b38:	f05a                	sd	s6,32(sp)
    80003b3a:	ec5e                	sd	s7,24(sp)
    80003b3c:	e862                	sd	s8,16(sp)
    80003b3e:	e466                	sd	s9,8(sp)
    80003b40:	1080                	addi	s0,sp,96
    80003b42:	84aa                	mv	s1,a0
    80003b44:	8b2e                	mv	s6,a1
    80003b46:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003b48:	00054703          	lbu	a4,0(a0)
    80003b4c:	02f00793          	li	a5,47
    80003b50:	00f70e63          	beq	a4,a5,80003b6c <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003b54:	db5fd0ef          	jal	80001908 <myproc>
    80003b58:	15053503          	ld	a0,336(a0)
    80003b5c:	935ff0ef          	jal	80003490 <idup>
    80003b60:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003b62:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003b66:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003b68:	4b85                	li	s7,1
    80003b6a:	a871                	j	80003c06 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003b6c:	4585                	li	a1,1
    80003b6e:	4505                	li	a0,1
    80003b70:	c58ff0ef          	jal	80002fc8 <iget>
    80003b74:	8a2a                	mv	s4,a0
    80003b76:	b7f5                	j	80003b62 <namex+0x3a>
      iunlockput(ip);
    80003b78:	8552                	mv	a0,s4
    80003b7a:	b6dff0ef          	jal	800036e6 <iunlockput>
      return 0;
    80003b7e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b80:	8552                	mv	a0,s4
    80003b82:	60e6                	ld	ra,88(sp)
    80003b84:	6446                	ld	s0,80(sp)
    80003b86:	64a6                	ld	s1,72(sp)
    80003b88:	6906                	ld	s2,64(sp)
    80003b8a:	79e2                	ld	s3,56(sp)
    80003b8c:	7a42                	ld	s4,48(sp)
    80003b8e:	7aa2                	ld	s5,40(sp)
    80003b90:	7b02                	ld	s6,32(sp)
    80003b92:	6be2                	ld	s7,24(sp)
    80003b94:	6c42                	ld	s8,16(sp)
    80003b96:	6ca2                	ld	s9,8(sp)
    80003b98:	6125                	addi	sp,sp,96
    80003b9a:	8082                	ret
      iunlock(ip);
    80003b9c:	8552                	mv	a0,s4
    80003b9e:	9dfff0ef          	jal	8000357c <iunlock>
      return ip;
    80003ba2:	bff9                	j	80003b80 <namex+0x58>
      iunlockput(ip);
    80003ba4:	8552                	mv	a0,s4
    80003ba6:	b41ff0ef          	jal	800036e6 <iunlockput>
      return 0;
    80003baa:	8a4e                	mv	s4,s3
    80003bac:	bfd1                	j	80003b80 <namex+0x58>
  len = path - s;
    80003bae:	40998633          	sub	a2,s3,s1
    80003bb2:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003bb6:	099c5063          	bge	s8,s9,80003c36 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003bba:	4639                	li	a2,14
    80003bbc:	85a6                	mv	a1,s1
    80003bbe:	8556                	mv	a0,s5
    80003bc0:	970fd0ef          	jal	80000d30 <memmove>
    80003bc4:	84ce                	mv	s1,s3
  while(*path == '/')
    80003bc6:	0004c783          	lbu	a5,0(s1)
    80003bca:	01279763          	bne	a5,s2,80003bd8 <namex+0xb0>
    path++;
    80003bce:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003bd0:	0004c783          	lbu	a5,0(s1)
    80003bd4:	ff278de3          	beq	a5,s2,80003bce <namex+0xa6>
    ilock(ip);
    80003bd8:	8552                	mv	a0,s4
    80003bda:	8edff0ef          	jal	800034c6 <ilock>
    if(ip->type != T_DIR){
    80003bde:	044a1783          	lh	a5,68(s4)
    80003be2:	f9779be3          	bne	a5,s7,80003b78 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003be6:	000b0563          	beqz	s6,80003bf0 <namex+0xc8>
    80003bea:	0004c783          	lbu	a5,0(s1)
    80003bee:	d7dd                	beqz	a5,80003b9c <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003bf0:	4601                	li	a2,0
    80003bf2:	85d6                	mv	a1,s5
    80003bf4:	8552                	mv	a0,s4
    80003bf6:	e97ff0ef          	jal	80003a8c <dirlookup>
    80003bfa:	89aa                	mv	s3,a0
    80003bfc:	d545                	beqz	a0,80003ba4 <namex+0x7c>
    iunlockput(ip);
    80003bfe:	8552                	mv	a0,s4
    80003c00:	ae7ff0ef          	jal	800036e6 <iunlockput>
    ip = next;
    80003c04:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003c06:	0004c783          	lbu	a5,0(s1)
    80003c0a:	01279763          	bne	a5,s2,80003c18 <namex+0xf0>
    path++;
    80003c0e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c10:	0004c783          	lbu	a5,0(s1)
    80003c14:	ff278de3          	beq	a5,s2,80003c0e <namex+0xe6>
  if(*path == 0)
    80003c18:	cb8d                	beqz	a5,80003c4a <namex+0x122>
  while(*path != '/' && *path != 0)
    80003c1a:	0004c783          	lbu	a5,0(s1)
    80003c1e:	89a6                	mv	s3,s1
  len = path - s;
    80003c20:	4c81                	li	s9,0
    80003c22:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003c24:	01278963          	beq	a5,s2,80003c36 <namex+0x10e>
    80003c28:	d3d9                	beqz	a5,80003bae <namex+0x86>
    path++;
    80003c2a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003c2c:	0009c783          	lbu	a5,0(s3)
    80003c30:	ff279ce3          	bne	a5,s2,80003c28 <namex+0x100>
    80003c34:	bfad                	j	80003bae <namex+0x86>
    memmove(name, s, len);
    80003c36:	2601                	sext.w	a2,a2
    80003c38:	85a6                	mv	a1,s1
    80003c3a:	8556                	mv	a0,s5
    80003c3c:	8f4fd0ef          	jal	80000d30 <memmove>
    name[len] = 0;
    80003c40:	9cd6                	add	s9,s9,s5
    80003c42:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003c46:	84ce                	mv	s1,s3
    80003c48:	bfbd                	j	80003bc6 <namex+0x9e>
  if(nameiparent){
    80003c4a:	f20b0be3          	beqz	s6,80003b80 <namex+0x58>
    iput(ip);
    80003c4e:	8552                	mv	a0,s4
    80003c50:	a09ff0ef          	jal	80003658 <iput>
    return 0;
    80003c54:	4a01                	li	s4,0
    80003c56:	b72d                	j	80003b80 <namex+0x58>

0000000080003c58 <dirlink>:
{
    80003c58:	7139                	addi	sp,sp,-64
    80003c5a:	fc06                	sd	ra,56(sp)
    80003c5c:	f822                	sd	s0,48(sp)
    80003c5e:	f04a                	sd	s2,32(sp)
    80003c60:	ec4e                	sd	s3,24(sp)
    80003c62:	e852                	sd	s4,16(sp)
    80003c64:	0080                	addi	s0,sp,64
    80003c66:	892a                	mv	s2,a0
    80003c68:	8a2e                	mv	s4,a1
    80003c6a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003c6c:	4601                	li	a2,0
    80003c6e:	e1fff0ef          	jal	80003a8c <dirlookup>
    80003c72:	e535                	bnez	a0,80003cde <dirlink+0x86>
    80003c74:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c76:	04c92483          	lw	s1,76(s2)
    80003c7a:	c48d                	beqz	s1,80003ca4 <dirlink+0x4c>
    80003c7c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c7e:	4741                	li	a4,16
    80003c80:	86a6                	mv	a3,s1
    80003c82:	fc040613          	addi	a2,s0,-64
    80003c86:	4581                	li	a1,0
    80003c88:	854a                	mv	a0,s2
    80003c8a:	be3ff0ef          	jal	8000386c <readi>
    80003c8e:	47c1                	li	a5,16
    80003c90:	04f51b63          	bne	a0,a5,80003ce6 <dirlink+0x8e>
    if(de.inum == 0)
    80003c94:	fc045783          	lhu	a5,-64(s0)
    80003c98:	c791                	beqz	a5,80003ca4 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c9a:	24c1                	addiw	s1,s1,16
    80003c9c:	04c92783          	lw	a5,76(s2)
    80003ca0:	fcf4efe3          	bltu	s1,a5,80003c7e <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003ca4:	4639                	li	a2,14
    80003ca6:	85d2                	mv	a1,s4
    80003ca8:	fc240513          	addi	a0,s0,-62
    80003cac:	92afd0ef          	jal	80000dd6 <strncpy>
  de.inum = inum;
    80003cb0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cb4:	4741                	li	a4,16
    80003cb6:	86a6                	mv	a3,s1
    80003cb8:	fc040613          	addi	a2,s0,-64
    80003cbc:	4581                	li	a1,0
    80003cbe:	854a                	mv	a0,s2
    80003cc0:	ca9ff0ef          	jal	80003968 <writei>
    80003cc4:	1541                	addi	a0,a0,-16
    80003cc6:	00a03533          	snez	a0,a0
    80003cca:	40a00533          	neg	a0,a0
    80003cce:	74a2                	ld	s1,40(sp)
}
    80003cd0:	70e2                	ld	ra,56(sp)
    80003cd2:	7442                	ld	s0,48(sp)
    80003cd4:	7902                	ld	s2,32(sp)
    80003cd6:	69e2                	ld	s3,24(sp)
    80003cd8:	6a42                	ld	s4,16(sp)
    80003cda:	6121                	addi	sp,sp,64
    80003cdc:	8082                	ret
    iput(ip);
    80003cde:	97bff0ef          	jal	80003658 <iput>
    return -1;
    80003ce2:	557d                	li	a0,-1
    80003ce4:	b7f5                	j	80003cd0 <dirlink+0x78>
      panic("dirlink read");
    80003ce6:	00004517          	auipc	a0,0x4
    80003cea:	7ea50513          	addi	a0,a0,2026 # 800084d0 <etext+0x4d0>
    80003cee:	b25fc0ef          	jal	80000812 <panic>

0000000080003cf2 <namei>:

struct inode*
namei(char *path)
{
    80003cf2:	1101                	addi	sp,sp,-32
    80003cf4:	ec06                	sd	ra,24(sp)
    80003cf6:	e822                	sd	s0,16(sp)
    80003cf8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003cfa:	fe040613          	addi	a2,s0,-32
    80003cfe:	4581                	li	a1,0
    80003d00:	e29ff0ef          	jal	80003b28 <namex>
}
    80003d04:	60e2                	ld	ra,24(sp)
    80003d06:	6442                	ld	s0,16(sp)
    80003d08:	6105                	addi	sp,sp,32
    80003d0a:	8082                	ret

0000000080003d0c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003d0c:	1141                	addi	sp,sp,-16
    80003d0e:	e406                	sd	ra,8(sp)
    80003d10:	e022                	sd	s0,0(sp)
    80003d12:	0800                	addi	s0,sp,16
    80003d14:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003d16:	4585                	li	a1,1
    80003d18:	e11ff0ef          	jal	80003b28 <namex>
}
    80003d1c:	60a2                	ld	ra,8(sp)
    80003d1e:	6402                	ld	s0,0(sp)
    80003d20:	0141                	addi	sp,sp,16
    80003d22:	8082                	ret

0000000080003d24 <install_trans>:
static void
install_trans(int recovering)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    80003d24:	0001d797          	auipc	a5,0x1d
    80003d28:	d3c7a783          	lw	a5,-708(a5) # 80020a60 <log+0x28>
    80003d2c:	0cf05263          	blez	a5,80003df0 <install_trans+0xcc>
{
    80003d30:	715d                	addi	sp,sp,-80
    80003d32:	e486                	sd	ra,72(sp)
    80003d34:	e0a2                	sd	s0,64(sp)
    80003d36:	fc26                	sd	s1,56(sp)
    80003d38:	f84a                	sd	s2,48(sp)
    80003d3a:	f44e                	sd	s3,40(sp)
    80003d3c:	f052                	sd	s4,32(sp)
    80003d3e:	ec56                	sd	s5,24(sp)
    80003d40:	e85a                	sd	s6,16(sp)
    80003d42:	e45e                	sd	s7,8(sp)
    80003d44:	0880                	addi	s0,sp,80
    80003d46:	8b2a                	mv	s6,a0
    80003d48:	0001da17          	auipc	s4,0x1d
    80003d4c:	d1ca0a13          	addi	s4,s4,-740 # 80020a64 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d50:	4981                	li	s3,0
    fslog_install(log.lh.block[tail]);
    if(recovering) {
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d52:	00004b97          	auipc	s7,0x4
    80003d56:	78eb8b93          	addi	s7,s7,1934 # 800084e0 <etext+0x4e0>
    }
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d5a:	0001da97          	auipc	s5,0x1d
    80003d5e:	cdea8a93          	addi	s5,s5,-802 # 80020a38 <log>
    80003d62:	a025                	j	80003d8a <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d64:	000a2603          	lw	a2,0(s4)
    80003d68:	85ce                	mv	a1,s3
    80003d6a:	855e                	mv	a0,s7
    80003d6c:	fc0fc0ef          	jal	8000052c <printf>
    80003d70:	a025                	j	80003d98 <install_trans+0x74>
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    if(recovering == 0)
      bunpin(dbuf);
    brelse(lbuf);
    80003d72:	854a                	mv	a0,s2
    80003d74:	8ecff0ef          	jal	80002e60 <brelse>
    brelse(dbuf);
    80003d78:	8526                	mv	a0,s1
    80003d7a:	8e6ff0ef          	jal	80002e60 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d7e:	2985                	addiw	s3,s3,1
    80003d80:	0a11                	addi	s4,s4,4
    80003d82:	028aa783          	lw	a5,40(s5)
    80003d86:	04f9da63          	bge	s3,a5,80003dda <install_trans+0xb6>
    fslog_install(log.lh.block[tail]);
    80003d8a:	84d2                	mv	s1,s4
    80003d8c:	000a2503          	lw	a0,0(s4)
    80003d90:	125020ef          	jal	800066b4 <fslog_install>
    if(recovering) {
    80003d94:	fc0b18e3          	bnez	s6,80003d64 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d98:	018aa583          	lw	a1,24(s5)
    80003d9c:	013585bb          	addw	a1,a1,s3
    80003da0:	2585                	addiw	a1,a1,1
    80003da2:	024aa503          	lw	a0,36(s5)
    80003da6:	df1fe0ef          	jal	80002b96 <bread>
    80003daa:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003dac:	408c                	lw	a1,0(s1)
    80003dae:	024aa503          	lw	a0,36(s5)
    80003db2:	de5fe0ef          	jal	80002b96 <bread>
    80003db6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003db8:	40000613          	li	a2,1024
    80003dbc:	05890593          	addi	a1,s2,88
    80003dc0:	05850513          	addi	a0,a0,88
    80003dc4:	f6dfc0ef          	jal	80000d30 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003dc8:	8526                	mv	a0,s1
    80003dca:	81cff0ef          	jal	80002de6 <bwrite>
    if(recovering == 0)
    80003dce:	fa0b12e3          	bnez	s6,80003d72 <install_trans+0x4e>
      bunpin(dbuf);
    80003dd2:	8526                	mv	a0,s1
    80003dd4:	9c0ff0ef          	jal	80002f94 <bunpin>
    80003dd8:	bf69                	j	80003d72 <install_trans+0x4e>
  }
}
    80003dda:	60a6                	ld	ra,72(sp)
    80003ddc:	6406                	ld	s0,64(sp)
    80003dde:	74e2                	ld	s1,56(sp)
    80003de0:	7942                	ld	s2,48(sp)
    80003de2:	79a2                	ld	s3,40(sp)
    80003de4:	7a02                	ld	s4,32(sp)
    80003de6:	6ae2                	ld	s5,24(sp)
    80003de8:	6b42                	ld	s6,16(sp)
    80003dea:	6ba2                	ld	s7,8(sp)
    80003dec:	6161                	addi	sp,sp,80
    80003dee:	8082                	ret
    80003df0:	8082                	ret

0000000080003df2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003df2:	1101                	addi	sp,sp,-32
    80003df4:	ec06                	sd	ra,24(sp)
    80003df6:	e822                	sd	s0,16(sp)
    80003df8:	e426                	sd	s1,8(sp)
    80003dfa:	e04a                	sd	s2,0(sp)
    80003dfc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003dfe:	0001d917          	auipc	s2,0x1d
    80003e02:	c3a90913          	addi	s2,s2,-966 # 80020a38 <log>
    80003e06:	01892583          	lw	a1,24(s2)
    80003e0a:	02492503          	lw	a0,36(s2)
    80003e0e:	d89fe0ef          	jal	80002b96 <bread>
    80003e12:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e14:	02892503          	lw	a0,40(s2)
    80003e18:	cca8                	sw	a0,88(s1)
  fslog_writehead(log.lh.n);
    80003e1a:	059020ef          	jal	80006672 <fslog_writehead>
  for (i = 0; i < log.lh.n; i++) {
    80003e1e:	02892603          	lw	a2,40(s2)
    80003e22:	00c05f63          	blez	a2,80003e40 <write_head+0x4e>
    80003e26:	0001d717          	auipc	a4,0x1d
    80003e2a:	c3e70713          	addi	a4,a4,-962 # 80020a64 <log+0x2c>
    80003e2e:	87a6                	mv	a5,s1
    80003e30:	060a                	slli	a2,a2,0x2
    80003e32:	9626                	add	a2,a2,s1
    hb->block[i] = log.lh.block[i];
    80003e34:	4314                	lw	a3,0(a4)
    80003e36:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003e38:	0711                	addi	a4,a4,4
    80003e3a:	0791                	addi	a5,a5,4
    80003e3c:	fec79ce3          	bne	a5,a2,80003e34 <write_head+0x42>
  }
  bwrite(buf);
    80003e40:	8526                	mv	a0,s1
    80003e42:	fa5fe0ef          	jal	80002de6 <bwrite>
  brelse(buf);
    80003e46:	8526                	mv	a0,s1
    80003e48:	818ff0ef          	jal	80002e60 <brelse>
}
    80003e4c:	60e2                	ld	ra,24(sp)
    80003e4e:	6442                	ld	s0,16(sp)
    80003e50:	64a2                	ld	s1,8(sp)
    80003e52:	6902                	ld	s2,0(sp)
    80003e54:	6105                	addi	sp,sp,32
    80003e56:	8082                	ret

0000000080003e58 <initlog>:
{
    80003e58:	7179                	addi	sp,sp,-48
    80003e5a:	f406                	sd	ra,40(sp)
    80003e5c:	f022                	sd	s0,32(sp)
    80003e5e:	ec26                	sd	s1,24(sp)
    80003e60:	e84a                	sd	s2,16(sp)
    80003e62:	e44e                	sd	s3,8(sp)
    80003e64:	1800                	addi	s0,sp,48
    80003e66:	892a                	mv	s2,a0
    80003e68:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e6a:	0001d497          	auipc	s1,0x1d
    80003e6e:	bce48493          	addi	s1,s1,-1074 # 80020a38 <log>
    80003e72:	00004597          	auipc	a1,0x4
    80003e76:	68e58593          	addi	a1,a1,1678 # 80008500 <etext+0x500>
    80003e7a:	8526                	mv	a0,s1
    80003e7c:	d05fc0ef          	jal	80000b80 <initlock>
  log.start = sb->logstart;
    80003e80:	0149a583          	lw	a1,20(s3)
    80003e84:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003e86:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003e8a:	854a                	mv	a0,s2
    80003e8c:	d0bfe0ef          	jal	80002b96 <bread>
  log.lh.n = lh->n;
    80003e90:	4d30                	lw	a2,88(a0)
    80003e92:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003e94:	00c05f63          	blez	a2,80003eb2 <initlog+0x5a>
    80003e98:	87aa                	mv	a5,a0
    80003e9a:	0001d717          	auipc	a4,0x1d
    80003e9e:	bca70713          	addi	a4,a4,-1078 # 80020a64 <log+0x2c>
    80003ea2:	060a                	slli	a2,a2,0x2
    80003ea4:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003ea6:	4ff4                	lw	a3,92(a5)
    80003ea8:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003eaa:	0791                	addi	a5,a5,4
    80003eac:	0711                	addi	a4,a4,4
    80003eae:	fec79ce3          	bne	a5,a2,80003ea6 <initlog+0x4e>
  brelse(buf);
    80003eb2:	faffe0ef          	jal	80002e60 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003eb6:	4505                	li	a0,1
    80003eb8:	e6dff0ef          	jal	80003d24 <install_trans>
  log.lh.n = 0;
    80003ebc:	0001d797          	auipc	a5,0x1d
    80003ec0:	ba07a223          	sw	zero,-1116(a5) # 80020a60 <log+0x28>
  write_head(); // clear the log
    80003ec4:	f2fff0ef          	jal	80003df2 <write_head>
}
    80003ec8:	70a2                	ld	ra,40(sp)
    80003eca:	7402                	ld	s0,32(sp)
    80003ecc:	64e2                	ld	s1,24(sp)
    80003ece:	6942                	ld	s2,16(sp)
    80003ed0:	69a2                	ld	s3,8(sp)
    80003ed2:	6145                	addi	sp,sp,48
    80003ed4:	8082                	ret

0000000080003ed6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ed6:	1101                	addi	sp,sp,-32
    80003ed8:	ec06                	sd	ra,24(sp)
    80003eda:	e822                	sd	s0,16(sp)
    80003edc:	e426                	sd	s1,8(sp)
    80003ede:	e04a                	sd	s2,0(sp)
    80003ee0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003ee2:	0001d517          	auipc	a0,0x1d
    80003ee6:	b5650513          	addi	a0,a0,-1194 # 80020a38 <log>
    80003eea:	d17fc0ef          	jal	80000c00 <acquire>
  while(1){
    if(log.committing){
    80003eee:	0001d497          	auipc	s1,0x1d
    80003ef2:	b4a48493          	addi	s1,s1,-1206 # 80020a38 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003ef6:	4979                	li	s2,30
    80003ef8:	a029                	j	80003f02 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003efa:	85a6                	mv	a1,s1
    80003efc:	8526                	mv	a0,s1
    80003efe:	81afe0ef          	jal	80001f18 <sleep>
    if(log.committing){
    80003f02:	509c                	lw	a5,32(s1)
    80003f04:	fbfd                	bnez	a5,80003efa <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003f06:	4cc8                	lw	a0,28(s1)
    80003f08:	0015071b          	addiw	a4,a0,1
    80003f0c:	0007059b          	sext.w	a1,a4
    80003f10:	0027179b          	slliw	a5,a4,0x2
    80003f14:	9fb9                	addw	a5,a5,a4
    80003f16:	0017979b          	slliw	a5,a5,0x1
    80003f1a:	5494                	lw	a3,40(s1)
    80003f1c:	9fb5                	addw	a5,a5,a3
    80003f1e:	00f95763          	bge	s2,a5,80003f2c <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003f22:	85a6                	mv	a1,s1
    80003f24:	8526                	mv	a0,s1
    80003f26:	ff3fd0ef          	jal	80001f18 <sleep>
    80003f2a:	bfe1                	j	80003f02 <begin_op+0x2c>
    } else {
      int before = log.outstanding;
      log.outstanding += 1;
    80003f2c:	0001d497          	auipc	s1,0x1d
    80003f30:	b0c48493          	addi	s1,s1,-1268 # 80020a38 <log>
    80003f34:	ccd8                	sw	a4,28(s1)
      fslog_begin(before, log.outstanding);
    80003f36:	5ee020ef          	jal	80006524 <fslog_begin>
      release(&log.lock);
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	d5dfc0ef          	jal	80000c98 <release>
      break;
    }
  }
}
    80003f40:	60e2                	ld	ra,24(sp)
    80003f42:	6442                	ld	s0,16(sp)
    80003f44:	64a2                	ld	s1,8(sp)
    80003f46:	6902                	ld	s2,0(sp)
    80003f48:	6105                	addi	sp,sp,32
    80003f4a:	8082                	ret

0000000080003f4c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003f4c:	7139                	addi	sp,sp,-64
    80003f4e:	fc06                	sd	ra,56(sp)
    80003f50:	f822                	sd	s0,48(sp)
    80003f52:	f04a                	sd	s2,32(sp)
    80003f54:	e05a                	sd	s6,0(sp)
    80003f56:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f58:	0001d917          	auipc	s2,0x1d
    80003f5c:	ae090913          	addi	s2,s2,-1312 # 80020a38 <log>
    80003f60:	854a                	mv	a0,s2
    80003f62:	c9ffc0ef          	jal	80000c00 <acquire>
  int before = log.outstanding;
    80003f66:	01c92b03          	lw	s6,28(s2)
  log.outstanding -= 1;
    80003f6a:	fffb079b          	addiw	a5,s6,-1
    80003f6e:	00f92e23          	sw	a5,28(s2)
  if(log.committing)
    80003f72:	02092903          	lw	s2,32(s2)
    80003f76:	04091563          	bnez	s2,80003fc0 <end_op+0x74>
    80003f7a:	f426                	sd	s1,40(sp)
    80003f7c:	0007849b          	sext.w	s1,a5
    panic("log.committing");
  if(log.outstanding == 0){
    80003f80:	e8b1                	bnez	s1,80003fd4 <end_op+0x88>
    do_commit = 1;
    log.committing = 1;
    80003f82:	0001d917          	auipc	s2,0x1d
    80003f86:	ab690913          	addi	s2,s2,-1354 # 80020a38 <log>
    80003f8a:	4785                	li	a5,1
    80003f8c:	02f92023          	sw	a5,32(s2)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f90:	854a                	mv	a0,s2
    80003f92:	d07fc0ef          	jal	80000c98 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f96:	02892783          	lw	a5,40(s2)
    80003f9a:	06f04663          	bgtz	a5,80004006 <end_op+0xba>
    acquire(&log.lock);
    80003f9e:	0001d497          	auipc	s1,0x1d
    80003fa2:	a9a48493          	addi	s1,s1,-1382 # 80020a38 <log>
    80003fa6:	8526                	mv	a0,s1
    80003fa8:	c59fc0ef          	jal	80000c00 <acquire>
    log.committing = 0;
    80003fac:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	fb3fd0ef          	jal	80001f64 <wakeup>
    release(&log.lock);
    80003fb6:	8526                	mv	a0,s1
    80003fb8:	ce1fc0ef          	jal	80000c98 <release>
    do_commit = 1;
    80003fbc:	4905                	li	s2,1
    80003fbe:	a02d                	j	80003fe8 <end_op+0x9c>
    80003fc0:	f426                	sd	s1,40(sp)
    80003fc2:	ec4e                	sd	s3,24(sp)
    80003fc4:	e852                	sd	s4,16(sp)
    80003fc6:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003fc8:	00004517          	auipc	a0,0x4
    80003fcc:	54050513          	addi	a0,a0,1344 # 80008508 <etext+0x508>
    80003fd0:	843fc0ef          	jal	80000812 <panic>
    wakeup(&log);
    80003fd4:	0001d497          	auipc	s1,0x1d
    80003fd8:	a6448493          	addi	s1,s1,-1436 # 80020a38 <log>
    80003fdc:	8526                	mv	a0,s1
    80003fde:	f87fd0ef          	jal	80001f64 <wakeup>
  release(&log.lock);
    80003fe2:	8526                	mv	a0,s1
    80003fe4:	cb5fc0ef          	jal	80000c98 <release>
  fslog_end(before, log.outstanding, do_commit);
    80003fe8:	864a                	mv	a2,s2
    80003fea:	0001d597          	auipc	a1,0x1d
    80003fee:	a6a5a583          	lw	a1,-1430(a1) # 80020a54 <log+0x1c>
    80003ff2:	855a                	mv	a0,s6
    80003ff4:	5dc020ef          	jal	800065d0 <fslog_end>
    80003ff8:	74a2                	ld	s1,40(sp)
}
    80003ffa:	70e2                	ld	ra,56(sp)
    80003ffc:	7442                	ld	s0,48(sp)
    80003ffe:	7902                	ld	s2,32(sp)
    80004000:	6b02                	ld	s6,0(sp)
    80004002:	6121                	addi	sp,sp,64
    80004004:	8082                	ret
    80004006:	ec4e                	sd	s3,24(sp)
    80004008:	e852                	sd	s4,16(sp)
    8000400a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000400c:	0001da97          	auipc	s5,0x1d
    80004010:	a58a8a93          	addi	s5,s5,-1448 # 80020a64 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004014:	0001da17          	auipc	s4,0x1d
    80004018:	a24a0a13          	addi	s4,s4,-1500 # 80020a38 <log>
    fslog_writelog(log.lh.block[tail], tail);
    8000401c:	85a6                	mv	a1,s1
    8000401e:	000aa503          	lw	a0,0(s5)
    80004022:	604020ef          	jal	80006626 <fslog_writelog>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004026:	018a2583          	lw	a1,24(s4)
    8000402a:	9da5                	addw	a1,a1,s1
    8000402c:	2585                	addiw	a1,a1,1
    8000402e:	024a2503          	lw	a0,36(s4)
    80004032:	b65fe0ef          	jal	80002b96 <bread>
    80004036:	892a                	mv	s2,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004038:	000aa583          	lw	a1,0(s5)
    8000403c:	024a2503          	lw	a0,36(s4)
    80004040:	b57fe0ef          	jal	80002b96 <bread>
    80004044:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004046:	40000613          	li	a2,1024
    8000404a:	05850593          	addi	a1,a0,88
    8000404e:	05890513          	addi	a0,s2,88
    80004052:	cdffc0ef          	jal	80000d30 <memmove>
    bwrite(to);  // write the log
    80004056:	854a                	mv	a0,s2
    80004058:	d8ffe0ef          	jal	80002de6 <bwrite>
    brelse(from);
    8000405c:	854e                	mv	a0,s3
    8000405e:	e03fe0ef          	jal	80002e60 <brelse>
    brelse(to);
    80004062:	854a                	mv	a0,s2
    80004064:	dfdfe0ef          	jal	80002e60 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004068:	2485                	addiw	s1,s1,1
    8000406a:	0a91                	addi	s5,s5,4
    8000406c:	028a2783          	lw	a5,40(s4)
    80004070:	faf4c6e3          	blt	s1,a5,8000401c <end_op+0xd0>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004074:	d7fff0ef          	jal	80003df2 <write_head>
    install_trans(0); // Now install writes to home locations
    80004078:	4501                	li	a0,0
    8000407a:	cabff0ef          	jal	80003d24 <install_trans>
    log.lh.n = 0;
    8000407e:	0001d797          	auipc	a5,0x1d
    80004082:	9e07a123          	sw	zero,-1566(a5) # 80020a60 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004086:	d6dff0ef          	jal	80003df2 <write_head>
    8000408a:	69e2                	ld	s3,24(sp)
    8000408c:	6a42                	ld	s4,16(sp)
    8000408e:	6aa2                	ld	s5,8(sp)
    80004090:	b739                	j	80003f9e <end_op+0x52>

0000000080004092 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004092:	7179                	addi	sp,sp,-48
    80004094:	f406                	sd	ra,40(sp)
    80004096:	f022                	sd	s0,32(sp)
    80004098:	ec26                	sd	s1,24(sp)
    8000409a:	e84a                	sd	s2,16(sp)
    8000409c:	e44e                	sd	s3,8(sp)
    8000409e:	e052                	sd	s4,0(sp)
    800040a0:	1800                	addi	s0,sp,48
    800040a2:	84aa                	mv	s1,a0
  int i;
  int existed = 0;
  int n_before = log.lh.n;
    800040a4:	0001d917          	auipc	s2,0x1d
    800040a8:	99490913          	addi	s2,s2,-1644 # 80020a38 <log>
    800040ac:	02892983          	lw	s3,40(s2)
  acquire(&log.lock);
    800040b0:	854a                	mv	a0,s2
    800040b2:	b4ffc0ef          	jal	80000c00 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800040b6:	02892603          	lw	a2,40(s2)
    800040ba:	47f5                	li	a5,29
    800040bc:	04c7ce63          	blt	a5,a2,80004118 <log_write+0x86>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800040c0:	0001d797          	auipc	a5,0x1d
    800040c4:	9947a783          	lw	a5,-1644(a5) # 80020a54 <log+0x1c>
    800040c8:	04f05e63          	blez	a5,80004124 <log_write+0x92>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800040cc:	4781                	li	a5,0
  int existed = 0;
    800040ce:	4a01                	li	s4,0
  for (i = 0; i < log.lh.n; i++) {
    800040d0:	06c05163          	blez	a2,80004132 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno) {
    800040d4:	44cc                	lw	a1,12(s1)
    800040d6:	0001d717          	auipc	a4,0x1d
    800040da:	98e70713          	addi	a4,a4,-1650 # 80020a64 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    800040de:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) {
    800040e0:	4314                	lw	a3,0(a4)
    800040e2:	04b68763          	beq	a3,a1,80004130 <log_write+0x9e>
  for (i = 0; i < log.lh.n; i++) {
    800040e6:	2785                	addiw	a5,a5,1
    800040e8:	0711                	addi	a4,a4,4
    800040ea:	fef61be3          	bne	a2,a5,800040e0 <log_write+0x4e>
      existed = 1;  // log absorption
      break;}
  }
  log.lh.block[i] = b->blockno;
    800040ee:	0621                	addi	a2,a2,8
    800040f0:	060a                	slli	a2,a2,0x2
    800040f2:	0001d797          	auipc	a5,0x1d
    800040f6:	94678793          	addi	a5,a5,-1722 # 80020a38 <log>
    800040fa:	97b2                	add	a5,a5,a2
    800040fc:	44d8                	lw	a4,12(s1)
    800040fe:	c7d8                	sw	a4,12(a5)
  int existed = 0;
    80004100:	4a01                	li	s4,0
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004102:	8526                	mv	a0,s1
    80004104:	e5dfe0ef          	jal	80002f60 <bpin>
    log.lh.n++;
    80004108:	0001d717          	auipc	a4,0x1d
    8000410c:	93070713          	addi	a4,a4,-1744 # 80020a38 <log>
    80004110:	571c                	lw	a5,40(a4)
    80004112:	2785                	addiw	a5,a5,1
    80004114:	d71c                	sw	a5,40(a4)
    80004116:	a815                	j	8000414a <log_write+0xb8>
    panic("too big a transaction");
    80004118:	00004517          	auipc	a0,0x4
    8000411c:	40050513          	addi	a0,a0,1024 # 80008518 <etext+0x518>
    80004120:	ef2fc0ef          	jal	80000812 <panic>
    panic("log_write outside of trans");
    80004124:	00004517          	auipc	a0,0x4
    80004128:	40c50513          	addi	a0,a0,1036 # 80008530 <etext+0x530>
    8000412c:	ee6fc0ef          	jal	80000812 <panic>
      existed = 1;  // log absorption
    80004130:	4a05                	li	s4,1
  log.lh.block[i] = b->blockno;
    80004132:	00878693          	addi	a3,a5,8
    80004136:	068a                	slli	a3,a3,0x2
    80004138:	0001d717          	auipc	a4,0x1d
    8000413c:	90070713          	addi	a4,a4,-1792 # 80020a38 <log>
    80004140:	9736                	add	a4,a4,a3
    80004142:	44d4                	lw	a3,12(s1)
    80004144:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004146:	faf60ee3          	beq	a2,a5,80004102 <log_write+0x70>
  }
  fslog_write(b->blockno, existed, n_before, log.lh.n);
    8000414a:	0001d917          	auipc	s2,0x1d
    8000414e:	8ee90913          	addi	s2,s2,-1810 # 80020a38 <log>
    80004152:	02892683          	lw	a3,40(s2)
    80004156:	864e                	mv	a2,s3
    80004158:	85d2                	mv	a1,s4
    8000415a:	44c8                	lw	a0,12(s1)
    8000415c:	414020ef          	jal	80006570 <fslog_write>
  release(&log.lock);
    80004160:	854a                	mv	a0,s2
    80004162:	b37fc0ef          	jal	80000c98 <release>
}
    80004166:	70a2                	ld	ra,40(sp)
    80004168:	7402                	ld	s0,32(sp)
    8000416a:	64e2                	ld	s1,24(sp)
    8000416c:	6942                	ld	s2,16(sp)
    8000416e:	69a2                	ld	s3,8(sp)
    80004170:	6a02                	ld	s4,0(sp)
    80004172:	6145                	addi	sp,sp,48
    80004174:	8082                	ret

0000000080004176 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004176:	1101                	addi	sp,sp,-32
    80004178:	ec06                	sd	ra,24(sp)
    8000417a:	e822                	sd	s0,16(sp)
    8000417c:	e426                	sd	s1,8(sp)
    8000417e:	e04a                	sd	s2,0(sp)
    80004180:	1000                	addi	s0,sp,32
    80004182:	84aa                	mv	s1,a0
    80004184:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004186:	00004597          	auipc	a1,0x4
    8000418a:	3ca58593          	addi	a1,a1,970 # 80008550 <etext+0x550>
    8000418e:	0521                	addi	a0,a0,8
    80004190:	9f1fc0ef          	jal	80000b80 <initlock>
  lk->name = name;
    80004194:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004198:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000419c:	0204a423          	sw	zero,40(s1)
}
    800041a0:	60e2                	ld	ra,24(sp)
    800041a2:	6442                	ld	s0,16(sp)
    800041a4:	64a2                	ld	s1,8(sp)
    800041a6:	6902                	ld	s2,0(sp)
    800041a8:	6105                	addi	sp,sp,32
    800041aa:	8082                	ret

00000000800041ac <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800041ac:	1101                	addi	sp,sp,-32
    800041ae:	ec06                	sd	ra,24(sp)
    800041b0:	e822                	sd	s0,16(sp)
    800041b2:	e426                	sd	s1,8(sp)
    800041b4:	e04a                	sd	s2,0(sp)
    800041b6:	1000                	addi	s0,sp,32
    800041b8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041ba:	00850913          	addi	s2,a0,8
    800041be:	854a                	mv	a0,s2
    800041c0:	a41fc0ef          	jal	80000c00 <acquire>
  while (lk->locked) {
    800041c4:	409c                	lw	a5,0(s1)
    800041c6:	c799                	beqz	a5,800041d4 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800041c8:	85ca                	mv	a1,s2
    800041ca:	8526                	mv	a0,s1
    800041cc:	d4dfd0ef          	jal	80001f18 <sleep>
  while (lk->locked) {
    800041d0:	409c                	lw	a5,0(s1)
    800041d2:	fbfd                	bnez	a5,800041c8 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800041d4:	4785                	li	a5,1
    800041d6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800041d8:	f30fd0ef          	jal	80001908 <myproc>
    800041dc:	591c                	lw	a5,48(a0)
    800041de:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800041e0:	854a                	mv	a0,s2
    800041e2:	ab7fc0ef          	jal	80000c98 <release>
}
    800041e6:	60e2                	ld	ra,24(sp)
    800041e8:	6442                	ld	s0,16(sp)
    800041ea:	64a2                	ld	s1,8(sp)
    800041ec:	6902                	ld	s2,0(sp)
    800041ee:	6105                	addi	sp,sp,32
    800041f0:	8082                	ret

00000000800041f2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800041f2:	1101                	addi	sp,sp,-32
    800041f4:	ec06                	sd	ra,24(sp)
    800041f6:	e822                	sd	s0,16(sp)
    800041f8:	e426                	sd	s1,8(sp)
    800041fa:	e04a                	sd	s2,0(sp)
    800041fc:	1000                	addi	s0,sp,32
    800041fe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004200:	00850913          	addi	s2,a0,8
    80004204:	854a                	mv	a0,s2
    80004206:	9fbfc0ef          	jal	80000c00 <acquire>
  lk->locked = 0;
    8000420a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000420e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004212:	8526                	mv	a0,s1
    80004214:	d51fd0ef          	jal	80001f64 <wakeup>
  release(&lk->lk);
    80004218:	854a                	mv	a0,s2
    8000421a:	a7ffc0ef          	jal	80000c98 <release>
}
    8000421e:	60e2                	ld	ra,24(sp)
    80004220:	6442                	ld	s0,16(sp)
    80004222:	64a2                	ld	s1,8(sp)
    80004224:	6902                	ld	s2,0(sp)
    80004226:	6105                	addi	sp,sp,32
    80004228:	8082                	ret

000000008000422a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000422a:	7179                	addi	sp,sp,-48
    8000422c:	f406                	sd	ra,40(sp)
    8000422e:	f022                	sd	s0,32(sp)
    80004230:	ec26                	sd	s1,24(sp)
    80004232:	e84a                	sd	s2,16(sp)
    80004234:	1800                	addi	s0,sp,48
    80004236:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004238:	00850913          	addi	s2,a0,8
    8000423c:	854a                	mv	a0,s2
    8000423e:	9c3fc0ef          	jal	80000c00 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004242:	409c                	lw	a5,0(s1)
    80004244:	ef81                	bnez	a5,8000425c <holdingsleep+0x32>
    80004246:	4481                	li	s1,0
  release(&lk->lk);
    80004248:	854a                	mv	a0,s2
    8000424a:	a4ffc0ef          	jal	80000c98 <release>
  return r;
}
    8000424e:	8526                	mv	a0,s1
    80004250:	70a2                	ld	ra,40(sp)
    80004252:	7402                	ld	s0,32(sp)
    80004254:	64e2                	ld	s1,24(sp)
    80004256:	6942                	ld	s2,16(sp)
    80004258:	6145                	addi	sp,sp,48
    8000425a:	8082                	ret
    8000425c:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000425e:	0284a983          	lw	s3,40(s1)
    80004262:	ea6fd0ef          	jal	80001908 <myproc>
    80004266:	5904                	lw	s1,48(a0)
    80004268:	413484b3          	sub	s1,s1,s3
    8000426c:	0014b493          	seqz	s1,s1
    80004270:	69a2                	ld	s3,8(sp)
    80004272:	bfd9                	j	80004248 <holdingsleep+0x1e>

0000000080004274 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004274:	1141                	addi	sp,sp,-16
    80004276:	e406                	sd	ra,8(sp)
    80004278:	e022                	sd	s0,0(sp)
    8000427a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000427c:	00004597          	auipc	a1,0x4
    80004280:	2e458593          	addi	a1,a1,740 # 80008560 <etext+0x560>
    80004284:	0001d517          	auipc	a0,0x1d
    80004288:	8fc50513          	addi	a0,a0,-1796 # 80020b80 <ftable>
    8000428c:	8f5fc0ef          	jal	80000b80 <initlock>
}
    80004290:	60a2                	ld	ra,8(sp)
    80004292:	6402                	ld	s0,0(sp)
    80004294:	0141                	addi	sp,sp,16
    80004296:	8082                	ret

0000000080004298 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004298:	1101                	addi	sp,sp,-32
    8000429a:	ec06                	sd	ra,24(sp)
    8000429c:	e822                	sd	s0,16(sp)
    8000429e:	e426                	sd	s1,8(sp)
    800042a0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800042a2:	0001d517          	auipc	a0,0x1d
    800042a6:	8de50513          	addi	a0,a0,-1826 # 80020b80 <ftable>
    800042aa:	957fc0ef          	jal	80000c00 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800042ae:	0001d497          	auipc	s1,0x1d
    800042b2:	8ea48493          	addi	s1,s1,-1814 # 80020b98 <ftable+0x18>
    800042b6:	0001e717          	auipc	a4,0x1e
    800042ba:	88270713          	addi	a4,a4,-1918 # 80021b38 <disk>
    if(f->ref == 0){
    800042be:	40dc                	lw	a5,4(s1)
    800042c0:	cf89                	beqz	a5,800042da <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800042c2:	02848493          	addi	s1,s1,40
    800042c6:	fee49ce3          	bne	s1,a4,800042be <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800042ca:	0001d517          	auipc	a0,0x1d
    800042ce:	8b650513          	addi	a0,a0,-1866 # 80020b80 <ftable>
    800042d2:	9c7fc0ef          	jal	80000c98 <release>
  return 0;
    800042d6:	4481                	li	s1,0
    800042d8:	a809                	j	800042ea <filealloc+0x52>
      f->ref = 1;
    800042da:	4785                	li	a5,1
    800042dc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800042de:	0001d517          	auipc	a0,0x1d
    800042e2:	8a250513          	addi	a0,a0,-1886 # 80020b80 <ftable>
    800042e6:	9b3fc0ef          	jal	80000c98 <release>
}
    800042ea:	8526                	mv	a0,s1
    800042ec:	60e2                	ld	ra,24(sp)
    800042ee:	6442                	ld	s0,16(sp)
    800042f0:	64a2                	ld	s1,8(sp)
    800042f2:	6105                	addi	sp,sp,32
    800042f4:	8082                	ret

00000000800042f6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800042f6:	1101                	addi	sp,sp,-32
    800042f8:	ec06                	sd	ra,24(sp)
    800042fa:	e822                	sd	s0,16(sp)
    800042fc:	e426                	sd	s1,8(sp)
    800042fe:	1000                	addi	s0,sp,32
    80004300:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004302:	0001d517          	auipc	a0,0x1d
    80004306:	87e50513          	addi	a0,a0,-1922 # 80020b80 <ftable>
    8000430a:	8f7fc0ef          	jal	80000c00 <acquire>
  if(f->ref < 1)
    8000430e:	40dc                	lw	a5,4(s1)
    80004310:	02f05063          	blez	a5,80004330 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004314:	2785                	addiw	a5,a5,1
    80004316:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004318:	0001d517          	auipc	a0,0x1d
    8000431c:	86850513          	addi	a0,a0,-1944 # 80020b80 <ftable>
    80004320:	979fc0ef          	jal	80000c98 <release>
  return f;
}
    80004324:	8526                	mv	a0,s1
    80004326:	60e2                	ld	ra,24(sp)
    80004328:	6442                	ld	s0,16(sp)
    8000432a:	64a2                	ld	s1,8(sp)
    8000432c:	6105                	addi	sp,sp,32
    8000432e:	8082                	ret
    panic("filedup");
    80004330:	00004517          	auipc	a0,0x4
    80004334:	23850513          	addi	a0,a0,568 # 80008568 <etext+0x568>
    80004338:	cdafc0ef          	jal	80000812 <panic>

000000008000433c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000433c:	7139                	addi	sp,sp,-64
    8000433e:	fc06                	sd	ra,56(sp)
    80004340:	f822                	sd	s0,48(sp)
    80004342:	f426                	sd	s1,40(sp)
    80004344:	0080                	addi	s0,sp,64
    80004346:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004348:	0001d517          	auipc	a0,0x1d
    8000434c:	83850513          	addi	a0,a0,-1992 # 80020b80 <ftable>
    80004350:	8b1fc0ef          	jal	80000c00 <acquire>
  if(f->ref < 1)
    80004354:	40dc                	lw	a5,4(s1)
    80004356:	04f05a63          	blez	a5,800043aa <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000435a:	37fd                	addiw	a5,a5,-1
    8000435c:	0007871b          	sext.w	a4,a5
    80004360:	c0dc                	sw	a5,4(s1)
    80004362:	04e04e63          	bgtz	a4,800043be <fileclose+0x82>
    80004366:	f04a                	sd	s2,32(sp)
    80004368:	ec4e                	sd	s3,24(sp)
    8000436a:	e852                	sd	s4,16(sp)
    8000436c:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000436e:	0004a903          	lw	s2,0(s1)
    80004372:	0094ca83          	lbu	s5,9(s1)
    80004376:	0104ba03          	ld	s4,16(s1)
    8000437a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000437e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004382:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004386:	0001c517          	auipc	a0,0x1c
    8000438a:	7fa50513          	addi	a0,a0,2042 # 80020b80 <ftable>
    8000438e:	90bfc0ef          	jal	80000c98 <release>

  if(ff.type == FD_PIPE){
    80004392:	4785                	li	a5,1
    80004394:	04f90063          	beq	s2,a5,800043d4 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004398:	3979                	addiw	s2,s2,-2
    8000439a:	4785                	li	a5,1
    8000439c:	0527f563          	bgeu	a5,s2,800043e6 <fileclose+0xaa>
    800043a0:	7902                	ld	s2,32(sp)
    800043a2:	69e2                	ld	s3,24(sp)
    800043a4:	6a42                	ld	s4,16(sp)
    800043a6:	6aa2                	ld	s5,8(sp)
    800043a8:	a00d                	j	800043ca <fileclose+0x8e>
    800043aa:	f04a                	sd	s2,32(sp)
    800043ac:	ec4e                	sd	s3,24(sp)
    800043ae:	e852                	sd	s4,16(sp)
    800043b0:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800043b2:	00004517          	auipc	a0,0x4
    800043b6:	1be50513          	addi	a0,a0,446 # 80008570 <etext+0x570>
    800043ba:	c58fc0ef          	jal	80000812 <panic>
    release(&ftable.lock);
    800043be:	0001c517          	auipc	a0,0x1c
    800043c2:	7c250513          	addi	a0,a0,1986 # 80020b80 <ftable>
    800043c6:	8d3fc0ef          	jal	80000c98 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800043ca:	70e2                	ld	ra,56(sp)
    800043cc:	7442                	ld	s0,48(sp)
    800043ce:	74a2                	ld	s1,40(sp)
    800043d0:	6121                	addi	sp,sp,64
    800043d2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800043d4:	85d6                	mv	a1,s5
    800043d6:	8552                	mv	a0,s4
    800043d8:	336000ef          	jal	8000470e <pipeclose>
    800043dc:	7902                	ld	s2,32(sp)
    800043de:	69e2                	ld	s3,24(sp)
    800043e0:	6a42                	ld	s4,16(sp)
    800043e2:	6aa2                	ld	s5,8(sp)
    800043e4:	b7dd                	j	800043ca <fileclose+0x8e>
    begin_op();
    800043e6:	af1ff0ef          	jal	80003ed6 <begin_op>
    iput(ff.ip);
    800043ea:	854e                	mv	a0,s3
    800043ec:	a6cff0ef          	jal	80003658 <iput>
    end_op();
    800043f0:	b5dff0ef          	jal	80003f4c <end_op>
    800043f4:	7902                	ld	s2,32(sp)
    800043f6:	69e2                	ld	s3,24(sp)
    800043f8:	6a42                	ld	s4,16(sp)
    800043fa:	6aa2                	ld	s5,8(sp)
    800043fc:	b7f9                	j	800043ca <fileclose+0x8e>

00000000800043fe <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800043fe:	715d                	addi	sp,sp,-80
    80004400:	e486                	sd	ra,72(sp)
    80004402:	e0a2                	sd	s0,64(sp)
    80004404:	fc26                	sd	s1,56(sp)
    80004406:	f44e                	sd	s3,40(sp)
    80004408:	0880                	addi	s0,sp,80
    8000440a:	84aa                	mv	s1,a0
    8000440c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000440e:	cfafd0ef          	jal	80001908 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004412:	409c                	lw	a5,0(s1)
    80004414:	37f9                	addiw	a5,a5,-2
    80004416:	4705                	li	a4,1
    80004418:	04f76063          	bltu	a4,a5,80004458 <filestat+0x5a>
    8000441c:	f84a                	sd	s2,48(sp)
    8000441e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004420:	6c88                	ld	a0,24(s1)
    80004422:	8a4ff0ef          	jal	800034c6 <ilock>
    stati(f->ip, &st);
    80004426:	fb840593          	addi	a1,s0,-72
    8000442a:	6c88                	ld	a0,24(s1)
    8000442c:	c16ff0ef          	jal	80003842 <stati>
    iunlock(f->ip);
    80004430:	6c88                	ld	a0,24(s1)
    80004432:	94aff0ef          	jal	8000357c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004436:	46e1                	li	a3,24
    80004438:	fb840613          	addi	a2,s0,-72
    8000443c:	85ce                	mv	a1,s3
    8000443e:	05093503          	ld	a0,80(s2)
    80004442:	9dafd0ef          	jal	8000161c <copyout>
    80004446:	41f5551b          	sraiw	a0,a0,0x1f
    8000444a:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000444c:	60a6                	ld	ra,72(sp)
    8000444e:	6406                	ld	s0,64(sp)
    80004450:	74e2                	ld	s1,56(sp)
    80004452:	79a2                	ld	s3,40(sp)
    80004454:	6161                	addi	sp,sp,80
    80004456:	8082                	ret
  return -1;
    80004458:	557d                	li	a0,-1
    8000445a:	bfcd                	j	8000444c <filestat+0x4e>

000000008000445c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000445c:	7179                	addi	sp,sp,-48
    8000445e:	f406                	sd	ra,40(sp)
    80004460:	f022                	sd	s0,32(sp)
    80004462:	e84a                	sd	s2,16(sp)
    80004464:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004466:	00854783          	lbu	a5,8(a0)
    8000446a:	cfd1                	beqz	a5,80004506 <fileread+0xaa>
    8000446c:	ec26                	sd	s1,24(sp)
    8000446e:	e44e                	sd	s3,8(sp)
    80004470:	84aa                	mv	s1,a0
    80004472:	89ae                	mv	s3,a1
    80004474:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004476:	411c                	lw	a5,0(a0)
    80004478:	4705                	li	a4,1
    8000447a:	04e78363          	beq	a5,a4,800044c0 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000447e:	470d                	li	a4,3
    80004480:	04e78763          	beq	a5,a4,800044ce <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004484:	4709                	li	a4,2
    80004486:	06e79a63          	bne	a5,a4,800044fa <fileread+0x9e>
    ilock(f->ip);
    8000448a:	6d08                	ld	a0,24(a0)
    8000448c:	83aff0ef          	jal	800034c6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004490:	874a                	mv	a4,s2
    80004492:	5094                	lw	a3,32(s1)
    80004494:	864e                	mv	a2,s3
    80004496:	4585                	li	a1,1
    80004498:	6c88                	ld	a0,24(s1)
    8000449a:	bd2ff0ef          	jal	8000386c <readi>
    8000449e:	892a                	mv	s2,a0
    800044a0:	00a05563          	blez	a0,800044aa <fileread+0x4e>
      f->off += r;
    800044a4:	509c                	lw	a5,32(s1)
    800044a6:	9fa9                	addw	a5,a5,a0
    800044a8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800044aa:	6c88                	ld	a0,24(s1)
    800044ac:	8d0ff0ef          	jal	8000357c <iunlock>
    800044b0:	64e2                	ld	s1,24(sp)
    800044b2:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800044b4:	854a                	mv	a0,s2
    800044b6:	70a2                	ld	ra,40(sp)
    800044b8:	7402                	ld	s0,32(sp)
    800044ba:	6942                	ld	s2,16(sp)
    800044bc:	6145                	addi	sp,sp,48
    800044be:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800044c0:	6908                	ld	a0,16(a0)
    800044c2:	388000ef          	jal	8000484a <piperead>
    800044c6:	892a                	mv	s2,a0
    800044c8:	64e2                	ld	s1,24(sp)
    800044ca:	69a2                	ld	s3,8(sp)
    800044cc:	b7e5                	j	800044b4 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800044ce:	02451783          	lh	a5,36(a0)
    800044d2:	03079693          	slli	a3,a5,0x30
    800044d6:	92c1                	srli	a3,a3,0x30
    800044d8:	4725                	li	a4,9
    800044da:	02d76863          	bltu	a4,a3,8000450a <fileread+0xae>
    800044de:	0792                	slli	a5,a5,0x4
    800044e0:	0001c717          	auipc	a4,0x1c
    800044e4:	60070713          	addi	a4,a4,1536 # 80020ae0 <devsw>
    800044e8:	97ba                	add	a5,a5,a4
    800044ea:	639c                	ld	a5,0(a5)
    800044ec:	c39d                	beqz	a5,80004512 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800044ee:	4505                	li	a0,1
    800044f0:	9782                	jalr	a5
    800044f2:	892a                	mv	s2,a0
    800044f4:	64e2                	ld	s1,24(sp)
    800044f6:	69a2                	ld	s3,8(sp)
    800044f8:	bf75                	j	800044b4 <fileread+0x58>
    panic("fileread");
    800044fa:	00004517          	auipc	a0,0x4
    800044fe:	08650513          	addi	a0,a0,134 # 80008580 <etext+0x580>
    80004502:	b10fc0ef          	jal	80000812 <panic>
    return -1;
    80004506:	597d                	li	s2,-1
    80004508:	b775                	j	800044b4 <fileread+0x58>
      return -1;
    8000450a:	597d                	li	s2,-1
    8000450c:	64e2                	ld	s1,24(sp)
    8000450e:	69a2                	ld	s3,8(sp)
    80004510:	b755                	j	800044b4 <fileread+0x58>
    80004512:	597d                	li	s2,-1
    80004514:	64e2                	ld	s1,24(sp)
    80004516:	69a2                	ld	s3,8(sp)
    80004518:	bf71                	j	800044b4 <fileread+0x58>

000000008000451a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000451a:	00954783          	lbu	a5,9(a0)
    8000451e:	10078b63          	beqz	a5,80004634 <filewrite+0x11a>
{
    80004522:	715d                	addi	sp,sp,-80
    80004524:	e486                	sd	ra,72(sp)
    80004526:	e0a2                	sd	s0,64(sp)
    80004528:	f84a                	sd	s2,48(sp)
    8000452a:	f052                	sd	s4,32(sp)
    8000452c:	e85a                	sd	s6,16(sp)
    8000452e:	0880                	addi	s0,sp,80
    80004530:	892a                	mv	s2,a0
    80004532:	8b2e                	mv	s6,a1
    80004534:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004536:	411c                	lw	a5,0(a0)
    80004538:	4705                	li	a4,1
    8000453a:	02e78763          	beq	a5,a4,80004568 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000453e:	470d                	li	a4,3
    80004540:	02e78863          	beq	a5,a4,80004570 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004544:	4709                	li	a4,2
    80004546:	0ce79c63          	bne	a5,a4,8000461e <filewrite+0x104>
    8000454a:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000454c:	0ac05863          	blez	a2,800045fc <filewrite+0xe2>
    80004550:	fc26                	sd	s1,56(sp)
    80004552:	ec56                	sd	s5,24(sp)
    80004554:	e45e                	sd	s7,8(sp)
    80004556:	e062                	sd	s8,0(sp)
    int i = 0;
    80004558:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000455a:	6b85                	lui	s7,0x1
    8000455c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004560:	6c05                	lui	s8,0x1
    80004562:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004566:	a8b5                	j	800045e2 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004568:	6908                	ld	a0,16(a0)
    8000456a:	1fc000ef          	jal	80004766 <pipewrite>
    8000456e:	a04d                	j	80004610 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004570:	02451783          	lh	a5,36(a0)
    80004574:	03079693          	slli	a3,a5,0x30
    80004578:	92c1                	srli	a3,a3,0x30
    8000457a:	4725                	li	a4,9
    8000457c:	0ad76e63          	bltu	a4,a3,80004638 <filewrite+0x11e>
    80004580:	0792                	slli	a5,a5,0x4
    80004582:	0001c717          	auipc	a4,0x1c
    80004586:	55e70713          	addi	a4,a4,1374 # 80020ae0 <devsw>
    8000458a:	97ba                	add	a5,a5,a4
    8000458c:	679c                	ld	a5,8(a5)
    8000458e:	c7dd                	beqz	a5,8000463c <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004590:	4505                	li	a0,1
    80004592:	9782                	jalr	a5
    80004594:	a8b5                	j	80004610 <filewrite+0xf6>
      if(n1 > max)
    80004596:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000459a:	93dff0ef          	jal	80003ed6 <begin_op>
      ilock(f->ip);
    8000459e:	01893503          	ld	a0,24(s2)
    800045a2:	f25fe0ef          	jal	800034c6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800045a6:	8756                	mv	a4,s5
    800045a8:	02092683          	lw	a3,32(s2)
    800045ac:	01698633          	add	a2,s3,s6
    800045b0:	4585                	li	a1,1
    800045b2:	01893503          	ld	a0,24(s2)
    800045b6:	bb2ff0ef          	jal	80003968 <writei>
    800045ba:	84aa                	mv	s1,a0
    800045bc:	00a05763          	blez	a0,800045ca <filewrite+0xb0>
        f->off += r;
    800045c0:	02092783          	lw	a5,32(s2)
    800045c4:	9fa9                	addw	a5,a5,a0
    800045c6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800045ca:	01893503          	ld	a0,24(s2)
    800045ce:	faffe0ef          	jal	8000357c <iunlock>
      end_op();
    800045d2:	97bff0ef          	jal	80003f4c <end_op>

      if(r != n1){
    800045d6:	029a9563          	bne	s5,s1,80004600 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800045da:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800045de:	0149da63          	bge	s3,s4,800045f2 <filewrite+0xd8>
      int n1 = n - i;
    800045e2:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800045e6:	0004879b          	sext.w	a5,s1
    800045ea:	fafbd6e3          	bge	s7,a5,80004596 <filewrite+0x7c>
    800045ee:	84e2                	mv	s1,s8
    800045f0:	b75d                	j	80004596 <filewrite+0x7c>
    800045f2:	74e2                	ld	s1,56(sp)
    800045f4:	6ae2                	ld	s5,24(sp)
    800045f6:	6ba2                	ld	s7,8(sp)
    800045f8:	6c02                	ld	s8,0(sp)
    800045fa:	a039                	j	80004608 <filewrite+0xee>
    int i = 0;
    800045fc:	4981                	li	s3,0
    800045fe:	a029                	j	80004608 <filewrite+0xee>
    80004600:	74e2                	ld	s1,56(sp)
    80004602:	6ae2                	ld	s5,24(sp)
    80004604:	6ba2                	ld	s7,8(sp)
    80004606:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004608:	033a1c63          	bne	s4,s3,80004640 <filewrite+0x126>
    8000460c:	8552                	mv	a0,s4
    8000460e:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004610:	60a6                	ld	ra,72(sp)
    80004612:	6406                	ld	s0,64(sp)
    80004614:	7942                	ld	s2,48(sp)
    80004616:	7a02                	ld	s4,32(sp)
    80004618:	6b42                	ld	s6,16(sp)
    8000461a:	6161                	addi	sp,sp,80
    8000461c:	8082                	ret
    8000461e:	fc26                	sd	s1,56(sp)
    80004620:	f44e                	sd	s3,40(sp)
    80004622:	ec56                	sd	s5,24(sp)
    80004624:	e45e                	sd	s7,8(sp)
    80004626:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004628:	00004517          	auipc	a0,0x4
    8000462c:	f6850513          	addi	a0,a0,-152 # 80008590 <etext+0x590>
    80004630:	9e2fc0ef          	jal	80000812 <panic>
    return -1;
    80004634:	557d                	li	a0,-1
}
    80004636:	8082                	ret
      return -1;
    80004638:	557d                	li	a0,-1
    8000463a:	bfd9                	j	80004610 <filewrite+0xf6>
    8000463c:	557d                	li	a0,-1
    8000463e:	bfc9                	j	80004610 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004640:	557d                	li	a0,-1
    80004642:	79a2                	ld	s3,40(sp)
    80004644:	b7f1                	j	80004610 <filewrite+0xf6>

0000000080004646 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004646:	7179                	addi	sp,sp,-48
    80004648:	f406                	sd	ra,40(sp)
    8000464a:	f022                	sd	s0,32(sp)
    8000464c:	ec26                	sd	s1,24(sp)
    8000464e:	e052                	sd	s4,0(sp)
    80004650:	1800                	addi	s0,sp,48
    80004652:	84aa                	mv	s1,a0
    80004654:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004656:	0005b023          	sd	zero,0(a1)
    8000465a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000465e:	c3bff0ef          	jal	80004298 <filealloc>
    80004662:	e088                	sd	a0,0(s1)
    80004664:	c549                	beqz	a0,800046ee <pipealloc+0xa8>
    80004666:	c33ff0ef          	jal	80004298 <filealloc>
    8000466a:	00aa3023          	sd	a0,0(s4)
    8000466e:	cd25                	beqz	a0,800046e6 <pipealloc+0xa0>
    80004670:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004672:	cbefc0ef          	jal	80000b30 <kalloc>
    80004676:	892a                	mv	s2,a0
    80004678:	c12d                	beqz	a0,800046da <pipealloc+0x94>
    8000467a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000467c:	4985                	li	s3,1
    8000467e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004682:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004686:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000468a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000468e:	00004597          	auipc	a1,0x4
    80004692:	f1258593          	addi	a1,a1,-238 # 800085a0 <etext+0x5a0>
    80004696:	ceafc0ef          	jal	80000b80 <initlock>
  (*f0)->type = FD_PIPE;
    8000469a:	609c                	ld	a5,0(s1)
    8000469c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800046a0:	609c                	ld	a5,0(s1)
    800046a2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800046a6:	609c                	ld	a5,0(s1)
    800046a8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800046ac:	609c                	ld	a5,0(s1)
    800046ae:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800046b2:	000a3783          	ld	a5,0(s4)
    800046b6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800046ba:	000a3783          	ld	a5,0(s4)
    800046be:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800046c2:	000a3783          	ld	a5,0(s4)
    800046c6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800046ca:	000a3783          	ld	a5,0(s4)
    800046ce:	0127b823          	sd	s2,16(a5)
  return 0;
    800046d2:	4501                	li	a0,0
    800046d4:	6942                	ld	s2,16(sp)
    800046d6:	69a2                	ld	s3,8(sp)
    800046d8:	a01d                	j	800046fe <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800046da:	6088                	ld	a0,0(s1)
    800046dc:	c119                	beqz	a0,800046e2 <pipealloc+0x9c>
    800046de:	6942                	ld	s2,16(sp)
    800046e0:	a029                	j	800046ea <pipealloc+0xa4>
    800046e2:	6942                	ld	s2,16(sp)
    800046e4:	a029                	j	800046ee <pipealloc+0xa8>
    800046e6:	6088                	ld	a0,0(s1)
    800046e8:	c10d                	beqz	a0,8000470a <pipealloc+0xc4>
    fileclose(*f0);
    800046ea:	c53ff0ef          	jal	8000433c <fileclose>
  if(*f1)
    800046ee:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800046f2:	557d                	li	a0,-1
  if(*f1)
    800046f4:	c789                	beqz	a5,800046fe <pipealloc+0xb8>
    fileclose(*f1);
    800046f6:	853e                	mv	a0,a5
    800046f8:	c45ff0ef          	jal	8000433c <fileclose>
  return -1;
    800046fc:	557d                	li	a0,-1
}
    800046fe:	70a2                	ld	ra,40(sp)
    80004700:	7402                	ld	s0,32(sp)
    80004702:	64e2                	ld	s1,24(sp)
    80004704:	6a02                	ld	s4,0(sp)
    80004706:	6145                	addi	sp,sp,48
    80004708:	8082                	ret
  return -1;
    8000470a:	557d                	li	a0,-1
    8000470c:	bfcd                	j	800046fe <pipealloc+0xb8>

000000008000470e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000470e:	1101                	addi	sp,sp,-32
    80004710:	ec06                	sd	ra,24(sp)
    80004712:	e822                	sd	s0,16(sp)
    80004714:	e426                	sd	s1,8(sp)
    80004716:	e04a                	sd	s2,0(sp)
    80004718:	1000                	addi	s0,sp,32
    8000471a:	84aa                	mv	s1,a0
    8000471c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000471e:	ce2fc0ef          	jal	80000c00 <acquire>
  if(writable){
    80004722:	02090763          	beqz	s2,80004750 <pipeclose+0x42>
    pi->writeopen = 0;
    80004726:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000472a:	21848513          	addi	a0,s1,536
    8000472e:	837fd0ef          	jal	80001f64 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004732:	2204b783          	ld	a5,544(s1)
    80004736:	e785                	bnez	a5,8000475e <pipeclose+0x50>
    release(&pi->lock);
    80004738:	8526                	mv	a0,s1
    8000473a:	d5efc0ef          	jal	80000c98 <release>
    kfree((char*)pi);
    8000473e:	8526                	mv	a0,s1
    80004740:	b0efc0ef          	jal	80000a4e <kfree>
  } else
    release(&pi->lock);
}
    80004744:	60e2                	ld	ra,24(sp)
    80004746:	6442                	ld	s0,16(sp)
    80004748:	64a2                	ld	s1,8(sp)
    8000474a:	6902                	ld	s2,0(sp)
    8000474c:	6105                	addi	sp,sp,32
    8000474e:	8082                	ret
    pi->readopen = 0;
    80004750:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004754:	21c48513          	addi	a0,s1,540
    80004758:	80dfd0ef          	jal	80001f64 <wakeup>
    8000475c:	bfd9                	j	80004732 <pipeclose+0x24>
    release(&pi->lock);
    8000475e:	8526                	mv	a0,s1
    80004760:	d38fc0ef          	jal	80000c98 <release>
}
    80004764:	b7c5                	j	80004744 <pipeclose+0x36>

0000000080004766 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004766:	711d                	addi	sp,sp,-96
    80004768:	ec86                	sd	ra,88(sp)
    8000476a:	e8a2                	sd	s0,80(sp)
    8000476c:	e4a6                	sd	s1,72(sp)
    8000476e:	e0ca                	sd	s2,64(sp)
    80004770:	fc4e                	sd	s3,56(sp)
    80004772:	f852                	sd	s4,48(sp)
    80004774:	f456                	sd	s5,40(sp)
    80004776:	1080                	addi	s0,sp,96
    80004778:	84aa                	mv	s1,a0
    8000477a:	8aae                	mv	s5,a1
    8000477c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000477e:	98afd0ef          	jal	80001908 <myproc>
    80004782:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004784:	8526                	mv	a0,s1
    80004786:	c7afc0ef          	jal	80000c00 <acquire>
  while(i < n){
    8000478a:	0b405a63          	blez	s4,8000483e <pipewrite+0xd8>
    8000478e:	f05a                	sd	s6,32(sp)
    80004790:	ec5e                	sd	s7,24(sp)
    80004792:	e862                	sd	s8,16(sp)
  int i = 0;
    80004794:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004796:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004798:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000479c:	21c48b93          	addi	s7,s1,540
    800047a0:	a81d                	j	800047d6 <pipewrite+0x70>
      release(&pi->lock);
    800047a2:	8526                	mv	a0,s1
    800047a4:	cf4fc0ef          	jal	80000c98 <release>
      return -1;
    800047a8:	597d                	li	s2,-1
    800047aa:	7b02                	ld	s6,32(sp)
    800047ac:	6be2                	ld	s7,24(sp)
    800047ae:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800047b0:	854a                	mv	a0,s2
    800047b2:	60e6                	ld	ra,88(sp)
    800047b4:	6446                	ld	s0,80(sp)
    800047b6:	64a6                	ld	s1,72(sp)
    800047b8:	6906                	ld	s2,64(sp)
    800047ba:	79e2                	ld	s3,56(sp)
    800047bc:	7a42                	ld	s4,48(sp)
    800047be:	7aa2                	ld	s5,40(sp)
    800047c0:	6125                	addi	sp,sp,96
    800047c2:	8082                	ret
      wakeup(&pi->nread);
    800047c4:	8562                	mv	a0,s8
    800047c6:	f9efd0ef          	jal	80001f64 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800047ca:	85a6                	mv	a1,s1
    800047cc:	855e                	mv	a0,s7
    800047ce:	f4afd0ef          	jal	80001f18 <sleep>
  while(i < n){
    800047d2:	05495b63          	bge	s2,s4,80004828 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800047d6:	2204a783          	lw	a5,544(s1)
    800047da:	d7e1                	beqz	a5,800047a2 <pipewrite+0x3c>
    800047dc:	854e                	mv	a0,s3
    800047de:	973fd0ef          	jal	80002150 <killed>
    800047e2:	f161                	bnez	a0,800047a2 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800047e4:	2184a783          	lw	a5,536(s1)
    800047e8:	21c4a703          	lw	a4,540(s1)
    800047ec:	2007879b          	addiw	a5,a5,512
    800047f0:	fcf70ae3          	beq	a4,a5,800047c4 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800047f4:	4685                	li	a3,1
    800047f6:	01590633          	add	a2,s2,s5
    800047fa:	faf40593          	addi	a1,s0,-81
    800047fe:	0509b503          	ld	a0,80(s3)
    80004802:	efffc0ef          	jal	80001700 <copyin>
    80004806:	03650e63          	beq	a0,s6,80004842 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000480a:	21c4a783          	lw	a5,540(s1)
    8000480e:	0017871b          	addiw	a4,a5,1
    80004812:	20e4ae23          	sw	a4,540(s1)
    80004816:	1ff7f793          	andi	a5,a5,511
    8000481a:	97a6                	add	a5,a5,s1
    8000481c:	faf44703          	lbu	a4,-81(s0)
    80004820:	00e78c23          	sb	a4,24(a5)
      i++;
    80004824:	2905                	addiw	s2,s2,1
    80004826:	b775                	j	800047d2 <pipewrite+0x6c>
    80004828:	7b02                	ld	s6,32(sp)
    8000482a:	6be2                	ld	s7,24(sp)
    8000482c:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000482e:	21848513          	addi	a0,s1,536
    80004832:	f32fd0ef          	jal	80001f64 <wakeup>
  release(&pi->lock);
    80004836:	8526                	mv	a0,s1
    80004838:	c60fc0ef          	jal	80000c98 <release>
  return i;
    8000483c:	bf95                	j	800047b0 <pipewrite+0x4a>
  int i = 0;
    8000483e:	4901                	li	s2,0
    80004840:	b7fd                	j	8000482e <pipewrite+0xc8>
    80004842:	7b02                	ld	s6,32(sp)
    80004844:	6be2                	ld	s7,24(sp)
    80004846:	6c42                	ld	s8,16(sp)
    80004848:	b7dd                	j	8000482e <pipewrite+0xc8>

000000008000484a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000484a:	715d                	addi	sp,sp,-80
    8000484c:	e486                	sd	ra,72(sp)
    8000484e:	e0a2                	sd	s0,64(sp)
    80004850:	fc26                	sd	s1,56(sp)
    80004852:	f84a                	sd	s2,48(sp)
    80004854:	f44e                	sd	s3,40(sp)
    80004856:	f052                	sd	s4,32(sp)
    80004858:	ec56                	sd	s5,24(sp)
    8000485a:	0880                	addi	s0,sp,80
    8000485c:	84aa                	mv	s1,a0
    8000485e:	892e                	mv	s2,a1
    80004860:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004862:	8a6fd0ef          	jal	80001908 <myproc>
    80004866:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004868:	8526                	mv	a0,s1
    8000486a:	b96fc0ef          	jal	80000c00 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000486e:	2184a703          	lw	a4,536(s1)
    80004872:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004876:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000487a:	02f71563          	bne	a4,a5,800048a4 <piperead+0x5a>
    8000487e:	2244a783          	lw	a5,548(s1)
    80004882:	cb85                	beqz	a5,800048b2 <piperead+0x68>
    if(killed(pr)){
    80004884:	8552                	mv	a0,s4
    80004886:	8cbfd0ef          	jal	80002150 <killed>
    8000488a:	ed19                	bnez	a0,800048a8 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000488c:	85a6                	mv	a1,s1
    8000488e:	854e                	mv	a0,s3
    80004890:	e88fd0ef          	jal	80001f18 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004894:	2184a703          	lw	a4,536(s1)
    80004898:	21c4a783          	lw	a5,540(s1)
    8000489c:	fef701e3          	beq	a4,a5,8000487e <piperead+0x34>
    800048a0:	e85a                	sd	s6,16(sp)
    800048a2:	a809                	j	800048b4 <piperead+0x6a>
    800048a4:	e85a                	sd	s6,16(sp)
    800048a6:	a039                	j	800048b4 <piperead+0x6a>
      release(&pi->lock);
    800048a8:	8526                	mv	a0,s1
    800048aa:	beefc0ef          	jal	80000c98 <release>
      return -1;
    800048ae:	59fd                	li	s3,-1
    800048b0:	a8b9                	j	8000490e <piperead+0xc4>
    800048b2:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048b4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800048b6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048b8:	05505363          	blez	s5,800048fe <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    800048bc:	2184a783          	lw	a5,536(s1)
    800048c0:	21c4a703          	lw	a4,540(s1)
    800048c4:	02f70d63          	beq	a4,a5,800048fe <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    800048c8:	1ff7f793          	andi	a5,a5,511
    800048cc:	97a6                	add	a5,a5,s1
    800048ce:	0187c783          	lbu	a5,24(a5)
    800048d2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800048d6:	4685                	li	a3,1
    800048d8:	fbf40613          	addi	a2,s0,-65
    800048dc:	85ca                	mv	a1,s2
    800048de:	050a3503          	ld	a0,80(s4)
    800048e2:	d3bfc0ef          	jal	8000161c <copyout>
    800048e6:	03650e63          	beq	a0,s6,80004922 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800048ea:	2184a783          	lw	a5,536(s1)
    800048ee:	2785                	addiw	a5,a5,1
    800048f0:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048f4:	2985                	addiw	s3,s3,1
    800048f6:	0905                	addi	s2,s2,1
    800048f8:	fd3a92e3          	bne	s5,s3,800048bc <piperead+0x72>
    800048fc:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800048fe:	21c48513          	addi	a0,s1,540
    80004902:	e62fd0ef          	jal	80001f64 <wakeup>
  release(&pi->lock);
    80004906:	8526                	mv	a0,s1
    80004908:	b90fc0ef          	jal	80000c98 <release>
    8000490c:	6b42                	ld	s6,16(sp)
  return i;
}
    8000490e:	854e                	mv	a0,s3
    80004910:	60a6                	ld	ra,72(sp)
    80004912:	6406                	ld	s0,64(sp)
    80004914:	74e2                	ld	s1,56(sp)
    80004916:	7942                	ld	s2,48(sp)
    80004918:	79a2                	ld	s3,40(sp)
    8000491a:	7a02                	ld	s4,32(sp)
    8000491c:	6ae2                	ld	s5,24(sp)
    8000491e:	6161                	addi	sp,sp,80
    80004920:	8082                	ret
      if(i == 0)
    80004922:	fc099ee3          	bnez	s3,800048fe <piperead+0xb4>
        i = -1;
    80004926:	89aa                	mv	s3,a0
    80004928:	bfd9                	j	800048fe <piperead+0xb4>

000000008000492a <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    8000492a:	1141                	addi	sp,sp,-16
    8000492c:	e422                	sd	s0,8(sp)
    8000492e:	0800                	addi	s0,sp,16
    80004930:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004932:	8905                	andi	a0,a0,1
    80004934:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004936:	8b89                	andi	a5,a5,2
    80004938:	c399                	beqz	a5,8000493e <flags2perm+0x14>
      perm |= PTE_W;
    8000493a:	00456513          	ori	a0,a0,4
    return perm;
}
    8000493e:	6422                	ld	s0,8(sp)
    80004940:	0141                	addi	sp,sp,16
    80004942:	8082                	ret

0000000080004944 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004944:	df010113          	addi	sp,sp,-528
    80004948:	20113423          	sd	ra,520(sp)
    8000494c:	20813023          	sd	s0,512(sp)
    80004950:	ffa6                	sd	s1,504(sp)
    80004952:	fbca                	sd	s2,496(sp)
    80004954:	0c00                	addi	s0,sp,528
    80004956:	892a                	mv	s2,a0
    80004958:	dea43c23          	sd	a0,-520(s0)
    8000495c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004960:	fa9fc0ef          	jal	80001908 <myproc>
    80004964:	84aa                	mv	s1,a0

  begin_op();
    80004966:	d70ff0ef          	jal	80003ed6 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000496a:	854a                	mv	a0,s2
    8000496c:	b86ff0ef          	jal	80003cf2 <namei>
    80004970:	c931                	beqz	a0,800049c4 <kexec+0x80>
    80004972:	f3d2                	sd	s4,480(sp)
    80004974:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004976:	b51fe0ef          	jal	800034c6 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000497a:	04000713          	li	a4,64
    8000497e:	4681                	li	a3,0
    80004980:	e5040613          	addi	a2,s0,-432
    80004984:	4581                	li	a1,0
    80004986:	8552                	mv	a0,s4
    80004988:	ee5fe0ef          	jal	8000386c <readi>
    8000498c:	04000793          	li	a5,64
    80004990:	00f51a63          	bne	a0,a5,800049a4 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004994:	e5042703          	lw	a4,-432(s0)
    80004998:	464c47b7          	lui	a5,0x464c4
    8000499c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800049a0:	02f70663          	beq	a4,a5,800049cc <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800049a4:	8552                	mv	a0,s4
    800049a6:	d41fe0ef          	jal	800036e6 <iunlockput>
    end_op();
    800049aa:	da2ff0ef          	jal	80003f4c <end_op>
  }
  return -1;
    800049ae:	557d                	li	a0,-1
    800049b0:	7a1e                	ld	s4,480(sp)
}
    800049b2:	20813083          	ld	ra,520(sp)
    800049b6:	20013403          	ld	s0,512(sp)
    800049ba:	74fe                	ld	s1,504(sp)
    800049bc:	795e                	ld	s2,496(sp)
    800049be:	21010113          	addi	sp,sp,528
    800049c2:	8082                	ret
    end_op();
    800049c4:	d88ff0ef          	jal	80003f4c <end_op>
    return -1;
    800049c8:	557d                	li	a0,-1
    800049ca:	b7e5                	j	800049b2 <kexec+0x6e>
    800049cc:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800049ce:	8526                	mv	a0,s1
    800049d0:	83efd0ef          	jal	80001a0e <proc_pagetable>
    800049d4:	8b2a                	mv	s6,a0
    800049d6:	2c050b63          	beqz	a0,80004cac <kexec+0x368>
    800049da:	f7ce                	sd	s3,488(sp)
    800049dc:	efd6                	sd	s5,472(sp)
    800049de:	e7de                	sd	s7,456(sp)
    800049e0:	e3e2                	sd	s8,448(sp)
    800049e2:	ff66                	sd	s9,440(sp)
    800049e4:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049e6:	e7042d03          	lw	s10,-400(s0)
    800049ea:	e8845783          	lhu	a5,-376(s0)
    800049ee:	12078963          	beqz	a5,80004b20 <kexec+0x1dc>
    800049f2:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049f4:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049f6:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800049f8:	6c85                	lui	s9,0x1
    800049fa:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800049fe:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004a02:	6a85                	lui	s5,0x1
    80004a04:	a085                	j	80004a64 <kexec+0x120>
      panic("loadseg: address should exist");
    80004a06:	00004517          	auipc	a0,0x4
    80004a0a:	ba250513          	addi	a0,a0,-1118 # 800085a8 <etext+0x5a8>
    80004a0e:	e05fb0ef          	jal	80000812 <panic>
    if(sz - i < PGSIZE)
    80004a12:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004a14:	8726                	mv	a4,s1
    80004a16:	012c06bb          	addw	a3,s8,s2
    80004a1a:	4581                	li	a1,0
    80004a1c:	8552                	mv	a0,s4
    80004a1e:	e4ffe0ef          	jal	8000386c <readi>
    80004a22:	2501                	sext.w	a0,a0
    80004a24:	24a49a63          	bne	s1,a0,80004c78 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004a28:	012a893b          	addw	s2,s5,s2
    80004a2c:	03397363          	bgeu	s2,s3,80004a52 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004a30:	02091593          	slli	a1,s2,0x20
    80004a34:	9181                	srli	a1,a1,0x20
    80004a36:	95de                	add	a1,a1,s7
    80004a38:	855a                	mv	a0,s6
    80004a3a:	db0fc0ef          	jal	80000fea <walkaddr>
    80004a3e:	862a                	mv	a2,a0
    if(pa == 0)
    80004a40:	d179                	beqz	a0,80004a06 <kexec+0xc2>
    if(sz - i < PGSIZE)
    80004a42:	412984bb          	subw	s1,s3,s2
    80004a46:	0004879b          	sext.w	a5,s1
    80004a4a:	fcfcf4e3          	bgeu	s9,a5,80004a12 <kexec+0xce>
    80004a4e:	84d6                	mv	s1,s5
    80004a50:	b7c9                	j	80004a12 <kexec+0xce>
    sz = sz1;
    80004a52:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a56:	2d85                	addiw	s11,s11,1
    80004a58:	038d0d1b          	addiw	s10,s10,56
    80004a5c:	e8845783          	lhu	a5,-376(s0)
    80004a60:	08fdd063          	bge	s11,a5,80004ae0 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a64:	2d01                	sext.w	s10,s10
    80004a66:	03800713          	li	a4,56
    80004a6a:	86ea                	mv	a3,s10
    80004a6c:	e1840613          	addi	a2,s0,-488
    80004a70:	4581                	li	a1,0
    80004a72:	8552                	mv	a0,s4
    80004a74:	df9fe0ef          	jal	8000386c <readi>
    80004a78:	03800793          	li	a5,56
    80004a7c:	1cf51663          	bne	a0,a5,80004c48 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004a80:	e1842783          	lw	a5,-488(s0)
    80004a84:	4705                	li	a4,1
    80004a86:	fce798e3          	bne	a5,a4,80004a56 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004a8a:	e4043483          	ld	s1,-448(s0)
    80004a8e:	e3843783          	ld	a5,-456(s0)
    80004a92:	1af4ef63          	bltu	s1,a5,80004c50 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a96:	e2843783          	ld	a5,-472(s0)
    80004a9a:	94be                	add	s1,s1,a5
    80004a9c:	1af4ee63          	bltu	s1,a5,80004c58 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004aa0:	df043703          	ld	a4,-528(s0)
    80004aa4:	8ff9                	and	a5,a5,a4
    80004aa6:	1a079d63          	bnez	a5,80004c60 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004aaa:	e1c42503          	lw	a0,-484(s0)
    80004aae:	e7dff0ef          	jal	8000492a <flags2perm>
    80004ab2:	86aa                	mv	a3,a0
    80004ab4:	8626                	mv	a2,s1
    80004ab6:	85ca                	mv	a1,s2
    80004ab8:	855a                	mv	a0,s6
    80004aba:	809fc0ef          	jal	800012c2 <uvmalloc>
    80004abe:	e0a43423          	sd	a0,-504(s0)
    80004ac2:	1a050363          	beqz	a0,80004c68 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ac6:	e2843b83          	ld	s7,-472(s0)
    80004aca:	e2042c03          	lw	s8,-480(s0)
    80004ace:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ad2:	00098463          	beqz	s3,80004ada <kexec+0x196>
    80004ad6:	4901                	li	s2,0
    80004ad8:	bfa1                	j	80004a30 <kexec+0xec>
    sz = sz1;
    80004ada:	e0843903          	ld	s2,-504(s0)
    80004ade:	bfa5                	j	80004a56 <kexec+0x112>
    80004ae0:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004ae2:	8552                	mv	a0,s4
    80004ae4:	c03fe0ef          	jal	800036e6 <iunlockput>
  end_op();
    80004ae8:	c64ff0ef          	jal	80003f4c <end_op>
  p = myproc();
    80004aec:	e1dfc0ef          	jal	80001908 <myproc>
    80004af0:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004af2:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004af6:	6985                	lui	s3,0x1
    80004af8:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004afa:	99ca                	add	s3,s3,s2
    80004afc:	77fd                	lui	a5,0xfffff
    80004afe:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004b02:	4691                	li	a3,4
    80004b04:	6609                	lui	a2,0x2
    80004b06:	964e                	add	a2,a2,s3
    80004b08:	85ce                	mv	a1,s3
    80004b0a:	855a                	mv	a0,s6
    80004b0c:	fb6fc0ef          	jal	800012c2 <uvmalloc>
    80004b10:	892a                	mv	s2,a0
    80004b12:	e0a43423          	sd	a0,-504(s0)
    80004b16:	e519                	bnez	a0,80004b24 <kexec+0x1e0>
  if(pagetable)
    80004b18:	e1343423          	sd	s3,-504(s0)
    80004b1c:	4a01                	li	s4,0
    80004b1e:	aab1                	j	80004c7a <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b20:	4901                	li	s2,0
    80004b22:	b7c1                	j	80004ae2 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004b24:	75f9                	lui	a1,0xffffe
    80004b26:	95aa                	add	a1,a1,a0
    80004b28:	855a                	mv	a0,s6
    80004b2a:	96ffc0ef          	jal	80001498 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004b2e:	7bfd                	lui	s7,0xfffff
    80004b30:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004b32:	e0043783          	ld	a5,-512(s0)
    80004b36:	6388                	ld	a0,0(a5)
    80004b38:	cd39                	beqz	a0,80004b96 <kexec+0x252>
    80004b3a:	e9040993          	addi	s3,s0,-368
    80004b3e:	f9040c13          	addi	s8,s0,-112
    80004b42:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004b44:	b00fc0ef          	jal	80000e44 <strlen>
    80004b48:	0015079b          	addiw	a5,a0,1
    80004b4c:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004b50:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004b54:	11796e63          	bltu	s2,s7,80004c70 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004b58:	e0043d03          	ld	s10,-512(s0)
    80004b5c:	000d3a03          	ld	s4,0(s10)
    80004b60:	8552                	mv	a0,s4
    80004b62:	ae2fc0ef          	jal	80000e44 <strlen>
    80004b66:	0015069b          	addiw	a3,a0,1
    80004b6a:	8652                	mv	a2,s4
    80004b6c:	85ca                	mv	a1,s2
    80004b6e:	855a                	mv	a0,s6
    80004b70:	aadfc0ef          	jal	8000161c <copyout>
    80004b74:	10054063          	bltz	a0,80004c74 <kexec+0x330>
    ustack[argc] = sp;
    80004b78:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004b7c:	0485                	addi	s1,s1,1
    80004b7e:	008d0793          	addi	a5,s10,8
    80004b82:	e0f43023          	sd	a5,-512(s0)
    80004b86:	008d3503          	ld	a0,8(s10)
    80004b8a:	c909                	beqz	a0,80004b9c <kexec+0x258>
    if(argc >= MAXARG)
    80004b8c:	09a1                	addi	s3,s3,8
    80004b8e:	fb899be3          	bne	s3,s8,80004b44 <kexec+0x200>
  ip = 0;
    80004b92:	4a01                	li	s4,0
    80004b94:	a0dd                	j	80004c7a <kexec+0x336>
  sp = sz;
    80004b96:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004b9a:	4481                	li	s1,0
  ustack[argc] = 0;
    80004b9c:	00349793          	slli	a5,s1,0x3
    80004ba0:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ff9d2b8>
    80004ba4:	97a2                	add	a5,a5,s0
    80004ba6:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004baa:	00148693          	addi	a3,s1,1
    80004bae:	068e                	slli	a3,a3,0x3
    80004bb0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004bb4:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004bb8:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004bbc:	f5796ee3          	bltu	s2,s7,80004b18 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004bc0:	e9040613          	addi	a2,s0,-368
    80004bc4:	85ca                	mv	a1,s2
    80004bc6:	855a                	mv	a0,s6
    80004bc8:	a55fc0ef          	jal	8000161c <copyout>
    80004bcc:	0e054263          	bltz	a0,80004cb0 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004bd0:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004bd4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004bd8:	df843783          	ld	a5,-520(s0)
    80004bdc:	0007c703          	lbu	a4,0(a5)
    80004be0:	cf11                	beqz	a4,80004bfc <kexec+0x2b8>
    80004be2:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004be4:	02f00693          	li	a3,47
    80004be8:	a039                	j	80004bf6 <kexec+0x2b2>
      last = s+1;
    80004bea:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004bee:	0785                	addi	a5,a5,1
    80004bf0:	fff7c703          	lbu	a4,-1(a5)
    80004bf4:	c701                	beqz	a4,80004bfc <kexec+0x2b8>
    if(*s == '/')
    80004bf6:	fed71ce3          	bne	a4,a3,80004bee <kexec+0x2aa>
    80004bfa:	bfc5                	j	80004bea <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004bfc:	4641                	li	a2,16
    80004bfe:	df843583          	ld	a1,-520(s0)
    80004c02:	158a8513          	addi	a0,s5,344
    80004c06:	a0cfc0ef          	jal	80000e12 <safestrcpy>
  oldpagetable = p->pagetable;
    80004c0a:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004c0e:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004c12:	e0843783          	ld	a5,-504(s0)
    80004c16:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004c1a:	058ab783          	ld	a5,88(s5)
    80004c1e:	e6843703          	ld	a4,-408(s0)
    80004c22:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004c24:	058ab783          	ld	a5,88(s5)
    80004c28:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004c2c:	85e6                	mv	a1,s9
    80004c2e:	e65fc0ef          	jal	80001a92 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004c32:	0004851b          	sext.w	a0,s1
    80004c36:	79be                	ld	s3,488(sp)
    80004c38:	7a1e                	ld	s4,480(sp)
    80004c3a:	6afe                	ld	s5,472(sp)
    80004c3c:	6b5e                	ld	s6,464(sp)
    80004c3e:	6bbe                	ld	s7,456(sp)
    80004c40:	6c1e                	ld	s8,448(sp)
    80004c42:	7cfa                	ld	s9,440(sp)
    80004c44:	7d5a                	ld	s10,432(sp)
    80004c46:	b3b5                	j	800049b2 <kexec+0x6e>
    80004c48:	e1243423          	sd	s2,-504(s0)
    80004c4c:	7dba                	ld	s11,424(sp)
    80004c4e:	a035                	j	80004c7a <kexec+0x336>
    80004c50:	e1243423          	sd	s2,-504(s0)
    80004c54:	7dba                	ld	s11,424(sp)
    80004c56:	a015                	j	80004c7a <kexec+0x336>
    80004c58:	e1243423          	sd	s2,-504(s0)
    80004c5c:	7dba                	ld	s11,424(sp)
    80004c5e:	a831                	j	80004c7a <kexec+0x336>
    80004c60:	e1243423          	sd	s2,-504(s0)
    80004c64:	7dba                	ld	s11,424(sp)
    80004c66:	a811                	j	80004c7a <kexec+0x336>
    80004c68:	e1243423          	sd	s2,-504(s0)
    80004c6c:	7dba                	ld	s11,424(sp)
    80004c6e:	a031                	j	80004c7a <kexec+0x336>
  ip = 0;
    80004c70:	4a01                	li	s4,0
    80004c72:	a021                	j	80004c7a <kexec+0x336>
    80004c74:	4a01                	li	s4,0
  if(pagetable)
    80004c76:	a011                	j	80004c7a <kexec+0x336>
    80004c78:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004c7a:	e0843583          	ld	a1,-504(s0)
    80004c7e:	855a                	mv	a0,s6
    80004c80:	e13fc0ef          	jal	80001a92 <proc_freepagetable>
  return -1;
    80004c84:	557d                	li	a0,-1
  if(ip){
    80004c86:	000a1b63          	bnez	s4,80004c9c <kexec+0x358>
    80004c8a:	79be                	ld	s3,488(sp)
    80004c8c:	7a1e                	ld	s4,480(sp)
    80004c8e:	6afe                	ld	s5,472(sp)
    80004c90:	6b5e                	ld	s6,464(sp)
    80004c92:	6bbe                	ld	s7,456(sp)
    80004c94:	6c1e                	ld	s8,448(sp)
    80004c96:	7cfa                	ld	s9,440(sp)
    80004c98:	7d5a                	ld	s10,432(sp)
    80004c9a:	bb21                	j	800049b2 <kexec+0x6e>
    80004c9c:	79be                	ld	s3,488(sp)
    80004c9e:	6afe                	ld	s5,472(sp)
    80004ca0:	6b5e                	ld	s6,464(sp)
    80004ca2:	6bbe                	ld	s7,456(sp)
    80004ca4:	6c1e                	ld	s8,448(sp)
    80004ca6:	7cfa                	ld	s9,440(sp)
    80004ca8:	7d5a                	ld	s10,432(sp)
    80004caa:	b9ed                	j	800049a4 <kexec+0x60>
    80004cac:	6b5e                	ld	s6,464(sp)
    80004cae:	b9dd                	j	800049a4 <kexec+0x60>
  sz = sz1;
    80004cb0:	e0843983          	ld	s3,-504(s0)
    80004cb4:	b595                	j	80004b18 <kexec+0x1d4>

0000000080004cb6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004cb6:	7179                	addi	sp,sp,-48
    80004cb8:	f406                	sd	ra,40(sp)
    80004cba:	f022                	sd	s0,32(sp)
    80004cbc:	ec26                	sd	s1,24(sp)
    80004cbe:	e84a                	sd	s2,16(sp)
    80004cc0:	1800                	addi	s0,sp,48
    80004cc2:	892e                	mv	s2,a1
    80004cc4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004cc6:	fdc40593          	addi	a1,s0,-36
    80004cca:	b53fd0ef          	jal	8000281c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004cce:	fdc42703          	lw	a4,-36(s0)
    80004cd2:	47bd                	li	a5,15
    80004cd4:	02e7e963          	bltu	a5,a4,80004d06 <argfd+0x50>
    80004cd8:	c31fc0ef          	jal	80001908 <myproc>
    80004cdc:	fdc42703          	lw	a4,-36(s0)
    80004ce0:	01a70793          	addi	a5,a4,26
    80004ce4:	078e                	slli	a5,a5,0x3
    80004ce6:	953e                	add	a0,a0,a5
    80004ce8:	611c                	ld	a5,0(a0)
    80004cea:	c385                	beqz	a5,80004d0a <argfd+0x54>
    return -1;
  if(pfd)
    80004cec:	00090463          	beqz	s2,80004cf4 <argfd+0x3e>
    *pfd = fd;
    80004cf0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004cf4:	4501                	li	a0,0
  if(pf)
    80004cf6:	c091                	beqz	s1,80004cfa <argfd+0x44>
    *pf = f;
    80004cf8:	e09c                	sd	a5,0(s1)
}
    80004cfa:	70a2                	ld	ra,40(sp)
    80004cfc:	7402                	ld	s0,32(sp)
    80004cfe:	64e2                	ld	s1,24(sp)
    80004d00:	6942                	ld	s2,16(sp)
    80004d02:	6145                	addi	sp,sp,48
    80004d04:	8082                	ret
    return -1;
    80004d06:	557d                	li	a0,-1
    80004d08:	bfcd                	j	80004cfa <argfd+0x44>
    80004d0a:	557d                	li	a0,-1
    80004d0c:	b7fd                	j	80004cfa <argfd+0x44>

0000000080004d0e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004d0e:	1101                	addi	sp,sp,-32
    80004d10:	ec06                	sd	ra,24(sp)
    80004d12:	e822                	sd	s0,16(sp)
    80004d14:	e426                	sd	s1,8(sp)
    80004d16:	1000                	addi	s0,sp,32
    80004d18:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d1a:	beffc0ef          	jal	80001908 <myproc>
    80004d1e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004d20:	0d050793          	addi	a5,a0,208
    80004d24:	4501                	li	a0,0
    80004d26:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004d28:	6398                	ld	a4,0(a5)
    80004d2a:	cb19                	beqz	a4,80004d40 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004d2c:	2505                	addiw	a0,a0,1
    80004d2e:	07a1                	addi	a5,a5,8
    80004d30:	fed51ce3          	bne	a0,a3,80004d28 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004d34:	557d                	li	a0,-1
}
    80004d36:	60e2                	ld	ra,24(sp)
    80004d38:	6442                	ld	s0,16(sp)
    80004d3a:	64a2                	ld	s1,8(sp)
    80004d3c:	6105                	addi	sp,sp,32
    80004d3e:	8082                	ret
      p->ofile[fd] = f;
    80004d40:	01a50793          	addi	a5,a0,26
    80004d44:	078e                	slli	a5,a5,0x3
    80004d46:	963e                	add	a2,a2,a5
    80004d48:	e204                	sd	s1,0(a2)
      return fd;
    80004d4a:	b7f5                	j	80004d36 <fdalloc+0x28>

0000000080004d4c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004d4c:	715d                	addi	sp,sp,-80
    80004d4e:	e486                	sd	ra,72(sp)
    80004d50:	e0a2                	sd	s0,64(sp)
    80004d52:	fc26                	sd	s1,56(sp)
    80004d54:	f84a                	sd	s2,48(sp)
    80004d56:	f44e                	sd	s3,40(sp)
    80004d58:	ec56                	sd	s5,24(sp)
    80004d5a:	e85a                	sd	s6,16(sp)
    80004d5c:	0880                	addi	s0,sp,80
    80004d5e:	8b2e                	mv	s6,a1
    80004d60:	89b2                	mv	s3,a2
    80004d62:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004d64:	fb040593          	addi	a1,s0,-80
    80004d68:	fa5fe0ef          	jal	80003d0c <nameiparent>
    80004d6c:	84aa                	mv	s1,a0
    80004d6e:	10050a63          	beqz	a0,80004e82 <create+0x136>
    return 0;

  ilock(dp);
    80004d72:	f54fe0ef          	jal	800034c6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004d76:	4601                	li	a2,0
    80004d78:	fb040593          	addi	a1,s0,-80
    80004d7c:	8526                	mv	a0,s1
    80004d7e:	d0ffe0ef          	jal	80003a8c <dirlookup>
    80004d82:	8aaa                	mv	s5,a0
    80004d84:	c129                	beqz	a0,80004dc6 <create+0x7a>
    iunlockput(dp);
    80004d86:	8526                	mv	a0,s1
    80004d88:	95ffe0ef          	jal	800036e6 <iunlockput>
    ilock(ip);
    80004d8c:	8556                	mv	a0,s5
    80004d8e:	f38fe0ef          	jal	800034c6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d92:	4789                	li	a5,2
    80004d94:	02fb1463          	bne	s6,a5,80004dbc <create+0x70>
    80004d98:	044ad783          	lhu	a5,68(s5)
    80004d9c:	37f9                	addiw	a5,a5,-2
    80004d9e:	17c2                	slli	a5,a5,0x30
    80004da0:	93c1                	srli	a5,a5,0x30
    80004da2:	4705                	li	a4,1
    80004da4:	00f76c63          	bltu	a4,a5,80004dbc <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004da8:	8556                	mv	a0,s5
    80004daa:	60a6                	ld	ra,72(sp)
    80004dac:	6406                	ld	s0,64(sp)
    80004dae:	74e2                	ld	s1,56(sp)
    80004db0:	7942                	ld	s2,48(sp)
    80004db2:	79a2                	ld	s3,40(sp)
    80004db4:	6ae2                	ld	s5,24(sp)
    80004db6:	6b42                	ld	s6,16(sp)
    80004db8:	6161                	addi	sp,sp,80
    80004dba:	8082                	ret
    iunlockput(ip);
    80004dbc:	8556                	mv	a0,s5
    80004dbe:	929fe0ef          	jal	800036e6 <iunlockput>
    return 0;
    80004dc2:	4a81                	li	s5,0
    80004dc4:	b7d5                	j	80004da8 <create+0x5c>
    80004dc6:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004dc8:	85da                	mv	a1,s6
    80004dca:	4088                	lw	a0,0(s1)
    80004dcc:	d74fe0ef          	jal	80003340 <ialloc>
    80004dd0:	8a2a                	mv	s4,a0
    80004dd2:	cd15                	beqz	a0,80004e0e <create+0xc2>
  ilock(ip);
    80004dd4:	ef2fe0ef          	jal	800034c6 <ilock>
  ip->major = major;
    80004dd8:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004ddc:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004de0:	4905                	li	s2,1
    80004de2:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004de6:	8552                	mv	a0,s4
    80004de8:	e24fe0ef          	jal	8000340c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004dec:	032b0763          	beq	s6,s2,80004e1a <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004df0:	004a2603          	lw	a2,4(s4)
    80004df4:	fb040593          	addi	a1,s0,-80
    80004df8:	8526                	mv	a0,s1
    80004dfa:	e5ffe0ef          	jal	80003c58 <dirlink>
    80004dfe:	06054563          	bltz	a0,80004e68 <create+0x11c>
  iunlockput(dp);
    80004e02:	8526                	mv	a0,s1
    80004e04:	8e3fe0ef          	jal	800036e6 <iunlockput>
  return ip;
    80004e08:	8ad2                	mv	s5,s4
    80004e0a:	7a02                	ld	s4,32(sp)
    80004e0c:	bf71                	j	80004da8 <create+0x5c>
    iunlockput(dp);
    80004e0e:	8526                	mv	a0,s1
    80004e10:	8d7fe0ef          	jal	800036e6 <iunlockput>
    return 0;
    80004e14:	8ad2                	mv	s5,s4
    80004e16:	7a02                	ld	s4,32(sp)
    80004e18:	bf41                	j	80004da8 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004e1a:	004a2603          	lw	a2,4(s4)
    80004e1e:	00003597          	auipc	a1,0x3
    80004e22:	7aa58593          	addi	a1,a1,1962 # 800085c8 <etext+0x5c8>
    80004e26:	8552                	mv	a0,s4
    80004e28:	e31fe0ef          	jal	80003c58 <dirlink>
    80004e2c:	02054e63          	bltz	a0,80004e68 <create+0x11c>
    80004e30:	40d0                	lw	a2,4(s1)
    80004e32:	00003597          	auipc	a1,0x3
    80004e36:	79e58593          	addi	a1,a1,1950 # 800085d0 <etext+0x5d0>
    80004e3a:	8552                	mv	a0,s4
    80004e3c:	e1dfe0ef          	jal	80003c58 <dirlink>
    80004e40:	02054463          	bltz	a0,80004e68 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e44:	004a2603          	lw	a2,4(s4)
    80004e48:	fb040593          	addi	a1,s0,-80
    80004e4c:	8526                	mv	a0,s1
    80004e4e:	e0bfe0ef          	jal	80003c58 <dirlink>
    80004e52:	00054b63          	bltz	a0,80004e68 <create+0x11c>
    dp->nlink++;  // for ".."
    80004e56:	04a4d783          	lhu	a5,74(s1)
    80004e5a:	2785                	addiw	a5,a5,1
    80004e5c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e60:	8526                	mv	a0,s1
    80004e62:	daafe0ef          	jal	8000340c <iupdate>
    80004e66:	bf71                	j	80004e02 <create+0xb6>
  ip->nlink = 0;
    80004e68:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004e6c:	8552                	mv	a0,s4
    80004e6e:	d9efe0ef          	jal	8000340c <iupdate>
  iunlockput(ip);
    80004e72:	8552                	mv	a0,s4
    80004e74:	873fe0ef          	jal	800036e6 <iunlockput>
  iunlockput(dp);
    80004e78:	8526                	mv	a0,s1
    80004e7a:	86dfe0ef          	jal	800036e6 <iunlockput>
  return 0;
    80004e7e:	7a02                	ld	s4,32(sp)
    80004e80:	b725                	j	80004da8 <create+0x5c>
    return 0;
    80004e82:	8aaa                	mv	s5,a0
    80004e84:	b715                	j	80004da8 <create+0x5c>

0000000080004e86 <sys_dup>:
{
    80004e86:	7179                	addi	sp,sp,-48
    80004e88:	f406                	sd	ra,40(sp)
    80004e8a:	f022                	sd	s0,32(sp)
    80004e8c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004e8e:	fd840613          	addi	a2,s0,-40
    80004e92:	4581                	li	a1,0
    80004e94:	4501                	li	a0,0
    80004e96:	e21ff0ef          	jal	80004cb6 <argfd>
    return -1;
    80004e9a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004e9c:	02054363          	bltz	a0,80004ec2 <sys_dup+0x3c>
    80004ea0:	ec26                	sd	s1,24(sp)
    80004ea2:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004ea4:	fd843903          	ld	s2,-40(s0)
    80004ea8:	854a                	mv	a0,s2
    80004eaa:	e65ff0ef          	jal	80004d0e <fdalloc>
    80004eae:	84aa                	mv	s1,a0
    return -1;
    80004eb0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004eb2:	00054d63          	bltz	a0,80004ecc <sys_dup+0x46>
  filedup(f);
    80004eb6:	854a                	mv	a0,s2
    80004eb8:	c3eff0ef          	jal	800042f6 <filedup>
  return fd;
    80004ebc:	87a6                	mv	a5,s1
    80004ebe:	64e2                	ld	s1,24(sp)
    80004ec0:	6942                	ld	s2,16(sp)
}
    80004ec2:	853e                	mv	a0,a5
    80004ec4:	70a2                	ld	ra,40(sp)
    80004ec6:	7402                	ld	s0,32(sp)
    80004ec8:	6145                	addi	sp,sp,48
    80004eca:	8082                	ret
    80004ecc:	64e2                	ld	s1,24(sp)
    80004ece:	6942                	ld	s2,16(sp)
    80004ed0:	bfcd                	j	80004ec2 <sys_dup+0x3c>

0000000080004ed2 <sys_read>:
{
    80004ed2:	7179                	addi	sp,sp,-48
    80004ed4:	f406                	sd	ra,40(sp)
    80004ed6:	f022                	sd	s0,32(sp)
    80004ed8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004eda:	fd840593          	addi	a1,s0,-40
    80004ede:	4505                	li	a0,1
    80004ee0:	959fd0ef          	jal	80002838 <argaddr>
  argint(2, &n);
    80004ee4:	fe440593          	addi	a1,s0,-28
    80004ee8:	4509                	li	a0,2
    80004eea:	933fd0ef          	jal	8000281c <argint>
  if(argfd(0, 0, &f) < 0)
    80004eee:	fe840613          	addi	a2,s0,-24
    80004ef2:	4581                	li	a1,0
    80004ef4:	4501                	li	a0,0
    80004ef6:	dc1ff0ef          	jal	80004cb6 <argfd>
    80004efa:	87aa                	mv	a5,a0
    return -1;
    80004efc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004efe:	0007ca63          	bltz	a5,80004f12 <sys_read+0x40>
  return fileread(f, p, n);
    80004f02:	fe442603          	lw	a2,-28(s0)
    80004f06:	fd843583          	ld	a1,-40(s0)
    80004f0a:	fe843503          	ld	a0,-24(s0)
    80004f0e:	d4eff0ef          	jal	8000445c <fileread>
}
    80004f12:	70a2                	ld	ra,40(sp)
    80004f14:	7402                	ld	s0,32(sp)
    80004f16:	6145                	addi	sp,sp,48
    80004f18:	8082                	ret

0000000080004f1a <sys_write>:
{
    80004f1a:	7179                	addi	sp,sp,-48
    80004f1c:	f406                	sd	ra,40(sp)
    80004f1e:	f022                	sd	s0,32(sp)
    80004f20:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f22:	fd840593          	addi	a1,s0,-40
    80004f26:	4505                	li	a0,1
    80004f28:	911fd0ef          	jal	80002838 <argaddr>
  argint(2, &n);
    80004f2c:	fe440593          	addi	a1,s0,-28
    80004f30:	4509                	li	a0,2
    80004f32:	8ebfd0ef          	jal	8000281c <argint>
  if(argfd(0, 0, &f) < 0)
    80004f36:	fe840613          	addi	a2,s0,-24
    80004f3a:	4581                	li	a1,0
    80004f3c:	4501                	li	a0,0
    80004f3e:	d79ff0ef          	jal	80004cb6 <argfd>
    80004f42:	87aa                	mv	a5,a0
    return -1;
    80004f44:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f46:	0007ca63          	bltz	a5,80004f5a <sys_write+0x40>
  return filewrite(f, p, n);
    80004f4a:	fe442603          	lw	a2,-28(s0)
    80004f4e:	fd843583          	ld	a1,-40(s0)
    80004f52:	fe843503          	ld	a0,-24(s0)
    80004f56:	dc4ff0ef          	jal	8000451a <filewrite>
}
    80004f5a:	70a2                	ld	ra,40(sp)
    80004f5c:	7402                	ld	s0,32(sp)
    80004f5e:	6145                	addi	sp,sp,48
    80004f60:	8082                	ret

0000000080004f62 <sys_close>:
{
    80004f62:	1101                	addi	sp,sp,-32
    80004f64:	ec06                	sd	ra,24(sp)
    80004f66:	e822                	sd	s0,16(sp)
    80004f68:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004f6a:	fe040613          	addi	a2,s0,-32
    80004f6e:	fec40593          	addi	a1,s0,-20
    80004f72:	4501                	li	a0,0
    80004f74:	d43ff0ef          	jal	80004cb6 <argfd>
    return -1;
    80004f78:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004f7a:	02054063          	bltz	a0,80004f9a <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004f7e:	98bfc0ef          	jal	80001908 <myproc>
    80004f82:	fec42783          	lw	a5,-20(s0)
    80004f86:	07e9                	addi	a5,a5,26
    80004f88:	078e                	slli	a5,a5,0x3
    80004f8a:	953e                	add	a0,a0,a5
    80004f8c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f90:	fe043503          	ld	a0,-32(s0)
    80004f94:	ba8ff0ef          	jal	8000433c <fileclose>
  return 0;
    80004f98:	4781                	li	a5,0
}
    80004f9a:	853e                	mv	a0,a5
    80004f9c:	60e2                	ld	ra,24(sp)
    80004f9e:	6442                	ld	s0,16(sp)
    80004fa0:	6105                	addi	sp,sp,32
    80004fa2:	8082                	ret

0000000080004fa4 <sys_fstat>:
{
    80004fa4:	1101                	addi	sp,sp,-32
    80004fa6:	ec06                	sd	ra,24(sp)
    80004fa8:	e822                	sd	s0,16(sp)
    80004faa:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004fac:	fe040593          	addi	a1,s0,-32
    80004fb0:	4505                	li	a0,1
    80004fb2:	887fd0ef          	jal	80002838 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004fb6:	fe840613          	addi	a2,s0,-24
    80004fba:	4581                	li	a1,0
    80004fbc:	4501                	li	a0,0
    80004fbe:	cf9ff0ef          	jal	80004cb6 <argfd>
    80004fc2:	87aa                	mv	a5,a0
    return -1;
    80004fc4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fc6:	0007c863          	bltz	a5,80004fd6 <sys_fstat+0x32>
  return filestat(f, st);
    80004fca:	fe043583          	ld	a1,-32(s0)
    80004fce:	fe843503          	ld	a0,-24(s0)
    80004fd2:	c2cff0ef          	jal	800043fe <filestat>
}
    80004fd6:	60e2                	ld	ra,24(sp)
    80004fd8:	6442                	ld	s0,16(sp)
    80004fda:	6105                	addi	sp,sp,32
    80004fdc:	8082                	ret

0000000080004fde <sys_link>:
{
    80004fde:	7169                	addi	sp,sp,-304
    80004fe0:	f606                	sd	ra,296(sp)
    80004fe2:	f222                	sd	s0,288(sp)
    80004fe4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fe6:	08000613          	li	a2,128
    80004fea:	ed040593          	addi	a1,s0,-304
    80004fee:	4501                	li	a0,0
    80004ff0:	865fd0ef          	jal	80002854 <argstr>
    return -1;
    80004ff4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ff6:	0c054e63          	bltz	a0,800050d2 <sys_link+0xf4>
    80004ffa:	08000613          	li	a2,128
    80004ffe:	f5040593          	addi	a1,s0,-176
    80005002:	4505                	li	a0,1
    80005004:	851fd0ef          	jal	80002854 <argstr>
    return -1;
    80005008:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000500a:	0c054463          	bltz	a0,800050d2 <sys_link+0xf4>
    8000500e:	ee26                	sd	s1,280(sp)
  begin_op();
    80005010:	ec7fe0ef          	jal	80003ed6 <begin_op>
  if((ip = namei(old)) == 0){
    80005014:	ed040513          	addi	a0,s0,-304
    80005018:	cdbfe0ef          	jal	80003cf2 <namei>
    8000501c:	84aa                	mv	s1,a0
    8000501e:	c53d                	beqz	a0,8000508c <sys_link+0xae>
  ilock(ip);
    80005020:	ca6fe0ef          	jal	800034c6 <ilock>
  if(ip->type == T_DIR){
    80005024:	04449703          	lh	a4,68(s1)
    80005028:	4785                	li	a5,1
    8000502a:	06f70663          	beq	a4,a5,80005096 <sys_link+0xb8>
    8000502e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005030:	04a4d783          	lhu	a5,74(s1)
    80005034:	2785                	addiw	a5,a5,1
    80005036:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000503a:	8526                	mv	a0,s1
    8000503c:	bd0fe0ef          	jal	8000340c <iupdate>
  iunlock(ip);
    80005040:	8526                	mv	a0,s1
    80005042:	d3afe0ef          	jal	8000357c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005046:	fd040593          	addi	a1,s0,-48
    8000504a:	f5040513          	addi	a0,s0,-176
    8000504e:	cbffe0ef          	jal	80003d0c <nameiparent>
    80005052:	892a                	mv	s2,a0
    80005054:	cd21                	beqz	a0,800050ac <sys_link+0xce>
  ilock(dp);
    80005056:	c70fe0ef          	jal	800034c6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000505a:	00092703          	lw	a4,0(s2)
    8000505e:	409c                	lw	a5,0(s1)
    80005060:	04f71363          	bne	a4,a5,800050a6 <sys_link+0xc8>
    80005064:	40d0                	lw	a2,4(s1)
    80005066:	fd040593          	addi	a1,s0,-48
    8000506a:	854a                	mv	a0,s2
    8000506c:	bedfe0ef          	jal	80003c58 <dirlink>
    80005070:	02054b63          	bltz	a0,800050a6 <sys_link+0xc8>
  iunlockput(dp);
    80005074:	854a                	mv	a0,s2
    80005076:	e70fe0ef          	jal	800036e6 <iunlockput>
  iput(ip);
    8000507a:	8526                	mv	a0,s1
    8000507c:	ddcfe0ef          	jal	80003658 <iput>
  end_op();
    80005080:	ecdfe0ef          	jal	80003f4c <end_op>
  return 0;
    80005084:	4781                	li	a5,0
    80005086:	64f2                	ld	s1,280(sp)
    80005088:	6952                	ld	s2,272(sp)
    8000508a:	a0a1                	j	800050d2 <sys_link+0xf4>
    end_op();
    8000508c:	ec1fe0ef          	jal	80003f4c <end_op>
    return -1;
    80005090:	57fd                	li	a5,-1
    80005092:	64f2                	ld	s1,280(sp)
    80005094:	a83d                	j	800050d2 <sys_link+0xf4>
    iunlockput(ip);
    80005096:	8526                	mv	a0,s1
    80005098:	e4efe0ef          	jal	800036e6 <iunlockput>
    end_op();
    8000509c:	eb1fe0ef          	jal	80003f4c <end_op>
    return -1;
    800050a0:	57fd                	li	a5,-1
    800050a2:	64f2                	ld	s1,280(sp)
    800050a4:	a03d                	j	800050d2 <sys_link+0xf4>
    iunlockput(dp);
    800050a6:	854a                	mv	a0,s2
    800050a8:	e3efe0ef          	jal	800036e6 <iunlockput>
  ilock(ip);
    800050ac:	8526                	mv	a0,s1
    800050ae:	c18fe0ef          	jal	800034c6 <ilock>
  ip->nlink--;
    800050b2:	04a4d783          	lhu	a5,74(s1)
    800050b6:	37fd                	addiw	a5,a5,-1
    800050b8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050bc:	8526                	mv	a0,s1
    800050be:	b4efe0ef          	jal	8000340c <iupdate>
  iunlockput(ip);
    800050c2:	8526                	mv	a0,s1
    800050c4:	e22fe0ef          	jal	800036e6 <iunlockput>
  end_op();
    800050c8:	e85fe0ef          	jal	80003f4c <end_op>
  return -1;
    800050cc:	57fd                	li	a5,-1
    800050ce:	64f2                	ld	s1,280(sp)
    800050d0:	6952                	ld	s2,272(sp)
}
    800050d2:	853e                	mv	a0,a5
    800050d4:	70b2                	ld	ra,296(sp)
    800050d6:	7412                	ld	s0,288(sp)
    800050d8:	6155                	addi	sp,sp,304
    800050da:	8082                	ret

00000000800050dc <sys_unlink>:
{
    800050dc:	7151                	addi	sp,sp,-240
    800050de:	f586                	sd	ra,232(sp)
    800050e0:	f1a2                	sd	s0,224(sp)
    800050e2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800050e4:	08000613          	li	a2,128
    800050e8:	f3040593          	addi	a1,s0,-208
    800050ec:	4501                	li	a0,0
    800050ee:	f66fd0ef          	jal	80002854 <argstr>
    800050f2:	16054063          	bltz	a0,80005252 <sys_unlink+0x176>
    800050f6:	eda6                	sd	s1,216(sp)
  begin_op();
    800050f8:	ddffe0ef          	jal	80003ed6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800050fc:	fb040593          	addi	a1,s0,-80
    80005100:	f3040513          	addi	a0,s0,-208
    80005104:	c09fe0ef          	jal	80003d0c <nameiparent>
    80005108:	84aa                	mv	s1,a0
    8000510a:	c945                	beqz	a0,800051ba <sys_unlink+0xde>
  ilock(dp);
    8000510c:	bbafe0ef          	jal	800034c6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005110:	00003597          	auipc	a1,0x3
    80005114:	4b858593          	addi	a1,a1,1208 # 800085c8 <etext+0x5c8>
    80005118:	fb040513          	addi	a0,s0,-80
    8000511c:	95bfe0ef          	jal	80003a76 <namecmp>
    80005120:	10050e63          	beqz	a0,8000523c <sys_unlink+0x160>
    80005124:	00003597          	auipc	a1,0x3
    80005128:	4ac58593          	addi	a1,a1,1196 # 800085d0 <etext+0x5d0>
    8000512c:	fb040513          	addi	a0,s0,-80
    80005130:	947fe0ef          	jal	80003a76 <namecmp>
    80005134:	10050463          	beqz	a0,8000523c <sys_unlink+0x160>
    80005138:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000513a:	f2c40613          	addi	a2,s0,-212
    8000513e:	fb040593          	addi	a1,s0,-80
    80005142:	8526                	mv	a0,s1
    80005144:	949fe0ef          	jal	80003a8c <dirlookup>
    80005148:	892a                	mv	s2,a0
    8000514a:	0e050863          	beqz	a0,8000523a <sys_unlink+0x15e>
  ilock(ip);
    8000514e:	b78fe0ef          	jal	800034c6 <ilock>
  if(ip->nlink < 1)
    80005152:	04a91783          	lh	a5,74(s2)
    80005156:	06f05763          	blez	a5,800051c4 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000515a:	04491703          	lh	a4,68(s2)
    8000515e:	4785                	li	a5,1
    80005160:	06f70963          	beq	a4,a5,800051d2 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005164:	4641                	li	a2,16
    80005166:	4581                	li	a1,0
    80005168:	fc040513          	addi	a0,s0,-64
    8000516c:	b69fb0ef          	jal	80000cd4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005170:	4741                	li	a4,16
    80005172:	f2c42683          	lw	a3,-212(s0)
    80005176:	fc040613          	addi	a2,s0,-64
    8000517a:	4581                	li	a1,0
    8000517c:	8526                	mv	a0,s1
    8000517e:	feafe0ef          	jal	80003968 <writei>
    80005182:	47c1                	li	a5,16
    80005184:	08f51b63          	bne	a0,a5,8000521a <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005188:	04491703          	lh	a4,68(s2)
    8000518c:	4785                	li	a5,1
    8000518e:	08f70d63          	beq	a4,a5,80005228 <sys_unlink+0x14c>
  iunlockput(dp);
    80005192:	8526                	mv	a0,s1
    80005194:	d52fe0ef          	jal	800036e6 <iunlockput>
  ip->nlink--;
    80005198:	04a95783          	lhu	a5,74(s2)
    8000519c:	37fd                	addiw	a5,a5,-1
    8000519e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800051a2:	854a                	mv	a0,s2
    800051a4:	a68fe0ef          	jal	8000340c <iupdate>
  iunlockput(ip);
    800051a8:	854a                	mv	a0,s2
    800051aa:	d3cfe0ef          	jal	800036e6 <iunlockput>
  end_op();
    800051ae:	d9ffe0ef          	jal	80003f4c <end_op>
  return 0;
    800051b2:	4501                	li	a0,0
    800051b4:	64ee                	ld	s1,216(sp)
    800051b6:	694e                	ld	s2,208(sp)
    800051b8:	a849                	j	8000524a <sys_unlink+0x16e>
    end_op();
    800051ba:	d93fe0ef          	jal	80003f4c <end_op>
    return -1;
    800051be:	557d                	li	a0,-1
    800051c0:	64ee                	ld	s1,216(sp)
    800051c2:	a061                	j	8000524a <sys_unlink+0x16e>
    800051c4:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800051c6:	00003517          	auipc	a0,0x3
    800051ca:	41250513          	addi	a0,a0,1042 # 800085d8 <etext+0x5d8>
    800051ce:	e44fb0ef          	jal	80000812 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800051d2:	04c92703          	lw	a4,76(s2)
    800051d6:	02000793          	li	a5,32
    800051da:	f8e7f5e3          	bgeu	a5,a4,80005164 <sys_unlink+0x88>
    800051de:	e5ce                	sd	s3,200(sp)
    800051e0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051e4:	4741                	li	a4,16
    800051e6:	86ce                	mv	a3,s3
    800051e8:	f1840613          	addi	a2,s0,-232
    800051ec:	4581                	li	a1,0
    800051ee:	854a                	mv	a0,s2
    800051f0:	e7cfe0ef          	jal	8000386c <readi>
    800051f4:	47c1                	li	a5,16
    800051f6:	00f51c63          	bne	a0,a5,8000520e <sys_unlink+0x132>
    if(de.inum != 0)
    800051fa:	f1845783          	lhu	a5,-232(s0)
    800051fe:	efa1                	bnez	a5,80005256 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005200:	29c1                	addiw	s3,s3,16
    80005202:	04c92783          	lw	a5,76(s2)
    80005206:	fcf9efe3          	bltu	s3,a5,800051e4 <sys_unlink+0x108>
    8000520a:	69ae                	ld	s3,200(sp)
    8000520c:	bfa1                	j	80005164 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000520e:	00003517          	auipc	a0,0x3
    80005212:	3e250513          	addi	a0,a0,994 # 800085f0 <etext+0x5f0>
    80005216:	dfcfb0ef          	jal	80000812 <panic>
    8000521a:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000521c:	00003517          	auipc	a0,0x3
    80005220:	3ec50513          	addi	a0,a0,1004 # 80008608 <etext+0x608>
    80005224:	deefb0ef          	jal	80000812 <panic>
    dp->nlink--;
    80005228:	04a4d783          	lhu	a5,74(s1)
    8000522c:	37fd                	addiw	a5,a5,-1
    8000522e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005232:	8526                	mv	a0,s1
    80005234:	9d8fe0ef          	jal	8000340c <iupdate>
    80005238:	bfa9                	j	80005192 <sys_unlink+0xb6>
    8000523a:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000523c:	8526                	mv	a0,s1
    8000523e:	ca8fe0ef          	jal	800036e6 <iunlockput>
  end_op();
    80005242:	d0bfe0ef          	jal	80003f4c <end_op>
  return -1;
    80005246:	557d                	li	a0,-1
    80005248:	64ee                	ld	s1,216(sp)
}
    8000524a:	70ae                	ld	ra,232(sp)
    8000524c:	740e                	ld	s0,224(sp)
    8000524e:	616d                	addi	sp,sp,240
    80005250:	8082                	ret
    return -1;
    80005252:	557d                	li	a0,-1
    80005254:	bfdd                	j	8000524a <sys_unlink+0x16e>
    iunlockput(ip);
    80005256:	854a                	mv	a0,s2
    80005258:	c8efe0ef          	jal	800036e6 <iunlockput>
    goto bad;
    8000525c:	694e                	ld	s2,208(sp)
    8000525e:	69ae                	ld	s3,200(sp)
    80005260:	bff1                	j	8000523c <sys_unlink+0x160>

0000000080005262 <sys_open>:

uint64
sys_open(void)
{
    80005262:	7131                	addi	sp,sp,-192
    80005264:	fd06                	sd	ra,184(sp)
    80005266:	f922                	sd	s0,176(sp)
    80005268:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000526a:	f4c40593          	addi	a1,s0,-180
    8000526e:	4505                	li	a0,1
    80005270:	dacfd0ef          	jal	8000281c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005274:	08000613          	li	a2,128
    80005278:	f5040593          	addi	a1,s0,-176
    8000527c:	4501                	li	a0,0
    8000527e:	dd6fd0ef          	jal	80002854 <argstr>
    80005282:	87aa                	mv	a5,a0
    return -1;
    80005284:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005286:	0a07c263          	bltz	a5,8000532a <sys_open+0xc8>
    8000528a:	f526                	sd	s1,168(sp)

  begin_op();
    8000528c:	c4bfe0ef          	jal	80003ed6 <begin_op>

  if(omode & O_CREATE){
    80005290:	f4c42783          	lw	a5,-180(s0)
    80005294:	2007f793          	andi	a5,a5,512
    80005298:	c3d5                	beqz	a5,8000533c <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000529a:	4681                	li	a3,0
    8000529c:	4601                	li	a2,0
    8000529e:	4589                	li	a1,2
    800052a0:	f5040513          	addi	a0,s0,-176
    800052a4:	aa9ff0ef          	jal	80004d4c <create>
    800052a8:	84aa                	mv	s1,a0
    if(ip == 0){
    800052aa:	c541                	beqz	a0,80005332 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800052ac:	04449703          	lh	a4,68(s1)
    800052b0:	478d                	li	a5,3
    800052b2:	00f71763          	bne	a4,a5,800052c0 <sys_open+0x5e>
    800052b6:	0464d703          	lhu	a4,70(s1)
    800052ba:	47a5                	li	a5,9
    800052bc:	0ae7ed63          	bltu	a5,a4,80005376 <sys_open+0x114>
    800052c0:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800052c2:	fd7fe0ef          	jal	80004298 <filealloc>
    800052c6:	892a                	mv	s2,a0
    800052c8:	c179                	beqz	a0,8000538e <sys_open+0x12c>
    800052ca:	ed4e                	sd	s3,152(sp)
    800052cc:	a43ff0ef          	jal	80004d0e <fdalloc>
    800052d0:	89aa                	mv	s3,a0
    800052d2:	0a054a63          	bltz	a0,80005386 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800052d6:	04449703          	lh	a4,68(s1)
    800052da:	478d                	li	a5,3
    800052dc:	0cf70263          	beq	a4,a5,800053a0 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800052e0:	4789                	li	a5,2
    800052e2:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800052e6:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800052ea:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800052ee:	f4c42783          	lw	a5,-180(s0)
    800052f2:	0017c713          	xori	a4,a5,1
    800052f6:	8b05                	andi	a4,a4,1
    800052f8:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800052fc:	0037f713          	andi	a4,a5,3
    80005300:	00e03733          	snez	a4,a4
    80005304:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005308:	4007f793          	andi	a5,a5,1024
    8000530c:	c791                	beqz	a5,80005318 <sys_open+0xb6>
    8000530e:	04449703          	lh	a4,68(s1)
    80005312:	4789                	li	a5,2
    80005314:	08f70d63          	beq	a4,a5,800053ae <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005318:	8526                	mv	a0,s1
    8000531a:	a62fe0ef          	jal	8000357c <iunlock>
  end_op();
    8000531e:	c2ffe0ef          	jal	80003f4c <end_op>

  return fd;
    80005322:	854e                	mv	a0,s3
    80005324:	74aa                	ld	s1,168(sp)
    80005326:	790a                	ld	s2,160(sp)
    80005328:	69ea                	ld	s3,152(sp)
}
    8000532a:	70ea                	ld	ra,184(sp)
    8000532c:	744a                	ld	s0,176(sp)
    8000532e:	6129                	addi	sp,sp,192
    80005330:	8082                	ret
      end_op();
    80005332:	c1bfe0ef          	jal	80003f4c <end_op>
      return -1;
    80005336:	557d                	li	a0,-1
    80005338:	74aa                	ld	s1,168(sp)
    8000533a:	bfc5                	j	8000532a <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    8000533c:	f5040513          	addi	a0,s0,-176
    80005340:	9b3fe0ef          	jal	80003cf2 <namei>
    80005344:	84aa                	mv	s1,a0
    80005346:	c11d                	beqz	a0,8000536c <sys_open+0x10a>
    ilock(ip);
    80005348:	97efe0ef          	jal	800034c6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000534c:	04449703          	lh	a4,68(s1)
    80005350:	4785                	li	a5,1
    80005352:	f4f71de3          	bne	a4,a5,800052ac <sys_open+0x4a>
    80005356:	f4c42783          	lw	a5,-180(s0)
    8000535a:	d3bd                	beqz	a5,800052c0 <sys_open+0x5e>
      iunlockput(ip);
    8000535c:	8526                	mv	a0,s1
    8000535e:	b88fe0ef          	jal	800036e6 <iunlockput>
      end_op();
    80005362:	bebfe0ef          	jal	80003f4c <end_op>
      return -1;
    80005366:	557d                	li	a0,-1
    80005368:	74aa                	ld	s1,168(sp)
    8000536a:	b7c1                	j	8000532a <sys_open+0xc8>
      end_op();
    8000536c:	be1fe0ef          	jal	80003f4c <end_op>
      return -1;
    80005370:	557d                	li	a0,-1
    80005372:	74aa                	ld	s1,168(sp)
    80005374:	bf5d                	j	8000532a <sys_open+0xc8>
    iunlockput(ip);
    80005376:	8526                	mv	a0,s1
    80005378:	b6efe0ef          	jal	800036e6 <iunlockput>
    end_op();
    8000537c:	bd1fe0ef          	jal	80003f4c <end_op>
    return -1;
    80005380:	557d                	li	a0,-1
    80005382:	74aa                	ld	s1,168(sp)
    80005384:	b75d                	j	8000532a <sys_open+0xc8>
      fileclose(f);
    80005386:	854a                	mv	a0,s2
    80005388:	fb5fe0ef          	jal	8000433c <fileclose>
    8000538c:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000538e:	8526                	mv	a0,s1
    80005390:	b56fe0ef          	jal	800036e6 <iunlockput>
    end_op();
    80005394:	bb9fe0ef          	jal	80003f4c <end_op>
    return -1;
    80005398:	557d                	li	a0,-1
    8000539a:	74aa                	ld	s1,168(sp)
    8000539c:	790a                	ld	s2,160(sp)
    8000539e:	b771                	j	8000532a <sys_open+0xc8>
    f->type = FD_DEVICE;
    800053a0:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800053a4:	04649783          	lh	a5,70(s1)
    800053a8:	02f91223          	sh	a5,36(s2)
    800053ac:	bf3d                	j	800052ea <sys_open+0x88>
    itrunc(ip);
    800053ae:	8526                	mv	a0,s1
    800053b0:	a14fe0ef          	jal	800035c4 <itrunc>
    800053b4:	b795                	j	80005318 <sys_open+0xb6>

00000000800053b6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800053b6:	7175                	addi	sp,sp,-144
    800053b8:	e506                	sd	ra,136(sp)
    800053ba:	e122                	sd	s0,128(sp)
    800053bc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800053be:	b19fe0ef          	jal	80003ed6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800053c2:	08000613          	li	a2,128
    800053c6:	f7040593          	addi	a1,s0,-144
    800053ca:	4501                	li	a0,0
    800053cc:	c88fd0ef          	jal	80002854 <argstr>
    800053d0:	02054363          	bltz	a0,800053f6 <sys_mkdir+0x40>
    800053d4:	4681                	li	a3,0
    800053d6:	4601                	li	a2,0
    800053d8:	4585                	li	a1,1
    800053da:	f7040513          	addi	a0,s0,-144
    800053de:	96fff0ef          	jal	80004d4c <create>
    800053e2:	c911                	beqz	a0,800053f6 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053e4:	b02fe0ef          	jal	800036e6 <iunlockput>
  end_op();
    800053e8:	b65fe0ef          	jal	80003f4c <end_op>
  return 0;
    800053ec:	4501                	li	a0,0
}
    800053ee:	60aa                	ld	ra,136(sp)
    800053f0:	640a                	ld	s0,128(sp)
    800053f2:	6149                	addi	sp,sp,144
    800053f4:	8082                	ret
    end_op();
    800053f6:	b57fe0ef          	jal	80003f4c <end_op>
    return -1;
    800053fa:	557d                	li	a0,-1
    800053fc:	bfcd                	j	800053ee <sys_mkdir+0x38>

00000000800053fe <sys_mknod>:

uint64
sys_mknod(void)
{
    800053fe:	7135                	addi	sp,sp,-160
    80005400:	ed06                	sd	ra,152(sp)
    80005402:	e922                	sd	s0,144(sp)
    80005404:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005406:	ad1fe0ef          	jal	80003ed6 <begin_op>
  argint(1, &major);
    8000540a:	f6c40593          	addi	a1,s0,-148
    8000540e:	4505                	li	a0,1
    80005410:	c0cfd0ef          	jal	8000281c <argint>
  argint(2, &minor);
    80005414:	f6840593          	addi	a1,s0,-152
    80005418:	4509                	li	a0,2
    8000541a:	c02fd0ef          	jal	8000281c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000541e:	08000613          	li	a2,128
    80005422:	f7040593          	addi	a1,s0,-144
    80005426:	4501                	li	a0,0
    80005428:	c2cfd0ef          	jal	80002854 <argstr>
    8000542c:	02054563          	bltz	a0,80005456 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005430:	f6841683          	lh	a3,-152(s0)
    80005434:	f6c41603          	lh	a2,-148(s0)
    80005438:	458d                	li	a1,3
    8000543a:	f7040513          	addi	a0,s0,-144
    8000543e:	90fff0ef          	jal	80004d4c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005442:	c911                	beqz	a0,80005456 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005444:	aa2fe0ef          	jal	800036e6 <iunlockput>
  end_op();
    80005448:	b05fe0ef          	jal	80003f4c <end_op>
  return 0;
    8000544c:	4501                	li	a0,0
}
    8000544e:	60ea                	ld	ra,152(sp)
    80005450:	644a                	ld	s0,144(sp)
    80005452:	610d                	addi	sp,sp,160
    80005454:	8082                	ret
    end_op();
    80005456:	af7fe0ef          	jal	80003f4c <end_op>
    return -1;
    8000545a:	557d                	li	a0,-1
    8000545c:	bfcd                	j	8000544e <sys_mknod+0x50>

000000008000545e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000545e:	7135                	addi	sp,sp,-160
    80005460:	ed06                	sd	ra,152(sp)
    80005462:	e922                	sd	s0,144(sp)
    80005464:	e14a                	sd	s2,128(sp)
    80005466:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005468:	ca0fc0ef          	jal	80001908 <myproc>
    8000546c:	892a                	mv	s2,a0
  
  begin_op();
    8000546e:	a69fe0ef          	jal	80003ed6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005472:	08000613          	li	a2,128
    80005476:	f6040593          	addi	a1,s0,-160
    8000547a:	4501                	li	a0,0
    8000547c:	bd8fd0ef          	jal	80002854 <argstr>
    80005480:	04054363          	bltz	a0,800054c6 <sys_chdir+0x68>
    80005484:	e526                	sd	s1,136(sp)
    80005486:	f6040513          	addi	a0,s0,-160
    8000548a:	869fe0ef          	jal	80003cf2 <namei>
    8000548e:	84aa                	mv	s1,a0
    80005490:	c915                	beqz	a0,800054c4 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005492:	834fe0ef          	jal	800034c6 <ilock>
  if(ip->type != T_DIR){
    80005496:	04449703          	lh	a4,68(s1)
    8000549a:	4785                	li	a5,1
    8000549c:	02f71963          	bne	a4,a5,800054ce <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800054a0:	8526                	mv	a0,s1
    800054a2:	8dafe0ef          	jal	8000357c <iunlock>
  iput(p->cwd);
    800054a6:	15093503          	ld	a0,336(s2)
    800054aa:	9aefe0ef          	jal	80003658 <iput>
  end_op();
    800054ae:	a9ffe0ef          	jal	80003f4c <end_op>
  p->cwd = ip;
    800054b2:	14993823          	sd	s1,336(s2)
  return 0;
    800054b6:	4501                	li	a0,0
    800054b8:	64aa                	ld	s1,136(sp)
}
    800054ba:	60ea                	ld	ra,152(sp)
    800054bc:	644a                	ld	s0,144(sp)
    800054be:	690a                	ld	s2,128(sp)
    800054c0:	610d                	addi	sp,sp,160
    800054c2:	8082                	ret
    800054c4:	64aa                	ld	s1,136(sp)
    end_op();
    800054c6:	a87fe0ef          	jal	80003f4c <end_op>
    return -1;
    800054ca:	557d                	li	a0,-1
    800054cc:	b7fd                	j	800054ba <sys_chdir+0x5c>
    iunlockput(ip);
    800054ce:	8526                	mv	a0,s1
    800054d0:	a16fe0ef          	jal	800036e6 <iunlockput>
    end_op();
    800054d4:	a79fe0ef          	jal	80003f4c <end_op>
    return -1;
    800054d8:	557d                	li	a0,-1
    800054da:	64aa                	ld	s1,136(sp)
    800054dc:	bff9                	j	800054ba <sys_chdir+0x5c>

00000000800054de <sys_exec>:

uint64
sys_exec(void)
{
    800054de:	7121                	addi	sp,sp,-448
    800054e0:	ff06                	sd	ra,440(sp)
    800054e2:	fb22                	sd	s0,432(sp)
    800054e4:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800054e6:	e4840593          	addi	a1,s0,-440
    800054ea:	4505                	li	a0,1
    800054ec:	b4cfd0ef          	jal	80002838 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800054f0:	08000613          	li	a2,128
    800054f4:	f5040593          	addi	a1,s0,-176
    800054f8:	4501                	li	a0,0
    800054fa:	b5afd0ef          	jal	80002854 <argstr>
    800054fe:	87aa                	mv	a5,a0
    return -1;
    80005500:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005502:	0c07c463          	bltz	a5,800055ca <sys_exec+0xec>
    80005506:	f726                	sd	s1,424(sp)
    80005508:	f34a                	sd	s2,416(sp)
    8000550a:	ef4e                	sd	s3,408(sp)
    8000550c:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000550e:	10000613          	li	a2,256
    80005512:	4581                	li	a1,0
    80005514:	e5040513          	addi	a0,s0,-432
    80005518:	fbcfb0ef          	jal	80000cd4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000551c:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005520:	89a6                	mv	s3,s1
    80005522:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005524:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005528:	00391513          	slli	a0,s2,0x3
    8000552c:	e4040593          	addi	a1,s0,-448
    80005530:	e4843783          	ld	a5,-440(s0)
    80005534:	953e                	add	a0,a0,a5
    80005536:	a5cfd0ef          	jal	80002792 <fetchaddr>
    8000553a:	02054663          	bltz	a0,80005566 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    8000553e:	e4043783          	ld	a5,-448(s0)
    80005542:	c3a9                	beqz	a5,80005584 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005544:	decfb0ef          	jal	80000b30 <kalloc>
    80005548:	85aa                	mv	a1,a0
    8000554a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000554e:	cd01                	beqz	a0,80005566 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005550:	6605                	lui	a2,0x1
    80005552:	e4043503          	ld	a0,-448(s0)
    80005556:	a86fd0ef          	jal	800027dc <fetchstr>
    8000555a:	00054663          	bltz	a0,80005566 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    8000555e:	0905                	addi	s2,s2,1
    80005560:	09a1                	addi	s3,s3,8
    80005562:	fd4913e3          	bne	s2,s4,80005528 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005566:	f5040913          	addi	s2,s0,-176
    8000556a:	6088                	ld	a0,0(s1)
    8000556c:	c931                	beqz	a0,800055c0 <sys_exec+0xe2>
    kfree(argv[i]);
    8000556e:	ce0fb0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005572:	04a1                	addi	s1,s1,8
    80005574:	ff249be3          	bne	s1,s2,8000556a <sys_exec+0x8c>
  return -1;
    80005578:	557d                	li	a0,-1
    8000557a:	74ba                	ld	s1,424(sp)
    8000557c:	791a                	ld	s2,416(sp)
    8000557e:	69fa                	ld	s3,408(sp)
    80005580:	6a5a                	ld	s4,400(sp)
    80005582:	a0a1                	j	800055ca <sys_exec+0xec>
      argv[i] = 0;
    80005584:	0009079b          	sext.w	a5,s2
    80005588:	078e                	slli	a5,a5,0x3
    8000558a:	fd078793          	addi	a5,a5,-48
    8000558e:	97a2                	add	a5,a5,s0
    80005590:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005594:	e5040593          	addi	a1,s0,-432
    80005598:	f5040513          	addi	a0,s0,-176
    8000559c:	ba8ff0ef          	jal	80004944 <kexec>
    800055a0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055a2:	f5040993          	addi	s3,s0,-176
    800055a6:	6088                	ld	a0,0(s1)
    800055a8:	c511                	beqz	a0,800055b4 <sys_exec+0xd6>
    kfree(argv[i]);
    800055aa:	ca4fb0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055ae:	04a1                	addi	s1,s1,8
    800055b0:	ff349be3          	bne	s1,s3,800055a6 <sys_exec+0xc8>
  return ret;
    800055b4:	854a                	mv	a0,s2
    800055b6:	74ba                	ld	s1,424(sp)
    800055b8:	791a                	ld	s2,416(sp)
    800055ba:	69fa                	ld	s3,408(sp)
    800055bc:	6a5a                	ld	s4,400(sp)
    800055be:	a031                	j	800055ca <sys_exec+0xec>
  return -1;
    800055c0:	557d                	li	a0,-1
    800055c2:	74ba                	ld	s1,424(sp)
    800055c4:	791a                	ld	s2,416(sp)
    800055c6:	69fa                	ld	s3,408(sp)
    800055c8:	6a5a                	ld	s4,400(sp)
}
    800055ca:	70fa                	ld	ra,440(sp)
    800055cc:	745a                	ld	s0,432(sp)
    800055ce:	6139                	addi	sp,sp,448
    800055d0:	8082                	ret

00000000800055d2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800055d2:	7139                	addi	sp,sp,-64
    800055d4:	fc06                	sd	ra,56(sp)
    800055d6:	f822                	sd	s0,48(sp)
    800055d8:	f426                	sd	s1,40(sp)
    800055da:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800055dc:	b2cfc0ef          	jal	80001908 <myproc>
    800055e0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800055e2:	fd840593          	addi	a1,s0,-40
    800055e6:	4501                	li	a0,0
    800055e8:	a50fd0ef          	jal	80002838 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800055ec:	fc840593          	addi	a1,s0,-56
    800055f0:	fd040513          	addi	a0,s0,-48
    800055f4:	852ff0ef          	jal	80004646 <pipealloc>
    return -1;
    800055f8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800055fa:	0a054463          	bltz	a0,800056a2 <sys_pipe+0xd0>
  fd0 = -1;
    800055fe:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005602:	fd043503          	ld	a0,-48(s0)
    80005606:	f08ff0ef          	jal	80004d0e <fdalloc>
    8000560a:	fca42223          	sw	a0,-60(s0)
    8000560e:	08054163          	bltz	a0,80005690 <sys_pipe+0xbe>
    80005612:	fc843503          	ld	a0,-56(s0)
    80005616:	ef8ff0ef          	jal	80004d0e <fdalloc>
    8000561a:	fca42023          	sw	a0,-64(s0)
    8000561e:	06054063          	bltz	a0,8000567e <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005622:	4691                	li	a3,4
    80005624:	fc440613          	addi	a2,s0,-60
    80005628:	fd843583          	ld	a1,-40(s0)
    8000562c:	68a8                	ld	a0,80(s1)
    8000562e:	feffb0ef          	jal	8000161c <copyout>
    80005632:	00054e63          	bltz	a0,8000564e <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005636:	4691                	li	a3,4
    80005638:	fc040613          	addi	a2,s0,-64
    8000563c:	fd843583          	ld	a1,-40(s0)
    80005640:	0591                	addi	a1,a1,4
    80005642:	68a8                	ld	a0,80(s1)
    80005644:	fd9fb0ef          	jal	8000161c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005648:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000564a:	04055c63          	bgez	a0,800056a2 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000564e:	fc442783          	lw	a5,-60(s0)
    80005652:	07e9                	addi	a5,a5,26
    80005654:	078e                	slli	a5,a5,0x3
    80005656:	97a6                	add	a5,a5,s1
    80005658:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000565c:	fc042783          	lw	a5,-64(s0)
    80005660:	07e9                	addi	a5,a5,26
    80005662:	078e                	slli	a5,a5,0x3
    80005664:	94be                	add	s1,s1,a5
    80005666:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000566a:	fd043503          	ld	a0,-48(s0)
    8000566e:	ccffe0ef          	jal	8000433c <fileclose>
    fileclose(wf);
    80005672:	fc843503          	ld	a0,-56(s0)
    80005676:	cc7fe0ef          	jal	8000433c <fileclose>
    return -1;
    8000567a:	57fd                	li	a5,-1
    8000567c:	a01d                	j	800056a2 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000567e:	fc442783          	lw	a5,-60(s0)
    80005682:	0007c763          	bltz	a5,80005690 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005686:	07e9                	addi	a5,a5,26
    80005688:	078e                	slli	a5,a5,0x3
    8000568a:	97a6                	add	a5,a5,s1
    8000568c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005690:	fd043503          	ld	a0,-48(s0)
    80005694:	ca9fe0ef          	jal	8000433c <fileclose>
    fileclose(wf);
    80005698:	fc843503          	ld	a0,-56(s0)
    8000569c:	ca1fe0ef          	jal	8000433c <fileclose>
    return -1;
    800056a0:	57fd                	li	a5,-1
}
    800056a2:	853e                	mv	a0,a5
    800056a4:	70e2                	ld	ra,56(sp)
    800056a6:	7442                	ld	s0,48(sp)
    800056a8:	74a2                	ld	s1,40(sp)
    800056aa:	6121                	addi	sp,sp,64
    800056ac:	8082                	ret

00000000800056ae <sys_fsread>:
uint64
sys_fsread(void)
{
    800056ae:	1101                	addi	sp,sp,-32
    800056b0:	ec06                	sd	ra,24(sp)
    800056b2:	e822                	sd	s0,16(sp)
    800056b4:	1000                	addi	s0,sp,32
  uint64 uaddr;
  int max;

  argaddr(0, &uaddr);   // عنوان اليوزر
    800056b6:	fe840593          	addi	a1,s0,-24
    800056ba:	4501                	li	a0,0
    800056bc:	97cfd0ef          	jal	80002838 <argaddr>
  argint(1, &max);      // عدد العناصر
    800056c0:	fe440593          	addi	a1,s0,-28
    800056c4:	4505                	li	a0,1
    800056c6:	956fd0ef          	jal	8000281c <argint>

  return fslog_read_many((struct fs_event *)uaddr, max);
    800056ca:	fe442583          	lw	a1,-28(s0)
    800056ce:	fe843503          	ld	a0,-24(s0)
    800056d2:	227000ef          	jal	800060f8 <fslog_read_many>
    800056d6:	60e2                	ld	ra,24(sp)
    800056d8:	6442                	ld	s0,16(sp)
    800056da:	6105                	addi	sp,sp,32
    800056dc:	8082                	ret
	...

00000000800056e0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800056e0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800056e2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800056e4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800056e6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800056e8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800056ea:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800056ec:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800056ee:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800056f0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800056f2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800056f4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800056f6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800056f8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800056fa:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800056fc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800056fe:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005700:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005702:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005704:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005706:	f9dfc0ef          	jal	800026a2 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000570a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000570c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000570e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005710:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005712:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005714:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005716:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005718:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000571a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000571c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000571e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005720:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005722:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005724:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005726:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005728:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000572a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000572c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000572e:	10200073          	sret
	...

000000008000573e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000573e:	1141                	addi	sp,sp,-16
    80005740:	e422                	sd	s0,8(sp)
    80005742:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005744:	0c0007b7          	lui	a5,0xc000
    80005748:	4705                	li	a4,1
    8000574a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000574c:	0c0007b7          	lui	a5,0xc000
    80005750:	c3d8                	sw	a4,4(a5)
}
    80005752:	6422                	ld	s0,8(sp)
    80005754:	0141                	addi	sp,sp,16
    80005756:	8082                	ret

0000000080005758 <plicinithart>:

void
plicinithart(void)
{
    80005758:	1141                	addi	sp,sp,-16
    8000575a:	e406                	sd	ra,8(sp)
    8000575c:	e022                	sd	s0,0(sp)
    8000575e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005760:	97cfc0ef          	jal	800018dc <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005764:	0085171b          	slliw	a4,a0,0x8
    80005768:	0c0027b7          	lui	a5,0xc002
    8000576c:	97ba                	add	a5,a5,a4
    8000576e:	40200713          	li	a4,1026
    80005772:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005776:	00d5151b          	slliw	a0,a0,0xd
    8000577a:	0c2017b7          	lui	a5,0xc201
    8000577e:	97aa                	add	a5,a5,a0
    80005780:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005784:	60a2                	ld	ra,8(sp)
    80005786:	6402                	ld	s0,0(sp)
    80005788:	0141                	addi	sp,sp,16
    8000578a:	8082                	ret

000000008000578c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000578c:	1141                	addi	sp,sp,-16
    8000578e:	e406                	sd	ra,8(sp)
    80005790:	e022                	sd	s0,0(sp)
    80005792:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005794:	948fc0ef          	jal	800018dc <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005798:	00d5151b          	slliw	a0,a0,0xd
    8000579c:	0c2017b7          	lui	a5,0xc201
    800057a0:	97aa                	add	a5,a5,a0
  return irq;
}
    800057a2:	43c8                	lw	a0,4(a5)
    800057a4:	60a2                	ld	ra,8(sp)
    800057a6:	6402                	ld	s0,0(sp)
    800057a8:	0141                	addi	sp,sp,16
    800057aa:	8082                	ret

00000000800057ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800057ac:	1101                	addi	sp,sp,-32
    800057ae:	ec06                	sd	ra,24(sp)
    800057b0:	e822                	sd	s0,16(sp)
    800057b2:	e426                	sd	s1,8(sp)
    800057b4:	1000                	addi	s0,sp,32
    800057b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800057b8:	924fc0ef          	jal	800018dc <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800057bc:	00d5151b          	slliw	a0,a0,0xd
    800057c0:	0c2017b7          	lui	a5,0xc201
    800057c4:	97aa                	add	a5,a5,a0
    800057c6:	c3c4                	sw	s1,4(a5)
}
    800057c8:	60e2                	ld	ra,24(sp)
    800057ca:	6442                	ld	s0,16(sp)
    800057cc:	64a2                	ld	s1,8(sp)
    800057ce:	6105                	addi	sp,sp,32
    800057d0:	8082                	ret

00000000800057d2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800057d2:	1141                	addi	sp,sp,-16
    800057d4:	e406                	sd	ra,8(sp)
    800057d6:	e022                	sd	s0,0(sp)
    800057d8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800057da:	479d                	li	a5,7
    800057dc:	04a7ca63          	blt	a5,a0,80005830 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800057e0:	0001c797          	auipc	a5,0x1c
    800057e4:	35878793          	addi	a5,a5,856 # 80021b38 <disk>
    800057e8:	97aa                	add	a5,a5,a0
    800057ea:	0187c783          	lbu	a5,24(a5)
    800057ee:	e7b9                	bnez	a5,8000583c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800057f0:	00451693          	slli	a3,a0,0x4
    800057f4:	0001c797          	auipc	a5,0x1c
    800057f8:	34478793          	addi	a5,a5,836 # 80021b38 <disk>
    800057fc:	6398                	ld	a4,0(a5)
    800057fe:	9736                	add	a4,a4,a3
    80005800:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005804:	6398                	ld	a4,0(a5)
    80005806:	9736                	add	a4,a4,a3
    80005808:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000580c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005810:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005814:	97aa                	add	a5,a5,a0
    80005816:	4705                	li	a4,1
    80005818:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000581c:	0001c517          	auipc	a0,0x1c
    80005820:	33450513          	addi	a0,a0,820 # 80021b50 <disk+0x18>
    80005824:	f40fc0ef          	jal	80001f64 <wakeup>
}
    80005828:	60a2                	ld	ra,8(sp)
    8000582a:	6402                	ld	s0,0(sp)
    8000582c:	0141                	addi	sp,sp,16
    8000582e:	8082                	ret
    panic("free_desc 1");
    80005830:	00003517          	auipc	a0,0x3
    80005834:	de850513          	addi	a0,a0,-536 # 80008618 <etext+0x618>
    80005838:	fdbfa0ef          	jal	80000812 <panic>
    panic("free_desc 2");
    8000583c:	00003517          	auipc	a0,0x3
    80005840:	dec50513          	addi	a0,a0,-532 # 80008628 <etext+0x628>
    80005844:	fcffa0ef          	jal	80000812 <panic>

0000000080005848 <virtio_disk_init>:
{
    80005848:	1101                	addi	sp,sp,-32
    8000584a:	ec06                	sd	ra,24(sp)
    8000584c:	e822                	sd	s0,16(sp)
    8000584e:	e426                	sd	s1,8(sp)
    80005850:	e04a                	sd	s2,0(sp)
    80005852:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005854:	00003597          	auipc	a1,0x3
    80005858:	de458593          	addi	a1,a1,-540 # 80008638 <etext+0x638>
    8000585c:	0001c517          	auipc	a0,0x1c
    80005860:	40450513          	addi	a0,a0,1028 # 80021c60 <disk+0x128>
    80005864:	b1cfb0ef          	jal	80000b80 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005868:	100017b7          	lui	a5,0x10001
    8000586c:	4398                	lw	a4,0(a5)
    8000586e:	2701                	sext.w	a4,a4
    80005870:	747277b7          	lui	a5,0x74727
    80005874:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005878:	18f71063          	bne	a4,a5,800059f8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000587c:	100017b7          	lui	a5,0x10001
    80005880:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005882:	439c                	lw	a5,0(a5)
    80005884:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005886:	4709                	li	a4,2
    80005888:	16e79863          	bne	a5,a4,800059f8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000588c:	100017b7          	lui	a5,0x10001
    80005890:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005892:	439c                	lw	a5,0(a5)
    80005894:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005896:	16e79163          	bne	a5,a4,800059f8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000589a:	100017b7          	lui	a5,0x10001
    8000589e:	47d8                	lw	a4,12(a5)
    800058a0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058a2:	554d47b7          	lui	a5,0x554d4
    800058a6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800058aa:	14f71763          	bne	a4,a5,800059f8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058ae:	100017b7          	lui	a5,0x10001
    800058b2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058b6:	4705                	li	a4,1
    800058b8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058ba:	470d                	li	a4,3
    800058bc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800058be:	10001737          	lui	a4,0x10001
    800058c2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800058c4:	c7ffe737          	lui	a4,0xc7ffe
    800058c8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47f9ca87>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800058cc:	8ef9                	and	a3,a3,a4
    800058ce:	10001737          	lui	a4,0x10001
    800058d2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058d4:	472d                	li	a4,11
    800058d6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058d8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800058dc:	439c                	lw	a5,0(a5)
    800058de:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800058e2:	8ba1                	andi	a5,a5,8
    800058e4:	12078063          	beqz	a5,80005a04 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800058e8:	100017b7          	lui	a5,0x10001
    800058ec:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800058f0:	100017b7          	lui	a5,0x10001
    800058f4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800058f8:	439c                	lw	a5,0(a5)
    800058fa:	2781                	sext.w	a5,a5
    800058fc:	10079a63          	bnez	a5,80005a10 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005900:	100017b7          	lui	a5,0x10001
    80005904:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005908:	439c                	lw	a5,0(a5)
    8000590a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000590c:	10078863          	beqz	a5,80005a1c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005910:	471d                	li	a4,7
    80005912:	10f77b63          	bgeu	a4,a5,80005a28 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005916:	a1afb0ef          	jal	80000b30 <kalloc>
    8000591a:	0001c497          	auipc	s1,0x1c
    8000591e:	21e48493          	addi	s1,s1,542 # 80021b38 <disk>
    80005922:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005924:	a0cfb0ef          	jal	80000b30 <kalloc>
    80005928:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000592a:	a06fb0ef          	jal	80000b30 <kalloc>
    8000592e:	87aa                	mv	a5,a0
    80005930:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005932:	6088                	ld	a0,0(s1)
    80005934:	10050063          	beqz	a0,80005a34 <virtio_disk_init+0x1ec>
    80005938:	0001c717          	auipc	a4,0x1c
    8000593c:	20873703          	ld	a4,520(a4) # 80021b40 <disk+0x8>
    80005940:	0e070a63          	beqz	a4,80005a34 <virtio_disk_init+0x1ec>
    80005944:	0e078863          	beqz	a5,80005a34 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005948:	6605                	lui	a2,0x1
    8000594a:	4581                	li	a1,0
    8000594c:	b88fb0ef          	jal	80000cd4 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005950:	0001c497          	auipc	s1,0x1c
    80005954:	1e848493          	addi	s1,s1,488 # 80021b38 <disk>
    80005958:	6605                	lui	a2,0x1
    8000595a:	4581                	li	a1,0
    8000595c:	6488                	ld	a0,8(s1)
    8000595e:	b76fb0ef          	jal	80000cd4 <memset>
  memset(disk.used, 0, PGSIZE);
    80005962:	6605                	lui	a2,0x1
    80005964:	4581                	li	a1,0
    80005966:	6888                	ld	a0,16(s1)
    80005968:	b6cfb0ef          	jal	80000cd4 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000596c:	100017b7          	lui	a5,0x10001
    80005970:	4721                	li	a4,8
    80005972:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005974:	4098                	lw	a4,0(s1)
    80005976:	100017b7          	lui	a5,0x10001
    8000597a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000597e:	40d8                	lw	a4,4(s1)
    80005980:	100017b7          	lui	a5,0x10001
    80005984:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005988:	649c                	ld	a5,8(s1)
    8000598a:	0007869b          	sext.w	a3,a5
    8000598e:	10001737          	lui	a4,0x10001
    80005992:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005996:	9781                	srai	a5,a5,0x20
    80005998:	10001737          	lui	a4,0x10001
    8000599c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800059a0:	689c                	ld	a5,16(s1)
    800059a2:	0007869b          	sext.w	a3,a5
    800059a6:	10001737          	lui	a4,0x10001
    800059aa:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800059ae:	9781                	srai	a5,a5,0x20
    800059b0:	10001737          	lui	a4,0x10001
    800059b4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800059b8:	10001737          	lui	a4,0x10001
    800059bc:	4785                	li	a5,1
    800059be:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800059c0:	00f48c23          	sb	a5,24(s1)
    800059c4:	00f48ca3          	sb	a5,25(s1)
    800059c8:	00f48d23          	sb	a5,26(s1)
    800059cc:	00f48da3          	sb	a5,27(s1)
    800059d0:	00f48e23          	sb	a5,28(s1)
    800059d4:	00f48ea3          	sb	a5,29(s1)
    800059d8:	00f48f23          	sb	a5,30(s1)
    800059dc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800059e0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800059e4:	100017b7          	lui	a5,0x10001
    800059e8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800059ec:	60e2                	ld	ra,24(sp)
    800059ee:	6442                	ld	s0,16(sp)
    800059f0:	64a2                	ld	s1,8(sp)
    800059f2:	6902                	ld	s2,0(sp)
    800059f4:	6105                	addi	sp,sp,32
    800059f6:	8082                	ret
    panic("could not find virtio disk");
    800059f8:	00003517          	auipc	a0,0x3
    800059fc:	c5050513          	addi	a0,a0,-944 # 80008648 <etext+0x648>
    80005a00:	e13fa0ef          	jal	80000812 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a04:	00003517          	auipc	a0,0x3
    80005a08:	c6450513          	addi	a0,a0,-924 # 80008668 <etext+0x668>
    80005a0c:	e07fa0ef          	jal	80000812 <panic>
    panic("virtio disk should not be ready");
    80005a10:	00003517          	auipc	a0,0x3
    80005a14:	c7850513          	addi	a0,a0,-904 # 80008688 <etext+0x688>
    80005a18:	dfbfa0ef          	jal	80000812 <panic>
    panic("virtio disk has no queue 0");
    80005a1c:	00003517          	auipc	a0,0x3
    80005a20:	c8c50513          	addi	a0,a0,-884 # 800086a8 <etext+0x6a8>
    80005a24:	deffa0ef          	jal	80000812 <panic>
    panic("virtio disk max queue too short");
    80005a28:	00003517          	auipc	a0,0x3
    80005a2c:	ca050513          	addi	a0,a0,-864 # 800086c8 <etext+0x6c8>
    80005a30:	de3fa0ef          	jal	80000812 <panic>
    panic("virtio disk kalloc");
    80005a34:	00003517          	auipc	a0,0x3
    80005a38:	cb450513          	addi	a0,a0,-844 # 800086e8 <etext+0x6e8>
    80005a3c:	dd7fa0ef          	jal	80000812 <panic>

0000000080005a40 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005a40:	7159                	addi	sp,sp,-112
    80005a42:	f486                	sd	ra,104(sp)
    80005a44:	f0a2                	sd	s0,96(sp)
    80005a46:	eca6                	sd	s1,88(sp)
    80005a48:	e8ca                	sd	s2,80(sp)
    80005a4a:	e4ce                	sd	s3,72(sp)
    80005a4c:	e0d2                	sd	s4,64(sp)
    80005a4e:	fc56                	sd	s5,56(sp)
    80005a50:	f85a                	sd	s6,48(sp)
    80005a52:	f45e                	sd	s7,40(sp)
    80005a54:	f062                	sd	s8,32(sp)
    80005a56:	ec66                	sd	s9,24(sp)
    80005a58:	1880                	addi	s0,sp,112
    80005a5a:	8a2a                	mv	s4,a0
    80005a5c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005a5e:	00c52c83          	lw	s9,12(a0)
    80005a62:	001c9c9b          	slliw	s9,s9,0x1
    80005a66:	1c82                	slli	s9,s9,0x20
    80005a68:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005a6c:	0001c517          	auipc	a0,0x1c
    80005a70:	1f450513          	addi	a0,a0,500 # 80021c60 <disk+0x128>
    80005a74:	98cfb0ef          	jal	80000c00 <acquire>
  for(int i = 0; i < 3; i++){
    80005a78:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005a7a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a7c:	0001cb17          	auipc	s6,0x1c
    80005a80:	0bcb0b13          	addi	s6,s6,188 # 80021b38 <disk>
  for(int i = 0; i < 3; i++){
    80005a84:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005a86:	0001cc17          	auipc	s8,0x1c
    80005a8a:	1dac0c13          	addi	s8,s8,474 # 80021c60 <disk+0x128>
    80005a8e:	a8b9                	j	80005aec <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005a90:	00fb0733          	add	a4,s6,a5
    80005a94:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005a98:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005a9a:	0207c563          	bltz	a5,80005ac4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80005a9e:	2905                	addiw	s2,s2,1
    80005aa0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005aa2:	05590963          	beq	s2,s5,80005af4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005aa6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005aa8:	0001c717          	auipc	a4,0x1c
    80005aac:	09070713          	addi	a4,a4,144 # 80021b38 <disk>
    80005ab0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005ab2:	01874683          	lbu	a3,24(a4)
    80005ab6:	fee9                	bnez	a3,80005a90 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005ab8:	2785                	addiw	a5,a5,1
    80005aba:	0705                	addi	a4,a4,1
    80005abc:	fe979be3          	bne	a5,s1,80005ab2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005ac0:	57fd                	li	a5,-1
    80005ac2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005ac4:	01205d63          	blez	s2,80005ade <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005ac8:	f9042503          	lw	a0,-112(s0)
    80005acc:	d07ff0ef          	jal	800057d2 <free_desc>
      for(int j = 0; j < i; j++)
    80005ad0:	4785                	li	a5,1
    80005ad2:	0127d663          	bge	a5,s2,80005ade <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005ad6:	f9442503          	lw	a0,-108(s0)
    80005ada:	cf9ff0ef          	jal	800057d2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005ade:	85e2                	mv	a1,s8
    80005ae0:	0001c517          	auipc	a0,0x1c
    80005ae4:	07050513          	addi	a0,a0,112 # 80021b50 <disk+0x18>
    80005ae8:	c30fc0ef          	jal	80001f18 <sleep>
  for(int i = 0; i < 3; i++){
    80005aec:	f9040613          	addi	a2,s0,-112
    80005af0:	894e                	mv	s2,s3
    80005af2:	bf55                	j	80005aa6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005af4:	f9042503          	lw	a0,-112(s0)
    80005af8:	00451693          	slli	a3,a0,0x4

  if(write)
    80005afc:	0001c797          	auipc	a5,0x1c
    80005b00:	03c78793          	addi	a5,a5,60 # 80021b38 <disk>
    80005b04:	00a50713          	addi	a4,a0,10
    80005b08:	0712                	slli	a4,a4,0x4
    80005b0a:	973e                	add	a4,a4,a5
    80005b0c:	01703633          	snez	a2,s7
    80005b10:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b12:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005b16:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b1a:	6398                	ld	a4,0(a5)
    80005b1c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b1e:	0a868613          	addi	a2,a3,168
    80005b22:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b24:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b26:	6390                	ld	a2,0(a5)
    80005b28:	00d605b3          	add	a1,a2,a3
    80005b2c:	4741                	li	a4,16
    80005b2e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005b30:	4805                	li	a6,1
    80005b32:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005b36:	f9442703          	lw	a4,-108(s0)
    80005b3a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005b3e:	0712                	slli	a4,a4,0x4
    80005b40:	963a                	add	a2,a2,a4
    80005b42:	058a0593          	addi	a1,s4,88
    80005b46:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005b48:	0007b883          	ld	a7,0(a5)
    80005b4c:	9746                	add	a4,a4,a7
    80005b4e:	40000613          	li	a2,1024
    80005b52:	c710                	sw	a2,8(a4)
  if(write)
    80005b54:	001bb613          	seqz	a2,s7
    80005b58:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005b5c:	00166613          	ori	a2,a2,1
    80005b60:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005b64:	f9842583          	lw	a1,-104(s0)
    80005b68:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005b6c:	00250613          	addi	a2,a0,2
    80005b70:	0612                	slli	a2,a2,0x4
    80005b72:	963e                	add	a2,a2,a5
    80005b74:	577d                	li	a4,-1
    80005b76:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005b7a:	0592                	slli	a1,a1,0x4
    80005b7c:	98ae                	add	a7,a7,a1
    80005b7e:	03068713          	addi	a4,a3,48
    80005b82:	973e                	add	a4,a4,a5
    80005b84:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005b88:	6398                	ld	a4,0(a5)
    80005b8a:	972e                	add	a4,a4,a1
    80005b8c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005b90:	4689                	li	a3,2
    80005b92:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005b96:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005b9a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005b9e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005ba2:	6794                	ld	a3,8(a5)
    80005ba4:	0026d703          	lhu	a4,2(a3)
    80005ba8:	8b1d                	andi	a4,a4,7
    80005baa:	0706                	slli	a4,a4,0x1
    80005bac:	96ba                	add	a3,a3,a4
    80005bae:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005bb2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005bb6:	6798                	ld	a4,8(a5)
    80005bb8:	00275783          	lhu	a5,2(a4)
    80005bbc:	2785                	addiw	a5,a5,1
    80005bbe:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005bc2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005bc6:	100017b7          	lui	a5,0x10001
    80005bca:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005bce:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005bd2:	0001c917          	auipc	s2,0x1c
    80005bd6:	08e90913          	addi	s2,s2,142 # 80021c60 <disk+0x128>
  while(b->disk == 1) {
    80005bda:	4485                	li	s1,1
    80005bdc:	01079a63          	bne	a5,a6,80005bf0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005be0:	85ca                	mv	a1,s2
    80005be2:	8552                	mv	a0,s4
    80005be4:	b34fc0ef          	jal	80001f18 <sleep>
  while(b->disk == 1) {
    80005be8:	004a2783          	lw	a5,4(s4)
    80005bec:	fe978ae3          	beq	a5,s1,80005be0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005bf0:	f9042903          	lw	s2,-112(s0)
    80005bf4:	00290713          	addi	a4,s2,2
    80005bf8:	0712                	slli	a4,a4,0x4
    80005bfa:	0001c797          	auipc	a5,0x1c
    80005bfe:	f3e78793          	addi	a5,a5,-194 # 80021b38 <disk>
    80005c02:	97ba                	add	a5,a5,a4
    80005c04:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c08:	0001c997          	auipc	s3,0x1c
    80005c0c:	f3098993          	addi	s3,s3,-208 # 80021b38 <disk>
    80005c10:	00491713          	slli	a4,s2,0x4
    80005c14:	0009b783          	ld	a5,0(s3)
    80005c18:	97ba                	add	a5,a5,a4
    80005c1a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c1e:	854a                	mv	a0,s2
    80005c20:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c24:	bafff0ef          	jal	800057d2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005c28:	8885                	andi	s1,s1,1
    80005c2a:	f0fd                	bnez	s1,80005c10 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c2c:	0001c517          	auipc	a0,0x1c
    80005c30:	03450513          	addi	a0,a0,52 # 80021c60 <disk+0x128>
    80005c34:	864fb0ef          	jal	80000c98 <release>
}
    80005c38:	70a6                	ld	ra,104(sp)
    80005c3a:	7406                	ld	s0,96(sp)
    80005c3c:	64e6                	ld	s1,88(sp)
    80005c3e:	6946                	ld	s2,80(sp)
    80005c40:	69a6                	ld	s3,72(sp)
    80005c42:	6a06                	ld	s4,64(sp)
    80005c44:	7ae2                	ld	s5,56(sp)
    80005c46:	7b42                	ld	s6,48(sp)
    80005c48:	7ba2                	ld	s7,40(sp)
    80005c4a:	7c02                	ld	s8,32(sp)
    80005c4c:	6ce2                	ld	s9,24(sp)
    80005c4e:	6165                	addi	sp,sp,112
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
    80005c5c:	0001c497          	auipc	s1,0x1c
    80005c60:	edc48493          	addi	s1,s1,-292 # 80021b38 <disk>
    80005c64:	0001c517          	auipc	a0,0x1c
    80005c68:	ffc50513          	addi	a0,a0,-4 # 80021c60 <disk+0x128>
    80005c6c:	f95fa0ef          	jal	80000c00 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c70:	100017b7          	lui	a5,0x10001
    80005c74:	53b8                	lw	a4,96(a5)
    80005c76:	8b0d                	andi	a4,a4,3
    80005c78:	100017b7          	lui	a5,0x10001
    80005c7c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005c7e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005c82:	689c                	ld	a5,16(s1)
    80005c84:	0204d703          	lhu	a4,32(s1)
    80005c88:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005c8c:	04f70663          	beq	a4,a5,80005cd8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005c90:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005c94:	6898                	ld	a4,16(s1)
    80005c96:	0204d783          	lhu	a5,32(s1)
    80005c9a:	8b9d                	andi	a5,a5,7
    80005c9c:	078e                	slli	a5,a5,0x3
    80005c9e:	97ba                	add	a5,a5,a4
    80005ca0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005ca2:	00278713          	addi	a4,a5,2
    80005ca6:	0712                	slli	a4,a4,0x4
    80005ca8:	9726                	add	a4,a4,s1
    80005caa:	01074703          	lbu	a4,16(a4)
    80005cae:	e321                	bnez	a4,80005cee <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005cb0:	0789                	addi	a5,a5,2
    80005cb2:	0792                	slli	a5,a5,0x4
    80005cb4:	97a6                	add	a5,a5,s1
    80005cb6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005cb8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005cbc:	aa8fc0ef          	jal	80001f64 <wakeup>

    disk.used_idx += 1;
    80005cc0:	0204d783          	lhu	a5,32(s1)
    80005cc4:	2785                	addiw	a5,a5,1
    80005cc6:	17c2                	slli	a5,a5,0x30
    80005cc8:	93c1                	srli	a5,a5,0x30
    80005cca:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005cce:	6898                	ld	a4,16(s1)
    80005cd0:	00275703          	lhu	a4,2(a4)
    80005cd4:	faf71ee3          	bne	a4,a5,80005c90 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005cd8:	0001c517          	auipc	a0,0x1c
    80005cdc:	f8850513          	addi	a0,a0,-120 # 80021c60 <disk+0x128>
    80005ce0:	fb9fa0ef          	jal	80000c98 <release>
}
    80005ce4:	60e2                	ld	ra,24(sp)
    80005ce6:	6442                	ld	s0,16(sp)
    80005ce8:	64a2                	ld	s1,8(sp)
    80005cea:	6105                	addi	sp,sp,32
    80005cec:	8082                	ret
      panic("virtio_disk_intr status");
    80005cee:	00003517          	auipc	a0,0x3
    80005cf2:	a1250513          	addi	a0,a0,-1518 # 80008700 <etext+0x700>
    80005cf6:	b1dfa0ef          	jal	80000812 <panic>

0000000080005cfa <cslog_init>:
  safestrcpy(e->name, p->name, CS_NM);
}

void
cslog_init(void)
{
    80005cfa:	1141                	addi	sp,sp,-16
    80005cfc:	e406                	sd	ra,8(sp)
    80005cfe:	e022                	sd	s0,0(sp)
    80005d00:	0800                	addi	s0,sp,16
  ringbuf_init(&cs_rb, "cslog", sizeof(struct cs_event));
    80005d02:	03000613          	li	a2,48
    80005d06:	00003597          	auipc	a1,0x3
    80005d0a:	a1258593          	addi	a1,a1,-1518 # 80008718 <etext+0x718>
    80005d0e:	0001c517          	auipc	a0,0x1c
    80005d12:	f6a50513          	addi	a0,a0,-150 # 80021c78 <cs_rb>
    80005d16:	1c6000ef          	jal	80005edc <ringbuf_init>
  printf("CS sizeof(cs_event)=%ld RB_MAX_ELEM=%d\n", sizeof(struct cs_event), RB_MAX_ELEM);
    80005d1a:	10000613          	li	a2,256
    80005d1e:	03000593          	li	a1,48
    80005d22:	00003517          	auipc	a0,0x3
    80005d26:	9fe50513          	addi	a0,a0,-1538 # 80008720 <etext+0x720>
    80005d2a:	803fa0ef          	jal	8000052c <printf>
}
    80005d2e:	60a2                	ld	ra,8(sp)
    80005d30:	6402                	ld	s0,0(sp)
    80005d32:	0141                	addi	sp,sp,16
    80005d34:	8082                	ret

0000000080005d36 <cslog_push>:

void
cslog_push(struct cs_event *e)
{
    80005d36:	1141                	addi	sp,sp,-16
    80005d38:	e406                	sd	ra,8(sp)
    80005d3a:	e022                	sd	s0,0(sp)
    80005d3c:	0800                	addi	s0,sp,16
    80005d3e:	85aa                	mv	a1,a0
  e->seq = ++cs_seq;
    80005d40:	00003717          	auipc	a4,0x3
    80005d44:	bf070713          	addi	a4,a4,-1040 # 80008930 <cs_seq>
    80005d48:	631c                	ld	a5,0(a4)
    80005d4a:	0785                	addi	a5,a5,1
    80005d4c:	e31c                	sd	a5,0(a4)
    80005d4e:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    80005d50:	0001c517          	auipc	a0,0x1c
    80005d54:	f2850513          	addi	a0,a0,-216 # 80021c78 <cs_rb>
    80005d58:	1b8000ef          	jal	80005f10 <ringbuf_push>
}
    80005d5c:	60a2                	ld	ra,8(sp)
    80005d5e:	6402                	ld	s0,0(sp)
    80005d60:	0141                	addi	sp,sp,16
    80005d62:	8082                	ret

0000000080005d64 <cslog_read_many>:

int
cslog_read_many(struct cs_event *out, int max)
{
    80005d64:	1141                	addi	sp,sp,-16
    80005d66:	e406                	sd	ra,8(sp)
    80005d68:	e022                	sd	s0,0(sp)
    80005d6a:	0800                	addi	s0,sp,16
    80005d6c:	862e                	mv	a2,a1
  return ringbuf_read_many(&cs_rb, out, max);
    80005d6e:	85aa                	mv	a1,a0
    80005d70:	0001c517          	auipc	a0,0x1c
    80005d74:	f0850513          	addi	a0,a0,-248 # 80021c78 <cs_rb>
    80005d78:	204000ef          	jal	80005f7c <ringbuf_read_many>
}
    80005d7c:	60a2                	ld	ra,8(sp)
    80005d7e:	6402                	ld	s0,0(sp)
    80005d80:	0141                	addi	sp,sp,16
    80005d82:	8082                	ret

0000000080005d84 <cslog_run_start>:

void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
    80005d84:	c14d                	beqz	a0,80005e26 <cslog_run_start+0xa2>
{
    80005d86:	715d                	addi	sp,sp,-80
    80005d88:	e486                	sd	ra,72(sp)
    80005d8a:	e0a2                	sd	s0,64(sp)
    80005d8c:	fc26                	sd	s1,56(sp)
    80005d8e:	0880                	addi	s0,sp,80
    80005d90:	84aa                	mv	s1,a0
  if(p->pid <= 0) return;
    80005d92:	591c                	lw	a5,48(a0)
    80005d94:	00f05563          	blez	a5,80005d9e <cslog_run_start+0x1a>
  if(p->name[0] == 0) return;
    80005d98:	15854783          	lbu	a5,344(a0)
    80005d9c:	e791                	bnez	a5,80005da8 <cslog_run_start+0x24>

  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
    80005d9e:	60a6                	ld	ra,72(sp)
    80005da0:	6406                	ld	s0,64(sp)
    80005da2:	74e2                	ld	s1,56(sp)
    80005da4:	6161                	addi	sp,sp,80
    80005da6:	8082                	ret
    80005da8:	f84a                	sd	s2,48(sp)
  if(strncmp(p->name, "cscat", 5) == 0) return;
    80005daa:	15850913          	addi	s2,a0,344
    80005dae:	4615                	li	a2,5
    80005db0:	00003597          	auipc	a1,0x3
    80005db4:	99858593          	addi	a1,a1,-1640 # 80008748 <etext+0x748>
    80005db8:	854a                	mv	a0,s2
    80005dba:	fe7fa0ef          	jal	80000da0 <strncmp>
    80005dbe:	e119                	bnez	a0,80005dc4 <cslog_run_start+0x40>
    80005dc0:	7942                	ld	s2,48(sp)
    80005dc2:	bff1                	j	80005d9e <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    80005dc4:	4621                	li	a2,8
    80005dc6:	00003597          	auipc	a1,0x3
    80005dca:	98a58593          	addi	a1,a1,-1654 # 80008750 <etext+0x750>
    80005dce:	854a                	mv	a0,s2
    80005dd0:	fd1fa0ef          	jal	80000da0 <strncmp>
    80005dd4:	e119                	bnez	a0,80005dda <cslog_run_start+0x56>
    80005dd6:	7942                	ld	s2,48(sp)
    80005dd8:	b7d9                	j	80005d9e <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    80005dda:	03000613          	li	a2,48
    80005dde:	4581                	li	a1,0
    80005de0:	fb040513          	addi	a0,s0,-80
    80005de4:	ef1fa0ef          	jal	80000cd4 <memset>
  e->ticks = ticks;
    80005de8:	00003797          	auipc	a5,0x3
    80005dec:	b407a783          	lw	a5,-1216(a5) # 80008928 <ticks>
    80005df0:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    80005df4:	ae9fb0ef          	jal	800018dc <cpuid>
    80005df8:	faa42e23          	sw	a0,-68(s0)
  e->pid   = p->pid;
    80005dfc:	589c                	lw	a5,48(s1)
    80005dfe:	fcf42223          	sw	a5,-60(s0)
  e->state = p->state;
    80005e02:	4c9c                	lw	a5,24(s1)
    80005e04:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e->name, p->name, CS_NM);
    80005e08:	4641                	li	a2,16
    80005e0a:	85ca                	mv	a1,s2
    80005e0c:	fcc40513          	addi	a0,s0,-52
    80005e10:	802fb0ef          	jal	80000e12 <safestrcpy>
  e.type = CS_RUN_START;
    80005e14:	4785                	li	a5,1
    80005e16:	fcf42023          	sw	a5,-64(s0)
  cslog_push(&e);
    80005e1a:	fb040513          	addi	a0,s0,-80
    80005e1e:	f19ff0ef          	jal	80005d36 <cslog_push>
    80005e22:	7942                	ld	s2,48(sp)
    80005e24:	bfad                	j	80005d9e <cslog_run_start+0x1a>
    80005e26:	8082                	ret

0000000080005e28 <sys_csread>:
#include "cslog.h"


uint64
sys_csread(void)
{
    80005e28:	81010113          	addi	sp,sp,-2032
    80005e2c:	7e113423          	sd	ra,2024(sp)
    80005e30:	7e813023          	sd	s0,2016(sp)
    80005e34:	7c913c23          	sd	s1,2008(sp)
    80005e38:	7d213823          	sd	s2,2000(sp)
    80005e3c:	7f010413          	addi	s0,sp,2032
    80005e40:	bb010113          	addi	sp,sp,-1104
  uint64 uaddr = 0;
    80005e44:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80005e48:	fc042a23          	sw	zero,-44(s0)

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
    80005e4c:	fd840593          	addi	a1,s0,-40
    80005e50:	4501                	li	a0,0
    80005e52:	9e7fc0ef          	jal	80002838 <argaddr>
  argint(1, &max);
    80005e56:	fd440593          	addi	a1,s0,-44
    80005e5a:	4505                	li	a0,1
    80005e5c:	9c1fc0ef          	jal	8000281c <argint>

  if(max <= 0) return 0;
    80005e60:	fd442783          	lw	a5,-44(s0)
    80005e64:	4501                	li	a0,0
    80005e66:	04f05c63          	blez	a5,80005ebe <sys_csread+0x96>
  if(max > 64) max = 64;
    80005e6a:	04000713          	li	a4,64
    80005e6e:	00f75663          	bge	a4,a5,80005e7a <sys_csread+0x52>
    80005e72:	04000793          	li	a5,64
    80005e76:	fcf42a23          	sw	a5,-44(s0)

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);
    80005e7a:	77fd                	lui	a5,0xfffff
    80005e7c:	3d078793          	addi	a5,a5,976 # fffffffffffff3d0 <end+0xffffffff7ff9d6f8>
    80005e80:	97a2                	add	a5,a5,s0
    80005e82:	797d                	lui	s2,0xfffff
    80005e84:	3c890713          	addi	a4,s2,968 # fffffffffffff3c8 <end+0xffffffff7ff9d6f0>
    80005e88:	9722                	add	a4,a4,s0
    80005e8a:	e31c                	sd	a5,0(a4)
    80005e8c:	fd442583          	lw	a1,-44(s0)
    80005e90:	6308                	ld	a0,0(a4)
    80005e92:	ed3ff0ef          	jal	80005d64 <cslog_read_many>
    80005e96:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80005e98:	a71fb0ef          	jal	80001908 <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    80005e9c:	0014969b          	slliw	a3,s1,0x1
    80005ea0:	9ea5                	addw	a3,a3,s1
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80005ea2:	0046969b          	slliw	a3,a3,0x4
    80005ea6:	3c890793          	addi	a5,s2,968
    80005eaa:	97a2                	add	a5,a5,s0
    80005eac:	6390                	ld	a2,0(a5)
    80005eae:	fd843583          	ld	a1,-40(s0)
    80005eb2:	6928                	ld	a0,80(a0)
    80005eb4:	f68fb0ef          	jal	8000161c <copyout>
    80005eb8:	02054063          	bltz	a0,80005ed8 <sys_csread+0xb0>
    return -1;

  return n;
    80005ebc:	8526                	mv	a0,s1
}
    80005ebe:	45010113          	addi	sp,sp,1104
    80005ec2:	7e813083          	ld	ra,2024(sp)
    80005ec6:	7e013403          	ld	s0,2016(sp)
    80005eca:	7d813483          	ld	s1,2008(sp)
    80005ece:	7d013903          	ld	s2,2000(sp)
    80005ed2:	7f010113          	addi	sp,sp,2032
    80005ed6:	8082                	ret
    return -1;
    80005ed8:	557d                	li	a0,-1
    80005eda:	b7d5                	j	80005ebe <sys_csread+0x96>

0000000080005edc <ringbuf_init>:
  return (void *)(rb->buf + idx * rb->elem_size);
}

void
ringbuf_init(struct ringbuf *rb, char *name, uint elem_size)
{
    80005edc:	1101                	addi	sp,sp,-32
    80005ede:	ec06                	sd	ra,24(sp)
    80005ee0:	e822                	sd	s0,16(sp)
    80005ee2:	e426                	sd	s1,8(sp)
    80005ee4:	e04a                	sd	s2,0(sp)
    80005ee6:	1000                	addi	s0,sp,32
    80005ee8:	84aa                	mv	s1,a0
    80005eea:	8932                	mv	s2,a2
  initlock(&rb->lock, name);
    80005eec:	c95fa0ef          	jal	80000b80 <initlock>
  rb->head = 0;
    80005ef0:	0004ac23          	sw	zero,24(s1)
  rb->tail = 0;
    80005ef4:	0004ae23          	sw	zero,28(s1)
  rb->count = 0;
    80005ef8:	0204a023          	sw	zero,32(s1)
  rb->seq = 0;
    80005efc:	0204b423          	sd	zero,40(s1)
  rb->elem_size = elem_size;
    80005f00:	0324a223          	sw	s2,36(s1)
}
    80005f04:	60e2                	ld	ra,24(sp)
    80005f06:	6442                	ld	s0,16(sp)
    80005f08:	64a2                	ld	s1,8(sp)
    80005f0a:	6902                	ld	s2,0(sp)
    80005f0c:	6105                	addi	sp,sp,32
    80005f0e:	8082                	ret

0000000080005f10 <ringbuf_push>:

int
ringbuf_push(struct ringbuf *rb, void *elem)
{
    80005f10:	1101                	addi	sp,sp,-32
    80005f12:	ec06                	sd	ra,24(sp)
    80005f14:	e822                	sd	s0,16(sp)
    80005f16:	e426                	sd	s1,8(sp)
    80005f18:	e04a                	sd	s2,0(sp)
    80005f1a:	1000                	addi	s0,sp,32
    80005f1c:	84aa                	mv	s1,a0
    80005f1e:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80005f20:	ce1fa0ef          	jal	80000c00 <acquire>

  if(rb->count == RB_CAP){
    80005f24:	5098                	lw	a4,32(s1)
    80005f26:	20000793          	li	a5,512
    80005f2a:	04f70063          	beq	a4,a5,80005f6a <ringbuf_push+0x5a>
  return (void *)(rb->buf + idx * rb->elem_size);
    80005f2e:	50d0                	lw	a2,36(s1)
    80005f30:	03048513          	addi	a0,s1,48
    80005f34:	4c9c                	lw	a5,24(s1)
    80005f36:	02c787bb          	mulw	a5,a5,a2
    80005f3a:	1782                	slli	a5,a5,0x20
    80005f3c:	9381                	srli	a5,a5,0x20
    rb->tail = (rb->tail + 1) % RB_CAP;
    rb->count--;
  }

  memmove(slot_ptr(rb, rb->head), elem, rb->elem_size);
    80005f3e:	85ca                	mv	a1,s2
    80005f40:	953e                	add	a0,a0,a5
    80005f42:	deffa0ef          	jal	80000d30 <memmove>
  rb->head = (rb->head + 1) % RB_CAP;
    80005f46:	4c9c                	lw	a5,24(s1)
    80005f48:	2785                	addiw	a5,a5,1
    80005f4a:	1ff7f793          	andi	a5,a5,511
    80005f4e:	cc9c                	sw	a5,24(s1)
  rb->count++;
    80005f50:	509c                	lw	a5,32(s1)
    80005f52:	2785                	addiw	a5,a5,1
    80005f54:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80005f56:	8526                	mv	a0,s1
    80005f58:	d41fa0ef          	jal	80000c98 <release>
  return 0;
}
    80005f5c:	4501                	li	a0,0
    80005f5e:	60e2                	ld	ra,24(sp)
    80005f60:	6442                	ld	s0,16(sp)
    80005f62:	64a2                	ld	s1,8(sp)
    80005f64:	6902                	ld	s2,0(sp)
    80005f66:	6105                	addi	sp,sp,32
    80005f68:	8082                	ret
    rb->tail = (rb->tail + 1) % RB_CAP;
    80005f6a:	4cdc                	lw	a5,28(s1)
    80005f6c:	2785                	addiw	a5,a5,1
    80005f6e:	1ff7f793          	andi	a5,a5,511
    80005f72:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80005f74:	1ff00793          	li	a5,511
    80005f78:	d09c                	sw	a5,32(s1)
    80005f7a:	bf55                	j	80005f2e <ringbuf_push+0x1e>

0000000080005f7c <ringbuf_read_many>:

int
ringbuf_read_many(struct ringbuf *rb, void *out, int max)
{
    80005f7c:	7139                	addi	sp,sp,-64
    80005f7e:	fc06                	sd	ra,56(sp)
    80005f80:	f822                	sd	s0,48(sp)
    80005f82:	f04a                	sd	s2,32(sp)
    80005f84:	0080                	addi	s0,sp,64
  int n = 0;
  char *dst = (char *)out;

  if(max <= 0)
    return 0;
    80005f86:	4901                	li	s2,0
  if(max <= 0)
    80005f88:	06c05163          	blez	a2,80005fea <ringbuf_read_many+0x6e>
    80005f8c:	f426                	sd	s1,40(sp)
    80005f8e:	ec4e                	sd	s3,24(sp)
    80005f90:	e852                	sd	s4,16(sp)
    80005f92:	e456                	sd	s5,8(sp)
    80005f94:	84aa                	mv	s1,a0
    80005f96:	8a2e                	mv	s4,a1
    80005f98:	89b2                	mv	s3,a2

  acquire(&rb->lock);
    80005f9a:	c67fa0ef          	jal	80000c00 <acquire>
  int n = 0;
    80005f9e:	4901                	li	s2,0
  return (void *)(rb->buf + idx * rb->elem_size);
    80005fa0:	03048a93          	addi	s5,s1,48
  while(n < max && rb->count > 0){
    80005fa4:	509c                	lw	a5,32(s1)
    80005fa6:	cb9d                	beqz	a5,80005fdc <ringbuf_read_many+0x60>
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80005fa8:	50d0                	lw	a2,36(s1)
  return (void *)(rb->buf + idx * rb->elem_size);
    80005faa:	4ccc                	lw	a1,28(s1)
    80005fac:	02c585bb          	mulw	a1,a1,a2
    80005fb0:	1582                	slli	a1,a1,0x20
    80005fb2:	9181                	srli	a1,a1,0x20
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80005fb4:	02c9053b          	mulw	a0,s2,a2
    80005fb8:	1502                	slli	a0,a0,0x20
    80005fba:	9101                	srli	a0,a0,0x20
    80005fbc:	95d6                	add	a1,a1,s5
    80005fbe:	9552                	add	a0,a0,s4
    80005fc0:	d71fa0ef          	jal	80000d30 <memmove>
    rb->tail = (rb->tail + 1) % RB_CAP;
    80005fc4:	4cdc                	lw	a5,28(s1)
    80005fc6:	2785                	addiw	a5,a5,1
    80005fc8:	1ff7f793          	andi	a5,a5,511
    80005fcc:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80005fce:	509c                	lw	a5,32(s1)
    80005fd0:	37fd                	addiw	a5,a5,-1
    80005fd2:	d09c                	sw	a5,32(s1)
    n++;
    80005fd4:	2905                	addiw	s2,s2,1
  while(n < max && rb->count > 0){
    80005fd6:	fd2997e3          	bne	s3,s2,80005fa4 <ringbuf_read_many+0x28>
    80005fda:	894e                	mv	s2,s3
  }
  release(&rb->lock);
    80005fdc:	8526                	mv	a0,s1
    80005fde:	cbbfa0ef          	jal	80000c98 <release>

  return n;
    80005fe2:	74a2                	ld	s1,40(sp)
    80005fe4:	69e2                	ld	s3,24(sp)
    80005fe6:	6a42                	ld	s4,16(sp)
    80005fe8:	6aa2                	ld	s5,8(sp)
}
    80005fea:	854a                	mv	a0,s2
    80005fec:	70e2                	ld	ra,56(sp)
    80005fee:	7442                	ld	s0,48(sp)
    80005ff0:	7902                	ld	s2,32(sp)
    80005ff2:	6121                	addi	sp,sp,64
    80005ff4:	8082                	ret

0000000080005ff6 <ringbuf_pop>:

int
ringbuf_pop(struct ringbuf *rb, void *dst)
{
    80005ff6:	1101                	addi	sp,sp,-32
    80005ff8:	ec06                	sd	ra,24(sp)
    80005ffa:	e822                	sd	s0,16(sp)
    80005ffc:	e426                	sd	s1,8(sp)
    80005ffe:	e04a                	sd	s2,0(sp)
    80006000:	1000                	addi	s0,sp,32
    80006002:	84aa                	mv	s1,a0
    80006004:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006006:	bfbfa0ef          	jal	80000c00 <acquire>

  if(rb->count == 0){
    8000600a:	509c                	lw	a5,32(s1)
    8000600c:	cf9d                	beqz	a5,8000604a <ringbuf_pop+0x54>
  return (void *)(rb->buf + idx * rb->elem_size);
    8000600e:	50d0                	lw	a2,36(s1)
    80006010:	03048593          	addi	a1,s1,48
    80006014:	4cdc                	lw	a5,28(s1)
    80006016:	02c787bb          	mulw	a5,a5,a2
    8000601a:	1782                	slli	a5,a5,0x20
    8000601c:	9381                	srli	a5,a5,0x20
    release(&rb->lock);
    return -1;
  }

  memmove(dst, slot_ptr(rb, rb->tail), rb->elem_size);
    8000601e:	95be                	add	a1,a1,a5
    80006020:	854a                	mv	a0,s2
    80006022:	d0ffa0ef          	jal	80000d30 <memmove>
  rb->tail = (rb->tail + 1) % RB_CAP;
    80006026:	4cdc                	lw	a5,28(s1)
    80006028:	2785                	addiw	a5,a5,1
    8000602a:	1ff7f793          	andi	a5,a5,511
    8000602e:	ccdc                	sw	a5,28(s1)
  rb->count--;
    80006030:	509c                	lw	a5,32(s1)
    80006032:	37fd                	addiw	a5,a5,-1
    80006034:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80006036:	8526                	mv	a0,s1
    80006038:	c61fa0ef          	jal	80000c98 <release>
  return 0;
    8000603c:	4501                	li	a0,0
    8000603e:	60e2                	ld	ra,24(sp)
    80006040:	6442                	ld	s0,16(sp)
    80006042:	64a2                	ld	s1,8(sp)
    80006044:	6902                	ld	s2,0(sp)
    80006046:	6105                	addi	sp,sp,32
    80006048:	8082                	ret
    release(&rb->lock);
    8000604a:	8526                	mv	a0,s1
    8000604c:	c4dfa0ef          	jal	80000c98 <release>
    return -1;
    80006050:	557d                	li	a0,-1
    80006052:	b7f5                	j	8000603e <ringbuf_pop+0x48>

0000000080006054 <fill_fs_common>:
#include "fslog.h"
static struct ringbuf fs_rb;
static uint64 fs_seq = 0;
static void
fill_fs_common(struct fs_event *e)
{
    80006054:	1101                	addi	sp,sp,-32
    80006056:	ec06                	sd	ra,24(sp)
    80006058:	e822                	sd	s0,16(sp)
    8000605a:	e426                	sd	s1,8(sp)
    8000605c:	1000                	addi	s0,sp,32
    8000605e:	84aa                	mv	s1,a0
  memset(e, 0, sizeof(*e));
    80006060:	0b800613          	li	a2,184
    80006064:	4581                	li	a1,0
    80006066:	c6ffa0ef          	jal	80000cd4 <memset>
  e->ticks = ticks;
    8000606a:	00003797          	auipc	a5,0x3
    8000606e:	8be7a783          	lw	a5,-1858(a5) # 80008928 <ticks>
    80006072:	c49c                	sw	a5,8(s1)
  e->pid = myproc() ? myproc()->pid : 0;
    80006074:	895fb0ef          	jal	80001908 <myproc>
    80006078:	4781                	li	a5,0
    8000607a:	c501                	beqz	a0,80006082 <fill_fs_common+0x2e>
    8000607c:	88dfb0ef          	jal	80001908 <myproc>
    80006080:	591c                	lw	a5,48(a0)
    80006082:	c89c                	sw	a5,16(s1)
}
    80006084:	60e2                	ld	ra,24(sp)
    80006086:	6442                	ld	s0,16(sp)
    80006088:	64a2                	ld	s1,8(sp)
    8000608a:	6105                	addi	sp,sp,32
    8000608c:	8082                	ret

000000008000608e <fslog_init>:

void
fslog_init(void)
{
    8000608e:	1141                	addi	sp,sp,-16
    80006090:	e406                	sd	ra,8(sp)
    80006092:	e022                	sd	s0,0(sp)
    80006094:	0800                	addi	s0,sp,16
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
    80006096:	0b800613          	li	a2,184
    8000609a:	00002597          	auipc	a1,0x2
    8000609e:	6c658593          	addi	a1,a1,1734 # 80008760 <etext+0x760>
    800060a2:	0003c517          	auipc	a0,0x3c
    800060a6:	c0650513          	addi	a0,a0,-1018 # 80041ca8 <fs_rb>
    800060aa:	e33ff0ef          	jal	80005edc <ringbuf_init>
  printf("FS sizeof(fs_event)=%ld RB_MAX_ELEM=%d\n", sizeof(struct fs_event), RB_MAX_ELEM);
    800060ae:	10000613          	li	a2,256
    800060b2:	0b800593          	li	a1,184
    800060b6:	00002517          	auipc	a0,0x2
    800060ba:	6b250513          	addi	a0,a0,1714 # 80008768 <etext+0x768>
    800060be:	c6efa0ef          	jal	8000052c <printf>
}
    800060c2:	60a2                	ld	ra,8(sp)
    800060c4:	6402                	ld	s0,0(sp)
    800060c6:	0141                	addi	sp,sp,16
    800060c8:	8082                	ret

00000000800060ca <fslog_push>:

void
fslog_push(struct fs_event *e)
{ e->seq = ++fs_seq;
    800060ca:	1141                	addi	sp,sp,-16
    800060cc:	e406                	sd	ra,8(sp)
    800060ce:	e022                	sd	s0,0(sp)
    800060d0:	0800                	addi	s0,sp,16
    800060d2:	85aa                	mv	a1,a0
    800060d4:	00003717          	auipc	a4,0x3
    800060d8:	86470713          	addi	a4,a4,-1948 # 80008938 <fs_seq>
    800060dc:	631c                	ld	a5,0(a4)
    800060de:	0785                	addi	a5,a5,1
    800060e0:	e31c                	sd	a5,0(a4)
    800060e2:	e11c                	sd	a5,0(a0)
  ringbuf_push(&fs_rb, e);
    800060e4:	0003c517          	auipc	a0,0x3c
    800060e8:	bc450513          	addi	a0,a0,-1084 # 80041ca8 <fs_rb>
    800060ec:	e25ff0ef          	jal	80005f10 <ringbuf_push>
}
    800060f0:	60a2                	ld	ra,8(sp)
    800060f2:	6402                	ld	s0,0(sp)
    800060f4:	0141                	addi	sp,sp,16
    800060f6:	8082                	ret

00000000800060f8 <fslog_read_many>:
int
fslog_read_many(struct fs_event *out, int max)
{
    800060f8:	7111                	addi	sp,sp,-256
    800060fa:	fd86                	sd	ra,248(sp)
    800060fc:	f9a2                	sd	s0,240(sp)
    800060fe:	f5a6                	sd	s1,232(sp)
    80006100:	f1ca                	sd	s2,224(sp)
    80006102:	edce                	sd	s3,216(sp)
    80006104:	0200                	addi	s0,sp,256
    80006106:	84aa                	mv	s1,a0
    80006108:	89ae                	mv	s3,a1
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
    8000610a:	ffefb0ef          	jal	80001908 <myproc>
  while(count < max){
    8000610e:	05305463          	blez	s3,80006156 <fslog_read_many+0x5e>
    80006112:	e9d2                	sd	s4,208(sp)
    80006114:	e5d6                	sd	s5,200(sp)
    80006116:	8a2a                	mv	s4,a0
  int count = 0;
    80006118:	4901                	li	s2,0
    if(ringbuf_pop(&fs_rb, &e) != 0)
    8000611a:	0003ca97          	auipc	s5,0x3c
    8000611e:	b8ea8a93          	addi	s5,s5,-1138 # 80041ca8 <fs_rb>
    80006122:	f0840593          	addi	a1,s0,-248
    80006126:	8556                	mv	a0,s5
    80006128:	ecfff0ef          	jal	80005ff6 <ringbuf_pop>
    8000612c:	e51d                	bnez	a0,8000615a <fslog_read_many+0x62>
      break;

    uint64 dst = (uint64)out + count * sizeof(struct fs_event);

    if(copyout(p->pagetable, dst, (char *)&e, sizeof(struct fs_event)) < 0)
    8000612e:	0b800693          	li	a3,184
    80006132:	f0840613          	addi	a2,s0,-248
    80006136:	85a6                	mv	a1,s1
    80006138:	050a3503          	ld	a0,80(s4)
    8000613c:	ce0fb0ef          	jal	8000161c <copyout>
    80006140:	02054763          	bltz	a0,8000616e <fslog_read_many+0x76>
      break;

    count++;
    80006144:	2905                	addiw	s2,s2,1
  while(count < max){
    80006146:	0b848493          	addi	s1,s1,184
    8000614a:	fd299ce3          	bne	s3,s2,80006122 <fslog_read_many+0x2a>
    8000614e:	894e                	mv	s2,s3
    80006150:	6a4e                	ld	s4,208(sp)
    80006152:	6aae                	ld	s5,200(sp)
    80006154:	a029                	j	8000615e <fslog_read_many+0x66>
  int count = 0;
    80006156:	4901                	li	s2,0
    80006158:	a019                	j	8000615e <fslog_read_many+0x66>
    8000615a:	6a4e                	ld	s4,208(sp)
    8000615c:	6aae                	ld	s5,200(sp)
  }

  return count;
}
    8000615e:	854a                	mv	a0,s2
    80006160:	70ee                	ld	ra,248(sp)
    80006162:	744e                	ld	s0,240(sp)
    80006164:	74ae                	ld	s1,232(sp)
    80006166:	790e                	ld	s2,224(sp)
    80006168:	69ee                	ld	s3,216(sp)
    8000616a:	6111                	addi	sp,sp,256
    8000616c:	8082                	ret
    8000616e:	6a4e                	ld	s4,208(sp)
    80006170:	6aae                	ld	s5,200(sp)
    80006172:	b7f5                	j	8000615e <fslog_read_many+0x66>

0000000080006174 <fslog_bread_req>:
void
fslog_bread_req(int dev, int blockno)
{
    80006174:	7115                	addi	sp,sp,-224
    80006176:	ed86                	sd	ra,216(sp)
    80006178:	e9a2                	sd	s0,208(sp)
    8000617a:	e5a6                	sd	s1,200(sp)
    8000617c:	e1ca                	sd	s2,192(sp)
    8000617e:	1180                	addi	s0,sp,224
    80006180:	892a                	mv	s2,a0
    80006182:	84ae                	mv	s1,a1
  struct fs_event e;
  fill_fs_common(&e);
    80006184:	f2840513          	addi	a0,s0,-216
    80006188:	ecdff0ef          	jal	80006054 <fill_fs_common>
  e.type = FS_BREAD_REQ;
    8000618c:	4785                	li	a5,1
    8000618e:	f2f42a23          	sw	a5,-204(s0)
  e.dev = dev;
    80006192:	f3242e23          	sw	s2,-196(s0)
  e.blockno = blockno;
    80006196:	f4942023          	sw	s1,-192(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    8000619a:	4641                	li	a2,16
    8000619c:	00002597          	auipc	a1,0x2
    800061a0:	5f458593          	addi	a1,a1,1524 # 80008790 <etext+0x790>
    800061a4:	f7c40513          	addi	a0,s0,-132
    800061a8:	c6bfa0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    800061ac:	f2840513          	addi	a0,s0,-216
    800061b0:	f1bff0ef          	jal	800060ca <fslog_push>
}
    800061b4:	60ee                	ld	ra,216(sp)
    800061b6:	644e                	ld	s0,208(sp)
    800061b8:	64ae                	ld	s1,200(sp)
    800061ba:	690e                	ld	s2,192(sp)
    800061bc:	612d                	addi	sp,sp,224
    800061be:	8082                	ret

00000000800061c0 <fslog_bget_scan>:
void
fslog_bget_scan(int dev, int blockno, int buf_id,
                int refcnt, int valid, int lru_pos,
                int scan_dir, int scan_step, int found)
{
    800061c0:	716d                	addi	sp,sp,-272
    800061c2:	e606                	sd	ra,264(sp)
    800061c4:	e222                	sd	s0,256(sp)
    800061c6:	fda6                	sd	s1,248(sp)
    800061c8:	f9ca                	sd	s2,240(sp)
    800061ca:	f5ce                	sd	s3,232(sp)
    800061cc:	f1d2                	sd	s4,224(sp)
    800061ce:	edd6                	sd	s5,216(sp)
    800061d0:	e9da                	sd	s6,208(sp)
    800061d2:	e5de                	sd	s7,200(sp)
    800061d4:	e1e2                	sd	s8,192(sp)
    800061d6:	0a00                	addi	s0,sp,272
    800061d8:	8c2a                	mv	s8,a0
    800061da:	8bae                	mv	s7,a1
    800061dc:	8b32                	mv	s6,a2
    800061de:	89b6                	mv	s3,a3
    800061e0:	893a                	mv	s2,a4
    800061e2:	84be                	mv	s1,a5
    800061e4:	8ac2                	mv	s5,a6
    800061e6:	8a46                	mv	s4,a7
  struct fs_event e;
  fill_fs_common(&e);
    800061e8:	ef840513          	addi	a0,s0,-264
    800061ec:	e69ff0ef          	jal	80006054 <fill_fs_common>
  e.type = FS_BGET_SCAN;
    800061f0:	4789                	li	a5,2
    800061f2:	f0f42223          	sw	a5,-252(s0)
  e.dev = dev;
    800061f6:	f1842623          	sw	s8,-244(s0)
  e.blockno = blockno;
    800061fa:	f1742823          	sw	s7,-240(s0)
  e.buf_id = buf_id;
    800061fe:	f1642c23          	sw	s6,-232(s0)
  e.ref_before = refcnt;
    80006202:	f1342e23          	sw	s3,-228(s0)
  e.ref_after = refcnt;
    80006206:	f3342023          	sw	s3,-224(s0)
  e.valid_before = valid;
    8000620a:	f3242223          	sw	s2,-220(s0)
  e.valid_after = valid;
    8000620e:	f3242423          	sw	s2,-216(s0)
  e.lru_before = lru_pos;
    80006212:	f2942a23          	sw	s1,-204(s0)
  e.lru_after = lru_pos;
    80006216:	f2942c23          	sw	s1,-200(s0)
  e.scan_dir = scan_dir;
    8000621a:	f3542e23          	sw	s5,-196(s0)
  e.scan_step = scan_step;
    8000621e:	f5442023          	sw	s4,-192(s0)
  e.found = found;
    80006222:	401c                	lw	a5,0(s0)
    80006224:	f4f42223          	sw	a5,-188(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    80006228:	4641                	li	a2,16
    8000622a:	00002597          	auipc	a1,0x2
    8000622e:	56658593          	addi	a1,a1,1382 # 80008790 <etext+0x790>
    80006232:	f4c40513          	addi	a0,s0,-180
    80006236:	bddfa0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    8000623a:	ef840513          	addi	a0,s0,-264
    8000623e:	e8dff0ef          	jal	800060ca <fslog_push>
}
    80006242:	60b2                	ld	ra,264(sp)
    80006244:	6412                	ld	s0,256(sp)
    80006246:	74ee                	ld	s1,248(sp)
    80006248:	794e                	ld	s2,240(sp)
    8000624a:	79ae                	ld	s3,232(sp)
    8000624c:	7a0e                	ld	s4,224(sp)
    8000624e:	6aee                	ld	s5,216(sp)
    80006250:	6b4e                	ld	s6,208(sp)
    80006252:	6bae                	ld	s7,200(sp)
    80006254:	6c0e                	ld	s8,192(sp)
    80006256:	6151                	addi	sp,sp,272
    80006258:	8082                	ret

000000008000625a <fslog_bget_hit>:
void
fslog_bget_hit(int dev, int blockno, int buf_id,
               int ref_before, int ref_after,
               int valid,
               int lru_pos)
{
    8000625a:	716d                	addi	sp,sp,-272
    8000625c:	e606                	sd	ra,264(sp)
    8000625e:	e222                	sd	s0,256(sp)
    80006260:	fda6                	sd	s1,248(sp)
    80006262:	f9ca                	sd	s2,240(sp)
    80006264:	f5ce                	sd	s3,232(sp)
    80006266:	f1d2                	sd	s4,224(sp)
    80006268:	edd6                	sd	s5,216(sp)
    8000626a:	e9da                	sd	s6,208(sp)
    8000626c:	e5de                	sd	s7,200(sp)
    8000626e:	0a00                	addi	s0,sp,272
    80006270:	8baa                	mv	s7,a0
    80006272:	8b2e                	mv	s6,a1
    80006274:	8ab2                	mv	s5,a2
    80006276:	8a36                	mv	s4,a3
    80006278:	89ba                	mv	s3,a4
    8000627a:	893e                	mv	s2,a5
    8000627c:	84c2                	mv	s1,a6
  struct fs_event e;
  fill_fs_common(&e);
    8000627e:	ef840513          	addi	a0,s0,-264
    80006282:	dd3ff0ef          	jal	80006054 <fill_fs_common>
  e.type = FS_BGET_HIT;
    80006286:	478d                	li	a5,3
    80006288:	f0f42223          	sw	a5,-252(s0)
  e.dev = dev;
    8000628c:	f1742623          	sw	s7,-244(s0)
  e.blockno = blockno;
    80006290:	f1642823          	sw	s6,-240(s0)
  e.buf_id = buf_id;
    80006294:	f1542c23          	sw	s5,-232(s0)
  e.ref_before = ref_before;
    80006298:	f1442e23          	sw	s4,-228(s0)
  e.ref_after = ref_after;
    8000629c:	f3342023          	sw	s3,-224(s0)
  e.valid_before = valid;
    800062a0:	f3242223          	sw	s2,-220(s0)
  e.valid_after = valid;
    800062a4:	f3242423          	sw	s2,-216(s0)
  e.locked_before = 0;
    800062a8:	f2042623          	sw	zero,-212(s0)
  e.locked_after = 1;
    800062ac:	4785                	li	a5,1
    800062ae:	f2f42823          	sw	a5,-208(s0)
  e.lru_before = lru_pos;
    800062b2:	f2942a23          	sw	s1,-204(s0)
  e.lru_after = lru_pos;
    800062b6:	f2942c23          	sw	s1,-200(s0)
  e.found = 1;
    800062ba:	f4f42223          	sw	a5,-188(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    800062be:	4641                	li	a2,16
    800062c0:	00002597          	auipc	a1,0x2
    800062c4:	4d058593          	addi	a1,a1,1232 # 80008790 <etext+0x790>
    800062c8:	f4c40513          	addi	a0,s0,-180
    800062cc:	b47fa0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    800062d0:	ef840513          	addi	a0,s0,-264
    800062d4:	df7ff0ef          	jal	800060ca <fslog_push>
}
    800062d8:	60b2                	ld	ra,264(sp)
    800062da:	6412                	ld	s0,256(sp)
    800062dc:	74ee                	ld	s1,248(sp)
    800062de:	794e                	ld	s2,240(sp)
    800062e0:	79ae                	ld	s3,232(sp)
    800062e2:	7a0e                	ld	s4,224(sp)
    800062e4:	6aee                	ld	s5,216(sp)
    800062e6:	6b4e                	ld	s6,208(sp)
    800062e8:	6bae                	ld	s7,200(sp)
    800062ea:	6151                	addi	sp,sp,272
    800062ec:	8082                	ret

00000000800062ee <fslog_bget_miss>:
void
fslog_bget_miss(int dev, int blockno, int old_blockno, int buf_id,
                int old_valid,
                int lru_pos)
{
    800062ee:	7111                	addi	sp,sp,-256
    800062f0:	fd86                	sd	ra,248(sp)
    800062f2:	f9a2                	sd	s0,240(sp)
    800062f4:	f5a6                	sd	s1,232(sp)
    800062f6:	f1ca                	sd	s2,224(sp)
    800062f8:	edce                	sd	s3,216(sp)
    800062fa:	e9d2                	sd	s4,208(sp)
    800062fc:	e5d6                	sd	s5,200(sp)
    800062fe:	e1da                	sd	s6,192(sp)
    80006300:	0200                	addi	s0,sp,256
    80006302:	8b2a                	mv	s6,a0
    80006304:	8aae                	mv	s5,a1
    80006306:	8a32                	mv	s4,a2
    80006308:	89b6                	mv	s3,a3
    8000630a:	893a                	mv	s2,a4
    8000630c:	84be                	mv	s1,a5
  struct fs_event e;
  fill_fs_common(&e);
    8000630e:	f0840513          	addi	a0,s0,-248
    80006312:	d43ff0ef          	jal	80006054 <fill_fs_common>
  e.type = FS_BGET_MISS;
    80006316:	4791                	li	a5,4
    80006318:	f0f42a23          	sw	a5,-236(s0)
  e.dev = dev;
    8000631c:	f1642e23          	sw	s6,-228(s0)
  e.blockno = blockno;
    80006320:	f3542023          	sw	s5,-224(s0)
  e.old_blockno = old_blockno;
    80006324:	f3442223          	sw	s4,-220(s0)
  e.buf_id = buf_id;
    80006328:	f3342423          	sw	s3,-216(s0)
  e.ref_before = 0;
    8000632c:	f2042623          	sw	zero,-212(s0)
  e.ref_after = 1;
    80006330:	4785                	li	a5,1
    80006332:	f2f42823          	sw	a5,-208(s0)
  e.valid_before = old_valid;
    80006336:	f3242a23          	sw	s2,-204(s0)
  e.valid_after = 0;
    8000633a:	f2042c23          	sw	zero,-200(s0)
  e.locked_before = 0;
    8000633e:	f2042e23          	sw	zero,-196(s0)
  e.locked_after = 1;
    80006342:	f4f42023          	sw	a5,-192(s0)
  e.lru_before = lru_pos;
    80006346:	f4942223          	sw	s1,-188(s0)
  e.lru_after = lru_pos;
    8000634a:	f4942423          	sw	s1,-184(s0)
  e.found = 1;
    8000634e:	f4f42a23          	sw	a5,-172(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    80006352:	4641                	li	a2,16
    80006354:	00002597          	auipc	a1,0x2
    80006358:	43c58593          	addi	a1,a1,1084 # 80008790 <etext+0x790>
    8000635c:	f5c40513          	addi	a0,s0,-164
    80006360:	ab3fa0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    80006364:	f0840513          	addi	a0,s0,-248
    80006368:	d63ff0ef          	jal	800060ca <fslog_push>
}
    8000636c:	70ee                	ld	ra,248(sp)
    8000636e:	744e                	ld	s0,240(sp)
    80006370:	74ae                	ld	s1,232(sp)
    80006372:	790e                	ld	s2,224(sp)
    80006374:	69ee                	ld	s3,216(sp)
    80006376:	6a4e                	ld	s4,208(sp)
    80006378:	6aae                	ld	s5,200(sp)
    8000637a:	6b0e                	ld	s6,192(sp)
    8000637c:	6111                	addi	sp,sp,256
    8000637e:	8082                	ret

0000000080006380 <fslog_bread_fill>:
void
fslog_bread_fill(int dev, int blockno, int buf_id,
                 int refcnt, int lru_pos)
{
    80006380:	7111                	addi	sp,sp,-256
    80006382:	fd86                	sd	ra,248(sp)
    80006384:	f9a2                	sd	s0,240(sp)
    80006386:	f5a6                	sd	s1,232(sp)
    80006388:	f1ca                	sd	s2,224(sp)
    8000638a:	edce                	sd	s3,216(sp)
    8000638c:	e9d2                	sd	s4,208(sp)
    8000638e:	e5d6                	sd	s5,200(sp)
    80006390:	0200                	addi	s0,sp,256
    80006392:	8aaa                	mv	s5,a0
    80006394:	8a2e                	mv	s4,a1
    80006396:	89b2                	mv	s3,a2
    80006398:	8936                	mv	s2,a3
    8000639a:	84ba                	mv	s1,a4
  struct fs_event e;
  fill_fs_common(&e);
    8000639c:	f0840513          	addi	a0,s0,-248
    800063a0:	cb5ff0ef          	jal	80006054 <fill_fs_common>
  e.type = FS_BREAD_FILL;
    800063a4:	4795                	li	a5,5
    800063a6:	f0f42a23          	sw	a5,-236(s0)
  e.dev = dev;
    800063aa:	f1542e23          	sw	s5,-228(s0)
  e.blockno = blockno;
    800063ae:	f3442023          	sw	s4,-224(s0)
  e.buf_id = buf_id;
    800063b2:	f3342423          	sw	s3,-216(s0)
  e.ref_before = refcnt;
    800063b6:	f3242623          	sw	s2,-212(s0)
  e.ref_after = refcnt;
    800063ba:	f3242823          	sw	s2,-208(s0)
  e.valid_before = 0;
    800063be:	f2042a23          	sw	zero,-204(s0)
  e.valid_after = 1;
    800063c2:	4785                	li	a5,1
    800063c4:	f2f42c23          	sw	a5,-200(s0)
  e.locked_before = 1;
    800063c8:	f2f42e23          	sw	a5,-196(s0)
  e.locked_after = 1;
    800063cc:	f4f42023          	sw	a5,-192(s0)
  e.lru_before = lru_pos;
    800063d0:	f4942223          	sw	s1,-188(s0)
  e.lru_after = lru_pos;
    800063d4:	f4942423          	sw	s1,-184(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    800063d8:	4641                	li	a2,16
    800063da:	00002597          	auipc	a1,0x2
    800063de:	3b658593          	addi	a1,a1,950 # 80008790 <etext+0x790>
    800063e2:	f5c40513          	addi	a0,s0,-164
    800063e6:	a2dfa0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    800063ea:	f0840513          	addi	a0,s0,-248
    800063ee:	cddff0ef          	jal	800060ca <fslog_push>
}
    800063f2:	70ee                	ld	ra,248(sp)
    800063f4:	744e                	ld	s0,240(sp)
    800063f6:	74ae                	ld	s1,232(sp)
    800063f8:	790e                	ld	s2,224(sp)
    800063fa:	69ee                	ld	s3,216(sp)
    800063fc:	6a4e                	ld	s4,208(sp)
    800063fe:	6aae                	ld	s5,200(sp)
    80006400:	6111                	addi	sp,sp,256
    80006402:	8082                	ret

0000000080006404 <fslog_bwrite_ev>:
void
fslog_bwrite_ev(int dev, int blockno, int buf_id,
                int refcnt, int valid, int lru_pos)
{
    80006404:	7111                	addi	sp,sp,-256
    80006406:	fd86                	sd	ra,248(sp)
    80006408:	f9a2                	sd	s0,240(sp)
    8000640a:	f5a6                	sd	s1,232(sp)
    8000640c:	f1ca                	sd	s2,224(sp)
    8000640e:	edce                	sd	s3,216(sp)
    80006410:	e9d2                	sd	s4,208(sp)
    80006412:	e5d6                	sd	s5,200(sp)
    80006414:	e1da                	sd	s6,192(sp)
    80006416:	0200                	addi	s0,sp,256
    80006418:	8b2a                	mv	s6,a0
    8000641a:	8aae                	mv	s5,a1
    8000641c:	8a32                	mv	s4,a2
    8000641e:	89b6                	mv	s3,a3
    80006420:	893a                	mv	s2,a4
    80006422:	84be                	mv	s1,a5
  struct fs_event e;
  fill_fs_common(&e);
    80006424:	f0840513          	addi	a0,s0,-248
    80006428:	c2dff0ef          	jal	80006054 <fill_fs_common>
  e.type = FS_BWRITE;
    8000642c:	4799                	li	a5,6
    8000642e:	f0f42a23          	sw	a5,-236(s0)
  e.dev = dev;
    80006432:	f1642e23          	sw	s6,-228(s0)
  e.blockno = blockno;
    80006436:	f3542023          	sw	s5,-224(s0)
  e.buf_id = buf_id;
    8000643a:	f3442423          	sw	s4,-216(s0)
  e.ref_before = refcnt;
    8000643e:	f3342623          	sw	s3,-212(s0)
  e.ref_after = refcnt;
    80006442:	f3342823          	sw	s3,-208(s0)
  e.valid_before = valid;
    80006446:	f3242a23          	sw	s2,-204(s0)
  e.valid_after = valid;
    8000644a:	f3242c23          	sw	s2,-200(s0)
  e.locked_before = 1;
    8000644e:	4785                	li	a5,1
    80006450:	f2f42e23          	sw	a5,-196(s0)
  e.locked_after = 1;
    80006454:	f4f42023          	sw	a5,-192(s0)
  e.lru_before = lru_pos;
    80006458:	f4942223          	sw	s1,-188(s0)
  e.lru_after = lru_pos;
    8000645c:	f4942423          	sw	s1,-184(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    80006460:	4641                	li	a2,16
    80006462:	00002597          	auipc	a1,0x2
    80006466:	32e58593          	addi	a1,a1,814 # 80008790 <etext+0x790>
    8000646a:	f5c40513          	addi	a0,s0,-164
    8000646e:	9a5fa0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    80006472:	f0840513          	addi	a0,s0,-248
    80006476:	c55ff0ef          	jal	800060ca <fslog_push>
}
    8000647a:	70ee                	ld	ra,248(sp)
    8000647c:	744e                	ld	s0,240(sp)
    8000647e:	74ae                	ld	s1,232(sp)
    80006480:	790e                	ld	s2,224(sp)
    80006482:	69ee                	ld	s3,216(sp)
    80006484:	6a4e                	ld	s4,208(sp)
    80006486:	6aae                	ld	s5,200(sp)
    80006488:	6b0e                	ld	s6,192(sp)
    8000648a:	6111                	addi	sp,sp,256
    8000648c:	8082                	ret

000000008000648e <fslog_brelease_ev>:
void
fslog_brelease_ev(int dev, int blockno, int buf_id,
                  int ref_before, int ref_after,
                  int valid,
                  int lru_before, int lru_after)
{
    8000648e:	716d                	addi	sp,sp,-272
    80006490:	e606                	sd	ra,264(sp)
    80006492:	e222                	sd	s0,256(sp)
    80006494:	fda6                	sd	s1,248(sp)
    80006496:	f9ca                	sd	s2,240(sp)
    80006498:	f5ce                	sd	s3,232(sp)
    8000649a:	f1d2                	sd	s4,224(sp)
    8000649c:	edd6                	sd	s5,216(sp)
    8000649e:	e9da                	sd	s6,208(sp)
    800064a0:	e5de                	sd	s7,200(sp)
    800064a2:	e1e2                	sd	s8,192(sp)
    800064a4:	0a00                	addi	s0,sp,272
    800064a6:	8c2a                	mv	s8,a0
    800064a8:	8bae                	mv	s7,a1
    800064aa:	8b32                	mv	s6,a2
    800064ac:	8ab6                	mv	s5,a3
    800064ae:	8a3a                	mv	s4,a4
    800064b0:	84be                	mv	s1,a5
    800064b2:	89c2                	mv	s3,a6
    800064b4:	8946                	mv	s2,a7
  struct fs_event e;
  fill_fs_common(&e);
    800064b6:	ef840513          	addi	a0,s0,-264
    800064ba:	b9bff0ef          	jal	80006054 <fill_fs_common>
  e.type = FS_BRELEASE;
    800064be:	479d                	li	a5,7
    800064c0:	f0f42223          	sw	a5,-252(s0)
  e.dev = dev;
    800064c4:	f1842623          	sw	s8,-244(s0)
  e.blockno = blockno;
    800064c8:	f1742823          	sw	s7,-240(s0)
  e.buf_id = buf_id;
    800064cc:	f1642c23          	sw	s6,-232(s0)
  e.ref_before = ref_before;
    800064d0:	f1542e23          	sw	s5,-228(s0)
  e.ref_after = ref_after;
    800064d4:	f3442023          	sw	s4,-224(s0)
  e.valid_before = valid;
    800064d8:	f2942223          	sw	s1,-220(s0)
  e.valid_after = valid;
    800064dc:	f2942423          	sw	s1,-216(s0)
  e.locked_before = 1;
    800064e0:	4785                	li	a5,1
    800064e2:	f2f42623          	sw	a5,-212(s0)
  e.locked_after = 0;
    800064e6:	f2042823          	sw	zero,-208(s0)
  e.lru_before = lru_before;
    800064ea:	f3342a23          	sw	s3,-204(s0)
  e.lru_after = lru_after;
    800064ee:	f3242c23          	sw	s2,-200(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    800064f2:	4641                	li	a2,16
    800064f4:	00002597          	auipc	a1,0x2
    800064f8:	29c58593          	addi	a1,a1,668 # 80008790 <etext+0x790>
    800064fc:	f4c40513          	addi	a0,s0,-180
    80006500:	913fa0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    80006504:	ef840513          	addi	a0,s0,-264
    80006508:	bc3ff0ef          	jal	800060ca <fslog_push>
}
    8000650c:	60b2                	ld	ra,264(sp)
    8000650e:	6412                	ld	s0,256(sp)
    80006510:	74ee                	ld	s1,248(sp)
    80006512:	794e                	ld	s2,240(sp)
    80006514:	79ae                	ld	s3,232(sp)
    80006516:	7a0e                	ld	s4,224(sp)
    80006518:	6aee                	ld	s5,216(sp)
    8000651a:	6b4e                	ld	s6,208(sp)
    8000651c:	6bae                	ld	s7,200(sp)
    8000651e:	6c0e                	ld	s8,192(sp)
    80006520:	6151                	addi	sp,sp,272
    80006522:	8082                	ret

0000000080006524 <fslog_begin>:
void fslog_begin(int before, int after){
    80006524:	7115                	addi	sp,sp,-224
    80006526:	ed86                	sd	ra,216(sp)
    80006528:	e9a2                	sd	s0,208(sp)
    8000652a:	e5a6                	sd	s1,200(sp)
    8000652c:	e1ca                	sd	s2,192(sp)
    8000652e:	1180                	addi	s0,sp,224
    80006530:	892a                	mv	s2,a0
    80006532:	84ae                	mv	s1,a1
  struct fs_event e;
  fill_fs_common(&e);
    80006534:	f2840513          	addi	a0,s0,-216
    80006538:	b1dff0ef          	jal	80006054 <fill_fs_common>

  e.type = FS_LOG_BEGIN;
    8000653c:	47d1                	li	a5,20
    8000653e:	f2f42a23          	sw	a5,-204(s0)
  e.ref_before = before;
    80006542:	f5242623          	sw	s2,-180(s0)
  e.ref_after = after;
    80006546:	f4942823          	sw	s1,-176(s0)

  safestrcpy(e.name, "LOG", FS_NM);
    8000654a:	4641                	li	a2,16
    8000654c:	00002597          	auipc	a1,0x2
    80006550:	24c58593          	addi	a1,a1,588 # 80008798 <etext+0x798>
    80006554:	f7c40513          	addi	a0,s0,-132
    80006558:	8bbfa0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    8000655c:	f2840513          	addi	a0,s0,-216
    80006560:	b6bff0ef          	jal	800060ca <fslog_push>
}
    80006564:	60ee                	ld	ra,216(sp)
    80006566:	644e                	ld	s0,208(sp)
    80006568:	64ae                	ld	s1,200(sp)
    8000656a:	690e                	ld	s2,192(sp)
    8000656c:	612d                	addi	sp,sp,224
    8000656e:	8082                	ret

0000000080006570 <fslog_write>:
void fslog_write(int blockno, int existed, int n_before, int n_after){
    80006570:	7151                	addi	sp,sp,-240
    80006572:	f586                	sd	ra,232(sp)
    80006574:	f1a2                	sd	s0,224(sp)
    80006576:	eda6                	sd	s1,216(sp)
    80006578:	e9ca                	sd	s2,208(sp)
    8000657a:	e5ce                	sd	s3,200(sp)
    8000657c:	e1d2                	sd	s4,192(sp)
    8000657e:	1980                	addi	s0,sp,240
    80006580:	8a2a                	mv	s4,a0
    80006582:	84ae                	mv	s1,a1
    80006584:	89b2                	mv	s3,a2
    80006586:	8936                	mv	s2,a3
  struct fs_event e;
  fill_fs_common(&e);
    80006588:	f1840513          	addi	a0,s0,-232
    8000658c:	ac9ff0ef          	jal	80006054 <fill_fs_common>

  e.type = FS_LOG_WRITE;
    80006590:	47d5                	li	a5,21
    80006592:	f2f42223          	sw	a5,-220(s0)
  e.blockno = blockno;
    80006596:	f3442823          	sw	s4,-208(s0)
  e.ref_before = n_before;
    8000659a:	f3342e23          	sw	s3,-196(s0)
  e.ref_after = n_after;
    8000659e:	f5242023          	sw	s2,-192(s0)
  e.found = existed;
    800065a2:	f6942223          	sw	s1,-156(s0)

  safestrcpy(e.name, "LOG", FS_NM);
    800065a6:	4641                	li	a2,16
    800065a8:	00002597          	auipc	a1,0x2
    800065ac:	1f058593          	addi	a1,a1,496 # 80008798 <etext+0x798>
    800065b0:	f6c40513          	addi	a0,s0,-148
    800065b4:	85ffa0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    800065b8:	f1840513          	addi	a0,s0,-232
    800065bc:	b0fff0ef          	jal	800060ca <fslog_push>
}
    800065c0:	70ae                	ld	ra,232(sp)
    800065c2:	740e                	ld	s0,224(sp)
    800065c4:	64ee                	ld	s1,216(sp)
    800065c6:	694e                	ld	s2,208(sp)
    800065c8:	69ae                	ld	s3,200(sp)
    800065ca:	6a0e                	ld	s4,192(sp)
    800065cc:	616d                	addi	sp,sp,240
    800065ce:	8082                	ret

00000000800065d0 <fslog_end>:

void fslog_end(int before, int after, int will_commit){
    800065d0:	7151                	addi	sp,sp,-240
    800065d2:	f586                	sd	ra,232(sp)
    800065d4:	f1a2                	sd	s0,224(sp)
    800065d6:	eda6                	sd	s1,216(sp)
    800065d8:	e9ca                	sd	s2,208(sp)
    800065da:	e5ce                	sd	s3,200(sp)
    800065dc:	1980                	addi	s0,sp,240
    800065de:	89aa                	mv	s3,a0
    800065e0:	892e                	mv	s2,a1
    800065e2:	84b2                	mv	s1,a2
  struct fs_event e;
  fill_fs_common(&e);
    800065e4:	f1840513          	addi	a0,s0,-232
    800065e8:	a6dff0ef          	jal	80006054 <fill_fs_common>
  e.type = FS_LOG_END;
    800065ec:	47d9                	li	a5,22
    800065ee:	f2f42223          	sw	a5,-220(s0)
  e.ref_before = before;
    800065f2:	f3342e23          	sw	s3,-196(s0)
  e.ref_after = after;
    800065f6:	f5242023          	sw	s2,-192(s0)
  e.found = will_commit;
    800065fa:	f6942223          	sw	s1,-156(s0)
  safestrcpy(e.name, "LOG", FS_NM);
    800065fe:	4641                	li	a2,16
    80006600:	00002597          	auipc	a1,0x2
    80006604:	19858593          	addi	a1,a1,408 # 80008798 <etext+0x798>
    80006608:	f6c40513          	addi	a0,s0,-148
    8000660c:	807fa0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    80006610:	f1840513          	addi	a0,s0,-232
    80006614:	ab7ff0ef          	jal	800060ca <fslog_push>
}
    80006618:	70ae                	ld	ra,232(sp)
    8000661a:	740e                	ld	s0,224(sp)
    8000661c:	64ee                	ld	s1,216(sp)
    8000661e:	694e                	ld	s2,208(sp)
    80006620:	69ae                	ld	s3,200(sp)
    80006622:	616d                	addi	sp,sp,240
    80006624:	8082                	ret

0000000080006626 <fslog_writelog>:
void fslog_writelog(int blockno, int idx){
    80006626:	7115                	addi	sp,sp,-224
    80006628:	ed86                	sd	ra,216(sp)
    8000662a:	e9a2                	sd	s0,208(sp)
    8000662c:	e5a6                	sd	s1,200(sp)
    8000662e:	e1ca                	sd	s2,192(sp)
    80006630:	1180                	addi	s0,sp,224
    80006632:	892a                	mv	s2,a0
    80006634:	84ae                	mv	s1,a1
  struct fs_event e;
  fill_fs_common(&e);
    80006636:	f2840513          	addi	a0,s0,-216
    8000663a:	a1bff0ef          	jal	80006054 <fill_fs_common>
  e.type = FS_LOG_WLOG;
    8000663e:	47dd                	li	a5,23
    80006640:	f2f42a23          	sw	a5,-204(s0)
  e.blockno = blockno;
    80006644:	f5242023          	sw	s2,-192(s0)
  e.lru_after = idx;
    80006648:	f6942423          	sw	s1,-152(s0)
  safestrcpy(e.name, "LOG", FS_NM);
    8000664c:	4641                	li	a2,16
    8000664e:	00002597          	auipc	a1,0x2
    80006652:	14a58593          	addi	a1,a1,330 # 80008798 <etext+0x798>
    80006656:	f7c40513          	addi	a0,s0,-132
    8000665a:	fb8fa0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    8000665e:	f2840513          	addi	a0,s0,-216
    80006662:	a69ff0ef          	jal	800060ca <fslog_push>
}
    80006666:	60ee                	ld	ra,216(sp)
    80006668:	644e                	ld	s0,208(sp)
    8000666a:	64ae                	ld	s1,200(sp)
    8000666c:	690e                	ld	s2,192(sp)
    8000666e:	612d                	addi	sp,sp,224
    80006670:	8082                	ret

0000000080006672 <fslog_writehead>:

void fslog_writehead(int n){
    80006672:	7115                	addi	sp,sp,-224
    80006674:	ed86                	sd	ra,216(sp)
    80006676:	e9a2                	sd	s0,208(sp)
    80006678:	e5a6                	sd	s1,200(sp)
    8000667a:	1180                	addi	s0,sp,224
    8000667c:	84aa                	mv	s1,a0
  struct fs_event e;
  fill_fs_common(&e);
    8000667e:	f2840513          	addi	a0,s0,-216
    80006682:	9d3ff0ef          	jal	80006054 <fill_fs_common>
  e.type = FS_LOG_WHEAD;
    80006686:	47e1                	li	a5,24
    80006688:	f2f42a23          	sw	a5,-204(s0)
  e.ref_after = n;
    8000668c:	f4942823          	sw	s1,-176(s0)
  safestrcpy(e.name, "LOG", FS_NM);
    80006690:	4641                	li	a2,16
    80006692:	00002597          	auipc	a1,0x2
    80006696:	10658593          	addi	a1,a1,262 # 80008798 <etext+0x798>
    8000669a:	f7c40513          	addi	a0,s0,-132
    8000669e:	f74fa0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    800066a2:	f2840513          	addi	a0,s0,-216
    800066a6:	a25ff0ef          	jal	800060ca <fslog_push>
}
    800066aa:	60ee                	ld	ra,216(sp)
    800066ac:	644e                	ld	s0,208(sp)
    800066ae:	64ae                	ld	s1,200(sp)
    800066b0:	612d                	addi	sp,sp,224
    800066b2:	8082                	ret

00000000800066b4 <fslog_install>:

void fslog_install(int blockno){
    800066b4:	7115                	addi	sp,sp,-224
    800066b6:	ed86                	sd	ra,216(sp)
    800066b8:	e9a2                	sd	s0,208(sp)
    800066ba:	e5a6                	sd	s1,200(sp)
    800066bc:	1180                	addi	s0,sp,224
    800066be:	84aa                	mv	s1,a0
  struct fs_event e;
  fill_fs_common(&e);
    800066c0:	f2840513          	addi	a0,s0,-216
    800066c4:	991ff0ef          	jal	80006054 <fill_fs_common>
  e.type = FS_LOG_INSTALL;
    800066c8:	47e5                	li	a5,25
    800066ca:	f2f42a23          	sw	a5,-204(s0)
  e.blockno = blockno;
    800066ce:	f4942023          	sw	s1,-192(s0)
  safestrcpy(e.name, "LOG", FS_NM);
    800066d2:	4641                	li	a2,16
    800066d4:	00002597          	auipc	a1,0x2
    800066d8:	0c458593          	addi	a1,a1,196 # 80008798 <etext+0x798>
    800066dc:	f7c40513          	addi	a0,s0,-132
    800066e0:	f32fa0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    800066e4:	f2840513          	addi	a0,s0,-216
    800066e8:	9e3ff0ef          	jal	800060ca <fslog_push>
}
    800066ec:	60ee                	ld	ra,216(sp)
    800066ee:	644e                	ld	s0,208(sp)
    800066f0:	64ae                	ld	s1,200(sp)
    800066f2:	612d                	addi	sp,sp,224
    800066f4:	8082                	ret

00000000800066f6 <fslog_balloc>:
void fslog_balloc(int block_allocated) {
    800066f6:	7115                	addi	sp,sp,-224
    800066f8:	ed86                	sd	ra,216(sp)
    800066fa:	e9a2                	sd	s0,208(sp)
    800066fc:	e5a6                	sd	s1,200(sp)
    800066fe:	1180                	addi	s0,sp,224
    80006700:	84aa                	mv	s1,a0
    struct fs_event e;
    fill_fs_common(&e);
    80006702:	f2840513          	addi	a0,s0,-216
    80006706:	94fff0ef          	jal	80006054 <fill_fs_common>
    e.type = FS_BLOCK_ALLOC;
    8000670a:	47f9                	li	a5,30
    8000670c:	f2f42a23          	sw	a5,-204(s0)
    e.blockno = block_allocated; // البلوك الذي تم حجزه فعلياً
    80006710:	f4942023          	sw	s1,-192(s0)
    safestrcpy(e.name, "BALLOC", FS_NM);
    80006714:	4641                	li	a2,16
    80006716:	00002597          	auipc	a1,0x2
    8000671a:	08a58593          	addi	a1,a1,138 # 800087a0 <etext+0x7a0>
    8000671e:	f7c40513          	addi	a0,s0,-132
    80006722:	ef0fa0ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    80006726:	f2840513          	addi	a0,s0,-216
    8000672a:	9a1ff0ef          	jal	800060ca <fslog_push>
}
    8000672e:	60ee                	ld	ra,216(sp)
    80006730:	644e                	ld	s0,208(sp)
    80006732:	64ae                	ld	s1,200(sp)
    80006734:	612d                	addi	sp,sp,224
    80006736:	8082                	ret

0000000080006738 <fslog_bfree>:
void fslog_bfree(int block_freed) {
    80006738:	7115                	addi	sp,sp,-224
    8000673a:	ed86                	sd	ra,216(sp)
    8000673c:	e9a2                	sd	s0,208(sp)
    8000673e:	e5a6                	sd	s1,200(sp)
    80006740:	1180                	addi	s0,sp,224
    80006742:	84aa                	mv	s1,a0
    struct fs_event e;
    fill_fs_common(&e);
    80006744:	f2840513          	addi	a0,s0,-216
    80006748:	90dff0ef          	jal	80006054 <fill_fs_common>
    e.type = FS_BLOCK_FREE;
    8000674c:	47fd                	li	a5,31
    8000674e:	f2f42a23          	sw	a5,-204(s0)
    e.blockno = block_freed; // البلوك الذي تم تحريره
    80006752:	f4942023          	sw	s1,-192(s0)
    safestrcpy(e.name, "BFREE", FS_NM);
    80006756:	4641                	li	a2,16
    80006758:	00002597          	auipc	a1,0x2
    8000675c:	05058593          	addi	a1,a1,80 # 800087a8 <etext+0x7a8>
    80006760:	f7c40513          	addi	a0,s0,-132
    80006764:	eaefa0ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    80006768:	f2840513          	addi	a0,s0,-216
    8000676c:	95fff0ef          	jal	800060ca <fslog_push>
}
    80006770:	60ee                	ld	ra,216(sp)
    80006772:	644e                	ld	s0,208(sp)
    80006774:	64ae                	ld	s1,200(sp)
    80006776:	612d                	addi	sp,sp,224
    80006778:	8082                	ret

000000008000677a <fslog_ialloc>:
void fslog_ialloc(int inum, short type) {
    8000677a:	7115                	addi	sp,sp,-224
    8000677c:	ed86                	sd	ra,216(sp)
    8000677e:	e9a2                	sd	s0,208(sp)
    80006780:	e5a6                	sd	s1,200(sp)
    80006782:	e1ca                	sd	s2,192(sp)
    80006784:	1180                	addi	s0,sp,224
    80006786:	892a                	mv	s2,a0
    80006788:	84ae                	mv	s1,a1
    struct fs_event e;
    fill_fs_common(&e);
    8000678a:	f2840513          	addi	a0,s0,-216
    8000678e:	8c7ff0ef          	jal	80006054 <fill_fs_common>
    e.type = FS_INODE_ALLOC;
    80006792:	02800793          	li	a5,40
    80006796:	f2f42a23          	sw	a5,-204(s0)
    e.inum = inum;
    8000679a:	f9242c23          	sw	s2,-104(s0)
    e.i_type = type;
    8000679e:	f8941e23          	sh	s1,-100(s0)
    safestrcpy(e.name, "IALLOC", FS_NM);
    800067a2:	4641                	li	a2,16
    800067a4:	00002597          	auipc	a1,0x2
    800067a8:	00c58593          	addi	a1,a1,12 # 800087b0 <etext+0x7b0>
    800067ac:	f7c40513          	addi	a0,s0,-132
    800067b0:	e62fa0ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    800067b4:	f2840513          	addi	a0,s0,-216
    800067b8:	913ff0ef          	jal	800060ca <fslog_push>
}
    800067bc:	60ee                	ld	ra,216(sp)
    800067be:	644e                	ld	s0,208(sp)
    800067c0:	64ae                	ld	s1,200(sp)
    800067c2:	690e                	ld	s2,192(sp)
    800067c4:	612d                	addi	sp,sp,224
    800067c6:	8082                	ret

00000000800067c8 <fslog_iget>:

void fslog_iget(int inum, int ref_before, int ref_after) {
    800067c8:	7151                	addi	sp,sp,-240
    800067ca:	f586                	sd	ra,232(sp)
    800067cc:	f1a2                	sd	s0,224(sp)
    800067ce:	eda6                	sd	s1,216(sp)
    800067d0:	e9ca                	sd	s2,208(sp)
    800067d2:	e5ce                	sd	s3,200(sp)
    800067d4:	1980                	addi	s0,sp,240
    800067d6:	89aa                	mv	s3,a0
    800067d8:	892e                	mv	s2,a1
    800067da:	84b2                	mv	s1,a2
    struct fs_event e;
    fill_fs_common(&e);
    800067dc:	f1840513          	addi	a0,s0,-232
    800067e0:	875ff0ef          	jal	80006054 <fill_fs_common>
    e.type = FS_INODE_GET;
    800067e4:	02900793          	li	a5,41
    800067e8:	f2f42223          	sw	a5,-220(s0)
    e.inum = inum;
    800067ec:	f9342423          	sw	s3,-120(s0)
    e.ref_before = ref_before;
    800067f0:	f3242e23          	sw	s2,-196(s0)
    e.ref_after = ref_after;
    800067f4:	f4942023          	sw	s1,-192(s0)
    safestrcpy(e.name, "IGET", FS_NM);
    800067f8:	4641                	li	a2,16
    800067fa:	00002597          	auipc	a1,0x2
    800067fe:	fbe58593          	addi	a1,a1,-66 # 800087b8 <etext+0x7b8>
    80006802:	f6c40513          	addi	a0,s0,-148
    80006806:	e0cfa0ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    8000680a:	f1840513          	addi	a0,s0,-232
    8000680e:	8bdff0ef          	jal	800060ca <fslog_push>
}
    80006812:	70ae                	ld	ra,232(sp)
    80006814:	740e                	ld	s0,224(sp)
    80006816:	64ee                	ld	s1,216(sp)
    80006818:	694e                	ld	s2,208(sp)
    8000681a:	69ae                	ld	s3,200(sp)
    8000681c:	616d                	addi	sp,sp,240
    8000681e:	8082                	ret

0000000080006820 <fslog_ilock>:
void fslog_ilock(int inum, int locked) {
    80006820:	7115                	addi	sp,sp,-224
    80006822:	ed86                	sd	ra,216(sp)
    80006824:	e9a2                	sd	s0,208(sp)
    80006826:	e5a6                	sd	s1,200(sp)
    80006828:	e1ca                	sd	s2,192(sp)
    8000682a:	1180                	addi	s0,sp,224
    8000682c:	892a                	mv	s2,a0
    8000682e:	84ae                	mv	s1,a1
    struct fs_event e;
    fill_fs_common(&e);
    80006830:	f2840513          	addi	a0,s0,-216
    80006834:	821ff0ef          	jal	80006054 <fill_fs_common>
    e.type = FS_INODE_LOCK;
    80006838:	02b00793          	li	a5,43
    8000683c:	f2f42a23          	sw	a5,-204(s0)
    e.inum = inum;
    80006840:	f9242c23          	sw	s2,-104(s0)
    e.locked_after = locked;
    80006844:	f6942023          	sw	s1,-160(s0)
    safestrcpy(e.name, "ILOCK", FS_NM);
    80006848:	4641                	li	a2,16
    8000684a:	00002597          	auipc	a1,0x2
    8000684e:	f7658593          	addi	a1,a1,-138 # 800087c0 <etext+0x7c0>
    80006852:	f7c40513          	addi	a0,s0,-132
    80006856:	dbcfa0ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    8000685a:	f2840513          	addi	a0,s0,-216
    8000685e:	86dff0ef          	jal	800060ca <fslog_push>
}
    80006862:	60ee                	ld	ra,216(sp)
    80006864:	644e                	ld	s0,208(sp)
    80006866:	64ae                	ld	s1,200(sp)
    80006868:	690e                	ld	s2,192(sp)
    8000686a:	612d                	addi	sp,sp,224
    8000686c:	8082                	ret

000000008000686e <fslog_iupdate>:

void fslog_iupdate(struct inode *ip) {
    8000686e:	7115                	addi	sp,sp,-224
    80006870:	ed86                	sd	ra,216(sp)
    80006872:	e9a2                	sd	s0,208(sp)
    80006874:	e5a6                	sd	s1,200(sp)
    80006876:	1180                	addi	s0,sp,224
    80006878:	84aa                	mv	s1,a0
    struct fs_event e;
    fill_fs_common(&e);
    8000687a:	f2840513          	addi	a0,s0,-216
    8000687e:	fd6ff0ef          	jal	80006054 <fill_fs_common>
    e.type = FS_INODE_UPDATE;
    80006882:	02d00793          	li	a5,45
    80006886:	f2f42a23          	sw	a5,-204(s0)
    e.inum = ip->inum;
    8000688a:	40dc                	lw	a5,4(s1)
    8000688c:	f8f42c23          	sw	a5,-104(s0)
    e.i_type = ip->type;
    80006890:	0444d783          	lhu	a5,68(s1)
    80006894:	f8f41e23          	sh	a5,-100(s0)
    e.i_size = ip->size;
    80006898:	44fc                	lw	a5,76(s1)
    8000689a:	faf42223          	sw	a5,-92(s0)
    e.nlink = ip->nlink;
    8000689e:	04a49783          	lh	a5,74(s1)
    800068a2:	faf42023          	sw	a5,-96(s0)
    for(int i=0; i<13; i++) e.addrs[i] = ip->addrs[i];
    800068a6:	05048513          	addi	a0,s1,80
    800068aa:	fa840793          	addi	a5,s0,-88
    800068ae:	fdc40693          	addi	a3,s0,-36
    800068b2:	4118                	lw	a4,0(a0)
    800068b4:	c398                	sw	a4,0(a5)
    800068b6:	0511                	addi	a0,a0,4
    800068b8:	0791                	addi	a5,a5,4
    800068ba:	fed79ce3          	bne	a5,a3,800068b2 <fslog_iupdate+0x44>
    safestrcpy(e.name, "IUPDATE", FS_NM);
    800068be:	4641                	li	a2,16
    800068c0:	00002597          	auipc	a1,0x2
    800068c4:	f0858593          	addi	a1,a1,-248 # 800087c8 <etext+0x7c8>
    800068c8:	f7c40513          	addi	a0,s0,-132
    800068cc:	d46fa0ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    800068d0:	f2840513          	addi	a0,s0,-216
    800068d4:	ff6ff0ef          	jal	800060ca <fslog_push>
    800068d8:	60ee                	ld	ra,216(sp)
    800068da:	644e                	ld	s0,208(sp)
    800068dc:	64ae                	ld	s1,200(sp)
    800068de:	612d                	addi	sp,sp,224
    800068e0:	8082                	ret
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
