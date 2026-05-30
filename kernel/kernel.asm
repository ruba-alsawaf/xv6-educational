
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
    80000004:	08010113          	addi	sp,sp,128 # 8000a080 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ff6e39f>
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
    800000e6:	00012517          	auipc	a0,0x12
    800000ea:	f9a50513          	addi	a0,a0,-102 # 80012080 <conswlock>
    800000ee:	3b1040ef          	jal	80004c9e <acquiresleep>

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
    80000162:	00012517          	auipc	a0,0x12
    80000166:	f1e50513          	addi	a0,a0,-226 # 80012080 <conswlock>
    8000016a:	37b040ef          	jal	80004ce4 <releasesleep>
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
    800001a0:	00012517          	auipc	a0,0x12
    800001a4:	f1050513          	addi	a0,a0,-240 # 800120b0 <cons>
    800001a8:	259000ef          	jal	80000c00 <acquire>

  while(n > 0){
    while(cons.r == cons.w){
    800001ac:	00012497          	auipc	s1,0x12
    800001b0:	ed448493          	addi	s1,s1,-300 # 80012080 <conswlock>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	00012997          	auipc	s3,0x12
    800001b8:	efc98993          	addi	s3,s3,-260 # 800120b0 <cons>
    800001bc:	00012917          	auipc	s2,0x12
    800001c0:	f8c90913          	addi	s2,s2,-116 # 80012148 <cons+0x98>
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
    800001f4:	00012717          	auipc	a4,0x12
    800001f8:	e8c70713          	addi	a4,a4,-372 # 80012080 <conswlock>
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
    8000023e:	00012517          	auipc	a0,0x12
    80000242:	e7250513          	addi	a0,a0,-398 # 800120b0 <cons>
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
    8000026a:	00012717          	auipc	a4,0x12
    8000026e:	ecf72f23          	sw	a5,-290(a4) # 80012148 <cons+0x98>
    80000272:	6c42                	ld	s8,16(sp)
    80000274:	a031                	j	80000280 <consoleread+0x100>
    80000276:	e862                	sd	s8,16(sp)
    80000278:	bfb5                	j	800001f4 <consoleread+0x74>
    8000027a:	6c42                	ld	s8,16(sp)
    8000027c:	a011                	j	80000280 <consoleread+0x100>
    8000027e:	6c42                	ld	s8,16(sp)
  release(&cons.lock);
    80000280:	00012517          	auipc	a0,0x12
    80000284:	e3050513          	addi	a0,a0,-464 # 800120b0 <cons>
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
    800002d4:	00012517          	auipc	a0,0x12
    800002d8:	ddc50513          	addi	a0,a0,-548 # 800120b0 <cons>
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
    800002fa:	00012517          	auipc	a0,0x12
    800002fe:	db650513          	addi	a0,a0,-586 # 800120b0 <cons>
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
    80000318:	00012717          	auipc	a4,0x12
    8000031c:	d6870713          	addi	a4,a4,-664 # 80012080 <conswlock>
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
    8000033e:	00012797          	auipc	a5,0x12
    80000342:	d4278793          	addi	a5,a5,-702 # 80012080 <conswlock>
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
    8000036c:	00012797          	auipc	a5,0x12
    80000370:	ddc7a783          	lw	a5,-548(a5) # 80012148 <cons+0x98>
    80000374:	9f1d                	subw	a4,a4,a5
    80000376:	08000793          	li	a5,128
    8000037a:	f8f710e3          	bne	a4,a5,800002fa <consoleintr+0x32>
    8000037e:	a07d                	j	8000042c <consoleintr+0x164>
    80000380:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000382:	00012717          	auipc	a4,0x12
    80000386:	cfe70713          	addi	a4,a4,-770 # 80012080 <conswlock>
    8000038a:	0d072783          	lw	a5,208(a4)
    8000038e:	0cc72703          	lw	a4,204(a4)
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    80000392:	00012497          	auipc	s1,0x12
    80000396:	cee48493          	addi	s1,s1,-786 # 80012080 <conswlock>
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
    800003d4:	00012717          	auipc	a4,0x12
    800003d8:	cac70713          	addi	a4,a4,-852 # 80012080 <conswlock>
    800003dc:	0d072783          	lw	a5,208(a4)
    800003e0:	0cc72703          	lw	a4,204(a4)
    800003e4:	f0f70be3          	beq	a4,a5,800002fa <consoleintr+0x32>
      cons.e--;
    800003e8:	37fd                	addiw	a5,a5,-1
    800003ea:	00012717          	auipc	a4,0x12
    800003ee:	d6f72323          	sw	a5,-666(a4) # 80012150 <cons+0xa0>
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
    80000408:	00012797          	auipc	a5,0x12
    8000040c:	c7878793          	addi	a5,a5,-904 # 80012080 <conswlock>
    80000410:	0d07a703          	lw	a4,208(a5)
    80000414:	0017069b          	addiw	a3,a4,1
    80000418:	0006861b          	sext.w	a2,a3
    8000041c:	0cd7a823          	sw	a3,208(a5)
    80000420:	07f77713          	andi	a4,a4,127
    80000424:	97ba                	add	a5,a5,a4
    80000426:	4729                	li	a4,10
    80000428:	04e78423          	sb	a4,72(a5)
        cons.w = cons.e;
    8000042c:	00012797          	auipc	a5,0x12
    80000430:	d2c7a023          	sw	a2,-736(a5) # 8001214c <cons+0x9c>
        wakeup(&cons.r);
    80000434:	00012517          	auipc	a0,0x12
    80000438:	d1450513          	addi	a0,a0,-748 # 80012148 <cons+0x98>
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
    8000044a:	00009597          	auipc	a1,0x9
    8000044e:	bb658593          	addi	a1,a1,-1098 # 80009000 <etext>
    80000452:	00012517          	auipc	a0,0x12
    80000456:	c5e50513          	addi	a0,a0,-930 # 800120b0 <cons>
    8000045a:	726000ef          	jal	80000b80 <initlock>
  initsleeplock(&conswlock, "consw");
    8000045e:	00009597          	auipc	a1,0x9
    80000462:	baa58593          	addi	a1,a1,-1110 # 80009008 <etext+0x8>
    80000466:	00012517          	auipc	a0,0x12
    8000046a:	c1a50513          	addi	a0,a0,-998 # 80012080 <conswlock>
    8000046e:	7fa040ef          	jal	80004c68 <initsleeplock>

  uartinit();
    80000472:	400000ef          	jal	80000872 <uartinit>

  devsw[CONSOLE].read = consoleread;
    80000476:	00022797          	auipc	a5,0x22
    8000047a:	daa78793          	addi	a5,a5,-598 # 80022220 <devsw>
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
    800004b0:	0000a617          	auipc	a2,0xa
    800004b4:	a2060613          	addi	a2,a2,-1504 # 80009ed0 <digits>
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
    8000054a:	0000a797          	auipc	a5,0xa
    8000054e:	ada7a783          	lw	a5,-1318(a5) # 8000a024 <panicking>
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
    80000592:	00012517          	auipc	a0,0x12
    80000596:	bc650513          	addi	a0,a0,-1082 # 80012158 <pr>
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
    8000075e:	776b8b93          	addi	s7,s7,1910 # 80009ed0 <digits>
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
    800007ba:	00009917          	auipc	s2,0x9
    800007be:	85690913          	addi	s2,s2,-1962 # 80009010 <etext+0x10>
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
    800007ee:	0000a797          	auipc	a5,0xa
    800007f2:	8367a783          	lw	a5,-1994(a5) # 8000a024 <panicking>
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
    80000804:	00012517          	auipc	a0,0x12
    80000808:	95450513          	addi	a0,a0,-1708 # 80012158 <pr>
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
    80000822:	0000a797          	auipc	a5,0xa
    80000826:	8127a123          	sw	s2,-2046(a5) # 8000a024 <panicking>
  printf("panic: ");
    8000082a:	00008517          	auipc	a0,0x8
    8000082e:	7ee50513          	addi	a0,a0,2030 # 80009018 <etext+0x18>
    80000832:	cfbff0ef          	jal	8000052c <printf>
  printf("%s\n", s);
    80000836:	85a6                	mv	a1,s1
    80000838:	00008517          	auipc	a0,0x8
    8000083c:	7e850513          	addi	a0,a0,2024 # 80009020 <etext+0x20>
    80000840:	cedff0ef          	jal	8000052c <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000844:	00009797          	auipc	a5,0x9
    80000848:	7d27ae23          	sw	s2,2012(a5) # 8000a020 <panicked>
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
    80000856:	00008597          	auipc	a1,0x8
    8000085a:	7d258593          	addi	a1,a1,2002 # 80009028 <etext+0x28>
    8000085e:	00012517          	auipc	a0,0x12
    80000862:	8fa50513          	addi	a0,a0,-1798 # 80012158 <pr>
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
    800008ae:	00008597          	auipc	a1,0x8
    800008b2:	78258593          	addi	a1,a1,1922 # 80009030 <etext+0x30>
    800008b6:	00012517          	auipc	a0,0x12
    800008ba:	8ba50513          	addi	a0,a0,-1862 # 80012170 <tx_lock>
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
    800008da:	00012517          	auipc	a0,0x12
    800008de:	89650513          	addi	a0,a0,-1898 # 80012170 <tx_lock>
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
    800008f8:	00009497          	auipc	s1,0x9
    800008fc:	73448493          	addi	s1,s1,1844 # 8000a02c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000900:	00012997          	auipc	s3,0x12
    80000904:	87098993          	addi	s3,s3,-1936 # 80012170 <tx_lock>
    80000908:	00009917          	auipc	s2,0x9
    8000090c:	72090913          	addi	s2,s2,1824 # 8000a028 <tx_chan>
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
    80000946:	00012517          	auipc	a0,0x12
    8000094a:	82a50513          	addi	a0,a0,-2006 # 80012170 <tx_lock>
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
    8000096a:	00009797          	auipc	a5,0x9
    8000096e:	6ba7a783          	lw	a5,1722(a5) # 8000a024 <panicking>
    80000972:	cf95                	beqz	a5,800009ae <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000974:	00009797          	auipc	a5,0x9
    80000978:	6ac7a783          	lw	a5,1708(a5) # 8000a020 <panicked>
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
    8000099a:	00009797          	auipc	a5,0x9
    8000099e:	68a7a783          	lw	a5,1674(a5) # 8000a024 <panicking>
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
    800009f6:	00011517          	auipc	a0,0x11
    800009fa:	77a50513          	addi	a0,a0,1914 # 80012170 <tx_lock>
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
    80000a12:	00011517          	auipc	a0,0x11
    80000a16:	75e50513          	addi	a0,a0,1886 # 80012170 <tx_lock>
    80000a1a:	27e000ef          	jal	80000c98 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a1e:	54fd                	li	s1,-1
    80000a20:	a831                	j	80000a3c <uartintr+0x5a>
    tx_busy = 0;
    80000a22:	00009797          	auipc	a5,0x9
    80000a26:	6007a523          	sw	zero,1546(a5) # 8000a02c <tx_busy>
    wakeup(&tx_chan);
    80000a2a:	00009517          	auipc	a0,0x9
    80000a2e:	5fe50513          	addi	a0,a0,1534 # 8000a028 <tx_chan>
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
    80000a62:	00090797          	auipc	a5,0x90
    80000a66:	9fe78793          	addi	a5,a5,-1538 # 80090460 <end>
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
    80000a7e:	00011917          	auipc	s2,0x11
    80000a82:	70a90913          	addi	s2,s2,1802 # 80012188 <kmem>
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
    80000aa8:	00008517          	auipc	a0,0x8
    80000aac:	59050513          	addi	a0,a0,1424 # 80009038 <etext+0x38>
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
    80000b04:	00008597          	auipc	a1,0x8
    80000b08:	53c58593          	addi	a1,a1,1340 # 80009040 <etext+0x40>
    80000b0c:	00011517          	auipc	a0,0x11
    80000b10:	67c50513          	addi	a0,a0,1660 # 80012188 <kmem>
    80000b14:	06c000ef          	jal	80000b80 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b18:	45c5                	li	a1,17
    80000b1a:	05ee                	slli	a1,a1,0x1b
    80000b1c:	00090517          	auipc	a0,0x90
    80000b20:	94450513          	addi	a0,a0,-1724 # 80090460 <end>
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
    80000b3a:	00011497          	auipc	s1,0x11
    80000b3e:	64e48493          	addi	s1,s1,1614 # 80012188 <kmem>
    80000b42:	8526                	mv	a0,s1
    80000b44:	0bc000ef          	jal	80000c00 <acquire>
  r = kmem.freelist;
    80000b48:	6c84                	ld	s1,24(s1)
  if(r)
    80000b4a:	c485                	beqz	s1,80000b72 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b4c:	609c                	ld	a5,0(s1)
    80000b4e:	00011517          	auipc	a0,0x11
    80000b52:	63a50513          	addi	a0,a0,1594 # 80012188 <kmem>
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
    80000b72:	00011517          	auipc	a0,0x11
    80000b76:	61650513          	addi	a0,a0,1558 # 80012188 <kmem>
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
    80000c38:	00008517          	auipc	a0,0x8
    80000c3c:	41050513          	addi	a0,a0,1040 # 80009048 <etext+0x48>
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
    80000c80:	00008517          	auipc	a0,0x8
    80000c84:	3d050513          	addi	a0,a0,976 # 80009050 <etext+0x50>
    80000c88:	b8bff0ef          	jal	80000812 <panic>
    panic("pop_off");
    80000c8c:	00008517          	auipc	a0,0x8
    80000c90:	3dc50513          	addi	a0,a0,988 # 80009068 <etext+0x68>
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
    80000cc8:	00008517          	auipc	a0,0x8
    80000ccc:	3a850513          	addi	a0,a0,936 # 80009070 <etext+0x70>
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
    80000d48:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ff6eba1>
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
    80000e7a:	00009717          	auipc	a4,0x9
    80000e7e:	1b670713          	addi	a4,a4,438 # 8000a030 <started>
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
    80000e94:	00008517          	auipc	a0,0x8
    80000e98:	1fc50513          	addi	a0,a0,508 # 80009090 <etext+0x90>
    80000e9c:	e90ff0ef          	jal	8000052c <printf>
    kvminithart();    // turn on paging
    80000ea0:	088000ef          	jal	80000f28 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ea4:	596010ef          	jal	8000243a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ea8:	6f0050ef          	jal	80006598 <plicinithart>
  }

  scheduler();        
    80000eac:	6cf000ef          	jal	80001d7a <scheduler>
    consoleinit();
    80000eb0:	d92ff0ef          	jal	80000442 <consoleinit>
    printfinit();
    80000eb4:	99bff0ef          	jal	8000084e <printfinit>
    printf("\n");
    80000eb8:	00008517          	auipc	a0,0x8
    80000ebc:	1e850513          	addi	a0,a0,488 # 800090a0 <etext+0xa0>
    80000ec0:	e6cff0ef          	jal	8000052c <printf>
    printf("xv6 kernel is booting\n");
    80000ec4:	00008517          	auipc	a0,0x8
    80000ec8:	1b450513          	addi	a0,a0,436 # 80009078 <etext+0x78>
    80000ecc:	e60ff0ef          	jal	8000052c <printf>
    printf("\n");
    80000ed0:	00008517          	auipc	a0,0x8
    80000ed4:	1d050513          	addi	a0,a0,464 # 800090a0 <etext+0xa0>
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
    80000ef4:	68a050ef          	jal	8000657e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ef8:	6a0050ef          	jal	80006598 <plicinithart>
    binit();         // buffer cache
    80000efc:	415010ef          	jal	80002b10 <binit>
    iinit();         // inode table
    80000f00:	011020ef          	jal	80003710 <iinit>
    fileinit();      // file table
    80000f04:	72f030ef          	jal	80004e32 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f08:	780050ef          	jal	80006688 <virtio_disk_init>
    cslog_init();
    80000f0c:	42f050ef          	jal	80006b3a <cslog_init>
    fslog_init();
    80000f10:	04c060ef          	jal	80006f5c <fslog_init>
    userinit();      // first user process
    80000f14:	4bb000ef          	jal	80001bce <userinit>
    __sync_synchronize();
    80000f18:	0ff0000f          	fence
    started = 1;
    80000f1c:	4785                	li	a5,1
    80000f1e:	00009717          	auipc	a4,0x9
    80000f22:	10f72923          	sw	a5,274(a4) # 8000a030 <started>
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
    80000f32:	00009797          	auipc	a5,0x9
    80000f36:	1067b783          	ld	a5,262(a5) # 8000a038 <kernel_pagetable>
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
    80000f76:	00008517          	auipc	a0,0x8
    80000f7a:	13250513          	addi	a0,a0,306 # 800090a8 <etext+0xa8>
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
    80000fa4:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ff6eb97>
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
    8000108c:	00008517          	auipc	a0,0x8
    80001090:	02450513          	addi	a0,a0,36 # 800090b0 <etext+0xb0>
    80001094:	f7eff0ef          	jal	80000812 <panic>
    panic("mappages: size not aligned");
    80001098:	00008517          	auipc	a0,0x8
    8000109c:	03850513          	addi	a0,a0,56 # 800090d0 <etext+0xd0>
    800010a0:	f72ff0ef          	jal	80000812 <panic>
    panic("mappages: size");
    800010a4:	00008517          	auipc	a0,0x8
    800010a8:	04c50513          	addi	a0,a0,76 # 800090f0 <etext+0xf0>
    800010ac:	f66ff0ef          	jal	80000812 <panic>
      panic("mappages: remap");
    800010b0:	00008517          	auipc	a0,0x8
    800010b4:	05050513          	addi	a0,a0,80 # 80009100 <etext+0x100>
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
    800010f4:	00008517          	auipc	a0,0x8
    800010f8:	01c50513          	addi	a0,a0,28 # 80009110 <etext+0x110>
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
    80001152:	00008917          	auipc	s2,0x8
    80001156:	eae90913          	addi	s2,s2,-338 # 80009000 <etext>
    8000115a:	4729                	li	a4,10
    8000115c:	80008697          	auipc	a3,0x80008
    80001160:	ea468693          	addi	a3,a3,-348 # 9000 <_entry-0x7fff7000>
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
    80001188:	00007617          	auipc	a2,0x7
    8000118c:	e7860613          	addi	a2,a2,-392 # 80008000 <_trampoline>
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
    800011be:	00009797          	auipc	a5,0x9
    800011c2:	e6a7bd23          	sd	a0,-390(a5) # 8000a038 <kernel_pagetable>
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
    8000122e:	00008517          	auipc	a0,0x8
    80001232:	eea50513          	addi	a0,a0,-278 # 80009118 <etext+0x118>
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
    800013a6:	00008517          	auipc	a0,0x8
    800013aa:	d8a50513          	addi	a0,a0,-630 # 80009130 <etext+0x130>
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
    800014b6:	00008517          	auipc	a0,0x8
    800014ba:	c8a50513          	addi	a0,a0,-886 # 80009140 <etext+0x140>
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
    800017a4:	00011497          	auipc	s1,0x11
    800017a8:	e3448493          	addi	s1,s1,-460 # 800125d8 <proc>
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
    800017d0:	00017a97          	auipc	s5,0x17
    800017d4:	808a8a93          	addi	s5,s5,-2040 # 80017fd8 <tickslock>
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
    8000181a:	00008517          	auipc	a0,0x8
    8000181e:	93650513          	addi	a0,a0,-1738 # 80009150 <etext+0x150>
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
    8000183a:	00008597          	auipc	a1,0x8
    8000183e:	91e58593          	addi	a1,a1,-1762 # 80009158 <etext+0x158>
    80001842:	00011517          	auipc	a0,0x11
    80001846:	96650513          	addi	a0,a0,-1690 # 800121a8 <pid_lock>
    8000184a:	b36ff0ef          	jal	80000b80 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000184e:	00008597          	auipc	a1,0x8
    80001852:	91258593          	addi	a1,a1,-1774 # 80009160 <etext+0x160>
    80001856:	00011517          	auipc	a0,0x11
    8000185a:	96a50513          	addi	a0,a0,-1686 # 800121c0 <wait_lock>
    8000185e:	b22ff0ef          	jal	80000b80 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001862:	00011497          	auipc	s1,0x11
    80001866:	d7648493          	addi	s1,s1,-650 # 800125d8 <proc>
    initlock(&p->lock, "proc");
    8000186a:	00008b17          	auipc	s6,0x8
    8000186e:	906b0b13          	addi	s6,s6,-1786 # 80009170 <etext+0x170>
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
    80001896:	00016a17          	auipc	s4,0x16
    8000189a:	742a0a13          	addi	s4,s4,1858 # 80017fd8 <tickslock>
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
    800018b4:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ff6eba1>
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
    800018f8:	00011517          	auipc	a0,0x11
    800018fc:	8e050513          	addi	a0,a0,-1824 # 800121d8 <cpus>
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
    8000191c:	00011717          	auipc	a4,0x11
    80001920:	88c70713          	addi	a4,a4,-1908 # 800121a8 <pid_lock>
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
    8000194c:	00008797          	auipc	a5,0x8
    80001950:	6c47a783          	lw	a5,1732(a5) # 8000a010 <first.1>
    80001954:	cf8d                	beqz	a5,8000198e <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001956:	4505                	li	a0,1
    80001958:	3ac020ef          	jal	80003d04 <fsinit>

    first = 0;
    8000195c:	00008797          	auipc	a5,0x8
    80001960:	6a07aa23          	sw	zero,1716(a5) # 8000a010 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001964:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001968:	00008517          	auipc	a0,0x8
    8000196c:	81050513          	addi	a0,a0,-2032 # 80009178 <etext+0x178>
    80001970:	fca43823          	sd	a0,-48(s0)
    80001974:	fc043c23          	sd	zero,-40(s0)
    80001978:	fd040593          	addi	a1,s0,-48
    8000197c:	425030ef          	jal	800055a0 <kexec>
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
    8000199e:	00006797          	auipc	a5,0x6
    800019a2:	6fe78793          	addi	a5,a5,1790 # 8000809c <userret>
    800019a6:	00006697          	auipc	a3,0x6
    800019aa:	65a68693          	addi	a3,a3,1626 # 80008000 <_trampoline>
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
    800019c4:	00007517          	auipc	a0,0x7
    800019c8:	7bc50513          	addi	a0,a0,1980 # 80009180 <etext+0x180>
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
    800019e0:	7cc90913          	addi	s2,s2,1996 # 800121a8 <pid_lock>
    800019e4:	854a                	mv	a0,s2
    800019e6:	a1aff0ef          	jal	80000c00 <acquire>
  pid = nextpid;
    800019ea:	00008797          	auipc	a5,0x8
    800019ee:	62a78793          	addi	a5,a5,1578 # 8000a014 <nextpid>
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
    80001a26:	00006697          	auipc	a3,0x6
    80001a2a:	5da68693          	addi	a3,a3,1498 # 80008000 <_trampoline>
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
    80001b34:	00011497          	auipc	s1,0x11
    80001b38:	aa448493          	addi	s1,s1,-1372 # 800125d8 <proc>
    80001b3c:	00016917          	auipc	s2,0x16
    80001b40:	49c90913          	addi	s2,s2,1180 # 80017fd8 <tickslock>
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
    80001bde:	00008797          	auipc	a5,0x8
    80001be2:	46a7b123          	sd	a0,1122(a5) # 8000a040 <initproc>
  p->cwd = namei("/");
    80001be6:	00007517          	auipc	a0,0x7
    80001bea:	5a250513          	addi	a0,a0,1442 # 80009188 <etext+0x188>
    80001bee:	7d4020ef          	jal	800043c2 <namei>
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
    80001d0a:	1c4030ef          	jal	80004ece <filedup>
    80001d0e:	00a93023          	sd	a0,0(s2)
    80001d12:	b7f5                	j	80001cfe <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001d14:	150ab503          	ld	a0,336(s5)
    80001d18:	3cf010ef          	jal	800038e6 <idup>
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
    80001d38:	00010497          	auipc	s1,0x10
    80001d3c:	48848493          	addi	s1,s1,1160 # 800121c0 <wait_lock>
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
    80001d9a:	00010717          	auipc	a4,0x10
    80001d9e:	40e70713          	addi	a4,a4,1038 # 800121a8 <pid_lock>
    80001da2:	975a                	add	a4,a4,s6
    80001da4:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001da8:	00010717          	auipc	a4,0x10
    80001dac:	43870713          	addi	a4,a4,1080 # 800121e0 <cpus+0x8>
    80001db0:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001db2:	4c11                	li	s8,4
        c->proc = p;
    80001db4:	079e                	slli	a5,a5,0x7
    80001db6:	00010a17          	auipc	s4,0x10
    80001dba:	3f2a0a13          	addi	s4,s4,1010 # 800121a8 <pid_lock>
    80001dbe:	9a3e                	add	s4,s4,a5
        found = 1;
    80001dc0:	4b85                	li	s7,1
    for (p = proc; p < &proc[NPROC]; p++) {
    80001dc2:	00016997          	auipc	s3,0x16
    80001dc6:	21698993          	addi	s3,s3,534 # 80017fd8 <tickslock>
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
    80001df0:	5d5040ef          	jal	80006bc4 <cslog_run_start>
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
    80001e2a:	7b248493          	addi	s1,s1,1970 # 800125d8 <proc>
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
    80001e52:	00010717          	auipc	a4,0x10
    80001e56:	35670713          	addi	a4,a4,854 # 800121a8 <pid_lock>
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
    80001e78:	00010917          	auipc	s2,0x10
    80001e7c:	33090913          	addi	s2,s2,816 # 800121a8 <pid_lock>
    80001e80:	2781                	sext.w	a5,a5
    80001e82:	079e                	slli	a5,a5,0x7
    80001e84:	97ca                	add	a5,a5,s2
    80001e86:	0ac7a983          	lw	s3,172(a5)
    80001e8a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e8c:	2781                	sext.w	a5,a5
    80001e8e:	079e                	slli	a5,a5,0x7
    80001e90:	00010597          	auipc	a1,0x10
    80001e94:	35058593          	addi	a1,a1,848 # 800121e0 <cpus+0x8>
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
    80001ebc:	00007517          	auipc	a0,0x7
    80001ec0:	2d450513          	addi	a0,a0,724 # 80009190 <etext+0x190>
    80001ec4:	94ffe0ef          	jal	80000812 <panic>
    panic("sched locks");
    80001ec8:	00007517          	auipc	a0,0x7
    80001ecc:	2d850513          	addi	a0,a0,728 # 800091a0 <etext+0x1a0>
    80001ed0:	943fe0ef          	jal	80000812 <panic>
    panic("sched RUNNING");
    80001ed4:	00007517          	auipc	a0,0x7
    80001ed8:	2dc50513          	addi	a0,a0,732 # 800091b0 <etext+0x1b0>
    80001edc:	937fe0ef          	jal	80000812 <panic>
    panic("sched interruptible");
    80001ee0:	00007517          	auipc	a0,0x7
    80001ee4:	2e050513          	addi	a0,a0,736 # 800091c0 <etext+0x1c0>
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
    80001f78:	00010497          	auipc	s1,0x10
    80001f7c:	66048493          	addi	s1,s1,1632 # 800125d8 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    80001f80:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f82:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f84:	00016917          	auipc	s2,0x16
    80001f88:	05490913          	addi	s2,s2,84 # 80017fd8 <tickslock>
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
    80001fe0:	00010497          	auipc	s1,0x10
    80001fe4:	5f848493          	addi	s1,s1,1528 # 800125d8 <proc>
      pp->parent = initproc;
    80001fe8:	00008a17          	auipc	s4,0x8
    80001fec:	058a0a13          	addi	s4,s4,88 # 8000a040 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001ff0:	00016997          	auipc	s3,0x16
    80001ff4:	fe898993          	addi	s3,s3,-24 # 80017fd8 <tickslock>
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
    8000203c:	00008797          	auipc	a5,0x8
    80002040:	0047b783          	ld	a5,4(a5) # 8000a040 <initproc>
    80002044:	0d050493          	addi	s1,a0,208
    80002048:	15050913          	addi	s2,a0,336
    8000204c:	00a79f63          	bne	a5,a0,8000206a <kexit+0x46>
    panic("init exiting");
    80002050:	00007517          	auipc	a0,0x7
    80002054:	18850513          	addi	a0,a0,392 # 800091d8 <etext+0x1d8>
    80002058:	fbafe0ef          	jal	80000812 <panic>
      fileclose(f);
    8000205c:	6d3020ef          	jal	80004f2e <fileclose>
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
    80002070:	79c020ef          	jal	8000480c <begin_op>
  iput(p->cwd);
    80002074:	1509b503          	ld	a0,336(s3)
    80002078:	2d7010ef          	jal	80003b4e <iput>
  end_op();
    8000207c:	0af020ef          	jal	8000492a <end_op>
  p->cwd = 0;
    80002080:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002084:	00010497          	auipc	s1,0x10
    80002088:	13c48493          	addi	s1,s1,316 # 800121c0 <wait_lock>
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
    800020ba:	00007517          	auipc	a0,0x7
    800020be:	12e50513          	addi	a0,a0,302 # 800091e8 <etext+0x1e8>
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
    800020d6:	00010497          	auipc	s1,0x10
    800020da:	50248493          	addi	s1,s1,1282 # 800125d8 <proc>
    800020de:	00016997          	auipc	s3,0x16
    800020e2:	efa98993          	addi	s3,s3,-262 # 80017fd8 <tickslock>
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
    8000219a:	00010517          	auipc	a0,0x10
    8000219e:	02650513          	addi	a0,a0,38 # 800121c0 <wait_lock>
    800021a2:	a5ffe0ef          	jal	80000c00 <acquire>
    havekids = 0;
    800021a6:	4b81                	li	s7,0
        if (pp->state == ZOMBIE) {
    800021a8:	4a15                	li	s4,5
        havekids = 1;
    800021aa:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021ac:	00016997          	auipc	s3,0x16
    800021b0:	e2c98993          	addi	s3,s3,-468 # 80017fd8 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800021b4:	00010c17          	auipc	s8,0x10
    800021b8:	00cc0c13          	addi	s8,s8,12 # 800121c0 <wait_lock>
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
    800021e6:	00010517          	auipc	a0,0x10
    800021ea:	fda50513          	addi	a0,a0,-38 # 800121c0 <wait_lock>
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
    80002212:	00010517          	auipc	a0,0x10
    80002216:	fae50513          	addi	a0,a0,-82 # 800121c0 <wait_lock>
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
    8000225a:	00010497          	auipc	s1,0x10
    8000225e:	37e48493          	addi	s1,s1,894 # 800125d8 <proc>
    80002262:	b7e1                	j	8000222a <kwait+0xb0>
      release(&wait_lock);
    80002264:	00010517          	auipc	a0,0x10
    80002268:	f5c50513          	addi	a0,a0,-164 # 800121c0 <wait_lock>
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
    8000231e:	00007517          	auipc	a0,0x7
    80002322:	d8250513          	addi	a0,a0,-638 # 800090a0 <etext+0xa0>
    80002326:	a06fe0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000232a:	00010497          	auipc	s1,0x10
    8000232e:	40648493          	addi	s1,s1,1030 # 80012730 <proc+0x158>
    80002332:	00016917          	auipc	s2,0x16
    80002336:	dfe90913          	addi	s2,s2,-514 # 80018130 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000233a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000233c:	00007997          	auipc	s3,0x7
    80002340:	ebc98993          	addi	s3,s3,-324 # 800091f8 <etext+0x1f8>
    printf("%d %s %s", p->pid, state, p->name);
    80002344:	00007a97          	auipc	s5,0x7
    80002348:	ebca8a93          	addi	s5,s5,-324 # 80009200 <etext+0x200>
    printf("\n");
    8000234c:	00007a17          	auipc	s4,0x7
    80002350:	d54a0a13          	addi	s4,s4,-684 # 800090a0 <etext+0xa0>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002354:	00008b97          	auipc	s7,0x8
    80002358:	b94b8b93          	addi	s7,s7,-1132 # 80009ee8 <states.0>
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
    8000241e:	00007597          	auipc	a1,0x7
    80002422:	e2258593          	addi	a1,a1,-478 # 80009240 <etext+0x240>
    80002426:	00016517          	auipc	a0,0x16
    8000242a:	bb250513          	addi	a0,a0,-1102 # 80017fd8 <tickslock>
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
    80002444:	0e078793          	addi	a5,a5,224 # 80006520 <kernelvec>
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
    80002470:	00006797          	auipc	a5,0x6
    80002474:	b9078793          	addi	a5,a5,-1136 # 80008000 <_trampoline>
    80002478:	00006697          	auipc	a3,0x6
    8000247c:	b8868693          	addi	a3,a3,-1144 # 80008000 <_trampoline>
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
    800024f6:	00016497          	auipc	s1,0x16
    800024fa:	ae248493          	addi	s1,s1,-1310 # 80017fd8 <tickslock>
    800024fe:	8526                	mv	a0,s1
    80002500:	f00fe0ef          	jal	80000c00 <acquire>
    ticks++;
    80002504:	00008517          	auipc	a0,0x8
    80002508:	b4450513          	addi	a0,a0,-1212 # 8000a048 <ticks>
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
    8000254c:	080040ef          	jal	800065cc <plic_claim>
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
    8000256c:	526040ef          	jal	80006a92 <virtio_disk_intr>
    if(irq)
    80002570:	a801                	j	80002580 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002572:	85a6                	mv	a1,s1
    80002574:	00007517          	auipc	a0,0x7
    80002578:	cd450513          	addi	a0,a0,-812 # 80009248 <etext+0x248>
    8000257c:	fb1fd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    80002580:	8526                	mv	a0,s1
    80002582:	06a040ef          	jal	800065ec <plic_complete>
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
    800025ae:	f7678793          	addi	a5,a5,-138 # 80006520 <kernelvec>
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
    800025f0:	00007517          	auipc	a0,0x7
    800025f4:	c9850513          	addi	a0,a0,-872 # 80009288 <etext+0x288>
    800025f8:	f35fd0ef          	jal	8000052c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025fc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002600:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002604:	00007517          	auipc	a0,0x7
    80002608:	cb450513          	addi	a0,a0,-844 # 800092b8 <etext+0x2b8>
    8000260c:	f21fd0ef          	jal	8000052c <printf>
    setkilled(p);
    80002610:	8526                	mv	a0,s1
    80002612:	b1bff0ef          	jal	8000212c <setkilled>
    80002616:	a035                	j	80002642 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002618:	00007517          	auipc	a0,0x7
    8000261c:	c5050513          	addi	a0,a0,-944 # 80009268 <etext+0x268>
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
    800026ec:	00007517          	auipc	a0,0x7
    800026f0:	bf450513          	addi	a0,a0,-1036 # 800092e0 <etext+0x2e0>
    800026f4:	91efe0ef          	jal	80000812 <panic>
    panic("kerneltrap: interrupts enabled");
    800026f8:	00007517          	auipc	a0,0x7
    800026fc:	c1050513          	addi	a0,a0,-1008 # 80009308 <etext+0x308>
    80002700:	912fe0ef          	jal	80000812 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002704:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002708:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000270c:	85ce                	mv	a1,s3
    8000270e:	00007517          	auipc	a0,0x7
    80002712:	c1a50513          	addi	a0,a0,-998 # 80009328 <etext+0x328>
    80002716:	e17fd0ef          	jal	8000052c <printf>
    panic("kerneltrap");
    8000271a:	00007517          	auipc	a0,0x7
    8000271e:	c3650513          	addi	a0,a0,-970 # 80009350 <etext+0x350>
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
    8000274e:	7ce70713          	addi	a4,a4,1998 # 80009f18 <states.0+0x30>
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
    80002786:	00007517          	auipc	a0,0x7
    8000278a:	bda50513          	addi	a0,a0,-1062 # 80009360 <etext+0x360>
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
    800028a4:	4769                	li	a4,26
    800028a6:	00f76f63          	bltu	a4,a5,800028c4 <syscall+0x40>
    800028aa:	00369713          	slli	a4,a3,0x3
    800028ae:	00007797          	auipc	a5,0x7
    800028b2:	68278793          	addi	a5,a5,1666 # 80009f30 <syscalls>
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
    800028ca:	00007517          	auipc	a0,0x7
    800028ce:	a9e50513          	addi	a0,a0,-1378 # 80009368 <etext+0x368>
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
    800029f0:	00015517          	auipc	a0,0x15
    800029f4:	5e850513          	addi	a0,a0,1512 # 80017fd8 <tickslock>
    800029f8:	a08fe0ef          	jal	80000c00 <acquire>
  ticks0 = ticks;
    800029fc:	00007917          	auipc	s2,0x7
    80002a00:	64c92903          	lw	s2,1612(s2) # 8000a048 <ticks>
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
    80002a0e:	00015997          	auipc	s3,0x15
    80002a12:	5ca98993          	addi	s3,s3,1482 # 80017fd8 <tickslock>
    80002a16:	00007497          	auipc	s1,0x7
    80002a1a:	63248493          	addi	s1,s1,1586 # 8000a048 <ticks>
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
    80002a42:	00015517          	auipc	a0,0x15
    80002a46:	59650513          	addi	a0,a0,1430 # 80017fd8 <tickslock>
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
    80002a60:	00015517          	auipc	a0,0x15
    80002a64:	57850513          	addi	a0,a0,1400 # 80017fd8 <tickslock>
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
    80002aa0:	00015517          	auipc	a0,0x15
    80002aa4:	53850513          	addi	a0,a0,1336 # 80017fd8 <tickslock>
    80002aa8:	958fe0ef          	jal	80000c00 <acquire>
  xticks = ticks;
    80002aac:	00007497          	auipc	s1,0x7
    80002ab0:	59c4a483          	lw	s1,1436(s1) # 8000a048 <ticks>
  release(&tickslock);
    80002ab4:	00015517          	auipc	a0,0x15
    80002ab8:	52450513          	addi	a0,a0,1316 # 80017fd8 <tickslock>
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
    80002ad6:	0001d797          	auipc	a5,0x1d
    80002ada:	7d27b783          	ld	a5,2002(a5) # 800202a8 <bcache+0x82b8>
    80002ade:	0001d697          	auipc	a3,0x1d
    80002ae2:	77a68693          	addi	a3,a3,1914 # 80020258 <bcache+0x8268>
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
    80002b20:	00007597          	auipc	a1,0x7
    80002b24:	86858593          	addi	a1,a1,-1944 # 80009388 <etext+0x388>
    80002b28:	00015517          	auipc	a0,0x15
    80002b2c:	4c850513          	addi	a0,a0,1224 # 80017ff0 <bcache>
    80002b30:	850fe0ef          	jal	80000b80 <initlock>
  bcache.head.prev = &bcache.head;
    80002b34:	0001d797          	auipc	a5,0x1d
    80002b38:	4bc78793          	addi	a5,a5,1212 # 8001fff0 <bcache+0x8000>
    80002b3c:	0001d717          	auipc	a4,0x1d
    80002b40:	71c70713          	addi	a4,a4,1820 # 80020258 <bcache+0x8268>
    80002b44:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b48:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b4c:	00015497          	auipc	s1,0x15
    80002b50:	4bc48493          	addi	s1,s1,1212 # 80018008 <bcache+0x18>
    b->next = bcache.head.next;
    80002b54:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b56:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b58:	00007a17          	auipc	s4,0x7
    80002b5c:	838a0a13          	addi	s4,s4,-1992 # 80009390 <etext+0x390>
    b->next = bcache.head.next;
    80002b60:	2b893783          	ld	a5,696(s2)
    80002b64:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b66:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b6a:	85d2                	mv	a1,s4
    80002b6c:	01048513          	addi	a0,s1,16
    80002b70:	0f8020ef          	jal	80004c68 <initsleeplock>
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
    80002bc6:	4a4040ef          	jal	8000706a <fslog_bread_req>
  acquire(&bcache.lock);
    80002bca:	00015517          	auipc	a0,0x15
    80002bce:	42650513          	addi	a0,a0,1062 # 80017ff0 <bcache>
    80002bd2:	82efe0ef          	jal	80000c00 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002bd6:	0001d497          	auipc	s1,0x1d
    80002bda:	6d24b483          	ld	s1,1746(s1) # 800202a8 <bcache+0x82b8>
    80002bde:	0001d797          	auipc	a5,0x1d
    80002be2:	67a78793          	addi	a5,a5,1658 # 80020258 <bcache+0x8268>
    80002be6:	0cf48263          	beq	s1,a5,80002caa <bread+0x114>
  int step = 0;
    80002bea:	4981                	li	s3,0
  return (int)(b - bcache.buf);
    80002bec:	00015d17          	auipc	s10,0x15
    80002bf0:	41cd0d13          	addi	s10,s10,1052 # 80018008 <bcache+0x18>
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
    80002c22:	4aa040ef          	jal	800070cc <fslog_bget_scan>
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
    80002c82:	00015517          	auipc	a0,0x15
    80002c86:	36e50513          	addi	a0,a0,878 # 80017ff0 <bcache>
    80002c8a:	80efe0ef          	jal	80000c98 <release>
      acquiresleep(&b->lock);
    80002c8e:	01048513          	addi	a0,s1,16
    80002c92:	00c020ef          	jal	80004c9e <acquiresleep>
      fslog_bget_hit(dev, blockno, buf_id(b),
    80002c96:	884e                	mv	a6,s3
    80002c98:	409c                	lw	a5,0(s1)
    80002c9a:	40b8                	lw	a4,64(s1)
    80002c9c:	86d2                	mv	a3,s4
    80002c9e:	864a                	mv	a2,s2
    80002ca0:	85de                	mv	a1,s7
    80002ca2:	855a                	mv	a0,s6
    80002ca4:	4f0040ef          	jal	80007194 <fslog_bget_hit>
      return b;
    80002ca8:	a0f9                	j	80002d76 <bread+0x1e0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002caa:	0001d497          	auipc	s1,0x1d
    80002cae:	5f64b483          	ld	s1,1526(s1) # 800202a0 <bcache+0x82b0>
    80002cb2:	0001d797          	auipc	a5,0x1d
    80002cb6:	5a678793          	addi	a5,a5,1446 # 80020258 <bcache+0x8268>
    80002cba:	06f48563          	beq	s1,a5,80002d24 <bread+0x18e>
  step = 0;
    80002cbe:	4a01                	li	s4,0
  return (int)(b - bcache.buf);
    80002cc0:	00015d17          	auipc	s10,0x15
    80002cc4:	348d0d13          	addi	s10,s10,840 # 80018008 <bcache+0x18>
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
    80002d14:	3b8040ef          	jal	800070cc <fslog_bget_scan>
    if(b->refcnt == 0) {
    80002d18:	40bc                	lw	a5,64(s1)
    80002d1a:	cb99                	beqz	a5,80002d30 <bread+0x19a>
    step++;
    80002d1c:	2a05                	addiw	s4,s4,1
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d1e:	64a4                	ld	s1,72(s1)
    80002d20:	fdb492e3          	bne	s1,s11,80002ce4 <bread+0x14e>
  panic("bget: no buffers");
    80002d24:	00006517          	auipc	a0,0x6
    80002d28:	67450513          	addi	a0,a0,1652 # 80009398 <etext+0x398>
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
    80002d52:	00015517          	auipc	a0,0x15
    80002d56:	29e50513          	addi	a0,a0,670 # 80017ff0 <bcache>
    80002d5a:	f3ffd0ef          	jal	80000c98 <release>
      acquiresleep(&b->lock);
    80002d5e:	01048513          	addi	a0,s1,16
    80002d62:	73d010ef          	jal	80004c9e <acquiresleep>
      fslog_bget_miss(dev, blockno, old_block, buf_id(b),
    80002d66:	87ce                	mv	a5,s3
    80002d68:	8762                	mv	a4,s8
    80002d6a:	86ca                	mv	a3,s2
    80002d6c:	8652                	mv	a2,s4
    80002d6e:	85de                	mv	a1,s7
    80002d70:	855a                	mv	a0,s6
    80002d72:	4e0040ef          	jal	80007252 <fslog_bget_miss>
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
    80002d9e:	2e3030ef          	jal	80006880 <virtio_disk_rw>
    b->valid = 1;
    80002da2:	4785                	li	a5,1
    80002da4:	c09c                	sw	a5,0(s1)
    fslog_bread_fill(b->dev, b->blockno, buf_id(b), b->refcnt, buf_lru_pos(b));
    80002da6:	8526                	mv	a0,s1
    80002da8:	d29ff0ef          	jal	80002ad0 <buf_lru_pos>
    80002dac:	872a                	mv	a4,a0
  return (int)(b - bcache.buf);
    80002dae:	00015617          	auipc	a2,0x15
    80002db2:	25a60613          	addi	a2,a2,602 # 80018008 <bcache+0x18>
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
    80002de0:	52a040ef          	jal	8000730a <fslog_bread_fill>
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
    80002df6:	727010ef          	jal	80004d1c <holdingsleep>
    80002dfa:	cd29                	beqz	a0,80002e54 <bwrite+0x6e>
  virtio_disk_rw(b, 1);
    80002dfc:	4585                	li	a1,1
    80002dfe:	8526                	mv	a0,s1
    80002e00:	281030ef          	jal	80006880 <virtio_disk_rw>
  fslog_bwrite_ev(b->dev, b->blockno, buf_id(b),
    80002e04:	0004a903          	lw	s2,0(s1)
    80002e08:	8526                	mv	a0,s1
    80002e0a:	cc7ff0ef          	jal	80002ad0 <buf_lru_pos>
    80002e0e:	87aa                	mv	a5,a0
  return (int)(b - bcache.buf);
    80002e10:	00015597          	auipc	a1,0x15
    80002e14:	1f858593          	addi	a1,a1,504 # 80018008 <bcache+0x18>
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
    80002e44:	56c040ef          	jal	800073b0 <fslog_bwrite_ev>
}
    80002e48:	60e2                	ld	ra,24(sp)
    80002e4a:	6442                	ld	s0,16(sp)
    80002e4c:	64a2                	ld	s1,8(sp)
    80002e4e:	6902                	ld	s2,0(sp)
    80002e50:	6105                	addi	sp,sp,32
    80002e52:	8082                	ret
    panic("bwrite");
    80002e54:	00006517          	auipc	a0,0x6
    80002e58:	55c50513          	addi	a0,a0,1372 # 800093b0 <etext+0x3b0>
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
    80002e80:	69d010ef          	jal	80004d1c <holdingsleep>
    80002e84:	c961                	beqz	a0,80002f54 <brelse+0xf4>
  old_ref = b->refcnt;
    80002e86:	0404aa83          	lw	s5,64(s1)
  old_lru = buf_lru_pos(b);
    80002e8a:	8526                	mv	a0,s1
    80002e8c:	c45ff0ef          	jal	80002ad0 <buf_lru_pos>
    80002e90:	89aa                	mv	s3,a0
  releasesleep(&b->lock);
    80002e92:	854a                	mv	a0,s2
    80002e94:	651010ef          	jal	80004ce4 <releasesleep>
  acquire(&bcache.lock);
    80002e98:	00015517          	auipc	a0,0x15
    80002e9c:	15850513          	addi	a0,a0,344 # 80017ff0 <bcache>
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
    80002eba:	0001d797          	auipc	a5,0x1d
    80002ebe:	13678793          	addi	a5,a5,310 # 8001fff0 <bcache+0x8000>
    80002ec2:	2b87b703          	ld	a4,696(a5)
    80002ec6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ec8:	0001d717          	auipc	a4,0x1d
    80002ecc:	39070713          	addi	a4,a4,912 # 80020258 <bcache+0x8268>
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
    80002ef4:	00015517          	auipc	a0,0x15
    80002ef8:	0fc50513          	addi	a0,a0,252 # 80017ff0 <bcache>
    80002efc:	d9dfd0ef          	jal	80000c98 <release>
  return (int)(b - bcache.buf);
    80002f00:	00015797          	auipc	a5,0x15
    80002f04:	10878793          	addi	a5,a5,264 # 80018008 <bcache+0x18>
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
    80002f38:	528040ef          	jal	80007460 <fslog_brelease_ev>
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
    80002f54:	00006517          	auipc	a0,0x6
    80002f58:	46450513          	addi	a0,a0,1124 # 800093b8 <etext+0x3b8>
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
    80002f6c:	00015517          	auipc	a0,0x15
    80002f70:	08450513          	addi	a0,a0,132 # 80017ff0 <bcache>
    80002f74:	c8dfd0ef          	jal	80000c00 <acquire>
  b->refcnt++;
    80002f78:	40bc                	lw	a5,64(s1)
    80002f7a:	2785                	addiw	a5,a5,1
    80002f7c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f7e:	00015517          	auipc	a0,0x15
    80002f82:	07250513          	addi	a0,a0,114 # 80017ff0 <bcache>
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
    80002fa0:	00015517          	auipc	a0,0x15
    80002fa4:	05050513          	addi	a0,a0,80 # 80017ff0 <bcache>
    80002fa8:	c59fd0ef          	jal	80000c00 <acquire>
  b->refcnt--;
    80002fac:	40bc                	lw	a5,64(s1)
    80002fae:	37fd                	addiw	a5,a5,-1
    80002fb0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fb2:	00015517          	auipc	a0,0x15
    80002fb6:	03e50513          	addi	a0,a0,62 # 80017ff0 <bcache>
    80002fba:	cdffd0ef          	jal	80000c98 <release>
}
    80002fbe:	60e2                	ld	ra,24(sp)
    80002fc0:	6442                	ld	s0,16(sp)
    80002fc2:	64a2                	ld	s1,8(sp)
    80002fc4:	6105                	addi	sp,sp,32
    80002fc6:	8082                	ret

0000000080002fc8 <dir_report>:
    struct inode *dp,
    char *name,
    uint target,
    uint off,
    char *details
){
    80002fc8:	dc010113          	addi	sp,sp,-576
    80002fcc:	22113c23          	sd	ra,568(sp)
    80002fd0:	22813823          	sd	s0,560(sp)
    80002fd4:	22913423          	sd	s1,552(sp)
    80002fd8:	23213023          	sd	s2,544(sp)
    80002fdc:	21313c23          	sd	s3,536(sp)
    80002fe0:	21413823          	sd	s4,528(sp)
    80002fe4:	21513423          	sd	s5,520(sp)
    80002fe8:	21613023          	sd	s6,512(sp)
    80002fec:	0480                	addi	s0,sp,576
    80002fee:	8b2a                	mv	s6,a0
    80002ff0:	84ae                	mv	s1,a1
    80002ff2:	8932                	mv	s2,a2
    80002ff4:	8ab6                	mv	s5,a3
    80002ff6:	8a3a                	mv	s4,a4
    80002ff8:	89be                	mv	s3,a5
    struct fs_event e;

    memset(&e, 0, sizeof(e));
    80002ffa:	20000613          	li	a2,512
    80002ffe:	4581                	li	a1,0
    80003000:	dc040513          	addi	a0,s0,-576
    80003004:	cd1fd0ef          	jal	80000cd4 <memset>

    e.ticks = ticks;
    80003008:	00007797          	auipc	a5,0x7
    8000300c:	0407a783          	lw	a5,64(a5) # 8000a048 <ticks>
    80003010:	dcf42423          	sw	a5,-568(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    80003014:	8f5fe0ef          	jal	80001908 <myproc>
    80003018:	4781                	li	a5,0
    8000301a:	c501                	beqz	a0,80003022 <dir_report+0x5a>
    8000301c:	8edfe0ef          	jal	80001908 <myproc>
    80003020:	591c                	lw	a5,48(a0)
    80003022:	dcf42623          	sw	a5,-564(s0)

    e.type = LAYER_DIR;
    80003026:	4795                	li	a5,5
    80003028:	dcf42823          	sw	a5,-560(s0)

    safestrcpy(e.op_name, op, sizeof(e.op_name));
    8000302c:	4641                	li	a2,16
    8000302e:	85da                	mv	a1,s6
    80003030:	dd440513          	addi	a0,s0,-556
    80003034:	ddffd0ef          	jal	80000e12 <safestrcpy>

    if(name)
    80003038:	00090863          	beqz	s2,80003048 <dir_report+0x80>
        safestrcpy(e.dir.name, name, sizeof(e.dir.name));
    8000303c:	4651                	li	a2,20
    8000303e:	85ca                	mv	a1,s2
    80003040:	fa040513          	addi	a0,s0,-96
    80003044:	dcffd0ef          	jal	80000e12 <safestrcpy>

    e.dir.parent_inum = dp ? dp->inum : -1;
    80003048:	57fd                	li	a5,-1
    8000304a:	c091                	beqz	s1,8000304e <dir_report+0x86>
    8000304c:	40dc                	lw	a5,4(s1)
    8000304e:	faf42a23          	sw	a5,-76(s0)
    e.dir.target_inum = target;
    80003052:	fb542c23          	sw	s5,-72(s0)
    e.dir.offset = off;
    80003056:	fb442e23          	sw	s4,-68(s0)

    safestrcpy(e.details, details, sizeof(e.details));
    8000305a:	08000613          	li	a2,128
    8000305e:	85ce                	mv	a1,s3
    80003060:	de440513          	addi	a0,s0,-540
    80003064:	daffd0ef          	jal	80000e12 <safestrcpy>

    fslog_push(&e);
    80003068:	dc040513          	addi	a0,s0,-576
    8000306c:	72d030ef          	jal	80006f98 <fslog_push>
}
    80003070:	23813083          	ld	ra,568(sp)
    80003074:	23013403          	ld	s0,560(sp)
    80003078:	22813483          	ld	s1,552(sp)
    8000307c:	22013903          	ld	s2,544(sp)
    80003080:	21813983          	ld	s3,536(sp)
    80003084:	21013a03          	ld	s4,528(sp)
    80003088:	20813a83          	ld	s5,520(sp)
    8000308c:	20013b03          	ld	s6,512(sp)
    80003090:	24010113          	addi	sp,sp,576
    80003094:	8082                	ret

0000000080003096 <path_report>:
    char *op,
    char *path,
    char *elem,
    struct inode *ip,
    char *details
){
    80003096:	dc010113          	addi	sp,sp,-576
    8000309a:	22113c23          	sd	ra,568(sp)
    8000309e:	22813823          	sd	s0,560(sp)
    800030a2:	22913423          	sd	s1,552(sp)
    800030a6:	23213023          	sd	s2,544(sp)
    800030aa:	21313c23          	sd	s3,536(sp)
    800030ae:	21413823          	sd	s4,528(sp)
    800030b2:	21513423          	sd	s5,520(sp)
    800030b6:	0480                	addi	s0,sp,576
    800030b8:	8aaa                	mv	s5,a0
    800030ba:	8a2e                	mv	s4,a1
    800030bc:	89b2                	mv	s3,a2
    800030be:	84b6                	mv	s1,a3
    800030c0:	893a                	mv	s2,a4
    struct fs_event e;

    memset(&e, 0, sizeof(e));
    800030c2:	20000613          	li	a2,512
    800030c6:	4581                	li	a1,0
    800030c8:	dc040513          	addi	a0,s0,-576
    800030cc:	c09fd0ef          	jal	80000cd4 <memset>

    e.ticks = ticks;
    800030d0:	00007797          	auipc	a5,0x7
    800030d4:	f787a783          	lw	a5,-136(a5) # 8000a048 <ticks>
    800030d8:	dcf42423          	sw	a5,-568(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    800030dc:	82dfe0ef          	jal	80001908 <myproc>
    800030e0:	4781                	li	a5,0
    800030e2:	c501                	beqz	a0,800030ea <path_report+0x54>
    800030e4:	825fe0ef          	jal	80001908 <myproc>
    800030e8:	591c                	lw	a5,48(a0)
    800030ea:	dcf42623          	sw	a5,-564(s0)

    e.type = LAYER_PATH;
    800030ee:	4799                	li	a5,6
    800030f0:	dcf42823          	sw	a5,-560(s0)

    safestrcpy(e.op_name, op, sizeof(e.op_name));
    800030f4:	4641                	li	a2,16
    800030f6:	85d6                	mv	a1,s5
    800030f8:	dd440513          	addi	a0,s0,-556
    800030fc:	d17fd0ef          	jal	80000e12 <safestrcpy>

    if(path)
    80003100:	000a0963          	beqz	s4,80003112 <path_report+0x7c>
        safestrcpy(e.dir.path, path, sizeof(e.dir.path));
    80003104:	08000613          	li	a2,128
    80003108:	85d2                	mv	a1,s4
    8000310a:	f2040513          	addi	a0,s0,-224
    8000310e:	d05fd0ef          	jal	80000e12 <safestrcpy>

    if(elem)
    80003112:	00098863          	beqz	s3,80003122 <path_report+0x8c>
        safestrcpy(e.dir.name, elem, sizeof(e.dir.name));
    80003116:	4651                	li	a2,20
    80003118:	85ce                	mv	a1,s3
    8000311a:	fa040513          	addi	a0,s0,-96
    8000311e:	cf5fd0ef          	jal	80000e12 <safestrcpy>

    e.dir.parent_inum = ip ? ip->inum : -1;
    80003122:	57fd                	li	a5,-1
    80003124:	c091                	beqz	s1,80003128 <path_report+0x92>
    80003126:	40dc                	lw	a5,4(s1)
    80003128:	faf42a23          	sw	a5,-76(s0)

    safestrcpy(e.details, details, sizeof(e.details));
    8000312c:	08000613          	li	a2,128
    80003130:	85ca                	mv	a1,s2
    80003132:	de440513          	addi	a0,s0,-540
    80003136:	cddfd0ef          	jal	80000e12 <safestrcpy>

    fslog_push(&e);
    8000313a:	dc040513          	addi	a0,s0,-576
    8000313e:	65b030ef          	jal	80006f98 <fslog_push>
}
    80003142:	23813083          	ld	ra,568(sp)
    80003146:	23013403          	ld	s0,560(sp)
    8000314a:	22813483          	ld	s1,552(sp)
    8000314e:	22013903          	ld	s2,544(sp)
    80003152:	21813983          	ld	s3,536(sp)
    80003156:	21013a03          	ld	s4,528(sp)
    8000315a:	20813a83          	ld	s5,520(sp)
    8000315e:	24010113          	addi	sp,sp,576
    80003162:	8082                	ret

0000000080003164 <balloc_report>:
void balloc_report(char* op, int blockno, int old_bit, int new_bit, char* det) {
    80003164:	dc010113          	addi	sp,sp,-576
    80003168:	22113c23          	sd	ra,568(sp)
    8000316c:	22813823          	sd	s0,560(sp)
    80003170:	22913423          	sd	s1,552(sp)
    80003174:	23213023          	sd	s2,544(sp)
    80003178:	21313c23          	sd	s3,536(sp)
    8000317c:	21413823          	sd	s4,528(sp)
    80003180:	21513423          	sd	s5,520(sp)
    80003184:	0480                	addi	s0,sp,576
    80003186:	8aaa                	mv	s5,a0
    80003188:	8a2e                	mv	s4,a1
    8000318a:	89b2                	mv	s3,a2
    8000318c:	8936                	mv	s2,a3
    8000318e:	84ba                	mv	s1,a4
    memset(&e, 0, sizeof(e));
    80003190:	20000613          	li	a2,512
    80003194:	4581                	li	a1,0
    80003196:	dc040513          	addi	a0,s0,-576
    8000319a:	b3bfd0ef          	jal	80000cd4 <memset>
    e.ticks = ticks;
    8000319e:	00007797          	auipc	a5,0x7
    800031a2:	eaa7a783          	lw	a5,-342(a5) # 8000a048 <ticks>
    800031a6:	dcf42423          	sw	a5,-568(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    800031aa:	f5efe0ef          	jal	80001908 <myproc>
    800031ae:	4781                	li	a5,0
    800031b0:	c501                	beqz	a0,800031b8 <balloc_report+0x54>
    800031b2:	f56fe0ef          	jal	80001908 <myproc>
    800031b6:	591c                	lw	a5,48(a0)
    800031b8:	dcf42623          	sw	a5,-564(s0)
    e.type = LAYER_BALLOC;
    800031bc:	478d                	li	a5,3
    800031be:	dcf42823          	sw	a5,-560(s0)
    safestrcpy(e.op_name, op, 16);
    800031c2:	4641                	li	a2,16
    800031c4:	85d6                	mv	a1,s5
    800031c6:	dd440513          	addi	a0,s0,-556
    800031ca:	c49fd0ef          	jal	80000e12 <safestrcpy>
    e.balloc.blockno = blockno;
    800031ce:	f3442023          	sw	s4,-224(s0)
    e.balloc.old_bit = old_bit;
    800031d2:	f3342423          	sw	s3,-216(s0)
    e.balloc.bit = new_bit;
    800031d6:	f3242223          	sw	s2,-220(s0)
    safestrcpy(e.details, det, 128);
    800031da:	08000613          	li	a2,128
    800031de:	85a6                	mv	a1,s1
    800031e0:	de440513          	addi	a0,s0,-540
    800031e4:	c2ffd0ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    800031e8:	dc040513          	addi	a0,s0,-576
    800031ec:	5ad030ef          	jal	80006f98 <fslog_push>
}
    800031f0:	23813083          	ld	ra,568(sp)
    800031f4:	23013403          	ld	s0,560(sp)
    800031f8:	22813483          	ld	s1,552(sp)
    800031fc:	22013903          	ld	s2,544(sp)
    80003200:	21813983          	ld	s3,536(sp)
    80003204:	21013a03          	ld	s4,528(sp)
    80003208:	20813a83          	ld	s5,520(sp)
    8000320c:	24010113          	addi	sp,sp,576
    80003210:	8082                	ret

0000000080003212 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003212:	1101                	addi	sp,sp,-32
    80003214:	ec06                	sd	ra,24(sp)
    80003216:	e822                	sd	s0,16(sp)
    80003218:	e426                	sd	s1,8(sp)
    8000321a:	e04a                	sd	s2,0(sp)
    8000321c:	1000                	addi	s0,sp,32
    8000321e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003220:	00d5d59b          	srliw	a1,a1,0xd
    80003224:	0001d797          	auipc	a5,0x1d
    80003228:	4a87a783          	lw	a5,1192(a5) # 800206cc <sb+0x1c>
    8000322c:	9dbd                	addw	a1,a1,a5
    8000322e:	969ff0ef          	jal	80002b96 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003232:	0074f793          	andi	a5,s1,7
    80003236:	4705                	li	a4,1
    80003238:	00f7173b          	sllw	a4,a4,a5
  if((bp->data[bi/8] & m) == 0)
    8000323c:	03349793          	slli	a5,s1,0x33
    80003240:	93d9                	srli	a5,a5,0x36
    80003242:	00f506b3          	add	a3,a0,a5
    80003246:	0586c683          	lbu	a3,88(a3)
    8000324a:	00d77633          	and	a2,a4,a3
    8000324e:	c229                	beqz	a2,80003290 <bfree+0x7e>
    80003250:	892a                	mv	s2,a0
    panic("freeing free block");
  int old_bit = 1;
  bp->data[bi/8] &= ~m;
    80003252:	97aa                	add	a5,a5,a0
    80003254:	fff74713          	not	a4,a4
    80003258:	8ef9                	and	a3,a3,a4
    8000325a:	04d78c23          	sb	a3,88(a5)
  balloc_report("BFREE", b, old_bit, 0, "Freed block");
    8000325e:	00006717          	auipc	a4,0x6
    80003262:	17a70713          	addi	a4,a4,378 # 800093d8 <etext+0x3d8>
    80003266:	4681                	li	a3,0
    80003268:	4605                	li	a2,1
    8000326a:	85a6                	mv	a1,s1
    8000326c:	00006517          	auipc	a0,0x6
    80003270:	17c50513          	addi	a0,a0,380 # 800093e8 <etext+0x3e8>
    80003274:	ef1ff0ef          	jal	80003164 <balloc_report>
  log_write(bp);
    80003278:	854a                	mv	a0,s2
    8000327a:	107010ef          	jal	80004b80 <log_write>
  brelse(bp);
    8000327e:	854a                	mv	a0,s2
    80003280:	be1ff0ef          	jal	80002e60 <brelse>
}
    80003284:	60e2                	ld	ra,24(sp)
    80003286:	6442                	ld	s0,16(sp)
    80003288:	64a2                	ld	s1,8(sp)
    8000328a:	6902                	ld	s2,0(sp)
    8000328c:	6105                	addi	sp,sp,32
    8000328e:	8082                	ret
    panic("freeing free block");
    80003290:	00006517          	auipc	a0,0x6
    80003294:	13050513          	addi	a0,a0,304 # 800093c0 <etext+0x3c0>
    80003298:	d7afd0ef          	jal	80000812 <panic>

000000008000329c <balloc>:
{
    8000329c:	711d                	addi	sp,sp,-96
    8000329e:	ec86                	sd	ra,88(sp)
    800032a0:	e8a2                	sd	s0,80(sp)
    800032a2:	e4a6                	sd	s1,72(sp)
    800032a4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800032a6:	0001d797          	auipc	a5,0x1d
    800032aa:	40e7a783          	lw	a5,1038(a5) # 800206b4 <sb+0x4>
    800032ae:	10078c63          	beqz	a5,800033c6 <balloc+0x12a>
    800032b2:	e0ca                	sd	s2,64(sp)
    800032b4:	fc4e                	sd	s3,56(sp)
    800032b6:	f852                	sd	s4,48(sp)
    800032b8:	f456                	sd	s5,40(sp)
    800032ba:	f05a                	sd	s6,32(sp)
    800032bc:	ec5e                	sd	s7,24(sp)
    800032be:	e862                	sd	s8,16(sp)
    800032c0:	e466                	sd	s9,8(sp)
    800032c2:	8baa                	mv	s7,a0
    800032c4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800032c6:	0001db17          	auipc	s6,0x1d
    800032ca:	3eab0b13          	addi	s6,s6,1002 # 800206b0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032ce:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800032d0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032d2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800032d4:	6c89                	lui	s9,0x2
    800032d6:	a059                	j	8000335c <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032d8:	97ca                	add	a5,a5,s2
    800032da:	8e55                	or	a2,a2,a3
    800032dc:	04c78c23          	sb	a2,88(a5)
        balloc_report("BALLOC", b + bi, old_bit, 1, "Allocated block");
    800032e0:	00006717          	auipc	a4,0x6
    800032e4:	11070713          	addi	a4,a4,272 # 800093f0 <etext+0x3f0>
    800032e8:	4685                	li	a3,1
    800032ea:	4601                	li	a2,0
    800032ec:	85a6                	mv	a1,s1
    800032ee:	00006517          	auipc	a0,0x6
    800032f2:	11250513          	addi	a0,a0,274 # 80009400 <etext+0x400>
    800032f6:	e6fff0ef          	jal	80003164 <balloc_report>
        log_write(bp);
    800032fa:	854a                	mv	a0,s2
    800032fc:	085010ef          	jal	80004b80 <log_write>
        brelse(bp);
    80003300:	854a                	mv	a0,s2
    80003302:	b5fff0ef          	jal	80002e60 <brelse>
  bp = bread(dev, bno);
    80003306:	85a6                	mv	a1,s1
    80003308:	855e                	mv	a0,s7
    8000330a:	88dff0ef          	jal	80002b96 <bread>
    8000330e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003310:	40000613          	li	a2,1024
    80003314:	4581                	li	a1,0
    80003316:	05850513          	addi	a0,a0,88
    8000331a:	9bbfd0ef          	jal	80000cd4 <memset>
  log_write(bp);
    8000331e:	854a                	mv	a0,s2
    80003320:	061010ef          	jal	80004b80 <log_write>
  brelse(bp);
    80003324:	854a                	mv	a0,s2
    80003326:	b3bff0ef          	jal	80002e60 <brelse>
}
    8000332a:	6906                	ld	s2,64(sp)
    8000332c:	79e2                	ld	s3,56(sp)
    8000332e:	7a42                	ld	s4,48(sp)
    80003330:	7aa2                	ld	s5,40(sp)
    80003332:	7b02                	ld	s6,32(sp)
    80003334:	6be2                	ld	s7,24(sp)
    80003336:	6c42                	ld	s8,16(sp)
    80003338:	6ca2                	ld	s9,8(sp)
}
    8000333a:	8526                	mv	a0,s1
    8000333c:	60e6                	ld	ra,88(sp)
    8000333e:	6446                	ld	s0,80(sp)
    80003340:	64a6                	ld	s1,72(sp)
    80003342:	6125                	addi	sp,sp,96
    80003344:	8082                	ret
    brelse(bp);
    80003346:	854a                	mv	a0,s2
    80003348:	b19ff0ef          	jal	80002e60 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000334c:	015c87bb          	addw	a5,s9,s5
    80003350:	00078a9b          	sext.w	s5,a5
    80003354:	004b2703          	lw	a4,4(s6)
    80003358:	04eaff63          	bgeu	s5,a4,800033b6 <balloc+0x11a>
    bp = bread(dev, BBLOCK(b, sb));
    8000335c:	41fad79b          	sraiw	a5,s5,0x1f
    80003360:	0137d79b          	srliw	a5,a5,0x13
    80003364:	015787bb          	addw	a5,a5,s5
    80003368:	40d7d79b          	sraiw	a5,a5,0xd
    8000336c:	01cb2583          	lw	a1,28(s6)
    80003370:	9dbd                	addw	a1,a1,a5
    80003372:	855e                	mv	a0,s7
    80003374:	823ff0ef          	jal	80002b96 <bread>
    80003378:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000337a:	004b2503          	lw	a0,4(s6)
    8000337e:	000a849b          	sext.w	s1,s5
    80003382:	8762                	mv	a4,s8
    80003384:	fca4f1e3          	bgeu	s1,a0,80003346 <balloc+0xaa>
      m = 1 << (bi % 8);
    80003388:	00777693          	andi	a3,a4,7
    8000338c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){
    80003390:	41f7579b          	sraiw	a5,a4,0x1f
    80003394:	01d7d79b          	srliw	a5,a5,0x1d
    80003398:	9fb9                	addw	a5,a5,a4
    8000339a:	4037d79b          	sraiw	a5,a5,0x3
    8000339e:	00f90633          	add	a2,s2,a5
    800033a2:	05864603          	lbu	a2,88(a2)
    800033a6:	00c6f5b3          	and	a1,a3,a2
    800033aa:	d59d                	beqz	a1,800032d8 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033ac:	2705                	addiw	a4,a4,1
    800033ae:	2485                	addiw	s1,s1,1
    800033b0:	fd471ae3          	bne	a4,s4,80003384 <balloc+0xe8>
    800033b4:	bf49                	j	80003346 <balloc+0xaa>
    800033b6:	6906                	ld	s2,64(sp)
    800033b8:	79e2                	ld	s3,56(sp)
    800033ba:	7a42                	ld	s4,48(sp)
    800033bc:	7aa2                	ld	s5,40(sp)
    800033be:	7b02                	ld	s6,32(sp)
    800033c0:	6be2                	ld	s7,24(sp)
    800033c2:	6c42                	ld	s8,16(sp)
    800033c4:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800033c6:	00006517          	auipc	a0,0x6
    800033ca:	04250513          	addi	a0,a0,66 # 80009408 <etext+0x408>
    800033ce:	95efd0ef          	jal	8000052c <printf>
  return 0;
    800033d2:	4481                	li	s1,0
    800033d4:	b79d                	j	8000333a <balloc+0x9e>

00000000800033d6 <inode_report>:
{
    800033d6:	db010113          	addi	sp,sp,-592
    800033da:	24113423          	sd	ra,584(sp)
    800033de:	24813023          	sd	s0,576(sp)
    800033e2:	22913c23          	sd	s1,568(sp)
    800033e6:	23213823          	sd	s2,560(sp)
    800033ea:	23313423          	sd	s3,552(sp)
    800033ee:	23413023          	sd	s4,544(sp)
    800033f2:	21513c23          	sd	s5,536(sp)
    800033f6:	21613823          	sd	s6,528(sp)
    800033fa:	21713423          	sd	s7,520(sp)
    800033fe:	21813023          	sd	s8,512(sp)
    80003402:	0c80                	addi	s0,sp,592
    80003404:	8c2a                	mv	s8,a0
    80003406:	84ae                	mv	s1,a1
    80003408:	8bb2                	mv	s7,a2
    8000340a:	8b36                	mv	s6,a3
    8000340c:	8aba                	mv	s5,a4
    8000340e:	8a3e                	mv	s4,a5
    80003410:	89c2                	mv	s3,a6
    80003412:	8946                	mv	s2,a7
  memset(&e, 0, sizeof(e));
    80003414:	20000613          	li	a2,512
    80003418:	4581                	li	a1,0
    8000341a:	db040513          	addi	a0,s0,-592
    8000341e:	8b7fd0ef          	jal	80000cd4 <memset>
  e.ticks = ticks;
    80003422:	00007797          	auipc	a5,0x7
    80003426:	c267a783          	lw	a5,-986(a5) # 8000a048 <ticks>
    8000342a:	daf42c23          	sw	a5,-584(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    8000342e:	cdafe0ef          	jal	80001908 <myproc>
    80003432:	4781                	li	a5,0
    80003434:	c501                	beqz	a0,8000343c <inode_report+0x66>
    80003436:	cd2fe0ef          	jal	80001908 <myproc>
    8000343a:	591c                	lw	a5,48(a0)
    8000343c:	daf42e23          	sw	a5,-580(s0)
  e.type = LAYER_INODE;
    80003440:	4791                	li	a5,4
    80003442:	dcf42023          	sw	a5,-576(s0)
  safestrcpy(e.op_name, op, 16);
    80003446:	4641                	li	a2,16
    80003448:	85e2                	mv	a1,s8
    8000344a:	dc440513          	addi	a0,s0,-572
    8000344e:	9c5fd0ef          	jal	80000e12 <safestrcpy>
  e.inode.inum = ip->inum;
    80003452:	40dc                	lw	a5,4(s1)
    80003454:	f0f42823          	sw	a5,-240(s0)
  e.inode.ref = ip->ref;
    80003458:	449c                	lw	a5,8(s1)
    8000345a:	f0f42a23          	sw	a5,-236(s0)
  e.inode.old_ref = old_ref;
    8000345e:	f1742c23          	sw	s7,-232(s0)
  e.inode.valid_inode = ip->valid;
    80003462:	40bc                	lw	a5,64(s1)
    80003464:	f0f42e23          	sw	a5,-228(s0)
  e.inode.old_valid_inode = old_valid;
    80003468:	f3642023          	sw	s6,-224(s0)
  e.inode.type_inode = ip->type;
    8000346c:	04449783          	lh	a5,68(s1)
    80003470:	f2f42223          	sw	a5,-220(s0)
  e.inode.old_type_inode = old_type;
    80003474:	f3542423          	sw	s5,-216(s0)
  e.inode.size = ip->size;
    80003478:	44fc                	lw	a5,76(s1)
    8000347a:	f2f42623          	sw	a5,-212(s0)
  e.inode.old_size = old_size;
    8000347e:	f3442823          	sw	s4,-208(s0)
  e.inode.locked = holdingsleep(&ip->lock);
    80003482:	01048513          	addi	a0,s1,16
    80003486:	097010ef          	jal	80004d1c <holdingsleep>
    8000348a:	f2a42a23          	sw	a0,-204(s0)
  e.inode.old_locked = old_locked;
    8000348e:	f3342c23          	sw	s3,-200(s0)
  safestrcpy(e.details, det, 128);
    80003492:	08000613          	li	a2,128
    80003496:	85ca                	mv	a1,s2
    80003498:	dd440513          	addi	a0,s0,-556
    8000349c:	977fd0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    800034a0:	db040513          	addi	a0,s0,-592
    800034a4:	2f5030ef          	jal	80006f98 <fslog_push>
}
    800034a8:	24813083          	ld	ra,584(sp)
    800034ac:	24013403          	ld	s0,576(sp)
    800034b0:	23813483          	ld	s1,568(sp)
    800034b4:	23013903          	ld	s2,560(sp)
    800034b8:	22813983          	ld	s3,552(sp)
    800034bc:	22013a03          	ld	s4,544(sp)
    800034c0:	21813a83          	ld	s5,536(sp)
    800034c4:	21013b03          	ld	s6,528(sp)
    800034c8:	20813b83          	ld	s7,520(sp)
    800034cc:	20013c03          	ld	s8,512(sp)
    800034d0:	25010113          	addi	sp,sp,592
    800034d4:	8082                	ret

00000000800034d6 <iget>:

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
{
    800034d6:	7179                	addi	sp,sp,-48
    800034d8:	f406                	sd	ra,40(sp)
    800034da:	f022                	sd	s0,32(sp)
    800034dc:	ec26                	sd	s1,24(sp)
    800034de:	e84a                	sd	s2,16(sp)
    800034e0:	e44e                	sd	s3,8(sp)
    800034e2:	e052                	sd	s4,0(sp)
    800034e4:	1800                	addi	s0,sp,48
    800034e6:	89aa                	mv	s3,a0
    800034e8:	8a2e                	mv	s4,a1
  struct inode *ip, *empty;

  acquire(&itable.lock);
    800034ea:	0001d517          	auipc	a0,0x1d
    800034ee:	1e650513          	addi	a0,a0,486 # 800206d0 <itable>
    800034f2:	f0efd0ef          	jal	80000c00 <acquire>

  // Is the inode already in the table?
  empty = 0;
    800034f6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034f8:	0001d497          	auipc	s1,0x1d
    800034fc:	1f048493          	addi	s1,s1,496 # 800206e8 <itable+0x18>
    80003500:	0001f717          	auipc	a4,0x1f
    80003504:	c7870713          	addi	a4,a4,-904 # 80022178 <log>
    80003508:	a039                	j	80003516 <iget+0x40>
      0,
      "Inode found in cache");
      release(&itable.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000350a:	04090a63          	beqz	s2,8000355e <iget+0x88>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000350e:	08848493          	addi	s1,s1,136
    80003512:	04e48963          	beq	s1,a4,80003564 <iget+0x8e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003516:	4490                	lw	a2,8(s1)
    80003518:	fec059e3          	blez	a2,8000350a <iget+0x34>
    8000351c:	409c                	lw	a5,0(s1)
    8000351e:	ff3796e3          	bne	a5,s3,8000350a <iget+0x34>
    80003522:	40dc                	lw	a5,4(s1)
    80003524:	ff4793e3          	bne	a5,s4,8000350a <iget+0x34>
      ip->ref++;
    80003528:	0016079b          	addiw	a5,a2,1
    8000352c:	c49c                	sw	a5,8(s1)
       inode_report("IGET_HIT", ip,
    8000352e:	00006897          	auipc	a7,0x6
    80003532:	ef288893          	addi	a7,a7,-270 # 80009420 <etext+0x420>
    80003536:	4801                	li	a6,0
    80003538:	44fc                	lw	a5,76(s1)
    8000353a:	04449703          	lh	a4,68(s1)
    8000353e:	40b4                	lw	a3,64(s1)
    80003540:	85a6                	mv	a1,s1
    80003542:	00006517          	auipc	a0,0x6
    80003546:	ef650513          	addi	a0,a0,-266 # 80009438 <etext+0x438>
    8000354a:	e8dff0ef          	jal	800033d6 <inode_report>
      release(&itable.lock);
    8000354e:	0001d517          	auipc	a0,0x1d
    80003552:	18250513          	addi	a0,a0,386 # 800206d0 <itable>
    80003556:	f42fd0ef          	jal	80000c98 <release>
      return ip;
    8000355a:	8926                	mv	s2,s1
    8000355c:	a0a9                	j	800035a6 <iget+0xd0>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000355e:	fa45                	bnez	a2,8000350e <iget+0x38>
      empty = ip;
    80003560:	8926                	mv	s2,s1
    80003562:	b775                	j	8000350e <iget+0x38>
  }

  // Recycle an inode entry.
  if(empty == 0)
    80003564:	04090a63          	beqz	s2,800035b8 <iget+0xe2>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
    80003568:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000356c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003570:	4785                	li	a5,1
    80003572:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003576:	04092023          	sw	zero,64(s2)
  inode_report("IGET_NEW", ip,
    8000357a:	00006897          	auipc	a7,0x6
    8000357e:	ede88893          	addi	a7,a7,-290 # 80009458 <etext+0x458>
    80003582:	4801                	li	a6,0
    80003584:	4781                	li	a5,0
    80003586:	4701                	li	a4,0
    80003588:	4681                	li	a3,0
    8000358a:	4601                	li	a2,0
    8000358c:	85ca                	mv	a1,s2
    8000358e:	00006517          	auipc	a0,0x6
    80003592:	eea50513          	addi	a0,a0,-278 # 80009478 <etext+0x478>
    80003596:	e41ff0ef          	jal	800033d6 <inode_report>
    0, 0,
    0, 0,
    0,
    "Allocated new inode in table");
  release(&itable.lock);
    8000359a:	0001d517          	auipc	a0,0x1d
    8000359e:	13650513          	addi	a0,a0,310 # 800206d0 <itable>
    800035a2:	ef6fd0ef          	jal	80000c98 <release>

  return ip;
}
    800035a6:	854a                	mv	a0,s2
    800035a8:	70a2                	ld	ra,40(sp)
    800035aa:	7402                	ld	s0,32(sp)
    800035ac:	64e2                	ld	s1,24(sp)
    800035ae:	6942                	ld	s2,16(sp)
    800035b0:	69a2                	ld	s3,8(sp)
    800035b2:	6a02                	ld	s4,0(sp)
    800035b4:	6145                	addi	sp,sp,48
    800035b6:	8082                	ret
    panic("iget: no inodes");
    800035b8:	00006517          	auipc	a0,0x6
    800035bc:	e9050513          	addi	a0,a0,-368 # 80009448 <etext+0x448>
    800035c0:	a52fd0ef          	jal	80000812 <panic>

00000000800035c4 <bmap>:
// Inode content

// Return the disk block address of the nth block in inode ip.
static uint
bmap(struct inode *ip, uint bn)
{
    800035c4:	7179                	addi	sp,sp,-48
    800035c6:	f406                	sd	ra,40(sp)
    800035c8:	f022                	sd	s0,32(sp)
    800035ca:	ec26                	sd	s1,24(sp)
    800035cc:	e84a                	sd	s2,16(sp)
    800035ce:	e44e                	sd	s3,8(sp)
    800035d0:	1800                	addi	s0,sp,48
    800035d2:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035d4:	47ad                	li	a5,11
    800035d6:	04b7ea63          	bltu	a5,a1,8000362a <bmap+0x66>
    if((addr = ip->addrs[bn]) == 0){
    800035da:	02059793          	slli	a5,a1,0x20
    800035de:	01e7d593          	srli	a1,a5,0x1e
    800035e2:	00b504b3          	add	s1,a0,a1
    800035e6:	0504a983          	lw	s3,80(s1)
    800035ea:	0c099263          	bnez	s3,800036ae <bmap+0xea>
      addr = balloc(ip->dev);
    800035ee:	4108                	lw	a0,0(a0)
    800035f0:	cadff0ef          	jal	8000329c <balloc>
    800035f4:	0005099b          	sext.w	s3,a0

inode_report("BMAP_ALLOC_DIRECT", ip,
    800035f8:	00006897          	auipc	a7,0x6
    800035fc:	e9088893          	addi	a7,a7,-368 # 80009488 <etext+0x488>
    80003600:	4805                	li	a6,1
    80003602:	04c92783          	lw	a5,76(s2)
    80003606:	04491703          	lh	a4,68(s2)
    8000360a:	04092683          	lw	a3,64(s2)
    8000360e:	00892603          	lw	a2,8(s2)
    80003612:	85ca                	mv	a1,s2
    80003614:	00006517          	auipc	a0,0x6
    80003618:	e8c50513          	addi	a0,a0,-372 # 800094a0 <etext+0x4a0>
    8000361c:	dbbff0ef          	jal	800033d6 <inode_report>
    ip->valid,
    ip->type,
    ip->size,
    1,
    "Allocated direct block");
      if(addr == 0)
    80003620:	08098763          	beqz	s3,800036ae <bmap+0xea>
        return 0;
      ip->addrs[bn] = addr;
    80003624:	0534a823          	sw	s3,80(s1)
    80003628:	a059                	j	800036ae <bmap+0xea>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000362a:	ff45849b          	addiw	s1,a1,-12
    8000362e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003632:	0ff00793          	li	a5,255
    80003636:	0ce7e663          	bltu	a5,a4,80003702 <bmap+0x13e>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000363a:	08052983          	lw	s3,128(a0)
    8000363e:	04099163          	bnez	s3,80003680 <bmap+0xbc>
      addr = balloc(ip->dev);
    80003642:	4108                	lw	a0,0(a0)
    80003644:	c59ff0ef          	jal	8000329c <balloc>
    80003648:	0005099b          	sext.w	s3,a0
      inode_report("BMAP_ALLOC_INDIRECT", ip,
    8000364c:	00006897          	auipc	a7,0x6
    80003650:	e6c88893          	addi	a7,a7,-404 # 800094b8 <etext+0x4b8>
    80003654:	4805                	li	a6,1
    80003656:	04c92783          	lw	a5,76(s2)
    8000365a:	04491703          	lh	a4,68(s2)
    8000365e:	04092683          	lw	a3,64(s2)
    80003662:	00892603          	lw	a2,8(s2)
    80003666:	85ca                	mv	a1,s2
    80003668:	00006517          	auipc	a0,0x6
    8000366c:	e7050513          	addi	a0,a0,-400 # 800094d8 <etext+0x4d8>
    80003670:	d67ff0ef          	jal	800033d6 <inode_report>
    ip->valid,
    ip->type,
    ip->size,
    1,
    "Allocated indirect block table");
      if(addr == 0)
    80003674:	02098d63          	beqz	s3,800036ae <bmap+0xea>
    80003678:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000367a:	09392023          	sw	s3,128(s2)
    8000367e:	a011                	j	80003682 <bmap+0xbe>
    80003680:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003682:	85ce                	mv	a1,s3
    80003684:	00092503          	lw	a0,0(s2)
    80003688:	d0eff0ef          	jal	80002b96 <bread>
    8000368c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000368e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003692:	02049713          	slli	a4,s1,0x20
    80003696:	01e75593          	srli	a1,a4,0x1e
    8000369a:	00b784b3          	add	s1,a5,a1
    8000369e:	0004a983          	lw	s3,0(s1)
    800036a2:	00098e63          	beqz	s3,800036be <bmap+0xfa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800036a6:	8552                	mv	a0,s4
    800036a8:	fb8ff0ef          	jal	80002e60 <brelse>
    return addr;
    800036ac:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800036ae:	854e                	mv	a0,s3
    800036b0:	70a2                	ld	ra,40(sp)
    800036b2:	7402                	ld	s0,32(sp)
    800036b4:	64e2                	ld	s1,24(sp)
    800036b6:	6942                	ld	s2,16(sp)
    800036b8:	69a2                	ld	s3,8(sp)
    800036ba:	6145                	addi	sp,sp,48
    800036bc:	8082                	ret
      inode_report("BMAP_ALLOC_DATA", ip,
    800036be:	00006897          	auipc	a7,0x6
    800036c2:	e3288893          	addi	a7,a7,-462 # 800094f0 <etext+0x4f0>
    800036c6:	4805                	li	a6,1
    800036c8:	04c92783          	lw	a5,76(s2)
    800036cc:	04491703          	lh	a4,68(s2)
    800036d0:	04092683          	lw	a3,64(s2)
    800036d4:	00892603          	lw	a2,8(s2)
    800036d8:	85ca                	mv	a1,s2
    800036da:	00006517          	auipc	a0,0x6
    800036de:	e3650513          	addi	a0,a0,-458 # 80009510 <etext+0x510>
    800036e2:	cf5ff0ef          	jal	800033d6 <inode_report>
      addr = balloc(ip->dev);
    800036e6:	00092503          	lw	a0,0(s2)
    800036ea:	bb3ff0ef          	jal	8000329c <balloc>
    800036ee:	0005099b          	sext.w	s3,a0
      if(addr){
    800036f2:	fa098ae3          	beqz	s3,800036a6 <bmap+0xe2>
        a[bn] = addr;
    800036f6:	0134a023          	sw	s3,0(s1)
        log_write(bp);
    800036fa:	8552                	mv	a0,s4
    800036fc:	484010ef          	jal	80004b80 <log_write>
    80003700:	b75d                	j	800036a6 <bmap+0xe2>
    80003702:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003704:	00006517          	auipc	a0,0x6
    80003708:	e1c50513          	addi	a0,a0,-484 # 80009520 <etext+0x520>
    8000370c:	906fd0ef          	jal	80000812 <panic>

0000000080003710 <iinit>:
{
    80003710:	7179                	addi	sp,sp,-48
    80003712:	f406                	sd	ra,40(sp)
    80003714:	f022                	sd	s0,32(sp)
    80003716:	ec26                	sd	s1,24(sp)
    80003718:	e84a                	sd	s2,16(sp)
    8000371a:	e44e                	sd	s3,8(sp)
    8000371c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000371e:	00006597          	auipc	a1,0x6
    80003722:	e1a58593          	addi	a1,a1,-486 # 80009538 <etext+0x538>
    80003726:	0001d517          	auipc	a0,0x1d
    8000372a:	faa50513          	addi	a0,a0,-86 # 800206d0 <itable>
    8000372e:	c52fd0ef          	jal	80000b80 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003732:	0001d497          	auipc	s1,0x1d
    80003736:	fc648493          	addi	s1,s1,-58 # 800206f8 <itable+0x28>
    8000373a:	0001f997          	auipc	s3,0x1f
    8000373e:	a4e98993          	addi	s3,s3,-1458 # 80022188 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003742:	00006917          	auipc	s2,0x6
    80003746:	e8690913          	addi	s2,s2,-378 # 800095c8 <etext+0x5c8>
    8000374a:	85ca                	mv	a1,s2
    8000374c:	8526                	mv	a0,s1
    8000374e:	51a010ef          	jal	80004c68 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003752:	08848493          	addi	s1,s1,136
    80003756:	ff349ae3          	bne	s1,s3,8000374a <iinit+0x3a>
}
    8000375a:	70a2                	ld	ra,40(sp)
    8000375c:	7402                	ld	s0,32(sp)
    8000375e:	64e2                	ld	s1,24(sp)
    80003760:	6942                	ld	s2,16(sp)
    80003762:	69a2                	ld	s3,8(sp)
    80003764:	6145                	addi	sp,sp,48
    80003766:	8082                	ret

0000000080003768 <ialloc>:
{
    80003768:	7139                	addi	sp,sp,-64
    8000376a:	fc06                	sd	ra,56(sp)
    8000376c:	f822                	sd	s0,48(sp)
    8000376e:	f04a                	sd	s2,32(sp)
    80003770:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003772:	0001d717          	auipc	a4,0x1d
    80003776:	f4a72703          	lw	a4,-182(a4) # 800206bc <sb+0xc>
    8000377a:	4785                	li	a5,1
    8000377c:	04e7fe63          	bgeu	a5,a4,800037d8 <ialloc+0x70>
    80003780:	f426                	sd	s1,40(sp)
    80003782:	ec4e                	sd	s3,24(sp)
    80003784:	e852                	sd	s4,16(sp)
    80003786:	e456                	sd	s5,8(sp)
    80003788:	e05a                	sd	s6,0(sp)
    8000378a:	8aaa                	mv	s5,a0
    8000378c:	8b2e                	mv	s6,a1
    8000378e:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003790:	0001da17          	auipc	s4,0x1d
    80003794:	f20a0a13          	addi	s4,s4,-224 # 800206b0 <sb>
    80003798:	00495593          	srli	a1,s2,0x4
    8000379c:	018a2783          	lw	a5,24(s4)
    800037a0:	9dbd                	addw	a1,a1,a5
    800037a2:	8556                	mv	a0,s5
    800037a4:	bf2ff0ef          	jal	80002b96 <bread>
    800037a8:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037aa:	05850993          	addi	s3,a0,88
    800037ae:	00f97793          	andi	a5,s2,15
    800037b2:	079a                	slli	a5,a5,0x6
    800037b4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037b6:	00099783          	lh	a5,0(s3)
    800037ba:	cf85                	beqz	a5,800037f2 <ialloc+0x8a>
    brelse(bp);
    800037bc:	ea4ff0ef          	jal	80002e60 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037c0:	0905                	addi	s2,s2,1
    800037c2:	00ca2703          	lw	a4,12(s4)
    800037c6:	0009079b          	sext.w	a5,s2
    800037ca:	fce7e7e3          	bltu	a5,a4,80003798 <ialloc+0x30>
    800037ce:	74a2                	ld	s1,40(sp)
    800037d0:	69e2                	ld	s3,24(sp)
    800037d2:	6a42                	ld	s4,16(sp)
    800037d4:	6aa2                	ld	s5,8(sp)
    800037d6:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800037d8:	00006517          	auipc	a0,0x6
    800037dc:	d8850513          	addi	a0,a0,-632 # 80009560 <etext+0x560>
    800037e0:	d4dfc0ef          	jal	8000052c <printf>
  return 0;
    800037e4:	4901                	li	s2,0
}
    800037e6:	854a                	mv	a0,s2
    800037e8:	70e2                	ld	ra,56(sp)
    800037ea:	7442                	ld	s0,48(sp)
    800037ec:	7902                	ld	s2,32(sp)
    800037ee:	6121                	addi	sp,sp,64
    800037f0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800037f2:	04000613          	li	a2,64
    800037f6:	4581                	li	a1,0
    800037f8:	854e                	mv	a0,s3
    800037fa:	cdafd0ef          	jal	80000cd4 <memset>
      dip->type = type;
    800037fe:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003802:	8526                	mv	a0,s1
    80003804:	37c010ef          	jal	80004b80 <log_write>
      struct inode *ip = iget(dev, inum);
    80003808:	0009059b          	sext.w	a1,s2
    8000380c:	8556                	mv	a0,s5
    8000380e:	cc9ff0ef          	jal	800034d6 <iget>
    80003812:	892a                	mv	s2,a0
      inode_report("IALLOC", ip,
    80003814:	00006897          	auipc	a7,0x6
    80003818:	d2c88893          	addi	a7,a7,-724 # 80009540 <etext+0x540>
    8000381c:	4801                	li	a6,0
    8000381e:	4781                	li	a5,0
    80003820:	4701                	li	a4,0
    80003822:	4681                	li	a3,0
    80003824:	4601                	li	a2,0
    80003826:	85aa                	mv	a1,a0
    80003828:	00006517          	auipc	a0,0x6
    8000382c:	d3050513          	addi	a0,a0,-720 # 80009558 <etext+0x558>
    80003830:	ba7ff0ef          	jal	800033d6 <inode_report>
      brelse(bp);
    80003834:	8526                	mv	a0,s1
    80003836:	e2aff0ef          	jal	80002e60 <brelse>
      return ip;
    8000383a:	74a2                	ld	s1,40(sp)
    8000383c:	69e2                	ld	s3,24(sp)
    8000383e:	6a42                	ld	s4,16(sp)
    80003840:	6aa2                	ld	s5,8(sp)
    80003842:	6b02                	ld	s6,0(sp)
    80003844:	b74d                	j	800037e6 <ialloc+0x7e>

0000000080003846 <iupdate>:
{
    80003846:	1101                	addi	sp,sp,-32
    80003848:	ec06                	sd	ra,24(sp)
    8000384a:	e822                	sd	s0,16(sp)
    8000384c:	e426                	sd	s1,8(sp)
    8000384e:	e04a                	sd	s2,0(sp)
    80003850:	1000                	addi	s0,sp,32
    80003852:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003854:	415c                	lw	a5,4(a0)
    80003856:	0047d79b          	srliw	a5,a5,0x4
    8000385a:	0001d597          	auipc	a1,0x1d
    8000385e:	e6e5a583          	lw	a1,-402(a1) # 800206c8 <sb+0x18>
    80003862:	9dbd                	addw	a1,a1,a5
    80003864:	4108                	lw	a0,0(a0)
    80003866:	b30ff0ef          	jal	80002b96 <bread>
    8000386a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000386c:	05850793          	addi	a5,a0,88
    80003870:	40d8                	lw	a4,4(s1)
    80003872:	8b3d                	andi	a4,a4,15
    80003874:	071a                	slli	a4,a4,0x6
    80003876:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003878:	04449703          	lh	a4,68(s1)
    8000387c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003880:	04649703          	lh	a4,70(s1)
    80003884:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003888:	04849703          	lh	a4,72(s1)
    8000388c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003890:	04a49703          	lh	a4,74(s1)
    80003894:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003898:	44f8                	lw	a4,76(s1)
    8000389a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000389c:	03400613          	li	a2,52
    800038a0:	05048593          	addi	a1,s1,80
    800038a4:	00c78513          	addi	a0,a5,12
    800038a8:	c88fd0ef          	jal	80000d30 <memmove>
  inode_report("IUPDATE", ip,
    800038ac:	00006897          	auipc	a7,0x6
    800038b0:	ccc88893          	addi	a7,a7,-820 # 80009578 <etext+0x578>
    800038b4:	4805                	li	a6,1
    800038b6:	44fc                	lw	a5,76(s1)
    800038b8:	04449703          	lh	a4,68(s1)
    800038bc:	40b4                	lw	a3,64(s1)
    800038be:	4490                	lw	a2,8(s1)
    800038c0:	85a6                	mv	a1,s1
    800038c2:	00006517          	auipc	a0,0x6
    800038c6:	cce50513          	addi	a0,a0,-818 # 80009590 <etext+0x590>
    800038ca:	b0dff0ef          	jal	800033d6 <inode_report>
  log_write(bp);
    800038ce:	854a                	mv	a0,s2
    800038d0:	2b0010ef          	jal	80004b80 <log_write>
  brelse(bp);
    800038d4:	854a                	mv	a0,s2
    800038d6:	d8aff0ef          	jal	80002e60 <brelse>
}
    800038da:	60e2                	ld	ra,24(sp)
    800038dc:	6442                	ld	s0,16(sp)
    800038de:	64a2                	ld	s1,8(sp)
    800038e0:	6902                	ld	s2,0(sp)
    800038e2:	6105                	addi	sp,sp,32
    800038e4:	8082                	ret

00000000800038e6 <idup>:
{
    800038e6:	1101                	addi	sp,sp,-32
    800038e8:	ec06                	sd	ra,24(sp)
    800038ea:	e822                	sd	s0,16(sp)
    800038ec:	e426                	sd	s1,8(sp)
    800038ee:	1000                	addi	s0,sp,32
    800038f0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038f2:	0001d517          	auipc	a0,0x1d
    800038f6:	dde50513          	addi	a0,a0,-546 # 800206d0 <itable>
    800038fa:	b06fd0ef          	jal	80000c00 <acquire>
  int old_ref = ip->ref;
    800038fe:	4490                	lw	a2,8(s1)
  ip->ref++;
    80003900:	0016079b          	addiw	a5,a2,1
    80003904:	c49c                	sw	a5,8(s1)
  inode_report("IDUP", ip,
    80003906:	00006897          	auipc	a7,0x6
    8000390a:	c9288893          	addi	a7,a7,-878 # 80009598 <etext+0x598>
    8000390e:	4801                	li	a6,0
    80003910:	44fc                	lw	a5,76(s1)
    80003912:	04449703          	lh	a4,68(s1)
    80003916:	40b4                	lw	a3,64(s1)
    80003918:	85a6                	mv	a1,s1
    8000391a:	00006517          	auipc	a0,0x6
    8000391e:	c9650513          	addi	a0,a0,-874 # 800095b0 <etext+0x5b0>
    80003922:	ab5ff0ef          	jal	800033d6 <inode_report>
  release(&itable.lock);
    80003926:	0001d517          	auipc	a0,0x1d
    8000392a:	daa50513          	addi	a0,a0,-598 # 800206d0 <itable>
    8000392e:	b6afd0ef          	jal	80000c98 <release>
}
    80003932:	8526                	mv	a0,s1
    80003934:	60e2                	ld	ra,24(sp)
    80003936:	6442                	ld	s0,16(sp)
    80003938:	64a2                	ld	s1,8(sp)
    8000393a:	6105                	addi	sp,sp,32
    8000393c:	8082                	ret

000000008000393e <ilock>:
{
    8000393e:	1101                	addi	sp,sp,-32
    80003940:	ec06                	sd	ra,24(sp)
    80003942:	e822                	sd	s0,16(sp)
    80003944:	e426                	sd	s1,8(sp)
    80003946:	e04a                	sd	s2,0(sp)
    80003948:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000394a:	c139                	beqz	a0,80003990 <ilock+0x52>
    8000394c:	84aa                	mv	s1,a0
    8000394e:	451c                	lw	a5,8(a0)
    80003950:	04f05063          	blez	a5,80003990 <ilock+0x52>
   int old_valid = ip->valid;
    80003954:	04052903          	lw	s2,64(a0)
  acquiresleep(&ip->lock);
    80003958:	0541                	addi	a0,a0,16
    8000395a:	344010ef          	jal	80004c9e <acquiresleep>
  inode_report("ILOCK_ACQUIRE", ip,
    8000395e:	00006897          	auipc	a7,0x6
    80003962:	c6288893          	addi	a7,a7,-926 # 800095c0 <etext+0x5c0>
    80003966:	4801                	li	a6,0
    80003968:	44fc                	lw	a5,76(s1)
    8000396a:	04449703          	lh	a4,68(s1)
    8000396e:	86ca                	mv	a3,s2
    80003970:	4490                	lw	a2,8(s1)
    80003972:	85a6                	mv	a1,s1
    80003974:	00006517          	auipc	a0,0x6
    80003978:	c5c50513          	addi	a0,a0,-932 # 800095d0 <etext+0x5d0>
    8000397c:	a5bff0ef          	jal	800033d6 <inode_report>
  if(ip->valid == 0){
    80003980:	40bc                	lw	a5,64(s1)
    80003982:	cf89                	beqz	a5,8000399c <ilock+0x5e>
}
    80003984:	60e2                	ld	ra,24(sp)
    80003986:	6442                	ld	s0,16(sp)
    80003988:	64a2                	ld	s1,8(sp)
    8000398a:	6902                	ld	s2,0(sp)
    8000398c:	6105                	addi	sp,sp,32
    8000398e:	8082                	ret
    panic("ilock");
    80003990:	00006517          	auipc	a0,0x6
    80003994:	c2850513          	addi	a0,a0,-984 # 800095b8 <etext+0x5b8>
    80003998:	e7bfc0ef          	jal	80000812 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000399c:	40dc                	lw	a5,4(s1)
    8000399e:	0047d79b          	srliw	a5,a5,0x4
    800039a2:	0001d597          	auipc	a1,0x1d
    800039a6:	d265a583          	lw	a1,-730(a1) # 800206c8 <sb+0x18>
    800039aa:	9dbd                	addw	a1,a1,a5
    800039ac:	4088                	lw	a0,0(s1)
    800039ae:	9e8ff0ef          	jal	80002b96 <bread>
    800039b2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039b4:	05850593          	addi	a1,a0,88
    800039b8:	40dc                	lw	a5,4(s1)
    800039ba:	8bbd                	andi	a5,a5,15
    800039bc:	079a                	slli	a5,a5,0x6
    800039be:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039c0:	00059783          	lh	a5,0(a1)
    800039c4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039c8:	00259783          	lh	a5,2(a1)
    800039cc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039d0:	00459783          	lh	a5,4(a1)
    800039d4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039d8:	00659783          	lh	a5,6(a1)
    800039dc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039e0:	459c                	lw	a5,8(a1)
    800039e2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039e4:	03400613          	li	a2,52
    800039e8:	05b1                	addi	a1,a1,12
    800039ea:	05048513          	addi	a0,s1,80
    800039ee:	b42fd0ef          	jal	80000d30 <memmove>
    brelse(bp);
    800039f2:	854a                	mv	a0,s2
    800039f4:	c6cff0ef          	jal	80002e60 <brelse>
    ip->valid = 1;
    800039f8:	4785                	li	a5,1
    800039fa:	c0bc                	sw	a5,64(s1)
    inode_report("ILOCK_LOAD", ip,
    800039fc:	00006897          	auipc	a7,0x6
    80003a00:	be488893          	addi	a7,a7,-1052 # 800095e0 <etext+0x5e0>
    80003a04:	4805                	li	a6,1
    80003a06:	44fc                	lw	a5,76(s1)
    80003a08:	04449703          	lh	a4,68(s1)
    80003a0c:	4681                	li	a3,0
    80003a0e:	4490                	lw	a2,8(s1)
    80003a10:	85a6                	mv	a1,s1
    80003a12:	00006517          	auipc	a0,0x6
    80003a16:	be650513          	addi	a0,a0,-1050 # 800095f8 <etext+0x5f8>
    80003a1a:	9bdff0ef          	jal	800033d6 <inode_report>
    if(ip->type == 0)
    80003a1e:	04449783          	lh	a5,68(s1)
    80003a22:	f3ad                	bnez	a5,80003984 <ilock+0x46>
      panic("ilock: no type");
    80003a24:	00006517          	auipc	a0,0x6
    80003a28:	be450513          	addi	a0,a0,-1052 # 80009608 <etext+0x608>
    80003a2c:	de7fc0ef          	jal	80000812 <panic>

0000000080003a30 <iunlock>:
{
    80003a30:	1101                	addi	sp,sp,-32
    80003a32:	ec06                	sd	ra,24(sp)
    80003a34:	e822                	sd	s0,16(sp)
    80003a36:	e426                	sd	s1,8(sp)
    80003a38:	e04a                	sd	s2,0(sp)
    80003a3a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a3c:	c529                	beqz	a0,80003a86 <iunlock+0x56>
    80003a3e:	84aa                	mv	s1,a0
    80003a40:	01050913          	addi	s2,a0,16
    80003a44:	854a                	mv	a0,s2
    80003a46:	2d6010ef          	jal	80004d1c <holdingsleep>
    80003a4a:	cd15                	beqz	a0,80003a86 <iunlock+0x56>
    80003a4c:	449c                	lw	a5,8(s1)
    80003a4e:	02f05c63          	blez	a5,80003a86 <iunlock+0x56>
  releasesleep(&ip->lock);
    80003a52:	854a                	mv	a0,s2
    80003a54:	290010ef          	jal	80004ce4 <releasesleep>
  inode_report("IUNLOCK", ip,
    80003a58:	00006897          	auipc	a7,0x6
    80003a5c:	bc888893          	addi	a7,a7,-1080 # 80009620 <etext+0x620>
    80003a60:	4805                	li	a6,1
    80003a62:	44fc                	lw	a5,76(s1)
    80003a64:	04449703          	lh	a4,68(s1)
    80003a68:	40b4                	lw	a3,64(s1)
    80003a6a:	4490                	lw	a2,8(s1)
    80003a6c:	85a6                	mv	a1,s1
    80003a6e:	00006517          	auipc	a0,0x6
    80003a72:	bc250513          	addi	a0,a0,-1086 # 80009630 <etext+0x630>
    80003a76:	961ff0ef          	jal	800033d6 <inode_report>
}
    80003a7a:	60e2                	ld	ra,24(sp)
    80003a7c:	6442                	ld	s0,16(sp)
    80003a7e:	64a2                	ld	s1,8(sp)
    80003a80:	6902                	ld	s2,0(sp)
    80003a82:	6105                	addi	sp,sp,32
    80003a84:	8082                	ret
    panic("iunlock");
    80003a86:	00006517          	auipc	a0,0x6
    80003a8a:	b9250513          	addi	a0,a0,-1134 # 80009618 <etext+0x618>
    80003a8e:	d85fc0ef          	jal	80000812 <panic>

0000000080003a92 <itrunc>:

// Truncate inode (discard contents).
void
itrunc(struct inode *ip)
{
    80003a92:	7179                	addi	sp,sp,-48
    80003a94:	f406                	sd	ra,40(sp)
    80003a96:	f022                	sd	s0,32(sp)
    80003a98:	ec26                	sd	s1,24(sp)
    80003a9a:	e84a                	sd	s2,16(sp)
    80003a9c:	e44e                	sd	s3,8(sp)
    80003a9e:	1800                	addi	s0,sp,48
    80003aa0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003aa2:	05050493          	addi	s1,a0,80
    80003aa6:	08050913          	addi	s2,a0,128
    80003aaa:	a021                	j	80003ab2 <itrunc+0x20>
    80003aac:	0491                	addi	s1,s1,4
    80003aae:	01248b63          	beq	s1,s2,80003ac4 <itrunc+0x32>
    if(ip->addrs[i]){
    80003ab2:	408c                	lw	a1,0(s1)
    80003ab4:	dde5                	beqz	a1,80003aac <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003ab6:	0009a503          	lw	a0,0(s3)
    80003aba:	f58ff0ef          	jal	80003212 <bfree>
      ip->addrs[i] = 0;
    80003abe:	0004a023          	sw	zero,0(s1)
    80003ac2:	b7ed                	j	80003aac <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ac4:	0809a583          	lw	a1,128(s3)
    80003ac8:	e1a9                	bnez	a1,80003b0a <itrunc+0x78>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  int old_size = ip->size;
    80003aca:	04c9a783          	lw	a5,76(s3)

ip->size = 0;
    80003ace:	0409a623          	sw	zero,76(s3)

inode_report("ITRUNC", ip,
    80003ad2:	00006897          	auipc	a7,0x6
    80003ad6:	b6688893          	addi	a7,a7,-1178 # 80009638 <etext+0x638>
    80003ada:	4805                	li	a6,1
    80003adc:	04499703          	lh	a4,68(s3)
    80003ae0:	0409a683          	lw	a3,64(s3)
    80003ae4:	0089a603          	lw	a2,8(s3)
    80003ae8:	85ce                	mv	a1,s3
    80003aea:	00006517          	auipc	a0,0x6
    80003aee:	b6650513          	addi	a0,a0,-1178 # 80009650 <etext+0x650>
    80003af2:	8e5ff0ef          	jal	800033d6 <inode_report>
    ip->ref, ip->valid,
    ip->type, old_size,
    1,
    "Truncating inode data");
  iupdate(ip);
    80003af6:	854e                	mv	a0,s3
    80003af8:	d4fff0ef          	jal	80003846 <iupdate>
}
    80003afc:	70a2                	ld	ra,40(sp)
    80003afe:	7402                	ld	s0,32(sp)
    80003b00:	64e2                	ld	s1,24(sp)
    80003b02:	6942                	ld	s2,16(sp)
    80003b04:	69a2                	ld	s3,8(sp)
    80003b06:	6145                	addi	sp,sp,48
    80003b08:	8082                	ret
    80003b0a:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b0c:	0009a503          	lw	a0,0(s3)
    80003b10:	886ff0ef          	jal	80002b96 <bread>
    80003b14:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b16:	05850493          	addi	s1,a0,88
    80003b1a:	45850913          	addi	s2,a0,1112
    80003b1e:	a021                	j	80003b26 <itrunc+0x94>
    80003b20:	0491                	addi	s1,s1,4
    80003b22:	01248963          	beq	s1,s2,80003b34 <itrunc+0xa2>
      if(a[j])
    80003b26:	408c                	lw	a1,0(s1)
    80003b28:	dde5                	beqz	a1,80003b20 <itrunc+0x8e>
        bfree(ip->dev, a[j]);
    80003b2a:	0009a503          	lw	a0,0(s3)
    80003b2e:	ee4ff0ef          	jal	80003212 <bfree>
    80003b32:	b7fd                	j	80003b20 <itrunc+0x8e>
    brelse(bp);
    80003b34:	8552                	mv	a0,s4
    80003b36:	b2aff0ef          	jal	80002e60 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b3a:	0809a583          	lw	a1,128(s3)
    80003b3e:	0009a503          	lw	a0,0(s3)
    80003b42:	ed0ff0ef          	jal	80003212 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b46:	0809a023          	sw	zero,128(s3)
    80003b4a:	6a02                	ld	s4,0(sp)
    80003b4c:	bfbd                	j	80003aca <itrunc+0x38>

0000000080003b4e <iput>:
{
    80003b4e:	1101                	addi	sp,sp,-32
    80003b50:	ec06                	sd	ra,24(sp)
    80003b52:	e822                	sd	s0,16(sp)
    80003b54:	e426                	sd	s1,8(sp)
    80003b56:	1000                	addi	s0,sp,32
    80003b58:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b5a:	0001d517          	auipc	a0,0x1d
    80003b5e:	b7650513          	addi	a0,a0,-1162 # 800206d0 <itable>
    80003b62:	89efd0ef          	jal	80000c00 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b66:	4498                	lw	a4,8(s1)
    80003b68:	4785                	li	a5,1
    80003b6a:	04f70163          	beq	a4,a5,80003bac <iput+0x5e>
  int old_ref = ip->ref;
    80003b6e:	4490                	lw	a2,8(s1)
ip->ref--;
    80003b70:	fff6079b          	addiw	a5,a2,-1
    80003b74:	c49c                	sw	a5,8(s1)
inode_report("IPUT", ip,
    80003b76:	00006897          	auipc	a7,0x6
    80003b7a:	b0a88893          	addi	a7,a7,-1270 # 80009680 <etext+0x680>
    80003b7e:	4801                	li	a6,0
    80003b80:	44fc                	lw	a5,76(s1)
    80003b82:	04449703          	lh	a4,68(s1)
    80003b86:	40b4                	lw	a3,64(s1)
    80003b88:	85a6                	mv	a1,s1
    80003b8a:	00006517          	auipc	a0,0x6
    80003b8e:	b0650513          	addi	a0,a0,-1274 # 80009690 <etext+0x690>
    80003b92:	845ff0ef          	jal	800033d6 <inode_report>
  release(&itable.lock);
    80003b96:	0001d517          	auipc	a0,0x1d
    80003b9a:	b3a50513          	addi	a0,a0,-1222 # 800206d0 <itable>
    80003b9e:	8fafd0ef          	jal	80000c98 <release>
}
    80003ba2:	60e2                	ld	ra,24(sp)
    80003ba4:	6442                	ld	s0,16(sp)
    80003ba6:	64a2                	ld	s1,8(sp)
    80003ba8:	6105                	addi	sp,sp,32
    80003baa:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bac:	40bc                	lw	a5,64(s1)
    80003bae:	d3e1                	beqz	a5,80003b6e <iput+0x20>
    80003bb0:	04a49783          	lh	a5,74(s1)
    80003bb4:	ffcd                	bnez	a5,80003b6e <iput+0x20>
    80003bb6:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003bb8:	01048913          	addi	s2,s1,16
    80003bbc:	854a                	mv	a0,s2
    80003bbe:	0e0010ef          	jal	80004c9e <acquiresleep>
    release(&itable.lock);
    80003bc2:	0001d517          	auipc	a0,0x1d
    80003bc6:	b0e50513          	addi	a0,a0,-1266 # 800206d0 <itable>
    80003bca:	8cefd0ef          	jal	80000c98 <release>
    itrunc(ip);
    80003bce:	8526                	mv	a0,s1
    80003bd0:	ec3ff0ef          	jal	80003a92 <itrunc>
    ip->type = 0;
    80003bd4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003bd8:	8526                	mv	a0,s1
    80003bda:	c6dff0ef          	jal	80003846 <iupdate>
    ip->valid = 0;
    80003bde:	0404a023          	sw	zero,64(s1)
    inode_report("IPUT_FREE", ip,
    80003be2:	00006897          	auipc	a7,0x6
    80003be6:	a7688893          	addi	a7,a7,-1418 # 80009658 <etext+0x658>
    80003bea:	4805                	li	a6,1
    80003bec:	44fc                	lw	a5,76(s1)
    80003bee:	04449703          	lh	a4,68(s1)
    80003bf2:	4681                	li	a3,0
    80003bf4:	4490                	lw	a2,8(s1)
    80003bf6:	85a6                	mv	a1,s1
    80003bf8:	00006517          	auipc	a0,0x6
    80003bfc:	a7850513          	addi	a0,a0,-1416 # 80009670 <etext+0x670>
    80003c00:	fd6ff0ef          	jal	800033d6 <inode_report>
    releasesleep(&ip->lock);
    80003c04:	854a                	mv	a0,s2
    80003c06:	0de010ef          	jal	80004ce4 <releasesleep>
    acquire(&itable.lock);
    80003c0a:	0001d517          	auipc	a0,0x1d
    80003c0e:	ac650513          	addi	a0,a0,-1338 # 800206d0 <itable>
    80003c12:	feffc0ef          	jal	80000c00 <acquire>
    80003c16:	6902                	ld	s2,0(sp)
    80003c18:	bf99                	j	80003b6e <iput+0x20>

0000000080003c1a <iunlockput>:
{
    80003c1a:	1101                	addi	sp,sp,-32
    80003c1c:	ec06                	sd	ra,24(sp)
    80003c1e:	e822                	sd	s0,16(sp)
    80003c20:	e426                	sd	s1,8(sp)
    80003c22:	1000                	addi	s0,sp,32
    80003c24:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c26:	e0bff0ef          	jal	80003a30 <iunlock>
  iput(ip);
    80003c2a:	8526                	mv	a0,s1
    80003c2c:	f23ff0ef          	jal	80003b4e <iput>
}
    80003c30:	60e2                	ld	ra,24(sp)
    80003c32:	6442                	ld	s0,16(sp)
    80003c34:	64a2                	ld	s1,8(sp)
    80003c36:	6105                	addi	sp,sp,32
    80003c38:	8082                	ret

0000000080003c3a <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003c3a:	0001d717          	auipc	a4,0x1d
    80003c3e:	a8272703          	lw	a4,-1406(a4) # 800206bc <sb+0xc>
    80003c42:	4785                	li	a5,1
    80003c44:	0ae7ff63          	bgeu	a5,a4,80003d02 <ireclaim+0xc8>
{
    80003c48:	7139                	addi	sp,sp,-64
    80003c4a:	fc06                	sd	ra,56(sp)
    80003c4c:	f822                	sd	s0,48(sp)
    80003c4e:	f426                	sd	s1,40(sp)
    80003c50:	f04a                	sd	s2,32(sp)
    80003c52:	ec4e                	sd	s3,24(sp)
    80003c54:	e852                	sd	s4,16(sp)
    80003c56:	e456                	sd	s5,8(sp)
    80003c58:	e05a                	sd	s6,0(sp)
    80003c5a:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003c5c:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003c5e:	00050a1b          	sext.w	s4,a0
    80003c62:	0001da97          	auipc	s5,0x1d
    80003c66:	a4ea8a93          	addi	s5,s5,-1458 # 800206b0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003c6a:	00006b17          	auipc	s6,0x6
    80003c6e:	a2eb0b13          	addi	s6,s6,-1490 # 80009698 <etext+0x698>
    80003c72:	a099                	j	80003cb8 <ireclaim+0x7e>
    80003c74:	85ce                	mv	a1,s3
    80003c76:	855a                	mv	a0,s6
    80003c78:	8b5fc0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    80003c7c:	85ce                	mv	a1,s3
    80003c7e:	8552                	mv	a0,s4
    80003c80:	857ff0ef          	jal	800034d6 <iget>
    80003c84:	89aa                	mv	s3,a0
    brelse(bp);
    80003c86:	854a                	mv	a0,s2
    80003c88:	9d8ff0ef          	jal	80002e60 <brelse>
    if (ip) {
    80003c8c:	00098f63          	beqz	s3,80003caa <ireclaim+0x70>
      begin_op();
    80003c90:	37d000ef          	jal	8000480c <begin_op>
      ilock(ip);
    80003c94:	854e                	mv	a0,s3
    80003c96:	ca9ff0ef          	jal	8000393e <ilock>
      iunlock(ip);
    80003c9a:	854e                	mv	a0,s3
    80003c9c:	d95ff0ef          	jal	80003a30 <iunlock>
      iput(ip);
    80003ca0:	854e                	mv	a0,s3
    80003ca2:	eadff0ef          	jal	80003b4e <iput>
      end_op();
    80003ca6:	485000ef          	jal	8000492a <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003caa:	0485                	addi	s1,s1,1
    80003cac:	00caa703          	lw	a4,12(s5)
    80003cb0:	0004879b          	sext.w	a5,s1
    80003cb4:	02e7fd63          	bgeu	a5,a4,80003cee <ireclaim+0xb4>
    80003cb8:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003cbc:	0044d593          	srli	a1,s1,0x4
    80003cc0:	018aa783          	lw	a5,24(s5)
    80003cc4:	9dbd                	addw	a1,a1,a5
    80003cc6:	8552                	mv	a0,s4
    80003cc8:	ecffe0ef          	jal	80002b96 <bread>
    80003ccc:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003cce:	05850793          	addi	a5,a0,88
    80003cd2:	00f9f713          	andi	a4,s3,15
    80003cd6:	071a                	slli	a4,a4,0x6
    80003cd8:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003cda:	00079703          	lh	a4,0(a5)
    80003cde:	c701                	beqz	a4,80003ce6 <ireclaim+0xac>
    80003ce0:	00679783          	lh	a5,6(a5)
    80003ce4:	dbc1                	beqz	a5,80003c74 <ireclaim+0x3a>
    brelse(bp);
    80003ce6:	854a                	mv	a0,s2
    80003ce8:	978ff0ef          	jal	80002e60 <brelse>
    if (ip) {
    80003cec:	bf7d                	j	80003caa <ireclaim+0x70>
}
    80003cee:	70e2                	ld	ra,56(sp)
    80003cf0:	7442                	ld	s0,48(sp)
    80003cf2:	74a2                	ld	s1,40(sp)
    80003cf4:	7902                	ld	s2,32(sp)
    80003cf6:	69e2                	ld	s3,24(sp)
    80003cf8:	6a42                	ld	s4,16(sp)
    80003cfa:	6aa2                	ld	s5,8(sp)
    80003cfc:	6b02                	ld	s6,0(sp)
    80003cfe:	6121                	addi	sp,sp,64
    80003d00:	8082                	ret
    80003d02:	8082                	ret

0000000080003d04 <fsinit>:
fsinit(int dev) {
    80003d04:	7179                	addi	sp,sp,-48
    80003d06:	f406                	sd	ra,40(sp)
    80003d08:	f022                	sd	s0,32(sp)
    80003d0a:	ec26                	sd	s1,24(sp)
    80003d0c:	e84a                	sd	s2,16(sp)
    80003d0e:	e44e                	sd	s3,8(sp)
    80003d10:	1800                	addi	s0,sp,48
    80003d12:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003d14:	4585                	li	a1,1
    80003d16:	e81fe0ef          	jal	80002b96 <bread>
    80003d1a:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003d1c:	0001d997          	auipc	s3,0x1d
    80003d20:	99498993          	addi	s3,s3,-1644 # 800206b0 <sb>
    80003d24:	02000613          	li	a2,32
    80003d28:	05850593          	addi	a1,a0,88
    80003d2c:	854e                	mv	a0,s3
    80003d2e:	802fd0ef          	jal	80000d30 <memmove>
  brelse(bp);
    80003d32:	854a                	mv	a0,s2
    80003d34:	92cff0ef          	jal	80002e60 <brelse>
  if(sb.magic != FSMAGIC)
    80003d38:	0009a703          	lw	a4,0(s3)
    80003d3c:	102037b7          	lui	a5,0x10203
    80003d40:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d44:	02f71363          	bne	a4,a5,80003d6a <fsinit+0x66>
  initlog(dev, &sb);
    80003d48:	0001d597          	auipc	a1,0x1d
    80003d4c:	96858593          	addi	a1,a1,-1688 # 800206b0 <sb>
    80003d50:	8526                	mv	a0,s1
    80003d52:	165000ef          	jal	800046b6 <initlog>
  ireclaim(dev);
    80003d56:	8526                	mv	a0,s1
    80003d58:	ee3ff0ef          	jal	80003c3a <ireclaim>
}
    80003d5c:	70a2                	ld	ra,40(sp)
    80003d5e:	7402                	ld	s0,32(sp)
    80003d60:	64e2                	ld	s1,24(sp)
    80003d62:	6942                	ld	s2,16(sp)
    80003d64:	69a2                	ld	s3,8(sp)
    80003d66:	6145                	addi	sp,sp,48
    80003d68:	8082                	ret
    panic("invalid file system");
    80003d6a:	00006517          	auipc	a0,0x6
    80003d6e:	94e50513          	addi	a0,a0,-1714 # 800096b8 <etext+0x6b8>
    80003d72:	aa1fc0ef          	jal	80000812 <panic>

0000000080003d76 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
    80003d76:	1141                	addi	sp,sp,-16
    80003d78:	e422                	sd	s0,8(sp)
    80003d7a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d7c:	411c                	lw	a5,0(a0)
    80003d7e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d80:	415c                	lw	a5,4(a0)
    80003d82:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d84:	04451783          	lh	a5,68(a0)
    80003d88:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d8c:	04a51783          	lh	a5,74(a0)
    80003d90:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d94:	04c56783          	lwu	a5,76(a0)
    80003d98:	e99c                	sd	a5,16(a1)
}
    80003d9a:	6422                	ld	s0,8(sp)
    80003d9c:	0141                	addi	sp,sp,16
    80003d9e:	8082                	ret

0000000080003da0 <readi>:

// Read data from inode.
int
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
    80003da0:	7119                	addi	sp,sp,-128
    80003da2:	fc86                	sd	ra,120(sp)
    80003da4:	f8a2                	sd	s0,112(sp)
    80003da6:	0100                	addi	s0,sp,128
    80003da8:	f8b43423          	sd	a1,-120(s0)
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003dac:	457c                	lw	a5,76(a0)
    80003dae:	10d7ea63          	bltu	a5,a3,80003ec2 <readi+0x122>
    80003db2:	f4a6                	sd	s1,104(sp)
    80003db4:	f0ca                	sd	s2,96(sp)
    80003db6:	e0da                	sd	s6,64(sp)
    80003db8:	fc5e                	sd	s7,56(sp)
    80003dba:	84aa                	mv	s1,a0
    80003dbc:	8b32                	mv	s6,a2
    80003dbe:	8936                	mv	s2,a3
    80003dc0:	8bba                	mv	s7,a4
    80003dc2:	9f35                	addw	a4,a4,a3
    return 0;
    80003dc4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003dc6:	10d76063          	bltu	a4,a3,80003ec6 <readi+0x126>
    80003dca:	e8d2                	sd	s4,80(sp)
  if(off + n > ip->size)
    80003dcc:	00e7f463          	bgeu	a5,a4,80003dd4 <readi+0x34>
    n = ip->size - off;
    80003dd0:	40d78bbb          	subw	s7,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dd4:	0c0b8463          	beqz	s7,80003e9c <readi+0xfc>
    80003dd8:	ecce                	sd	s3,88(sp)
    80003dda:	e4d6                	sd	s5,72(sp)
    80003ddc:	f862                	sd	s8,48(sp)
    80003dde:	f466                	sd	s9,40(sp)
    80003de0:	f06a                	sd	s10,32(sp)
    80003de2:	ec6e                	sd	s11,24(sp)
    80003de4:	4a01                	li	s4,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003de6:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003dea:	5cfd                	li	s9,-1
      brelse(bp);
      tot = -1;
      break;
    }
    inode_report("READI", ip,
    80003dec:	00006d97          	auipc	s11,0x6
    80003df0:	8e4d8d93          	addi	s11,s11,-1820 # 800096d0 <etext+0x6d0>
    80003df4:	a881                	j	80003e44 <readi+0xa4>
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003df6:	020a9c13          	slli	s8,s5,0x20
    80003dfa:	020c5c13          	srli	s8,s8,0x20
    80003dfe:	05898613          	addi	a2,s3,88
    80003e02:	86e2                	mv	a3,s8
    80003e04:	963a                	add	a2,a2,a4
    80003e06:	85da                	mv	a1,s6
    80003e08:	f8843503          	ld	a0,-120(s0)
    80003e0c:	c68fe0ef          	jal	80002274 <either_copyout>
    80003e10:	07950463          	beq	a0,s9,80003e78 <readi+0xd8>
    inode_report("READI", ip,
    80003e14:	88ee                	mv	a7,s11
    80003e16:	4805                	li	a6,1
    80003e18:	44fc                	lw	a5,76(s1)
    80003e1a:	04449703          	lh	a4,68(s1)
    80003e1e:	40b4                	lw	a3,64(s1)
    80003e20:	4490                	lw	a2,8(s1)
    80003e22:	85a6                	mv	a1,s1
    80003e24:	00006517          	auipc	a0,0x6
    80003e28:	8c450513          	addi	a0,a0,-1852 # 800096e8 <etext+0x6e8>
    80003e2c:	daaff0ef          	jal	800033d6 <inode_report>
    ip->ref, ip->valid,
    ip->type, ip->size,
    1,
    "Reading from inode");
    brelse(bp);
    80003e30:	854e                	mv	a0,s3
    80003e32:	82eff0ef          	jal	80002e60 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e36:	014a8a3b          	addw	s4,s5,s4
    80003e3a:	012a893b          	addw	s2,s5,s2
    80003e3e:	9b62                	add	s6,s6,s8
    80003e40:	057a7763          	bgeu	s4,s7,80003e8e <readi+0xee>
    uint addr = bmap(ip, off/BSIZE);
    80003e44:	00a9559b          	srliw	a1,s2,0xa
    80003e48:	8526                	mv	a0,s1
    80003e4a:	f7aff0ef          	jal	800035c4 <bmap>
    80003e4e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e52:	c5b9                	beqz	a1,80003ea0 <readi+0x100>
    bp = bread(ip->dev, addr);
    80003e54:	4088                	lw	a0,0(s1)
    80003e56:	d41fe0ef          	jal	80002b96 <bread>
    80003e5a:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e5c:	3ff97713          	andi	a4,s2,1023
    80003e60:	40ed07bb          	subw	a5,s10,a4
    80003e64:	414b86bb          	subw	a3,s7,s4
    80003e68:	8abe                	mv	s5,a5
    80003e6a:	2781                	sext.w	a5,a5
    80003e6c:	0006861b          	sext.w	a2,a3
    80003e70:	f8f673e3          	bgeu	a2,a5,80003df6 <readi+0x56>
    80003e74:	8ab6                	mv	s5,a3
    80003e76:	b741                	j	80003df6 <readi+0x56>
      brelse(bp);
    80003e78:	854e                	mv	a0,s3
    80003e7a:	fe7fe0ef          	jal	80002e60 <brelse>
      tot = -1;
    80003e7e:	5a7d                	li	s4,-1
      break;
    80003e80:	69e6                	ld	s3,88(sp)
    80003e82:	6aa6                	ld	s5,72(sp)
    80003e84:	7c42                	ld	s8,48(sp)
    80003e86:	7ca2                	ld	s9,40(sp)
    80003e88:	7d02                	ld	s10,32(sp)
    80003e8a:	6de2                	ld	s11,24(sp)
    80003e8c:	a005                	j	80003eac <readi+0x10c>
    80003e8e:	69e6                	ld	s3,88(sp)
    80003e90:	6aa6                	ld	s5,72(sp)
    80003e92:	7c42                	ld	s8,48(sp)
    80003e94:	7ca2                	ld	s9,40(sp)
    80003e96:	7d02                	ld	s10,32(sp)
    80003e98:	6de2                	ld	s11,24(sp)
    80003e9a:	a809                	j	80003eac <readi+0x10c>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e9c:	8a5e                	mv	s4,s7
    80003e9e:	a039                	j	80003eac <readi+0x10c>
    80003ea0:	69e6                	ld	s3,88(sp)
    80003ea2:	6aa6                	ld	s5,72(sp)
    80003ea4:	7c42                	ld	s8,48(sp)
    80003ea6:	7ca2                	ld	s9,40(sp)
    80003ea8:	7d02                	ld	s10,32(sp)
    80003eaa:	6de2                	ld	s11,24(sp)
  }
  return tot;
    80003eac:	000a051b          	sext.w	a0,s4
    80003eb0:	74a6                	ld	s1,104(sp)
    80003eb2:	7906                	ld	s2,96(sp)
    80003eb4:	6a46                	ld	s4,80(sp)
    80003eb6:	6b06                	ld	s6,64(sp)
    80003eb8:	7be2                	ld	s7,56(sp)
}
    80003eba:	70e6                	ld	ra,120(sp)
    80003ebc:	7446                	ld	s0,112(sp)
    80003ebe:	6109                	addi	sp,sp,128
    80003ec0:	8082                	ret
    return 0;
    80003ec2:	4501                	li	a0,0
    80003ec4:	bfdd                	j	80003eba <readi+0x11a>
    80003ec6:	74a6                	ld	s1,104(sp)
    80003ec8:	7906                	ld	s2,96(sp)
    80003eca:	6b06                	ld	s6,64(sp)
    80003ecc:	7be2                	ld	s7,56(sp)
    80003ece:	b7f5                	j	80003eba <readi+0x11a>

0000000080003ed0 <writei>:

// Write data to inode.
int
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
    80003ed0:	7119                	addi	sp,sp,-128
    80003ed2:	fc86                	sd	ra,120(sp)
    80003ed4:	f8a2                	sd	s0,112(sp)
    80003ed6:	f862                	sd	s8,48(sp)
    80003ed8:	0100                	addi	s0,sp,128
    80003eda:	8c3a                	mv	s8,a4
  uint tot, m;
  struct buf *bp;
  int old_size = ip->size;
    80003edc:	457c                	lw	a5,76(a0)
    80003ede:	0007871b          	sext.w	a4,a5
    80003ee2:	f8e43423          	sd	a4,-120(s0)
  if(off > ip->size || off + n < off)
    80003ee6:	10d7ee63          	bltu	a5,a3,80004002 <writei+0x132>
    80003eea:	f0ca                	sd	s2,96(sp)
    80003eec:	e4d6                	sd	s5,72(sp)
    80003eee:	e0da                	sd	s6,64(sp)
    80003ef0:	f466                	sd	s9,40(sp)
    80003ef2:	8b2a                	mv	s6,a0
    80003ef4:	8cae                	mv	s9,a1
    80003ef6:	8ab2                	mv	s5,a2
    80003ef8:	8936                	mv	s2,a3
    80003efa:	018687bb          	addw	a5,a3,s8
    80003efe:	10d7e463          	bltu	a5,a3,80004006 <writei+0x136>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f02:	00043737          	lui	a4,0x43
    80003f06:	10f76663          	bltu	a4,a5,80004012 <writei+0x142>
    80003f0a:	e8d2                	sd	s4,80(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f0c:	0e0c0363          	beqz	s8,80003ff2 <writei+0x122>
    80003f10:	f4a6                	sd	s1,104(sp)
    80003f12:	ecce                	sd	s3,88(sp)
    80003f14:	fc5e                	sd	s7,56(sp)
    80003f16:	f06a                	sd	s10,32(sp)
    80003f18:	ec6e                	sd	s11,24(sp)
    80003f1a:	4a01                	li	s4,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f1c:	40000d93          	li	s11,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f20:	5d7d                	li	s10,-1
    80003f22:	a825                	j	80003f5a <writei+0x8a>
    80003f24:	02099b93          	slli	s7,s3,0x20
    80003f28:	020bdb93          	srli	s7,s7,0x20
    80003f2c:	05848513          	addi	a0,s1,88
    80003f30:	86de                	mv	a3,s7
    80003f32:	8656                	mv	a2,s5
    80003f34:	85e6                	mv	a1,s9
    80003f36:	953a                	add	a0,a0,a4
    80003f38:	b86fe0ef          	jal	800022be <either_copyin>
    80003f3c:	05a50a63          	beq	a0,s10,80003f90 <writei+0xc0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f40:	8526                	mv	a0,s1
    80003f42:	43f000ef          	jal	80004b80 <log_write>
    brelse(bp);
    80003f46:	8526                	mv	a0,s1
    80003f48:	f19fe0ef          	jal	80002e60 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f4c:	01498a3b          	addw	s4,s3,s4
    80003f50:	0129893b          	addw	s2,s3,s2
    80003f54:	9ade                	add	s5,s5,s7
    80003f56:	058a7063          	bgeu	s4,s8,80003f96 <writei+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003f5a:	00a9559b          	srliw	a1,s2,0xa
    80003f5e:	855a                	mv	a0,s6
    80003f60:	e64ff0ef          	jal	800035c4 <bmap>
    80003f64:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f68:	c59d                	beqz	a1,80003f96 <writei+0xc6>
    bp = bread(ip->dev, addr);
    80003f6a:	000b2503          	lw	a0,0(s6)
    80003f6e:	c29fe0ef          	jal	80002b96 <bread>
    80003f72:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f74:	3ff97713          	andi	a4,s2,1023
    80003f78:	40ed87bb          	subw	a5,s11,a4
    80003f7c:	414c06bb          	subw	a3,s8,s4
    80003f80:	89be                	mv	s3,a5
    80003f82:	2781                	sext.w	a5,a5
    80003f84:	0006861b          	sext.w	a2,a3
    80003f88:	f8f67ee3          	bgeu	a2,a5,80003f24 <writei+0x54>
    80003f8c:	89b6                	mv	s3,a3
    80003f8e:	bf59                	j	80003f24 <writei+0x54>
      brelse(bp);
    80003f90:	8526                	mv	a0,s1
    80003f92:	ecffe0ef          	jal	80002e60 <brelse>
  }

  if(off > ip->size)
    80003f96:	04cb2783          	lw	a5,76(s6)
    80003f9a:	0527fe63          	bgeu	a5,s2,80003ff6 <writei+0x126>
    ip->size = off;
    80003f9e:	052b2623          	sw	s2,76(s6)
    80003fa2:	74a6                	ld	s1,104(sp)
    80003fa4:	69e6                	ld	s3,88(sp)
    80003fa6:	7be2                	ld	s7,56(sp)
    80003fa8:	7d02                	ld	s10,32(sp)
    80003faa:	6de2                	ld	s11,24(sp)
  inode_report("WRITEI", ip,
    80003fac:	00005897          	auipc	a7,0x5
    80003fb0:	74488893          	addi	a7,a7,1860 # 800096f0 <etext+0x6f0>
    80003fb4:	4805                	li	a6,1
    80003fb6:	f8843783          	ld	a5,-120(s0)
    80003fba:	044b1703          	lh	a4,68(s6)
    80003fbe:	040b2683          	lw	a3,64(s6)
    80003fc2:	008b2603          	lw	a2,8(s6)
    80003fc6:	85da                	mv	a1,s6
    80003fc8:	00005517          	auipc	a0,0x5
    80003fcc:	74050513          	addi	a0,a0,1856 # 80009708 <etext+0x708>
    80003fd0:	c06ff0ef          	jal	800033d6 <inode_report>
    ip->ref, ip->valid,
    ip->type, old_size,
    1,
    "Writing to inode");

  iupdate(ip);
    80003fd4:	855a                	mv	a0,s6
    80003fd6:	871ff0ef          	jal	80003846 <iupdate>

  return tot;
    80003fda:	000a051b          	sext.w	a0,s4
    80003fde:	7906                	ld	s2,96(sp)
    80003fe0:	6a46                	ld	s4,80(sp)
    80003fe2:	6aa6                	ld	s5,72(sp)
    80003fe4:	6b06                	ld	s6,64(sp)
    80003fe6:	7ca2                	ld	s9,40(sp)
}
    80003fe8:	70e6                	ld	ra,120(sp)
    80003fea:	7446                	ld	s0,112(sp)
    80003fec:	7c42                	ld	s8,48(sp)
    80003fee:	6109                	addi	sp,sp,128
    80003ff0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ff2:	8a62                	mv	s4,s8
    80003ff4:	bf65                	j	80003fac <writei+0xdc>
    80003ff6:	74a6                	ld	s1,104(sp)
    80003ff8:	69e6                	ld	s3,88(sp)
    80003ffa:	7be2                	ld	s7,56(sp)
    80003ffc:	7d02                	ld	s10,32(sp)
    80003ffe:	6de2                	ld	s11,24(sp)
    80004000:	b775                	j	80003fac <writei+0xdc>
    return -1;
    80004002:	557d                	li	a0,-1
    80004004:	b7d5                	j	80003fe8 <writei+0x118>
    80004006:	557d                	li	a0,-1
    80004008:	7906                	ld	s2,96(sp)
    8000400a:	6aa6                	ld	s5,72(sp)
    8000400c:	6b06                	ld	s6,64(sp)
    8000400e:	7ca2                	ld	s9,40(sp)
    80004010:	bfe1                	j	80003fe8 <writei+0x118>
    return -1;
    80004012:	557d                	li	a0,-1
    80004014:	7906                	ld	s2,96(sp)
    80004016:	6aa6                	ld	s5,72(sp)
    80004018:	6b06                	ld	s6,64(sp)
    8000401a:	7ca2                	ld	s9,40(sp)
    8000401c:	b7f1                	j	80003fe8 <writei+0x118>

000000008000401e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000401e:	1141                	addi	sp,sp,-16
    80004020:	e406                	sd	ra,8(sp)
    80004022:	e022                	sd	s0,0(sp)
    80004024:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004026:	4639                	li	a2,14
    80004028:	d79fc0ef          	jal	80000da0 <strncmp>
}
    8000402c:	60a2                	ld	ra,8(sp)
    8000402e:	6402                	ld	s0,0(sp)
    80004030:	0141                	addi	sp,sp,16
    80004032:	8082                	ret

0000000080004034 <dirlookup>:

// Look for a directory entry in a directory.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004034:	7139                	addi	sp,sp,-64
    80004036:	fc06                	sd	ra,56(sp)
    80004038:	f822                	sd	s0,48(sp)
    8000403a:	f426                	sd	s1,40(sp)
    8000403c:	f04a                	sd	s2,32(sp)
    8000403e:	ec4e                	sd	s3,24(sp)
    80004040:	e852                	sd	s4,16(sp)
    80004042:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004044:	04451703          	lh	a4,68(a0)
    80004048:	4785                	li	a5,1
    8000404a:	02f71f63          	bne	a4,a5,80004088 <dirlookup+0x54>
    8000404e:	892a                	mv	s2,a0
    80004050:	89ae                	mv	s3,a1
    80004052:	8a32                	mv	s4,a2
    name,
    -1,
    -1,
    "Starting directory lookup"
);}
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004054:	457c                	lw	a5,76(a0)
    80004056:	4481                	li	s1,0
    80004058:	eba9                	bnez	a5,800040aa <dirlookup+0x76>
    "Directory entry found"
);
      return iget(dp->dev, inum);
    }
  }
  dir_report(
    8000405a:	00005797          	auipc	a5,0x5
    8000405e:	70678793          	addi	a5,a5,1798 # 80009760 <etext+0x760>
    80004062:	577d                	li	a4,-1
    80004064:	56fd                	li	a3,-1
    80004066:	864e                	mv	a2,s3
    80004068:	85ca                	mv	a1,s2
    8000406a:	00005517          	auipc	a0,0x5
    8000406e:	71650513          	addi	a0,a0,1814 # 80009780 <etext+0x780>
    80004072:	f57fe0ef          	jal	80002fc8 <dir_report>
    name,
    -1,
    -1,
    "Directory entry not found"
);
  return 0;
    80004076:	4501                	li	a0,0
}
    80004078:	70e2                	ld	ra,56(sp)
    8000407a:	7442                	ld	s0,48(sp)
    8000407c:	74a2                	ld	s1,40(sp)
    8000407e:	7902                	ld	s2,32(sp)
    80004080:	69e2                	ld	s3,24(sp)
    80004082:	6a42                	ld	s4,16(sp)
    80004084:	6121                	addi	sp,sp,64
    80004086:	8082                	ret
   { panic("dirlookup not DIR");
    80004088:	00005517          	auipc	a0,0x5
    8000408c:	68850513          	addi	a0,a0,1672 # 80009710 <etext+0x710>
    80004090:	f82fc0ef          	jal	80000812 <panic>
      panic("dirlookup read");
    80004094:	00005517          	auipc	a0,0x5
    80004098:	69450513          	addi	a0,a0,1684 # 80009728 <etext+0x728>
    8000409c:	f76fc0ef          	jal	80000812 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040a0:	24c1                	addiw	s1,s1,16
    800040a2:	04c92783          	lw	a5,76(s2)
    800040a6:	faf4fae3          	bgeu	s1,a5,8000405a <dirlookup+0x26>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040aa:	4741                	li	a4,16
    800040ac:	86a6                	mv	a3,s1
    800040ae:	fc040613          	addi	a2,s0,-64
    800040b2:	4581                	li	a1,0
    800040b4:	854a                	mv	a0,s2
    800040b6:	cebff0ef          	jal	80003da0 <readi>
    800040ba:	47c1                	li	a5,16
    800040bc:	fcf51ce3          	bne	a0,a5,80004094 <dirlookup+0x60>
    if(de.inum == 0)
    800040c0:	fc045783          	lhu	a5,-64(s0)
    800040c4:	dff1                	beqz	a5,800040a0 <dirlookup+0x6c>
    if(namecmp(name, de.name) == 0){
    800040c6:	fc240593          	addi	a1,s0,-62
    800040ca:	854e                	mv	a0,s3
    800040cc:	f53ff0ef          	jal	8000401e <namecmp>
    800040d0:	f961                	bnez	a0,800040a0 <dirlookup+0x6c>
      if(poff)
    800040d2:	000a0463          	beqz	s4,800040da <dirlookup+0xa6>
        *poff = off;
    800040d6:	009a2023          	sw	s1,0(s4)
      inum = de.inum;
    800040da:	fc045a03          	lhu	s4,-64(s0)
      dir_report(
    800040de:	00005797          	auipc	a5,0x5
    800040e2:	65a78793          	addi	a5,a5,1626 # 80009738 <etext+0x738>
    800040e6:	8726                	mv	a4,s1
    800040e8:	86d2                	mv	a3,s4
    800040ea:	864e                	mv	a2,s3
    800040ec:	85ca                	mv	a1,s2
    800040ee:	00005517          	auipc	a0,0x5
    800040f2:	66250513          	addi	a0,a0,1634 # 80009750 <etext+0x750>
    800040f6:	ed3fe0ef          	jal	80002fc8 <dir_report>
      return iget(dp->dev, inum);
    800040fa:	85d2                	mv	a1,s4
    800040fc:	00092503          	lw	a0,0(s2)
    80004100:	bd6ff0ef          	jal	800034d6 <iget>
    80004104:	bf95                	j	80004078 <dirlookup+0x44>

0000000080004106 <namex>:
}

// Look up and return the inode for a path name.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004106:	7159                	addi	sp,sp,-112
    80004108:	f486                	sd	ra,104(sp)
    8000410a:	f0a2                	sd	s0,96(sp)
    8000410c:	eca6                	sd	s1,88(sp)
    8000410e:	e8ca                	sd	s2,80(sp)
    80004110:	e4ce                	sd	s3,72(sp)
    80004112:	e0d2                	sd	s4,64(sp)
    80004114:	fc56                	sd	s5,56(sp)
    80004116:	f85a                	sd	s6,48(sp)
    80004118:	f45e                	sd	s7,40(sp)
    8000411a:	f062                	sd	s8,32(sp)
    8000411c:	ec66                	sd	s9,24(sp)
    8000411e:	e86a                	sd	s10,16(sp)
    80004120:	e46e                	sd	s11,8(sp)
    80004122:	1880                	addi	s0,sp,112
    80004124:	84aa                	mv	s1,a0
    80004126:	8bae                	mv	s7,a1
    80004128:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000412a:	00054703          	lbu	a4,0(a0)
    8000412e:	02f00793          	li	a5,47
    80004132:	04f70663          	beq	a4,a5,8000417e <namex+0x78>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004136:	fd2fd0ef          	jal	80001908 <myproc>
    8000413a:	15053503          	ld	a0,336(a0)
    8000413e:	fa8ff0ef          	jal	800038e6 <idup>
    80004142:	8a2a                	mv	s4,a0
  path_report(
    80004144:	00005717          	auipc	a4,0x5
    80004148:	64c70713          	addi	a4,a4,1612 # 80009790 <etext+0x790>
    8000414c:	86d2                	mv	a3,s4
    8000414e:	00006617          	auipc	a2,0x6
    80004152:	9a260613          	addi	a2,a2,-1630 # 80009af0 <etext+0xaf0>
    80004156:	85a6                	mv	a1,s1
    80004158:	00005517          	auipc	a0,0x5
    8000415c:	65850513          	addi	a0,a0,1624 # 800097b0 <etext+0x7b0>
    80004160:	f37fe0ef          	jal	80003096 <path_report>
  while(*path == '/')
    80004164:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004168:	4db5                	li	s11,13
    "",
    ip,
    "Starting pathname resolution"
);
  while((path = skipelem(path, name)) != 0){
    path_report(
    8000416a:	00005d17          	auipc	s10,0x5
    8000416e:	656d0d13          	addi	s10,s10,1622 # 800097c0 <etext+0x7c0>
    80004172:	00005c97          	auipc	s9,0x5
    80004176:	666c8c93          	addi	s9,s9,1638 # 800097d8 <etext+0x7d8>
    name,
    ip,
    "Traversing pathname"
);
    ilock(ip);
    if(ip->type != T_DIR){
    8000417a:	4c05                	li	s8,1
  while((path = skipelem(path, name)) != 0){
    8000417c:	a07d                	j	8000422a <namex+0x124>
    ip = iget(ROOTDEV, ROOTINO);
    8000417e:	4585                	li	a1,1
    80004180:	4505                	li	a0,1
    80004182:	b54ff0ef          	jal	800034d6 <iget>
    80004186:	8a2a                	mv	s4,a0
    80004188:	bf75                	j	80004144 <namex+0x3e>
      iunlockput(ip);
    8000418a:	8552                	mv	a0,s4
    8000418c:	a8fff0ef          	jal	80003c1a <iunlockput>
      
      return 0;
    80004190:	4a01                	li	s4,0
    name,
    ip,
    "Path resolved successfully"
);
  return ip;
}
    80004192:	8552                	mv	a0,s4
    80004194:	70a6                	ld	ra,104(sp)
    80004196:	7406                	ld	s0,96(sp)
    80004198:	64e6                	ld	s1,88(sp)
    8000419a:	6946                	ld	s2,80(sp)
    8000419c:	69a6                	ld	s3,72(sp)
    8000419e:	6a06                	ld	s4,64(sp)
    800041a0:	7ae2                	ld	s5,56(sp)
    800041a2:	7b42                	ld	s6,48(sp)
    800041a4:	7ba2                	ld	s7,40(sp)
    800041a6:	7c02                	ld	s8,32(sp)
    800041a8:	6ce2                	ld	s9,24(sp)
    800041aa:	6d42                	ld	s10,16(sp)
    800041ac:	6da2                	ld	s11,8(sp)
    800041ae:	6165                	addi	sp,sp,112
    800041b0:	8082                	ret
      iunlock(ip);
    800041b2:	8552                	mv	a0,s4
    800041b4:	87dff0ef          	jal	80003a30 <iunlock>
      return ip;
    800041b8:	bfe9                	j	80004192 <namex+0x8c>
      iunlockput(ip);
    800041ba:	8552                	mv	a0,s4
    800041bc:	a5fff0ef          	jal	80003c1a <iunlockput>
      return 0;
    800041c0:	8a4e                	mv	s4,s3
    800041c2:	bfc1                	j	80004192 <namex+0x8c>
  len = path - s;
    800041c4:	40998633          	sub	a2,s3,s1
    800041c8:	00060b1b          	sext.w	s6,a2
  if(len >= DIRSIZ)
    800041cc:	096dd763          	bge	s11,s6,8000425a <namex+0x154>
    memmove(name, s, DIRSIZ);
    800041d0:	4639                	li	a2,14
    800041d2:	85a6                	mv	a1,s1
    800041d4:	8556                	mv	a0,s5
    800041d6:	b5bfc0ef          	jal	80000d30 <memmove>
    800041da:	84ce                	mv	s1,s3
  while(*path == '/')
    800041dc:	0004c783          	lbu	a5,0(s1)
    800041e0:	01279763          	bne	a5,s2,800041ee <namex+0xe8>
    path++;
    800041e4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041e6:	0004c783          	lbu	a5,0(s1)
    800041ea:	ff278de3          	beq	a5,s2,800041e4 <namex+0xde>
    path_report(
    800041ee:	876a                	mv	a4,s10
    800041f0:	86d2                	mv	a3,s4
    800041f2:	8656                	mv	a2,s5
    800041f4:	85a6                	mv	a1,s1
    800041f6:	8566                	mv	a0,s9
    800041f8:	e9ffe0ef          	jal	80003096 <path_report>
    ilock(ip);
    800041fc:	8552                	mv	a0,s4
    800041fe:	f40ff0ef          	jal	8000393e <ilock>
    if(ip->type != T_DIR){
    80004202:	044a1783          	lh	a5,68(s4)
    80004206:	f98792e3          	bne	a5,s8,8000418a <namex+0x84>
    if(nameiparent && *path == '\0'){
    8000420a:	000b8563          	beqz	s7,80004214 <namex+0x10e>
    8000420e:	0004c783          	lbu	a5,0(s1)
    80004212:	d3c5                	beqz	a5,800041b2 <namex+0xac>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004214:	4601                	li	a2,0
    80004216:	85d6                	mv	a1,s5
    80004218:	8552                	mv	a0,s4
    8000421a:	e1bff0ef          	jal	80004034 <dirlookup>
    8000421e:	89aa                	mv	s3,a0
    80004220:	dd49                	beqz	a0,800041ba <namex+0xb4>
    iunlockput(ip);
    80004222:	8552                	mv	a0,s4
    80004224:	9f7ff0ef          	jal	80003c1a <iunlockput>
    ip = next;
    80004228:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000422a:	0004c783          	lbu	a5,0(s1)
    8000422e:	01279763          	bne	a5,s2,8000423c <namex+0x136>
    path++;
    80004232:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004234:	0004c783          	lbu	a5,0(s1)
    80004238:	ff278de3          	beq	a5,s2,80004232 <namex+0x12c>
  if(*path == 0)
    8000423c:	c7b1                	beqz	a5,80004288 <namex+0x182>
  while(*path != '/' && *path != 0)
    8000423e:	0004c783          	lbu	a5,0(s1)
    80004242:	89a6                	mv	s3,s1
  len = path - s;
    80004244:	4b01                	li	s6,0
    80004246:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004248:	01278963          	beq	a5,s2,8000425a <namex+0x154>
    8000424c:	dfa5                	beqz	a5,800041c4 <namex+0xbe>
    path++;
    8000424e:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004250:	0009c783          	lbu	a5,0(s3)
    80004254:	ff279ce3          	bne	a5,s2,8000424c <namex+0x146>
    80004258:	b7b5                	j	800041c4 <namex+0xbe>
    memmove(name, s, len);
    8000425a:	2601                	sext.w	a2,a2
    8000425c:	85a6                	mv	a1,s1
    8000425e:	8556                	mv	a0,s5
    80004260:	ad1fc0ef          	jal	80000d30 <memmove>
    name[len] = 0;
    80004264:	9b56                	add	s6,s6,s5
    80004266:	000b0023          	sb	zero,0(s6)
    path_report(
    8000426a:	00005717          	auipc	a4,0x5
    8000426e:	57e70713          	addi	a4,a4,1406 # 800097e8 <etext+0x7e8>
    80004272:	4681                	li	a3,0
    80004274:	8656                	mv	a2,s5
    80004276:	85a6                	mv	a1,s1
    80004278:	00005517          	auipc	a0,0x5
    8000427c:	58850513          	addi	a0,a0,1416 # 80009800 <etext+0x800>
    80004280:	e17fe0ef          	jal	80003096 <path_report>
    80004284:	84ce                	mv	s1,s3
    80004286:	bf99                	j	800041dc <namex+0xd6>
  if(nameiparent){
    80004288:	020b9063          	bnez	s7,800042a8 <namex+0x1a2>
  path_report(
    8000428c:	00005717          	auipc	a4,0x5
    80004290:	5ac70713          	addi	a4,a4,1452 # 80009838 <etext+0x838>
    80004294:	86d2                	mv	a3,s4
    80004296:	8656                	mv	a2,s5
    80004298:	4581                	li	a1,0
    8000429a:	00005517          	auipc	a0,0x5
    8000429e:	5be50513          	addi	a0,a0,1470 # 80009858 <etext+0x858>
    800042a2:	df5fe0ef          	jal	80003096 <path_report>
  return ip;
    800042a6:	b5f5                	j	80004192 <namex+0x8c>
    iput(ip);
    800042a8:	8552                	mv	a0,s4
    800042aa:	8a5ff0ef          	jal	80003b4e <iput>
    path_report(
    800042ae:	00005717          	auipc	a4,0x5
    800042b2:	56270713          	addi	a4,a4,1378 # 80009810 <etext+0x810>
    800042b6:	86d2                	mv	a3,s4
    800042b8:	8656                	mv	a2,s5
    800042ba:	4581                	li	a1,0
    800042bc:	00005517          	auipc	a0,0x5
    800042c0:	56c50513          	addi	a0,a0,1388 # 80009828 <etext+0x828>
    800042c4:	dd3fe0ef          	jal	80003096 <path_report>
    return 0;
    800042c8:	4a01                	li	s4,0
    800042ca:	b5e1                	j	80004192 <namex+0x8c>

00000000800042cc <dirlink>:
{
    800042cc:	7139                	addi	sp,sp,-64
    800042ce:	fc06                	sd	ra,56(sp)
    800042d0:	f822                	sd	s0,48(sp)
    800042d2:	f04a                	sd	s2,32(sp)
    800042d4:	ec4e                	sd	s3,24(sp)
    800042d6:	e852                	sd	s4,16(sp)
    800042d8:	0080                	addi	s0,sp,64
    800042da:	892a                	mv	s2,a0
    800042dc:	89ae                	mv	s3,a1
    800042de:	8a32                	mv	s4,a2
  dir_report(
    800042e0:	00005797          	auipc	a5,0x5
    800042e4:	58878793          	addi	a5,a5,1416 # 80009868 <etext+0x868>
    800042e8:	577d                	li	a4,-1
    800042ea:	86b2                	mv	a3,a2
    800042ec:	862e                	mv	a2,a1
    800042ee:	85aa                	mv	a1,a0
    800042f0:	00005517          	auipc	a0,0x5
    800042f4:	59850513          	addi	a0,a0,1432 # 80009888 <etext+0x888>
    800042f8:	cd1fe0ef          	jal	80002fc8 <dir_report>
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042fc:	4601                	li	a2,0
    800042fe:	85ce                	mv	a1,s3
    80004300:	854a                	mv	a0,s2
    80004302:	d33ff0ef          	jal	80004034 <dirlookup>
    80004306:	e159                	bnez	a0,8000438c <dirlink+0xc0>
    80004308:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000430a:	04c92483          	lw	s1,76(s2)
    8000430e:	c48d                	beqz	s1,80004338 <dirlink+0x6c>
    80004310:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004312:	4741                	li	a4,16
    80004314:	86a6                	mv	a3,s1
    80004316:	fc040613          	addi	a2,s0,-64
    8000431a:	4581                	li	a1,0
    8000431c:	854a                	mv	a0,s2
    8000431e:	a83ff0ef          	jal	80003da0 <readi>
    80004322:	47c1                	li	a5,16
    80004324:	08f51663          	bne	a0,a5,800043b0 <dirlink+0xe4>
    if(de.inum == 0)
    80004328:	fc045783          	lhu	a5,-64(s0)
    8000432c:	c791                	beqz	a5,80004338 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000432e:	24c1                	addiw	s1,s1,16
    80004330:	04c92783          	lw	a5,76(s2)
    80004334:	fcf4efe3          	bltu	s1,a5,80004312 <dirlink+0x46>
  strncpy(de.name, name, DIRSIZ);
    80004338:	4639                	li	a2,14
    8000433a:	85ce                	mv	a1,s3
    8000433c:	fc240513          	addi	a0,s0,-62
    80004340:	a97fc0ef          	jal	80000dd6 <strncpy>
  de.inum = inum;
    80004344:	fd441023          	sh	s4,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004348:	4741                	li	a4,16
    8000434a:	86a6                	mv	a3,s1
    8000434c:	fc040613          	addi	a2,s0,-64
    80004350:	4581                	li	a1,0
    80004352:	854a                	mv	a0,s2
    80004354:	b7dff0ef          	jal	80003ed0 <writei>
    80004358:	47c1                	li	a5,16
    8000435a:	06f51163          	bne	a0,a5,800043bc <dirlink+0xf0>
  dir_report(
    8000435e:	00005797          	auipc	a5,0x5
    80004362:	57278793          	addi	a5,a5,1394 # 800098d0 <etext+0x8d0>
    80004366:	8726                	mv	a4,s1
    80004368:	86d2                	mv	a3,s4
    8000436a:	864e                	mv	a2,s3
    8000436c:	85ca                	mv	a1,s2
    8000436e:	00005517          	auipc	a0,0x5
    80004372:	57a50513          	addi	a0,a0,1402 # 800098e8 <etext+0x8e8>
    80004376:	c53fe0ef          	jal	80002fc8 <dir_report>
  return 0;
    8000437a:	4501                	li	a0,0
    8000437c:	74a2                	ld	s1,40(sp)
}
    8000437e:	70e2                	ld	ra,56(sp)
    80004380:	7442                	ld	s0,48(sp)
    80004382:	7902                	ld	s2,32(sp)
    80004384:	69e2                	ld	s3,24(sp)
    80004386:	6a42                	ld	s4,16(sp)
    80004388:	6121                	addi	sp,sp,64
    8000438a:	8082                	ret
    iput(ip);
    8000438c:	fc2ff0ef          	jal	80003b4e <iput>
    dir_report(
    80004390:	00005797          	auipc	a5,0x5
    80004394:	50878793          	addi	a5,a5,1288 # 80009898 <etext+0x898>
    80004398:	577d                	li	a4,-1
    8000439a:	86d2                	mv	a3,s4
    8000439c:	864e                	mv	a2,s3
    8000439e:	85ca                	mv	a1,s2
    800043a0:	00005517          	auipc	a0,0x5
    800043a4:	51050513          	addi	a0,a0,1296 # 800098b0 <etext+0x8b0>
    800043a8:	c21fe0ef          	jal	80002fc8 <dir_report>
    return -1;
    800043ac:	557d                	li	a0,-1
    800043ae:	bfc1                	j	8000437e <dirlink+0xb2>
      panic("dirlink read");
    800043b0:	00005517          	auipc	a0,0x5
    800043b4:	51050513          	addi	a0,a0,1296 # 800098c0 <etext+0x8c0>
    800043b8:	c5afc0ef          	jal	80000812 <panic>
    return -1;
    800043bc:	557d                	li	a0,-1
    800043be:	74a2                	ld	s1,40(sp)
    800043c0:	bf7d                	j	8000437e <dirlink+0xb2>

00000000800043c2 <namei>:

struct inode*
namei(char *path)
{
    800043c2:	1101                	addi	sp,sp,-32
    800043c4:	ec06                	sd	ra,24(sp)
    800043c6:	e822                	sd	s0,16(sp)
    800043c8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800043ca:	fe040613          	addi	a2,s0,-32
    800043ce:	4581                	li	a1,0
    800043d0:	d37ff0ef          	jal	80004106 <namex>
}
    800043d4:	60e2                	ld	ra,24(sp)
    800043d6:	6442                	ld	s0,16(sp)
    800043d8:	6105                	addi	sp,sp,32
    800043da:	8082                	ret

00000000800043dc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043dc:	1141                	addi	sp,sp,-16
    800043de:	e406                	sd	ra,8(sp)
    800043e0:	e022                	sd	s0,0(sp)
    800043e2:	0800                	addi	s0,sp,16
    800043e4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800043e6:	4585                	li	a1,1
    800043e8:	d1fff0ef          	jal	80004106 <namex>
}
    800043ec:	60a2                	ld	ra,8(sp)
    800043ee:	6402                	ld	s0,0(sp)
    800043f0:	0141                	addi	sp,sp,16
    800043f2:	8082                	ret

00000000800043f4 <log_get_state>:
  int committing;
};

static struct log_state
log_get_state(void)
{
    800043f4:	1101                	addi	sp,sp,-32
    800043f6:	ec22                	sd	s0,24(sp)
    800043f8:	1000                	addi	s0,sp,32
  struct log_state s;
  s.n = log.lh.n;
  s.out = log.outstanding;
    800043fa:	0001e697          	auipc	a3,0x1e
    800043fe:	d7e68693          	addi	a3,a3,-642 # 80022178 <log>
  s.committing = log.committing;
  return s;
    80004402:	0286e503          	lwu	a0,40(a3)
    80004406:	57fd                	li	a5,-1
    80004408:	9381                	srli	a5,a5,0x20
    8000440a:	01c6e703          	lwu	a4,28(a3)
    8000440e:	1702                	slli	a4,a4,0x20
    80004410:	8d7d                	and	a0,a0,a5
    80004412:	0206e583          	lwu	a1,32(a3)
}
    80004416:	8d59                	or	a0,a0,a4
    80004418:	8dfd                	and	a1,a1,a5
    8000441a:	6462                	ld	s0,24(sp)
    8000441c:	6105                	addi	sp,sp,32
    8000441e:	8082                	ret

0000000080004420 <log_report>:

//
// 🔥 report (نفس نمط bio.c)
//
void log_report(char *op, int bno, struct log_state old, char *desc)
{
    80004420:	db010113          	addi	sp,sp,-592
    80004424:	24113423          	sd	ra,584(sp)
    80004428:	24813023          	sd	s0,576(sp)
    8000442c:	22913c23          	sd	s1,568(sp)
    80004430:	23213823          	sd	s2,560(sp)
    80004434:	23313423          	sd	s3,552(sp)
    80004438:	0c80                	addi	s0,sp,592
    8000443a:	892a                	mv	s2,a0
    8000443c:	89ae                	mv	s3,a1
    8000443e:	dac43823          	sd	a2,-592(s0)
    80004442:	dad43c23          	sd	a3,-584(s0)
    80004446:	84ba                	mv	s1,a4
  struct fs_event e;
  memset(&e, 0, sizeof(e));
    80004448:	20000613          	li	a2,512
    8000444c:	4581                	li	a1,0
    8000444e:	dd040513          	addi	a0,s0,-560
    80004452:	883fc0ef          	jal	80000cd4 <memset>

  struct log_state now = log_get_state();
    80004456:	f9fff0ef          	jal	800043f4 <log_get_state>
    8000445a:	dca42023          	sw	a0,-576(s0)
    8000445e:	02055793          	srli	a5,a0,0x20
    80004462:	dcf42223          	sw	a5,-572(s0)
    80004466:	dcb42423          	sw	a1,-568(s0)

  e.ticks = ticks;
    8000446a:	00006797          	auipc	a5,0x6
    8000446e:	bde7a783          	lw	a5,-1058(a5) # 8000a048 <ticks>
    80004472:	dcf42c23          	sw	a5,-552(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    80004476:	c92fd0ef          	jal	80001908 <myproc>
    8000447a:	4781                	li	a5,0
    8000447c:	c501                	beqz	a0,80004484 <log_report+0x64>
    8000447e:	c8afd0ef          	jal	80001908 <myproc>
    80004482:	591c                	lw	a5,48(a0)
    80004484:	dcf42e23          	sw	a5,-548(s0)
  e.type = LAYER_LOG;
    80004488:	4789                	li	a5,2
    8000448a:	def42023          	sw	a5,-544(s0)
  e.blockno = bno;
    8000448e:	e9342a23          	sw	s3,-364(s0)

  // before
  e.old_log_n = old.n;
    80004492:	db042783          	lw	a5,-592(s0)
    80004496:	eef42223          	sw	a5,-284(s0)
  e.old_outstanding = old.out;
    8000449a:	db442783          	lw	a5,-588(s0)
    8000449e:	eef42423          	sw	a5,-280(s0)
  e.old_committing = old.committing;
    800044a2:	db842783          	lw	a5,-584(s0)
    800044a6:	eef42623          	sw	a5,-276(s0)

  // after
  e.log_n = now.n;
    800044aa:	dc042783          	lw	a5,-576(s0)
    800044ae:	eef42823          	sw	a5,-272(s0)
  e.outstanding = now.out;
    800044b2:	dc442783          	lw	a5,-572(s0)
    800044b6:	eef42a23          	sw	a5,-268(s0)
  e.committing = now.committing;
    800044ba:	dc842783          	lw	a5,-568(s0)
    800044be:	eef42c23          	sw	a5,-264(s0)

  safestrcpy(e.op_name, op, 16);
    800044c2:	4641                	li	a2,16
    800044c4:	85ca                	mv	a1,s2
    800044c6:	de440513          	addi	a0,s0,-540
    800044ca:	949fc0ef          	jal	80000e12 <safestrcpy>
  safestrcpy(e.details, desc, 128);
    800044ce:	08000613          	li	a2,128
    800044d2:	85a6                	mv	a1,s1
    800044d4:	df440513          	addi	a0,s0,-524
    800044d8:	93bfc0ef          	jal	80000e12 <safestrcpy>

  fslog_push(&e);
    800044dc:	dd040513          	addi	a0,s0,-560
    800044e0:	2b9020ef          	jal	80006f98 <fslog_push>
}
    800044e4:	24813083          	ld	ra,584(sp)
    800044e8:	24013403          	ld	s0,576(sp)
    800044ec:	23813483          	ld	s1,568(sp)
    800044f0:	23013903          	ld	s2,560(sp)
    800044f4:	22813983          	ld	s3,552(sp)
    800044f8:	25010113          	addi	sp,sp,592
    800044fc:	8082                	ret

00000000800044fe <install_trans>:
}

static void
install_trans(int recovering)
{
  for (int tail = 0; tail < log.lh.n; tail++) {
    800044fe:	0001e797          	auipc	a5,0x1e
    80004502:	ca27a783          	lw	a5,-862(a5) # 800221a0 <log+0x28>
    80004506:	12f05063          	blez	a5,80004626 <install_trans+0x128>
{
    8000450a:	7159                	addi	sp,sp,-112
    8000450c:	f486                	sd	ra,104(sp)
    8000450e:	f0a2                	sd	s0,96(sp)
    80004510:	eca6                	sd	s1,88(sp)
    80004512:	e8ca                	sd	s2,80(sp)
    80004514:	e4ce                	sd	s3,72(sp)
    80004516:	e0d2                	sd	s4,64(sp)
    80004518:	fc56                	sd	s5,56(sp)
    8000451a:	f85a                	sd	s6,48(sp)
    8000451c:	f45e                	sd	s7,40(sp)
    8000451e:	f062                	sd	s8,32(sp)
    80004520:	ec66                	sd	s9,24(sp)
    80004522:	e86a                	sd	s10,16(sp)
    80004524:	1880                	addi	s0,sp,112
    80004526:	8b2a                	mv	s6,a0
    80004528:	0001ea97          	auipc	s5,0x1e
    8000452c:	c7ca8a93          	addi	s5,s5,-900 # 800221a4 <log+0x2c>
  for (int tail = 0; tail < log.lh.n; tail++) {
    80004530:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1);
    80004532:	0001e997          	auipc	s3,0x1e
    80004536:	c4698993          	addi	s3,s3,-954 # 80022178 <log>
    struct log_state old = log_get_state();

    if (recovering)
      log_report("RECOVER_BLK", log.lh.block[tail], old, "Recover block");
    else
      log_report("INSTALL_BLK", log.lh.block[tail], old, "Install block");
    8000453a:	00005d17          	auipc	s10,0x5
    8000453e:	3ded0d13          	addi	s10,s10,990 # 80009918 <etext+0x918>
    80004542:	00005c97          	auipc	s9,0x5
    80004546:	3e6c8c93          	addi	s9,s9,998 # 80009928 <etext+0x928>
      log_report("RECOVER_BLK", log.lh.block[tail], old, "Recover block");
    8000454a:	00005c17          	auipc	s8,0x5
    8000454e:	3aec0c13          	addi	s8,s8,942 # 800098f8 <etext+0x8f8>
    80004552:	00005b97          	auipc	s7,0x5
    80004556:	3b6b8b93          	addi	s7,s7,950 # 80009908 <etext+0x908>
    8000455a:	a0a9                	j	800045a4 <install_trans+0xa6>
      log_report("INSTALL_BLK", log.lh.block[tail], old, "Install block");
    8000455c:	876a                	mv	a4,s10
    8000455e:	f9043603          	ld	a2,-112(s0)
    80004562:	f9843683          	ld	a3,-104(s0)
    80004566:	000aa583          	lw	a1,0(s5)
    8000456a:	8566                	mv	a0,s9
    8000456c:	eb5ff0ef          	jal	80004420 <log_report>

    memmove(dbuf->data, lbuf->data, BSIZE);
    80004570:	40000613          	li	a2,1024
    80004574:	05890593          	addi	a1,s2,88
    80004578:	05848513          	addi	a0,s1,88
    8000457c:	fb4fc0ef          	jal	80000d30 <memmove>
    bwrite(dbuf);
    80004580:	8526                	mv	a0,s1
    80004582:	865fe0ef          	jal	80002de6 <bwrite>

    if (!recovering)
      bunpin(dbuf);
    80004586:	8526                	mv	a0,s1
    80004588:	a0dfe0ef          	jal	80002f94 <bunpin>

    brelse(lbuf);
    8000458c:	854a                	mv	a0,s2
    8000458e:	8d3fe0ef          	jal	80002e60 <brelse>
    brelse(dbuf);
    80004592:	8526                	mv	a0,s1
    80004594:	8cdfe0ef          	jal	80002e60 <brelse>
  for (int tail = 0; tail < log.lh.n; tail++) {
    80004598:	2a05                	addiw	s4,s4,1
    8000459a:	0a91                	addi	s5,s5,4
    8000459c:	0289a783          	lw	a5,40(s3)
    800045a0:	06fa5563          	bge	s4,a5,8000460a <install_trans+0x10c>
    struct buf *lbuf = bread(log.dev, log.start+tail+1);
    800045a4:	0189a583          	lw	a1,24(s3)
    800045a8:	014585bb          	addw	a1,a1,s4
    800045ac:	2585                	addiw	a1,a1,1
    800045ae:	0249a503          	lw	a0,36(s3)
    800045b2:	de4fe0ef          	jal	80002b96 <bread>
    800045b6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);
    800045b8:	000aa583          	lw	a1,0(s5)
    800045bc:	0249a503          	lw	a0,36(s3)
    800045c0:	dd6fe0ef          	jal	80002b96 <bread>
    800045c4:	84aa                	mv	s1,a0
    struct log_state old = log_get_state();
    800045c6:	e2fff0ef          	jal	800043f4 <log_get_state>
    800045ca:	f8a42823          	sw	a0,-112(s0)
    800045ce:	02055793          	srli	a5,a0,0x20
    800045d2:	f8f42a23          	sw	a5,-108(s0)
    800045d6:	f8b42c23          	sw	a1,-104(s0)
    if (recovering)
    800045da:	f80b01e3          	beqz	s6,8000455c <install_trans+0x5e>
      log_report("RECOVER_BLK", log.lh.block[tail], old, "Recover block");
    800045de:	8762                	mv	a4,s8
    800045e0:	f9043603          	ld	a2,-112(s0)
    800045e4:	f9843683          	ld	a3,-104(s0)
    800045e8:	000aa583          	lw	a1,0(s5)
    800045ec:	855e                	mv	a0,s7
    800045ee:	e33ff0ef          	jal	80004420 <log_report>
    memmove(dbuf->data, lbuf->data, BSIZE);
    800045f2:	40000613          	li	a2,1024
    800045f6:	05890593          	addi	a1,s2,88
    800045fa:	05848513          	addi	a0,s1,88
    800045fe:	f32fc0ef          	jal	80000d30 <memmove>
    bwrite(dbuf);
    80004602:	8526                	mv	a0,s1
    80004604:	fe2fe0ef          	jal	80002de6 <bwrite>
    if (!recovering)
    80004608:	b751                	j	8000458c <install_trans+0x8e>
  }
}
    8000460a:	70a6                	ld	ra,104(sp)
    8000460c:	7406                	ld	s0,96(sp)
    8000460e:	64e6                	ld	s1,88(sp)
    80004610:	6946                	ld	s2,80(sp)
    80004612:	69a6                	ld	s3,72(sp)
    80004614:	6a06                	ld	s4,64(sp)
    80004616:	7ae2                	ld	s5,56(sp)
    80004618:	7b42                	ld	s6,48(sp)
    8000461a:	7ba2                	ld	s7,40(sp)
    8000461c:	7c02                	ld	s8,32(sp)
    8000461e:	6ce2                	ld	s9,24(sp)
    80004620:	6d42                	ld	s10,16(sp)
    80004622:	6165                	addi	sp,sp,112
    80004624:	8082                	ret
    80004626:	8082                	ret

0000000080004628 <write_head>:
{
    80004628:	7179                	addi	sp,sp,-48
    8000462a:	f406                	sd	ra,40(sp)
    8000462c:	f022                	sd	s0,32(sp)
    8000462e:	ec26                	sd	s1,24(sp)
    80004630:	e84a                	sd	s2,16(sp)
    80004632:	1800                	addi	s0,sp,48
  struct buf *buf = bread(log.dev, log.start);
    80004634:	0001e917          	auipc	s2,0x1e
    80004638:	b4490913          	addi	s2,s2,-1212 # 80022178 <log>
    8000463c:	01892583          	lw	a1,24(s2)
    80004640:	02492503          	lw	a0,36(s2)
    80004644:	d52fe0ef          	jal	80002b96 <bread>
    80004648:	84aa                	mv	s1,a0
  struct log_state old = log_get_state();
    8000464a:	dabff0ef          	jal	800043f4 <log_get_state>
    8000464e:	fca42823          	sw	a0,-48(s0)
    80004652:	9101                	srli	a0,a0,0x20
    80004654:	fca42a23          	sw	a0,-44(s0)
    80004658:	fcb42c23          	sw	a1,-40(s0)
  hb->n = log.lh.n;
    8000465c:	02892603          	lw	a2,40(s2)
    80004660:	ccb0                	sw	a2,88(s1)
  for (int i = 0; i < log.lh.n; i++)
    80004662:	00c05f63          	blez	a2,80004680 <write_head+0x58>
    80004666:	0001e717          	auipc	a4,0x1e
    8000466a:	b3e70713          	addi	a4,a4,-1218 # 800221a4 <log+0x2c>
    8000466e:	87a6                	mv	a5,s1
    80004670:	060a                	slli	a2,a2,0x2
    80004672:	9626                	add	a2,a2,s1
    hb->block[i] = log.lh.block[i];
    80004674:	4314                	lw	a3,0(a4)
    80004676:	cff4                	sw	a3,92(a5)
  for (int i = 0; i < log.lh.n; i++)
    80004678:	0711                	addi	a4,a4,4
    8000467a:	0791                	addi	a5,a5,4
    8000467c:	fec79ce3          	bne	a5,a2,80004674 <write_head+0x4c>
  bwrite(buf);
    80004680:	8526                	mv	a0,s1
    80004682:	f64fe0ef          	jal	80002de6 <bwrite>
  log_report("WRITE_HEAD", 0, old, "Write log header to disk");
    80004686:	00005717          	auipc	a4,0x5
    8000468a:	2b270713          	addi	a4,a4,690 # 80009938 <etext+0x938>
    8000468e:	fd043603          	ld	a2,-48(s0)
    80004692:	fd843683          	ld	a3,-40(s0)
    80004696:	4581                	li	a1,0
    80004698:	00005517          	auipc	a0,0x5
    8000469c:	2c050513          	addi	a0,a0,704 # 80009958 <etext+0x958>
    800046a0:	d81ff0ef          	jal	80004420 <log_report>
  brelse(buf);
    800046a4:	8526                	mv	a0,s1
    800046a6:	fbafe0ef          	jal	80002e60 <brelse>
}
    800046aa:	70a2                	ld	ra,40(sp)
    800046ac:	7402                	ld	s0,32(sp)
    800046ae:	64e2                	ld	s1,24(sp)
    800046b0:	6942                	ld	s2,16(sp)
    800046b2:	6145                	addi	sp,sp,48
    800046b4:	8082                	ret

00000000800046b6 <initlog>:
{
    800046b6:	715d                	addi	sp,sp,-80
    800046b8:	e486                	sd	ra,72(sp)
    800046ba:	e0a2                	sd	s0,64(sp)
    800046bc:	fc26                	sd	s1,56(sp)
    800046be:	f84a                	sd	s2,48(sp)
    800046c0:	f44e                	sd	s3,40(sp)
    800046c2:	0880                	addi	s0,sp,80
    800046c4:	892a                	mv	s2,a0
    800046c6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800046c8:	0001e497          	auipc	s1,0x1e
    800046cc:	ab048493          	addi	s1,s1,-1360 # 80022178 <log>
    800046d0:	00005597          	auipc	a1,0x5
    800046d4:	29858593          	addi	a1,a1,664 # 80009968 <etext+0x968>
    800046d8:	8526                	mv	a0,s1
    800046da:	ca6fc0ef          	jal	80000b80 <initlock>
  log.start = sb->logstart;
    800046de:	0149a783          	lw	a5,20(s3)
    800046e2:	cc9c                	sw	a5,24(s1)
  log.dev = dev;
    800046e4:	0324a223          	sw	s2,36(s1)
  struct log_state old = log_get_state();
    800046e8:	d0dff0ef          	jal	800043f4 <log_get_state>
    800046ec:	fca42023          	sw	a0,-64(s0)
    800046f0:	9101                	srli	a0,a0,0x20
    800046f2:	fca42223          	sw	a0,-60(s0)
    800046f6:	fcb42423          	sw	a1,-56(s0)
  log_report("INIT_LOG", 0, old, "Initialize log system");
    800046fa:	00005717          	auipc	a4,0x5
    800046fe:	27670713          	addi	a4,a4,630 # 80009970 <etext+0x970>
    80004702:	fc043603          	ld	a2,-64(s0)
    80004706:	fc843683          	ld	a3,-56(s0)
    8000470a:	4581                	li	a1,0
    8000470c:	00005517          	auipc	a0,0x5
    80004710:	27c50513          	addi	a0,a0,636 # 80009988 <etext+0x988>
    80004714:	d0dff0ef          	jal	80004420 <log_report>
  struct buf *buf = bread(log.dev, log.start);
    80004718:	4c8c                	lw	a1,24(s1)
    8000471a:	50c8                	lw	a0,36(s1)
    8000471c:	c7afe0ef          	jal	80002b96 <bread>
    80004720:	892a                	mv	s2,a0
  struct log_state old = log_get_state();
    80004722:	cd3ff0ef          	jal	800043f4 <log_get_state>
    80004726:	faa42823          	sw	a0,-80(s0)
    8000472a:	02055793          	srli	a5,a0,0x20
    8000472e:	faf42a23          	sw	a5,-76(s0)
    80004732:	fab42c23          	sw	a1,-72(s0)
  log.lh.n = lh->n;
    80004736:	05892603          	lw	a2,88(s2)
    8000473a:	d490                	sw	a2,40(s1)
  for (int i = 0; i < log.lh.n; i++)
    8000473c:	00c05f63          	blez	a2,8000475a <initlog+0xa4>
    80004740:	87ca                	mv	a5,s2
    80004742:	0001e717          	auipc	a4,0x1e
    80004746:	a6270713          	addi	a4,a4,-1438 # 800221a4 <log+0x2c>
    8000474a:	060a                	slli	a2,a2,0x2
    8000474c:	964a                	add	a2,a2,s2
    log.lh.block[i] = lh->block[i];
    8000474e:	4ff4                	lw	a3,92(a5)
    80004750:	c314                	sw	a3,0(a4)
  for (int i = 0; i < log.lh.n; i++)
    80004752:	0791                	addi	a5,a5,4
    80004754:	0711                	addi	a4,a4,4
    80004756:	fec79ce3          	bne	a5,a2,8000474e <initlog+0x98>
  log_report("READ_HEAD", 0, old, "Read log header from disk");
    8000475a:	00005717          	auipc	a4,0x5
    8000475e:	23e70713          	addi	a4,a4,574 # 80009998 <etext+0x998>
    80004762:	fb043603          	ld	a2,-80(s0)
    80004766:	fb843683          	ld	a3,-72(s0)
    8000476a:	4581                	li	a1,0
    8000476c:	00005517          	auipc	a0,0x5
    80004770:	24c50513          	addi	a0,a0,588 # 800099b8 <etext+0x9b8>
    80004774:	cadff0ef          	jal	80004420 <log_report>
  brelse(buf);
    80004778:	854a                	mv	a0,s2
    8000477a:	ee6fe0ef          	jal	80002e60 <brelse>
static void
recover_from_log(void)
{
  read_head();

  if (log.lh.n > 0) {
    8000477e:	0001e797          	auipc	a5,0x1e
    80004782:	a227a783          	lw	a5,-1502(a5) # 800221a0 <log+0x28>
    80004786:	00f04963          	bgtz	a5,80004798 <initlog+0xe2>
}
    8000478a:	60a6                	ld	ra,72(sp)
    8000478c:	6406                	ld	s0,64(sp)
    8000478e:	74e2                	ld	s1,56(sp)
    80004790:	7942                	ld	s2,48(sp)
    80004792:	79a2                	ld	s3,40(sp)
    80004794:	6161                	addi	sp,sp,80
    80004796:	8082                	ret
    struct log_state old = log_get_state();
    80004798:	c5dff0ef          	jal	800043f4 <log_get_state>
    8000479c:	faa42823          	sw	a0,-80(s0)
    800047a0:	9101                	srli	a0,a0,0x20
    800047a2:	faa42a23          	sw	a0,-76(s0)
    800047a6:	fab42c23          	sw	a1,-72(s0)

    log_report("RECOVER_START", 0, old, "Start recovery");
    800047aa:	00005717          	auipc	a4,0x5
    800047ae:	21e70713          	addi	a4,a4,542 # 800099c8 <etext+0x9c8>
    800047b2:	fb043603          	ld	a2,-80(s0)
    800047b6:	fb843683          	ld	a3,-72(s0)
    800047ba:	4581                	li	a1,0
    800047bc:	00005517          	auipc	a0,0x5
    800047c0:	21c50513          	addi	a0,a0,540 # 800099d8 <etext+0x9d8>
    800047c4:	c5dff0ef          	jal	80004420 <log_report>

    install_trans(1);
    800047c8:	4505                	li	a0,1
    800047ca:	d35ff0ef          	jal	800044fe <install_trans>

    old = log_get_state();
    800047ce:	c27ff0ef          	jal	800043f4 <log_get_state>
    800047d2:	faa42823          	sw	a0,-80(s0)
    800047d6:	9101                	srli	a0,a0,0x20
    800047d8:	faa42a23          	sw	a0,-76(s0)
    800047dc:	fab42c23          	sw	a1,-72(s0)
    log.lh.n = 0;
    800047e0:	0001e797          	auipc	a5,0x1e
    800047e4:	9c07a023          	sw	zero,-1600(a5) # 800221a0 <log+0x28>
    write_head();
    800047e8:	e41ff0ef          	jal	80004628 <write_head>

    log_report("RECOVER_DONE", 0, old, "Recovery done");
    800047ec:	00005717          	auipc	a4,0x5
    800047f0:	1fc70713          	addi	a4,a4,508 # 800099e8 <etext+0x9e8>
    800047f4:	fb043603          	ld	a2,-80(s0)
    800047f8:	fb843683          	ld	a3,-72(s0)
    800047fc:	4581                	li	a1,0
    800047fe:	00005517          	auipc	a0,0x5
    80004802:	1fa50513          	addi	a0,a0,506 # 800099f8 <etext+0x9f8>
    80004806:	c1bff0ef          	jal	80004420 <log_report>
}
    8000480a:	b741                	j	8000478a <initlog+0xd4>

000000008000480c <begin_op>:
  }
}

void
begin_op(void)
{
    8000480c:	711d                	addi	sp,sp,-96
    8000480e:	ec86                	sd	ra,88(sp)
    80004810:	e8a2                	sd	s0,80(sp)
    80004812:	e4a6                	sd	s1,72(sp)
    80004814:	e0ca                	sd	s2,64(sp)
    80004816:	fc4e                	sd	s3,56(sp)
    80004818:	f852                	sd	s4,48(sp)
    8000481a:	f456                	sd	s5,40(sp)
    8000481c:	f05a                	sd	s6,32(sp)
    8000481e:	ec5e                	sd	s7,24(sp)
    80004820:	1080                	addi	s0,sp,96
  acquire(&log.lock);
    80004822:	0001e517          	auipc	a0,0x1e
    80004826:	95650513          	addi	a0,a0,-1706 # 80022178 <log>
    8000482a:	bd6fc0ef          	jal	80000c00 <acquire>

  while (1) {
    if (log.committing) {
    8000482e:	0001e497          	auipc	s1,0x1e
    80004832:	94a48493          	addi	s1,s1,-1718 # 80022178 <log>
      struct log_state old = log_get_state();
      log_report("WAIT_COMMIT", 0, old, "Waiting for commit");
      sleep(&log, &log.lock);

    } else if (log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS) {
    80004836:	4979                	li	s2,30
      struct log_state old = log_get_state();
      log_report("WAIT_SPACE", 0, old, "Waiting for log space");
    80004838:	00005a17          	auipc	s4,0x5
    8000483c:	1f8a0a13          	addi	s4,s4,504 # 80009a30 <etext+0xa30>
    80004840:	00005997          	auipc	s3,0x5
    80004844:	20898993          	addi	s3,s3,520 # 80009a48 <etext+0xa48>
      log_report("WAIT_COMMIT", 0, old, "Waiting for commit");
    80004848:	00005b17          	auipc	s6,0x5
    8000484c:	1c0b0b13          	addi	s6,s6,448 # 80009a08 <etext+0xa08>
    80004850:	00005a97          	auipc	s5,0x5
    80004854:	1d0a8a93          	addi	s5,s5,464 # 80009a20 <etext+0xa20>
    80004858:	a03d                	j	80004886 <begin_op+0x7a>
      struct log_state old = log_get_state();
    8000485a:	b9bff0ef          	jal	800043f4 <log_get_state>
    8000485e:	faa42023          	sw	a0,-96(s0)
    80004862:	9101                	srli	a0,a0,0x20
    80004864:	faa42223          	sw	a0,-92(s0)
    80004868:	fab42423          	sw	a1,-88(s0)
      log_report("WAIT_COMMIT", 0, old, "Waiting for commit");
    8000486c:	875a                	mv	a4,s6
    8000486e:	fa043603          	ld	a2,-96(s0)
    80004872:	fa843683          	ld	a3,-88(s0)
    80004876:	4581                	li	a1,0
    80004878:	8556                	mv	a0,s5
    8000487a:	ba7ff0ef          	jal	80004420 <log_report>
      sleep(&log, &log.lock);
    8000487e:	85a6                	mv	a1,s1
    80004880:	8526                	mv	a0,s1
    80004882:	e96fd0ef          	jal	80001f18 <sleep>
    if (log.committing) {
    80004886:	509c                	lw	a5,32(s1)
    80004888:	fbe9                	bnez	a5,8000485a <begin_op+0x4e>
    } else if (log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS) {
    8000488a:	01c4ab83          	lw	s7,28(s1)
    8000488e:	2b85                	addiw	s7,s7,1
    80004890:	002b979b          	slliw	a5,s7,0x2
    80004894:	017787bb          	addw	a5,a5,s7
    80004898:	0017979b          	slliw	a5,a5,0x1
    8000489c:	5498                	lw	a4,40(s1)
    8000489e:	9fb9                	addw	a5,a5,a4
    800048a0:	02f95963          	bge	s2,a5,800048d2 <begin_op+0xc6>
      struct log_state old = log_get_state();
    800048a4:	b51ff0ef          	jal	800043f4 <log_get_state>
    800048a8:	faa42023          	sw	a0,-96(s0)
    800048ac:	9101                	srli	a0,a0,0x20
    800048ae:	faa42223          	sw	a0,-92(s0)
    800048b2:	fab42423          	sw	a1,-88(s0)
      log_report("WAIT_SPACE", 0, old, "Waiting for log space");
    800048b6:	8752                	mv	a4,s4
    800048b8:	fa043603          	ld	a2,-96(s0)
    800048bc:	fa843683          	ld	a3,-88(s0)
    800048c0:	4581                	li	a1,0
    800048c2:	854e                	mv	a0,s3
    800048c4:	b5dff0ef          	jal	80004420 <log_report>
      sleep(&log, &log.lock);
    800048c8:	85a6                	mv	a1,s1
    800048ca:	8526                	mv	a0,s1
    800048cc:	e4cfd0ef          	jal	80001f18 <sleep>
    800048d0:	bf5d                	j	80004886 <begin_op+0x7a>

    } else {
      struct log_state old = log_get_state();
    800048d2:	b23ff0ef          	jal	800043f4 <log_get_state>
    800048d6:	faa42023          	sw	a0,-96(s0)
    800048da:	9101                	srli	a0,a0,0x20
    800048dc:	faa42223          	sw	a0,-92(s0)
    800048e0:	fab42423          	sw	a1,-88(s0)

      log.outstanding++;
    800048e4:	0001e497          	auipc	s1,0x1e
    800048e8:	89448493          	addi	s1,s1,-1900 # 80022178 <log>
    800048ec:	0174ae23          	sw	s7,28(s1)

      log_report("BEGIN_OP", 0, old, "Begin operation");
    800048f0:	00005717          	auipc	a4,0x5
    800048f4:	16870713          	addi	a4,a4,360 # 80009a58 <etext+0xa58>
    800048f8:	fa043603          	ld	a2,-96(s0)
    800048fc:	fa843683          	ld	a3,-88(s0)
    80004900:	4581                	li	a1,0
    80004902:	00005517          	auipc	a0,0x5
    80004906:	16650513          	addi	a0,a0,358 # 80009a68 <etext+0xa68>
    8000490a:	b17ff0ef          	jal	80004420 <log_report>

      release(&log.lock);
    8000490e:	8526                	mv	a0,s1
    80004910:	b88fc0ef          	jal	80000c98 <release>
      break;
    }
  }
}
    80004914:	60e6                	ld	ra,88(sp)
    80004916:	6446                	ld	s0,80(sp)
    80004918:	64a6                	ld	s1,72(sp)
    8000491a:	6906                	ld	s2,64(sp)
    8000491c:	79e2                	ld	s3,56(sp)
    8000491e:	7a42                	ld	s4,48(sp)
    80004920:	7aa2                	ld	s5,40(sp)
    80004922:	7b02                	ld	s6,32(sp)
    80004924:	6be2                	ld	s7,24(sp)
    80004926:	6125                	addi	sp,sp,96
    80004928:	8082                	ret

000000008000492a <end_op>:

void
end_op(void)
{
    8000492a:	7119                	addi	sp,sp,-128
    8000492c:	fc86                	sd	ra,120(sp)
    8000492e:	f8a2                	sd	s0,112(sp)
    80004930:	f4a6                	sd	s1,104(sp)
    80004932:	f0ca                	sd	s2,96(sp)
    80004934:	0100                	addi	s0,sp,128
  int do_commit = 0;

  acquire(&log.lock);
    80004936:	0001e497          	auipc	s1,0x1e
    8000493a:	84248493          	addi	s1,s1,-1982 # 80022178 <log>
    8000493e:	8526                	mv	a0,s1
    80004940:	ac0fc0ef          	jal	80000c00 <acquire>

  struct log_state old = log_get_state();
    80004944:	ab1ff0ef          	jal	800043f4 <log_get_state>
    80004948:	faa42023          	sw	a0,-96(s0)
    8000494c:	9101                	srli	a0,a0,0x20
    8000494e:	faa42223          	sw	a0,-92(s0)
    80004952:	fab42423          	sw	a1,-88(s0)

  log.outstanding--;
    80004956:	4cdc                	lw	a5,28(s1)
    80004958:	37fd                	addiw	a5,a5,-1
    8000495a:	0007891b          	sext.w	s2,a5
    8000495e:	ccdc                	sw	a5,28(s1)

  if (log.outstanding == 0) {
    80004960:	08091163          	bnez	s2,800049e2 <end_op+0xb8>
    do_commit = 1;
    log.committing = 1;
    80004964:	4785                	li	a5,1
    80004966:	d09c                	sw	a5,32(s1)

    log_report("PRE_COMMIT", 0, old, "Start committing");
    80004968:	00005717          	auipc	a4,0x5
    8000496c:	11070713          	addi	a4,a4,272 # 80009a78 <etext+0xa78>
    80004970:	fa043603          	ld	a2,-96(s0)
    80004974:	fa843683          	ld	a3,-88(s0)
    80004978:	4581                	li	a1,0
    8000497a:	00005517          	auipc	a0,0x5
    8000497e:	11650513          	addi	a0,a0,278 # 80009a90 <etext+0xa90>
    80004982:	a9fff0ef          	jal	80004420 <log_report>
  } else {
    log_report("END_OP", 0, old, "End operation");
    wakeup(&log);
  }

  release(&log.lock);
    80004986:	8526                	mv	a0,s1
    80004988:	b10fc0ef          	jal	80000c98 <release>
}

static void
commit(void)
{
  if (log.lh.n > 0) {
    8000498c:	549c                	lw	a5,40(s1)
    8000498e:	08f04963          	bgtz	a5,80004a20 <end_op+0xf6>
    acquire(&log.lock);
    80004992:	0001d497          	auipc	s1,0x1d
    80004996:	7e648493          	addi	s1,s1,2022 # 80022178 <log>
    8000499a:	8526                	mv	a0,s1
    8000499c:	a64fc0ef          	jal	80000c00 <acquire>
    old = log_get_state();
    800049a0:	a55ff0ef          	jal	800043f4 <log_get_state>
    800049a4:	faa42023          	sw	a0,-96(s0)
    800049a8:	9101                	srli	a0,a0,0x20
    800049aa:	faa42223          	sw	a0,-92(s0)
    800049ae:	fab42423          	sw	a1,-88(s0)
    log.committing = 0;
    800049b2:	0204a023          	sw	zero,32(s1)
    log_report("FINAL_RELEASE", 0, old, "Commit finished");
    800049b6:	00005717          	auipc	a4,0x5
    800049ba:	17a70713          	addi	a4,a4,378 # 80009b30 <etext+0xb30>
    800049be:	fa043603          	ld	a2,-96(s0)
    800049c2:	fa843683          	ld	a3,-88(s0)
    800049c6:	4581                	li	a1,0
    800049c8:	00005517          	auipc	a0,0x5
    800049cc:	17850513          	addi	a0,a0,376 # 80009b40 <etext+0xb40>
    800049d0:	a51ff0ef          	jal	80004420 <log_report>
    wakeup(&log);
    800049d4:	8526                	mv	a0,s1
    800049d6:	d8efd0ef          	jal	80001f64 <wakeup>
    release(&log.lock);
    800049da:	8526                	mv	a0,s1
    800049dc:	abcfc0ef          	jal	80000c98 <release>
}
    800049e0:	a815                	j	80004a14 <end_op+0xea>
    log_report("END_OP", 0, old, "End operation");
    800049e2:	00005717          	auipc	a4,0x5
    800049e6:	0be70713          	addi	a4,a4,190 # 80009aa0 <etext+0xaa0>
    800049ea:	fa043603          	ld	a2,-96(s0)
    800049ee:	fa843683          	ld	a3,-88(s0)
    800049f2:	4581                	li	a1,0
    800049f4:	00005517          	auipc	a0,0x5
    800049f8:	0bc50513          	addi	a0,a0,188 # 80009ab0 <etext+0xab0>
    800049fc:	a25ff0ef          	jal	80004420 <log_report>
    wakeup(&log);
    80004a00:	0001d497          	auipc	s1,0x1d
    80004a04:	77848493          	addi	s1,s1,1912 # 80022178 <log>
    80004a08:	8526                	mv	a0,s1
    80004a0a:	d5afd0ef          	jal	80001f64 <wakeup>
  release(&log.lock);
    80004a0e:	8526                	mv	a0,s1
    80004a10:	a88fc0ef          	jal	80000c98 <release>
}
    80004a14:	70e6                	ld	ra,120(sp)
    80004a16:	7446                	ld	s0,112(sp)
    80004a18:	74a6                	ld	s1,104(sp)
    80004a1a:	7906                	ld	s2,96(sp)
    80004a1c:	6109                	addi	sp,sp,128
    80004a1e:	8082                	ret
    struct log_state old = log_get_state();
    80004a20:	9d5ff0ef          	jal	800043f4 <log_get_state>
    80004a24:	f8a42023          	sw	a0,-128(s0)
    80004a28:	9101                	srli	a0,a0,0x20
    80004a2a:	f8a42223          	sw	a0,-124(s0)
    80004a2e:	f8b42423          	sw	a1,-120(s0)

    log_report("COMMIT_START", 0, old, "Commit start");
    80004a32:	00005717          	auipc	a4,0x5
    80004a36:	08670713          	addi	a4,a4,134 # 80009ab8 <etext+0xab8>
    80004a3a:	f8043603          	ld	a2,-128(s0)
    80004a3e:	f8843683          	ld	a3,-120(s0)
    80004a42:	4581                	li	a1,0
    80004a44:	00005517          	auipc	a0,0x5
    80004a48:	08450513          	addi	a0,a0,132 # 80009ac8 <etext+0xac8>
    80004a4c:	9d5ff0ef          	jal	80004420 <log_report>
  for (int tail = 0; tail < log.lh.n; tail++) {
    80004a50:	0001d797          	auipc	a5,0x1d
    80004a54:	7507a783          	lw	a5,1872(a5) # 800221a0 <log+0x28>
    80004a58:	0af05863          	blez	a5,80004b08 <end_op+0x1de>
    80004a5c:	ecce                	sd	s3,88(sp)
    80004a5e:	e8d2                	sd	s4,80(sp)
    80004a60:	e4d6                	sd	s5,72(sp)
    80004a62:	e0da                	sd	s6,64(sp)
    80004a64:	fc5e                	sd	s7,56(sp)
    80004a66:	0001da97          	auipc	s5,0x1d
    80004a6a:	73ea8a93          	addi	s5,s5,1854 # 800221a4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1);
    80004a6e:	0001da17          	auipc	s4,0x1d
    80004a72:	70aa0a13          	addi	s4,s4,1802 # 80022178 <log>
    log_report("LOG_SYNC", log.lh.block[tail], old, "Write to log");
    80004a76:	00005b97          	auipc	s7,0x5
    80004a7a:	062b8b93          	addi	s7,s7,98 # 80009ad8 <etext+0xad8>
    80004a7e:	00005b17          	auipc	s6,0x5
    80004a82:	06ab0b13          	addi	s6,s6,106 # 80009ae8 <etext+0xae8>
    struct buf *to = bread(log.dev, log.start+tail+1);
    80004a86:	018a2583          	lw	a1,24(s4)
    80004a8a:	012585bb          	addw	a1,a1,s2
    80004a8e:	2585                	addiw	a1,a1,1
    80004a90:	024a2503          	lw	a0,36(s4)
    80004a94:	902fe0ef          	jal	80002b96 <bread>
    80004a98:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]);
    80004a9a:	000aa583          	lw	a1,0(s5)
    80004a9e:	024a2503          	lw	a0,36(s4)
    80004aa2:	8f4fe0ef          	jal	80002b96 <bread>
    80004aa6:	89aa                	mv	s3,a0
    struct log_state old = log_get_state();
    80004aa8:	94dff0ef          	jal	800043f4 <log_get_state>
    80004aac:	f8a42823          	sw	a0,-112(s0)
    80004ab0:	02055793          	srli	a5,a0,0x20
    80004ab4:	f8f42a23          	sw	a5,-108(s0)
    80004ab8:	f8b42c23          	sw	a1,-104(s0)
    log_report("LOG_SYNC", log.lh.block[tail], old, "Write to log");
    80004abc:	875e                	mv	a4,s7
    80004abe:	f9043603          	ld	a2,-112(s0)
    80004ac2:	f9843683          	ld	a3,-104(s0)
    80004ac6:	000aa583          	lw	a1,0(s5)
    80004aca:	855a                	mv	a0,s6
    80004acc:	955ff0ef          	jal	80004420 <log_report>
    memmove(to->data, from->data, BSIZE);
    80004ad0:	40000613          	li	a2,1024
    80004ad4:	05898593          	addi	a1,s3,88
    80004ad8:	05848513          	addi	a0,s1,88
    80004adc:	a54fc0ef          	jal	80000d30 <memmove>
    bwrite(to);
    80004ae0:	8526                	mv	a0,s1
    80004ae2:	b04fe0ef          	jal	80002de6 <bwrite>
    brelse(from);
    80004ae6:	854e                	mv	a0,s3
    80004ae8:	b78fe0ef          	jal	80002e60 <brelse>
    brelse(to);
    80004aec:	8526                	mv	a0,s1
    80004aee:	b72fe0ef          	jal	80002e60 <brelse>
  for (int tail = 0; tail < log.lh.n; tail++) {
    80004af2:	2905                	addiw	s2,s2,1
    80004af4:	0a91                	addi	s5,s5,4
    80004af6:	028a2783          	lw	a5,40(s4)
    80004afa:	f8f946e3          	blt	s2,a5,80004a86 <end_op+0x15c>
    80004afe:	69e6                	ld	s3,88(sp)
    80004b00:	6a46                	ld	s4,80(sp)
    80004b02:	6aa6                	ld	s5,72(sp)
    80004b04:	6b06                	ld	s6,64(sp)
    80004b06:	7be2                	ld	s7,56(sp)

    write_log();
    write_head();
    80004b08:	b21ff0ef          	jal	80004628 <write_head>

    old = log_get_state();
    80004b0c:	8e9ff0ef          	jal	800043f4 <log_get_state>
    80004b10:	f8a42023          	sw	a0,-128(s0)
    80004b14:	9101                	srli	a0,a0,0x20
    80004b16:	f8a42223          	sw	a0,-124(s0)
    80004b1a:	f8b42423          	sw	a1,-120(s0)
    log_report("WRITE_HEAD", 0, old, "Header committed");
    80004b1e:	00005717          	auipc	a4,0x5
    80004b22:	fda70713          	addi	a4,a4,-38 # 80009af8 <etext+0xaf8>
    80004b26:	f8043603          	ld	a2,-128(s0)
    80004b2a:	f8843683          	ld	a3,-120(s0)
    80004b2e:	4581                	li	a1,0
    80004b30:	00005517          	auipc	a0,0x5
    80004b34:	e2850513          	addi	a0,a0,-472 # 80009958 <etext+0x958>
    80004b38:	8e9ff0ef          	jal	80004420 <log_report>

    install_trans(0);
    80004b3c:	4501                	li	a0,0
    80004b3e:	9c1ff0ef          	jal	800044fe <install_trans>

    old = log_get_state();
    80004b42:	8b3ff0ef          	jal	800043f4 <log_get_state>
    80004b46:	f8a42023          	sw	a0,-128(s0)
    80004b4a:	9101                	srli	a0,a0,0x20
    80004b4c:	f8a42223          	sw	a0,-124(s0)
    80004b50:	f8b42423          	sw	a1,-120(s0)
    log.lh.n = 0;
    80004b54:	0001d797          	auipc	a5,0x1d
    80004b58:	6407a623          	sw	zero,1612(a5) # 800221a0 <log+0x28>
    write_head();
    80004b5c:	acdff0ef          	jal	80004628 <write_head>

    log_report("COMMIT_DONE", 0, old, "Commit done");
    80004b60:	00005717          	auipc	a4,0x5
    80004b64:	fb070713          	addi	a4,a4,-80 # 80009b10 <etext+0xb10>
    80004b68:	f8043603          	ld	a2,-128(s0)
    80004b6c:	f8843683          	ld	a3,-120(s0)
    80004b70:	4581                	li	a1,0
    80004b72:	00005517          	auipc	a0,0x5
    80004b76:	fae50513          	addi	a0,a0,-82 # 80009b20 <etext+0xb20>
    80004b7a:	8a7ff0ef          	jal	80004420 <log_report>
    80004b7e:	bd11                	j	80004992 <end_op+0x68>

0000000080004b80 <log_write>:
  }
}

void
log_write(struct buf *b)
{
    80004b80:	7179                	addi	sp,sp,-48
    80004b82:	f406                	sd	ra,40(sp)
    80004b84:	f022                	sd	s0,32(sp)
    80004b86:	ec26                	sd	s1,24(sp)
    80004b88:	e84a                	sd	s2,16(sp)
    80004b8a:	1800                	addi	s0,sp,48
    80004b8c:	84aa                	mv	s1,a0
  acquire(&log.lock);
    80004b8e:	0001d917          	auipc	s2,0x1d
    80004b92:	5ea90913          	addi	s2,s2,1514 # 80022178 <log>
    80004b96:	854a                	mv	a0,s2
    80004b98:	868fc0ef          	jal	80000c00 <acquire>

  struct log_state old = log_get_state();
    80004b9c:	859ff0ef          	jal	800043f4 <log_get_state>
    80004ba0:	fca42823          	sw	a0,-48(s0)
    80004ba4:	02055793          	srli	a5,a0,0x20
    80004ba8:	fcf42a23          	sw	a5,-44(s0)
    80004bac:	fcb42c23          	sw	a1,-40(s0)

  int i;
  for (i = 0; i < log.lh.n; i++) {
    80004bb0:	02892603          	lw	a2,40(s2)
    80004bb4:	06c05263          	blez	a2,80004c18 <log_write+0x98>
    if (log.lh.block[i] == b->blockno)
    80004bb8:	44cc                	lw	a1,12(s1)
    80004bba:	0001d717          	auipc	a4,0x1d
    80004bbe:	5ea70713          	addi	a4,a4,1514 # 800221a4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004bc2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)
    80004bc4:	4314                	lw	a3,0(a4)
    80004bc6:	04b68a63          	beq	a3,a1,80004c1a <log_write+0x9a>
  for (i = 0; i < log.lh.n; i++) {
    80004bca:	2785                	addiw	a5,a5,1
    80004bcc:	0711                	addi	a4,a4,4
    80004bce:	fec79be3          	bne	a5,a2,80004bc4 <log_write+0x44>
      break;
  }

  log.lh.block[i] = b->blockno;
    80004bd2:	0621                	addi	a2,a2,8
    80004bd4:	060a                	slli	a2,a2,0x2
    80004bd6:	0001d797          	auipc	a5,0x1d
    80004bda:	5a278793          	addi	a5,a5,1442 # 80022178 <log>
    80004bde:	97b2                	add	a5,a5,a2
    80004be0:	44d8                	lw	a4,12(s1)
    80004be2:	c7d8                	sw	a4,12(a5)

  if (i == log.lh.n) {
    bpin(b);
    80004be4:	8526                	mv	a0,s1
    80004be6:	b7afe0ef          	jal	80002f60 <bpin>
    log.lh.n++;
    80004bea:	0001d717          	auipc	a4,0x1d
    80004bee:	58e70713          	addi	a4,a4,1422 # 80022178 <log>
    80004bf2:	571c                	lw	a5,40(a4)
    80004bf4:	2785                	addiw	a5,a5,1
    80004bf6:	d71c                	sw	a5,40(a4)

    log_report("LOG_WRITE", b->blockno, old, "Add block to log");
    80004bf8:	00005717          	auipc	a4,0x5
    80004bfc:	f5870713          	addi	a4,a4,-168 # 80009b50 <etext+0xb50>
    80004c00:	fd043603          	ld	a2,-48(s0)
    80004c04:	fd843683          	ld	a3,-40(s0)
    80004c08:	44cc                	lw	a1,12(s1)
    80004c0a:	00005517          	auipc	a0,0x5
    80004c0e:	f5e50513          	addi	a0,a0,-162 # 80009b68 <etext+0xb68>
    80004c12:	80fff0ef          	jal	80004420 <log_report>
    80004c16:	a82d                	j	80004c50 <log_write+0xd0>
  for (i = 0; i < log.lh.n; i++) {
    80004c18:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004c1a:	00878693          	addi	a3,a5,8
    80004c1e:	068a                	slli	a3,a3,0x2
    80004c20:	0001d717          	auipc	a4,0x1d
    80004c24:	55870713          	addi	a4,a4,1368 # 80022178 <log>
    80004c28:	9736                	add	a4,a4,a3
    80004c2a:	44d4                	lw	a3,12(s1)
    80004c2c:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {
    80004c2e:	faf60be3          	beq	a2,a5,80004be4 <log_write+0x64>
  } else {
    log_report("LOG_MERGE", b->blockno, old, "Merge block");
    80004c32:	00005717          	auipc	a4,0x5
    80004c36:	f4670713          	addi	a4,a4,-186 # 80009b78 <etext+0xb78>
    80004c3a:	fd043603          	ld	a2,-48(s0)
    80004c3e:	fd843683          	ld	a3,-40(s0)
    80004c42:	44cc                	lw	a1,12(s1)
    80004c44:	00005517          	auipc	a0,0x5
    80004c48:	f4450513          	addi	a0,a0,-188 # 80009b88 <etext+0xb88>
    80004c4c:	fd4ff0ef          	jal	80004420 <log_report>
  }

  release(&log.lock);
    80004c50:	0001d517          	auipc	a0,0x1d
    80004c54:	52850513          	addi	a0,a0,1320 # 80022178 <log>
    80004c58:	840fc0ef          	jal	80000c98 <release>
    80004c5c:	70a2                	ld	ra,40(sp)
    80004c5e:	7402                	ld	s0,32(sp)
    80004c60:	64e2                	ld	s1,24(sp)
    80004c62:	6942                	ld	s2,16(sp)
    80004c64:	6145                	addi	sp,sp,48
    80004c66:	8082                	ret

0000000080004c68 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004c68:	1101                	addi	sp,sp,-32
    80004c6a:	ec06                	sd	ra,24(sp)
    80004c6c:	e822                	sd	s0,16(sp)
    80004c6e:	e426                	sd	s1,8(sp)
    80004c70:	e04a                	sd	s2,0(sp)
    80004c72:	1000                	addi	s0,sp,32
    80004c74:	84aa                	mv	s1,a0
    80004c76:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004c78:	00005597          	auipc	a1,0x5
    80004c7c:	f2058593          	addi	a1,a1,-224 # 80009b98 <etext+0xb98>
    80004c80:	0521                	addi	a0,a0,8
    80004c82:	efffb0ef          	jal	80000b80 <initlock>
  lk->name = name;
    80004c86:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004c8a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c8e:	0204a423          	sw	zero,40(s1)
}
    80004c92:	60e2                	ld	ra,24(sp)
    80004c94:	6442                	ld	s0,16(sp)
    80004c96:	64a2                	ld	s1,8(sp)
    80004c98:	6902                	ld	s2,0(sp)
    80004c9a:	6105                	addi	sp,sp,32
    80004c9c:	8082                	ret

0000000080004c9e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004c9e:	1101                	addi	sp,sp,-32
    80004ca0:	ec06                	sd	ra,24(sp)
    80004ca2:	e822                	sd	s0,16(sp)
    80004ca4:	e426                	sd	s1,8(sp)
    80004ca6:	e04a                	sd	s2,0(sp)
    80004ca8:	1000                	addi	s0,sp,32
    80004caa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004cac:	00850913          	addi	s2,a0,8
    80004cb0:	854a                	mv	a0,s2
    80004cb2:	f4ffb0ef          	jal	80000c00 <acquire>
  while (lk->locked) {
    80004cb6:	409c                	lw	a5,0(s1)
    80004cb8:	c799                	beqz	a5,80004cc6 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004cba:	85ca                	mv	a1,s2
    80004cbc:	8526                	mv	a0,s1
    80004cbe:	a5afd0ef          	jal	80001f18 <sleep>
  while (lk->locked) {
    80004cc2:	409c                	lw	a5,0(s1)
    80004cc4:	fbfd                	bnez	a5,80004cba <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004cc6:	4785                	li	a5,1
    80004cc8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004cca:	c3ffc0ef          	jal	80001908 <myproc>
    80004cce:	591c                	lw	a5,48(a0)
    80004cd0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004cd2:	854a                	mv	a0,s2
    80004cd4:	fc5fb0ef          	jal	80000c98 <release>
}
    80004cd8:	60e2                	ld	ra,24(sp)
    80004cda:	6442                	ld	s0,16(sp)
    80004cdc:	64a2                	ld	s1,8(sp)
    80004cde:	6902                	ld	s2,0(sp)
    80004ce0:	6105                	addi	sp,sp,32
    80004ce2:	8082                	ret

0000000080004ce4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004ce4:	1101                	addi	sp,sp,-32
    80004ce6:	ec06                	sd	ra,24(sp)
    80004ce8:	e822                	sd	s0,16(sp)
    80004cea:	e426                	sd	s1,8(sp)
    80004cec:	e04a                	sd	s2,0(sp)
    80004cee:	1000                	addi	s0,sp,32
    80004cf0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004cf2:	00850913          	addi	s2,a0,8
    80004cf6:	854a                	mv	a0,s2
    80004cf8:	f09fb0ef          	jal	80000c00 <acquire>
  lk->locked = 0;
    80004cfc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004d00:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004d04:	8526                	mv	a0,s1
    80004d06:	a5efd0ef          	jal	80001f64 <wakeup>
  release(&lk->lk);
    80004d0a:	854a                	mv	a0,s2
    80004d0c:	f8dfb0ef          	jal	80000c98 <release>
}
    80004d10:	60e2                	ld	ra,24(sp)
    80004d12:	6442                	ld	s0,16(sp)
    80004d14:	64a2                	ld	s1,8(sp)
    80004d16:	6902                	ld	s2,0(sp)
    80004d18:	6105                	addi	sp,sp,32
    80004d1a:	8082                	ret

0000000080004d1c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004d1c:	7179                	addi	sp,sp,-48
    80004d1e:	f406                	sd	ra,40(sp)
    80004d20:	f022                	sd	s0,32(sp)
    80004d22:	ec26                	sd	s1,24(sp)
    80004d24:	e84a                	sd	s2,16(sp)
    80004d26:	1800                	addi	s0,sp,48
    80004d28:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004d2a:	00850913          	addi	s2,a0,8
    80004d2e:	854a                	mv	a0,s2
    80004d30:	ed1fb0ef          	jal	80000c00 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d34:	409c                	lw	a5,0(s1)
    80004d36:	ef81                	bnez	a5,80004d4e <holdingsleep+0x32>
    80004d38:	4481                	li	s1,0
  release(&lk->lk);
    80004d3a:	854a                	mv	a0,s2
    80004d3c:	f5dfb0ef          	jal	80000c98 <release>
  return r;
}
    80004d40:	8526                	mv	a0,s1
    80004d42:	70a2                	ld	ra,40(sp)
    80004d44:	7402                	ld	s0,32(sp)
    80004d46:	64e2                	ld	s1,24(sp)
    80004d48:	6942                	ld	s2,16(sp)
    80004d4a:	6145                	addi	sp,sp,48
    80004d4c:	8082                	ret
    80004d4e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d50:	0284a983          	lw	s3,40(s1)
    80004d54:	bb5fc0ef          	jal	80001908 <myproc>
    80004d58:	5904                	lw	s1,48(a0)
    80004d5a:	413484b3          	sub	s1,s1,s3
    80004d5e:	0014b493          	seqz	s1,s1
    80004d62:	69a2                	ld	s3,8(sp)
    80004d64:	bfd9                	j	80004d3a <holdingsleep+0x1e>

0000000080004d66 <file_report>:
    char *op,
    struct file *f,
    int old_ref,
    int old_off,
    char *details
){
    80004d66:	dc010113          	addi	sp,sp,-576
    80004d6a:	22113c23          	sd	ra,568(sp)
    80004d6e:	22813823          	sd	s0,560(sp)
    80004d72:	22913423          	sd	s1,552(sp)
    80004d76:	23213023          	sd	s2,544(sp)
    80004d7a:	21313c23          	sd	s3,536(sp)
    80004d7e:	21413823          	sd	s4,528(sp)
    80004d82:	21513423          	sd	s5,520(sp)
    80004d86:	0480                	addi	s0,sp,576
    80004d88:	8aaa                	mv	s5,a0
    80004d8a:	84ae                	mv	s1,a1
    80004d8c:	8a32                	mv	s4,a2
    80004d8e:	89b6                	mv	s3,a3
    80004d90:	893a                	mv	s2,a4
    struct fs_event e;

    memset(&e, 0, sizeof(e));
    80004d92:	20000613          	li	a2,512
    80004d96:	4581                	li	a1,0
    80004d98:	dc040513          	addi	a0,s0,-576
    80004d9c:	f39fb0ef          	jal	80000cd4 <memset>

    e.ticks = ticks;
    80004da0:	00005797          	auipc	a5,0x5
    80004da4:	2a87a783          	lw	a5,680(a5) # 8000a048 <ticks>
    80004da8:	dcf42423          	sw	a5,-568(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    80004dac:	b5dfc0ef          	jal	80001908 <myproc>
    80004db0:	4781                	li	a5,0
    80004db2:	c501                	beqz	a0,80004dba <file_report+0x54>
    80004db4:	b55fc0ef          	jal	80001908 <myproc>
    80004db8:	591c                	lw	a5,48(a0)
    80004dba:	dcf42623          	sw	a5,-564(s0)

    e.type = LAYER_FILE;
    80004dbe:	479d                	li	a5,7
    80004dc0:	dcf42823          	sw	a5,-560(s0)

    safestrcpy(e.op_name, op, sizeof(e.op_name));
    80004dc4:	4641                	li	a2,16
    80004dc6:	85d6                	mv	a1,s5
    80004dc8:	dd440513          	addi	a0,s0,-556
    80004dcc:	846fc0ef          	jal	80000e12 <safestrcpy>

    // تم التعديل هنا: استخدام قسم file من الـ union
    e.file.file_type = f->type;
    80004dd0:	409c                	lw	a5,0(s1)
    80004dd2:	f2f42223          	sw	a5,-220(s0)

    e.file.readable = f->readable;
    80004dd6:	0084c783          	lbu	a5,8(s1)
    80004dda:	f2f42423          	sw	a5,-216(s0)
    e.file.writable = f->writable;
    80004dde:	0094c783          	lbu	a5,9(s1)
    80004de2:	f2f42623          	sw	a5,-212(s0)

    e.file.file_ref = f->ref;
    80004de6:	40dc                	lw	a5,4(s1)
    80004de8:	f2f42823          	sw	a5,-208(s0)
    e.file.old_file_ref = old_ref;
    80004dec:	f3442a23          	sw	s4,-204(s0)

    e.file.file_off = f->off;
    80004df0:	509c                	lw	a5,32(s1)
    80004df2:	f2f42c23          	sw	a5,-200(s0)
    e.file.old_file_off = old_off;
    80004df6:	f3342e23          	sw	s3,-196(s0)

    safestrcpy(e.details, details, sizeof(e.details));
    80004dfa:	08000613          	li	a2,128
    80004dfe:	85ca                	mv	a1,s2
    80004e00:	de440513          	addi	a0,s0,-540
    80004e04:	80efc0ef          	jal	80000e12 <safestrcpy>

    fslog_push(&e);
    80004e08:	dc040513          	addi	a0,s0,-576
    80004e0c:	18c020ef          	jal	80006f98 <fslog_push>
}
    80004e10:	23813083          	ld	ra,568(sp)
    80004e14:	23013403          	ld	s0,560(sp)
    80004e18:	22813483          	ld	s1,552(sp)
    80004e1c:	22013903          	ld	s2,544(sp)
    80004e20:	21813983          	ld	s3,536(sp)
    80004e24:	21013a03          	ld	s4,528(sp)
    80004e28:	20813a83          	ld	s5,520(sp)
    80004e2c:	24010113          	addi	sp,sp,576
    80004e30:	8082                	ret

0000000080004e32 <fileinit>:

void
fileinit(void)
{
    80004e32:	1141                	addi	sp,sp,-16
    80004e34:	e406                	sd	ra,8(sp)
    80004e36:	e022                	sd	s0,0(sp)
    80004e38:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004e3a:	00005597          	auipc	a1,0x5
    80004e3e:	d6e58593          	addi	a1,a1,-658 # 80009ba8 <etext+0xba8>
    80004e42:	0001d517          	auipc	a0,0x1d
    80004e46:	47e50513          	addi	a0,a0,1150 # 800222c0 <ftable>
    80004e4a:	d37fb0ef          	jal	80000b80 <initlock>
}
    80004e4e:	60a2                	ld	ra,8(sp)
    80004e50:	6402                	ld	s0,0(sp)
    80004e52:	0141                	addi	sp,sp,16
    80004e54:	8082                	ret

0000000080004e56 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004e56:	1101                	addi	sp,sp,-32
    80004e58:	ec06                	sd	ra,24(sp)
    80004e5a:	e822                	sd	s0,16(sp)
    80004e5c:	e426                	sd	s1,8(sp)
    80004e5e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004e60:	0001d517          	auipc	a0,0x1d
    80004e64:	46050513          	addi	a0,a0,1120 # 800222c0 <ftable>
    80004e68:	d99fb0ef          	jal	80000c00 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e6c:	0001d497          	auipc	s1,0x1d
    80004e70:	46c48493          	addi	s1,s1,1132 # 800222d8 <ftable+0x18>
    80004e74:	0001e717          	auipc	a4,0x1e
    80004e78:	40470713          	addi	a4,a4,1028 # 80023278 <disk>
    if(f->ref == 0){
    80004e7c:	40dc                	lw	a5,4(s1)
    80004e7e:	cf89                	beqz	a5,80004e98 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e80:	02848493          	addi	s1,s1,40
    80004e84:	fee49ce3          	bne	s1,a4,80004e7c <filealloc+0x26>
);
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004e88:	0001d517          	auipc	a0,0x1d
    80004e8c:	43850513          	addi	a0,a0,1080 # 800222c0 <ftable>
    80004e90:	e09fb0ef          	jal	80000c98 <release>
  return 0;
    80004e94:	4481                	li	s1,0
    80004e96:	a035                	j	80004ec2 <filealloc+0x6c>
      f->ref = 1;
    80004e98:	4785                	li	a5,1
    80004e9a:	c0dc                	sw	a5,4(s1)
      file_report(
    80004e9c:	00005717          	auipc	a4,0x5
    80004ea0:	d1470713          	addi	a4,a4,-748 # 80009bb0 <etext+0xbb0>
    80004ea4:	4681                	li	a3,0
    80004ea6:	4601                	li	a2,0
    80004ea8:	85a6                	mv	a1,s1
    80004eaa:	00005517          	auipc	a0,0x5
    80004eae:	d2650513          	addi	a0,a0,-730 # 80009bd0 <etext+0xbd0>
    80004eb2:	eb5ff0ef          	jal	80004d66 <file_report>
      release(&ftable.lock);
    80004eb6:	0001d517          	auipc	a0,0x1d
    80004eba:	40a50513          	addi	a0,a0,1034 # 800222c0 <ftable>
    80004ebe:	ddbfb0ef          	jal	80000c98 <release>
}
    80004ec2:	8526                	mv	a0,s1
    80004ec4:	60e2                	ld	ra,24(sp)
    80004ec6:	6442                	ld	s0,16(sp)
    80004ec8:	64a2                	ld	s1,8(sp)
    80004eca:	6105                	addi	sp,sp,32
    80004ecc:	8082                	ret

0000000080004ece <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004ece:	1101                	addi	sp,sp,-32
    80004ed0:	ec06                	sd	ra,24(sp)
    80004ed2:	e822                	sd	s0,16(sp)
    80004ed4:	e426                	sd	s1,8(sp)
    80004ed6:	1000                	addi	s0,sp,32
    80004ed8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004eda:	0001d517          	auipc	a0,0x1d
    80004ede:	3e650513          	addi	a0,a0,998 # 800222c0 <ftable>
    80004ee2:	d1ffb0ef          	jal	80000c00 <acquire>
  if(f->ref < 1)
    80004ee6:	40d0                	lw	a2,4(s1)
    80004ee8:	02c05d63          	blez	a2,80004f22 <filedup+0x54>
    panic("filedup");
  int old_ref = f->ref;
  f->ref++;
    80004eec:	0016079b          	addiw	a5,a2,1
    80004ef0:	c0dc                	sw	a5,4(s1)
  file_report(
    80004ef2:	00005717          	auipc	a4,0x5
    80004ef6:	cf670713          	addi	a4,a4,-778 # 80009be8 <etext+0xbe8>
    80004efa:	5094                	lw	a3,32(s1)
    80004efc:	85a6                	mv	a1,s1
    80004efe:	00005517          	auipc	a0,0x5
    80004f02:	d0a50513          	addi	a0,a0,-758 # 80009c08 <etext+0xc08>
    80004f06:	e61ff0ef          	jal	80004d66 <file_report>
    f,
    old_ref,
    f->off,
    "Duplicated file descriptor"
);
  release(&ftable.lock);
    80004f0a:	0001d517          	auipc	a0,0x1d
    80004f0e:	3b650513          	addi	a0,a0,950 # 800222c0 <ftable>
    80004f12:	d87fb0ef          	jal	80000c98 <release>
  return f;
}
    80004f16:	8526                	mv	a0,s1
    80004f18:	60e2                	ld	ra,24(sp)
    80004f1a:	6442                	ld	s0,16(sp)
    80004f1c:	64a2                	ld	s1,8(sp)
    80004f1e:	6105                	addi	sp,sp,32
    80004f20:	8082                	ret
    panic("filedup");
    80004f22:	00005517          	auipc	a0,0x5
    80004f26:	cbe50513          	addi	a0,a0,-834 # 80009be0 <etext+0xbe0>
    80004f2a:	8e9fb0ef          	jal	80000812 <panic>

0000000080004f2e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004f2e:	7139                	addi	sp,sp,-64
    80004f30:	fc06                	sd	ra,56(sp)
    80004f32:	f822                	sd	s0,48(sp)
    80004f34:	f426                	sd	s1,40(sp)
    80004f36:	0080                	addi	s0,sp,64
    80004f38:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004f3a:	0001d517          	auipc	a0,0x1d
    80004f3e:	38650513          	addi	a0,a0,902 # 800222c0 <ftable>
    80004f42:	cbffb0ef          	jal	80000c00 <acquire>
  if(f->ref < 1)
    80004f46:	40d0                	lw	a2,4(s1)
    80004f48:	04c05b63          	blez	a2,80004f9e <fileclose+0x70>
    panic("fileclose");
  int old_ref = f->ref;
  if(--f->ref > 0){
    80004f4c:	fff6079b          	addiw	a5,a2,-1
    80004f50:	0007871b          	sext.w	a4,a5
    80004f54:	c0dc                	sw	a5,4(s1)
    80004f56:	04e04e63          	bgtz	a4,80004fb2 <fileclose+0x84>
    80004f5a:	f04a                	sd	s2,32(sp)
    80004f5c:	ec4e                	sd	s3,24(sp)
    80004f5e:	e852                	sd	s4,16(sp)
    80004f60:	e456                	sd	s5,8(sp)
    "Closing file"
);
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004f62:	0004a903          	lw	s2,0(s1)
    80004f66:	0094ca83          	lbu	s5,9(s1)
    80004f6a:	0104ba03          	ld	s4,16(s1)
    80004f6e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004f72:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004f76:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004f7a:	0001d517          	auipc	a0,0x1d
    80004f7e:	34650513          	addi	a0,a0,838 # 800222c0 <ftable>
    80004f82:	d17fb0ef          	jal	80000c98 <release>

  if(ff.type == FD_PIPE){
    80004f86:	4785                	li	a5,1
    80004f88:	04f90c63          	beq	s2,a5,80004fe0 <fileclose+0xb2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004f8c:	3979                	addiw	s2,s2,-2
    80004f8e:	4785                	li	a5,1
    80004f90:	0727f163          	bgeu	a5,s2,80004ff2 <fileclose+0xc4>
    80004f94:	7902                	ld	s2,32(sp)
    80004f96:	69e2                	ld	s3,24(sp)
    80004f98:	6a42                	ld	s4,16(sp)
    80004f9a:	6aa2                	ld	s5,8(sp)
    80004f9c:	a82d                	j	80004fd6 <fileclose+0xa8>
    80004f9e:	f04a                	sd	s2,32(sp)
    80004fa0:	ec4e                	sd	s3,24(sp)
    80004fa2:	e852                	sd	s4,16(sp)
    80004fa4:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004fa6:	00005517          	auipc	a0,0x5
    80004faa:	c7250513          	addi	a0,a0,-910 # 80009c18 <etext+0xc18>
    80004fae:	865fb0ef          	jal	80000812 <panic>
    file_report(
    80004fb2:	00005717          	auipc	a4,0x5
    80004fb6:	c7670713          	addi	a4,a4,-906 # 80009c28 <etext+0xc28>
    80004fba:	5094                	lw	a3,32(s1)
    80004fbc:	85a6                	mv	a1,s1
    80004fbe:	00005517          	auipc	a0,0x5
    80004fc2:	c7a50513          	addi	a0,a0,-902 # 80009c38 <etext+0xc38>
    80004fc6:	da1ff0ef          	jal	80004d66 <file_report>
    release(&ftable.lock);
    80004fca:	0001d517          	auipc	a0,0x1d
    80004fce:	2f650513          	addi	a0,a0,758 # 800222c0 <ftable>
    80004fd2:	cc7fb0ef          	jal	80000c98 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004fd6:	70e2                	ld	ra,56(sp)
    80004fd8:	7442                	ld	s0,48(sp)
    80004fda:	74a2                	ld	s1,40(sp)
    80004fdc:	6121                	addi	sp,sp,64
    80004fde:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004fe0:	85d6                	mv	a1,s5
    80004fe2:	8552                	mv	a0,s4
    80004fe4:	386000ef          	jal	8000536a <pipeclose>
    80004fe8:	7902                	ld	s2,32(sp)
    80004fea:	69e2                	ld	s3,24(sp)
    80004fec:	6a42                	ld	s4,16(sp)
    80004fee:	6aa2                	ld	s5,8(sp)
    80004ff0:	b7dd                	j	80004fd6 <fileclose+0xa8>
    begin_op();
    80004ff2:	81bff0ef          	jal	8000480c <begin_op>
    iput(ff.ip);
    80004ff6:	854e                	mv	a0,s3
    80004ff8:	b57fe0ef          	jal	80003b4e <iput>
    end_op();
    80004ffc:	92fff0ef          	jal	8000492a <end_op>
    80005000:	7902                	ld	s2,32(sp)
    80005002:	69e2                	ld	s3,24(sp)
    80005004:	6a42                	ld	s4,16(sp)
    80005006:	6aa2                	ld	s5,8(sp)
    80005008:	b7f9                	j	80004fd6 <fileclose+0xa8>

000000008000500a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000500a:	715d                	addi	sp,sp,-80
    8000500c:	e486                	sd	ra,72(sp)
    8000500e:	e0a2                	sd	s0,64(sp)
    80005010:	fc26                	sd	s1,56(sp)
    80005012:	f44e                	sd	s3,40(sp)
    80005014:	0880                	addi	s0,sp,80
    80005016:	84aa                	mv	s1,a0
    80005018:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000501a:	8effc0ef          	jal	80001908 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000501e:	409c                	lw	a5,0(s1)
    80005020:	37f9                	addiw	a5,a5,-2
    80005022:	4705                	li	a4,1
    80005024:	04f76063          	bltu	a4,a5,80005064 <filestat+0x5a>
    80005028:	f84a                	sd	s2,48(sp)
    8000502a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000502c:	6c88                	ld	a0,24(s1)
    8000502e:	911fe0ef          	jal	8000393e <ilock>
    stati(f->ip, &st);
    80005032:	fb840593          	addi	a1,s0,-72
    80005036:	6c88                	ld	a0,24(s1)
    80005038:	d3ffe0ef          	jal	80003d76 <stati>
    iunlock(f->ip);
    8000503c:	6c88                	ld	a0,24(s1)
    8000503e:	9f3fe0ef          	jal	80003a30 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005042:	46e1                	li	a3,24
    80005044:	fb840613          	addi	a2,s0,-72
    80005048:	85ce                	mv	a1,s3
    8000504a:	05093503          	ld	a0,80(s2)
    8000504e:	dcefc0ef          	jal	8000161c <copyout>
    80005052:	41f5551b          	sraiw	a0,a0,0x1f
    80005056:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80005058:	60a6                	ld	ra,72(sp)
    8000505a:	6406                	ld	s0,64(sp)
    8000505c:	74e2                	ld	s1,56(sp)
    8000505e:	79a2                	ld	s3,40(sp)
    80005060:	6161                	addi	sp,sp,80
    80005062:	8082                	ret
  return -1;
    80005064:	557d                	li	a0,-1
    80005066:	bfcd                	j	80005058 <filestat+0x4e>

0000000080005068 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005068:	7179                	addi	sp,sp,-48
    8000506a:	f406                	sd	ra,40(sp)
    8000506c:	f022                	sd	s0,32(sp)
    8000506e:	e84a                	sd	s2,16(sp)
    80005070:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005072:	00854783          	lbu	a5,8(a0)
    80005076:	cfdd                	beqz	a5,80005134 <fileread+0xcc>
    80005078:	ec26                	sd	s1,24(sp)
    8000507a:	e44e                	sd	s3,8(sp)
    8000507c:	84aa                	mv	s1,a0
    8000507e:	89ae                	mv	s3,a1
    80005080:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005082:	411c                	lw	a5,0(a0)
    80005084:	4705                	li	a4,1
    80005086:	06e78463          	beq	a5,a4,800050ee <fileread+0x86>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000508a:	470d                	li	a4,3
    8000508c:	06e78863          	beq	a5,a4,800050fc <fileread+0x94>
    80005090:	e052                	sd	s4,0(sp)
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005092:	4709                	li	a4,2
    80005094:	08e79a63          	bne	a5,a4,80005128 <fileread+0xc0>
    ilock(f->ip);
    80005098:	6d08                	ld	a0,24(a0)
    8000509a:	8a5fe0ef          	jal	8000393e <ilock>
    int old_off = f->off;
    8000509e:	5094                	lw	a3,32(s1)
    800050a0:	00068a1b          	sext.w	s4,a3

    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800050a4:	874a                	mv	a4,s2
    800050a6:	864e                	mv	a2,s3
    800050a8:	4585                	li	a1,1
    800050aa:	6c88                	ld	a0,24(s1)
    800050ac:	cf5fe0ef          	jal	80003da0 <readi>
    800050b0:	892a                	mv	s2,a0
    800050b2:	00a05563          	blez	a0,800050bc <fileread+0x54>
   
    f->off += r;
    800050b6:	509c                	lw	a5,32(s1)
    800050b8:	9fa9                	addw	a5,a5,a0
    800050ba:	d09c                	sw	a5,32(s1)
    file_report(
    800050bc:	00005717          	auipc	a4,0x5
    800050c0:	b8c70713          	addi	a4,a4,-1140 # 80009c48 <etext+0xc48>
    800050c4:	86d2                	mv	a3,s4
    800050c6:	40d0                	lw	a2,4(s1)
    800050c8:	85a6                	mv	a1,s1
    800050ca:	00005517          	auipc	a0,0x5
    800050ce:	b8e50513          	addi	a0,a0,-1138 # 80009c58 <etext+0xc58>
    800050d2:	c95ff0ef          	jal	80004d66 <file_report>
    f,
    f->ref,
    old_off,
    "Read from file"
);
    iunlock(f->ip);
    800050d6:	6c88                	ld	a0,24(s1)
    800050d8:	959fe0ef          	jal	80003a30 <iunlock>
    800050dc:	64e2                	ld	s1,24(sp)
    800050de:	69a2                	ld	s3,8(sp)
    800050e0:	6a02                	ld	s4,0(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800050e2:	854a                	mv	a0,s2
    800050e4:	70a2                	ld	ra,40(sp)
    800050e6:	7402                	ld	s0,32(sp)
    800050e8:	6942                	ld	s2,16(sp)
    800050ea:	6145                	addi	sp,sp,48
    800050ec:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800050ee:	6908                	ld	a0,16(a0)
    800050f0:	3b6000ef          	jal	800054a6 <piperead>
    800050f4:	892a                	mv	s2,a0
    800050f6:	64e2                	ld	s1,24(sp)
    800050f8:	69a2                	ld	s3,8(sp)
    800050fa:	b7e5                	j	800050e2 <fileread+0x7a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800050fc:	02451783          	lh	a5,36(a0)
    80005100:	03079693          	slli	a3,a5,0x30
    80005104:	92c1                	srli	a3,a3,0x30
    80005106:	4725                	li	a4,9
    80005108:	02d76863          	bltu	a4,a3,80005138 <fileread+0xd0>
    8000510c:	0792                	slli	a5,a5,0x4
    8000510e:	0001d717          	auipc	a4,0x1d
    80005112:	11270713          	addi	a4,a4,274 # 80022220 <devsw>
    80005116:	97ba                	add	a5,a5,a4
    80005118:	639c                	ld	a5,0(a5)
    8000511a:	c39d                	beqz	a5,80005140 <fileread+0xd8>
    r = devsw[f->major].read(1, addr, n);
    8000511c:	4505                	li	a0,1
    8000511e:	9782                	jalr	a5
    80005120:	892a                	mv	s2,a0
    80005122:	64e2                	ld	s1,24(sp)
    80005124:	69a2                	ld	s3,8(sp)
    80005126:	bf75                	j	800050e2 <fileread+0x7a>
    panic("fileread");
    80005128:	00005517          	auipc	a0,0x5
    8000512c:	b4050513          	addi	a0,a0,-1216 # 80009c68 <etext+0xc68>
    80005130:	ee2fb0ef          	jal	80000812 <panic>
    return -1;
    80005134:	597d                	li	s2,-1
    80005136:	b775                	j	800050e2 <fileread+0x7a>
      return -1;
    80005138:	597d                	li	s2,-1
    8000513a:	64e2                	ld	s1,24(sp)
    8000513c:	69a2                	ld	s3,8(sp)
    8000513e:	b755                	j	800050e2 <fileread+0x7a>
    80005140:	597d                	li	s2,-1
    80005142:	64e2                	ld	s1,24(sp)
    80005144:	69a2                	ld	s3,8(sp)
    80005146:	bf71                	j	800050e2 <fileread+0x7a>

0000000080005148 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80005148:	00954783          	lbu	a5,9(a0)
    8000514c:	14078263          	beqz	a5,80005290 <filewrite+0x148>
{
    80005150:	7159                	addi	sp,sp,-112
    80005152:	f486                	sd	ra,104(sp)
    80005154:	f0a2                	sd	s0,96(sp)
    80005156:	eca6                	sd	s1,88(sp)
    80005158:	e0d2                	sd	s4,64(sp)
    8000515a:	f45e                	sd	s7,40(sp)
    8000515c:	1880                	addi	s0,sp,112
    8000515e:	84aa                	mv	s1,a0
    80005160:	8bae                	mv	s7,a1
    80005162:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005164:	411c                	lw	a5,0(a0)
    80005166:	4705                	li	a4,1
    80005168:	04e78263          	beq	a5,a4,800051ac <filewrite+0x64>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000516c:	470d                	li	a4,3
    8000516e:	04e78363          	beq	a5,a4,800051b4 <filewrite+0x6c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005172:	4709                	li	a4,2
    80005174:	10e79063          	bne	a5,a4,80005274 <filewrite+0x12c>
    80005178:	e4ce                	sd	s3,72(sp)
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    int old_off;
    while(i < n){
    8000517a:	0cc05963          	blez	a2,8000524c <filewrite+0x104>
    8000517e:	e8ca                	sd	s2,80(sp)
    80005180:	fc56                	sd	s5,56(sp)
    80005182:	f85a                	sd	s6,48(sp)
    80005184:	f062                	sd	s8,32(sp)
    80005186:	ec66                	sd	s9,24(sp)
    80005188:	e86a                	sd	s10,16(sp)
    8000518a:	e46e                	sd	s11,8(sp)
    int i = 0;
    8000518c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000518e:	6c05                	lui	s8,0x1
    80005190:	c00c0c13          	addi	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80005194:	6d85                	lui	s11,0x1
    80005196:	c00d8d9b          	addiw	s11,s11,-1024 # c00 <_entry-0x7ffff400>
      begin_op();
      ilock(f->ip);
      old_off = f->off;
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
        f->off += r;
      file_report(
    8000519a:	00005d17          	auipc	s10,0x5
    8000519e:	aded0d13          	addi	s10,s10,-1314 # 80009c78 <etext+0xc78>
    800051a2:	00005c97          	auipc	s9,0x5
    800051a6:	ae6c8c93          	addi	s9,s9,-1306 # 80009c88 <etext+0xc88>
    800051aa:	a049                	j	8000522c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800051ac:	6908                	ld	a0,16(a0)
    800051ae:	214000ef          	jal	800053c2 <pipewrite>
    800051b2:	a855                	j	80005266 <filewrite+0x11e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800051b4:	02451783          	lh	a5,36(a0)
    800051b8:	03079693          	slli	a3,a5,0x30
    800051bc:	92c1                	srli	a3,a3,0x30
    800051be:	4725                	li	a4,9
    800051c0:	0cd76a63          	bltu	a4,a3,80005294 <filewrite+0x14c>
    800051c4:	0792                	slli	a5,a5,0x4
    800051c6:	0001d717          	auipc	a4,0x1d
    800051ca:	05a70713          	addi	a4,a4,90 # 80022220 <devsw>
    800051ce:	97ba                	add	a5,a5,a4
    800051d0:	679c                	ld	a5,8(a5)
    800051d2:	c3f9                	beqz	a5,80005298 <filewrite+0x150>
    ret = devsw[f->major].write(1, addr, n);
    800051d4:	4505                	li	a0,1
    800051d6:	9782                	jalr	a5
    800051d8:	a079                	j	80005266 <filewrite+0x11e>
      if(n1 > max)
    800051da:	00090a9b          	sext.w	s5,s2
      begin_op();
    800051de:	e2eff0ef          	jal	8000480c <begin_op>
      ilock(f->ip);
    800051e2:	6c88                	ld	a0,24(s1)
    800051e4:	f5afe0ef          	jal	8000393e <ilock>
      old_off = f->off;
    800051e8:	5094                	lw	a3,32(s1)
    800051ea:	00068b1b          	sext.w	s6,a3
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800051ee:	8756                	mv	a4,s5
    800051f0:	01798633          	add	a2,s3,s7
    800051f4:	4585                	li	a1,1
    800051f6:	6c88                	ld	a0,24(s1)
    800051f8:	cd9fe0ef          	jal	80003ed0 <writei>
    800051fc:	892a                	mv	s2,a0
    800051fe:	00a05563          	blez	a0,80005208 <filewrite+0xc0>
        f->off += r;
    80005202:	509c                	lw	a5,32(s1)
    80005204:	9fa9                	addw	a5,a5,a0
    80005206:	d09c                	sw	a5,32(s1)
      file_report(
    80005208:	876a                	mv	a4,s10
    8000520a:	86da                	mv	a3,s6
    8000520c:	40d0                	lw	a2,4(s1)
    8000520e:	85a6                	mv	a1,s1
    80005210:	8566                	mv	a0,s9
    80005212:	b55ff0ef          	jal	80004d66 <file_report>
    f,
    f->ref,
    old_off,
    "Write to file"
);
      iunlock(f->ip);
    80005216:	6c88                	ld	a0,24(s1)
    80005218:	819fe0ef          	jal	80003a30 <iunlock>
      end_op();
    8000521c:	f0eff0ef          	jal	8000492a <end_op>

      if(r != n1){
    80005220:	032a9863          	bne	s5,s2,80005250 <filewrite+0x108>
        // error from writei
        break;
      }
      i += r;
    80005224:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80005228:	0149da63          	bge	s3,s4,8000523c <filewrite+0xf4>
      int n1 = n - i;
    8000522c:	413a093b          	subw	s2,s4,s3
      if(n1 > max)
    80005230:	0009079b          	sext.w	a5,s2
    80005234:	fafc53e3          	bge	s8,a5,800051da <filewrite+0x92>
    80005238:	896e                	mv	s2,s11
    8000523a:	b745                	j	800051da <filewrite+0x92>
    8000523c:	6946                	ld	s2,80(sp)
    8000523e:	7ae2                	ld	s5,56(sp)
    80005240:	7b42                	ld	s6,48(sp)
    80005242:	7c02                	ld	s8,32(sp)
    80005244:	6ce2                	ld	s9,24(sp)
    80005246:	6d42                	ld	s10,16(sp)
    80005248:	6da2                	ld	s11,8(sp)
    8000524a:	a811                	j	8000525e <filewrite+0x116>
    int i = 0;
    8000524c:	4981                	li	s3,0
    8000524e:	a801                	j	8000525e <filewrite+0x116>
    80005250:	6946                	ld	s2,80(sp)
    80005252:	7ae2                	ld	s5,56(sp)
    80005254:	7b42                	ld	s6,48(sp)
    80005256:	7c02                	ld	s8,32(sp)
    80005258:	6ce2                	ld	s9,24(sp)
    8000525a:	6d42                	ld	s10,16(sp)
    8000525c:	6da2                	ld	s11,8(sp)
    }
    ret = (i == n ? n : -1);
    8000525e:	033a1f63          	bne	s4,s3,8000529c <filewrite+0x154>
    80005262:	8552                	mv	a0,s4
    80005264:	69a6                	ld	s3,72(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005266:	70a6                	ld	ra,104(sp)
    80005268:	7406                	ld	s0,96(sp)
    8000526a:	64e6                	ld	s1,88(sp)
    8000526c:	6a06                	ld	s4,64(sp)
    8000526e:	7ba2                	ld	s7,40(sp)
    80005270:	6165                	addi	sp,sp,112
    80005272:	8082                	ret
    80005274:	e8ca                	sd	s2,80(sp)
    80005276:	e4ce                	sd	s3,72(sp)
    80005278:	fc56                	sd	s5,56(sp)
    8000527a:	f85a                	sd	s6,48(sp)
    8000527c:	f062                	sd	s8,32(sp)
    8000527e:	ec66                	sd	s9,24(sp)
    80005280:	e86a                	sd	s10,16(sp)
    80005282:	e46e                	sd	s11,8(sp)
    panic("filewrite");
    80005284:	00005517          	auipc	a0,0x5
    80005288:	a1450513          	addi	a0,a0,-1516 # 80009c98 <etext+0xc98>
    8000528c:	d86fb0ef          	jal	80000812 <panic>
    return -1;
    80005290:	557d                	li	a0,-1
}
    80005292:	8082                	ret
      return -1;
    80005294:	557d                	li	a0,-1
    80005296:	bfc1                	j	80005266 <filewrite+0x11e>
    80005298:	557d                	li	a0,-1
    8000529a:	b7f1                	j	80005266 <filewrite+0x11e>
    ret = (i == n ? n : -1);
    8000529c:	557d                	li	a0,-1
    8000529e:	69a6                	ld	s3,72(sp)
    800052a0:	b7d9                	j	80005266 <filewrite+0x11e>

00000000800052a2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800052a2:	7179                	addi	sp,sp,-48
    800052a4:	f406                	sd	ra,40(sp)
    800052a6:	f022                	sd	s0,32(sp)
    800052a8:	ec26                	sd	s1,24(sp)
    800052aa:	e052                	sd	s4,0(sp)
    800052ac:	1800                	addi	s0,sp,48
    800052ae:	84aa                	mv	s1,a0
    800052b0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800052b2:	0005b023          	sd	zero,0(a1)
    800052b6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800052ba:	b9dff0ef          	jal	80004e56 <filealloc>
    800052be:	e088                	sd	a0,0(s1)
    800052c0:	c549                	beqz	a0,8000534a <pipealloc+0xa8>
    800052c2:	b95ff0ef          	jal	80004e56 <filealloc>
    800052c6:	00aa3023          	sd	a0,0(s4)
    800052ca:	cd25                	beqz	a0,80005342 <pipealloc+0xa0>
    800052cc:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800052ce:	863fb0ef          	jal	80000b30 <kalloc>
    800052d2:	892a                	mv	s2,a0
    800052d4:	c12d                	beqz	a0,80005336 <pipealloc+0x94>
    800052d6:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800052d8:	4985                	li	s3,1
    800052da:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800052de:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800052e2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800052e6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800052ea:	00005597          	auipc	a1,0x5
    800052ee:	9be58593          	addi	a1,a1,-1602 # 80009ca8 <etext+0xca8>
    800052f2:	88ffb0ef          	jal	80000b80 <initlock>
  (*f0)->type = FD_PIPE;
    800052f6:	609c                	ld	a5,0(s1)
    800052f8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800052fc:	609c                	ld	a5,0(s1)
    800052fe:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005302:	609c                	ld	a5,0(s1)
    80005304:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005308:	609c                	ld	a5,0(s1)
    8000530a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000530e:	000a3783          	ld	a5,0(s4)
    80005312:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005316:	000a3783          	ld	a5,0(s4)
    8000531a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000531e:	000a3783          	ld	a5,0(s4)
    80005322:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005326:	000a3783          	ld	a5,0(s4)
    8000532a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000532e:	4501                	li	a0,0
    80005330:	6942                	ld	s2,16(sp)
    80005332:	69a2                	ld	s3,8(sp)
    80005334:	a01d                	j	8000535a <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005336:	6088                	ld	a0,0(s1)
    80005338:	c119                	beqz	a0,8000533e <pipealloc+0x9c>
    8000533a:	6942                	ld	s2,16(sp)
    8000533c:	a029                	j	80005346 <pipealloc+0xa4>
    8000533e:	6942                	ld	s2,16(sp)
    80005340:	a029                	j	8000534a <pipealloc+0xa8>
    80005342:	6088                	ld	a0,0(s1)
    80005344:	c10d                	beqz	a0,80005366 <pipealloc+0xc4>
    fileclose(*f0);
    80005346:	be9ff0ef          	jal	80004f2e <fileclose>
  if(*f1)
    8000534a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000534e:	557d                	li	a0,-1
  if(*f1)
    80005350:	c789                	beqz	a5,8000535a <pipealloc+0xb8>
    fileclose(*f1);
    80005352:	853e                	mv	a0,a5
    80005354:	bdbff0ef          	jal	80004f2e <fileclose>
  return -1;
    80005358:	557d                	li	a0,-1
}
    8000535a:	70a2                	ld	ra,40(sp)
    8000535c:	7402                	ld	s0,32(sp)
    8000535e:	64e2                	ld	s1,24(sp)
    80005360:	6a02                	ld	s4,0(sp)
    80005362:	6145                	addi	sp,sp,48
    80005364:	8082                	ret
  return -1;
    80005366:	557d                	li	a0,-1
    80005368:	bfcd                	j	8000535a <pipealloc+0xb8>

000000008000536a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000536a:	1101                	addi	sp,sp,-32
    8000536c:	ec06                	sd	ra,24(sp)
    8000536e:	e822                	sd	s0,16(sp)
    80005370:	e426                	sd	s1,8(sp)
    80005372:	e04a                	sd	s2,0(sp)
    80005374:	1000                	addi	s0,sp,32
    80005376:	84aa                	mv	s1,a0
    80005378:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000537a:	887fb0ef          	jal	80000c00 <acquire>
  if(writable){
    8000537e:	02090763          	beqz	s2,800053ac <pipeclose+0x42>
    pi->writeopen = 0;
    80005382:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005386:	21848513          	addi	a0,s1,536
    8000538a:	bdbfc0ef          	jal	80001f64 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000538e:	2204b783          	ld	a5,544(s1)
    80005392:	e785                	bnez	a5,800053ba <pipeclose+0x50>
    release(&pi->lock);
    80005394:	8526                	mv	a0,s1
    80005396:	903fb0ef          	jal	80000c98 <release>
    kfree((char*)pi);
    8000539a:	8526                	mv	a0,s1
    8000539c:	eb2fb0ef          	jal	80000a4e <kfree>
  } else
    release(&pi->lock);
}
    800053a0:	60e2                	ld	ra,24(sp)
    800053a2:	6442                	ld	s0,16(sp)
    800053a4:	64a2                	ld	s1,8(sp)
    800053a6:	6902                	ld	s2,0(sp)
    800053a8:	6105                	addi	sp,sp,32
    800053aa:	8082                	ret
    pi->readopen = 0;
    800053ac:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800053b0:	21c48513          	addi	a0,s1,540
    800053b4:	bb1fc0ef          	jal	80001f64 <wakeup>
    800053b8:	bfd9                	j	8000538e <pipeclose+0x24>
    release(&pi->lock);
    800053ba:	8526                	mv	a0,s1
    800053bc:	8ddfb0ef          	jal	80000c98 <release>
}
    800053c0:	b7c5                	j	800053a0 <pipeclose+0x36>

00000000800053c2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800053c2:	711d                	addi	sp,sp,-96
    800053c4:	ec86                	sd	ra,88(sp)
    800053c6:	e8a2                	sd	s0,80(sp)
    800053c8:	e4a6                	sd	s1,72(sp)
    800053ca:	e0ca                	sd	s2,64(sp)
    800053cc:	fc4e                	sd	s3,56(sp)
    800053ce:	f852                	sd	s4,48(sp)
    800053d0:	f456                	sd	s5,40(sp)
    800053d2:	1080                	addi	s0,sp,96
    800053d4:	84aa                	mv	s1,a0
    800053d6:	8aae                	mv	s5,a1
    800053d8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800053da:	d2efc0ef          	jal	80001908 <myproc>
    800053de:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800053e0:	8526                	mv	a0,s1
    800053e2:	81ffb0ef          	jal	80000c00 <acquire>
  while(i < n){
    800053e6:	0b405a63          	blez	s4,8000549a <pipewrite+0xd8>
    800053ea:	f05a                	sd	s6,32(sp)
    800053ec:	ec5e                	sd	s7,24(sp)
    800053ee:	e862                	sd	s8,16(sp)
  int i = 0;
    800053f0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800053f2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800053f4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800053f8:	21c48b93          	addi	s7,s1,540
    800053fc:	a81d                	j	80005432 <pipewrite+0x70>
      release(&pi->lock);
    800053fe:	8526                	mv	a0,s1
    80005400:	899fb0ef          	jal	80000c98 <release>
      return -1;
    80005404:	597d                	li	s2,-1
    80005406:	7b02                	ld	s6,32(sp)
    80005408:	6be2                	ld	s7,24(sp)
    8000540a:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000540c:	854a                	mv	a0,s2
    8000540e:	60e6                	ld	ra,88(sp)
    80005410:	6446                	ld	s0,80(sp)
    80005412:	64a6                	ld	s1,72(sp)
    80005414:	6906                	ld	s2,64(sp)
    80005416:	79e2                	ld	s3,56(sp)
    80005418:	7a42                	ld	s4,48(sp)
    8000541a:	7aa2                	ld	s5,40(sp)
    8000541c:	6125                	addi	sp,sp,96
    8000541e:	8082                	ret
      wakeup(&pi->nread);
    80005420:	8562                	mv	a0,s8
    80005422:	b43fc0ef          	jal	80001f64 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005426:	85a6                	mv	a1,s1
    80005428:	855e                	mv	a0,s7
    8000542a:	aeffc0ef          	jal	80001f18 <sleep>
  while(i < n){
    8000542e:	05495b63          	bge	s2,s4,80005484 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80005432:	2204a783          	lw	a5,544(s1)
    80005436:	d7e1                	beqz	a5,800053fe <pipewrite+0x3c>
    80005438:	854e                	mv	a0,s3
    8000543a:	d17fc0ef          	jal	80002150 <killed>
    8000543e:	f161                	bnez	a0,800053fe <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005440:	2184a783          	lw	a5,536(s1)
    80005444:	21c4a703          	lw	a4,540(s1)
    80005448:	2007879b          	addiw	a5,a5,512
    8000544c:	fcf70ae3          	beq	a4,a5,80005420 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005450:	4685                	li	a3,1
    80005452:	01590633          	add	a2,s2,s5
    80005456:	faf40593          	addi	a1,s0,-81
    8000545a:	0509b503          	ld	a0,80(s3)
    8000545e:	aa2fc0ef          	jal	80001700 <copyin>
    80005462:	03650e63          	beq	a0,s6,8000549e <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005466:	21c4a783          	lw	a5,540(s1)
    8000546a:	0017871b          	addiw	a4,a5,1
    8000546e:	20e4ae23          	sw	a4,540(s1)
    80005472:	1ff7f793          	andi	a5,a5,511
    80005476:	97a6                	add	a5,a5,s1
    80005478:	faf44703          	lbu	a4,-81(s0)
    8000547c:	00e78c23          	sb	a4,24(a5)
      i++;
    80005480:	2905                	addiw	s2,s2,1
    80005482:	b775                	j	8000542e <pipewrite+0x6c>
    80005484:	7b02                	ld	s6,32(sp)
    80005486:	6be2                	ld	s7,24(sp)
    80005488:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000548a:	21848513          	addi	a0,s1,536
    8000548e:	ad7fc0ef          	jal	80001f64 <wakeup>
  release(&pi->lock);
    80005492:	8526                	mv	a0,s1
    80005494:	805fb0ef          	jal	80000c98 <release>
  return i;
    80005498:	bf95                	j	8000540c <pipewrite+0x4a>
  int i = 0;
    8000549a:	4901                	li	s2,0
    8000549c:	b7fd                	j	8000548a <pipewrite+0xc8>
    8000549e:	7b02                	ld	s6,32(sp)
    800054a0:	6be2                	ld	s7,24(sp)
    800054a2:	6c42                	ld	s8,16(sp)
    800054a4:	b7dd                	j	8000548a <pipewrite+0xc8>

00000000800054a6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800054a6:	715d                	addi	sp,sp,-80
    800054a8:	e486                	sd	ra,72(sp)
    800054aa:	e0a2                	sd	s0,64(sp)
    800054ac:	fc26                	sd	s1,56(sp)
    800054ae:	f84a                	sd	s2,48(sp)
    800054b0:	f44e                	sd	s3,40(sp)
    800054b2:	f052                	sd	s4,32(sp)
    800054b4:	ec56                	sd	s5,24(sp)
    800054b6:	0880                	addi	s0,sp,80
    800054b8:	84aa                	mv	s1,a0
    800054ba:	892e                	mv	s2,a1
    800054bc:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800054be:	c4afc0ef          	jal	80001908 <myproc>
    800054c2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800054c4:	8526                	mv	a0,s1
    800054c6:	f3afb0ef          	jal	80000c00 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800054ca:	2184a703          	lw	a4,536(s1)
    800054ce:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800054d2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800054d6:	02f71563          	bne	a4,a5,80005500 <piperead+0x5a>
    800054da:	2244a783          	lw	a5,548(s1)
    800054de:	cb85                	beqz	a5,8000550e <piperead+0x68>
    if(killed(pr)){
    800054e0:	8552                	mv	a0,s4
    800054e2:	c6ffc0ef          	jal	80002150 <killed>
    800054e6:	ed19                	bnez	a0,80005504 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800054e8:	85a6                	mv	a1,s1
    800054ea:	854e                	mv	a0,s3
    800054ec:	a2dfc0ef          	jal	80001f18 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800054f0:	2184a703          	lw	a4,536(s1)
    800054f4:	21c4a783          	lw	a5,540(s1)
    800054f8:	fef701e3          	beq	a4,a5,800054da <piperead+0x34>
    800054fc:	e85a                	sd	s6,16(sp)
    800054fe:	a809                	j	80005510 <piperead+0x6a>
    80005500:	e85a                	sd	s6,16(sp)
    80005502:	a039                	j	80005510 <piperead+0x6a>
      release(&pi->lock);
    80005504:	8526                	mv	a0,s1
    80005506:	f92fb0ef          	jal	80000c98 <release>
      return -1;
    8000550a:	59fd                	li	s3,-1
    8000550c:	a8b9                	j	8000556a <piperead+0xc4>
    8000550e:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005510:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80005512:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005514:	05505363          	blez	s5,8000555a <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005518:	2184a783          	lw	a5,536(s1)
    8000551c:	21c4a703          	lw	a4,540(s1)
    80005520:	02f70d63          	beq	a4,a5,8000555a <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80005524:	1ff7f793          	andi	a5,a5,511
    80005528:	97a6                	add	a5,a5,s1
    8000552a:	0187c783          	lbu	a5,24(a5)
    8000552e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80005532:	4685                	li	a3,1
    80005534:	fbf40613          	addi	a2,s0,-65
    80005538:	85ca                	mv	a1,s2
    8000553a:	050a3503          	ld	a0,80(s4)
    8000553e:	8defc0ef          	jal	8000161c <copyout>
    80005542:	03650e63          	beq	a0,s6,8000557e <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80005546:	2184a783          	lw	a5,536(s1)
    8000554a:	2785                	addiw	a5,a5,1
    8000554c:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005550:	2985                	addiw	s3,s3,1
    80005552:	0905                	addi	s2,s2,1
    80005554:	fd3a92e3          	bne	s5,s3,80005518 <piperead+0x72>
    80005558:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000555a:	21c48513          	addi	a0,s1,540
    8000555e:	a07fc0ef          	jal	80001f64 <wakeup>
  release(&pi->lock);
    80005562:	8526                	mv	a0,s1
    80005564:	f34fb0ef          	jal	80000c98 <release>
    80005568:	6b42                	ld	s6,16(sp)
  return i;
}
    8000556a:	854e                	mv	a0,s3
    8000556c:	60a6                	ld	ra,72(sp)
    8000556e:	6406                	ld	s0,64(sp)
    80005570:	74e2                	ld	s1,56(sp)
    80005572:	7942                	ld	s2,48(sp)
    80005574:	79a2                	ld	s3,40(sp)
    80005576:	7a02                	ld	s4,32(sp)
    80005578:	6ae2                	ld	s5,24(sp)
    8000557a:	6161                	addi	sp,sp,80
    8000557c:	8082                	ret
      if(i == 0)
    8000557e:	fc099ee3          	bnez	s3,8000555a <piperead+0xb4>
        i = -1;
    80005582:	89aa                	mv	s3,a0
    80005584:	bfd9                	j	8000555a <piperead+0xb4>

0000000080005586 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80005586:	1141                	addi	sp,sp,-16
    80005588:	e422                	sd	s0,8(sp)
    8000558a:	0800                	addi	s0,sp,16
    8000558c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000558e:	8905                	andi	a0,a0,1
    80005590:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005592:	8b89                	andi	a5,a5,2
    80005594:	c399                	beqz	a5,8000559a <flags2perm+0x14>
      perm |= PTE_W;
    80005596:	00456513          	ori	a0,a0,4
    return perm;
}
    8000559a:	6422                	ld	s0,8(sp)
    8000559c:	0141                	addi	sp,sp,16
    8000559e:	8082                	ret

00000000800055a0 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800055a0:	df010113          	addi	sp,sp,-528
    800055a4:	20113423          	sd	ra,520(sp)
    800055a8:	20813023          	sd	s0,512(sp)
    800055ac:	ffa6                	sd	s1,504(sp)
    800055ae:	fbca                	sd	s2,496(sp)
    800055b0:	0c00                	addi	s0,sp,528
    800055b2:	892a                	mv	s2,a0
    800055b4:	dea43c23          	sd	a0,-520(s0)
    800055b8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800055bc:	b4cfc0ef          	jal	80001908 <myproc>
    800055c0:	84aa                	mv	s1,a0

  begin_op();
    800055c2:	a4aff0ef          	jal	8000480c <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800055c6:	854a                	mv	a0,s2
    800055c8:	dfbfe0ef          	jal	800043c2 <namei>
    800055cc:	c931                	beqz	a0,80005620 <kexec+0x80>
    800055ce:	f3d2                	sd	s4,480(sp)
    800055d0:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800055d2:	b6cfe0ef          	jal	8000393e <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800055d6:	04000713          	li	a4,64
    800055da:	4681                	li	a3,0
    800055dc:	e5040613          	addi	a2,s0,-432
    800055e0:	4581                	li	a1,0
    800055e2:	8552                	mv	a0,s4
    800055e4:	fbcfe0ef          	jal	80003da0 <readi>
    800055e8:	04000793          	li	a5,64
    800055ec:	00f51a63          	bne	a0,a5,80005600 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800055f0:	e5042703          	lw	a4,-432(s0)
    800055f4:	464c47b7          	lui	a5,0x464c4
    800055f8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800055fc:	02f70663          	beq	a4,a5,80005628 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005600:	8552                	mv	a0,s4
    80005602:	e18fe0ef          	jal	80003c1a <iunlockput>
    end_op();
    80005606:	b24ff0ef          	jal	8000492a <end_op>
  }
  return -1;
    8000560a:	557d                	li	a0,-1
    8000560c:	7a1e                	ld	s4,480(sp)
}
    8000560e:	20813083          	ld	ra,520(sp)
    80005612:	20013403          	ld	s0,512(sp)
    80005616:	74fe                	ld	s1,504(sp)
    80005618:	795e                	ld	s2,496(sp)
    8000561a:	21010113          	addi	sp,sp,528
    8000561e:	8082                	ret
    end_op();
    80005620:	b0aff0ef          	jal	8000492a <end_op>
    return -1;
    80005624:	557d                	li	a0,-1
    80005626:	b7e5                	j	8000560e <kexec+0x6e>
    80005628:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000562a:	8526                	mv	a0,s1
    8000562c:	be2fc0ef          	jal	80001a0e <proc_pagetable>
    80005630:	8b2a                	mv	s6,a0
    80005632:	2c050b63          	beqz	a0,80005908 <kexec+0x368>
    80005636:	f7ce                	sd	s3,488(sp)
    80005638:	efd6                	sd	s5,472(sp)
    8000563a:	e7de                	sd	s7,456(sp)
    8000563c:	e3e2                	sd	s8,448(sp)
    8000563e:	ff66                	sd	s9,440(sp)
    80005640:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005642:	e7042d03          	lw	s10,-400(s0)
    80005646:	e8845783          	lhu	a5,-376(s0)
    8000564a:	12078963          	beqz	a5,8000577c <kexec+0x1dc>
    8000564e:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005650:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005652:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005654:	6c85                	lui	s9,0x1
    80005656:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000565a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000565e:	6a85                	lui	s5,0x1
    80005660:	a085                	j	800056c0 <kexec+0x120>
      panic("loadseg: address should exist");
    80005662:	00004517          	auipc	a0,0x4
    80005666:	64e50513          	addi	a0,a0,1614 # 80009cb0 <etext+0xcb0>
    8000566a:	9a8fb0ef          	jal	80000812 <panic>
    if(sz - i < PGSIZE)
    8000566e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005670:	8726                	mv	a4,s1
    80005672:	012c06bb          	addw	a3,s8,s2
    80005676:	4581                	li	a1,0
    80005678:	8552                	mv	a0,s4
    8000567a:	f26fe0ef          	jal	80003da0 <readi>
    8000567e:	2501                	sext.w	a0,a0
    80005680:	24a49a63          	bne	s1,a0,800058d4 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80005684:	012a893b          	addw	s2,s5,s2
    80005688:	03397363          	bgeu	s2,s3,800056ae <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000568c:	02091593          	slli	a1,s2,0x20
    80005690:	9181                	srli	a1,a1,0x20
    80005692:	95de                	add	a1,a1,s7
    80005694:	855a                	mv	a0,s6
    80005696:	955fb0ef          	jal	80000fea <walkaddr>
    8000569a:	862a                	mv	a2,a0
    if(pa == 0)
    8000569c:	d179                	beqz	a0,80005662 <kexec+0xc2>
    if(sz - i < PGSIZE)
    8000569e:	412984bb          	subw	s1,s3,s2
    800056a2:	0004879b          	sext.w	a5,s1
    800056a6:	fcfcf4e3          	bgeu	s9,a5,8000566e <kexec+0xce>
    800056aa:	84d6                	mv	s1,s5
    800056ac:	b7c9                	j	8000566e <kexec+0xce>
    sz = sz1;
    800056ae:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800056b2:	2d85                	addiw	s11,s11,1
    800056b4:	038d0d1b          	addiw	s10,s10,56
    800056b8:	e8845783          	lhu	a5,-376(s0)
    800056bc:	08fdd063          	bge	s11,a5,8000573c <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800056c0:	2d01                	sext.w	s10,s10
    800056c2:	03800713          	li	a4,56
    800056c6:	86ea                	mv	a3,s10
    800056c8:	e1840613          	addi	a2,s0,-488
    800056cc:	4581                	li	a1,0
    800056ce:	8552                	mv	a0,s4
    800056d0:	ed0fe0ef          	jal	80003da0 <readi>
    800056d4:	03800793          	li	a5,56
    800056d8:	1cf51663          	bne	a0,a5,800058a4 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800056dc:	e1842783          	lw	a5,-488(s0)
    800056e0:	4705                	li	a4,1
    800056e2:	fce798e3          	bne	a5,a4,800056b2 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    800056e6:	e4043483          	ld	s1,-448(s0)
    800056ea:	e3843783          	ld	a5,-456(s0)
    800056ee:	1af4ef63          	bltu	s1,a5,800058ac <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800056f2:	e2843783          	ld	a5,-472(s0)
    800056f6:	94be                	add	s1,s1,a5
    800056f8:	1af4ee63          	bltu	s1,a5,800058b4 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800056fc:	df043703          	ld	a4,-528(s0)
    80005700:	8ff9                	and	a5,a5,a4
    80005702:	1a079d63          	bnez	a5,800058bc <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005706:	e1c42503          	lw	a0,-484(s0)
    8000570a:	e7dff0ef          	jal	80005586 <flags2perm>
    8000570e:	86aa                	mv	a3,a0
    80005710:	8626                	mv	a2,s1
    80005712:	85ca                	mv	a1,s2
    80005714:	855a                	mv	a0,s6
    80005716:	badfb0ef          	jal	800012c2 <uvmalloc>
    8000571a:	e0a43423          	sd	a0,-504(s0)
    8000571e:	1a050363          	beqz	a0,800058c4 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005722:	e2843b83          	ld	s7,-472(s0)
    80005726:	e2042c03          	lw	s8,-480(s0)
    8000572a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000572e:	00098463          	beqz	s3,80005736 <kexec+0x196>
    80005732:	4901                	li	s2,0
    80005734:	bfa1                	j	8000568c <kexec+0xec>
    sz = sz1;
    80005736:	e0843903          	ld	s2,-504(s0)
    8000573a:	bfa5                	j	800056b2 <kexec+0x112>
    8000573c:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000573e:	8552                	mv	a0,s4
    80005740:	cdafe0ef          	jal	80003c1a <iunlockput>
  end_op();
    80005744:	9e6ff0ef          	jal	8000492a <end_op>
  p = myproc();
    80005748:	9c0fc0ef          	jal	80001908 <myproc>
    8000574c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000574e:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005752:	6985                	lui	s3,0x1
    80005754:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005756:	99ca                	add	s3,s3,s2
    80005758:	77fd                	lui	a5,0xfffff
    8000575a:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000575e:	4691                	li	a3,4
    80005760:	6609                	lui	a2,0x2
    80005762:	964e                	add	a2,a2,s3
    80005764:	85ce                	mv	a1,s3
    80005766:	855a                	mv	a0,s6
    80005768:	b5bfb0ef          	jal	800012c2 <uvmalloc>
    8000576c:	892a                	mv	s2,a0
    8000576e:	e0a43423          	sd	a0,-504(s0)
    80005772:	e519                	bnez	a0,80005780 <kexec+0x1e0>
  if(pagetable)
    80005774:	e1343423          	sd	s3,-504(s0)
    80005778:	4a01                	li	s4,0
    8000577a:	aab1                	j	800058d6 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000577c:	4901                	li	s2,0
    8000577e:	b7c1                	j	8000573e <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80005780:	75f9                	lui	a1,0xffffe
    80005782:	95aa                	add	a1,a1,a0
    80005784:	855a                	mv	a0,s6
    80005786:	d13fb0ef          	jal	80001498 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    8000578a:	7bfd                	lui	s7,0xfffff
    8000578c:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    8000578e:	e0043783          	ld	a5,-512(s0)
    80005792:	6388                	ld	a0,0(a5)
    80005794:	cd39                	beqz	a0,800057f2 <kexec+0x252>
    80005796:	e9040993          	addi	s3,s0,-368
    8000579a:	f9040c13          	addi	s8,s0,-112
    8000579e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800057a0:	ea4fb0ef          	jal	80000e44 <strlen>
    800057a4:	0015079b          	addiw	a5,a0,1
    800057a8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800057ac:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800057b0:	11796e63          	bltu	s2,s7,800058cc <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800057b4:	e0043d03          	ld	s10,-512(s0)
    800057b8:	000d3a03          	ld	s4,0(s10)
    800057bc:	8552                	mv	a0,s4
    800057be:	e86fb0ef          	jal	80000e44 <strlen>
    800057c2:	0015069b          	addiw	a3,a0,1
    800057c6:	8652                	mv	a2,s4
    800057c8:	85ca                	mv	a1,s2
    800057ca:	855a                	mv	a0,s6
    800057cc:	e51fb0ef          	jal	8000161c <copyout>
    800057d0:	10054063          	bltz	a0,800058d0 <kexec+0x330>
    ustack[argc] = sp;
    800057d4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800057d8:	0485                	addi	s1,s1,1
    800057da:	008d0793          	addi	a5,s10,8
    800057de:	e0f43023          	sd	a5,-512(s0)
    800057e2:	008d3503          	ld	a0,8(s10)
    800057e6:	c909                	beqz	a0,800057f8 <kexec+0x258>
    if(argc >= MAXARG)
    800057e8:	09a1                	addi	s3,s3,8
    800057ea:	fb899be3          	bne	s3,s8,800057a0 <kexec+0x200>
  ip = 0;
    800057ee:	4a01                	li	s4,0
    800057f0:	a0dd                	j	800058d6 <kexec+0x336>
  sp = sz;
    800057f2:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800057f6:	4481                	li	s1,0
  ustack[argc] = 0;
    800057f8:	00349793          	slli	a5,s1,0x3
    800057fc:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ff6eb30>
    80005800:	97a2                	add	a5,a5,s0
    80005802:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005806:	00148693          	addi	a3,s1,1
    8000580a:	068e                	slli	a3,a3,0x3
    8000580c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005810:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005814:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005818:	f5796ee3          	bltu	s2,s7,80005774 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000581c:	e9040613          	addi	a2,s0,-368
    80005820:	85ca                	mv	a1,s2
    80005822:	855a                	mv	a0,s6
    80005824:	df9fb0ef          	jal	8000161c <copyout>
    80005828:	0e054263          	bltz	a0,8000590c <kexec+0x36c>
  p->trapframe->a1 = sp;
    8000582c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005830:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005834:	df843783          	ld	a5,-520(s0)
    80005838:	0007c703          	lbu	a4,0(a5)
    8000583c:	cf11                	beqz	a4,80005858 <kexec+0x2b8>
    8000583e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005840:	02f00693          	li	a3,47
    80005844:	a039                	j	80005852 <kexec+0x2b2>
      last = s+1;
    80005846:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000584a:	0785                	addi	a5,a5,1
    8000584c:	fff7c703          	lbu	a4,-1(a5)
    80005850:	c701                	beqz	a4,80005858 <kexec+0x2b8>
    if(*s == '/')
    80005852:	fed71ce3          	bne	a4,a3,8000584a <kexec+0x2aa>
    80005856:	bfc5                	j	80005846 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80005858:	4641                	li	a2,16
    8000585a:	df843583          	ld	a1,-520(s0)
    8000585e:	158a8513          	addi	a0,s5,344
    80005862:	db0fb0ef          	jal	80000e12 <safestrcpy>
  oldpagetable = p->pagetable;
    80005866:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000586a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000586e:	e0843783          	ld	a5,-504(s0)
    80005872:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80005876:	058ab783          	ld	a5,88(s5)
    8000587a:	e6843703          	ld	a4,-408(s0)
    8000587e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005880:	058ab783          	ld	a5,88(s5)
    80005884:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005888:	85e6                	mv	a1,s9
    8000588a:	a08fc0ef          	jal	80001a92 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000588e:	0004851b          	sext.w	a0,s1
    80005892:	79be                	ld	s3,488(sp)
    80005894:	7a1e                	ld	s4,480(sp)
    80005896:	6afe                	ld	s5,472(sp)
    80005898:	6b5e                	ld	s6,464(sp)
    8000589a:	6bbe                	ld	s7,456(sp)
    8000589c:	6c1e                	ld	s8,448(sp)
    8000589e:	7cfa                	ld	s9,440(sp)
    800058a0:	7d5a                	ld	s10,432(sp)
    800058a2:	b3b5                	j	8000560e <kexec+0x6e>
    800058a4:	e1243423          	sd	s2,-504(s0)
    800058a8:	7dba                	ld	s11,424(sp)
    800058aa:	a035                	j	800058d6 <kexec+0x336>
    800058ac:	e1243423          	sd	s2,-504(s0)
    800058b0:	7dba                	ld	s11,424(sp)
    800058b2:	a015                	j	800058d6 <kexec+0x336>
    800058b4:	e1243423          	sd	s2,-504(s0)
    800058b8:	7dba                	ld	s11,424(sp)
    800058ba:	a831                	j	800058d6 <kexec+0x336>
    800058bc:	e1243423          	sd	s2,-504(s0)
    800058c0:	7dba                	ld	s11,424(sp)
    800058c2:	a811                	j	800058d6 <kexec+0x336>
    800058c4:	e1243423          	sd	s2,-504(s0)
    800058c8:	7dba                	ld	s11,424(sp)
    800058ca:	a031                	j	800058d6 <kexec+0x336>
  ip = 0;
    800058cc:	4a01                	li	s4,0
    800058ce:	a021                	j	800058d6 <kexec+0x336>
    800058d0:	4a01                	li	s4,0
  if(pagetable)
    800058d2:	a011                	j	800058d6 <kexec+0x336>
    800058d4:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800058d6:	e0843583          	ld	a1,-504(s0)
    800058da:	855a                	mv	a0,s6
    800058dc:	9b6fc0ef          	jal	80001a92 <proc_freepagetable>
  return -1;
    800058e0:	557d                	li	a0,-1
  if(ip){
    800058e2:	000a1b63          	bnez	s4,800058f8 <kexec+0x358>
    800058e6:	79be                	ld	s3,488(sp)
    800058e8:	7a1e                	ld	s4,480(sp)
    800058ea:	6afe                	ld	s5,472(sp)
    800058ec:	6b5e                	ld	s6,464(sp)
    800058ee:	6bbe                	ld	s7,456(sp)
    800058f0:	6c1e                	ld	s8,448(sp)
    800058f2:	7cfa                	ld	s9,440(sp)
    800058f4:	7d5a                	ld	s10,432(sp)
    800058f6:	bb21                	j	8000560e <kexec+0x6e>
    800058f8:	79be                	ld	s3,488(sp)
    800058fa:	6afe                	ld	s5,472(sp)
    800058fc:	6b5e                	ld	s6,464(sp)
    800058fe:	6bbe                	ld	s7,456(sp)
    80005900:	6c1e                	ld	s8,448(sp)
    80005902:	7cfa                	ld	s9,440(sp)
    80005904:	7d5a                	ld	s10,432(sp)
    80005906:	b9ed                	j	80005600 <kexec+0x60>
    80005908:	6b5e                	ld	s6,464(sp)
    8000590a:	b9dd                	j	80005600 <kexec+0x60>
  sz = sz1;
    8000590c:	e0843983          	ld	s3,-504(s0)
    80005910:	b595                	j	80005774 <kexec+0x1d4>

0000000080005912 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005912:	7179                	addi	sp,sp,-48
    80005914:	f406                	sd	ra,40(sp)
    80005916:	f022                	sd	s0,32(sp)
    80005918:	ec26                	sd	s1,24(sp)
    8000591a:	e84a                	sd	s2,16(sp)
    8000591c:	1800                	addi	s0,sp,48
    8000591e:	892e                	mv	s2,a1
    80005920:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005922:	fdc40593          	addi	a1,s0,-36
    80005926:	ef7fc0ef          	jal	8000281c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000592a:	fdc42703          	lw	a4,-36(s0)
    8000592e:	47bd                	li	a5,15
    80005930:	02e7e963          	bltu	a5,a4,80005962 <argfd+0x50>
    80005934:	fd5fb0ef          	jal	80001908 <myproc>
    80005938:	fdc42703          	lw	a4,-36(s0)
    8000593c:	01a70793          	addi	a5,a4,26
    80005940:	078e                	slli	a5,a5,0x3
    80005942:	953e                	add	a0,a0,a5
    80005944:	611c                	ld	a5,0(a0)
    80005946:	c385                	beqz	a5,80005966 <argfd+0x54>
    return -1;
  if(pfd)
    80005948:	00090463          	beqz	s2,80005950 <argfd+0x3e>
    *pfd = fd;
    8000594c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005950:	4501                	li	a0,0
  if(pf)
    80005952:	c091                	beqz	s1,80005956 <argfd+0x44>
    *pf = f;
    80005954:	e09c                	sd	a5,0(s1)
}
    80005956:	70a2                	ld	ra,40(sp)
    80005958:	7402                	ld	s0,32(sp)
    8000595a:	64e2                	ld	s1,24(sp)
    8000595c:	6942                	ld	s2,16(sp)
    8000595e:	6145                	addi	sp,sp,48
    80005960:	8082                	ret
    return -1;
    80005962:	557d                	li	a0,-1
    80005964:	bfcd                	j	80005956 <argfd+0x44>
    80005966:	557d                	li	a0,-1
    80005968:	b7fd                	j	80005956 <argfd+0x44>

000000008000596a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000596a:	1101                	addi	sp,sp,-32
    8000596c:	ec06                	sd	ra,24(sp)
    8000596e:	e822                	sd	s0,16(sp)
    80005970:	e426                	sd	s1,8(sp)
    80005972:	1000                	addi	s0,sp,32
    80005974:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005976:	f93fb0ef          	jal	80001908 <myproc>
    8000597a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000597c:	0d050793          	addi	a5,a0,208
    80005980:	4501                	li	a0,0
    80005982:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005984:	6398                	ld	a4,0(a5)
    80005986:	cb19                	beqz	a4,8000599c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80005988:	2505                	addiw	a0,a0,1
    8000598a:	07a1                	addi	a5,a5,8
    8000598c:	fed51ce3          	bne	a0,a3,80005984 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005990:	557d                	li	a0,-1
}
    80005992:	60e2                	ld	ra,24(sp)
    80005994:	6442                	ld	s0,16(sp)
    80005996:	64a2                	ld	s1,8(sp)
    80005998:	6105                	addi	sp,sp,32
    8000599a:	8082                	ret
      p->ofile[fd] = f;
    8000599c:	01a50793          	addi	a5,a0,26
    800059a0:	078e                	slli	a5,a5,0x3
    800059a2:	963e                	add	a2,a2,a5
    800059a4:	e204                	sd	s1,0(a2)
      return fd;
    800059a6:	b7f5                	j	80005992 <fdalloc+0x28>

00000000800059a8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800059a8:	715d                	addi	sp,sp,-80
    800059aa:	e486                	sd	ra,72(sp)
    800059ac:	e0a2                	sd	s0,64(sp)
    800059ae:	fc26                	sd	s1,56(sp)
    800059b0:	f84a                	sd	s2,48(sp)
    800059b2:	f44e                	sd	s3,40(sp)
    800059b4:	ec56                	sd	s5,24(sp)
    800059b6:	e85a                	sd	s6,16(sp)
    800059b8:	0880                	addi	s0,sp,80
    800059ba:	8b2e                	mv	s6,a1
    800059bc:	89b2                	mv	s3,a2
    800059be:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800059c0:	fb040593          	addi	a1,s0,-80
    800059c4:	a19fe0ef          	jal	800043dc <nameiparent>
    800059c8:	84aa                	mv	s1,a0
    800059ca:	10050a63          	beqz	a0,80005ade <create+0x136>
    return 0;

  ilock(dp);
    800059ce:	f71fd0ef          	jal	8000393e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800059d2:	4601                	li	a2,0
    800059d4:	fb040593          	addi	a1,s0,-80
    800059d8:	8526                	mv	a0,s1
    800059da:	e5afe0ef          	jal	80004034 <dirlookup>
    800059de:	8aaa                	mv	s5,a0
    800059e0:	c129                	beqz	a0,80005a22 <create+0x7a>
    iunlockput(dp);
    800059e2:	8526                	mv	a0,s1
    800059e4:	a36fe0ef          	jal	80003c1a <iunlockput>
    ilock(ip);
    800059e8:	8556                	mv	a0,s5
    800059ea:	f55fd0ef          	jal	8000393e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800059ee:	4789                	li	a5,2
    800059f0:	02fb1463          	bne	s6,a5,80005a18 <create+0x70>
    800059f4:	044ad783          	lhu	a5,68(s5)
    800059f8:	37f9                	addiw	a5,a5,-2
    800059fa:	17c2                	slli	a5,a5,0x30
    800059fc:	93c1                	srli	a5,a5,0x30
    800059fe:	4705                	li	a4,1
    80005a00:	00f76c63          	bltu	a4,a5,80005a18 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005a04:	8556                	mv	a0,s5
    80005a06:	60a6                	ld	ra,72(sp)
    80005a08:	6406                	ld	s0,64(sp)
    80005a0a:	74e2                	ld	s1,56(sp)
    80005a0c:	7942                	ld	s2,48(sp)
    80005a0e:	79a2                	ld	s3,40(sp)
    80005a10:	6ae2                	ld	s5,24(sp)
    80005a12:	6b42                	ld	s6,16(sp)
    80005a14:	6161                	addi	sp,sp,80
    80005a16:	8082                	ret
    iunlockput(ip);
    80005a18:	8556                	mv	a0,s5
    80005a1a:	a00fe0ef          	jal	80003c1a <iunlockput>
    return 0;
    80005a1e:	4a81                	li	s5,0
    80005a20:	b7d5                	j	80005a04 <create+0x5c>
    80005a22:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005a24:	85da                	mv	a1,s6
    80005a26:	4088                	lw	a0,0(s1)
    80005a28:	d41fd0ef          	jal	80003768 <ialloc>
    80005a2c:	8a2a                	mv	s4,a0
    80005a2e:	cd15                	beqz	a0,80005a6a <create+0xc2>
  ilock(ip);
    80005a30:	f0ffd0ef          	jal	8000393e <ilock>
  ip->major = major;
    80005a34:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005a38:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005a3c:	4905                	li	s2,1
    80005a3e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005a42:	8552                	mv	a0,s4
    80005a44:	e03fd0ef          	jal	80003846 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005a48:	032b0763          	beq	s6,s2,80005a76 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80005a4c:	004a2603          	lw	a2,4(s4)
    80005a50:	fb040593          	addi	a1,s0,-80
    80005a54:	8526                	mv	a0,s1
    80005a56:	877fe0ef          	jal	800042cc <dirlink>
    80005a5a:	06054563          	bltz	a0,80005ac4 <create+0x11c>
  iunlockput(dp);
    80005a5e:	8526                	mv	a0,s1
    80005a60:	9bafe0ef          	jal	80003c1a <iunlockput>
  return ip;
    80005a64:	8ad2                	mv	s5,s4
    80005a66:	7a02                	ld	s4,32(sp)
    80005a68:	bf71                	j	80005a04 <create+0x5c>
    iunlockput(dp);
    80005a6a:	8526                	mv	a0,s1
    80005a6c:	9aefe0ef          	jal	80003c1a <iunlockput>
    return 0;
    80005a70:	8ad2                	mv	s5,s4
    80005a72:	7a02                	ld	s4,32(sp)
    80005a74:	bf41                	j	80005a04 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005a76:	004a2603          	lw	a2,4(s4)
    80005a7a:	00004597          	auipc	a1,0x4
    80005a7e:	25658593          	addi	a1,a1,598 # 80009cd0 <etext+0xcd0>
    80005a82:	8552                	mv	a0,s4
    80005a84:	849fe0ef          	jal	800042cc <dirlink>
    80005a88:	02054e63          	bltz	a0,80005ac4 <create+0x11c>
    80005a8c:	40d0                	lw	a2,4(s1)
    80005a8e:	00004597          	auipc	a1,0x4
    80005a92:	24a58593          	addi	a1,a1,586 # 80009cd8 <etext+0xcd8>
    80005a96:	8552                	mv	a0,s4
    80005a98:	835fe0ef          	jal	800042cc <dirlink>
    80005a9c:	02054463          	bltz	a0,80005ac4 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005aa0:	004a2603          	lw	a2,4(s4)
    80005aa4:	fb040593          	addi	a1,s0,-80
    80005aa8:	8526                	mv	a0,s1
    80005aaa:	823fe0ef          	jal	800042cc <dirlink>
    80005aae:	00054b63          	bltz	a0,80005ac4 <create+0x11c>
    dp->nlink++;  // for ".."
    80005ab2:	04a4d783          	lhu	a5,74(s1)
    80005ab6:	2785                	addiw	a5,a5,1
    80005ab8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005abc:	8526                	mv	a0,s1
    80005abe:	d89fd0ef          	jal	80003846 <iupdate>
    80005ac2:	bf71                	j	80005a5e <create+0xb6>
  ip->nlink = 0;
    80005ac4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005ac8:	8552                	mv	a0,s4
    80005aca:	d7dfd0ef          	jal	80003846 <iupdate>
  iunlockput(ip);
    80005ace:	8552                	mv	a0,s4
    80005ad0:	94afe0ef          	jal	80003c1a <iunlockput>
  iunlockput(dp);
    80005ad4:	8526                	mv	a0,s1
    80005ad6:	944fe0ef          	jal	80003c1a <iunlockput>
  return 0;
    80005ada:	7a02                	ld	s4,32(sp)
    80005adc:	b725                	j	80005a04 <create+0x5c>
    return 0;
    80005ade:	8aaa                	mv	s5,a0
    80005ae0:	b715                	j	80005a04 <create+0x5c>

0000000080005ae2 <sys_dup>:
{
    80005ae2:	7179                	addi	sp,sp,-48
    80005ae4:	f406                	sd	ra,40(sp)
    80005ae6:	f022                	sd	s0,32(sp)
    80005ae8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005aea:	fd840613          	addi	a2,s0,-40
    80005aee:	4581                	li	a1,0
    80005af0:	4501                	li	a0,0
    80005af2:	e21ff0ef          	jal	80005912 <argfd>
    return -1;
    80005af6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005af8:	02054363          	bltz	a0,80005b1e <sys_dup+0x3c>
    80005afc:	ec26                	sd	s1,24(sp)
    80005afe:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005b00:	fd843903          	ld	s2,-40(s0)
    80005b04:	854a                	mv	a0,s2
    80005b06:	e65ff0ef          	jal	8000596a <fdalloc>
    80005b0a:	84aa                	mv	s1,a0
    return -1;
    80005b0c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005b0e:	00054d63          	bltz	a0,80005b28 <sys_dup+0x46>
  filedup(f);
    80005b12:	854a                	mv	a0,s2
    80005b14:	bbaff0ef          	jal	80004ece <filedup>
  return fd;
    80005b18:	87a6                	mv	a5,s1
    80005b1a:	64e2                	ld	s1,24(sp)
    80005b1c:	6942                	ld	s2,16(sp)
}
    80005b1e:	853e                	mv	a0,a5
    80005b20:	70a2                	ld	ra,40(sp)
    80005b22:	7402                	ld	s0,32(sp)
    80005b24:	6145                	addi	sp,sp,48
    80005b26:	8082                	ret
    80005b28:	64e2                	ld	s1,24(sp)
    80005b2a:	6942                	ld	s2,16(sp)
    80005b2c:	bfcd                	j	80005b1e <sys_dup+0x3c>

0000000080005b2e <sys_read>:
{
    80005b2e:	7179                	addi	sp,sp,-48
    80005b30:	f406                	sd	ra,40(sp)
    80005b32:	f022                	sd	s0,32(sp)
    80005b34:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005b36:	fd840593          	addi	a1,s0,-40
    80005b3a:	4505                	li	a0,1
    80005b3c:	cfdfc0ef          	jal	80002838 <argaddr>
  argint(2, &n);
    80005b40:	fe440593          	addi	a1,s0,-28
    80005b44:	4509                	li	a0,2
    80005b46:	cd7fc0ef          	jal	8000281c <argint>
  if(argfd(0, 0, &f) < 0)
    80005b4a:	fe840613          	addi	a2,s0,-24
    80005b4e:	4581                	li	a1,0
    80005b50:	4501                	li	a0,0
    80005b52:	dc1ff0ef          	jal	80005912 <argfd>
    80005b56:	87aa                	mv	a5,a0
    return -1;
    80005b58:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b5a:	0007ca63          	bltz	a5,80005b6e <sys_read+0x40>
  return fileread(f, p, n);
    80005b5e:	fe442603          	lw	a2,-28(s0)
    80005b62:	fd843583          	ld	a1,-40(s0)
    80005b66:	fe843503          	ld	a0,-24(s0)
    80005b6a:	cfeff0ef          	jal	80005068 <fileread>
}
    80005b6e:	70a2                	ld	ra,40(sp)
    80005b70:	7402                	ld	s0,32(sp)
    80005b72:	6145                	addi	sp,sp,48
    80005b74:	8082                	ret

0000000080005b76 <sys_write>:
{
    80005b76:	7179                	addi	sp,sp,-48
    80005b78:	f406                	sd	ra,40(sp)
    80005b7a:	f022                	sd	s0,32(sp)
    80005b7c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005b7e:	fd840593          	addi	a1,s0,-40
    80005b82:	4505                	li	a0,1
    80005b84:	cb5fc0ef          	jal	80002838 <argaddr>
  argint(2, &n);
    80005b88:	fe440593          	addi	a1,s0,-28
    80005b8c:	4509                	li	a0,2
    80005b8e:	c8ffc0ef          	jal	8000281c <argint>
  if(argfd(0, 0, &f) < 0)
    80005b92:	fe840613          	addi	a2,s0,-24
    80005b96:	4581                	li	a1,0
    80005b98:	4501                	li	a0,0
    80005b9a:	d79ff0ef          	jal	80005912 <argfd>
    80005b9e:	87aa                	mv	a5,a0
    return -1;
    80005ba0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005ba2:	0007ca63          	bltz	a5,80005bb6 <sys_write+0x40>
  return filewrite(f, p, n);
    80005ba6:	fe442603          	lw	a2,-28(s0)
    80005baa:	fd843583          	ld	a1,-40(s0)
    80005bae:	fe843503          	ld	a0,-24(s0)
    80005bb2:	d96ff0ef          	jal	80005148 <filewrite>
}
    80005bb6:	70a2                	ld	ra,40(sp)
    80005bb8:	7402                	ld	s0,32(sp)
    80005bba:	6145                	addi	sp,sp,48
    80005bbc:	8082                	ret

0000000080005bbe <sys_close>:
{
    80005bbe:	1101                	addi	sp,sp,-32
    80005bc0:	ec06                	sd	ra,24(sp)
    80005bc2:	e822                	sd	s0,16(sp)
    80005bc4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005bc6:	fe040613          	addi	a2,s0,-32
    80005bca:	fec40593          	addi	a1,s0,-20
    80005bce:	4501                	li	a0,0
    80005bd0:	d43ff0ef          	jal	80005912 <argfd>
    return -1;
    80005bd4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005bd6:	02054063          	bltz	a0,80005bf6 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80005bda:	d2ffb0ef          	jal	80001908 <myproc>
    80005bde:	fec42783          	lw	a5,-20(s0)
    80005be2:	07e9                	addi	a5,a5,26
    80005be4:	078e                	slli	a5,a5,0x3
    80005be6:	953e                	add	a0,a0,a5
    80005be8:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005bec:	fe043503          	ld	a0,-32(s0)
    80005bf0:	b3eff0ef          	jal	80004f2e <fileclose>
  return 0;
    80005bf4:	4781                	li	a5,0
}
    80005bf6:	853e                	mv	a0,a5
    80005bf8:	60e2                	ld	ra,24(sp)
    80005bfa:	6442                	ld	s0,16(sp)
    80005bfc:	6105                	addi	sp,sp,32
    80005bfe:	8082                	ret

0000000080005c00 <sys_fstat>:
{
    80005c00:	1101                	addi	sp,sp,-32
    80005c02:	ec06                	sd	ra,24(sp)
    80005c04:	e822                	sd	s0,16(sp)
    80005c06:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005c08:	fe040593          	addi	a1,s0,-32
    80005c0c:	4505                	li	a0,1
    80005c0e:	c2bfc0ef          	jal	80002838 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005c12:	fe840613          	addi	a2,s0,-24
    80005c16:	4581                	li	a1,0
    80005c18:	4501                	li	a0,0
    80005c1a:	cf9ff0ef          	jal	80005912 <argfd>
    80005c1e:	87aa                	mv	a5,a0
    return -1;
    80005c20:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c22:	0007c863          	bltz	a5,80005c32 <sys_fstat+0x32>
  return filestat(f, st);
    80005c26:	fe043583          	ld	a1,-32(s0)
    80005c2a:	fe843503          	ld	a0,-24(s0)
    80005c2e:	bdcff0ef          	jal	8000500a <filestat>
}
    80005c32:	60e2                	ld	ra,24(sp)
    80005c34:	6442                	ld	s0,16(sp)
    80005c36:	6105                	addi	sp,sp,32
    80005c38:	8082                	ret

0000000080005c3a <sys_link>:
{
    80005c3a:	7169                	addi	sp,sp,-304
    80005c3c:	f606                	sd	ra,296(sp)
    80005c3e:	f222                	sd	s0,288(sp)
    80005c40:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c42:	08000613          	li	a2,128
    80005c46:	ed040593          	addi	a1,s0,-304
    80005c4a:	4501                	li	a0,0
    80005c4c:	c09fc0ef          	jal	80002854 <argstr>
    return -1;
    80005c50:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c52:	0c054e63          	bltz	a0,80005d2e <sys_link+0xf4>
    80005c56:	08000613          	li	a2,128
    80005c5a:	f5040593          	addi	a1,s0,-176
    80005c5e:	4505                	li	a0,1
    80005c60:	bf5fc0ef          	jal	80002854 <argstr>
    return -1;
    80005c64:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c66:	0c054463          	bltz	a0,80005d2e <sys_link+0xf4>
    80005c6a:	ee26                	sd	s1,280(sp)
  begin_op();
    80005c6c:	ba1fe0ef          	jal	8000480c <begin_op>
  if((ip = namei(old)) == 0){
    80005c70:	ed040513          	addi	a0,s0,-304
    80005c74:	f4efe0ef          	jal	800043c2 <namei>
    80005c78:	84aa                	mv	s1,a0
    80005c7a:	c53d                	beqz	a0,80005ce8 <sys_link+0xae>
  ilock(ip);
    80005c7c:	cc3fd0ef          	jal	8000393e <ilock>
  if(ip->type == T_DIR){
    80005c80:	04449703          	lh	a4,68(s1)
    80005c84:	4785                	li	a5,1
    80005c86:	06f70663          	beq	a4,a5,80005cf2 <sys_link+0xb8>
    80005c8a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005c8c:	04a4d783          	lhu	a5,74(s1)
    80005c90:	2785                	addiw	a5,a5,1
    80005c92:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c96:	8526                	mv	a0,s1
    80005c98:	baffd0ef          	jal	80003846 <iupdate>
  iunlock(ip);
    80005c9c:	8526                	mv	a0,s1
    80005c9e:	d93fd0ef          	jal	80003a30 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005ca2:	fd040593          	addi	a1,s0,-48
    80005ca6:	f5040513          	addi	a0,s0,-176
    80005caa:	f32fe0ef          	jal	800043dc <nameiparent>
    80005cae:	892a                	mv	s2,a0
    80005cb0:	cd21                	beqz	a0,80005d08 <sys_link+0xce>
  ilock(dp);
    80005cb2:	c8dfd0ef          	jal	8000393e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005cb6:	00092703          	lw	a4,0(s2)
    80005cba:	409c                	lw	a5,0(s1)
    80005cbc:	04f71363          	bne	a4,a5,80005d02 <sys_link+0xc8>
    80005cc0:	40d0                	lw	a2,4(s1)
    80005cc2:	fd040593          	addi	a1,s0,-48
    80005cc6:	854a                	mv	a0,s2
    80005cc8:	e04fe0ef          	jal	800042cc <dirlink>
    80005ccc:	02054b63          	bltz	a0,80005d02 <sys_link+0xc8>
  iunlockput(dp);
    80005cd0:	854a                	mv	a0,s2
    80005cd2:	f49fd0ef          	jal	80003c1a <iunlockput>
  iput(ip);
    80005cd6:	8526                	mv	a0,s1
    80005cd8:	e77fd0ef          	jal	80003b4e <iput>
  end_op();
    80005cdc:	c4ffe0ef          	jal	8000492a <end_op>
  return 0;
    80005ce0:	4781                	li	a5,0
    80005ce2:	64f2                	ld	s1,280(sp)
    80005ce4:	6952                	ld	s2,272(sp)
    80005ce6:	a0a1                	j	80005d2e <sys_link+0xf4>
    end_op();
    80005ce8:	c43fe0ef          	jal	8000492a <end_op>
    return -1;
    80005cec:	57fd                	li	a5,-1
    80005cee:	64f2                	ld	s1,280(sp)
    80005cf0:	a83d                	j	80005d2e <sys_link+0xf4>
    iunlockput(ip);
    80005cf2:	8526                	mv	a0,s1
    80005cf4:	f27fd0ef          	jal	80003c1a <iunlockput>
    end_op();
    80005cf8:	c33fe0ef          	jal	8000492a <end_op>
    return -1;
    80005cfc:	57fd                	li	a5,-1
    80005cfe:	64f2                	ld	s1,280(sp)
    80005d00:	a03d                	j	80005d2e <sys_link+0xf4>
    iunlockput(dp);
    80005d02:	854a                	mv	a0,s2
    80005d04:	f17fd0ef          	jal	80003c1a <iunlockput>
  ilock(ip);
    80005d08:	8526                	mv	a0,s1
    80005d0a:	c35fd0ef          	jal	8000393e <ilock>
  ip->nlink--;
    80005d0e:	04a4d783          	lhu	a5,74(s1)
    80005d12:	37fd                	addiw	a5,a5,-1
    80005d14:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005d18:	8526                	mv	a0,s1
    80005d1a:	b2dfd0ef          	jal	80003846 <iupdate>
  iunlockput(ip);
    80005d1e:	8526                	mv	a0,s1
    80005d20:	efbfd0ef          	jal	80003c1a <iunlockput>
  end_op();
    80005d24:	c07fe0ef          	jal	8000492a <end_op>
  return -1;
    80005d28:	57fd                	li	a5,-1
    80005d2a:	64f2                	ld	s1,280(sp)
    80005d2c:	6952                	ld	s2,272(sp)
}
    80005d2e:	853e                	mv	a0,a5
    80005d30:	70b2                	ld	ra,296(sp)
    80005d32:	7412                	ld	s0,288(sp)
    80005d34:	6155                	addi	sp,sp,304
    80005d36:	8082                	ret

0000000080005d38 <sys_unlink>:
{
    80005d38:	7151                	addi	sp,sp,-240
    80005d3a:	f586                	sd	ra,232(sp)
    80005d3c:	f1a2                	sd	s0,224(sp)
    80005d3e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005d40:	08000613          	li	a2,128
    80005d44:	f3040593          	addi	a1,s0,-208
    80005d48:	4501                	li	a0,0
    80005d4a:	b0bfc0ef          	jal	80002854 <argstr>
    80005d4e:	16054063          	bltz	a0,80005eae <sys_unlink+0x176>
    80005d52:	eda6                	sd	s1,216(sp)
  begin_op();
    80005d54:	ab9fe0ef          	jal	8000480c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005d58:	fb040593          	addi	a1,s0,-80
    80005d5c:	f3040513          	addi	a0,s0,-208
    80005d60:	e7cfe0ef          	jal	800043dc <nameiparent>
    80005d64:	84aa                	mv	s1,a0
    80005d66:	c945                	beqz	a0,80005e16 <sys_unlink+0xde>
  ilock(dp);
    80005d68:	bd7fd0ef          	jal	8000393e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005d6c:	00004597          	auipc	a1,0x4
    80005d70:	f6458593          	addi	a1,a1,-156 # 80009cd0 <etext+0xcd0>
    80005d74:	fb040513          	addi	a0,s0,-80
    80005d78:	aa6fe0ef          	jal	8000401e <namecmp>
    80005d7c:	10050e63          	beqz	a0,80005e98 <sys_unlink+0x160>
    80005d80:	00004597          	auipc	a1,0x4
    80005d84:	f5858593          	addi	a1,a1,-168 # 80009cd8 <etext+0xcd8>
    80005d88:	fb040513          	addi	a0,s0,-80
    80005d8c:	a92fe0ef          	jal	8000401e <namecmp>
    80005d90:	10050463          	beqz	a0,80005e98 <sys_unlink+0x160>
    80005d94:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005d96:	f2c40613          	addi	a2,s0,-212
    80005d9a:	fb040593          	addi	a1,s0,-80
    80005d9e:	8526                	mv	a0,s1
    80005da0:	a94fe0ef          	jal	80004034 <dirlookup>
    80005da4:	892a                	mv	s2,a0
    80005da6:	0e050863          	beqz	a0,80005e96 <sys_unlink+0x15e>
  ilock(ip);
    80005daa:	b95fd0ef          	jal	8000393e <ilock>
  if(ip->nlink < 1)
    80005dae:	04a91783          	lh	a5,74(s2)
    80005db2:	06f05763          	blez	a5,80005e20 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005db6:	04491703          	lh	a4,68(s2)
    80005dba:	4785                	li	a5,1
    80005dbc:	06f70963          	beq	a4,a5,80005e2e <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005dc0:	4641                	li	a2,16
    80005dc2:	4581                	li	a1,0
    80005dc4:	fc040513          	addi	a0,s0,-64
    80005dc8:	f0dfa0ef          	jal	80000cd4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005dcc:	4741                	li	a4,16
    80005dce:	f2c42683          	lw	a3,-212(s0)
    80005dd2:	fc040613          	addi	a2,s0,-64
    80005dd6:	4581                	li	a1,0
    80005dd8:	8526                	mv	a0,s1
    80005dda:	8f6fe0ef          	jal	80003ed0 <writei>
    80005dde:	47c1                	li	a5,16
    80005de0:	08f51b63          	bne	a0,a5,80005e76 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005de4:	04491703          	lh	a4,68(s2)
    80005de8:	4785                	li	a5,1
    80005dea:	08f70d63          	beq	a4,a5,80005e84 <sys_unlink+0x14c>
  iunlockput(dp);
    80005dee:	8526                	mv	a0,s1
    80005df0:	e2bfd0ef          	jal	80003c1a <iunlockput>
  ip->nlink--;
    80005df4:	04a95783          	lhu	a5,74(s2)
    80005df8:	37fd                	addiw	a5,a5,-1
    80005dfa:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005dfe:	854a                	mv	a0,s2
    80005e00:	a47fd0ef          	jal	80003846 <iupdate>
  iunlockput(ip);
    80005e04:	854a                	mv	a0,s2
    80005e06:	e15fd0ef          	jal	80003c1a <iunlockput>
  end_op();
    80005e0a:	b21fe0ef          	jal	8000492a <end_op>
  return 0;
    80005e0e:	4501                	li	a0,0
    80005e10:	64ee                	ld	s1,216(sp)
    80005e12:	694e                	ld	s2,208(sp)
    80005e14:	a849                	j	80005ea6 <sys_unlink+0x16e>
    end_op();
    80005e16:	b15fe0ef          	jal	8000492a <end_op>
    return -1;
    80005e1a:	557d                	li	a0,-1
    80005e1c:	64ee                	ld	s1,216(sp)
    80005e1e:	a061                	j	80005ea6 <sys_unlink+0x16e>
    80005e20:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005e22:	00004517          	auipc	a0,0x4
    80005e26:	ebe50513          	addi	a0,a0,-322 # 80009ce0 <etext+0xce0>
    80005e2a:	9e9fa0ef          	jal	80000812 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e2e:	04c92703          	lw	a4,76(s2)
    80005e32:	02000793          	li	a5,32
    80005e36:	f8e7f5e3          	bgeu	a5,a4,80005dc0 <sys_unlink+0x88>
    80005e3a:	e5ce                	sd	s3,200(sp)
    80005e3c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e40:	4741                	li	a4,16
    80005e42:	86ce                	mv	a3,s3
    80005e44:	f1840613          	addi	a2,s0,-232
    80005e48:	4581                	li	a1,0
    80005e4a:	854a                	mv	a0,s2
    80005e4c:	f55fd0ef          	jal	80003da0 <readi>
    80005e50:	47c1                	li	a5,16
    80005e52:	00f51c63          	bne	a0,a5,80005e6a <sys_unlink+0x132>
    if(de.inum != 0)
    80005e56:	f1845783          	lhu	a5,-232(s0)
    80005e5a:	efa1                	bnez	a5,80005eb2 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e5c:	29c1                	addiw	s3,s3,16
    80005e5e:	04c92783          	lw	a5,76(s2)
    80005e62:	fcf9efe3          	bltu	s3,a5,80005e40 <sys_unlink+0x108>
    80005e66:	69ae                	ld	s3,200(sp)
    80005e68:	bfa1                	j	80005dc0 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005e6a:	00004517          	auipc	a0,0x4
    80005e6e:	e8e50513          	addi	a0,a0,-370 # 80009cf8 <etext+0xcf8>
    80005e72:	9a1fa0ef          	jal	80000812 <panic>
    80005e76:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005e78:	00004517          	auipc	a0,0x4
    80005e7c:	e9850513          	addi	a0,a0,-360 # 80009d10 <etext+0xd10>
    80005e80:	993fa0ef          	jal	80000812 <panic>
    dp->nlink--;
    80005e84:	04a4d783          	lhu	a5,74(s1)
    80005e88:	37fd                	addiw	a5,a5,-1
    80005e8a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005e8e:	8526                	mv	a0,s1
    80005e90:	9b7fd0ef          	jal	80003846 <iupdate>
    80005e94:	bfa9                	j	80005dee <sys_unlink+0xb6>
    80005e96:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005e98:	8526                	mv	a0,s1
    80005e9a:	d81fd0ef          	jal	80003c1a <iunlockput>
  end_op();
    80005e9e:	a8dfe0ef          	jal	8000492a <end_op>
  return -1;
    80005ea2:	557d                	li	a0,-1
    80005ea4:	64ee                	ld	s1,216(sp)
}
    80005ea6:	70ae                	ld	ra,232(sp)
    80005ea8:	740e                	ld	s0,224(sp)
    80005eaa:	616d                	addi	sp,sp,240
    80005eac:	8082                	ret
    return -1;
    80005eae:	557d                	li	a0,-1
    80005eb0:	bfdd                	j	80005ea6 <sys_unlink+0x16e>
    iunlockput(ip);
    80005eb2:	854a                	mv	a0,s2
    80005eb4:	d67fd0ef          	jal	80003c1a <iunlockput>
    goto bad;
    80005eb8:	694e                	ld	s2,208(sp)
    80005eba:	69ae                	ld	s3,200(sp)
    80005ebc:	bff1                	j	80005e98 <sys_unlink+0x160>

0000000080005ebe <sys_open>:

uint64
sys_open(void)
{
    80005ebe:	7131                	addi	sp,sp,-192
    80005ec0:	fd06                	sd	ra,184(sp)
    80005ec2:	f922                	sd	s0,176(sp)
    80005ec4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005ec6:	f4c40593          	addi	a1,s0,-180
    80005eca:	4505                	li	a0,1
    80005ecc:	951fc0ef          	jal	8000281c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ed0:	08000613          	li	a2,128
    80005ed4:	f5040593          	addi	a1,s0,-176
    80005ed8:	4501                	li	a0,0
    80005eda:	97bfc0ef          	jal	80002854 <argstr>
    80005ede:	87aa                	mv	a5,a0
    return -1;
    80005ee0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ee2:	0a07c263          	bltz	a5,80005f86 <sys_open+0xc8>
    80005ee6:	f526                	sd	s1,168(sp)

  begin_op();
    80005ee8:	925fe0ef          	jal	8000480c <begin_op>

  if(omode & O_CREATE){
    80005eec:	f4c42783          	lw	a5,-180(s0)
    80005ef0:	2007f793          	andi	a5,a5,512
    80005ef4:	c3d5                	beqz	a5,80005f98 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005ef6:	4681                	li	a3,0
    80005ef8:	4601                	li	a2,0
    80005efa:	4589                	li	a1,2
    80005efc:	f5040513          	addi	a0,s0,-176
    80005f00:	aa9ff0ef          	jal	800059a8 <create>
    80005f04:	84aa                	mv	s1,a0
    if(ip == 0){
    80005f06:	c541                	beqz	a0,80005f8e <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005f08:	04449703          	lh	a4,68(s1)
    80005f0c:	478d                	li	a5,3
    80005f0e:	00f71763          	bne	a4,a5,80005f1c <sys_open+0x5e>
    80005f12:	0464d703          	lhu	a4,70(s1)
    80005f16:	47a5                	li	a5,9
    80005f18:	0ae7ed63          	bltu	a5,a4,80005fd2 <sys_open+0x114>
    80005f1c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005f1e:	f39fe0ef          	jal	80004e56 <filealloc>
    80005f22:	892a                	mv	s2,a0
    80005f24:	c179                	beqz	a0,80005fea <sys_open+0x12c>
    80005f26:	ed4e                	sd	s3,152(sp)
    80005f28:	a43ff0ef          	jal	8000596a <fdalloc>
    80005f2c:	89aa                	mv	s3,a0
    80005f2e:	0a054a63          	bltz	a0,80005fe2 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005f32:	04449703          	lh	a4,68(s1)
    80005f36:	478d                	li	a5,3
    80005f38:	0cf70263          	beq	a4,a5,80005ffc <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005f3c:	4789                	li	a5,2
    80005f3e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005f42:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005f46:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005f4a:	f4c42783          	lw	a5,-180(s0)
    80005f4e:	0017c713          	xori	a4,a5,1
    80005f52:	8b05                	andi	a4,a4,1
    80005f54:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005f58:	0037f713          	andi	a4,a5,3
    80005f5c:	00e03733          	snez	a4,a4
    80005f60:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005f64:	4007f793          	andi	a5,a5,1024
    80005f68:	c791                	beqz	a5,80005f74 <sys_open+0xb6>
    80005f6a:	04449703          	lh	a4,68(s1)
    80005f6e:	4789                	li	a5,2
    80005f70:	08f70d63          	beq	a4,a5,8000600a <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005f74:	8526                	mv	a0,s1
    80005f76:	abbfd0ef          	jal	80003a30 <iunlock>
  end_op();
    80005f7a:	9b1fe0ef          	jal	8000492a <end_op>

  return fd;
    80005f7e:	854e                	mv	a0,s3
    80005f80:	74aa                	ld	s1,168(sp)
    80005f82:	790a                	ld	s2,160(sp)
    80005f84:	69ea                	ld	s3,152(sp)
}
    80005f86:	70ea                	ld	ra,184(sp)
    80005f88:	744a                	ld	s0,176(sp)
    80005f8a:	6129                	addi	sp,sp,192
    80005f8c:	8082                	ret
      end_op();
    80005f8e:	99dfe0ef          	jal	8000492a <end_op>
      return -1;
    80005f92:	557d                	li	a0,-1
    80005f94:	74aa                	ld	s1,168(sp)
    80005f96:	bfc5                	j	80005f86 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005f98:	f5040513          	addi	a0,s0,-176
    80005f9c:	c26fe0ef          	jal	800043c2 <namei>
    80005fa0:	84aa                	mv	s1,a0
    80005fa2:	c11d                	beqz	a0,80005fc8 <sys_open+0x10a>
    ilock(ip);
    80005fa4:	99bfd0ef          	jal	8000393e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005fa8:	04449703          	lh	a4,68(s1)
    80005fac:	4785                	li	a5,1
    80005fae:	f4f71de3          	bne	a4,a5,80005f08 <sys_open+0x4a>
    80005fb2:	f4c42783          	lw	a5,-180(s0)
    80005fb6:	d3bd                	beqz	a5,80005f1c <sys_open+0x5e>
      iunlockput(ip);
    80005fb8:	8526                	mv	a0,s1
    80005fba:	c61fd0ef          	jal	80003c1a <iunlockput>
      end_op();
    80005fbe:	96dfe0ef          	jal	8000492a <end_op>
      return -1;
    80005fc2:	557d                	li	a0,-1
    80005fc4:	74aa                	ld	s1,168(sp)
    80005fc6:	b7c1                	j	80005f86 <sys_open+0xc8>
      end_op();
    80005fc8:	963fe0ef          	jal	8000492a <end_op>
      return -1;
    80005fcc:	557d                	li	a0,-1
    80005fce:	74aa                	ld	s1,168(sp)
    80005fd0:	bf5d                	j	80005f86 <sys_open+0xc8>
    iunlockput(ip);
    80005fd2:	8526                	mv	a0,s1
    80005fd4:	c47fd0ef          	jal	80003c1a <iunlockput>
    end_op();
    80005fd8:	953fe0ef          	jal	8000492a <end_op>
    return -1;
    80005fdc:	557d                	li	a0,-1
    80005fde:	74aa                	ld	s1,168(sp)
    80005fe0:	b75d                	j	80005f86 <sys_open+0xc8>
      fileclose(f);
    80005fe2:	854a                	mv	a0,s2
    80005fe4:	f4bfe0ef          	jal	80004f2e <fileclose>
    80005fe8:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005fea:	8526                	mv	a0,s1
    80005fec:	c2ffd0ef          	jal	80003c1a <iunlockput>
    end_op();
    80005ff0:	93bfe0ef          	jal	8000492a <end_op>
    return -1;
    80005ff4:	557d                	li	a0,-1
    80005ff6:	74aa                	ld	s1,168(sp)
    80005ff8:	790a                	ld	s2,160(sp)
    80005ffa:	b771                	j	80005f86 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005ffc:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80006000:	04649783          	lh	a5,70(s1)
    80006004:	02f91223          	sh	a5,36(s2)
    80006008:	bf3d                	j	80005f46 <sys_open+0x88>
    itrunc(ip);
    8000600a:	8526                	mv	a0,s1
    8000600c:	a87fd0ef          	jal	80003a92 <itrunc>
    80006010:	b795                	j	80005f74 <sys_open+0xb6>

0000000080006012 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006012:	7175                	addi	sp,sp,-144
    80006014:	e506                	sd	ra,136(sp)
    80006016:	e122                	sd	s0,128(sp)
    80006018:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000601a:	ff2fe0ef          	jal	8000480c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000601e:	08000613          	li	a2,128
    80006022:	f7040593          	addi	a1,s0,-144
    80006026:	4501                	li	a0,0
    80006028:	82dfc0ef          	jal	80002854 <argstr>
    8000602c:	02054363          	bltz	a0,80006052 <sys_mkdir+0x40>
    80006030:	4681                	li	a3,0
    80006032:	4601                	li	a2,0
    80006034:	4585                	li	a1,1
    80006036:	f7040513          	addi	a0,s0,-144
    8000603a:	96fff0ef          	jal	800059a8 <create>
    8000603e:	c911                	beqz	a0,80006052 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006040:	bdbfd0ef          	jal	80003c1a <iunlockput>
  end_op();
    80006044:	8e7fe0ef          	jal	8000492a <end_op>
  return 0;
    80006048:	4501                	li	a0,0
}
    8000604a:	60aa                	ld	ra,136(sp)
    8000604c:	640a                	ld	s0,128(sp)
    8000604e:	6149                	addi	sp,sp,144
    80006050:	8082                	ret
    end_op();
    80006052:	8d9fe0ef          	jal	8000492a <end_op>
    return -1;
    80006056:	557d                	li	a0,-1
    80006058:	bfcd                	j	8000604a <sys_mkdir+0x38>

000000008000605a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000605a:	7135                	addi	sp,sp,-160
    8000605c:	ed06                	sd	ra,152(sp)
    8000605e:	e922                	sd	s0,144(sp)
    80006060:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006062:	faafe0ef          	jal	8000480c <begin_op>
  argint(1, &major);
    80006066:	f6c40593          	addi	a1,s0,-148
    8000606a:	4505                	li	a0,1
    8000606c:	fb0fc0ef          	jal	8000281c <argint>
  argint(2, &minor);
    80006070:	f6840593          	addi	a1,s0,-152
    80006074:	4509                	li	a0,2
    80006076:	fa6fc0ef          	jal	8000281c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000607a:	08000613          	li	a2,128
    8000607e:	f7040593          	addi	a1,s0,-144
    80006082:	4501                	li	a0,0
    80006084:	fd0fc0ef          	jal	80002854 <argstr>
    80006088:	02054563          	bltz	a0,800060b2 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000608c:	f6841683          	lh	a3,-152(s0)
    80006090:	f6c41603          	lh	a2,-148(s0)
    80006094:	458d                	li	a1,3
    80006096:	f7040513          	addi	a0,s0,-144
    8000609a:	90fff0ef          	jal	800059a8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000609e:	c911                	beqz	a0,800060b2 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800060a0:	b7bfd0ef          	jal	80003c1a <iunlockput>
  end_op();
    800060a4:	887fe0ef          	jal	8000492a <end_op>
  return 0;
    800060a8:	4501                	li	a0,0
}
    800060aa:	60ea                	ld	ra,152(sp)
    800060ac:	644a                	ld	s0,144(sp)
    800060ae:	610d                	addi	sp,sp,160
    800060b0:	8082                	ret
    end_op();
    800060b2:	879fe0ef          	jal	8000492a <end_op>
    return -1;
    800060b6:	557d                	li	a0,-1
    800060b8:	bfcd                	j	800060aa <sys_mknod+0x50>

00000000800060ba <sys_chdir>:

uint64
sys_chdir(void)
{
    800060ba:	7135                	addi	sp,sp,-160
    800060bc:	ed06                	sd	ra,152(sp)
    800060be:	e922                	sd	s0,144(sp)
    800060c0:	e14a                	sd	s2,128(sp)
    800060c2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800060c4:	845fb0ef          	jal	80001908 <myproc>
    800060c8:	892a                	mv	s2,a0
  
  begin_op();
    800060ca:	f42fe0ef          	jal	8000480c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800060ce:	08000613          	li	a2,128
    800060d2:	f6040593          	addi	a1,s0,-160
    800060d6:	4501                	li	a0,0
    800060d8:	f7cfc0ef          	jal	80002854 <argstr>
    800060dc:	04054363          	bltz	a0,80006122 <sys_chdir+0x68>
    800060e0:	e526                	sd	s1,136(sp)
    800060e2:	f6040513          	addi	a0,s0,-160
    800060e6:	adcfe0ef          	jal	800043c2 <namei>
    800060ea:	84aa                	mv	s1,a0
    800060ec:	c915                	beqz	a0,80006120 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800060ee:	851fd0ef          	jal	8000393e <ilock>
  if(ip->type != T_DIR){
    800060f2:	04449703          	lh	a4,68(s1)
    800060f6:	4785                	li	a5,1
    800060f8:	02f71963          	bne	a4,a5,8000612a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800060fc:	8526                	mv	a0,s1
    800060fe:	933fd0ef          	jal	80003a30 <iunlock>
  iput(p->cwd);
    80006102:	15093503          	ld	a0,336(s2)
    80006106:	a49fd0ef          	jal	80003b4e <iput>
  end_op();
    8000610a:	821fe0ef          	jal	8000492a <end_op>
  p->cwd = ip;
    8000610e:	14993823          	sd	s1,336(s2)
  return 0;
    80006112:	4501                	li	a0,0
    80006114:	64aa                	ld	s1,136(sp)
}
    80006116:	60ea                	ld	ra,152(sp)
    80006118:	644a                	ld	s0,144(sp)
    8000611a:	690a                	ld	s2,128(sp)
    8000611c:	610d                	addi	sp,sp,160
    8000611e:	8082                	ret
    80006120:	64aa                	ld	s1,136(sp)
    end_op();
    80006122:	809fe0ef          	jal	8000492a <end_op>
    return -1;
    80006126:	557d                	li	a0,-1
    80006128:	b7fd                	j	80006116 <sys_chdir+0x5c>
    iunlockput(ip);
    8000612a:	8526                	mv	a0,s1
    8000612c:	aeffd0ef          	jal	80003c1a <iunlockput>
    end_op();
    80006130:	ffafe0ef          	jal	8000492a <end_op>
    return -1;
    80006134:	557d                	li	a0,-1
    80006136:	64aa                	ld	s1,136(sp)
    80006138:	bff9                	j	80006116 <sys_chdir+0x5c>

000000008000613a <sys_exec>:

uint64
sys_exec(void)
{
    8000613a:	7121                	addi	sp,sp,-448
    8000613c:	ff06                	sd	ra,440(sp)
    8000613e:	fb22                	sd	s0,432(sp)
    80006140:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006142:	e4840593          	addi	a1,s0,-440
    80006146:	4505                	li	a0,1
    80006148:	ef0fc0ef          	jal	80002838 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000614c:	08000613          	li	a2,128
    80006150:	f5040593          	addi	a1,s0,-176
    80006154:	4501                	li	a0,0
    80006156:	efefc0ef          	jal	80002854 <argstr>
    8000615a:	87aa                	mv	a5,a0
    return -1;
    8000615c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000615e:	0c07c463          	bltz	a5,80006226 <sys_exec+0xec>
    80006162:	f726                	sd	s1,424(sp)
    80006164:	f34a                	sd	s2,416(sp)
    80006166:	ef4e                	sd	s3,408(sp)
    80006168:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000616a:	10000613          	li	a2,256
    8000616e:	4581                	li	a1,0
    80006170:	e5040513          	addi	a0,s0,-432
    80006174:	b61fa0ef          	jal	80000cd4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006178:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000617c:	89a6                	mv	s3,s1
    8000617e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006180:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006184:	00391513          	slli	a0,s2,0x3
    80006188:	e4040593          	addi	a1,s0,-448
    8000618c:	e4843783          	ld	a5,-440(s0)
    80006190:	953e                	add	a0,a0,a5
    80006192:	e00fc0ef          	jal	80002792 <fetchaddr>
    80006196:	02054663          	bltz	a0,800061c2 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    8000619a:	e4043783          	ld	a5,-448(s0)
    8000619e:	c3a9                	beqz	a5,800061e0 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800061a0:	991fa0ef          	jal	80000b30 <kalloc>
    800061a4:	85aa                	mv	a1,a0
    800061a6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800061aa:	cd01                	beqz	a0,800061c2 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800061ac:	6605                	lui	a2,0x1
    800061ae:	e4043503          	ld	a0,-448(s0)
    800061b2:	e2afc0ef          	jal	800027dc <fetchstr>
    800061b6:	00054663          	bltz	a0,800061c2 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800061ba:	0905                	addi	s2,s2,1
    800061bc:	09a1                	addi	s3,s3,8
    800061be:	fd4913e3          	bne	s2,s4,80006184 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800061c2:	f5040913          	addi	s2,s0,-176
    800061c6:	6088                	ld	a0,0(s1)
    800061c8:	c931                	beqz	a0,8000621c <sys_exec+0xe2>
    kfree(argv[i]);
    800061ca:	885fa0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800061ce:	04a1                	addi	s1,s1,8
    800061d0:	ff249be3          	bne	s1,s2,800061c6 <sys_exec+0x8c>
  return -1;
    800061d4:	557d                	li	a0,-1
    800061d6:	74ba                	ld	s1,424(sp)
    800061d8:	791a                	ld	s2,416(sp)
    800061da:	69fa                	ld	s3,408(sp)
    800061dc:	6a5a                	ld	s4,400(sp)
    800061de:	a0a1                	j	80006226 <sys_exec+0xec>
      argv[i] = 0;
    800061e0:	0009079b          	sext.w	a5,s2
    800061e4:	078e                	slli	a5,a5,0x3
    800061e6:	fd078793          	addi	a5,a5,-48
    800061ea:	97a2                	add	a5,a5,s0
    800061ec:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800061f0:	e5040593          	addi	a1,s0,-432
    800061f4:	f5040513          	addi	a0,s0,-176
    800061f8:	ba8ff0ef          	jal	800055a0 <kexec>
    800061fc:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800061fe:	f5040993          	addi	s3,s0,-176
    80006202:	6088                	ld	a0,0(s1)
    80006204:	c511                	beqz	a0,80006210 <sys_exec+0xd6>
    kfree(argv[i]);
    80006206:	849fa0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000620a:	04a1                	addi	s1,s1,8
    8000620c:	ff349be3          	bne	s1,s3,80006202 <sys_exec+0xc8>
  return ret;
    80006210:	854a                	mv	a0,s2
    80006212:	74ba                	ld	s1,424(sp)
    80006214:	791a                	ld	s2,416(sp)
    80006216:	69fa                	ld	s3,408(sp)
    80006218:	6a5a                	ld	s4,400(sp)
    8000621a:	a031                	j	80006226 <sys_exec+0xec>
  return -1;
    8000621c:	557d                	li	a0,-1
    8000621e:	74ba                	ld	s1,424(sp)
    80006220:	791a                	ld	s2,416(sp)
    80006222:	69fa                	ld	s3,408(sp)
    80006224:	6a5a                	ld	s4,400(sp)
}
    80006226:	70fa                	ld	ra,440(sp)
    80006228:	745a                	ld	s0,432(sp)
    8000622a:	6139                	addi	sp,sp,448
    8000622c:	8082                	ret

000000008000622e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000622e:	7139                	addi	sp,sp,-64
    80006230:	fc06                	sd	ra,56(sp)
    80006232:	f822                	sd	s0,48(sp)
    80006234:	f426                	sd	s1,40(sp)
    80006236:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006238:	ed0fb0ef          	jal	80001908 <myproc>
    8000623c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000623e:	fd840593          	addi	a1,s0,-40
    80006242:	4501                	li	a0,0
    80006244:	df4fc0ef          	jal	80002838 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006248:	fc840593          	addi	a1,s0,-56
    8000624c:	fd040513          	addi	a0,s0,-48
    80006250:	852ff0ef          	jal	800052a2 <pipealloc>
    return -1;
    80006254:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006256:	0a054463          	bltz	a0,800062fe <sys_pipe+0xd0>
  fd0 = -1;
    8000625a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000625e:	fd043503          	ld	a0,-48(s0)
    80006262:	f08ff0ef          	jal	8000596a <fdalloc>
    80006266:	fca42223          	sw	a0,-60(s0)
    8000626a:	08054163          	bltz	a0,800062ec <sys_pipe+0xbe>
    8000626e:	fc843503          	ld	a0,-56(s0)
    80006272:	ef8ff0ef          	jal	8000596a <fdalloc>
    80006276:	fca42023          	sw	a0,-64(s0)
    8000627a:	06054063          	bltz	a0,800062da <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000627e:	4691                	li	a3,4
    80006280:	fc440613          	addi	a2,s0,-60
    80006284:	fd843583          	ld	a1,-40(s0)
    80006288:	68a8                	ld	a0,80(s1)
    8000628a:	b92fb0ef          	jal	8000161c <copyout>
    8000628e:	00054e63          	bltz	a0,800062aa <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006292:	4691                	li	a3,4
    80006294:	fc040613          	addi	a2,s0,-64
    80006298:	fd843583          	ld	a1,-40(s0)
    8000629c:	0591                	addi	a1,a1,4
    8000629e:	68a8                	ld	a0,80(s1)
    800062a0:	b7cfb0ef          	jal	8000161c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800062a4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062a6:	04055c63          	bgez	a0,800062fe <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800062aa:	fc442783          	lw	a5,-60(s0)
    800062ae:	07e9                	addi	a5,a5,26
    800062b0:	078e                	slli	a5,a5,0x3
    800062b2:	97a6                	add	a5,a5,s1
    800062b4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800062b8:	fc042783          	lw	a5,-64(s0)
    800062bc:	07e9                	addi	a5,a5,26
    800062be:	078e                	slli	a5,a5,0x3
    800062c0:	94be                	add	s1,s1,a5
    800062c2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800062c6:	fd043503          	ld	a0,-48(s0)
    800062ca:	c65fe0ef          	jal	80004f2e <fileclose>
    fileclose(wf);
    800062ce:	fc843503          	ld	a0,-56(s0)
    800062d2:	c5dfe0ef          	jal	80004f2e <fileclose>
    return -1;
    800062d6:	57fd                	li	a5,-1
    800062d8:	a01d                	j	800062fe <sys_pipe+0xd0>
    if(fd0 >= 0)
    800062da:	fc442783          	lw	a5,-60(s0)
    800062de:	0007c763          	bltz	a5,800062ec <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800062e2:	07e9                	addi	a5,a5,26
    800062e4:	078e                	slli	a5,a5,0x3
    800062e6:	97a6                	add	a5,a5,s1
    800062e8:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800062ec:	fd043503          	ld	a0,-48(s0)
    800062f0:	c3ffe0ef          	jal	80004f2e <fileclose>
    fileclose(wf);
    800062f4:	fc843503          	ld	a0,-56(s0)
    800062f8:	c37fe0ef          	jal	80004f2e <fileclose>
    return -1;
    800062fc:	57fd                	li	a5,-1
}
    800062fe:	853e                	mv	a0,a5
    80006300:	70e2                	ld	ra,56(sp)
    80006302:	7442                	ld	s0,48(sp)
    80006304:	74a2                	ld	s1,40(sp)
    80006306:	6121                	addi	sp,sp,64
    80006308:	8082                	ret

000000008000630a <sys_fsread>:
uint64
sys_fsread(void)
{
    8000630a:	1101                	addi	sp,sp,-32
    8000630c:	ec06                	sd	ra,24(sp)
    8000630e:	e822                	sd	s0,16(sp)
    80006310:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  // استدعاء الدوال مباشرة لأنها void في نسختك
  argaddr(0, &addr); 
    80006312:	fe840593          	addi	a1,s0,-24
    80006316:	4501                	li	a0,0
    80006318:	d20fc0ef          	jal	80002838 <argaddr>
  argint(1, &n);
    8000631c:	fe440593          	addi	a1,s0,-28
    80006320:	4505                	li	a0,1
    80006322:	cfafc0ef          	jal	8000281c <argint>

  // شرط حماية صارم داخل الكيرنل: 
  // إذا كانت n سالبة، أو صفر، أو أكبر من الحد الأقصى للبفر (32)، قم بتصحيحها فوراً
  if(n <= 0)
    80006326:	fe442783          	lw	a5,-28(s0)
    return 0;
    8000632a:	4501                	li	a0,0
  if(n <= 0)
    8000632c:	02f05063          	blez	a5,8000634c <sys_fsread+0x42>
  if(n > 32)
    80006330:	02000713          	li	a4,32
    80006334:	00f75663          	bge	a4,a5,80006340 <sys_fsread+0x36>
    n = 32;
    80006338:	02000793          	li	a5,32
    8000633c:	fef42223          	sw	a5,-28(s0)

  // استدعاء الوظيفة الحقيقية وإعادة نتيجتها
  return fslog_read_many((struct fs_event *)addr, n);
    80006340:	fe442583          	lw	a1,-28(s0)
    80006344:	fe843503          	ld	a0,-24(s0)
    80006348:	47f000ef          	jal	80006fc6 <fslog_read_many>
}
    8000634c:	60e2                	ld	ra,24(sp)
    8000634e:	6442                	ld	s0,16(sp)
    80006350:	6105                	addi	sp,sp,32
    80006352:	8082                	ret

0000000080006354 <sys_schedread>:

uint64
sys_schedread(void)
{
    80006354:	1101                	addi	sp,sp,-32
    80006356:	ec06                	sd	ra,24(sp)
    80006358:	e822                	sd	s0,16(sp)
    8000635a:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  argaddr(0, &addr);
    8000635c:	fe840593          	addi	a1,s0,-24
    80006360:	4501                	li	a0,0
    80006362:	cd6fc0ef          	jal	80002838 <argaddr>
  argint(1, &n);
    80006366:	fe440593          	addi	a1,s0,-28
    8000636a:	4505                	li	a0,1
    8000636c:	cb0fc0ef          	jal	8000281c <argint>

  if(n <= 0)
    80006370:	fe442783          	lw	a5,-28(s0)
    return 0;
    80006374:	4501                	li	a0,0
  if(n <= 0)
    80006376:	02f05063          	blez	a5,80006396 <sys_schedread+0x42>
  if(n > 32)
    8000637a:	02000713          	li	a4,32
    8000637e:	00f75663          	bge	a4,a5,8000638a <sys_schedread+0x36>
    n = 32;
    80006382:	02000793          	li	a5,32
    80006386:	fef42223          	sw	a5,-28(s0)

  return schedread((struct sched_event *)addr, n);
    8000638a:	fe442583          	lw	a1,-28(s0)
    8000638e:	fe843503          	ld	a0,-24(s0)
    80006392:	72a010ef          	jal	80007abc <schedread>
}
    80006396:	60e2                	ld	ra,24(sp)
    80006398:	6442                	ld	s0,16(sp)
    8000639a:	6105                	addi	sp,sp,32
    8000639c:	8082                	ret

000000008000639e <sys_getcpuinfo>:

uint64
sys_getcpuinfo(void)
{
    8000639e:	7135                	addi	sp,sp,-160
    800063a0:	ed06                	sd	ra,152(sp)
    800063a2:	e922                	sd	s0,144(sp)
    800063a4:	e526                	sd	s1,136(sp)
    800063a6:	e14a                	sd	s2,128(sp)
    800063a8:	fcce                	sd	s3,120(sp)
    800063aa:	f8d2                	sd	s4,112(sp)
    800063ac:	f4d6                	sd	s5,104(sp)
    800063ae:	1100                	addi	s0,sp,160
  int ncpu;
  struct cpu_info info;
  int i;
  extern struct cpu cpus[NCPU];

  argaddr(0, &addr);
    800063b0:	fb840593          	addi	a1,s0,-72
    800063b4:	4501                	li	a0,0
    800063b6:	c82fc0ef          	jal	80002838 <argaddr>
  argint(1, &ncpu);
    800063ba:	fb440593          	addi	a1,s0,-76
    800063be:	4505                	li	a0,1
    800063c0:	c5cfc0ef          	jal	8000281c <argint>

  if(ncpu <= 0 || ncpu > NCPU)
    800063c4:	fb442783          	lw	a5,-76(s0)
    800063c8:	37fd                	addiw	a5,a5,-1
    800063ca:	471d                	li	a4,7
    800063cc:	00f77563          	bgeu	a4,a5,800063d6 <sys_getcpuinfo+0x38>
    ncpu = NCPU;
    800063d0:	47a1                	li	a5,8
    800063d2:	faf42a23          	sw	a5,-76(s0)

  // Fill in CPU info for each CPU
  for(i = 0; i < ncpu; i++) {
    800063d6:	0000ca17          	auipc	s4,0xc
    800063da:	e02a0a13          	addi	s4,s4,-510 # 800121d8 <cpus>
{
    800063de:	4981                	li	s3,0
    800063e0:	4901                	li	s2,0
    memset(&info, 0, sizeof(info));
    
    info.cpu = i;
    if(cpus[i].proc != 0) {
      struct proc *p = cpus[i].proc;
      info.active = 1;
    800063e2:	4a85                	li	s5,1
    800063e4:	a815                	j	80006418 <sys_getcpuinfo+0x7a>
      if(p->trapframe) {
        info.context_eip = p->trapframe->epc;  // instruction pointer
        info.context_esp = p->trapframe->sp;   // stack pointer
      }
    }
    info.busy_percent = 0;  // Simplified
    800063e6:	fa042423          	sw	zero,-88(s0)
    
    if(copyout(myproc()->pagetable, addr + i * sizeof(struct cpu_info), 
    800063ea:	d1efb0ef          	jal	80001908 <myproc>
    800063ee:	04800693          	li	a3,72
    800063f2:	f6840613          	addi	a2,s0,-152
    800063f6:	fb843583          	ld	a1,-72(s0)
    800063fa:	95ce                	add	a1,a1,s3
    800063fc:	6928                	ld	a0,80(a0)
    800063fe:	a1efb0ef          	jal	8000161c <copyout>
    80006402:	04054f63          	bltz	a0,80006460 <sys_getcpuinfo+0xc2>
  for(i = 0; i < ncpu; i++) {
    80006406:	2905                	addiw	s2,s2,1
    80006408:	fb442503          	lw	a0,-76(s0)
    8000640c:	080a0a13          	addi	s4,s4,128
    80006410:	04898993          	addi	s3,s3,72
    80006414:	04a95763          	bge	s2,a0,80006462 <sys_getcpuinfo+0xc4>
    memset(&info, 0, sizeof(info));
    80006418:	04800613          	li	a2,72
    8000641c:	4581                	li	a1,0
    8000641e:	f6840513          	addi	a0,s0,-152
    80006422:	8b3fa0ef          	jal	80000cd4 <memset>
    info.cpu = i;
    80006426:	f7242423          	sw	s2,-152(s0)
    if(cpus[i].proc != 0) {
    8000642a:	000a3483          	ld	s1,0(s4)
    8000642e:	dcc5                	beqz	s1,800063e6 <sys_getcpuinfo+0x48>
      info.active = 1;
    80006430:	f7542623          	sw	s5,-148(s0)
      info.current_pid = p->pid;
    80006434:	589c                	lw	a5,48(s1)
    80006436:	f6f42823          	sw	a5,-144(s0)
      info.current_state = p->state;
    8000643a:	4c9c                	lw	a5,24(s1)
    8000643c:	f8f42223          	sw	a5,-124(s0)
      safestrcpy(info.proc_name, p->name, PROC_NAME_LEN);
    80006440:	4641                	li	a2,16
    80006442:	15848593          	addi	a1,s1,344
    80006446:	f7440513          	addi	a0,s0,-140
    8000644a:	9c9fa0ef          	jal	80000e12 <safestrcpy>
      if(p->trapframe) {
    8000644e:	6cbc                	ld	a5,88(s1)
    80006450:	dbd9                	beqz	a5,800063e6 <sys_getcpuinfo+0x48>
        info.context_eip = p->trapframe->epc;  // instruction pointer
    80006452:	6f98                	ld	a4,24(a5)
    80006454:	f8e43c23          	sd	a4,-104(s0)
        info.context_esp = p->trapframe->sp;   // stack pointer
    80006458:	7b9c                	ld	a5,48(a5)
    8000645a:	faf43023          	sd	a5,-96(s0)
    8000645e:	b761                	j	800063e6 <sys_getcpuinfo+0x48>
               (char *)&info, sizeof(info)) < 0)
      return -1;
    80006460:	557d                	li	a0,-1
  }

  return ncpu;
}
    80006462:	60ea                	ld	ra,152(sp)
    80006464:	644a                	ld	s0,144(sp)
    80006466:	64aa                	ld	s1,136(sp)
    80006468:	690a                	ld	s2,128(sp)
    8000646a:	79e6                	ld	s3,120(sp)
    8000646c:	7a46                	ld	s4,112(sp)
    8000646e:	7aa6                	ld	s5,104(sp)
    80006470:	610d                	addi	sp,sp,160
    80006472:	8082                	ret

0000000080006474 <sys_getprocstats>:

uint64
sys_getprocstats(void)
{
    80006474:	7175                	addi	sp,sp,-144
    80006476:	e506                	sd	ra,136(sp)
    80006478:	e122                	sd	s0,128(sp)
    8000647a:	0900                	addi	s0,sp,144
  uint64 addr;
  struct proc_stats stats;
  struct proc *p;
  extern struct proc proc[];

  argaddr(0, &addr);
    8000647c:	fe840593          	addi	a1,s0,-24
    80006480:	4501                	li	a0,0
    80006482:	bb6fc0ef          	jal	80002838 <argaddr>

  memset(&stats, 0, sizeof(stats));
    80006486:	07000613          	li	a2,112
    8000648a:	4581                	li	a1,0
    8000648c:	f7840513          	addi	a0,s0,-136
    80006490:	845fa0ef          	jal	80000cd4 <memset>
  stats.total_created = 0;
    80006494:	fc043c23          	sd	zero,-40(s0)
  stats.total_exited = 0;
    80006498:	fe043023          	sd	zero,-32(s0)
    8000649c:	4301                	li	t1,0
    8000649e:	4881                	li	a7,0

  // Walk through all processes
  for(p = proc; p < &proc[NPROC]; p++) {
    800064a0:	0000c717          	auipc	a4,0xc
    800064a4:	13870713          	addi	a4,a4,312 # 800125d8 <proc>
    if(p->state != UNUSED) {
      stats.current_count[p->state]++;
      stats.unique_count[p->state]++;
      if(p->state == RUNNING) {
    800064a8:	4811                	li	a6,4
        stats.total_created++;
    800064aa:	4e05                	li	t3,1
  for(p = proc; p < &proc[NPROC]; p++) {
    800064ac:	00012517          	auipc	a0,0x12
    800064b0:	b2c50513          	addi	a0,a0,-1236 # 80017fd8 <tickslock>
    800064b4:	a029                	j	800064be <sys_getprocstats+0x4a>
    800064b6:	16870713          	addi	a4,a4,360
    800064ba:	02a70e63          	beq	a4,a0,800064f6 <sys_getprocstats+0x82>
    if(p->state != UNUSED) {
    800064be:	4f14                	lw	a3,24(a4)
    800064c0:	dafd                	beqz	a3,800064b6 <sys_getprocstats+0x42>
      stats.current_count[p->state]++;
    800064c2:	02069793          	slli	a5,a3,0x20
    800064c6:	9381                	srli	a5,a5,0x20
    800064c8:	00379613          	slli	a2,a5,0x3
    800064cc:	1641                	addi	a2,a2,-16 # ff0 <_entry-0x7ffff010>
    800064ce:	9622                	add	a2,a2,s0
    800064d0:	f8863583          	ld	a1,-120(a2)
    800064d4:	0585                	addi	a1,a1,1
    800064d6:	f8b63423          	sd	a1,-120(a2)
      stats.unique_count[p->state]++;
    800064da:	0799                	addi	a5,a5,6
    800064dc:	078e                	slli	a5,a5,0x3
    800064de:	17c1                	addi	a5,a5,-16
    800064e0:	97a2                	add	a5,a5,s0
    800064e2:	f887b603          	ld	a2,-120(a5)
    800064e6:	0605                	addi	a2,a2,1
    800064e8:	f8c7b423          	sd	a2,-120(a5)
      if(p->state == RUNNING) {
    800064ec:	fd0695e3          	bne	a3,a6,800064b6 <sys_getprocstats+0x42>
        stats.total_created++;
    800064f0:	0885                	addi	a7,a7,1
    800064f2:	8372                	mv	t1,t3
    800064f4:	b7c9                	j	800064b6 <sys_getprocstats+0x42>
    800064f6:	00030463          	beqz	t1,800064fe <sys_getprocstats+0x8a>
    800064fa:	fd143c23          	sd	a7,-40(s0)
      }
    }
  }

  if(copyout(myproc()->pagetable, addr, (char *)&stats, sizeof(stats)) < 0)
    800064fe:	c0afb0ef          	jal	80001908 <myproc>
    80006502:	07000693          	li	a3,112
    80006506:	f7840613          	addi	a2,s0,-136
    8000650a:	fe843583          	ld	a1,-24(s0)
    8000650e:	6928                	ld	a0,80(a0)
    80006510:	90cfb0ef          	jal	8000161c <copyout>
    return -1;

  return 0;
}
    80006514:	957d                	srai	a0,a0,0x3f
    80006516:	60aa                	ld	ra,136(sp)
    80006518:	640a                	ld	s0,128(sp)
    8000651a:	6149                	addi	sp,sp,144
    8000651c:	8082                	ret
	...

0000000080006520 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80006520:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80006522:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80006524:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80006526:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80006528:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000652a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000652c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000652e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80006530:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80006532:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80006534:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80006536:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80006538:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000653a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000653c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000653e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80006540:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80006542:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80006544:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80006546:	95cfc0ef          	jal	800026a2 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000654a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000654c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000654e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80006550:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80006552:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80006554:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80006556:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80006558:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000655a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000655c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000655e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80006560:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80006562:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80006564:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80006566:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80006568:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000656a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000656c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000656e:	10200073          	sret
	...

000000008000657e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000657e:	1141                	addi	sp,sp,-16
    80006580:	e422                	sd	s0,8(sp)
    80006582:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006584:	0c0007b7          	lui	a5,0xc000
    80006588:	4705                	li	a4,1
    8000658a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000658c:	0c0007b7          	lui	a5,0xc000
    80006590:	c3d8                	sw	a4,4(a5)
}
    80006592:	6422                	ld	s0,8(sp)
    80006594:	0141                	addi	sp,sp,16
    80006596:	8082                	ret

0000000080006598 <plicinithart>:

void
plicinithart(void)
{
    80006598:	1141                	addi	sp,sp,-16
    8000659a:	e406                	sd	ra,8(sp)
    8000659c:	e022                	sd	s0,0(sp)
    8000659e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800065a0:	b3cfb0ef          	jal	800018dc <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800065a4:	0085171b          	slliw	a4,a0,0x8
    800065a8:	0c0027b7          	lui	a5,0xc002
    800065ac:	97ba                	add	a5,a5,a4
    800065ae:	40200713          	li	a4,1026
    800065b2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800065b6:	00d5151b          	slliw	a0,a0,0xd
    800065ba:	0c2017b7          	lui	a5,0xc201
    800065be:	97aa                	add	a5,a5,a0
    800065c0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800065c4:	60a2                	ld	ra,8(sp)
    800065c6:	6402                	ld	s0,0(sp)
    800065c8:	0141                	addi	sp,sp,16
    800065ca:	8082                	ret

00000000800065cc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800065cc:	1141                	addi	sp,sp,-16
    800065ce:	e406                	sd	ra,8(sp)
    800065d0:	e022                	sd	s0,0(sp)
    800065d2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800065d4:	b08fb0ef          	jal	800018dc <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800065d8:	00d5151b          	slliw	a0,a0,0xd
    800065dc:	0c2017b7          	lui	a5,0xc201
    800065e0:	97aa                	add	a5,a5,a0
  return irq;
}
    800065e2:	43c8                	lw	a0,4(a5)
    800065e4:	60a2                	ld	ra,8(sp)
    800065e6:	6402                	ld	s0,0(sp)
    800065e8:	0141                	addi	sp,sp,16
    800065ea:	8082                	ret

00000000800065ec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800065ec:	1101                	addi	sp,sp,-32
    800065ee:	ec06                	sd	ra,24(sp)
    800065f0:	e822                	sd	s0,16(sp)
    800065f2:	e426                	sd	s1,8(sp)
    800065f4:	1000                	addi	s0,sp,32
    800065f6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800065f8:	ae4fb0ef          	jal	800018dc <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800065fc:	00d5151b          	slliw	a0,a0,0xd
    80006600:	0c2017b7          	lui	a5,0xc201
    80006604:	97aa                	add	a5,a5,a0
    80006606:	c3c4                	sw	s1,4(a5)
}
    80006608:	60e2                	ld	ra,24(sp)
    8000660a:	6442                	ld	s0,16(sp)
    8000660c:	64a2                	ld	s1,8(sp)
    8000660e:	6105                	addi	sp,sp,32
    80006610:	8082                	ret

0000000080006612 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006612:	1141                	addi	sp,sp,-16
    80006614:	e406                	sd	ra,8(sp)
    80006616:	e022                	sd	s0,0(sp)
    80006618:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000661a:	479d                	li	a5,7
    8000661c:	04a7ca63          	blt	a5,a0,80006670 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80006620:	0001d797          	auipc	a5,0x1d
    80006624:	c5878793          	addi	a5,a5,-936 # 80023278 <disk>
    80006628:	97aa                	add	a5,a5,a0
    8000662a:	0187c783          	lbu	a5,24(a5)
    8000662e:	e7b9                	bnez	a5,8000667c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006630:	00451693          	slli	a3,a0,0x4
    80006634:	0001d797          	auipc	a5,0x1d
    80006638:	c4478793          	addi	a5,a5,-956 # 80023278 <disk>
    8000663c:	6398                	ld	a4,0(a5)
    8000663e:	9736                	add	a4,a4,a3
    80006640:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006644:	6398                	ld	a4,0(a5)
    80006646:	9736                	add	a4,a4,a3
    80006648:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000664c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006650:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006654:	97aa                	add	a5,a5,a0
    80006656:	4705                	li	a4,1
    80006658:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000665c:	0001d517          	auipc	a0,0x1d
    80006660:	c3450513          	addi	a0,a0,-972 # 80023290 <disk+0x18>
    80006664:	901fb0ef          	jal	80001f64 <wakeup>
}
    80006668:	60a2                	ld	ra,8(sp)
    8000666a:	6402                	ld	s0,0(sp)
    8000666c:	0141                	addi	sp,sp,16
    8000666e:	8082                	ret
    panic("free_desc 1");
    80006670:	00003517          	auipc	a0,0x3
    80006674:	6b050513          	addi	a0,a0,1712 # 80009d20 <etext+0xd20>
    80006678:	99afa0ef          	jal	80000812 <panic>
    panic("free_desc 2");
    8000667c:	00003517          	auipc	a0,0x3
    80006680:	6b450513          	addi	a0,a0,1716 # 80009d30 <etext+0xd30>
    80006684:	98efa0ef          	jal	80000812 <panic>

0000000080006688 <virtio_disk_init>:
{
    80006688:	1101                	addi	sp,sp,-32
    8000668a:	ec06                	sd	ra,24(sp)
    8000668c:	e822                	sd	s0,16(sp)
    8000668e:	e426                	sd	s1,8(sp)
    80006690:	e04a                	sd	s2,0(sp)
    80006692:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006694:	00003597          	auipc	a1,0x3
    80006698:	6ac58593          	addi	a1,a1,1708 # 80009d40 <etext+0xd40>
    8000669c:	0001d517          	auipc	a0,0x1d
    800066a0:	d0450513          	addi	a0,a0,-764 # 800233a0 <disk+0x128>
    800066a4:	cdcfa0ef          	jal	80000b80 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800066a8:	100017b7          	lui	a5,0x10001
    800066ac:	4398                	lw	a4,0(a5)
    800066ae:	2701                	sext.w	a4,a4
    800066b0:	747277b7          	lui	a5,0x74727
    800066b4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800066b8:	18f71063          	bne	a4,a5,80006838 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800066bc:	100017b7          	lui	a5,0x10001
    800066c0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800066c2:	439c                	lw	a5,0(a5)
    800066c4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800066c6:	4709                	li	a4,2
    800066c8:	16e79863          	bne	a5,a4,80006838 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800066cc:	100017b7          	lui	a5,0x10001
    800066d0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800066d2:	439c                	lw	a5,0(a5)
    800066d4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800066d6:	16e79163          	bne	a5,a4,80006838 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800066da:	100017b7          	lui	a5,0x10001
    800066de:	47d8                	lw	a4,12(a5)
    800066e0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800066e2:	554d47b7          	lui	a5,0x554d4
    800066e6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800066ea:	14f71763          	bne	a4,a5,80006838 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800066ee:	100017b7          	lui	a5,0x10001
    800066f2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800066f6:	4705                	li	a4,1
    800066f8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800066fa:	470d                	li	a4,3
    800066fc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800066fe:	10001737          	lui	a4,0x10001
    80006702:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006704:	c7ffe737          	lui	a4,0xc7ffe
    80006708:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47f6e2ff>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000670c:	8ef9                	and	a3,a3,a4
    8000670e:	10001737          	lui	a4,0x10001
    80006712:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006714:	472d                	li	a4,11
    80006716:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006718:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000671c:	439c                	lw	a5,0(a5)
    8000671e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006722:	8ba1                	andi	a5,a5,8
    80006724:	12078063          	beqz	a5,80006844 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006728:	100017b7          	lui	a5,0x10001
    8000672c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006730:	100017b7          	lui	a5,0x10001
    80006734:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006738:	439c                	lw	a5,0(a5)
    8000673a:	2781                	sext.w	a5,a5
    8000673c:	10079a63          	bnez	a5,80006850 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006740:	100017b7          	lui	a5,0x10001
    80006744:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006748:	439c                	lw	a5,0(a5)
    8000674a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000674c:	10078863          	beqz	a5,8000685c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80006750:	471d                	li	a4,7
    80006752:	10f77b63          	bgeu	a4,a5,80006868 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80006756:	bdafa0ef          	jal	80000b30 <kalloc>
    8000675a:	0001d497          	auipc	s1,0x1d
    8000675e:	b1e48493          	addi	s1,s1,-1250 # 80023278 <disk>
    80006762:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006764:	bccfa0ef          	jal	80000b30 <kalloc>
    80006768:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000676a:	bc6fa0ef          	jal	80000b30 <kalloc>
    8000676e:	87aa                	mv	a5,a0
    80006770:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006772:	6088                	ld	a0,0(s1)
    80006774:	10050063          	beqz	a0,80006874 <virtio_disk_init+0x1ec>
    80006778:	0001d717          	auipc	a4,0x1d
    8000677c:	b0873703          	ld	a4,-1272(a4) # 80023280 <disk+0x8>
    80006780:	0e070a63          	beqz	a4,80006874 <virtio_disk_init+0x1ec>
    80006784:	0e078863          	beqz	a5,80006874 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80006788:	6605                	lui	a2,0x1
    8000678a:	4581                	li	a1,0
    8000678c:	d48fa0ef          	jal	80000cd4 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006790:	0001d497          	auipc	s1,0x1d
    80006794:	ae848493          	addi	s1,s1,-1304 # 80023278 <disk>
    80006798:	6605                	lui	a2,0x1
    8000679a:	4581                	li	a1,0
    8000679c:	6488                	ld	a0,8(s1)
    8000679e:	d36fa0ef          	jal	80000cd4 <memset>
  memset(disk.used, 0, PGSIZE);
    800067a2:	6605                	lui	a2,0x1
    800067a4:	4581                	li	a1,0
    800067a6:	6888                	ld	a0,16(s1)
    800067a8:	d2cfa0ef          	jal	80000cd4 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800067ac:	100017b7          	lui	a5,0x10001
    800067b0:	4721                	li	a4,8
    800067b2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800067b4:	4098                	lw	a4,0(s1)
    800067b6:	100017b7          	lui	a5,0x10001
    800067ba:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800067be:	40d8                	lw	a4,4(s1)
    800067c0:	100017b7          	lui	a5,0x10001
    800067c4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800067c8:	649c                	ld	a5,8(s1)
    800067ca:	0007869b          	sext.w	a3,a5
    800067ce:	10001737          	lui	a4,0x10001
    800067d2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800067d6:	9781                	srai	a5,a5,0x20
    800067d8:	10001737          	lui	a4,0x10001
    800067dc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800067e0:	689c                	ld	a5,16(s1)
    800067e2:	0007869b          	sext.w	a3,a5
    800067e6:	10001737          	lui	a4,0x10001
    800067ea:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800067ee:	9781                	srai	a5,a5,0x20
    800067f0:	10001737          	lui	a4,0x10001
    800067f4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800067f8:	10001737          	lui	a4,0x10001
    800067fc:	4785                	li	a5,1
    800067fe:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006800:	00f48c23          	sb	a5,24(s1)
    80006804:	00f48ca3          	sb	a5,25(s1)
    80006808:	00f48d23          	sb	a5,26(s1)
    8000680c:	00f48da3          	sb	a5,27(s1)
    80006810:	00f48e23          	sb	a5,28(s1)
    80006814:	00f48ea3          	sb	a5,29(s1)
    80006818:	00f48f23          	sb	a5,30(s1)
    8000681c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006820:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006824:	100017b7          	lui	a5,0x10001
    80006828:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000682c:	60e2                	ld	ra,24(sp)
    8000682e:	6442                	ld	s0,16(sp)
    80006830:	64a2                	ld	s1,8(sp)
    80006832:	6902                	ld	s2,0(sp)
    80006834:	6105                	addi	sp,sp,32
    80006836:	8082                	ret
    panic("could not find virtio disk");
    80006838:	00003517          	auipc	a0,0x3
    8000683c:	51850513          	addi	a0,a0,1304 # 80009d50 <etext+0xd50>
    80006840:	fd3f90ef          	jal	80000812 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006844:	00003517          	auipc	a0,0x3
    80006848:	52c50513          	addi	a0,a0,1324 # 80009d70 <etext+0xd70>
    8000684c:	fc7f90ef          	jal	80000812 <panic>
    panic("virtio disk should not be ready");
    80006850:	00003517          	auipc	a0,0x3
    80006854:	54050513          	addi	a0,a0,1344 # 80009d90 <etext+0xd90>
    80006858:	fbbf90ef          	jal	80000812 <panic>
    panic("virtio disk has no queue 0");
    8000685c:	00003517          	auipc	a0,0x3
    80006860:	55450513          	addi	a0,a0,1364 # 80009db0 <etext+0xdb0>
    80006864:	faff90ef          	jal	80000812 <panic>
    panic("virtio disk max queue too short");
    80006868:	00003517          	auipc	a0,0x3
    8000686c:	56850513          	addi	a0,a0,1384 # 80009dd0 <etext+0xdd0>
    80006870:	fa3f90ef          	jal	80000812 <panic>
    panic("virtio disk kalloc");
    80006874:	00003517          	auipc	a0,0x3
    80006878:	57c50513          	addi	a0,a0,1404 # 80009df0 <etext+0xdf0>
    8000687c:	f97f90ef          	jal	80000812 <panic>

0000000080006880 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006880:	7159                	addi	sp,sp,-112
    80006882:	f486                	sd	ra,104(sp)
    80006884:	f0a2                	sd	s0,96(sp)
    80006886:	eca6                	sd	s1,88(sp)
    80006888:	e8ca                	sd	s2,80(sp)
    8000688a:	e4ce                	sd	s3,72(sp)
    8000688c:	e0d2                	sd	s4,64(sp)
    8000688e:	fc56                	sd	s5,56(sp)
    80006890:	f85a                	sd	s6,48(sp)
    80006892:	f45e                	sd	s7,40(sp)
    80006894:	f062                	sd	s8,32(sp)
    80006896:	ec66                	sd	s9,24(sp)
    80006898:	1880                	addi	s0,sp,112
    8000689a:	8a2a                	mv	s4,a0
    8000689c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000689e:	00c52c83          	lw	s9,12(a0)
    800068a2:	001c9c9b          	slliw	s9,s9,0x1
    800068a6:	1c82                	slli	s9,s9,0x20
    800068a8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800068ac:	0001d517          	auipc	a0,0x1d
    800068b0:	af450513          	addi	a0,a0,-1292 # 800233a0 <disk+0x128>
    800068b4:	b4cfa0ef          	jal	80000c00 <acquire>
  for(int i = 0; i < 3; i++){
    800068b8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800068ba:	44a1                	li	s1,8
      disk.free[i] = 0;
    800068bc:	0001db17          	auipc	s6,0x1d
    800068c0:	9bcb0b13          	addi	s6,s6,-1604 # 80023278 <disk>
  for(int i = 0; i < 3; i++){
    800068c4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800068c6:	0001dc17          	auipc	s8,0x1d
    800068ca:	adac0c13          	addi	s8,s8,-1318 # 800233a0 <disk+0x128>
    800068ce:	a8b9                	j	8000692c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800068d0:	00fb0733          	add	a4,s6,a5
    800068d4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800068d8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800068da:	0207c563          	bltz	a5,80006904 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800068de:	2905                	addiw	s2,s2,1
    800068e0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800068e2:	05590963          	beq	s2,s5,80006934 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800068e6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800068e8:	0001d717          	auipc	a4,0x1d
    800068ec:	99070713          	addi	a4,a4,-1648 # 80023278 <disk>
    800068f0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800068f2:	01874683          	lbu	a3,24(a4)
    800068f6:	fee9                	bnez	a3,800068d0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800068f8:	2785                	addiw	a5,a5,1
    800068fa:	0705                	addi	a4,a4,1
    800068fc:	fe979be3          	bne	a5,s1,800068f2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80006900:	57fd                	li	a5,-1
    80006902:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006904:	01205d63          	blez	s2,8000691e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006908:	f9042503          	lw	a0,-112(s0)
    8000690c:	d07ff0ef          	jal	80006612 <free_desc>
      for(int j = 0; j < i; j++)
    80006910:	4785                	li	a5,1
    80006912:	0127d663          	bge	a5,s2,8000691e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006916:	f9442503          	lw	a0,-108(s0)
    8000691a:	cf9ff0ef          	jal	80006612 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000691e:	85e2                	mv	a1,s8
    80006920:	0001d517          	auipc	a0,0x1d
    80006924:	97050513          	addi	a0,a0,-1680 # 80023290 <disk+0x18>
    80006928:	df0fb0ef          	jal	80001f18 <sleep>
  for(int i = 0; i < 3; i++){
    8000692c:	f9040613          	addi	a2,s0,-112
    80006930:	894e                	mv	s2,s3
    80006932:	bf55                	j	800068e6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006934:	f9042503          	lw	a0,-112(s0)
    80006938:	00451693          	slli	a3,a0,0x4

  if(write)
    8000693c:	0001d797          	auipc	a5,0x1d
    80006940:	93c78793          	addi	a5,a5,-1732 # 80023278 <disk>
    80006944:	00a50713          	addi	a4,a0,10
    80006948:	0712                	slli	a4,a4,0x4
    8000694a:	973e                	add	a4,a4,a5
    8000694c:	01703633          	snez	a2,s7
    80006950:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006952:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006956:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000695a:	6398                	ld	a4,0(a5)
    8000695c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000695e:	0a868613          	addi	a2,a3,168
    80006962:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006964:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006966:	6390                	ld	a2,0(a5)
    80006968:	00d605b3          	add	a1,a2,a3
    8000696c:	4741                	li	a4,16
    8000696e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006970:	4805                	li	a6,1
    80006972:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006976:	f9442703          	lw	a4,-108(s0)
    8000697a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000697e:	0712                	slli	a4,a4,0x4
    80006980:	963a                	add	a2,a2,a4
    80006982:	058a0593          	addi	a1,s4,88
    80006986:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006988:	0007b883          	ld	a7,0(a5)
    8000698c:	9746                	add	a4,a4,a7
    8000698e:	40000613          	li	a2,1024
    80006992:	c710                	sw	a2,8(a4)
  if(write)
    80006994:	001bb613          	seqz	a2,s7
    80006998:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000699c:	00166613          	ori	a2,a2,1
    800069a0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800069a4:	f9842583          	lw	a1,-104(s0)
    800069a8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800069ac:	00250613          	addi	a2,a0,2
    800069b0:	0612                	slli	a2,a2,0x4
    800069b2:	963e                	add	a2,a2,a5
    800069b4:	577d                	li	a4,-1
    800069b6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800069ba:	0592                	slli	a1,a1,0x4
    800069bc:	98ae                	add	a7,a7,a1
    800069be:	03068713          	addi	a4,a3,48
    800069c2:	973e                	add	a4,a4,a5
    800069c4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800069c8:	6398                	ld	a4,0(a5)
    800069ca:	972e                	add	a4,a4,a1
    800069cc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800069d0:	4689                	li	a3,2
    800069d2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800069d6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800069da:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800069de:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800069e2:	6794                	ld	a3,8(a5)
    800069e4:	0026d703          	lhu	a4,2(a3)
    800069e8:	8b1d                	andi	a4,a4,7
    800069ea:	0706                	slli	a4,a4,0x1
    800069ec:	96ba                	add	a3,a3,a4
    800069ee:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800069f2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800069f6:	6798                	ld	a4,8(a5)
    800069f8:	00275783          	lhu	a5,2(a4)
    800069fc:	2785                	addiw	a5,a5,1
    800069fe:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006a02:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006a06:	100017b7          	lui	a5,0x10001
    80006a0a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006a0e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006a12:	0001d917          	auipc	s2,0x1d
    80006a16:	98e90913          	addi	s2,s2,-1650 # 800233a0 <disk+0x128>
  while(b->disk == 1) {
    80006a1a:	4485                	li	s1,1
    80006a1c:	01079a63          	bne	a5,a6,80006a30 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80006a20:	85ca                	mv	a1,s2
    80006a22:	8552                	mv	a0,s4
    80006a24:	cf4fb0ef          	jal	80001f18 <sleep>
  while(b->disk == 1) {
    80006a28:	004a2783          	lw	a5,4(s4)
    80006a2c:	fe978ae3          	beq	a5,s1,80006a20 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80006a30:	f9042903          	lw	s2,-112(s0)
    80006a34:	00290713          	addi	a4,s2,2
    80006a38:	0712                	slli	a4,a4,0x4
    80006a3a:	0001d797          	auipc	a5,0x1d
    80006a3e:	83e78793          	addi	a5,a5,-1986 # 80023278 <disk>
    80006a42:	97ba                	add	a5,a5,a4
    80006a44:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006a48:	0001d997          	auipc	s3,0x1d
    80006a4c:	83098993          	addi	s3,s3,-2000 # 80023278 <disk>
    80006a50:	00491713          	slli	a4,s2,0x4
    80006a54:	0009b783          	ld	a5,0(s3)
    80006a58:	97ba                	add	a5,a5,a4
    80006a5a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006a5e:	854a                	mv	a0,s2
    80006a60:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006a64:	bafff0ef          	jal	80006612 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006a68:	8885                	andi	s1,s1,1
    80006a6a:	f0fd                	bnez	s1,80006a50 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006a6c:	0001d517          	auipc	a0,0x1d
    80006a70:	93450513          	addi	a0,a0,-1740 # 800233a0 <disk+0x128>
    80006a74:	a24fa0ef          	jal	80000c98 <release>
}
    80006a78:	70a6                	ld	ra,104(sp)
    80006a7a:	7406                	ld	s0,96(sp)
    80006a7c:	64e6                	ld	s1,88(sp)
    80006a7e:	6946                	ld	s2,80(sp)
    80006a80:	69a6                	ld	s3,72(sp)
    80006a82:	6a06                	ld	s4,64(sp)
    80006a84:	7ae2                	ld	s5,56(sp)
    80006a86:	7b42                	ld	s6,48(sp)
    80006a88:	7ba2                	ld	s7,40(sp)
    80006a8a:	7c02                	ld	s8,32(sp)
    80006a8c:	6ce2                	ld	s9,24(sp)
    80006a8e:	6165                	addi	sp,sp,112
    80006a90:	8082                	ret

0000000080006a92 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006a92:	1101                	addi	sp,sp,-32
    80006a94:	ec06                	sd	ra,24(sp)
    80006a96:	e822                	sd	s0,16(sp)
    80006a98:	e426                	sd	s1,8(sp)
    80006a9a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006a9c:	0001c497          	auipc	s1,0x1c
    80006aa0:	7dc48493          	addi	s1,s1,2012 # 80023278 <disk>
    80006aa4:	0001d517          	auipc	a0,0x1d
    80006aa8:	8fc50513          	addi	a0,a0,-1796 # 800233a0 <disk+0x128>
    80006aac:	954fa0ef          	jal	80000c00 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006ab0:	100017b7          	lui	a5,0x10001
    80006ab4:	53b8                	lw	a4,96(a5)
    80006ab6:	8b0d                	andi	a4,a4,3
    80006ab8:	100017b7          	lui	a5,0x10001
    80006abc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006abe:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006ac2:	689c                	ld	a5,16(s1)
    80006ac4:	0204d703          	lhu	a4,32(s1)
    80006ac8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006acc:	04f70663          	beq	a4,a5,80006b18 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80006ad0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006ad4:	6898                	ld	a4,16(s1)
    80006ad6:	0204d783          	lhu	a5,32(s1)
    80006ada:	8b9d                	andi	a5,a5,7
    80006adc:	078e                	slli	a5,a5,0x3
    80006ade:	97ba                	add	a5,a5,a4
    80006ae0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006ae2:	00278713          	addi	a4,a5,2
    80006ae6:	0712                	slli	a4,a4,0x4
    80006ae8:	9726                	add	a4,a4,s1
    80006aea:	01074703          	lbu	a4,16(a4)
    80006aee:	e321                	bnez	a4,80006b2e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006af0:	0789                	addi	a5,a5,2
    80006af2:	0792                	slli	a5,a5,0x4
    80006af4:	97a6                	add	a5,a5,s1
    80006af6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006af8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006afc:	c68fb0ef          	jal	80001f64 <wakeup>

    disk.used_idx += 1;
    80006b00:	0204d783          	lhu	a5,32(s1)
    80006b04:	2785                	addiw	a5,a5,1
    80006b06:	17c2                	slli	a5,a5,0x30
    80006b08:	93c1                	srli	a5,a5,0x30
    80006b0a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006b0e:	6898                	ld	a4,16(s1)
    80006b10:	00275703          	lhu	a4,2(a4)
    80006b14:	faf71ee3          	bne	a4,a5,80006ad0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006b18:	0001d517          	auipc	a0,0x1d
    80006b1c:	88850513          	addi	a0,a0,-1912 # 800233a0 <disk+0x128>
    80006b20:	978fa0ef          	jal	80000c98 <release>
}
    80006b24:	60e2                	ld	ra,24(sp)
    80006b26:	6442                	ld	s0,16(sp)
    80006b28:	64a2                	ld	s1,8(sp)
    80006b2a:	6105                	addi	sp,sp,32
    80006b2c:	8082                	ret
      panic("virtio_disk_intr status");
    80006b2e:	00003517          	auipc	a0,0x3
    80006b32:	2da50513          	addi	a0,a0,730 # 80009e08 <etext+0xe08>
    80006b36:	cddf90ef          	jal	80000812 <panic>

0000000080006b3a <cslog_init>:
  safestrcpy(e->name, p->name, CS_NM);
}

void
cslog_init(void)
{
    80006b3a:	1141                	addi	sp,sp,-16
    80006b3c:	e406                	sd	ra,8(sp)
    80006b3e:	e022                	sd	s0,0(sp)
    80006b40:	0800                	addi	s0,sp,16
  ringbuf_init(&cs_rb, "cslog", sizeof(struct cs_event));
    80006b42:	03000613          	li	a2,48
    80006b46:	00003597          	auipc	a1,0x3
    80006b4a:	2da58593          	addi	a1,a1,730 # 80009e20 <etext+0xe20>
    80006b4e:	0001d517          	auipc	a0,0x1d
    80006b52:	86a50513          	addi	a0,a0,-1942 # 800233b8 <cs_rb>
    80006b56:	254000ef          	jal	80006daa <ringbuf_init>
  printf("CS sizeof(cs_event)=%ld RB_MAX_ELEM=%d\n", sizeof(struct cs_event), RB_MAX_ELEM);
    80006b5a:	10000613          	li	a2,256
    80006b5e:	03000593          	li	a1,48
    80006b62:	00003517          	auipc	a0,0x3
    80006b66:	2c650513          	addi	a0,a0,710 # 80009e28 <etext+0xe28>
    80006b6a:	9c3f90ef          	jal	8000052c <printf>
}
    80006b6e:	60a2                	ld	ra,8(sp)
    80006b70:	6402                	ld	s0,0(sp)
    80006b72:	0141                	addi	sp,sp,16
    80006b74:	8082                	ret

0000000080006b76 <cslog_push>:

void
cslog_push(struct cs_event *e)
{
    80006b76:	1141                	addi	sp,sp,-16
    80006b78:	e406                	sd	ra,8(sp)
    80006b7a:	e022                	sd	s0,0(sp)
    80006b7c:	0800                	addi	s0,sp,16
    80006b7e:	85aa                	mv	a1,a0
  e->seq = ++cs_seq;
    80006b80:	00003717          	auipc	a4,0x3
    80006b84:	4d070713          	addi	a4,a4,1232 # 8000a050 <cs_seq>
    80006b88:	631c                	ld	a5,0(a4)
    80006b8a:	0785                	addi	a5,a5,1
    80006b8c:	e31c                	sd	a5,0(a4)
    80006b8e:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    80006b90:	0001d517          	auipc	a0,0x1d
    80006b94:	82850513          	addi	a0,a0,-2008 # 800233b8 <cs_rb>
    80006b98:	246000ef          	jal	80006dde <ringbuf_push>
}
    80006b9c:	60a2                	ld	ra,8(sp)
    80006b9e:	6402                	ld	s0,0(sp)
    80006ba0:	0141                	addi	sp,sp,16
    80006ba2:	8082                	ret

0000000080006ba4 <cslog_read_many>:

int
cslog_read_many(struct cs_event *out, int max)
{
    80006ba4:	1141                	addi	sp,sp,-16
    80006ba6:	e406                	sd	ra,8(sp)
    80006ba8:	e022                	sd	s0,0(sp)
    80006baa:	0800                	addi	s0,sp,16
    80006bac:	862e                	mv	a2,a1
  return ringbuf_read_many(&cs_rb, out, max);
    80006bae:	85aa                	mv	a1,a0
    80006bb0:	0001d517          	auipc	a0,0x1d
    80006bb4:	80850513          	addi	a0,a0,-2040 # 800233b8 <cs_rb>
    80006bb8:	292000ef          	jal	80006e4a <ringbuf_read_many>
}
    80006bbc:	60a2                	ld	ra,8(sp)
    80006bbe:	6402                	ld	s0,0(sp)
    80006bc0:	0141                	addi	sp,sp,16
    80006bc2:	8082                	ret

0000000080006bc4 <cslog_run_start>:

void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
    80006bc4:	c14d                	beqz	a0,80006c66 <cslog_run_start+0xa2>
{
    80006bc6:	715d                	addi	sp,sp,-80
    80006bc8:	e486                	sd	ra,72(sp)
    80006bca:	e0a2                	sd	s0,64(sp)
    80006bcc:	fc26                	sd	s1,56(sp)
    80006bce:	0880                	addi	s0,sp,80
    80006bd0:	84aa                	mv	s1,a0
  if(p->pid <= 0) return;
    80006bd2:	591c                	lw	a5,48(a0)
    80006bd4:	00f05563          	blez	a5,80006bde <cslog_run_start+0x1a>
  if(p->name[0] == 0) return;
    80006bd8:	15854783          	lbu	a5,344(a0)
    80006bdc:	e791                	bnez	a5,80006be8 <cslog_run_start+0x24>

  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
    80006bde:	60a6                	ld	ra,72(sp)
    80006be0:	6406                	ld	s0,64(sp)
    80006be2:	74e2                	ld	s1,56(sp)
    80006be4:	6161                	addi	sp,sp,80
    80006be6:	8082                	ret
    80006be8:	f84a                	sd	s2,48(sp)
  if(strncmp(p->name, "cscat", 5) == 0) return;
    80006bea:	15850913          	addi	s2,a0,344
    80006bee:	4615                	li	a2,5
    80006bf0:	00003597          	auipc	a1,0x3
    80006bf4:	26058593          	addi	a1,a1,608 # 80009e50 <etext+0xe50>
    80006bf8:	854a                	mv	a0,s2
    80006bfa:	9a6fa0ef          	jal	80000da0 <strncmp>
    80006bfe:	e119                	bnez	a0,80006c04 <cslog_run_start+0x40>
    80006c00:	7942                	ld	s2,48(sp)
    80006c02:	bff1                	j	80006bde <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    80006c04:	4621                	li	a2,8
    80006c06:	00003597          	auipc	a1,0x3
    80006c0a:	25258593          	addi	a1,a1,594 # 80009e58 <etext+0xe58>
    80006c0e:	854a                	mv	a0,s2
    80006c10:	990fa0ef          	jal	80000da0 <strncmp>
    80006c14:	e119                	bnez	a0,80006c1a <cslog_run_start+0x56>
    80006c16:	7942                	ld	s2,48(sp)
    80006c18:	b7d9                	j	80006bde <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    80006c1a:	03000613          	li	a2,48
    80006c1e:	4581                	li	a1,0
    80006c20:	fb040513          	addi	a0,s0,-80
    80006c24:	8b0fa0ef          	jal	80000cd4 <memset>
  e->ticks = ticks;
    80006c28:	00003797          	auipc	a5,0x3
    80006c2c:	4207a783          	lw	a5,1056(a5) # 8000a048 <ticks>
    80006c30:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    80006c34:	ca9fa0ef          	jal	800018dc <cpuid>
    80006c38:	faa42e23          	sw	a0,-68(s0)
  e->pid   = p->pid;
    80006c3c:	589c                	lw	a5,48(s1)
    80006c3e:	fcf42223          	sw	a5,-60(s0)
  e->state = p->state;
    80006c42:	4c9c                	lw	a5,24(s1)
    80006c44:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e->name, p->name, CS_NM);
    80006c48:	4641                	li	a2,16
    80006c4a:	85ca                	mv	a1,s2
    80006c4c:	fcc40513          	addi	a0,s0,-52
    80006c50:	9c2fa0ef          	jal	80000e12 <safestrcpy>
  e.type = CS_RUN_START;
    80006c54:	4785                	li	a5,1
    80006c56:	fcf42023          	sw	a5,-64(s0)
  cslog_push(&e);
    80006c5a:	fb040513          	addi	a0,s0,-80
    80006c5e:	f19ff0ef          	jal	80006b76 <cslog_push>
    80006c62:	7942                	ld	s2,48(sp)
    80006c64:	bfad                	j	80006bde <cslog_run_start+0x1a>
    80006c66:	8082                	ret

0000000080006c68 <sys_csread>:
#include "cslog.h"


uint64
sys_csread(void)
{
    80006c68:	81010113          	addi	sp,sp,-2032
    80006c6c:	7e113423          	sd	ra,2024(sp)
    80006c70:	7e813023          	sd	s0,2016(sp)
    80006c74:	7c913c23          	sd	s1,2008(sp)
    80006c78:	7d213823          	sd	s2,2000(sp)
    80006c7c:	7f010413          	addi	s0,sp,2032
    80006c80:	bb010113          	addi	sp,sp,-1104
  uint64 uaddr = 0;
    80006c84:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80006c88:	fc042a23          	sw	zero,-44(s0)

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
    80006c8c:	fd840593          	addi	a1,s0,-40
    80006c90:	4501                	li	a0,0
    80006c92:	ba7fb0ef          	jal	80002838 <argaddr>
  argint(1, &max);
    80006c96:	fd440593          	addi	a1,s0,-44
    80006c9a:	4505                	li	a0,1
    80006c9c:	b81fb0ef          	jal	8000281c <argint>

  if(max <= 0) return 0;
    80006ca0:	fd442783          	lw	a5,-44(s0)
    80006ca4:	4501                	li	a0,0
    80006ca6:	04f05c63          	blez	a5,80006cfe <sys_csread+0x96>
  if(max > 64) max = 64;
    80006caa:	04000713          	li	a4,64
    80006cae:	00f75663          	bge	a4,a5,80006cba <sys_csread+0x52>
    80006cb2:	04000793          	li	a5,64
    80006cb6:	fcf42a23          	sw	a5,-44(s0)

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);
    80006cba:	77fd                	lui	a5,0xfffff
    80006cbc:	3d078793          	addi	a5,a5,976 # fffffffffffff3d0 <end+0xffffffff7ff6ef70>
    80006cc0:	97a2                	add	a5,a5,s0
    80006cc2:	797d                	lui	s2,0xfffff
    80006cc4:	3c890713          	addi	a4,s2,968 # fffffffffffff3c8 <end+0xffffffff7ff6ef68>
    80006cc8:	9722                	add	a4,a4,s0
    80006cca:	e31c                	sd	a5,0(a4)
    80006ccc:	fd442583          	lw	a1,-44(s0)
    80006cd0:	6308                	ld	a0,0(a4)
    80006cd2:	ed3ff0ef          	jal	80006ba4 <cslog_read_many>
    80006cd6:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80006cd8:	c31fa0ef          	jal	80001908 <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    80006cdc:	0014969b          	slliw	a3,s1,0x1
    80006ce0:	9ea5                	addw	a3,a3,s1
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80006ce2:	0046969b          	slliw	a3,a3,0x4
    80006ce6:	3c890793          	addi	a5,s2,968
    80006cea:	97a2                	add	a5,a5,s0
    80006cec:	6390                	ld	a2,0(a5)
    80006cee:	fd843583          	ld	a1,-40(s0)
    80006cf2:	6928                	ld	a0,80(a0)
    80006cf4:	929fa0ef          	jal	8000161c <copyout>
    80006cf8:	02054063          	bltz	a0,80006d18 <sys_csread+0xb0>
    return -1;

  return n;
    80006cfc:	8526                	mv	a0,s1
}
    80006cfe:	45010113          	addi	sp,sp,1104
    80006d02:	7e813083          	ld	ra,2024(sp)
    80006d06:	7e013403          	ld	s0,2016(sp)
    80006d0a:	7d813483          	ld	s1,2008(sp)
    80006d0e:	7d013903          	ld	s2,2000(sp)
    80006d12:	7f010113          	addi	sp,sp,2032
    80006d16:	8082                	ret
    return -1;
    80006d18:	557d                	li	a0,-1
    80006d1a:	b7d5                	j	80006cfe <sys_csread+0x96>

0000000080006d1c <sys_memread>:
#include "memevent.h"
#include "memlog.h"

uint64
sys_memread(void)
{
    80006d1c:	95010113          	addi	sp,sp,-1712
    80006d20:	6a113423          	sd	ra,1704(sp)
    80006d24:	6a813023          	sd	s0,1696(sp)
    80006d28:	6b010413          	addi	s0,sp,1712
  uint64 uaddr = 0;
    80006d2c:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80006d30:	fc042a23          	sw	zero,-44(s0)

  argaddr(0, &uaddr);
    80006d34:	fd840593          	addi	a1,s0,-40
    80006d38:	4501                	li	a0,0
    80006d3a:	afffb0ef          	jal	80002838 <argaddr>
  argint(1, &max);
    80006d3e:	fd440593          	addi	a1,s0,-44
    80006d42:	4505                	li	a0,1
    80006d44:	ad9fb0ef          	jal	8000281c <argint>

  if(max <= 0)
    80006d48:	fd442783          	lw	a5,-44(s0)
    return 0;
    80006d4c:	4501                	li	a0,0
  if(max <= 0)
    80006d4e:	04f05363          	blez	a5,80006d94 <sys_memread+0x78>
    80006d52:	68913c23          	sd	s1,1688(sp)
  if(max > 16)
    80006d56:	4741                	li	a4,16
    80006d58:	00f75563          	bge	a4,a5,80006d62 <sys_memread+0x46>
    max = 16;
    80006d5c:	47c1                	li	a5,16
    80006d5e:	fcf42a23          	sw	a5,-44(s0)

  struct mem_event tmp[16];
  int n = memlog_read_many(tmp, max);
    80006d62:	fd442583          	lw	a1,-44(s0)
    80006d66:	95040513          	addi	a0,s0,-1712
    80006d6a:	68b000ef          	jal	80007bf4 <memlog_read_many>
    80006d6e:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct mem_event);
  if(copyout(myproc()->pagetable, uaddr, (char *)tmp, bytes) < 0)
    80006d70:	b99fa0ef          	jal	80001908 <myproc>
    80006d74:	06800693          	li	a3,104
    80006d78:	029686bb          	mulw	a3,a3,s1
    80006d7c:	95040613          	addi	a2,s0,-1712
    80006d80:	fd843583          	ld	a1,-40(s0)
    80006d84:	6928                	ld	a0,80(a0)
    80006d86:	897fa0ef          	jal	8000161c <copyout>
    80006d8a:	00054c63          	bltz	a0,80006da2 <sys_memread+0x86>
    return -1;

  return n;
    80006d8e:	8526                	mv	a0,s1
    80006d90:	69813483          	ld	s1,1688(sp)
    80006d94:	6a813083          	ld	ra,1704(sp)
    80006d98:	6a013403          	ld	s0,1696(sp)
    80006d9c:	6b010113          	addi	sp,sp,1712
    80006da0:	8082                	ret
    return -1;
    80006da2:	557d                	li	a0,-1
    80006da4:	69813483          	ld	s1,1688(sp)
    80006da8:	b7f5                	j	80006d94 <sys_memread+0x78>

0000000080006daa <ringbuf_init>:
  return (void *)(rb->buf + idx * rb->elem_size);
}

void
ringbuf_init(struct ringbuf *rb, char *name, uint elem_size)
{
    80006daa:	1101                	addi	sp,sp,-32
    80006dac:	ec06                	sd	ra,24(sp)
    80006dae:	e822                	sd	s0,16(sp)
    80006db0:	e426                	sd	s1,8(sp)
    80006db2:	e04a                	sd	s2,0(sp)
    80006db4:	1000                	addi	s0,sp,32
    80006db6:	84aa                	mv	s1,a0
    80006db8:	8932                	mv	s2,a2
  initlock(&rb->lock, name);
    80006dba:	dc7f90ef          	jal	80000b80 <initlock>
  rb->head = 0;
    80006dbe:	0004ac23          	sw	zero,24(s1)
  rb->tail = 0;
    80006dc2:	0004ae23          	sw	zero,28(s1)
  rb->count = 0;
    80006dc6:	0204a023          	sw	zero,32(s1)
  rb->seq = 0;
    80006dca:	0204b423          	sd	zero,40(s1)
  rb->elem_size = elem_size;
    80006dce:	0324a223          	sw	s2,36(s1)
}
    80006dd2:	60e2                	ld	ra,24(sp)
    80006dd4:	6442                	ld	s0,16(sp)
    80006dd6:	64a2                	ld	s1,8(sp)
    80006dd8:	6902                	ld	s2,0(sp)
    80006dda:	6105                	addi	sp,sp,32
    80006ddc:	8082                	ret

0000000080006dde <ringbuf_push>:

int
ringbuf_push(struct ringbuf *rb, void *elem)
{
    80006dde:	1101                	addi	sp,sp,-32
    80006de0:	ec06                	sd	ra,24(sp)
    80006de2:	e822                	sd	s0,16(sp)
    80006de4:	e426                	sd	s1,8(sp)
    80006de6:	e04a                	sd	s2,0(sp)
    80006de8:	1000                	addi	s0,sp,32
    80006dea:	84aa                	mv	s1,a0
    80006dec:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006dee:	e13f90ef          	jal	80000c00 <acquire>

  if(rb->count == RB_CAP){
    80006df2:	5098                	lw	a4,32(s1)
    80006df4:	20000793          	li	a5,512
    80006df8:	04f70063          	beq	a4,a5,80006e38 <ringbuf_push+0x5a>
  return (void *)(rb->buf + idx * rb->elem_size);
    80006dfc:	50d0                	lw	a2,36(s1)
    80006dfe:	03048513          	addi	a0,s1,48
    80006e02:	4c9c                	lw	a5,24(s1)
    80006e04:	02c787bb          	mulw	a5,a5,a2
    80006e08:	1782                	slli	a5,a5,0x20
    80006e0a:	9381                	srli	a5,a5,0x20
    rb->tail = (rb->tail + 1) % RB_CAP;
    rb->count--;
  }

  memmove(slot_ptr(rb, rb->head), elem, rb->elem_size);
    80006e0c:	85ca                	mv	a1,s2
    80006e0e:	953e                	add	a0,a0,a5
    80006e10:	f21f90ef          	jal	80000d30 <memmove>
  rb->head = (rb->head + 1) % RB_CAP;
    80006e14:	4c9c                	lw	a5,24(s1)
    80006e16:	2785                	addiw	a5,a5,1
    80006e18:	1ff7f793          	andi	a5,a5,511
    80006e1c:	cc9c                	sw	a5,24(s1)
  rb->count++;
    80006e1e:	509c                	lw	a5,32(s1)
    80006e20:	2785                	addiw	a5,a5,1
    80006e22:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80006e24:	8526                	mv	a0,s1
    80006e26:	e73f90ef          	jal	80000c98 <release>
  return 0;
}
    80006e2a:	4501                	li	a0,0
    80006e2c:	60e2                	ld	ra,24(sp)
    80006e2e:	6442                	ld	s0,16(sp)
    80006e30:	64a2                	ld	s1,8(sp)
    80006e32:	6902                	ld	s2,0(sp)
    80006e34:	6105                	addi	sp,sp,32
    80006e36:	8082                	ret
    rb->tail = (rb->tail + 1) % RB_CAP;
    80006e38:	4cdc                	lw	a5,28(s1)
    80006e3a:	2785                	addiw	a5,a5,1
    80006e3c:	1ff7f793          	andi	a5,a5,511
    80006e40:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80006e42:	1ff00793          	li	a5,511
    80006e46:	d09c                	sw	a5,32(s1)
    80006e48:	bf55                	j	80006dfc <ringbuf_push+0x1e>

0000000080006e4a <ringbuf_read_many>:

int
ringbuf_read_many(struct ringbuf *rb, void *out, int max)
{
    80006e4a:	7139                	addi	sp,sp,-64
    80006e4c:	fc06                	sd	ra,56(sp)
    80006e4e:	f822                	sd	s0,48(sp)
    80006e50:	f04a                	sd	s2,32(sp)
    80006e52:	0080                	addi	s0,sp,64
  int n = 0;
  char *dst = (char *)out;

  if(max <= 0)
    return 0;
    80006e54:	4901                	li	s2,0
  if(max <= 0)
    80006e56:	06c05163          	blez	a2,80006eb8 <ringbuf_read_many+0x6e>
    80006e5a:	f426                	sd	s1,40(sp)
    80006e5c:	ec4e                	sd	s3,24(sp)
    80006e5e:	e852                	sd	s4,16(sp)
    80006e60:	e456                	sd	s5,8(sp)
    80006e62:	84aa                	mv	s1,a0
    80006e64:	8a2e                	mv	s4,a1
    80006e66:	89b2                	mv	s3,a2

  acquire(&rb->lock);
    80006e68:	d99f90ef          	jal	80000c00 <acquire>
  int n = 0;
    80006e6c:	4901                	li	s2,0
  return (void *)(rb->buf + idx * rb->elem_size);
    80006e6e:	03048a93          	addi	s5,s1,48
  while(n < max && rb->count > 0){
    80006e72:	509c                	lw	a5,32(s1)
    80006e74:	cb9d                	beqz	a5,80006eaa <ringbuf_read_many+0x60>
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006e76:	50d0                	lw	a2,36(s1)
  return (void *)(rb->buf + idx * rb->elem_size);
    80006e78:	4ccc                	lw	a1,28(s1)
    80006e7a:	02c585bb          	mulw	a1,a1,a2
    80006e7e:	1582                	slli	a1,a1,0x20
    80006e80:	9181                	srli	a1,a1,0x20
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006e82:	02c9053b          	mulw	a0,s2,a2
    80006e86:	1502                	slli	a0,a0,0x20
    80006e88:	9101                	srli	a0,a0,0x20
    80006e8a:	95d6                	add	a1,a1,s5
    80006e8c:	9552                	add	a0,a0,s4
    80006e8e:	ea3f90ef          	jal	80000d30 <memmove>
    rb->tail = (rb->tail + 1) % RB_CAP;
    80006e92:	4cdc                	lw	a5,28(s1)
    80006e94:	2785                	addiw	a5,a5,1
    80006e96:	1ff7f793          	andi	a5,a5,511
    80006e9a:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80006e9c:	509c                	lw	a5,32(s1)
    80006e9e:	37fd                	addiw	a5,a5,-1
    80006ea0:	d09c                	sw	a5,32(s1)
    n++;
    80006ea2:	2905                	addiw	s2,s2,1
  while(n < max && rb->count > 0){
    80006ea4:	fd2997e3          	bne	s3,s2,80006e72 <ringbuf_read_many+0x28>
    80006ea8:	894e                	mv	s2,s3
  }
  release(&rb->lock);
    80006eaa:	8526                	mv	a0,s1
    80006eac:	dedf90ef          	jal	80000c98 <release>

  return n;
    80006eb0:	74a2                	ld	s1,40(sp)
    80006eb2:	69e2                	ld	s3,24(sp)
    80006eb4:	6a42                	ld	s4,16(sp)
    80006eb6:	6aa2                	ld	s5,8(sp)
}
    80006eb8:	854a                	mv	a0,s2
    80006eba:	70e2                	ld	ra,56(sp)
    80006ebc:	7442                	ld	s0,48(sp)
    80006ebe:	7902                	ld	s2,32(sp)
    80006ec0:	6121                	addi	sp,sp,64
    80006ec2:	8082                	ret

0000000080006ec4 <ringbuf_pop>:

int
ringbuf_pop(struct ringbuf *rb, void *dst)
{
    80006ec4:	1101                	addi	sp,sp,-32
    80006ec6:	ec06                	sd	ra,24(sp)
    80006ec8:	e822                	sd	s0,16(sp)
    80006eca:	e426                	sd	s1,8(sp)
    80006ecc:	e04a                	sd	s2,0(sp)
    80006ece:	1000                	addi	s0,sp,32
    80006ed0:	84aa                	mv	s1,a0
    80006ed2:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006ed4:	d2df90ef          	jal	80000c00 <acquire>

  if(rb->count == 0){
    80006ed8:	509c                	lw	a5,32(s1)
    80006eda:	cf9d                	beqz	a5,80006f18 <ringbuf_pop+0x54>
  return (void *)(rb->buf + idx * rb->elem_size);
    80006edc:	50d0                	lw	a2,36(s1)
    80006ede:	03048593          	addi	a1,s1,48
    80006ee2:	4cdc                	lw	a5,28(s1)
    80006ee4:	02c787bb          	mulw	a5,a5,a2
    80006ee8:	1782                	slli	a5,a5,0x20
    80006eea:	9381                	srli	a5,a5,0x20
    release(&rb->lock);
    return -1;
  }

  memmove(dst, slot_ptr(rb, rb->tail), rb->elem_size);
    80006eec:	95be                	add	a1,a1,a5
    80006eee:	854a                	mv	a0,s2
    80006ef0:	e41f90ef          	jal	80000d30 <memmove>
  rb->tail = (rb->tail + 1) % RB_CAP;
    80006ef4:	4cdc                	lw	a5,28(s1)
    80006ef6:	2785                	addiw	a5,a5,1
    80006ef8:	1ff7f793          	andi	a5,a5,511
    80006efc:	ccdc                	sw	a5,28(s1)
  rb->count--;
    80006efe:	509c                	lw	a5,32(s1)
    80006f00:	37fd                	addiw	a5,a5,-1
    80006f02:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80006f04:	8526                	mv	a0,s1
    80006f06:	d93f90ef          	jal	80000c98 <release>
  return 0;
    80006f0a:	4501                	li	a0,0
    80006f0c:	60e2                	ld	ra,24(sp)
    80006f0e:	6442                	ld	s0,16(sp)
    80006f10:	64a2                	ld	s1,8(sp)
    80006f12:	6902                	ld	s2,0(sp)
    80006f14:	6105                	addi	sp,sp,32
    80006f16:	8082                	ret
    release(&rb->lock);
    80006f18:	8526                	mv	a0,s1
    80006f1a:	d7ff90ef          	jal	80000c98 <release>
    return -1;
    80006f1e:	557d                	li	a0,-1
    80006f20:	b7f5                	j	80006f0c <ringbuf_pop+0x48>

0000000080006f22 <fill_fs_common>:
#include "fslog.h"
static struct ringbuf fs_rb;
static uint64 fs_seq = 0;
static void
fill_fs_common(struct fs_event *e)
{
    80006f22:	1101                	addi	sp,sp,-32
    80006f24:	ec06                	sd	ra,24(sp)
    80006f26:	e822                	sd	s0,16(sp)
    80006f28:	e426                	sd	s1,8(sp)
    80006f2a:	1000                	addi	s0,sp,32
    80006f2c:	84aa                	mv	s1,a0
  memset(e, 0, sizeof(*e));
    80006f2e:	20000613          	li	a2,512
    80006f32:	4581                	li	a1,0
    80006f34:	da1f90ef          	jal	80000cd4 <memset>
  e->ticks = ticks;
    80006f38:	00003797          	auipc	a5,0x3
    80006f3c:	1107a783          	lw	a5,272(a5) # 8000a048 <ticks>
    80006f40:	c49c                	sw	a5,8(s1)
  e->pid = myproc() ? myproc()->pid : 0;
    80006f42:	9c7fa0ef          	jal	80001908 <myproc>
    80006f46:	4781                	li	a5,0
    80006f48:	c501                	beqz	a0,80006f50 <fill_fs_common+0x2e>
    80006f4a:	9bffa0ef          	jal	80001908 <myproc>
    80006f4e:	591c                	lw	a5,48(a0)
    80006f50:	c4dc                	sw	a5,12(s1)
}
    80006f52:	60e2                	ld	ra,24(sp)
    80006f54:	6442                	ld	s0,16(sp)
    80006f56:	64a2                	ld	s1,8(sp)
    80006f58:	6105                	addi	sp,sp,32
    80006f5a:	8082                	ret

0000000080006f5c <fslog_init>:

void
fslog_init(void)
{
    80006f5c:	1141                	addi	sp,sp,-16
    80006f5e:	e406                	sd	ra,8(sp)
    80006f60:	e022                	sd	s0,0(sp)
    80006f62:	0800                	addi	s0,sp,16
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
    80006f64:	20000613          	li	a2,512
    80006f68:	00003597          	auipc	a1,0x3
    80006f6c:	f0058593          	addi	a1,a1,-256 # 80009e68 <etext+0xe68>
    80006f70:	0003c517          	auipc	a0,0x3c
    80006f74:	47850513          	addi	a0,a0,1144 # 800433e8 <fs_rb>
    80006f78:	e33ff0ef          	jal	80006daa <ringbuf_init>
  printf("FS sizeof(fs_event)=%ld RB_MAX_ELEM=%d\n", sizeof(struct fs_event), RB_MAX_ELEM);
    80006f7c:	10000613          	li	a2,256
    80006f80:	20000593          	li	a1,512
    80006f84:	00003517          	auipc	a0,0x3
    80006f88:	eec50513          	addi	a0,a0,-276 # 80009e70 <etext+0xe70>
    80006f8c:	da0f90ef          	jal	8000052c <printf>
}
    80006f90:	60a2                	ld	ra,8(sp)
    80006f92:	6402                	ld	s0,0(sp)
    80006f94:	0141                	addi	sp,sp,16
    80006f96:	8082                	ret

0000000080006f98 <fslog_push>:

void
fslog_push(struct fs_event *e)
{ e->seq = ++fs_seq;
    80006f98:	1141                	addi	sp,sp,-16
    80006f9a:	e406                	sd	ra,8(sp)
    80006f9c:	e022                	sd	s0,0(sp)
    80006f9e:	0800                	addi	s0,sp,16
    80006fa0:	85aa                	mv	a1,a0
    80006fa2:	00003717          	auipc	a4,0x3
    80006fa6:	0b670713          	addi	a4,a4,182 # 8000a058 <fs_seq>
    80006faa:	631c                	ld	a5,0(a4)
    80006fac:	0785                	addi	a5,a5,1
    80006fae:	e31c                	sd	a5,0(a4)
    80006fb0:	e11c                	sd	a5,0(a0)
  ringbuf_push(&fs_rb, e);
    80006fb2:	0003c517          	auipc	a0,0x3c
    80006fb6:	43650513          	addi	a0,a0,1078 # 800433e8 <fs_rb>
    80006fba:	e25ff0ef          	jal	80006dde <ringbuf_push>
}
    80006fbe:	60a2                	ld	ra,8(sp)
    80006fc0:	6402                	ld	s0,0(sp)
    80006fc2:	0141                	addi	sp,sp,16
    80006fc4:	8082                	ret

0000000080006fc6 <fslog_read_many>:
int
fslog_read_many(struct fs_event *out, int max)
{
    80006fc6:	dc010113          	addi	sp,sp,-576
    80006fca:	22113c23          	sd	ra,568(sp)
    80006fce:	22813823          	sd	s0,560(sp)
    80006fd2:	22913423          	sd	s1,552(sp)
    80006fd6:	23213023          	sd	s2,544(sp)
    80006fda:	21313c23          	sd	s3,536(sp)
    80006fde:	0480                	addi	s0,sp,576
    80006fe0:	84aa                	mv	s1,a0
    80006fe2:	89ae                	mv	s3,a1
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
    80006fe4:	925fa0ef          	jal	80001908 <myproc>
  while(count < max){
    80006fe8:	05305863          	blez	s3,80007038 <fslog_read_many+0x72>
    80006fec:	21413823          	sd	s4,528(sp)
    80006ff0:	21513423          	sd	s5,520(sp)
    80006ff4:	8a2a                	mv	s4,a0
  int count = 0;
    80006ff6:	4901                	li	s2,0
    if(ringbuf_pop(&fs_rb, &e) != 0)
    80006ff8:	0003ca97          	auipc	s5,0x3c
    80006ffc:	3f0a8a93          	addi	s5,s5,1008 # 800433e8 <fs_rb>
    80007000:	dc040593          	addi	a1,s0,-576
    80007004:	8556                	mv	a0,s5
    80007006:	ebfff0ef          	jal	80006ec4 <ringbuf_pop>
    8000700a:	e90d                	bnez	a0,8000703c <fslog_read_many+0x76>
      break;

    uint64 dst = (uint64)out + count * sizeof(struct fs_event);

    if(copyout(p->pagetable, dst, (char *)&e, sizeof(struct fs_event)) < 0)
    8000700c:	20000693          	li	a3,512
    80007010:	dc040613          	addi	a2,s0,-576
    80007014:	85a6                	mv	a1,s1
    80007016:	050a3503          	ld	a0,80(s4)
    8000701a:	e02fa0ef          	jal	8000161c <copyout>
    8000701e:	04054163          	bltz	a0,80007060 <fslog_read_many+0x9a>
      break;

    count++;
    80007022:	2905                	addiw	s2,s2,1
  while(count < max){
    80007024:	20048493          	addi	s1,s1,512
    80007028:	fd299ce3          	bne	s3,s2,80007000 <fslog_read_many+0x3a>
    8000702c:	894e                	mv	s2,s3
    8000702e:	21013a03          	ld	s4,528(sp)
    80007032:	20813a83          	ld	s5,520(sp)
    80007036:	a039                	j	80007044 <fslog_read_many+0x7e>
  int count = 0;
    80007038:	4901                	li	s2,0
    8000703a:	a029                	j	80007044 <fslog_read_many+0x7e>
    8000703c:	21013a03          	ld	s4,528(sp)
    80007040:	20813a83          	ld	s5,520(sp)
  }

  return count;
}
    80007044:	854a                	mv	a0,s2
    80007046:	23813083          	ld	ra,568(sp)
    8000704a:	23013403          	ld	s0,560(sp)
    8000704e:	22813483          	ld	s1,552(sp)
    80007052:	22013903          	ld	s2,544(sp)
    80007056:	21813983          	ld	s3,536(sp)
    8000705a:	24010113          	addi	sp,sp,576
    8000705e:	8082                	ret
    80007060:	21013a03          	ld	s4,528(sp)
    80007064:	20813a83          	ld	s5,520(sp)
    80007068:	bff1                	j	80007044 <fslog_read_many+0x7e>

000000008000706a <fslog_bread_req>:
void
fslog_bread_req(int dev, int blockno)
{
    8000706a:	de010113          	addi	sp,sp,-544
    8000706e:	20113c23          	sd	ra,536(sp)
    80007072:	20813823          	sd	s0,528(sp)
    80007076:	20913423          	sd	s1,520(sp)
    8000707a:	21213023          	sd	s2,512(sp)
    8000707e:	1400                	addi	s0,sp,544
    80007080:	892a                	mv	s2,a0
    80007082:	84ae                	mv	s1,a1
  struct fs_event e;
  fill_fs_common(&e);
    80007084:	de040513          	addi	a0,s0,-544
    80007088:	e9bff0ef          	jal	80006f22 <fill_fs_common>
  e.type = FS_BREAD_REQ;
    8000708c:	47a9                	li	a5,10
    8000708e:	def42823          	sw	a5,-528(s0)
  e.dev = dev;
    80007092:	eb242823          	sw	s2,-336(s0)
  e.blockno = blockno;
    80007096:	ea942223          	sw	s1,-348(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    8000709a:	02000613          	li	a2,32
    8000709e:	00003597          	auipc	a1,0x3
    800070a2:	dfa58593          	addi	a1,a1,-518 # 80009e98 <etext+0xe98>
    800070a6:	e8440513          	addi	a0,s0,-380
    800070aa:	d69f90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    800070ae:	de040513          	addi	a0,s0,-544
    800070b2:	ee7ff0ef          	jal	80006f98 <fslog_push>
}
    800070b6:	21813083          	ld	ra,536(sp)
    800070ba:	21013403          	ld	s0,528(sp)
    800070be:	20813483          	ld	s1,520(sp)
    800070c2:	20013903          	ld	s2,512(sp)
    800070c6:	22010113          	addi	sp,sp,544
    800070ca:	8082                	ret

00000000800070cc <fslog_bget_scan>:
void
fslog_bget_scan(int dev, int blockno, int buf_id,
                int refcnt, int valid, int lru_pos,
                int scan_dir, int scan_step, int found)
{
    800070cc:	db010113          	addi	sp,sp,-592
    800070d0:	24113423          	sd	ra,584(sp)
    800070d4:	24813023          	sd	s0,576(sp)
    800070d8:	22913c23          	sd	s1,568(sp)
    800070dc:	23213823          	sd	s2,560(sp)
    800070e0:	23313423          	sd	s3,552(sp)
    800070e4:	23413023          	sd	s4,544(sp)
    800070e8:	21513c23          	sd	s5,536(sp)
    800070ec:	21613823          	sd	s6,528(sp)
    800070f0:	21713423          	sd	s7,520(sp)
    800070f4:	21813023          	sd	s8,512(sp)
    800070f8:	0c80                	addi	s0,sp,592
    800070fa:	8c2a                	mv	s8,a0
    800070fc:	8bae                	mv	s7,a1
    800070fe:	8b32                	mv	s6,a2
    80007100:	89b6                	mv	s3,a3
    80007102:	893a                	mv	s2,a4
    80007104:	84be                	mv	s1,a5
    80007106:	8ac2                	mv	s5,a6
    80007108:	8a46                	mv	s4,a7
  struct fs_event e;
  fill_fs_common(&e);
    8000710a:	db040513          	addi	a0,s0,-592
    8000710e:	e15ff0ef          	jal	80006f22 <fill_fs_common>
  e.type = FS_BGET_SCAN;
    80007112:	47ad                	li	a5,11
    80007114:	dcf42023          	sw	a5,-576(s0)
  e.dev = dev;
    80007118:	e9842023          	sw	s8,-384(s0)
  e.blockno = blockno;
    8000711c:	e7742a23          	sw	s7,-396(s0)
  e.buf_id = buf_id;
    80007120:	e9642223          	sw	s6,-380(s0)
  e.ref_before = refcnt;
    80007124:	e9342c23          	sw	s3,-360(s0)
  e.ref_after = refcnt;
    80007128:	e9342e23          	sw	s3,-356(s0)
  e.valid_before = valid;
    8000712c:	eb242023          	sw	s2,-352(s0)
  e.valid_after = valid;
    80007130:	eb242223          	sw	s2,-348(s0)
  e.lru_before = lru_pos;
    80007134:	ea942823          	sw	s1,-336(s0)
  e.lru_after = lru_pos;
    80007138:	ea942a23          	sw	s1,-332(s0)
  e.scan_dir = scan_dir;
    8000713c:	eb542c23          	sw	s5,-328(s0)
  e.scan_step = scan_step;
    80007140:	eb442e23          	sw	s4,-324(s0)
  e.found = found;
    80007144:	401c                	lw	a5,0(s0)
    80007146:	ecf42023          	sw	a5,-320(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    8000714a:	02000613          	li	a2,32
    8000714e:	00003597          	auipc	a1,0x3
    80007152:	d4a58593          	addi	a1,a1,-694 # 80009e98 <etext+0xe98>
    80007156:	e5440513          	addi	a0,s0,-428
    8000715a:	cb9f90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    8000715e:	db040513          	addi	a0,s0,-592
    80007162:	e37ff0ef          	jal	80006f98 <fslog_push>
}
    80007166:	24813083          	ld	ra,584(sp)
    8000716a:	24013403          	ld	s0,576(sp)
    8000716e:	23813483          	ld	s1,568(sp)
    80007172:	23013903          	ld	s2,560(sp)
    80007176:	22813983          	ld	s3,552(sp)
    8000717a:	22013a03          	ld	s4,544(sp)
    8000717e:	21813a83          	ld	s5,536(sp)
    80007182:	21013b03          	ld	s6,528(sp)
    80007186:	20813b83          	ld	s7,520(sp)
    8000718a:	20013c03          	ld	s8,512(sp)
    8000718e:	25010113          	addi	sp,sp,592
    80007192:	8082                	ret

0000000080007194 <fslog_bget_hit>:
void
fslog_bget_hit(int dev, int blockno, int buf_id,
               int ref_before, int ref_after,
               int valid,
               int lru_pos)
{
    80007194:	db010113          	addi	sp,sp,-592
    80007198:	24113423          	sd	ra,584(sp)
    8000719c:	24813023          	sd	s0,576(sp)
    800071a0:	22913c23          	sd	s1,568(sp)
    800071a4:	23213823          	sd	s2,560(sp)
    800071a8:	23313423          	sd	s3,552(sp)
    800071ac:	23413023          	sd	s4,544(sp)
    800071b0:	21513c23          	sd	s5,536(sp)
    800071b4:	21613823          	sd	s6,528(sp)
    800071b8:	21713423          	sd	s7,520(sp)
    800071bc:	0c80                	addi	s0,sp,592
    800071be:	8baa                	mv	s7,a0
    800071c0:	8b2e                	mv	s6,a1
    800071c2:	8ab2                	mv	s5,a2
    800071c4:	8a36                	mv	s4,a3
    800071c6:	89ba                	mv	s3,a4
    800071c8:	893e                	mv	s2,a5
    800071ca:	84c2                	mv	s1,a6
  struct fs_event e;
  fill_fs_common(&e);
    800071cc:	db040513          	addi	a0,s0,-592
    800071d0:	d53ff0ef          	jal	80006f22 <fill_fs_common>
  e.type = FS_BGET_HIT;
    800071d4:	4799                	li	a5,6
    800071d6:	dcf42023          	sw	a5,-576(s0)
  e.dev = dev;
    800071da:	e9742023          	sw	s7,-384(s0)
  e.blockno = blockno;
    800071de:	e7642a23          	sw	s6,-396(s0)
  e.buf_id = buf_id;
    800071e2:	e9542223          	sw	s5,-380(s0)
  e.ref_before = ref_before;
    800071e6:	e9442c23          	sw	s4,-360(s0)
  e.ref_after = ref_after;
    800071ea:	e9342e23          	sw	s3,-356(s0)
  e.valid_before = valid;
    800071ee:	eb242023          	sw	s2,-352(s0)
  e.valid_after = valid;
    800071f2:	eb242223          	sw	s2,-348(s0)
  e.locked_before = 0;
    800071f6:	ea042423          	sw	zero,-344(s0)
  e.locked_after = 1;
    800071fa:	4785                	li	a5,1
    800071fc:	eaf42623          	sw	a5,-340(s0)
  e.lru_before = lru_pos;
    80007200:	ea942823          	sw	s1,-336(s0)
  e.lru_after = lru_pos;
    80007204:	ea942a23          	sw	s1,-332(s0)
  e.found = 1;
    80007208:	ecf42023          	sw	a5,-320(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    8000720c:	02000613          	li	a2,32
    80007210:	00003597          	auipc	a1,0x3
    80007214:	c8858593          	addi	a1,a1,-888 # 80009e98 <etext+0xe98>
    80007218:	e5440513          	addi	a0,s0,-428
    8000721c:	bf7f90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    80007220:	db040513          	addi	a0,s0,-592
    80007224:	d75ff0ef          	jal	80006f98 <fslog_push>
}
    80007228:	24813083          	ld	ra,584(sp)
    8000722c:	24013403          	ld	s0,576(sp)
    80007230:	23813483          	ld	s1,568(sp)
    80007234:	23013903          	ld	s2,560(sp)
    80007238:	22813983          	ld	s3,552(sp)
    8000723c:	22013a03          	ld	s4,544(sp)
    80007240:	21813a83          	ld	s5,536(sp)
    80007244:	21013b03          	ld	s6,528(sp)
    80007248:	20813b83          	ld	s7,520(sp)
    8000724c:	25010113          	addi	sp,sp,592
    80007250:	8082                	ret

0000000080007252 <fslog_bget_miss>:
void
fslog_bget_miss(int dev, int blockno, int old_blockno, int buf_id,
                int old_valid,
                int lru_pos)
{
    80007252:	dc010113          	addi	sp,sp,-576
    80007256:	22113c23          	sd	ra,568(sp)
    8000725a:	22813823          	sd	s0,560(sp)
    8000725e:	22913423          	sd	s1,552(sp)
    80007262:	23213023          	sd	s2,544(sp)
    80007266:	21313c23          	sd	s3,536(sp)
    8000726a:	21413823          	sd	s4,528(sp)
    8000726e:	21513423          	sd	s5,520(sp)
    80007272:	21613023          	sd	s6,512(sp)
    80007276:	0480                	addi	s0,sp,576
    80007278:	8b2a                	mv	s6,a0
    8000727a:	8aae                	mv	s5,a1
    8000727c:	8a32                	mv	s4,a2
    8000727e:	89b6                	mv	s3,a3
    80007280:	893a                	mv	s2,a4
    80007282:	84be                	mv	s1,a5
  struct fs_event e;
  fill_fs_common(&e);
    80007284:	dc040513          	addi	a0,s0,-576
    80007288:	c9bff0ef          	jal	80006f22 <fill_fs_common>
  e.type = FS_BGET_MISS;
    8000728c:	479d                	li	a5,7
    8000728e:	dcf42823          	sw	a5,-560(s0)
  e.dev = dev;
    80007292:	e9642823          	sw	s6,-368(s0)
  e.blockno = blockno;
    80007296:	e9542223          	sw	s5,-380(s0)
  e.old_blockno = old_blockno;
    8000729a:	e9442423          	sw	s4,-376(s0)
  e.buf_id = buf_id;
    8000729e:	e9342a23          	sw	s3,-364(s0)
  e.ref_before = 0;
    800072a2:	ea042423          	sw	zero,-344(s0)
  e.ref_after = 1;
    800072a6:	4785                	li	a5,1
    800072a8:	eaf42623          	sw	a5,-340(s0)
  e.valid_before = old_valid;
    800072ac:	eb242823          	sw	s2,-336(s0)
  e.valid_after = 0;
    800072b0:	ea042a23          	sw	zero,-332(s0)
  e.locked_before = 0;
    800072b4:	ea042c23          	sw	zero,-328(s0)
  e.locked_after = 1;
    800072b8:	eaf42e23          	sw	a5,-324(s0)
  e.lru_before = lru_pos;
    800072bc:	ec942023          	sw	s1,-320(s0)
  e.lru_after = lru_pos;
    800072c0:	ec942223          	sw	s1,-316(s0)
  e.found = 1;
    800072c4:	ecf42823          	sw	a5,-304(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    800072c8:	02000613          	li	a2,32
    800072cc:	00003597          	auipc	a1,0x3
    800072d0:	bcc58593          	addi	a1,a1,-1076 # 80009e98 <etext+0xe98>
    800072d4:	e6440513          	addi	a0,s0,-412
    800072d8:	b3bf90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    800072dc:	dc040513          	addi	a0,s0,-576
    800072e0:	cb9ff0ef          	jal	80006f98 <fslog_push>
}
    800072e4:	23813083          	ld	ra,568(sp)
    800072e8:	23013403          	ld	s0,560(sp)
    800072ec:	22813483          	ld	s1,552(sp)
    800072f0:	22013903          	ld	s2,544(sp)
    800072f4:	21813983          	ld	s3,536(sp)
    800072f8:	21013a03          	ld	s4,528(sp)
    800072fc:	20813a83          	ld	s5,520(sp)
    80007300:	20013b03          	ld	s6,512(sp)
    80007304:	24010113          	addi	sp,sp,576
    80007308:	8082                	ret

000000008000730a <fslog_bread_fill>:
void
fslog_bread_fill(int dev, int blockno, int buf_id,
                 int refcnt, int lru_pos)
{
    8000730a:	dc010113          	addi	sp,sp,-576
    8000730e:	22113c23          	sd	ra,568(sp)
    80007312:	22813823          	sd	s0,560(sp)
    80007316:	22913423          	sd	s1,552(sp)
    8000731a:	23213023          	sd	s2,544(sp)
    8000731e:	21313c23          	sd	s3,536(sp)
    80007322:	21413823          	sd	s4,528(sp)
    80007326:	21513423          	sd	s5,520(sp)
    8000732a:	0480                	addi	s0,sp,576
    8000732c:	8aaa                	mv	s5,a0
    8000732e:	8a2e                	mv	s4,a1
    80007330:	89b2                	mv	s3,a2
    80007332:	8936                	mv	s2,a3
    80007334:	84ba                	mv	s1,a4
  struct fs_event e;
  fill_fs_common(&e);
    80007336:	dc040513          	addi	a0,s0,-576
    8000733a:	be9ff0ef          	jal	80006f22 <fill_fs_common>
  e.type = FS_BREAD_FILL;
    8000733e:	47b1                	li	a5,12
    80007340:	dcf42823          	sw	a5,-560(s0)
  e.dev = dev;
    80007344:	e9542823          	sw	s5,-368(s0)
  e.blockno = blockno;
    80007348:	e9442223          	sw	s4,-380(s0)
  e.buf_id = buf_id;
    8000734c:	e9342a23          	sw	s3,-364(s0)
  e.ref_before = refcnt;
    80007350:	eb242423          	sw	s2,-344(s0)
  e.ref_after = refcnt;
    80007354:	eb242623          	sw	s2,-340(s0)
  e.valid_before = 0;
    80007358:	ea042823          	sw	zero,-336(s0)
  e.valid_after = 1;
    8000735c:	4785                	li	a5,1
    8000735e:	eaf42a23          	sw	a5,-332(s0)
  e.locked_before = 1;
    80007362:	eaf42c23          	sw	a5,-328(s0)
  e.locked_after = 1;
    80007366:	eaf42e23          	sw	a5,-324(s0)
  e.lru_before = lru_pos;
    8000736a:	ec942023          	sw	s1,-320(s0)
  e.lru_after = lru_pos;
    8000736e:	ec942223          	sw	s1,-316(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    80007372:	02000613          	li	a2,32
    80007376:	00003597          	auipc	a1,0x3
    8000737a:	b2258593          	addi	a1,a1,-1246 # 80009e98 <etext+0xe98>
    8000737e:	e6440513          	addi	a0,s0,-412
    80007382:	a91f90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    80007386:	dc040513          	addi	a0,s0,-576
    8000738a:	c0fff0ef          	jal	80006f98 <fslog_push>
}
    8000738e:	23813083          	ld	ra,568(sp)
    80007392:	23013403          	ld	s0,560(sp)
    80007396:	22813483          	ld	s1,552(sp)
    8000739a:	22013903          	ld	s2,544(sp)
    8000739e:	21813983          	ld	s3,536(sp)
    800073a2:	21013a03          	ld	s4,528(sp)
    800073a6:	20813a83          	ld	s5,520(sp)
    800073aa:	24010113          	addi	sp,sp,576
    800073ae:	8082                	ret

00000000800073b0 <fslog_bwrite_ev>:
void
fslog_bwrite_ev(int dev, int blockno, int buf_id,
                int refcnt, int valid, int lru_pos)
{
    800073b0:	dc010113          	addi	sp,sp,-576
    800073b4:	22113c23          	sd	ra,568(sp)
    800073b8:	22813823          	sd	s0,560(sp)
    800073bc:	22913423          	sd	s1,552(sp)
    800073c0:	23213023          	sd	s2,544(sp)
    800073c4:	21313c23          	sd	s3,536(sp)
    800073c8:	21413823          	sd	s4,528(sp)
    800073cc:	21513423          	sd	s5,520(sp)
    800073d0:	21613023          	sd	s6,512(sp)
    800073d4:	0480                	addi	s0,sp,576
    800073d6:	8b2a                	mv	s6,a0
    800073d8:	8aae                	mv	s5,a1
    800073da:	8a32                	mv	s4,a2
    800073dc:	89b6                	mv	s3,a3
    800073de:	893a                	mv	s2,a4
    800073e0:	84be                	mv	s1,a5
  struct fs_event e;
  fill_fs_common(&e);
    800073e2:	dc040513          	addi	a0,s0,-576
    800073e6:	b3dff0ef          	jal	80006f22 <fill_fs_common>
  e.type = FS_BWRITE;
    800073ea:	47b5                	li	a5,13
    800073ec:	dcf42823          	sw	a5,-560(s0)
  e.dev = dev;
    800073f0:	e9642823          	sw	s6,-368(s0)
  e.blockno = blockno;
    800073f4:	e9542223          	sw	s5,-380(s0)
  e.buf_id = buf_id;
    800073f8:	e9442a23          	sw	s4,-364(s0)
  e.ref_before = refcnt;
    800073fc:	eb342423          	sw	s3,-344(s0)
  e.ref_after = refcnt;
    80007400:	eb342623          	sw	s3,-340(s0)
  e.valid_before = valid;
    80007404:	eb242823          	sw	s2,-336(s0)
  e.valid_after = valid;
    80007408:	eb242a23          	sw	s2,-332(s0)
  e.locked_before = 1;
    8000740c:	4785                	li	a5,1
    8000740e:	eaf42c23          	sw	a5,-328(s0)
  e.locked_after = 1;
    80007412:	eaf42e23          	sw	a5,-324(s0)
  e.lru_before = lru_pos;
    80007416:	ec942023          	sw	s1,-320(s0)
  e.lru_after = lru_pos;
    8000741a:	ec942223          	sw	s1,-316(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    8000741e:	02000613          	li	a2,32
    80007422:	00003597          	auipc	a1,0x3
    80007426:	a7658593          	addi	a1,a1,-1418 # 80009e98 <etext+0xe98>
    8000742a:	e6440513          	addi	a0,s0,-412
    8000742e:	9e5f90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    80007432:	dc040513          	addi	a0,s0,-576
    80007436:	b63ff0ef          	jal	80006f98 <fslog_push>
}
    8000743a:	23813083          	ld	ra,568(sp)
    8000743e:	23013403          	ld	s0,560(sp)
    80007442:	22813483          	ld	s1,552(sp)
    80007446:	22013903          	ld	s2,544(sp)
    8000744a:	21813983          	ld	s3,536(sp)
    8000744e:	21013a03          	ld	s4,528(sp)
    80007452:	20813a83          	ld	s5,520(sp)
    80007456:	20013b03          	ld	s6,512(sp)
    8000745a:	24010113          	addi	sp,sp,576
    8000745e:	8082                	ret

0000000080007460 <fslog_brelease_ev>:
void
fslog_brelease_ev(int dev, int blockno, int buf_id,
                  int ref_before, int ref_after,
                  int valid,
                  int lru_before, int lru_after)
{
    80007460:	db010113          	addi	sp,sp,-592
    80007464:	24113423          	sd	ra,584(sp)
    80007468:	24813023          	sd	s0,576(sp)
    8000746c:	22913c23          	sd	s1,568(sp)
    80007470:	23213823          	sd	s2,560(sp)
    80007474:	23313423          	sd	s3,552(sp)
    80007478:	23413023          	sd	s4,544(sp)
    8000747c:	21513c23          	sd	s5,536(sp)
    80007480:	21613823          	sd	s6,528(sp)
    80007484:	21713423          	sd	s7,520(sp)
    80007488:	21813023          	sd	s8,512(sp)
    8000748c:	0c80                	addi	s0,sp,592
    8000748e:	8c2a                	mv	s8,a0
    80007490:	8bae                	mv	s7,a1
    80007492:	8b32                	mv	s6,a2
    80007494:	8ab6                	mv	s5,a3
    80007496:	8a3a                	mv	s4,a4
    80007498:	84be                	mv	s1,a5
    8000749a:	89c2                	mv	s3,a6
    8000749c:	8946                	mv	s2,a7
  struct fs_event e;
  fill_fs_common(&e);
    8000749e:	db040513          	addi	a0,s0,-592
    800074a2:	a81ff0ef          	jal	80006f22 <fill_fs_common>
  e.type = FS_BRELEASE;
    800074a6:	47a1                	li	a5,8
    800074a8:	dcf42023          	sw	a5,-576(s0)
  e.dev = dev;
    800074ac:	e9842023          	sw	s8,-384(s0)
  e.blockno = blockno;
    800074b0:	e7742a23          	sw	s7,-396(s0)
  e.buf_id = buf_id;
    800074b4:	e9642223          	sw	s6,-380(s0)
  e.ref_before = ref_before;
    800074b8:	e9542c23          	sw	s5,-360(s0)
  e.ref_after = ref_after;
    800074bc:	e9442e23          	sw	s4,-356(s0)
  e.valid_before = valid;
    800074c0:	ea942023          	sw	s1,-352(s0)
  e.valid_after = valid;
    800074c4:	ea942223          	sw	s1,-348(s0)
  e.locked_before = 1;
    800074c8:	4785                	li	a5,1
    800074ca:	eaf42423          	sw	a5,-344(s0)
  e.locked_after = 0;
    800074ce:	ea042623          	sw	zero,-340(s0)
  e.lru_before = lru_before;
    800074d2:	eb342823          	sw	s3,-336(s0)
  e.lru_after = lru_after;
    800074d6:	eb242a23          	sw	s2,-332(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    800074da:	02000613          	li	a2,32
    800074de:	00003597          	auipc	a1,0x3
    800074e2:	9ba58593          	addi	a1,a1,-1606 # 80009e98 <etext+0xe98>
    800074e6:	e5440513          	addi	a0,s0,-428
    800074ea:	929f90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    800074ee:	db040513          	addi	a0,s0,-592
    800074f2:	aa7ff0ef          	jal	80006f98 <fslog_push>
}
    800074f6:	24813083          	ld	ra,584(sp)
    800074fa:	24013403          	ld	s0,576(sp)
    800074fe:	23813483          	ld	s1,568(sp)
    80007502:	23013903          	ld	s2,560(sp)
    80007506:	22813983          	ld	s3,552(sp)
    8000750a:	22013a03          	ld	s4,544(sp)
    8000750e:	21813a83          	ld	s5,536(sp)
    80007512:	21013b03          	ld	s6,528(sp)
    80007516:	20813b83          	ld	s7,520(sp)
    8000751a:	20013c03          	ld	s8,512(sp)
    8000751e:	25010113          	addi	sp,sp,592
    80007522:	8082                	ret

0000000080007524 <fslog_begin>:
void fslog_begin(int before, int after){
    80007524:	de010113          	addi	sp,sp,-544
    80007528:	20113c23          	sd	ra,536(sp)
    8000752c:	20813823          	sd	s0,528(sp)
    80007530:	20913423          	sd	s1,520(sp)
    80007534:	21213023          	sd	s2,512(sp)
    80007538:	1400                	addi	s0,sp,544
    8000753a:	892a                	mv	s2,a0
    8000753c:	84ae                	mv	s1,a1
  struct fs_event e;
  fill_fs_common(&e);
    8000753e:	de040513          	addi	a0,s0,-544
    80007542:	9e1ff0ef          	jal	80006f22 <fill_fs_common>

  e.type = FS_LOG_BEGIN;
    80007546:	47b9                	li	a5,14
    80007548:	def42823          	sw	a5,-528(s0)
  e.ref_before = before;
    8000754c:	ed242423          	sw	s2,-312(s0)
  e.ref_after = after;
    80007550:	ec942623          	sw	s1,-308(s0)

  safestrcpy(e.name, "LOG", FS_NM);
    80007554:	02000613          	li	a2,32
    80007558:	00003597          	auipc	a1,0x3
    8000755c:	94858593          	addi	a1,a1,-1720 # 80009ea0 <etext+0xea0>
    80007560:	e8440513          	addi	a0,s0,-380
    80007564:	8aff90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    80007568:	de040513          	addi	a0,s0,-544
    8000756c:	a2dff0ef          	jal	80006f98 <fslog_push>
}
    80007570:	21813083          	ld	ra,536(sp)
    80007574:	21013403          	ld	s0,528(sp)
    80007578:	20813483          	ld	s1,520(sp)
    8000757c:	20013903          	ld	s2,512(sp)
    80007580:	22010113          	addi	sp,sp,544
    80007584:	8082                	ret

0000000080007586 <fslog_write>:
void fslog_write(int blockno, int existed, int n_before, int n_after){
    80007586:	dd010113          	addi	sp,sp,-560
    8000758a:	22113423          	sd	ra,552(sp)
    8000758e:	22813023          	sd	s0,544(sp)
    80007592:	20913c23          	sd	s1,536(sp)
    80007596:	21213823          	sd	s2,528(sp)
    8000759a:	21313423          	sd	s3,520(sp)
    8000759e:	21413023          	sd	s4,512(sp)
    800075a2:	1c00                	addi	s0,sp,560
    800075a4:	8a2a                	mv	s4,a0
    800075a6:	84ae                	mv	s1,a1
    800075a8:	89b2                	mv	s3,a2
    800075aa:	8936                	mv	s2,a3
  struct fs_event e;
  fill_fs_common(&e);
    800075ac:	dd040513          	addi	a0,s0,-560
    800075b0:	973ff0ef          	jal	80006f22 <fill_fs_common>

  e.type = FS_LOG_WRITE;
    800075b4:	47bd                	li	a5,15
    800075b6:	def42023          	sw	a5,-544(s0)
  e.blockno = blockno;
    800075ba:	e9442a23          	sw	s4,-364(s0)
  e.ref_before = n_before;
    800075be:	eb342c23          	sw	s3,-328(s0)
  e.ref_after = n_after;
    800075c2:	eb242e23          	sw	s2,-324(s0)
  e.found = existed;
    800075c6:	ee942023          	sw	s1,-288(s0)

  safestrcpy(e.name, "LOG", FS_NM);
    800075ca:	02000613          	li	a2,32
    800075ce:	00003597          	auipc	a1,0x3
    800075d2:	8d258593          	addi	a1,a1,-1838 # 80009ea0 <etext+0xea0>
    800075d6:	e7440513          	addi	a0,s0,-396
    800075da:	839f90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    800075de:	dd040513          	addi	a0,s0,-560
    800075e2:	9b7ff0ef          	jal	80006f98 <fslog_push>
}
    800075e6:	22813083          	ld	ra,552(sp)
    800075ea:	22013403          	ld	s0,544(sp)
    800075ee:	21813483          	ld	s1,536(sp)
    800075f2:	21013903          	ld	s2,528(sp)
    800075f6:	20813983          	ld	s3,520(sp)
    800075fa:	20013a03          	ld	s4,512(sp)
    800075fe:	23010113          	addi	sp,sp,560
    80007602:	8082                	ret

0000000080007604 <fslog_end>:

void fslog_end(int before, int after, int will_commit){
    80007604:	dd010113          	addi	sp,sp,-560
    80007608:	22113423          	sd	ra,552(sp)
    8000760c:	22813023          	sd	s0,544(sp)
    80007610:	20913c23          	sd	s1,536(sp)
    80007614:	21213823          	sd	s2,528(sp)
    80007618:	21313423          	sd	s3,520(sp)
    8000761c:	1c00                	addi	s0,sp,560
    8000761e:	89aa                	mv	s3,a0
    80007620:	892e                	mv	s2,a1
    80007622:	84b2                	mv	s1,a2
  struct fs_event e;
  fill_fs_common(&e);
    80007624:	dd040513          	addi	a0,s0,-560
    80007628:	8fbff0ef          	jal	80006f22 <fill_fs_common>
  e.type = FS_LOG_END;
    8000762c:	47c1                	li	a5,16
    8000762e:	def42023          	sw	a5,-544(s0)
  e.ref_before = before;
    80007632:	eb342c23          	sw	s3,-328(s0)
  e.ref_after = after;
    80007636:	eb242e23          	sw	s2,-324(s0)
  e.found = will_commit;
    8000763a:	ee942023          	sw	s1,-288(s0)
  safestrcpy(e.name, "LOG", FS_NM);
    8000763e:	02000613          	li	a2,32
    80007642:	00003597          	auipc	a1,0x3
    80007646:	85e58593          	addi	a1,a1,-1954 # 80009ea0 <etext+0xea0>
    8000764a:	e7440513          	addi	a0,s0,-396
    8000764e:	fc4f90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    80007652:	dd040513          	addi	a0,s0,-560
    80007656:	943ff0ef          	jal	80006f98 <fslog_push>
}
    8000765a:	22813083          	ld	ra,552(sp)
    8000765e:	22013403          	ld	s0,544(sp)
    80007662:	21813483          	ld	s1,536(sp)
    80007666:	21013903          	ld	s2,528(sp)
    8000766a:	20813983          	ld	s3,520(sp)
    8000766e:	23010113          	addi	sp,sp,560
    80007672:	8082                	ret

0000000080007674 <fslog_writelog>:
void fslog_writelog(int blockno, int idx){
    80007674:	de010113          	addi	sp,sp,-544
    80007678:	20113c23          	sd	ra,536(sp)
    8000767c:	20813823          	sd	s0,528(sp)
    80007680:	20913423          	sd	s1,520(sp)
    80007684:	21213023          	sd	s2,512(sp)
    80007688:	1400                	addi	s0,sp,544
    8000768a:	892a                	mv	s2,a0
    8000768c:	84ae                	mv	s1,a1
  struct fs_event e;
  fill_fs_common(&e);
    8000768e:	de040513          	addi	a0,s0,-544
    80007692:	891ff0ef          	jal	80006f22 <fill_fs_common>
  e.type = FS_LOG_WLOG;
    80007696:	47c5                	li	a5,17
    80007698:	def42823          	sw	a5,-528(s0)
  e.blockno = blockno;
    8000769c:	eb242223          	sw	s2,-348(s0)
  e.lru_after = idx;
    800076a0:	ee942223          	sw	s1,-284(s0)
  safestrcpy(e.name, "LOG", FS_NM);
    800076a4:	02000613          	li	a2,32
    800076a8:	00002597          	auipc	a1,0x2
    800076ac:	7f858593          	addi	a1,a1,2040 # 80009ea0 <etext+0xea0>
    800076b0:	e8440513          	addi	a0,s0,-380
    800076b4:	f5ef90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    800076b8:	de040513          	addi	a0,s0,-544
    800076bc:	8ddff0ef          	jal	80006f98 <fslog_push>
}
    800076c0:	21813083          	ld	ra,536(sp)
    800076c4:	21013403          	ld	s0,528(sp)
    800076c8:	20813483          	ld	s1,520(sp)
    800076cc:	20013903          	ld	s2,512(sp)
    800076d0:	22010113          	addi	sp,sp,544
    800076d4:	8082                	ret

00000000800076d6 <fslog_writehead>:

void fslog_writehead(int n){
    800076d6:	de010113          	addi	sp,sp,-544
    800076da:	20113c23          	sd	ra,536(sp)
    800076de:	20813823          	sd	s0,528(sp)
    800076e2:	20913423          	sd	s1,520(sp)
    800076e6:	1400                	addi	s0,sp,544
    800076e8:	84aa                	mv	s1,a0
  struct fs_event e;
  fill_fs_common(&e);
    800076ea:	de040513          	addi	a0,s0,-544
    800076ee:	835ff0ef          	jal	80006f22 <fill_fs_common>
  e.type = FS_LOG_WHEAD;
    800076f2:	47c9                	li	a5,18
    800076f4:	def42823          	sw	a5,-528(s0)
  e.ref_after = n;
    800076f8:	ec942623          	sw	s1,-308(s0)
  safestrcpy(e.name, "LOG", FS_NM);
    800076fc:	02000613          	li	a2,32
    80007700:	00002597          	auipc	a1,0x2
    80007704:	7a058593          	addi	a1,a1,1952 # 80009ea0 <etext+0xea0>
    80007708:	e8440513          	addi	a0,s0,-380
    8000770c:	f06f90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    80007710:	de040513          	addi	a0,s0,-544
    80007714:	885ff0ef          	jal	80006f98 <fslog_push>
}
    80007718:	21813083          	ld	ra,536(sp)
    8000771c:	21013403          	ld	s0,528(sp)
    80007720:	20813483          	ld	s1,520(sp)
    80007724:	22010113          	addi	sp,sp,544
    80007728:	8082                	ret

000000008000772a <fslog_install>:

void fslog_install(int blockno){
    8000772a:	de010113          	addi	sp,sp,-544
    8000772e:	20113c23          	sd	ra,536(sp)
    80007732:	20813823          	sd	s0,528(sp)
    80007736:	20913423          	sd	s1,520(sp)
    8000773a:	1400                	addi	s0,sp,544
    8000773c:	84aa                	mv	s1,a0
  struct fs_event e;
  fill_fs_common(&e);
    8000773e:	de040513          	addi	a0,s0,-544
    80007742:	fe0ff0ef          	jal	80006f22 <fill_fs_common>
  e.type = FS_LOG_INSTALL;
    80007746:	47cd                	li	a5,19
    80007748:	def42823          	sw	a5,-528(s0)
  e.blockno = blockno;
    8000774c:	ea942223          	sw	s1,-348(s0)
  safestrcpy(e.name, "LOG", FS_NM);
    80007750:	02000613          	li	a2,32
    80007754:	00002597          	auipc	a1,0x2
    80007758:	74c58593          	addi	a1,a1,1868 # 80009ea0 <etext+0xea0>
    8000775c:	e8440513          	addi	a0,s0,-380
    80007760:	eb2f90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    80007764:	de040513          	addi	a0,s0,-544
    80007768:	831ff0ef          	jal	80006f98 <fslog_push>
}
    8000776c:	21813083          	ld	ra,536(sp)
    80007770:	21013403          	ld	s0,528(sp)
    80007774:	20813483          	ld	s1,520(sp)
    80007778:	22010113          	addi	sp,sp,544
    8000777c:	8082                	ret

000000008000777e <fslog_balloc>:
void fslog_balloc(int block_allocated) {
    8000777e:	de010113          	addi	sp,sp,-544
    80007782:	20113c23          	sd	ra,536(sp)
    80007786:	20813823          	sd	s0,528(sp)
    8000778a:	20913423          	sd	s1,520(sp)
    8000778e:	1400                	addi	s0,sp,544
    80007790:	84aa                	mv	s1,a0
    struct fs_event e;
    fill_fs_common(&e);
    80007792:	de040513          	addi	a0,s0,-544
    80007796:	f8cff0ef          	jal	80006f22 <fill_fs_common>
    e.type = FS_BLOCK_ALLOC;
    8000779a:	47d1                	li	a5,20
    8000779c:	def42823          	sw	a5,-528(s0)
    e.blockno = block_allocated; // البلوك الذي تم حجزه فعلياً
    800077a0:	ea942223          	sw	s1,-348(s0)
    safestrcpy(e.name, "BALLOC", FS_NM);
    800077a4:	02000613          	li	a2,32
    800077a8:	00002597          	auipc	a1,0x2
    800077ac:	c5858593          	addi	a1,a1,-936 # 80009400 <etext+0x400>
    800077b0:	e8440513          	addi	a0,s0,-380
    800077b4:	e5ef90ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    800077b8:	de040513          	addi	a0,s0,-544
    800077bc:	fdcff0ef          	jal	80006f98 <fslog_push>
}
    800077c0:	21813083          	ld	ra,536(sp)
    800077c4:	21013403          	ld	s0,528(sp)
    800077c8:	20813483          	ld	s1,520(sp)
    800077cc:	22010113          	addi	sp,sp,544
    800077d0:	8082                	ret

00000000800077d2 <fslog_bfree>:
void fslog_bfree(int block_freed) {
    800077d2:	de010113          	addi	sp,sp,-544
    800077d6:	20113c23          	sd	ra,536(sp)
    800077da:	20813823          	sd	s0,528(sp)
    800077de:	20913423          	sd	s1,520(sp)
    800077e2:	1400                	addi	s0,sp,544
    800077e4:	84aa                	mv	s1,a0
    struct fs_event e;
    fill_fs_common(&e);
    800077e6:	de040513          	addi	a0,s0,-544
    800077ea:	f38ff0ef          	jal	80006f22 <fill_fs_common>
    e.type = FS_BLOCK_FREE;
    800077ee:	47d5                	li	a5,21
    800077f0:	def42823          	sw	a5,-528(s0)
    e.blockno = block_freed; // البلوك الذي تم تحريره
    800077f4:	ea942223          	sw	s1,-348(s0)
    safestrcpy(e.name, "BFREE", FS_NM);
    800077f8:	02000613          	li	a2,32
    800077fc:	00002597          	auipc	a1,0x2
    80007800:	bec58593          	addi	a1,a1,-1044 # 800093e8 <etext+0x3e8>
    80007804:	e8440513          	addi	a0,s0,-380
    80007808:	e0af90ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    8000780c:	de040513          	addi	a0,s0,-544
    80007810:	f88ff0ef          	jal	80006f98 <fslog_push>
}
    80007814:	21813083          	ld	ra,536(sp)
    80007818:	21013403          	ld	s0,528(sp)
    8000781c:	20813483          	ld	s1,520(sp)
    80007820:	22010113          	addi	sp,sp,544
    80007824:	8082                	ret

0000000080007826 <fslog_ialloc>:
void fslog_ialloc(int inum, short type) {
    80007826:	de010113          	addi	sp,sp,-544
    8000782a:	20113c23          	sd	ra,536(sp)
    8000782e:	20813823          	sd	s0,528(sp)
    80007832:	20913423          	sd	s1,520(sp)
    80007836:	21213023          	sd	s2,512(sp)
    8000783a:	1400                	addi	s0,sp,544
    8000783c:	892a                	mv	s2,a0
    8000783e:	84ae                	mv	s1,a1
    struct fs_event e;
    fill_fs_common(&e);
    80007840:	de040513          	addi	a0,s0,-544
    80007844:	edeff0ef          	jal	80006f22 <fill_fs_common>
    e.type = FS_INODE_ALLOC;
    80007848:	47d9                	li	a5,22
    8000784a:	def42823          	sw	a5,-528(s0)
    e.inum = inum;
    8000784e:	eb242623          	sw	s2,-340(s0)
    e.i_type = type;
    80007852:	ea942e23          	sw	s1,-324(s0)
    safestrcpy(e.name, "IALLOC", FS_NM);
    80007856:	02000613          	li	a2,32
    8000785a:	00002597          	auipc	a1,0x2
    8000785e:	cfe58593          	addi	a1,a1,-770 # 80009558 <etext+0x558>
    80007862:	e8440513          	addi	a0,s0,-380
    80007866:	dacf90ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    8000786a:	de040513          	addi	a0,s0,-544
    8000786e:	f2aff0ef          	jal	80006f98 <fslog_push>
}
    80007872:	21813083          	ld	ra,536(sp)
    80007876:	21013403          	ld	s0,528(sp)
    8000787a:	20813483          	ld	s1,520(sp)
    8000787e:	20013903          	ld	s2,512(sp)
    80007882:	22010113          	addi	sp,sp,544
    80007886:	8082                	ret

0000000080007888 <fslog_iget>:

void fslog_iget(int inum, int ref_before, int ref_after) {
    80007888:	dd010113          	addi	sp,sp,-560
    8000788c:	22113423          	sd	ra,552(sp)
    80007890:	22813023          	sd	s0,544(sp)
    80007894:	20913c23          	sd	s1,536(sp)
    80007898:	21213823          	sd	s2,528(sp)
    8000789c:	21313423          	sd	s3,520(sp)
    800078a0:	1c00                	addi	s0,sp,560
    800078a2:	89aa                	mv	s3,a0
    800078a4:	892e                	mv	s2,a1
    800078a6:	84b2                	mv	s1,a2
    struct fs_event e;
    fill_fs_common(&e);
    800078a8:	dd040513          	addi	a0,s0,-560
    800078ac:	e76ff0ef          	jal	80006f22 <fill_fs_common>
    e.type = FS_INODE_GET;
    800078b0:	47dd                	li	a5,23
    800078b2:	def42023          	sw	a5,-544(s0)
    e.inum = inum;
    800078b6:	e9342e23          	sw	s3,-356(s0)
    e.ref_before = ref_before;
    800078ba:	eb242c23          	sw	s2,-328(s0)
    e.ref_after = ref_after;
    800078be:	ea942e23          	sw	s1,-324(s0)
    safestrcpy(e.name, "IGET", FS_NM);
    800078c2:	02000613          	li	a2,32
    800078c6:	00002597          	auipc	a1,0x2
    800078ca:	5e258593          	addi	a1,a1,1506 # 80009ea8 <etext+0xea8>
    800078ce:	e7440513          	addi	a0,s0,-396
    800078d2:	d40f90ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    800078d6:	dd040513          	addi	a0,s0,-560
    800078da:	ebeff0ef          	jal	80006f98 <fslog_push>
}
    800078de:	22813083          	ld	ra,552(sp)
    800078e2:	22013403          	ld	s0,544(sp)
    800078e6:	21813483          	ld	s1,536(sp)
    800078ea:	21013903          	ld	s2,528(sp)
    800078ee:	20813983          	ld	s3,520(sp)
    800078f2:	23010113          	addi	sp,sp,560
    800078f6:	8082                	ret

00000000800078f8 <fslog_ilock>:
// في ملف kernel/fslog.c

void fslog_ilock(int inum, int locked) {
    800078f8:	de010113          	addi	sp,sp,-544
    800078fc:	20113c23          	sd	ra,536(sp)
    80007900:	20813823          	sd	s0,528(sp)
    80007904:	20913423          	sd	s1,520(sp)
    80007908:	21213023          	sd	s2,512(sp)
    8000790c:	1400                	addi	s0,sp,544
    8000790e:	892a                	mv	s2,a0
    80007910:	84ae                	mv	s1,a1
    struct fs_event e;
    fill_fs_common(&e);
    80007912:	de040513          	addi	a0,s0,-544
    80007916:	e0cff0ef          	jal	80006f22 <fill_fs_common>
    e.type = FS_INODE_LOCK;
    8000791a:	47e1                	li	a5,24
    8000791c:	def42823          	sw	a5,-528(s0)
    e.inum = inum;
    80007920:	eb242623          	sw	s2,-340(s0)
    e.locked_after = locked; // 1 للـ Lock و 0 للـ Unlock
    80007924:	ec942e23          	sw	s1,-292(s0)
    e.ref_after = 1; // لضمان بقاء السطر في الواجهة
    80007928:	4785                	li	a5,1
    8000792a:	ecf42623          	sw	a5,-308(s0)
    safestrcpy(e.name, "ILOCK", FS_NM);
    8000792e:	02000613          	li	a2,32
    80007932:	00002597          	auipc	a1,0x2
    80007936:	57e58593          	addi	a1,a1,1406 # 80009eb0 <etext+0xeb0>
    8000793a:	e8440513          	addi	a0,s0,-380
    8000793e:	cd4f90ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    80007942:	de040513          	addi	a0,s0,-544
    80007946:	e52ff0ef          	jal	80006f98 <fslog_push>
}
    8000794a:	21813083          	ld	ra,536(sp)
    8000794e:	21013403          	ld	s0,528(sp)
    80007952:	20813483          	ld	s1,520(sp)
    80007956:	20013903          	ld	s2,512(sp)
    8000795a:	22010113          	addi	sp,sp,544
    8000795e:	8082                	ret

0000000080007960 <fslog_iupdate>:

void fslog_iupdate(struct inode *ip) {
    80007960:	de010113          	addi	sp,sp,-544
    80007964:	20113c23          	sd	ra,536(sp)
    80007968:	20813823          	sd	s0,528(sp)
    8000796c:	20913423          	sd	s1,520(sp)
    80007970:	1400                	addi	s0,sp,544
    80007972:	84aa                	mv	s1,a0
    struct fs_event e;
    fill_fs_common(&e);
    80007974:	de040513          	addi	a0,s0,-544
    80007978:	daaff0ef          	jal	80006f22 <fill_fs_common>
    e.type = FS_INODE_UPDATE;
    8000797c:	47e5                	li	a5,25
    8000797e:	def42823          	sw	a5,-528(s0)
    e.inum = ip->inum;
    80007982:	40dc                	lw	a5,4(s1)
    80007984:	eaf42623          	sw	a5,-340(s0)
    e.i_type = ip->type;
    80007988:	04449783          	lh	a5,68(s1)
    8000798c:	eaf42e23          	sw	a5,-324(s0)
    e.i_size = ip->size;
    80007990:	44fc                	lw	a5,76(s1)
    80007992:	ecf42023          	sw	a5,-320(s0)
    e.nlink = ip->nlink;
    80007996:	04a49783          	lh	a5,74(s1)
    8000799a:	ecf42223          	sw	a5,-316(s0)
    e.ref_after = ip->ref; // مهم جداً للواجهة
    8000799e:	449c                	lw	a5,8(s1)
    800079a0:	ecf42623          	sw	a5,-308(s0)
    for(int i=0; i<13; i++) e.addrs[i] = ip->addrs[i];
    800079a4:	05048513          	addi	a0,s1,80
    800079a8:	f0c40793          	addi	a5,s0,-244
    800079ac:	f4040693          	addi	a3,s0,-192
    800079b0:	4118                	lw	a4,0(a0)
    800079b2:	c398                	sw	a4,0(a5)
    800079b4:	0511                	addi	a0,a0,4
    800079b6:	0791                	addi	a5,a5,4
    800079b8:	fed79ce3          	bne	a5,a3,800079b0 <fslog_iupdate+0x50>
    safestrcpy(e.name, "IUPDATE", FS_NM);
    800079bc:	02000613          	li	a2,32
    800079c0:	00002597          	auipc	a1,0x2
    800079c4:	bd058593          	addi	a1,a1,-1072 # 80009590 <etext+0x590>
    800079c8:	e8440513          	addi	a0,s0,-380
    800079cc:	c46f90ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    800079d0:	de040513          	addi	a0,s0,-544
    800079d4:	dc4ff0ef          	jal	80006f98 <fslog_push>
}
    800079d8:	21813083          	ld	ra,536(sp)
    800079dc:	21013403          	ld	s0,528(sp)
    800079e0:	20813483          	ld	s1,520(sp)
    800079e4:	22010113          	addi	sp,sp,544
    800079e8:	8082                	ret

00000000800079ea <fslog_iput>:
// داخل ملف kernel/fslog.c

void
fslog_iput(int inum, int old_ref, int new_ref)
{
    800079ea:	dd010113          	addi	sp,sp,-560
    800079ee:	22113423          	sd	ra,552(sp)
    800079f2:	22813023          	sd	s0,544(sp)
    800079f6:	20913c23          	sd	s1,536(sp)
    800079fa:	21213823          	sd	s2,528(sp)
    800079fe:	21313423          	sd	s3,520(sp)
    80007a02:	1c00                	addi	s0,sp,560
    80007a04:	89aa                	mv	s3,a0
    80007a06:	892e                	mv	s2,a1
    80007a08:	84b2                	mv	s1,a2
  struct fs_event e;
  fill_fs_common(&e);
    80007a0a:	dd040513          	addi	a0,s0,-560
    80007a0e:	d14ff0ef          	jal	80006f22 <fill_fs_common>
  e.type = FS_INODE_PUT; // تأكدي أن هذا الرقم (مثلاً 42) معرف في الـ Header
    80007a12:	47a5                	li	a5,9
    80007a14:	def42023          	sw	a5,-544(s0)
  e.inum = inum;
    80007a18:	e9342e23          	sw	s3,-356(s0)
  e.ref_before = old_ref;
    80007a1c:	eb242c23          	sw	s2,-328(s0)
  e.ref_after = new_ref;
    80007a20:	ea942e23          	sw	s1,-324(s0)
  safestrcpy(e.name, "IPUT", FS_NM);
    80007a24:	02000613          	li	a2,32
    80007a28:	00002597          	auipc	a1,0x2
    80007a2c:	c6858593          	addi	a1,a1,-920 # 80009690 <etext+0x690>
    80007a30:	e7440513          	addi	a0,s0,-396
    80007a34:	bdef90ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    80007a38:	dd040513          	addi	a0,s0,-560
    80007a3c:	d5cff0ef          	jal	80006f98 <fslog_push>
    80007a40:	22813083          	ld	ra,552(sp)
    80007a44:	22013403          	ld	s0,544(sp)
    80007a48:	21813483          	ld	s1,536(sp)
    80007a4c:	21013903          	ld	s2,528(sp)
    80007a50:	20813983          	ld	s3,520(sp)
    80007a54:	23010113          	addi	sp,sp,560
    80007a58:	8082                	ret

0000000080007a5a <schedlog_init>:

static struct ringbuf sched_rb;

void
schedlog_init(void)
{
    80007a5a:	1141                	addi	sp,sp,-16
    80007a5c:	e406                	sd	ra,8(sp)
    80007a5e:	e022                	sd	s0,0(sp)
    80007a60:	0800                	addi	s0,sp,16
  ringbuf_init(&sched_rb, "schedlog", sizeof(struct sched_event));
    80007a62:	04400613          	li	a2,68
    80007a66:	00002597          	auipc	a1,0x2
    80007a6a:	45258593          	addi	a1,a1,1106 # 80009eb8 <etext+0xeb8>
    80007a6e:	0005c517          	auipc	a0,0x5c
    80007a72:	9aa50513          	addi	a0,a0,-1622 # 80063418 <sched_rb>
    80007a76:	b34ff0ef          	jal	80006daa <ringbuf_init>
}
    80007a7a:	60a2                	ld	ra,8(sp)
    80007a7c:	6402                	ld	s0,0(sp)
    80007a7e:	0141                	addi	sp,sp,16
    80007a80:	8082                	ret

0000000080007a82 <schedlog_emit>:

void
schedlog_emit(struct sched_event *e)
{
    80007a82:	711d                	addi	sp,sp,-96
    80007a84:	ec86                	sd	ra,88(sp)
    80007a86:	e8a2                	sd	s0,80(sp)
    80007a88:	1080                	addi	s0,sp,96
    80007a8a:	85aa                	mv	a1,a0
  struct sched_event copy;

  memmove(&copy, e, sizeof(copy));
    80007a8c:	04400613          	li	a2,68
    80007a90:	fa840513          	addi	a0,s0,-88
    80007a94:	a9cf90ef          	jal	80000d30 <memmove>
  copy.seq = sched_rb.seq++;
    80007a98:	0005c517          	auipc	a0,0x5c
    80007a9c:	98050513          	addi	a0,a0,-1664 # 80063418 <sched_rb>
    80007aa0:	751c                	ld	a5,40(a0)
    80007aa2:	00178713          	addi	a4,a5,1
    80007aa6:	f518                	sd	a4,40(a0)
    80007aa8:	faf42423          	sw	a5,-88(s0)
  ringbuf_push(&sched_rb, &copy);
    80007aac:	fa840593          	addi	a1,s0,-88
    80007ab0:	b2eff0ef          	jal	80006dde <ringbuf_push>
}
    80007ab4:	60e6                	ld	ra,88(sp)
    80007ab6:	6446                	ld	s0,80(sp)
    80007ab8:	6125                	addi	sp,sp,96
    80007aba:	8082                	ret

0000000080007abc <schedread>:

int
schedread(struct sched_event *dst, int max)
{
    80007abc:	1141                	addi	sp,sp,-16
    80007abe:	e406                	sd	ra,8(sp)
    80007ac0:	e022                	sd	s0,0(sp)
    80007ac2:	0800                	addi	s0,sp,16
    80007ac4:	862e                	mv	a2,a1
  return ringbuf_read_many(&sched_rb, dst, max);
    80007ac6:	85aa                	mv	a1,a0
    80007ac8:	0005c517          	auipc	a0,0x5c
    80007acc:	95050513          	addi	a0,a0,-1712 # 80063418 <sched_rb>
    80007ad0:	b7aff0ef          	jal	80006e4a <ringbuf_read_many>
    80007ad4:	60a2                	ld	ra,8(sp)
    80007ad6:	6402                	ld	s0,0(sp)
    80007ad8:	0141                	addi	sp,sp,16
    80007ada:	8082                	ret

0000000080007adc <memlog_init>:
static uint mem_count = 0;
static uint64 mem_seq = 0;

void
memlog_init(void)
{
    80007adc:	1141                	addi	sp,sp,-16
    80007ade:	e406                	sd	ra,8(sp)
    80007ae0:	e022                	sd	s0,0(sp)
    80007ae2:	0800                	addi	s0,sp,16
  initlock(&mem_lock, "memlog");
    80007ae4:	00002597          	auipc	a1,0x2
    80007ae8:	3e458593          	addi	a1,a1,996 # 80009ec8 <etext+0xec8>
    80007aec:	0007c517          	auipc	a0,0x7c
    80007af0:	95c50513          	addi	a0,a0,-1700 # 80083448 <mem_lock>
    80007af4:	88cf90ef          	jal	80000b80 <initlock>
  mem_head = 0;
    80007af8:	00002797          	auipc	a5,0x2
    80007afc:	5607ac23          	sw	zero,1400(a5) # 8000a070 <mem_head>
  mem_tail = 0;
    80007b00:	00002797          	auipc	a5,0x2
    80007b04:	5607a623          	sw	zero,1388(a5) # 8000a06c <mem_tail>
  mem_count = 0;
    80007b08:	00002797          	auipc	a5,0x2
    80007b0c:	5607a023          	sw	zero,1376(a5) # 8000a068 <mem_count>
  mem_seq = 0;
    80007b10:	00002797          	auipc	a5,0x2
    80007b14:	5407b823          	sd	zero,1360(a5) # 8000a060 <mem_seq>
}
    80007b18:	60a2                	ld	ra,8(sp)
    80007b1a:	6402                	ld	s0,0(sp)
    80007b1c:	0141                	addi	sp,sp,16
    80007b1e:	8082                	ret

0000000080007b20 <memlog_push>:

void
memlog_push(struct mem_event *e)
{
    80007b20:	1101                	addi	sp,sp,-32
    80007b22:	ec06                	sd	ra,24(sp)
    80007b24:	e822                	sd	s0,16(sp)
    80007b26:	e426                	sd	s1,8(sp)
    80007b28:	1000                	addi	s0,sp,32
    80007b2a:	84aa                	mv	s1,a0
  acquire(&mem_lock);
    80007b2c:	0007c517          	auipc	a0,0x7c
    80007b30:	91c50513          	addi	a0,a0,-1764 # 80083448 <mem_lock>
    80007b34:	8ccf90ef          	jal	80000c00 <acquire>

  e->seq = ++mem_seq;
    80007b38:	00002717          	auipc	a4,0x2
    80007b3c:	52870713          	addi	a4,a4,1320 # 8000a060 <mem_seq>
    80007b40:	631c                	ld	a5,0(a4)
    80007b42:	0785                	addi	a5,a5,1
    80007b44:	e31c                	sd	a5,0(a4)
    80007b46:	e09c                	sd	a5,0(s1)

  if(mem_count == MEM_RB_CAP){
    80007b48:	00002717          	auipc	a4,0x2
    80007b4c:	52072703          	lw	a4,1312(a4) # 8000a068 <mem_count>
    80007b50:	20000793          	li	a5,512
    80007b54:	08f70063          	beq	a4,a5,80007bd4 <memlog_push+0xb4>
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    mem_count--;
  }

  mem_buf[mem_head] = *e;
    80007b58:	00002697          	auipc	a3,0x2
    80007b5c:	5186a683          	lw	a3,1304(a3) # 8000a070 <mem_head>
    80007b60:	02069613          	slli	a2,a3,0x20
    80007b64:	9201                	srli	a2,a2,0x20
    80007b66:	06800793          	li	a5,104
    80007b6a:	02f60633          	mul	a2,a2,a5
    80007b6e:	8726                	mv	a4,s1
    80007b70:	0007c797          	auipc	a5,0x7c
    80007b74:	8f078793          	addi	a5,a5,-1808 # 80083460 <mem_buf>
    80007b78:	97b2                	add	a5,a5,a2
    80007b7a:	06048493          	addi	s1,s1,96
    80007b7e:	00073803          	ld	a6,0(a4)
    80007b82:	6708                	ld	a0,8(a4)
    80007b84:	6b0c                	ld	a1,16(a4)
    80007b86:	6f10                	ld	a2,24(a4)
    80007b88:	0107b023          	sd	a6,0(a5)
    80007b8c:	e788                	sd	a0,8(a5)
    80007b8e:	eb8c                	sd	a1,16(a5)
    80007b90:	ef90                	sd	a2,24(a5)
    80007b92:	02070713          	addi	a4,a4,32
    80007b96:	02078793          	addi	a5,a5,32
    80007b9a:	fe9712e3          	bne	a4,s1,80007b7e <memlog_push+0x5e>
    80007b9e:	6318                	ld	a4,0(a4)
    80007ba0:	e398                	sd	a4,0(a5)
  mem_head = (mem_head + 1) % MEM_RB_CAP;
    80007ba2:	2685                	addiw	a3,a3,1
    80007ba4:	1ff6f693          	andi	a3,a3,511
    80007ba8:	00002797          	auipc	a5,0x2
    80007bac:	4cd7a423          	sw	a3,1224(a5) # 8000a070 <mem_head>
  mem_count++;
    80007bb0:	00002717          	auipc	a4,0x2
    80007bb4:	4b870713          	addi	a4,a4,1208 # 8000a068 <mem_count>
    80007bb8:	431c                	lw	a5,0(a4)
    80007bba:	2785                	addiw	a5,a5,1
    80007bbc:	c31c                	sw	a5,0(a4)

  release(&mem_lock);
    80007bbe:	0007c517          	auipc	a0,0x7c
    80007bc2:	88a50513          	addi	a0,a0,-1910 # 80083448 <mem_lock>
    80007bc6:	8d2f90ef          	jal	80000c98 <release>
}
    80007bca:	60e2                	ld	ra,24(sp)
    80007bcc:	6442                	ld	s0,16(sp)
    80007bce:	64a2                	ld	s1,8(sp)
    80007bd0:	6105                	addi	sp,sp,32
    80007bd2:	8082                	ret
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    80007bd4:	00002717          	auipc	a4,0x2
    80007bd8:	49870713          	addi	a4,a4,1176 # 8000a06c <mem_tail>
    80007bdc:	431c                	lw	a5,0(a4)
    80007bde:	2785                	addiw	a5,a5,1
    80007be0:	1ff7f793          	andi	a5,a5,511
    80007be4:	c31c                	sw	a5,0(a4)
    mem_count--;
    80007be6:	1ff00793          	li	a5,511
    80007bea:	00002717          	auipc	a4,0x2
    80007bee:	46f72f23          	sw	a5,1150(a4) # 8000a068 <mem_count>
    80007bf2:	b79d                	j	80007b58 <memlog_push+0x38>

0000000080007bf4 <memlog_read_many>:

int
memlog_read_many(struct mem_event *out, int max)
{
    80007bf4:	1101                	addi	sp,sp,-32
    80007bf6:	ec06                	sd	ra,24(sp)
    80007bf8:	e822                	sd	s0,16(sp)
    80007bfa:	e426                	sd	s1,8(sp)
    80007bfc:	1000                	addi	s0,sp,32
  int n = 0;

  if(max <= 0)
    return 0;
    80007bfe:	4481                	li	s1,0
  if(max <= 0)
    80007c00:	0ab05963          	blez	a1,80007cb2 <memlog_read_many+0xbe>
    80007c04:	e04a                	sd	s2,0(sp)
    80007c06:	84aa                	mv	s1,a0
    80007c08:	892e                	mv	s2,a1

  acquire(&mem_lock);
    80007c0a:	0007c517          	auipc	a0,0x7c
    80007c0e:	83e50513          	addi	a0,a0,-1986 # 80083448 <mem_lock>
    80007c12:	feff80ef          	jal	80000c00 <acquire>
  while(n < max && mem_count > 0){
    80007c16:	00002697          	auipc	a3,0x2
    80007c1a:	4566a683          	lw	a3,1110(a3) # 8000a06c <mem_tail>
    80007c1e:	00002617          	auipc	a2,0x2
    80007c22:	44a62603          	lw	a2,1098(a2) # 8000a068 <mem_count>
    80007c26:	8526                	mv	a0,s1
  acquire(&mem_lock);
    80007c28:	4701                	li	a4,0
  int n = 0;
    80007c2a:	4481                	li	s1,0
    out[n] = mem_buf[mem_tail];
    80007c2c:	0007cf97          	auipc	t6,0x7c
    80007c30:	834f8f93          	addi	t6,t6,-1996 # 80083460 <mem_buf>
    80007c34:	06800f13          	li	t5,104
    80007c38:	4e85                	li	t4,1
  while(n < max && mem_count > 0){
    80007c3a:	c251                	beqz	a2,80007cbe <memlog_read_many+0xca>
    out[n] = mem_buf[mem_tail];
    80007c3c:	02069793          	slli	a5,a3,0x20
    80007c40:	9381                	srli	a5,a5,0x20
    80007c42:	03e787b3          	mul	a5,a5,t5
    80007c46:	97fe                	add	a5,a5,t6
    80007c48:	872a                	mv	a4,a0
    80007c4a:	06078e13          	addi	t3,a5,96
    80007c4e:	0007b303          	ld	t1,0(a5)
    80007c52:	0087b883          	ld	a7,8(a5)
    80007c56:	0107b803          	ld	a6,16(a5)
    80007c5a:	6f8c                	ld	a1,24(a5)
    80007c5c:	00673023          	sd	t1,0(a4)
    80007c60:	01173423          	sd	a7,8(a4)
    80007c64:	01073823          	sd	a6,16(a4)
    80007c68:	ef0c                	sd	a1,24(a4)
    80007c6a:	02078793          	addi	a5,a5,32
    80007c6e:	02070713          	addi	a4,a4,32
    80007c72:	fdc79ee3          	bne	a5,t3,80007c4e <memlog_read_many+0x5a>
    80007c76:	639c                	ld	a5,0(a5)
    80007c78:	e31c                	sd	a5,0(a4)
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    80007c7a:	2685                	addiw	a3,a3,1
    80007c7c:	1ff6f693          	andi	a3,a3,511
    mem_count--;
    80007c80:	fff6079b          	addiw	a5,a2,-1
    80007c84:	0007861b          	sext.w	a2,a5
    n++;
    80007c88:	2485                	addiw	s1,s1,1
  while(n < max && mem_count > 0){
    80007c8a:	06850513          	addi	a0,a0,104
    80007c8e:	8776                	mv	a4,t4
    80007c90:	fa9915e3          	bne	s2,s1,80007c3a <memlog_read_many+0x46>
    80007c94:	00002717          	auipc	a4,0x2
    80007c98:	3cd72c23          	sw	a3,984(a4) # 8000a06c <mem_tail>
    80007c9c:	00002717          	auipc	a4,0x2
    80007ca0:	3cf72623          	sw	a5,972(a4) # 8000a068 <mem_count>
  }
  release(&mem_lock);
    80007ca4:	0007b517          	auipc	a0,0x7b
    80007ca8:	7a450513          	addi	a0,a0,1956 # 80083448 <mem_lock>
    80007cac:	fedf80ef          	jal	80000c98 <release>

  return n;
    80007cb0:	6902                	ld	s2,0(sp)
    80007cb2:	8526                	mv	a0,s1
    80007cb4:	60e2                	ld	ra,24(sp)
    80007cb6:	6442                	ld	s0,16(sp)
    80007cb8:	64a2                	ld	s1,8(sp)
    80007cba:	6105                	addi	sp,sp,32
    80007cbc:	8082                	ret
    80007cbe:	d37d                	beqz	a4,80007ca4 <memlog_read_many+0xb0>
    80007cc0:	00002797          	auipc	a5,0x2
    80007cc4:	3ad7a623          	sw	a3,940(a5) # 8000a06c <mem_tail>
    80007cc8:	00002797          	auipc	a5,0x2
    80007ccc:	3a07a023          	sw	zero,928(a5) # 8000a068 <mem_count>
    80007cd0:	bfd1                	j	80007ca4 <memlog_read_many+0xb0>
	...

0000000080008000 <_trampoline>:
    80008000:	14051073          	csrw	sscratch,a0
    80008004:	02000537          	lui	a0,0x2000
    80008008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000800a:	0536                	slli	a0,a0,0xd
    8000800c:	02153423          	sd	ra,40(a0)
    80008010:	02253823          	sd	sp,48(a0)
    80008014:	02353c23          	sd	gp,56(a0)
    80008018:	04453023          	sd	tp,64(a0)
    8000801c:	04553423          	sd	t0,72(a0)
    80008020:	04653823          	sd	t1,80(a0)
    80008024:	04753c23          	sd	t2,88(a0)
    80008028:	f120                	sd	s0,96(a0)
    8000802a:	f524                	sd	s1,104(a0)
    8000802c:	fd2c                	sd	a1,120(a0)
    8000802e:	e150                	sd	a2,128(a0)
    80008030:	e554                	sd	a3,136(a0)
    80008032:	e958                	sd	a4,144(a0)
    80008034:	ed5c                	sd	a5,152(a0)
    80008036:	0b053023          	sd	a6,160(a0)
    8000803a:	0b153423          	sd	a7,168(a0)
    8000803e:	0b253823          	sd	s2,176(a0)
    80008042:	0b353c23          	sd	s3,184(a0)
    80008046:	0d453023          	sd	s4,192(a0)
    8000804a:	0d553423          	sd	s5,200(a0)
    8000804e:	0d653823          	sd	s6,208(a0)
    80008052:	0d753c23          	sd	s7,216(a0)
    80008056:	0f853023          	sd	s8,224(a0)
    8000805a:	0f953423          	sd	s9,232(a0)
    8000805e:	0fa53823          	sd	s10,240(a0)
    80008062:	0fb53c23          	sd	s11,248(a0)
    80008066:	11c53023          	sd	t3,256(a0)
    8000806a:	11d53423          	sd	t4,264(a0)
    8000806e:	11e53823          	sd	t5,272(a0)
    80008072:	11f53c23          	sd	t6,280(a0)
    80008076:	140022f3          	csrr	t0,sscratch
    8000807a:	06553823          	sd	t0,112(a0)
    8000807e:	00853103          	ld	sp,8(a0)
    80008082:	02053203          	ld	tp,32(a0)
    80008086:	01053283          	ld	t0,16(a0)
    8000808a:	00053303          	ld	t1,0(a0)
    8000808e:	12000073          	sfence.vma
    80008092:	18031073          	csrw	satp,t1
    80008096:	12000073          	sfence.vma
    8000809a:	9282                	jalr	t0

000000008000809c <userret>:
    8000809c:	12000073          	sfence.vma
    800080a0:	18051073          	csrw	satp,a0
    800080a4:	12000073          	sfence.vma
    800080a8:	02000537          	lui	a0,0x2000
    800080ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800080ae:	0536                	slli	a0,a0,0xd
    800080b0:	02853083          	ld	ra,40(a0)
    800080b4:	03053103          	ld	sp,48(a0)
    800080b8:	03853183          	ld	gp,56(a0)
    800080bc:	04053203          	ld	tp,64(a0)
    800080c0:	04853283          	ld	t0,72(a0)
    800080c4:	05053303          	ld	t1,80(a0)
    800080c8:	05853383          	ld	t2,88(a0)
    800080cc:	7120                	ld	s0,96(a0)
    800080ce:	7524                	ld	s1,104(a0)
    800080d0:	7d2c                	ld	a1,120(a0)
    800080d2:	6150                	ld	a2,128(a0)
    800080d4:	6554                	ld	a3,136(a0)
    800080d6:	6958                	ld	a4,144(a0)
    800080d8:	6d5c                	ld	a5,152(a0)
    800080da:	0a053803          	ld	a6,160(a0)
    800080de:	0a853883          	ld	a7,168(a0)
    800080e2:	0b053903          	ld	s2,176(a0)
    800080e6:	0b853983          	ld	s3,184(a0)
    800080ea:	0c053a03          	ld	s4,192(a0)
    800080ee:	0c853a83          	ld	s5,200(a0)
    800080f2:	0d053b03          	ld	s6,208(a0)
    800080f6:	0d853b83          	ld	s7,216(a0)
    800080fa:	0e053c03          	ld	s8,224(a0)
    800080fe:	0e853c83          	ld	s9,232(a0)
    80008102:	0f053d03          	ld	s10,240(a0)
    80008106:	0f853d83          	ld	s11,248(a0)
    8000810a:	10053e03          	ld	t3,256(a0)
    8000810e:	10853e83          	ld	t4,264(a0)
    80008112:	11053f03          	ld	t5,272(a0)
    80008116:	11853f83          	ld	t6,280(a0)
    8000811a:	7928                	ld	a0,112(a0)
    8000811c:	10200073          	sret
	...
