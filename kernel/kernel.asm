
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
    80000004:	10010113          	addi	sp,sp,256 # 80009100 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ff9c367>
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
    800000ea:	01a50513          	addi	a0,a0,26 # 80011100 <conswlock>
    800000ee:	28f040ef          	jal	80004b7c <acquiresleep>

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
    80000162:	00011517          	auipc	a0,0x11
    80000166:	f9e50513          	addi	a0,a0,-98 # 80011100 <conswlock>
    8000016a:	259040ef          	jal	80004bc2 <releasesleep>
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
    800001a0:	00011517          	auipc	a0,0x11
    800001a4:	f9050513          	addi	a0,a0,-112 # 80011130 <cons>
    800001a8:	259000ef          	jal	80000c00 <acquire>

  while(n > 0){
    while(cons.r == cons.w){
    800001ac:	00011497          	auipc	s1,0x11
    800001b0:	f5448493          	addi	s1,s1,-172 # 80011100 <conswlock>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	00011997          	auipc	s3,0x11
    800001b8:	f7c98993          	addi	s3,s3,-132 # 80011130 <cons>
    800001bc:	00011917          	auipc	s2,0x11
    800001c0:	00c90913          	addi	s2,s2,12 # 800111c8 <cons+0x98>
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
    800001f4:	00011717          	auipc	a4,0x11
    800001f8:	f0c70713          	addi	a4,a4,-244 # 80011100 <conswlock>
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
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	ef250513          	addi	a0,a0,-270 # 80011130 <cons>
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
    8000026a:	00011717          	auipc	a4,0x11
    8000026e:	f4f72f23          	sw	a5,-162(a4) # 800111c8 <cons+0x98>
    80000272:	6c42                	ld	s8,16(sp)
    80000274:	a031                	j	80000280 <consoleread+0x100>
    80000276:	e862                	sd	s8,16(sp)
    80000278:	bfb5                	j	800001f4 <consoleread+0x74>
    8000027a:	6c42                	ld	s8,16(sp)
    8000027c:	a011                	j	80000280 <consoleread+0x100>
    8000027e:	6c42                	ld	s8,16(sp)
  release(&cons.lock);
    80000280:	00011517          	auipc	a0,0x11
    80000284:	eb050513          	addi	a0,a0,-336 # 80011130 <cons>
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
    800002d4:	00011517          	auipc	a0,0x11
    800002d8:	e5c50513          	addi	a0,a0,-420 # 80011130 <cons>
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
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	e3650513          	addi	a0,a0,-458 # 80011130 <cons>
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
    80000318:	00011717          	auipc	a4,0x11
    8000031c:	de870713          	addi	a4,a4,-536 # 80011100 <conswlock>
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
    8000033e:	00011797          	auipc	a5,0x11
    80000342:	dc278793          	addi	a5,a5,-574 # 80011100 <conswlock>
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
    8000036c:	00011797          	auipc	a5,0x11
    80000370:	e5c7a783          	lw	a5,-420(a5) # 800111c8 <cons+0x98>
    80000374:	9f1d                	subw	a4,a4,a5
    80000376:	08000793          	li	a5,128
    8000037a:	f8f710e3          	bne	a4,a5,800002fa <consoleintr+0x32>
    8000037e:	a07d                	j	8000042c <consoleintr+0x164>
    80000380:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000382:	00011717          	auipc	a4,0x11
    80000386:	d7e70713          	addi	a4,a4,-642 # 80011100 <conswlock>
    8000038a:	0d072783          	lw	a5,208(a4)
    8000038e:	0cc72703          	lw	a4,204(a4)
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    80000392:	00011497          	auipc	s1,0x11
    80000396:	d6e48493          	addi	s1,s1,-658 # 80011100 <conswlock>
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
    800003d4:	00011717          	auipc	a4,0x11
    800003d8:	d2c70713          	addi	a4,a4,-724 # 80011100 <conswlock>
    800003dc:	0d072783          	lw	a5,208(a4)
    800003e0:	0cc72703          	lw	a4,204(a4)
    800003e4:	f0f70be3          	beq	a4,a5,800002fa <consoleintr+0x32>
      cons.e--;
    800003e8:	37fd                	addiw	a5,a5,-1
    800003ea:	00011717          	auipc	a4,0x11
    800003ee:	def72323          	sw	a5,-538(a4) # 800111d0 <cons+0xa0>
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
    80000408:	00011797          	auipc	a5,0x11
    8000040c:	cf878793          	addi	a5,a5,-776 # 80011100 <conswlock>
    80000410:	0d07a703          	lw	a4,208(a5)
    80000414:	0017069b          	addiw	a3,a4,1
    80000418:	0006861b          	sext.w	a2,a3
    8000041c:	0cd7a823          	sw	a3,208(a5)
    80000420:	07f77713          	andi	a4,a4,127
    80000424:	97ba                	add	a5,a5,a4
    80000426:	4729                	li	a4,10
    80000428:	04e78423          	sb	a4,72(a5)
        cons.w = cons.e;
    8000042c:	00011797          	auipc	a5,0x11
    80000430:	dac7a023          	sw	a2,-608(a5) # 800111cc <cons+0x9c>
        wakeup(&cons.r);
    80000434:	00011517          	auipc	a0,0x11
    80000438:	d9450513          	addi	a0,a0,-620 # 800111c8 <cons+0x98>
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
    80000452:	00011517          	auipc	a0,0x11
    80000456:	cde50513          	addi	a0,a0,-802 # 80011130 <cons>
    8000045a:	726000ef          	jal	80000b80 <initlock>
  initsleeplock(&conswlock, "consw");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	baa58593          	addi	a1,a1,-1110 # 80008008 <etext+0x8>
    80000466:	00011517          	auipc	a0,0x11
    8000046a:	c9a50513          	addi	a0,a0,-870 # 80011100 <conswlock>
    8000046e:	6d8040ef          	jal	80004b46 <initsleeplock>

  uartinit();
    80000472:	400000ef          	jal	80000872 <uartinit>

  devsw[CONSOLE].read = consoleread;
    80000476:	00021797          	auipc	a5,0x21
    8000047a:	e2a78793          	addi	a5,a5,-470 # 800212a0 <devsw>
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
    800004b0:	00009617          	auipc	a2,0x9
    800004b4:	ae060613          	addi	a2,a2,-1312 # 80008f90 <digits>
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
    8000054a:	00009797          	auipc	a5,0x9
    8000054e:	b7a7a783          	lw	a5,-1158(a5) # 800090c4 <panicking>
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
    80000592:	00011517          	auipc	a0,0x11
    80000596:	c4650513          	addi	a0,a0,-954 # 800111d8 <pr>
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
    8000075a:	00009b97          	auipc	s7,0x9
    8000075e:	836b8b93          	addi	s7,s7,-1994 # 80008f90 <digits>
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
    800007be:	85690913          	addi	s2,s2,-1962 # 80008010 <etext+0x10>
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
    800007ee:	00009797          	auipc	a5,0x9
    800007f2:	8d67a783          	lw	a5,-1834(a5) # 800090c4 <panicking>
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
    80000804:	00011517          	auipc	a0,0x11
    80000808:	9d450513          	addi	a0,a0,-1580 # 800111d8 <pr>
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
    80000822:	00009797          	auipc	a5,0x9
    80000826:	8b27a123          	sw	s2,-1886(a5) # 800090c4 <panicking>
  printf("panic: ");
    8000082a:	00007517          	auipc	a0,0x7
    8000082e:	7ee50513          	addi	a0,a0,2030 # 80008018 <etext+0x18>
    80000832:	cfbff0ef          	jal	8000052c <printf>
  printf("%s\n", s);
    80000836:	85a6                	mv	a1,s1
    80000838:	00007517          	auipc	a0,0x7
    8000083c:	7e850513          	addi	a0,a0,2024 # 80008020 <etext+0x20>
    80000840:	cedff0ef          	jal	8000052c <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000844:	00009797          	auipc	a5,0x9
    80000848:	8727ae23          	sw	s2,-1924(a5) # 800090c0 <panicked>
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
    8000085a:	7d258593          	addi	a1,a1,2002 # 80008028 <etext+0x28>
    8000085e:	00011517          	auipc	a0,0x11
    80000862:	97a50513          	addi	a0,a0,-1670 # 800111d8 <pr>
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
    800008b2:	78258593          	addi	a1,a1,1922 # 80008030 <etext+0x30>
    800008b6:	00011517          	auipc	a0,0x11
    800008ba:	93a50513          	addi	a0,a0,-1734 # 800111f0 <tx_lock>
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
    800008da:	00011517          	auipc	a0,0x11
    800008de:	91650513          	addi	a0,a0,-1770 # 800111f0 <tx_lock>
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
    800008fc:	7d448493          	addi	s1,s1,2004 # 800090cc <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000900:	00011997          	auipc	s3,0x11
    80000904:	8f098993          	addi	s3,s3,-1808 # 800111f0 <tx_lock>
    80000908:	00008917          	auipc	s2,0x8
    8000090c:	7c090913          	addi	s2,s2,1984 # 800090c8 <tx_chan>
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
    80000946:	00011517          	auipc	a0,0x11
    8000094a:	8aa50513          	addi	a0,a0,-1878 # 800111f0 <tx_lock>
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
    8000096e:	75a7a783          	lw	a5,1882(a5) # 800090c4 <panicking>
    80000972:	cf95                	beqz	a5,800009ae <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000974:	00008797          	auipc	a5,0x8
    80000978:	74c7a783          	lw	a5,1868(a5) # 800090c0 <panicked>
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
    8000099e:	72a7a783          	lw	a5,1834(a5) # 800090c4 <panicking>
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
    800009fa:	7fa50513          	addi	a0,a0,2042 # 800111f0 <tx_lock>
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
    80000a16:	7de50513          	addi	a0,a0,2014 # 800111f0 <tx_lock>
    80000a1a:	27e000ef          	jal	80000c98 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a1e:	54fd                	li	s1,-1
    80000a20:	a831                	j	80000a3c <uartintr+0x5a>
    tx_busy = 0;
    80000a22:	00008797          	auipc	a5,0x8
    80000a26:	6a07a523          	sw	zero,1706(a5) # 800090cc <tx_busy>
    wakeup(&tx_chan);
    80000a2a:	00008517          	auipc	a0,0x8
    80000a2e:	69e50513          	addi	a0,a0,1694 # 800090c8 <tx_chan>
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
    80000a62:	00062797          	auipc	a5,0x62
    80000a66:	a3678793          	addi	a5,a5,-1482 # 80062498 <end>
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
    80000a82:	78a90913          	addi	s2,s2,1930 # 80011208 <kmem>
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
    80000aac:	59050513          	addi	a0,a0,1424 # 80008038 <etext+0x38>
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
    80000b08:	53c58593          	addi	a1,a1,1340 # 80008040 <etext+0x40>
    80000b0c:	00010517          	auipc	a0,0x10
    80000b10:	6fc50513          	addi	a0,a0,1788 # 80011208 <kmem>
    80000b14:	06c000ef          	jal	80000b80 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b18:	45c5                	li	a1,17
    80000b1a:	05ee                	slli	a1,a1,0x1b
    80000b1c:	00062517          	auipc	a0,0x62
    80000b20:	97c50513          	addi	a0,a0,-1668 # 80062498 <end>
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
    80000b3e:	6ce48493          	addi	s1,s1,1742 # 80011208 <kmem>
    80000b42:	8526                	mv	a0,s1
    80000b44:	0bc000ef          	jal	80000c00 <acquire>
  r = kmem.freelist;
    80000b48:	6c84                	ld	s1,24(s1)
  if(r)
    80000b4a:	c485                	beqz	s1,80000b72 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b4c:	609c                	ld	a5,0(s1)
    80000b4e:	00010517          	auipc	a0,0x10
    80000b52:	6ba50513          	addi	a0,a0,1722 # 80011208 <kmem>
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
    80000b76:	69650513          	addi	a0,a0,1686 # 80011208 <kmem>
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
    80000c3c:	41050513          	addi	a0,a0,1040 # 80008048 <etext+0x48>
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
    80000c84:	3d050513          	addi	a0,a0,976 # 80008050 <etext+0x50>
    80000c88:	b8bff0ef          	jal	80000812 <panic>
    panic("pop_off");
    80000c8c:	00007517          	auipc	a0,0x7
    80000c90:	3dc50513          	addi	a0,a0,988 # 80008068 <etext+0x68>
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
    80000ccc:	3a850513          	addi	a0,a0,936 # 80008070 <etext+0x70>
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
    80000d48:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ff9cb69>
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
    80000e7e:	25670713          	addi	a4,a4,598 # 800090d0 <started>
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
    80000e98:	1fc50513          	addi	a0,a0,508 # 80008090 <etext+0x90>
    80000e9c:	e90ff0ef          	jal	8000052c <printf>
    kvminithart();    // turn on paging
    80000ea0:	088000ef          	jal	80000f28 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ea4:	596010ef          	jal	8000243a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ea8:	3e0050ef          	jal	80006288 <plicinithart>
  }

  scheduler();        
    80000eac:	6cf000ef          	jal	80001d7a <scheduler>
    consoleinit();
    80000eb0:	d92ff0ef          	jal	80000442 <consoleinit>
    printfinit();
    80000eb4:	99bff0ef          	jal	8000084e <printfinit>
    printf("\n");
    80000eb8:	00007517          	auipc	a0,0x7
    80000ebc:	1e850513          	addi	a0,a0,488 # 800080a0 <etext+0xa0>
    80000ec0:	e6cff0ef          	jal	8000052c <printf>
    printf("xv6 kernel is booting\n");
    80000ec4:	00007517          	auipc	a0,0x7
    80000ec8:	1b450513          	addi	a0,a0,436 # 80008078 <etext+0x78>
    80000ecc:	e60ff0ef          	jal	8000052c <printf>
    printf("\n");
    80000ed0:	00007517          	auipc	a0,0x7
    80000ed4:	1d050513          	addi	a0,a0,464 # 800080a0 <etext+0xa0>
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
    80000ef4:	37a050ef          	jal	8000626e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ef8:	390050ef          	jal	80006288 <plicinithart>
    binit();         // buffer cache
    80000efc:	4af010ef          	jal	80002baa <binit>
    iinit();         // inode table
    80000f00:	6f2020ef          	jal	800035f2 <iinit>
    fileinit();      // file table
    80000f04:	5f9030ef          	jal	80004cfc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f08:	470050ef          	jal	80006378 <virtio_disk_init>
    cslog_init();
    80000f0c:	11f050ef          	jal	8000682a <cslog_init>
    fslog_init();
    80000f10:	475050ef          	jal	80006b84 <fslog_init>
    userinit();      // first user process
    80000f14:	4bb000ef          	jal	80001bce <userinit>
    __sync_synchronize();
    80000f18:	0ff0000f          	fence
    started = 1;
    80000f1c:	4785                	li	a5,1
    80000f1e:	00008717          	auipc	a4,0x8
    80000f22:	1af72923          	sw	a5,434(a4) # 800090d0 <started>
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
    80000f36:	1a67b783          	ld	a5,422(a5) # 800090d8 <kernel_pagetable>
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
    80000f7a:	13250513          	addi	a0,a0,306 # 800080a8 <etext+0xa8>
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
    80000fa4:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ff9cb5f>
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
    80001090:	02450513          	addi	a0,a0,36 # 800080b0 <etext+0xb0>
    80001094:	f7eff0ef          	jal	80000812 <panic>
    panic("mappages: size not aligned");
    80001098:	00007517          	auipc	a0,0x7
    8000109c:	03850513          	addi	a0,a0,56 # 800080d0 <etext+0xd0>
    800010a0:	f72ff0ef          	jal	80000812 <panic>
    panic("mappages: size");
    800010a4:	00007517          	auipc	a0,0x7
    800010a8:	04c50513          	addi	a0,a0,76 # 800080f0 <etext+0xf0>
    800010ac:	f66ff0ef          	jal	80000812 <panic>
      panic("mappages: remap");
    800010b0:	00007517          	auipc	a0,0x7
    800010b4:	05050513          	addi	a0,a0,80 # 80008100 <etext+0x100>
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
    800010f8:	01c50513          	addi	a0,a0,28 # 80008110 <etext+0x110>
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
    800011be:	00008797          	auipc	a5,0x8
    800011c2:	f0a7bd23          	sd	a0,-230(a5) # 800090d8 <kernel_pagetable>
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
    80001232:	eea50513          	addi	a0,a0,-278 # 80008118 <etext+0x118>
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
    800013aa:	d8a50513          	addi	a0,a0,-630 # 80008130 <etext+0x130>
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
    800014ba:	c8a50513          	addi	a0,a0,-886 # 80008140 <etext+0x140>
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
    800017a4:	00010497          	auipc	s1,0x10
    800017a8:	eb448493          	addi	s1,s1,-332 # 80011658 <proc>
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
    800017d0:	00016a97          	auipc	s5,0x16
    800017d4:	888a8a93          	addi	s5,s5,-1912 # 80017058 <tickslock>
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
    8000181e:	93650513          	addi	a0,a0,-1738 # 80008150 <etext+0x150>
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
    8000183e:	91e58593          	addi	a1,a1,-1762 # 80008158 <etext+0x158>
    80001842:	00010517          	auipc	a0,0x10
    80001846:	9e650513          	addi	a0,a0,-1562 # 80011228 <pid_lock>
    8000184a:	b36ff0ef          	jal	80000b80 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000184e:	00007597          	auipc	a1,0x7
    80001852:	91258593          	addi	a1,a1,-1774 # 80008160 <etext+0x160>
    80001856:	00010517          	auipc	a0,0x10
    8000185a:	9ea50513          	addi	a0,a0,-1558 # 80011240 <wait_lock>
    8000185e:	b22ff0ef          	jal	80000b80 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001862:	00010497          	auipc	s1,0x10
    80001866:	df648493          	addi	s1,s1,-522 # 80011658 <proc>
    initlock(&p->lock, "proc");
    8000186a:	00007b17          	auipc	s6,0x7
    8000186e:	906b0b13          	addi	s6,s6,-1786 # 80008170 <etext+0x170>
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
    8000189a:	7c2a0a13          	addi	s4,s4,1986 # 80017058 <tickslock>
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
    800018b4:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ff9cb69>
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
    800018f8:	00010517          	auipc	a0,0x10
    800018fc:	96050513          	addi	a0,a0,-1696 # 80011258 <cpus>
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
    8000191c:	00010717          	auipc	a4,0x10
    80001920:	90c70713          	addi	a4,a4,-1780 # 80011228 <pid_lock>
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
    80001950:	7647a783          	lw	a5,1892(a5) # 800090b0 <first.1>
    80001954:	cf8d                	beqz	a5,8000198e <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001956:	4505                	li	a0,1
    80001958:	28e020ef          	jal	80003be6 <fsinit>

    first = 0;
    8000195c:	00007797          	auipc	a5,0x7
    80001960:	7407aa23          	sw	zero,1876(a5) # 800090b0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001964:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001968:	00007517          	auipc	a0,0x7
    8000196c:	81050513          	addi	a0,a0,-2032 # 80008178 <etext+0x178>
    80001970:	fca43823          	sd	a0,-48(s0)
    80001974:	fc043c23          	sd	zero,-40(s0)
    80001978:	fd040593          	addi	a1,s0,-48
    8000197c:	2ef030ef          	jal	8000546a <kexec>
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
    800019c8:	7bc50513          	addi	a0,a0,1980 # 80008180 <etext+0x180>
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
    800019dc:	00010917          	auipc	s2,0x10
    800019e0:	84c90913          	addi	s2,s2,-1972 # 80011228 <pid_lock>
    800019e4:	854a                	mv	a0,s2
    800019e6:	a1aff0ef          	jal	80000c00 <acquire>
  pid = nextpid;
    800019ea:	00007797          	auipc	a5,0x7
    800019ee:	6ca78793          	addi	a5,a5,1738 # 800090b4 <nextpid>
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
    80001b34:	00010497          	auipc	s1,0x10
    80001b38:	b2448493          	addi	s1,s1,-1244 # 80011658 <proc>
    80001b3c:	00015917          	auipc	s2,0x15
    80001b40:	51c90913          	addi	s2,s2,1308 # 80017058 <tickslock>
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
    80001be2:	50a7b123          	sd	a0,1282(a5) # 800090e0 <initproc>
  p->cwd = namei("/");
    80001be6:	00006517          	auipc	a0,0x6
    80001bea:	5a250513          	addi	a0,a0,1442 # 80008188 <etext+0x188>
    80001bee:	6b6020ef          	jal	800042a4 <namei>
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
    80001d0a:	08e030ef          	jal	80004d98 <filedup>
    80001d0e:	00a93023          	sd	a0,0(s2)
    80001d12:	b7f5                	j	80001cfe <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001d14:	150ab503          	ld	a0,336(s5)
    80001d18:	2b1010ef          	jal	800037c8 <idup>
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
    80001d3c:	50848493          	addi	s1,s1,1288 # 80011240 <wait_lock>
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
    80001d9e:	48e70713          	addi	a4,a4,1166 # 80011228 <pid_lock>
    80001da2:	975a                	add	a4,a4,s6
    80001da4:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001da8:	0000f717          	auipc	a4,0xf
    80001dac:	4b870713          	addi	a4,a4,1208 # 80011260 <cpus+0x8>
    80001db0:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001db2:	4c11                	li	s8,4
        c->proc = p;
    80001db4:	079e                	slli	a5,a5,0x7
    80001db6:	0000fa17          	auipc	s4,0xf
    80001dba:	472a0a13          	addi	s4,s4,1138 # 80011228 <pid_lock>
    80001dbe:	9a3e                	add	s4,s4,a5
        found = 1;
    80001dc0:	4b85                	li	s7,1
    for (p = proc; p < &proc[NPROC]; p++) {
    80001dc2:	00015997          	auipc	s3,0x15
    80001dc6:	29698993          	addi	s3,s3,662 # 80017058 <tickslock>
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
    80001df0:	2c5040ef          	jal	800068b4 <cslog_run_start>
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
    80001e26:	00010497          	auipc	s1,0x10
    80001e2a:	83248493          	addi	s1,s1,-1998 # 80011658 <proc>
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
    80001e56:	3d670713          	addi	a4,a4,982 # 80011228 <pid_lock>
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
    80001e7c:	3b090913          	addi	s2,s2,944 # 80011228 <pid_lock>
    80001e80:	2781                	sext.w	a5,a5
    80001e82:	079e                	slli	a5,a5,0x7
    80001e84:	97ca                	add	a5,a5,s2
    80001e86:	0ac7a983          	lw	s3,172(a5)
    80001e8a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e8c:	2781                	sext.w	a5,a5
    80001e8e:	079e                	slli	a5,a5,0x7
    80001e90:	0000f597          	auipc	a1,0xf
    80001e94:	3d058593          	addi	a1,a1,976 # 80011260 <cpus+0x8>
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
    80001ec0:	2d450513          	addi	a0,a0,724 # 80008190 <etext+0x190>
    80001ec4:	94ffe0ef          	jal	80000812 <panic>
    panic("sched locks");
    80001ec8:	00006517          	auipc	a0,0x6
    80001ecc:	2d850513          	addi	a0,a0,728 # 800081a0 <etext+0x1a0>
    80001ed0:	943fe0ef          	jal	80000812 <panic>
    panic("sched RUNNING");
    80001ed4:	00006517          	auipc	a0,0x6
    80001ed8:	2dc50513          	addi	a0,a0,732 # 800081b0 <etext+0x1b0>
    80001edc:	937fe0ef          	jal	80000812 <panic>
    panic("sched interruptible");
    80001ee0:	00006517          	auipc	a0,0x6
    80001ee4:	2e050513          	addi	a0,a0,736 # 800081c0 <etext+0x1c0>
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
    80001f7c:	6e048493          	addi	s1,s1,1760 # 80011658 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    80001f80:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f82:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f84:	00015917          	auipc	s2,0x15
    80001f88:	0d490913          	addi	s2,s2,212 # 80017058 <tickslock>
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
    80001fe4:	67848493          	addi	s1,s1,1656 # 80011658 <proc>
      pp->parent = initproc;
    80001fe8:	00007a17          	auipc	s4,0x7
    80001fec:	0f8a0a13          	addi	s4,s4,248 # 800090e0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001ff0:	00015997          	auipc	s3,0x15
    80001ff4:	06898993          	addi	s3,s3,104 # 80017058 <tickslock>
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
    80002040:	0a47b783          	ld	a5,164(a5) # 800090e0 <initproc>
    80002044:	0d050493          	addi	s1,a0,208
    80002048:	15050913          	addi	s2,a0,336
    8000204c:	00a79f63          	bne	a5,a0,8000206a <kexit+0x46>
    panic("init exiting");
    80002050:	00006517          	auipc	a0,0x6
    80002054:	18850513          	addi	a0,a0,392 # 800081d8 <etext+0x1d8>
    80002058:	fbafe0ef          	jal	80000812 <panic>
      fileclose(f);
    8000205c:	59d020ef          	jal	80004df8 <fileclose>
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
    80002070:	67a020ef          	jal	800046ea <begin_op>
  iput(p->cwd);
    80002074:	1509b503          	ld	a0,336(s3)
    80002078:	1b9010ef          	jal	80003a30 <iput>
  end_op();
    8000207c:	78c020ef          	jal	80004808 <end_op>
  p->cwd = 0;
    80002080:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002084:	0000f497          	auipc	s1,0xf
    80002088:	1bc48493          	addi	s1,s1,444 # 80011240 <wait_lock>
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
    800020be:	12e50513          	addi	a0,a0,302 # 800081e8 <etext+0x1e8>
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
    800020da:	58248493          	addi	s1,s1,1410 # 80011658 <proc>
    800020de:	00015997          	auipc	s3,0x15
    800020e2:	f7a98993          	addi	s3,s3,-134 # 80017058 <tickslock>
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
    8000219e:	0a650513          	addi	a0,a0,166 # 80011240 <wait_lock>
    800021a2:	a5ffe0ef          	jal	80000c00 <acquire>
    havekids = 0;
    800021a6:	4b81                	li	s7,0
        if (pp->state == ZOMBIE) {
    800021a8:	4a15                	li	s4,5
        havekids = 1;
    800021aa:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021ac:	00015997          	auipc	s3,0x15
    800021b0:	eac98993          	addi	s3,s3,-340 # 80017058 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800021b4:	0000fc17          	auipc	s8,0xf
    800021b8:	08cc0c13          	addi	s8,s8,140 # 80011240 <wait_lock>
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
    800021ea:	05a50513          	addi	a0,a0,90 # 80011240 <wait_lock>
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
    80002216:	02e50513          	addi	a0,a0,46 # 80011240 <wait_lock>
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
    8000225e:	3fe48493          	addi	s1,s1,1022 # 80011658 <proc>
    80002262:	b7e1                	j	8000222a <kwait+0xb0>
      release(&wait_lock);
    80002264:	0000f517          	auipc	a0,0xf
    80002268:	fdc50513          	addi	a0,a0,-36 # 80011240 <wait_lock>
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
    80002322:	d8250513          	addi	a0,a0,-638 # 800080a0 <etext+0xa0>
    80002326:	a06fe0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000232a:	0000f497          	auipc	s1,0xf
    8000232e:	48648493          	addi	s1,s1,1158 # 800117b0 <proc+0x158>
    80002332:	00015917          	auipc	s2,0x15
    80002336:	e7e90913          	addi	s2,s2,-386 # 800171b0 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000233a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000233c:	00006997          	auipc	s3,0x6
    80002340:	ebc98993          	addi	s3,s3,-324 # 800081f8 <etext+0x1f8>
    printf("%d %s %s", p->pid, state, p->name);
    80002344:	00006a97          	auipc	s5,0x6
    80002348:	ebca8a93          	addi	s5,s5,-324 # 80008200 <etext+0x200>
    printf("\n");
    8000234c:	00006a17          	auipc	s4,0x6
    80002350:	d54a0a13          	addi	s4,s4,-684 # 800080a0 <etext+0xa0>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002354:	00007b97          	auipc	s7,0x7
    80002358:	c54b8b93          	addi	s7,s7,-940 # 80008fa8 <states.0>
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
    80002422:	e2258593          	addi	a1,a1,-478 # 80008240 <etext+0x240>
    80002426:	00015517          	auipc	a0,0x15
    8000242a:	c3250513          	addi	a0,a0,-974 # 80017058 <tickslock>
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
    80002440:	00004797          	auipc	a5,0x4
    80002444:	dd078793          	addi	a5,a5,-560 # 80006210 <kernelvec>
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
    800024f6:	00015497          	auipc	s1,0x15
    800024fa:	b6248493          	addi	s1,s1,-1182 # 80017058 <tickslock>
    800024fe:	8526                	mv	a0,s1
    80002500:	f00fe0ef          	jal	80000c00 <acquire>
    ticks++;
    80002504:	00007517          	auipc	a0,0x7
    80002508:	be450513          	addi	a0,a0,-1052 # 800090e8 <ticks>
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
    8000254c:	571030ef          	jal	800062bc <plic_claim>
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
    8000256c:	216040ef          	jal	80006782 <virtio_disk_intr>
    if(irq)
    80002570:	a801                	j	80002580 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002572:	85a6                	mv	a1,s1
    80002574:	00006517          	auipc	a0,0x6
    80002578:	cd450513          	addi	a0,a0,-812 # 80008248 <etext+0x248>
    8000257c:	fb1fd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    80002580:	8526                	mv	a0,s1
    80002582:	55b030ef          	jal	800062dc <plic_complete>
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
    800025aa:	00004797          	auipc	a5,0x4
    800025ae:	c6678793          	addi	a5,a5,-922 # 80006210 <kernelvec>
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
    800025f4:	c9850513          	addi	a0,a0,-872 # 80008288 <etext+0x288>
    800025f8:	f35fd0ef          	jal	8000052c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025fc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002600:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002604:	00006517          	auipc	a0,0x6
    80002608:	cb450513          	addi	a0,a0,-844 # 800082b8 <etext+0x2b8>
    8000260c:	f21fd0ef          	jal	8000052c <printf>
    setkilled(p);
    80002610:	8526                	mv	a0,s1
    80002612:	b1bff0ef          	jal	8000212c <setkilled>
    80002616:	a035                	j	80002642 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002618:	00006517          	auipc	a0,0x6
    8000261c:	c5050513          	addi	a0,a0,-944 # 80008268 <etext+0x268>
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
    800026f0:	bf450513          	addi	a0,a0,-1036 # 800082e0 <etext+0x2e0>
    800026f4:	91efe0ef          	jal	80000812 <panic>
    panic("kerneltrap: interrupts enabled");
    800026f8:	00006517          	auipc	a0,0x6
    800026fc:	c1050513          	addi	a0,a0,-1008 # 80008308 <etext+0x308>
    80002700:	912fe0ef          	jal	80000812 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002704:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002708:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000270c:	85ce                	mv	a1,s3
    8000270e:	00006517          	auipc	a0,0x6
    80002712:	c1a50513          	addi	a0,a0,-998 # 80008328 <etext+0x328>
    80002716:	e17fd0ef          	jal	8000052c <printf>
    panic("kerneltrap");
    8000271a:	00006517          	auipc	a0,0x6
    8000271e:	c3650513          	addi	a0,a0,-970 # 80008350 <etext+0x350>
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
    8000274a:	00007717          	auipc	a4,0x7
    8000274e:	88e70713          	addi	a4,a4,-1906 # 80008fd8 <states.0+0x30>
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
    8000278a:	bda50513          	addi	a0,a0,-1062 # 80008360 <etext+0x360>
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
    800028b2:	74278793          	addi	a5,a5,1858 # 80008ff0 <syscalls>
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
    800028ce:	a9e50513          	addi	a0,a0,-1378 # 80008368 <etext+0x368>
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
    800029f4:	66850513          	addi	a0,a0,1640 # 80017058 <tickslock>
    800029f8:	a08fe0ef          	jal	80000c00 <acquire>
  ticks0 = ticks;
    800029fc:	00006917          	auipc	s2,0x6
    80002a00:	6ec92903          	lw	s2,1772(s2) # 800090e8 <ticks>
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
    80002a12:	64a98993          	addi	s3,s3,1610 # 80017058 <tickslock>
    80002a16:	00006497          	auipc	s1,0x6
    80002a1a:	6d248493          	addi	s1,s1,1746 # 800090e8 <ticks>
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
    80002a46:	61650513          	addi	a0,a0,1558 # 80017058 <tickslock>
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
    80002a64:	5f850513          	addi	a0,a0,1528 # 80017058 <tickslock>
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
    80002aa4:	5b850513          	addi	a0,a0,1464 # 80017058 <tickslock>
    80002aa8:	958fe0ef          	jal	80000c00 <acquire>
  xticks = ticks;
    80002aac:	00006497          	auipc	s1,0x6
    80002ab0:	63c4a483          	lw	s1,1596(s1) # 800090e8 <ticks>
  release(&tickslock);
    80002ab4:	00014517          	auipc	a0,0x14
    80002ab8:	5a450513          	addi	a0,a0,1444 # 80017058 <tickslock>
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

0000000080002ad0 <bcache_report>:
} bcache;

static int buf_id(struct buf *b);

// --- الدالة المساعدة الجديدة للتقرير ---
void bcache_report(char* op, struct buf *b, int old_ref, int old_val,  char* det) {
    80002ad0:	df010113          	addi	sp,sp,-528
    80002ad4:	20113423          	sd	ra,520(sp)
    80002ad8:	20813023          	sd	s0,512(sp)
    80002adc:	ffa6                	sd	s1,504(sp)
    80002ade:	fbca                	sd	s2,496(sp)
    80002ae0:	f7ce                	sd	s3,488(sp)
    80002ae2:	f3d2                	sd	s4,480(sp)
    80002ae4:	efd6                	sd	s5,472(sp)
    80002ae6:	0c00                	addi	s0,sp,528
    80002ae8:	8aaa                	mv	s5,a0
    80002aea:	84ae                	mv	s1,a1
    80002aec:	8a32                	mv	s4,a2
    80002aee:	89b6                	mv	s3,a3
    80002af0:	893a                	mv	s2,a4
    struct fs_event e;
    memset(&e, 0, sizeof(e));
    80002af2:	1c800613          	li	a2,456
    80002af6:	4581                	li	a1,0
    80002af8:	df840513          	addi	a0,s0,-520
    80002afc:	9d8fe0ef          	jal	80000cd4 <memset>
    e.ticks = ticks; 
    80002b00:	00006797          	auipc	a5,0x6
    80002b04:	5e87a783          	lw	a5,1512(a5) # 800090e8 <ticks>
    80002b08:	e0f42023          	sw	a5,-512(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    80002b0c:	dfdfe0ef          	jal	80001908 <myproc>
    80002b10:	4781                	li	a5,0
    80002b12:	c501                	beqz	a0,80002b1a <bcache_report+0x4a>
    80002b14:	df5fe0ef          	jal	80001908 <myproc>
    80002b18:	591c                	lw	a5,48(a0)
    80002b1a:	e0f42223          	sw	a5,-508(s0)
    e.type = LAYER_BCACHE;
    80002b1e:	4785                	li	a5,1
    80002b20:	e0f42423          	sw	a5,-504(s0)
    safestrcpy(e.op_name, op, 16);
    80002b24:	4641                	li	a2,16
    80002b26:	85d6                	mv	a1,s5
    80002b28:	e0c40513          	addi	a0,s0,-500
    80002b2c:	ae6fe0ef          	jal	80000e12 <safestrcpy>
}

static int
buf_id(struct buf *b)
{
  return (int)(b - bcache.buf);
    80002b30:	00014797          	auipc	a5,0x14
    80002b34:	55878793          	addi	a5,a5,1368 # 80017088 <bcache+0x18>
    80002b38:	40f487b3          	sub	a5,s1,a5
    80002b3c:	4037d513          	srai	a0,a5,0x3
    80002b40:	003af7b7          	lui	a5,0x3af
    80002b44:	f6d78793          	addi	a5,a5,-147 # 3aef6d <_entry-0x7fc51093>
    80002b48:	07b2                	slli	a5,a5,0xc
    80002b4a:	a9778793          	addi	a5,a5,-1385
    80002b4e:	07be                	slli	a5,a5,0xf
    80002b50:	2c378793          	addi	a5,a5,707
    80002b54:	07b6                	slli	a5,a5,0xd
    80002b56:	72378793          	addi	a5,a5,1827
    80002b5a:	02f507b3          	mul	a5,a0,a5
    80002b5e:	e2f42023          	sw	a5,-480(s0)
    e.blockno = b->blockno;
    80002b62:	44dc                	lw	a5,12(s1)
    80002b64:	e0f42e23          	sw	a5,-484(s0)
    e.refcnt = b->refcnt;
    80002b68:	40bc                	lw	a5,64(s1)
    80002b6a:	e2f42223          	sw	a5,-476(s0)
    e.old_refcnt = old_ref;
    80002b6e:	e3442423          	sw	s4,-472(s0)
    e.valid = b->valid;
    80002b72:	409c                	lw	a5,0(s1)
    80002b74:	e2f42623          	sw	a5,-468(s0)
    e.old_valid = old_val;
    80002b78:	e3342823          	sw	s3,-464(s0)
    safestrcpy(e.details, det, 128);
    80002b7c:	08000613          	li	a2,128
    80002b80:	85ca                	mv	a1,s2
    80002b82:	f4040513          	addi	a0,s0,-192
    80002b86:	a8cfe0ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    80002b8a:	df840513          	addi	a0,s0,-520
    80002b8e:	01e040ef          	jal	80006bac <fslog_push>
}
    80002b92:	20813083          	ld	ra,520(sp)
    80002b96:	20013403          	ld	s0,512(sp)
    80002b9a:	74fe                	ld	s1,504(sp)
    80002b9c:	795e                	ld	s2,496(sp)
    80002b9e:	79be                	ld	s3,488(sp)
    80002ba0:	7a1e                	ld	s4,480(sp)
    80002ba2:	6afe                	ld	s5,472(sp)
    80002ba4:	21010113          	addi	sp,sp,528
    80002ba8:	8082                	ret

0000000080002baa <binit>:
{
    80002baa:	7179                	addi	sp,sp,-48
    80002bac:	f406                	sd	ra,40(sp)
    80002bae:	f022                	sd	s0,32(sp)
    80002bb0:	ec26                	sd	s1,24(sp)
    80002bb2:	e84a                	sd	s2,16(sp)
    80002bb4:	e44e                	sd	s3,8(sp)
    80002bb6:	e052                	sd	s4,0(sp)
    80002bb8:	1800                	addi	s0,sp,48
  initlock(&bcache.lock, "bcache");
    80002bba:	00005597          	auipc	a1,0x5
    80002bbe:	7ce58593          	addi	a1,a1,1998 # 80008388 <etext+0x388>
    80002bc2:	00014517          	auipc	a0,0x14
    80002bc6:	4ae50513          	addi	a0,a0,1198 # 80017070 <bcache>
    80002bca:	fb7fd0ef          	jal	80000b80 <initlock>
  bcache.head.prev = &bcache.head;
    80002bce:	0001c797          	auipc	a5,0x1c
    80002bd2:	4a278793          	addi	a5,a5,1186 # 8001f070 <bcache+0x8000>
    80002bd6:	0001c717          	auipc	a4,0x1c
    80002bda:	70270713          	addi	a4,a4,1794 # 8001f2d8 <bcache+0x8268>
    80002bde:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002be2:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002be6:	00014497          	auipc	s1,0x14
    80002bea:	4a248493          	addi	s1,s1,1186 # 80017088 <bcache+0x18>
    b->next = bcache.head.next;
    80002bee:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002bf0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002bf2:	00005a17          	auipc	s4,0x5
    80002bf6:	79ea0a13          	addi	s4,s4,1950 # 80008390 <etext+0x390>
    b->next = bcache.head.next;
    80002bfa:	2b893783          	ld	a5,696(s2)
    80002bfe:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c00:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c04:	85d2                	mv	a1,s4
    80002c06:	01048513          	addi	a0,s1,16
    80002c0a:	73d010ef          	jal	80004b46 <initsleeplock>
    bcache.head.next->prev = b;
    80002c0e:	2b893783          	ld	a5,696(s2)
    80002c12:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c14:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c18:	45848493          	addi	s1,s1,1112
    80002c1c:	fd349fe3          	bne	s1,s3,80002bfa <binit+0x50>
}
    80002c20:	70a2                	ld	ra,40(sp)
    80002c22:	7402                	ld	s0,32(sp)
    80002c24:	64e2                	ld	s1,24(sp)
    80002c26:	6942                	ld	s2,16(sp)
    80002c28:	69a2                	ld	s3,8(sp)
    80002c2a:	6a02                	ld	s4,0(sp)
    80002c2c:	6145                	addi	sp,sp,48
    80002c2e:	8082                	ret

0000000080002c30 <bread>:
{
    80002c30:	7179                	addi	sp,sp,-48
    80002c32:	f406                	sd	ra,40(sp)
    80002c34:	f022                	sd	s0,32(sp)
    80002c36:	ec26                	sd	s1,24(sp)
    80002c38:	e84a                	sd	s2,16(sp)
    80002c3a:	e44e                	sd	s3,8(sp)
    80002c3c:	1800                	addi	s0,sp,48
    80002c3e:	892a                	mv	s2,a0
    80002c40:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002c42:	00014517          	auipc	a0,0x14
    80002c46:	42e50513          	addi	a0,a0,1070 # 80017070 <bcache>
    80002c4a:	fb7fd0ef          	jal	80000c00 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c4e:	0001c497          	auipc	s1,0x1c
    80002c52:	6da4b483          	ld	s1,1754(s1) # 8001f328 <bcache+0x82b8>
    80002c56:	0001c797          	auipc	a5,0x1c
    80002c5a:	68278793          	addi	a5,a5,1666 # 8001f2d8 <bcache+0x8268>
    80002c5e:	04f48863          	beq	s1,a5,80002cae <bread+0x7e>
    80002c62:	873e                	mv	a4,a5
    80002c64:	a021                	j	80002c6c <bread+0x3c>
    80002c66:	68a4                	ld	s1,80(s1)
    80002c68:	04e48363          	beq	s1,a4,80002cae <bread+0x7e>
    if(b->dev == dev && b->blockno == blockno){
    80002c6c:	449c                	lw	a5,8(s1)
    80002c6e:	ff279ce3          	bne	a5,s2,80002c66 <bread+0x36>
    80002c72:	44dc                	lw	a5,12(s1)
    80002c74:	ff3799e3          	bne	a5,s3,80002c66 <bread+0x36>
      int old_ref = b->refcnt;
    80002c78:	40b0                	lw	a2,64(s1)
      b->refcnt++;
    80002c7a:	0016079b          	addiw	a5,a2,1
    80002c7e:	c0bc                	sw	a5,64(s1)
      bcache_report("BGET_HIT", b, old_ref, b->valid, "HIT: Buffer found in cache");
    80002c80:	00005717          	auipc	a4,0x5
    80002c84:	71870713          	addi	a4,a4,1816 # 80008398 <etext+0x398>
    80002c88:	4094                	lw	a3,0(s1)
    80002c8a:	85a6                	mv	a1,s1
    80002c8c:	00005517          	auipc	a0,0x5
    80002c90:	72c50513          	addi	a0,a0,1836 # 800083b8 <etext+0x3b8>
    80002c94:	e3dff0ef          	jal	80002ad0 <bcache_report>
      release(&bcache.lock);
    80002c98:	00014517          	auipc	a0,0x14
    80002c9c:	3d850513          	addi	a0,a0,984 # 80017070 <bcache>
    80002ca0:	ff9fd0ef          	jal	80000c98 <release>
      acquiresleep(&b->lock);
    80002ca4:	01048513          	addi	a0,s1,16
    80002ca8:	6d5010ef          	jal	80004b7c <acquiresleep>
      return b;
    80002cac:	a0b5                	j	80002d18 <bread+0xe8>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002cae:	0001c497          	auipc	s1,0x1c
    80002cb2:	6724b483          	ld	s1,1650(s1) # 8001f320 <bcache+0x82b0>
    80002cb6:	0001c797          	auipc	a5,0x1c
    80002cba:	62278793          	addi	a5,a5,1570 # 8001f2d8 <bcache+0x8268>
    80002cbe:	00f48863          	beq	s1,a5,80002cce <bread+0x9e>
    80002cc2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002cc4:	40bc                	lw	a5,64(s1)
    80002cc6:	cb91                	beqz	a5,80002cda <bread+0xaa>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002cc8:	64a4                	ld	s1,72(s1)
    80002cca:	fee49de3          	bne	s1,a4,80002cc4 <bread+0x94>
  panic("bget: no buffers");
    80002cce:	00005517          	auipc	a0,0x5
    80002cd2:	72a50513          	addi	a0,a0,1834 # 800083f8 <etext+0x3f8>
    80002cd6:	b3dfd0ef          	jal	80000812 <panic>
  int old_val = b->valid;
    80002cda:	4094                	lw	a3,0(s1)
  b->dev = dev;
    80002cdc:	0124a423          	sw	s2,8(s1)
  b->blockno = blockno;
    80002ce0:	0134a623          	sw	s3,12(s1)
  b->valid = 0;
    80002ce4:	0004a023          	sw	zero,0(s1)
  b->refcnt = 1;   
    80002ce8:	4785                	li	a5,1
    80002cea:	c0bc                	sw	a5,64(s1)
  bcache_report("BGET_MISS", b, old_ref, old_val, "MISS: Evicting LRU buffer");
    80002cec:	00005717          	auipc	a4,0x5
    80002cf0:	6dc70713          	addi	a4,a4,1756 # 800083c8 <etext+0x3c8>
    80002cf4:	4601                	li	a2,0
    80002cf6:	85a6                	mv	a1,s1
    80002cf8:	00005517          	auipc	a0,0x5
    80002cfc:	6f050513          	addi	a0,a0,1776 # 800083e8 <etext+0x3e8>
    80002d00:	dd1ff0ef          	jal	80002ad0 <bcache_report>
      release(&bcache.lock);
    80002d04:	00014517          	auipc	a0,0x14
    80002d08:	36c50513          	addi	a0,a0,876 # 80017070 <bcache>
    80002d0c:	f8dfd0ef          	jal	80000c98 <release>
      acquiresleep(&b->lock);
    80002d10:	01048513          	addi	a0,s1,16
    80002d14:	669010ef          	jal	80004b7c <acquiresleep>
  if(!b->valid) {
    80002d18:	409c                	lw	a5,0(s1)
    80002d1a:	cb89                	beqz	a5,80002d2c <bread+0xfc>
}
    80002d1c:	8526                	mv	a0,s1
    80002d1e:	70a2                	ld	ra,40(sp)
    80002d20:	7402                	ld	s0,32(sp)
    80002d22:	64e2                	ld	s1,24(sp)
    80002d24:	6942                	ld	s2,16(sp)
    80002d26:	69a2                	ld	s3,8(sp)
    80002d28:	6145                	addi	sp,sp,48
    80002d2a:	8082                	ret
  bcache_report("BREAD_START", b, b->refcnt, old_valid, "Reading from disk...");
    80002d2c:	00005717          	auipc	a4,0x5
    80002d30:	6e470713          	addi	a4,a4,1764 # 80008410 <etext+0x410>
    80002d34:	4681                	li	a3,0
    80002d36:	40b0                	lw	a2,64(s1)
    80002d38:	85a6                	mv	a1,s1
    80002d3a:	00005517          	auipc	a0,0x5
    80002d3e:	6ee50513          	addi	a0,a0,1774 # 80008428 <etext+0x428>
    80002d42:	d8fff0ef          	jal	80002ad0 <bcache_report>
    virtio_disk_rw(b, 0);
    80002d46:	4581                	li	a1,0
    80002d48:	8526                	mv	a0,s1
    80002d4a:	027030ef          	jal	80006570 <virtio_disk_rw>
    b->valid = 1;
    80002d4e:	4785                	li	a5,1
    80002d50:	c09c                	sw	a5,0(s1)
  bcache_report("BREAD_END", b, b->refcnt, b->valid, "Read finished: Valid=1");
    80002d52:	00005717          	auipc	a4,0x5
    80002d56:	6e670713          	addi	a4,a4,1766 # 80008438 <etext+0x438>
    80002d5a:	4685                	li	a3,1
    80002d5c:	40b0                	lw	a2,64(s1)
    80002d5e:	85a6                	mv	a1,s1
    80002d60:	00005517          	auipc	a0,0x5
    80002d64:	6f050513          	addi	a0,a0,1776 # 80008450 <etext+0x450>
    80002d68:	d69ff0ef          	jal	80002ad0 <bcache_report>
  return b;
    80002d6c:	bf45                	j	80002d1c <bread+0xec>

0000000080002d6e <bwrite>:
{
    80002d6e:	1101                	addi	sp,sp,-32
    80002d70:	ec06                	sd	ra,24(sp)
    80002d72:	e822                	sd	s0,16(sp)
    80002d74:	e426                	sd	s1,8(sp)
    80002d76:	e04a                	sd	s2,0(sp)
    80002d78:	1000                	addi	s0,sp,32
    80002d7a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d7c:	0541                	addi	a0,a0,16
    80002d7e:	67d010ef          	jal	80004bfa <holdingsleep>
    80002d82:	cd05                	beqz	a0,80002dba <bwrite+0x4c>
  int old_valid = b->valid;
    80002d84:	0004a903          	lw	s2,0(s1)
  virtio_disk_rw(b, 1);
    80002d88:	4585                	li	a1,1
    80002d8a:	8526                	mv	a0,s1
    80002d8c:	7e4030ef          	jal	80006570 <virtio_disk_rw>
  b->disk = 0;
    80002d90:	0004a223          	sw	zero,4(s1)
  bcache_report("BWRITE", b, b->refcnt, old_valid, "Writing buffer to disk");
    80002d94:	00005717          	auipc	a4,0x5
    80002d98:	6d470713          	addi	a4,a4,1748 # 80008468 <etext+0x468>
    80002d9c:	86ca                	mv	a3,s2
    80002d9e:	40b0                	lw	a2,64(s1)
    80002da0:	85a6                	mv	a1,s1
    80002da2:	00005517          	auipc	a0,0x5
    80002da6:	6de50513          	addi	a0,a0,1758 # 80008480 <etext+0x480>
    80002daa:	d27ff0ef          	jal	80002ad0 <bcache_report>
}
    80002dae:	60e2                	ld	ra,24(sp)
    80002db0:	6442                	ld	s0,16(sp)
    80002db2:	64a2                	ld	s1,8(sp)
    80002db4:	6902                	ld	s2,0(sp)
    80002db6:	6105                	addi	sp,sp,32
    80002db8:	8082                	ret
    panic("bwrite");
    80002dba:	00005517          	auipc	a0,0x5
    80002dbe:	6a650513          	addi	a0,a0,1702 # 80008460 <etext+0x460>
    80002dc2:	a51fd0ef          	jal	80000812 <panic>

0000000080002dc6 <brelse>:
{
    80002dc6:	1101                	addi	sp,sp,-32
    80002dc8:	ec06                	sd	ra,24(sp)
    80002dca:	e822                	sd	s0,16(sp)
    80002dcc:	e426                	sd	s1,8(sp)
    80002dce:	e04a                	sd	s2,0(sp)
    80002dd0:	1000                	addi	s0,sp,32
    80002dd2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002dd4:	01050913          	addi	s2,a0,16
    80002dd8:	854a                	mv	a0,s2
    80002dda:	621010ef          	jal	80004bfa <holdingsleep>
    80002dde:	cd35                	beqz	a0,80002e5a <brelse+0x94>
  releasesleep(&b->lock);
    80002de0:	854a                	mv	a0,s2
    80002de2:	5e1010ef          	jal	80004bc2 <releasesleep>
  acquire(&bcache.lock);
    80002de6:	00014517          	auipc	a0,0x14
    80002dea:	28a50513          	addi	a0,a0,650 # 80017070 <bcache>
    80002dee:	e13fd0ef          	jal	80000c00 <acquire>
  int old_ref = b->refcnt;
    80002df2:	40b0                	lw	a2,64(s1)
  b->refcnt--;
    80002df4:	fff6079b          	addiw	a5,a2,-1
    80002df8:	c0bc                	sw	a5,64(s1)
  bcache_report("BRELEASE", b, old_ref, old_valid, "Released buffer");
    80002dfa:	00005717          	auipc	a4,0x5
    80002dfe:	69670713          	addi	a4,a4,1686 # 80008490 <etext+0x490>
    80002e02:	4094                	lw	a3,0(s1)
    80002e04:	85a6                	mv	a1,s1
    80002e06:	00005517          	auipc	a0,0x5
    80002e0a:	69a50513          	addi	a0,a0,1690 # 800084a0 <etext+0x4a0>
    80002e0e:	cc3ff0ef          	jal	80002ad0 <bcache_report>
  if (b->refcnt == 0) {
    80002e12:	40bc                	lw	a5,64(s1)
    80002e14:	e79d                	bnez	a5,80002e42 <brelse+0x7c>
    b->next->prev = b->prev;
    80002e16:	68b8                	ld	a4,80(s1)
    80002e18:	64bc                	ld	a5,72(s1)
    80002e1a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e1c:	68b8                	ld	a4,80(s1)
    80002e1e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e20:	0001c797          	auipc	a5,0x1c
    80002e24:	25078793          	addi	a5,a5,592 # 8001f070 <bcache+0x8000>
    80002e28:	2b87b703          	ld	a4,696(a5)
    80002e2c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e2e:	0001c717          	auipc	a4,0x1c
    80002e32:	4aa70713          	addi	a4,a4,1194 # 8001f2d8 <bcache+0x8268>
    80002e36:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e38:	2b87b703          	ld	a4,696(a5)
    80002e3c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e3e:	2a97bc23          	sd	s1,696(a5)
  release(&bcache.lock);
    80002e42:	00014517          	auipc	a0,0x14
    80002e46:	22e50513          	addi	a0,a0,558 # 80017070 <bcache>
    80002e4a:	e4ffd0ef          	jal	80000c98 <release>
}
    80002e4e:	60e2                	ld	ra,24(sp)
    80002e50:	6442                	ld	s0,16(sp)
    80002e52:	64a2                	ld	s1,8(sp)
    80002e54:	6902                	ld	s2,0(sp)
    80002e56:	6105                	addi	sp,sp,32
    80002e58:	8082                	ret
    panic("brelse");
    80002e5a:	00005517          	auipc	a0,0x5
    80002e5e:	62e50513          	addi	a0,a0,1582 # 80008488 <etext+0x488>
    80002e62:	9b1fd0ef          	jal	80000812 <panic>

0000000080002e66 <bpin>:
bpin(struct buf *b) {
    80002e66:	1101                	addi	sp,sp,-32
    80002e68:	ec06                	sd	ra,24(sp)
    80002e6a:	e822                	sd	s0,16(sp)
    80002e6c:	e426                	sd	s1,8(sp)
    80002e6e:	1000                	addi	s0,sp,32
    80002e70:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e72:	00014517          	auipc	a0,0x14
    80002e76:	1fe50513          	addi	a0,a0,510 # 80017070 <bcache>
    80002e7a:	d87fd0ef          	jal	80000c00 <acquire>
  int old_ref = b->refcnt;
    80002e7e:	40b0                	lw	a2,64(s1)
  b->refcnt++;
    80002e80:	0016079b          	addiw	a5,a2,1
    80002e84:	c0bc                	sw	a5,64(s1)
  bcache_report("BPIN", b, old_ref, old_valid, "Pinned buffer"); 
    80002e86:	00005717          	auipc	a4,0x5
    80002e8a:	62a70713          	addi	a4,a4,1578 # 800084b0 <etext+0x4b0>
    80002e8e:	4094                	lw	a3,0(s1)
    80002e90:	85a6                	mv	a1,s1
    80002e92:	00005517          	auipc	a0,0x5
    80002e96:	62e50513          	addi	a0,a0,1582 # 800084c0 <etext+0x4c0>
    80002e9a:	c37ff0ef          	jal	80002ad0 <bcache_report>
  release(&bcache.lock);
    80002e9e:	00014517          	auipc	a0,0x14
    80002ea2:	1d250513          	addi	a0,a0,466 # 80017070 <bcache>
    80002ea6:	df3fd0ef          	jal	80000c98 <release>
}
    80002eaa:	60e2                	ld	ra,24(sp)
    80002eac:	6442                	ld	s0,16(sp)
    80002eae:	64a2                	ld	s1,8(sp)
    80002eb0:	6105                	addi	sp,sp,32
    80002eb2:	8082                	ret

0000000080002eb4 <bunpin>:
bunpin(struct buf *b) {
    80002eb4:	1101                	addi	sp,sp,-32
    80002eb6:	ec06                	sd	ra,24(sp)
    80002eb8:	e822                	sd	s0,16(sp)
    80002eba:	e426                	sd	s1,8(sp)
    80002ebc:	1000                	addi	s0,sp,32
    80002ebe:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ec0:	00014517          	auipc	a0,0x14
    80002ec4:	1b050513          	addi	a0,a0,432 # 80017070 <bcache>
    80002ec8:	d39fd0ef          	jal	80000c00 <acquire>
  int old_ref = b->refcnt;
    80002ecc:	40b0                	lw	a2,64(s1)
  b->refcnt--;
    80002ece:	fff6079b          	addiw	a5,a2,-1
    80002ed2:	c0bc                	sw	a5,64(s1)
  bcache_report("BUNPIN",b, old_ref, old_valid, "Unpinned buffer");
    80002ed4:	00005717          	auipc	a4,0x5
    80002ed8:	5f470713          	addi	a4,a4,1524 # 800084c8 <etext+0x4c8>
    80002edc:	4094                	lw	a3,0(s1)
    80002ede:	85a6                	mv	a1,s1
    80002ee0:	00005517          	auipc	a0,0x5
    80002ee4:	5f850513          	addi	a0,a0,1528 # 800084d8 <etext+0x4d8>
    80002ee8:	be9ff0ef          	jal	80002ad0 <bcache_report>
  release(&bcache.lock);
    80002eec:	00014517          	auipc	a0,0x14
    80002ef0:	18450513          	addi	a0,a0,388 # 80017070 <bcache>
    80002ef4:	da5fd0ef          	jal	80000c98 <release>
}
    80002ef8:	60e2                	ld	ra,24(sp)
    80002efa:	6442                	ld	s0,16(sp)
    80002efc:	64a2                	ld	s1,8(sp)
    80002efe:	6105                	addi	sp,sp,32
    80002f00:	8082                	ret

0000000080002f02 <dir_report>:
    struct inode *dp,
    char *name,
    uint target,
    uint off,
    char *details
){
    80002f02:	df010113          	addi	sp,sp,-528
    80002f06:	20113423          	sd	ra,520(sp)
    80002f0a:	20813023          	sd	s0,512(sp)
    80002f0e:	ffa6                	sd	s1,504(sp)
    80002f10:	fbca                	sd	s2,496(sp)
    80002f12:	f7ce                	sd	s3,488(sp)
    80002f14:	f3d2                	sd	s4,480(sp)
    80002f16:	efd6                	sd	s5,472(sp)
    80002f18:	ebda                	sd	s6,464(sp)
    80002f1a:	0c00                	addi	s0,sp,528
    80002f1c:	8b2a                	mv	s6,a0
    80002f1e:	84ae                	mv	s1,a1
    80002f20:	8932                	mv	s2,a2
    80002f22:	8ab6                	mv	s5,a3
    80002f24:	8a3a                	mv	s4,a4
    80002f26:	89be                	mv	s3,a5
    struct fs_event e;

    memset(&e, 0, sizeof(e));
    80002f28:	1c800613          	li	a2,456
    80002f2c:	4581                	li	a1,0
    80002f2e:	df840513          	addi	a0,s0,-520
    80002f32:	da3fd0ef          	jal	80000cd4 <memset>

    e.ticks = ticks;
    80002f36:	00006797          	auipc	a5,0x6
    80002f3a:	1b27a783          	lw	a5,434(a5) # 800090e8 <ticks>
    80002f3e:	e0f42023          	sw	a5,-512(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    80002f42:	9c7fe0ef          	jal	80001908 <myproc>
    80002f46:	4781                	li	a5,0
    80002f48:	c501                	beqz	a0,80002f50 <dir_report+0x4e>
    80002f4a:	9bffe0ef          	jal	80001908 <myproc>
    80002f4e:	591c                	lw	a5,48(a0)
    80002f50:	e0f42223          	sw	a5,-508(s0)

    e.type = LAYER_DIR;
    80002f54:	4795                	li	a5,5
    80002f56:	e0f42423          	sw	a5,-504(s0)

    safestrcpy(e.op_name, op, sizeof(e.op_name));
    80002f5a:	4641                	li	a2,16
    80002f5c:	85da                	mv	a1,s6
    80002f5e:	e0c40513          	addi	a0,s0,-500
    80002f62:	eb1fd0ef          	jal	80000e12 <safestrcpy>

    if(name)
    80002f66:	00090863          	beqz	s2,80002f76 <dir_report+0x74>
        safestrcpy(e.name, name, sizeof(e.name));
    80002f6a:	4651                	li	a2,20
    80002f6c:	85ca                	mv	a1,s2
    80002f6e:	f0040513          	addi	a0,s0,-256
    80002f72:	ea1fd0ef          	jal	80000e12 <safestrcpy>

    e.parent_inum = dp ? dp->inum : -1;
    80002f76:	57fd                	li	a5,-1
    80002f78:	c091                	beqz	s1,80002f7c <dir_report+0x7a>
    80002f7a:	40dc                	lw	a5,4(s1)
    80002f7c:	f0f42a23          	sw	a5,-236(s0)
    e.target_inum = target;
    80002f80:	f1542c23          	sw	s5,-232(s0)
    e.offset = off;
    80002f84:	f1442e23          	sw	s4,-228(s0)

    safestrcpy(e.details, details, sizeof(e.details));
    80002f88:	08000613          	li	a2,128
    80002f8c:	85ce                	mv	a1,s3
    80002f8e:	f4040513          	addi	a0,s0,-192
    80002f92:	e81fd0ef          	jal	80000e12 <safestrcpy>

    fslog_push(&e);
    80002f96:	df840513          	addi	a0,s0,-520
    80002f9a:	413030ef          	jal	80006bac <fslog_push>
}
    80002f9e:	20813083          	ld	ra,520(sp)
    80002fa2:	20013403          	ld	s0,512(sp)
    80002fa6:	74fe                	ld	s1,504(sp)
    80002fa8:	795e                	ld	s2,496(sp)
    80002faa:	79be                	ld	s3,488(sp)
    80002fac:	7a1e                	ld	s4,480(sp)
    80002fae:	6afe                	ld	s5,472(sp)
    80002fb0:	6b5e                	ld	s6,464(sp)
    80002fb2:	21010113          	addi	sp,sp,528
    80002fb6:	8082                	ret

0000000080002fb8 <path_report>:
    char *op,
    char *path,
    char *elem,
    struct inode *ip,
    char *details
){
    80002fb8:	df010113          	addi	sp,sp,-528
    80002fbc:	20113423          	sd	ra,520(sp)
    80002fc0:	20813023          	sd	s0,512(sp)
    80002fc4:	ffa6                	sd	s1,504(sp)
    80002fc6:	fbca                	sd	s2,496(sp)
    80002fc8:	f7ce                	sd	s3,488(sp)
    80002fca:	f3d2                	sd	s4,480(sp)
    80002fcc:	efd6                	sd	s5,472(sp)
    80002fce:	0c00                	addi	s0,sp,528
    80002fd0:	8aaa                	mv	s5,a0
    80002fd2:	8a2e                	mv	s4,a1
    80002fd4:	89b2                	mv	s3,a2
    80002fd6:	84b6                	mv	s1,a3
    80002fd8:	893a                	mv	s2,a4
    struct fs_event e;

    memset(&e, 0, sizeof(e));
    80002fda:	1c800613          	li	a2,456
    80002fde:	4581                	li	a1,0
    80002fe0:	df840513          	addi	a0,s0,-520
    80002fe4:	cf1fd0ef          	jal	80000cd4 <memset>

    e.ticks = ticks;
    80002fe8:	00006797          	auipc	a5,0x6
    80002fec:	1007a783          	lw	a5,256(a5) # 800090e8 <ticks>
    80002ff0:	e0f42023          	sw	a5,-512(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    80002ff4:	915fe0ef          	jal	80001908 <myproc>
    80002ff8:	4781                	li	a5,0
    80002ffa:	c501                	beqz	a0,80003002 <path_report+0x4a>
    80002ffc:	90dfe0ef          	jal	80001908 <myproc>
    80003000:	591c                	lw	a5,48(a0)
    80003002:	e0f42223          	sw	a5,-508(s0)

    e.type = LAYER_PATH;
    80003006:	4799                	li	a5,6
    80003008:	e0f42423          	sw	a5,-504(s0)

    safestrcpy(e.op_name, op, sizeof(e.op_name));
    8000300c:	4641                	li	a2,16
    8000300e:	85d6                	mv	a1,s5
    80003010:	e0c40513          	addi	a0,s0,-500
    80003014:	dfffd0ef          	jal	80000e12 <safestrcpy>

    if(path)
    80003018:	000a0963          	beqz	s4,8000302a <path_report+0x72>
        safestrcpy(e.path, path, sizeof(e.path));
    8000301c:	08000613          	li	a2,128
    80003020:	85d2                	mv	a1,s4
    80003022:	e8040513          	addi	a0,s0,-384
    80003026:	dedfd0ef          	jal	80000e12 <safestrcpy>

    if(elem)
    8000302a:	00098863          	beqz	s3,8000303a <path_report+0x82>
        safestrcpy(e.name, elem, sizeof(e.name));
    8000302e:	4651                	li	a2,20
    80003030:	85ce                	mv	a1,s3
    80003032:	f0040513          	addi	a0,s0,-256
    80003036:	dddfd0ef          	jal	80000e12 <safestrcpy>

    e.parent_inum = ip ? ip->inum : -1;
    8000303a:	57fd                	li	a5,-1
    8000303c:	c091                	beqz	s1,80003040 <path_report+0x88>
    8000303e:	40dc                	lw	a5,4(s1)
    80003040:	f0f42a23          	sw	a5,-236(s0)

    safestrcpy(e.details, details, sizeof(e.details));
    80003044:	08000613          	li	a2,128
    80003048:	85ca                	mv	a1,s2
    8000304a:	f4040513          	addi	a0,s0,-192
    8000304e:	dc5fd0ef          	jal	80000e12 <safestrcpy>

    fslog_push(&e);
    80003052:	df840513          	addi	a0,s0,-520
    80003056:	357030ef          	jal	80006bac <fslog_push>
}
    8000305a:	20813083          	ld	ra,520(sp)
    8000305e:	20013403          	ld	s0,512(sp)
    80003062:	74fe                	ld	s1,504(sp)
    80003064:	795e                	ld	s2,496(sp)
    80003066:	79be                	ld	s3,488(sp)
    80003068:	7a1e                	ld	s4,480(sp)
    8000306a:	6afe                	ld	s5,472(sp)
    8000306c:	21010113          	addi	sp,sp,528
    80003070:	8082                	ret

0000000080003072 <balloc_report>:
void balloc_report(char* op, int blockno, int old_bit, int new_bit, char* det) {
    80003072:	df010113          	addi	sp,sp,-528
    80003076:	20113423          	sd	ra,520(sp)
    8000307a:	20813023          	sd	s0,512(sp)
    8000307e:	ffa6                	sd	s1,504(sp)
    80003080:	fbca                	sd	s2,496(sp)
    80003082:	f7ce                	sd	s3,488(sp)
    80003084:	f3d2                	sd	s4,480(sp)
    80003086:	efd6                	sd	s5,472(sp)
    80003088:	0c00                	addi	s0,sp,528
    8000308a:	8aaa                	mv	s5,a0
    8000308c:	8a2e                	mv	s4,a1
    8000308e:	89b2                	mv	s3,a2
    80003090:	8936                	mv	s2,a3
    80003092:	84ba                	mv	s1,a4
    memset(&e, 0, sizeof(e));
    80003094:	1c800613          	li	a2,456
    80003098:	4581                	li	a1,0
    8000309a:	df840513          	addi	a0,s0,-520
    8000309e:	c37fd0ef          	jal	80000cd4 <memset>
    e.ticks = ticks;
    800030a2:	00006797          	auipc	a5,0x6
    800030a6:	0467a783          	lw	a5,70(a5) # 800090e8 <ticks>
    800030aa:	e0f42023          	sw	a5,-512(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    800030ae:	85bfe0ef          	jal	80001908 <myproc>
    800030b2:	4781                	li	a5,0
    800030b4:	c501                	beqz	a0,800030bc <balloc_report+0x4a>
    800030b6:	853fe0ef          	jal	80001908 <myproc>
    800030ba:	591c                	lw	a5,48(a0)
    800030bc:	e0f42223          	sw	a5,-508(s0)
    e.type = LAYER_BALLOC;
    800030c0:	478d                	li	a5,3
    800030c2:	e0f42423          	sw	a5,-504(s0)
    safestrcpy(e.op_name, op, 16);
    800030c6:	4641                	li	a2,16
    800030c8:	85d6                	mv	a1,s5
    800030ca:	e0c40513          	addi	a0,s0,-500
    800030ce:	d45fd0ef          	jal	80000e12 <safestrcpy>
    e.blockno = blockno;
    800030d2:	e1442e23          	sw	s4,-484(s0)
    e.old_bit = old_bit;
    800030d6:	e5342823          	sw	s3,-432(s0)
    e.bit = new_bit;
    800030da:	e5242623          	sw	s2,-436(s0)
    safestrcpy(e.details, det, 128);
    800030de:	08000613          	li	a2,128
    800030e2:	85a6                	mv	a1,s1
    800030e4:	f4040513          	addi	a0,s0,-192
    800030e8:	d2bfd0ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    800030ec:	df840513          	addi	a0,s0,-520
    800030f0:	2bd030ef          	jal	80006bac <fslog_push>
}
    800030f4:	20813083          	ld	ra,520(sp)
    800030f8:	20013403          	ld	s0,512(sp)
    800030fc:	74fe                	ld	s1,504(sp)
    800030fe:	795e                	ld	s2,496(sp)
    80003100:	79be                	ld	s3,488(sp)
    80003102:	7a1e                	ld	s4,480(sp)
    80003104:	6afe                	ld	s5,472(sp)
    80003106:	21010113          	addi	sp,sp,528
    8000310a:	8082                	ret

000000008000310c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000310c:	1101                	addi	sp,sp,-32
    8000310e:	ec06                	sd	ra,24(sp)
    80003110:	e822                	sd	s0,16(sp)
    80003112:	e426                	sd	s1,8(sp)
    80003114:	e04a                	sd	s2,0(sp)
    80003116:	1000                	addi	s0,sp,32
    80003118:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000311a:	00d5d59b          	srliw	a1,a1,0xd
    8000311e:	0001c797          	auipc	a5,0x1c
    80003122:	62e7a783          	lw	a5,1582(a5) # 8001f74c <sb+0x1c>
    80003126:	9dbd                	addw	a1,a1,a5
    80003128:	b09ff0ef          	jal	80002c30 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000312c:	0074f793          	andi	a5,s1,7
    80003130:	4705                	li	a4,1
    80003132:	00f7173b          	sllw	a4,a4,a5
  if((bp->data[bi/8] & m) == 0)
    80003136:	03349793          	slli	a5,s1,0x33
    8000313a:	93d9                	srli	a5,a5,0x36
    8000313c:	00f506b3          	add	a3,a0,a5
    80003140:	0586c683          	lbu	a3,88(a3) # 1058 <_entry-0x7fffefa8>
    80003144:	00d77633          	and	a2,a4,a3
    80003148:	c229                	beqz	a2,8000318a <bfree+0x7e>
    8000314a:	892a                	mv	s2,a0
    panic("freeing free block");
  int old_bit = 1;
  bp->data[bi/8] &= ~m;
    8000314c:	97aa                	add	a5,a5,a0
    8000314e:	fff74713          	not	a4,a4
    80003152:	8ef9                	and	a3,a3,a4
    80003154:	04d78c23          	sb	a3,88(a5)
  balloc_report("BFREE", b, old_bit, 0, "Freed block");
    80003158:	00005717          	auipc	a4,0x5
    8000315c:	3a070713          	addi	a4,a4,928 # 800084f8 <etext+0x4f8>
    80003160:	4681                	li	a3,0
    80003162:	4605                	li	a2,1
    80003164:	85a6                	mv	a1,s1
    80003166:	00005517          	auipc	a0,0x5
    8000316a:	3a250513          	addi	a0,a0,930 # 80008508 <etext+0x508>
    8000316e:	f05ff0ef          	jal	80003072 <balloc_report>
  log_write(bp);
    80003172:	854a                	mv	a0,s2
    80003174:	0eb010ef          	jal	80004a5e <log_write>
  brelse(bp);
    80003178:	854a                	mv	a0,s2
    8000317a:	c4dff0ef          	jal	80002dc6 <brelse>
}
    8000317e:	60e2                	ld	ra,24(sp)
    80003180:	6442                	ld	s0,16(sp)
    80003182:	64a2                	ld	s1,8(sp)
    80003184:	6902                	ld	s2,0(sp)
    80003186:	6105                	addi	sp,sp,32
    80003188:	8082                	ret
    panic("freeing free block");
    8000318a:	00005517          	auipc	a0,0x5
    8000318e:	35650513          	addi	a0,a0,854 # 800084e0 <etext+0x4e0>
    80003192:	e80fd0ef          	jal	80000812 <panic>

0000000080003196 <balloc>:
{
    80003196:	711d                	addi	sp,sp,-96
    80003198:	ec86                	sd	ra,88(sp)
    8000319a:	e8a2                	sd	s0,80(sp)
    8000319c:	e4a6                	sd	s1,72(sp)
    8000319e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031a0:	0001c797          	auipc	a5,0x1c
    800031a4:	5947a783          	lw	a5,1428(a5) # 8001f734 <sb+0x4>
    800031a8:	10078c63          	beqz	a5,800032c0 <balloc+0x12a>
    800031ac:	e0ca                	sd	s2,64(sp)
    800031ae:	fc4e                	sd	s3,56(sp)
    800031b0:	f852                	sd	s4,48(sp)
    800031b2:	f456                	sd	s5,40(sp)
    800031b4:	f05a                	sd	s6,32(sp)
    800031b6:	ec5e                	sd	s7,24(sp)
    800031b8:	e862                	sd	s8,16(sp)
    800031ba:	e466                	sd	s9,8(sp)
    800031bc:	8baa                	mv	s7,a0
    800031be:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031c0:	0001cb17          	auipc	s6,0x1c
    800031c4:	570b0b13          	addi	s6,s6,1392 # 8001f730 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031c8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031ca:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031cc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031ce:	6c89                	lui	s9,0x2
    800031d0:	a059                	j	80003256 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031d2:	97ca                	add	a5,a5,s2
    800031d4:	8e55                	or	a2,a2,a3
    800031d6:	04c78c23          	sb	a2,88(a5)
        balloc_report("BALLOC", b + bi, old_bit, 1, "Allocated block");
    800031da:	00005717          	auipc	a4,0x5
    800031de:	33670713          	addi	a4,a4,822 # 80008510 <etext+0x510>
    800031e2:	4685                	li	a3,1
    800031e4:	4601                	li	a2,0
    800031e6:	85a6                	mv	a1,s1
    800031e8:	00005517          	auipc	a0,0x5
    800031ec:	33850513          	addi	a0,a0,824 # 80008520 <etext+0x520>
    800031f0:	e83ff0ef          	jal	80003072 <balloc_report>
        log_write(bp);
    800031f4:	854a                	mv	a0,s2
    800031f6:	069010ef          	jal	80004a5e <log_write>
        brelse(bp);
    800031fa:	854a                	mv	a0,s2
    800031fc:	bcbff0ef          	jal	80002dc6 <brelse>
  bp = bread(dev, bno);
    80003200:	85a6                	mv	a1,s1
    80003202:	855e                	mv	a0,s7
    80003204:	a2dff0ef          	jal	80002c30 <bread>
    80003208:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000320a:	40000613          	li	a2,1024
    8000320e:	4581                	li	a1,0
    80003210:	05850513          	addi	a0,a0,88
    80003214:	ac1fd0ef          	jal	80000cd4 <memset>
  log_write(bp);
    80003218:	854a                	mv	a0,s2
    8000321a:	045010ef          	jal	80004a5e <log_write>
  brelse(bp);
    8000321e:	854a                	mv	a0,s2
    80003220:	ba7ff0ef          	jal	80002dc6 <brelse>
}
    80003224:	6906                	ld	s2,64(sp)
    80003226:	79e2                	ld	s3,56(sp)
    80003228:	7a42                	ld	s4,48(sp)
    8000322a:	7aa2                	ld	s5,40(sp)
    8000322c:	7b02                	ld	s6,32(sp)
    8000322e:	6be2                	ld	s7,24(sp)
    80003230:	6c42                	ld	s8,16(sp)
    80003232:	6ca2                	ld	s9,8(sp)
}
    80003234:	8526                	mv	a0,s1
    80003236:	60e6                	ld	ra,88(sp)
    80003238:	6446                	ld	s0,80(sp)
    8000323a:	64a6                	ld	s1,72(sp)
    8000323c:	6125                	addi	sp,sp,96
    8000323e:	8082                	ret
    brelse(bp);
    80003240:	854a                	mv	a0,s2
    80003242:	b85ff0ef          	jal	80002dc6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003246:	015c87bb          	addw	a5,s9,s5
    8000324a:	00078a9b          	sext.w	s5,a5
    8000324e:	004b2703          	lw	a4,4(s6)
    80003252:	04eaff63          	bgeu	s5,a4,800032b0 <balloc+0x11a>
    bp = bread(dev, BBLOCK(b, sb));
    80003256:	41fad79b          	sraiw	a5,s5,0x1f
    8000325a:	0137d79b          	srliw	a5,a5,0x13
    8000325e:	015787bb          	addw	a5,a5,s5
    80003262:	40d7d79b          	sraiw	a5,a5,0xd
    80003266:	01cb2583          	lw	a1,28(s6)
    8000326a:	9dbd                	addw	a1,a1,a5
    8000326c:	855e                	mv	a0,s7
    8000326e:	9c3ff0ef          	jal	80002c30 <bread>
    80003272:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003274:	004b2503          	lw	a0,4(s6)
    80003278:	000a849b          	sext.w	s1,s5
    8000327c:	8762                	mv	a4,s8
    8000327e:	fca4f1e3          	bgeu	s1,a0,80003240 <balloc+0xaa>
      m = 1 << (bi % 8);
    80003282:	00777693          	andi	a3,a4,7
    80003286:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){
    8000328a:	41f7579b          	sraiw	a5,a4,0x1f
    8000328e:	01d7d79b          	srliw	a5,a5,0x1d
    80003292:	9fb9                	addw	a5,a5,a4
    80003294:	4037d79b          	sraiw	a5,a5,0x3
    80003298:	00f90633          	add	a2,s2,a5
    8000329c:	05864603          	lbu	a2,88(a2)
    800032a0:	00c6f5b3          	and	a1,a3,a2
    800032a4:	d59d                	beqz	a1,800031d2 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032a6:	2705                	addiw	a4,a4,1
    800032a8:	2485                	addiw	s1,s1,1
    800032aa:	fd471ae3          	bne	a4,s4,8000327e <balloc+0xe8>
    800032ae:	bf49                	j	80003240 <balloc+0xaa>
    800032b0:	6906                	ld	s2,64(sp)
    800032b2:	79e2                	ld	s3,56(sp)
    800032b4:	7a42                	ld	s4,48(sp)
    800032b6:	7aa2                	ld	s5,40(sp)
    800032b8:	7b02                	ld	s6,32(sp)
    800032ba:	6be2                	ld	s7,24(sp)
    800032bc:	6c42                	ld	s8,16(sp)
    800032be:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800032c0:	00005517          	auipc	a0,0x5
    800032c4:	26850513          	addi	a0,a0,616 # 80008528 <etext+0x528>
    800032c8:	a64fd0ef          	jal	8000052c <printf>
  return 0;
    800032cc:	4481                	li	s1,0
    800032ce:	b79d                	j	80003234 <balloc+0x9e>

00000000800032d0 <inode_report>:
{
    800032d0:	de010113          	addi	sp,sp,-544
    800032d4:	20113c23          	sd	ra,536(sp)
    800032d8:	20813823          	sd	s0,528(sp)
    800032dc:	20913423          	sd	s1,520(sp)
    800032e0:	21213023          	sd	s2,512(sp)
    800032e4:	ffce                	sd	s3,504(sp)
    800032e6:	fbd2                	sd	s4,496(sp)
    800032e8:	f7d6                	sd	s5,488(sp)
    800032ea:	f3da                	sd	s6,480(sp)
    800032ec:	efde                	sd	s7,472(sp)
    800032ee:	ebe2                	sd	s8,464(sp)
    800032f0:	1400                	addi	s0,sp,544
    800032f2:	8c2a                	mv	s8,a0
    800032f4:	84ae                	mv	s1,a1
    800032f6:	8bb2                	mv	s7,a2
    800032f8:	8b36                	mv	s6,a3
    800032fa:	8aba                	mv	s5,a4
    800032fc:	8a3e                	mv	s4,a5
    800032fe:	89c2                	mv	s3,a6
    80003300:	8946                	mv	s2,a7
  memset(&e, 0, sizeof(e));
    80003302:	1c800613          	li	a2,456
    80003306:	4581                	li	a1,0
    80003308:	de840513          	addi	a0,s0,-536
    8000330c:	9c9fd0ef          	jal	80000cd4 <memset>
  e.ticks = ticks;
    80003310:	00006797          	auipc	a5,0x6
    80003314:	dd87a783          	lw	a5,-552(a5) # 800090e8 <ticks>
    80003318:	def42823          	sw	a5,-528(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    8000331c:	decfe0ef          	jal	80001908 <myproc>
    80003320:	4781                	li	a5,0
    80003322:	c501                	beqz	a0,8000332a <inode_report+0x5a>
    80003324:	de4fe0ef          	jal	80001908 <myproc>
    80003328:	591c                	lw	a5,48(a0)
    8000332a:	def42a23          	sw	a5,-524(s0)
  e.type = LAYER_INODE;
    8000332e:	4791                	li	a5,4
    80003330:	def42c23          	sw	a5,-520(s0)
  safestrcpy(e.op_name, op, 16);
    80003334:	4641                	li	a2,16
    80003336:	85e2                	mv	a1,s8
    80003338:	dfc40513          	addi	a0,s0,-516
    8000333c:	ad7fd0ef          	jal	80000e12 <safestrcpy>
  e.inum = ip->inum;
    80003340:	40dc                	lw	a5,4(s1)
    80003342:	e4f42223          	sw	a5,-444(s0)
  e.ref = ip->ref;
    80003346:	449c                	lw	a5,8(s1)
    80003348:	e4f42423          	sw	a5,-440(s0)
  e.old_ref = old_ref;
    8000334c:	e5742623          	sw	s7,-436(s0)
  e.valid_inode = ip->valid;
    80003350:	40bc                	lw	a5,64(s1)
    80003352:	e4f42823          	sw	a5,-432(s0)
  e.old_valid_inode = old_valid;
    80003356:	e5642a23          	sw	s6,-428(s0)
  e.type_inode = ip->type;
    8000335a:	04449783          	lh	a5,68(s1)
    8000335e:	e4f42c23          	sw	a5,-424(s0)
  e.old_type_inode = old_type;
    80003362:	e5542e23          	sw	s5,-420(s0)
  e.size = ip->size;
    80003366:	44fc                	lw	a5,76(s1)
    80003368:	e6f42023          	sw	a5,-416(s0)
  e.old_size = old_size;
    8000336c:	e7442223          	sw	s4,-412(s0)
  e.locked = holdingsleep(&ip->lock);
    80003370:	01048513          	addi	a0,s1,16
    80003374:	087010ef          	jal	80004bfa <holdingsleep>
    80003378:	e6a42423          	sw	a0,-408(s0)
  e.old_locked = old_locked;
    8000337c:	e7342623          	sw	s3,-404(s0)
  safestrcpy(e.details, det, 128);
    80003380:	08000613          	li	a2,128
    80003384:	85ca                	mv	a1,s2
    80003386:	f3040513          	addi	a0,s0,-208
    8000338a:	a89fd0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    8000338e:	de840513          	addi	a0,s0,-536
    80003392:	01b030ef          	jal	80006bac <fslog_push>
}
    80003396:	21813083          	ld	ra,536(sp)
    8000339a:	21013403          	ld	s0,528(sp)
    8000339e:	20813483          	ld	s1,520(sp)
    800033a2:	20013903          	ld	s2,512(sp)
    800033a6:	79fe                	ld	s3,504(sp)
    800033a8:	7a5e                	ld	s4,496(sp)
    800033aa:	7abe                	ld	s5,488(sp)
    800033ac:	7b1e                	ld	s6,480(sp)
    800033ae:	6bfe                	ld	s7,472(sp)
    800033b0:	6c5e                	ld	s8,464(sp)
    800033b2:	22010113          	addi	sp,sp,544
    800033b6:	8082                	ret

00000000800033b8 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
    800033b8:	7179                	addi	sp,sp,-48
    800033ba:	f406                	sd	ra,40(sp)
    800033bc:	f022                	sd	s0,32(sp)
    800033be:	ec26                	sd	s1,24(sp)
    800033c0:	e84a                	sd	s2,16(sp)
    800033c2:	e44e                	sd	s3,8(sp)
    800033c4:	e052                	sd	s4,0(sp)
    800033c6:	1800                	addi	s0,sp,48
    800033c8:	89aa                	mv	s3,a0
    800033ca:	8a2e                	mv	s4,a1
  struct inode *ip, *empty;

  acquire(&itable.lock);
    800033cc:	0001c517          	auipc	a0,0x1c
    800033d0:	38450513          	addi	a0,a0,900 # 8001f750 <itable>
    800033d4:	82dfd0ef          	jal	80000c00 <acquire>

  // Is the inode already in the table?
  empty = 0;
    800033d8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033da:	0001c497          	auipc	s1,0x1c
    800033de:	38e48493          	addi	s1,s1,910 # 8001f768 <itable+0x18>
    800033e2:	0001e717          	auipc	a4,0x1e
    800033e6:	e1670713          	addi	a4,a4,-490 # 800211f8 <log>
    800033ea:	a039                	j	800033f8 <iget+0x40>
      0,
      "Inode found in cache");
      release(&itable.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033ec:	04090a63          	beqz	s2,80003440 <iget+0x88>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033f0:	08848493          	addi	s1,s1,136
    800033f4:	04e48963          	beq	s1,a4,80003446 <iget+0x8e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033f8:	4490                	lw	a2,8(s1)
    800033fa:	fec059e3          	blez	a2,800033ec <iget+0x34>
    800033fe:	409c                	lw	a5,0(s1)
    80003400:	ff3796e3          	bne	a5,s3,800033ec <iget+0x34>
    80003404:	40dc                	lw	a5,4(s1)
    80003406:	ff4793e3          	bne	a5,s4,800033ec <iget+0x34>
      ip->ref++;
    8000340a:	0016079b          	addiw	a5,a2,1
    8000340e:	c49c                	sw	a5,8(s1)
       inode_report("IGET_HIT", ip,
    80003410:	00005897          	auipc	a7,0x5
    80003414:	13088893          	addi	a7,a7,304 # 80008540 <etext+0x540>
    80003418:	4801                	li	a6,0
    8000341a:	44fc                	lw	a5,76(s1)
    8000341c:	04449703          	lh	a4,68(s1)
    80003420:	40b4                	lw	a3,64(s1)
    80003422:	85a6                	mv	a1,s1
    80003424:	00005517          	auipc	a0,0x5
    80003428:	13450513          	addi	a0,a0,308 # 80008558 <etext+0x558>
    8000342c:	ea5ff0ef          	jal	800032d0 <inode_report>
      release(&itable.lock);
    80003430:	0001c517          	auipc	a0,0x1c
    80003434:	32050513          	addi	a0,a0,800 # 8001f750 <itable>
    80003438:	861fd0ef          	jal	80000c98 <release>
      return ip;
    8000343c:	8926                	mv	s2,s1
    8000343e:	a0a9                	j	80003488 <iget+0xd0>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003440:	fa45                	bnez	a2,800033f0 <iget+0x38>
      empty = ip;
    80003442:	8926                	mv	s2,s1
    80003444:	b775                	j	800033f0 <iget+0x38>
  }

  // Recycle an inode entry.
  if(empty == 0)
    80003446:	04090a63          	beqz	s2,8000349a <iget+0xe2>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
    8000344a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000344e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003452:	4785                	li	a5,1
    80003454:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003458:	04092023          	sw	zero,64(s2)
  inode_report("IGET_NEW", ip,
    8000345c:	00005897          	auipc	a7,0x5
    80003460:	11c88893          	addi	a7,a7,284 # 80008578 <etext+0x578>
    80003464:	4801                	li	a6,0
    80003466:	4781                	li	a5,0
    80003468:	4701                	li	a4,0
    8000346a:	4681                	li	a3,0
    8000346c:	4601                	li	a2,0
    8000346e:	85ca                	mv	a1,s2
    80003470:	00005517          	auipc	a0,0x5
    80003474:	12850513          	addi	a0,a0,296 # 80008598 <etext+0x598>
    80003478:	e59ff0ef          	jal	800032d0 <inode_report>
    0, 0,
    0, 0,
    0,
    "Allocated new inode in table");
  release(&itable.lock);
    8000347c:	0001c517          	auipc	a0,0x1c
    80003480:	2d450513          	addi	a0,a0,724 # 8001f750 <itable>
    80003484:	815fd0ef          	jal	80000c98 <release>

  return ip;
}
    80003488:	854a                	mv	a0,s2
    8000348a:	70a2                	ld	ra,40(sp)
    8000348c:	7402                	ld	s0,32(sp)
    8000348e:	64e2                	ld	s1,24(sp)
    80003490:	6942                	ld	s2,16(sp)
    80003492:	69a2                	ld	s3,8(sp)
    80003494:	6a02                	ld	s4,0(sp)
    80003496:	6145                	addi	sp,sp,48
    80003498:	8082                	ret
    panic("iget: no inodes");
    8000349a:	00005517          	auipc	a0,0x5
    8000349e:	0ce50513          	addi	a0,a0,206 # 80008568 <etext+0x568>
    800034a2:	b70fd0ef          	jal	80000812 <panic>

00000000800034a6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800034a6:	7179                	addi	sp,sp,-48
    800034a8:	f406                	sd	ra,40(sp)
    800034aa:	f022                	sd	s0,32(sp)
    800034ac:	ec26                	sd	s1,24(sp)
    800034ae:	e84a                	sd	s2,16(sp)
    800034b0:	e44e                	sd	s3,8(sp)
    800034b2:	1800                	addi	s0,sp,48
    800034b4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034b6:	47ad                	li	a5,11
    800034b8:	04b7ea63          	bltu	a5,a1,8000350c <bmap+0x66>
    if((addr = ip->addrs[bn]) == 0){
    800034bc:	02059793          	slli	a5,a1,0x20
    800034c0:	01e7d593          	srli	a1,a5,0x1e
    800034c4:	00b504b3          	add	s1,a0,a1
    800034c8:	0504a983          	lw	s3,80(s1)
    800034cc:	0c099263          	bnez	s3,80003590 <bmap+0xea>
      addr = balloc(ip->dev);
    800034d0:	4108                	lw	a0,0(a0)
    800034d2:	cc5ff0ef          	jal	80003196 <balloc>
    800034d6:	0005099b          	sext.w	s3,a0

inode_report("BMAP_ALLOC_DIRECT", ip,
    800034da:	00005897          	auipc	a7,0x5
    800034de:	0ce88893          	addi	a7,a7,206 # 800085a8 <etext+0x5a8>
    800034e2:	4805                	li	a6,1
    800034e4:	04c92783          	lw	a5,76(s2)
    800034e8:	04491703          	lh	a4,68(s2)
    800034ec:	04092683          	lw	a3,64(s2)
    800034f0:	00892603          	lw	a2,8(s2)
    800034f4:	85ca                	mv	a1,s2
    800034f6:	00005517          	auipc	a0,0x5
    800034fa:	0ca50513          	addi	a0,a0,202 # 800085c0 <etext+0x5c0>
    800034fe:	dd3ff0ef          	jal	800032d0 <inode_report>
    ip->valid,
    ip->type,
    ip->size,
    1,
    "Allocated direct block");
      if(addr == 0)
    80003502:	08098763          	beqz	s3,80003590 <bmap+0xea>
        return 0;
      ip->addrs[bn] = addr;
    80003506:	0534a823          	sw	s3,80(s1)
    8000350a:	a059                	j	80003590 <bmap+0xea>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000350c:	ff45849b          	addiw	s1,a1,-12
    80003510:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003514:	0ff00793          	li	a5,255
    80003518:	0ce7e663          	bltu	a5,a4,800035e4 <bmap+0x13e>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000351c:	08052983          	lw	s3,128(a0)
    80003520:	04099163          	bnez	s3,80003562 <bmap+0xbc>
      addr = balloc(ip->dev);
    80003524:	4108                	lw	a0,0(a0)
    80003526:	c71ff0ef          	jal	80003196 <balloc>
    8000352a:	0005099b          	sext.w	s3,a0
      inode_report("BMAP_ALLOC_INDIRECT", ip,
    8000352e:	00005897          	auipc	a7,0x5
    80003532:	0aa88893          	addi	a7,a7,170 # 800085d8 <etext+0x5d8>
    80003536:	4805                	li	a6,1
    80003538:	04c92783          	lw	a5,76(s2)
    8000353c:	04491703          	lh	a4,68(s2)
    80003540:	04092683          	lw	a3,64(s2)
    80003544:	00892603          	lw	a2,8(s2)
    80003548:	85ca                	mv	a1,s2
    8000354a:	00005517          	auipc	a0,0x5
    8000354e:	0ae50513          	addi	a0,a0,174 # 800085f8 <etext+0x5f8>
    80003552:	d7fff0ef          	jal	800032d0 <inode_report>
    ip->valid,
    ip->type,
    ip->size,
    1,
    "Allocated indirect block table");
      if(addr == 0)
    80003556:	02098d63          	beqz	s3,80003590 <bmap+0xea>
    8000355a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000355c:	09392023          	sw	s3,128(s2)
    80003560:	a011                	j	80003564 <bmap+0xbe>
    80003562:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003564:	85ce                	mv	a1,s3
    80003566:	00092503          	lw	a0,0(s2)
    8000356a:	ec6ff0ef          	jal	80002c30 <bread>
    8000356e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003570:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003574:	02049713          	slli	a4,s1,0x20
    80003578:	01e75593          	srli	a1,a4,0x1e
    8000357c:	00b784b3          	add	s1,a5,a1
    80003580:	0004a983          	lw	s3,0(s1)
    80003584:	00098e63          	beqz	s3,800035a0 <bmap+0xfa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003588:	8552                	mv	a0,s4
    8000358a:	83dff0ef          	jal	80002dc6 <brelse>
    return addr;
    8000358e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003590:	854e                	mv	a0,s3
    80003592:	70a2                	ld	ra,40(sp)
    80003594:	7402                	ld	s0,32(sp)
    80003596:	64e2                	ld	s1,24(sp)
    80003598:	6942                	ld	s2,16(sp)
    8000359a:	69a2                	ld	s3,8(sp)
    8000359c:	6145                	addi	sp,sp,48
    8000359e:	8082                	ret
      inode_report("BMAP_ALLOC_DATA", ip,
    800035a0:	00005897          	auipc	a7,0x5
    800035a4:	07088893          	addi	a7,a7,112 # 80008610 <etext+0x610>
    800035a8:	4805                	li	a6,1
    800035aa:	04c92783          	lw	a5,76(s2)
    800035ae:	04491703          	lh	a4,68(s2)
    800035b2:	04092683          	lw	a3,64(s2)
    800035b6:	00892603          	lw	a2,8(s2)
    800035ba:	85ca                	mv	a1,s2
    800035bc:	00005517          	auipc	a0,0x5
    800035c0:	07450513          	addi	a0,a0,116 # 80008630 <etext+0x630>
    800035c4:	d0dff0ef          	jal	800032d0 <inode_report>
      addr = balloc(ip->dev);
    800035c8:	00092503          	lw	a0,0(s2)
    800035cc:	bcbff0ef          	jal	80003196 <balloc>
    800035d0:	0005099b          	sext.w	s3,a0
      if(addr){
    800035d4:	fa098ae3          	beqz	s3,80003588 <bmap+0xe2>
        a[bn] = addr;
    800035d8:	0134a023          	sw	s3,0(s1)
        log_write(bp);
    800035dc:	8552                	mv	a0,s4
    800035de:	480010ef          	jal	80004a5e <log_write>
    800035e2:	b75d                	j	80003588 <bmap+0xe2>
    800035e4:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800035e6:	00005517          	auipc	a0,0x5
    800035ea:	05a50513          	addi	a0,a0,90 # 80008640 <etext+0x640>
    800035ee:	a24fd0ef          	jal	80000812 <panic>

00000000800035f2 <iinit>:
{
    800035f2:	7179                	addi	sp,sp,-48
    800035f4:	f406                	sd	ra,40(sp)
    800035f6:	f022                	sd	s0,32(sp)
    800035f8:	ec26                	sd	s1,24(sp)
    800035fa:	e84a                	sd	s2,16(sp)
    800035fc:	e44e                	sd	s3,8(sp)
    800035fe:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003600:	00005597          	auipc	a1,0x5
    80003604:	05858593          	addi	a1,a1,88 # 80008658 <etext+0x658>
    80003608:	0001c517          	auipc	a0,0x1c
    8000360c:	14850513          	addi	a0,a0,328 # 8001f750 <itable>
    80003610:	d70fd0ef          	jal	80000b80 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003614:	0001c497          	auipc	s1,0x1c
    80003618:	16448493          	addi	s1,s1,356 # 8001f778 <itable+0x28>
    8000361c:	0001e997          	auipc	s3,0x1e
    80003620:	bec98993          	addi	s3,s3,-1044 # 80021208 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003624:	00005917          	auipc	s2,0x5
    80003628:	0c490913          	addi	s2,s2,196 # 800086e8 <etext+0x6e8>
    8000362c:	85ca                	mv	a1,s2
    8000362e:	8526                	mv	a0,s1
    80003630:	516010ef          	jal	80004b46 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003634:	08848493          	addi	s1,s1,136
    80003638:	ff349ae3          	bne	s1,s3,8000362c <iinit+0x3a>
}
    8000363c:	70a2                	ld	ra,40(sp)
    8000363e:	7402                	ld	s0,32(sp)
    80003640:	64e2                	ld	s1,24(sp)
    80003642:	6942                	ld	s2,16(sp)
    80003644:	69a2                	ld	s3,8(sp)
    80003646:	6145                	addi	sp,sp,48
    80003648:	8082                	ret

000000008000364a <ialloc>:
{
    8000364a:	7139                	addi	sp,sp,-64
    8000364c:	fc06                	sd	ra,56(sp)
    8000364e:	f822                	sd	s0,48(sp)
    80003650:	f04a                	sd	s2,32(sp)
    80003652:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003654:	0001c717          	auipc	a4,0x1c
    80003658:	0e872703          	lw	a4,232(a4) # 8001f73c <sb+0xc>
    8000365c:	4785                	li	a5,1
    8000365e:	04e7fe63          	bgeu	a5,a4,800036ba <ialloc+0x70>
    80003662:	f426                	sd	s1,40(sp)
    80003664:	ec4e                	sd	s3,24(sp)
    80003666:	e852                	sd	s4,16(sp)
    80003668:	e456                	sd	s5,8(sp)
    8000366a:	e05a                	sd	s6,0(sp)
    8000366c:	8aaa                	mv	s5,a0
    8000366e:	8b2e                	mv	s6,a1
    80003670:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003672:	0001ca17          	auipc	s4,0x1c
    80003676:	0bea0a13          	addi	s4,s4,190 # 8001f730 <sb>
    8000367a:	00495593          	srli	a1,s2,0x4
    8000367e:	018a2783          	lw	a5,24(s4)
    80003682:	9dbd                	addw	a1,a1,a5
    80003684:	8556                	mv	a0,s5
    80003686:	daaff0ef          	jal	80002c30 <bread>
    8000368a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000368c:	05850993          	addi	s3,a0,88
    80003690:	00f97793          	andi	a5,s2,15
    80003694:	079a                	slli	a5,a5,0x6
    80003696:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003698:	00099783          	lh	a5,0(s3)
    8000369c:	cf85                	beqz	a5,800036d4 <ialloc+0x8a>
    brelse(bp);
    8000369e:	f28ff0ef          	jal	80002dc6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036a2:	0905                	addi	s2,s2,1
    800036a4:	00ca2703          	lw	a4,12(s4)
    800036a8:	0009079b          	sext.w	a5,s2
    800036ac:	fce7e7e3          	bltu	a5,a4,8000367a <ialloc+0x30>
    800036b0:	74a2                	ld	s1,40(sp)
    800036b2:	69e2                	ld	s3,24(sp)
    800036b4:	6a42                	ld	s4,16(sp)
    800036b6:	6aa2                	ld	s5,8(sp)
    800036b8:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800036ba:	00005517          	auipc	a0,0x5
    800036be:	fc650513          	addi	a0,a0,-58 # 80008680 <etext+0x680>
    800036c2:	e6bfc0ef          	jal	8000052c <printf>
  return 0;
    800036c6:	4901                	li	s2,0
}
    800036c8:	854a                	mv	a0,s2
    800036ca:	70e2                	ld	ra,56(sp)
    800036cc:	7442                	ld	s0,48(sp)
    800036ce:	7902                	ld	s2,32(sp)
    800036d0:	6121                	addi	sp,sp,64
    800036d2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800036d4:	04000613          	li	a2,64
    800036d8:	4581                	li	a1,0
    800036da:	854e                	mv	a0,s3
    800036dc:	df8fd0ef          	jal	80000cd4 <memset>
      dip->type = type;
    800036e0:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800036e4:	8526                	mv	a0,s1
    800036e6:	378010ef          	jal	80004a5e <log_write>
      struct inode *ip = iget(dev, inum);
    800036ea:	0009059b          	sext.w	a1,s2
    800036ee:	8556                	mv	a0,s5
    800036f0:	cc9ff0ef          	jal	800033b8 <iget>
    800036f4:	892a                	mv	s2,a0
      inode_report("IALLOC", ip,
    800036f6:	00005897          	auipc	a7,0x5
    800036fa:	f6a88893          	addi	a7,a7,-150 # 80008660 <etext+0x660>
    800036fe:	4801                	li	a6,0
    80003700:	4781                	li	a5,0
    80003702:	4701                	li	a4,0
    80003704:	4681                	li	a3,0
    80003706:	4601                	li	a2,0
    80003708:	85aa                	mv	a1,a0
    8000370a:	00005517          	auipc	a0,0x5
    8000370e:	f6e50513          	addi	a0,a0,-146 # 80008678 <etext+0x678>
    80003712:	bbfff0ef          	jal	800032d0 <inode_report>
      brelse(bp);
    80003716:	8526                	mv	a0,s1
    80003718:	eaeff0ef          	jal	80002dc6 <brelse>
      return ip;
    8000371c:	74a2                	ld	s1,40(sp)
    8000371e:	69e2                	ld	s3,24(sp)
    80003720:	6a42                	ld	s4,16(sp)
    80003722:	6aa2                	ld	s5,8(sp)
    80003724:	6b02                	ld	s6,0(sp)
    80003726:	b74d                	j	800036c8 <ialloc+0x7e>

0000000080003728 <iupdate>:
{
    80003728:	1101                	addi	sp,sp,-32
    8000372a:	ec06                	sd	ra,24(sp)
    8000372c:	e822                	sd	s0,16(sp)
    8000372e:	e426                	sd	s1,8(sp)
    80003730:	e04a                	sd	s2,0(sp)
    80003732:	1000                	addi	s0,sp,32
    80003734:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003736:	415c                	lw	a5,4(a0)
    80003738:	0047d79b          	srliw	a5,a5,0x4
    8000373c:	0001c597          	auipc	a1,0x1c
    80003740:	00c5a583          	lw	a1,12(a1) # 8001f748 <sb+0x18>
    80003744:	9dbd                	addw	a1,a1,a5
    80003746:	4108                	lw	a0,0(a0)
    80003748:	ce8ff0ef          	jal	80002c30 <bread>
    8000374c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000374e:	05850793          	addi	a5,a0,88
    80003752:	40d8                	lw	a4,4(s1)
    80003754:	8b3d                	andi	a4,a4,15
    80003756:	071a                	slli	a4,a4,0x6
    80003758:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000375a:	04449703          	lh	a4,68(s1)
    8000375e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003762:	04649703          	lh	a4,70(s1)
    80003766:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000376a:	04849703          	lh	a4,72(s1)
    8000376e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003772:	04a49703          	lh	a4,74(s1)
    80003776:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000377a:	44f8                	lw	a4,76(s1)
    8000377c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000377e:	03400613          	li	a2,52
    80003782:	05048593          	addi	a1,s1,80
    80003786:	00c78513          	addi	a0,a5,12
    8000378a:	da6fd0ef          	jal	80000d30 <memmove>
  inode_report("IUPDATE", ip,
    8000378e:	00005897          	auipc	a7,0x5
    80003792:	f0a88893          	addi	a7,a7,-246 # 80008698 <etext+0x698>
    80003796:	4805                	li	a6,1
    80003798:	44fc                	lw	a5,76(s1)
    8000379a:	04449703          	lh	a4,68(s1)
    8000379e:	40b4                	lw	a3,64(s1)
    800037a0:	4490                	lw	a2,8(s1)
    800037a2:	85a6                	mv	a1,s1
    800037a4:	00005517          	auipc	a0,0x5
    800037a8:	f0c50513          	addi	a0,a0,-244 # 800086b0 <etext+0x6b0>
    800037ac:	b25ff0ef          	jal	800032d0 <inode_report>
  log_write(bp);
    800037b0:	854a                	mv	a0,s2
    800037b2:	2ac010ef          	jal	80004a5e <log_write>
  brelse(bp);
    800037b6:	854a                	mv	a0,s2
    800037b8:	e0eff0ef          	jal	80002dc6 <brelse>
}
    800037bc:	60e2                	ld	ra,24(sp)
    800037be:	6442                	ld	s0,16(sp)
    800037c0:	64a2                	ld	s1,8(sp)
    800037c2:	6902                	ld	s2,0(sp)
    800037c4:	6105                	addi	sp,sp,32
    800037c6:	8082                	ret

00000000800037c8 <idup>:
{
    800037c8:	1101                	addi	sp,sp,-32
    800037ca:	ec06                	sd	ra,24(sp)
    800037cc:	e822                	sd	s0,16(sp)
    800037ce:	e426                	sd	s1,8(sp)
    800037d0:	1000                	addi	s0,sp,32
    800037d2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037d4:	0001c517          	auipc	a0,0x1c
    800037d8:	f7c50513          	addi	a0,a0,-132 # 8001f750 <itable>
    800037dc:	c24fd0ef          	jal	80000c00 <acquire>
  int old_ref = ip->ref;
    800037e0:	4490                	lw	a2,8(s1)
  ip->ref++;
    800037e2:	0016079b          	addiw	a5,a2,1
    800037e6:	c49c                	sw	a5,8(s1)
  inode_report("IDUP", ip,
    800037e8:	00005897          	auipc	a7,0x5
    800037ec:	ed088893          	addi	a7,a7,-304 # 800086b8 <etext+0x6b8>
    800037f0:	4801                	li	a6,0
    800037f2:	44fc                	lw	a5,76(s1)
    800037f4:	04449703          	lh	a4,68(s1)
    800037f8:	40b4                	lw	a3,64(s1)
    800037fa:	85a6                	mv	a1,s1
    800037fc:	00005517          	auipc	a0,0x5
    80003800:	ed450513          	addi	a0,a0,-300 # 800086d0 <etext+0x6d0>
    80003804:	acdff0ef          	jal	800032d0 <inode_report>
  release(&itable.lock);
    80003808:	0001c517          	auipc	a0,0x1c
    8000380c:	f4850513          	addi	a0,a0,-184 # 8001f750 <itable>
    80003810:	c88fd0ef          	jal	80000c98 <release>
}
    80003814:	8526                	mv	a0,s1
    80003816:	60e2                	ld	ra,24(sp)
    80003818:	6442                	ld	s0,16(sp)
    8000381a:	64a2                	ld	s1,8(sp)
    8000381c:	6105                	addi	sp,sp,32
    8000381e:	8082                	ret

0000000080003820 <ilock>:
{
    80003820:	1101                	addi	sp,sp,-32
    80003822:	ec06                	sd	ra,24(sp)
    80003824:	e822                	sd	s0,16(sp)
    80003826:	e426                	sd	s1,8(sp)
    80003828:	e04a                	sd	s2,0(sp)
    8000382a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000382c:	c139                	beqz	a0,80003872 <ilock+0x52>
    8000382e:	84aa                	mv	s1,a0
    80003830:	451c                	lw	a5,8(a0)
    80003832:	04f05063          	blez	a5,80003872 <ilock+0x52>
   int old_valid = ip->valid;
    80003836:	04052903          	lw	s2,64(a0)
  acquiresleep(&ip->lock);
    8000383a:	0541                	addi	a0,a0,16
    8000383c:	340010ef          	jal	80004b7c <acquiresleep>
  inode_report("ILOCK_ACQUIRE", ip,
    80003840:	00005897          	auipc	a7,0x5
    80003844:	ea088893          	addi	a7,a7,-352 # 800086e0 <etext+0x6e0>
    80003848:	4801                	li	a6,0
    8000384a:	44fc                	lw	a5,76(s1)
    8000384c:	04449703          	lh	a4,68(s1)
    80003850:	86ca                	mv	a3,s2
    80003852:	4490                	lw	a2,8(s1)
    80003854:	85a6                	mv	a1,s1
    80003856:	00005517          	auipc	a0,0x5
    8000385a:	e9a50513          	addi	a0,a0,-358 # 800086f0 <etext+0x6f0>
    8000385e:	a73ff0ef          	jal	800032d0 <inode_report>
  if(ip->valid == 0){
    80003862:	40bc                	lw	a5,64(s1)
    80003864:	cf89                	beqz	a5,8000387e <ilock+0x5e>
}
    80003866:	60e2                	ld	ra,24(sp)
    80003868:	6442                	ld	s0,16(sp)
    8000386a:	64a2                	ld	s1,8(sp)
    8000386c:	6902                	ld	s2,0(sp)
    8000386e:	6105                	addi	sp,sp,32
    80003870:	8082                	ret
    panic("ilock");
    80003872:	00005517          	auipc	a0,0x5
    80003876:	e6650513          	addi	a0,a0,-410 # 800086d8 <etext+0x6d8>
    8000387a:	f99fc0ef          	jal	80000812 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000387e:	40dc                	lw	a5,4(s1)
    80003880:	0047d79b          	srliw	a5,a5,0x4
    80003884:	0001c597          	auipc	a1,0x1c
    80003888:	ec45a583          	lw	a1,-316(a1) # 8001f748 <sb+0x18>
    8000388c:	9dbd                	addw	a1,a1,a5
    8000388e:	4088                	lw	a0,0(s1)
    80003890:	ba0ff0ef          	jal	80002c30 <bread>
    80003894:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003896:	05850593          	addi	a1,a0,88
    8000389a:	40dc                	lw	a5,4(s1)
    8000389c:	8bbd                	andi	a5,a5,15
    8000389e:	079a                	slli	a5,a5,0x6
    800038a0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038a2:	00059783          	lh	a5,0(a1)
    800038a6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038aa:	00259783          	lh	a5,2(a1)
    800038ae:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038b2:	00459783          	lh	a5,4(a1)
    800038b6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038ba:	00659783          	lh	a5,6(a1)
    800038be:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800038c2:	459c                	lw	a5,8(a1)
    800038c4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800038c6:	03400613          	li	a2,52
    800038ca:	05b1                	addi	a1,a1,12
    800038cc:	05048513          	addi	a0,s1,80
    800038d0:	c60fd0ef          	jal	80000d30 <memmove>
    brelse(bp);
    800038d4:	854a                	mv	a0,s2
    800038d6:	cf0ff0ef          	jal	80002dc6 <brelse>
    ip->valid = 1;
    800038da:	4785                	li	a5,1
    800038dc:	c0bc                	sw	a5,64(s1)
    inode_report("ILOCK_LOAD", ip,
    800038de:	00005897          	auipc	a7,0x5
    800038e2:	e2288893          	addi	a7,a7,-478 # 80008700 <etext+0x700>
    800038e6:	4805                	li	a6,1
    800038e8:	44fc                	lw	a5,76(s1)
    800038ea:	04449703          	lh	a4,68(s1)
    800038ee:	4681                	li	a3,0
    800038f0:	4490                	lw	a2,8(s1)
    800038f2:	85a6                	mv	a1,s1
    800038f4:	00005517          	auipc	a0,0x5
    800038f8:	e2450513          	addi	a0,a0,-476 # 80008718 <etext+0x718>
    800038fc:	9d5ff0ef          	jal	800032d0 <inode_report>
    if(ip->type == 0)
    80003900:	04449783          	lh	a5,68(s1)
    80003904:	f3ad                	bnez	a5,80003866 <ilock+0x46>
      panic("ilock: no type");
    80003906:	00005517          	auipc	a0,0x5
    8000390a:	e2250513          	addi	a0,a0,-478 # 80008728 <etext+0x728>
    8000390e:	f05fc0ef          	jal	80000812 <panic>

0000000080003912 <iunlock>:
{
    80003912:	1101                	addi	sp,sp,-32
    80003914:	ec06                	sd	ra,24(sp)
    80003916:	e822                	sd	s0,16(sp)
    80003918:	e426                	sd	s1,8(sp)
    8000391a:	e04a                	sd	s2,0(sp)
    8000391c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000391e:	c529                	beqz	a0,80003968 <iunlock+0x56>
    80003920:	84aa                	mv	s1,a0
    80003922:	01050913          	addi	s2,a0,16
    80003926:	854a                	mv	a0,s2
    80003928:	2d2010ef          	jal	80004bfa <holdingsleep>
    8000392c:	cd15                	beqz	a0,80003968 <iunlock+0x56>
    8000392e:	449c                	lw	a5,8(s1)
    80003930:	02f05c63          	blez	a5,80003968 <iunlock+0x56>
  releasesleep(&ip->lock);
    80003934:	854a                	mv	a0,s2
    80003936:	28c010ef          	jal	80004bc2 <releasesleep>
  inode_report("IUNLOCK", ip,
    8000393a:	00005897          	auipc	a7,0x5
    8000393e:	e0688893          	addi	a7,a7,-506 # 80008740 <etext+0x740>
    80003942:	4805                	li	a6,1
    80003944:	44fc                	lw	a5,76(s1)
    80003946:	04449703          	lh	a4,68(s1)
    8000394a:	40b4                	lw	a3,64(s1)
    8000394c:	4490                	lw	a2,8(s1)
    8000394e:	85a6                	mv	a1,s1
    80003950:	00005517          	auipc	a0,0x5
    80003954:	e0050513          	addi	a0,a0,-512 # 80008750 <etext+0x750>
    80003958:	979ff0ef          	jal	800032d0 <inode_report>
}
    8000395c:	60e2                	ld	ra,24(sp)
    8000395e:	6442                	ld	s0,16(sp)
    80003960:	64a2                	ld	s1,8(sp)
    80003962:	6902                	ld	s2,0(sp)
    80003964:	6105                	addi	sp,sp,32
    80003966:	8082                	ret
    panic("iunlock");
    80003968:	00005517          	auipc	a0,0x5
    8000396c:	dd050513          	addi	a0,a0,-560 # 80008738 <etext+0x738>
    80003970:	ea3fc0ef          	jal	80000812 <panic>

0000000080003974 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003974:	7179                	addi	sp,sp,-48
    80003976:	f406                	sd	ra,40(sp)
    80003978:	f022                	sd	s0,32(sp)
    8000397a:	ec26                	sd	s1,24(sp)
    8000397c:	e84a                	sd	s2,16(sp)
    8000397e:	e44e                	sd	s3,8(sp)
    80003980:	1800                	addi	s0,sp,48
    80003982:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003984:	05050493          	addi	s1,a0,80
    80003988:	08050913          	addi	s2,a0,128
    8000398c:	a021                	j	80003994 <itrunc+0x20>
    8000398e:	0491                	addi	s1,s1,4
    80003990:	01248b63          	beq	s1,s2,800039a6 <itrunc+0x32>
    if(ip->addrs[i]){
    80003994:	408c                	lw	a1,0(s1)
    80003996:	dde5                	beqz	a1,8000398e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003998:	0009a503          	lw	a0,0(s3)
    8000399c:	f70ff0ef          	jal	8000310c <bfree>
      ip->addrs[i] = 0;
    800039a0:	0004a023          	sw	zero,0(s1)
    800039a4:	b7ed                	j	8000398e <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039a6:	0809a583          	lw	a1,128(s3)
    800039aa:	e1a9                	bnez	a1,800039ec <itrunc+0x78>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  int old_size = ip->size;
    800039ac:	04c9a783          	lw	a5,76(s3)

ip->size = 0;
    800039b0:	0409a623          	sw	zero,76(s3)

inode_report("ITRUNC", ip,
    800039b4:	00005897          	auipc	a7,0x5
    800039b8:	da488893          	addi	a7,a7,-604 # 80008758 <etext+0x758>
    800039bc:	4805                	li	a6,1
    800039be:	04499703          	lh	a4,68(s3)
    800039c2:	0409a683          	lw	a3,64(s3)
    800039c6:	0089a603          	lw	a2,8(s3)
    800039ca:	85ce                	mv	a1,s3
    800039cc:	00005517          	auipc	a0,0x5
    800039d0:	da450513          	addi	a0,a0,-604 # 80008770 <etext+0x770>
    800039d4:	8fdff0ef          	jal	800032d0 <inode_report>
    ip->ref, ip->valid,
    ip->type, old_size,
    1,
    "Truncating inode data");
  iupdate(ip);
    800039d8:	854e                	mv	a0,s3
    800039da:	d4fff0ef          	jal	80003728 <iupdate>
}
    800039de:	70a2                	ld	ra,40(sp)
    800039e0:	7402                	ld	s0,32(sp)
    800039e2:	64e2                	ld	s1,24(sp)
    800039e4:	6942                	ld	s2,16(sp)
    800039e6:	69a2                	ld	s3,8(sp)
    800039e8:	6145                	addi	sp,sp,48
    800039ea:	8082                	ret
    800039ec:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039ee:	0009a503          	lw	a0,0(s3)
    800039f2:	a3eff0ef          	jal	80002c30 <bread>
    800039f6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039f8:	05850493          	addi	s1,a0,88
    800039fc:	45850913          	addi	s2,a0,1112
    80003a00:	a021                	j	80003a08 <itrunc+0x94>
    80003a02:	0491                	addi	s1,s1,4
    80003a04:	01248963          	beq	s1,s2,80003a16 <itrunc+0xa2>
      if(a[j])
    80003a08:	408c                	lw	a1,0(s1)
    80003a0a:	dde5                	beqz	a1,80003a02 <itrunc+0x8e>
        bfree(ip->dev, a[j]);
    80003a0c:	0009a503          	lw	a0,0(s3)
    80003a10:	efcff0ef          	jal	8000310c <bfree>
    80003a14:	b7fd                	j	80003a02 <itrunc+0x8e>
    brelse(bp);
    80003a16:	8552                	mv	a0,s4
    80003a18:	baeff0ef          	jal	80002dc6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a1c:	0809a583          	lw	a1,128(s3)
    80003a20:	0009a503          	lw	a0,0(s3)
    80003a24:	ee8ff0ef          	jal	8000310c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a28:	0809a023          	sw	zero,128(s3)
    80003a2c:	6a02                	ld	s4,0(sp)
    80003a2e:	bfbd                	j	800039ac <itrunc+0x38>

0000000080003a30 <iput>:
{
    80003a30:	1101                	addi	sp,sp,-32
    80003a32:	ec06                	sd	ra,24(sp)
    80003a34:	e822                	sd	s0,16(sp)
    80003a36:	e426                	sd	s1,8(sp)
    80003a38:	1000                	addi	s0,sp,32
    80003a3a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a3c:	0001c517          	auipc	a0,0x1c
    80003a40:	d1450513          	addi	a0,a0,-748 # 8001f750 <itable>
    80003a44:	9bcfd0ef          	jal	80000c00 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a48:	4498                	lw	a4,8(s1)
    80003a4a:	4785                	li	a5,1
    80003a4c:	04f70163          	beq	a4,a5,80003a8e <iput+0x5e>
  int old_ref = ip->ref;
    80003a50:	4490                	lw	a2,8(s1)
ip->ref--;
    80003a52:	fff6079b          	addiw	a5,a2,-1
    80003a56:	c49c                	sw	a5,8(s1)
inode_report("IPUT", ip,
    80003a58:	00005897          	auipc	a7,0x5
    80003a5c:	d4888893          	addi	a7,a7,-696 # 800087a0 <etext+0x7a0>
    80003a60:	4801                	li	a6,0
    80003a62:	44fc                	lw	a5,76(s1)
    80003a64:	04449703          	lh	a4,68(s1)
    80003a68:	40b4                	lw	a3,64(s1)
    80003a6a:	85a6                	mv	a1,s1
    80003a6c:	00005517          	auipc	a0,0x5
    80003a70:	d4450513          	addi	a0,a0,-700 # 800087b0 <etext+0x7b0>
    80003a74:	85dff0ef          	jal	800032d0 <inode_report>
  release(&itable.lock);
    80003a78:	0001c517          	auipc	a0,0x1c
    80003a7c:	cd850513          	addi	a0,a0,-808 # 8001f750 <itable>
    80003a80:	a18fd0ef          	jal	80000c98 <release>
}
    80003a84:	60e2                	ld	ra,24(sp)
    80003a86:	6442                	ld	s0,16(sp)
    80003a88:	64a2                	ld	s1,8(sp)
    80003a8a:	6105                	addi	sp,sp,32
    80003a8c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a8e:	40bc                	lw	a5,64(s1)
    80003a90:	d3e1                	beqz	a5,80003a50 <iput+0x20>
    80003a92:	04a49783          	lh	a5,74(s1)
    80003a96:	ffcd                	bnez	a5,80003a50 <iput+0x20>
    80003a98:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003a9a:	01048913          	addi	s2,s1,16
    80003a9e:	854a                	mv	a0,s2
    80003aa0:	0dc010ef          	jal	80004b7c <acquiresleep>
    release(&itable.lock);
    80003aa4:	0001c517          	auipc	a0,0x1c
    80003aa8:	cac50513          	addi	a0,a0,-852 # 8001f750 <itable>
    80003aac:	9ecfd0ef          	jal	80000c98 <release>
    itrunc(ip);
    80003ab0:	8526                	mv	a0,s1
    80003ab2:	ec3ff0ef          	jal	80003974 <itrunc>
    ip->type = 0;
    80003ab6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003aba:	8526                	mv	a0,s1
    80003abc:	c6dff0ef          	jal	80003728 <iupdate>
    ip->valid = 0;
    80003ac0:	0404a023          	sw	zero,64(s1)
    inode_report("IPUT_FREE", ip,
    80003ac4:	00005897          	auipc	a7,0x5
    80003ac8:	cb488893          	addi	a7,a7,-844 # 80008778 <etext+0x778>
    80003acc:	4805                	li	a6,1
    80003ace:	44fc                	lw	a5,76(s1)
    80003ad0:	04449703          	lh	a4,68(s1)
    80003ad4:	4681                	li	a3,0
    80003ad6:	4490                	lw	a2,8(s1)
    80003ad8:	85a6                	mv	a1,s1
    80003ada:	00005517          	auipc	a0,0x5
    80003ade:	cb650513          	addi	a0,a0,-842 # 80008790 <etext+0x790>
    80003ae2:	feeff0ef          	jal	800032d0 <inode_report>
    releasesleep(&ip->lock);
    80003ae6:	854a                	mv	a0,s2
    80003ae8:	0da010ef          	jal	80004bc2 <releasesleep>
    acquire(&itable.lock);
    80003aec:	0001c517          	auipc	a0,0x1c
    80003af0:	c6450513          	addi	a0,a0,-924 # 8001f750 <itable>
    80003af4:	90cfd0ef          	jal	80000c00 <acquire>
    80003af8:	6902                	ld	s2,0(sp)
    80003afa:	bf99                	j	80003a50 <iput+0x20>

0000000080003afc <iunlockput>:
{
    80003afc:	1101                	addi	sp,sp,-32
    80003afe:	ec06                	sd	ra,24(sp)
    80003b00:	e822                	sd	s0,16(sp)
    80003b02:	e426                	sd	s1,8(sp)
    80003b04:	1000                	addi	s0,sp,32
    80003b06:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b08:	e0bff0ef          	jal	80003912 <iunlock>
  iput(ip);
    80003b0c:	8526                	mv	a0,s1
    80003b0e:	f23ff0ef          	jal	80003a30 <iput>
}
    80003b12:	60e2                	ld	ra,24(sp)
    80003b14:	6442                	ld	s0,16(sp)
    80003b16:	64a2                	ld	s1,8(sp)
    80003b18:	6105                	addi	sp,sp,32
    80003b1a:	8082                	ret

0000000080003b1c <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003b1c:	0001c717          	auipc	a4,0x1c
    80003b20:	c2072703          	lw	a4,-992(a4) # 8001f73c <sb+0xc>
    80003b24:	4785                	li	a5,1
    80003b26:	0ae7ff63          	bgeu	a5,a4,80003be4 <ireclaim+0xc8>
{
    80003b2a:	7139                	addi	sp,sp,-64
    80003b2c:	fc06                	sd	ra,56(sp)
    80003b2e:	f822                	sd	s0,48(sp)
    80003b30:	f426                	sd	s1,40(sp)
    80003b32:	f04a                	sd	s2,32(sp)
    80003b34:	ec4e                	sd	s3,24(sp)
    80003b36:	e852                	sd	s4,16(sp)
    80003b38:	e456                	sd	s5,8(sp)
    80003b3a:	e05a                	sd	s6,0(sp)
    80003b3c:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003b3e:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003b40:	00050a1b          	sext.w	s4,a0
    80003b44:	0001ca97          	auipc	s5,0x1c
    80003b48:	beca8a93          	addi	s5,s5,-1044 # 8001f730 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003b4c:	00005b17          	auipc	s6,0x5
    80003b50:	c6cb0b13          	addi	s6,s6,-916 # 800087b8 <etext+0x7b8>
    80003b54:	a099                	j	80003b9a <ireclaim+0x7e>
    80003b56:	85ce                	mv	a1,s3
    80003b58:	855a                	mv	a0,s6
    80003b5a:	9d3fc0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    80003b5e:	85ce                	mv	a1,s3
    80003b60:	8552                	mv	a0,s4
    80003b62:	857ff0ef          	jal	800033b8 <iget>
    80003b66:	89aa                	mv	s3,a0
    brelse(bp);
    80003b68:	854a                	mv	a0,s2
    80003b6a:	a5cff0ef          	jal	80002dc6 <brelse>
    if (ip) {
    80003b6e:	00098f63          	beqz	s3,80003b8c <ireclaim+0x70>
      begin_op();
    80003b72:	379000ef          	jal	800046ea <begin_op>
      ilock(ip);
    80003b76:	854e                	mv	a0,s3
    80003b78:	ca9ff0ef          	jal	80003820 <ilock>
      iunlock(ip);
    80003b7c:	854e                	mv	a0,s3
    80003b7e:	d95ff0ef          	jal	80003912 <iunlock>
      iput(ip);
    80003b82:	854e                	mv	a0,s3
    80003b84:	eadff0ef          	jal	80003a30 <iput>
      end_op();
    80003b88:	481000ef          	jal	80004808 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003b8c:	0485                	addi	s1,s1,1
    80003b8e:	00caa703          	lw	a4,12(s5)
    80003b92:	0004879b          	sext.w	a5,s1
    80003b96:	02e7fd63          	bgeu	a5,a4,80003bd0 <ireclaim+0xb4>
    80003b9a:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003b9e:	0044d593          	srli	a1,s1,0x4
    80003ba2:	018aa783          	lw	a5,24(s5)
    80003ba6:	9dbd                	addw	a1,a1,a5
    80003ba8:	8552                	mv	a0,s4
    80003baa:	886ff0ef          	jal	80002c30 <bread>
    80003bae:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003bb0:	05850793          	addi	a5,a0,88
    80003bb4:	00f9f713          	andi	a4,s3,15
    80003bb8:	071a                	slli	a4,a4,0x6
    80003bba:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003bbc:	00079703          	lh	a4,0(a5)
    80003bc0:	c701                	beqz	a4,80003bc8 <ireclaim+0xac>
    80003bc2:	00679783          	lh	a5,6(a5)
    80003bc6:	dbc1                	beqz	a5,80003b56 <ireclaim+0x3a>
    brelse(bp);
    80003bc8:	854a                	mv	a0,s2
    80003bca:	9fcff0ef          	jal	80002dc6 <brelse>
    if (ip) {
    80003bce:	bf7d                	j	80003b8c <ireclaim+0x70>
}
    80003bd0:	70e2                	ld	ra,56(sp)
    80003bd2:	7442                	ld	s0,48(sp)
    80003bd4:	74a2                	ld	s1,40(sp)
    80003bd6:	7902                	ld	s2,32(sp)
    80003bd8:	69e2                	ld	s3,24(sp)
    80003bda:	6a42                	ld	s4,16(sp)
    80003bdc:	6aa2                	ld	s5,8(sp)
    80003bde:	6b02                	ld	s6,0(sp)
    80003be0:	6121                	addi	sp,sp,64
    80003be2:	8082                	ret
    80003be4:	8082                	ret

0000000080003be6 <fsinit>:
fsinit(int dev) {
    80003be6:	7179                	addi	sp,sp,-48
    80003be8:	f406                	sd	ra,40(sp)
    80003bea:	f022                	sd	s0,32(sp)
    80003bec:	ec26                	sd	s1,24(sp)
    80003bee:	e84a                	sd	s2,16(sp)
    80003bf0:	e44e                	sd	s3,8(sp)
    80003bf2:	1800                	addi	s0,sp,48
    80003bf4:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003bf6:	4585                	li	a1,1
    80003bf8:	838ff0ef          	jal	80002c30 <bread>
    80003bfc:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003bfe:	0001c997          	auipc	s3,0x1c
    80003c02:	b3298993          	addi	s3,s3,-1230 # 8001f730 <sb>
    80003c06:	02000613          	li	a2,32
    80003c0a:	05850593          	addi	a1,a0,88
    80003c0e:	854e                	mv	a0,s3
    80003c10:	920fd0ef          	jal	80000d30 <memmove>
  brelse(bp);
    80003c14:	854a                	mv	a0,s2
    80003c16:	9b0ff0ef          	jal	80002dc6 <brelse>
  if(sb.magic != FSMAGIC)
    80003c1a:	0009a703          	lw	a4,0(s3)
    80003c1e:	102037b7          	lui	a5,0x10203
    80003c22:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c26:	02f71363          	bne	a4,a5,80003c4c <fsinit+0x66>
  initlog(dev, &sb);
    80003c2a:	0001c597          	auipc	a1,0x1c
    80003c2e:	b0658593          	addi	a1,a1,-1274 # 8001f730 <sb>
    80003c32:	8526                	mv	a0,s1
    80003c34:	161000ef          	jal	80004594 <initlog>
  ireclaim(dev);
    80003c38:	8526                	mv	a0,s1
    80003c3a:	ee3ff0ef          	jal	80003b1c <ireclaim>
}
    80003c3e:	70a2                	ld	ra,40(sp)
    80003c40:	7402                	ld	s0,32(sp)
    80003c42:	64e2                	ld	s1,24(sp)
    80003c44:	6942                	ld	s2,16(sp)
    80003c46:	69a2                	ld	s3,8(sp)
    80003c48:	6145                	addi	sp,sp,48
    80003c4a:	8082                	ret
    panic("invalid file system");
    80003c4c:	00005517          	auipc	a0,0x5
    80003c50:	b8c50513          	addi	a0,a0,-1140 # 800087d8 <etext+0x7d8>
    80003c54:	bbffc0ef          	jal	80000812 <panic>

0000000080003c58 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c58:	1141                	addi	sp,sp,-16
    80003c5a:	e422                	sd	s0,8(sp)
    80003c5c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c5e:	411c                	lw	a5,0(a0)
    80003c60:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c62:	415c                	lw	a5,4(a0)
    80003c64:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c66:	04451783          	lh	a5,68(a0)
    80003c6a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c6e:	04a51783          	lh	a5,74(a0)
    80003c72:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c76:	04c56783          	lwu	a5,76(a0)
    80003c7a:	e99c                	sd	a5,16(a1)
}
    80003c7c:	6422                	ld	s0,8(sp)
    80003c7e:	0141                	addi	sp,sp,16
    80003c80:	8082                	ret

0000000080003c82 <readi>:
// Caller must hold ip->lock.
// If user_dst==1, then dst is a user virtual address;
// otherwise, dst is a kernel address.
int
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
    80003c82:	7119                	addi	sp,sp,-128
    80003c84:	fc86                	sd	ra,120(sp)
    80003c86:	f8a2                	sd	s0,112(sp)
    80003c88:	0100                	addi	s0,sp,128
    80003c8a:	f8b43423          	sd	a1,-120(s0)
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c8e:	457c                	lw	a5,76(a0)
    80003c90:	10d7ea63          	bltu	a5,a3,80003da4 <readi+0x122>
    80003c94:	f4a6                	sd	s1,104(sp)
    80003c96:	f0ca                	sd	s2,96(sp)
    80003c98:	e0da                	sd	s6,64(sp)
    80003c9a:	fc5e                	sd	s7,56(sp)
    80003c9c:	84aa                	mv	s1,a0
    80003c9e:	8b32                	mv	s6,a2
    80003ca0:	8936                	mv	s2,a3
    80003ca2:	8bba                	mv	s7,a4
    80003ca4:	9f35                	addw	a4,a4,a3
    return 0;
    80003ca6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ca8:	10d76063          	bltu	a4,a3,80003da8 <readi+0x126>
    80003cac:	e8d2                	sd	s4,80(sp)
  if(off + n > ip->size)
    80003cae:	00e7f463          	bgeu	a5,a4,80003cb6 <readi+0x34>
    n = ip->size - off;
    80003cb2:	40d78bbb          	subw	s7,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cb6:	0c0b8463          	beqz	s7,80003d7e <readi+0xfc>
    80003cba:	ecce                	sd	s3,88(sp)
    80003cbc:	e4d6                	sd	s5,72(sp)
    80003cbe:	f862                	sd	s8,48(sp)
    80003cc0:	f466                	sd	s9,40(sp)
    80003cc2:	f06a                	sd	s10,32(sp)
    80003cc4:	ec6e                	sd	s11,24(sp)
    80003cc6:	4a01                	li	s4,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cc8:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ccc:	5cfd                	li	s9,-1
      brelse(bp);
      tot = -1;
      break;
    }
    inode_report("READI", ip,
    80003cce:	00005d97          	auipc	s11,0x5
    80003cd2:	b22d8d93          	addi	s11,s11,-1246 # 800087f0 <etext+0x7f0>
    80003cd6:	a881                	j	80003d26 <readi+0xa4>
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003cd8:	020a9c13          	slli	s8,s5,0x20
    80003cdc:	020c5c13          	srli	s8,s8,0x20
    80003ce0:	05898613          	addi	a2,s3,88
    80003ce4:	86e2                	mv	a3,s8
    80003ce6:	963a                	add	a2,a2,a4
    80003ce8:	85da                	mv	a1,s6
    80003cea:	f8843503          	ld	a0,-120(s0)
    80003cee:	d86fe0ef          	jal	80002274 <either_copyout>
    80003cf2:	07950463          	beq	a0,s9,80003d5a <readi+0xd8>
    inode_report("READI", ip,
    80003cf6:	88ee                	mv	a7,s11
    80003cf8:	4805                	li	a6,1
    80003cfa:	44fc                	lw	a5,76(s1)
    80003cfc:	04449703          	lh	a4,68(s1)
    80003d00:	40b4                	lw	a3,64(s1)
    80003d02:	4490                	lw	a2,8(s1)
    80003d04:	85a6                	mv	a1,s1
    80003d06:	00005517          	auipc	a0,0x5
    80003d0a:	b0250513          	addi	a0,a0,-1278 # 80008808 <etext+0x808>
    80003d0e:	dc2ff0ef          	jal	800032d0 <inode_report>
    ip->ref, ip->valid,
    ip->type, ip->size,
    1,
    "Reading from inode");
    brelse(bp);
    80003d12:	854e                	mv	a0,s3
    80003d14:	8b2ff0ef          	jal	80002dc6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d18:	014a8a3b          	addw	s4,s5,s4
    80003d1c:	012a893b          	addw	s2,s5,s2
    80003d20:	9b62                	add	s6,s6,s8
    80003d22:	057a7763          	bgeu	s4,s7,80003d70 <readi+0xee>
    uint addr = bmap(ip, off/BSIZE);
    80003d26:	00a9559b          	srliw	a1,s2,0xa
    80003d2a:	8526                	mv	a0,s1
    80003d2c:	f7aff0ef          	jal	800034a6 <bmap>
    80003d30:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d34:	c5b9                	beqz	a1,80003d82 <readi+0x100>
    bp = bread(ip->dev, addr);
    80003d36:	4088                	lw	a0,0(s1)
    80003d38:	ef9fe0ef          	jal	80002c30 <bread>
    80003d3c:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d3e:	3ff97713          	andi	a4,s2,1023
    80003d42:	40ed07bb          	subw	a5,s10,a4
    80003d46:	414b86bb          	subw	a3,s7,s4
    80003d4a:	8abe                	mv	s5,a5
    80003d4c:	2781                	sext.w	a5,a5
    80003d4e:	0006861b          	sext.w	a2,a3
    80003d52:	f8f673e3          	bgeu	a2,a5,80003cd8 <readi+0x56>
    80003d56:	8ab6                	mv	s5,a3
    80003d58:	b741                	j	80003cd8 <readi+0x56>
      brelse(bp);
    80003d5a:	854e                	mv	a0,s3
    80003d5c:	86aff0ef          	jal	80002dc6 <brelse>
      tot = -1;
    80003d60:	5a7d                	li	s4,-1
      break;
    80003d62:	69e6                	ld	s3,88(sp)
    80003d64:	6aa6                	ld	s5,72(sp)
    80003d66:	7c42                	ld	s8,48(sp)
    80003d68:	7ca2                	ld	s9,40(sp)
    80003d6a:	7d02                	ld	s10,32(sp)
    80003d6c:	6de2                	ld	s11,24(sp)
    80003d6e:	a005                	j	80003d8e <readi+0x10c>
    80003d70:	69e6                	ld	s3,88(sp)
    80003d72:	6aa6                	ld	s5,72(sp)
    80003d74:	7c42                	ld	s8,48(sp)
    80003d76:	7ca2                	ld	s9,40(sp)
    80003d78:	7d02                	ld	s10,32(sp)
    80003d7a:	6de2                	ld	s11,24(sp)
    80003d7c:	a809                	j	80003d8e <readi+0x10c>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d7e:	8a5e                	mv	s4,s7
    80003d80:	a039                	j	80003d8e <readi+0x10c>
    80003d82:	69e6                	ld	s3,88(sp)
    80003d84:	6aa6                	ld	s5,72(sp)
    80003d86:	7c42                	ld	s8,48(sp)
    80003d88:	7ca2                	ld	s9,40(sp)
    80003d8a:	7d02                	ld	s10,32(sp)
    80003d8c:	6de2                	ld	s11,24(sp)
  }
  return tot;
    80003d8e:	000a051b          	sext.w	a0,s4
    80003d92:	74a6                	ld	s1,104(sp)
    80003d94:	7906                	ld	s2,96(sp)
    80003d96:	6a46                	ld	s4,80(sp)
    80003d98:	6b06                	ld	s6,64(sp)
    80003d9a:	7be2                	ld	s7,56(sp)
}
    80003d9c:	70e6                	ld	ra,120(sp)
    80003d9e:	7446                	ld	s0,112(sp)
    80003da0:	6109                	addi	sp,sp,128
    80003da2:	8082                	ret
    return 0;
    80003da4:	4501                	li	a0,0
    80003da6:	bfdd                	j	80003d9c <readi+0x11a>
    80003da8:	74a6                	ld	s1,104(sp)
    80003daa:	7906                	ld	s2,96(sp)
    80003dac:	6b06                	ld	s6,64(sp)
    80003dae:	7be2                	ld	s7,56(sp)
    80003db0:	b7f5                	j	80003d9c <readi+0x11a>

0000000080003db2 <writei>:
// Returns the number of bytes successfully written.
// If the return value is less than the requested n,
// there was an error of some kind.
int
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
    80003db2:	7119                	addi	sp,sp,-128
    80003db4:	fc86                	sd	ra,120(sp)
    80003db6:	f8a2                	sd	s0,112(sp)
    80003db8:	f862                	sd	s8,48(sp)
    80003dba:	0100                	addi	s0,sp,128
    80003dbc:	8c3a                	mv	s8,a4
  uint tot, m;
  struct buf *bp;
  int old_size = ip->size;
    80003dbe:	457c                	lw	a5,76(a0)
    80003dc0:	0007871b          	sext.w	a4,a5
    80003dc4:	f8e43423          	sd	a4,-120(s0)
  if(off > ip->size || off + n < off)
    80003dc8:	10d7ee63          	bltu	a5,a3,80003ee4 <writei+0x132>
    80003dcc:	f0ca                	sd	s2,96(sp)
    80003dce:	e4d6                	sd	s5,72(sp)
    80003dd0:	e0da                	sd	s6,64(sp)
    80003dd2:	f466                	sd	s9,40(sp)
    80003dd4:	8b2a                	mv	s6,a0
    80003dd6:	8cae                	mv	s9,a1
    80003dd8:	8ab2                	mv	s5,a2
    80003dda:	8936                	mv	s2,a3
    80003ddc:	018687bb          	addw	a5,a3,s8
    80003de0:	10d7e463          	bltu	a5,a3,80003ee8 <writei+0x136>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003de4:	00043737          	lui	a4,0x43
    80003de8:	10f76663          	bltu	a4,a5,80003ef4 <writei+0x142>
    80003dec:	e8d2                	sd	s4,80(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dee:	0e0c0363          	beqz	s8,80003ed4 <writei+0x122>
    80003df2:	f4a6                	sd	s1,104(sp)
    80003df4:	ecce                	sd	s3,88(sp)
    80003df6:	fc5e                	sd	s7,56(sp)
    80003df8:	f06a                	sd	s10,32(sp)
    80003dfa:	ec6e                	sd	s11,24(sp)
    80003dfc:	4a01                	li	s4,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dfe:	40000d93          	li	s11,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003e02:	5d7d                	li	s10,-1
    80003e04:	a825                	j	80003e3c <writei+0x8a>
    80003e06:	02099b93          	slli	s7,s3,0x20
    80003e0a:	020bdb93          	srli	s7,s7,0x20
    80003e0e:	05848513          	addi	a0,s1,88
    80003e12:	86de                	mv	a3,s7
    80003e14:	8656                	mv	a2,s5
    80003e16:	85e6                	mv	a1,s9
    80003e18:	953a                	add	a0,a0,a4
    80003e1a:	ca4fe0ef          	jal	800022be <either_copyin>
    80003e1e:	05a50a63          	beq	a0,s10,80003e72 <writei+0xc0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e22:	8526                	mv	a0,s1
    80003e24:	43b000ef          	jal	80004a5e <log_write>
    brelse(bp);
    80003e28:	8526                	mv	a0,s1
    80003e2a:	f9dfe0ef          	jal	80002dc6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e2e:	01498a3b          	addw	s4,s3,s4
    80003e32:	0129893b          	addw	s2,s3,s2
    80003e36:	9ade                	add	s5,s5,s7
    80003e38:	058a7063          	bgeu	s4,s8,80003e78 <writei+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003e3c:	00a9559b          	srliw	a1,s2,0xa
    80003e40:	855a                	mv	a0,s6
    80003e42:	e64ff0ef          	jal	800034a6 <bmap>
    80003e46:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e4a:	c59d                	beqz	a1,80003e78 <writei+0xc6>
    bp = bread(ip->dev, addr);
    80003e4c:	000b2503          	lw	a0,0(s6)
    80003e50:	de1fe0ef          	jal	80002c30 <bread>
    80003e54:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e56:	3ff97713          	andi	a4,s2,1023
    80003e5a:	40ed87bb          	subw	a5,s11,a4
    80003e5e:	414c06bb          	subw	a3,s8,s4
    80003e62:	89be                	mv	s3,a5
    80003e64:	2781                	sext.w	a5,a5
    80003e66:	0006861b          	sext.w	a2,a3
    80003e6a:	f8f67ee3          	bgeu	a2,a5,80003e06 <writei+0x54>
    80003e6e:	89b6                	mv	s3,a3
    80003e70:	bf59                	j	80003e06 <writei+0x54>
      brelse(bp);
    80003e72:	8526                	mv	a0,s1
    80003e74:	f53fe0ef          	jal	80002dc6 <brelse>
  }

  if(off > ip->size)
    80003e78:	04cb2783          	lw	a5,76(s6)
    80003e7c:	0527fe63          	bgeu	a5,s2,80003ed8 <writei+0x126>
    ip->size = off;
    80003e80:	052b2623          	sw	s2,76(s6)
    80003e84:	74a6                	ld	s1,104(sp)
    80003e86:	69e6                	ld	s3,88(sp)
    80003e88:	7be2                	ld	s7,56(sp)
    80003e8a:	7d02                	ld	s10,32(sp)
    80003e8c:	6de2                	ld	s11,24(sp)
  inode_report("WRITEI", ip,
    80003e8e:	00005897          	auipc	a7,0x5
    80003e92:	98288893          	addi	a7,a7,-1662 # 80008810 <etext+0x810>
    80003e96:	4805                	li	a6,1
    80003e98:	f8843783          	ld	a5,-120(s0)
    80003e9c:	044b1703          	lh	a4,68(s6)
    80003ea0:	040b2683          	lw	a3,64(s6)
    80003ea4:	008b2603          	lw	a2,8(s6)
    80003ea8:	85da                	mv	a1,s6
    80003eaa:	00005517          	auipc	a0,0x5
    80003eae:	97e50513          	addi	a0,a0,-1666 # 80008828 <etext+0x828>
    80003eb2:	c1eff0ef          	jal	800032d0 <inode_report>
    "Writing to inode");

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003eb6:	855a                	mv	a0,s6
    80003eb8:	871ff0ef          	jal	80003728 <iupdate>

  return tot;
    80003ebc:	000a051b          	sext.w	a0,s4
    80003ec0:	7906                	ld	s2,96(sp)
    80003ec2:	6a46                	ld	s4,80(sp)
    80003ec4:	6aa6                	ld	s5,72(sp)
    80003ec6:	6b06                	ld	s6,64(sp)
    80003ec8:	7ca2                	ld	s9,40(sp)
}
    80003eca:	70e6                	ld	ra,120(sp)
    80003ecc:	7446                	ld	s0,112(sp)
    80003ece:	7c42                	ld	s8,48(sp)
    80003ed0:	6109                	addi	sp,sp,128
    80003ed2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ed4:	8a62                	mv	s4,s8
    80003ed6:	bf65                	j	80003e8e <writei+0xdc>
    80003ed8:	74a6                	ld	s1,104(sp)
    80003eda:	69e6                	ld	s3,88(sp)
    80003edc:	7be2                	ld	s7,56(sp)
    80003ede:	7d02                	ld	s10,32(sp)
    80003ee0:	6de2                	ld	s11,24(sp)
    80003ee2:	b775                	j	80003e8e <writei+0xdc>
    return -1;
    80003ee4:	557d                	li	a0,-1
    80003ee6:	b7d5                	j	80003eca <writei+0x118>
    80003ee8:	557d                	li	a0,-1
    80003eea:	7906                	ld	s2,96(sp)
    80003eec:	6aa6                	ld	s5,72(sp)
    80003eee:	6b06                	ld	s6,64(sp)
    80003ef0:	7ca2                	ld	s9,40(sp)
    80003ef2:	bfe1                	j	80003eca <writei+0x118>
    return -1;
    80003ef4:	557d                	li	a0,-1
    80003ef6:	7906                	ld	s2,96(sp)
    80003ef8:	6aa6                	ld	s5,72(sp)
    80003efa:	6b06                	ld	s6,64(sp)
    80003efc:	7ca2                	ld	s9,40(sp)
    80003efe:	b7f1                	j	80003eca <writei+0x118>

0000000080003f00 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f00:	1141                	addi	sp,sp,-16
    80003f02:	e406                	sd	ra,8(sp)
    80003f04:	e022                	sd	s0,0(sp)
    80003f06:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f08:	4639                	li	a2,14
    80003f0a:	e97fc0ef          	jal	80000da0 <strncmp>
}
    80003f0e:	60a2                	ld	ra,8(sp)
    80003f10:	6402                	ld	s0,0(sp)
    80003f12:	0141                	addi	sp,sp,16
    80003f14:	8082                	ret

0000000080003f16 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f16:	7139                	addi	sp,sp,-64
    80003f18:	fc06                	sd	ra,56(sp)
    80003f1a:	f822                	sd	s0,48(sp)
    80003f1c:	f426                	sd	s1,40(sp)
    80003f1e:	f04a                	sd	s2,32(sp)
    80003f20:	ec4e                	sd	s3,24(sp)
    80003f22:	e852                	sd	s4,16(sp)
    80003f24:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003f26:	04451703          	lh	a4,68(a0)
    80003f2a:	4785                	li	a5,1
    80003f2c:	02f71f63          	bne	a4,a5,80003f6a <dirlookup+0x54>
    80003f30:	892a                	mv	s2,a0
    80003f32:	89ae                	mv	s3,a1
    80003f34:	8a32                	mv	s4,a2
    name,
    -1,
    -1,
    "Starting directory lookup"
);}
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f36:	457c                	lw	a5,76(a0)
    80003f38:	4481                	li	s1,0
    80003f3a:	eba9                	bnez	a5,80003f8c <dirlookup+0x76>
    "Directory entry found"
);
      return iget(dp->dev, inum);
    }
  }
  dir_report(
    80003f3c:	00005797          	auipc	a5,0x5
    80003f40:	94478793          	addi	a5,a5,-1724 # 80008880 <etext+0x880>
    80003f44:	577d                	li	a4,-1
    80003f46:	56fd                	li	a3,-1
    80003f48:	864e                	mv	a2,s3
    80003f4a:	85ca                	mv	a1,s2
    80003f4c:	00005517          	auipc	a0,0x5
    80003f50:	95450513          	addi	a0,a0,-1708 # 800088a0 <etext+0x8a0>
    80003f54:	faffe0ef          	jal	80002f02 <dir_report>
    name,
    -1,
    -1,
    "Directory entry not found"
);
  return 0;
    80003f58:	4501                	li	a0,0
}
    80003f5a:	70e2                	ld	ra,56(sp)
    80003f5c:	7442                	ld	s0,48(sp)
    80003f5e:	74a2                	ld	s1,40(sp)
    80003f60:	7902                	ld	s2,32(sp)
    80003f62:	69e2                	ld	s3,24(sp)
    80003f64:	6a42                	ld	s4,16(sp)
    80003f66:	6121                	addi	sp,sp,64
    80003f68:	8082                	ret
   { panic("dirlookup not DIR");
    80003f6a:	00005517          	auipc	a0,0x5
    80003f6e:	8c650513          	addi	a0,a0,-1850 # 80008830 <etext+0x830>
    80003f72:	8a1fc0ef          	jal	80000812 <panic>
      panic("dirlookup read");
    80003f76:	00005517          	auipc	a0,0x5
    80003f7a:	8d250513          	addi	a0,a0,-1838 # 80008848 <etext+0x848>
    80003f7e:	895fc0ef          	jal	80000812 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f82:	24c1                	addiw	s1,s1,16
    80003f84:	04c92783          	lw	a5,76(s2)
    80003f88:	faf4fae3          	bgeu	s1,a5,80003f3c <dirlookup+0x26>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f8c:	4741                	li	a4,16
    80003f8e:	86a6                	mv	a3,s1
    80003f90:	fc040613          	addi	a2,s0,-64
    80003f94:	4581                	li	a1,0
    80003f96:	854a                	mv	a0,s2
    80003f98:	cebff0ef          	jal	80003c82 <readi>
    80003f9c:	47c1                	li	a5,16
    80003f9e:	fcf51ce3          	bne	a0,a5,80003f76 <dirlookup+0x60>
    if(de.inum == 0)
    80003fa2:	fc045783          	lhu	a5,-64(s0)
    80003fa6:	dff1                	beqz	a5,80003f82 <dirlookup+0x6c>
    if(namecmp(name, de.name) == 0){
    80003fa8:	fc240593          	addi	a1,s0,-62
    80003fac:	854e                	mv	a0,s3
    80003fae:	f53ff0ef          	jal	80003f00 <namecmp>
    80003fb2:	f961                	bnez	a0,80003f82 <dirlookup+0x6c>
      if(poff)
    80003fb4:	000a0463          	beqz	s4,80003fbc <dirlookup+0xa6>
        *poff = off;
    80003fb8:	009a2023          	sw	s1,0(s4)
      inum = de.inum;
    80003fbc:	fc045a03          	lhu	s4,-64(s0)
      dir_report(
    80003fc0:	00005797          	auipc	a5,0x5
    80003fc4:	89878793          	addi	a5,a5,-1896 # 80008858 <etext+0x858>
    80003fc8:	8726                	mv	a4,s1
    80003fca:	86d2                	mv	a3,s4
    80003fcc:	864e                	mv	a2,s3
    80003fce:	85ca                	mv	a1,s2
    80003fd0:	00005517          	auipc	a0,0x5
    80003fd4:	8a050513          	addi	a0,a0,-1888 # 80008870 <etext+0x870>
    80003fd8:	f2bfe0ef          	jal	80002f02 <dir_report>
      return iget(dp->dev, inum);
    80003fdc:	85d2                	mv	a1,s4
    80003fde:	00092503          	lw	a0,0(s2)
    80003fe2:	bd6ff0ef          	jal	800033b8 <iget>
    80003fe6:	bf95                	j	80003f5a <dirlookup+0x44>

0000000080003fe8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003fe8:	7159                	addi	sp,sp,-112
    80003fea:	f486                	sd	ra,104(sp)
    80003fec:	f0a2                	sd	s0,96(sp)
    80003fee:	eca6                	sd	s1,88(sp)
    80003ff0:	e8ca                	sd	s2,80(sp)
    80003ff2:	e4ce                	sd	s3,72(sp)
    80003ff4:	e0d2                	sd	s4,64(sp)
    80003ff6:	fc56                	sd	s5,56(sp)
    80003ff8:	f85a                	sd	s6,48(sp)
    80003ffa:	f45e                	sd	s7,40(sp)
    80003ffc:	f062                	sd	s8,32(sp)
    80003ffe:	ec66                	sd	s9,24(sp)
    80004000:	e86a                	sd	s10,16(sp)
    80004002:	e46e                	sd	s11,8(sp)
    80004004:	1880                	addi	s0,sp,112
    80004006:	84aa                	mv	s1,a0
    80004008:	8bae                	mv	s7,a1
    8000400a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000400c:	00054703          	lbu	a4,0(a0)
    80004010:	02f00793          	li	a5,47
    80004014:	04f70663          	beq	a4,a5,80004060 <namex+0x78>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004018:	8f1fd0ef          	jal	80001908 <myproc>
    8000401c:	15053503          	ld	a0,336(a0)
    80004020:	fa8ff0ef          	jal	800037c8 <idup>
    80004024:	8a2a                	mv	s4,a0
  path_report(
    80004026:	00005717          	auipc	a4,0x5
    8000402a:	88a70713          	addi	a4,a4,-1910 # 800088b0 <etext+0x8b0>
    8000402e:	86d2                	mv	a3,s4
    80004030:	00005617          	auipc	a2,0x5
    80004034:	be060613          	addi	a2,a2,-1056 # 80008c10 <etext+0xc10>
    80004038:	85a6                	mv	a1,s1
    8000403a:	00005517          	auipc	a0,0x5
    8000403e:	89650513          	addi	a0,a0,-1898 # 800088d0 <etext+0x8d0>
    80004042:	f77fe0ef          	jal	80002fb8 <path_report>
  while(*path == '/')
    80004046:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000404a:	4db5                	li	s11,13
    "",
    ip,
    "Starting pathname resolution"
);
  while((path = skipelem(path, name)) != 0){
    path_report(
    8000404c:	00005d17          	auipc	s10,0x5
    80004050:	894d0d13          	addi	s10,s10,-1900 # 800088e0 <etext+0x8e0>
    80004054:	00005c97          	auipc	s9,0x5
    80004058:	8a4c8c93          	addi	s9,s9,-1884 # 800088f8 <etext+0x8f8>
    name,
    ip,
    "Traversing pathname"
);
    ilock(ip);
    if(ip->type != T_DIR){
    8000405c:	4c05                	li	s8,1
  while((path = skipelem(path, name)) != 0){
    8000405e:	a07d                	j	8000410c <namex+0x124>
    ip = iget(ROOTDEV, ROOTINO);
    80004060:	4585                	li	a1,1
    80004062:	4505                	li	a0,1
    80004064:	b54ff0ef          	jal	800033b8 <iget>
    80004068:	8a2a                	mv	s4,a0
    8000406a:	bf75                	j	80004026 <namex+0x3e>
      iunlockput(ip);
    8000406c:	8552                	mv	a0,s4
    8000406e:	a8fff0ef          	jal	80003afc <iunlockput>
      
      return 0;
    80004072:	4a01                	li	s4,0
    name,
    ip,
    "Path resolved successfully"
);
  return ip;
}
    80004074:	8552                	mv	a0,s4
    80004076:	70a6                	ld	ra,104(sp)
    80004078:	7406                	ld	s0,96(sp)
    8000407a:	64e6                	ld	s1,88(sp)
    8000407c:	6946                	ld	s2,80(sp)
    8000407e:	69a6                	ld	s3,72(sp)
    80004080:	6a06                	ld	s4,64(sp)
    80004082:	7ae2                	ld	s5,56(sp)
    80004084:	7b42                	ld	s6,48(sp)
    80004086:	7ba2                	ld	s7,40(sp)
    80004088:	7c02                	ld	s8,32(sp)
    8000408a:	6ce2                	ld	s9,24(sp)
    8000408c:	6d42                	ld	s10,16(sp)
    8000408e:	6da2                	ld	s11,8(sp)
    80004090:	6165                	addi	sp,sp,112
    80004092:	8082                	ret
      iunlock(ip);
    80004094:	8552                	mv	a0,s4
    80004096:	87dff0ef          	jal	80003912 <iunlock>
      return ip;
    8000409a:	bfe9                	j	80004074 <namex+0x8c>
      iunlockput(ip);
    8000409c:	8552                	mv	a0,s4
    8000409e:	a5fff0ef          	jal	80003afc <iunlockput>
      return 0;
    800040a2:	8a4e                	mv	s4,s3
    800040a4:	bfc1                	j	80004074 <namex+0x8c>
  len = path - s;
    800040a6:	40998633          	sub	a2,s3,s1
    800040aa:	00060b1b          	sext.w	s6,a2
  if(len >= DIRSIZ)
    800040ae:	096dd763          	bge	s11,s6,8000413c <namex+0x154>
    memmove(name, s, DIRSIZ);
    800040b2:	4639                	li	a2,14
    800040b4:	85a6                	mv	a1,s1
    800040b6:	8556                	mv	a0,s5
    800040b8:	c79fc0ef          	jal	80000d30 <memmove>
    800040bc:	84ce                	mv	s1,s3
  while(*path == '/')
    800040be:	0004c783          	lbu	a5,0(s1)
    800040c2:	01279763          	bne	a5,s2,800040d0 <namex+0xe8>
    path++;
    800040c6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800040c8:	0004c783          	lbu	a5,0(s1)
    800040cc:	ff278de3          	beq	a5,s2,800040c6 <namex+0xde>
    path_report(
    800040d0:	876a                	mv	a4,s10
    800040d2:	86d2                	mv	a3,s4
    800040d4:	8656                	mv	a2,s5
    800040d6:	85a6                	mv	a1,s1
    800040d8:	8566                	mv	a0,s9
    800040da:	edffe0ef          	jal	80002fb8 <path_report>
    ilock(ip);
    800040de:	8552                	mv	a0,s4
    800040e0:	f40ff0ef          	jal	80003820 <ilock>
    if(ip->type != T_DIR){
    800040e4:	044a1783          	lh	a5,68(s4)
    800040e8:	f98792e3          	bne	a5,s8,8000406c <namex+0x84>
    if(nameiparent && *path == '\0'){
    800040ec:	000b8563          	beqz	s7,800040f6 <namex+0x10e>
    800040f0:	0004c783          	lbu	a5,0(s1)
    800040f4:	d3c5                	beqz	a5,80004094 <namex+0xac>
    if((next = dirlookup(ip, name, 0)) == 0){
    800040f6:	4601                	li	a2,0
    800040f8:	85d6                	mv	a1,s5
    800040fa:	8552                	mv	a0,s4
    800040fc:	e1bff0ef          	jal	80003f16 <dirlookup>
    80004100:	89aa                	mv	s3,a0
    80004102:	dd49                	beqz	a0,8000409c <namex+0xb4>
    iunlockput(ip);
    80004104:	8552                	mv	a0,s4
    80004106:	9f7ff0ef          	jal	80003afc <iunlockput>
    ip = next;
    8000410a:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000410c:	0004c783          	lbu	a5,0(s1)
    80004110:	01279763          	bne	a5,s2,8000411e <namex+0x136>
    path++;
    80004114:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004116:	0004c783          	lbu	a5,0(s1)
    8000411a:	ff278de3          	beq	a5,s2,80004114 <namex+0x12c>
  if(*path == 0)
    8000411e:	c7b1                	beqz	a5,8000416a <namex+0x182>
  while(*path != '/' && *path != 0)
    80004120:	0004c783          	lbu	a5,0(s1)
    80004124:	89a6                	mv	s3,s1
  len = path - s;
    80004126:	4b01                	li	s6,0
    80004128:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000412a:	01278963          	beq	a5,s2,8000413c <namex+0x154>
    8000412e:	dfa5                	beqz	a5,800040a6 <namex+0xbe>
    path++;
    80004130:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004132:	0009c783          	lbu	a5,0(s3)
    80004136:	ff279ce3          	bne	a5,s2,8000412e <namex+0x146>
    8000413a:	b7b5                	j	800040a6 <namex+0xbe>
    memmove(name, s, len);
    8000413c:	2601                	sext.w	a2,a2
    8000413e:	85a6                	mv	a1,s1
    80004140:	8556                	mv	a0,s5
    80004142:	beffc0ef          	jal	80000d30 <memmove>
    name[len] = 0;
    80004146:	9b56                	add	s6,s6,s5
    80004148:	000b0023          	sb	zero,0(s6)
    path_report(
    8000414c:	00004717          	auipc	a4,0x4
    80004150:	7bc70713          	addi	a4,a4,1980 # 80008908 <etext+0x908>
    80004154:	4681                	li	a3,0
    80004156:	8656                	mv	a2,s5
    80004158:	85a6                	mv	a1,s1
    8000415a:	00004517          	auipc	a0,0x4
    8000415e:	7c650513          	addi	a0,a0,1990 # 80008920 <etext+0x920>
    80004162:	e57fe0ef          	jal	80002fb8 <path_report>
    80004166:	84ce                	mv	s1,s3
    80004168:	bf99                	j	800040be <namex+0xd6>
  if(nameiparent){
    8000416a:	020b9063          	bnez	s7,8000418a <namex+0x1a2>
  path_report(
    8000416e:	00004717          	auipc	a4,0x4
    80004172:	7ea70713          	addi	a4,a4,2026 # 80008958 <etext+0x958>
    80004176:	86d2                	mv	a3,s4
    80004178:	8656                	mv	a2,s5
    8000417a:	4581                	li	a1,0
    8000417c:	00004517          	auipc	a0,0x4
    80004180:	7fc50513          	addi	a0,a0,2044 # 80008978 <etext+0x978>
    80004184:	e35fe0ef          	jal	80002fb8 <path_report>
  return ip;
    80004188:	b5f5                	j	80004074 <namex+0x8c>
    iput(ip);
    8000418a:	8552                	mv	a0,s4
    8000418c:	8a5ff0ef          	jal	80003a30 <iput>
    path_report(
    80004190:	00004717          	auipc	a4,0x4
    80004194:	7a070713          	addi	a4,a4,1952 # 80008930 <etext+0x930>
    80004198:	86d2                	mv	a3,s4
    8000419a:	8656                	mv	a2,s5
    8000419c:	4581                	li	a1,0
    8000419e:	00004517          	auipc	a0,0x4
    800041a2:	7aa50513          	addi	a0,a0,1962 # 80008948 <etext+0x948>
    800041a6:	e13fe0ef          	jal	80002fb8 <path_report>
    return 0;
    800041aa:	4a01                	li	s4,0
    800041ac:	b5e1                	j	80004074 <namex+0x8c>

00000000800041ae <dirlink>:
{
    800041ae:	7139                	addi	sp,sp,-64
    800041b0:	fc06                	sd	ra,56(sp)
    800041b2:	f822                	sd	s0,48(sp)
    800041b4:	f04a                	sd	s2,32(sp)
    800041b6:	ec4e                	sd	s3,24(sp)
    800041b8:	e852                	sd	s4,16(sp)
    800041ba:	0080                	addi	s0,sp,64
    800041bc:	892a                	mv	s2,a0
    800041be:	89ae                	mv	s3,a1
    800041c0:	8a32                	mv	s4,a2
  dir_report(
    800041c2:	00004797          	auipc	a5,0x4
    800041c6:	7c678793          	addi	a5,a5,1990 # 80008988 <etext+0x988>
    800041ca:	577d                	li	a4,-1
    800041cc:	86b2                	mv	a3,a2
    800041ce:	862e                	mv	a2,a1
    800041d0:	85aa                	mv	a1,a0
    800041d2:	00004517          	auipc	a0,0x4
    800041d6:	7d650513          	addi	a0,a0,2006 # 800089a8 <etext+0x9a8>
    800041da:	d29fe0ef          	jal	80002f02 <dir_report>
  if((ip = dirlookup(dp, name, 0)) != 0){
    800041de:	4601                	li	a2,0
    800041e0:	85ce                	mv	a1,s3
    800041e2:	854a                	mv	a0,s2
    800041e4:	d33ff0ef          	jal	80003f16 <dirlookup>
    800041e8:	e159                	bnez	a0,8000426e <dirlink+0xc0>
    800041ea:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041ec:	04c92483          	lw	s1,76(s2)
    800041f0:	c48d                	beqz	s1,8000421a <dirlink+0x6c>
    800041f2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041f4:	4741                	li	a4,16
    800041f6:	86a6                	mv	a3,s1
    800041f8:	fc040613          	addi	a2,s0,-64
    800041fc:	4581                	li	a1,0
    800041fe:	854a                	mv	a0,s2
    80004200:	a83ff0ef          	jal	80003c82 <readi>
    80004204:	47c1                	li	a5,16
    80004206:	08f51663          	bne	a0,a5,80004292 <dirlink+0xe4>
    if(de.inum == 0)
    8000420a:	fc045783          	lhu	a5,-64(s0)
    8000420e:	c791                	beqz	a5,8000421a <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004210:	24c1                	addiw	s1,s1,16
    80004212:	04c92783          	lw	a5,76(s2)
    80004216:	fcf4efe3          	bltu	s1,a5,800041f4 <dirlink+0x46>
  strncpy(de.name, name, DIRSIZ);
    8000421a:	4639                	li	a2,14
    8000421c:	85ce                	mv	a1,s3
    8000421e:	fc240513          	addi	a0,s0,-62
    80004222:	bb5fc0ef          	jal	80000dd6 <strncpy>
  de.inum = inum;
    80004226:	fd441023          	sh	s4,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000422a:	4741                	li	a4,16
    8000422c:	86a6                	mv	a3,s1
    8000422e:	fc040613          	addi	a2,s0,-64
    80004232:	4581                	li	a1,0
    80004234:	854a                	mv	a0,s2
    80004236:	b7dff0ef          	jal	80003db2 <writei>
    8000423a:	47c1                	li	a5,16
    8000423c:	06f51163          	bne	a0,a5,8000429e <dirlink+0xf0>
  dir_report(
    80004240:	00004797          	auipc	a5,0x4
    80004244:	7b078793          	addi	a5,a5,1968 # 800089f0 <etext+0x9f0>
    80004248:	8726                	mv	a4,s1
    8000424a:	86d2                	mv	a3,s4
    8000424c:	864e                	mv	a2,s3
    8000424e:	85ca                	mv	a1,s2
    80004250:	00004517          	auipc	a0,0x4
    80004254:	7b850513          	addi	a0,a0,1976 # 80008a08 <etext+0xa08>
    80004258:	cabfe0ef          	jal	80002f02 <dir_report>
  return 0;
    8000425c:	4501                	li	a0,0
    8000425e:	74a2                	ld	s1,40(sp)
}
    80004260:	70e2                	ld	ra,56(sp)
    80004262:	7442                	ld	s0,48(sp)
    80004264:	7902                	ld	s2,32(sp)
    80004266:	69e2                	ld	s3,24(sp)
    80004268:	6a42                	ld	s4,16(sp)
    8000426a:	6121                	addi	sp,sp,64
    8000426c:	8082                	ret
    iput(ip);
    8000426e:	fc2ff0ef          	jal	80003a30 <iput>
    dir_report(
    80004272:	00004797          	auipc	a5,0x4
    80004276:	74678793          	addi	a5,a5,1862 # 800089b8 <etext+0x9b8>
    8000427a:	577d                	li	a4,-1
    8000427c:	86d2                	mv	a3,s4
    8000427e:	864e                	mv	a2,s3
    80004280:	85ca                	mv	a1,s2
    80004282:	00004517          	auipc	a0,0x4
    80004286:	74e50513          	addi	a0,a0,1870 # 800089d0 <etext+0x9d0>
    8000428a:	c79fe0ef          	jal	80002f02 <dir_report>
    return -1;
    8000428e:	557d                	li	a0,-1
    80004290:	bfc1                	j	80004260 <dirlink+0xb2>
      panic("dirlink read");
    80004292:	00004517          	auipc	a0,0x4
    80004296:	74e50513          	addi	a0,a0,1870 # 800089e0 <etext+0x9e0>
    8000429a:	d78fc0ef          	jal	80000812 <panic>
    return -1;
    8000429e:	557d                	li	a0,-1
    800042a0:	74a2                	ld	s1,40(sp)
    800042a2:	bf7d                	j	80004260 <dirlink+0xb2>

00000000800042a4 <namei>:

struct inode*
namei(char *path)
{
    800042a4:	1101                	addi	sp,sp,-32
    800042a6:	ec06                	sd	ra,24(sp)
    800042a8:	e822                	sd	s0,16(sp)
    800042aa:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800042ac:	fe040613          	addi	a2,s0,-32
    800042b0:	4581                	li	a1,0
    800042b2:	d37ff0ef          	jal	80003fe8 <namex>
}
    800042b6:	60e2                	ld	ra,24(sp)
    800042b8:	6442                	ld	s0,16(sp)
    800042ba:	6105                	addi	sp,sp,32
    800042bc:	8082                	ret

00000000800042be <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800042be:	1141                	addi	sp,sp,-16
    800042c0:	e406                	sd	ra,8(sp)
    800042c2:	e022                	sd	s0,0(sp)
    800042c4:	0800                	addi	s0,sp,16
    800042c6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800042c8:	4585                	li	a1,1
    800042ca:	d1fff0ef          	jal	80003fe8 <namex>
    800042ce:	60a2                	ld	ra,8(sp)
    800042d0:	6402                	ld	s0,0(sp)
    800042d2:	0141                	addi	sp,sp,16
    800042d4:	8082                	ret

00000000800042d6 <log_get_state>:
  int committing;
};

static struct log_state
log_get_state(void)
{
    800042d6:	1101                	addi	sp,sp,-32
    800042d8:	ec22                	sd	s0,24(sp)
    800042da:	1000                	addi	s0,sp,32
  struct log_state s;
  s.n = log.lh.n;
  s.out = log.outstanding;
    800042dc:	0001d697          	auipc	a3,0x1d
    800042e0:	f1c68693          	addi	a3,a3,-228 # 800211f8 <log>
  s.committing = log.committing;
  return s;
    800042e4:	0286e503          	lwu	a0,40(a3)
    800042e8:	57fd                	li	a5,-1
    800042ea:	9381                	srli	a5,a5,0x20
    800042ec:	01c6e703          	lwu	a4,28(a3)
    800042f0:	1702                	slli	a4,a4,0x20
    800042f2:	8d7d                	and	a0,a0,a5
    800042f4:	0206e583          	lwu	a1,32(a3)
}
    800042f8:	8d59                	or	a0,a0,a4
    800042fa:	8dfd                	and	a1,a1,a5
    800042fc:	6462                	ld	s0,24(sp)
    800042fe:	6105                	addi	sp,sp,32
    80004300:	8082                	ret

0000000080004302 <log_report>:

//
// 🔥 report (نفس نمط bio.c)
//
void log_report(char *op, int bno, struct log_state old, char *desc)
{
    80004302:	de010113          	addi	sp,sp,-544
    80004306:	20113c23          	sd	ra,536(sp)
    8000430a:	20813823          	sd	s0,528(sp)
    8000430e:	20913423          	sd	s1,520(sp)
    80004312:	21213023          	sd	s2,512(sp)
    80004316:	ffce                	sd	s3,504(sp)
    80004318:	1400                	addi	s0,sp,544
    8000431a:	892a                	mv	s2,a0
    8000431c:	89ae                	mv	s3,a1
    8000431e:	dec43023          	sd	a2,-544(s0)
    80004322:	ded43423          	sd	a3,-536(s0)
    80004326:	84ba                	mv	s1,a4
  struct fs_event e;
  memset(&e, 0, sizeof(e));
    80004328:	1c800613          	li	a2,456
    8000432c:	4581                	li	a1,0
    8000432e:	e0840513          	addi	a0,s0,-504
    80004332:	9a3fc0ef          	jal	80000cd4 <memset>

  struct log_state now = log_get_state();
    80004336:	fa1ff0ef          	jal	800042d6 <log_get_state>
    8000433a:	dea42c23          	sw	a0,-520(s0)
    8000433e:	02055793          	srli	a5,a0,0x20
    80004342:	def42e23          	sw	a5,-516(s0)
    80004346:	e0b42023          	sw	a1,-512(s0)

  e.ticks = ticks;
    8000434a:	00005797          	auipc	a5,0x5
    8000434e:	d9e7a783          	lw	a5,-610(a5) # 800090e8 <ticks>
    80004352:	e0f42823          	sw	a5,-496(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    80004356:	db2fd0ef          	jal	80001908 <myproc>
    8000435a:	4781                	li	a5,0
    8000435c:	c501                	beqz	a0,80004364 <log_report+0x62>
    8000435e:	daafd0ef          	jal	80001908 <myproc>
    80004362:	591c                	lw	a5,48(a0)
    80004364:	e0f42a23          	sw	a5,-492(s0)
  e.type = LAYER_LOG;
    80004368:	4789                	li	a5,2
    8000436a:	e0f42c23          	sw	a5,-488(s0)
  e.blockno = bno;
    8000436e:	e3342623          	sw	s3,-468(s0)

  // before
  e.old_log_n = old.n;
    80004372:	de042783          	lw	a5,-544(s0)
    80004376:	e4f42423          	sw	a5,-440(s0)
  e.old_outstanding = old.out;
    8000437a:	de442783          	lw	a5,-540(s0)
    8000437e:	e4f42823          	sw	a5,-432(s0)
  e.old_committing = old.committing;
    80004382:	de842783          	lw	a5,-536(s0)
    80004386:	e4f42c23          	sw	a5,-424(s0)

  // after
  e.log_n = now.n;
    8000438a:	df842783          	lw	a5,-520(s0)
    8000438e:	e4f42223          	sw	a5,-444(s0)
  e.outstanding = now.out;
    80004392:	dfc42783          	lw	a5,-516(s0)
    80004396:	e4f42623          	sw	a5,-436(s0)
  e.committing = now.committing;
    8000439a:	e0042783          	lw	a5,-512(s0)
    8000439e:	e4f42a23          	sw	a5,-428(s0)

  safestrcpy(e.op_name, op, 16);
    800043a2:	4641                	li	a2,16
    800043a4:	85ca                	mv	a1,s2
    800043a6:	e1c40513          	addi	a0,s0,-484
    800043aa:	a69fc0ef          	jal	80000e12 <safestrcpy>
  safestrcpy(e.details, desc, 128);
    800043ae:	08000613          	li	a2,128
    800043b2:	85a6                	mv	a1,s1
    800043b4:	f5040513          	addi	a0,s0,-176
    800043b8:	a5bfc0ef          	jal	80000e12 <safestrcpy>

  fslog_push(&e);
    800043bc:	e0840513          	addi	a0,s0,-504
    800043c0:	7ec020ef          	jal	80006bac <fslog_push>
}
    800043c4:	21813083          	ld	ra,536(sp)
    800043c8:	21013403          	ld	s0,528(sp)
    800043cc:	20813483          	ld	s1,520(sp)
    800043d0:	20013903          	ld	s2,512(sp)
    800043d4:	79fe                	ld	s3,504(sp)
    800043d6:	22010113          	addi	sp,sp,544
    800043da:	8082                	ret

00000000800043dc <install_trans>:
}

static void
install_trans(int recovering)
{
  for (int tail = 0; tail < log.lh.n; tail++) {
    800043dc:	0001d797          	auipc	a5,0x1d
    800043e0:	e447a783          	lw	a5,-444(a5) # 80021220 <log+0x28>
    800043e4:	12f05063          	blez	a5,80004504 <install_trans+0x128>
{
    800043e8:	7159                	addi	sp,sp,-112
    800043ea:	f486                	sd	ra,104(sp)
    800043ec:	f0a2                	sd	s0,96(sp)
    800043ee:	eca6                	sd	s1,88(sp)
    800043f0:	e8ca                	sd	s2,80(sp)
    800043f2:	e4ce                	sd	s3,72(sp)
    800043f4:	e0d2                	sd	s4,64(sp)
    800043f6:	fc56                	sd	s5,56(sp)
    800043f8:	f85a                	sd	s6,48(sp)
    800043fa:	f45e                	sd	s7,40(sp)
    800043fc:	f062                	sd	s8,32(sp)
    800043fe:	ec66                	sd	s9,24(sp)
    80004400:	e86a                	sd	s10,16(sp)
    80004402:	1880                	addi	s0,sp,112
    80004404:	8b2a                	mv	s6,a0
    80004406:	0001da97          	auipc	s5,0x1d
    8000440a:	e1ea8a93          	addi	s5,s5,-482 # 80021224 <log+0x2c>
  for (int tail = 0; tail < log.lh.n; tail++) {
    8000440e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1);
    80004410:	0001d997          	auipc	s3,0x1d
    80004414:	de898993          	addi	s3,s3,-536 # 800211f8 <log>
    struct log_state old = log_get_state();

    if (recovering)
      log_report("RECOVER_BLK", log.lh.block[tail], old, "Recover block");
    else
      log_report("INSTALL_BLK", log.lh.block[tail], old, "Install block");
    80004418:	00004d17          	auipc	s10,0x4
    8000441c:	620d0d13          	addi	s10,s10,1568 # 80008a38 <etext+0xa38>
    80004420:	00004c97          	auipc	s9,0x4
    80004424:	628c8c93          	addi	s9,s9,1576 # 80008a48 <etext+0xa48>
      log_report("RECOVER_BLK", log.lh.block[tail], old, "Recover block");
    80004428:	00004c17          	auipc	s8,0x4
    8000442c:	5f0c0c13          	addi	s8,s8,1520 # 80008a18 <etext+0xa18>
    80004430:	00004b97          	auipc	s7,0x4
    80004434:	5f8b8b93          	addi	s7,s7,1528 # 80008a28 <etext+0xa28>
    80004438:	a0a9                	j	80004482 <install_trans+0xa6>
      log_report("INSTALL_BLK", log.lh.block[tail], old, "Install block");
    8000443a:	876a                	mv	a4,s10
    8000443c:	f9043603          	ld	a2,-112(s0)
    80004440:	f9843683          	ld	a3,-104(s0)
    80004444:	000aa583          	lw	a1,0(s5)
    80004448:	8566                	mv	a0,s9
    8000444a:	eb9ff0ef          	jal	80004302 <log_report>

    memmove(dbuf->data, lbuf->data, BSIZE);
    8000444e:	40000613          	li	a2,1024
    80004452:	05890593          	addi	a1,s2,88
    80004456:	05848513          	addi	a0,s1,88
    8000445a:	8d7fc0ef          	jal	80000d30 <memmove>
    bwrite(dbuf);
    8000445e:	8526                	mv	a0,s1
    80004460:	90ffe0ef          	jal	80002d6e <bwrite>

    if (!recovering)
      bunpin(dbuf);
    80004464:	8526                	mv	a0,s1
    80004466:	a4ffe0ef          	jal	80002eb4 <bunpin>

    brelse(lbuf);
    8000446a:	854a                	mv	a0,s2
    8000446c:	95bfe0ef          	jal	80002dc6 <brelse>
    brelse(dbuf);
    80004470:	8526                	mv	a0,s1
    80004472:	955fe0ef          	jal	80002dc6 <brelse>
  for (int tail = 0; tail < log.lh.n; tail++) {
    80004476:	2a05                	addiw	s4,s4,1
    80004478:	0a91                	addi	s5,s5,4
    8000447a:	0289a783          	lw	a5,40(s3)
    8000447e:	06fa5563          	bge	s4,a5,800044e8 <install_trans+0x10c>
    struct buf *lbuf = bread(log.dev, log.start+tail+1);
    80004482:	0189a583          	lw	a1,24(s3)
    80004486:	014585bb          	addw	a1,a1,s4
    8000448a:	2585                	addiw	a1,a1,1
    8000448c:	0249a503          	lw	a0,36(s3)
    80004490:	fa0fe0ef          	jal	80002c30 <bread>
    80004494:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);
    80004496:	000aa583          	lw	a1,0(s5)
    8000449a:	0249a503          	lw	a0,36(s3)
    8000449e:	f92fe0ef          	jal	80002c30 <bread>
    800044a2:	84aa                	mv	s1,a0
    struct log_state old = log_get_state();
    800044a4:	e33ff0ef          	jal	800042d6 <log_get_state>
    800044a8:	f8a42823          	sw	a0,-112(s0)
    800044ac:	02055793          	srli	a5,a0,0x20
    800044b0:	f8f42a23          	sw	a5,-108(s0)
    800044b4:	f8b42c23          	sw	a1,-104(s0)
    if (recovering)
    800044b8:	f80b01e3          	beqz	s6,8000443a <install_trans+0x5e>
      log_report("RECOVER_BLK", log.lh.block[tail], old, "Recover block");
    800044bc:	8762                	mv	a4,s8
    800044be:	f9043603          	ld	a2,-112(s0)
    800044c2:	f9843683          	ld	a3,-104(s0)
    800044c6:	000aa583          	lw	a1,0(s5)
    800044ca:	855e                	mv	a0,s7
    800044cc:	e37ff0ef          	jal	80004302 <log_report>
    memmove(dbuf->data, lbuf->data, BSIZE);
    800044d0:	40000613          	li	a2,1024
    800044d4:	05890593          	addi	a1,s2,88
    800044d8:	05848513          	addi	a0,s1,88
    800044dc:	855fc0ef          	jal	80000d30 <memmove>
    bwrite(dbuf);
    800044e0:	8526                	mv	a0,s1
    800044e2:	88dfe0ef          	jal	80002d6e <bwrite>
    if (!recovering)
    800044e6:	b751                	j	8000446a <install_trans+0x8e>
  }
}
    800044e8:	70a6                	ld	ra,104(sp)
    800044ea:	7406                	ld	s0,96(sp)
    800044ec:	64e6                	ld	s1,88(sp)
    800044ee:	6946                	ld	s2,80(sp)
    800044f0:	69a6                	ld	s3,72(sp)
    800044f2:	6a06                	ld	s4,64(sp)
    800044f4:	7ae2                	ld	s5,56(sp)
    800044f6:	7b42                	ld	s6,48(sp)
    800044f8:	7ba2                	ld	s7,40(sp)
    800044fa:	7c02                	ld	s8,32(sp)
    800044fc:	6ce2                	ld	s9,24(sp)
    800044fe:	6d42                	ld	s10,16(sp)
    80004500:	6165                	addi	sp,sp,112
    80004502:	8082                	ret
    80004504:	8082                	ret

0000000080004506 <write_head>:
{
    80004506:	7179                	addi	sp,sp,-48
    80004508:	f406                	sd	ra,40(sp)
    8000450a:	f022                	sd	s0,32(sp)
    8000450c:	ec26                	sd	s1,24(sp)
    8000450e:	e84a                	sd	s2,16(sp)
    80004510:	1800                	addi	s0,sp,48
  struct buf *buf = bread(log.dev, log.start);
    80004512:	0001d917          	auipc	s2,0x1d
    80004516:	ce690913          	addi	s2,s2,-794 # 800211f8 <log>
    8000451a:	01892583          	lw	a1,24(s2)
    8000451e:	02492503          	lw	a0,36(s2)
    80004522:	f0efe0ef          	jal	80002c30 <bread>
    80004526:	84aa                	mv	s1,a0
  struct log_state old = log_get_state();
    80004528:	dafff0ef          	jal	800042d6 <log_get_state>
    8000452c:	fca42823          	sw	a0,-48(s0)
    80004530:	9101                	srli	a0,a0,0x20
    80004532:	fca42a23          	sw	a0,-44(s0)
    80004536:	fcb42c23          	sw	a1,-40(s0)
  hb->n = log.lh.n;
    8000453a:	02892603          	lw	a2,40(s2)
    8000453e:	ccb0                	sw	a2,88(s1)
  for (int i = 0; i < log.lh.n; i++)
    80004540:	00c05f63          	blez	a2,8000455e <write_head+0x58>
    80004544:	0001d717          	auipc	a4,0x1d
    80004548:	ce070713          	addi	a4,a4,-800 # 80021224 <log+0x2c>
    8000454c:	87a6                	mv	a5,s1
    8000454e:	060a                	slli	a2,a2,0x2
    80004550:	9626                	add	a2,a2,s1
    hb->block[i] = log.lh.block[i];
    80004552:	4314                	lw	a3,0(a4)
    80004554:	cff4                	sw	a3,92(a5)
  for (int i = 0; i < log.lh.n; i++)
    80004556:	0711                	addi	a4,a4,4
    80004558:	0791                	addi	a5,a5,4
    8000455a:	fec79ce3          	bne	a5,a2,80004552 <write_head+0x4c>
  bwrite(buf);
    8000455e:	8526                	mv	a0,s1
    80004560:	80ffe0ef          	jal	80002d6e <bwrite>
  log_report("WRITE_HEAD", 0, old, "Write log header to disk");
    80004564:	00004717          	auipc	a4,0x4
    80004568:	4f470713          	addi	a4,a4,1268 # 80008a58 <etext+0xa58>
    8000456c:	fd043603          	ld	a2,-48(s0)
    80004570:	fd843683          	ld	a3,-40(s0)
    80004574:	4581                	li	a1,0
    80004576:	00004517          	auipc	a0,0x4
    8000457a:	50250513          	addi	a0,a0,1282 # 80008a78 <etext+0xa78>
    8000457e:	d85ff0ef          	jal	80004302 <log_report>
  brelse(buf);
    80004582:	8526                	mv	a0,s1
    80004584:	843fe0ef          	jal	80002dc6 <brelse>
}
    80004588:	70a2                	ld	ra,40(sp)
    8000458a:	7402                	ld	s0,32(sp)
    8000458c:	64e2                	ld	s1,24(sp)
    8000458e:	6942                	ld	s2,16(sp)
    80004590:	6145                	addi	sp,sp,48
    80004592:	8082                	ret

0000000080004594 <initlog>:
{
    80004594:	715d                	addi	sp,sp,-80
    80004596:	e486                	sd	ra,72(sp)
    80004598:	e0a2                	sd	s0,64(sp)
    8000459a:	fc26                	sd	s1,56(sp)
    8000459c:	f84a                	sd	s2,48(sp)
    8000459e:	f44e                	sd	s3,40(sp)
    800045a0:	0880                	addi	s0,sp,80
    800045a2:	892a                	mv	s2,a0
    800045a4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800045a6:	0001d497          	auipc	s1,0x1d
    800045aa:	c5248493          	addi	s1,s1,-942 # 800211f8 <log>
    800045ae:	00004597          	auipc	a1,0x4
    800045b2:	4da58593          	addi	a1,a1,1242 # 80008a88 <etext+0xa88>
    800045b6:	8526                	mv	a0,s1
    800045b8:	dc8fc0ef          	jal	80000b80 <initlock>
  log.start = sb->logstart;
    800045bc:	0149a783          	lw	a5,20(s3)
    800045c0:	cc9c                	sw	a5,24(s1)
  log.dev = dev;
    800045c2:	0324a223          	sw	s2,36(s1)
  struct log_state old = log_get_state();
    800045c6:	d11ff0ef          	jal	800042d6 <log_get_state>
    800045ca:	fca42023          	sw	a0,-64(s0)
    800045ce:	9101                	srli	a0,a0,0x20
    800045d0:	fca42223          	sw	a0,-60(s0)
    800045d4:	fcb42423          	sw	a1,-56(s0)
  log_report("INIT_LOG", 0, old, "Initialize log system");
    800045d8:	00004717          	auipc	a4,0x4
    800045dc:	4b870713          	addi	a4,a4,1208 # 80008a90 <etext+0xa90>
    800045e0:	fc043603          	ld	a2,-64(s0)
    800045e4:	fc843683          	ld	a3,-56(s0)
    800045e8:	4581                	li	a1,0
    800045ea:	00004517          	auipc	a0,0x4
    800045ee:	4be50513          	addi	a0,a0,1214 # 80008aa8 <etext+0xaa8>
    800045f2:	d11ff0ef          	jal	80004302 <log_report>
  struct buf *buf = bread(log.dev, log.start);
    800045f6:	4c8c                	lw	a1,24(s1)
    800045f8:	50c8                	lw	a0,36(s1)
    800045fa:	e36fe0ef          	jal	80002c30 <bread>
    800045fe:	892a                	mv	s2,a0
  struct log_state old = log_get_state();
    80004600:	cd7ff0ef          	jal	800042d6 <log_get_state>
    80004604:	faa42823          	sw	a0,-80(s0)
    80004608:	02055793          	srli	a5,a0,0x20
    8000460c:	faf42a23          	sw	a5,-76(s0)
    80004610:	fab42c23          	sw	a1,-72(s0)
  log.lh.n = lh->n;
    80004614:	05892603          	lw	a2,88(s2)
    80004618:	d490                	sw	a2,40(s1)
  for (int i = 0; i < log.lh.n; i++)
    8000461a:	00c05f63          	blez	a2,80004638 <initlog+0xa4>
    8000461e:	87ca                	mv	a5,s2
    80004620:	0001d717          	auipc	a4,0x1d
    80004624:	c0470713          	addi	a4,a4,-1020 # 80021224 <log+0x2c>
    80004628:	060a                	slli	a2,a2,0x2
    8000462a:	964a                	add	a2,a2,s2
    log.lh.block[i] = lh->block[i];
    8000462c:	4ff4                	lw	a3,92(a5)
    8000462e:	c314                	sw	a3,0(a4)
  for (int i = 0; i < log.lh.n; i++)
    80004630:	0791                	addi	a5,a5,4
    80004632:	0711                	addi	a4,a4,4
    80004634:	fec79ce3          	bne	a5,a2,8000462c <initlog+0x98>
  log_report("READ_HEAD", 0, old, "Read log header from disk");
    80004638:	00004717          	auipc	a4,0x4
    8000463c:	48070713          	addi	a4,a4,1152 # 80008ab8 <etext+0xab8>
    80004640:	fb043603          	ld	a2,-80(s0)
    80004644:	fb843683          	ld	a3,-72(s0)
    80004648:	4581                	li	a1,0
    8000464a:	00004517          	auipc	a0,0x4
    8000464e:	48e50513          	addi	a0,a0,1166 # 80008ad8 <etext+0xad8>
    80004652:	cb1ff0ef          	jal	80004302 <log_report>
  brelse(buf);
    80004656:	854a                	mv	a0,s2
    80004658:	f6efe0ef          	jal	80002dc6 <brelse>
static void
recover_from_log(void)
{
  read_head();

  if (log.lh.n > 0) {
    8000465c:	0001d797          	auipc	a5,0x1d
    80004660:	bc47a783          	lw	a5,-1084(a5) # 80021220 <log+0x28>
    80004664:	00f04963          	bgtz	a5,80004676 <initlog+0xe2>
}
    80004668:	60a6                	ld	ra,72(sp)
    8000466a:	6406                	ld	s0,64(sp)
    8000466c:	74e2                	ld	s1,56(sp)
    8000466e:	7942                	ld	s2,48(sp)
    80004670:	79a2                	ld	s3,40(sp)
    80004672:	6161                	addi	sp,sp,80
    80004674:	8082                	ret
    struct log_state old = log_get_state();
    80004676:	c61ff0ef          	jal	800042d6 <log_get_state>
    8000467a:	faa42823          	sw	a0,-80(s0)
    8000467e:	9101                	srli	a0,a0,0x20
    80004680:	faa42a23          	sw	a0,-76(s0)
    80004684:	fab42c23          	sw	a1,-72(s0)

    log_report("RECOVER_START", 0, old, "Start recovery");
    80004688:	00004717          	auipc	a4,0x4
    8000468c:	46070713          	addi	a4,a4,1120 # 80008ae8 <etext+0xae8>
    80004690:	fb043603          	ld	a2,-80(s0)
    80004694:	fb843683          	ld	a3,-72(s0)
    80004698:	4581                	li	a1,0
    8000469a:	00004517          	auipc	a0,0x4
    8000469e:	45e50513          	addi	a0,a0,1118 # 80008af8 <etext+0xaf8>
    800046a2:	c61ff0ef          	jal	80004302 <log_report>

    install_trans(1);
    800046a6:	4505                	li	a0,1
    800046a8:	d35ff0ef          	jal	800043dc <install_trans>

    old = log_get_state();
    800046ac:	c2bff0ef          	jal	800042d6 <log_get_state>
    800046b0:	faa42823          	sw	a0,-80(s0)
    800046b4:	9101                	srli	a0,a0,0x20
    800046b6:	faa42a23          	sw	a0,-76(s0)
    800046ba:	fab42c23          	sw	a1,-72(s0)
    log.lh.n = 0;
    800046be:	0001d797          	auipc	a5,0x1d
    800046c2:	b607a123          	sw	zero,-1182(a5) # 80021220 <log+0x28>
    write_head();
    800046c6:	e41ff0ef          	jal	80004506 <write_head>

    log_report("RECOVER_DONE", 0, old, "Recovery done");
    800046ca:	00004717          	auipc	a4,0x4
    800046ce:	43e70713          	addi	a4,a4,1086 # 80008b08 <etext+0xb08>
    800046d2:	fb043603          	ld	a2,-80(s0)
    800046d6:	fb843683          	ld	a3,-72(s0)
    800046da:	4581                	li	a1,0
    800046dc:	00004517          	auipc	a0,0x4
    800046e0:	43c50513          	addi	a0,a0,1084 # 80008b18 <etext+0xb18>
    800046e4:	c1fff0ef          	jal	80004302 <log_report>
}
    800046e8:	b741                	j	80004668 <initlog+0xd4>

00000000800046ea <begin_op>:
  }
}

void
begin_op(void)
{
    800046ea:	711d                	addi	sp,sp,-96
    800046ec:	ec86                	sd	ra,88(sp)
    800046ee:	e8a2                	sd	s0,80(sp)
    800046f0:	e4a6                	sd	s1,72(sp)
    800046f2:	e0ca                	sd	s2,64(sp)
    800046f4:	fc4e                	sd	s3,56(sp)
    800046f6:	f852                	sd	s4,48(sp)
    800046f8:	f456                	sd	s5,40(sp)
    800046fa:	f05a                	sd	s6,32(sp)
    800046fc:	ec5e                	sd	s7,24(sp)
    800046fe:	1080                	addi	s0,sp,96
  acquire(&log.lock);
    80004700:	0001d517          	auipc	a0,0x1d
    80004704:	af850513          	addi	a0,a0,-1288 # 800211f8 <log>
    80004708:	cf8fc0ef          	jal	80000c00 <acquire>

  while (1) {
    if (log.committing) {
    8000470c:	0001d497          	auipc	s1,0x1d
    80004710:	aec48493          	addi	s1,s1,-1300 # 800211f8 <log>
      struct log_state old = log_get_state();
      log_report("WAIT_COMMIT", 0, old, "Waiting for commit");
      sleep(&log, &log.lock);

    } else if (log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS) {
    80004714:	4979                	li	s2,30
      struct log_state old = log_get_state();
      log_report("WAIT_SPACE", 0, old, "Waiting for log space");
    80004716:	00004a17          	auipc	s4,0x4
    8000471a:	43aa0a13          	addi	s4,s4,1082 # 80008b50 <etext+0xb50>
    8000471e:	00004997          	auipc	s3,0x4
    80004722:	44a98993          	addi	s3,s3,1098 # 80008b68 <etext+0xb68>
      log_report("WAIT_COMMIT", 0, old, "Waiting for commit");
    80004726:	00004b17          	auipc	s6,0x4
    8000472a:	402b0b13          	addi	s6,s6,1026 # 80008b28 <etext+0xb28>
    8000472e:	00004a97          	auipc	s5,0x4
    80004732:	412a8a93          	addi	s5,s5,1042 # 80008b40 <etext+0xb40>
    80004736:	a03d                	j	80004764 <begin_op+0x7a>
      struct log_state old = log_get_state();
    80004738:	b9fff0ef          	jal	800042d6 <log_get_state>
    8000473c:	faa42023          	sw	a0,-96(s0)
    80004740:	9101                	srli	a0,a0,0x20
    80004742:	faa42223          	sw	a0,-92(s0)
    80004746:	fab42423          	sw	a1,-88(s0)
      log_report("WAIT_COMMIT", 0, old, "Waiting for commit");
    8000474a:	875a                	mv	a4,s6
    8000474c:	fa043603          	ld	a2,-96(s0)
    80004750:	fa843683          	ld	a3,-88(s0)
    80004754:	4581                	li	a1,0
    80004756:	8556                	mv	a0,s5
    80004758:	babff0ef          	jal	80004302 <log_report>
      sleep(&log, &log.lock);
    8000475c:	85a6                	mv	a1,s1
    8000475e:	8526                	mv	a0,s1
    80004760:	fb8fd0ef          	jal	80001f18 <sleep>
    if (log.committing) {
    80004764:	509c                	lw	a5,32(s1)
    80004766:	fbe9                	bnez	a5,80004738 <begin_op+0x4e>
    } else if (log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS) {
    80004768:	01c4ab83          	lw	s7,28(s1)
    8000476c:	2b85                	addiw	s7,s7,1
    8000476e:	002b979b          	slliw	a5,s7,0x2
    80004772:	017787bb          	addw	a5,a5,s7
    80004776:	0017979b          	slliw	a5,a5,0x1
    8000477a:	5498                	lw	a4,40(s1)
    8000477c:	9fb9                	addw	a5,a5,a4
    8000477e:	02f95963          	bge	s2,a5,800047b0 <begin_op+0xc6>
      struct log_state old = log_get_state();
    80004782:	b55ff0ef          	jal	800042d6 <log_get_state>
    80004786:	faa42023          	sw	a0,-96(s0)
    8000478a:	9101                	srli	a0,a0,0x20
    8000478c:	faa42223          	sw	a0,-92(s0)
    80004790:	fab42423          	sw	a1,-88(s0)
      log_report("WAIT_SPACE", 0, old, "Waiting for log space");
    80004794:	8752                	mv	a4,s4
    80004796:	fa043603          	ld	a2,-96(s0)
    8000479a:	fa843683          	ld	a3,-88(s0)
    8000479e:	4581                	li	a1,0
    800047a0:	854e                	mv	a0,s3
    800047a2:	b61ff0ef          	jal	80004302 <log_report>
      sleep(&log, &log.lock);
    800047a6:	85a6                	mv	a1,s1
    800047a8:	8526                	mv	a0,s1
    800047aa:	f6efd0ef          	jal	80001f18 <sleep>
    800047ae:	bf5d                	j	80004764 <begin_op+0x7a>

    } else {
      struct log_state old = log_get_state();
    800047b0:	b27ff0ef          	jal	800042d6 <log_get_state>
    800047b4:	faa42023          	sw	a0,-96(s0)
    800047b8:	9101                	srli	a0,a0,0x20
    800047ba:	faa42223          	sw	a0,-92(s0)
    800047be:	fab42423          	sw	a1,-88(s0)

      log.outstanding++;
    800047c2:	0001d497          	auipc	s1,0x1d
    800047c6:	a3648493          	addi	s1,s1,-1482 # 800211f8 <log>
    800047ca:	0174ae23          	sw	s7,28(s1)

      log_report("BEGIN_OP", 0, old, "Begin operation");
    800047ce:	00004717          	auipc	a4,0x4
    800047d2:	3aa70713          	addi	a4,a4,938 # 80008b78 <etext+0xb78>
    800047d6:	fa043603          	ld	a2,-96(s0)
    800047da:	fa843683          	ld	a3,-88(s0)
    800047de:	4581                	li	a1,0
    800047e0:	00004517          	auipc	a0,0x4
    800047e4:	3a850513          	addi	a0,a0,936 # 80008b88 <etext+0xb88>
    800047e8:	b1bff0ef          	jal	80004302 <log_report>

      release(&log.lock);
    800047ec:	8526                	mv	a0,s1
    800047ee:	caafc0ef          	jal	80000c98 <release>
      break;
    }
  }
}
    800047f2:	60e6                	ld	ra,88(sp)
    800047f4:	6446                	ld	s0,80(sp)
    800047f6:	64a6                	ld	s1,72(sp)
    800047f8:	6906                	ld	s2,64(sp)
    800047fa:	79e2                	ld	s3,56(sp)
    800047fc:	7a42                	ld	s4,48(sp)
    800047fe:	7aa2                	ld	s5,40(sp)
    80004800:	7b02                	ld	s6,32(sp)
    80004802:	6be2                	ld	s7,24(sp)
    80004804:	6125                	addi	sp,sp,96
    80004806:	8082                	ret

0000000080004808 <end_op>:

void
end_op(void)
{
    80004808:	7119                	addi	sp,sp,-128
    8000480a:	fc86                	sd	ra,120(sp)
    8000480c:	f8a2                	sd	s0,112(sp)
    8000480e:	f4a6                	sd	s1,104(sp)
    80004810:	f0ca                	sd	s2,96(sp)
    80004812:	0100                	addi	s0,sp,128
  int do_commit = 0;

  acquire(&log.lock);
    80004814:	0001d497          	auipc	s1,0x1d
    80004818:	9e448493          	addi	s1,s1,-1564 # 800211f8 <log>
    8000481c:	8526                	mv	a0,s1
    8000481e:	be2fc0ef          	jal	80000c00 <acquire>

  struct log_state old = log_get_state();
    80004822:	ab5ff0ef          	jal	800042d6 <log_get_state>
    80004826:	faa42023          	sw	a0,-96(s0)
    8000482a:	9101                	srli	a0,a0,0x20
    8000482c:	faa42223          	sw	a0,-92(s0)
    80004830:	fab42423          	sw	a1,-88(s0)

  log.outstanding--;
    80004834:	4cdc                	lw	a5,28(s1)
    80004836:	37fd                	addiw	a5,a5,-1
    80004838:	0007891b          	sext.w	s2,a5
    8000483c:	ccdc                	sw	a5,28(s1)

  if (log.outstanding == 0) {
    8000483e:	08091163          	bnez	s2,800048c0 <end_op+0xb8>
    do_commit = 1;
    log.committing = 1;
    80004842:	4785                	li	a5,1
    80004844:	d09c                	sw	a5,32(s1)

    log_report("PRE_COMMIT", 0, old, "Start committing");
    80004846:	00004717          	auipc	a4,0x4
    8000484a:	35270713          	addi	a4,a4,850 # 80008b98 <etext+0xb98>
    8000484e:	fa043603          	ld	a2,-96(s0)
    80004852:	fa843683          	ld	a3,-88(s0)
    80004856:	4581                	li	a1,0
    80004858:	00004517          	auipc	a0,0x4
    8000485c:	35850513          	addi	a0,a0,856 # 80008bb0 <etext+0xbb0>
    80004860:	aa3ff0ef          	jal	80004302 <log_report>
  } else {
    log_report("END_OP", 0, old, "End operation");
    wakeup(&log);
  }

  release(&log.lock);
    80004864:	8526                	mv	a0,s1
    80004866:	c32fc0ef          	jal	80000c98 <release>
}

static void
commit(void)
{
  if (log.lh.n > 0) {
    8000486a:	549c                	lw	a5,40(s1)
    8000486c:	08f04963          	bgtz	a5,800048fe <end_op+0xf6>
    acquire(&log.lock);
    80004870:	0001d497          	auipc	s1,0x1d
    80004874:	98848493          	addi	s1,s1,-1656 # 800211f8 <log>
    80004878:	8526                	mv	a0,s1
    8000487a:	b86fc0ef          	jal	80000c00 <acquire>
    old = log_get_state();
    8000487e:	a59ff0ef          	jal	800042d6 <log_get_state>
    80004882:	faa42023          	sw	a0,-96(s0)
    80004886:	9101                	srli	a0,a0,0x20
    80004888:	faa42223          	sw	a0,-92(s0)
    8000488c:	fab42423          	sw	a1,-88(s0)
    log.committing = 0;
    80004890:	0204a023          	sw	zero,32(s1)
    log_report("FINAL_RELEASE", 0, old, "Commit finished");
    80004894:	00004717          	auipc	a4,0x4
    80004898:	3bc70713          	addi	a4,a4,956 # 80008c50 <etext+0xc50>
    8000489c:	fa043603          	ld	a2,-96(s0)
    800048a0:	fa843683          	ld	a3,-88(s0)
    800048a4:	4581                	li	a1,0
    800048a6:	00004517          	auipc	a0,0x4
    800048aa:	3ba50513          	addi	a0,a0,954 # 80008c60 <etext+0xc60>
    800048ae:	a55ff0ef          	jal	80004302 <log_report>
    wakeup(&log);
    800048b2:	8526                	mv	a0,s1
    800048b4:	eb0fd0ef          	jal	80001f64 <wakeup>
    release(&log.lock);
    800048b8:	8526                	mv	a0,s1
    800048ba:	bdefc0ef          	jal	80000c98 <release>
}
    800048be:	a815                	j	800048f2 <end_op+0xea>
    log_report("END_OP", 0, old, "End operation");
    800048c0:	00004717          	auipc	a4,0x4
    800048c4:	30070713          	addi	a4,a4,768 # 80008bc0 <etext+0xbc0>
    800048c8:	fa043603          	ld	a2,-96(s0)
    800048cc:	fa843683          	ld	a3,-88(s0)
    800048d0:	4581                	li	a1,0
    800048d2:	00004517          	auipc	a0,0x4
    800048d6:	2fe50513          	addi	a0,a0,766 # 80008bd0 <etext+0xbd0>
    800048da:	a29ff0ef          	jal	80004302 <log_report>
    wakeup(&log);
    800048de:	0001d497          	auipc	s1,0x1d
    800048e2:	91a48493          	addi	s1,s1,-1766 # 800211f8 <log>
    800048e6:	8526                	mv	a0,s1
    800048e8:	e7cfd0ef          	jal	80001f64 <wakeup>
  release(&log.lock);
    800048ec:	8526                	mv	a0,s1
    800048ee:	baafc0ef          	jal	80000c98 <release>
}
    800048f2:	70e6                	ld	ra,120(sp)
    800048f4:	7446                	ld	s0,112(sp)
    800048f6:	74a6                	ld	s1,104(sp)
    800048f8:	7906                	ld	s2,96(sp)
    800048fa:	6109                	addi	sp,sp,128
    800048fc:	8082                	ret
    struct log_state old = log_get_state();
    800048fe:	9d9ff0ef          	jal	800042d6 <log_get_state>
    80004902:	f8a42023          	sw	a0,-128(s0)
    80004906:	9101                	srli	a0,a0,0x20
    80004908:	f8a42223          	sw	a0,-124(s0)
    8000490c:	f8b42423          	sw	a1,-120(s0)

    log_report("COMMIT_START", 0, old, "Commit start");
    80004910:	00004717          	auipc	a4,0x4
    80004914:	2c870713          	addi	a4,a4,712 # 80008bd8 <etext+0xbd8>
    80004918:	f8043603          	ld	a2,-128(s0)
    8000491c:	f8843683          	ld	a3,-120(s0)
    80004920:	4581                	li	a1,0
    80004922:	00004517          	auipc	a0,0x4
    80004926:	2c650513          	addi	a0,a0,710 # 80008be8 <etext+0xbe8>
    8000492a:	9d9ff0ef          	jal	80004302 <log_report>
  for (int tail = 0; tail < log.lh.n; tail++) {
    8000492e:	0001d797          	auipc	a5,0x1d
    80004932:	8f27a783          	lw	a5,-1806(a5) # 80021220 <log+0x28>
    80004936:	0af05863          	blez	a5,800049e6 <end_op+0x1de>
    8000493a:	ecce                	sd	s3,88(sp)
    8000493c:	e8d2                	sd	s4,80(sp)
    8000493e:	e4d6                	sd	s5,72(sp)
    80004940:	e0da                	sd	s6,64(sp)
    80004942:	fc5e                	sd	s7,56(sp)
    80004944:	0001da97          	auipc	s5,0x1d
    80004948:	8e0a8a93          	addi	s5,s5,-1824 # 80021224 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1);
    8000494c:	0001da17          	auipc	s4,0x1d
    80004950:	8aca0a13          	addi	s4,s4,-1876 # 800211f8 <log>
    log_report("LOG_SYNC", log.lh.block[tail], old, "Write to log");
    80004954:	00004b97          	auipc	s7,0x4
    80004958:	2a4b8b93          	addi	s7,s7,676 # 80008bf8 <etext+0xbf8>
    8000495c:	00004b17          	auipc	s6,0x4
    80004960:	2acb0b13          	addi	s6,s6,684 # 80008c08 <etext+0xc08>
    struct buf *to = bread(log.dev, log.start+tail+1);
    80004964:	018a2583          	lw	a1,24(s4)
    80004968:	012585bb          	addw	a1,a1,s2
    8000496c:	2585                	addiw	a1,a1,1
    8000496e:	024a2503          	lw	a0,36(s4)
    80004972:	abefe0ef          	jal	80002c30 <bread>
    80004976:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]);
    80004978:	000aa583          	lw	a1,0(s5)
    8000497c:	024a2503          	lw	a0,36(s4)
    80004980:	ab0fe0ef          	jal	80002c30 <bread>
    80004984:	89aa                	mv	s3,a0
    struct log_state old = log_get_state();
    80004986:	951ff0ef          	jal	800042d6 <log_get_state>
    8000498a:	f8a42823          	sw	a0,-112(s0)
    8000498e:	02055793          	srli	a5,a0,0x20
    80004992:	f8f42a23          	sw	a5,-108(s0)
    80004996:	f8b42c23          	sw	a1,-104(s0)
    log_report("LOG_SYNC", log.lh.block[tail], old, "Write to log");
    8000499a:	875e                	mv	a4,s7
    8000499c:	f9043603          	ld	a2,-112(s0)
    800049a0:	f9843683          	ld	a3,-104(s0)
    800049a4:	000aa583          	lw	a1,0(s5)
    800049a8:	855a                	mv	a0,s6
    800049aa:	959ff0ef          	jal	80004302 <log_report>
    memmove(to->data, from->data, BSIZE);
    800049ae:	40000613          	li	a2,1024
    800049b2:	05898593          	addi	a1,s3,88
    800049b6:	05848513          	addi	a0,s1,88
    800049ba:	b76fc0ef          	jal	80000d30 <memmove>
    bwrite(to);
    800049be:	8526                	mv	a0,s1
    800049c0:	baefe0ef          	jal	80002d6e <bwrite>
    brelse(from);
    800049c4:	854e                	mv	a0,s3
    800049c6:	c00fe0ef          	jal	80002dc6 <brelse>
    brelse(to);
    800049ca:	8526                	mv	a0,s1
    800049cc:	bfafe0ef          	jal	80002dc6 <brelse>
  for (int tail = 0; tail < log.lh.n; tail++) {
    800049d0:	2905                	addiw	s2,s2,1
    800049d2:	0a91                	addi	s5,s5,4
    800049d4:	028a2783          	lw	a5,40(s4)
    800049d8:	f8f946e3          	blt	s2,a5,80004964 <end_op+0x15c>
    800049dc:	69e6                	ld	s3,88(sp)
    800049de:	6a46                	ld	s4,80(sp)
    800049e0:	6aa6                	ld	s5,72(sp)
    800049e2:	6b06                	ld	s6,64(sp)
    800049e4:	7be2                	ld	s7,56(sp)

    write_log();
    write_head();
    800049e6:	b21ff0ef          	jal	80004506 <write_head>

    old = log_get_state();
    800049ea:	8edff0ef          	jal	800042d6 <log_get_state>
    800049ee:	f8a42023          	sw	a0,-128(s0)
    800049f2:	9101                	srli	a0,a0,0x20
    800049f4:	f8a42223          	sw	a0,-124(s0)
    800049f8:	f8b42423          	sw	a1,-120(s0)
    log_report("WRITE_HEAD", 0, old, "Header committed");
    800049fc:	00004717          	auipc	a4,0x4
    80004a00:	21c70713          	addi	a4,a4,540 # 80008c18 <etext+0xc18>
    80004a04:	f8043603          	ld	a2,-128(s0)
    80004a08:	f8843683          	ld	a3,-120(s0)
    80004a0c:	4581                	li	a1,0
    80004a0e:	00004517          	auipc	a0,0x4
    80004a12:	06a50513          	addi	a0,a0,106 # 80008a78 <etext+0xa78>
    80004a16:	8edff0ef          	jal	80004302 <log_report>

    install_trans(0);
    80004a1a:	4501                	li	a0,0
    80004a1c:	9c1ff0ef          	jal	800043dc <install_trans>

    old = log_get_state();
    80004a20:	8b7ff0ef          	jal	800042d6 <log_get_state>
    80004a24:	f8a42023          	sw	a0,-128(s0)
    80004a28:	9101                	srli	a0,a0,0x20
    80004a2a:	f8a42223          	sw	a0,-124(s0)
    80004a2e:	f8b42423          	sw	a1,-120(s0)
    log.lh.n = 0;
    80004a32:	0001c797          	auipc	a5,0x1c
    80004a36:	7e07a723          	sw	zero,2030(a5) # 80021220 <log+0x28>
    write_head();
    80004a3a:	acdff0ef          	jal	80004506 <write_head>

    log_report("COMMIT_DONE", 0, old, "Commit done");
    80004a3e:	00004717          	auipc	a4,0x4
    80004a42:	1f270713          	addi	a4,a4,498 # 80008c30 <etext+0xc30>
    80004a46:	f8043603          	ld	a2,-128(s0)
    80004a4a:	f8843683          	ld	a3,-120(s0)
    80004a4e:	4581                	li	a1,0
    80004a50:	00004517          	auipc	a0,0x4
    80004a54:	1f050513          	addi	a0,a0,496 # 80008c40 <etext+0xc40>
    80004a58:	8abff0ef          	jal	80004302 <log_report>
    80004a5c:	bd11                	j	80004870 <end_op+0x68>

0000000080004a5e <log_write>:
  }
}

void
log_write(struct buf *b)
{
    80004a5e:	7179                	addi	sp,sp,-48
    80004a60:	f406                	sd	ra,40(sp)
    80004a62:	f022                	sd	s0,32(sp)
    80004a64:	ec26                	sd	s1,24(sp)
    80004a66:	e84a                	sd	s2,16(sp)
    80004a68:	1800                	addi	s0,sp,48
    80004a6a:	84aa                	mv	s1,a0
  acquire(&log.lock);
    80004a6c:	0001c917          	auipc	s2,0x1c
    80004a70:	78c90913          	addi	s2,s2,1932 # 800211f8 <log>
    80004a74:	854a                	mv	a0,s2
    80004a76:	98afc0ef          	jal	80000c00 <acquire>

  struct log_state old = log_get_state();
    80004a7a:	85dff0ef          	jal	800042d6 <log_get_state>
    80004a7e:	fca42823          	sw	a0,-48(s0)
    80004a82:	02055793          	srli	a5,a0,0x20
    80004a86:	fcf42a23          	sw	a5,-44(s0)
    80004a8a:	fcb42c23          	sw	a1,-40(s0)

  int i;
  for (i = 0; i < log.lh.n; i++) {
    80004a8e:	02892603          	lw	a2,40(s2)
    80004a92:	06c05263          	blez	a2,80004af6 <log_write+0x98>
    if (log.lh.block[i] == b->blockno)
    80004a96:	44cc                	lw	a1,12(s1)
    80004a98:	0001c717          	auipc	a4,0x1c
    80004a9c:	78c70713          	addi	a4,a4,1932 # 80021224 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004aa0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)
    80004aa2:	4314                	lw	a3,0(a4)
    80004aa4:	04b68a63          	beq	a3,a1,80004af8 <log_write+0x9a>
  for (i = 0; i < log.lh.n; i++) {
    80004aa8:	2785                	addiw	a5,a5,1
    80004aaa:	0711                	addi	a4,a4,4
    80004aac:	fec79be3          	bne	a5,a2,80004aa2 <log_write+0x44>
      break;
  }

  log.lh.block[i] = b->blockno;
    80004ab0:	0621                	addi	a2,a2,8
    80004ab2:	060a                	slli	a2,a2,0x2
    80004ab4:	0001c797          	auipc	a5,0x1c
    80004ab8:	74478793          	addi	a5,a5,1860 # 800211f8 <log>
    80004abc:	97b2                	add	a5,a5,a2
    80004abe:	44d8                	lw	a4,12(s1)
    80004ac0:	c7d8                	sw	a4,12(a5)

  if (i == log.lh.n) {
    bpin(b);
    80004ac2:	8526                	mv	a0,s1
    80004ac4:	ba2fe0ef          	jal	80002e66 <bpin>
    log.lh.n++;
    80004ac8:	0001c717          	auipc	a4,0x1c
    80004acc:	73070713          	addi	a4,a4,1840 # 800211f8 <log>
    80004ad0:	571c                	lw	a5,40(a4)
    80004ad2:	2785                	addiw	a5,a5,1
    80004ad4:	d71c                	sw	a5,40(a4)

    log_report("LOG_WRITE", b->blockno, old, "Add block to log");
    80004ad6:	00004717          	auipc	a4,0x4
    80004ada:	19a70713          	addi	a4,a4,410 # 80008c70 <etext+0xc70>
    80004ade:	fd043603          	ld	a2,-48(s0)
    80004ae2:	fd843683          	ld	a3,-40(s0)
    80004ae6:	44cc                	lw	a1,12(s1)
    80004ae8:	00004517          	auipc	a0,0x4
    80004aec:	1a050513          	addi	a0,a0,416 # 80008c88 <etext+0xc88>
    80004af0:	813ff0ef          	jal	80004302 <log_report>
    80004af4:	a82d                	j	80004b2e <log_write+0xd0>
  for (i = 0; i < log.lh.n; i++) {
    80004af6:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004af8:	00878693          	addi	a3,a5,8
    80004afc:	068a                	slli	a3,a3,0x2
    80004afe:	0001c717          	auipc	a4,0x1c
    80004b02:	6fa70713          	addi	a4,a4,1786 # 800211f8 <log>
    80004b06:	9736                	add	a4,a4,a3
    80004b08:	44d4                	lw	a3,12(s1)
    80004b0a:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {
    80004b0c:	faf60be3          	beq	a2,a5,80004ac2 <log_write+0x64>
  } else {
    log_report("LOG_MERGE", b->blockno, old, "Merge block");
    80004b10:	00004717          	auipc	a4,0x4
    80004b14:	18870713          	addi	a4,a4,392 # 80008c98 <etext+0xc98>
    80004b18:	fd043603          	ld	a2,-48(s0)
    80004b1c:	fd843683          	ld	a3,-40(s0)
    80004b20:	44cc                	lw	a1,12(s1)
    80004b22:	00004517          	auipc	a0,0x4
    80004b26:	18650513          	addi	a0,a0,390 # 80008ca8 <etext+0xca8>
    80004b2a:	fd8ff0ef          	jal	80004302 <log_report>
  }

  release(&log.lock);
    80004b2e:	0001c517          	auipc	a0,0x1c
    80004b32:	6ca50513          	addi	a0,a0,1738 # 800211f8 <log>
    80004b36:	962fc0ef          	jal	80000c98 <release>
    80004b3a:	70a2                	ld	ra,40(sp)
    80004b3c:	7402                	ld	s0,32(sp)
    80004b3e:	64e2                	ld	s1,24(sp)
    80004b40:	6942                	ld	s2,16(sp)
    80004b42:	6145                	addi	sp,sp,48
    80004b44:	8082                	ret

0000000080004b46 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004b46:	1101                	addi	sp,sp,-32
    80004b48:	ec06                	sd	ra,24(sp)
    80004b4a:	e822                	sd	s0,16(sp)
    80004b4c:	e426                	sd	s1,8(sp)
    80004b4e:	e04a                	sd	s2,0(sp)
    80004b50:	1000                	addi	s0,sp,32
    80004b52:	84aa                	mv	s1,a0
    80004b54:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004b56:	00004597          	auipc	a1,0x4
    80004b5a:	16258593          	addi	a1,a1,354 # 80008cb8 <etext+0xcb8>
    80004b5e:	0521                	addi	a0,a0,8
    80004b60:	820fc0ef          	jal	80000b80 <initlock>
  lk->name = name;
    80004b64:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004b68:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b6c:	0204a423          	sw	zero,40(s1)
}
    80004b70:	60e2                	ld	ra,24(sp)
    80004b72:	6442                	ld	s0,16(sp)
    80004b74:	64a2                	ld	s1,8(sp)
    80004b76:	6902                	ld	s2,0(sp)
    80004b78:	6105                	addi	sp,sp,32
    80004b7a:	8082                	ret

0000000080004b7c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004b7c:	1101                	addi	sp,sp,-32
    80004b7e:	ec06                	sd	ra,24(sp)
    80004b80:	e822                	sd	s0,16(sp)
    80004b82:	e426                	sd	s1,8(sp)
    80004b84:	e04a                	sd	s2,0(sp)
    80004b86:	1000                	addi	s0,sp,32
    80004b88:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b8a:	00850913          	addi	s2,a0,8
    80004b8e:	854a                	mv	a0,s2
    80004b90:	870fc0ef          	jal	80000c00 <acquire>
  while (lk->locked) {
    80004b94:	409c                	lw	a5,0(s1)
    80004b96:	c799                	beqz	a5,80004ba4 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004b98:	85ca                	mv	a1,s2
    80004b9a:	8526                	mv	a0,s1
    80004b9c:	b7cfd0ef          	jal	80001f18 <sleep>
  while (lk->locked) {
    80004ba0:	409c                	lw	a5,0(s1)
    80004ba2:	fbfd                	bnez	a5,80004b98 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004ba4:	4785                	li	a5,1
    80004ba6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004ba8:	d61fc0ef          	jal	80001908 <myproc>
    80004bac:	591c                	lw	a5,48(a0)
    80004bae:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004bb0:	854a                	mv	a0,s2
    80004bb2:	8e6fc0ef          	jal	80000c98 <release>
}
    80004bb6:	60e2                	ld	ra,24(sp)
    80004bb8:	6442                	ld	s0,16(sp)
    80004bba:	64a2                	ld	s1,8(sp)
    80004bbc:	6902                	ld	s2,0(sp)
    80004bbe:	6105                	addi	sp,sp,32
    80004bc0:	8082                	ret

0000000080004bc2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004bc2:	1101                	addi	sp,sp,-32
    80004bc4:	ec06                	sd	ra,24(sp)
    80004bc6:	e822                	sd	s0,16(sp)
    80004bc8:	e426                	sd	s1,8(sp)
    80004bca:	e04a                	sd	s2,0(sp)
    80004bcc:	1000                	addi	s0,sp,32
    80004bce:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004bd0:	00850913          	addi	s2,a0,8
    80004bd4:	854a                	mv	a0,s2
    80004bd6:	82afc0ef          	jal	80000c00 <acquire>
  lk->locked = 0;
    80004bda:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004bde:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004be2:	8526                	mv	a0,s1
    80004be4:	b80fd0ef          	jal	80001f64 <wakeup>
  release(&lk->lk);
    80004be8:	854a                	mv	a0,s2
    80004bea:	8aefc0ef          	jal	80000c98 <release>
}
    80004bee:	60e2                	ld	ra,24(sp)
    80004bf0:	6442                	ld	s0,16(sp)
    80004bf2:	64a2                	ld	s1,8(sp)
    80004bf4:	6902                	ld	s2,0(sp)
    80004bf6:	6105                	addi	sp,sp,32
    80004bf8:	8082                	ret

0000000080004bfa <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004bfa:	7179                	addi	sp,sp,-48
    80004bfc:	f406                	sd	ra,40(sp)
    80004bfe:	f022                	sd	s0,32(sp)
    80004c00:	ec26                	sd	s1,24(sp)
    80004c02:	e84a                	sd	s2,16(sp)
    80004c04:	1800                	addi	s0,sp,48
    80004c06:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004c08:	00850913          	addi	s2,a0,8
    80004c0c:	854a                	mv	a0,s2
    80004c0e:	ff3fb0ef          	jal	80000c00 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c12:	409c                	lw	a5,0(s1)
    80004c14:	ef81                	bnez	a5,80004c2c <holdingsleep+0x32>
    80004c16:	4481                	li	s1,0
  release(&lk->lk);
    80004c18:	854a                	mv	a0,s2
    80004c1a:	87efc0ef          	jal	80000c98 <release>
  return r;
}
    80004c1e:	8526                	mv	a0,s1
    80004c20:	70a2                	ld	ra,40(sp)
    80004c22:	7402                	ld	s0,32(sp)
    80004c24:	64e2                	ld	s1,24(sp)
    80004c26:	6942                	ld	s2,16(sp)
    80004c28:	6145                	addi	sp,sp,48
    80004c2a:	8082                	ret
    80004c2c:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c2e:	0284a983          	lw	s3,40(s1)
    80004c32:	cd7fc0ef          	jal	80001908 <myproc>
    80004c36:	5904                	lw	s1,48(a0)
    80004c38:	413484b3          	sub	s1,s1,s3
    80004c3c:	0014b493          	seqz	s1,s1
    80004c40:	69a2                	ld	s3,8(sp)
    80004c42:	bfd9                	j	80004c18 <holdingsleep+0x1e>

0000000080004c44 <file_report>:
    char *op,
    struct file *f,
    int old_ref,
    int old_off,
    char *details
){
    80004c44:	df010113          	addi	sp,sp,-528
    80004c48:	20113423          	sd	ra,520(sp)
    80004c4c:	20813023          	sd	s0,512(sp)
    80004c50:	ffa6                	sd	s1,504(sp)
    80004c52:	fbca                	sd	s2,496(sp)
    80004c54:	f7ce                	sd	s3,488(sp)
    80004c56:	f3d2                	sd	s4,480(sp)
    80004c58:	efd6                	sd	s5,472(sp)
    80004c5a:	0c00                	addi	s0,sp,528
    80004c5c:	8aaa                	mv	s5,a0
    80004c5e:	84ae                	mv	s1,a1
    80004c60:	8a32                	mv	s4,a2
    80004c62:	89b6                	mv	s3,a3
    80004c64:	893a                	mv	s2,a4
    struct fs_event e;

    memset(&e, 0, sizeof(e));
    80004c66:	1c800613          	li	a2,456
    80004c6a:	4581                	li	a1,0
    80004c6c:	df840513          	addi	a0,s0,-520
    80004c70:	864fc0ef          	jal	80000cd4 <memset>

    e.ticks = ticks;
    80004c74:	00004797          	auipc	a5,0x4
    80004c78:	4747a783          	lw	a5,1140(a5) # 800090e8 <ticks>
    80004c7c:	e0f42023          	sw	a5,-512(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    80004c80:	c89fc0ef          	jal	80001908 <myproc>
    80004c84:	4781                	li	a5,0
    80004c86:	c501                	beqz	a0,80004c8e <file_report+0x4a>
    80004c88:	c81fc0ef          	jal	80001908 <myproc>
    80004c8c:	591c                	lw	a5,48(a0)
    80004c8e:	e0f42223          	sw	a5,-508(s0)

    e.type = LAYER_FILE;
    80004c92:	479d                	li	a5,7
    80004c94:	e0f42423          	sw	a5,-504(s0)

    safestrcpy(e.op_name, op, sizeof(e.op_name));
    80004c98:	4641                	li	a2,16
    80004c9a:	85d6                	mv	a1,s5
    80004c9c:	e0c40513          	addi	a0,s0,-500
    80004ca0:	972fc0ef          	jal	80000e12 <safestrcpy>

    e.file_type = f->type;
    80004ca4:	409c                	lw	a5,0(s1)
    80004ca6:	f2f42223          	sw	a5,-220(s0)

    e.readable = f->readable;
    80004caa:	0084c783          	lbu	a5,8(s1)
    80004cae:	f2f42423          	sw	a5,-216(s0)
    e.writable = f->writable;
    80004cb2:	0094c783          	lbu	a5,9(s1)
    80004cb6:	f2f42623          	sw	a5,-212(s0)

    e.file_ref = f->ref;
    80004cba:	40dc                	lw	a5,4(s1)
    80004cbc:	f2f42823          	sw	a5,-208(s0)
    e.old_file_ref = old_ref;
    80004cc0:	f3442a23          	sw	s4,-204(s0)

    e.file_off = f->off;
    80004cc4:	509c                	lw	a5,32(s1)
    80004cc6:	f2f42c23          	sw	a5,-200(s0)
    e.old_file_off = old_off;
    80004cca:	f3342e23          	sw	s3,-196(s0)

    safestrcpy(e.details, details, sizeof(e.details));
    80004cce:	08000613          	li	a2,128
    80004cd2:	85ca                	mv	a1,s2
    80004cd4:	f4040513          	addi	a0,s0,-192
    80004cd8:	93afc0ef          	jal	80000e12 <safestrcpy>

    fslog_push(&e);
    80004cdc:	df840513          	addi	a0,s0,-520
    80004ce0:	6cd010ef          	jal	80006bac <fslog_push>
}
    80004ce4:	20813083          	ld	ra,520(sp)
    80004ce8:	20013403          	ld	s0,512(sp)
    80004cec:	74fe                	ld	s1,504(sp)
    80004cee:	795e                	ld	s2,496(sp)
    80004cf0:	79be                	ld	s3,488(sp)
    80004cf2:	7a1e                	ld	s4,480(sp)
    80004cf4:	6afe                	ld	s5,472(sp)
    80004cf6:	21010113          	addi	sp,sp,528
    80004cfa:	8082                	ret

0000000080004cfc <fileinit>:

void
fileinit(void)
{
    80004cfc:	1141                	addi	sp,sp,-16
    80004cfe:	e406                	sd	ra,8(sp)
    80004d00:	e022                	sd	s0,0(sp)
    80004d02:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004d04:	00004597          	auipc	a1,0x4
    80004d08:	fc458593          	addi	a1,a1,-60 # 80008cc8 <etext+0xcc8>
    80004d0c:	0001c517          	auipc	a0,0x1c
    80004d10:	63450513          	addi	a0,a0,1588 # 80021340 <ftable>
    80004d14:	e6dfb0ef          	jal	80000b80 <initlock>
}
    80004d18:	60a2                	ld	ra,8(sp)
    80004d1a:	6402                	ld	s0,0(sp)
    80004d1c:	0141                	addi	sp,sp,16
    80004d1e:	8082                	ret

0000000080004d20 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004d20:	1101                	addi	sp,sp,-32
    80004d22:	ec06                	sd	ra,24(sp)
    80004d24:	e822                	sd	s0,16(sp)
    80004d26:	e426                	sd	s1,8(sp)
    80004d28:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004d2a:	0001c517          	auipc	a0,0x1c
    80004d2e:	61650513          	addi	a0,a0,1558 # 80021340 <ftable>
    80004d32:	ecffb0ef          	jal	80000c00 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d36:	0001c497          	auipc	s1,0x1c
    80004d3a:	62248493          	addi	s1,s1,1570 # 80021358 <ftable+0x18>
    80004d3e:	0001d717          	auipc	a4,0x1d
    80004d42:	5ba70713          	addi	a4,a4,1466 # 800222f8 <disk>
    if(f->ref == 0){
    80004d46:	40dc                	lw	a5,4(s1)
    80004d48:	cf89                	beqz	a5,80004d62 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d4a:	02848493          	addi	s1,s1,40
    80004d4e:	fee49ce3          	bne	s1,a4,80004d46 <filealloc+0x26>
);
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004d52:	0001c517          	auipc	a0,0x1c
    80004d56:	5ee50513          	addi	a0,a0,1518 # 80021340 <ftable>
    80004d5a:	f3ffb0ef          	jal	80000c98 <release>
  return 0;
    80004d5e:	4481                	li	s1,0
    80004d60:	a035                	j	80004d8c <filealloc+0x6c>
      f->ref = 1;
    80004d62:	4785                	li	a5,1
    80004d64:	c0dc                	sw	a5,4(s1)
      file_report(
    80004d66:	00004717          	auipc	a4,0x4
    80004d6a:	f6a70713          	addi	a4,a4,-150 # 80008cd0 <etext+0xcd0>
    80004d6e:	4681                	li	a3,0
    80004d70:	4601                	li	a2,0
    80004d72:	85a6                	mv	a1,s1
    80004d74:	00004517          	auipc	a0,0x4
    80004d78:	f7c50513          	addi	a0,a0,-132 # 80008cf0 <etext+0xcf0>
    80004d7c:	ec9ff0ef          	jal	80004c44 <file_report>
      release(&ftable.lock);
    80004d80:	0001c517          	auipc	a0,0x1c
    80004d84:	5c050513          	addi	a0,a0,1472 # 80021340 <ftable>
    80004d88:	f11fb0ef          	jal	80000c98 <release>
}
    80004d8c:	8526                	mv	a0,s1
    80004d8e:	60e2                	ld	ra,24(sp)
    80004d90:	6442                	ld	s0,16(sp)
    80004d92:	64a2                	ld	s1,8(sp)
    80004d94:	6105                	addi	sp,sp,32
    80004d96:	8082                	ret

0000000080004d98 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004d98:	1101                	addi	sp,sp,-32
    80004d9a:	ec06                	sd	ra,24(sp)
    80004d9c:	e822                	sd	s0,16(sp)
    80004d9e:	e426                	sd	s1,8(sp)
    80004da0:	1000                	addi	s0,sp,32
    80004da2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004da4:	0001c517          	auipc	a0,0x1c
    80004da8:	59c50513          	addi	a0,a0,1436 # 80021340 <ftable>
    80004dac:	e55fb0ef          	jal	80000c00 <acquire>
  if(f->ref < 1)
    80004db0:	40d0                	lw	a2,4(s1)
    80004db2:	02c05d63          	blez	a2,80004dec <filedup+0x54>
    panic("filedup");
  int old_ref = f->ref;
  f->ref++;
    80004db6:	0016079b          	addiw	a5,a2,1
    80004dba:	c0dc                	sw	a5,4(s1)
  file_report(
    80004dbc:	00004717          	auipc	a4,0x4
    80004dc0:	f4c70713          	addi	a4,a4,-180 # 80008d08 <etext+0xd08>
    80004dc4:	5094                	lw	a3,32(s1)
    80004dc6:	85a6                	mv	a1,s1
    80004dc8:	00004517          	auipc	a0,0x4
    80004dcc:	f6050513          	addi	a0,a0,-160 # 80008d28 <etext+0xd28>
    80004dd0:	e75ff0ef          	jal	80004c44 <file_report>
    f,
    old_ref,
    f->off,
    "Duplicated file descriptor"
);
  release(&ftable.lock);
    80004dd4:	0001c517          	auipc	a0,0x1c
    80004dd8:	56c50513          	addi	a0,a0,1388 # 80021340 <ftable>
    80004ddc:	ebdfb0ef          	jal	80000c98 <release>
  return f;
}
    80004de0:	8526                	mv	a0,s1
    80004de2:	60e2                	ld	ra,24(sp)
    80004de4:	6442                	ld	s0,16(sp)
    80004de6:	64a2                	ld	s1,8(sp)
    80004de8:	6105                	addi	sp,sp,32
    80004dea:	8082                	ret
    panic("filedup");
    80004dec:	00004517          	auipc	a0,0x4
    80004df0:	f1450513          	addi	a0,a0,-236 # 80008d00 <etext+0xd00>
    80004df4:	a1ffb0ef          	jal	80000812 <panic>

0000000080004df8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004df8:	7139                	addi	sp,sp,-64
    80004dfa:	fc06                	sd	ra,56(sp)
    80004dfc:	f822                	sd	s0,48(sp)
    80004dfe:	f426                	sd	s1,40(sp)
    80004e00:	0080                	addi	s0,sp,64
    80004e02:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004e04:	0001c517          	auipc	a0,0x1c
    80004e08:	53c50513          	addi	a0,a0,1340 # 80021340 <ftable>
    80004e0c:	df5fb0ef          	jal	80000c00 <acquire>
  if(f->ref < 1)
    80004e10:	40d0                	lw	a2,4(s1)
    80004e12:	04c05b63          	blez	a2,80004e68 <fileclose+0x70>
    panic("fileclose");
  int old_ref = f->ref;
  if(--f->ref > 0){
    80004e16:	fff6079b          	addiw	a5,a2,-1
    80004e1a:	0007871b          	sext.w	a4,a5
    80004e1e:	c0dc                	sw	a5,4(s1)
    80004e20:	04e04e63          	bgtz	a4,80004e7c <fileclose+0x84>
    80004e24:	f04a                	sd	s2,32(sp)
    80004e26:	ec4e                	sd	s3,24(sp)
    80004e28:	e852                	sd	s4,16(sp)
    80004e2a:	e456                	sd	s5,8(sp)
    "Closing file"
);
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004e2c:	0004a903          	lw	s2,0(s1)
    80004e30:	0094ca83          	lbu	s5,9(s1)
    80004e34:	0104ba03          	ld	s4,16(s1)
    80004e38:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004e3c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004e40:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004e44:	0001c517          	auipc	a0,0x1c
    80004e48:	4fc50513          	addi	a0,a0,1276 # 80021340 <ftable>
    80004e4c:	e4dfb0ef          	jal	80000c98 <release>

  if(ff.type == FD_PIPE){
    80004e50:	4785                	li	a5,1
    80004e52:	04f90c63          	beq	s2,a5,80004eaa <fileclose+0xb2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004e56:	3979                	addiw	s2,s2,-2
    80004e58:	4785                	li	a5,1
    80004e5a:	0727f163          	bgeu	a5,s2,80004ebc <fileclose+0xc4>
    80004e5e:	7902                	ld	s2,32(sp)
    80004e60:	69e2                	ld	s3,24(sp)
    80004e62:	6a42                	ld	s4,16(sp)
    80004e64:	6aa2                	ld	s5,8(sp)
    80004e66:	a82d                	j	80004ea0 <fileclose+0xa8>
    80004e68:	f04a                	sd	s2,32(sp)
    80004e6a:	ec4e                	sd	s3,24(sp)
    80004e6c:	e852                	sd	s4,16(sp)
    80004e6e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004e70:	00004517          	auipc	a0,0x4
    80004e74:	ec850513          	addi	a0,a0,-312 # 80008d38 <etext+0xd38>
    80004e78:	99bfb0ef          	jal	80000812 <panic>
    file_report(
    80004e7c:	00004717          	auipc	a4,0x4
    80004e80:	ecc70713          	addi	a4,a4,-308 # 80008d48 <etext+0xd48>
    80004e84:	5094                	lw	a3,32(s1)
    80004e86:	85a6                	mv	a1,s1
    80004e88:	00004517          	auipc	a0,0x4
    80004e8c:	ed050513          	addi	a0,a0,-304 # 80008d58 <etext+0xd58>
    80004e90:	db5ff0ef          	jal	80004c44 <file_report>
    release(&ftable.lock);
    80004e94:	0001c517          	auipc	a0,0x1c
    80004e98:	4ac50513          	addi	a0,a0,1196 # 80021340 <ftable>
    80004e9c:	dfdfb0ef          	jal	80000c98 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004ea0:	70e2                	ld	ra,56(sp)
    80004ea2:	7442                	ld	s0,48(sp)
    80004ea4:	74a2                	ld	s1,40(sp)
    80004ea6:	6121                	addi	sp,sp,64
    80004ea8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004eaa:	85d6                	mv	a1,s5
    80004eac:	8552                	mv	a0,s4
    80004eae:	386000ef          	jal	80005234 <pipeclose>
    80004eb2:	7902                	ld	s2,32(sp)
    80004eb4:	69e2                	ld	s3,24(sp)
    80004eb6:	6a42                	ld	s4,16(sp)
    80004eb8:	6aa2                	ld	s5,8(sp)
    80004eba:	b7dd                	j	80004ea0 <fileclose+0xa8>
    begin_op();
    80004ebc:	82fff0ef          	jal	800046ea <begin_op>
    iput(ff.ip);
    80004ec0:	854e                	mv	a0,s3
    80004ec2:	b6ffe0ef          	jal	80003a30 <iput>
    end_op();
    80004ec6:	943ff0ef          	jal	80004808 <end_op>
    80004eca:	7902                	ld	s2,32(sp)
    80004ecc:	69e2                	ld	s3,24(sp)
    80004ece:	6a42                	ld	s4,16(sp)
    80004ed0:	6aa2                	ld	s5,8(sp)
    80004ed2:	b7f9                	j	80004ea0 <fileclose+0xa8>

0000000080004ed4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004ed4:	715d                	addi	sp,sp,-80
    80004ed6:	e486                	sd	ra,72(sp)
    80004ed8:	e0a2                	sd	s0,64(sp)
    80004eda:	fc26                	sd	s1,56(sp)
    80004edc:	f44e                	sd	s3,40(sp)
    80004ede:	0880                	addi	s0,sp,80
    80004ee0:	84aa                	mv	s1,a0
    80004ee2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ee4:	a25fc0ef          	jal	80001908 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ee8:	409c                	lw	a5,0(s1)
    80004eea:	37f9                	addiw	a5,a5,-2
    80004eec:	4705                	li	a4,1
    80004eee:	04f76063          	bltu	a4,a5,80004f2e <filestat+0x5a>
    80004ef2:	f84a                	sd	s2,48(sp)
    80004ef4:	892a                	mv	s2,a0
    ilock(f->ip);
    80004ef6:	6c88                	ld	a0,24(s1)
    80004ef8:	929fe0ef          	jal	80003820 <ilock>
    stati(f->ip, &st);
    80004efc:	fb840593          	addi	a1,s0,-72
    80004f00:	6c88                	ld	a0,24(s1)
    80004f02:	d57fe0ef          	jal	80003c58 <stati>
    iunlock(f->ip);
    80004f06:	6c88                	ld	a0,24(s1)
    80004f08:	a0bfe0ef          	jal	80003912 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004f0c:	46e1                	li	a3,24
    80004f0e:	fb840613          	addi	a2,s0,-72
    80004f12:	85ce                	mv	a1,s3
    80004f14:	05093503          	ld	a0,80(s2)
    80004f18:	f04fc0ef          	jal	8000161c <copyout>
    80004f1c:	41f5551b          	sraiw	a0,a0,0x1f
    80004f20:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004f22:	60a6                	ld	ra,72(sp)
    80004f24:	6406                	ld	s0,64(sp)
    80004f26:	74e2                	ld	s1,56(sp)
    80004f28:	79a2                	ld	s3,40(sp)
    80004f2a:	6161                	addi	sp,sp,80
    80004f2c:	8082                	ret
  return -1;
    80004f2e:	557d                	li	a0,-1
    80004f30:	bfcd                	j	80004f22 <filestat+0x4e>

0000000080004f32 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004f32:	7179                	addi	sp,sp,-48
    80004f34:	f406                	sd	ra,40(sp)
    80004f36:	f022                	sd	s0,32(sp)
    80004f38:	e84a                	sd	s2,16(sp)
    80004f3a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004f3c:	00854783          	lbu	a5,8(a0)
    80004f40:	cfdd                	beqz	a5,80004ffe <fileread+0xcc>
    80004f42:	ec26                	sd	s1,24(sp)
    80004f44:	e44e                	sd	s3,8(sp)
    80004f46:	84aa                	mv	s1,a0
    80004f48:	89ae                	mv	s3,a1
    80004f4a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f4c:	411c                	lw	a5,0(a0)
    80004f4e:	4705                	li	a4,1
    80004f50:	06e78463          	beq	a5,a4,80004fb8 <fileread+0x86>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f54:	470d                	li	a4,3
    80004f56:	06e78863          	beq	a5,a4,80004fc6 <fileread+0x94>
    80004f5a:	e052                	sd	s4,0(sp)
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f5c:	4709                	li	a4,2
    80004f5e:	08e79a63          	bne	a5,a4,80004ff2 <fileread+0xc0>
    ilock(f->ip);
    80004f62:	6d08                	ld	a0,24(a0)
    80004f64:	8bdfe0ef          	jal	80003820 <ilock>
    int old_off = f->off;
    80004f68:	5094                	lw	a3,32(s1)
    80004f6a:	00068a1b          	sext.w	s4,a3

    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004f6e:	874a                	mv	a4,s2
    80004f70:	864e                	mv	a2,s3
    80004f72:	4585                	li	a1,1
    80004f74:	6c88                	ld	a0,24(s1)
    80004f76:	d0dfe0ef          	jal	80003c82 <readi>
    80004f7a:	892a                	mv	s2,a0
    80004f7c:	00a05563          	blez	a0,80004f86 <fileread+0x54>
   
    f->off += r;
    80004f80:	509c                	lw	a5,32(s1)
    80004f82:	9fa9                	addw	a5,a5,a0
    80004f84:	d09c                	sw	a5,32(s1)
    file_report(
    80004f86:	00004717          	auipc	a4,0x4
    80004f8a:	de270713          	addi	a4,a4,-542 # 80008d68 <etext+0xd68>
    80004f8e:	86d2                	mv	a3,s4
    80004f90:	40d0                	lw	a2,4(s1)
    80004f92:	85a6                	mv	a1,s1
    80004f94:	00004517          	auipc	a0,0x4
    80004f98:	de450513          	addi	a0,a0,-540 # 80008d78 <etext+0xd78>
    80004f9c:	ca9ff0ef          	jal	80004c44 <file_report>
    f,
    f->ref,
    old_off,
    "Read from file"
);
    iunlock(f->ip);
    80004fa0:	6c88                	ld	a0,24(s1)
    80004fa2:	971fe0ef          	jal	80003912 <iunlock>
    80004fa6:	64e2                	ld	s1,24(sp)
    80004fa8:	69a2                	ld	s3,8(sp)
    80004faa:	6a02                	ld	s4,0(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004fac:	854a                	mv	a0,s2
    80004fae:	70a2                	ld	ra,40(sp)
    80004fb0:	7402                	ld	s0,32(sp)
    80004fb2:	6942                	ld	s2,16(sp)
    80004fb4:	6145                	addi	sp,sp,48
    80004fb6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004fb8:	6908                	ld	a0,16(a0)
    80004fba:	3b6000ef          	jal	80005370 <piperead>
    80004fbe:	892a                	mv	s2,a0
    80004fc0:	64e2                	ld	s1,24(sp)
    80004fc2:	69a2                	ld	s3,8(sp)
    80004fc4:	b7e5                	j	80004fac <fileread+0x7a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004fc6:	02451783          	lh	a5,36(a0)
    80004fca:	03079693          	slli	a3,a5,0x30
    80004fce:	92c1                	srli	a3,a3,0x30
    80004fd0:	4725                	li	a4,9
    80004fd2:	02d76863          	bltu	a4,a3,80005002 <fileread+0xd0>
    80004fd6:	0792                	slli	a5,a5,0x4
    80004fd8:	0001c717          	auipc	a4,0x1c
    80004fdc:	2c870713          	addi	a4,a4,712 # 800212a0 <devsw>
    80004fe0:	97ba                	add	a5,a5,a4
    80004fe2:	639c                	ld	a5,0(a5)
    80004fe4:	c39d                	beqz	a5,8000500a <fileread+0xd8>
    r = devsw[f->major].read(1, addr, n);
    80004fe6:	4505                	li	a0,1
    80004fe8:	9782                	jalr	a5
    80004fea:	892a                	mv	s2,a0
    80004fec:	64e2                	ld	s1,24(sp)
    80004fee:	69a2                	ld	s3,8(sp)
    80004ff0:	bf75                	j	80004fac <fileread+0x7a>
    panic("fileread");
    80004ff2:	00004517          	auipc	a0,0x4
    80004ff6:	d9650513          	addi	a0,a0,-618 # 80008d88 <etext+0xd88>
    80004ffa:	819fb0ef          	jal	80000812 <panic>
    return -1;
    80004ffe:	597d                	li	s2,-1
    80005000:	b775                	j	80004fac <fileread+0x7a>
      return -1;
    80005002:	597d                	li	s2,-1
    80005004:	64e2                	ld	s1,24(sp)
    80005006:	69a2                	ld	s3,8(sp)
    80005008:	b755                	j	80004fac <fileread+0x7a>
    8000500a:	597d                	li	s2,-1
    8000500c:	64e2                	ld	s1,24(sp)
    8000500e:	69a2                	ld	s3,8(sp)
    80005010:	bf71                	j	80004fac <fileread+0x7a>

0000000080005012 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80005012:	00954783          	lbu	a5,9(a0)
    80005016:	14078263          	beqz	a5,8000515a <filewrite+0x148>
{
    8000501a:	7159                	addi	sp,sp,-112
    8000501c:	f486                	sd	ra,104(sp)
    8000501e:	f0a2                	sd	s0,96(sp)
    80005020:	eca6                	sd	s1,88(sp)
    80005022:	e0d2                	sd	s4,64(sp)
    80005024:	f45e                	sd	s7,40(sp)
    80005026:	1880                	addi	s0,sp,112
    80005028:	84aa                	mv	s1,a0
    8000502a:	8bae                	mv	s7,a1
    8000502c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000502e:	411c                	lw	a5,0(a0)
    80005030:	4705                	li	a4,1
    80005032:	04e78263          	beq	a5,a4,80005076 <filewrite+0x64>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005036:	470d                	li	a4,3
    80005038:	04e78363          	beq	a5,a4,8000507e <filewrite+0x6c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000503c:	4709                	li	a4,2
    8000503e:	10e79063          	bne	a5,a4,8000513e <filewrite+0x12c>
    80005042:	e4ce                	sd	s3,72(sp)
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    int old_off;
    while(i < n){
    80005044:	0cc05963          	blez	a2,80005116 <filewrite+0x104>
    80005048:	e8ca                	sd	s2,80(sp)
    8000504a:	fc56                	sd	s5,56(sp)
    8000504c:	f85a                	sd	s6,48(sp)
    8000504e:	f062                	sd	s8,32(sp)
    80005050:	ec66                	sd	s9,24(sp)
    80005052:	e86a                	sd	s10,16(sp)
    80005054:	e46e                	sd	s11,8(sp)
    int i = 0;
    80005056:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80005058:	6c05                	lui	s8,0x1
    8000505a:	c00c0c13          	addi	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000505e:	6d85                	lui	s11,0x1
    80005060:	c00d8d9b          	addiw	s11,s11,-1024 # c00 <_entry-0x7ffff400>
      begin_op();
      ilock(f->ip);
      old_off = f->off;
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
        f->off += r;
      file_report(
    80005064:	00004d17          	auipc	s10,0x4
    80005068:	d34d0d13          	addi	s10,s10,-716 # 80008d98 <etext+0xd98>
    8000506c:	00004c97          	auipc	s9,0x4
    80005070:	d3cc8c93          	addi	s9,s9,-708 # 80008da8 <etext+0xda8>
    80005074:	a049                	j	800050f6 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005076:	6908                	ld	a0,16(a0)
    80005078:	214000ef          	jal	8000528c <pipewrite>
    8000507c:	a855                	j	80005130 <filewrite+0x11e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000507e:	02451783          	lh	a5,36(a0)
    80005082:	03079693          	slli	a3,a5,0x30
    80005086:	92c1                	srli	a3,a3,0x30
    80005088:	4725                	li	a4,9
    8000508a:	0cd76a63          	bltu	a4,a3,8000515e <filewrite+0x14c>
    8000508e:	0792                	slli	a5,a5,0x4
    80005090:	0001c717          	auipc	a4,0x1c
    80005094:	21070713          	addi	a4,a4,528 # 800212a0 <devsw>
    80005098:	97ba                	add	a5,a5,a4
    8000509a:	679c                	ld	a5,8(a5)
    8000509c:	c3f9                	beqz	a5,80005162 <filewrite+0x150>
    ret = devsw[f->major].write(1, addr, n);
    8000509e:	4505                	li	a0,1
    800050a0:	9782                	jalr	a5
    800050a2:	a079                	j	80005130 <filewrite+0x11e>
      if(n1 > max)
    800050a4:	00090a9b          	sext.w	s5,s2
      begin_op();
    800050a8:	e42ff0ef          	jal	800046ea <begin_op>
      ilock(f->ip);
    800050ac:	6c88                	ld	a0,24(s1)
    800050ae:	f72fe0ef          	jal	80003820 <ilock>
      old_off = f->off;
    800050b2:	5094                	lw	a3,32(s1)
    800050b4:	00068b1b          	sext.w	s6,a3
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800050b8:	8756                	mv	a4,s5
    800050ba:	01798633          	add	a2,s3,s7
    800050be:	4585                	li	a1,1
    800050c0:	6c88                	ld	a0,24(s1)
    800050c2:	cf1fe0ef          	jal	80003db2 <writei>
    800050c6:	892a                	mv	s2,a0
    800050c8:	00a05563          	blez	a0,800050d2 <filewrite+0xc0>
        f->off += r;
    800050cc:	509c                	lw	a5,32(s1)
    800050ce:	9fa9                	addw	a5,a5,a0
    800050d0:	d09c                	sw	a5,32(s1)
      file_report(
    800050d2:	876a                	mv	a4,s10
    800050d4:	86da                	mv	a3,s6
    800050d6:	40d0                	lw	a2,4(s1)
    800050d8:	85a6                	mv	a1,s1
    800050da:	8566                	mv	a0,s9
    800050dc:	b69ff0ef          	jal	80004c44 <file_report>
    f,
    f->ref,
    old_off,
    "Write to file"
);
      iunlock(f->ip);
    800050e0:	6c88                	ld	a0,24(s1)
    800050e2:	831fe0ef          	jal	80003912 <iunlock>
      end_op();
    800050e6:	f22ff0ef          	jal	80004808 <end_op>

      if(r != n1){
    800050ea:	032a9863          	bne	s5,s2,8000511a <filewrite+0x108>
        // error from writei
        break;
      }
      i += r;
    800050ee:	013909bb          	addw	s3,s2,s3
    while(i < n){
    800050f2:	0149da63          	bge	s3,s4,80005106 <filewrite+0xf4>
      int n1 = n - i;
    800050f6:	413a093b          	subw	s2,s4,s3
      if(n1 > max)
    800050fa:	0009079b          	sext.w	a5,s2
    800050fe:	fafc53e3          	bge	s8,a5,800050a4 <filewrite+0x92>
    80005102:	896e                	mv	s2,s11
    80005104:	b745                	j	800050a4 <filewrite+0x92>
    80005106:	6946                	ld	s2,80(sp)
    80005108:	7ae2                	ld	s5,56(sp)
    8000510a:	7b42                	ld	s6,48(sp)
    8000510c:	7c02                	ld	s8,32(sp)
    8000510e:	6ce2                	ld	s9,24(sp)
    80005110:	6d42                	ld	s10,16(sp)
    80005112:	6da2                	ld	s11,8(sp)
    80005114:	a811                	j	80005128 <filewrite+0x116>
    int i = 0;
    80005116:	4981                	li	s3,0
    80005118:	a801                	j	80005128 <filewrite+0x116>
    8000511a:	6946                	ld	s2,80(sp)
    8000511c:	7ae2                	ld	s5,56(sp)
    8000511e:	7b42                	ld	s6,48(sp)
    80005120:	7c02                	ld	s8,32(sp)
    80005122:	6ce2                	ld	s9,24(sp)
    80005124:	6d42                	ld	s10,16(sp)
    80005126:	6da2                	ld	s11,8(sp)
    }
    ret = (i == n ? n : -1);
    80005128:	033a1f63          	bne	s4,s3,80005166 <filewrite+0x154>
    8000512c:	8552                	mv	a0,s4
    8000512e:	69a6                	ld	s3,72(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005130:	70a6                	ld	ra,104(sp)
    80005132:	7406                	ld	s0,96(sp)
    80005134:	64e6                	ld	s1,88(sp)
    80005136:	6a06                	ld	s4,64(sp)
    80005138:	7ba2                	ld	s7,40(sp)
    8000513a:	6165                	addi	sp,sp,112
    8000513c:	8082                	ret
    8000513e:	e8ca                	sd	s2,80(sp)
    80005140:	e4ce                	sd	s3,72(sp)
    80005142:	fc56                	sd	s5,56(sp)
    80005144:	f85a                	sd	s6,48(sp)
    80005146:	f062                	sd	s8,32(sp)
    80005148:	ec66                	sd	s9,24(sp)
    8000514a:	e86a                	sd	s10,16(sp)
    8000514c:	e46e                	sd	s11,8(sp)
    panic("filewrite");
    8000514e:	00004517          	auipc	a0,0x4
    80005152:	c6a50513          	addi	a0,a0,-918 # 80008db8 <etext+0xdb8>
    80005156:	ebcfb0ef          	jal	80000812 <panic>
    return -1;
    8000515a:	557d                	li	a0,-1
}
    8000515c:	8082                	ret
      return -1;
    8000515e:	557d                	li	a0,-1
    80005160:	bfc1                	j	80005130 <filewrite+0x11e>
    80005162:	557d                	li	a0,-1
    80005164:	b7f1                	j	80005130 <filewrite+0x11e>
    ret = (i == n ? n : -1);
    80005166:	557d                	li	a0,-1
    80005168:	69a6                	ld	s3,72(sp)
    8000516a:	b7d9                	j	80005130 <filewrite+0x11e>

000000008000516c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000516c:	7179                	addi	sp,sp,-48
    8000516e:	f406                	sd	ra,40(sp)
    80005170:	f022                	sd	s0,32(sp)
    80005172:	ec26                	sd	s1,24(sp)
    80005174:	e052                	sd	s4,0(sp)
    80005176:	1800                	addi	s0,sp,48
    80005178:	84aa                	mv	s1,a0
    8000517a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000517c:	0005b023          	sd	zero,0(a1)
    80005180:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005184:	b9dff0ef          	jal	80004d20 <filealloc>
    80005188:	e088                	sd	a0,0(s1)
    8000518a:	c549                	beqz	a0,80005214 <pipealloc+0xa8>
    8000518c:	b95ff0ef          	jal	80004d20 <filealloc>
    80005190:	00aa3023          	sd	a0,0(s4)
    80005194:	cd25                	beqz	a0,8000520c <pipealloc+0xa0>
    80005196:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005198:	999fb0ef          	jal	80000b30 <kalloc>
    8000519c:	892a                	mv	s2,a0
    8000519e:	c12d                	beqz	a0,80005200 <pipealloc+0x94>
    800051a0:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800051a2:	4985                	li	s3,1
    800051a4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800051a8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800051ac:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800051b0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800051b4:	00004597          	auipc	a1,0x4
    800051b8:	c1458593          	addi	a1,a1,-1004 # 80008dc8 <etext+0xdc8>
    800051bc:	9c5fb0ef          	jal	80000b80 <initlock>
  (*f0)->type = FD_PIPE;
    800051c0:	609c                	ld	a5,0(s1)
    800051c2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800051c6:	609c                	ld	a5,0(s1)
    800051c8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800051cc:	609c                	ld	a5,0(s1)
    800051ce:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800051d2:	609c                	ld	a5,0(s1)
    800051d4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800051d8:	000a3783          	ld	a5,0(s4)
    800051dc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800051e0:	000a3783          	ld	a5,0(s4)
    800051e4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800051e8:	000a3783          	ld	a5,0(s4)
    800051ec:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800051f0:	000a3783          	ld	a5,0(s4)
    800051f4:	0127b823          	sd	s2,16(a5)
  return 0;
    800051f8:	4501                	li	a0,0
    800051fa:	6942                	ld	s2,16(sp)
    800051fc:	69a2                	ld	s3,8(sp)
    800051fe:	a01d                	j	80005224 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005200:	6088                	ld	a0,0(s1)
    80005202:	c119                	beqz	a0,80005208 <pipealloc+0x9c>
    80005204:	6942                	ld	s2,16(sp)
    80005206:	a029                	j	80005210 <pipealloc+0xa4>
    80005208:	6942                	ld	s2,16(sp)
    8000520a:	a029                	j	80005214 <pipealloc+0xa8>
    8000520c:	6088                	ld	a0,0(s1)
    8000520e:	c10d                	beqz	a0,80005230 <pipealloc+0xc4>
    fileclose(*f0);
    80005210:	be9ff0ef          	jal	80004df8 <fileclose>
  if(*f1)
    80005214:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005218:	557d                	li	a0,-1
  if(*f1)
    8000521a:	c789                	beqz	a5,80005224 <pipealloc+0xb8>
    fileclose(*f1);
    8000521c:	853e                	mv	a0,a5
    8000521e:	bdbff0ef          	jal	80004df8 <fileclose>
  return -1;
    80005222:	557d                	li	a0,-1
}
    80005224:	70a2                	ld	ra,40(sp)
    80005226:	7402                	ld	s0,32(sp)
    80005228:	64e2                	ld	s1,24(sp)
    8000522a:	6a02                	ld	s4,0(sp)
    8000522c:	6145                	addi	sp,sp,48
    8000522e:	8082                	ret
  return -1;
    80005230:	557d                	li	a0,-1
    80005232:	bfcd                	j	80005224 <pipealloc+0xb8>

0000000080005234 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005234:	1101                	addi	sp,sp,-32
    80005236:	ec06                	sd	ra,24(sp)
    80005238:	e822                	sd	s0,16(sp)
    8000523a:	e426                	sd	s1,8(sp)
    8000523c:	e04a                	sd	s2,0(sp)
    8000523e:	1000                	addi	s0,sp,32
    80005240:	84aa                	mv	s1,a0
    80005242:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005244:	9bdfb0ef          	jal	80000c00 <acquire>
  if(writable){
    80005248:	02090763          	beqz	s2,80005276 <pipeclose+0x42>
    pi->writeopen = 0;
    8000524c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005250:	21848513          	addi	a0,s1,536
    80005254:	d11fc0ef          	jal	80001f64 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005258:	2204b783          	ld	a5,544(s1)
    8000525c:	e785                	bnez	a5,80005284 <pipeclose+0x50>
    release(&pi->lock);
    8000525e:	8526                	mv	a0,s1
    80005260:	a39fb0ef          	jal	80000c98 <release>
    kfree((char*)pi);
    80005264:	8526                	mv	a0,s1
    80005266:	fe8fb0ef          	jal	80000a4e <kfree>
  } else
    release(&pi->lock);
}
    8000526a:	60e2                	ld	ra,24(sp)
    8000526c:	6442                	ld	s0,16(sp)
    8000526e:	64a2                	ld	s1,8(sp)
    80005270:	6902                	ld	s2,0(sp)
    80005272:	6105                	addi	sp,sp,32
    80005274:	8082                	ret
    pi->readopen = 0;
    80005276:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000527a:	21c48513          	addi	a0,s1,540
    8000527e:	ce7fc0ef          	jal	80001f64 <wakeup>
    80005282:	bfd9                	j	80005258 <pipeclose+0x24>
    release(&pi->lock);
    80005284:	8526                	mv	a0,s1
    80005286:	a13fb0ef          	jal	80000c98 <release>
}
    8000528a:	b7c5                	j	8000526a <pipeclose+0x36>

000000008000528c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000528c:	711d                	addi	sp,sp,-96
    8000528e:	ec86                	sd	ra,88(sp)
    80005290:	e8a2                	sd	s0,80(sp)
    80005292:	e4a6                	sd	s1,72(sp)
    80005294:	e0ca                	sd	s2,64(sp)
    80005296:	fc4e                	sd	s3,56(sp)
    80005298:	f852                	sd	s4,48(sp)
    8000529a:	f456                	sd	s5,40(sp)
    8000529c:	1080                	addi	s0,sp,96
    8000529e:	84aa                	mv	s1,a0
    800052a0:	8aae                	mv	s5,a1
    800052a2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800052a4:	e64fc0ef          	jal	80001908 <myproc>
    800052a8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800052aa:	8526                	mv	a0,s1
    800052ac:	955fb0ef          	jal	80000c00 <acquire>
  while(i < n){
    800052b0:	0b405a63          	blez	s4,80005364 <pipewrite+0xd8>
    800052b4:	f05a                	sd	s6,32(sp)
    800052b6:	ec5e                	sd	s7,24(sp)
    800052b8:	e862                	sd	s8,16(sp)
  int i = 0;
    800052ba:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800052bc:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800052be:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800052c2:	21c48b93          	addi	s7,s1,540
    800052c6:	a81d                	j	800052fc <pipewrite+0x70>
      release(&pi->lock);
    800052c8:	8526                	mv	a0,s1
    800052ca:	9cffb0ef          	jal	80000c98 <release>
      return -1;
    800052ce:	597d                	li	s2,-1
    800052d0:	7b02                	ld	s6,32(sp)
    800052d2:	6be2                	ld	s7,24(sp)
    800052d4:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800052d6:	854a                	mv	a0,s2
    800052d8:	60e6                	ld	ra,88(sp)
    800052da:	6446                	ld	s0,80(sp)
    800052dc:	64a6                	ld	s1,72(sp)
    800052de:	6906                	ld	s2,64(sp)
    800052e0:	79e2                	ld	s3,56(sp)
    800052e2:	7a42                	ld	s4,48(sp)
    800052e4:	7aa2                	ld	s5,40(sp)
    800052e6:	6125                	addi	sp,sp,96
    800052e8:	8082                	ret
      wakeup(&pi->nread);
    800052ea:	8562                	mv	a0,s8
    800052ec:	c79fc0ef          	jal	80001f64 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800052f0:	85a6                	mv	a1,s1
    800052f2:	855e                	mv	a0,s7
    800052f4:	c25fc0ef          	jal	80001f18 <sleep>
  while(i < n){
    800052f8:	05495b63          	bge	s2,s4,8000534e <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800052fc:	2204a783          	lw	a5,544(s1)
    80005300:	d7e1                	beqz	a5,800052c8 <pipewrite+0x3c>
    80005302:	854e                	mv	a0,s3
    80005304:	e4dfc0ef          	jal	80002150 <killed>
    80005308:	f161                	bnez	a0,800052c8 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000530a:	2184a783          	lw	a5,536(s1)
    8000530e:	21c4a703          	lw	a4,540(s1)
    80005312:	2007879b          	addiw	a5,a5,512
    80005316:	fcf70ae3          	beq	a4,a5,800052ea <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000531a:	4685                	li	a3,1
    8000531c:	01590633          	add	a2,s2,s5
    80005320:	faf40593          	addi	a1,s0,-81
    80005324:	0509b503          	ld	a0,80(s3)
    80005328:	bd8fc0ef          	jal	80001700 <copyin>
    8000532c:	03650e63          	beq	a0,s6,80005368 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005330:	21c4a783          	lw	a5,540(s1)
    80005334:	0017871b          	addiw	a4,a5,1
    80005338:	20e4ae23          	sw	a4,540(s1)
    8000533c:	1ff7f793          	andi	a5,a5,511
    80005340:	97a6                	add	a5,a5,s1
    80005342:	faf44703          	lbu	a4,-81(s0)
    80005346:	00e78c23          	sb	a4,24(a5)
      i++;
    8000534a:	2905                	addiw	s2,s2,1
    8000534c:	b775                	j	800052f8 <pipewrite+0x6c>
    8000534e:	7b02                	ld	s6,32(sp)
    80005350:	6be2                	ld	s7,24(sp)
    80005352:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80005354:	21848513          	addi	a0,s1,536
    80005358:	c0dfc0ef          	jal	80001f64 <wakeup>
  release(&pi->lock);
    8000535c:	8526                	mv	a0,s1
    8000535e:	93bfb0ef          	jal	80000c98 <release>
  return i;
    80005362:	bf95                	j	800052d6 <pipewrite+0x4a>
  int i = 0;
    80005364:	4901                	li	s2,0
    80005366:	b7fd                	j	80005354 <pipewrite+0xc8>
    80005368:	7b02                	ld	s6,32(sp)
    8000536a:	6be2                	ld	s7,24(sp)
    8000536c:	6c42                	ld	s8,16(sp)
    8000536e:	b7dd                	j	80005354 <pipewrite+0xc8>

0000000080005370 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005370:	715d                	addi	sp,sp,-80
    80005372:	e486                	sd	ra,72(sp)
    80005374:	e0a2                	sd	s0,64(sp)
    80005376:	fc26                	sd	s1,56(sp)
    80005378:	f84a                	sd	s2,48(sp)
    8000537a:	f44e                	sd	s3,40(sp)
    8000537c:	f052                	sd	s4,32(sp)
    8000537e:	ec56                	sd	s5,24(sp)
    80005380:	0880                	addi	s0,sp,80
    80005382:	84aa                	mv	s1,a0
    80005384:	892e                	mv	s2,a1
    80005386:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005388:	d80fc0ef          	jal	80001908 <myproc>
    8000538c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000538e:	8526                	mv	a0,s1
    80005390:	871fb0ef          	jal	80000c00 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005394:	2184a703          	lw	a4,536(s1)
    80005398:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000539c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053a0:	02f71563          	bne	a4,a5,800053ca <piperead+0x5a>
    800053a4:	2244a783          	lw	a5,548(s1)
    800053a8:	cb85                	beqz	a5,800053d8 <piperead+0x68>
    if(killed(pr)){
    800053aa:	8552                	mv	a0,s4
    800053ac:	da5fc0ef          	jal	80002150 <killed>
    800053b0:	ed19                	bnez	a0,800053ce <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800053b2:	85a6                	mv	a1,s1
    800053b4:	854e                	mv	a0,s3
    800053b6:	b63fc0ef          	jal	80001f18 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053ba:	2184a703          	lw	a4,536(s1)
    800053be:	21c4a783          	lw	a5,540(s1)
    800053c2:	fef701e3          	beq	a4,a5,800053a4 <piperead+0x34>
    800053c6:	e85a                	sd	s6,16(sp)
    800053c8:	a809                	j	800053da <piperead+0x6a>
    800053ca:	e85a                	sd	s6,16(sp)
    800053cc:	a039                	j	800053da <piperead+0x6a>
      release(&pi->lock);
    800053ce:	8526                	mv	a0,s1
    800053d0:	8c9fb0ef          	jal	80000c98 <release>
      return -1;
    800053d4:	59fd                	li	s3,-1
    800053d6:	a8b9                	j	80005434 <piperead+0xc4>
    800053d8:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053da:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800053dc:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053de:	05505363          	blez	s5,80005424 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    800053e2:	2184a783          	lw	a5,536(s1)
    800053e6:	21c4a703          	lw	a4,540(s1)
    800053ea:	02f70d63          	beq	a4,a5,80005424 <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    800053ee:	1ff7f793          	andi	a5,a5,511
    800053f2:	97a6                	add	a5,a5,s1
    800053f4:	0187c783          	lbu	a5,24(a5)
    800053f8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800053fc:	4685                	li	a3,1
    800053fe:	fbf40613          	addi	a2,s0,-65
    80005402:	85ca                	mv	a1,s2
    80005404:	050a3503          	ld	a0,80(s4)
    80005408:	a14fc0ef          	jal	8000161c <copyout>
    8000540c:	03650e63          	beq	a0,s6,80005448 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80005410:	2184a783          	lw	a5,536(s1)
    80005414:	2785                	addiw	a5,a5,1
    80005416:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000541a:	2985                	addiw	s3,s3,1
    8000541c:	0905                	addi	s2,s2,1
    8000541e:	fd3a92e3          	bne	s5,s3,800053e2 <piperead+0x72>
    80005422:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005424:	21c48513          	addi	a0,s1,540
    80005428:	b3dfc0ef          	jal	80001f64 <wakeup>
  release(&pi->lock);
    8000542c:	8526                	mv	a0,s1
    8000542e:	86bfb0ef          	jal	80000c98 <release>
    80005432:	6b42                	ld	s6,16(sp)
  return i;
}
    80005434:	854e                	mv	a0,s3
    80005436:	60a6                	ld	ra,72(sp)
    80005438:	6406                	ld	s0,64(sp)
    8000543a:	74e2                	ld	s1,56(sp)
    8000543c:	7942                	ld	s2,48(sp)
    8000543e:	79a2                	ld	s3,40(sp)
    80005440:	7a02                	ld	s4,32(sp)
    80005442:	6ae2                	ld	s5,24(sp)
    80005444:	6161                	addi	sp,sp,80
    80005446:	8082                	ret
      if(i == 0)
    80005448:	fc099ee3          	bnez	s3,80005424 <piperead+0xb4>
        i = -1;
    8000544c:	89aa                	mv	s3,a0
    8000544e:	bfd9                	j	80005424 <piperead+0xb4>

0000000080005450 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80005450:	1141                	addi	sp,sp,-16
    80005452:	e422                	sd	s0,8(sp)
    80005454:	0800                	addi	s0,sp,16
    80005456:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005458:	8905                	andi	a0,a0,1
    8000545a:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000545c:	8b89                	andi	a5,a5,2
    8000545e:	c399                	beqz	a5,80005464 <flags2perm+0x14>
      perm |= PTE_W;
    80005460:	00456513          	ori	a0,a0,4
    return perm;
}
    80005464:	6422                	ld	s0,8(sp)
    80005466:	0141                	addi	sp,sp,16
    80005468:	8082                	ret

000000008000546a <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000546a:	df010113          	addi	sp,sp,-528
    8000546e:	20113423          	sd	ra,520(sp)
    80005472:	20813023          	sd	s0,512(sp)
    80005476:	ffa6                	sd	s1,504(sp)
    80005478:	fbca                	sd	s2,496(sp)
    8000547a:	0c00                	addi	s0,sp,528
    8000547c:	892a                	mv	s2,a0
    8000547e:	dea43c23          	sd	a0,-520(s0)
    80005482:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005486:	c82fc0ef          	jal	80001908 <myproc>
    8000548a:	84aa                	mv	s1,a0

  begin_op();
    8000548c:	a5eff0ef          	jal	800046ea <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80005490:	854a                	mv	a0,s2
    80005492:	e13fe0ef          	jal	800042a4 <namei>
    80005496:	c931                	beqz	a0,800054ea <kexec+0x80>
    80005498:	f3d2                	sd	s4,480(sp)
    8000549a:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000549c:	b84fe0ef          	jal	80003820 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800054a0:	04000713          	li	a4,64
    800054a4:	4681                	li	a3,0
    800054a6:	e5040613          	addi	a2,s0,-432
    800054aa:	4581                	li	a1,0
    800054ac:	8552                	mv	a0,s4
    800054ae:	fd4fe0ef          	jal	80003c82 <readi>
    800054b2:	04000793          	li	a5,64
    800054b6:	00f51a63          	bne	a0,a5,800054ca <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800054ba:	e5042703          	lw	a4,-432(s0)
    800054be:	464c47b7          	lui	a5,0x464c4
    800054c2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800054c6:	02f70663          	beq	a4,a5,800054f2 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800054ca:	8552                	mv	a0,s4
    800054cc:	e30fe0ef          	jal	80003afc <iunlockput>
    end_op();
    800054d0:	b38ff0ef          	jal	80004808 <end_op>
  }
  return -1;
    800054d4:	557d                	li	a0,-1
    800054d6:	7a1e                	ld	s4,480(sp)
}
    800054d8:	20813083          	ld	ra,520(sp)
    800054dc:	20013403          	ld	s0,512(sp)
    800054e0:	74fe                	ld	s1,504(sp)
    800054e2:	795e                	ld	s2,496(sp)
    800054e4:	21010113          	addi	sp,sp,528
    800054e8:	8082                	ret
    end_op();
    800054ea:	b1eff0ef          	jal	80004808 <end_op>
    return -1;
    800054ee:	557d                	li	a0,-1
    800054f0:	b7e5                	j	800054d8 <kexec+0x6e>
    800054f2:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800054f4:	8526                	mv	a0,s1
    800054f6:	d18fc0ef          	jal	80001a0e <proc_pagetable>
    800054fa:	8b2a                	mv	s6,a0
    800054fc:	2c050b63          	beqz	a0,800057d2 <kexec+0x368>
    80005500:	f7ce                	sd	s3,488(sp)
    80005502:	efd6                	sd	s5,472(sp)
    80005504:	e7de                	sd	s7,456(sp)
    80005506:	e3e2                	sd	s8,448(sp)
    80005508:	ff66                	sd	s9,440(sp)
    8000550a:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000550c:	e7042d03          	lw	s10,-400(s0)
    80005510:	e8845783          	lhu	a5,-376(s0)
    80005514:	12078963          	beqz	a5,80005646 <kexec+0x1dc>
    80005518:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000551a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000551c:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    8000551e:	6c85                	lui	s9,0x1
    80005520:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005524:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005528:	6a85                	lui	s5,0x1
    8000552a:	a085                	j	8000558a <kexec+0x120>
      panic("loadseg: address should exist");
    8000552c:	00004517          	auipc	a0,0x4
    80005530:	8a450513          	addi	a0,a0,-1884 # 80008dd0 <etext+0xdd0>
    80005534:	adefb0ef          	jal	80000812 <panic>
    if(sz - i < PGSIZE)
    80005538:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000553a:	8726                	mv	a4,s1
    8000553c:	012c06bb          	addw	a3,s8,s2
    80005540:	4581                	li	a1,0
    80005542:	8552                	mv	a0,s4
    80005544:	f3efe0ef          	jal	80003c82 <readi>
    80005548:	2501                	sext.w	a0,a0
    8000554a:	24a49a63          	bne	s1,a0,8000579e <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    8000554e:	012a893b          	addw	s2,s5,s2
    80005552:	03397363          	bgeu	s2,s3,80005578 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80005556:	02091593          	slli	a1,s2,0x20
    8000555a:	9181                	srli	a1,a1,0x20
    8000555c:	95de                	add	a1,a1,s7
    8000555e:	855a                	mv	a0,s6
    80005560:	a8bfb0ef          	jal	80000fea <walkaddr>
    80005564:	862a                	mv	a2,a0
    if(pa == 0)
    80005566:	d179                	beqz	a0,8000552c <kexec+0xc2>
    if(sz - i < PGSIZE)
    80005568:	412984bb          	subw	s1,s3,s2
    8000556c:	0004879b          	sext.w	a5,s1
    80005570:	fcfcf4e3          	bgeu	s9,a5,80005538 <kexec+0xce>
    80005574:	84d6                	mv	s1,s5
    80005576:	b7c9                	j	80005538 <kexec+0xce>
    sz = sz1;
    80005578:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000557c:	2d85                	addiw	s11,s11,1
    8000557e:	038d0d1b          	addiw	s10,s10,56
    80005582:	e8845783          	lhu	a5,-376(s0)
    80005586:	08fdd063          	bge	s11,a5,80005606 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000558a:	2d01                	sext.w	s10,s10
    8000558c:	03800713          	li	a4,56
    80005590:	86ea                	mv	a3,s10
    80005592:	e1840613          	addi	a2,s0,-488
    80005596:	4581                	li	a1,0
    80005598:	8552                	mv	a0,s4
    8000559a:	ee8fe0ef          	jal	80003c82 <readi>
    8000559e:	03800793          	li	a5,56
    800055a2:	1cf51663          	bne	a0,a5,8000576e <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800055a6:	e1842783          	lw	a5,-488(s0)
    800055aa:	4705                	li	a4,1
    800055ac:	fce798e3          	bne	a5,a4,8000557c <kexec+0x112>
    if(ph.memsz < ph.filesz)
    800055b0:	e4043483          	ld	s1,-448(s0)
    800055b4:	e3843783          	ld	a5,-456(s0)
    800055b8:	1af4ef63          	bltu	s1,a5,80005776 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800055bc:	e2843783          	ld	a5,-472(s0)
    800055c0:	94be                	add	s1,s1,a5
    800055c2:	1af4ee63          	bltu	s1,a5,8000577e <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800055c6:	df043703          	ld	a4,-528(s0)
    800055ca:	8ff9                	and	a5,a5,a4
    800055cc:	1a079d63          	bnez	a5,80005786 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800055d0:	e1c42503          	lw	a0,-484(s0)
    800055d4:	e7dff0ef          	jal	80005450 <flags2perm>
    800055d8:	86aa                	mv	a3,a0
    800055da:	8626                	mv	a2,s1
    800055dc:	85ca                	mv	a1,s2
    800055de:	855a                	mv	a0,s6
    800055e0:	ce3fb0ef          	jal	800012c2 <uvmalloc>
    800055e4:	e0a43423          	sd	a0,-504(s0)
    800055e8:	1a050363          	beqz	a0,8000578e <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800055ec:	e2843b83          	ld	s7,-472(s0)
    800055f0:	e2042c03          	lw	s8,-480(s0)
    800055f4:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800055f8:	00098463          	beqz	s3,80005600 <kexec+0x196>
    800055fc:	4901                	li	s2,0
    800055fe:	bfa1                	j	80005556 <kexec+0xec>
    sz = sz1;
    80005600:	e0843903          	ld	s2,-504(s0)
    80005604:	bfa5                	j	8000557c <kexec+0x112>
    80005606:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80005608:	8552                	mv	a0,s4
    8000560a:	cf2fe0ef          	jal	80003afc <iunlockput>
  end_op();
    8000560e:	9faff0ef          	jal	80004808 <end_op>
  p = myproc();
    80005612:	af6fc0ef          	jal	80001908 <myproc>
    80005616:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005618:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000561c:	6985                	lui	s3,0x1
    8000561e:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005620:	99ca                	add	s3,s3,s2
    80005622:	77fd                	lui	a5,0xfffff
    80005624:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005628:	4691                	li	a3,4
    8000562a:	6609                	lui	a2,0x2
    8000562c:	964e                	add	a2,a2,s3
    8000562e:	85ce                	mv	a1,s3
    80005630:	855a                	mv	a0,s6
    80005632:	c91fb0ef          	jal	800012c2 <uvmalloc>
    80005636:	892a                	mv	s2,a0
    80005638:	e0a43423          	sd	a0,-504(s0)
    8000563c:	e519                	bnez	a0,8000564a <kexec+0x1e0>
  if(pagetable)
    8000563e:	e1343423          	sd	s3,-504(s0)
    80005642:	4a01                	li	s4,0
    80005644:	aab1                	j	800057a0 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005646:	4901                	li	s2,0
    80005648:	b7c1                	j	80005608 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000564a:	75f9                	lui	a1,0xffffe
    8000564c:	95aa                	add	a1,a1,a0
    8000564e:	855a                	mv	a0,s6
    80005650:	e49fb0ef          	jal	80001498 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80005654:	7bfd                	lui	s7,0xfffff
    80005656:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005658:	e0043783          	ld	a5,-512(s0)
    8000565c:	6388                	ld	a0,0(a5)
    8000565e:	cd39                	beqz	a0,800056bc <kexec+0x252>
    80005660:	e9040993          	addi	s3,s0,-368
    80005664:	f9040c13          	addi	s8,s0,-112
    80005668:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000566a:	fdafb0ef          	jal	80000e44 <strlen>
    8000566e:	0015079b          	addiw	a5,a0,1
    80005672:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005676:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000567a:	11796e63          	bltu	s2,s7,80005796 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000567e:	e0043d03          	ld	s10,-512(s0)
    80005682:	000d3a03          	ld	s4,0(s10)
    80005686:	8552                	mv	a0,s4
    80005688:	fbcfb0ef          	jal	80000e44 <strlen>
    8000568c:	0015069b          	addiw	a3,a0,1
    80005690:	8652                	mv	a2,s4
    80005692:	85ca                	mv	a1,s2
    80005694:	855a                	mv	a0,s6
    80005696:	f87fb0ef          	jal	8000161c <copyout>
    8000569a:	10054063          	bltz	a0,8000579a <kexec+0x330>
    ustack[argc] = sp;
    8000569e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800056a2:	0485                	addi	s1,s1,1
    800056a4:	008d0793          	addi	a5,s10,8
    800056a8:	e0f43023          	sd	a5,-512(s0)
    800056ac:	008d3503          	ld	a0,8(s10)
    800056b0:	c909                	beqz	a0,800056c2 <kexec+0x258>
    if(argc >= MAXARG)
    800056b2:	09a1                	addi	s3,s3,8
    800056b4:	fb899be3          	bne	s3,s8,8000566a <kexec+0x200>
  ip = 0;
    800056b8:	4a01                	li	s4,0
    800056ba:	a0dd                	j	800057a0 <kexec+0x336>
  sp = sz;
    800056bc:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800056c0:	4481                	li	s1,0
  ustack[argc] = 0;
    800056c2:	00349793          	slli	a5,s1,0x3
    800056c6:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ff9caf8>
    800056ca:	97a2                	add	a5,a5,s0
    800056cc:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800056d0:	00148693          	addi	a3,s1,1
    800056d4:	068e                	slli	a3,a3,0x3
    800056d6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800056da:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800056de:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800056e2:	f5796ee3          	bltu	s2,s7,8000563e <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800056e6:	e9040613          	addi	a2,s0,-368
    800056ea:	85ca                	mv	a1,s2
    800056ec:	855a                	mv	a0,s6
    800056ee:	f2ffb0ef          	jal	8000161c <copyout>
    800056f2:	0e054263          	bltz	a0,800057d6 <kexec+0x36c>
  p->trapframe->a1 = sp;
    800056f6:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800056fa:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800056fe:	df843783          	ld	a5,-520(s0)
    80005702:	0007c703          	lbu	a4,0(a5)
    80005706:	cf11                	beqz	a4,80005722 <kexec+0x2b8>
    80005708:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000570a:	02f00693          	li	a3,47
    8000570e:	a039                	j	8000571c <kexec+0x2b2>
      last = s+1;
    80005710:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005714:	0785                	addi	a5,a5,1
    80005716:	fff7c703          	lbu	a4,-1(a5)
    8000571a:	c701                	beqz	a4,80005722 <kexec+0x2b8>
    if(*s == '/')
    8000571c:	fed71ce3          	bne	a4,a3,80005714 <kexec+0x2aa>
    80005720:	bfc5                	j	80005710 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80005722:	4641                	li	a2,16
    80005724:	df843583          	ld	a1,-520(s0)
    80005728:	158a8513          	addi	a0,s5,344
    8000572c:	ee6fb0ef          	jal	80000e12 <safestrcpy>
  oldpagetable = p->pagetable;
    80005730:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005734:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005738:	e0843783          	ld	a5,-504(s0)
    8000573c:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80005740:	058ab783          	ld	a5,88(s5)
    80005744:	e6843703          	ld	a4,-408(s0)
    80005748:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000574a:	058ab783          	ld	a5,88(s5)
    8000574e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005752:	85e6                	mv	a1,s9
    80005754:	b3efc0ef          	jal	80001a92 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005758:	0004851b          	sext.w	a0,s1
    8000575c:	79be                	ld	s3,488(sp)
    8000575e:	7a1e                	ld	s4,480(sp)
    80005760:	6afe                	ld	s5,472(sp)
    80005762:	6b5e                	ld	s6,464(sp)
    80005764:	6bbe                	ld	s7,456(sp)
    80005766:	6c1e                	ld	s8,448(sp)
    80005768:	7cfa                	ld	s9,440(sp)
    8000576a:	7d5a                	ld	s10,432(sp)
    8000576c:	b3b5                	j	800054d8 <kexec+0x6e>
    8000576e:	e1243423          	sd	s2,-504(s0)
    80005772:	7dba                	ld	s11,424(sp)
    80005774:	a035                	j	800057a0 <kexec+0x336>
    80005776:	e1243423          	sd	s2,-504(s0)
    8000577a:	7dba                	ld	s11,424(sp)
    8000577c:	a015                	j	800057a0 <kexec+0x336>
    8000577e:	e1243423          	sd	s2,-504(s0)
    80005782:	7dba                	ld	s11,424(sp)
    80005784:	a831                	j	800057a0 <kexec+0x336>
    80005786:	e1243423          	sd	s2,-504(s0)
    8000578a:	7dba                	ld	s11,424(sp)
    8000578c:	a811                	j	800057a0 <kexec+0x336>
    8000578e:	e1243423          	sd	s2,-504(s0)
    80005792:	7dba                	ld	s11,424(sp)
    80005794:	a031                	j	800057a0 <kexec+0x336>
  ip = 0;
    80005796:	4a01                	li	s4,0
    80005798:	a021                	j	800057a0 <kexec+0x336>
    8000579a:	4a01                	li	s4,0
  if(pagetable)
    8000579c:	a011                	j	800057a0 <kexec+0x336>
    8000579e:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800057a0:	e0843583          	ld	a1,-504(s0)
    800057a4:	855a                	mv	a0,s6
    800057a6:	aecfc0ef          	jal	80001a92 <proc_freepagetable>
  return -1;
    800057aa:	557d                	li	a0,-1
  if(ip){
    800057ac:	000a1b63          	bnez	s4,800057c2 <kexec+0x358>
    800057b0:	79be                	ld	s3,488(sp)
    800057b2:	7a1e                	ld	s4,480(sp)
    800057b4:	6afe                	ld	s5,472(sp)
    800057b6:	6b5e                	ld	s6,464(sp)
    800057b8:	6bbe                	ld	s7,456(sp)
    800057ba:	6c1e                	ld	s8,448(sp)
    800057bc:	7cfa                	ld	s9,440(sp)
    800057be:	7d5a                	ld	s10,432(sp)
    800057c0:	bb21                	j	800054d8 <kexec+0x6e>
    800057c2:	79be                	ld	s3,488(sp)
    800057c4:	6afe                	ld	s5,472(sp)
    800057c6:	6b5e                	ld	s6,464(sp)
    800057c8:	6bbe                	ld	s7,456(sp)
    800057ca:	6c1e                	ld	s8,448(sp)
    800057cc:	7cfa                	ld	s9,440(sp)
    800057ce:	7d5a                	ld	s10,432(sp)
    800057d0:	b9ed                	j	800054ca <kexec+0x60>
    800057d2:	6b5e                	ld	s6,464(sp)
    800057d4:	b9dd                	j	800054ca <kexec+0x60>
  sz = sz1;
    800057d6:	e0843983          	ld	s3,-504(s0)
    800057da:	b595                	j	8000563e <kexec+0x1d4>

00000000800057dc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800057dc:	7179                	addi	sp,sp,-48
    800057de:	f406                	sd	ra,40(sp)
    800057e0:	f022                	sd	s0,32(sp)
    800057e2:	ec26                	sd	s1,24(sp)
    800057e4:	e84a                	sd	s2,16(sp)
    800057e6:	1800                	addi	s0,sp,48
    800057e8:	892e                	mv	s2,a1
    800057ea:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800057ec:	fdc40593          	addi	a1,s0,-36
    800057f0:	82cfd0ef          	jal	8000281c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800057f4:	fdc42703          	lw	a4,-36(s0)
    800057f8:	47bd                	li	a5,15
    800057fa:	02e7e963          	bltu	a5,a4,8000582c <argfd+0x50>
    800057fe:	90afc0ef          	jal	80001908 <myproc>
    80005802:	fdc42703          	lw	a4,-36(s0)
    80005806:	01a70793          	addi	a5,a4,26
    8000580a:	078e                	slli	a5,a5,0x3
    8000580c:	953e                	add	a0,a0,a5
    8000580e:	611c                	ld	a5,0(a0)
    80005810:	c385                	beqz	a5,80005830 <argfd+0x54>
    return -1;
  if(pfd)
    80005812:	00090463          	beqz	s2,8000581a <argfd+0x3e>
    *pfd = fd;
    80005816:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000581a:	4501                	li	a0,0
  if(pf)
    8000581c:	c091                	beqz	s1,80005820 <argfd+0x44>
    *pf = f;
    8000581e:	e09c                	sd	a5,0(s1)
}
    80005820:	70a2                	ld	ra,40(sp)
    80005822:	7402                	ld	s0,32(sp)
    80005824:	64e2                	ld	s1,24(sp)
    80005826:	6942                	ld	s2,16(sp)
    80005828:	6145                	addi	sp,sp,48
    8000582a:	8082                	ret
    return -1;
    8000582c:	557d                	li	a0,-1
    8000582e:	bfcd                	j	80005820 <argfd+0x44>
    80005830:	557d                	li	a0,-1
    80005832:	b7fd                	j	80005820 <argfd+0x44>

0000000080005834 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005834:	1101                	addi	sp,sp,-32
    80005836:	ec06                	sd	ra,24(sp)
    80005838:	e822                	sd	s0,16(sp)
    8000583a:	e426                	sd	s1,8(sp)
    8000583c:	1000                	addi	s0,sp,32
    8000583e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005840:	8c8fc0ef          	jal	80001908 <myproc>
    80005844:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005846:	0d050793          	addi	a5,a0,208
    8000584a:	4501                	li	a0,0
    8000584c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000584e:	6398                	ld	a4,0(a5)
    80005850:	cb19                	beqz	a4,80005866 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80005852:	2505                	addiw	a0,a0,1
    80005854:	07a1                	addi	a5,a5,8
    80005856:	fed51ce3          	bne	a0,a3,8000584e <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000585a:	557d                	li	a0,-1
}
    8000585c:	60e2                	ld	ra,24(sp)
    8000585e:	6442                	ld	s0,16(sp)
    80005860:	64a2                	ld	s1,8(sp)
    80005862:	6105                	addi	sp,sp,32
    80005864:	8082                	ret
      p->ofile[fd] = f;
    80005866:	01a50793          	addi	a5,a0,26
    8000586a:	078e                	slli	a5,a5,0x3
    8000586c:	963e                	add	a2,a2,a5
    8000586e:	e204                	sd	s1,0(a2)
      return fd;
    80005870:	b7f5                	j	8000585c <fdalloc+0x28>

0000000080005872 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005872:	715d                	addi	sp,sp,-80
    80005874:	e486                	sd	ra,72(sp)
    80005876:	e0a2                	sd	s0,64(sp)
    80005878:	fc26                	sd	s1,56(sp)
    8000587a:	f84a                	sd	s2,48(sp)
    8000587c:	f44e                	sd	s3,40(sp)
    8000587e:	ec56                	sd	s5,24(sp)
    80005880:	e85a                	sd	s6,16(sp)
    80005882:	0880                	addi	s0,sp,80
    80005884:	8b2e                	mv	s6,a1
    80005886:	89b2                	mv	s3,a2
    80005888:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000588a:	fb040593          	addi	a1,s0,-80
    8000588e:	a31fe0ef          	jal	800042be <nameiparent>
    80005892:	84aa                	mv	s1,a0
    80005894:	10050a63          	beqz	a0,800059a8 <create+0x136>
    return 0;

  ilock(dp);
    80005898:	f89fd0ef          	jal	80003820 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000589c:	4601                	li	a2,0
    8000589e:	fb040593          	addi	a1,s0,-80
    800058a2:	8526                	mv	a0,s1
    800058a4:	e72fe0ef          	jal	80003f16 <dirlookup>
    800058a8:	8aaa                	mv	s5,a0
    800058aa:	c129                	beqz	a0,800058ec <create+0x7a>
    iunlockput(dp);
    800058ac:	8526                	mv	a0,s1
    800058ae:	a4efe0ef          	jal	80003afc <iunlockput>
    ilock(ip);
    800058b2:	8556                	mv	a0,s5
    800058b4:	f6dfd0ef          	jal	80003820 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800058b8:	4789                	li	a5,2
    800058ba:	02fb1463          	bne	s6,a5,800058e2 <create+0x70>
    800058be:	044ad783          	lhu	a5,68(s5)
    800058c2:	37f9                	addiw	a5,a5,-2
    800058c4:	17c2                	slli	a5,a5,0x30
    800058c6:	93c1                	srli	a5,a5,0x30
    800058c8:	4705                	li	a4,1
    800058ca:	00f76c63          	bltu	a4,a5,800058e2 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800058ce:	8556                	mv	a0,s5
    800058d0:	60a6                	ld	ra,72(sp)
    800058d2:	6406                	ld	s0,64(sp)
    800058d4:	74e2                	ld	s1,56(sp)
    800058d6:	7942                	ld	s2,48(sp)
    800058d8:	79a2                	ld	s3,40(sp)
    800058da:	6ae2                	ld	s5,24(sp)
    800058dc:	6b42                	ld	s6,16(sp)
    800058de:	6161                	addi	sp,sp,80
    800058e0:	8082                	ret
    iunlockput(ip);
    800058e2:	8556                	mv	a0,s5
    800058e4:	a18fe0ef          	jal	80003afc <iunlockput>
    return 0;
    800058e8:	4a81                	li	s5,0
    800058ea:	b7d5                	j	800058ce <create+0x5c>
    800058ec:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800058ee:	85da                	mv	a1,s6
    800058f0:	4088                	lw	a0,0(s1)
    800058f2:	d59fd0ef          	jal	8000364a <ialloc>
    800058f6:	8a2a                	mv	s4,a0
    800058f8:	cd15                	beqz	a0,80005934 <create+0xc2>
  ilock(ip);
    800058fa:	f27fd0ef          	jal	80003820 <ilock>
  ip->major = major;
    800058fe:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005902:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005906:	4905                	li	s2,1
    80005908:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000590c:	8552                	mv	a0,s4
    8000590e:	e1bfd0ef          	jal	80003728 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005912:	032b0763          	beq	s6,s2,80005940 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80005916:	004a2603          	lw	a2,4(s4)
    8000591a:	fb040593          	addi	a1,s0,-80
    8000591e:	8526                	mv	a0,s1
    80005920:	88ffe0ef          	jal	800041ae <dirlink>
    80005924:	06054563          	bltz	a0,8000598e <create+0x11c>
  iunlockput(dp);
    80005928:	8526                	mv	a0,s1
    8000592a:	9d2fe0ef          	jal	80003afc <iunlockput>
  return ip;
    8000592e:	8ad2                	mv	s5,s4
    80005930:	7a02                	ld	s4,32(sp)
    80005932:	bf71                	j	800058ce <create+0x5c>
    iunlockput(dp);
    80005934:	8526                	mv	a0,s1
    80005936:	9c6fe0ef          	jal	80003afc <iunlockput>
    return 0;
    8000593a:	8ad2                	mv	s5,s4
    8000593c:	7a02                	ld	s4,32(sp)
    8000593e:	bf41                	j	800058ce <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005940:	004a2603          	lw	a2,4(s4)
    80005944:	00003597          	auipc	a1,0x3
    80005948:	4ac58593          	addi	a1,a1,1196 # 80008df0 <etext+0xdf0>
    8000594c:	8552                	mv	a0,s4
    8000594e:	861fe0ef          	jal	800041ae <dirlink>
    80005952:	02054e63          	bltz	a0,8000598e <create+0x11c>
    80005956:	40d0                	lw	a2,4(s1)
    80005958:	00003597          	auipc	a1,0x3
    8000595c:	4a058593          	addi	a1,a1,1184 # 80008df8 <etext+0xdf8>
    80005960:	8552                	mv	a0,s4
    80005962:	84dfe0ef          	jal	800041ae <dirlink>
    80005966:	02054463          	bltz	a0,8000598e <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    8000596a:	004a2603          	lw	a2,4(s4)
    8000596e:	fb040593          	addi	a1,s0,-80
    80005972:	8526                	mv	a0,s1
    80005974:	83bfe0ef          	jal	800041ae <dirlink>
    80005978:	00054b63          	bltz	a0,8000598e <create+0x11c>
    dp->nlink++;  // for ".."
    8000597c:	04a4d783          	lhu	a5,74(s1)
    80005980:	2785                	addiw	a5,a5,1
    80005982:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005986:	8526                	mv	a0,s1
    80005988:	da1fd0ef          	jal	80003728 <iupdate>
    8000598c:	bf71                	j	80005928 <create+0xb6>
  ip->nlink = 0;
    8000598e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005992:	8552                	mv	a0,s4
    80005994:	d95fd0ef          	jal	80003728 <iupdate>
  iunlockput(ip);
    80005998:	8552                	mv	a0,s4
    8000599a:	962fe0ef          	jal	80003afc <iunlockput>
  iunlockput(dp);
    8000599e:	8526                	mv	a0,s1
    800059a0:	95cfe0ef          	jal	80003afc <iunlockput>
  return 0;
    800059a4:	7a02                	ld	s4,32(sp)
    800059a6:	b725                	j	800058ce <create+0x5c>
    return 0;
    800059a8:	8aaa                	mv	s5,a0
    800059aa:	b715                	j	800058ce <create+0x5c>

00000000800059ac <sys_dup>:
{
    800059ac:	7179                	addi	sp,sp,-48
    800059ae:	f406                	sd	ra,40(sp)
    800059b0:	f022                	sd	s0,32(sp)
    800059b2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800059b4:	fd840613          	addi	a2,s0,-40
    800059b8:	4581                	li	a1,0
    800059ba:	4501                	li	a0,0
    800059bc:	e21ff0ef          	jal	800057dc <argfd>
    return -1;
    800059c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800059c2:	02054363          	bltz	a0,800059e8 <sys_dup+0x3c>
    800059c6:	ec26                	sd	s1,24(sp)
    800059c8:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800059ca:	fd843903          	ld	s2,-40(s0)
    800059ce:	854a                	mv	a0,s2
    800059d0:	e65ff0ef          	jal	80005834 <fdalloc>
    800059d4:	84aa                	mv	s1,a0
    return -1;
    800059d6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800059d8:	00054d63          	bltz	a0,800059f2 <sys_dup+0x46>
  filedup(f);
    800059dc:	854a                	mv	a0,s2
    800059de:	bbaff0ef          	jal	80004d98 <filedup>
  return fd;
    800059e2:	87a6                	mv	a5,s1
    800059e4:	64e2                	ld	s1,24(sp)
    800059e6:	6942                	ld	s2,16(sp)
}
    800059e8:	853e                	mv	a0,a5
    800059ea:	70a2                	ld	ra,40(sp)
    800059ec:	7402                	ld	s0,32(sp)
    800059ee:	6145                	addi	sp,sp,48
    800059f0:	8082                	ret
    800059f2:	64e2                	ld	s1,24(sp)
    800059f4:	6942                	ld	s2,16(sp)
    800059f6:	bfcd                	j	800059e8 <sys_dup+0x3c>

00000000800059f8 <sys_read>:
{
    800059f8:	7179                	addi	sp,sp,-48
    800059fa:	f406                	sd	ra,40(sp)
    800059fc:	f022                	sd	s0,32(sp)
    800059fe:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a00:	fd840593          	addi	a1,s0,-40
    80005a04:	4505                	li	a0,1
    80005a06:	e33fc0ef          	jal	80002838 <argaddr>
  argint(2, &n);
    80005a0a:	fe440593          	addi	a1,s0,-28
    80005a0e:	4509                	li	a0,2
    80005a10:	e0dfc0ef          	jal	8000281c <argint>
  if(argfd(0, 0, &f) < 0)
    80005a14:	fe840613          	addi	a2,s0,-24
    80005a18:	4581                	li	a1,0
    80005a1a:	4501                	li	a0,0
    80005a1c:	dc1ff0ef          	jal	800057dc <argfd>
    80005a20:	87aa                	mv	a5,a0
    return -1;
    80005a22:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a24:	0007ca63          	bltz	a5,80005a38 <sys_read+0x40>
  return fileread(f, p, n);
    80005a28:	fe442603          	lw	a2,-28(s0)
    80005a2c:	fd843583          	ld	a1,-40(s0)
    80005a30:	fe843503          	ld	a0,-24(s0)
    80005a34:	cfeff0ef          	jal	80004f32 <fileread>
}
    80005a38:	70a2                	ld	ra,40(sp)
    80005a3a:	7402                	ld	s0,32(sp)
    80005a3c:	6145                	addi	sp,sp,48
    80005a3e:	8082                	ret

0000000080005a40 <sys_write>:
{
    80005a40:	7179                	addi	sp,sp,-48
    80005a42:	f406                	sd	ra,40(sp)
    80005a44:	f022                	sd	s0,32(sp)
    80005a46:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a48:	fd840593          	addi	a1,s0,-40
    80005a4c:	4505                	li	a0,1
    80005a4e:	debfc0ef          	jal	80002838 <argaddr>
  argint(2, &n);
    80005a52:	fe440593          	addi	a1,s0,-28
    80005a56:	4509                	li	a0,2
    80005a58:	dc5fc0ef          	jal	8000281c <argint>
  if(argfd(0, 0, &f) < 0)
    80005a5c:	fe840613          	addi	a2,s0,-24
    80005a60:	4581                	li	a1,0
    80005a62:	4501                	li	a0,0
    80005a64:	d79ff0ef          	jal	800057dc <argfd>
    80005a68:	87aa                	mv	a5,a0
    return -1;
    80005a6a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a6c:	0007ca63          	bltz	a5,80005a80 <sys_write+0x40>
  return filewrite(f, p, n);
    80005a70:	fe442603          	lw	a2,-28(s0)
    80005a74:	fd843583          	ld	a1,-40(s0)
    80005a78:	fe843503          	ld	a0,-24(s0)
    80005a7c:	d96ff0ef          	jal	80005012 <filewrite>
}
    80005a80:	70a2                	ld	ra,40(sp)
    80005a82:	7402                	ld	s0,32(sp)
    80005a84:	6145                	addi	sp,sp,48
    80005a86:	8082                	ret

0000000080005a88 <sys_close>:
{
    80005a88:	1101                	addi	sp,sp,-32
    80005a8a:	ec06                	sd	ra,24(sp)
    80005a8c:	e822                	sd	s0,16(sp)
    80005a8e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005a90:	fe040613          	addi	a2,s0,-32
    80005a94:	fec40593          	addi	a1,s0,-20
    80005a98:	4501                	li	a0,0
    80005a9a:	d43ff0ef          	jal	800057dc <argfd>
    return -1;
    80005a9e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005aa0:	02054063          	bltz	a0,80005ac0 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80005aa4:	e65fb0ef          	jal	80001908 <myproc>
    80005aa8:	fec42783          	lw	a5,-20(s0)
    80005aac:	07e9                	addi	a5,a5,26
    80005aae:	078e                	slli	a5,a5,0x3
    80005ab0:	953e                	add	a0,a0,a5
    80005ab2:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005ab6:	fe043503          	ld	a0,-32(s0)
    80005aba:	b3eff0ef          	jal	80004df8 <fileclose>
  return 0;
    80005abe:	4781                	li	a5,0
}
    80005ac0:	853e                	mv	a0,a5
    80005ac2:	60e2                	ld	ra,24(sp)
    80005ac4:	6442                	ld	s0,16(sp)
    80005ac6:	6105                	addi	sp,sp,32
    80005ac8:	8082                	ret

0000000080005aca <sys_fstat>:
{
    80005aca:	1101                	addi	sp,sp,-32
    80005acc:	ec06                	sd	ra,24(sp)
    80005ace:	e822                	sd	s0,16(sp)
    80005ad0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005ad2:	fe040593          	addi	a1,s0,-32
    80005ad6:	4505                	li	a0,1
    80005ad8:	d61fc0ef          	jal	80002838 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005adc:	fe840613          	addi	a2,s0,-24
    80005ae0:	4581                	li	a1,0
    80005ae2:	4501                	li	a0,0
    80005ae4:	cf9ff0ef          	jal	800057dc <argfd>
    80005ae8:	87aa                	mv	a5,a0
    return -1;
    80005aea:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005aec:	0007c863          	bltz	a5,80005afc <sys_fstat+0x32>
  return filestat(f, st);
    80005af0:	fe043583          	ld	a1,-32(s0)
    80005af4:	fe843503          	ld	a0,-24(s0)
    80005af8:	bdcff0ef          	jal	80004ed4 <filestat>
}
    80005afc:	60e2                	ld	ra,24(sp)
    80005afe:	6442                	ld	s0,16(sp)
    80005b00:	6105                	addi	sp,sp,32
    80005b02:	8082                	ret

0000000080005b04 <sys_link>:
{
    80005b04:	7169                	addi	sp,sp,-304
    80005b06:	f606                	sd	ra,296(sp)
    80005b08:	f222                	sd	s0,288(sp)
    80005b0a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b0c:	08000613          	li	a2,128
    80005b10:	ed040593          	addi	a1,s0,-304
    80005b14:	4501                	li	a0,0
    80005b16:	d3ffc0ef          	jal	80002854 <argstr>
    return -1;
    80005b1a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b1c:	0c054e63          	bltz	a0,80005bf8 <sys_link+0xf4>
    80005b20:	08000613          	li	a2,128
    80005b24:	f5040593          	addi	a1,s0,-176
    80005b28:	4505                	li	a0,1
    80005b2a:	d2bfc0ef          	jal	80002854 <argstr>
    return -1;
    80005b2e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b30:	0c054463          	bltz	a0,80005bf8 <sys_link+0xf4>
    80005b34:	ee26                	sd	s1,280(sp)
  begin_op();
    80005b36:	bb5fe0ef          	jal	800046ea <begin_op>
  if((ip = namei(old)) == 0){
    80005b3a:	ed040513          	addi	a0,s0,-304
    80005b3e:	f66fe0ef          	jal	800042a4 <namei>
    80005b42:	84aa                	mv	s1,a0
    80005b44:	c53d                	beqz	a0,80005bb2 <sys_link+0xae>
  ilock(ip);
    80005b46:	cdbfd0ef          	jal	80003820 <ilock>
  if(ip->type == T_DIR){
    80005b4a:	04449703          	lh	a4,68(s1)
    80005b4e:	4785                	li	a5,1
    80005b50:	06f70663          	beq	a4,a5,80005bbc <sys_link+0xb8>
    80005b54:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005b56:	04a4d783          	lhu	a5,74(s1)
    80005b5a:	2785                	addiw	a5,a5,1
    80005b5c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b60:	8526                	mv	a0,s1
    80005b62:	bc7fd0ef          	jal	80003728 <iupdate>
  iunlock(ip);
    80005b66:	8526                	mv	a0,s1
    80005b68:	dabfd0ef          	jal	80003912 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005b6c:	fd040593          	addi	a1,s0,-48
    80005b70:	f5040513          	addi	a0,s0,-176
    80005b74:	f4afe0ef          	jal	800042be <nameiparent>
    80005b78:	892a                	mv	s2,a0
    80005b7a:	cd21                	beqz	a0,80005bd2 <sys_link+0xce>
  ilock(dp);
    80005b7c:	ca5fd0ef          	jal	80003820 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005b80:	00092703          	lw	a4,0(s2)
    80005b84:	409c                	lw	a5,0(s1)
    80005b86:	04f71363          	bne	a4,a5,80005bcc <sys_link+0xc8>
    80005b8a:	40d0                	lw	a2,4(s1)
    80005b8c:	fd040593          	addi	a1,s0,-48
    80005b90:	854a                	mv	a0,s2
    80005b92:	e1cfe0ef          	jal	800041ae <dirlink>
    80005b96:	02054b63          	bltz	a0,80005bcc <sys_link+0xc8>
  iunlockput(dp);
    80005b9a:	854a                	mv	a0,s2
    80005b9c:	f61fd0ef          	jal	80003afc <iunlockput>
  iput(ip);
    80005ba0:	8526                	mv	a0,s1
    80005ba2:	e8ffd0ef          	jal	80003a30 <iput>
  end_op();
    80005ba6:	c63fe0ef          	jal	80004808 <end_op>
  return 0;
    80005baa:	4781                	li	a5,0
    80005bac:	64f2                	ld	s1,280(sp)
    80005bae:	6952                	ld	s2,272(sp)
    80005bb0:	a0a1                	j	80005bf8 <sys_link+0xf4>
    end_op();
    80005bb2:	c57fe0ef          	jal	80004808 <end_op>
    return -1;
    80005bb6:	57fd                	li	a5,-1
    80005bb8:	64f2                	ld	s1,280(sp)
    80005bba:	a83d                	j	80005bf8 <sys_link+0xf4>
    iunlockput(ip);
    80005bbc:	8526                	mv	a0,s1
    80005bbe:	f3ffd0ef          	jal	80003afc <iunlockput>
    end_op();
    80005bc2:	c47fe0ef          	jal	80004808 <end_op>
    return -1;
    80005bc6:	57fd                	li	a5,-1
    80005bc8:	64f2                	ld	s1,280(sp)
    80005bca:	a03d                	j	80005bf8 <sys_link+0xf4>
    iunlockput(dp);
    80005bcc:	854a                	mv	a0,s2
    80005bce:	f2ffd0ef          	jal	80003afc <iunlockput>
  ilock(ip);
    80005bd2:	8526                	mv	a0,s1
    80005bd4:	c4dfd0ef          	jal	80003820 <ilock>
  ip->nlink--;
    80005bd8:	04a4d783          	lhu	a5,74(s1)
    80005bdc:	37fd                	addiw	a5,a5,-1
    80005bde:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005be2:	8526                	mv	a0,s1
    80005be4:	b45fd0ef          	jal	80003728 <iupdate>
  iunlockput(ip);
    80005be8:	8526                	mv	a0,s1
    80005bea:	f13fd0ef          	jal	80003afc <iunlockput>
  end_op();
    80005bee:	c1bfe0ef          	jal	80004808 <end_op>
  return -1;
    80005bf2:	57fd                	li	a5,-1
    80005bf4:	64f2                	ld	s1,280(sp)
    80005bf6:	6952                	ld	s2,272(sp)
}
    80005bf8:	853e                	mv	a0,a5
    80005bfa:	70b2                	ld	ra,296(sp)
    80005bfc:	7412                	ld	s0,288(sp)
    80005bfe:	6155                	addi	sp,sp,304
    80005c00:	8082                	ret

0000000080005c02 <sys_unlink>:
{
    80005c02:	7151                	addi	sp,sp,-240
    80005c04:	f586                	sd	ra,232(sp)
    80005c06:	f1a2                	sd	s0,224(sp)
    80005c08:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005c0a:	08000613          	li	a2,128
    80005c0e:	f3040593          	addi	a1,s0,-208
    80005c12:	4501                	li	a0,0
    80005c14:	c41fc0ef          	jal	80002854 <argstr>
    80005c18:	16054063          	bltz	a0,80005d78 <sys_unlink+0x176>
    80005c1c:	eda6                	sd	s1,216(sp)
  begin_op();
    80005c1e:	acdfe0ef          	jal	800046ea <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005c22:	fb040593          	addi	a1,s0,-80
    80005c26:	f3040513          	addi	a0,s0,-208
    80005c2a:	e94fe0ef          	jal	800042be <nameiparent>
    80005c2e:	84aa                	mv	s1,a0
    80005c30:	c945                	beqz	a0,80005ce0 <sys_unlink+0xde>
  ilock(dp);
    80005c32:	beffd0ef          	jal	80003820 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005c36:	00003597          	auipc	a1,0x3
    80005c3a:	1ba58593          	addi	a1,a1,442 # 80008df0 <etext+0xdf0>
    80005c3e:	fb040513          	addi	a0,s0,-80
    80005c42:	abefe0ef          	jal	80003f00 <namecmp>
    80005c46:	10050e63          	beqz	a0,80005d62 <sys_unlink+0x160>
    80005c4a:	00003597          	auipc	a1,0x3
    80005c4e:	1ae58593          	addi	a1,a1,430 # 80008df8 <etext+0xdf8>
    80005c52:	fb040513          	addi	a0,s0,-80
    80005c56:	aaafe0ef          	jal	80003f00 <namecmp>
    80005c5a:	10050463          	beqz	a0,80005d62 <sys_unlink+0x160>
    80005c5e:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005c60:	f2c40613          	addi	a2,s0,-212
    80005c64:	fb040593          	addi	a1,s0,-80
    80005c68:	8526                	mv	a0,s1
    80005c6a:	aacfe0ef          	jal	80003f16 <dirlookup>
    80005c6e:	892a                	mv	s2,a0
    80005c70:	0e050863          	beqz	a0,80005d60 <sys_unlink+0x15e>
  ilock(ip);
    80005c74:	badfd0ef          	jal	80003820 <ilock>
  if(ip->nlink < 1)
    80005c78:	04a91783          	lh	a5,74(s2)
    80005c7c:	06f05763          	blez	a5,80005cea <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005c80:	04491703          	lh	a4,68(s2)
    80005c84:	4785                	li	a5,1
    80005c86:	06f70963          	beq	a4,a5,80005cf8 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005c8a:	4641                	li	a2,16
    80005c8c:	4581                	li	a1,0
    80005c8e:	fc040513          	addi	a0,s0,-64
    80005c92:	842fb0ef          	jal	80000cd4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c96:	4741                	li	a4,16
    80005c98:	f2c42683          	lw	a3,-212(s0)
    80005c9c:	fc040613          	addi	a2,s0,-64
    80005ca0:	4581                	li	a1,0
    80005ca2:	8526                	mv	a0,s1
    80005ca4:	90efe0ef          	jal	80003db2 <writei>
    80005ca8:	47c1                	li	a5,16
    80005caa:	08f51b63          	bne	a0,a5,80005d40 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005cae:	04491703          	lh	a4,68(s2)
    80005cb2:	4785                	li	a5,1
    80005cb4:	08f70d63          	beq	a4,a5,80005d4e <sys_unlink+0x14c>
  iunlockput(dp);
    80005cb8:	8526                	mv	a0,s1
    80005cba:	e43fd0ef          	jal	80003afc <iunlockput>
  ip->nlink--;
    80005cbe:	04a95783          	lhu	a5,74(s2)
    80005cc2:	37fd                	addiw	a5,a5,-1
    80005cc4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005cc8:	854a                	mv	a0,s2
    80005cca:	a5ffd0ef          	jal	80003728 <iupdate>
  iunlockput(ip);
    80005cce:	854a                	mv	a0,s2
    80005cd0:	e2dfd0ef          	jal	80003afc <iunlockput>
  end_op();
    80005cd4:	b35fe0ef          	jal	80004808 <end_op>
  return 0;
    80005cd8:	4501                	li	a0,0
    80005cda:	64ee                	ld	s1,216(sp)
    80005cdc:	694e                	ld	s2,208(sp)
    80005cde:	a849                	j	80005d70 <sys_unlink+0x16e>
    end_op();
    80005ce0:	b29fe0ef          	jal	80004808 <end_op>
    return -1;
    80005ce4:	557d                	li	a0,-1
    80005ce6:	64ee                	ld	s1,216(sp)
    80005ce8:	a061                	j	80005d70 <sys_unlink+0x16e>
    80005cea:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005cec:	00003517          	auipc	a0,0x3
    80005cf0:	11450513          	addi	a0,a0,276 # 80008e00 <etext+0xe00>
    80005cf4:	b1ffa0ef          	jal	80000812 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005cf8:	04c92703          	lw	a4,76(s2)
    80005cfc:	02000793          	li	a5,32
    80005d00:	f8e7f5e3          	bgeu	a5,a4,80005c8a <sys_unlink+0x88>
    80005d04:	e5ce                	sd	s3,200(sp)
    80005d06:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d0a:	4741                	li	a4,16
    80005d0c:	86ce                	mv	a3,s3
    80005d0e:	f1840613          	addi	a2,s0,-232
    80005d12:	4581                	li	a1,0
    80005d14:	854a                	mv	a0,s2
    80005d16:	f6dfd0ef          	jal	80003c82 <readi>
    80005d1a:	47c1                	li	a5,16
    80005d1c:	00f51c63          	bne	a0,a5,80005d34 <sys_unlink+0x132>
    if(de.inum != 0)
    80005d20:	f1845783          	lhu	a5,-232(s0)
    80005d24:	efa1                	bnez	a5,80005d7c <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005d26:	29c1                	addiw	s3,s3,16
    80005d28:	04c92783          	lw	a5,76(s2)
    80005d2c:	fcf9efe3          	bltu	s3,a5,80005d0a <sys_unlink+0x108>
    80005d30:	69ae                	ld	s3,200(sp)
    80005d32:	bfa1                	j	80005c8a <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005d34:	00003517          	auipc	a0,0x3
    80005d38:	0e450513          	addi	a0,a0,228 # 80008e18 <etext+0xe18>
    80005d3c:	ad7fa0ef          	jal	80000812 <panic>
    80005d40:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005d42:	00003517          	auipc	a0,0x3
    80005d46:	0ee50513          	addi	a0,a0,238 # 80008e30 <etext+0xe30>
    80005d4a:	ac9fa0ef          	jal	80000812 <panic>
    dp->nlink--;
    80005d4e:	04a4d783          	lhu	a5,74(s1)
    80005d52:	37fd                	addiw	a5,a5,-1
    80005d54:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005d58:	8526                	mv	a0,s1
    80005d5a:	9cffd0ef          	jal	80003728 <iupdate>
    80005d5e:	bfa9                	j	80005cb8 <sys_unlink+0xb6>
    80005d60:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005d62:	8526                	mv	a0,s1
    80005d64:	d99fd0ef          	jal	80003afc <iunlockput>
  end_op();
    80005d68:	aa1fe0ef          	jal	80004808 <end_op>
  return -1;
    80005d6c:	557d                	li	a0,-1
    80005d6e:	64ee                	ld	s1,216(sp)
}
    80005d70:	70ae                	ld	ra,232(sp)
    80005d72:	740e                	ld	s0,224(sp)
    80005d74:	616d                	addi	sp,sp,240
    80005d76:	8082                	ret
    return -1;
    80005d78:	557d                	li	a0,-1
    80005d7a:	bfdd                	j	80005d70 <sys_unlink+0x16e>
    iunlockput(ip);
    80005d7c:	854a                	mv	a0,s2
    80005d7e:	d7ffd0ef          	jal	80003afc <iunlockput>
    goto bad;
    80005d82:	694e                	ld	s2,208(sp)
    80005d84:	69ae                	ld	s3,200(sp)
    80005d86:	bff1                	j	80005d62 <sys_unlink+0x160>

0000000080005d88 <sys_open>:

uint64
sys_open(void)
{
    80005d88:	7131                	addi	sp,sp,-192
    80005d8a:	fd06                	sd	ra,184(sp)
    80005d8c:	f922                	sd	s0,176(sp)
    80005d8e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005d90:	f4c40593          	addi	a1,s0,-180
    80005d94:	4505                	li	a0,1
    80005d96:	a87fc0ef          	jal	8000281c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005d9a:	08000613          	li	a2,128
    80005d9e:	f5040593          	addi	a1,s0,-176
    80005da2:	4501                	li	a0,0
    80005da4:	ab1fc0ef          	jal	80002854 <argstr>
    80005da8:	87aa                	mv	a5,a0
    return -1;
    80005daa:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005dac:	0a07c263          	bltz	a5,80005e50 <sys_open+0xc8>
    80005db0:	f526                	sd	s1,168(sp)

  begin_op();
    80005db2:	939fe0ef          	jal	800046ea <begin_op>

  if(omode & O_CREATE){
    80005db6:	f4c42783          	lw	a5,-180(s0)
    80005dba:	2007f793          	andi	a5,a5,512
    80005dbe:	c3d5                	beqz	a5,80005e62 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005dc0:	4681                	li	a3,0
    80005dc2:	4601                	li	a2,0
    80005dc4:	4589                	li	a1,2
    80005dc6:	f5040513          	addi	a0,s0,-176
    80005dca:	aa9ff0ef          	jal	80005872 <create>
    80005dce:	84aa                	mv	s1,a0
    if(ip == 0){
    80005dd0:	c541                	beqz	a0,80005e58 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005dd2:	04449703          	lh	a4,68(s1)
    80005dd6:	478d                	li	a5,3
    80005dd8:	00f71763          	bne	a4,a5,80005de6 <sys_open+0x5e>
    80005ddc:	0464d703          	lhu	a4,70(s1)
    80005de0:	47a5                	li	a5,9
    80005de2:	0ae7ed63          	bltu	a5,a4,80005e9c <sys_open+0x114>
    80005de6:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005de8:	f39fe0ef          	jal	80004d20 <filealloc>
    80005dec:	892a                	mv	s2,a0
    80005dee:	c179                	beqz	a0,80005eb4 <sys_open+0x12c>
    80005df0:	ed4e                	sd	s3,152(sp)
    80005df2:	a43ff0ef          	jal	80005834 <fdalloc>
    80005df6:	89aa                	mv	s3,a0
    80005df8:	0a054a63          	bltz	a0,80005eac <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005dfc:	04449703          	lh	a4,68(s1)
    80005e00:	478d                	li	a5,3
    80005e02:	0cf70263          	beq	a4,a5,80005ec6 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005e06:	4789                	li	a5,2
    80005e08:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005e0c:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005e10:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005e14:	f4c42783          	lw	a5,-180(s0)
    80005e18:	0017c713          	xori	a4,a5,1
    80005e1c:	8b05                	andi	a4,a4,1
    80005e1e:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005e22:	0037f713          	andi	a4,a5,3
    80005e26:	00e03733          	snez	a4,a4
    80005e2a:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005e2e:	4007f793          	andi	a5,a5,1024
    80005e32:	c791                	beqz	a5,80005e3e <sys_open+0xb6>
    80005e34:	04449703          	lh	a4,68(s1)
    80005e38:	4789                	li	a5,2
    80005e3a:	08f70d63          	beq	a4,a5,80005ed4 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005e3e:	8526                	mv	a0,s1
    80005e40:	ad3fd0ef          	jal	80003912 <iunlock>
  end_op();
    80005e44:	9c5fe0ef          	jal	80004808 <end_op>

  return fd;
    80005e48:	854e                	mv	a0,s3
    80005e4a:	74aa                	ld	s1,168(sp)
    80005e4c:	790a                	ld	s2,160(sp)
    80005e4e:	69ea                	ld	s3,152(sp)
}
    80005e50:	70ea                	ld	ra,184(sp)
    80005e52:	744a                	ld	s0,176(sp)
    80005e54:	6129                	addi	sp,sp,192
    80005e56:	8082                	ret
      end_op();
    80005e58:	9b1fe0ef          	jal	80004808 <end_op>
      return -1;
    80005e5c:	557d                	li	a0,-1
    80005e5e:	74aa                	ld	s1,168(sp)
    80005e60:	bfc5                	j	80005e50 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005e62:	f5040513          	addi	a0,s0,-176
    80005e66:	c3efe0ef          	jal	800042a4 <namei>
    80005e6a:	84aa                	mv	s1,a0
    80005e6c:	c11d                	beqz	a0,80005e92 <sys_open+0x10a>
    ilock(ip);
    80005e6e:	9b3fd0ef          	jal	80003820 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005e72:	04449703          	lh	a4,68(s1)
    80005e76:	4785                	li	a5,1
    80005e78:	f4f71de3          	bne	a4,a5,80005dd2 <sys_open+0x4a>
    80005e7c:	f4c42783          	lw	a5,-180(s0)
    80005e80:	d3bd                	beqz	a5,80005de6 <sys_open+0x5e>
      iunlockput(ip);
    80005e82:	8526                	mv	a0,s1
    80005e84:	c79fd0ef          	jal	80003afc <iunlockput>
      end_op();
    80005e88:	981fe0ef          	jal	80004808 <end_op>
      return -1;
    80005e8c:	557d                	li	a0,-1
    80005e8e:	74aa                	ld	s1,168(sp)
    80005e90:	b7c1                	j	80005e50 <sys_open+0xc8>
      end_op();
    80005e92:	977fe0ef          	jal	80004808 <end_op>
      return -1;
    80005e96:	557d                	li	a0,-1
    80005e98:	74aa                	ld	s1,168(sp)
    80005e9a:	bf5d                	j	80005e50 <sys_open+0xc8>
    iunlockput(ip);
    80005e9c:	8526                	mv	a0,s1
    80005e9e:	c5ffd0ef          	jal	80003afc <iunlockput>
    end_op();
    80005ea2:	967fe0ef          	jal	80004808 <end_op>
    return -1;
    80005ea6:	557d                	li	a0,-1
    80005ea8:	74aa                	ld	s1,168(sp)
    80005eaa:	b75d                	j	80005e50 <sys_open+0xc8>
      fileclose(f);
    80005eac:	854a                	mv	a0,s2
    80005eae:	f4bfe0ef          	jal	80004df8 <fileclose>
    80005eb2:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005eb4:	8526                	mv	a0,s1
    80005eb6:	c47fd0ef          	jal	80003afc <iunlockput>
    end_op();
    80005eba:	94ffe0ef          	jal	80004808 <end_op>
    return -1;
    80005ebe:	557d                	li	a0,-1
    80005ec0:	74aa                	ld	s1,168(sp)
    80005ec2:	790a                	ld	s2,160(sp)
    80005ec4:	b771                	j	80005e50 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005ec6:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005eca:	04649783          	lh	a5,70(s1)
    80005ece:	02f91223          	sh	a5,36(s2)
    80005ed2:	bf3d                	j	80005e10 <sys_open+0x88>
    itrunc(ip);
    80005ed4:	8526                	mv	a0,s1
    80005ed6:	a9ffd0ef          	jal	80003974 <itrunc>
    80005eda:	b795                	j	80005e3e <sys_open+0xb6>

0000000080005edc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005edc:	7175                	addi	sp,sp,-144
    80005ede:	e506                	sd	ra,136(sp)
    80005ee0:	e122                	sd	s0,128(sp)
    80005ee2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ee4:	807fe0ef          	jal	800046ea <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ee8:	08000613          	li	a2,128
    80005eec:	f7040593          	addi	a1,s0,-144
    80005ef0:	4501                	li	a0,0
    80005ef2:	963fc0ef          	jal	80002854 <argstr>
    80005ef6:	02054363          	bltz	a0,80005f1c <sys_mkdir+0x40>
    80005efa:	4681                	li	a3,0
    80005efc:	4601                	li	a2,0
    80005efe:	4585                	li	a1,1
    80005f00:	f7040513          	addi	a0,s0,-144
    80005f04:	96fff0ef          	jal	80005872 <create>
    80005f08:	c911                	beqz	a0,80005f1c <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f0a:	bf3fd0ef          	jal	80003afc <iunlockput>
  end_op();
    80005f0e:	8fbfe0ef          	jal	80004808 <end_op>
  return 0;
    80005f12:	4501                	li	a0,0
}
    80005f14:	60aa                	ld	ra,136(sp)
    80005f16:	640a                	ld	s0,128(sp)
    80005f18:	6149                	addi	sp,sp,144
    80005f1a:	8082                	ret
    end_op();
    80005f1c:	8edfe0ef          	jal	80004808 <end_op>
    return -1;
    80005f20:	557d                	li	a0,-1
    80005f22:	bfcd                	j	80005f14 <sys_mkdir+0x38>

0000000080005f24 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005f24:	7135                	addi	sp,sp,-160
    80005f26:	ed06                	sd	ra,152(sp)
    80005f28:	e922                	sd	s0,144(sp)
    80005f2a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005f2c:	fbefe0ef          	jal	800046ea <begin_op>
  argint(1, &major);
    80005f30:	f6c40593          	addi	a1,s0,-148
    80005f34:	4505                	li	a0,1
    80005f36:	8e7fc0ef          	jal	8000281c <argint>
  argint(2, &minor);
    80005f3a:	f6840593          	addi	a1,s0,-152
    80005f3e:	4509                	li	a0,2
    80005f40:	8ddfc0ef          	jal	8000281c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f44:	08000613          	li	a2,128
    80005f48:	f7040593          	addi	a1,s0,-144
    80005f4c:	4501                	li	a0,0
    80005f4e:	907fc0ef          	jal	80002854 <argstr>
    80005f52:	02054563          	bltz	a0,80005f7c <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005f56:	f6841683          	lh	a3,-152(s0)
    80005f5a:	f6c41603          	lh	a2,-148(s0)
    80005f5e:	458d                	li	a1,3
    80005f60:	f7040513          	addi	a0,s0,-144
    80005f64:	90fff0ef          	jal	80005872 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f68:	c911                	beqz	a0,80005f7c <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f6a:	b93fd0ef          	jal	80003afc <iunlockput>
  end_op();
    80005f6e:	89bfe0ef          	jal	80004808 <end_op>
  return 0;
    80005f72:	4501                	li	a0,0
}
    80005f74:	60ea                	ld	ra,152(sp)
    80005f76:	644a                	ld	s0,144(sp)
    80005f78:	610d                	addi	sp,sp,160
    80005f7a:	8082                	ret
    end_op();
    80005f7c:	88dfe0ef          	jal	80004808 <end_op>
    return -1;
    80005f80:	557d                	li	a0,-1
    80005f82:	bfcd                	j	80005f74 <sys_mknod+0x50>

0000000080005f84 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f84:	7135                	addi	sp,sp,-160
    80005f86:	ed06                	sd	ra,152(sp)
    80005f88:	e922                	sd	s0,144(sp)
    80005f8a:	e14a                	sd	s2,128(sp)
    80005f8c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f8e:	97bfb0ef          	jal	80001908 <myproc>
    80005f92:	892a                	mv	s2,a0
  
  begin_op();
    80005f94:	f56fe0ef          	jal	800046ea <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f98:	08000613          	li	a2,128
    80005f9c:	f6040593          	addi	a1,s0,-160
    80005fa0:	4501                	li	a0,0
    80005fa2:	8b3fc0ef          	jal	80002854 <argstr>
    80005fa6:	04054363          	bltz	a0,80005fec <sys_chdir+0x68>
    80005faa:	e526                	sd	s1,136(sp)
    80005fac:	f6040513          	addi	a0,s0,-160
    80005fb0:	af4fe0ef          	jal	800042a4 <namei>
    80005fb4:	84aa                	mv	s1,a0
    80005fb6:	c915                	beqz	a0,80005fea <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005fb8:	869fd0ef          	jal	80003820 <ilock>
  if(ip->type != T_DIR){
    80005fbc:	04449703          	lh	a4,68(s1)
    80005fc0:	4785                	li	a5,1
    80005fc2:	02f71963          	bne	a4,a5,80005ff4 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005fc6:	8526                	mv	a0,s1
    80005fc8:	94bfd0ef          	jal	80003912 <iunlock>
  iput(p->cwd);
    80005fcc:	15093503          	ld	a0,336(s2)
    80005fd0:	a61fd0ef          	jal	80003a30 <iput>
  end_op();
    80005fd4:	835fe0ef          	jal	80004808 <end_op>
  p->cwd = ip;
    80005fd8:	14993823          	sd	s1,336(s2)
  return 0;
    80005fdc:	4501                	li	a0,0
    80005fde:	64aa                	ld	s1,136(sp)
}
    80005fe0:	60ea                	ld	ra,152(sp)
    80005fe2:	644a                	ld	s0,144(sp)
    80005fe4:	690a                	ld	s2,128(sp)
    80005fe6:	610d                	addi	sp,sp,160
    80005fe8:	8082                	ret
    80005fea:	64aa                	ld	s1,136(sp)
    end_op();
    80005fec:	81dfe0ef          	jal	80004808 <end_op>
    return -1;
    80005ff0:	557d                	li	a0,-1
    80005ff2:	b7fd                	j	80005fe0 <sys_chdir+0x5c>
    iunlockput(ip);
    80005ff4:	8526                	mv	a0,s1
    80005ff6:	b07fd0ef          	jal	80003afc <iunlockput>
    end_op();
    80005ffa:	80ffe0ef          	jal	80004808 <end_op>
    return -1;
    80005ffe:	557d                	li	a0,-1
    80006000:	64aa                	ld	s1,136(sp)
    80006002:	bff9                	j	80005fe0 <sys_chdir+0x5c>

0000000080006004 <sys_exec>:

uint64
sys_exec(void)
{
    80006004:	7121                	addi	sp,sp,-448
    80006006:	ff06                	sd	ra,440(sp)
    80006008:	fb22                	sd	s0,432(sp)
    8000600a:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000600c:	e4840593          	addi	a1,s0,-440
    80006010:	4505                	li	a0,1
    80006012:	827fc0ef          	jal	80002838 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006016:	08000613          	li	a2,128
    8000601a:	f5040593          	addi	a1,s0,-176
    8000601e:	4501                	li	a0,0
    80006020:	835fc0ef          	jal	80002854 <argstr>
    80006024:	87aa                	mv	a5,a0
    return -1;
    80006026:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006028:	0c07c463          	bltz	a5,800060f0 <sys_exec+0xec>
    8000602c:	f726                	sd	s1,424(sp)
    8000602e:	f34a                	sd	s2,416(sp)
    80006030:	ef4e                	sd	s3,408(sp)
    80006032:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80006034:	10000613          	li	a2,256
    80006038:	4581                	li	a1,0
    8000603a:	e5040513          	addi	a0,s0,-432
    8000603e:	c97fa0ef          	jal	80000cd4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006042:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80006046:	89a6                	mv	s3,s1
    80006048:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000604a:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000604e:	00391513          	slli	a0,s2,0x3
    80006052:	e4040593          	addi	a1,s0,-448
    80006056:	e4843783          	ld	a5,-440(s0)
    8000605a:	953e                	add	a0,a0,a5
    8000605c:	f36fc0ef          	jal	80002792 <fetchaddr>
    80006060:	02054663          	bltz	a0,8000608c <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80006064:	e4043783          	ld	a5,-448(s0)
    80006068:	c3a9                	beqz	a5,800060aa <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000606a:	ac7fa0ef          	jal	80000b30 <kalloc>
    8000606e:	85aa                	mv	a1,a0
    80006070:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006074:	cd01                	beqz	a0,8000608c <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006076:	6605                	lui	a2,0x1
    80006078:	e4043503          	ld	a0,-448(s0)
    8000607c:	f60fc0ef          	jal	800027dc <fetchstr>
    80006080:	00054663          	bltz	a0,8000608c <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80006084:	0905                	addi	s2,s2,1
    80006086:	09a1                	addi	s3,s3,8
    80006088:	fd4913e3          	bne	s2,s4,8000604e <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000608c:	f5040913          	addi	s2,s0,-176
    80006090:	6088                	ld	a0,0(s1)
    80006092:	c931                	beqz	a0,800060e6 <sys_exec+0xe2>
    kfree(argv[i]);
    80006094:	9bbfa0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006098:	04a1                	addi	s1,s1,8
    8000609a:	ff249be3          	bne	s1,s2,80006090 <sys_exec+0x8c>
  return -1;
    8000609e:	557d                	li	a0,-1
    800060a0:	74ba                	ld	s1,424(sp)
    800060a2:	791a                	ld	s2,416(sp)
    800060a4:	69fa                	ld	s3,408(sp)
    800060a6:	6a5a                	ld	s4,400(sp)
    800060a8:	a0a1                	j	800060f0 <sys_exec+0xec>
      argv[i] = 0;
    800060aa:	0009079b          	sext.w	a5,s2
    800060ae:	078e                	slli	a5,a5,0x3
    800060b0:	fd078793          	addi	a5,a5,-48
    800060b4:	97a2                	add	a5,a5,s0
    800060b6:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800060ba:	e5040593          	addi	a1,s0,-432
    800060be:	f5040513          	addi	a0,s0,-176
    800060c2:	ba8ff0ef          	jal	8000546a <kexec>
    800060c6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060c8:	f5040993          	addi	s3,s0,-176
    800060cc:	6088                	ld	a0,0(s1)
    800060ce:	c511                	beqz	a0,800060da <sys_exec+0xd6>
    kfree(argv[i]);
    800060d0:	97ffa0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060d4:	04a1                	addi	s1,s1,8
    800060d6:	ff349be3          	bne	s1,s3,800060cc <sys_exec+0xc8>
  return ret;
    800060da:	854a                	mv	a0,s2
    800060dc:	74ba                	ld	s1,424(sp)
    800060de:	791a                	ld	s2,416(sp)
    800060e0:	69fa                	ld	s3,408(sp)
    800060e2:	6a5a                	ld	s4,400(sp)
    800060e4:	a031                	j	800060f0 <sys_exec+0xec>
  return -1;
    800060e6:	557d                	li	a0,-1
    800060e8:	74ba                	ld	s1,424(sp)
    800060ea:	791a                	ld	s2,416(sp)
    800060ec:	69fa                	ld	s3,408(sp)
    800060ee:	6a5a                	ld	s4,400(sp)
}
    800060f0:	70fa                	ld	ra,440(sp)
    800060f2:	745a                	ld	s0,432(sp)
    800060f4:	6139                	addi	sp,sp,448
    800060f6:	8082                	ret

00000000800060f8 <sys_pipe>:

uint64
sys_pipe(void)
{
    800060f8:	7139                	addi	sp,sp,-64
    800060fa:	fc06                	sd	ra,56(sp)
    800060fc:	f822                	sd	s0,48(sp)
    800060fe:	f426                	sd	s1,40(sp)
    80006100:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006102:	807fb0ef          	jal	80001908 <myproc>
    80006106:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006108:	fd840593          	addi	a1,s0,-40
    8000610c:	4501                	li	a0,0
    8000610e:	f2afc0ef          	jal	80002838 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006112:	fc840593          	addi	a1,s0,-56
    80006116:	fd040513          	addi	a0,s0,-48
    8000611a:	852ff0ef          	jal	8000516c <pipealloc>
    return -1;
    8000611e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006120:	0a054463          	bltz	a0,800061c8 <sys_pipe+0xd0>
  fd0 = -1;
    80006124:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006128:	fd043503          	ld	a0,-48(s0)
    8000612c:	f08ff0ef          	jal	80005834 <fdalloc>
    80006130:	fca42223          	sw	a0,-60(s0)
    80006134:	08054163          	bltz	a0,800061b6 <sys_pipe+0xbe>
    80006138:	fc843503          	ld	a0,-56(s0)
    8000613c:	ef8ff0ef          	jal	80005834 <fdalloc>
    80006140:	fca42023          	sw	a0,-64(s0)
    80006144:	06054063          	bltz	a0,800061a4 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006148:	4691                	li	a3,4
    8000614a:	fc440613          	addi	a2,s0,-60
    8000614e:	fd843583          	ld	a1,-40(s0)
    80006152:	68a8                	ld	a0,80(s1)
    80006154:	cc8fb0ef          	jal	8000161c <copyout>
    80006158:	00054e63          	bltz	a0,80006174 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000615c:	4691                	li	a3,4
    8000615e:	fc040613          	addi	a2,s0,-64
    80006162:	fd843583          	ld	a1,-40(s0)
    80006166:	0591                	addi	a1,a1,4
    80006168:	68a8                	ld	a0,80(s1)
    8000616a:	cb2fb0ef          	jal	8000161c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000616e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006170:	04055c63          	bgez	a0,800061c8 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80006174:	fc442783          	lw	a5,-60(s0)
    80006178:	07e9                	addi	a5,a5,26
    8000617a:	078e                	slli	a5,a5,0x3
    8000617c:	97a6                	add	a5,a5,s1
    8000617e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006182:	fc042783          	lw	a5,-64(s0)
    80006186:	07e9                	addi	a5,a5,26
    80006188:	078e                	slli	a5,a5,0x3
    8000618a:	94be                	add	s1,s1,a5
    8000618c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006190:	fd043503          	ld	a0,-48(s0)
    80006194:	c65fe0ef          	jal	80004df8 <fileclose>
    fileclose(wf);
    80006198:	fc843503          	ld	a0,-56(s0)
    8000619c:	c5dfe0ef          	jal	80004df8 <fileclose>
    return -1;
    800061a0:	57fd                	li	a5,-1
    800061a2:	a01d                	j	800061c8 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800061a4:	fc442783          	lw	a5,-60(s0)
    800061a8:	0007c763          	bltz	a5,800061b6 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800061ac:	07e9                	addi	a5,a5,26
    800061ae:	078e                	slli	a5,a5,0x3
    800061b0:	97a6                	add	a5,a5,s1
    800061b2:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800061b6:	fd043503          	ld	a0,-48(s0)
    800061ba:	c3ffe0ef          	jal	80004df8 <fileclose>
    fileclose(wf);
    800061be:	fc843503          	ld	a0,-56(s0)
    800061c2:	c37fe0ef          	jal	80004df8 <fileclose>
    return -1;
    800061c6:	57fd                	li	a5,-1
}
    800061c8:	853e                	mv	a0,a5
    800061ca:	70e2                	ld	ra,56(sp)
    800061cc:	7442                	ld	s0,48(sp)
    800061ce:	74a2                	ld	s1,40(sp)
    800061d0:	6121                	addi	sp,sp,64
    800061d2:	8082                	ret

00000000800061d4 <sys_fsread>:
uint64
sys_fsread(void)
{
    800061d4:	1101                	addi	sp,sp,-32
    800061d6:	ec06                	sd	ra,24(sp)
    800061d8:	e822                	sd	s0,16(sp)
    800061da:	1000                	addi	s0,sp,32
  uint64 uaddr;
  int max;

  argaddr(0, &uaddr);   // عنوان اليوزر
    800061dc:	fe840593          	addi	a1,s0,-24
    800061e0:	4501                	li	a0,0
    800061e2:	e56fc0ef          	jal	80002838 <argaddr>
  argint(1, &max);      // عدد العناصر
    800061e6:	fe440593          	addi	a1,s0,-28
    800061ea:	4505                	li	a0,1
    800061ec:	e30fc0ef          	jal	8000281c <argint>

  return fslog_read_many((struct fs_event *)uaddr, max);
    800061f0:	fe442583          	lw	a1,-28(s0)
    800061f4:	fe843503          	ld	a0,-24(s0)
    800061f8:	1e3000ef          	jal	80006bda <fslog_read_many>
    800061fc:	60e2                	ld	ra,24(sp)
    800061fe:	6442                	ld	s0,16(sp)
    80006200:	6105                	addi	sp,sp,32
    80006202:	8082                	ret
	...

0000000080006210 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80006210:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80006212:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80006214:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80006216:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80006218:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000621a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000621c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000621e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80006220:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80006222:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80006224:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80006226:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80006228:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000622a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000622c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000622e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80006230:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80006232:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80006234:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80006236:	c6cfc0ef          	jal	800026a2 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000623a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000623c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000623e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80006240:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80006242:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80006244:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80006246:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80006248:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000624a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000624c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000624e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80006250:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80006252:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80006254:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80006256:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80006258:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000625a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000625c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000625e:	10200073          	sret
	...

000000008000626e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000626e:	1141                	addi	sp,sp,-16
    80006270:	e422                	sd	s0,8(sp)
    80006272:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006274:	0c0007b7          	lui	a5,0xc000
    80006278:	4705                	li	a4,1
    8000627a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000627c:	0c0007b7          	lui	a5,0xc000
    80006280:	c3d8                	sw	a4,4(a5)
}
    80006282:	6422                	ld	s0,8(sp)
    80006284:	0141                	addi	sp,sp,16
    80006286:	8082                	ret

0000000080006288 <plicinithart>:

void
plicinithart(void)
{
    80006288:	1141                	addi	sp,sp,-16
    8000628a:	e406                	sd	ra,8(sp)
    8000628c:	e022                	sd	s0,0(sp)
    8000628e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006290:	e4cfb0ef          	jal	800018dc <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006294:	0085171b          	slliw	a4,a0,0x8
    80006298:	0c0027b7          	lui	a5,0xc002
    8000629c:	97ba                	add	a5,a5,a4
    8000629e:	40200713          	li	a4,1026
    800062a2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800062a6:	00d5151b          	slliw	a0,a0,0xd
    800062aa:	0c2017b7          	lui	a5,0xc201
    800062ae:	97aa                	add	a5,a5,a0
    800062b0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800062b4:	60a2                	ld	ra,8(sp)
    800062b6:	6402                	ld	s0,0(sp)
    800062b8:	0141                	addi	sp,sp,16
    800062ba:	8082                	ret

00000000800062bc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800062bc:	1141                	addi	sp,sp,-16
    800062be:	e406                	sd	ra,8(sp)
    800062c0:	e022                	sd	s0,0(sp)
    800062c2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062c4:	e18fb0ef          	jal	800018dc <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800062c8:	00d5151b          	slliw	a0,a0,0xd
    800062cc:	0c2017b7          	lui	a5,0xc201
    800062d0:	97aa                	add	a5,a5,a0
  return irq;
}
    800062d2:	43c8                	lw	a0,4(a5)
    800062d4:	60a2                	ld	ra,8(sp)
    800062d6:	6402                	ld	s0,0(sp)
    800062d8:	0141                	addi	sp,sp,16
    800062da:	8082                	ret

00000000800062dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800062dc:	1101                	addi	sp,sp,-32
    800062de:	ec06                	sd	ra,24(sp)
    800062e0:	e822                	sd	s0,16(sp)
    800062e2:	e426                	sd	s1,8(sp)
    800062e4:	1000                	addi	s0,sp,32
    800062e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800062e8:	df4fb0ef          	jal	800018dc <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800062ec:	00d5151b          	slliw	a0,a0,0xd
    800062f0:	0c2017b7          	lui	a5,0xc201
    800062f4:	97aa                	add	a5,a5,a0
    800062f6:	c3c4                	sw	s1,4(a5)
}
    800062f8:	60e2                	ld	ra,24(sp)
    800062fa:	6442                	ld	s0,16(sp)
    800062fc:	64a2                	ld	s1,8(sp)
    800062fe:	6105                	addi	sp,sp,32
    80006300:	8082                	ret

0000000080006302 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006302:	1141                	addi	sp,sp,-16
    80006304:	e406                	sd	ra,8(sp)
    80006306:	e022                	sd	s0,0(sp)
    80006308:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000630a:	479d                	li	a5,7
    8000630c:	04a7ca63          	blt	a5,a0,80006360 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80006310:	0001c797          	auipc	a5,0x1c
    80006314:	fe878793          	addi	a5,a5,-24 # 800222f8 <disk>
    80006318:	97aa                	add	a5,a5,a0
    8000631a:	0187c783          	lbu	a5,24(a5)
    8000631e:	e7b9                	bnez	a5,8000636c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006320:	00451693          	slli	a3,a0,0x4
    80006324:	0001c797          	auipc	a5,0x1c
    80006328:	fd478793          	addi	a5,a5,-44 # 800222f8 <disk>
    8000632c:	6398                	ld	a4,0(a5)
    8000632e:	9736                	add	a4,a4,a3
    80006330:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006334:	6398                	ld	a4,0(a5)
    80006336:	9736                	add	a4,a4,a3
    80006338:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000633c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006340:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006344:	97aa                	add	a5,a5,a0
    80006346:	4705                	li	a4,1
    80006348:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000634c:	0001c517          	auipc	a0,0x1c
    80006350:	fc450513          	addi	a0,a0,-60 # 80022310 <disk+0x18>
    80006354:	c11fb0ef          	jal	80001f64 <wakeup>
}
    80006358:	60a2                	ld	ra,8(sp)
    8000635a:	6402                	ld	s0,0(sp)
    8000635c:	0141                	addi	sp,sp,16
    8000635e:	8082                	ret
    panic("free_desc 1");
    80006360:	00003517          	auipc	a0,0x3
    80006364:	ae050513          	addi	a0,a0,-1312 # 80008e40 <etext+0xe40>
    80006368:	caafa0ef          	jal	80000812 <panic>
    panic("free_desc 2");
    8000636c:	00003517          	auipc	a0,0x3
    80006370:	ae450513          	addi	a0,a0,-1308 # 80008e50 <etext+0xe50>
    80006374:	c9efa0ef          	jal	80000812 <panic>

0000000080006378 <virtio_disk_init>:
{
    80006378:	1101                	addi	sp,sp,-32
    8000637a:	ec06                	sd	ra,24(sp)
    8000637c:	e822                	sd	s0,16(sp)
    8000637e:	e426                	sd	s1,8(sp)
    80006380:	e04a                	sd	s2,0(sp)
    80006382:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006384:	00003597          	auipc	a1,0x3
    80006388:	adc58593          	addi	a1,a1,-1316 # 80008e60 <etext+0xe60>
    8000638c:	0001c517          	auipc	a0,0x1c
    80006390:	09450513          	addi	a0,a0,148 # 80022420 <disk+0x128>
    80006394:	fecfa0ef          	jal	80000b80 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006398:	100017b7          	lui	a5,0x10001
    8000639c:	4398                	lw	a4,0(a5)
    8000639e:	2701                	sext.w	a4,a4
    800063a0:	747277b7          	lui	a5,0x74727
    800063a4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800063a8:	18f71063          	bne	a4,a5,80006528 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063ac:	100017b7          	lui	a5,0x10001
    800063b0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800063b2:	439c                	lw	a5,0(a5)
    800063b4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063b6:	4709                	li	a4,2
    800063b8:	16e79863          	bne	a5,a4,80006528 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063bc:	100017b7          	lui	a5,0x10001
    800063c0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800063c2:	439c                	lw	a5,0(a5)
    800063c4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063c6:	16e79163          	bne	a5,a4,80006528 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800063ca:	100017b7          	lui	a5,0x10001
    800063ce:	47d8                	lw	a4,12(a5)
    800063d0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063d2:	554d47b7          	lui	a5,0x554d4
    800063d6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800063da:	14f71763          	bne	a4,a5,80006528 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063de:	100017b7          	lui	a5,0x10001
    800063e2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063e6:	4705                	li	a4,1
    800063e8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063ea:	470d                	li	a4,3
    800063ec:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800063ee:	10001737          	lui	a4,0x10001
    800063f2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800063f4:	c7ffe737          	lui	a4,0xc7ffe
    800063f8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47f9c2c7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063fc:	8ef9                	and	a3,a3,a4
    800063fe:	10001737          	lui	a4,0x10001
    80006402:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006404:	472d                	li	a4,11
    80006406:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006408:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000640c:	439c                	lw	a5,0(a5)
    8000640e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006412:	8ba1                	andi	a5,a5,8
    80006414:	12078063          	beqz	a5,80006534 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006418:	100017b7          	lui	a5,0x10001
    8000641c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006420:	100017b7          	lui	a5,0x10001
    80006424:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006428:	439c                	lw	a5,0(a5)
    8000642a:	2781                	sext.w	a5,a5
    8000642c:	10079a63          	bnez	a5,80006540 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006430:	100017b7          	lui	a5,0x10001
    80006434:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006438:	439c                	lw	a5,0(a5)
    8000643a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000643c:	10078863          	beqz	a5,8000654c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80006440:	471d                	li	a4,7
    80006442:	10f77b63          	bgeu	a4,a5,80006558 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80006446:	eeafa0ef          	jal	80000b30 <kalloc>
    8000644a:	0001c497          	auipc	s1,0x1c
    8000644e:	eae48493          	addi	s1,s1,-338 # 800222f8 <disk>
    80006452:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006454:	edcfa0ef          	jal	80000b30 <kalloc>
    80006458:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000645a:	ed6fa0ef          	jal	80000b30 <kalloc>
    8000645e:	87aa                	mv	a5,a0
    80006460:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006462:	6088                	ld	a0,0(s1)
    80006464:	10050063          	beqz	a0,80006564 <virtio_disk_init+0x1ec>
    80006468:	0001c717          	auipc	a4,0x1c
    8000646c:	e9873703          	ld	a4,-360(a4) # 80022300 <disk+0x8>
    80006470:	0e070a63          	beqz	a4,80006564 <virtio_disk_init+0x1ec>
    80006474:	0e078863          	beqz	a5,80006564 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80006478:	6605                	lui	a2,0x1
    8000647a:	4581                	li	a1,0
    8000647c:	859fa0ef          	jal	80000cd4 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006480:	0001c497          	auipc	s1,0x1c
    80006484:	e7848493          	addi	s1,s1,-392 # 800222f8 <disk>
    80006488:	6605                	lui	a2,0x1
    8000648a:	4581                	li	a1,0
    8000648c:	6488                	ld	a0,8(s1)
    8000648e:	847fa0ef          	jal	80000cd4 <memset>
  memset(disk.used, 0, PGSIZE);
    80006492:	6605                	lui	a2,0x1
    80006494:	4581                	li	a1,0
    80006496:	6888                	ld	a0,16(s1)
    80006498:	83dfa0ef          	jal	80000cd4 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000649c:	100017b7          	lui	a5,0x10001
    800064a0:	4721                	li	a4,8
    800064a2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800064a4:	4098                	lw	a4,0(s1)
    800064a6:	100017b7          	lui	a5,0x10001
    800064aa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800064ae:	40d8                	lw	a4,4(s1)
    800064b0:	100017b7          	lui	a5,0x10001
    800064b4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800064b8:	649c                	ld	a5,8(s1)
    800064ba:	0007869b          	sext.w	a3,a5
    800064be:	10001737          	lui	a4,0x10001
    800064c2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800064c6:	9781                	srai	a5,a5,0x20
    800064c8:	10001737          	lui	a4,0x10001
    800064cc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800064d0:	689c                	ld	a5,16(s1)
    800064d2:	0007869b          	sext.w	a3,a5
    800064d6:	10001737          	lui	a4,0x10001
    800064da:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800064de:	9781                	srai	a5,a5,0x20
    800064e0:	10001737          	lui	a4,0x10001
    800064e4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800064e8:	10001737          	lui	a4,0x10001
    800064ec:	4785                	li	a5,1
    800064ee:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800064f0:	00f48c23          	sb	a5,24(s1)
    800064f4:	00f48ca3          	sb	a5,25(s1)
    800064f8:	00f48d23          	sb	a5,26(s1)
    800064fc:	00f48da3          	sb	a5,27(s1)
    80006500:	00f48e23          	sb	a5,28(s1)
    80006504:	00f48ea3          	sb	a5,29(s1)
    80006508:	00f48f23          	sb	a5,30(s1)
    8000650c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006510:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006514:	100017b7          	lui	a5,0x10001
    80006518:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000651c:	60e2                	ld	ra,24(sp)
    8000651e:	6442                	ld	s0,16(sp)
    80006520:	64a2                	ld	s1,8(sp)
    80006522:	6902                	ld	s2,0(sp)
    80006524:	6105                	addi	sp,sp,32
    80006526:	8082                	ret
    panic("could not find virtio disk");
    80006528:	00003517          	auipc	a0,0x3
    8000652c:	94850513          	addi	a0,a0,-1720 # 80008e70 <etext+0xe70>
    80006530:	ae2fa0ef          	jal	80000812 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006534:	00003517          	auipc	a0,0x3
    80006538:	95c50513          	addi	a0,a0,-1700 # 80008e90 <etext+0xe90>
    8000653c:	ad6fa0ef          	jal	80000812 <panic>
    panic("virtio disk should not be ready");
    80006540:	00003517          	auipc	a0,0x3
    80006544:	97050513          	addi	a0,a0,-1680 # 80008eb0 <etext+0xeb0>
    80006548:	acafa0ef          	jal	80000812 <panic>
    panic("virtio disk has no queue 0");
    8000654c:	00003517          	auipc	a0,0x3
    80006550:	98450513          	addi	a0,a0,-1660 # 80008ed0 <etext+0xed0>
    80006554:	abefa0ef          	jal	80000812 <panic>
    panic("virtio disk max queue too short");
    80006558:	00003517          	auipc	a0,0x3
    8000655c:	99850513          	addi	a0,a0,-1640 # 80008ef0 <etext+0xef0>
    80006560:	ab2fa0ef          	jal	80000812 <panic>
    panic("virtio disk kalloc");
    80006564:	00003517          	auipc	a0,0x3
    80006568:	9ac50513          	addi	a0,a0,-1620 # 80008f10 <etext+0xf10>
    8000656c:	aa6fa0ef          	jal	80000812 <panic>

0000000080006570 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006570:	7159                	addi	sp,sp,-112
    80006572:	f486                	sd	ra,104(sp)
    80006574:	f0a2                	sd	s0,96(sp)
    80006576:	eca6                	sd	s1,88(sp)
    80006578:	e8ca                	sd	s2,80(sp)
    8000657a:	e4ce                	sd	s3,72(sp)
    8000657c:	e0d2                	sd	s4,64(sp)
    8000657e:	fc56                	sd	s5,56(sp)
    80006580:	f85a                	sd	s6,48(sp)
    80006582:	f45e                	sd	s7,40(sp)
    80006584:	f062                	sd	s8,32(sp)
    80006586:	ec66                	sd	s9,24(sp)
    80006588:	1880                	addi	s0,sp,112
    8000658a:	8a2a                	mv	s4,a0
    8000658c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000658e:	00c52c83          	lw	s9,12(a0)
    80006592:	001c9c9b          	slliw	s9,s9,0x1
    80006596:	1c82                	slli	s9,s9,0x20
    80006598:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000659c:	0001c517          	auipc	a0,0x1c
    800065a0:	e8450513          	addi	a0,a0,-380 # 80022420 <disk+0x128>
    800065a4:	e5cfa0ef          	jal	80000c00 <acquire>
  for(int i = 0; i < 3; i++){
    800065a8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800065aa:	44a1                	li	s1,8
      disk.free[i] = 0;
    800065ac:	0001cb17          	auipc	s6,0x1c
    800065b0:	d4cb0b13          	addi	s6,s6,-692 # 800222f8 <disk>
  for(int i = 0; i < 3; i++){
    800065b4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065b6:	0001cc17          	auipc	s8,0x1c
    800065ba:	e6ac0c13          	addi	s8,s8,-406 # 80022420 <disk+0x128>
    800065be:	a8b9                	j	8000661c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800065c0:	00fb0733          	add	a4,s6,a5
    800065c4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800065c8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800065ca:	0207c563          	bltz	a5,800065f4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800065ce:	2905                	addiw	s2,s2,1
    800065d0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800065d2:	05590963          	beq	s2,s5,80006624 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800065d6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800065d8:	0001c717          	auipc	a4,0x1c
    800065dc:	d2070713          	addi	a4,a4,-736 # 800222f8 <disk>
    800065e0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800065e2:	01874683          	lbu	a3,24(a4)
    800065e6:	fee9                	bnez	a3,800065c0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800065e8:	2785                	addiw	a5,a5,1
    800065ea:	0705                	addi	a4,a4,1
    800065ec:	fe979be3          	bne	a5,s1,800065e2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800065f0:	57fd                	li	a5,-1
    800065f2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800065f4:	01205d63          	blez	s2,8000660e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800065f8:	f9042503          	lw	a0,-112(s0)
    800065fc:	d07ff0ef          	jal	80006302 <free_desc>
      for(int j = 0; j < i; j++)
    80006600:	4785                	li	a5,1
    80006602:	0127d663          	bge	a5,s2,8000660e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006606:	f9442503          	lw	a0,-108(s0)
    8000660a:	cf9ff0ef          	jal	80006302 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000660e:	85e2                	mv	a1,s8
    80006610:	0001c517          	auipc	a0,0x1c
    80006614:	d0050513          	addi	a0,a0,-768 # 80022310 <disk+0x18>
    80006618:	901fb0ef          	jal	80001f18 <sleep>
  for(int i = 0; i < 3; i++){
    8000661c:	f9040613          	addi	a2,s0,-112
    80006620:	894e                	mv	s2,s3
    80006622:	bf55                	j	800065d6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006624:	f9042503          	lw	a0,-112(s0)
    80006628:	00451693          	slli	a3,a0,0x4

  if(write)
    8000662c:	0001c797          	auipc	a5,0x1c
    80006630:	ccc78793          	addi	a5,a5,-820 # 800222f8 <disk>
    80006634:	00a50713          	addi	a4,a0,10
    80006638:	0712                	slli	a4,a4,0x4
    8000663a:	973e                	add	a4,a4,a5
    8000663c:	01703633          	snez	a2,s7
    80006640:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006642:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006646:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000664a:	6398                	ld	a4,0(a5)
    8000664c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000664e:	0a868613          	addi	a2,a3,168
    80006652:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006654:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006656:	6390                	ld	a2,0(a5)
    80006658:	00d605b3          	add	a1,a2,a3
    8000665c:	4741                	li	a4,16
    8000665e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006660:	4805                	li	a6,1
    80006662:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006666:	f9442703          	lw	a4,-108(s0)
    8000666a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000666e:	0712                	slli	a4,a4,0x4
    80006670:	963a                	add	a2,a2,a4
    80006672:	058a0593          	addi	a1,s4,88
    80006676:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006678:	0007b883          	ld	a7,0(a5)
    8000667c:	9746                	add	a4,a4,a7
    8000667e:	40000613          	li	a2,1024
    80006682:	c710                	sw	a2,8(a4)
  if(write)
    80006684:	001bb613          	seqz	a2,s7
    80006688:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000668c:	00166613          	ori	a2,a2,1
    80006690:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006694:	f9842583          	lw	a1,-104(s0)
    80006698:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000669c:	00250613          	addi	a2,a0,2
    800066a0:	0612                	slli	a2,a2,0x4
    800066a2:	963e                	add	a2,a2,a5
    800066a4:	577d                	li	a4,-1
    800066a6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800066aa:	0592                	slli	a1,a1,0x4
    800066ac:	98ae                	add	a7,a7,a1
    800066ae:	03068713          	addi	a4,a3,48
    800066b2:	973e                	add	a4,a4,a5
    800066b4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800066b8:	6398                	ld	a4,0(a5)
    800066ba:	972e                	add	a4,a4,a1
    800066bc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800066c0:	4689                	li	a3,2
    800066c2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800066c6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800066ca:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800066ce:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800066d2:	6794                	ld	a3,8(a5)
    800066d4:	0026d703          	lhu	a4,2(a3)
    800066d8:	8b1d                	andi	a4,a4,7
    800066da:	0706                	slli	a4,a4,0x1
    800066dc:	96ba                	add	a3,a3,a4
    800066de:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800066e2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800066e6:	6798                	ld	a4,8(a5)
    800066e8:	00275783          	lhu	a5,2(a4)
    800066ec:	2785                	addiw	a5,a5,1
    800066ee:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800066f2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800066f6:	100017b7          	lui	a5,0x10001
    800066fa:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800066fe:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006702:	0001c917          	auipc	s2,0x1c
    80006706:	d1e90913          	addi	s2,s2,-738 # 80022420 <disk+0x128>
  while(b->disk == 1) {
    8000670a:	4485                	li	s1,1
    8000670c:	01079a63          	bne	a5,a6,80006720 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80006710:	85ca                	mv	a1,s2
    80006712:	8552                	mv	a0,s4
    80006714:	805fb0ef          	jal	80001f18 <sleep>
  while(b->disk == 1) {
    80006718:	004a2783          	lw	a5,4(s4)
    8000671c:	fe978ae3          	beq	a5,s1,80006710 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80006720:	f9042903          	lw	s2,-112(s0)
    80006724:	00290713          	addi	a4,s2,2
    80006728:	0712                	slli	a4,a4,0x4
    8000672a:	0001c797          	auipc	a5,0x1c
    8000672e:	bce78793          	addi	a5,a5,-1074 # 800222f8 <disk>
    80006732:	97ba                	add	a5,a5,a4
    80006734:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006738:	0001c997          	auipc	s3,0x1c
    8000673c:	bc098993          	addi	s3,s3,-1088 # 800222f8 <disk>
    80006740:	00491713          	slli	a4,s2,0x4
    80006744:	0009b783          	ld	a5,0(s3)
    80006748:	97ba                	add	a5,a5,a4
    8000674a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000674e:	854a                	mv	a0,s2
    80006750:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006754:	bafff0ef          	jal	80006302 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006758:	8885                	andi	s1,s1,1
    8000675a:	f0fd                	bnez	s1,80006740 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000675c:	0001c517          	auipc	a0,0x1c
    80006760:	cc450513          	addi	a0,a0,-828 # 80022420 <disk+0x128>
    80006764:	d34fa0ef          	jal	80000c98 <release>
}
    80006768:	70a6                	ld	ra,104(sp)
    8000676a:	7406                	ld	s0,96(sp)
    8000676c:	64e6                	ld	s1,88(sp)
    8000676e:	6946                	ld	s2,80(sp)
    80006770:	69a6                	ld	s3,72(sp)
    80006772:	6a06                	ld	s4,64(sp)
    80006774:	7ae2                	ld	s5,56(sp)
    80006776:	7b42                	ld	s6,48(sp)
    80006778:	7ba2                	ld	s7,40(sp)
    8000677a:	7c02                	ld	s8,32(sp)
    8000677c:	6ce2                	ld	s9,24(sp)
    8000677e:	6165                	addi	sp,sp,112
    80006780:	8082                	ret

0000000080006782 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006782:	1101                	addi	sp,sp,-32
    80006784:	ec06                	sd	ra,24(sp)
    80006786:	e822                	sd	s0,16(sp)
    80006788:	e426                	sd	s1,8(sp)
    8000678a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000678c:	0001c497          	auipc	s1,0x1c
    80006790:	b6c48493          	addi	s1,s1,-1172 # 800222f8 <disk>
    80006794:	0001c517          	auipc	a0,0x1c
    80006798:	c8c50513          	addi	a0,a0,-884 # 80022420 <disk+0x128>
    8000679c:	c64fa0ef          	jal	80000c00 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800067a0:	100017b7          	lui	a5,0x10001
    800067a4:	53b8                	lw	a4,96(a5)
    800067a6:	8b0d                	andi	a4,a4,3
    800067a8:	100017b7          	lui	a5,0x10001
    800067ac:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800067ae:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800067b2:	689c                	ld	a5,16(s1)
    800067b4:	0204d703          	lhu	a4,32(s1)
    800067b8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800067bc:	04f70663          	beq	a4,a5,80006808 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800067c0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800067c4:	6898                	ld	a4,16(s1)
    800067c6:	0204d783          	lhu	a5,32(s1)
    800067ca:	8b9d                	andi	a5,a5,7
    800067cc:	078e                	slli	a5,a5,0x3
    800067ce:	97ba                	add	a5,a5,a4
    800067d0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800067d2:	00278713          	addi	a4,a5,2
    800067d6:	0712                	slli	a4,a4,0x4
    800067d8:	9726                	add	a4,a4,s1
    800067da:	01074703          	lbu	a4,16(a4)
    800067de:	e321                	bnez	a4,8000681e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800067e0:	0789                	addi	a5,a5,2
    800067e2:	0792                	slli	a5,a5,0x4
    800067e4:	97a6                	add	a5,a5,s1
    800067e6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800067e8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800067ec:	f78fb0ef          	jal	80001f64 <wakeup>

    disk.used_idx += 1;
    800067f0:	0204d783          	lhu	a5,32(s1)
    800067f4:	2785                	addiw	a5,a5,1
    800067f6:	17c2                	slli	a5,a5,0x30
    800067f8:	93c1                	srli	a5,a5,0x30
    800067fa:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800067fe:	6898                	ld	a4,16(s1)
    80006800:	00275703          	lhu	a4,2(a4)
    80006804:	faf71ee3          	bne	a4,a5,800067c0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006808:	0001c517          	auipc	a0,0x1c
    8000680c:	c1850513          	addi	a0,a0,-1000 # 80022420 <disk+0x128>
    80006810:	c88fa0ef          	jal	80000c98 <release>
}
    80006814:	60e2                	ld	ra,24(sp)
    80006816:	6442                	ld	s0,16(sp)
    80006818:	64a2                	ld	s1,8(sp)
    8000681a:	6105                	addi	sp,sp,32
    8000681c:	8082                	ret
      panic("virtio_disk_intr status");
    8000681e:	00002517          	auipc	a0,0x2
    80006822:	70a50513          	addi	a0,a0,1802 # 80008f28 <etext+0xf28>
    80006826:	fedf90ef          	jal	80000812 <panic>

000000008000682a <cslog_init>:
  safestrcpy(e->name, p->name, CS_NM);
}

void
cslog_init(void)
{
    8000682a:	1141                	addi	sp,sp,-16
    8000682c:	e406                	sd	ra,8(sp)
    8000682e:	e022                	sd	s0,0(sp)
    80006830:	0800                	addi	s0,sp,16
  ringbuf_init(&cs_rb, "cslog", sizeof(struct cs_event));
    80006832:	03000613          	li	a2,48
    80006836:	00002597          	auipc	a1,0x2
    8000683a:	70a58593          	addi	a1,a1,1802 # 80008f40 <etext+0xf40>
    8000683e:	0001c517          	auipc	a0,0x1c
    80006842:	bfa50513          	addi	a0,a0,-1030 # 80022438 <cs_rb>
    80006846:	1c6000ef          	jal	80006a0c <ringbuf_init>
  printf("CS sizeof(cs_event)=%ld RB_MAX_ELEM=%d\n", sizeof(struct cs_event), RB_MAX_ELEM);
    8000684a:	10000613          	li	a2,256
    8000684e:	03000593          	li	a1,48
    80006852:	00002517          	auipc	a0,0x2
    80006856:	6f650513          	addi	a0,a0,1782 # 80008f48 <etext+0xf48>
    8000685a:	cd3f90ef          	jal	8000052c <printf>
}
    8000685e:	60a2                	ld	ra,8(sp)
    80006860:	6402                	ld	s0,0(sp)
    80006862:	0141                	addi	sp,sp,16
    80006864:	8082                	ret

0000000080006866 <cslog_push>:

void
cslog_push(struct cs_event *e)
{
    80006866:	1141                	addi	sp,sp,-16
    80006868:	e406                	sd	ra,8(sp)
    8000686a:	e022                	sd	s0,0(sp)
    8000686c:	0800                	addi	s0,sp,16
    8000686e:	85aa                	mv	a1,a0
  e->seq = ++cs_seq;
    80006870:	00003717          	auipc	a4,0x3
    80006874:	88070713          	addi	a4,a4,-1920 # 800090f0 <cs_seq>
    80006878:	631c                	ld	a5,0(a4)
    8000687a:	0785                	addi	a5,a5,1
    8000687c:	e31c                	sd	a5,0(a4)
    8000687e:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    80006880:	0001c517          	auipc	a0,0x1c
    80006884:	bb850513          	addi	a0,a0,-1096 # 80022438 <cs_rb>
    80006888:	1b8000ef          	jal	80006a40 <ringbuf_push>
}
    8000688c:	60a2                	ld	ra,8(sp)
    8000688e:	6402                	ld	s0,0(sp)
    80006890:	0141                	addi	sp,sp,16
    80006892:	8082                	ret

0000000080006894 <cslog_read_many>:

int
cslog_read_many(struct cs_event *out, int max)
{
    80006894:	1141                	addi	sp,sp,-16
    80006896:	e406                	sd	ra,8(sp)
    80006898:	e022                	sd	s0,0(sp)
    8000689a:	0800                	addi	s0,sp,16
    8000689c:	862e                	mv	a2,a1
  return ringbuf_read_many(&cs_rb, out, max);
    8000689e:	85aa                	mv	a1,a0
    800068a0:	0001c517          	auipc	a0,0x1c
    800068a4:	b9850513          	addi	a0,a0,-1128 # 80022438 <cs_rb>
    800068a8:	204000ef          	jal	80006aac <ringbuf_read_many>
}
    800068ac:	60a2                	ld	ra,8(sp)
    800068ae:	6402                	ld	s0,0(sp)
    800068b0:	0141                	addi	sp,sp,16
    800068b2:	8082                	ret

00000000800068b4 <cslog_run_start>:

void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
    800068b4:	c14d                	beqz	a0,80006956 <cslog_run_start+0xa2>
{
    800068b6:	715d                	addi	sp,sp,-80
    800068b8:	e486                	sd	ra,72(sp)
    800068ba:	e0a2                	sd	s0,64(sp)
    800068bc:	fc26                	sd	s1,56(sp)
    800068be:	0880                	addi	s0,sp,80
    800068c0:	84aa                	mv	s1,a0
  if(p->pid <= 0) return;
    800068c2:	591c                	lw	a5,48(a0)
    800068c4:	00f05563          	blez	a5,800068ce <cslog_run_start+0x1a>
  if(p->name[0] == 0) return;
    800068c8:	15854783          	lbu	a5,344(a0)
    800068cc:	e791                	bnez	a5,800068d8 <cslog_run_start+0x24>

  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
    800068ce:	60a6                	ld	ra,72(sp)
    800068d0:	6406                	ld	s0,64(sp)
    800068d2:	74e2                	ld	s1,56(sp)
    800068d4:	6161                	addi	sp,sp,80
    800068d6:	8082                	ret
    800068d8:	f84a                	sd	s2,48(sp)
  if(strncmp(p->name, "cscat", 5) == 0) return;
    800068da:	15850913          	addi	s2,a0,344
    800068de:	4615                	li	a2,5
    800068e0:	00002597          	auipc	a1,0x2
    800068e4:	69058593          	addi	a1,a1,1680 # 80008f70 <etext+0xf70>
    800068e8:	854a                	mv	a0,s2
    800068ea:	cb6fa0ef          	jal	80000da0 <strncmp>
    800068ee:	e119                	bnez	a0,800068f4 <cslog_run_start+0x40>
    800068f0:	7942                	ld	s2,48(sp)
    800068f2:	bff1                	j	800068ce <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    800068f4:	4621                	li	a2,8
    800068f6:	00002597          	auipc	a1,0x2
    800068fa:	68258593          	addi	a1,a1,1666 # 80008f78 <etext+0xf78>
    800068fe:	854a                	mv	a0,s2
    80006900:	ca0fa0ef          	jal	80000da0 <strncmp>
    80006904:	e119                	bnez	a0,8000690a <cslog_run_start+0x56>
    80006906:	7942                	ld	s2,48(sp)
    80006908:	b7d9                	j	800068ce <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    8000690a:	03000613          	li	a2,48
    8000690e:	4581                	li	a1,0
    80006910:	fb040513          	addi	a0,s0,-80
    80006914:	bc0fa0ef          	jal	80000cd4 <memset>
  e->ticks = ticks;
    80006918:	00002797          	auipc	a5,0x2
    8000691c:	7d07a783          	lw	a5,2000(a5) # 800090e8 <ticks>
    80006920:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    80006924:	fb9fa0ef          	jal	800018dc <cpuid>
    80006928:	faa42e23          	sw	a0,-68(s0)
  e->pid   = p->pid;
    8000692c:	589c                	lw	a5,48(s1)
    8000692e:	fcf42223          	sw	a5,-60(s0)
  e->state = p->state;
    80006932:	4c9c                	lw	a5,24(s1)
    80006934:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e->name, p->name, CS_NM);
    80006938:	4641                	li	a2,16
    8000693a:	85ca                	mv	a1,s2
    8000693c:	fcc40513          	addi	a0,s0,-52
    80006940:	cd2fa0ef          	jal	80000e12 <safestrcpy>
  e.type = CS_RUN_START;
    80006944:	4785                	li	a5,1
    80006946:	fcf42023          	sw	a5,-64(s0)
  cslog_push(&e);
    8000694a:	fb040513          	addi	a0,s0,-80
    8000694e:	f19ff0ef          	jal	80006866 <cslog_push>
    80006952:	7942                	ld	s2,48(sp)
    80006954:	bfad                	j	800068ce <cslog_run_start+0x1a>
    80006956:	8082                	ret

0000000080006958 <sys_csread>:
#include "cslog.h"


uint64
sys_csread(void)
{
    80006958:	81010113          	addi	sp,sp,-2032
    8000695c:	7e113423          	sd	ra,2024(sp)
    80006960:	7e813023          	sd	s0,2016(sp)
    80006964:	7c913c23          	sd	s1,2008(sp)
    80006968:	7d213823          	sd	s2,2000(sp)
    8000696c:	7f010413          	addi	s0,sp,2032
    80006970:	bb010113          	addi	sp,sp,-1104
  uint64 uaddr = 0;
    80006974:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80006978:	fc042a23          	sw	zero,-44(s0)

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
    8000697c:	fd840593          	addi	a1,s0,-40
    80006980:	4501                	li	a0,0
    80006982:	eb7fb0ef          	jal	80002838 <argaddr>
  argint(1, &max);
    80006986:	fd440593          	addi	a1,s0,-44
    8000698a:	4505                	li	a0,1
    8000698c:	e91fb0ef          	jal	8000281c <argint>

  if(max <= 0) return 0;
    80006990:	fd442783          	lw	a5,-44(s0)
    80006994:	4501                	li	a0,0
    80006996:	04f05c63          	blez	a5,800069ee <sys_csread+0x96>
  if(max > 64) max = 64;
    8000699a:	04000713          	li	a4,64
    8000699e:	00f75663          	bge	a4,a5,800069aa <sys_csread+0x52>
    800069a2:	04000793          	li	a5,64
    800069a6:	fcf42a23          	sw	a5,-44(s0)

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);
    800069aa:	77fd                	lui	a5,0xfffff
    800069ac:	3d078793          	addi	a5,a5,976 # fffffffffffff3d0 <end+0xffffffff7ff9cf38>
    800069b0:	97a2                	add	a5,a5,s0
    800069b2:	797d                	lui	s2,0xfffff
    800069b4:	3c890713          	addi	a4,s2,968 # fffffffffffff3c8 <end+0xffffffff7ff9cf30>
    800069b8:	9722                	add	a4,a4,s0
    800069ba:	e31c                	sd	a5,0(a4)
    800069bc:	fd442583          	lw	a1,-44(s0)
    800069c0:	6308                	ld	a0,0(a4)
    800069c2:	ed3ff0ef          	jal	80006894 <cslog_read_many>
    800069c6:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    800069c8:	f41fa0ef          	jal	80001908 <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    800069cc:	0014969b          	slliw	a3,s1,0x1
    800069d0:	9ea5                	addw	a3,a3,s1
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    800069d2:	0046969b          	slliw	a3,a3,0x4
    800069d6:	3c890793          	addi	a5,s2,968
    800069da:	97a2                	add	a5,a5,s0
    800069dc:	6390                	ld	a2,0(a5)
    800069de:	fd843583          	ld	a1,-40(s0)
    800069e2:	6928                	ld	a0,80(a0)
    800069e4:	c39fa0ef          	jal	8000161c <copyout>
    800069e8:	02054063          	bltz	a0,80006a08 <sys_csread+0xb0>
    return -1;

  return n;
    800069ec:	8526                	mv	a0,s1
}
    800069ee:	45010113          	addi	sp,sp,1104
    800069f2:	7e813083          	ld	ra,2024(sp)
    800069f6:	7e013403          	ld	s0,2016(sp)
    800069fa:	7d813483          	ld	s1,2008(sp)
    800069fe:	7d013903          	ld	s2,2000(sp)
    80006a02:	7f010113          	addi	sp,sp,2032
    80006a06:	8082                	ret
    return -1;
    80006a08:	557d                	li	a0,-1
    80006a0a:	b7d5                	j	800069ee <sys_csread+0x96>

0000000080006a0c <ringbuf_init>:
  return (void *)(rb->buf + idx * rb->elem_size);
}

void
ringbuf_init(struct ringbuf *rb, char *name, uint elem_size)
{
    80006a0c:	1101                	addi	sp,sp,-32
    80006a0e:	ec06                	sd	ra,24(sp)
    80006a10:	e822                	sd	s0,16(sp)
    80006a12:	e426                	sd	s1,8(sp)
    80006a14:	e04a                	sd	s2,0(sp)
    80006a16:	1000                	addi	s0,sp,32
    80006a18:	84aa                	mv	s1,a0
    80006a1a:	8932                	mv	s2,a2
  initlock(&rb->lock, name);
    80006a1c:	964fa0ef          	jal	80000b80 <initlock>
  rb->head = 0;
    80006a20:	0004ac23          	sw	zero,24(s1)
  rb->tail = 0;
    80006a24:	0004ae23          	sw	zero,28(s1)
  rb->count = 0;
    80006a28:	0204a023          	sw	zero,32(s1)
  rb->seq = 0;
    80006a2c:	0204b423          	sd	zero,40(s1)
  rb->elem_size = elem_size;
    80006a30:	0324a223          	sw	s2,36(s1)
}
    80006a34:	60e2                	ld	ra,24(sp)
    80006a36:	6442                	ld	s0,16(sp)
    80006a38:	64a2                	ld	s1,8(sp)
    80006a3a:	6902                	ld	s2,0(sp)
    80006a3c:	6105                	addi	sp,sp,32
    80006a3e:	8082                	ret

0000000080006a40 <ringbuf_push>:

int
ringbuf_push(struct ringbuf *rb, void *elem)
{
    80006a40:	1101                	addi	sp,sp,-32
    80006a42:	ec06                	sd	ra,24(sp)
    80006a44:	e822                	sd	s0,16(sp)
    80006a46:	e426                	sd	s1,8(sp)
    80006a48:	e04a                	sd	s2,0(sp)
    80006a4a:	1000                	addi	s0,sp,32
    80006a4c:	84aa                	mv	s1,a0
    80006a4e:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006a50:	9b0fa0ef          	jal	80000c00 <acquire>

  if(rb->count == RB_CAP){
    80006a54:	5098                	lw	a4,32(s1)
    80006a56:	20000793          	li	a5,512
    80006a5a:	04f70063          	beq	a4,a5,80006a9a <ringbuf_push+0x5a>
  return (void *)(rb->buf + idx * rb->elem_size);
    80006a5e:	50d0                	lw	a2,36(s1)
    80006a60:	03048513          	addi	a0,s1,48
    80006a64:	4c9c                	lw	a5,24(s1)
    80006a66:	02c787bb          	mulw	a5,a5,a2
    80006a6a:	1782                	slli	a5,a5,0x20
    80006a6c:	9381                	srli	a5,a5,0x20
    rb->tail = (rb->tail + 1) % RB_CAP;
    rb->count--;
  }

  memmove(slot_ptr(rb, rb->head), elem, rb->elem_size);
    80006a6e:	85ca                	mv	a1,s2
    80006a70:	953e                	add	a0,a0,a5
    80006a72:	abefa0ef          	jal	80000d30 <memmove>
  rb->head = (rb->head + 1) % RB_CAP;
    80006a76:	4c9c                	lw	a5,24(s1)
    80006a78:	2785                	addiw	a5,a5,1
    80006a7a:	1ff7f793          	andi	a5,a5,511
    80006a7e:	cc9c                	sw	a5,24(s1)
  rb->count++;
    80006a80:	509c                	lw	a5,32(s1)
    80006a82:	2785                	addiw	a5,a5,1
    80006a84:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80006a86:	8526                	mv	a0,s1
    80006a88:	a10fa0ef          	jal	80000c98 <release>
  return 0;
}
    80006a8c:	4501                	li	a0,0
    80006a8e:	60e2                	ld	ra,24(sp)
    80006a90:	6442                	ld	s0,16(sp)
    80006a92:	64a2                	ld	s1,8(sp)
    80006a94:	6902                	ld	s2,0(sp)
    80006a96:	6105                	addi	sp,sp,32
    80006a98:	8082                	ret
    rb->tail = (rb->tail + 1) % RB_CAP;
    80006a9a:	4cdc                	lw	a5,28(s1)
    80006a9c:	2785                	addiw	a5,a5,1
    80006a9e:	1ff7f793          	andi	a5,a5,511
    80006aa2:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80006aa4:	1ff00793          	li	a5,511
    80006aa8:	d09c                	sw	a5,32(s1)
    80006aaa:	bf55                	j	80006a5e <ringbuf_push+0x1e>

0000000080006aac <ringbuf_read_many>:

int
ringbuf_read_many(struct ringbuf *rb, void *out, int max)
{
    80006aac:	7139                	addi	sp,sp,-64
    80006aae:	fc06                	sd	ra,56(sp)
    80006ab0:	f822                	sd	s0,48(sp)
    80006ab2:	f04a                	sd	s2,32(sp)
    80006ab4:	0080                	addi	s0,sp,64
  int n = 0;
  char *dst = (char *)out;

  if(max <= 0)
    return 0;
    80006ab6:	4901                	li	s2,0
  if(max <= 0)
    80006ab8:	06c05163          	blez	a2,80006b1a <ringbuf_read_many+0x6e>
    80006abc:	f426                	sd	s1,40(sp)
    80006abe:	ec4e                	sd	s3,24(sp)
    80006ac0:	e852                	sd	s4,16(sp)
    80006ac2:	e456                	sd	s5,8(sp)
    80006ac4:	84aa                	mv	s1,a0
    80006ac6:	8a2e                	mv	s4,a1
    80006ac8:	89b2                	mv	s3,a2

  acquire(&rb->lock);
    80006aca:	936fa0ef          	jal	80000c00 <acquire>
  int n = 0;
    80006ace:	4901                	li	s2,0
  return (void *)(rb->buf + idx * rb->elem_size);
    80006ad0:	03048a93          	addi	s5,s1,48
  while(n < max && rb->count > 0){
    80006ad4:	509c                	lw	a5,32(s1)
    80006ad6:	cb9d                	beqz	a5,80006b0c <ringbuf_read_many+0x60>
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006ad8:	50d0                	lw	a2,36(s1)
  return (void *)(rb->buf + idx * rb->elem_size);
    80006ada:	4ccc                	lw	a1,28(s1)
    80006adc:	02c585bb          	mulw	a1,a1,a2
    80006ae0:	1582                	slli	a1,a1,0x20
    80006ae2:	9181                	srli	a1,a1,0x20
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006ae4:	02c9053b          	mulw	a0,s2,a2
    80006ae8:	1502                	slli	a0,a0,0x20
    80006aea:	9101                	srli	a0,a0,0x20
    80006aec:	95d6                	add	a1,a1,s5
    80006aee:	9552                	add	a0,a0,s4
    80006af0:	a40fa0ef          	jal	80000d30 <memmove>
    rb->tail = (rb->tail + 1) % RB_CAP;
    80006af4:	4cdc                	lw	a5,28(s1)
    80006af6:	2785                	addiw	a5,a5,1
    80006af8:	1ff7f793          	andi	a5,a5,511
    80006afc:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80006afe:	509c                	lw	a5,32(s1)
    80006b00:	37fd                	addiw	a5,a5,-1
    80006b02:	d09c                	sw	a5,32(s1)
    n++;
    80006b04:	2905                	addiw	s2,s2,1
  while(n < max && rb->count > 0){
    80006b06:	fd2997e3          	bne	s3,s2,80006ad4 <ringbuf_read_many+0x28>
    80006b0a:	894e                	mv	s2,s3
  }
  release(&rb->lock);
    80006b0c:	8526                	mv	a0,s1
    80006b0e:	98afa0ef          	jal	80000c98 <release>

  return n;
    80006b12:	74a2                	ld	s1,40(sp)
    80006b14:	69e2                	ld	s3,24(sp)
    80006b16:	6a42                	ld	s4,16(sp)
    80006b18:	6aa2                	ld	s5,8(sp)
}
    80006b1a:	854a                	mv	a0,s2
    80006b1c:	70e2                	ld	ra,56(sp)
    80006b1e:	7442                	ld	s0,48(sp)
    80006b20:	7902                	ld	s2,32(sp)
    80006b22:	6121                	addi	sp,sp,64
    80006b24:	8082                	ret

0000000080006b26 <ringbuf_pop>:

int
ringbuf_pop(struct ringbuf *rb, void *dst)
{
    80006b26:	1101                	addi	sp,sp,-32
    80006b28:	ec06                	sd	ra,24(sp)
    80006b2a:	e822                	sd	s0,16(sp)
    80006b2c:	e426                	sd	s1,8(sp)
    80006b2e:	e04a                	sd	s2,0(sp)
    80006b30:	1000                	addi	s0,sp,32
    80006b32:	84aa                	mv	s1,a0
    80006b34:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006b36:	8cafa0ef          	jal	80000c00 <acquire>

  if(rb->count == 0){
    80006b3a:	509c                	lw	a5,32(s1)
    80006b3c:	cf9d                	beqz	a5,80006b7a <ringbuf_pop+0x54>
  return (void *)(rb->buf + idx * rb->elem_size);
    80006b3e:	50d0                	lw	a2,36(s1)
    80006b40:	03048593          	addi	a1,s1,48
    80006b44:	4cdc                	lw	a5,28(s1)
    80006b46:	02c787bb          	mulw	a5,a5,a2
    80006b4a:	1782                	slli	a5,a5,0x20
    80006b4c:	9381                	srli	a5,a5,0x20
    release(&rb->lock);
    return -1;
  }

  memmove(dst, slot_ptr(rb, rb->tail), rb->elem_size);
    80006b4e:	95be                	add	a1,a1,a5
    80006b50:	854a                	mv	a0,s2
    80006b52:	9defa0ef          	jal	80000d30 <memmove>
  rb->tail = (rb->tail + 1) % RB_CAP;
    80006b56:	4cdc                	lw	a5,28(s1)
    80006b58:	2785                	addiw	a5,a5,1
    80006b5a:	1ff7f793          	andi	a5,a5,511
    80006b5e:	ccdc                	sw	a5,28(s1)
  rb->count--;
    80006b60:	509c                	lw	a5,32(s1)
    80006b62:	37fd                	addiw	a5,a5,-1
    80006b64:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80006b66:	8526                	mv	a0,s1
    80006b68:	930fa0ef          	jal	80000c98 <release>
  return 0;
    80006b6c:	4501                	li	a0,0
    80006b6e:	60e2                	ld	ra,24(sp)
    80006b70:	6442                	ld	s0,16(sp)
    80006b72:	64a2                	ld	s1,8(sp)
    80006b74:	6902                	ld	s2,0(sp)
    80006b76:	6105                	addi	sp,sp,32
    80006b78:	8082                	ret
    release(&rb->lock);
    80006b7a:	8526                	mv	a0,s1
    80006b7c:	91cfa0ef          	jal	80000c98 <release>
    return -1;
    80006b80:	557d                	li	a0,-1
    80006b82:	b7f5                	j	80006b6e <ringbuf_pop+0x48>

0000000080006b84 <fslog_init>:
static struct ringbuf fs_rb;
static uint64 fs_seq = 0;

void
fslog_init(void)
{
    80006b84:	1141                	addi	sp,sp,-16
    80006b86:	e406                	sd	ra,8(sp)
    80006b88:	e022                	sd	s0,0(sp)
    80006b8a:	0800                	addi	s0,sp,16
  // تهيئة الـ ring buffer الخاص بـ أحداث نظام الملفات
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
    80006b8c:	1c800613          	li	a2,456
    80006b90:	00002597          	auipc	a1,0x2
    80006b94:	3f858593          	addi	a1,a1,1016 # 80008f88 <etext+0xf88>
    80006b98:	0003c517          	auipc	a0,0x3c
    80006b9c:	8d050513          	addi	a0,a0,-1840 # 80042468 <fs_rb>
    80006ba0:	e6dff0ef          	jal	80006a0c <ringbuf_init>
}
    80006ba4:	60a2                	ld	ra,8(sp)
    80006ba6:	6402                	ld	s0,0(sp)
    80006ba8:	0141                	addi	sp,sp,16
    80006baa:	8082                	ret

0000000080006bac <fslog_push>:

void
fslog_push(struct fs_event *e)
{
    80006bac:	1141                	addi	sp,sp,-16
    80006bae:	e406                	sd	ra,8(sp)
    80006bb0:	e022                	sd	s0,0(sp)
    80006bb2:	0800                	addi	s0,sp,16
    80006bb4:	85aa                	mv	a1,a0
  // إضافة رقم تسلسلي لكل حدث لترتيبها في الواجهة الرسومية
  e->seq = ++fs_seq;
    80006bb6:	00002717          	auipc	a4,0x2
    80006bba:	54270713          	addi	a4,a4,1346 # 800090f8 <fs_seq>
    80006bbe:	631c                	ld	a5,0(a4)
    80006bc0:	0785                	addi	a5,a5,1
    80006bc2:	e31c                	sd	a5,0(a4)
    80006bc4:	e11c                	sd	a5,0(a0)
  ringbuf_push(&fs_rb, e);
    80006bc6:	0003c517          	auipc	a0,0x3c
    80006bca:	8a250513          	addi	a0,a0,-1886 # 80042468 <fs_rb>
    80006bce:	e73ff0ef          	jal	80006a40 <ringbuf_push>
}
    80006bd2:	60a2                	ld	ra,8(sp)
    80006bd4:	6402                	ld	s0,0(sp)
    80006bd6:	0141                	addi	sp,sp,16
    80006bd8:	8082                	ret

0000000080006bda <fslog_read_many>:

int
fslog_read_many(struct fs_event *out, int max)
{
    80006bda:	df010113          	addi	sp,sp,-528
    80006bde:	20113423          	sd	ra,520(sp)
    80006be2:	20813023          	sd	s0,512(sp)
    80006be6:	ffa6                	sd	s1,504(sp)
    80006be8:	fbca                	sd	s2,496(sp)
    80006bea:	f7ce                	sd	s3,488(sp)
    80006bec:	0c00                	addi	s0,sp,528
    80006bee:	84aa                	mv	s1,a0
    80006bf0:	89ae                	mv	s3,a1
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
    80006bf2:	d17fa0ef          	jal	80001908 <myproc>
  
  while(count < max){
    80006bf6:	05305463          	blez	s3,80006c3e <fslog_read_many+0x64>
    80006bfa:	f3d2                	sd	s4,480(sp)
    80006bfc:	efd6                	sd	s5,472(sp)
    80006bfe:	8a2a                	mv	s4,a0
  int count = 0;
    80006c00:	4901                	li	s2,0
    if(ringbuf_pop(&fs_rb, &e) != 0)
    80006c02:	0003ca97          	auipc	s5,0x3c
    80006c06:	866a8a93          	addi	s5,s5,-1946 # 80042468 <fs_rb>
    80006c0a:	df840593          	addi	a1,s0,-520
    80006c0e:	8556                	mv	a0,s5
    80006c10:	f17ff0ef          	jal	80006b26 <ringbuf_pop>
    80006c14:	e51d                	bnez	a0,80006c42 <fslog_read_many+0x68>
      break;

    // نقل البيانات من مساحة النواة إلى مساحة المستخدم (User Space) ليعرضها الـ GUI
    uint64 dst = (uint64)out + count * sizeof(struct fs_event);
    if(copyout(p->pagetable, dst, (char *)&e, sizeof(struct fs_event)) < 0)
    80006c16:	1c800693          	li	a3,456
    80006c1a:	df840613          	addi	a2,s0,-520
    80006c1e:	85a6                	mv	a1,s1
    80006c20:	050a3503          	ld	a0,80(s4)
    80006c24:	9f9fa0ef          	jal	8000161c <copyout>
    80006c28:	02054a63          	bltz	a0,80006c5c <fslog_read_many+0x82>
      break;
    count++;
    80006c2c:	2905                	addiw	s2,s2,1
  while(count < max){
    80006c2e:	1c848493          	addi	s1,s1,456
    80006c32:	fd299ce3          	bne	s3,s2,80006c0a <fslog_read_many+0x30>
    80006c36:	894e                	mv	s2,s3
    80006c38:	7a1e                	ld	s4,480(sp)
    80006c3a:	6afe                	ld	s5,472(sp)
    80006c3c:	a029                	j	80006c46 <fslog_read_many+0x6c>
  int count = 0;
    80006c3e:	4901                	li	s2,0
    80006c40:	a019                	j	80006c46 <fslog_read_many+0x6c>
    80006c42:	7a1e                	ld	s4,480(sp)
    80006c44:	6afe                	ld	s5,472(sp)
  }
  return count;
    80006c46:	854a                	mv	a0,s2
    80006c48:	20813083          	ld	ra,520(sp)
    80006c4c:	20013403          	ld	s0,512(sp)
    80006c50:	74fe                	ld	s1,504(sp)
    80006c52:	795e                	ld	s2,496(sp)
    80006c54:	79be                	ld	s3,488(sp)
    80006c56:	21010113          	addi	sp,sp,528
    80006c5a:	8082                	ret
    80006c5c:	7a1e                	ld	s4,480(sp)
    80006c5e:	6afe                	ld	s5,472(sp)
    80006c60:	b7dd                	j	80006c46 <fslog_read_many+0x6c>
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
