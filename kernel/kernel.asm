
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
    80000004:	0b010113          	addi	sp,sp,176 # 800090b0 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ff989b7>
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
    800000ea:	fca50513          	addi	a0,a0,-54 # 800110b0 <conswlock>
    800000ee:	33b040ef          	jal	80004c28 <acquiresleep>

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
    80000166:	f4e50513          	addi	a0,a0,-178 # 800110b0 <conswlock>
    8000016a:	305040ef          	jal	80004c6e <releasesleep>
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
    800001a4:	f4050513          	addi	a0,a0,-192 # 800110e0 <cons>
    800001a8:	259000ef          	jal	80000c00 <acquire>

  while(n > 0){
    while(cons.r == cons.w){
    800001ac:	00011497          	auipc	s1,0x11
    800001b0:	f0448493          	addi	s1,s1,-252 # 800110b0 <conswlock>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	00011997          	auipc	s3,0x11
    800001b8:	f2c98993          	addi	s3,s3,-212 # 800110e0 <cons>
    800001bc:	00011917          	auipc	s2,0x11
    800001c0:	fbc90913          	addi	s2,s2,-68 # 80011178 <cons+0x98>
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
    800001f8:	ebc70713          	addi	a4,a4,-324 # 800110b0 <conswlock>
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
    80000242:	ea250513          	addi	a0,a0,-350 # 800110e0 <cons>
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
    8000026e:	f0f72723          	sw	a5,-242(a4) # 80011178 <cons+0x98>
    80000272:	6c42                	ld	s8,16(sp)
    80000274:	a031                	j	80000280 <consoleread+0x100>
    80000276:	e862                	sd	s8,16(sp)
    80000278:	bfb5                	j	800001f4 <consoleread+0x74>
    8000027a:	6c42                	ld	s8,16(sp)
    8000027c:	a011                	j	80000280 <consoleread+0x100>
    8000027e:	6c42                	ld	s8,16(sp)
  release(&cons.lock);
    80000280:	00011517          	auipc	a0,0x11
    80000284:	e6050513          	addi	a0,a0,-416 # 800110e0 <cons>
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
    800002d8:	e0c50513          	addi	a0,a0,-500 # 800110e0 <cons>
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
    800002fe:	de650513          	addi	a0,a0,-538 # 800110e0 <cons>
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
    8000031c:	d9870713          	addi	a4,a4,-616 # 800110b0 <conswlock>
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
    80000342:	d7278793          	addi	a5,a5,-654 # 800110b0 <conswlock>
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
    80000370:	e0c7a783          	lw	a5,-500(a5) # 80011178 <cons+0x98>
    80000374:	9f1d                	subw	a4,a4,a5
    80000376:	08000793          	li	a5,128
    8000037a:	f8f710e3          	bne	a4,a5,800002fa <consoleintr+0x32>
    8000037e:	a07d                	j	8000042c <consoleintr+0x164>
    80000380:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000382:	00011717          	auipc	a4,0x11
    80000386:	d2e70713          	addi	a4,a4,-722 # 800110b0 <conswlock>
    8000038a:	0d072783          	lw	a5,208(a4)
    8000038e:	0cc72703          	lw	a4,204(a4)
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    80000392:	00011497          	auipc	s1,0x11
    80000396:	d1e48493          	addi	s1,s1,-738 # 800110b0 <conswlock>
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
    800003d8:	cdc70713          	addi	a4,a4,-804 # 800110b0 <conswlock>
    800003dc:	0d072783          	lw	a5,208(a4)
    800003e0:	0cc72703          	lw	a4,204(a4)
    800003e4:	f0f70be3          	beq	a4,a5,800002fa <consoleintr+0x32>
      cons.e--;
    800003e8:	37fd                	addiw	a5,a5,-1
    800003ea:	00011717          	auipc	a4,0x11
    800003ee:	d8f72b23          	sw	a5,-618(a4) # 80011180 <cons+0xa0>
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
    8000040c:	ca878793          	addi	a5,a5,-856 # 800110b0 <conswlock>
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
    80000430:	d4c7a823          	sw	a2,-688(a5) # 8001117c <cons+0x9c>
        wakeup(&cons.r);
    80000434:	00011517          	auipc	a0,0x11
    80000438:	d4450513          	addi	a0,a0,-700 # 80011178 <cons+0x98>
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
    80000456:	c8e50513          	addi	a0,a0,-882 # 800110e0 <cons>
    8000045a:	726000ef          	jal	80000b80 <initlock>
  initsleeplock(&conswlock, "consw");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	baa58593          	addi	a1,a1,-1110 # 80008008 <etext+0x8>
    80000466:	00011517          	auipc	a0,0x11
    8000046a:	c4a50513          	addi	a0,a0,-950 # 800110b0 <conswlock>
    8000046e:	784040ef          	jal	80004bf2 <initsleeplock>

  uartinit();
    80000472:	400000ef          	jal	80000872 <uartinit>

  devsw[CONSOLE].read = consoleread;
    80000476:	00021797          	auipc	a5,0x21
    8000047a:	5da78793          	addi	a5,a5,1498 # 80021a50 <devsw>
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
    800004b4:	a8860613          	addi	a2,a2,-1400 # 80008f38 <digits>
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
    8000054e:	b2a7a783          	lw	a5,-1238(a5) # 80009074 <panicking>
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
    80000596:	bf650513          	addi	a0,a0,-1034 # 80011188 <pr>
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
    8000075e:	7deb8b93          	addi	s7,s7,2014 # 80008f38 <digits>
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
    800007f2:	8867a783          	lw	a5,-1914(a5) # 80009074 <panicking>
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
    80000808:	98450513          	addi	a0,a0,-1660 # 80011188 <pr>
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
    80000826:	8527a923          	sw	s2,-1966(a5) # 80009074 <panicking>
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
    80000848:	8327a623          	sw	s2,-2004(a5) # 80009070 <panicked>
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
    80000862:	92a50513          	addi	a0,a0,-1750 # 80011188 <pr>
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
    800008ba:	8ea50513          	addi	a0,a0,-1814 # 800111a0 <tx_lock>
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
    800008de:	8c650513          	addi	a0,a0,-1850 # 800111a0 <tx_lock>
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
    800008fc:	78448493          	addi	s1,s1,1924 # 8000907c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000900:	00011997          	auipc	s3,0x11
    80000904:	8a098993          	addi	s3,s3,-1888 # 800111a0 <tx_lock>
    80000908:	00008917          	auipc	s2,0x8
    8000090c:	77090913          	addi	s2,s2,1904 # 80009078 <tx_chan>
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
    8000094a:	85a50513          	addi	a0,a0,-1958 # 800111a0 <tx_lock>
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
    8000096e:	70a7a783          	lw	a5,1802(a5) # 80009074 <panicking>
    80000972:	cf95                	beqz	a5,800009ae <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000974:	00008797          	auipc	a5,0x8
    80000978:	6fc7a783          	lw	a5,1788(a5) # 80009070 <panicked>
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
    8000099e:	6da7a783          	lw	a5,1754(a5) # 80009074 <panicking>
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
    800009fa:	7aa50513          	addi	a0,a0,1962 # 800111a0 <tx_lock>
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
    80000a16:	78e50513          	addi	a0,a0,1934 # 800111a0 <tx_lock>
    80000a1a:	27e000ef          	jal	80000c98 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a1e:	54fd                	li	s1,-1
    80000a20:	a831                	j	80000a3c <uartintr+0x5a>
    tx_busy = 0;
    80000a22:	00008797          	auipc	a5,0x8
    80000a26:	6407ad23          	sw	zero,1626(a5) # 8000907c <tx_busy>
    wakeup(&tx_chan);
    80000a2a:	00008517          	auipc	a0,0x8
    80000a2e:	64e50513          	addi	a0,a0,1614 # 80009078 <tx_chan>
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
    80000a62:	00065797          	auipc	a5,0x65
    80000a66:	3e678793          	addi	a5,a5,998 # 80065e48 <end>
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
    80000a82:	73a90913          	addi	s2,s2,1850 # 800111b8 <kmem>
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
    80000b10:	6ac50513          	addi	a0,a0,1708 # 800111b8 <kmem>
    80000b14:	06c000ef          	jal	80000b80 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b18:	45c5                	li	a1,17
    80000b1a:	05ee                	slli	a1,a1,0x1b
    80000b1c:	00065517          	auipc	a0,0x65
    80000b20:	32c50513          	addi	a0,a0,812 # 80065e48 <end>
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
    80000b3e:	67e48493          	addi	s1,s1,1662 # 800111b8 <kmem>
    80000b42:	8526                	mv	a0,s1
    80000b44:	0bc000ef          	jal	80000c00 <acquire>
  r = kmem.freelist;
    80000b48:	6c84                	ld	s1,24(s1)
  if(r)
    80000b4a:	c485                	beqz	s1,80000b72 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b4c:	609c                	ld	a5,0(s1)
    80000b4e:	00010517          	auipc	a0,0x10
    80000b52:	66a50513          	addi	a0,a0,1642 # 800111b8 <kmem>
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
    80000b76:	64650513          	addi	a0,a0,1606 # 800111b8 <kmem>
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
    80000d48:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ff991b9>
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
    80000e7e:	20670713          	addi	a4,a4,518 # 80009080 <started>
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
    80000ea8:	650050ef          	jal	800064f8 <plicinithart>
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
    80000ef4:	5ea050ef          	jal	800064de <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ef8:	600050ef          	jal	800064f8 <plicinithart>
    binit();         // buffer cache
    80000efc:	4c3010ef          	jal	80002bbe <binit>
    iinit();         // inode table
    80000f00:	7ba020ef          	jal	800036ba <iinit>
    fileinit();      // file table
    80000f04:	6e9030ef          	jal	80004dec <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f08:	6e0050ef          	jal	800065e8 <virtio_disk_init>
    cslog_init();
    80000f0c:	38f050ef          	jal	80006a9a <cslog_init>
    fslog_init();
    80000f10:	6e5050ef          	jal	80006df4 <fslog_init>
    userinit();      // first user process
    80000f14:	4bb000ef          	jal	80001bce <userinit>
    __sync_synchronize();
    80000f18:	0ff0000f          	fence
    started = 1;
    80000f1c:	4785                	li	a5,1
    80000f1e:	00008717          	auipc	a4,0x8
    80000f22:	16f72123          	sw	a5,354(a4) # 80009080 <started>
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
    80000f36:	1567b783          	ld	a5,342(a5) # 80009088 <kernel_pagetable>
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
    80000fa4:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ff991af>
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
    800011c2:	eca7b523          	sd	a0,-310(a5) # 80009088 <kernel_pagetable>
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
    800017a8:	e6448493          	addi	s1,s1,-412 # 80011608 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017ac:	8b26                	mv	s6,s1
    800017ae:	03eb2937          	lui	s2,0x3eb2
    800017b2:	a1f90913          	addi	s2,s2,-1505 # 3eb1a1f <_entry-0x7c14e5e1>
    800017b6:	0932                	slli	s2,s2,0xc
    800017b8:	58d90913          	addi	s2,s2,1421
    800017bc:	0932                	slli	s2,s2,0xc
    800017be:	0fb90913          	addi	s2,s2,251
    800017c2:	0936                	slli	s2,s2,0xd
    800017c4:	8d190913          	addi	s2,s2,-1839
    800017c8:	040009b7          	lui	s3,0x4000
    800017cc:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017ce:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800017d0:	00016a97          	auipc	s5,0x16
    800017d4:	038a8a93          	addi	s5,s5,56 # 80017808 <tickslock>
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
    800017fe:	18848493          	addi	s1,s1,392
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
    80001846:	99650513          	addi	a0,a0,-1642 # 800111d8 <pid_lock>
    8000184a:	b36ff0ef          	jal	80000b80 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000184e:	00007597          	auipc	a1,0x7
    80001852:	91258593          	addi	a1,a1,-1774 # 80008160 <etext+0x160>
    80001856:	00010517          	auipc	a0,0x10
    8000185a:	99a50513          	addi	a0,a0,-1638 # 800111f0 <wait_lock>
    8000185e:	b22ff0ef          	jal	80000b80 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001862:	00010497          	auipc	s1,0x10
    80001866:	da648493          	addi	s1,s1,-602 # 80011608 <proc>
    initlock(&p->lock, "proc");
    8000186a:	00007b17          	auipc	s6,0x7
    8000186e:	906b0b13          	addi	s6,s6,-1786 # 80008170 <etext+0x170>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001872:	8aa6                	mv	s5,s1
    80001874:	03eb2937          	lui	s2,0x3eb2
    80001878:	a1f90913          	addi	s2,s2,-1505 # 3eb1a1f <_entry-0x7c14e5e1>
    8000187c:	0932                	slli	s2,s2,0xc
    8000187e:	58d90913          	addi	s2,s2,1421
    80001882:	0932                	slli	s2,s2,0xc
    80001884:	0fb90913          	addi	s2,s2,251
    80001888:	0936                	slli	s2,s2,0xd
    8000188a:	8d190913          	addi	s2,s2,-1839
    8000188e:	040009b7          	lui	s3,0x4000
    80001892:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001894:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001896:	00016a17          	auipc	s4,0x16
    8000189a:	f72a0a13          	addi	s4,s4,-142 # 80017808 <tickslock>
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
    800018b4:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ff991b9>
    800018b6:	00d7979b          	slliw	a5,a5,0xd
    800018ba:	40f987b3          	sub	a5,s3,a5
    800018be:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    800018c0:	18848493          	addi	s1,s1,392
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
    800018fc:	91050513          	addi	a0,a0,-1776 # 80011208 <cpus>
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
    80001920:	8bc70713          	addi	a4,a4,-1860 # 800111d8 <pid_lock>
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
    80001950:	7147a783          	lw	a5,1812(a5) # 80009060 <first.1>
    80001954:	cf8d                	beqz	a5,8000198e <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001956:	4505                	li	a0,1
    80001958:	356020ef          	jal	80003cae <fsinit>

    first = 0;
    8000195c:	00007797          	auipc	a5,0x7
    80001960:	7007a223          	sw	zero,1796(a5) # 80009060 <first.1>
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
    8000197c:	409030ef          	jal	80005584 <kexec>
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
    800019dc:	0000f917          	auipc	s2,0xf
    800019e0:	7fc90913          	addi	s2,s2,2044 # 800111d8 <pid_lock>
    800019e4:	854a                	mv	a0,s2
    800019e6:	a1aff0ef          	jal	80000c00 <acquire>
  pid = nextpid;
    800019ea:	00007797          	auipc	a5,0x7
    800019ee:	67a78793          	addi	a5,a5,1658 # 80009064 <nextpid>
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
    80001b38:	ad448493          	addi	s1,s1,-1324 # 80011608 <proc>
    80001b3c:	00016917          	auipc	s2,0x16
    80001b40:	ccc90913          	addi	s2,s2,-820 # 80017808 <tickslock>
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
    80001b54:	18848493          	addi	s1,s1,392
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
    80001be2:	4aa7b923          	sd	a0,1202(a5) # 80009090 <initproc>
  p->cwd = namei("/");
    80001be6:	00006517          	auipc	a0,0x6
    80001bea:	5a250513          	addi	a0,a0,1442 # 80008188 <etext+0x188>
    80001bee:	75e020ef          	jal	8000434c <namei>
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
    80001d0a:	164030ef          	jal	80004e6e <filedup>
    80001d0e:	00a93023          	sd	a0,0(s2)
    80001d12:	b7f5                	j	80001cfe <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001d14:	150ab503          	ld	a0,336(s5)
    80001d18:	379010ef          	jal	80003890 <idup>
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
    80001d3c:	4b848493          	addi	s1,s1,1208 # 800111f0 <wait_lock>
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
    80001d9e:	43e70713          	addi	a4,a4,1086 # 800111d8 <pid_lock>
    80001da2:	975a                	add	a4,a4,s6
    80001da4:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001da8:	0000f717          	auipc	a4,0xf
    80001dac:	46870713          	addi	a4,a4,1128 # 80011210 <cpus+0x8>
    80001db0:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001db2:	4c11                	li	s8,4
        c->proc = p;
    80001db4:	079e                	slli	a5,a5,0x7
    80001db6:	0000fa17          	auipc	s4,0xf
    80001dba:	422a0a13          	addi	s4,s4,1058 # 800111d8 <pid_lock>
    80001dbe:	9a3e                	add	s4,s4,a5
        found = 1;
    80001dc0:	4b85                	li	s7,1
    for (p = proc; p < &proc[NPROC]; p++) {
    80001dc2:	00016997          	auipc	s3,0x16
    80001dc6:	a4698993          	addi	s3,s3,-1466 # 80017808 <tickslock>
    80001dca:	a091                	j	80001e0e <scheduler+0x94>
      release(&p->lock);
    80001dcc:	8526                	mv	a0,s1
    80001dce:	ecbfe0ef          	jal	80000c98 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001dd2:	18848493          	addi	s1,s1,392
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
    80001df0:	535040ef          	jal	80006b24 <cslog_run_start>
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
    80001e2a:	7e248493          	addi	s1,s1,2018 # 80011608 <proc>
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
    80001e56:	38670713          	addi	a4,a4,902 # 800111d8 <pid_lock>
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
    80001e7c:	36090913          	addi	s2,s2,864 # 800111d8 <pid_lock>
    80001e80:	2781                	sext.w	a5,a5
    80001e82:	079e                	slli	a5,a5,0x7
    80001e84:	97ca                	add	a5,a5,s2
    80001e86:	0ac7a983          	lw	s3,172(a5)
    80001e8a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e8c:	2781                	sext.w	a5,a5
    80001e8e:	079e                	slli	a5,a5,0x7
    80001e90:	0000f597          	auipc	a1,0xf
    80001e94:	38058593          	addi	a1,a1,896 # 80011210 <cpus+0x8>
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
    80001f7c:	69048493          	addi	s1,s1,1680 # 80011608 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    80001f80:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f82:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f84:	00016917          	auipc	s2,0x16
    80001f88:	88490913          	addi	s2,s2,-1916 # 80017808 <tickslock>
    80001f8c:	a801                	j	80001f9c <wakeup+0x38>
      }
      release(&p->lock);
    80001f8e:	8526                	mv	a0,s1
    80001f90:	d09fe0ef          	jal	80000c98 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f94:	18848493          	addi	s1,s1,392
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
    80001fe4:	62848493          	addi	s1,s1,1576 # 80011608 <proc>
      pp->parent = initproc;
    80001fe8:	00007a17          	auipc	s4,0x7
    80001fec:	0a8a0a13          	addi	s4,s4,168 # 80009090 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001ff0:	00016997          	auipc	s3,0x16
    80001ff4:	81898993          	addi	s3,s3,-2024 # 80017808 <tickslock>
    80001ff8:	a029                	j	80002002 <reparent+0x34>
    80001ffa:	18848493          	addi	s1,s1,392
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
    80002040:	0547b783          	ld	a5,84(a5) # 80009090 <initproc>
    80002044:	0d050493          	addi	s1,a0,208
    80002048:	15050913          	addi	s2,a0,336
    8000204c:	00a79f63          	bne	a5,a0,8000206a <kexit+0x46>
    panic("init exiting");
    80002050:	00006517          	auipc	a0,0x6
    80002054:	18850513          	addi	a0,a0,392 # 800081d8 <etext+0x1d8>
    80002058:	fbafe0ef          	jal	80000812 <panic>
      fileclose(f);
    8000205c:	675020ef          	jal	80004ed0 <fileclose>
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
    80002070:	726020ef          	jal	80004796 <begin_op>
  iput(p->cwd);
    80002074:	1509b503          	ld	a0,336(s3)
    80002078:	281010ef          	jal	80003af8 <iput>
  end_op();
    8000207c:	039020ef          	jal	800048b4 <end_op>
  p->cwd = 0;
    80002080:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002084:	0000f497          	auipc	s1,0xf
    80002088:	16c48493          	addi	s1,s1,364 # 800111f0 <wait_lock>
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
    800020da:	53248493          	addi	s1,s1,1330 # 80011608 <proc>
    800020de:	00015997          	auipc	s3,0x15
    800020e2:	72a98993          	addi	s3,s3,1834 # 80017808 <tickslock>
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
    800020f8:	18848493          	addi	s1,s1,392
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
    8000219e:	05650513          	addi	a0,a0,86 # 800111f0 <wait_lock>
    800021a2:	a5ffe0ef          	jal	80000c00 <acquire>
    havekids = 0;
    800021a6:	4b81                	li	s7,0
        if (pp->state == ZOMBIE) {
    800021a8:	4a15                	li	s4,5
        havekids = 1;
    800021aa:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021ac:	00015997          	auipc	s3,0x15
    800021b0:	65c98993          	addi	s3,s3,1628 # 80017808 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800021b4:	0000fc17          	auipc	s8,0xf
    800021b8:	03cc0c13          	addi	s8,s8,60 # 800111f0 <wait_lock>
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
    800021ea:	00a50513          	addi	a0,a0,10 # 800111f0 <wait_lock>
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
    80002216:	fde50513          	addi	a0,a0,-34 # 800111f0 <wait_lock>
    8000221a:	a7ffe0ef          	jal	80000c98 <release>
            return -1;
    8000221e:	59fd                	li	s3,-1
    80002220:	bfc9                	j	800021f2 <kwait+0x78>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002222:	18848493          	addi	s1,s1,392
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
    8000225e:	3ae48493          	addi	s1,s1,942 # 80011608 <proc>
    80002262:	b7e1                	j	8000222a <kwait+0xb0>
      release(&wait_lock);
    80002264:	0000f517          	auipc	a0,0xf
    80002268:	f8c50513          	addi	a0,a0,-116 # 800111f0 <wait_lock>
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
    8000232e:	43648493          	addi	s1,s1,1078 # 80011760 <proc+0x158>
    80002332:	00015917          	auipc	s2,0x15
    80002336:	62e90913          	addi	s2,s2,1582 # 80017960 <bcache+0x140>
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
    80002358:	bfcb8b93          	addi	s7,s7,-1028 # 80008f50 <states.0>
    8000235c:	a829                	j	80002376 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000235e:	ed86a583          	lw	a1,-296(a3)
    80002362:	8556                	mv	a0,s5
    80002364:	9c8fe0ef          	jal	8000052c <printf>
    printf("\n");
    80002368:	8552                	mv	a0,s4
    8000236a:	9c2fe0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000236e:	18848493          	addi	s1,s1,392
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
    8000242a:	3e250513          	addi	a0,a0,994 # 80017808 <tickslock>
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
    80002444:	04078793          	addi	a5,a5,64 # 80006480 <kernelvec>
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
    800024fa:	31248493          	addi	s1,s1,786 # 80017808 <tickslock>
    800024fe:	8526                	mv	a0,s1
    80002500:	f00fe0ef          	jal	80000c00 <acquire>
    ticks++;
    80002504:	00007517          	auipc	a0,0x7
    80002508:	b9450513          	addi	a0,a0,-1132 # 80009098 <ticks>
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
    8000254c:	7e1030ef          	jal	8000652c <plic_claim>
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
    8000256c:	486040ef          	jal	800069f2 <virtio_disk_intr>
    if(irq)
    80002570:	a801                	j	80002580 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002572:	85a6                	mv	a1,s1
    80002574:	00006517          	auipc	a0,0x6
    80002578:	cd450513          	addi	a0,a0,-812 # 80008248 <etext+0x248>
    8000257c:	fb1fd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    80002580:	8526                	mv	a0,s1
    80002582:	7cb030ef          	jal	8000654c <plic_complete>
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
    800025ae:	ed678793          	addi	a5,a5,-298 # 80006480 <kernelvec>
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
    8000274e:	83670713          	addi	a4,a4,-1994 # 80008f80 <states.0+0x30>
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
    800028b2:	6ea78793          	addi	a5,a5,1770 # 80008f98 <syscalls>
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
    800029f0:	00015517          	auipc	a0,0x15
    800029f4:	e1850513          	addi	a0,a0,-488 # 80017808 <tickslock>
    800029f8:	a08fe0ef          	jal	80000c00 <acquire>
  ticks0 = ticks;
    800029fc:	00006917          	auipc	s2,0x6
    80002a00:	69c92903          	lw	s2,1692(s2) # 80009098 <ticks>
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
    80002a12:	dfa98993          	addi	s3,s3,-518 # 80017808 <tickslock>
    80002a16:	00006497          	auipc	s1,0x6
    80002a1a:	68248493          	addi	s1,s1,1666 # 80009098 <ticks>
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
    80002a46:	dc650513          	addi	a0,a0,-570 # 80017808 <tickslock>
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
    80002a64:	da850513          	addi	a0,a0,-600 # 80017808 <tickslock>
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
    80002aa4:	d6850513          	addi	a0,a0,-664 # 80017808 <tickslock>
    80002aa8:	958fe0ef          	jal	80000c00 <acquire>
  xticks = ticks;
    80002aac:	00006497          	auipc	s1,0x6
    80002ab0:	5ec4a483          	lw	s1,1516(s1) # 80009098 <ticks>
  release(&tickslock);
    80002ab4:	00015517          	auipc	a0,0x15
    80002ab8:	d5450513          	addi	a0,a0,-684 # 80017808 <tickslock>
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
    80002ad0:	cb010113          	addi	sp,sp,-848
    80002ad4:	34113423          	sd	ra,840(sp)
    80002ad8:	34813023          	sd	s0,832(sp)
    80002adc:	32913c23          	sd	s1,824(sp)
    80002ae0:	33213823          	sd	s2,816(sp)
    80002ae4:	33313423          	sd	s3,808(sp)
    80002ae8:	33413023          	sd	s4,800(sp)
    80002aec:	31513c23          	sd	s5,792(sp)
    80002af0:	0e80                	addi	s0,sp,848
    80002af2:	8aaa                	mv	s5,a0
    80002af4:	84ae                	mv	s1,a1
    80002af6:	8a32                	mv	s4,a2
    80002af8:	89b6                	mv	s3,a3
    80002afa:	893a                	mv	s2,a4
    struct fs_event e;
    memset(&e, 0, sizeof(e));
    80002afc:	30800613          	li	a2,776
    80002b00:	4581                	li	a1,0
    80002b02:	cb840513          	addi	a0,s0,-840
    80002b06:	9cefe0ef          	jal	80000cd4 <memset>
    e.ticks = ticks; 
    80002b0a:	00006797          	auipc	a5,0x6
    80002b0e:	58e7a783          	lw	a5,1422(a5) # 80009098 <ticks>
    80002b12:	ccf42023          	sw	a5,-832(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    80002b16:	df3fe0ef          	jal	80001908 <myproc>
    80002b1a:	4781                	li	a5,0
    80002b1c:	c501                	beqz	a0,80002b24 <bcache_report+0x54>
    80002b1e:	debfe0ef          	jal	80001908 <myproc>
    80002b22:	591c                	lw	a5,48(a0)
    80002b24:	ccf42223          	sw	a5,-828(s0)
    e.type = LAYER_BCACHE;
    80002b28:	4785                	li	a5,1
    80002b2a:	ccf42423          	sw	a5,-824(s0)
    safestrcpy(e.op_name, op, 16);
    80002b2e:	4641                	li	a2,16
    80002b30:	85d6                	mv	a1,s5
    80002b32:	ccc40513          	addi	a0,s0,-820
    80002b36:	adcfe0ef          	jal	80000e12 <safestrcpy>
}

static int
buf_id(struct buf *b)
{
  return (int)(b - bcache.buf);
    80002b3a:	00015797          	auipc	a5,0x15
    80002b3e:	cfe78793          	addi	a5,a5,-770 # 80017838 <bcache+0x18>
    80002b42:	40f487b3          	sub	a5,s1,a5
    80002b46:	4037d513          	srai	a0,a5,0x3
    80002b4a:	003af7b7          	lui	a5,0x3af
    80002b4e:	f6d78793          	addi	a5,a5,-147 # 3aef6d <_entry-0x7fc51093>
    80002b52:	07b2                	slli	a5,a5,0xc
    80002b54:	a9778793          	addi	a5,a5,-1385
    80002b58:	07be                	slli	a5,a5,0xf
    80002b5a:	2c378793          	addi	a5,a5,707
    80002b5e:	07b6                	slli	a5,a5,0xd
    80002b60:	72378793          	addi	a5,a5,1827
    80002b64:	02f507b3          	mul	a5,a0,a5
    80002b68:	cef42023          	sw	a5,-800(s0)
    e.blockno = b->blockno;
    80002b6c:	44dc                	lw	a5,12(s1)
    80002b6e:	ccf42e23          	sw	a5,-804(s0)
    e.refcnt = b->refcnt;
    80002b72:	40bc                	lw	a5,64(s1)
    80002b74:	cef42223          	sw	a5,-796(s0)
    e.old_refcnt = old_ref;
    80002b78:	cf442423          	sw	s4,-792(s0)
    e.valid = b->valid;
    80002b7c:	409c                	lw	a5,0(s1)
    80002b7e:	cef42623          	sw	a5,-788(s0)
    e.old_valid = old_val;
    80002b82:	cf342823          	sw	s3,-784(s0)
    safestrcpy(e.details, det, 128);
    80002b86:	08000613          	li	a2,128
    80002b8a:	85ca                	mv	a1,s2
    80002b8c:	f4040513          	addi	a0,s0,-192
    80002b90:	a82fe0ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    80002b94:	cb840513          	addi	a0,s0,-840
    80002b98:	284040ef          	jal	80006e1c <fslog_push>
}
    80002b9c:	34813083          	ld	ra,840(sp)
    80002ba0:	34013403          	ld	s0,832(sp)
    80002ba4:	33813483          	ld	s1,824(sp)
    80002ba8:	33013903          	ld	s2,816(sp)
    80002bac:	32813983          	ld	s3,808(sp)
    80002bb0:	32013a03          	ld	s4,800(sp)
    80002bb4:	31813a83          	ld	s5,792(sp)
    80002bb8:	35010113          	addi	sp,sp,848
    80002bbc:	8082                	ret

0000000080002bbe <binit>:
{
    80002bbe:	7179                	addi	sp,sp,-48
    80002bc0:	f406                	sd	ra,40(sp)
    80002bc2:	f022                	sd	s0,32(sp)
    80002bc4:	ec26                	sd	s1,24(sp)
    80002bc6:	e84a                	sd	s2,16(sp)
    80002bc8:	e44e                	sd	s3,8(sp)
    80002bca:	e052                	sd	s4,0(sp)
    80002bcc:	1800                	addi	s0,sp,48
  initlock(&bcache.lock, "bcache");
    80002bce:	00005597          	auipc	a1,0x5
    80002bd2:	7ba58593          	addi	a1,a1,1978 # 80008388 <etext+0x388>
    80002bd6:	00015517          	auipc	a0,0x15
    80002bda:	c4a50513          	addi	a0,a0,-950 # 80017820 <bcache>
    80002bde:	fa3fd0ef          	jal	80000b80 <initlock>
  bcache.head.prev = &bcache.head;
    80002be2:	0001d797          	auipc	a5,0x1d
    80002be6:	c3e78793          	addi	a5,a5,-962 # 8001f820 <bcache+0x8000>
    80002bea:	0001d717          	auipc	a4,0x1d
    80002bee:	e9e70713          	addi	a4,a4,-354 # 8001fa88 <bcache+0x8268>
    80002bf2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002bf6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bfa:	00015497          	auipc	s1,0x15
    80002bfe:	c3e48493          	addi	s1,s1,-962 # 80017838 <bcache+0x18>
    b->next = bcache.head.next;
    80002c02:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c04:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c06:	00005a17          	auipc	s4,0x5
    80002c0a:	78aa0a13          	addi	s4,s4,1930 # 80008390 <etext+0x390>
    b->next = bcache.head.next;
    80002c0e:	2b893783          	ld	a5,696(s2)
    80002c12:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c14:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c18:	85d2                	mv	a1,s4
    80002c1a:	01048513          	addi	a0,s1,16
    80002c1e:	7d5010ef          	jal	80004bf2 <initsleeplock>
    bcache.head.next->prev = b;
    80002c22:	2b893783          	ld	a5,696(s2)
    80002c26:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c28:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c2c:	45848493          	addi	s1,s1,1112
    80002c30:	fd349fe3          	bne	s1,s3,80002c0e <binit+0x50>
}
    80002c34:	70a2                	ld	ra,40(sp)
    80002c36:	7402                	ld	s0,32(sp)
    80002c38:	64e2                	ld	s1,24(sp)
    80002c3a:	6942                	ld	s2,16(sp)
    80002c3c:	69a2                	ld	s3,8(sp)
    80002c3e:	6a02                	ld	s4,0(sp)
    80002c40:	6145                	addi	sp,sp,48
    80002c42:	8082                	ret

0000000080002c44 <bread>:
{
    80002c44:	7179                	addi	sp,sp,-48
    80002c46:	f406                	sd	ra,40(sp)
    80002c48:	f022                	sd	s0,32(sp)
    80002c4a:	ec26                	sd	s1,24(sp)
    80002c4c:	e84a                	sd	s2,16(sp)
    80002c4e:	e44e                	sd	s3,8(sp)
    80002c50:	1800                	addi	s0,sp,48
    80002c52:	892a                	mv	s2,a0
    80002c54:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002c56:	00015517          	auipc	a0,0x15
    80002c5a:	bca50513          	addi	a0,a0,-1078 # 80017820 <bcache>
    80002c5e:	fa3fd0ef          	jal	80000c00 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c62:	0001d497          	auipc	s1,0x1d
    80002c66:	e764b483          	ld	s1,-394(s1) # 8001fad8 <bcache+0x82b8>
    80002c6a:	0001d797          	auipc	a5,0x1d
    80002c6e:	e1e78793          	addi	a5,a5,-482 # 8001fa88 <bcache+0x8268>
    80002c72:	04f48863          	beq	s1,a5,80002cc2 <bread+0x7e>
    80002c76:	873e                	mv	a4,a5
    80002c78:	a021                	j	80002c80 <bread+0x3c>
    80002c7a:	68a4                	ld	s1,80(s1)
    80002c7c:	04e48363          	beq	s1,a4,80002cc2 <bread+0x7e>
    if(b->dev == dev && b->blockno == blockno){
    80002c80:	449c                	lw	a5,8(s1)
    80002c82:	ff279ce3          	bne	a5,s2,80002c7a <bread+0x36>
    80002c86:	44dc                	lw	a5,12(s1)
    80002c88:	ff3799e3          	bne	a5,s3,80002c7a <bread+0x36>
      int old_ref = b->refcnt;
    80002c8c:	40b0                	lw	a2,64(s1)
      b->refcnt++;
    80002c8e:	0016079b          	addiw	a5,a2,1
    80002c92:	c0bc                	sw	a5,64(s1)
      bcache_report("BGET_HIT", b, old_ref, b->valid, "HIT: Buffer found in cache");
    80002c94:	00005717          	auipc	a4,0x5
    80002c98:	70470713          	addi	a4,a4,1796 # 80008398 <etext+0x398>
    80002c9c:	4094                	lw	a3,0(s1)
    80002c9e:	85a6                	mv	a1,s1
    80002ca0:	00005517          	auipc	a0,0x5
    80002ca4:	71850513          	addi	a0,a0,1816 # 800083b8 <etext+0x3b8>
    80002ca8:	e29ff0ef          	jal	80002ad0 <bcache_report>
      release(&bcache.lock);
    80002cac:	00015517          	auipc	a0,0x15
    80002cb0:	b7450513          	addi	a0,a0,-1164 # 80017820 <bcache>
    80002cb4:	fe5fd0ef          	jal	80000c98 <release>
      acquiresleep(&b->lock);
    80002cb8:	01048513          	addi	a0,s1,16
    80002cbc:	76d010ef          	jal	80004c28 <acquiresleep>
      return b;
    80002cc0:	a0b5                	j	80002d2c <bread+0xe8>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002cc2:	0001d497          	auipc	s1,0x1d
    80002cc6:	e0e4b483          	ld	s1,-498(s1) # 8001fad0 <bcache+0x82b0>
    80002cca:	0001d797          	auipc	a5,0x1d
    80002cce:	dbe78793          	addi	a5,a5,-578 # 8001fa88 <bcache+0x8268>
    80002cd2:	00f48863          	beq	s1,a5,80002ce2 <bread+0x9e>
    80002cd6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002cd8:	40bc                	lw	a5,64(s1)
    80002cda:	cb91                	beqz	a5,80002cee <bread+0xaa>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002cdc:	64a4                	ld	s1,72(s1)
    80002cde:	fee49de3          	bne	s1,a4,80002cd8 <bread+0x94>
  panic("bget: no buffers");
    80002ce2:	00005517          	auipc	a0,0x5
    80002ce6:	71650513          	addi	a0,a0,1814 # 800083f8 <etext+0x3f8>
    80002cea:	b29fd0ef          	jal	80000812 <panic>
  int old_val = b->valid;
    80002cee:	4094                	lw	a3,0(s1)
  b->dev = dev;
    80002cf0:	0124a423          	sw	s2,8(s1)
  b->blockno = blockno;
    80002cf4:	0134a623          	sw	s3,12(s1)
  b->valid = 0;
    80002cf8:	0004a023          	sw	zero,0(s1)
  b->refcnt = 1;   
    80002cfc:	4785                	li	a5,1
    80002cfe:	c0bc                	sw	a5,64(s1)
  bcache_report("BGET_MISS", b, old_ref, old_val, "MISS: Evicting LRU buffer");
    80002d00:	00005717          	auipc	a4,0x5
    80002d04:	6c870713          	addi	a4,a4,1736 # 800083c8 <etext+0x3c8>
    80002d08:	4601                	li	a2,0
    80002d0a:	85a6                	mv	a1,s1
    80002d0c:	00005517          	auipc	a0,0x5
    80002d10:	6dc50513          	addi	a0,a0,1756 # 800083e8 <etext+0x3e8>
    80002d14:	dbdff0ef          	jal	80002ad0 <bcache_report>
      release(&bcache.lock);
    80002d18:	00015517          	auipc	a0,0x15
    80002d1c:	b0850513          	addi	a0,a0,-1272 # 80017820 <bcache>
    80002d20:	f79fd0ef          	jal	80000c98 <release>
      acquiresleep(&b->lock);
    80002d24:	01048513          	addi	a0,s1,16
    80002d28:	701010ef          	jal	80004c28 <acquiresleep>
  if(!b->valid) {
    80002d2c:	409c                	lw	a5,0(s1)
    80002d2e:	cb89                	beqz	a5,80002d40 <bread+0xfc>
}
    80002d30:	8526                	mv	a0,s1
    80002d32:	70a2                	ld	ra,40(sp)
    80002d34:	7402                	ld	s0,32(sp)
    80002d36:	64e2                	ld	s1,24(sp)
    80002d38:	6942                	ld	s2,16(sp)
    80002d3a:	69a2                	ld	s3,8(sp)
    80002d3c:	6145                	addi	sp,sp,48
    80002d3e:	8082                	ret
  bcache_report("BREAD_START", b, b->refcnt, old_valid, "Reading from disk...");
    80002d40:	00005717          	auipc	a4,0x5
    80002d44:	6d070713          	addi	a4,a4,1744 # 80008410 <etext+0x410>
    80002d48:	4681                	li	a3,0
    80002d4a:	40b0                	lw	a2,64(s1)
    80002d4c:	85a6                	mv	a1,s1
    80002d4e:	00005517          	auipc	a0,0x5
    80002d52:	6da50513          	addi	a0,a0,1754 # 80008428 <etext+0x428>
    80002d56:	d7bff0ef          	jal	80002ad0 <bcache_report>
    virtio_disk_rw(b, 0);
    80002d5a:	4581                	li	a1,0
    80002d5c:	8526                	mv	a0,s1
    80002d5e:	283030ef          	jal	800067e0 <virtio_disk_rw>
    b->valid = 1;
    80002d62:	4785                	li	a5,1
    80002d64:	c09c                	sw	a5,0(s1)
  bcache_report("BREAD_END", b, b->refcnt, b->valid, "Read finished: Valid=1");
    80002d66:	00005717          	auipc	a4,0x5
    80002d6a:	6d270713          	addi	a4,a4,1746 # 80008438 <etext+0x438>
    80002d6e:	4685                	li	a3,1
    80002d70:	40b0                	lw	a2,64(s1)
    80002d72:	85a6                	mv	a1,s1
    80002d74:	00005517          	auipc	a0,0x5
    80002d78:	6dc50513          	addi	a0,a0,1756 # 80008450 <etext+0x450>
    80002d7c:	d55ff0ef          	jal	80002ad0 <bcache_report>
  return b;
    80002d80:	bf45                	j	80002d30 <bread+0xec>

0000000080002d82 <bwrite>:
{
    80002d82:	1101                	addi	sp,sp,-32
    80002d84:	ec06                	sd	ra,24(sp)
    80002d86:	e822                	sd	s0,16(sp)
    80002d88:	e426                	sd	s1,8(sp)
    80002d8a:	e04a                	sd	s2,0(sp)
    80002d8c:	1000                	addi	s0,sp,32
    80002d8e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d90:	0541                	addi	a0,a0,16
    80002d92:	715010ef          	jal	80004ca6 <holdingsleep>
    80002d96:	cd05                	beqz	a0,80002dce <bwrite+0x4c>
  int old_valid = b->valid;
    80002d98:	0004a903          	lw	s2,0(s1)
  virtio_disk_rw(b, 1);
    80002d9c:	4585                	li	a1,1
    80002d9e:	8526                	mv	a0,s1
    80002da0:	241030ef          	jal	800067e0 <virtio_disk_rw>
  b->disk = 0;
    80002da4:	0004a223          	sw	zero,4(s1)
  bcache_report("BWRITE", b, b->refcnt, old_valid, "Writing buffer to disk");
    80002da8:	00005717          	auipc	a4,0x5
    80002dac:	6c070713          	addi	a4,a4,1728 # 80008468 <etext+0x468>
    80002db0:	86ca                	mv	a3,s2
    80002db2:	40b0                	lw	a2,64(s1)
    80002db4:	85a6                	mv	a1,s1
    80002db6:	00005517          	auipc	a0,0x5
    80002dba:	6ca50513          	addi	a0,a0,1738 # 80008480 <etext+0x480>
    80002dbe:	d13ff0ef          	jal	80002ad0 <bcache_report>
}
    80002dc2:	60e2                	ld	ra,24(sp)
    80002dc4:	6442                	ld	s0,16(sp)
    80002dc6:	64a2                	ld	s1,8(sp)
    80002dc8:	6902                	ld	s2,0(sp)
    80002dca:	6105                	addi	sp,sp,32
    80002dcc:	8082                	ret
    panic("bwrite");
    80002dce:	00005517          	auipc	a0,0x5
    80002dd2:	69250513          	addi	a0,a0,1682 # 80008460 <etext+0x460>
    80002dd6:	a3dfd0ef          	jal	80000812 <panic>

0000000080002dda <brelse>:
{
    80002dda:	1101                	addi	sp,sp,-32
    80002ddc:	ec06                	sd	ra,24(sp)
    80002dde:	e822                	sd	s0,16(sp)
    80002de0:	e426                	sd	s1,8(sp)
    80002de2:	e04a                	sd	s2,0(sp)
    80002de4:	1000                	addi	s0,sp,32
    80002de6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002de8:	01050913          	addi	s2,a0,16
    80002dec:	854a                	mv	a0,s2
    80002dee:	6b9010ef          	jal	80004ca6 <holdingsleep>
    80002df2:	cd35                	beqz	a0,80002e6e <brelse+0x94>
  releasesleep(&b->lock);
    80002df4:	854a                	mv	a0,s2
    80002df6:	679010ef          	jal	80004c6e <releasesleep>
  acquire(&bcache.lock);
    80002dfa:	00015517          	auipc	a0,0x15
    80002dfe:	a2650513          	addi	a0,a0,-1498 # 80017820 <bcache>
    80002e02:	dfffd0ef          	jal	80000c00 <acquire>
  int old_ref = b->refcnt;
    80002e06:	40b0                	lw	a2,64(s1)
  b->refcnt--;
    80002e08:	fff6079b          	addiw	a5,a2,-1
    80002e0c:	c0bc                	sw	a5,64(s1)
  bcache_report("BRELEASE", b, old_ref, old_valid, "Released buffer");
    80002e0e:	00005717          	auipc	a4,0x5
    80002e12:	68270713          	addi	a4,a4,1666 # 80008490 <etext+0x490>
    80002e16:	4094                	lw	a3,0(s1)
    80002e18:	85a6                	mv	a1,s1
    80002e1a:	00005517          	auipc	a0,0x5
    80002e1e:	68650513          	addi	a0,a0,1670 # 800084a0 <etext+0x4a0>
    80002e22:	cafff0ef          	jal	80002ad0 <bcache_report>
  if (b->refcnt == 0) {
    80002e26:	40bc                	lw	a5,64(s1)
    80002e28:	e79d                	bnez	a5,80002e56 <brelse+0x7c>
    b->next->prev = b->prev;
    80002e2a:	68b8                	ld	a4,80(s1)
    80002e2c:	64bc                	ld	a5,72(s1)
    80002e2e:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e30:	68b8                	ld	a4,80(s1)
    80002e32:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e34:	0001d797          	auipc	a5,0x1d
    80002e38:	9ec78793          	addi	a5,a5,-1556 # 8001f820 <bcache+0x8000>
    80002e3c:	2b87b703          	ld	a4,696(a5)
    80002e40:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e42:	0001d717          	auipc	a4,0x1d
    80002e46:	c4670713          	addi	a4,a4,-954 # 8001fa88 <bcache+0x8268>
    80002e4a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e4c:	2b87b703          	ld	a4,696(a5)
    80002e50:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e52:	2a97bc23          	sd	s1,696(a5)
  release(&bcache.lock);
    80002e56:	00015517          	auipc	a0,0x15
    80002e5a:	9ca50513          	addi	a0,a0,-1590 # 80017820 <bcache>
    80002e5e:	e3bfd0ef          	jal	80000c98 <release>
}
    80002e62:	60e2                	ld	ra,24(sp)
    80002e64:	6442                	ld	s0,16(sp)
    80002e66:	64a2                	ld	s1,8(sp)
    80002e68:	6902                	ld	s2,0(sp)
    80002e6a:	6105                	addi	sp,sp,32
    80002e6c:	8082                	ret
    panic("brelse");
    80002e6e:	00005517          	auipc	a0,0x5
    80002e72:	61a50513          	addi	a0,a0,1562 # 80008488 <etext+0x488>
    80002e76:	99dfd0ef          	jal	80000812 <panic>

0000000080002e7a <bpin>:
bpin(struct buf *b) {
    80002e7a:	1101                	addi	sp,sp,-32
    80002e7c:	ec06                	sd	ra,24(sp)
    80002e7e:	e822                	sd	s0,16(sp)
    80002e80:	e426                	sd	s1,8(sp)
    80002e82:	1000                	addi	s0,sp,32
    80002e84:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e86:	00015517          	auipc	a0,0x15
    80002e8a:	99a50513          	addi	a0,a0,-1638 # 80017820 <bcache>
    80002e8e:	d73fd0ef          	jal	80000c00 <acquire>
  int old_ref = b->refcnt;
    80002e92:	40b0                	lw	a2,64(s1)
  b->refcnt++;
    80002e94:	0016079b          	addiw	a5,a2,1
    80002e98:	c0bc                	sw	a5,64(s1)
  bcache_report("BPIN", b, old_ref, old_valid, "Pinned buffer"); 
    80002e9a:	00005717          	auipc	a4,0x5
    80002e9e:	61670713          	addi	a4,a4,1558 # 800084b0 <etext+0x4b0>
    80002ea2:	4094                	lw	a3,0(s1)
    80002ea4:	85a6                	mv	a1,s1
    80002ea6:	00005517          	auipc	a0,0x5
    80002eaa:	61a50513          	addi	a0,a0,1562 # 800084c0 <etext+0x4c0>
    80002eae:	c23ff0ef          	jal	80002ad0 <bcache_report>
  release(&bcache.lock);
    80002eb2:	00015517          	auipc	a0,0x15
    80002eb6:	96e50513          	addi	a0,a0,-1682 # 80017820 <bcache>
    80002eba:	ddffd0ef          	jal	80000c98 <release>
}
    80002ebe:	60e2                	ld	ra,24(sp)
    80002ec0:	6442                	ld	s0,16(sp)
    80002ec2:	64a2                	ld	s1,8(sp)
    80002ec4:	6105                	addi	sp,sp,32
    80002ec6:	8082                	ret

0000000080002ec8 <bunpin>:
bunpin(struct buf *b) {
    80002ec8:	1101                	addi	sp,sp,-32
    80002eca:	ec06                	sd	ra,24(sp)
    80002ecc:	e822                	sd	s0,16(sp)
    80002ece:	e426                	sd	s1,8(sp)
    80002ed0:	1000                	addi	s0,sp,32
    80002ed2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ed4:	00015517          	auipc	a0,0x15
    80002ed8:	94c50513          	addi	a0,a0,-1716 # 80017820 <bcache>
    80002edc:	d25fd0ef          	jal	80000c00 <acquire>
  int old_ref = b->refcnt;
    80002ee0:	40b0                	lw	a2,64(s1)
  b->refcnt--;
    80002ee2:	fff6079b          	addiw	a5,a2,-1
    80002ee6:	c0bc                	sw	a5,64(s1)
  bcache_report("BUNPIN",b, old_ref, old_valid, "Unpinned buffer");
    80002ee8:	00005717          	auipc	a4,0x5
    80002eec:	5e070713          	addi	a4,a4,1504 # 800084c8 <etext+0x4c8>
    80002ef0:	4094                	lw	a3,0(s1)
    80002ef2:	85a6                	mv	a1,s1
    80002ef4:	00005517          	auipc	a0,0x5
    80002ef8:	5e450513          	addi	a0,a0,1508 # 800084d8 <etext+0x4d8>
    80002efc:	bd5ff0ef          	jal	80002ad0 <bcache_report>
  release(&bcache.lock);
    80002f00:	00015517          	auipc	a0,0x15
    80002f04:	92050513          	addi	a0,a0,-1760 # 80017820 <bcache>
    80002f08:	d91fd0ef          	jal	80000c98 <release>
}
    80002f0c:	60e2                	ld	ra,24(sp)
    80002f0e:	6442                	ld	s0,16(sp)
    80002f10:	64a2                	ld	s1,8(sp)
    80002f12:	6105                	addi	sp,sp,32
    80002f14:	8082                	ret

0000000080002f16 <dir_report>:
    struct inode *dp,
    char *name,
    uint target,
    uint off,
    char *details
){
    80002f16:	cb010113          	addi	sp,sp,-848
    80002f1a:	34113423          	sd	ra,840(sp)
    80002f1e:	34813023          	sd	s0,832(sp)
    80002f22:	32913c23          	sd	s1,824(sp)
    80002f26:	33213823          	sd	s2,816(sp)
    80002f2a:	33313423          	sd	s3,808(sp)
    80002f2e:	33413023          	sd	s4,800(sp)
    80002f32:	31513c23          	sd	s5,792(sp)
    80002f36:	31613823          	sd	s6,784(sp)
    80002f3a:	0e80                	addi	s0,sp,848
    80002f3c:	8b2a                	mv	s6,a0
    80002f3e:	84ae                	mv	s1,a1
    80002f40:	8932                	mv	s2,a2
    80002f42:	8ab6                	mv	s5,a3
    80002f44:	8a3a                	mv	s4,a4
    80002f46:	89be                	mv	s3,a5
    struct fs_event e;

    memset(&e, 0, sizeof(e));
    80002f48:	30800613          	li	a2,776
    80002f4c:	4581                	li	a1,0
    80002f4e:	cb840513          	addi	a0,s0,-840
    80002f52:	d83fd0ef          	jal	80000cd4 <memset>

    e.ticks = ticks;
    80002f56:	00006797          	auipc	a5,0x6
    80002f5a:	1427a783          	lw	a5,322(a5) # 80009098 <ticks>
    80002f5e:	ccf42023          	sw	a5,-832(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    80002f62:	9a7fe0ef          	jal	80001908 <myproc>
    80002f66:	4781                	li	a5,0
    80002f68:	c501                	beqz	a0,80002f70 <dir_report+0x5a>
    80002f6a:	99ffe0ef          	jal	80001908 <myproc>
    80002f6e:	591c                	lw	a5,48(a0)
    80002f70:	ccf42223          	sw	a5,-828(s0)

    e.type = LAYER_DIR;
    80002f74:	4795                	li	a5,5
    80002f76:	ccf42423          	sw	a5,-824(s0)

    safestrcpy(e.op_name, op, sizeof(e.op_name));
    80002f7a:	4641                	li	a2,16
    80002f7c:	85da                	mv	a1,s6
    80002f7e:	ccc40513          	addi	a0,s0,-820
    80002f82:	e91fd0ef          	jal	80000e12 <safestrcpy>

    if(name)
    80002f86:	00090863          	beqz	s2,80002f96 <dir_report+0x80>
        safestrcpy(e.name, name, sizeof(e.name));
    80002f8a:	4651                	li	a2,20
    80002f8c:	85ca                	mv	a1,s2
    80002f8e:	e6040513          	addi	a0,s0,-416
    80002f92:	e81fd0ef          	jal	80000e12 <safestrcpy>

    e.parent_inum = dp ? dp->inum : -1;
    80002f96:	57fd                	li	a5,-1
    80002f98:	c091                	beqz	s1,80002f9c <dir_report+0x86>
    80002f9a:	40dc                	lw	a5,4(s1)
    80002f9c:	e6f42a23          	sw	a5,-396(s0)
    e.target_inum = target;
    80002fa0:	e7542c23          	sw	s5,-392(s0)
    e.offset = off;
    80002fa4:	e7442e23          	sw	s4,-388(s0)

    safestrcpy(e.details, details, sizeof(e.details));
    80002fa8:	08000613          	li	a2,128
    80002fac:	85ce                	mv	a1,s3
    80002fae:	f4040513          	addi	a0,s0,-192
    80002fb2:	e61fd0ef          	jal	80000e12 <safestrcpy>

    fslog_push(&e);
    80002fb6:	cb840513          	addi	a0,s0,-840
    80002fba:	663030ef          	jal	80006e1c <fslog_push>
}
    80002fbe:	34813083          	ld	ra,840(sp)
    80002fc2:	34013403          	ld	s0,832(sp)
    80002fc6:	33813483          	ld	s1,824(sp)
    80002fca:	33013903          	ld	s2,816(sp)
    80002fce:	32813983          	ld	s3,808(sp)
    80002fd2:	32013a03          	ld	s4,800(sp)
    80002fd6:	31813a83          	ld	s5,792(sp)
    80002fda:	31013b03          	ld	s6,784(sp)
    80002fde:	35010113          	addi	sp,sp,848
    80002fe2:	8082                	ret

0000000080002fe4 <path_report>:
    char *path,
    char *elem,
    char *cwd,
    struct inode *ip,
    char *details
){
    80002fe4:	ca010113          	addi	sp,sp,-864
    80002fe8:	34113c23          	sd	ra,856(sp)
    80002fec:	34813823          	sd	s0,848(sp)
    80002ff0:	34913423          	sd	s1,840(sp)
    80002ff4:	35213023          	sd	s2,832(sp)
    80002ff8:	33313c23          	sd	s3,824(sp)
    80002ffc:	33413823          	sd	s4,816(sp)
    80003000:	33513423          	sd	s5,808(sp)
    80003004:	33613023          	sd	s6,800(sp)
    80003008:	31713c23          	sd	s7,792(sp)
    8000300c:	1680                	addi	s0,sp,864
    8000300e:	8b2a                	mv	s6,a0
    80003010:	8bae                	mv	s7,a1
    80003012:	8a32                	mv	s4,a2
    80003014:	89b6                	mv	s3,a3
    80003016:	8aba                	mv	s5,a4
    80003018:	84be                	mv	s1,a5
    8000301a:	8942                	mv	s2,a6
    struct fs_event e;

    memset(&e, 0, sizeof(e));
    8000301c:	30800613          	li	a2,776
    80003020:	4581                	li	a1,0
    80003022:	ca840513          	addi	a0,s0,-856
    80003026:	caffd0ef          	jal	80000cd4 <memset>

    e.ticks = ticks;
    8000302a:	00006797          	auipc	a5,0x6
    8000302e:	06e7a783          	lw	a5,110(a5) # 80009098 <ticks>
    80003032:	caf42823          	sw	a5,-848(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    80003036:	8d3fe0ef          	jal	80001908 <myproc>
    8000303a:	4781                	li	a5,0
    8000303c:	c501                	beqz	a0,80003044 <path_report+0x60>
    8000303e:	8cbfe0ef          	jal	80001908 <myproc>
    80003042:	591c                	lw	a5,48(a0)
    80003044:	caf42a23          	sw	a5,-844(s0)

    e.type = LAYER_PATH;
    80003048:	4799                	li	a5,6
    8000304a:	caf42c23          	sw	a5,-840(s0)

    if(op)
    8000304e:	000b8863          	beqz	s7,8000305e <path_report+0x7a>
        safestrcpy(e.op_name, op, sizeof(e.op_name));
    80003052:	4641                	li	a2,16
    80003054:	85de                	mv	a1,s7
    80003056:	cbc40513          	addi	a0,s0,-836
    8000305a:	db9fd0ef          	jal	80000e12 <safestrcpy>

    if(syscall)
    8000305e:	000b0963          	beqz	s6,80003070 <path_report+0x8c>
        safestrcpy(e.syscall, syscall, sizeof(e.syscall));
    80003062:	02000613          	li	a2,32
    80003066:	85da                	mv	a1,s6
    80003068:	db040513          	addi	a0,s0,-592
    8000306c:	da7fd0ef          	jal	80000e12 <safestrcpy>

    if(cwd)
    80003070:	000a8963          	beqz	s5,80003082 <path_report+0x9e>
        safestrcpy(e.cwd, cwd, sizeof(e.cwd));
    80003074:	08000613          	li	a2,128
    80003078:	85d6                	mv	a1,s5
    8000307a:	d3040513          	addi	a0,s0,-720
    8000307e:	d95fd0ef          	jal	80000e12 <safestrcpy>

    if(path)
    80003082:	000a0963          	beqz	s4,80003094 <path_report+0xb0>
        safestrcpy(e.path, path, sizeof(e.path));
    80003086:	08000613          	li	a2,128
    8000308a:	85d2                	mv	a1,s4
    8000308c:	dd040513          	addi	a0,s0,-560
    80003090:	d83fd0ef          	jal	80000e12 <safestrcpy>

    if(elem)
    80003094:	00098863          	beqz	s3,800030a4 <path_report+0xc0>
        safestrcpy(e.name, elem, sizeof(e.name));
    80003098:	4651                	li	a2,20
    8000309a:	85ce                	mv	a1,s3
    8000309c:	e5040513          	addi	a0,s0,-432
    800030a0:	d73fd0ef          	jal	80000e12 <safestrcpy>

    e.parent_inum = ip ? ip->inum : -1;
    800030a4:	57fd                	li	a5,-1
    800030a6:	c091                	beqz	s1,800030aa <path_report+0xc6>
    800030a8:	40dc                	lw	a5,4(s1)
    800030aa:	e6f42223          	sw	a5,-412(s0)

    if(details)
    800030ae:	00090963          	beqz	s2,800030c0 <path_report+0xdc>
        safestrcpy(e.details, details, sizeof(e.details));
    800030b2:	08000613          	li	a2,128
    800030b6:	85ca                	mv	a1,s2
    800030b8:	f3040513          	addi	a0,s0,-208
    800030bc:	d57fd0ef          	jal	80000e12 <safestrcpy>

    fslog_push(&e);
    800030c0:	ca840513          	addi	a0,s0,-856
    800030c4:	559030ef          	jal	80006e1c <fslog_push>
}
    800030c8:	35813083          	ld	ra,856(sp)
    800030cc:	35013403          	ld	s0,848(sp)
    800030d0:	34813483          	ld	s1,840(sp)
    800030d4:	34013903          	ld	s2,832(sp)
    800030d8:	33813983          	ld	s3,824(sp)
    800030dc:	33013a03          	ld	s4,816(sp)
    800030e0:	32813a83          	ld	s5,808(sp)
    800030e4:	32013b03          	ld	s6,800(sp)
    800030e8:	31813b83          	ld	s7,792(sp)
    800030ec:	36010113          	addi	sp,sp,864
    800030f0:	8082                	ret

00000000800030f2 <balloc_report>:
void balloc_report(char* op, int blockno, int old_bit, int new_bit, char* det) {
    800030f2:	cb010113          	addi	sp,sp,-848
    800030f6:	34113423          	sd	ra,840(sp)
    800030fa:	34813023          	sd	s0,832(sp)
    800030fe:	32913c23          	sd	s1,824(sp)
    80003102:	33213823          	sd	s2,816(sp)
    80003106:	33313423          	sd	s3,808(sp)
    8000310a:	33413023          	sd	s4,800(sp)
    8000310e:	31513c23          	sd	s5,792(sp)
    80003112:	0e80                	addi	s0,sp,848
    80003114:	8aaa                	mv	s5,a0
    80003116:	8a2e                	mv	s4,a1
    80003118:	89b2                	mv	s3,a2
    8000311a:	8936                	mv	s2,a3
    8000311c:	84ba                	mv	s1,a4
    memset(&e, 0, sizeof(e));
    8000311e:	30800613          	li	a2,776
    80003122:	4581                	li	a1,0
    80003124:	cb840513          	addi	a0,s0,-840
    80003128:	badfd0ef          	jal	80000cd4 <memset>
    e.ticks = ticks;
    8000312c:	00006797          	auipc	a5,0x6
    80003130:	f6c7a783          	lw	a5,-148(a5) # 80009098 <ticks>
    80003134:	ccf42023          	sw	a5,-832(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    80003138:	fd0fe0ef          	jal	80001908 <myproc>
    8000313c:	4781                	li	a5,0
    8000313e:	c501                	beqz	a0,80003146 <balloc_report+0x54>
    80003140:	fc8fe0ef          	jal	80001908 <myproc>
    80003144:	591c                	lw	a5,48(a0)
    80003146:	ccf42223          	sw	a5,-828(s0)
    e.type = LAYER_BALLOC;
    8000314a:	478d                	li	a5,3
    8000314c:	ccf42423          	sw	a5,-824(s0)
    safestrcpy(e.op_name, op, 16);
    80003150:	4641                	li	a2,16
    80003152:	85d6                	mv	a1,s5
    80003154:	ccc40513          	addi	a0,s0,-820
    80003158:	cbbfd0ef          	jal	80000e12 <safestrcpy>
    e.blockno = blockno;
    8000315c:	cd442e23          	sw	s4,-804(s0)
    e.old_bit = old_bit;
    80003160:	d1342823          	sw	s3,-752(s0)
    e.bit = new_bit;
    80003164:	d1242623          	sw	s2,-756(s0)
    safestrcpy(e.details, det, 128);
    80003168:	08000613          	li	a2,128
    8000316c:	85a6                	mv	a1,s1
    8000316e:	f4040513          	addi	a0,s0,-192
    80003172:	ca1fd0ef          	jal	80000e12 <safestrcpy>
    fslog_push(&e);
    80003176:	cb840513          	addi	a0,s0,-840
    8000317a:	4a3030ef          	jal	80006e1c <fslog_push>
}
    8000317e:	34813083          	ld	ra,840(sp)
    80003182:	34013403          	ld	s0,832(sp)
    80003186:	33813483          	ld	s1,824(sp)
    8000318a:	33013903          	ld	s2,816(sp)
    8000318e:	32813983          	ld	s3,808(sp)
    80003192:	32013a03          	ld	s4,800(sp)
    80003196:	31813a83          	ld	s5,792(sp)
    8000319a:	35010113          	addi	sp,sp,848
    8000319e:	8082                	ret

00000000800031a0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031a0:	1101                	addi	sp,sp,-32
    800031a2:	ec06                	sd	ra,24(sp)
    800031a4:	e822                	sd	s0,16(sp)
    800031a6:	e426                	sd	s1,8(sp)
    800031a8:	e04a                	sd	s2,0(sp)
    800031aa:	1000                	addi	s0,sp,32
    800031ac:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031ae:	00d5d59b          	srliw	a1,a1,0xd
    800031b2:	0001d797          	auipc	a5,0x1d
    800031b6:	d4a7a783          	lw	a5,-694(a5) # 8001fefc <sb+0x1c>
    800031ba:	9dbd                	addw	a1,a1,a5
    800031bc:	a89ff0ef          	jal	80002c44 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031c0:	0074f793          	andi	a5,s1,7
    800031c4:	4705                	li	a4,1
    800031c6:	00f7173b          	sllw	a4,a4,a5
  if((bp->data[bi/8] & m) == 0)
    800031ca:	03349793          	slli	a5,s1,0x33
    800031ce:	93d9                	srli	a5,a5,0x36
    800031d0:	00f506b3          	add	a3,a0,a5
    800031d4:	0586c683          	lbu	a3,88(a3) # 1058 <_entry-0x7fffefa8>
    800031d8:	00d77633          	and	a2,a4,a3
    800031dc:	c229                	beqz	a2,8000321e <bfree+0x7e>
    800031de:	892a                	mv	s2,a0
    panic("freeing free block");
  int old_bit = 1;
  bp->data[bi/8] &= ~m;
    800031e0:	97aa                	add	a5,a5,a0
    800031e2:	fff74713          	not	a4,a4
    800031e6:	8ef9                	and	a3,a3,a4
    800031e8:	04d78c23          	sb	a3,88(a5)
  balloc_report("BFREE", b, old_bit, 0, "Freed block");
    800031ec:	00005717          	auipc	a4,0x5
    800031f0:	30c70713          	addi	a4,a4,780 # 800084f8 <etext+0x4f8>
    800031f4:	4681                	li	a3,0
    800031f6:	4605                	li	a2,1
    800031f8:	85a6                	mv	a1,s1
    800031fa:	00005517          	auipc	a0,0x5
    800031fe:	30e50513          	addi	a0,a0,782 # 80008508 <etext+0x508>
    80003202:	ef1ff0ef          	jal	800030f2 <balloc_report>
  log_write(bp);
    80003206:	854a                	mv	a0,s2
    80003208:	103010ef          	jal	80004b0a <log_write>
  brelse(bp);
    8000320c:	854a                	mv	a0,s2
    8000320e:	bcdff0ef          	jal	80002dda <brelse>
}
    80003212:	60e2                	ld	ra,24(sp)
    80003214:	6442                	ld	s0,16(sp)
    80003216:	64a2                	ld	s1,8(sp)
    80003218:	6902                	ld	s2,0(sp)
    8000321a:	6105                	addi	sp,sp,32
    8000321c:	8082                	ret
    panic("freeing free block");
    8000321e:	00005517          	auipc	a0,0x5
    80003222:	2c250513          	addi	a0,a0,706 # 800084e0 <etext+0x4e0>
    80003226:	decfd0ef          	jal	80000812 <panic>

000000008000322a <balloc>:
{
    8000322a:	711d                	addi	sp,sp,-96
    8000322c:	ec86                	sd	ra,88(sp)
    8000322e:	e8a2                	sd	s0,80(sp)
    80003230:	e4a6                	sd	s1,72(sp)
    80003232:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003234:	0001d797          	auipc	a5,0x1d
    80003238:	cb07a783          	lw	a5,-848(a5) # 8001fee4 <sb+0x4>
    8000323c:	10078c63          	beqz	a5,80003354 <balloc+0x12a>
    80003240:	e0ca                	sd	s2,64(sp)
    80003242:	fc4e                	sd	s3,56(sp)
    80003244:	f852                	sd	s4,48(sp)
    80003246:	f456                	sd	s5,40(sp)
    80003248:	f05a                	sd	s6,32(sp)
    8000324a:	ec5e                	sd	s7,24(sp)
    8000324c:	e862                	sd	s8,16(sp)
    8000324e:	e466                	sd	s9,8(sp)
    80003250:	8baa                	mv	s7,a0
    80003252:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003254:	0001db17          	auipc	s6,0x1d
    80003258:	c8cb0b13          	addi	s6,s6,-884 # 8001fee0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000325c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000325e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003260:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003262:	6c89                	lui	s9,0x2
    80003264:	a059                	j	800032ea <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003266:	97ca                	add	a5,a5,s2
    80003268:	8e55                	or	a2,a2,a3
    8000326a:	04c78c23          	sb	a2,88(a5)
        balloc_report("BALLOC", b + bi, old_bit, 1, "Allocated block");
    8000326e:	00005717          	auipc	a4,0x5
    80003272:	2a270713          	addi	a4,a4,674 # 80008510 <etext+0x510>
    80003276:	4685                	li	a3,1
    80003278:	4601                	li	a2,0
    8000327a:	85a6                	mv	a1,s1
    8000327c:	00005517          	auipc	a0,0x5
    80003280:	2a450513          	addi	a0,a0,676 # 80008520 <etext+0x520>
    80003284:	e6fff0ef          	jal	800030f2 <balloc_report>
        log_write(bp);
    80003288:	854a                	mv	a0,s2
    8000328a:	081010ef          	jal	80004b0a <log_write>
        brelse(bp);
    8000328e:	854a                	mv	a0,s2
    80003290:	b4bff0ef          	jal	80002dda <brelse>
  bp = bread(dev, bno);
    80003294:	85a6                	mv	a1,s1
    80003296:	855e                	mv	a0,s7
    80003298:	9adff0ef          	jal	80002c44 <bread>
    8000329c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000329e:	40000613          	li	a2,1024
    800032a2:	4581                	li	a1,0
    800032a4:	05850513          	addi	a0,a0,88
    800032a8:	a2dfd0ef          	jal	80000cd4 <memset>
  log_write(bp);
    800032ac:	854a                	mv	a0,s2
    800032ae:	05d010ef          	jal	80004b0a <log_write>
  brelse(bp);
    800032b2:	854a                	mv	a0,s2
    800032b4:	b27ff0ef          	jal	80002dda <brelse>
}
    800032b8:	6906                	ld	s2,64(sp)
    800032ba:	79e2                	ld	s3,56(sp)
    800032bc:	7a42                	ld	s4,48(sp)
    800032be:	7aa2                	ld	s5,40(sp)
    800032c0:	7b02                	ld	s6,32(sp)
    800032c2:	6be2                	ld	s7,24(sp)
    800032c4:	6c42                	ld	s8,16(sp)
    800032c6:	6ca2                	ld	s9,8(sp)
}
    800032c8:	8526                	mv	a0,s1
    800032ca:	60e6                	ld	ra,88(sp)
    800032cc:	6446                	ld	s0,80(sp)
    800032ce:	64a6                	ld	s1,72(sp)
    800032d0:	6125                	addi	sp,sp,96
    800032d2:	8082                	ret
    brelse(bp);
    800032d4:	854a                	mv	a0,s2
    800032d6:	b05ff0ef          	jal	80002dda <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032da:	015c87bb          	addw	a5,s9,s5
    800032de:	00078a9b          	sext.w	s5,a5
    800032e2:	004b2703          	lw	a4,4(s6)
    800032e6:	04eaff63          	bgeu	s5,a4,80003344 <balloc+0x11a>
    bp = bread(dev, BBLOCK(b, sb));
    800032ea:	41fad79b          	sraiw	a5,s5,0x1f
    800032ee:	0137d79b          	srliw	a5,a5,0x13
    800032f2:	015787bb          	addw	a5,a5,s5
    800032f6:	40d7d79b          	sraiw	a5,a5,0xd
    800032fa:	01cb2583          	lw	a1,28(s6)
    800032fe:	9dbd                	addw	a1,a1,a5
    80003300:	855e                	mv	a0,s7
    80003302:	943ff0ef          	jal	80002c44 <bread>
    80003306:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003308:	004b2503          	lw	a0,4(s6)
    8000330c:	000a849b          	sext.w	s1,s5
    80003310:	8762                	mv	a4,s8
    80003312:	fca4f1e3          	bgeu	s1,a0,800032d4 <balloc+0xaa>
      m = 1 << (bi % 8);
    80003316:	00777693          	andi	a3,a4,7
    8000331a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){
    8000331e:	41f7579b          	sraiw	a5,a4,0x1f
    80003322:	01d7d79b          	srliw	a5,a5,0x1d
    80003326:	9fb9                	addw	a5,a5,a4
    80003328:	4037d79b          	sraiw	a5,a5,0x3
    8000332c:	00f90633          	add	a2,s2,a5
    80003330:	05864603          	lbu	a2,88(a2)
    80003334:	00c6f5b3          	and	a1,a3,a2
    80003338:	d59d                	beqz	a1,80003266 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000333a:	2705                	addiw	a4,a4,1
    8000333c:	2485                	addiw	s1,s1,1
    8000333e:	fd471ae3          	bne	a4,s4,80003312 <balloc+0xe8>
    80003342:	bf49                	j	800032d4 <balloc+0xaa>
    80003344:	6906                	ld	s2,64(sp)
    80003346:	79e2                	ld	s3,56(sp)
    80003348:	7a42                	ld	s4,48(sp)
    8000334a:	7aa2                	ld	s5,40(sp)
    8000334c:	7b02                	ld	s6,32(sp)
    8000334e:	6be2                	ld	s7,24(sp)
    80003350:	6c42                	ld	s8,16(sp)
    80003352:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003354:	00005517          	auipc	a0,0x5
    80003358:	1d450513          	addi	a0,a0,468 # 80008528 <etext+0x528>
    8000335c:	9d0fd0ef          	jal	8000052c <printf>
  return 0;
    80003360:	4481                	li	s1,0
    80003362:	b79d                	j	800032c8 <balloc+0x9e>

0000000080003364 <inode_report>:
{
    80003364:	ca010113          	addi	sp,sp,-864
    80003368:	34113c23          	sd	ra,856(sp)
    8000336c:	34813823          	sd	s0,848(sp)
    80003370:	34913423          	sd	s1,840(sp)
    80003374:	35213023          	sd	s2,832(sp)
    80003378:	33313c23          	sd	s3,824(sp)
    8000337c:	33413823          	sd	s4,816(sp)
    80003380:	33513423          	sd	s5,808(sp)
    80003384:	33613023          	sd	s6,800(sp)
    80003388:	31713c23          	sd	s7,792(sp)
    8000338c:	31813823          	sd	s8,784(sp)
    80003390:	1680                	addi	s0,sp,864
    80003392:	8c2a                	mv	s8,a0
    80003394:	84ae                	mv	s1,a1
    80003396:	8bb2                	mv	s7,a2
    80003398:	8b36                	mv	s6,a3
    8000339a:	8aba                	mv	s5,a4
    8000339c:	8a3e                	mv	s4,a5
    8000339e:	89c2                	mv	s3,a6
    800033a0:	8946                	mv	s2,a7
  memset(&e, 0, sizeof(e));
    800033a2:	30800613          	li	a2,776
    800033a6:	4581                	li	a1,0
    800033a8:	ca840513          	addi	a0,s0,-856
    800033ac:	929fd0ef          	jal	80000cd4 <memset>
  e.ticks = ticks;
    800033b0:	00006797          	auipc	a5,0x6
    800033b4:	ce87a783          	lw	a5,-792(a5) # 80009098 <ticks>
    800033b8:	caf42823          	sw	a5,-848(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    800033bc:	d4cfe0ef          	jal	80001908 <myproc>
    800033c0:	4781                	li	a5,0
    800033c2:	c501                	beqz	a0,800033ca <inode_report+0x66>
    800033c4:	d44fe0ef          	jal	80001908 <myproc>
    800033c8:	591c                	lw	a5,48(a0)
    800033ca:	caf42a23          	sw	a5,-844(s0)
  e.type = LAYER_INODE;
    800033ce:	4791                	li	a5,4
    800033d0:	caf42c23          	sw	a5,-840(s0)
  safestrcpy(e.op_name, op, 16);
    800033d4:	4641                	li	a2,16
    800033d6:	85e2                	mv	a1,s8
    800033d8:	cbc40513          	addi	a0,s0,-836
    800033dc:	a37fd0ef          	jal	80000e12 <safestrcpy>
  e.inum = ip->inum;
    800033e0:	40dc                	lw	a5,4(s1)
    800033e2:	d0f42223          	sw	a5,-764(s0)
  e.ref = ip->ref;
    800033e6:	449c                	lw	a5,8(s1)
    800033e8:	d0f42423          	sw	a5,-760(s0)
  e.old_ref = old_ref;
    800033ec:	d1742623          	sw	s7,-756(s0)
  e.valid_inode = ip->valid;
    800033f0:	40bc                	lw	a5,64(s1)
    800033f2:	d0f42823          	sw	a5,-752(s0)
  e.old_valid_inode = old_valid;
    800033f6:	d1642a23          	sw	s6,-748(s0)
  e.inode_type = ip->type;
    800033fa:	04449783          	lh	a5,68(s1)
    800033fe:	d0f42c23          	sw	a5,-744(s0)
  e.old_type_inode = old_type;
    80003402:	d1542e23          	sw	s5,-740(s0)
  e.size = ip->size;
    80003406:	44fc                	lw	a5,76(s1)
    80003408:	d2f42023          	sw	a5,-736(s0)
  e.old_size = old_size;
    8000340c:	d3442223          	sw	s4,-732(s0)
  e.locked = holdingsleep(&ip->lock);
    80003410:	01048513          	addi	a0,s1,16
    80003414:	093010ef          	jal	80004ca6 <holdingsleep>
    80003418:	d2a42423          	sw	a0,-728(s0)
  e.old_locked = old_locked;
    8000341c:	d3342623          	sw	s3,-724(s0)
  safestrcpy(e.details, det, 128);
    80003420:	08000613          	li	a2,128
    80003424:	85ca                	mv	a1,s2
    80003426:	f3040513          	addi	a0,s0,-208
    8000342a:	9e9fd0ef          	jal	80000e12 <safestrcpy>
  fslog_push(&e);
    8000342e:	ca840513          	addi	a0,s0,-856
    80003432:	1eb030ef          	jal	80006e1c <fslog_push>
}
    80003436:	35813083          	ld	ra,856(sp)
    8000343a:	35013403          	ld	s0,848(sp)
    8000343e:	34813483          	ld	s1,840(sp)
    80003442:	34013903          	ld	s2,832(sp)
    80003446:	33813983          	ld	s3,824(sp)
    8000344a:	33013a03          	ld	s4,816(sp)
    8000344e:	32813a83          	ld	s5,808(sp)
    80003452:	32013b03          	ld	s6,800(sp)
    80003456:	31813b83          	ld	s7,792(sp)
    8000345a:	31013c03          	ld	s8,784(sp)
    8000345e:	36010113          	addi	sp,sp,864
    80003462:	8082                	ret

0000000080003464 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
    80003464:	7139                	addi	sp,sp,-64
    80003466:	fc06                	sd	ra,56(sp)
    80003468:	f822                	sd	s0,48(sp)
    8000346a:	f426                	sd	s1,40(sp)
    8000346c:	f04a                	sd	s2,32(sp)
    8000346e:	ec4e                	sd	s3,24(sp)
    80003470:	e852                	sd	s4,16(sp)
    80003472:	e456                	sd	s5,8(sp)
    80003474:	0080                	addi	s0,sp,64
    80003476:	8a2a                	mv	s4,a0
    80003478:	8aae                	mv	s5,a1
  struct inode *ip, *empty;

  acquire(&itable.lock);
    8000347a:	0001d517          	auipc	a0,0x1d
    8000347e:	a8650513          	addi	a0,a0,-1402 # 8001ff00 <itable>
    80003482:	f7efd0ef          	jal	80000c00 <acquire>

  // Is the inode already in the table?
  empty = 0;
    80003486:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003488:	0001d497          	auipc	s1,0x1d
    8000348c:	a9048493          	addi	s1,s1,-1392 # 8001ff18 <itable+0x18>
    80003490:	0001e717          	auipc	a4,0x1e
    80003494:	51870713          	addi	a4,a4,1304 # 800219a8 <log>
    80003498:	a039                	j	800034a6 <iget+0x42>
      holdingsleep(&ip->lock),
      "Inode found in cache");
      release(&itable.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000349a:	06098563          	beqz	s3,80003504 <iget+0xa0>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000349e:	08848493          	addi	s1,s1,136
    800034a2:	06e48563          	beq	s1,a4,8000350c <iget+0xa8>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034a6:	0084a903          	lw	s2,8(s1)
    800034aa:	ff2058e3          	blez	s2,8000349a <iget+0x36>
    800034ae:	409c                	lw	a5,0(s1)
    800034b0:	ff4795e3          	bne	a5,s4,8000349a <iget+0x36>
    800034b4:	40dc                	lw	a5,4(s1)
    800034b6:	ff5792e3          	bne	a5,s5,8000349a <iget+0x36>
      ip->ref++;
    800034ba:	0019079b          	addiw	a5,s2,1
    800034be:	c49c                	sw	a5,8(s1)
       inode_report("IGET_HIT", ip,
    800034c0:	0404a983          	lw	s3,64(s1)
    800034c4:	04449a03          	lh	s4,68(s1)
    800034c8:	04c4aa83          	lw	s5,76(s1)
    800034cc:	01048513          	addi	a0,s1,16
    800034d0:	7d6010ef          	jal	80004ca6 <holdingsleep>
    800034d4:	00005897          	auipc	a7,0x5
    800034d8:	06c88893          	addi	a7,a7,108 # 80008540 <etext+0x540>
    800034dc:	882a                	mv	a6,a0
    800034de:	87d6                	mv	a5,s5
    800034e0:	8752                	mv	a4,s4
    800034e2:	86ce                	mv	a3,s3
    800034e4:	864a                	mv	a2,s2
    800034e6:	85a6                	mv	a1,s1
    800034e8:	00005517          	auipc	a0,0x5
    800034ec:	07050513          	addi	a0,a0,112 # 80008558 <etext+0x558>
    800034f0:	e75ff0ef          	jal	80003364 <inode_report>
      release(&itable.lock);
    800034f4:	0001d517          	auipc	a0,0x1d
    800034f8:	a0c50513          	addi	a0,a0,-1524 # 8001ff00 <itable>
    800034fc:	f9cfd0ef          	jal	80000c98 <release>
      return ip;
    80003500:	89a6                	mv	s3,s1
    80003502:	a0b1                	j	8000354e <iget+0xea>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003504:	f8091de3          	bnez	s2,8000349e <iget+0x3a>
      empty = ip;
    80003508:	89a6                	mv	s3,s1
    8000350a:	bf51                	j	8000349e <iget+0x3a>
  }

  // Recycle an inode entry.
  if(empty == 0)
    8000350c:	04098b63          	beqz	s3,80003562 <iget+0xfe>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
    80003510:	0149a023          	sw	s4,0(s3)
  ip->inum = inum;
    80003514:	0159a223          	sw	s5,4(s3)
  ip->ref = 1;
    80003518:	4785                	li	a5,1
    8000351a:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    8000351e:	0409a023          	sw	zero,64(s3)
  inode_report("IGET_NEW", ip,
    80003522:	00005897          	auipc	a7,0x5
    80003526:	05688893          	addi	a7,a7,86 # 80008578 <etext+0x578>
    8000352a:	4801                	li	a6,0
    8000352c:	4781                	li	a5,0
    8000352e:	4701                	li	a4,0
    80003530:	4681                	li	a3,0
    80003532:	4601                	li	a2,0
    80003534:	85ce                	mv	a1,s3
    80003536:	00005517          	auipc	a0,0x5
    8000353a:	06250513          	addi	a0,a0,98 # 80008598 <etext+0x598>
    8000353e:	e27ff0ef          	jal	80003364 <inode_report>
    0, 0,
    0, 0,
    0,
    "Allocated new inode in table");
  release(&itable.lock);
    80003542:	0001d517          	auipc	a0,0x1d
    80003546:	9be50513          	addi	a0,a0,-1602 # 8001ff00 <itable>
    8000354a:	f4efd0ef          	jal	80000c98 <release>

  return ip;
}
    8000354e:	854e                	mv	a0,s3
    80003550:	70e2                	ld	ra,56(sp)
    80003552:	7442                	ld	s0,48(sp)
    80003554:	74a2                	ld	s1,40(sp)
    80003556:	7902                	ld	s2,32(sp)
    80003558:	69e2                	ld	s3,24(sp)
    8000355a:	6a42                	ld	s4,16(sp)
    8000355c:	6aa2                	ld	s5,8(sp)
    8000355e:	6121                	addi	sp,sp,64
    80003560:	8082                	ret
    panic("iget: no inodes");
    80003562:	00005517          	auipc	a0,0x5
    80003566:	00650513          	addi	a0,a0,6 # 80008568 <etext+0x568>
    8000356a:	aa8fd0ef          	jal	80000812 <panic>

000000008000356e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000356e:	7179                	addi	sp,sp,-48
    80003570:	f406                	sd	ra,40(sp)
    80003572:	f022                	sd	s0,32(sp)
    80003574:	ec26                	sd	s1,24(sp)
    80003576:	e84a                	sd	s2,16(sp)
    80003578:	e44e                	sd	s3,8(sp)
    8000357a:	1800                	addi	s0,sp,48
    8000357c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000357e:	47ad                	li	a5,11
    80003580:	04b7ea63          	bltu	a5,a1,800035d4 <bmap+0x66>
    if((addr = ip->addrs[bn]) == 0){
    80003584:	02059793          	slli	a5,a1,0x20
    80003588:	01e7d593          	srli	a1,a5,0x1e
    8000358c:	00b504b3          	add	s1,a0,a1
    80003590:	0504a983          	lw	s3,80(s1)
    80003594:	0c099263          	bnez	s3,80003658 <bmap+0xea>
      addr = balloc(ip->dev);
    80003598:	4108                	lw	a0,0(a0)
    8000359a:	c91ff0ef          	jal	8000322a <balloc>
    8000359e:	0005099b          	sext.w	s3,a0

      inode_report("BMAP_ALLOC_DIRECT", ip,
    800035a2:	00005897          	auipc	a7,0x5
    800035a6:	00688893          	addi	a7,a7,6 # 800085a8 <etext+0x5a8>
    800035aa:	4805                	li	a6,1
    800035ac:	04c92783          	lw	a5,76(s2)
    800035b0:	04491703          	lh	a4,68(s2)
    800035b4:	04092683          	lw	a3,64(s2)
    800035b8:	00892603          	lw	a2,8(s2)
    800035bc:	85ca                	mv	a1,s2
    800035be:	00005517          	auipc	a0,0x5
    800035c2:	00250513          	addi	a0,a0,2 # 800085c0 <etext+0x5c0>
    800035c6:	d9fff0ef          	jal	80003364 <inode_report>
        ip->valid,
        ip->type,
        ip->size,
        1,
        "Allocated direct block");
      if(addr == 0)
    800035ca:	08098763          	beqz	s3,80003658 <bmap+0xea>
        return 0;
      ip->addrs[bn] = addr;
    800035ce:	0534a823          	sw	s3,80(s1)
    800035d2:	a059                	j	80003658 <bmap+0xea>
    }
    return addr;
  }
  bn -= NDIRECT;
    800035d4:	ff45849b          	addiw	s1,a1,-12
    800035d8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035dc:	0ff00793          	li	a5,255
    800035e0:	0ce7e663          	bltu	a5,a4,800036ac <bmap+0x13e>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800035e4:	08052983          	lw	s3,128(a0)
    800035e8:	04099163          	bnez	s3,8000362a <bmap+0xbc>
      addr = balloc(ip->dev);
    800035ec:	4108                	lw	a0,0(a0)
    800035ee:	c3dff0ef          	jal	8000322a <balloc>
    800035f2:	0005099b          	sext.w	s3,a0
      inode_report("BMAP_ALLOC_INDIRECT", ip,
    800035f6:	00005897          	auipc	a7,0x5
    800035fa:	fe288893          	addi	a7,a7,-30 # 800085d8 <etext+0x5d8>
    800035fe:	4805                	li	a6,1
    80003600:	04c92783          	lw	a5,76(s2)
    80003604:	04491703          	lh	a4,68(s2)
    80003608:	04092683          	lw	a3,64(s2)
    8000360c:	00892603          	lw	a2,8(s2)
    80003610:	85ca                	mv	a1,s2
    80003612:	00005517          	auipc	a0,0x5
    80003616:	fe650513          	addi	a0,a0,-26 # 800085f8 <etext+0x5f8>
    8000361a:	d4bff0ef          	jal	80003364 <inode_report>
        ip->valid,
        ip->type,
        ip->size,
        1,
        "Allocated indirect block table");
      if(addr == 0)
    8000361e:	02098d63          	beqz	s3,80003658 <bmap+0xea>
    80003622:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003624:	09392023          	sw	s3,128(s2)
    80003628:	a011                	j	8000362c <bmap+0xbe>
    8000362a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000362c:	85ce                	mv	a1,s3
    8000362e:	00092503          	lw	a0,0(s2)
    80003632:	e12ff0ef          	jal	80002c44 <bread>
    80003636:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003638:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000363c:	02049713          	slli	a4,s1,0x20
    80003640:	01e75593          	srli	a1,a4,0x1e
    80003644:	00b784b3          	add	s1,a5,a1
    80003648:	0004a983          	lw	s3,0(s1)
    8000364c:	00098e63          	beqz	s3,80003668 <bmap+0xfa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003650:	8552                	mv	a0,s4
    80003652:	f88ff0ef          	jal	80002dda <brelse>
    return addr;
    80003656:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003658:	854e                	mv	a0,s3
    8000365a:	70a2                	ld	ra,40(sp)
    8000365c:	7402                	ld	s0,32(sp)
    8000365e:	64e2                	ld	s1,24(sp)
    80003660:	6942                	ld	s2,16(sp)
    80003662:	69a2                	ld	s3,8(sp)
    80003664:	6145                	addi	sp,sp,48
    80003666:	8082                	ret
      inode_report("BMAP_ALLOC_DATA", ip,
    80003668:	00005897          	auipc	a7,0x5
    8000366c:	fa888893          	addi	a7,a7,-88 # 80008610 <etext+0x610>
    80003670:	4805                	li	a6,1
    80003672:	04c92783          	lw	a5,76(s2)
    80003676:	04491703          	lh	a4,68(s2)
    8000367a:	04092683          	lw	a3,64(s2)
    8000367e:	00892603          	lw	a2,8(s2)
    80003682:	85ca                	mv	a1,s2
    80003684:	00005517          	auipc	a0,0x5
    80003688:	fac50513          	addi	a0,a0,-84 # 80008630 <etext+0x630>
    8000368c:	cd9ff0ef          	jal	80003364 <inode_report>
      addr = balloc(ip->dev);
    80003690:	00092503          	lw	a0,0(s2)
    80003694:	b97ff0ef          	jal	8000322a <balloc>
    80003698:	0005099b          	sext.w	s3,a0
      if(addr){
    8000369c:	fa098ae3          	beqz	s3,80003650 <bmap+0xe2>
        a[bn] = addr;
    800036a0:	0134a023          	sw	s3,0(s1)
        log_write(bp);
    800036a4:	8552                	mv	a0,s4
    800036a6:	464010ef          	jal	80004b0a <log_write>
    800036aa:	b75d                	j	80003650 <bmap+0xe2>
    800036ac:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800036ae:	00005517          	auipc	a0,0x5
    800036b2:	f9250513          	addi	a0,a0,-110 # 80008640 <etext+0x640>
    800036b6:	95cfd0ef          	jal	80000812 <panic>

00000000800036ba <iinit>:
{
    800036ba:	7179                	addi	sp,sp,-48
    800036bc:	f406                	sd	ra,40(sp)
    800036be:	f022                	sd	s0,32(sp)
    800036c0:	ec26                	sd	s1,24(sp)
    800036c2:	e84a                	sd	s2,16(sp)
    800036c4:	e44e                	sd	s3,8(sp)
    800036c6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800036c8:	00005597          	auipc	a1,0x5
    800036cc:	f9058593          	addi	a1,a1,-112 # 80008658 <etext+0x658>
    800036d0:	0001d517          	auipc	a0,0x1d
    800036d4:	83050513          	addi	a0,a0,-2000 # 8001ff00 <itable>
    800036d8:	ca8fd0ef          	jal	80000b80 <initlock>
  for(i = 0; i < NINODE; i++) {
    800036dc:	0001d497          	auipc	s1,0x1d
    800036e0:	84c48493          	addi	s1,s1,-1972 # 8001ff28 <itable+0x28>
    800036e4:	0001e997          	auipc	s3,0x1e
    800036e8:	2d498993          	addi	s3,s3,724 # 800219b8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800036ec:	00005917          	auipc	s2,0x5
    800036f0:	ffc90913          	addi	s2,s2,-4 # 800086e8 <etext+0x6e8>
    800036f4:	85ca                	mv	a1,s2
    800036f6:	8526                	mv	a0,s1
    800036f8:	4fa010ef          	jal	80004bf2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036fc:	08848493          	addi	s1,s1,136
    80003700:	ff349ae3          	bne	s1,s3,800036f4 <iinit+0x3a>
}
    80003704:	70a2                	ld	ra,40(sp)
    80003706:	7402                	ld	s0,32(sp)
    80003708:	64e2                	ld	s1,24(sp)
    8000370a:	6942                	ld	s2,16(sp)
    8000370c:	69a2                	ld	s3,8(sp)
    8000370e:	6145                	addi	sp,sp,48
    80003710:	8082                	ret

0000000080003712 <ialloc>:
{
    80003712:	7139                	addi	sp,sp,-64
    80003714:	fc06                	sd	ra,56(sp)
    80003716:	f822                	sd	s0,48(sp)
    80003718:	f04a                	sd	s2,32(sp)
    8000371a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000371c:	0001c717          	auipc	a4,0x1c
    80003720:	7d072703          	lw	a4,2000(a4) # 8001feec <sb+0xc>
    80003724:	4785                	li	a5,1
    80003726:	04e7fe63          	bgeu	a5,a4,80003782 <ialloc+0x70>
    8000372a:	f426                	sd	s1,40(sp)
    8000372c:	ec4e                	sd	s3,24(sp)
    8000372e:	e852                	sd	s4,16(sp)
    80003730:	e456                	sd	s5,8(sp)
    80003732:	e05a                	sd	s6,0(sp)
    80003734:	8aaa                	mv	s5,a0
    80003736:	8b2e                	mv	s6,a1
    80003738:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000373a:	0001ca17          	auipc	s4,0x1c
    8000373e:	7a6a0a13          	addi	s4,s4,1958 # 8001fee0 <sb>
    80003742:	00495593          	srli	a1,s2,0x4
    80003746:	018a2783          	lw	a5,24(s4)
    8000374a:	9dbd                	addw	a1,a1,a5
    8000374c:	8556                	mv	a0,s5
    8000374e:	cf6ff0ef          	jal	80002c44 <bread>
    80003752:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003754:	05850993          	addi	s3,a0,88
    80003758:	00f97793          	andi	a5,s2,15
    8000375c:	079a                	slli	a5,a5,0x6
    8000375e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003760:	00099783          	lh	a5,0(s3)
    80003764:	cf85                	beqz	a5,8000379c <ialloc+0x8a>
    brelse(bp);
    80003766:	e74ff0ef          	jal	80002dda <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000376a:	0905                	addi	s2,s2,1
    8000376c:	00ca2703          	lw	a4,12(s4)
    80003770:	0009079b          	sext.w	a5,s2
    80003774:	fce7e7e3          	bltu	a5,a4,80003742 <ialloc+0x30>
    80003778:	74a2                	ld	s1,40(sp)
    8000377a:	69e2                	ld	s3,24(sp)
    8000377c:	6a42                	ld	s4,16(sp)
    8000377e:	6aa2                	ld	s5,8(sp)
    80003780:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003782:	00005517          	auipc	a0,0x5
    80003786:	efe50513          	addi	a0,a0,-258 # 80008680 <etext+0x680>
    8000378a:	da3fc0ef          	jal	8000052c <printf>
  return 0;
    8000378e:	4901                	li	s2,0
}
    80003790:	854a                	mv	a0,s2
    80003792:	70e2                	ld	ra,56(sp)
    80003794:	7442                	ld	s0,48(sp)
    80003796:	7902                	ld	s2,32(sp)
    80003798:	6121                	addi	sp,sp,64
    8000379a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000379c:	04000613          	li	a2,64
    800037a0:	4581                	li	a1,0
    800037a2:	854e                	mv	a0,s3
    800037a4:	d30fd0ef          	jal	80000cd4 <memset>
      dip->type = type;
    800037a8:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800037ac:	8526                	mv	a0,s1
    800037ae:	35c010ef          	jal	80004b0a <log_write>
      struct inode *ip = iget(dev, inum);
    800037b2:	0009059b          	sext.w	a1,s2
    800037b6:	8556                	mv	a0,s5
    800037b8:	cadff0ef          	jal	80003464 <iget>
    800037bc:	892a                	mv	s2,a0
      inode_report("IALLOC", ip,
    800037be:	00005897          	auipc	a7,0x5
    800037c2:	ea288893          	addi	a7,a7,-350 # 80008660 <etext+0x660>
    800037c6:	4801                	li	a6,0
    800037c8:	4781                	li	a5,0
    800037ca:	4701                	li	a4,0
    800037cc:	4681                	li	a3,0
    800037ce:	4601                	li	a2,0
    800037d0:	85aa                	mv	a1,a0
    800037d2:	00005517          	auipc	a0,0x5
    800037d6:	ea650513          	addi	a0,a0,-346 # 80008678 <etext+0x678>
    800037da:	b8bff0ef          	jal	80003364 <inode_report>
      brelse(bp);
    800037de:	8526                	mv	a0,s1
    800037e0:	dfaff0ef          	jal	80002dda <brelse>
      return ip;
    800037e4:	74a2                	ld	s1,40(sp)
    800037e6:	69e2                	ld	s3,24(sp)
    800037e8:	6a42                	ld	s4,16(sp)
    800037ea:	6aa2                	ld	s5,8(sp)
    800037ec:	6b02                	ld	s6,0(sp)
    800037ee:	b74d                	j	80003790 <ialloc+0x7e>

00000000800037f0 <iupdate>:
{
    800037f0:	1101                	addi	sp,sp,-32
    800037f2:	ec06                	sd	ra,24(sp)
    800037f4:	e822                	sd	s0,16(sp)
    800037f6:	e426                	sd	s1,8(sp)
    800037f8:	e04a                	sd	s2,0(sp)
    800037fa:	1000                	addi	s0,sp,32
    800037fc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037fe:	415c                	lw	a5,4(a0)
    80003800:	0047d79b          	srliw	a5,a5,0x4
    80003804:	0001c597          	auipc	a1,0x1c
    80003808:	6f45a583          	lw	a1,1780(a1) # 8001fef8 <sb+0x18>
    8000380c:	9dbd                	addw	a1,a1,a5
    8000380e:	4108                	lw	a0,0(a0)
    80003810:	c34ff0ef          	jal	80002c44 <bread>
    80003814:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003816:	05850793          	addi	a5,a0,88
    8000381a:	40d8                	lw	a4,4(s1)
    8000381c:	8b3d                	andi	a4,a4,15
    8000381e:	071a                	slli	a4,a4,0x6
    80003820:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003822:	04449703          	lh	a4,68(s1)
    80003826:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000382a:	04649703          	lh	a4,70(s1)
    8000382e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003832:	04849703          	lh	a4,72(s1)
    80003836:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000383a:	04a49703          	lh	a4,74(s1)
    8000383e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003842:	44f8                	lw	a4,76(s1)
    80003844:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003846:	03400613          	li	a2,52
    8000384a:	05048593          	addi	a1,s1,80
    8000384e:	00c78513          	addi	a0,a5,12
    80003852:	cdefd0ef          	jal	80000d30 <memmove>
  inode_report("IUPDATE", ip,
    80003856:	00005897          	auipc	a7,0x5
    8000385a:	e4288893          	addi	a7,a7,-446 # 80008698 <etext+0x698>
    8000385e:	4805                	li	a6,1
    80003860:	44fc                	lw	a5,76(s1)
    80003862:	04449703          	lh	a4,68(s1)
    80003866:	40b4                	lw	a3,64(s1)
    80003868:	4490                	lw	a2,8(s1)
    8000386a:	85a6                	mv	a1,s1
    8000386c:	00005517          	auipc	a0,0x5
    80003870:	e4450513          	addi	a0,a0,-444 # 800086b0 <etext+0x6b0>
    80003874:	af1ff0ef          	jal	80003364 <inode_report>
  log_write(bp);
    80003878:	854a                	mv	a0,s2
    8000387a:	290010ef          	jal	80004b0a <log_write>
  brelse(bp);
    8000387e:	854a                	mv	a0,s2
    80003880:	d5aff0ef          	jal	80002dda <brelse>
}
    80003884:	60e2                	ld	ra,24(sp)
    80003886:	6442                	ld	s0,16(sp)
    80003888:	64a2                	ld	s1,8(sp)
    8000388a:	6902                	ld	s2,0(sp)
    8000388c:	6105                	addi	sp,sp,32
    8000388e:	8082                	ret

0000000080003890 <idup>:
{
    80003890:	1101                	addi	sp,sp,-32
    80003892:	ec06                	sd	ra,24(sp)
    80003894:	e822                	sd	s0,16(sp)
    80003896:	e426                	sd	s1,8(sp)
    80003898:	1000                	addi	s0,sp,32
    8000389a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000389c:	0001c517          	auipc	a0,0x1c
    800038a0:	66450513          	addi	a0,a0,1636 # 8001ff00 <itable>
    800038a4:	b5cfd0ef          	jal	80000c00 <acquire>
  int old_ref = ip->ref;
    800038a8:	4490                	lw	a2,8(s1)
  ip->ref++;
    800038aa:	0016079b          	addiw	a5,a2,1
    800038ae:	c49c                	sw	a5,8(s1)
  inode_report("IDUP", ip,
    800038b0:	00005897          	auipc	a7,0x5
    800038b4:	e0888893          	addi	a7,a7,-504 # 800086b8 <etext+0x6b8>
    800038b8:	4801                	li	a6,0
    800038ba:	44fc                	lw	a5,76(s1)
    800038bc:	04449703          	lh	a4,68(s1)
    800038c0:	40b4                	lw	a3,64(s1)
    800038c2:	85a6                	mv	a1,s1
    800038c4:	00005517          	auipc	a0,0x5
    800038c8:	e0c50513          	addi	a0,a0,-500 # 800086d0 <etext+0x6d0>
    800038cc:	a99ff0ef          	jal	80003364 <inode_report>
  release(&itable.lock);
    800038d0:	0001c517          	auipc	a0,0x1c
    800038d4:	63050513          	addi	a0,a0,1584 # 8001ff00 <itable>
    800038d8:	bc0fd0ef          	jal	80000c98 <release>
}
    800038dc:	8526                	mv	a0,s1
    800038de:	60e2                	ld	ra,24(sp)
    800038e0:	6442                	ld	s0,16(sp)
    800038e2:	64a2                	ld	s1,8(sp)
    800038e4:	6105                	addi	sp,sp,32
    800038e6:	8082                	ret

00000000800038e8 <ilock>:
{
    800038e8:	1101                	addi	sp,sp,-32
    800038ea:	ec06                	sd	ra,24(sp)
    800038ec:	e822                	sd	s0,16(sp)
    800038ee:	e426                	sd	s1,8(sp)
    800038f0:	e04a                	sd	s2,0(sp)
    800038f2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800038f4:	c139                	beqz	a0,8000393a <ilock+0x52>
    800038f6:	84aa                	mv	s1,a0
    800038f8:	451c                	lw	a5,8(a0)
    800038fa:	04f05063          	blez	a5,8000393a <ilock+0x52>
   int old_valid = ip->valid;
    800038fe:	04052903          	lw	s2,64(a0)
  acquiresleep(&ip->lock);
    80003902:	0541                	addi	a0,a0,16
    80003904:	324010ef          	jal	80004c28 <acquiresleep>
  inode_report("ILOCK_ACQUIRE", ip,
    80003908:	00005897          	auipc	a7,0x5
    8000390c:	dd888893          	addi	a7,a7,-552 # 800086e0 <etext+0x6e0>
    80003910:	4801                	li	a6,0
    80003912:	44fc                	lw	a5,76(s1)
    80003914:	04449703          	lh	a4,68(s1)
    80003918:	86ca                	mv	a3,s2
    8000391a:	4490                	lw	a2,8(s1)
    8000391c:	85a6                	mv	a1,s1
    8000391e:	00005517          	auipc	a0,0x5
    80003922:	dd250513          	addi	a0,a0,-558 # 800086f0 <etext+0x6f0>
    80003926:	a3fff0ef          	jal	80003364 <inode_report>
  if(ip->valid == 0){
    8000392a:	40bc                	lw	a5,64(s1)
    8000392c:	cf89                	beqz	a5,80003946 <ilock+0x5e>
}
    8000392e:	60e2                	ld	ra,24(sp)
    80003930:	6442                	ld	s0,16(sp)
    80003932:	64a2                	ld	s1,8(sp)
    80003934:	6902                	ld	s2,0(sp)
    80003936:	6105                	addi	sp,sp,32
    80003938:	8082                	ret
    panic("ilock");
    8000393a:	00005517          	auipc	a0,0x5
    8000393e:	d9e50513          	addi	a0,a0,-610 # 800086d8 <etext+0x6d8>
    80003942:	ed1fc0ef          	jal	80000812 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003946:	40dc                	lw	a5,4(s1)
    80003948:	0047d79b          	srliw	a5,a5,0x4
    8000394c:	0001c597          	auipc	a1,0x1c
    80003950:	5ac5a583          	lw	a1,1452(a1) # 8001fef8 <sb+0x18>
    80003954:	9dbd                	addw	a1,a1,a5
    80003956:	4088                	lw	a0,0(s1)
    80003958:	aecff0ef          	jal	80002c44 <bread>
    8000395c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000395e:	05850593          	addi	a1,a0,88
    80003962:	40dc                	lw	a5,4(s1)
    80003964:	8bbd                	andi	a5,a5,15
    80003966:	079a                	slli	a5,a5,0x6
    80003968:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000396a:	00059783          	lh	a5,0(a1)
    8000396e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003972:	00259783          	lh	a5,2(a1)
    80003976:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000397a:	00459783          	lh	a5,4(a1)
    8000397e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003982:	00659783          	lh	a5,6(a1)
    80003986:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000398a:	459c                	lw	a5,8(a1)
    8000398c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000398e:	03400613          	li	a2,52
    80003992:	05b1                	addi	a1,a1,12
    80003994:	05048513          	addi	a0,s1,80
    80003998:	b98fd0ef          	jal	80000d30 <memmove>
    brelse(bp);
    8000399c:	854a                	mv	a0,s2
    8000399e:	c3cff0ef          	jal	80002dda <brelse>
    ip->valid = 1;
    800039a2:	4785                	li	a5,1
    800039a4:	c0bc                	sw	a5,64(s1)
    inode_report("ILOCK_LOAD", ip,
    800039a6:	00005897          	auipc	a7,0x5
    800039aa:	d5a88893          	addi	a7,a7,-678 # 80008700 <etext+0x700>
    800039ae:	4805                	li	a6,1
    800039b0:	44fc                	lw	a5,76(s1)
    800039b2:	04449703          	lh	a4,68(s1)
    800039b6:	4681                	li	a3,0
    800039b8:	4490                	lw	a2,8(s1)
    800039ba:	85a6                	mv	a1,s1
    800039bc:	00005517          	auipc	a0,0x5
    800039c0:	d5c50513          	addi	a0,a0,-676 # 80008718 <etext+0x718>
    800039c4:	9a1ff0ef          	jal	80003364 <inode_report>
    if(ip->type == 0)
    800039c8:	04449783          	lh	a5,68(s1)
    800039cc:	f3ad                	bnez	a5,8000392e <ilock+0x46>
      panic("ilock: no type");
    800039ce:	00005517          	auipc	a0,0x5
    800039d2:	d5a50513          	addi	a0,a0,-678 # 80008728 <etext+0x728>
    800039d6:	e3dfc0ef          	jal	80000812 <panic>

00000000800039da <iunlock>:
{
    800039da:	1101                	addi	sp,sp,-32
    800039dc:	ec06                	sd	ra,24(sp)
    800039de:	e822                	sd	s0,16(sp)
    800039e0:	e426                	sd	s1,8(sp)
    800039e2:	e04a                	sd	s2,0(sp)
    800039e4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039e6:	c529                	beqz	a0,80003a30 <iunlock+0x56>
    800039e8:	84aa                	mv	s1,a0
    800039ea:	01050913          	addi	s2,a0,16
    800039ee:	854a                	mv	a0,s2
    800039f0:	2b6010ef          	jal	80004ca6 <holdingsleep>
    800039f4:	cd15                	beqz	a0,80003a30 <iunlock+0x56>
    800039f6:	449c                	lw	a5,8(s1)
    800039f8:	02f05c63          	blez	a5,80003a30 <iunlock+0x56>
  releasesleep(&ip->lock);
    800039fc:	854a                	mv	a0,s2
    800039fe:	270010ef          	jal	80004c6e <releasesleep>
  inode_report("IUNLOCK", ip,
    80003a02:	00005897          	auipc	a7,0x5
    80003a06:	d3e88893          	addi	a7,a7,-706 # 80008740 <etext+0x740>
    80003a0a:	4805                	li	a6,1
    80003a0c:	44fc                	lw	a5,76(s1)
    80003a0e:	04449703          	lh	a4,68(s1)
    80003a12:	40b4                	lw	a3,64(s1)
    80003a14:	4490                	lw	a2,8(s1)
    80003a16:	85a6                	mv	a1,s1
    80003a18:	00005517          	auipc	a0,0x5
    80003a1c:	d3850513          	addi	a0,a0,-712 # 80008750 <etext+0x750>
    80003a20:	945ff0ef          	jal	80003364 <inode_report>
}
    80003a24:	60e2                	ld	ra,24(sp)
    80003a26:	6442                	ld	s0,16(sp)
    80003a28:	64a2                	ld	s1,8(sp)
    80003a2a:	6902                	ld	s2,0(sp)
    80003a2c:	6105                	addi	sp,sp,32
    80003a2e:	8082                	ret
    panic("iunlock");
    80003a30:	00005517          	auipc	a0,0x5
    80003a34:	d0850513          	addi	a0,a0,-760 # 80008738 <etext+0x738>
    80003a38:	ddbfc0ef          	jal	80000812 <panic>

0000000080003a3c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a3c:	7179                	addi	sp,sp,-48
    80003a3e:	f406                	sd	ra,40(sp)
    80003a40:	f022                	sd	s0,32(sp)
    80003a42:	ec26                	sd	s1,24(sp)
    80003a44:	e84a                	sd	s2,16(sp)
    80003a46:	e44e                	sd	s3,8(sp)
    80003a48:	1800                	addi	s0,sp,48
    80003a4a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a4c:	05050493          	addi	s1,a0,80
    80003a50:	08050913          	addi	s2,a0,128
    80003a54:	a021                	j	80003a5c <itrunc+0x20>
    80003a56:	0491                	addi	s1,s1,4
    80003a58:	01248b63          	beq	s1,s2,80003a6e <itrunc+0x32>
    if(ip->addrs[i]){
    80003a5c:	408c                	lw	a1,0(s1)
    80003a5e:	dde5                	beqz	a1,80003a56 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003a60:	0009a503          	lw	a0,0(s3)
    80003a64:	f3cff0ef          	jal	800031a0 <bfree>
      ip->addrs[i] = 0;
    80003a68:	0004a023          	sw	zero,0(s1)
    80003a6c:	b7ed                	j	80003a56 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a6e:	0809a583          	lw	a1,128(s3)
    80003a72:	e1a9                	bnez	a1,80003ab4 <itrunc+0x78>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  int old_size = ip->size;
    80003a74:	04c9a783          	lw	a5,76(s3)

  ip->size = 0;
    80003a78:	0409a623          	sw	zero,76(s3)

  inode_report("ITRUNC", ip,
    80003a7c:	00005897          	auipc	a7,0x5
    80003a80:	cdc88893          	addi	a7,a7,-804 # 80008758 <etext+0x758>
    80003a84:	4805                	li	a6,1
    80003a86:	04499703          	lh	a4,68(s3)
    80003a8a:	0409a683          	lw	a3,64(s3)
    80003a8e:	0089a603          	lw	a2,8(s3)
    80003a92:	85ce                	mv	a1,s3
    80003a94:	00005517          	auipc	a0,0x5
    80003a98:	cdc50513          	addi	a0,a0,-804 # 80008770 <etext+0x770>
    80003a9c:	8c9ff0ef          	jal	80003364 <inode_report>
    ip->ref, ip->valid,
    ip->type, old_size,
    1,
    "Truncating inode data");
  iupdate(ip);
    80003aa0:	854e                	mv	a0,s3
    80003aa2:	d4fff0ef          	jal	800037f0 <iupdate>
}
    80003aa6:	70a2                	ld	ra,40(sp)
    80003aa8:	7402                	ld	s0,32(sp)
    80003aaa:	64e2                	ld	s1,24(sp)
    80003aac:	6942                	ld	s2,16(sp)
    80003aae:	69a2                	ld	s3,8(sp)
    80003ab0:	6145                	addi	sp,sp,48
    80003ab2:	8082                	ret
    80003ab4:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003ab6:	0009a503          	lw	a0,0(s3)
    80003aba:	98aff0ef          	jal	80002c44 <bread>
    80003abe:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003ac0:	05850493          	addi	s1,a0,88
    80003ac4:	45850913          	addi	s2,a0,1112
    80003ac8:	a021                	j	80003ad0 <itrunc+0x94>
    80003aca:	0491                	addi	s1,s1,4
    80003acc:	01248963          	beq	s1,s2,80003ade <itrunc+0xa2>
      if(a[j])
    80003ad0:	408c                	lw	a1,0(s1)
    80003ad2:	dde5                	beqz	a1,80003aca <itrunc+0x8e>
        bfree(ip->dev, a[j]);
    80003ad4:	0009a503          	lw	a0,0(s3)
    80003ad8:	ec8ff0ef          	jal	800031a0 <bfree>
    80003adc:	b7fd                	j	80003aca <itrunc+0x8e>
    brelse(bp);
    80003ade:	8552                	mv	a0,s4
    80003ae0:	afaff0ef          	jal	80002dda <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ae4:	0809a583          	lw	a1,128(s3)
    80003ae8:	0009a503          	lw	a0,0(s3)
    80003aec:	eb4ff0ef          	jal	800031a0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003af0:	0809a023          	sw	zero,128(s3)
    80003af4:	6a02                	ld	s4,0(sp)
    80003af6:	bfbd                	j	80003a74 <itrunc+0x38>

0000000080003af8 <iput>:
{
    80003af8:	1101                	addi	sp,sp,-32
    80003afa:	ec06                	sd	ra,24(sp)
    80003afc:	e822                	sd	s0,16(sp)
    80003afe:	e426                	sd	s1,8(sp)
    80003b00:	1000                	addi	s0,sp,32
    80003b02:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b04:	0001c517          	auipc	a0,0x1c
    80003b08:	3fc50513          	addi	a0,a0,1020 # 8001ff00 <itable>
    80003b0c:	8f4fd0ef          	jal	80000c00 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b10:	4498                	lw	a4,8(s1)
    80003b12:	4785                	li	a5,1
    80003b14:	04f70163          	beq	a4,a5,80003b56 <iput+0x5e>
  int old_ref = ip->ref;
    80003b18:	4490                	lw	a2,8(s1)
  ip->ref--;
    80003b1a:	fff6079b          	addiw	a5,a2,-1
    80003b1e:	c49c                	sw	a5,8(s1)
  inode_report("IPUT", ip,
    80003b20:	00005897          	auipc	a7,0x5
    80003b24:	c8088893          	addi	a7,a7,-896 # 800087a0 <etext+0x7a0>
    80003b28:	4801                	li	a6,0
    80003b2a:	44fc                	lw	a5,76(s1)
    80003b2c:	04449703          	lh	a4,68(s1)
    80003b30:	40b4                	lw	a3,64(s1)
    80003b32:	85a6                	mv	a1,s1
    80003b34:	00005517          	auipc	a0,0x5
    80003b38:	c7c50513          	addi	a0,a0,-900 # 800087b0 <etext+0x7b0>
    80003b3c:	829ff0ef          	jal	80003364 <inode_report>
  release(&itable.lock);
    80003b40:	0001c517          	auipc	a0,0x1c
    80003b44:	3c050513          	addi	a0,a0,960 # 8001ff00 <itable>
    80003b48:	950fd0ef          	jal	80000c98 <release>
}
    80003b4c:	60e2                	ld	ra,24(sp)
    80003b4e:	6442                	ld	s0,16(sp)
    80003b50:	64a2                	ld	s1,8(sp)
    80003b52:	6105                	addi	sp,sp,32
    80003b54:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b56:	40bc                	lw	a5,64(s1)
    80003b58:	d3e1                	beqz	a5,80003b18 <iput+0x20>
    80003b5a:	04a49783          	lh	a5,74(s1)
    80003b5e:	ffcd                	bnez	a5,80003b18 <iput+0x20>
    80003b60:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003b62:	01048913          	addi	s2,s1,16
    80003b66:	854a                	mv	a0,s2
    80003b68:	0c0010ef          	jal	80004c28 <acquiresleep>
    release(&itable.lock);
    80003b6c:	0001c517          	auipc	a0,0x1c
    80003b70:	39450513          	addi	a0,a0,916 # 8001ff00 <itable>
    80003b74:	924fd0ef          	jal	80000c98 <release>
    itrunc(ip);
    80003b78:	8526                	mv	a0,s1
    80003b7a:	ec3ff0ef          	jal	80003a3c <itrunc>
    ip->type = 0;
    80003b7e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b82:	8526                	mv	a0,s1
    80003b84:	c6dff0ef          	jal	800037f0 <iupdate>
    ip->valid = 0;
    80003b88:	0404a023          	sw	zero,64(s1)
    inode_report("IPUT_FREE", ip,
    80003b8c:	00005897          	auipc	a7,0x5
    80003b90:	bec88893          	addi	a7,a7,-1044 # 80008778 <etext+0x778>
    80003b94:	4805                	li	a6,1
    80003b96:	44fc                	lw	a5,76(s1)
    80003b98:	04449703          	lh	a4,68(s1)
    80003b9c:	4681                	li	a3,0
    80003b9e:	4490                	lw	a2,8(s1)
    80003ba0:	85a6                	mv	a1,s1
    80003ba2:	00005517          	auipc	a0,0x5
    80003ba6:	bee50513          	addi	a0,a0,-1042 # 80008790 <etext+0x790>
    80003baa:	fbaff0ef          	jal	80003364 <inode_report>
    releasesleep(&ip->lock);
    80003bae:	854a                	mv	a0,s2
    80003bb0:	0be010ef          	jal	80004c6e <releasesleep>
    acquire(&itable.lock);
    80003bb4:	0001c517          	auipc	a0,0x1c
    80003bb8:	34c50513          	addi	a0,a0,844 # 8001ff00 <itable>
    80003bbc:	844fd0ef          	jal	80000c00 <acquire>
    80003bc0:	6902                	ld	s2,0(sp)
    80003bc2:	bf99                	j	80003b18 <iput+0x20>

0000000080003bc4 <iunlockput>:
{
    80003bc4:	1101                	addi	sp,sp,-32
    80003bc6:	ec06                	sd	ra,24(sp)
    80003bc8:	e822                	sd	s0,16(sp)
    80003bca:	e426                	sd	s1,8(sp)
    80003bcc:	1000                	addi	s0,sp,32
    80003bce:	84aa                	mv	s1,a0
  iunlock(ip);
    80003bd0:	e0bff0ef          	jal	800039da <iunlock>
  iput(ip);
    80003bd4:	8526                	mv	a0,s1
    80003bd6:	f23ff0ef          	jal	80003af8 <iput>
}
    80003bda:	60e2                	ld	ra,24(sp)
    80003bdc:	6442                	ld	s0,16(sp)
    80003bde:	64a2                	ld	s1,8(sp)
    80003be0:	6105                	addi	sp,sp,32
    80003be2:	8082                	ret

0000000080003be4 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003be4:	0001c717          	auipc	a4,0x1c
    80003be8:	30872703          	lw	a4,776(a4) # 8001feec <sb+0xc>
    80003bec:	4785                	li	a5,1
    80003bee:	0ae7ff63          	bgeu	a5,a4,80003cac <ireclaim+0xc8>
{
    80003bf2:	7139                	addi	sp,sp,-64
    80003bf4:	fc06                	sd	ra,56(sp)
    80003bf6:	f822                	sd	s0,48(sp)
    80003bf8:	f426                	sd	s1,40(sp)
    80003bfa:	f04a                	sd	s2,32(sp)
    80003bfc:	ec4e                	sd	s3,24(sp)
    80003bfe:	e852                	sd	s4,16(sp)
    80003c00:	e456                	sd	s5,8(sp)
    80003c02:	e05a                	sd	s6,0(sp)
    80003c04:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003c06:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003c08:	00050a1b          	sext.w	s4,a0
    80003c0c:	0001ca97          	auipc	s5,0x1c
    80003c10:	2d4a8a93          	addi	s5,s5,724 # 8001fee0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003c14:	00005b17          	auipc	s6,0x5
    80003c18:	ba4b0b13          	addi	s6,s6,-1116 # 800087b8 <etext+0x7b8>
    80003c1c:	a099                	j	80003c62 <ireclaim+0x7e>
    80003c1e:	85ce                	mv	a1,s3
    80003c20:	855a                	mv	a0,s6
    80003c22:	90bfc0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    80003c26:	85ce                	mv	a1,s3
    80003c28:	8552                	mv	a0,s4
    80003c2a:	83bff0ef          	jal	80003464 <iget>
    80003c2e:	89aa                	mv	s3,a0
    brelse(bp);
    80003c30:	854a                	mv	a0,s2
    80003c32:	9a8ff0ef          	jal	80002dda <brelse>
    if (ip) {
    80003c36:	00098f63          	beqz	s3,80003c54 <ireclaim+0x70>
      begin_op();
    80003c3a:	35d000ef          	jal	80004796 <begin_op>
      ilock(ip);
    80003c3e:	854e                	mv	a0,s3
    80003c40:	ca9ff0ef          	jal	800038e8 <ilock>
      iunlock(ip);
    80003c44:	854e                	mv	a0,s3
    80003c46:	d95ff0ef          	jal	800039da <iunlock>
      iput(ip);
    80003c4a:	854e                	mv	a0,s3
    80003c4c:	eadff0ef          	jal	80003af8 <iput>
      end_op();
    80003c50:	465000ef          	jal	800048b4 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003c54:	0485                	addi	s1,s1,1
    80003c56:	00caa703          	lw	a4,12(s5)
    80003c5a:	0004879b          	sext.w	a5,s1
    80003c5e:	02e7fd63          	bgeu	a5,a4,80003c98 <ireclaim+0xb4>
    80003c62:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003c66:	0044d593          	srli	a1,s1,0x4
    80003c6a:	018aa783          	lw	a5,24(s5)
    80003c6e:	9dbd                	addw	a1,a1,a5
    80003c70:	8552                	mv	a0,s4
    80003c72:	fd3fe0ef          	jal	80002c44 <bread>
    80003c76:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003c78:	05850793          	addi	a5,a0,88
    80003c7c:	00f9f713          	andi	a4,s3,15
    80003c80:	071a                	slli	a4,a4,0x6
    80003c82:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003c84:	00079703          	lh	a4,0(a5)
    80003c88:	c701                	beqz	a4,80003c90 <ireclaim+0xac>
    80003c8a:	00679783          	lh	a5,6(a5)
    80003c8e:	dbc1                	beqz	a5,80003c1e <ireclaim+0x3a>
    brelse(bp);
    80003c90:	854a                	mv	a0,s2
    80003c92:	948ff0ef          	jal	80002dda <brelse>
    if (ip) {
    80003c96:	bf7d                	j	80003c54 <ireclaim+0x70>
}
    80003c98:	70e2                	ld	ra,56(sp)
    80003c9a:	7442                	ld	s0,48(sp)
    80003c9c:	74a2                	ld	s1,40(sp)
    80003c9e:	7902                	ld	s2,32(sp)
    80003ca0:	69e2                	ld	s3,24(sp)
    80003ca2:	6a42                	ld	s4,16(sp)
    80003ca4:	6aa2                	ld	s5,8(sp)
    80003ca6:	6b02                	ld	s6,0(sp)
    80003ca8:	6121                	addi	sp,sp,64
    80003caa:	8082                	ret
    80003cac:	8082                	ret

0000000080003cae <fsinit>:
fsinit(int dev) {
    80003cae:	7179                	addi	sp,sp,-48
    80003cb0:	f406                	sd	ra,40(sp)
    80003cb2:	f022                	sd	s0,32(sp)
    80003cb4:	ec26                	sd	s1,24(sp)
    80003cb6:	e84a                	sd	s2,16(sp)
    80003cb8:	e44e                	sd	s3,8(sp)
    80003cba:	1800                	addi	s0,sp,48
    80003cbc:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003cbe:	4585                	li	a1,1
    80003cc0:	f85fe0ef          	jal	80002c44 <bread>
    80003cc4:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003cc6:	0001c997          	auipc	s3,0x1c
    80003cca:	21a98993          	addi	s3,s3,538 # 8001fee0 <sb>
    80003cce:	02000613          	li	a2,32
    80003cd2:	05850593          	addi	a1,a0,88
    80003cd6:	854e                	mv	a0,s3
    80003cd8:	858fd0ef          	jal	80000d30 <memmove>
  brelse(bp);
    80003cdc:	854a                	mv	a0,s2
    80003cde:	8fcff0ef          	jal	80002dda <brelse>
  if(sb.magic != FSMAGIC)
    80003ce2:	0009a703          	lw	a4,0(s3)
    80003ce6:	102037b7          	lui	a5,0x10203
    80003cea:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003cee:	02f71363          	bne	a4,a5,80003d14 <fsinit+0x66>
  initlog(dev, &sb);
    80003cf2:	0001c597          	auipc	a1,0x1c
    80003cf6:	1ee58593          	addi	a1,a1,494 # 8001fee0 <sb>
    80003cfa:	8526                	mv	a0,s1
    80003cfc:	145000ef          	jal	80004640 <initlog>
  ireclaim(dev);
    80003d00:	8526                	mv	a0,s1
    80003d02:	ee3ff0ef          	jal	80003be4 <ireclaim>
}
    80003d06:	70a2                	ld	ra,40(sp)
    80003d08:	7402                	ld	s0,32(sp)
    80003d0a:	64e2                	ld	s1,24(sp)
    80003d0c:	6942                	ld	s2,16(sp)
    80003d0e:	69a2                	ld	s3,8(sp)
    80003d10:	6145                	addi	sp,sp,48
    80003d12:	8082                	ret
    panic("invalid file system");
    80003d14:	00005517          	auipc	a0,0x5
    80003d18:	ac450513          	addi	a0,a0,-1340 # 800087d8 <etext+0x7d8>
    80003d1c:	af7fc0ef          	jal	80000812 <panic>

0000000080003d20 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d20:	1141                	addi	sp,sp,-16
    80003d22:	e422                	sd	s0,8(sp)
    80003d24:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d26:	411c                	lw	a5,0(a0)
    80003d28:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d2a:	415c                	lw	a5,4(a0)
    80003d2c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d2e:	04451783          	lh	a5,68(a0)
    80003d32:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d36:	04a51783          	lh	a5,74(a0)
    80003d3a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d3e:	04c56783          	lwu	a5,76(a0)
    80003d42:	e99c                	sd	a5,16(a1)
}
    80003d44:	6422                	ld	s0,8(sp)
    80003d46:	0141                	addi	sp,sp,16
    80003d48:	8082                	ret

0000000080003d4a <readi>:
// Caller must hold ip->lock.
// If user_dst==1, then dst is a user virtual address;
// otherwise, dst is a kernel address.
int
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
    80003d4a:	7119                	addi	sp,sp,-128
    80003d4c:	fc86                	sd	ra,120(sp)
    80003d4e:	f8a2                	sd	s0,112(sp)
    80003d50:	0100                	addi	s0,sp,128
    80003d52:	f8b43423          	sd	a1,-120(s0)
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d56:	457c                	lw	a5,76(a0)
    80003d58:	10d7ea63          	bltu	a5,a3,80003e6c <readi+0x122>
    80003d5c:	f4a6                	sd	s1,104(sp)
    80003d5e:	f0ca                	sd	s2,96(sp)
    80003d60:	e0da                	sd	s6,64(sp)
    80003d62:	fc5e                	sd	s7,56(sp)
    80003d64:	84aa                	mv	s1,a0
    80003d66:	8b32                	mv	s6,a2
    80003d68:	8936                	mv	s2,a3
    80003d6a:	8bba                	mv	s7,a4
    80003d6c:	9f35                	addw	a4,a4,a3
    return 0;
    80003d6e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003d70:	10d76063          	bltu	a4,a3,80003e70 <readi+0x126>
    80003d74:	e8d2                	sd	s4,80(sp)
  if(off + n > ip->size)
    80003d76:	00e7f463          	bgeu	a5,a4,80003d7e <readi+0x34>
    n = ip->size - off;
    80003d7a:	40d78bbb          	subw	s7,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d7e:	0c0b8463          	beqz	s7,80003e46 <readi+0xfc>
    80003d82:	ecce                	sd	s3,88(sp)
    80003d84:	e4d6                	sd	s5,72(sp)
    80003d86:	f862                	sd	s8,48(sp)
    80003d88:	f466                	sd	s9,40(sp)
    80003d8a:	f06a                	sd	s10,32(sp)
    80003d8c:	ec6e                	sd	s11,24(sp)
    80003d8e:	4a01                	li	s4,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d90:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003d94:	5cfd                	li	s9,-1
      brelse(bp);
      tot = -1;
      break;
    }
    inode_report("READI", ip,
    80003d96:	00005d97          	auipc	s11,0x5
    80003d9a:	a5ad8d93          	addi	s11,s11,-1446 # 800087f0 <etext+0x7f0>
    80003d9e:	a881                	j	80003dee <readi+0xa4>
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003da0:	020a9c13          	slli	s8,s5,0x20
    80003da4:	020c5c13          	srli	s8,s8,0x20
    80003da8:	05898613          	addi	a2,s3,88
    80003dac:	86e2                	mv	a3,s8
    80003dae:	963a                	add	a2,a2,a4
    80003db0:	85da                	mv	a1,s6
    80003db2:	f8843503          	ld	a0,-120(s0)
    80003db6:	cbefe0ef          	jal	80002274 <either_copyout>
    80003dba:	07950463          	beq	a0,s9,80003e22 <readi+0xd8>
    inode_report("READI", ip,
    80003dbe:	88ee                	mv	a7,s11
    80003dc0:	4805                	li	a6,1
    80003dc2:	44fc                	lw	a5,76(s1)
    80003dc4:	04449703          	lh	a4,68(s1)
    80003dc8:	40b4                	lw	a3,64(s1)
    80003dca:	4490                	lw	a2,8(s1)
    80003dcc:	85a6                	mv	a1,s1
    80003dce:	00005517          	auipc	a0,0x5
    80003dd2:	a3a50513          	addi	a0,a0,-1478 # 80008808 <etext+0x808>
    80003dd6:	d8eff0ef          	jal	80003364 <inode_report>
      ip->ref, ip->valid,
      ip->type, ip->size,
      1,
      "Reading from inode");
    brelse(bp);
    80003dda:	854e                	mv	a0,s3
    80003ddc:	ffffe0ef          	jal	80002dda <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003de0:	014a8a3b          	addw	s4,s5,s4
    80003de4:	012a893b          	addw	s2,s5,s2
    80003de8:	9b62                	add	s6,s6,s8
    80003dea:	057a7763          	bgeu	s4,s7,80003e38 <readi+0xee>
    uint addr = bmap(ip, off/BSIZE);
    80003dee:	00a9559b          	srliw	a1,s2,0xa
    80003df2:	8526                	mv	a0,s1
    80003df4:	f7aff0ef          	jal	8000356e <bmap>
    80003df8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003dfc:	c5b9                	beqz	a1,80003e4a <readi+0x100>
    bp = bread(ip->dev, addr);
    80003dfe:	4088                	lw	a0,0(s1)
    80003e00:	e45fe0ef          	jal	80002c44 <bread>
    80003e04:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e06:	3ff97713          	andi	a4,s2,1023
    80003e0a:	40ed07bb          	subw	a5,s10,a4
    80003e0e:	414b86bb          	subw	a3,s7,s4
    80003e12:	8abe                	mv	s5,a5
    80003e14:	2781                	sext.w	a5,a5
    80003e16:	0006861b          	sext.w	a2,a3
    80003e1a:	f8f673e3          	bgeu	a2,a5,80003da0 <readi+0x56>
    80003e1e:	8ab6                	mv	s5,a3
    80003e20:	b741                	j	80003da0 <readi+0x56>
      brelse(bp);
    80003e22:	854e                	mv	a0,s3
    80003e24:	fb7fe0ef          	jal	80002dda <brelse>
      tot = -1;
    80003e28:	5a7d                	li	s4,-1
      break;
    80003e2a:	69e6                	ld	s3,88(sp)
    80003e2c:	6aa6                	ld	s5,72(sp)
    80003e2e:	7c42                	ld	s8,48(sp)
    80003e30:	7ca2                	ld	s9,40(sp)
    80003e32:	7d02                	ld	s10,32(sp)
    80003e34:	6de2                	ld	s11,24(sp)
    80003e36:	a005                	j	80003e56 <readi+0x10c>
    80003e38:	69e6                	ld	s3,88(sp)
    80003e3a:	6aa6                	ld	s5,72(sp)
    80003e3c:	7c42                	ld	s8,48(sp)
    80003e3e:	7ca2                	ld	s9,40(sp)
    80003e40:	7d02                	ld	s10,32(sp)
    80003e42:	6de2                	ld	s11,24(sp)
    80003e44:	a809                	j	80003e56 <readi+0x10c>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e46:	8a5e                	mv	s4,s7
    80003e48:	a039                	j	80003e56 <readi+0x10c>
    80003e4a:	69e6                	ld	s3,88(sp)
    80003e4c:	6aa6                	ld	s5,72(sp)
    80003e4e:	7c42                	ld	s8,48(sp)
    80003e50:	7ca2                	ld	s9,40(sp)
    80003e52:	7d02                	ld	s10,32(sp)
    80003e54:	6de2                	ld	s11,24(sp)
  }
  return tot;
    80003e56:	000a051b          	sext.w	a0,s4
    80003e5a:	74a6                	ld	s1,104(sp)
    80003e5c:	7906                	ld	s2,96(sp)
    80003e5e:	6a46                	ld	s4,80(sp)
    80003e60:	6b06                	ld	s6,64(sp)
    80003e62:	7be2                	ld	s7,56(sp)
}
    80003e64:	70e6                	ld	ra,120(sp)
    80003e66:	7446                	ld	s0,112(sp)
    80003e68:	6109                	addi	sp,sp,128
    80003e6a:	8082                	ret
    return 0;
    80003e6c:	4501                	li	a0,0
    80003e6e:	bfdd                	j	80003e64 <readi+0x11a>
    80003e70:	74a6                	ld	s1,104(sp)
    80003e72:	7906                	ld	s2,96(sp)
    80003e74:	6b06                	ld	s6,64(sp)
    80003e76:	7be2                	ld	s7,56(sp)
    80003e78:	b7f5                	j	80003e64 <readi+0x11a>

0000000080003e7a <writei>:
// Returns the number of bytes successfully written.
// If the return value is less than the requested n,
// there was an error of some kind.
int
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
    80003e7a:	7119                	addi	sp,sp,-128
    80003e7c:	fc86                	sd	ra,120(sp)
    80003e7e:	f8a2                	sd	s0,112(sp)
    80003e80:	f862                	sd	s8,48(sp)
    80003e82:	0100                	addi	s0,sp,128
    80003e84:	8c3a                	mv	s8,a4
  uint tot, m;
  struct buf *bp;
  int old_size = ip->size;
    80003e86:	457c                	lw	a5,76(a0)
    80003e88:	0007871b          	sext.w	a4,a5
    80003e8c:	f8e43423          	sd	a4,-120(s0)
  if(off > ip->size || off + n < off)
    80003e90:	10d7ee63          	bltu	a5,a3,80003fac <writei+0x132>
    80003e94:	f0ca                	sd	s2,96(sp)
    80003e96:	e4d6                	sd	s5,72(sp)
    80003e98:	e0da                	sd	s6,64(sp)
    80003e9a:	f466                	sd	s9,40(sp)
    80003e9c:	8b2a                	mv	s6,a0
    80003e9e:	8cae                	mv	s9,a1
    80003ea0:	8ab2                	mv	s5,a2
    80003ea2:	8936                	mv	s2,a3
    80003ea4:	018687bb          	addw	a5,a3,s8
    80003ea8:	10d7e463          	bltu	a5,a3,80003fb0 <writei+0x136>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003eac:	00043737          	lui	a4,0x43
    80003eb0:	10f76663          	bltu	a4,a5,80003fbc <writei+0x142>
    80003eb4:	e8d2                	sd	s4,80(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003eb6:	0e0c0363          	beqz	s8,80003f9c <writei+0x122>
    80003eba:	f4a6                	sd	s1,104(sp)
    80003ebc:	ecce                	sd	s3,88(sp)
    80003ebe:	fc5e                	sd	s7,56(sp)
    80003ec0:	f06a                	sd	s10,32(sp)
    80003ec2:	ec6e                	sd	s11,24(sp)
    80003ec4:	4a01                	li	s4,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ec6:	40000d93          	li	s11,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003eca:	5d7d                	li	s10,-1
    80003ecc:	a825                	j	80003f04 <writei+0x8a>
    80003ece:	02099b93          	slli	s7,s3,0x20
    80003ed2:	020bdb93          	srli	s7,s7,0x20
    80003ed6:	05848513          	addi	a0,s1,88
    80003eda:	86de                	mv	a3,s7
    80003edc:	8656                	mv	a2,s5
    80003ede:	85e6                	mv	a1,s9
    80003ee0:	953a                	add	a0,a0,a4
    80003ee2:	bdcfe0ef          	jal	800022be <either_copyin>
    80003ee6:	05a50a63          	beq	a0,s10,80003f3a <writei+0xc0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003eea:	8526                	mv	a0,s1
    80003eec:	41f000ef          	jal	80004b0a <log_write>
    brelse(bp);
    80003ef0:	8526                	mv	a0,s1
    80003ef2:	ee9fe0ef          	jal	80002dda <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ef6:	01498a3b          	addw	s4,s3,s4
    80003efa:	0129893b          	addw	s2,s3,s2
    80003efe:	9ade                	add	s5,s5,s7
    80003f00:	058a7063          	bgeu	s4,s8,80003f40 <writei+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003f04:	00a9559b          	srliw	a1,s2,0xa
    80003f08:	855a                	mv	a0,s6
    80003f0a:	e64ff0ef          	jal	8000356e <bmap>
    80003f0e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f12:	c59d                	beqz	a1,80003f40 <writei+0xc6>
    bp = bread(ip->dev, addr);
    80003f14:	000b2503          	lw	a0,0(s6)
    80003f18:	d2dfe0ef          	jal	80002c44 <bread>
    80003f1c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f1e:	3ff97713          	andi	a4,s2,1023
    80003f22:	40ed87bb          	subw	a5,s11,a4
    80003f26:	414c06bb          	subw	a3,s8,s4
    80003f2a:	89be                	mv	s3,a5
    80003f2c:	2781                	sext.w	a5,a5
    80003f2e:	0006861b          	sext.w	a2,a3
    80003f32:	f8f67ee3          	bgeu	a2,a5,80003ece <writei+0x54>
    80003f36:	89b6                	mv	s3,a3
    80003f38:	bf59                	j	80003ece <writei+0x54>
      brelse(bp);
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	e9ffe0ef          	jal	80002dda <brelse>
  }

  if(off > ip->size)
    80003f40:	04cb2783          	lw	a5,76(s6)
    80003f44:	0527fe63          	bgeu	a5,s2,80003fa0 <writei+0x126>
    ip->size = off;
    80003f48:	052b2623          	sw	s2,76(s6)
    80003f4c:	74a6                	ld	s1,104(sp)
    80003f4e:	69e6                	ld	s3,88(sp)
    80003f50:	7be2                	ld	s7,56(sp)
    80003f52:	7d02                	ld	s10,32(sp)
    80003f54:	6de2                	ld	s11,24(sp)
  inode_report("WRITEI", ip,
    80003f56:	00005897          	auipc	a7,0x5
    80003f5a:	8ba88893          	addi	a7,a7,-1862 # 80008810 <etext+0x810>
    80003f5e:	4805                	li	a6,1
    80003f60:	f8843783          	ld	a5,-120(s0)
    80003f64:	044b1703          	lh	a4,68(s6)
    80003f68:	040b2683          	lw	a3,64(s6)
    80003f6c:	008b2603          	lw	a2,8(s6)
    80003f70:	85da                	mv	a1,s6
    80003f72:	00005517          	auipc	a0,0x5
    80003f76:	8b650513          	addi	a0,a0,-1866 # 80008828 <etext+0x828>
    80003f7a:	beaff0ef          	jal	80003364 <inode_report>
    "Writing to inode");

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f7e:	855a                	mv	a0,s6
    80003f80:	871ff0ef          	jal	800037f0 <iupdate>

  return tot;
    80003f84:	000a051b          	sext.w	a0,s4
    80003f88:	7906                	ld	s2,96(sp)
    80003f8a:	6a46                	ld	s4,80(sp)
    80003f8c:	6aa6                	ld	s5,72(sp)
    80003f8e:	6b06                	ld	s6,64(sp)
    80003f90:	7ca2                	ld	s9,40(sp)
}
    80003f92:	70e6                	ld	ra,120(sp)
    80003f94:	7446                	ld	s0,112(sp)
    80003f96:	7c42                	ld	s8,48(sp)
    80003f98:	6109                	addi	sp,sp,128
    80003f9a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f9c:	8a62                	mv	s4,s8
    80003f9e:	bf65                	j	80003f56 <writei+0xdc>
    80003fa0:	74a6                	ld	s1,104(sp)
    80003fa2:	69e6                	ld	s3,88(sp)
    80003fa4:	7be2                	ld	s7,56(sp)
    80003fa6:	7d02                	ld	s10,32(sp)
    80003fa8:	6de2                	ld	s11,24(sp)
    80003faa:	b775                	j	80003f56 <writei+0xdc>
    return -1;
    80003fac:	557d                	li	a0,-1
    80003fae:	b7d5                	j	80003f92 <writei+0x118>
    80003fb0:	557d                	li	a0,-1
    80003fb2:	7906                	ld	s2,96(sp)
    80003fb4:	6aa6                	ld	s5,72(sp)
    80003fb6:	6b06                	ld	s6,64(sp)
    80003fb8:	7ca2                	ld	s9,40(sp)
    80003fba:	bfe1                	j	80003f92 <writei+0x118>
    return -1;
    80003fbc:	557d                	li	a0,-1
    80003fbe:	7906                	ld	s2,96(sp)
    80003fc0:	6aa6                	ld	s5,72(sp)
    80003fc2:	6b06                	ld	s6,64(sp)
    80003fc4:	7ca2                	ld	s9,40(sp)
    80003fc6:	b7f1                	j	80003f92 <writei+0x118>

0000000080003fc8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003fc8:	1141                	addi	sp,sp,-16
    80003fca:	e406                	sd	ra,8(sp)
    80003fcc:	e022                	sd	s0,0(sp)
    80003fce:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003fd0:	4639                	li	a2,14
    80003fd2:	dcffc0ef          	jal	80000da0 <strncmp>
}
    80003fd6:	60a2                	ld	ra,8(sp)
    80003fd8:	6402                	ld	s0,0(sp)
    80003fda:	0141                	addi	sp,sp,16
    80003fdc:	8082                	ret

0000000080003fde <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003fde:	7139                	addi	sp,sp,-64
    80003fe0:	fc06                	sd	ra,56(sp)
    80003fe2:	f822                	sd	s0,48(sp)
    80003fe4:	f426                	sd	s1,40(sp)
    80003fe6:	f04a                	sd	s2,32(sp)
    80003fe8:	ec4e                	sd	s3,24(sp)
    80003fea:	e852                	sd	s4,16(sp)
    80003fec:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR){
    80003fee:	04451703          	lh	a4,68(a0)
    80003ff2:	4785                	li	a5,1
    80003ff4:	02f71f63          	bne	a4,a5,80004032 <dirlookup+0x54>
    80003ff8:	892a                	mv	s2,a0
    80003ffa:	89ae                	mv	s3,a1
    80003ffc:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");
  }
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ffe:	457c                	lw	a5,76(a0)
    80004000:	4481                	li	s1,0
    80004002:	eba9                	bnez	a5,80004054 <dirlookup+0x76>
        "Directory entry found"
      );
      return iget(dp->dev, inum);
    }
  }
  dir_report(
    80004004:	00005797          	auipc	a5,0x5
    80004008:	87c78793          	addi	a5,a5,-1924 # 80008880 <etext+0x880>
    8000400c:	577d                	li	a4,-1
    8000400e:	56fd                	li	a3,-1
    80004010:	864e                	mv	a2,s3
    80004012:	85ca                	mv	a1,s2
    80004014:	00005517          	auipc	a0,0x5
    80004018:	88c50513          	addi	a0,a0,-1908 # 800088a0 <etext+0x8a0>
    8000401c:	efbfe0ef          	jal	80002f16 <dir_report>
    name,
    -1,
    -1,
    "Directory entry not found"
  );
  return 0;
    80004020:	4501                	li	a0,0
}
    80004022:	70e2                	ld	ra,56(sp)
    80004024:	7442                	ld	s0,48(sp)
    80004026:	74a2                	ld	s1,40(sp)
    80004028:	7902                	ld	s2,32(sp)
    8000402a:	69e2                	ld	s3,24(sp)
    8000402c:	6a42                	ld	s4,16(sp)
    8000402e:	6121                	addi	sp,sp,64
    80004030:	8082                	ret
    panic("dirlookup not DIR");
    80004032:	00004517          	auipc	a0,0x4
    80004036:	7fe50513          	addi	a0,a0,2046 # 80008830 <etext+0x830>
    8000403a:	fd8fc0ef          	jal	80000812 <panic>
      panic("dirlookup read");
    8000403e:	00005517          	auipc	a0,0x5
    80004042:	80a50513          	addi	a0,a0,-2038 # 80008848 <etext+0x848>
    80004046:	fccfc0ef          	jal	80000812 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000404a:	24c1                	addiw	s1,s1,16
    8000404c:	04c92783          	lw	a5,76(s2)
    80004050:	faf4fae3          	bgeu	s1,a5,80004004 <dirlookup+0x26>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004054:	4741                	li	a4,16
    80004056:	86a6                	mv	a3,s1
    80004058:	fc040613          	addi	a2,s0,-64
    8000405c:	4581                	li	a1,0
    8000405e:	854a                	mv	a0,s2
    80004060:	cebff0ef          	jal	80003d4a <readi>
    80004064:	47c1                	li	a5,16
    80004066:	fcf51ce3          	bne	a0,a5,8000403e <dirlookup+0x60>
    if(de.inum == 0)
    8000406a:	fc045783          	lhu	a5,-64(s0)
    8000406e:	dff1                	beqz	a5,8000404a <dirlookup+0x6c>
    if(namecmp(name, de.name) == 0){
    80004070:	fc240593          	addi	a1,s0,-62
    80004074:	854e                	mv	a0,s3
    80004076:	f53ff0ef          	jal	80003fc8 <namecmp>
    8000407a:	f961                	bnez	a0,8000404a <dirlookup+0x6c>
      if(poff)
    8000407c:	000a0463          	beqz	s4,80004084 <dirlookup+0xa6>
        *poff = off;
    80004080:	009a2023          	sw	s1,0(s4)
      inum = de.inum;
    80004084:	fc045a03          	lhu	s4,-64(s0)
      dir_report(
    80004088:	00004797          	auipc	a5,0x4
    8000408c:	7d078793          	addi	a5,a5,2000 # 80008858 <etext+0x858>
    80004090:	8726                	mv	a4,s1
    80004092:	86d2                	mv	a3,s4
    80004094:	864e                	mv	a2,s3
    80004096:	85ca                	mv	a1,s2
    80004098:	00004517          	auipc	a0,0x4
    8000409c:	7d850513          	addi	a0,a0,2008 # 80008870 <etext+0x870>
    800040a0:	e77fe0ef          	jal	80002f16 <dir_report>
      return iget(dp->dev, inum);
    800040a4:	85d2                	mv	a1,s4
    800040a6:	00092503          	lw	a0,0(s2)
    800040aa:	bbaff0ef          	jal	80003464 <iget>
    800040ae:	bf95                	j	80004022 <dirlookup+0x44>

00000000800040b0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800040b0:	711d                	addi	sp,sp,-96
    800040b2:	ec86                	sd	ra,88(sp)
    800040b4:	e8a2                	sd	s0,80(sp)
    800040b6:	e4a6                	sd	s1,72(sp)
    800040b8:	e0ca                	sd	s2,64(sp)
    800040ba:	fc4e                	sd	s3,56(sp)
    800040bc:	f852                	sd	s4,48(sp)
    800040be:	f456                	sd	s5,40(sp)
    800040c0:	f05a                	sd	s6,32(sp)
    800040c2:	ec5e                	sd	s7,24(sp)
    800040c4:	e862                	sd	s8,16(sp)
    800040c6:	e466                	sd	s9,8(sp)
    800040c8:	1080                	addi	s0,sp,96
    800040ca:	84aa                	mv	s1,a0
    800040cc:	8b2e                	mv	s6,a1
    800040ce:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800040d0:	00054703          	lbu	a4,0(a0)
    800040d4:	02f00793          	li	a5,47
    800040d8:	00f70e63          	beq	a4,a5,800040f4 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800040dc:	82dfd0ef          	jal	80001908 <myproc>
    800040e0:	15053503          	ld	a0,336(a0)
    800040e4:	facff0ef          	jal	80003890 <idup>
    800040e8:	8a2a                	mv	s4,a0
  while(*path == '/')
    800040ea:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800040ee:	4c35                	li	s8,13
  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800040f0:	4b85                	li	s7,1
    800040f2:	a871                	j	8000418e <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800040f4:	4585                	li	a1,1
    800040f6:	4505                	li	a0,1
    800040f8:	b6cff0ef          	jal	80003464 <iget>
    800040fc:	8a2a                	mv	s4,a0
    800040fe:	b7f5                	j	800040ea <namex+0x3a>
      iunlockput(ip);
    80004100:	8552                	mv	a0,s4
    80004102:	ac3ff0ef          	jal	80003bc4 <iunlockput>
      
      return 0;
    80004106:	4a01                	li	s4,0
    myproc() ? "Process CWD" : "Root", // تم الإصلاح هنا بتمرير نوع السلسلة النصية المناسب بدلاً من الـ inode pointer
    ip,
    "Path resolved successfully"
  );
  return ip;
}
    80004108:	8552                	mv	a0,s4
    8000410a:	60e6                	ld	ra,88(sp)
    8000410c:	6446                	ld	s0,80(sp)
    8000410e:	64a6                	ld	s1,72(sp)
    80004110:	6906                	ld	s2,64(sp)
    80004112:	79e2                	ld	s3,56(sp)
    80004114:	7a42                	ld	s4,48(sp)
    80004116:	7aa2                	ld	s5,40(sp)
    80004118:	7b02                	ld	s6,32(sp)
    8000411a:	6be2                	ld	s7,24(sp)
    8000411c:	6c42                	ld	s8,16(sp)
    8000411e:	6ca2                	ld	s9,8(sp)
    80004120:	6125                	addi	sp,sp,96
    80004122:	8082                	ret
      iunlock(ip);
    80004124:	8552                	mv	a0,s4
    80004126:	8b5ff0ef          	jal	800039da <iunlock>
      return ip;
    8000412a:	bff9                	j	80004108 <namex+0x58>
      iunlockput(ip);
    8000412c:	8552                	mv	a0,s4
    8000412e:	a97ff0ef          	jal	80003bc4 <iunlockput>
      return 0;
    80004132:	8a4e                	mv	s4,s3
    80004134:	bfd1                	j	80004108 <namex+0x58>
  len = path - s;
    80004136:	40998633          	sub	a2,s3,s1
    8000413a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000413e:	099c5063          	bge	s8,s9,800041be <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80004142:	4639                	li	a2,14
    80004144:	85a6                	mv	a1,s1
    80004146:	8556                	mv	a0,s5
    80004148:	be9fc0ef          	jal	80000d30 <memmove>
    8000414c:	84ce                	mv	s1,s3
  while(*path == '/')
    8000414e:	0004c783          	lbu	a5,0(s1)
    80004152:	01279763          	bne	a5,s2,80004160 <namex+0xb0>
    path++;
    80004156:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004158:	0004c783          	lbu	a5,0(s1)
    8000415c:	ff278de3          	beq	a5,s2,80004156 <namex+0xa6>
    ilock(ip);
    80004160:	8552                	mv	a0,s4
    80004162:	f86ff0ef          	jal	800038e8 <ilock>
    if(ip->type != T_DIR){
    80004166:	044a1783          	lh	a5,68(s4)
    8000416a:	f9779be3          	bne	a5,s7,80004100 <namex+0x50>
    if(nameiparent && *path == '\0'){
    8000416e:	000b0563          	beqz	s6,80004178 <namex+0xc8>
    80004172:	0004c783          	lbu	a5,0(s1)
    80004176:	d7dd                	beqz	a5,80004124 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004178:	4601                	li	a2,0
    8000417a:	85d6                	mv	a1,s5
    8000417c:	8552                	mv	a0,s4
    8000417e:	e61ff0ef          	jal	80003fde <dirlookup>
    80004182:	89aa                	mv	s3,a0
    80004184:	d545                	beqz	a0,8000412c <namex+0x7c>
    iunlockput(ip);
    80004186:	8552                	mv	a0,s4
    80004188:	a3dff0ef          	jal	80003bc4 <iunlockput>
    ip = next;
    8000418c:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000418e:	0004c783          	lbu	a5,0(s1)
    80004192:	01279763          	bne	a5,s2,800041a0 <namex+0xf0>
    path++;
    80004196:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004198:	0004c783          	lbu	a5,0(s1)
    8000419c:	ff278de3          	beq	a5,s2,80004196 <namex+0xe6>
  if(*path == 0)
    800041a0:	cb8d                	beqz	a5,800041d2 <namex+0x122>
  while(*path != '/' && *path != 0)
    800041a2:	0004c783          	lbu	a5,0(s1)
    800041a6:	89a6                	mv	s3,s1
  len = path - s;
    800041a8:	4c81                	li	s9,0
    800041aa:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800041ac:	01278963          	beq	a5,s2,800041be <namex+0x10e>
    800041b0:	d3d9                	beqz	a5,80004136 <namex+0x86>
    path++;
    800041b2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800041b4:	0009c783          	lbu	a5,0(s3)
    800041b8:	ff279ce3          	bne	a5,s2,800041b0 <namex+0x100>
    800041bc:	bfad                	j	80004136 <namex+0x86>
    memmove(name, s, len);
    800041be:	2601                	sext.w	a2,a2
    800041c0:	85a6                	mv	a1,s1
    800041c2:	8556                	mv	a0,s5
    800041c4:	b6dfc0ef          	jal	80000d30 <memmove>
    name[len] = 0;
    800041c8:	9cd6                	add	s9,s9,s5
    800041ca:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800041ce:	84ce                	mv	s1,s3
    800041d0:	bfbd                	j	8000414e <namex+0x9e>
  if(nameiparent){
    800041d2:	040b1763          	bnez	s6,80004220 <namex+0x170>
    myproc() ? myproc()->current_syscall : "",
    800041d6:	f32fd0ef          	jal	80001908 <myproc>
  path_report(
    800041da:	00005497          	auipc	s1,0x5
    800041de:	9a648493          	addi	s1,s1,-1626 # 80008b80 <etext+0xb80>
    800041e2:	c509                	beqz	a0,800041ec <namex+0x13c>
    myproc() ? myproc()->current_syscall : "",
    800041e4:	f24fd0ef          	jal	80001908 <myproc>
  path_report(
    800041e8:	16850493          	addi	s1,a0,360
    myproc() ? "Process CWD" : "Root", // تم الإصلاح هنا بتمرير نوع السلسلة النصية المناسب بدلاً من الـ inode pointer
    800041ec:	f1cfd0ef          	jal	80001908 <myproc>
  path_report(
    800041f0:	00004717          	auipc	a4,0x4
    800041f4:	6d070713          	addi	a4,a4,1744 # 800088c0 <etext+0x8c0>
    800041f8:	c509                	beqz	a0,80004202 <namex+0x152>
    800041fa:	00004717          	auipc	a4,0x4
    800041fe:	6b670713          	addi	a4,a4,1718 # 800088b0 <etext+0x8b0>
    80004202:	00004817          	auipc	a6,0x4
    80004206:	6ee80813          	addi	a6,a6,1774 # 800088f0 <etext+0x8f0>
    8000420a:	87d2                	mv	a5,s4
    8000420c:	86d6                	mv	a3,s5
    8000420e:	4601                	li	a2,0
    80004210:	00004597          	auipc	a1,0x4
    80004214:	70058593          	addi	a1,a1,1792 # 80008910 <etext+0x910>
    80004218:	8526                	mv	a0,s1
    8000421a:	dcbfe0ef          	jal	80002fe4 <path_report>
  return ip;
    8000421e:	b5ed                	j	80004108 <namex+0x58>
      myproc() ? myproc()->current_syscall : "",
    80004220:	ee8fd0ef          	jal	80001908 <myproc>
    path_report(
    80004224:	00005497          	auipc	s1,0x5
    80004228:	95c48493          	addi	s1,s1,-1700 # 80008b80 <etext+0xb80>
    8000422c:	c509                	beqz	a0,80004236 <namex+0x186>
      myproc() ? myproc()->current_syscall : "",
    8000422e:	edafd0ef          	jal	80001908 <myproc>
    path_report(
    80004232:	16850493          	addi	s1,a0,360
      myproc() ? "Process CWD" : "Root", // تم الإصلاح هنا بتمرير نوع السلسلة النصية المناسب بدلاً من الـ inode pointer
    80004236:	ed2fd0ef          	jal	80001908 <myproc>
    path_report(
    8000423a:	00004717          	auipc	a4,0x4
    8000423e:	68670713          	addi	a4,a4,1670 # 800088c0 <etext+0x8c0>
    80004242:	c509                	beqz	a0,8000424c <namex+0x19c>
    80004244:	00004717          	auipc	a4,0x4
    80004248:	66c70713          	addi	a4,a4,1644 # 800088b0 <etext+0x8b0>
    8000424c:	00004817          	auipc	a6,0x4
    80004250:	67c80813          	addi	a6,a6,1660 # 800088c8 <etext+0x8c8>
    80004254:	87d2                	mv	a5,s4
    80004256:	86d6                	mv	a3,s5
    80004258:	4601                	li	a2,0
    8000425a:	00004597          	auipc	a1,0x4
    8000425e:	68658593          	addi	a1,a1,1670 # 800088e0 <etext+0x8e0>
    80004262:	8526                	mv	a0,s1
    80004264:	d81fe0ef          	jal	80002fe4 <path_report>
    iput(ip);
    80004268:	8552                	mv	a0,s4
    8000426a:	88fff0ef          	jal	80003af8 <iput>
    return 0;
    8000426e:	4a01                	li	s4,0
    80004270:	bd61                	j	80004108 <namex+0x58>

0000000080004272 <dirlink>:
{
    80004272:	7139                	addi	sp,sp,-64
    80004274:	fc06                	sd	ra,56(sp)
    80004276:	f822                	sd	s0,48(sp)
    80004278:	f04a                	sd	s2,32(sp)
    8000427a:	ec4e                	sd	s3,24(sp)
    8000427c:	e852                	sd	s4,16(sp)
    8000427e:	0080                	addi	s0,sp,64
    80004280:	892a                	mv	s2,a0
    80004282:	89ae                	mv	s3,a1
    80004284:	8a32                	mv	s4,a2
  dir_report(
    80004286:	00004797          	auipc	a5,0x4
    8000428a:	69a78793          	addi	a5,a5,1690 # 80008920 <etext+0x920>
    8000428e:	577d                	li	a4,-1
    80004290:	86b2                	mv	a3,a2
    80004292:	862e                	mv	a2,a1
    80004294:	85aa                	mv	a1,a0
    80004296:	00004517          	auipc	a0,0x4
    8000429a:	6aa50513          	addi	a0,a0,1706 # 80008940 <etext+0x940>
    8000429e:	c79fe0ef          	jal	80002f16 <dir_report>
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042a2:	4601                	li	a2,0
    800042a4:	85ce                	mv	a1,s3
    800042a6:	854a                	mv	a0,s2
    800042a8:	d37ff0ef          	jal	80003fde <dirlookup>
    800042ac:	e159                	bnez	a0,80004332 <dirlink+0xc0>
    800042ae:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042b0:	04c92483          	lw	s1,76(s2)
    800042b4:	c48d                	beqz	s1,800042de <dirlink+0x6c>
    800042b6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042b8:	4741                	li	a4,16
    800042ba:	86a6                	mv	a3,s1
    800042bc:	fc040613          	addi	a2,s0,-64
    800042c0:	4581                	li	a1,0
    800042c2:	854a                	mv	a0,s2
    800042c4:	a87ff0ef          	jal	80003d4a <readi>
    800042c8:	47c1                	li	a5,16
    800042ca:	06f51863          	bne	a0,a5,8000433a <dirlink+0xc8>
    if(de.inum == 0)
    800042ce:	fc045783          	lhu	a5,-64(s0)
    800042d2:	c791                	beqz	a5,800042de <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042d4:	24c1                	addiw	s1,s1,16
    800042d6:	04c92783          	lw	a5,76(s2)
    800042da:	fcf4efe3          	bltu	s1,a5,800042b8 <dirlink+0x46>
  strncpy(de.name, name, DIRSIZ);
    800042de:	4639                	li	a2,14
    800042e0:	85ce                	mv	a1,s3
    800042e2:	fc240513          	addi	a0,s0,-62
    800042e6:	af1fc0ef          	jal	80000dd6 <strncpy>
  de.inum = inum;
    800042ea:	fd441023          	sh	s4,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042ee:	4741                	li	a4,16
    800042f0:	86a6                	mv	a3,s1
    800042f2:	fc040613          	addi	a2,s0,-64
    800042f6:	4581                	li	a1,0
    800042f8:	854a                	mv	a0,s2
    800042fa:	b81ff0ef          	jal	80003e7a <writei>
    800042fe:	47c1                	li	a5,16
    80004300:	04f51363          	bne	a0,a5,80004346 <dirlink+0xd4>
  dir_report(
    80004304:	00004797          	auipc	a5,0x4
    80004308:	65c78793          	addi	a5,a5,1628 # 80008960 <etext+0x960>
    8000430c:	8726                	mv	a4,s1
    8000430e:	86d2                	mv	a3,s4
    80004310:	864e                	mv	a2,s3
    80004312:	85ca                	mv	a1,s2
    80004314:	00004517          	auipc	a0,0x4
    80004318:	66450513          	addi	a0,a0,1636 # 80008978 <etext+0x978>
    8000431c:	bfbfe0ef          	jal	80002f16 <dir_report>
  return 0;
    80004320:	4501                	li	a0,0
    80004322:	74a2                	ld	s1,40(sp)
}
    80004324:	70e2                	ld	ra,56(sp)
    80004326:	7442                	ld	s0,48(sp)
    80004328:	7902                	ld	s2,32(sp)
    8000432a:	69e2                	ld	s3,24(sp)
    8000432c:	6a42                	ld	s4,16(sp)
    8000432e:	6121                	addi	sp,sp,64
    80004330:	8082                	ret
    iput(ip);
    80004332:	fc6ff0ef          	jal	80003af8 <iput>
    return -1;
    80004336:	557d                	li	a0,-1
    80004338:	b7f5                	j	80004324 <dirlink+0xb2>
      panic("dirlink read");
    8000433a:	00004517          	auipc	a0,0x4
    8000433e:	61650513          	addi	a0,a0,1558 # 80008950 <etext+0x950>
    80004342:	cd0fc0ef          	jal	80000812 <panic>
    return -1;
    80004346:	557d                	li	a0,-1
    80004348:	74a2                	ld	s1,40(sp)
    8000434a:	bfe9                	j	80004324 <dirlink+0xb2>

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
    8000435a:	d57ff0ef          	jal	800040b0 <namex>
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
    80004372:	d3fff0ef          	jal	800040b0 <namex>
    80004376:	60a2                	ld	ra,8(sp)
    80004378:	6402                	ld	s0,0(sp)
    8000437a:	0141                	addi	sp,sp,16
    8000437c:	8082                	ret

000000008000437e <log_get_state>:
  int committing;
};

static struct log_state
log_get_state(void)
{
    8000437e:	1101                	addi	sp,sp,-32
    80004380:	ec22                	sd	s0,24(sp)
    80004382:	1000                	addi	s0,sp,32
  struct log_state s;
  s.n = log.lh.n;
  s.out = log.outstanding;
    80004384:	0001d697          	auipc	a3,0x1d
    80004388:	62468693          	addi	a3,a3,1572 # 800219a8 <log>
  s.committing = log.committing;
  return s;
    8000438c:	0286e503          	lwu	a0,40(a3)
    80004390:	57fd                	li	a5,-1
    80004392:	9381                	srli	a5,a5,0x20
    80004394:	01c6e703          	lwu	a4,28(a3)
    80004398:	1702                	slli	a4,a4,0x20
    8000439a:	8d7d                	and	a0,a0,a5
    8000439c:	0206e583          	lwu	a1,32(a3)
}
    800043a0:	8d59                	or	a0,a0,a4
    800043a2:	8dfd                	and	a1,a1,a5
    800043a4:	6462                	ld	s0,24(sp)
    800043a6:	6105                	addi	sp,sp,32
    800043a8:	8082                	ret

00000000800043aa <log_report>:
void log_report(char *op, int bno, struct log_state old, char *desc)
{
    800043aa:	ca010113          	addi	sp,sp,-864
    800043ae:	34113c23          	sd	ra,856(sp)
    800043b2:	34813823          	sd	s0,848(sp)
    800043b6:	34913423          	sd	s1,840(sp)
    800043ba:	35213023          	sd	s2,832(sp)
    800043be:	33313c23          	sd	s3,824(sp)
    800043c2:	1680                	addi	s0,sp,864
    800043c4:	892a                	mv	s2,a0
    800043c6:	89ae                	mv	s3,a1
    800043c8:	cac43023          	sd	a2,-864(s0)
    800043cc:	cad43423          	sd	a3,-856(s0)
    800043d0:	84ba                	mv	s1,a4
  struct fs_event e;
  memset(&e, 0, sizeof(e));
    800043d2:	30800613          	li	a2,776
    800043d6:	4581                	li	a1,0
    800043d8:	cc840513          	addi	a0,s0,-824
    800043dc:	8f9fc0ef          	jal	80000cd4 <memset>

  struct log_state now = log_get_state();
    800043e0:	f9fff0ef          	jal	8000437e <log_get_state>
    800043e4:	caa42c23          	sw	a0,-840(s0)
    800043e8:	02055793          	srli	a5,a0,0x20
    800043ec:	caf42e23          	sw	a5,-836(s0)
    800043f0:	ccb42023          	sw	a1,-832(s0)

  e.ticks = ticks;
    800043f4:	00005797          	auipc	a5,0x5
    800043f8:	ca47a783          	lw	a5,-860(a5) # 80009098 <ticks>
    800043fc:	ccf42823          	sw	a5,-816(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    80004400:	d08fd0ef          	jal	80001908 <myproc>
    80004404:	4781                	li	a5,0
    80004406:	c501                	beqz	a0,8000440e <log_report+0x64>
    80004408:	d00fd0ef          	jal	80001908 <myproc>
    8000440c:	591c                	lw	a5,48(a0)
    8000440e:	ccf42a23          	sw	a5,-812(s0)
  e.type = LAYER_LOG;
    80004412:	4789                	li	a5,2
    80004414:	ccf42c23          	sw	a5,-808(s0)
  e.blockno = bno;
    80004418:	cf342623          	sw	s3,-788(s0)

  // before
  e.old_log_n = old.n;
    8000441c:	ca042783          	lw	a5,-864(s0)
    80004420:	d0f42423          	sw	a5,-760(s0)
  e.old_outstanding = old.out;
    80004424:	ca442783          	lw	a5,-860(s0)
    80004428:	d0f42823          	sw	a5,-752(s0)
  e.old_committing = old.committing;
    8000442c:	ca842783          	lw	a5,-856(s0)
    80004430:	d0f42c23          	sw	a5,-744(s0)

  // after
  e.log_n = now.n;
    80004434:	cb842783          	lw	a5,-840(s0)
    80004438:	d0f42223          	sw	a5,-764(s0)
  e.outstanding = now.out;
    8000443c:	cbc42783          	lw	a5,-836(s0)
    80004440:	d0f42623          	sw	a5,-756(s0)
  e.committing = now.committing;
    80004444:	cc042783          	lw	a5,-832(s0)
    80004448:	d0f42a23          	sw	a5,-748(s0)

  safestrcpy(e.op_name, op, 16);
    8000444c:	4641                	li	a2,16
    8000444e:	85ca                	mv	a1,s2
    80004450:	cdc40513          	addi	a0,s0,-804
    80004454:	9bffc0ef          	jal	80000e12 <safestrcpy>
  safestrcpy(e.details, desc, 128);
    80004458:	08000613          	li	a2,128
    8000445c:	85a6                	mv	a1,s1
    8000445e:	f5040513          	addi	a0,s0,-176
    80004462:	9b1fc0ef          	jal	80000e12 <safestrcpy>

  fslog_push(&e);
    80004466:	cc840513          	addi	a0,s0,-824
    8000446a:	1b3020ef          	jal	80006e1c <fslog_push>
}
    8000446e:	35813083          	ld	ra,856(sp)
    80004472:	35013403          	ld	s0,848(sp)
    80004476:	34813483          	ld	s1,840(sp)
    8000447a:	34013903          	ld	s2,832(sp)
    8000447e:	33813983          	ld	s3,824(sp)
    80004482:	36010113          	addi	sp,sp,864
    80004486:	8082                	ret

0000000080004488 <install_trans>:
}

static void
install_trans(int recovering)
{
  for (int tail = 0; tail < log.lh.n; tail++) {
    80004488:	0001d797          	auipc	a5,0x1d
    8000448c:	5487a783          	lw	a5,1352(a5) # 800219d0 <log+0x28>
    80004490:	12f05063          	blez	a5,800045b0 <install_trans+0x128>
{
    80004494:	7159                	addi	sp,sp,-112
    80004496:	f486                	sd	ra,104(sp)
    80004498:	f0a2                	sd	s0,96(sp)
    8000449a:	eca6                	sd	s1,88(sp)
    8000449c:	e8ca                	sd	s2,80(sp)
    8000449e:	e4ce                	sd	s3,72(sp)
    800044a0:	e0d2                	sd	s4,64(sp)
    800044a2:	fc56                	sd	s5,56(sp)
    800044a4:	f85a                	sd	s6,48(sp)
    800044a6:	f45e                	sd	s7,40(sp)
    800044a8:	f062                	sd	s8,32(sp)
    800044aa:	ec66                	sd	s9,24(sp)
    800044ac:	e86a                	sd	s10,16(sp)
    800044ae:	1880                	addi	s0,sp,112
    800044b0:	8b2a                	mv	s6,a0
    800044b2:	0001da97          	auipc	s5,0x1d
    800044b6:	522a8a93          	addi	s5,s5,1314 # 800219d4 <log+0x2c>
  for (int tail = 0; tail < log.lh.n; tail++) {
    800044ba:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1);
    800044bc:	0001d997          	auipc	s3,0x1d
    800044c0:	4ec98993          	addi	s3,s3,1260 # 800219a8 <log>
    struct log_state old = log_get_state();

    if (recovering)
      log_report("RECOVER_BLK", log.lh.block[tail], old, "Recover block");
    else
      log_report("INSTALL_BLK", log.lh.block[tail], old, "Install block");
    800044c4:	00004d17          	auipc	s10,0x4
    800044c8:	4e4d0d13          	addi	s10,s10,1252 # 800089a8 <etext+0x9a8>
    800044cc:	00004c97          	auipc	s9,0x4
    800044d0:	4ecc8c93          	addi	s9,s9,1260 # 800089b8 <etext+0x9b8>
      log_report("RECOVER_BLK", log.lh.block[tail], old, "Recover block");
    800044d4:	00004c17          	auipc	s8,0x4
    800044d8:	4b4c0c13          	addi	s8,s8,1204 # 80008988 <etext+0x988>
    800044dc:	00004b97          	auipc	s7,0x4
    800044e0:	4bcb8b93          	addi	s7,s7,1212 # 80008998 <etext+0x998>
    800044e4:	a0a9                	j	8000452e <install_trans+0xa6>
      log_report("INSTALL_BLK", log.lh.block[tail], old, "Install block");
    800044e6:	876a                	mv	a4,s10
    800044e8:	f9043603          	ld	a2,-112(s0)
    800044ec:	f9843683          	ld	a3,-104(s0)
    800044f0:	000aa583          	lw	a1,0(s5)
    800044f4:	8566                	mv	a0,s9
    800044f6:	eb5ff0ef          	jal	800043aa <log_report>

    memmove(dbuf->data, lbuf->data, BSIZE);
    800044fa:	40000613          	li	a2,1024
    800044fe:	05890593          	addi	a1,s2,88
    80004502:	05848513          	addi	a0,s1,88
    80004506:	82bfc0ef          	jal	80000d30 <memmove>
    bwrite(dbuf);
    8000450a:	8526                	mv	a0,s1
    8000450c:	877fe0ef          	jal	80002d82 <bwrite>

    if (!recovering)
      bunpin(dbuf);
    80004510:	8526                	mv	a0,s1
    80004512:	9b7fe0ef          	jal	80002ec8 <bunpin>

    brelse(lbuf);
    80004516:	854a                	mv	a0,s2
    80004518:	8c3fe0ef          	jal	80002dda <brelse>
    brelse(dbuf);
    8000451c:	8526                	mv	a0,s1
    8000451e:	8bdfe0ef          	jal	80002dda <brelse>
  for (int tail = 0; tail < log.lh.n; tail++) {
    80004522:	2a05                	addiw	s4,s4,1
    80004524:	0a91                	addi	s5,s5,4
    80004526:	0289a783          	lw	a5,40(s3)
    8000452a:	06fa5563          	bge	s4,a5,80004594 <install_trans+0x10c>
    struct buf *lbuf = bread(log.dev, log.start+tail+1);
    8000452e:	0189a583          	lw	a1,24(s3)
    80004532:	014585bb          	addw	a1,a1,s4
    80004536:	2585                	addiw	a1,a1,1
    80004538:	0249a503          	lw	a0,36(s3)
    8000453c:	f08fe0ef          	jal	80002c44 <bread>
    80004540:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);
    80004542:	000aa583          	lw	a1,0(s5)
    80004546:	0249a503          	lw	a0,36(s3)
    8000454a:	efafe0ef          	jal	80002c44 <bread>
    8000454e:	84aa                	mv	s1,a0
    struct log_state old = log_get_state();
    80004550:	e2fff0ef          	jal	8000437e <log_get_state>
    80004554:	f8a42823          	sw	a0,-112(s0)
    80004558:	02055793          	srli	a5,a0,0x20
    8000455c:	f8f42a23          	sw	a5,-108(s0)
    80004560:	f8b42c23          	sw	a1,-104(s0)
    if (recovering)
    80004564:	f80b01e3          	beqz	s6,800044e6 <install_trans+0x5e>
      log_report("RECOVER_BLK", log.lh.block[tail], old, "Recover block");
    80004568:	8762                	mv	a4,s8
    8000456a:	f9043603          	ld	a2,-112(s0)
    8000456e:	f9843683          	ld	a3,-104(s0)
    80004572:	000aa583          	lw	a1,0(s5)
    80004576:	855e                	mv	a0,s7
    80004578:	e33ff0ef          	jal	800043aa <log_report>
    memmove(dbuf->data, lbuf->data, BSIZE);
    8000457c:	40000613          	li	a2,1024
    80004580:	05890593          	addi	a1,s2,88
    80004584:	05848513          	addi	a0,s1,88
    80004588:	fa8fc0ef          	jal	80000d30 <memmove>
    bwrite(dbuf);
    8000458c:	8526                	mv	a0,s1
    8000458e:	ff4fe0ef          	jal	80002d82 <bwrite>
    if (!recovering)
    80004592:	b751                	j	80004516 <install_trans+0x8e>
  }
}
    80004594:	70a6                	ld	ra,104(sp)
    80004596:	7406                	ld	s0,96(sp)
    80004598:	64e6                	ld	s1,88(sp)
    8000459a:	6946                	ld	s2,80(sp)
    8000459c:	69a6                	ld	s3,72(sp)
    8000459e:	6a06                	ld	s4,64(sp)
    800045a0:	7ae2                	ld	s5,56(sp)
    800045a2:	7b42                	ld	s6,48(sp)
    800045a4:	7ba2                	ld	s7,40(sp)
    800045a6:	7c02                	ld	s8,32(sp)
    800045a8:	6ce2                	ld	s9,24(sp)
    800045aa:	6d42                	ld	s10,16(sp)
    800045ac:	6165                	addi	sp,sp,112
    800045ae:	8082                	ret
    800045b0:	8082                	ret

00000000800045b2 <write_head>:
{
    800045b2:	7179                	addi	sp,sp,-48
    800045b4:	f406                	sd	ra,40(sp)
    800045b6:	f022                	sd	s0,32(sp)
    800045b8:	ec26                	sd	s1,24(sp)
    800045ba:	e84a                	sd	s2,16(sp)
    800045bc:	1800                	addi	s0,sp,48
  struct buf *buf = bread(log.dev, log.start);
    800045be:	0001d917          	auipc	s2,0x1d
    800045c2:	3ea90913          	addi	s2,s2,1002 # 800219a8 <log>
    800045c6:	01892583          	lw	a1,24(s2)
    800045ca:	02492503          	lw	a0,36(s2)
    800045ce:	e76fe0ef          	jal	80002c44 <bread>
    800045d2:	84aa                	mv	s1,a0
  struct log_state old = log_get_state();
    800045d4:	dabff0ef          	jal	8000437e <log_get_state>
    800045d8:	fca42823          	sw	a0,-48(s0)
    800045dc:	9101                	srli	a0,a0,0x20
    800045de:	fca42a23          	sw	a0,-44(s0)
    800045e2:	fcb42c23          	sw	a1,-40(s0)
  hb->n = log.lh.n;
    800045e6:	02892603          	lw	a2,40(s2)
    800045ea:	ccb0                	sw	a2,88(s1)
  for (int i = 0; i < log.lh.n; i++)
    800045ec:	00c05f63          	blez	a2,8000460a <write_head+0x58>
    800045f0:	0001d717          	auipc	a4,0x1d
    800045f4:	3e470713          	addi	a4,a4,996 # 800219d4 <log+0x2c>
    800045f8:	87a6                	mv	a5,s1
    800045fa:	060a                	slli	a2,a2,0x2
    800045fc:	9626                	add	a2,a2,s1
    hb->block[i] = log.lh.block[i];
    800045fe:	4314                	lw	a3,0(a4)
    80004600:	cff4                	sw	a3,92(a5)
  for (int i = 0; i < log.lh.n; i++)
    80004602:	0711                	addi	a4,a4,4
    80004604:	0791                	addi	a5,a5,4
    80004606:	fec79ce3          	bne	a5,a2,800045fe <write_head+0x4c>
  bwrite(buf);
    8000460a:	8526                	mv	a0,s1
    8000460c:	f76fe0ef          	jal	80002d82 <bwrite>
  log_report("WRITE_HEAD", 0, old, "Write log header to disk");
    80004610:	00004717          	auipc	a4,0x4
    80004614:	3b870713          	addi	a4,a4,952 # 800089c8 <etext+0x9c8>
    80004618:	fd043603          	ld	a2,-48(s0)
    8000461c:	fd843683          	ld	a3,-40(s0)
    80004620:	4581                	li	a1,0
    80004622:	00004517          	auipc	a0,0x4
    80004626:	3c650513          	addi	a0,a0,966 # 800089e8 <etext+0x9e8>
    8000462a:	d81ff0ef          	jal	800043aa <log_report>
  brelse(buf);
    8000462e:	8526                	mv	a0,s1
    80004630:	faafe0ef          	jal	80002dda <brelse>
}
    80004634:	70a2                	ld	ra,40(sp)
    80004636:	7402                	ld	s0,32(sp)
    80004638:	64e2                	ld	s1,24(sp)
    8000463a:	6942                	ld	s2,16(sp)
    8000463c:	6145                	addi	sp,sp,48
    8000463e:	8082                	ret

0000000080004640 <initlog>:
{
    80004640:	715d                	addi	sp,sp,-80
    80004642:	e486                	sd	ra,72(sp)
    80004644:	e0a2                	sd	s0,64(sp)
    80004646:	fc26                	sd	s1,56(sp)
    80004648:	f84a                	sd	s2,48(sp)
    8000464a:	f44e                	sd	s3,40(sp)
    8000464c:	0880                	addi	s0,sp,80
    8000464e:	892a                	mv	s2,a0
    80004650:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004652:	0001d497          	auipc	s1,0x1d
    80004656:	35648493          	addi	s1,s1,854 # 800219a8 <log>
    8000465a:	00004597          	auipc	a1,0x4
    8000465e:	39e58593          	addi	a1,a1,926 # 800089f8 <etext+0x9f8>
    80004662:	8526                	mv	a0,s1
    80004664:	d1cfc0ef          	jal	80000b80 <initlock>
  log.start = sb->logstart;
    80004668:	0149a783          	lw	a5,20(s3)
    8000466c:	cc9c                	sw	a5,24(s1)
  log.dev = dev;
    8000466e:	0324a223          	sw	s2,36(s1)
  struct log_state old = log_get_state();
    80004672:	d0dff0ef          	jal	8000437e <log_get_state>
    80004676:	fca42023          	sw	a0,-64(s0)
    8000467a:	9101                	srli	a0,a0,0x20
    8000467c:	fca42223          	sw	a0,-60(s0)
    80004680:	fcb42423          	sw	a1,-56(s0)
  log_report("INIT_LOG", 0, old, "Initialize log system");
    80004684:	00004717          	auipc	a4,0x4
    80004688:	37c70713          	addi	a4,a4,892 # 80008a00 <etext+0xa00>
    8000468c:	fc043603          	ld	a2,-64(s0)
    80004690:	fc843683          	ld	a3,-56(s0)
    80004694:	4581                	li	a1,0
    80004696:	00004517          	auipc	a0,0x4
    8000469a:	38250513          	addi	a0,a0,898 # 80008a18 <etext+0xa18>
    8000469e:	d0dff0ef          	jal	800043aa <log_report>
  struct buf *buf = bread(log.dev, log.start);
    800046a2:	4c8c                	lw	a1,24(s1)
    800046a4:	50c8                	lw	a0,36(s1)
    800046a6:	d9efe0ef          	jal	80002c44 <bread>
    800046aa:	892a                	mv	s2,a0
  struct log_state old = log_get_state();
    800046ac:	cd3ff0ef          	jal	8000437e <log_get_state>
    800046b0:	faa42823          	sw	a0,-80(s0)
    800046b4:	02055793          	srli	a5,a0,0x20
    800046b8:	faf42a23          	sw	a5,-76(s0)
    800046bc:	fab42c23          	sw	a1,-72(s0)
  log.lh.n = lh->n;
    800046c0:	05892603          	lw	a2,88(s2)
    800046c4:	d490                	sw	a2,40(s1)
  for (int i = 0; i < log.lh.n; i++)
    800046c6:	00c05f63          	blez	a2,800046e4 <initlog+0xa4>
    800046ca:	87ca                	mv	a5,s2
    800046cc:	0001d717          	auipc	a4,0x1d
    800046d0:	30870713          	addi	a4,a4,776 # 800219d4 <log+0x2c>
    800046d4:	060a                	slli	a2,a2,0x2
    800046d6:	964a                	add	a2,a2,s2
    log.lh.block[i] = lh->block[i];
    800046d8:	4ff4                	lw	a3,92(a5)
    800046da:	c314                	sw	a3,0(a4)
  for (int i = 0; i < log.lh.n; i++)
    800046dc:	0791                	addi	a5,a5,4
    800046de:	0711                	addi	a4,a4,4
    800046e0:	fec79ce3          	bne	a5,a2,800046d8 <initlog+0x98>
  log_report("READ_HEAD", 0, old, "Read log header from disk");
    800046e4:	00004717          	auipc	a4,0x4
    800046e8:	34470713          	addi	a4,a4,836 # 80008a28 <etext+0xa28>
    800046ec:	fb043603          	ld	a2,-80(s0)
    800046f0:	fb843683          	ld	a3,-72(s0)
    800046f4:	4581                	li	a1,0
    800046f6:	00004517          	auipc	a0,0x4
    800046fa:	35250513          	addi	a0,a0,850 # 80008a48 <etext+0xa48>
    800046fe:	cadff0ef          	jal	800043aa <log_report>
  brelse(buf);
    80004702:	854a                	mv	a0,s2
    80004704:	ed6fe0ef          	jal	80002dda <brelse>
static void
recover_from_log(void)
{
  read_head();

  if (log.lh.n > 0) {
    80004708:	0001d797          	auipc	a5,0x1d
    8000470c:	2c87a783          	lw	a5,712(a5) # 800219d0 <log+0x28>
    80004710:	00f04963          	bgtz	a5,80004722 <initlog+0xe2>
}
    80004714:	60a6                	ld	ra,72(sp)
    80004716:	6406                	ld	s0,64(sp)
    80004718:	74e2                	ld	s1,56(sp)
    8000471a:	7942                	ld	s2,48(sp)
    8000471c:	79a2                	ld	s3,40(sp)
    8000471e:	6161                	addi	sp,sp,80
    80004720:	8082                	ret
    struct log_state old = log_get_state();
    80004722:	c5dff0ef          	jal	8000437e <log_get_state>
    80004726:	faa42823          	sw	a0,-80(s0)
    8000472a:	9101                	srli	a0,a0,0x20
    8000472c:	faa42a23          	sw	a0,-76(s0)
    80004730:	fab42c23          	sw	a1,-72(s0)

    log_report("RECOVER_START", 0, old, "Start recovery");
    80004734:	00004717          	auipc	a4,0x4
    80004738:	32470713          	addi	a4,a4,804 # 80008a58 <etext+0xa58>
    8000473c:	fb043603          	ld	a2,-80(s0)
    80004740:	fb843683          	ld	a3,-72(s0)
    80004744:	4581                	li	a1,0
    80004746:	00004517          	auipc	a0,0x4
    8000474a:	32250513          	addi	a0,a0,802 # 80008a68 <etext+0xa68>
    8000474e:	c5dff0ef          	jal	800043aa <log_report>

    install_trans(1);
    80004752:	4505                	li	a0,1
    80004754:	d35ff0ef          	jal	80004488 <install_trans>

    old = log_get_state();
    80004758:	c27ff0ef          	jal	8000437e <log_get_state>
    8000475c:	faa42823          	sw	a0,-80(s0)
    80004760:	9101                	srli	a0,a0,0x20
    80004762:	faa42a23          	sw	a0,-76(s0)
    80004766:	fab42c23          	sw	a1,-72(s0)
    log.lh.n = 0;
    8000476a:	0001d797          	auipc	a5,0x1d
    8000476e:	2607a323          	sw	zero,614(a5) # 800219d0 <log+0x28>
    write_head();
    80004772:	e41ff0ef          	jal	800045b2 <write_head>

    log_report("RECOVER_DONE", 0, old, "Recovery done");
    80004776:	00004717          	auipc	a4,0x4
    8000477a:	30270713          	addi	a4,a4,770 # 80008a78 <etext+0xa78>
    8000477e:	fb043603          	ld	a2,-80(s0)
    80004782:	fb843683          	ld	a3,-72(s0)
    80004786:	4581                	li	a1,0
    80004788:	00004517          	auipc	a0,0x4
    8000478c:	30050513          	addi	a0,a0,768 # 80008a88 <etext+0xa88>
    80004790:	c1bff0ef          	jal	800043aa <log_report>
}
    80004794:	b741                	j	80004714 <initlog+0xd4>

0000000080004796 <begin_op>:
  }
}

void
begin_op(void)
{
    80004796:	711d                	addi	sp,sp,-96
    80004798:	ec86                	sd	ra,88(sp)
    8000479a:	e8a2                	sd	s0,80(sp)
    8000479c:	e4a6                	sd	s1,72(sp)
    8000479e:	e0ca                	sd	s2,64(sp)
    800047a0:	fc4e                	sd	s3,56(sp)
    800047a2:	f852                	sd	s4,48(sp)
    800047a4:	f456                	sd	s5,40(sp)
    800047a6:	f05a                	sd	s6,32(sp)
    800047a8:	ec5e                	sd	s7,24(sp)
    800047aa:	1080                	addi	s0,sp,96
  acquire(&log.lock);
    800047ac:	0001d517          	auipc	a0,0x1d
    800047b0:	1fc50513          	addi	a0,a0,508 # 800219a8 <log>
    800047b4:	c4cfc0ef          	jal	80000c00 <acquire>

  while (1) {
    if (log.committing) {
    800047b8:	0001d497          	auipc	s1,0x1d
    800047bc:	1f048493          	addi	s1,s1,496 # 800219a8 <log>
      struct log_state old = log_get_state();
      log_report("WAIT_COMMIT", 0, old, "Waiting for commit");
      sleep(&log, &log.lock);

    } else if (log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS) {
    800047c0:	4979                	li	s2,30
      struct log_state old = log_get_state();
      log_report("WAIT_SPACE", 0, old, "Waiting for log space");
    800047c2:	00004a17          	auipc	s4,0x4
    800047c6:	2fea0a13          	addi	s4,s4,766 # 80008ac0 <etext+0xac0>
    800047ca:	00004997          	auipc	s3,0x4
    800047ce:	30e98993          	addi	s3,s3,782 # 80008ad8 <etext+0xad8>
      log_report("WAIT_COMMIT", 0, old, "Waiting for commit");
    800047d2:	00004b17          	auipc	s6,0x4
    800047d6:	2c6b0b13          	addi	s6,s6,710 # 80008a98 <etext+0xa98>
    800047da:	00004a97          	auipc	s5,0x4
    800047de:	2d6a8a93          	addi	s5,s5,726 # 80008ab0 <etext+0xab0>
    800047e2:	a03d                	j	80004810 <begin_op+0x7a>
      struct log_state old = log_get_state();
    800047e4:	b9bff0ef          	jal	8000437e <log_get_state>
    800047e8:	faa42023          	sw	a0,-96(s0)
    800047ec:	9101                	srli	a0,a0,0x20
    800047ee:	faa42223          	sw	a0,-92(s0)
    800047f2:	fab42423          	sw	a1,-88(s0)
      log_report("WAIT_COMMIT", 0, old, "Waiting for commit");
    800047f6:	875a                	mv	a4,s6
    800047f8:	fa043603          	ld	a2,-96(s0)
    800047fc:	fa843683          	ld	a3,-88(s0)
    80004800:	4581                	li	a1,0
    80004802:	8556                	mv	a0,s5
    80004804:	ba7ff0ef          	jal	800043aa <log_report>
      sleep(&log, &log.lock);
    80004808:	85a6                	mv	a1,s1
    8000480a:	8526                	mv	a0,s1
    8000480c:	f0cfd0ef          	jal	80001f18 <sleep>
    if (log.committing) {
    80004810:	509c                	lw	a5,32(s1)
    80004812:	fbe9                	bnez	a5,800047e4 <begin_op+0x4e>
    } else if (log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS) {
    80004814:	01c4ab83          	lw	s7,28(s1)
    80004818:	2b85                	addiw	s7,s7,1
    8000481a:	002b979b          	slliw	a5,s7,0x2
    8000481e:	017787bb          	addw	a5,a5,s7
    80004822:	0017979b          	slliw	a5,a5,0x1
    80004826:	5498                	lw	a4,40(s1)
    80004828:	9fb9                	addw	a5,a5,a4
    8000482a:	02f95963          	bge	s2,a5,8000485c <begin_op+0xc6>
      struct log_state old = log_get_state();
    8000482e:	b51ff0ef          	jal	8000437e <log_get_state>
    80004832:	faa42023          	sw	a0,-96(s0)
    80004836:	9101                	srli	a0,a0,0x20
    80004838:	faa42223          	sw	a0,-92(s0)
    8000483c:	fab42423          	sw	a1,-88(s0)
      log_report("WAIT_SPACE", 0, old, "Waiting for log space");
    80004840:	8752                	mv	a4,s4
    80004842:	fa043603          	ld	a2,-96(s0)
    80004846:	fa843683          	ld	a3,-88(s0)
    8000484a:	4581                	li	a1,0
    8000484c:	854e                	mv	a0,s3
    8000484e:	b5dff0ef          	jal	800043aa <log_report>
      sleep(&log, &log.lock);
    80004852:	85a6                	mv	a1,s1
    80004854:	8526                	mv	a0,s1
    80004856:	ec2fd0ef          	jal	80001f18 <sleep>
    8000485a:	bf5d                	j	80004810 <begin_op+0x7a>

    } else {
      struct log_state old = log_get_state();
    8000485c:	b23ff0ef          	jal	8000437e <log_get_state>
    80004860:	faa42023          	sw	a0,-96(s0)
    80004864:	9101                	srli	a0,a0,0x20
    80004866:	faa42223          	sw	a0,-92(s0)
    8000486a:	fab42423          	sw	a1,-88(s0)

      log.outstanding++;
    8000486e:	0001d497          	auipc	s1,0x1d
    80004872:	13a48493          	addi	s1,s1,314 # 800219a8 <log>
    80004876:	0174ae23          	sw	s7,28(s1)

      log_report("BEGIN_OP", 0, old, "Begin operation");
    8000487a:	00004717          	auipc	a4,0x4
    8000487e:	26e70713          	addi	a4,a4,622 # 80008ae8 <etext+0xae8>
    80004882:	fa043603          	ld	a2,-96(s0)
    80004886:	fa843683          	ld	a3,-88(s0)
    8000488a:	4581                	li	a1,0
    8000488c:	00004517          	auipc	a0,0x4
    80004890:	26c50513          	addi	a0,a0,620 # 80008af8 <etext+0xaf8>
    80004894:	b17ff0ef          	jal	800043aa <log_report>

      release(&log.lock);
    80004898:	8526                	mv	a0,s1
    8000489a:	bfefc0ef          	jal	80000c98 <release>
      break;
    }
  }
}
    8000489e:	60e6                	ld	ra,88(sp)
    800048a0:	6446                	ld	s0,80(sp)
    800048a2:	64a6                	ld	s1,72(sp)
    800048a4:	6906                	ld	s2,64(sp)
    800048a6:	79e2                	ld	s3,56(sp)
    800048a8:	7a42                	ld	s4,48(sp)
    800048aa:	7aa2                	ld	s5,40(sp)
    800048ac:	7b02                	ld	s6,32(sp)
    800048ae:	6be2                	ld	s7,24(sp)
    800048b0:	6125                	addi	sp,sp,96
    800048b2:	8082                	ret

00000000800048b4 <end_op>:

void
end_op(void)
{
    800048b4:	7119                	addi	sp,sp,-128
    800048b6:	fc86                	sd	ra,120(sp)
    800048b8:	f8a2                	sd	s0,112(sp)
    800048ba:	f4a6                	sd	s1,104(sp)
    800048bc:	f0ca                	sd	s2,96(sp)
    800048be:	0100                	addi	s0,sp,128
  int do_commit = 0;

  acquire(&log.lock);
    800048c0:	0001d497          	auipc	s1,0x1d
    800048c4:	0e848493          	addi	s1,s1,232 # 800219a8 <log>
    800048c8:	8526                	mv	a0,s1
    800048ca:	b36fc0ef          	jal	80000c00 <acquire>

  struct log_state old = log_get_state();
    800048ce:	ab1ff0ef          	jal	8000437e <log_get_state>
    800048d2:	faa42023          	sw	a0,-96(s0)
    800048d6:	9101                	srli	a0,a0,0x20
    800048d8:	faa42223          	sw	a0,-92(s0)
    800048dc:	fab42423          	sw	a1,-88(s0)

  log.outstanding--;
    800048e0:	4cdc                	lw	a5,28(s1)
    800048e2:	37fd                	addiw	a5,a5,-1
    800048e4:	0007891b          	sext.w	s2,a5
    800048e8:	ccdc                	sw	a5,28(s1)

  if (log.outstanding == 0) {
    800048ea:	08091163          	bnez	s2,8000496c <end_op+0xb8>
    do_commit = 1;
    log.committing = 1;
    800048ee:	4785                	li	a5,1
    800048f0:	d09c                	sw	a5,32(s1)

    log_report("PRE_COMMIT", 0, old, "Start committing");
    800048f2:	00004717          	auipc	a4,0x4
    800048f6:	21670713          	addi	a4,a4,534 # 80008b08 <etext+0xb08>
    800048fa:	fa043603          	ld	a2,-96(s0)
    800048fe:	fa843683          	ld	a3,-88(s0)
    80004902:	4581                	li	a1,0
    80004904:	00004517          	auipc	a0,0x4
    80004908:	21c50513          	addi	a0,a0,540 # 80008b20 <etext+0xb20>
    8000490c:	a9fff0ef          	jal	800043aa <log_report>
  } else {
    log_report("END_OP", 0, old, "End operation");
    wakeup(&log);
  }

  release(&log.lock);
    80004910:	8526                	mv	a0,s1
    80004912:	b86fc0ef          	jal	80000c98 <release>
}

static void
commit(void)
{
  if (log.lh.n > 0) {
    80004916:	549c                	lw	a5,40(s1)
    80004918:	08f04963          	bgtz	a5,800049aa <end_op+0xf6>
    acquire(&log.lock);
    8000491c:	0001d497          	auipc	s1,0x1d
    80004920:	08c48493          	addi	s1,s1,140 # 800219a8 <log>
    80004924:	8526                	mv	a0,s1
    80004926:	adafc0ef          	jal	80000c00 <acquire>
    old = log_get_state();
    8000492a:	a55ff0ef          	jal	8000437e <log_get_state>
    8000492e:	faa42023          	sw	a0,-96(s0)
    80004932:	9101                	srli	a0,a0,0x20
    80004934:	faa42223          	sw	a0,-92(s0)
    80004938:	fab42423          	sw	a1,-88(s0)
    log.committing = 0;
    8000493c:	0204a023          	sw	zero,32(s1)
    log_report("FINAL_RELEASE", 0, old, "Commit finished");
    80004940:	00004717          	auipc	a4,0x4
    80004944:	28070713          	addi	a4,a4,640 # 80008bc0 <etext+0xbc0>
    80004948:	fa043603          	ld	a2,-96(s0)
    8000494c:	fa843683          	ld	a3,-88(s0)
    80004950:	4581                	li	a1,0
    80004952:	00004517          	auipc	a0,0x4
    80004956:	27e50513          	addi	a0,a0,638 # 80008bd0 <etext+0xbd0>
    8000495a:	a51ff0ef          	jal	800043aa <log_report>
    wakeup(&log);
    8000495e:	8526                	mv	a0,s1
    80004960:	e04fd0ef          	jal	80001f64 <wakeup>
    release(&log.lock);
    80004964:	8526                	mv	a0,s1
    80004966:	b32fc0ef          	jal	80000c98 <release>
}
    8000496a:	a815                	j	8000499e <end_op+0xea>
    log_report("END_OP", 0, old, "End operation");
    8000496c:	00004717          	auipc	a4,0x4
    80004970:	1c470713          	addi	a4,a4,452 # 80008b30 <etext+0xb30>
    80004974:	fa043603          	ld	a2,-96(s0)
    80004978:	fa843683          	ld	a3,-88(s0)
    8000497c:	4581                	li	a1,0
    8000497e:	00004517          	auipc	a0,0x4
    80004982:	1c250513          	addi	a0,a0,450 # 80008b40 <etext+0xb40>
    80004986:	a25ff0ef          	jal	800043aa <log_report>
    wakeup(&log);
    8000498a:	0001d497          	auipc	s1,0x1d
    8000498e:	01e48493          	addi	s1,s1,30 # 800219a8 <log>
    80004992:	8526                	mv	a0,s1
    80004994:	dd0fd0ef          	jal	80001f64 <wakeup>
  release(&log.lock);
    80004998:	8526                	mv	a0,s1
    8000499a:	afefc0ef          	jal	80000c98 <release>
}
    8000499e:	70e6                	ld	ra,120(sp)
    800049a0:	7446                	ld	s0,112(sp)
    800049a2:	74a6                	ld	s1,104(sp)
    800049a4:	7906                	ld	s2,96(sp)
    800049a6:	6109                	addi	sp,sp,128
    800049a8:	8082                	ret
    struct log_state old = log_get_state();
    800049aa:	9d5ff0ef          	jal	8000437e <log_get_state>
    800049ae:	f8a42023          	sw	a0,-128(s0)
    800049b2:	9101                	srli	a0,a0,0x20
    800049b4:	f8a42223          	sw	a0,-124(s0)
    800049b8:	f8b42423          	sw	a1,-120(s0)

    log_report("COMMIT_START", 0, old, "Commit start");
    800049bc:	00004717          	auipc	a4,0x4
    800049c0:	18c70713          	addi	a4,a4,396 # 80008b48 <etext+0xb48>
    800049c4:	f8043603          	ld	a2,-128(s0)
    800049c8:	f8843683          	ld	a3,-120(s0)
    800049cc:	4581                	li	a1,0
    800049ce:	00004517          	auipc	a0,0x4
    800049d2:	18a50513          	addi	a0,a0,394 # 80008b58 <etext+0xb58>
    800049d6:	9d5ff0ef          	jal	800043aa <log_report>
  for (int tail = 0; tail < log.lh.n; tail++) {
    800049da:	0001d797          	auipc	a5,0x1d
    800049de:	ff67a783          	lw	a5,-10(a5) # 800219d0 <log+0x28>
    800049e2:	0af05863          	blez	a5,80004a92 <end_op+0x1de>
    800049e6:	ecce                	sd	s3,88(sp)
    800049e8:	e8d2                	sd	s4,80(sp)
    800049ea:	e4d6                	sd	s5,72(sp)
    800049ec:	e0da                	sd	s6,64(sp)
    800049ee:	fc5e                	sd	s7,56(sp)
    800049f0:	0001da97          	auipc	s5,0x1d
    800049f4:	fe4a8a93          	addi	s5,s5,-28 # 800219d4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1);
    800049f8:	0001da17          	auipc	s4,0x1d
    800049fc:	fb0a0a13          	addi	s4,s4,-80 # 800219a8 <log>
    log_report("LOG_SYNC", log.lh.block[tail], old, "Write to log");
    80004a00:	00004b97          	auipc	s7,0x4
    80004a04:	168b8b93          	addi	s7,s7,360 # 80008b68 <etext+0xb68>
    80004a08:	00004b17          	auipc	s6,0x4
    80004a0c:	170b0b13          	addi	s6,s6,368 # 80008b78 <etext+0xb78>
    struct buf *to = bread(log.dev, log.start+tail+1);
    80004a10:	018a2583          	lw	a1,24(s4)
    80004a14:	012585bb          	addw	a1,a1,s2
    80004a18:	2585                	addiw	a1,a1,1
    80004a1a:	024a2503          	lw	a0,36(s4)
    80004a1e:	a26fe0ef          	jal	80002c44 <bread>
    80004a22:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]);
    80004a24:	000aa583          	lw	a1,0(s5)
    80004a28:	024a2503          	lw	a0,36(s4)
    80004a2c:	a18fe0ef          	jal	80002c44 <bread>
    80004a30:	89aa                	mv	s3,a0
    struct log_state old = log_get_state();
    80004a32:	94dff0ef          	jal	8000437e <log_get_state>
    80004a36:	f8a42823          	sw	a0,-112(s0)
    80004a3a:	02055793          	srli	a5,a0,0x20
    80004a3e:	f8f42a23          	sw	a5,-108(s0)
    80004a42:	f8b42c23          	sw	a1,-104(s0)
    log_report("LOG_SYNC", log.lh.block[tail], old, "Write to log");
    80004a46:	875e                	mv	a4,s7
    80004a48:	f9043603          	ld	a2,-112(s0)
    80004a4c:	f9843683          	ld	a3,-104(s0)
    80004a50:	000aa583          	lw	a1,0(s5)
    80004a54:	855a                	mv	a0,s6
    80004a56:	955ff0ef          	jal	800043aa <log_report>
    memmove(to->data, from->data, BSIZE);
    80004a5a:	40000613          	li	a2,1024
    80004a5e:	05898593          	addi	a1,s3,88
    80004a62:	05848513          	addi	a0,s1,88
    80004a66:	acafc0ef          	jal	80000d30 <memmove>
    bwrite(to);
    80004a6a:	8526                	mv	a0,s1
    80004a6c:	b16fe0ef          	jal	80002d82 <bwrite>
    brelse(from);
    80004a70:	854e                	mv	a0,s3
    80004a72:	b68fe0ef          	jal	80002dda <brelse>
    brelse(to);
    80004a76:	8526                	mv	a0,s1
    80004a78:	b62fe0ef          	jal	80002dda <brelse>
  for (int tail = 0; tail < log.lh.n; tail++) {
    80004a7c:	2905                	addiw	s2,s2,1
    80004a7e:	0a91                	addi	s5,s5,4
    80004a80:	028a2783          	lw	a5,40(s4)
    80004a84:	f8f946e3          	blt	s2,a5,80004a10 <end_op+0x15c>
    80004a88:	69e6                	ld	s3,88(sp)
    80004a8a:	6a46                	ld	s4,80(sp)
    80004a8c:	6aa6                	ld	s5,72(sp)
    80004a8e:	6b06                	ld	s6,64(sp)
    80004a90:	7be2                	ld	s7,56(sp)

    write_log();
    write_head();
    80004a92:	b21ff0ef          	jal	800045b2 <write_head>

    old = log_get_state();
    80004a96:	8e9ff0ef          	jal	8000437e <log_get_state>
    80004a9a:	f8a42023          	sw	a0,-128(s0)
    80004a9e:	9101                	srli	a0,a0,0x20
    80004aa0:	f8a42223          	sw	a0,-124(s0)
    80004aa4:	f8b42423          	sw	a1,-120(s0)
    log_report("WRITE_HEAD", 0, old, "Header committed");
    80004aa8:	00004717          	auipc	a4,0x4
    80004aac:	0e070713          	addi	a4,a4,224 # 80008b88 <etext+0xb88>
    80004ab0:	f8043603          	ld	a2,-128(s0)
    80004ab4:	f8843683          	ld	a3,-120(s0)
    80004ab8:	4581                	li	a1,0
    80004aba:	00004517          	auipc	a0,0x4
    80004abe:	f2e50513          	addi	a0,a0,-210 # 800089e8 <etext+0x9e8>
    80004ac2:	8e9ff0ef          	jal	800043aa <log_report>

    install_trans(0);
    80004ac6:	4501                	li	a0,0
    80004ac8:	9c1ff0ef          	jal	80004488 <install_trans>

    old = log_get_state();
    80004acc:	8b3ff0ef          	jal	8000437e <log_get_state>
    80004ad0:	f8a42023          	sw	a0,-128(s0)
    80004ad4:	9101                	srli	a0,a0,0x20
    80004ad6:	f8a42223          	sw	a0,-124(s0)
    80004ada:	f8b42423          	sw	a1,-120(s0)
    log.lh.n = 0;
    80004ade:	0001d797          	auipc	a5,0x1d
    80004ae2:	ee07a923          	sw	zero,-270(a5) # 800219d0 <log+0x28>
    write_head();
    80004ae6:	acdff0ef          	jal	800045b2 <write_head>

    log_report("COMMIT_DONE", 0, old, "Commit done");
    80004aea:	00004717          	auipc	a4,0x4
    80004aee:	0b670713          	addi	a4,a4,182 # 80008ba0 <etext+0xba0>
    80004af2:	f8043603          	ld	a2,-128(s0)
    80004af6:	f8843683          	ld	a3,-120(s0)
    80004afa:	4581                	li	a1,0
    80004afc:	00004517          	auipc	a0,0x4
    80004b00:	0b450513          	addi	a0,a0,180 # 80008bb0 <etext+0xbb0>
    80004b04:	8a7ff0ef          	jal	800043aa <log_report>
    80004b08:	bd11                	j	8000491c <end_op+0x68>

0000000080004b0a <log_write>:
  }
}

void
log_write(struct buf *b)
{
    80004b0a:	7179                	addi	sp,sp,-48
    80004b0c:	f406                	sd	ra,40(sp)
    80004b0e:	f022                	sd	s0,32(sp)
    80004b10:	ec26                	sd	s1,24(sp)
    80004b12:	e84a                	sd	s2,16(sp)
    80004b14:	1800                	addi	s0,sp,48
    80004b16:	84aa                	mv	s1,a0
  acquire(&log.lock);
    80004b18:	0001d917          	auipc	s2,0x1d
    80004b1c:	e9090913          	addi	s2,s2,-368 # 800219a8 <log>
    80004b20:	854a                	mv	a0,s2
    80004b22:	8defc0ef          	jal	80000c00 <acquire>

  struct log_state old = log_get_state();
    80004b26:	859ff0ef          	jal	8000437e <log_get_state>
    80004b2a:	fca42823          	sw	a0,-48(s0)
    80004b2e:	02055793          	srli	a5,a0,0x20
    80004b32:	fcf42a23          	sw	a5,-44(s0)
    80004b36:	fcb42c23          	sw	a1,-40(s0)

  int i;
  for (i = 0; i < log.lh.n; i++) {
    80004b3a:	02892603          	lw	a2,40(s2)
    80004b3e:	06c05263          	blez	a2,80004ba2 <log_write+0x98>
    if (log.lh.block[i] == b->blockno)
    80004b42:	44cc                	lw	a1,12(s1)
    80004b44:	0001d717          	auipc	a4,0x1d
    80004b48:	e9070713          	addi	a4,a4,-368 # 800219d4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004b4c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)
    80004b4e:	4314                	lw	a3,0(a4)
    80004b50:	04b68a63          	beq	a3,a1,80004ba4 <log_write+0x9a>
  for (i = 0; i < log.lh.n; i++) {
    80004b54:	2785                	addiw	a5,a5,1
    80004b56:	0711                	addi	a4,a4,4
    80004b58:	fec79be3          	bne	a5,a2,80004b4e <log_write+0x44>
      break;
  }

  log.lh.block[i] = b->blockno;
    80004b5c:	0621                	addi	a2,a2,8
    80004b5e:	060a                	slli	a2,a2,0x2
    80004b60:	0001d797          	auipc	a5,0x1d
    80004b64:	e4878793          	addi	a5,a5,-440 # 800219a8 <log>
    80004b68:	97b2                	add	a5,a5,a2
    80004b6a:	44d8                	lw	a4,12(s1)
    80004b6c:	c7d8                	sw	a4,12(a5)

  if (i == log.lh.n) {
    bpin(b);
    80004b6e:	8526                	mv	a0,s1
    80004b70:	b0afe0ef          	jal	80002e7a <bpin>
    log.lh.n++;
    80004b74:	0001d717          	auipc	a4,0x1d
    80004b78:	e3470713          	addi	a4,a4,-460 # 800219a8 <log>
    80004b7c:	571c                	lw	a5,40(a4)
    80004b7e:	2785                	addiw	a5,a5,1
    80004b80:	d71c                	sw	a5,40(a4)

    log_report("LOG_WRITE", b->blockno, old, "Add block to log");
    80004b82:	00004717          	auipc	a4,0x4
    80004b86:	05e70713          	addi	a4,a4,94 # 80008be0 <etext+0xbe0>
    80004b8a:	fd043603          	ld	a2,-48(s0)
    80004b8e:	fd843683          	ld	a3,-40(s0)
    80004b92:	44cc                	lw	a1,12(s1)
    80004b94:	00004517          	auipc	a0,0x4
    80004b98:	06450513          	addi	a0,a0,100 # 80008bf8 <etext+0xbf8>
    80004b9c:	80fff0ef          	jal	800043aa <log_report>
    80004ba0:	a82d                	j	80004bda <log_write+0xd0>
  for (i = 0; i < log.lh.n; i++) {
    80004ba2:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004ba4:	00878693          	addi	a3,a5,8
    80004ba8:	068a                	slli	a3,a3,0x2
    80004baa:	0001d717          	auipc	a4,0x1d
    80004bae:	dfe70713          	addi	a4,a4,-514 # 800219a8 <log>
    80004bb2:	9736                	add	a4,a4,a3
    80004bb4:	44d4                	lw	a3,12(s1)
    80004bb6:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {
    80004bb8:	faf60be3          	beq	a2,a5,80004b6e <log_write+0x64>
  } else {
    log_report("LOG_MERGE", b->blockno, old, "Merge block");
    80004bbc:	00004717          	auipc	a4,0x4
    80004bc0:	04c70713          	addi	a4,a4,76 # 80008c08 <etext+0xc08>
    80004bc4:	fd043603          	ld	a2,-48(s0)
    80004bc8:	fd843683          	ld	a3,-40(s0)
    80004bcc:	44cc                	lw	a1,12(s1)
    80004bce:	00004517          	auipc	a0,0x4
    80004bd2:	04a50513          	addi	a0,a0,74 # 80008c18 <etext+0xc18>
    80004bd6:	fd4ff0ef          	jal	800043aa <log_report>
  }

  release(&log.lock);
    80004bda:	0001d517          	auipc	a0,0x1d
    80004bde:	dce50513          	addi	a0,a0,-562 # 800219a8 <log>
    80004be2:	8b6fc0ef          	jal	80000c98 <release>
    80004be6:	70a2                	ld	ra,40(sp)
    80004be8:	7402                	ld	s0,32(sp)
    80004bea:	64e2                	ld	s1,24(sp)
    80004bec:	6942                	ld	s2,16(sp)
    80004bee:	6145                	addi	sp,sp,48
    80004bf0:	8082                	ret

0000000080004bf2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004bf2:	1101                	addi	sp,sp,-32
    80004bf4:	ec06                	sd	ra,24(sp)
    80004bf6:	e822                	sd	s0,16(sp)
    80004bf8:	e426                	sd	s1,8(sp)
    80004bfa:	e04a                	sd	s2,0(sp)
    80004bfc:	1000                	addi	s0,sp,32
    80004bfe:	84aa                	mv	s1,a0
    80004c00:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004c02:	00004597          	auipc	a1,0x4
    80004c06:	02658593          	addi	a1,a1,38 # 80008c28 <etext+0xc28>
    80004c0a:	0521                	addi	a0,a0,8
    80004c0c:	f75fb0ef          	jal	80000b80 <initlock>
  lk->name = name;
    80004c10:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004c14:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c18:	0204a423          	sw	zero,40(s1)
}
    80004c1c:	60e2                	ld	ra,24(sp)
    80004c1e:	6442                	ld	s0,16(sp)
    80004c20:	64a2                	ld	s1,8(sp)
    80004c22:	6902                	ld	s2,0(sp)
    80004c24:	6105                	addi	sp,sp,32
    80004c26:	8082                	ret

0000000080004c28 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004c28:	1101                	addi	sp,sp,-32
    80004c2a:	ec06                	sd	ra,24(sp)
    80004c2c:	e822                	sd	s0,16(sp)
    80004c2e:	e426                	sd	s1,8(sp)
    80004c30:	e04a                	sd	s2,0(sp)
    80004c32:	1000                	addi	s0,sp,32
    80004c34:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c36:	00850913          	addi	s2,a0,8
    80004c3a:	854a                	mv	a0,s2
    80004c3c:	fc5fb0ef          	jal	80000c00 <acquire>
  while (lk->locked) {
    80004c40:	409c                	lw	a5,0(s1)
    80004c42:	c799                	beqz	a5,80004c50 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004c44:	85ca                	mv	a1,s2
    80004c46:	8526                	mv	a0,s1
    80004c48:	ad0fd0ef          	jal	80001f18 <sleep>
  while (lk->locked) {
    80004c4c:	409c                	lw	a5,0(s1)
    80004c4e:	fbfd                	bnez	a5,80004c44 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004c50:	4785                	li	a5,1
    80004c52:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004c54:	cb5fc0ef          	jal	80001908 <myproc>
    80004c58:	591c                	lw	a5,48(a0)
    80004c5a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004c5c:	854a                	mv	a0,s2
    80004c5e:	83afc0ef          	jal	80000c98 <release>
}
    80004c62:	60e2                	ld	ra,24(sp)
    80004c64:	6442                	ld	s0,16(sp)
    80004c66:	64a2                	ld	s1,8(sp)
    80004c68:	6902                	ld	s2,0(sp)
    80004c6a:	6105                	addi	sp,sp,32
    80004c6c:	8082                	ret

0000000080004c6e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004c6e:	1101                	addi	sp,sp,-32
    80004c70:	ec06                	sd	ra,24(sp)
    80004c72:	e822                	sd	s0,16(sp)
    80004c74:	e426                	sd	s1,8(sp)
    80004c76:	e04a                	sd	s2,0(sp)
    80004c78:	1000                	addi	s0,sp,32
    80004c7a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c7c:	00850913          	addi	s2,a0,8
    80004c80:	854a                	mv	a0,s2
    80004c82:	f7ffb0ef          	jal	80000c00 <acquire>
  lk->locked = 0;
    80004c86:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c8a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004c8e:	8526                	mv	a0,s1
    80004c90:	ad4fd0ef          	jal	80001f64 <wakeup>
  release(&lk->lk);
    80004c94:	854a                	mv	a0,s2
    80004c96:	802fc0ef          	jal	80000c98 <release>
}
    80004c9a:	60e2                	ld	ra,24(sp)
    80004c9c:	6442                	ld	s0,16(sp)
    80004c9e:	64a2                	ld	s1,8(sp)
    80004ca0:	6902                	ld	s2,0(sp)
    80004ca2:	6105                	addi	sp,sp,32
    80004ca4:	8082                	ret

0000000080004ca6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004ca6:	7179                	addi	sp,sp,-48
    80004ca8:	f406                	sd	ra,40(sp)
    80004caa:	f022                	sd	s0,32(sp)
    80004cac:	ec26                	sd	s1,24(sp)
    80004cae:	e84a                	sd	s2,16(sp)
    80004cb0:	1800                	addi	s0,sp,48
    80004cb2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004cb4:	00850913          	addi	s2,a0,8
    80004cb8:	854a                	mv	a0,s2
    80004cba:	f47fb0ef          	jal	80000c00 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004cbe:	409c                	lw	a5,0(s1)
    80004cc0:	ef81                	bnez	a5,80004cd8 <holdingsleep+0x32>
    80004cc2:	4481                	li	s1,0
  release(&lk->lk);
    80004cc4:	854a                	mv	a0,s2
    80004cc6:	fd3fb0ef          	jal	80000c98 <release>
  return r;
}
    80004cca:	8526                	mv	a0,s1
    80004ccc:	70a2                	ld	ra,40(sp)
    80004cce:	7402                	ld	s0,32(sp)
    80004cd0:	64e2                	ld	s1,24(sp)
    80004cd2:	6942                	ld	s2,16(sp)
    80004cd4:	6145                	addi	sp,sp,48
    80004cd6:	8082                	ret
    80004cd8:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004cda:	0284a983          	lw	s3,40(s1)
    80004cde:	c2bfc0ef          	jal	80001908 <myproc>
    80004ce2:	5904                	lw	s1,48(a0)
    80004ce4:	413484b3          	sub	s1,s1,s3
    80004ce8:	0014b493          	seqz	s1,s1
    80004cec:	69a2                	ld	s3,8(sp)
    80004cee:	bfd9                	j	80004cc4 <holdingsleep+0x1e>

0000000080004cf0 <file_report>:
    int fd,
    struct file *f,
    int old_ref,
    int old_off,
    char *details
){
    80004cf0:	cb010113          	addi	sp,sp,-848
    80004cf4:	34113423          	sd	ra,840(sp)
    80004cf8:	34813023          	sd	s0,832(sp)
    80004cfc:	32913c23          	sd	s1,824(sp)
    80004d00:	33213823          	sd	s2,816(sp)
    80004d04:	33313423          	sd	s3,808(sp)
    80004d08:	33413023          	sd	s4,800(sp)
    80004d0c:	31513c23          	sd	s5,792(sp)
    80004d10:	31613823          	sd	s6,784(sp)
    80004d14:	0e80                	addi	s0,sp,848
    80004d16:	8a2a                	mv	s4,a0
    80004d18:	89ae                	mv	s3,a1
    80004d1a:	84b2                	mv	s1,a2
    80004d1c:	8ab6                	mv	s5,a3
    80004d1e:	8b3a                	mv	s6,a4
    80004d20:	893e                	mv	s2,a5
    struct fs_event e;

    memset(&e, 0, sizeof(e));
    80004d22:	30800613          	li	a2,776
    80004d26:	4581                	li	a1,0
    80004d28:	cb840513          	addi	a0,s0,-840
    80004d2c:	fa9fb0ef          	jal	80000cd4 <memset>

    e.ticks = ticks;
    80004d30:	00004797          	auipc	a5,0x4
    80004d34:	3687a783          	lw	a5,872(a5) # 80009098 <ticks>
    80004d38:	ccf42023          	sw	a5,-832(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    80004d3c:	bcdfc0ef          	jal	80001908 <myproc>
    80004d40:	4781                	li	a5,0
    80004d42:	c501                	beqz	a0,80004d4a <file_report+0x5a>
    80004d44:	bc5fc0ef          	jal	80001908 <myproc>
    80004d48:	591c                	lw	a5,48(a0)
    80004d4a:	ccf42223          	sw	a5,-828(s0)

    e.type = LAYER_FILE;
    80004d4e:	479d                	li	a5,7
    80004d50:	ccf42423          	sw	a5,-824(s0)

    safestrcpy(e.op_name, op, sizeof(e.op_name));
    80004d54:	4641                	li	a2,16
    80004d56:	85d2                	mv	a1,s4
    80004d58:	ccc40513          	addi	a0,s0,-820
    80004d5c:	8b6fc0ef          	jal	80000e12 <safestrcpy>

    e.fd = fd;
    80004d60:	e9342023          	sw	s3,-384(s0)
    e.file_object_id = (uint64)f;
    80004d64:	f2943c23          	sd	s1,-200(s0)

    if(f){
    80004d68:	c4a1                	beqz	s1,80004db0 <file_report+0xc0>
        e.file_type = f->type;
    80004d6a:	409c                	lw	a5,0(s1)
    80004d6c:	e8f42223          	sw	a5,-380(s0)

        e.readable = f->readable;
    80004d70:	0084c783          	lbu	a5,8(s1)
    80004d74:	e8f42c23          	sw	a5,-360(s0)
        e.writable = f->writable;
    80004d78:	0094c783          	lbu	a5,9(s1)
    80004d7c:	e8f42e23          	sw	a5,-356(s0)

        e.file_ref = f->ref;
    80004d80:	40dc                	lw	a5,4(s1)
    80004d82:	eaf42023          	sw	a5,-352(s0)
        e.old_file_ref = old_ref;
    80004d86:	eb542223          	sw	s5,-348(s0)

        e.file_off = f->off;
    80004d8a:	509c                	lw	a5,32(s1)
    80004d8c:	eaf42423          	sw	a5,-344(s0)
        e.old_file_off = old_off;
    80004d90:	eb642623          	sw	s6,-340(s0)

        e.file_inum = (f->ip) ? f->ip->inum : -1;
    80004d94:	6c98                	ld	a4,24(s1)
    80004d96:	57fd                	li	a5,-1
    80004d98:	c311                	beqz	a4,80004d9c <file_report+0xac>
    80004d9a:	435c                	lw	a5,4(a4)
    80004d9c:	eaf42823          	sw	a5,-336(s0)
        safestrcpy(e.path, f->path, MAXPATH);
    80004da0:	08000613          	li	a2,128
    80004da4:	02648593          	addi	a1,s1,38
    80004da8:	de040513          	addi	a0,s0,-544
    80004dac:	866fc0ef          	jal	80000e12 <safestrcpy>
    }


    safestrcpy(e.details, details, sizeof(e.details));
    80004db0:	08000613          	li	a2,128
    80004db4:	85ca                	mv	a1,s2
    80004db6:	f4040513          	addi	a0,s0,-192
    80004dba:	858fc0ef          	jal	80000e12 <safestrcpy>

    fslog_push(&e);}
    80004dbe:	cb840513          	addi	a0,s0,-840
    80004dc2:	05a020ef          	jal	80006e1c <fslog_push>
    80004dc6:	34813083          	ld	ra,840(sp)
    80004dca:	34013403          	ld	s0,832(sp)
    80004dce:	33813483          	ld	s1,824(sp)
    80004dd2:	33013903          	ld	s2,816(sp)
    80004dd6:	32813983          	ld	s3,808(sp)
    80004dda:	32013a03          	ld	s4,800(sp)
    80004dde:	31813a83          	ld	s5,792(sp)
    80004de2:	31013b03          	ld	s6,784(sp)
    80004de6:	35010113          	addi	sp,sp,848
    80004dea:	8082                	ret

0000000080004dec <fileinit>:

void
fileinit(void)
{
    80004dec:	1141                	addi	sp,sp,-16
    80004dee:	e406                	sd	ra,8(sp)
    80004df0:	e022                	sd	s0,0(sp)
    80004df2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004df4:	00004597          	auipc	a1,0x4
    80004df8:	e4458593          	addi	a1,a1,-444 # 80008c38 <etext+0xc38>
    80004dfc:	0001d517          	auipc	a0,0x1d
    80004e00:	cf450513          	addi	a0,a0,-780 # 80021af0 <ftable>
    80004e04:	d7dfb0ef          	jal	80000b80 <initlock>
}
    80004e08:	60a2                	ld	ra,8(sp)
    80004e0a:	6402                	ld	s0,0(sp)
    80004e0c:	0141                	addi	sp,sp,16
    80004e0e:	8082                	ret

0000000080004e10 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004e10:	1101                	addi	sp,sp,-32
    80004e12:	ec06                	sd	ra,24(sp)
    80004e14:	e822                	sd	s0,16(sp)
    80004e16:	e426                	sd	s1,8(sp)
    80004e18:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004e1a:	0001d517          	auipc	a0,0x1d
    80004e1e:	cd650513          	addi	a0,a0,-810 # 80021af0 <ftable>
    80004e22:	ddffb0ef          	jal	80000c00 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e26:	0001d497          	auipc	s1,0x1d
    80004e2a:	ce248493          	addi	s1,s1,-798 # 80021b08 <ftable+0x18>
    80004e2e:	00021717          	auipc	a4,0x21
    80004e32:	e7a70713          	addi	a4,a4,-390 # 80025ca8 <disk>
    if(f->ref == 0){
    80004e36:	40dc                	lw	a5,4(s1)
    80004e38:	cf89                	beqz	a5,80004e52 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e3a:	0a848493          	addi	s1,s1,168
    80004e3e:	fee49ce3          	bne	s1,a4,80004e36 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004e42:	0001d517          	auipc	a0,0x1d
    80004e46:	cae50513          	addi	a0,a0,-850 # 80021af0 <ftable>
    80004e4a:	e4ffb0ef          	jal	80000c98 <release>
  return 0;
    80004e4e:	4481                	li	s1,0
    80004e50:	a809                	j	80004e62 <filealloc+0x52>
      f->ref = 1;
    80004e52:	4785                	li	a5,1
    80004e54:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004e56:	0001d517          	auipc	a0,0x1d
    80004e5a:	c9a50513          	addi	a0,a0,-870 # 80021af0 <ftable>
    80004e5e:	e3bfb0ef          	jal	80000c98 <release>
}
    80004e62:	8526                	mv	a0,s1
    80004e64:	60e2                	ld	ra,24(sp)
    80004e66:	6442                	ld	s0,16(sp)
    80004e68:	64a2                	ld	s1,8(sp)
    80004e6a:	6105                	addi	sp,sp,32
    80004e6c:	8082                	ret

0000000080004e6e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004e6e:	1101                	addi	sp,sp,-32
    80004e70:	ec06                	sd	ra,24(sp)
    80004e72:	e822                	sd	s0,16(sp)
    80004e74:	e426                	sd	s1,8(sp)
    80004e76:	1000                	addi	s0,sp,32
    80004e78:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004e7a:	0001d517          	auipc	a0,0x1d
    80004e7e:	c7650513          	addi	a0,a0,-906 # 80021af0 <ftable>
    80004e82:	d7ffb0ef          	jal	80000c00 <acquire>
  if(f->ref < 1)
    80004e86:	40d4                	lw	a3,4(s1)
    80004e88:	02d05e63          	blez	a3,80004ec4 <filedup+0x56>
    panic("filedup");
  int old_ref = f->ref;
  f->ref++;
    80004e8c:	0016879b          	addiw	a5,a3,1
    80004e90:	c0dc                	sw	a5,4(s1)
  
  file_report(
    80004e92:	00004797          	auipc	a5,0x4
    80004e96:	db678793          	addi	a5,a5,-586 # 80008c48 <etext+0xc48>
    80004e9a:	5098                	lw	a4,32(s1)
    80004e9c:	8626                	mv	a2,s1
    80004e9e:	55fd                	li	a1,-1
    80004ea0:	00004517          	auipc	a0,0x4
    80004ea4:	dc850513          	addi	a0,a0,-568 # 80008c68 <etext+0xc68>
    80004ea8:	e49ff0ef          	jal	80004cf0 <file_report>
    f,
    old_ref,
    f->off,
    "Duplicated file reference"
  );
  release(&ftable.lock);
    80004eac:	0001d517          	auipc	a0,0x1d
    80004eb0:	c4450513          	addi	a0,a0,-956 # 80021af0 <ftable>
    80004eb4:	de5fb0ef          	jal	80000c98 <release>
  return f;
}
    80004eb8:	8526                	mv	a0,s1
    80004eba:	60e2                	ld	ra,24(sp)
    80004ebc:	6442                	ld	s0,16(sp)
    80004ebe:	64a2                	ld	s1,8(sp)
    80004ec0:	6105                	addi	sp,sp,32
    80004ec2:	8082                	ret
    panic("filedup");
    80004ec4:	00004517          	auipc	a0,0x4
    80004ec8:	d7c50513          	addi	a0,a0,-644 # 80008c40 <etext+0xc40>
    80004ecc:	947fb0ef          	jal	80000812 <panic>

0000000080004ed0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004ed0:	7139                	addi	sp,sp,-64
    80004ed2:	fc06                	sd	ra,56(sp)
    80004ed4:	f822                	sd	s0,48(sp)
    80004ed6:	f426                	sd	s1,40(sp)
    80004ed8:	0080                	addi	s0,sp,64
    80004eda:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004edc:	0001d517          	auipc	a0,0x1d
    80004ee0:	c1450513          	addi	a0,a0,-1004 # 80021af0 <ftable>
    80004ee4:	d1dfb0ef          	jal	80000c00 <acquire>
  if(f->ref < 1)
    80004ee8:	40d4                	lw	a3,4(s1)
    80004eea:	06d05963          	blez	a3,80004f5c <fileclose+0x8c>
    panic("fileclose");
  int old_ref = f->ref;
  int old_off = f->off;
    80004eee:	5098                	lw	a4,32(s1)
  
  
  if(--f->ref > 0){
    80004ef0:	fff6879b          	addiw	a5,a3,-1
    80004ef4:	0007861b          	sext.w	a2,a5
    80004ef8:	c0dc                	sw	a5,4(s1)
    80004efa:	06c04b63          	bgtz	a2,80004f70 <fileclose+0xa0>
    80004efe:	f04a                	sd	s2,32(sp)
    80004f00:	ec4e                	sd	s3,24(sp)
    80004f02:	e852                	sd	s4,16(sp)
    80004f04:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  
  // في حال رغبنا بالتقرير عند الإغلاق النهائي والتصفير:
  file_report(
    80004f06:	00004797          	auipc	a5,0x4
    80004f0a:	da278793          	addi	a5,a5,-606 # 80008ca8 <etext+0xca8>
    80004f0e:	4685                	li	a3,1
    80004f10:	8626                	mv	a2,s1
    80004f12:	55fd                	li	a1,-1
    80004f14:	00004517          	auipc	a0,0x4
    80004f18:	db450513          	addi	a0,a0,-588 # 80008cc8 <etext+0xcc8>
    80004f1c:	dd5ff0ef          	jal	80004cf0 <file_report>
    old_ref,
    old_off,
    "File structure fully freed"
  );

  ff = *f;
    80004f20:	0004a903          	lw	s2,0(s1)
    80004f24:	0094ca83          	lbu	s5,9(s1)
    80004f28:	0104ba03          	ld	s4,16(s1)
    80004f2c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004f30:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004f34:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004f38:	0001d517          	auipc	a0,0x1d
    80004f3c:	bb850513          	addi	a0,a0,-1096 # 80021af0 <ftable>
    80004f40:	d59fb0ef          	jal	80000c98 <release>

  if(ff.type == FD_PIPE){
    80004f44:	4785                	li	a5,1
    80004f46:	04f90c63          	beq	s2,a5,80004f9e <fileclose+0xce>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004f4a:	3979                	addiw	s2,s2,-2
    80004f4c:	4785                	li	a5,1
    80004f4e:	0727f163          	bgeu	a5,s2,80004fb0 <fileclose+0xe0>
    80004f52:	7902                	ld	s2,32(sp)
    80004f54:	69e2                	ld	s3,24(sp)
    80004f56:	6a42                	ld	s4,16(sp)
    80004f58:	6aa2                	ld	s5,8(sp)
    80004f5a:	a82d                	j	80004f94 <fileclose+0xc4>
    80004f5c:	f04a                	sd	s2,32(sp)
    80004f5e:	ec4e                	sd	s3,24(sp)
    80004f60:	e852                	sd	s4,16(sp)
    80004f62:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004f64:	00004517          	auipc	a0,0x4
    80004f68:	d0c50513          	addi	a0,a0,-756 # 80008c70 <etext+0xc70>
    80004f6c:	8a7fb0ef          	jal	80000812 <panic>
    file_report(
    80004f70:	00004797          	auipc	a5,0x4
    80004f74:	d1078793          	addi	a5,a5,-752 # 80008c80 <etext+0xc80>
    80004f78:	8626                	mv	a2,s1
    80004f7a:	55fd                	li	a1,-1
    80004f7c:	00004517          	auipc	a0,0x4
    80004f80:	d1c50513          	addi	a0,a0,-740 # 80008c98 <etext+0xc98>
    80004f84:	d6dff0ef          	jal	80004cf0 <file_report>
    release(&ftable.lock);
    80004f88:	0001d517          	auipc	a0,0x1d
    80004f8c:	b6850513          	addi	a0,a0,-1176 # 80021af0 <ftable>
    80004f90:	d09fb0ef          	jal	80000c98 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004f94:	70e2                	ld	ra,56(sp)
    80004f96:	7442                	ld	s0,48(sp)
    80004f98:	74a2                	ld	s1,40(sp)
    80004f9a:	6121                	addi	sp,sp,64
    80004f9c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004f9e:	85d6                	mv	a1,s5
    80004fa0:	8552                	mv	a0,s4
    80004fa2:	3ac000ef          	jal	8000534e <pipeclose>
    80004fa6:	7902                	ld	s2,32(sp)
    80004fa8:	69e2                	ld	s3,24(sp)
    80004faa:	6a42                	ld	s4,16(sp)
    80004fac:	6aa2                	ld	s5,8(sp)
    80004fae:	b7dd                	j	80004f94 <fileclose+0xc4>
    begin_op();
    80004fb0:	fe6ff0ef          	jal	80004796 <begin_op>
    iput(ff.ip);
    80004fb4:	854e                	mv	a0,s3
    80004fb6:	b43fe0ef          	jal	80003af8 <iput>
    end_op();
    80004fba:	8fbff0ef          	jal	800048b4 <end_op>
    80004fbe:	7902                	ld	s2,32(sp)
    80004fc0:	69e2                	ld	s3,24(sp)
    80004fc2:	6a42                	ld	s4,16(sp)
    80004fc4:	6aa2                	ld	s5,8(sp)
    80004fc6:	b7f9                	j	80004f94 <fileclose+0xc4>

0000000080004fc8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004fc8:	715d                	addi	sp,sp,-80
    80004fca:	e486                	sd	ra,72(sp)
    80004fcc:	e0a2                	sd	s0,64(sp)
    80004fce:	fc26                	sd	s1,56(sp)
    80004fd0:	f44e                	sd	s3,40(sp)
    80004fd2:	0880                	addi	s0,sp,80
    80004fd4:	84aa                	mv	s1,a0
    80004fd6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004fd8:	931fc0ef          	jal	80001908 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004fdc:	409c                	lw	a5,0(s1)
    80004fde:	37f9                	addiw	a5,a5,-2
    80004fe0:	4705                	li	a4,1
    80004fe2:	04f76063          	bltu	a4,a5,80005022 <filestat+0x5a>
    80004fe6:	f84a                	sd	s2,48(sp)
    80004fe8:	892a                	mv	s2,a0
    ilock(f->ip);
    80004fea:	6c88                	ld	a0,24(s1)
    80004fec:	8fdfe0ef          	jal	800038e8 <ilock>
    stati(f->ip, &st);
    80004ff0:	fb840593          	addi	a1,s0,-72
    80004ff4:	6c88                	ld	a0,24(s1)
    80004ff6:	d2bfe0ef          	jal	80003d20 <stati>
    iunlock(f->ip);
    80004ffa:	6c88                	ld	a0,24(s1)
    80004ffc:	9dffe0ef          	jal	800039da <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005000:	46e1                	li	a3,24
    80005002:	fb840613          	addi	a2,s0,-72
    80005006:	85ce                	mv	a1,s3
    80005008:	05093503          	ld	a0,80(s2)
    8000500c:	e10fc0ef          	jal	8000161c <copyout>
    80005010:	41f5551b          	sraiw	a0,a0,0x1f
    80005014:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80005016:	60a6                	ld	ra,72(sp)
    80005018:	6406                	ld	s0,64(sp)
    8000501a:	74e2                	ld	s1,56(sp)
    8000501c:	79a2                	ld	s3,40(sp)
    8000501e:	6161                	addi	sp,sp,80
    80005020:	8082                	ret
  return -1;
    80005022:	557d                	li	a0,-1
    80005024:	bfcd                	j	80005016 <filestat+0x4e>

0000000080005026 <fileread>:

// Read from file f.
// addr is a user virtual address.

int fileread(struct file *f, int fd, uint64 addr, int n)
{
    80005026:	7139                	addi	sp,sp,-64
    80005028:	fc06                	sd	ra,56(sp)
    8000502a:	f822                	sd	s0,48(sp)
    8000502c:	f04a                	sd	s2,32(sp)
    8000502e:	0080                	addi	s0,sp,64
  int r = 0;

  if(f->readable == 0)
    80005030:	00854783          	lbu	a5,8(a0)
    80005034:	cbe9                	beqz	a5,80005106 <fileread+0xe0>
    80005036:	f426                	sd	s1,40(sp)
    80005038:	ec4e                	sd	s3,24(sp)
    8000503a:	e852                	sd	s4,16(sp)
    8000503c:	84aa                	mv	s1,a0
    8000503e:	8a2e                	mv	s4,a1
    80005040:	89b2                	mv	s3,a2
    80005042:	8936                	mv	s2,a3
    return -1;

  if(f->type == FD_PIPE){
    80005044:	411c                	lw	a5,0(a0)
    80005046:	4705                	li	a4,1
    80005048:	06e78663          	beq	a5,a4,800050b4 <fileread+0x8e>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000504c:	470d                	li	a4,3
    8000504e:	06e78d63          	beq	a5,a4,800050c8 <fileread+0xa2>
    80005052:	e456                	sd	s5,8(sp)
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005054:	4709                	li	a4,2
    80005056:	0ae79263          	bne	a5,a4,800050fa <fileread+0xd4>
    ilock(f->ip);
    8000505a:	6d08                	ld	a0,24(a0)
    8000505c:	88dfe0ef          	jal	800038e8 <ilock>
    int old_off = f->off;
    80005060:	5094                	lw	a3,32(s1)
    80005062:	00068a9b          	sext.w	s5,a3

    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005066:	874a                	mv	a4,s2
    80005068:	864e                	mv	a2,s3
    8000506a:	4585                	li	a1,1
    8000506c:	6c88                	ld	a0,24(s1)
    8000506e:	cddfe0ef          	jal	80003d4a <readi>
    80005072:	892a                	mv	s2,a0
    80005074:	00a05563          	blez	a0,8000507e <fileread+0x58>
   
   { f->off += r;}
    80005078:	509c                	lw	a5,32(s1)
    8000507a:	9fa9                	addw	a5,a5,a0
    8000507c:	d09c                	sw	a5,32(s1)
    file_report(
    8000507e:	00004797          	auipc	a5,0x4
    80005082:	c5a78793          	addi	a5,a5,-934 # 80008cd8 <etext+0xcd8>
    80005086:	8756                	mv	a4,s5
    80005088:	40d4                	lw	a3,4(s1)
    8000508a:	8626                	mv	a2,s1
    8000508c:	85d2                	mv	a1,s4
    8000508e:	00004517          	auipc	a0,0x4
    80005092:	c5a50513          	addi	a0,a0,-934 # 80008ce8 <etext+0xce8>
    80005096:	c5bff0ef          	jal	80004cf0 <file_report>
    f,
    f->ref,
    old_off,
    "Read from file"
);
    iunlock(f->ip);
    8000509a:	6c88                	ld	a0,24(s1)
    8000509c:	93ffe0ef          	jal	800039da <iunlock>
    800050a0:	74a2                	ld	s1,40(sp)
    800050a2:	69e2                	ld	s3,24(sp)
    800050a4:	6a42                	ld	s4,16(sp)
    800050a6:	6aa2                	ld	s5,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800050a8:	854a                	mv	a0,s2
    800050aa:	70e2                	ld	ra,56(sp)
    800050ac:	7442                	ld	s0,48(sp)
    800050ae:	7902                	ld	s2,32(sp)
    800050b0:	6121                	addi	sp,sp,64
    800050b2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800050b4:	8636                	mv	a2,a3
    800050b6:	85ce                	mv	a1,s3
    800050b8:	6908                	ld	a0,16(a0)
    800050ba:	3d0000ef          	jal	8000548a <piperead>
    800050be:	892a                	mv	s2,a0
    800050c0:	74a2                	ld	s1,40(sp)
    800050c2:	69e2                	ld	s3,24(sp)
    800050c4:	6a42                	ld	s4,16(sp)
    800050c6:	b7cd                	j	800050a8 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800050c8:	02451783          	lh	a5,36(a0)
    800050cc:	03079693          	slli	a3,a5,0x30
    800050d0:	92c1                	srli	a3,a3,0x30
    800050d2:	4725                	li	a4,9
    800050d4:	02d76b63          	bltu	a4,a3,8000510a <fileread+0xe4>
    800050d8:	0792                	slli	a5,a5,0x4
    800050da:	0001d717          	auipc	a4,0x1d
    800050de:	97670713          	addi	a4,a4,-1674 # 80021a50 <devsw>
    800050e2:	97ba                	add	a5,a5,a4
    800050e4:	639c                	ld	a5,0(a5)
    800050e6:	c79d                	beqz	a5,80005114 <fileread+0xee>
    r = devsw[f->major].read(1, addr, n);
    800050e8:	864a                	mv	a2,s2
    800050ea:	85ce                	mv	a1,s3
    800050ec:	4505                	li	a0,1
    800050ee:	9782                	jalr	a5
    800050f0:	892a                	mv	s2,a0
    800050f2:	74a2                	ld	s1,40(sp)
    800050f4:	69e2                	ld	s3,24(sp)
    800050f6:	6a42                	ld	s4,16(sp)
    800050f8:	bf45                	j	800050a8 <fileread+0x82>
    panic("fileread");
    800050fa:	00004517          	auipc	a0,0x4
    800050fe:	bfe50513          	addi	a0,a0,-1026 # 80008cf8 <etext+0xcf8>
    80005102:	f10fb0ef          	jal	80000812 <panic>
    return -1;
    80005106:	597d                	li	s2,-1
    80005108:	b745                	j	800050a8 <fileread+0x82>
      return -1;
    8000510a:	597d                	li	s2,-1
    8000510c:	74a2                	ld	s1,40(sp)
    8000510e:	69e2                	ld	s3,24(sp)
    80005110:	6a42                	ld	s4,16(sp)
    80005112:	bf59                	j	800050a8 <fileread+0x82>
    80005114:	597d                	li	s2,-1
    80005116:	74a2                	ld	s1,40(sp)
    80005118:	69e2                	ld	s3,24(sp)
    8000511a:	6a42                	ld	s4,16(sp)
    8000511c:	b771                	j	800050a8 <fileread+0x82>

000000008000511e <filewrite>:

int filewrite(struct file *f, int fd, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000511e:	00954783          	lbu	a5,9(a0)
    80005122:	14078963          	beqz	a5,80005274 <filewrite+0x156>
{
    80005126:	7119                	addi	sp,sp,-128
    80005128:	fc86                	sd	ra,120(sp)
    8000512a:	f8a2                	sd	s0,112(sp)
    8000512c:	f4a6                	sd	s1,104(sp)
    8000512e:	e8d2                	sd	s4,80(sp)
    80005130:	fc5e                	sd	s7,56(sp)
    80005132:	f862                	sd	s8,48(sp)
    80005134:	0100                	addi	s0,sp,128
    80005136:	84aa                	mv	s1,a0
    80005138:	8c2e                	mv	s8,a1
    8000513a:	8bb2                	mv	s7,a2
    8000513c:	8a36                	mv	s4,a3
    return -1;

  if(f->type == FD_PIPE){
    8000513e:	411c                	lw	a5,0(a0)
    80005140:	4705                	li	a4,1
    80005142:	04e78363          	beq	a5,a4,80005188 <filewrite+0x6a>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005146:	470d                	li	a4,3
    80005148:	04e78663          	beq	a5,a4,80005194 <filewrite+0x76>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000514c:	4709                	li	a4,2
    8000514e:	10e79663          	bne	a5,a4,8000525a <filewrite+0x13c>
    80005152:	ecce                	sd	s3,88(sp)
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    int old_off;
    while(i < n){
    80005154:	0cd05f63          	blez	a3,80005232 <filewrite+0x114>
    80005158:	f0ca                	sd	s2,96(sp)
    8000515a:	e4d6                	sd	s5,72(sp)
    8000515c:	e0da                	sd	s6,64(sp)
    8000515e:	f466                	sd	s9,40(sp)
    80005160:	f06a                	sd	s10,32(sp)
    80005162:	ec6e                	sd	s11,24(sp)
    int i = 0;
    80005164:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80005166:	6c85                	lui	s9,0x1
    80005168:	c00c8c93          	addi	s9,s9,-1024 # c00 <_entry-0x7ffff400>
    8000516c:	6785                	lui	a5,0x1
    8000516e:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80005172:	f8f42623          	sw	a5,-116(s0)
      begin_op();
      ilock(f->ip);
      old_off = f->off;
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
        f->off += r;
      file_report(
    80005176:	00004d97          	auipc	s11,0x4
    8000517a:	b92d8d93          	addi	s11,s11,-1134 # 80008d08 <etext+0xd08>
    8000517e:	00004d17          	auipc	s10,0x4
    80005182:	b9ad0d13          	addi	s10,s10,-1126 # 80008d18 <etext+0xd18>
    80005186:	a071                	j	80005212 <filewrite+0xf4>
    ret = pipewrite(f->pipe, addr, n);
    80005188:	8636                	mv	a2,a3
    8000518a:	85de                	mv	a1,s7
    8000518c:	6908                	ld	a0,16(a0)
    8000518e:	218000ef          	jal	800053a6 <pipewrite>
    80005192:	a865                	j	8000524a <filewrite+0x12c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005194:	02451783          	lh	a5,36(a0)
    80005198:	03079693          	slli	a3,a5,0x30
    8000519c:	92c1                	srli	a3,a3,0x30
    8000519e:	4725                	li	a4,9
    800051a0:	0cd76c63          	bltu	a4,a3,80005278 <filewrite+0x15a>
    800051a4:	0792                	slli	a5,a5,0x4
    800051a6:	0001d717          	auipc	a4,0x1d
    800051aa:	8aa70713          	addi	a4,a4,-1878 # 80021a50 <devsw>
    800051ae:	97ba                	add	a5,a5,a4
    800051b0:	679c                	ld	a5,8(a5)
    800051b2:	c7e9                	beqz	a5,8000527c <filewrite+0x15e>
    ret = devsw[f->major].write(1, addr, n);
    800051b4:	8652                	mv	a2,s4
    800051b6:	85de                	mv	a1,s7
    800051b8:	4505                	li	a0,1
    800051ba:	9782                	jalr	a5
    800051bc:	a079                	j	8000524a <filewrite+0x12c>
      if(n1 > max)
    800051be:	00090a9b          	sext.w	s5,s2
      begin_op();
    800051c2:	dd4ff0ef          	jal	80004796 <begin_op>
      ilock(f->ip);
    800051c6:	6c88                	ld	a0,24(s1)
    800051c8:	f20fe0ef          	jal	800038e8 <ilock>
      old_off = f->off;
    800051cc:	5094                	lw	a3,32(s1)
    800051ce:	00068b1b          	sext.w	s6,a3
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800051d2:	8756                	mv	a4,s5
    800051d4:	01798633          	add	a2,s3,s7
    800051d8:	4585                	li	a1,1
    800051da:	6c88                	ld	a0,24(s1)
    800051dc:	c9ffe0ef          	jal	80003e7a <writei>
    800051e0:	892a                	mv	s2,a0
    800051e2:	00a05563          	blez	a0,800051ec <filewrite+0xce>
        f->off += r;
    800051e6:	509c                	lw	a5,32(s1)
    800051e8:	9fa9                	addw	a5,a5,a0
    800051ea:	d09c                	sw	a5,32(s1)
      file_report(
    800051ec:	87ee                	mv	a5,s11
    800051ee:	875a                	mv	a4,s6
    800051f0:	40d4                	lw	a3,4(s1)
    800051f2:	8626                	mv	a2,s1
    800051f4:	85e2                	mv	a1,s8
    800051f6:	856a                	mv	a0,s10
    800051f8:	af9ff0ef          	jal	80004cf0 <file_report>
    f,
    f->ref,
    old_off,
    "Write to file"
);
      iunlock(f->ip);
    800051fc:	6c88                	ld	a0,24(s1)
    800051fe:	fdcfe0ef          	jal	800039da <iunlock>
      end_op();
    80005202:	eb2ff0ef          	jal	800048b4 <end_op>

      if(r != n1){
    80005206:	032a9863          	bne	s5,s2,80005236 <filewrite+0x118>
        // error from writei
        break;
      }
      i += r;
    8000520a:	013909bb          	addw	s3,s2,s3
    while(i < n){
    8000520e:	0149db63          	bge	s3,s4,80005224 <filewrite+0x106>
      int n1 = n - i;
    80005212:	413a093b          	subw	s2,s4,s3
      if(n1 > max)
    80005216:	0009079b          	sext.w	a5,s2
    8000521a:	fafcd2e3          	bge	s9,a5,800051be <filewrite+0xa0>
    8000521e:	f8c42903          	lw	s2,-116(s0)
    80005222:	bf71                	j	800051be <filewrite+0xa0>
    80005224:	7906                	ld	s2,96(sp)
    80005226:	6aa6                	ld	s5,72(sp)
    80005228:	6b06                	ld	s6,64(sp)
    8000522a:	7ca2                	ld	s9,40(sp)
    8000522c:	7d02                	ld	s10,32(sp)
    8000522e:	6de2                	ld	s11,24(sp)
    80005230:	a809                	j	80005242 <filewrite+0x124>
    int i = 0;
    80005232:	4981                	li	s3,0
    80005234:	a039                	j	80005242 <filewrite+0x124>
    80005236:	7906                	ld	s2,96(sp)
    80005238:	6aa6                	ld	s5,72(sp)
    8000523a:	6b06                	ld	s6,64(sp)
    8000523c:	7ca2                	ld	s9,40(sp)
    8000523e:	7d02                	ld	s10,32(sp)
    80005240:	6de2                	ld	s11,24(sp)
    }
    ret = (i == n ? n : -1);
    80005242:	033a1f63          	bne	s4,s3,80005280 <filewrite+0x162>
    80005246:	8552                	mv	a0,s4
    80005248:	69e6                	ld	s3,88(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000524a:	70e6                	ld	ra,120(sp)
    8000524c:	7446                	ld	s0,112(sp)
    8000524e:	74a6                	ld	s1,104(sp)
    80005250:	6a46                	ld	s4,80(sp)
    80005252:	7be2                	ld	s7,56(sp)
    80005254:	7c42                	ld	s8,48(sp)
    80005256:	6109                	addi	sp,sp,128
    80005258:	8082                	ret
    8000525a:	f0ca                	sd	s2,96(sp)
    8000525c:	ecce                	sd	s3,88(sp)
    8000525e:	e4d6                	sd	s5,72(sp)
    80005260:	e0da                	sd	s6,64(sp)
    80005262:	f466                	sd	s9,40(sp)
    80005264:	f06a                	sd	s10,32(sp)
    80005266:	ec6e                	sd	s11,24(sp)
    panic("filewrite");
    80005268:	00004517          	auipc	a0,0x4
    8000526c:	ac050513          	addi	a0,a0,-1344 # 80008d28 <etext+0xd28>
    80005270:	da2fb0ef          	jal	80000812 <panic>
    return -1;
    80005274:	557d                	li	a0,-1
}
    80005276:	8082                	ret
      return -1;
    80005278:	557d                	li	a0,-1
    8000527a:	bfc1                	j	8000524a <filewrite+0x12c>
    8000527c:	557d                	li	a0,-1
    8000527e:	b7f1                	j	8000524a <filewrite+0x12c>
    ret = (i == n ? n : -1);
    80005280:	557d                	li	a0,-1
    80005282:	69e6                	ld	s3,88(sp)
    80005284:	b7d9                	j	8000524a <filewrite+0x12c>

0000000080005286 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005286:	7179                	addi	sp,sp,-48
    80005288:	f406                	sd	ra,40(sp)
    8000528a:	f022                	sd	s0,32(sp)
    8000528c:	ec26                	sd	s1,24(sp)
    8000528e:	e052                	sd	s4,0(sp)
    80005290:	1800                	addi	s0,sp,48
    80005292:	84aa                	mv	s1,a0
    80005294:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005296:	0005b023          	sd	zero,0(a1)
    8000529a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000529e:	b73ff0ef          	jal	80004e10 <filealloc>
    800052a2:	e088                	sd	a0,0(s1)
    800052a4:	c549                	beqz	a0,8000532e <pipealloc+0xa8>
    800052a6:	b6bff0ef          	jal	80004e10 <filealloc>
    800052aa:	00aa3023          	sd	a0,0(s4)
    800052ae:	cd25                	beqz	a0,80005326 <pipealloc+0xa0>
    800052b0:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800052b2:	87ffb0ef          	jal	80000b30 <kalloc>
    800052b6:	892a                	mv	s2,a0
    800052b8:	c12d                	beqz	a0,8000531a <pipealloc+0x94>
    800052ba:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800052bc:	4985                	li	s3,1
    800052be:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800052c2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800052c6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800052ca:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800052ce:	00004597          	auipc	a1,0x4
    800052d2:	a6a58593          	addi	a1,a1,-1430 # 80008d38 <etext+0xd38>
    800052d6:	8abfb0ef          	jal	80000b80 <initlock>
  (*f0)->type = FD_PIPE;
    800052da:	609c                	ld	a5,0(s1)
    800052dc:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800052e0:	609c                	ld	a5,0(s1)
    800052e2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800052e6:	609c                	ld	a5,0(s1)
    800052e8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800052ec:	609c                	ld	a5,0(s1)
    800052ee:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800052f2:	000a3783          	ld	a5,0(s4)
    800052f6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800052fa:	000a3783          	ld	a5,0(s4)
    800052fe:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005302:	000a3783          	ld	a5,0(s4)
    80005306:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000530a:	000a3783          	ld	a5,0(s4)
    8000530e:	0127b823          	sd	s2,16(a5)
  return 0;
    80005312:	4501                	li	a0,0
    80005314:	6942                	ld	s2,16(sp)
    80005316:	69a2                	ld	s3,8(sp)
    80005318:	a01d                	j	8000533e <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000531a:	6088                	ld	a0,0(s1)
    8000531c:	c119                	beqz	a0,80005322 <pipealloc+0x9c>
    8000531e:	6942                	ld	s2,16(sp)
    80005320:	a029                	j	8000532a <pipealloc+0xa4>
    80005322:	6942                	ld	s2,16(sp)
    80005324:	a029                	j	8000532e <pipealloc+0xa8>
    80005326:	6088                	ld	a0,0(s1)
    80005328:	c10d                	beqz	a0,8000534a <pipealloc+0xc4>
    fileclose(*f0);
    8000532a:	ba7ff0ef          	jal	80004ed0 <fileclose>
  if(*f1)
    8000532e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005332:	557d                	li	a0,-1
  if(*f1)
    80005334:	c789                	beqz	a5,8000533e <pipealloc+0xb8>
    fileclose(*f1);
    80005336:	853e                	mv	a0,a5
    80005338:	b99ff0ef          	jal	80004ed0 <fileclose>
  return -1;
    8000533c:	557d                	li	a0,-1
}
    8000533e:	70a2                	ld	ra,40(sp)
    80005340:	7402                	ld	s0,32(sp)
    80005342:	64e2                	ld	s1,24(sp)
    80005344:	6a02                	ld	s4,0(sp)
    80005346:	6145                	addi	sp,sp,48
    80005348:	8082                	ret
  return -1;
    8000534a:	557d                	li	a0,-1
    8000534c:	bfcd                	j	8000533e <pipealloc+0xb8>

000000008000534e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000534e:	1101                	addi	sp,sp,-32
    80005350:	ec06                	sd	ra,24(sp)
    80005352:	e822                	sd	s0,16(sp)
    80005354:	e426                	sd	s1,8(sp)
    80005356:	e04a                	sd	s2,0(sp)
    80005358:	1000                	addi	s0,sp,32
    8000535a:	84aa                	mv	s1,a0
    8000535c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000535e:	8a3fb0ef          	jal	80000c00 <acquire>
  if(writable){
    80005362:	02090763          	beqz	s2,80005390 <pipeclose+0x42>
    pi->writeopen = 0;
    80005366:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000536a:	21848513          	addi	a0,s1,536
    8000536e:	bf7fc0ef          	jal	80001f64 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005372:	2204b783          	ld	a5,544(s1)
    80005376:	e785                	bnez	a5,8000539e <pipeclose+0x50>
    release(&pi->lock);
    80005378:	8526                	mv	a0,s1
    8000537a:	91ffb0ef          	jal	80000c98 <release>
    kfree((char*)pi);
    8000537e:	8526                	mv	a0,s1
    80005380:	ecefb0ef          	jal	80000a4e <kfree>
  } else
    release(&pi->lock);
}
    80005384:	60e2                	ld	ra,24(sp)
    80005386:	6442                	ld	s0,16(sp)
    80005388:	64a2                	ld	s1,8(sp)
    8000538a:	6902                	ld	s2,0(sp)
    8000538c:	6105                	addi	sp,sp,32
    8000538e:	8082                	ret
    pi->readopen = 0;
    80005390:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005394:	21c48513          	addi	a0,s1,540
    80005398:	bcdfc0ef          	jal	80001f64 <wakeup>
    8000539c:	bfd9                	j	80005372 <pipeclose+0x24>
    release(&pi->lock);
    8000539e:	8526                	mv	a0,s1
    800053a0:	8f9fb0ef          	jal	80000c98 <release>
}
    800053a4:	b7c5                	j	80005384 <pipeclose+0x36>

00000000800053a6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800053a6:	711d                	addi	sp,sp,-96
    800053a8:	ec86                	sd	ra,88(sp)
    800053aa:	e8a2                	sd	s0,80(sp)
    800053ac:	e4a6                	sd	s1,72(sp)
    800053ae:	e0ca                	sd	s2,64(sp)
    800053b0:	fc4e                	sd	s3,56(sp)
    800053b2:	f852                	sd	s4,48(sp)
    800053b4:	f456                	sd	s5,40(sp)
    800053b6:	1080                	addi	s0,sp,96
    800053b8:	84aa                	mv	s1,a0
    800053ba:	8aae                	mv	s5,a1
    800053bc:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800053be:	d4afc0ef          	jal	80001908 <myproc>
    800053c2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800053c4:	8526                	mv	a0,s1
    800053c6:	83bfb0ef          	jal	80000c00 <acquire>
  while(i < n){
    800053ca:	0b405a63          	blez	s4,8000547e <pipewrite+0xd8>
    800053ce:	f05a                	sd	s6,32(sp)
    800053d0:	ec5e                	sd	s7,24(sp)
    800053d2:	e862                	sd	s8,16(sp)
  int i = 0;
    800053d4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800053d6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800053d8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800053dc:	21c48b93          	addi	s7,s1,540
    800053e0:	a81d                	j	80005416 <pipewrite+0x70>
      release(&pi->lock);
    800053e2:	8526                	mv	a0,s1
    800053e4:	8b5fb0ef          	jal	80000c98 <release>
      return -1;
    800053e8:	597d                	li	s2,-1
    800053ea:	7b02                	ld	s6,32(sp)
    800053ec:	6be2                	ld	s7,24(sp)
    800053ee:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800053f0:	854a                	mv	a0,s2
    800053f2:	60e6                	ld	ra,88(sp)
    800053f4:	6446                	ld	s0,80(sp)
    800053f6:	64a6                	ld	s1,72(sp)
    800053f8:	6906                	ld	s2,64(sp)
    800053fa:	79e2                	ld	s3,56(sp)
    800053fc:	7a42                	ld	s4,48(sp)
    800053fe:	7aa2                	ld	s5,40(sp)
    80005400:	6125                	addi	sp,sp,96
    80005402:	8082                	ret
      wakeup(&pi->nread);
    80005404:	8562                	mv	a0,s8
    80005406:	b5ffc0ef          	jal	80001f64 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000540a:	85a6                	mv	a1,s1
    8000540c:	855e                	mv	a0,s7
    8000540e:	b0bfc0ef          	jal	80001f18 <sleep>
  while(i < n){
    80005412:	05495b63          	bge	s2,s4,80005468 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80005416:	2204a783          	lw	a5,544(s1)
    8000541a:	d7e1                	beqz	a5,800053e2 <pipewrite+0x3c>
    8000541c:	854e                	mv	a0,s3
    8000541e:	d33fc0ef          	jal	80002150 <killed>
    80005422:	f161                	bnez	a0,800053e2 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005424:	2184a783          	lw	a5,536(s1)
    80005428:	21c4a703          	lw	a4,540(s1)
    8000542c:	2007879b          	addiw	a5,a5,512
    80005430:	fcf70ae3          	beq	a4,a5,80005404 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005434:	4685                	li	a3,1
    80005436:	01590633          	add	a2,s2,s5
    8000543a:	faf40593          	addi	a1,s0,-81
    8000543e:	0509b503          	ld	a0,80(s3)
    80005442:	abefc0ef          	jal	80001700 <copyin>
    80005446:	03650e63          	beq	a0,s6,80005482 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000544a:	21c4a783          	lw	a5,540(s1)
    8000544e:	0017871b          	addiw	a4,a5,1
    80005452:	20e4ae23          	sw	a4,540(s1)
    80005456:	1ff7f793          	andi	a5,a5,511
    8000545a:	97a6                	add	a5,a5,s1
    8000545c:	faf44703          	lbu	a4,-81(s0)
    80005460:	00e78c23          	sb	a4,24(a5)
      i++;
    80005464:	2905                	addiw	s2,s2,1
    80005466:	b775                	j	80005412 <pipewrite+0x6c>
    80005468:	7b02                	ld	s6,32(sp)
    8000546a:	6be2                	ld	s7,24(sp)
    8000546c:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000546e:	21848513          	addi	a0,s1,536
    80005472:	af3fc0ef          	jal	80001f64 <wakeup>
  release(&pi->lock);
    80005476:	8526                	mv	a0,s1
    80005478:	821fb0ef          	jal	80000c98 <release>
  return i;
    8000547c:	bf95                	j	800053f0 <pipewrite+0x4a>
  int i = 0;
    8000547e:	4901                	li	s2,0
    80005480:	b7fd                	j	8000546e <pipewrite+0xc8>
    80005482:	7b02                	ld	s6,32(sp)
    80005484:	6be2                	ld	s7,24(sp)
    80005486:	6c42                	ld	s8,16(sp)
    80005488:	b7dd                	j	8000546e <pipewrite+0xc8>

000000008000548a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000548a:	715d                	addi	sp,sp,-80
    8000548c:	e486                	sd	ra,72(sp)
    8000548e:	e0a2                	sd	s0,64(sp)
    80005490:	fc26                	sd	s1,56(sp)
    80005492:	f84a                	sd	s2,48(sp)
    80005494:	f44e                	sd	s3,40(sp)
    80005496:	f052                	sd	s4,32(sp)
    80005498:	ec56                	sd	s5,24(sp)
    8000549a:	0880                	addi	s0,sp,80
    8000549c:	84aa                	mv	s1,a0
    8000549e:	892e                	mv	s2,a1
    800054a0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800054a2:	c66fc0ef          	jal	80001908 <myproc>
    800054a6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800054a8:	8526                	mv	a0,s1
    800054aa:	f56fb0ef          	jal	80000c00 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800054ae:	2184a703          	lw	a4,536(s1)
    800054b2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800054b6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800054ba:	02f71563          	bne	a4,a5,800054e4 <piperead+0x5a>
    800054be:	2244a783          	lw	a5,548(s1)
    800054c2:	cb85                	beqz	a5,800054f2 <piperead+0x68>
    if(killed(pr)){
    800054c4:	8552                	mv	a0,s4
    800054c6:	c8bfc0ef          	jal	80002150 <killed>
    800054ca:	ed19                	bnez	a0,800054e8 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800054cc:	85a6                	mv	a1,s1
    800054ce:	854e                	mv	a0,s3
    800054d0:	a49fc0ef          	jal	80001f18 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800054d4:	2184a703          	lw	a4,536(s1)
    800054d8:	21c4a783          	lw	a5,540(s1)
    800054dc:	fef701e3          	beq	a4,a5,800054be <piperead+0x34>
    800054e0:	e85a                	sd	s6,16(sp)
    800054e2:	a809                	j	800054f4 <piperead+0x6a>
    800054e4:	e85a                	sd	s6,16(sp)
    800054e6:	a039                	j	800054f4 <piperead+0x6a>
      release(&pi->lock);
    800054e8:	8526                	mv	a0,s1
    800054ea:	faefb0ef          	jal	80000c98 <release>
      return -1;
    800054ee:	59fd                	li	s3,-1
    800054f0:	a8b9                	j	8000554e <piperead+0xc4>
    800054f2:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800054f4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800054f6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800054f8:	05505363          	blez	s5,8000553e <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    800054fc:	2184a783          	lw	a5,536(s1)
    80005500:	21c4a703          	lw	a4,540(s1)
    80005504:	02f70d63          	beq	a4,a5,8000553e <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80005508:	1ff7f793          	andi	a5,a5,511
    8000550c:	97a6                	add	a5,a5,s1
    8000550e:	0187c783          	lbu	a5,24(a5)
    80005512:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80005516:	4685                	li	a3,1
    80005518:	fbf40613          	addi	a2,s0,-65
    8000551c:	85ca                	mv	a1,s2
    8000551e:	050a3503          	ld	a0,80(s4)
    80005522:	8fafc0ef          	jal	8000161c <copyout>
    80005526:	03650e63          	beq	a0,s6,80005562 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    8000552a:	2184a783          	lw	a5,536(s1)
    8000552e:	2785                	addiw	a5,a5,1
    80005530:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005534:	2985                	addiw	s3,s3,1
    80005536:	0905                	addi	s2,s2,1
    80005538:	fd3a92e3          	bne	s5,s3,800054fc <piperead+0x72>
    8000553c:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000553e:	21c48513          	addi	a0,s1,540
    80005542:	a23fc0ef          	jal	80001f64 <wakeup>
  release(&pi->lock);
    80005546:	8526                	mv	a0,s1
    80005548:	f50fb0ef          	jal	80000c98 <release>
    8000554c:	6b42                	ld	s6,16(sp)
  return i;
}
    8000554e:	854e                	mv	a0,s3
    80005550:	60a6                	ld	ra,72(sp)
    80005552:	6406                	ld	s0,64(sp)
    80005554:	74e2                	ld	s1,56(sp)
    80005556:	7942                	ld	s2,48(sp)
    80005558:	79a2                	ld	s3,40(sp)
    8000555a:	7a02                	ld	s4,32(sp)
    8000555c:	6ae2                	ld	s5,24(sp)
    8000555e:	6161                	addi	sp,sp,80
    80005560:	8082                	ret
      if(i == 0)
    80005562:	fc099ee3          	bnez	s3,8000553e <piperead+0xb4>
        i = -1;
    80005566:	89aa                	mv	s3,a0
    80005568:	bfd9                	j	8000553e <piperead+0xb4>

000000008000556a <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    8000556a:	1141                	addi	sp,sp,-16
    8000556c:	e422                	sd	s0,8(sp)
    8000556e:	0800                	addi	s0,sp,16
    80005570:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005572:	8905                	andi	a0,a0,1
    80005574:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005576:	8b89                	andi	a5,a5,2
    80005578:	c399                	beqz	a5,8000557e <flags2perm+0x14>
      perm |= PTE_W;
    8000557a:	00456513          	ori	a0,a0,4
    return perm;
}
    8000557e:	6422                	ld	s0,8(sp)
    80005580:	0141                	addi	sp,sp,16
    80005582:	8082                	ret

0000000080005584 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80005584:	df010113          	addi	sp,sp,-528
    80005588:	20113423          	sd	ra,520(sp)
    8000558c:	20813023          	sd	s0,512(sp)
    80005590:	ffa6                	sd	s1,504(sp)
    80005592:	fbca                	sd	s2,496(sp)
    80005594:	0c00                	addi	s0,sp,528
    80005596:	892a                	mv	s2,a0
    80005598:	dea43c23          	sd	a0,-520(s0)
    8000559c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800055a0:	b68fc0ef          	jal	80001908 <myproc>
    800055a4:	84aa                	mv	s1,a0

  begin_op();
    800055a6:	9f0ff0ef          	jal	80004796 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800055aa:	854a                	mv	a0,s2
    800055ac:	da1fe0ef          	jal	8000434c <namei>
    800055b0:	c931                	beqz	a0,80005604 <kexec+0x80>
    800055b2:	f3d2                	sd	s4,480(sp)
    800055b4:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800055b6:	b32fe0ef          	jal	800038e8 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800055ba:	04000713          	li	a4,64
    800055be:	4681                	li	a3,0
    800055c0:	e5040613          	addi	a2,s0,-432
    800055c4:	4581                	li	a1,0
    800055c6:	8552                	mv	a0,s4
    800055c8:	f82fe0ef          	jal	80003d4a <readi>
    800055cc:	04000793          	li	a5,64
    800055d0:	00f51a63          	bne	a0,a5,800055e4 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800055d4:	e5042703          	lw	a4,-432(s0)
    800055d8:	464c47b7          	lui	a5,0x464c4
    800055dc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800055e0:	02f70663          	beq	a4,a5,8000560c <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800055e4:	8552                	mv	a0,s4
    800055e6:	ddefe0ef          	jal	80003bc4 <iunlockput>
    end_op();
    800055ea:	acaff0ef          	jal	800048b4 <end_op>
  }
  return -1;
    800055ee:	557d                	li	a0,-1
    800055f0:	7a1e                	ld	s4,480(sp)
}
    800055f2:	20813083          	ld	ra,520(sp)
    800055f6:	20013403          	ld	s0,512(sp)
    800055fa:	74fe                	ld	s1,504(sp)
    800055fc:	795e                	ld	s2,496(sp)
    800055fe:	21010113          	addi	sp,sp,528
    80005602:	8082                	ret
    end_op();
    80005604:	ab0ff0ef          	jal	800048b4 <end_op>
    return -1;
    80005608:	557d                	li	a0,-1
    8000560a:	b7e5                	j	800055f2 <kexec+0x6e>
    8000560c:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000560e:	8526                	mv	a0,s1
    80005610:	bfefc0ef          	jal	80001a0e <proc_pagetable>
    80005614:	8b2a                	mv	s6,a0
    80005616:	2c050b63          	beqz	a0,800058ec <kexec+0x368>
    8000561a:	f7ce                	sd	s3,488(sp)
    8000561c:	efd6                	sd	s5,472(sp)
    8000561e:	e7de                	sd	s7,456(sp)
    80005620:	e3e2                	sd	s8,448(sp)
    80005622:	ff66                	sd	s9,440(sp)
    80005624:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005626:	e7042d03          	lw	s10,-400(s0)
    8000562a:	e8845783          	lhu	a5,-376(s0)
    8000562e:	12078963          	beqz	a5,80005760 <kexec+0x1dc>
    80005632:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005634:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005636:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005638:	6c85                	lui	s9,0x1
    8000563a:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000563e:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005642:	6a85                	lui	s5,0x1
    80005644:	a085                	j	800056a4 <kexec+0x120>
      panic("loadseg: address should exist");
    80005646:	00003517          	auipc	a0,0x3
    8000564a:	6fa50513          	addi	a0,a0,1786 # 80008d40 <etext+0xd40>
    8000564e:	9c4fb0ef          	jal	80000812 <panic>
    if(sz - i < PGSIZE)
    80005652:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005654:	8726                	mv	a4,s1
    80005656:	012c06bb          	addw	a3,s8,s2
    8000565a:	4581                	li	a1,0
    8000565c:	8552                	mv	a0,s4
    8000565e:	eecfe0ef          	jal	80003d4a <readi>
    80005662:	2501                	sext.w	a0,a0
    80005664:	24a49a63          	bne	s1,a0,800058b8 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80005668:	012a893b          	addw	s2,s5,s2
    8000566c:	03397363          	bgeu	s2,s3,80005692 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80005670:	02091593          	slli	a1,s2,0x20
    80005674:	9181                	srli	a1,a1,0x20
    80005676:	95de                	add	a1,a1,s7
    80005678:	855a                	mv	a0,s6
    8000567a:	971fb0ef          	jal	80000fea <walkaddr>
    8000567e:	862a                	mv	a2,a0
    if(pa == 0)
    80005680:	d179                	beqz	a0,80005646 <kexec+0xc2>
    if(sz - i < PGSIZE)
    80005682:	412984bb          	subw	s1,s3,s2
    80005686:	0004879b          	sext.w	a5,s1
    8000568a:	fcfcf4e3          	bgeu	s9,a5,80005652 <kexec+0xce>
    8000568e:	84d6                	mv	s1,s5
    80005690:	b7c9                	j	80005652 <kexec+0xce>
    sz = sz1;
    80005692:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005696:	2d85                	addiw	s11,s11,1
    80005698:	038d0d1b          	addiw	s10,s10,56
    8000569c:	e8845783          	lhu	a5,-376(s0)
    800056a0:	08fdd063          	bge	s11,a5,80005720 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800056a4:	2d01                	sext.w	s10,s10
    800056a6:	03800713          	li	a4,56
    800056aa:	86ea                	mv	a3,s10
    800056ac:	e1840613          	addi	a2,s0,-488
    800056b0:	4581                	li	a1,0
    800056b2:	8552                	mv	a0,s4
    800056b4:	e96fe0ef          	jal	80003d4a <readi>
    800056b8:	03800793          	li	a5,56
    800056bc:	1cf51663          	bne	a0,a5,80005888 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800056c0:	e1842783          	lw	a5,-488(s0)
    800056c4:	4705                	li	a4,1
    800056c6:	fce798e3          	bne	a5,a4,80005696 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    800056ca:	e4043483          	ld	s1,-448(s0)
    800056ce:	e3843783          	ld	a5,-456(s0)
    800056d2:	1af4ef63          	bltu	s1,a5,80005890 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800056d6:	e2843783          	ld	a5,-472(s0)
    800056da:	94be                	add	s1,s1,a5
    800056dc:	1af4ee63          	bltu	s1,a5,80005898 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800056e0:	df043703          	ld	a4,-528(s0)
    800056e4:	8ff9                	and	a5,a5,a4
    800056e6:	1a079d63          	bnez	a5,800058a0 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800056ea:	e1c42503          	lw	a0,-484(s0)
    800056ee:	e7dff0ef          	jal	8000556a <flags2perm>
    800056f2:	86aa                	mv	a3,a0
    800056f4:	8626                	mv	a2,s1
    800056f6:	85ca                	mv	a1,s2
    800056f8:	855a                	mv	a0,s6
    800056fa:	bc9fb0ef          	jal	800012c2 <uvmalloc>
    800056fe:	e0a43423          	sd	a0,-504(s0)
    80005702:	1a050363          	beqz	a0,800058a8 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005706:	e2843b83          	ld	s7,-472(s0)
    8000570a:	e2042c03          	lw	s8,-480(s0)
    8000570e:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005712:	00098463          	beqz	s3,8000571a <kexec+0x196>
    80005716:	4901                	li	s2,0
    80005718:	bfa1                	j	80005670 <kexec+0xec>
    sz = sz1;
    8000571a:	e0843903          	ld	s2,-504(s0)
    8000571e:	bfa5                	j	80005696 <kexec+0x112>
    80005720:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80005722:	8552                	mv	a0,s4
    80005724:	ca0fe0ef          	jal	80003bc4 <iunlockput>
  end_op();
    80005728:	98cff0ef          	jal	800048b4 <end_op>
  p = myproc();
    8000572c:	9dcfc0ef          	jal	80001908 <myproc>
    80005730:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005732:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005736:	6985                	lui	s3,0x1
    80005738:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000573a:	99ca                	add	s3,s3,s2
    8000573c:	77fd                	lui	a5,0xfffff
    8000573e:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005742:	4691                	li	a3,4
    80005744:	6609                	lui	a2,0x2
    80005746:	964e                	add	a2,a2,s3
    80005748:	85ce                	mv	a1,s3
    8000574a:	855a                	mv	a0,s6
    8000574c:	b77fb0ef          	jal	800012c2 <uvmalloc>
    80005750:	892a                	mv	s2,a0
    80005752:	e0a43423          	sd	a0,-504(s0)
    80005756:	e519                	bnez	a0,80005764 <kexec+0x1e0>
  if(pagetable)
    80005758:	e1343423          	sd	s3,-504(s0)
    8000575c:	4a01                	li	s4,0
    8000575e:	aab1                	j	800058ba <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005760:	4901                	li	s2,0
    80005762:	b7c1                	j	80005722 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80005764:	75f9                	lui	a1,0xffffe
    80005766:	95aa                	add	a1,a1,a0
    80005768:	855a                	mv	a0,s6
    8000576a:	d2ffb0ef          	jal	80001498 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    8000576e:	7bfd                	lui	s7,0xfffff
    80005770:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005772:	e0043783          	ld	a5,-512(s0)
    80005776:	6388                	ld	a0,0(a5)
    80005778:	cd39                	beqz	a0,800057d6 <kexec+0x252>
    8000577a:	e9040993          	addi	s3,s0,-368
    8000577e:	f9040c13          	addi	s8,s0,-112
    80005782:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005784:	ec0fb0ef          	jal	80000e44 <strlen>
    80005788:	0015079b          	addiw	a5,a0,1
    8000578c:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005790:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005794:	11796e63          	bltu	s2,s7,800058b0 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005798:	e0043d03          	ld	s10,-512(s0)
    8000579c:	000d3a03          	ld	s4,0(s10)
    800057a0:	8552                	mv	a0,s4
    800057a2:	ea2fb0ef          	jal	80000e44 <strlen>
    800057a6:	0015069b          	addiw	a3,a0,1
    800057aa:	8652                	mv	a2,s4
    800057ac:	85ca                	mv	a1,s2
    800057ae:	855a                	mv	a0,s6
    800057b0:	e6dfb0ef          	jal	8000161c <copyout>
    800057b4:	10054063          	bltz	a0,800058b4 <kexec+0x330>
    ustack[argc] = sp;
    800057b8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800057bc:	0485                	addi	s1,s1,1
    800057be:	008d0793          	addi	a5,s10,8
    800057c2:	e0f43023          	sd	a5,-512(s0)
    800057c6:	008d3503          	ld	a0,8(s10)
    800057ca:	c909                	beqz	a0,800057dc <kexec+0x258>
    if(argc >= MAXARG)
    800057cc:	09a1                	addi	s3,s3,8
    800057ce:	fb899be3          	bne	s3,s8,80005784 <kexec+0x200>
  ip = 0;
    800057d2:	4a01                	li	s4,0
    800057d4:	a0dd                	j	800058ba <kexec+0x336>
  sp = sz;
    800057d6:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800057da:	4481                	li	s1,0
  ustack[argc] = 0;
    800057dc:	00349793          	slli	a5,s1,0x3
    800057e0:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ff99148>
    800057e4:	97a2                	add	a5,a5,s0
    800057e6:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800057ea:	00148693          	addi	a3,s1,1
    800057ee:	068e                	slli	a3,a3,0x3
    800057f0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800057f4:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800057f8:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800057fc:	f5796ee3          	bltu	s2,s7,80005758 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005800:	e9040613          	addi	a2,s0,-368
    80005804:	85ca                	mv	a1,s2
    80005806:	855a                	mv	a0,s6
    80005808:	e15fb0ef          	jal	8000161c <copyout>
    8000580c:	0e054263          	bltz	a0,800058f0 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80005810:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005814:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005818:	df843783          	ld	a5,-520(s0)
    8000581c:	0007c703          	lbu	a4,0(a5)
    80005820:	cf11                	beqz	a4,8000583c <kexec+0x2b8>
    80005822:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005824:	02f00693          	li	a3,47
    80005828:	a039                	j	80005836 <kexec+0x2b2>
      last = s+1;
    8000582a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000582e:	0785                	addi	a5,a5,1
    80005830:	fff7c703          	lbu	a4,-1(a5)
    80005834:	c701                	beqz	a4,8000583c <kexec+0x2b8>
    if(*s == '/')
    80005836:	fed71ce3          	bne	a4,a3,8000582e <kexec+0x2aa>
    8000583a:	bfc5                	j	8000582a <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    8000583c:	4641                	li	a2,16
    8000583e:	df843583          	ld	a1,-520(s0)
    80005842:	158a8513          	addi	a0,s5,344
    80005846:	dccfb0ef          	jal	80000e12 <safestrcpy>
  oldpagetable = p->pagetable;
    8000584a:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000584e:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005852:	e0843783          	ld	a5,-504(s0)
    80005856:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    8000585a:	058ab783          	ld	a5,88(s5)
    8000585e:	e6843703          	ld	a4,-408(s0)
    80005862:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005864:	058ab783          	ld	a5,88(s5)
    80005868:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000586c:	85e6                	mv	a1,s9
    8000586e:	a24fc0ef          	jal	80001a92 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005872:	0004851b          	sext.w	a0,s1
    80005876:	79be                	ld	s3,488(sp)
    80005878:	7a1e                	ld	s4,480(sp)
    8000587a:	6afe                	ld	s5,472(sp)
    8000587c:	6b5e                	ld	s6,464(sp)
    8000587e:	6bbe                	ld	s7,456(sp)
    80005880:	6c1e                	ld	s8,448(sp)
    80005882:	7cfa                	ld	s9,440(sp)
    80005884:	7d5a                	ld	s10,432(sp)
    80005886:	b3b5                	j	800055f2 <kexec+0x6e>
    80005888:	e1243423          	sd	s2,-504(s0)
    8000588c:	7dba                	ld	s11,424(sp)
    8000588e:	a035                	j	800058ba <kexec+0x336>
    80005890:	e1243423          	sd	s2,-504(s0)
    80005894:	7dba                	ld	s11,424(sp)
    80005896:	a015                	j	800058ba <kexec+0x336>
    80005898:	e1243423          	sd	s2,-504(s0)
    8000589c:	7dba                	ld	s11,424(sp)
    8000589e:	a831                	j	800058ba <kexec+0x336>
    800058a0:	e1243423          	sd	s2,-504(s0)
    800058a4:	7dba                	ld	s11,424(sp)
    800058a6:	a811                	j	800058ba <kexec+0x336>
    800058a8:	e1243423          	sd	s2,-504(s0)
    800058ac:	7dba                	ld	s11,424(sp)
    800058ae:	a031                	j	800058ba <kexec+0x336>
  ip = 0;
    800058b0:	4a01                	li	s4,0
    800058b2:	a021                	j	800058ba <kexec+0x336>
    800058b4:	4a01                	li	s4,0
  if(pagetable)
    800058b6:	a011                	j	800058ba <kexec+0x336>
    800058b8:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800058ba:	e0843583          	ld	a1,-504(s0)
    800058be:	855a                	mv	a0,s6
    800058c0:	9d2fc0ef          	jal	80001a92 <proc_freepagetable>
  return -1;
    800058c4:	557d                	li	a0,-1
  if(ip){
    800058c6:	000a1b63          	bnez	s4,800058dc <kexec+0x358>
    800058ca:	79be                	ld	s3,488(sp)
    800058cc:	7a1e                	ld	s4,480(sp)
    800058ce:	6afe                	ld	s5,472(sp)
    800058d0:	6b5e                	ld	s6,464(sp)
    800058d2:	6bbe                	ld	s7,456(sp)
    800058d4:	6c1e                	ld	s8,448(sp)
    800058d6:	7cfa                	ld	s9,440(sp)
    800058d8:	7d5a                	ld	s10,432(sp)
    800058da:	bb21                	j	800055f2 <kexec+0x6e>
    800058dc:	79be                	ld	s3,488(sp)
    800058de:	6afe                	ld	s5,472(sp)
    800058e0:	6b5e                	ld	s6,464(sp)
    800058e2:	6bbe                	ld	s7,456(sp)
    800058e4:	6c1e                	ld	s8,448(sp)
    800058e6:	7cfa                	ld	s9,440(sp)
    800058e8:	7d5a                	ld	s10,432(sp)
    800058ea:	b9ed                	j	800055e4 <kexec+0x60>
    800058ec:	6b5e                	ld	s6,464(sp)
    800058ee:	b9dd                	j	800055e4 <kexec+0x60>
  sz = sz1;
    800058f0:	e0843983          	ld	s3,-504(s0)
    800058f4:	b595                	j	80005758 <kexec+0x1d4>

00000000800058f6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800058f6:	1101                	addi	sp,sp,-32
    800058f8:	ec06                	sd	ra,24(sp)
    800058fa:	e822                	sd	s0,16(sp)
    800058fc:	e426                	sd	s1,8(sp)
    800058fe:	1000                	addi	s0,sp,32
    80005900:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005902:	806fc0ef          	jal	80001908 <myproc>
    80005906:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005908:	0d050793          	addi	a5,a0,208
    8000590c:	4501                	li	a0,0
    8000590e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005910:	6398                	ld	a4,0(a5)
    80005912:	cb19                	beqz	a4,80005928 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80005914:	2505                	addiw	a0,a0,1
    80005916:	07a1                	addi	a5,a5,8
    80005918:	fed51ce3          	bne	a0,a3,80005910 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000591c:	557d                	li	a0,-1
}
    8000591e:	60e2                	ld	ra,24(sp)
    80005920:	6442                	ld	s0,16(sp)
    80005922:	64a2                	ld	s1,8(sp)
    80005924:	6105                	addi	sp,sp,32
    80005926:	8082                	ret
      p->ofile[fd] = f;
    80005928:	01a50793          	addi	a5,a0,26
    8000592c:	078e                	slli	a5,a5,0x3
    8000592e:	963e                	add	a2,a2,a5
    80005930:	e204                	sd	s1,0(a2)
      return fd;
    80005932:	b7f5                	j	8000591e <fdalloc+0x28>

0000000080005934 <argfd>:
{
    80005934:	7179                	addi	sp,sp,-48
    80005936:	f406                	sd	ra,40(sp)
    80005938:	f022                	sd	s0,32(sp)
    8000593a:	ec26                	sd	s1,24(sp)
    8000593c:	e84a                	sd	s2,16(sp)
    8000593e:	1800                	addi	s0,sp,48
    80005940:	892e                	mv	s2,a1
    80005942:	84b2                	mv	s1,a2
  argint(n, &fd);
    80005944:	fdc40593          	addi	a1,s0,-36
    80005948:	ed5fc0ef          	jal	8000281c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000594c:	fdc42703          	lw	a4,-36(s0)
    80005950:	47bd                	li	a5,15
    80005952:	02e7e963          	bltu	a5,a4,80005984 <argfd+0x50>
    80005956:	fb3fb0ef          	jal	80001908 <myproc>
    8000595a:	fdc42703          	lw	a4,-36(s0)
    8000595e:	01a70793          	addi	a5,a4,26
    80005962:	078e                	slli	a5,a5,0x3
    80005964:	953e                	add	a0,a0,a5
    80005966:	611c                	ld	a5,0(a0)
    80005968:	c385                	beqz	a5,80005988 <argfd+0x54>
  if(pfd)
    8000596a:	00090463          	beqz	s2,80005972 <argfd+0x3e>
    *pfd = fd;
    8000596e:	00e92023          	sw	a4,0(s2)
  return 0;
    80005972:	4501                	li	a0,0
  if(pf)
    80005974:	c091                	beqz	s1,80005978 <argfd+0x44>
    *pf = f;
    80005976:	e09c                	sd	a5,0(s1)
}
    80005978:	70a2                	ld	ra,40(sp)
    8000597a:	7402                	ld	s0,32(sp)
    8000597c:	64e2                	ld	s1,24(sp)
    8000597e:	6942                	ld	s2,16(sp)
    80005980:	6145                	addi	sp,sp,48
    80005982:	8082                	ret
    return -1;
    80005984:	557d                	li	a0,-1
    80005986:	bfcd                	j	80005978 <argfd+0x44>
    80005988:	557d                	li	a0,-1
    8000598a:	b7fd                	j	80005978 <argfd+0x44>

000000008000598c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000598c:	715d                	addi	sp,sp,-80
    8000598e:	e486                	sd	ra,72(sp)
    80005990:	e0a2                	sd	s0,64(sp)
    80005992:	fc26                	sd	s1,56(sp)
    80005994:	f84a                	sd	s2,48(sp)
    80005996:	f44e                	sd	s3,40(sp)
    80005998:	ec56                	sd	s5,24(sp)
    8000599a:	e85a                	sd	s6,16(sp)
    8000599c:	0880                	addi	s0,sp,80
    8000599e:	8b2e                	mv	s6,a1
    800059a0:	89b2                	mv	s3,a2
    800059a2:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800059a4:	fb040593          	addi	a1,s0,-80
    800059a8:	9bffe0ef          	jal	80004366 <nameiparent>
    800059ac:	84aa                	mv	s1,a0
    800059ae:	10050a63          	beqz	a0,80005ac2 <create+0x136>
    return 0;

  ilock(dp);
    800059b2:	f37fd0ef          	jal	800038e8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800059b6:	4601                	li	a2,0
    800059b8:	fb040593          	addi	a1,s0,-80
    800059bc:	8526                	mv	a0,s1
    800059be:	e20fe0ef          	jal	80003fde <dirlookup>
    800059c2:	8aaa                	mv	s5,a0
    800059c4:	c129                	beqz	a0,80005a06 <create+0x7a>
    iunlockput(dp);
    800059c6:	8526                	mv	a0,s1
    800059c8:	9fcfe0ef          	jal	80003bc4 <iunlockput>
    ilock(ip);
    800059cc:	8556                	mv	a0,s5
    800059ce:	f1bfd0ef          	jal	800038e8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800059d2:	4789                	li	a5,2
    800059d4:	02fb1463          	bne	s6,a5,800059fc <create+0x70>
    800059d8:	044ad783          	lhu	a5,68(s5)
    800059dc:	37f9                	addiw	a5,a5,-2
    800059de:	17c2                	slli	a5,a5,0x30
    800059e0:	93c1                	srli	a5,a5,0x30
    800059e2:	4705                	li	a4,1
    800059e4:	00f76c63          	bltu	a4,a5,800059fc <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800059e8:	8556                	mv	a0,s5
    800059ea:	60a6                	ld	ra,72(sp)
    800059ec:	6406                	ld	s0,64(sp)
    800059ee:	74e2                	ld	s1,56(sp)
    800059f0:	7942                	ld	s2,48(sp)
    800059f2:	79a2                	ld	s3,40(sp)
    800059f4:	6ae2                	ld	s5,24(sp)
    800059f6:	6b42                	ld	s6,16(sp)
    800059f8:	6161                	addi	sp,sp,80
    800059fa:	8082                	ret
    iunlockput(ip);
    800059fc:	8556                	mv	a0,s5
    800059fe:	9c6fe0ef          	jal	80003bc4 <iunlockput>
    return 0;
    80005a02:	4a81                	li	s5,0
    80005a04:	b7d5                	j	800059e8 <create+0x5c>
    80005a06:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005a08:	85da                	mv	a1,s6
    80005a0a:	4088                	lw	a0,0(s1)
    80005a0c:	d07fd0ef          	jal	80003712 <ialloc>
    80005a10:	8a2a                	mv	s4,a0
    80005a12:	cd15                	beqz	a0,80005a4e <create+0xc2>
  ilock(ip);
    80005a14:	ed5fd0ef          	jal	800038e8 <ilock>
  ip->major = major;
    80005a18:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005a1c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005a20:	4905                	li	s2,1
    80005a22:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005a26:	8552                	mv	a0,s4
    80005a28:	dc9fd0ef          	jal	800037f0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005a2c:	032b0763          	beq	s6,s2,80005a5a <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80005a30:	004a2603          	lw	a2,4(s4)
    80005a34:	fb040593          	addi	a1,s0,-80
    80005a38:	8526                	mv	a0,s1
    80005a3a:	839fe0ef          	jal	80004272 <dirlink>
    80005a3e:	06054563          	bltz	a0,80005aa8 <create+0x11c>
  iunlockput(dp);
    80005a42:	8526                	mv	a0,s1
    80005a44:	980fe0ef          	jal	80003bc4 <iunlockput>
  return ip;
    80005a48:	8ad2                	mv	s5,s4
    80005a4a:	7a02                	ld	s4,32(sp)
    80005a4c:	bf71                	j	800059e8 <create+0x5c>
    iunlockput(dp);
    80005a4e:	8526                	mv	a0,s1
    80005a50:	974fe0ef          	jal	80003bc4 <iunlockput>
    return 0;
    80005a54:	8ad2                	mv	s5,s4
    80005a56:	7a02                	ld	s4,32(sp)
    80005a58:	bf41                	j	800059e8 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005a5a:	004a2603          	lw	a2,4(s4)
    80005a5e:	00003597          	auipc	a1,0x3
    80005a62:	30258593          	addi	a1,a1,770 # 80008d60 <etext+0xd60>
    80005a66:	8552                	mv	a0,s4
    80005a68:	80bfe0ef          	jal	80004272 <dirlink>
    80005a6c:	02054e63          	bltz	a0,80005aa8 <create+0x11c>
    80005a70:	40d0                	lw	a2,4(s1)
    80005a72:	00003597          	auipc	a1,0x3
    80005a76:	2f658593          	addi	a1,a1,758 # 80008d68 <etext+0xd68>
    80005a7a:	8552                	mv	a0,s4
    80005a7c:	ff6fe0ef          	jal	80004272 <dirlink>
    80005a80:	02054463          	bltz	a0,80005aa8 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005a84:	004a2603          	lw	a2,4(s4)
    80005a88:	fb040593          	addi	a1,s0,-80
    80005a8c:	8526                	mv	a0,s1
    80005a8e:	fe4fe0ef          	jal	80004272 <dirlink>
    80005a92:	00054b63          	bltz	a0,80005aa8 <create+0x11c>
    dp->nlink++;  // for ".."
    80005a96:	04a4d783          	lhu	a5,74(s1)
    80005a9a:	2785                	addiw	a5,a5,1
    80005a9c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005aa0:	8526                	mv	a0,s1
    80005aa2:	d4ffd0ef          	jal	800037f0 <iupdate>
    80005aa6:	bf71                	j	80005a42 <create+0xb6>
  ip->nlink = 0;
    80005aa8:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005aac:	8552                	mv	a0,s4
    80005aae:	d43fd0ef          	jal	800037f0 <iupdate>
  iunlockput(ip);
    80005ab2:	8552                	mv	a0,s4
    80005ab4:	910fe0ef          	jal	80003bc4 <iunlockput>
  iunlockput(dp);
    80005ab8:	8526                	mv	a0,s1
    80005aba:	90afe0ef          	jal	80003bc4 <iunlockput>
  return 0;
    80005abe:	7a02                	ld	s4,32(sp)
    80005ac0:	b725                	j	800059e8 <create+0x5c>
    return 0;
    80005ac2:	8aaa                	mv	s5,a0
    80005ac4:	b715                	j	800059e8 <create+0x5c>

0000000080005ac6 <sys_dup>:
{
    80005ac6:	7179                	addi	sp,sp,-48
    80005ac8:	f406                	sd	ra,40(sp)
    80005aca:	f022                	sd	s0,32(sp)
    80005acc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005ace:	fd840613          	addi	a2,s0,-40
    80005ad2:	4581                	li	a1,0
    80005ad4:	4501                	li	a0,0
    80005ad6:	e5fff0ef          	jal	80005934 <argfd>
    return -1;
    80005ada:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005adc:	02054e63          	bltz	a0,80005b18 <sys_dup+0x52>
    80005ae0:	ec26                	sd	s1,24(sp)
    80005ae2:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005ae4:	fd843903          	ld	s2,-40(s0)
    80005ae8:	854a                	mv	a0,s2
    80005aea:	e0dff0ef          	jal	800058f6 <fdalloc>
    80005aee:	84aa                	mv	s1,a0
    return -1;
    80005af0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005af2:	02054863          	bltz	a0,80005b22 <sys_dup+0x5c>
  filedup(f);
    80005af6:	854a                	mv	a0,s2
    80005af8:	b76ff0ef          	jal	80004e6e <filedup>
    myproc()->pid,
    80005afc:	e0dfb0ef          	jal	80001908 <myproc>
  state_update_file(
    80005b00:	00003697          	auipc	a3,0x3
    80005b04:	08068693          	addi	a3,a3,128 # 80008b80 <etext+0xb80>
    80005b08:	864a                	mv	a2,s2
    80005b0a:	85a6                	mv	a1,s1
    80005b0c:	5908                	lw	a0,48(a0)
    80005b0e:	3e0010ef          	jal	80006eee <state_update_file>
  return fd;
    80005b12:	87a6                	mv	a5,s1
    80005b14:	64e2                	ld	s1,24(sp)
    80005b16:	6942                	ld	s2,16(sp)
}
    80005b18:	853e                	mv	a0,a5
    80005b1a:	70a2                	ld	ra,40(sp)
    80005b1c:	7402                	ld	s0,32(sp)
    80005b1e:	6145                	addi	sp,sp,48
    80005b20:	8082                	ret
    80005b22:	64e2                	ld	s1,24(sp)
    80005b24:	6942                	ld	s2,16(sp)
    80005b26:	bfcd                	j	80005b18 <sys_dup+0x52>

0000000080005b28 <sys_read>:
{
    80005b28:	7179                	addi	sp,sp,-48
    80005b2a:	f406                	sd	ra,40(sp)
    80005b2c:	f022                	sd	s0,32(sp)
    80005b2e:	1800                	addi	s0,sp,48
  if(argfd(0, &fd, &f) < 0)
    80005b30:	fe840613          	addi	a2,s0,-24
    80005b34:	fd440593          	addi	a1,s0,-44
    80005b38:	4501                	li	a0,0
    80005b3a:	dfbff0ef          	jal	80005934 <argfd>
    80005b3e:	87aa                	mv	a5,a0
    return -1;
    80005b40:	557d                	li	a0,-1
  if(argfd(0, &fd, &f) < 0)
    80005b42:	0407c263          	bltz	a5,80005b86 <sys_read+0x5e>
  argaddr(1, &p);
    80005b46:	fd840593          	addi	a1,s0,-40
    80005b4a:	4505                	li	a0,1
    80005b4c:	cedfc0ef          	jal	80002838 <argaddr>
  argint(2, &n);
    80005b50:	fe440593          	addi	a1,s0,-28
    80005b54:	4509                	li	a0,2
    80005b56:	cc7fc0ef          	jal	8000281c <argint>
  safestrcpy(myproc()->current_syscall,
    80005b5a:	daffb0ef          	jal	80001908 <myproc>
    80005b5e:	02000613          	li	a2,32
    80005b62:	00003597          	auipc	a1,0x3
    80005b66:	20e58593          	addi	a1,a1,526 # 80008d70 <etext+0xd70>
    80005b6a:	16850513          	addi	a0,a0,360
    80005b6e:	aa4fb0ef          	jal	80000e12 <safestrcpy>
  return fileread(f, fd, p, n);
    80005b72:	fe442683          	lw	a3,-28(s0)
    80005b76:	fd843603          	ld	a2,-40(s0)
    80005b7a:	fd442583          	lw	a1,-44(s0)
    80005b7e:	fe843503          	ld	a0,-24(s0)
    80005b82:	ca4ff0ef          	jal	80005026 <fileread>
}
    80005b86:	70a2                	ld	ra,40(sp)
    80005b88:	7402                	ld	s0,32(sp)
    80005b8a:	6145                	addi	sp,sp,48
    80005b8c:	8082                	ret

0000000080005b8e <sys_write>:
{
    80005b8e:	7179                	addi	sp,sp,-48
    80005b90:	f406                	sd	ra,40(sp)
    80005b92:	f022                	sd	s0,32(sp)
    80005b94:	1800                	addi	s0,sp,48
  if(argfd(0, &fd , &f) < 0)
    80005b96:	fe840613          	addi	a2,s0,-24
    80005b9a:	fd440593          	addi	a1,s0,-44
    80005b9e:	4501                	li	a0,0
    80005ba0:	d95ff0ef          	jal	80005934 <argfd>
    80005ba4:	87aa                	mv	a5,a0
    return -1;
    80005ba6:	557d                	li	a0,-1
  if(argfd(0, &fd , &f) < 0)
    80005ba8:	0407c263          	bltz	a5,80005bec <sys_write+0x5e>
  argaddr(1, &p);
    80005bac:	fd840593          	addi	a1,s0,-40
    80005bb0:	4505                	li	a0,1
    80005bb2:	c87fc0ef          	jal	80002838 <argaddr>
  argint(2, &n);
    80005bb6:	fe440593          	addi	a1,s0,-28
    80005bba:	4509                	li	a0,2
    80005bbc:	c61fc0ef          	jal	8000281c <argint>
  safestrcpy(myproc()->current_syscall,
    80005bc0:	d49fb0ef          	jal	80001908 <myproc>
    80005bc4:	02000613          	li	a2,32
    80005bc8:	00003597          	auipc	a1,0x3
    80005bcc:	1b058593          	addi	a1,a1,432 # 80008d78 <etext+0xd78>
    80005bd0:	16850513          	addi	a0,a0,360
    80005bd4:	a3efb0ef          	jal	80000e12 <safestrcpy>
  return filewrite(f, fd, p, n);
    80005bd8:	fe442683          	lw	a3,-28(s0)
    80005bdc:	fd843603          	ld	a2,-40(s0)
    80005be0:	fd442583          	lw	a1,-44(s0)
    80005be4:	fe843503          	ld	a0,-24(s0)
    80005be8:	d36ff0ef          	jal	8000511e <filewrite>
}
    80005bec:	70a2                	ld	ra,40(sp)
    80005bee:	7402                	ld	s0,32(sp)
    80005bf0:	6145                	addi	sp,sp,48
    80005bf2:	8082                	ret

0000000080005bf4 <sys_close>:
{
    80005bf4:	7179                	addi	sp,sp,-48
    80005bf6:	f406                	sd	ra,40(sp)
    80005bf8:	f022                	sd	s0,32(sp)
    80005bfa:	1800                	addi	s0,sp,48
  if(argfd(0, &fd, &f) < 0)
    80005bfc:	fd040613          	addi	a2,s0,-48
    80005c00:	fdc40593          	addi	a1,s0,-36
    80005c04:	4501                	li	a0,0
    80005c06:	d2fff0ef          	jal	80005934 <argfd>
    return -1;
    80005c0a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005c0c:	02054963          	bltz	a0,80005c3e <sys_close+0x4a>
    80005c10:	ec26                	sd	s1,24(sp)
  myproc()->ofile[fd] = 0;
    80005c12:	cf7fb0ef          	jal	80001908 <myproc>
    80005c16:	fdc42483          	lw	s1,-36(s0)
    80005c1a:	01a48793          	addi	a5,s1,26
    80005c1e:	078e                	slli	a5,a5,0x3
    80005c20:	953e                	add	a0,a0,a5
    80005c22:	00053023          	sd	zero,0(a0)
  state_remove_fd(myproc()->pid, fd);
    80005c26:	ce3fb0ef          	jal	80001908 <myproc>
    80005c2a:	85a6                	mv	a1,s1
    80005c2c:	5908                	lw	a0,48(a0)
    80005c2e:	2cc010ef          	jal	80006efa <state_remove_fd>
  fileclose(f);
    80005c32:	fd043503          	ld	a0,-48(s0)
    80005c36:	a9aff0ef          	jal	80004ed0 <fileclose>
  return 0;
    80005c3a:	4781                	li	a5,0
    80005c3c:	64e2                	ld	s1,24(sp)
}
    80005c3e:	853e                	mv	a0,a5
    80005c40:	70a2                	ld	ra,40(sp)
    80005c42:	7402                	ld	s0,32(sp)
    80005c44:	6145                	addi	sp,sp,48
    80005c46:	8082                	ret

0000000080005c48 <sys_fstat>:
{
    80005c48:	1101                	addi	sp,sp,-32
    80005c4a:	ec06                	sd	ra,24(sp)
    80005c4c:	e822                	sd	s0,16(sp)
    80005c4e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005c50:	fe040593          	addi	a1,s0,-32
    80005c54:	4505                	li	a0,1
    80005c56:	be3fc0ef          	jal	80002838 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005c5a:	fe840613          	addi	a2,s0,-24
    80005c5e:	4581                	li	a1,0
    80005c60:	4501                	li	a0,0
    80005c62:	cd3ff0ef          	jal	80005934 <argfd>
    80005c66:	87aa                	mv	a5,a0
    return -1;
    80005c68:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c6a:	0007c863          	bltz	a5,80005c7a <sys_fstat+0x32>
  return filestat(f, st);
    80005c6e:	fe043583          	ld	a1,-32(s0)
    80005c72:	fe843503          	ld	a0,-24(s0)
    80005c76:	b52ff0ef          	jal	80004fc8 <filestat>
}
    80005c7a:	60e2                	ld	ra,24(sp)
    80005c7c:	6442                	ld	s0,16(sp)
    80005c7e:	6105                	addi	sp,sp,32
    80005c80:	8082                	ret

0000000080005c82 <sys_link>:
{
    80005c82:	7169                	addi	sp,sp,-304
    80005c84:	f606                	sd	ra,296(sp)
    80005c86:	f222                	sd	s0,288(sp)
    80005c88:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c8a:	08000613          	li	a2,128
    80005c8e:	ed040593          	addi	a1,s0,-304
    80005c92:	4501                	li	a0,0
    80005c94:	bc1fc0ef          	jal	80002854 <argstr>
    return -1;
    80005c98:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c9a:	0e054a63          	bltz	a0,80005d8e <sys_link+0x10c>
    80005c9e:	08000613          	li	a2,128
    80005ca2:	f5040593          	addi	a1,s0,-176
    80005ca6:	4505                	li	a0,1
    80005ca8:	badfc0ef          	jal	80002854 <argstr>
    return -1;
    80005cac:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005cae:	0e054063          	bltz	a0,80005d8e <sys_link+0x10c>
    80005cb2:	ee26                	sd	s1,280(sp)
  safestrcpy(myproc()->current_syscall,
    80005cb4:	c55fb0ef          	jal	80001908 <myproc>
    80005cb8:	02000613          	li	a2,32
    80005cbc:	00003597          	auipc	a1,0x3
    80005cc0:	0c458593          	addi	a1,a1,196 # 80008d80 <etext+0xd80>
    80005cc4:	16850513          	addi	a0,a0,360
    80005cc8:	94afb0ef          	jal	80000e12 <safestrcpy>
  begin_op();
    80005ccc:	acbfe0ef          	jal	80004796 <begin_op>
  if((ip = namei(old)) == 0){
    80005cd0:	ed040513          	addi	a0,s0,-304
    80005cd4:	e78fe0ef          	jal	8000434c <namei>
    80005cd8:	84aa                	mv	s1,a0
    80005cda:	c53d                	beqz	a0,80005d48 <sys_link+0xc6>
  ilock(ip);
    80005cdc:	c0dfd0ef          	jal	800038e8 <ilock>
  if(ip->type == T_DIR){
    80005ce0:	04449703          	lh	a4,68(s1)
    80005ce4:	4785                	li	a5,1
    80005ce6:	06f70663          	beq	a4,a5,80005d52 <sys_link+0xd0>
    80005cea:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005cec:	04a4d783          	lhu	a5,74(s1)
    80005cf0:	2785                	addiw	a5,a5,1
    80005cf2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005cf6:	8526                	mv	a0,s1
    80005cf8:	af9fd0ef          	jal	800037f0 <iupdate>
  iunlock(ip);
    80005cfc:	8526                	mv	a0,s1
    80005cfe:	cddfd0ef          	jal	800039da <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005d02:	fd040593          	addi	a1,s0,-48
    80005d06:	f5040513          	addi	a0,s0,-176
    80005d0a:	e5cfe0ef          	jal	80004366 <nameiparent>
    80005d0e:	892a                	mv	s2,a0
    80005d10:	cd21                	beqz	a0,80005d68 <sys_link+0xe6>
  ilock(dp);
    80005d12:	bd7fd0ef          	jal	800038e8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005d16:	00092703          	lw	a4,0(s2)
    80005d1a:	409c                	lw	a5,0(s1)
    80005d1c:	04f71363          	bne	a4,a5,80005d62 <sys_link+0xe0>
    80005d20:	40d0                	lw	a2,4(s1)
    80005d22:	fd040593          	addi	a1,s0,-48
    80005d26:	854a                	mv	a0,s2
    80005d28:	d4afe0ef          	jal	80004272 <dirlink>
    80005d2c:	02054b63          	bltz	a0,80005d62 <sys_link+0xe0>
  iunlockput(dp);
    80005d30:	854a                	mv	a0,s2
    80005d32:	e93fd0ef          	jal	80003bc4 <iunlockput>
  iput(ip);
    80005d36:	8526                	mv	a0,s1
    80005d38:	dc1fd0ef          	jal	80003af8 <iput>
  end_op();
    80005d3c:	b79fe0ef          	jal	800048b4 <end_op>
  return 0;
    80005d40:	4781                	li	a5,0
    80005d42:	64f2                	ld	s1,280(sp)
    80005d44:	6952                	ld	s2,272(sp)
    80005d46:	a0a1                	j	80005d8e <sys_link+0x10c>
    end_op();
    80005d48:	b6dfe0ef          	jal	800048b4 <end_op>
    return -1;
    80005d4c:	57fd                	li	a5,-1
    80005d4e:	64f2                	ld	s1,280(sp)
    80005d50:	a83d                	j	80005d8e <sys_link+0x10c>
    iunlockput(ip);
    80005d52:	8526                	mv	a0,s1
    80005d54:	e71fd0ef          	jal	80003bc4 <iunlockput>
    end_op();
    80005d58:	b5dfe0ef          	jal	800048b4 <end_op>
    return -1;
    80005d5c:	57fd                	li	a5,-1
    80005d5e:	64f2                	ld	s1,280(sp)
    80005d60:	a03d                	j	80005d8e <sys_link+0x10c>
    iunlockput(dp);
    80005d62:	854a                	mv	a0,s2
    80005d64:	e61fd0ef          	jal	80003bc4 <iunlockput>
  ilock(ip);
    80005d68:	8526                	mv	a0,s1
    80005d6a:	b7ffd0ef          	jal	800038e8 <ilock>
  ip->nlink--;
    80005d6e:	04a4d783          	lhu	a5,74(s1)
    80005d72:	37fd                	addiw	a5,a5,-1
    80005d74:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005d78:	8526                	mv	a0,s1
    80005d7a:	a77fd0ef          	jal	800037f0 <iupdate>
  iunlockput(ip);
    80005d7e:	8526                	mv	a0,s1
    80005d80:	e45fd0ef          	jal	80003bc4 <iunlockput>
  end_op();
    80005d84:	b31fe0ef          	jal	800048b4 <end_op>
  return -1;
    80005d88:	57fd                	li	a5,-1
    80005d8a:	64f2                	ld	s1,280(sp)
    80005d8c:	6952                	ld	s2,272(sp)
}
    80005d8e:	853e                	mv	a0,a5
    80005d90:	70b2                	ld	ra,296(sp)
    80005d92:	7412                	ld	s0,288(sp)
    80005d94:	6155                	addi	sp,sp,304
    80005d96:	8082                	ret

0000000080005d98 <sys_unlink>:
{
    80005d98:	7151                	addi	sp,sp,-240
    80005d9a:	f586                	sd	ra,232(sp)
    80005d9c:	f1a2                	sd	s0,224(sp)
    80005d9e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005da0:	08000613          	li	a2,128
    80005da4:	f3040593          	addi	a1,s0,-208
    80005da8:	4501                	li	a0,0
    80005daa:	aabfc0ef          	jal	80002854 <argstr>
    80005dae:	16054c63          	bltz	a0,80005f26 <sys_unlink+0x18e>
    80005db2:	eda6                	sd	s1,216(sp)
  safestrcpy(myproc()->current_syscall,
    80005db4:	b55fb0ef          	jal	80001908 <myproc>
    80005db8:	02000613          	li	a2,32
    80005dbc:	00003597          	auipc	a1,0x3
    80005dc0:	fcc58593          	addi	a1,a1,-52 # 80008d88 <etext+0xd88>
    80005dc4:	16850513          	addi	a0,a0,360
    80005dc8:	84afb0ef          	jal	80000e12 <safestrcpy>
  begin_op();
    80005dcc:	9cbfe0ef          	jal	80004796 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005dd0:	fb040593          	addi	a1,s0,-80
    80005dd4:	f3040513          	addi	a0,s0,-208
    80005dd8:	d8efe0ef          	jal	80004366 <nameiparent>
    80005ddc:	84aa                	mv	s1,a0
    80005dde:	c945                	beqz	a0,80005e8e <sys_unlink+0xf6>
  ilock(dp);
    80005de0:	b09fd0ef          	jal	800038e8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005de4:	00003597          	auipc	a1,0x3
    80005de8:	f7c58593          	addi	a1,a1,-132 # 80008d60 <etext+0xd60>
    80005dec:	fb040513          	addi	a0,s0,-80
    80005df0:	9d8fe0ef          	jal	80003fc8 <namecmp>
    80005df4:	10050e63          	beqz	a0,80005f10 <sys_unlink+0x178>
    80005df8:	00003597          	auipc	a1,0x3
    80005dfc:	f7058593          	addi	a1,a1,-144 # 80008d68 <etext+0xd68>
    80005e00:	fb040513          	addi	a0,s0,-80
    80005e04:	9c4fe0ef          	jal	80003fc8 <namecmp>
    80005e08:	10050463          	beqz	a0,80005f10 <sys_unlink+0x178>
    80005e0c:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005e0e:	f2c40613          	addi	a2,s0,-212
    80005e12:	fb040593          	addi	a1,s0,-80
    80005e16:	8526                	mv	a0,s1
    80005e18:	9c6fe0ef          	jal	80003fde <dirlookup>
    80005e1c:	892a                	mv	s2,a0
    80005e1e:	0e050863          	beqz	a0,80005f0e <sys_unlink+0x176>
  ilock(ip);
    80005e22:	ac7fd0ef          	jal	800038e8 <ilock>
  if(ip->nlink < 1)
    80005e26:	04a91783          	lh	a5,74(s2)
    80005e2a:	06f05763          	blez	a5,80005e98 <sys_unlink+0x100>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005e2e:	04491703          	lh	a4,68(s2)
    80005e32:	4785                	li	a5,1
    80005e34:	06f70963          	beq	a4,a5,80005ea6 <sys_unlink+0x10e>
  memset(&de, 0, sizeof(de));
    80005e38:	4641                	li	a2,16
    80005e3a:	4581                	li	a1,0
    80005e3c:	fc040513          	addi	a0,s0,-64
    80005e40:	e95fa0ef          	jal	80000cd4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e44:	4741                	li	a4,16
    80005e46:	f2c42683          	lw	a3,-212(s0)
    80005e4a:	fc040613          	addi	a2,s0,-64
    80005e4e:	4581                	li	a1,0
    80005e50:	8526                	mv	a0,s1
    80005e52:	828fe0ef          	jal	80003e7a <writei>
    80005e56:	47c1                	li	a5,16
    80005e58:	08f51b63          	bne	a0,a5,80005eee <sys_unlink+0x156>
  if(ip->type == T_DIR){
    80005e5c:	04491703          	lh	a4,68(s2)
    80005e60:	4785                	li	a5,1
    80005e62:	08f70d63          	beq	a4,a5,80005efc <sys_unlink+0x164>
  iunlockput(dp);
    80005e66:	8526                	mv	a0,s1
    80005e68:	d5dfd0ef          	jal	80003bc4 <iunlockput>
  ip->nlink--;
    80005e6c:	04a95783          	lhu	a5,74(s2)
    80005e70:	37fd                	addiw	a5,a5,-1
    80005e72:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005e76:	854a                	mv	a0,s2
    80005e78:	979fd0ef          	jal	800037f0 <iupdate>
  iunlockput(ip);
    80005e7c:	854a                	mv	a0,s2
    80005e7e:	d47fd0ef          	jal	80003bc4 <iunlockput>
  end_op();
    80005e82:	a33fe0ef          	jal	800048b4 <end_op>
  return 0;
    80005e86:	4501                	li	a0,0
    80005e88:	64ee                	ld	s1,216(sp)
    80005e8a:	694e                	ld	s2,208(sp)
    80005e8c:	a849                	j	80005f1e <sys_unlink+0x186>
    end_op();
    80005e8e:	a27fe0ef          	jal	800048b4 <end_op>
    return -1;
    80005e92:	557d                	li	a0,-1
    80005e94:	64ee                	ld	s1,216(sp)
    80005e96:	a061                	j	80005f1e <sys_unlink+0x186>
    80005e98:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005e9a:	00003517          	auipc	a0,0x3
    80005e9e:	ef650513          	addi	a0,a0,-266 # 80008d90 <etext+0xd90>
    80005ea2:	971fa0ef          	jal	80000812 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ea6:	04c92703          	lw	a4,76(s2)
    80005eaa:	02000793          	li	a5,32
    80005eae:	f8e7f5e3          	bgeu	a5,a4,80005e38 <sys_unlink+0xa0>
    80005eb2:	e5ce                	sd	s3,200(sp)
    80005eb4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005eb8:	4741                	li	a4,16
    80005eba:	86ce                	mv	a3,s3
    80005ebc:	f1840613          	addi	a2,s0,-232
    80005ec0:	4581                	li	a1,0
    80005ec2:	854a                	mv	a0,s2
    80005ec4:	e87fd0ef          	jal	80003d4a <readi>
    80005ec8:	47c1                	li	a5,16
    80005eca:	00f51c63          	bne	a0,a5,80005ee2 <sys_unlink+0x14a>
    if(de.inum != 0)
    80005ece:	f1845783          	lhu	a5,-232(s0)
    80005ed2:	efa1                	bnez	a5,80005f2a <sys_unlink+0x192>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ed4:	29c1                	addiw	s3,s3,16
    80005ed6:	04c92783          	lw	a5,76(s2)
    80005eda:	fcf9efe3          	bltu	s3,a5,80005eb8 <sys_unlink+0x120>
    80005ede:	69ae                	ld	s3,200(sp)
    80005ee0:	bfa1                	j	80005e38 <sys_unlink+0xa0>
      panic("isdirempty: readi");
    80005ee2:	00003517          	auipc	a0,0x3
    80005ee6:	ec650513          	addi	a0,a0,-314 # 80008da8 <etext+0xda8>
    80005eea:	929fa0ef          	jal	80000812 <panic>
    80005eee:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005ef0:	00003517          	auipc	a0,0x3
    80005ef4:	ed050513          	addi	a0,a0,-304 # 80008dc0 <etext+0xdc0>
    80005ef8:	91bfa0ef          	jal	80000812 <panic>
    dp->nlink--;
    80005efc:	04a4d783          	lhu	a5,74(s1)
    80005f00:	37fd                	addiw	a5,a5,-1
    80005f02:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005f06:	8526                	mv	a0,s1
    80005f08:	8e9fd0ef          	jal	800037f0 <iupdate>
    80005f0c:	bfa9                	j	80005e66 <sys_unlink+0xce>
    80005f0e:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005f10:	8526                	mv	a0,s1
    80005f12:	cb3fd0ef          	jal	80003bc4 <iunlockput>
  end_op();
    80005f16:	99ffe0ef          	jal	800048b4 <end_op>
  return -1;
    80005f1a:	557d                	li	a0,-1
    80005f1c:	64ee                	ld	s1,216(sp)
}
    80005f1e:	70ae                	ld	ra,232(sp)
    80005f20:	740e                	ld	s0,224(sp)
    80005f22:	616d                	addi	sp,sp,240
    80005f24:	8082                	ret
    return -1;
    80005f26:	557d                	li	a0,-1
    80005f28:	bfdd                	j	80005f1e <sys_unlink+0x186>
    iunlockput(ip);
    80005f2a:	854a                	mv	a0,s2
    80005f2c:	c99fd0ef          	jal	80003bc4 <iunlockput>
    goto bad;
    80005f30:	694e                	ld	s2,208(sp)
    80005f32:	69ae                	ld	s3,200(sp)
    80005f34:	bff1                	j	80005f10 <sys_unlink+0x178>

0000000080005f36 <sys_open>:

uint64
sys_open(void)
{
    80005f36:	7129                	addi	sp,sp,-320
    80005f38:	fe06                	sd	ra,312(sp)
    80005f3a:	fa22                	sd	s0,304(sp)
    80005f3c:	0280                	addi	s0,sp,320
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005f3e:	f4c40593          	addi	a1,s0,-180
    80005f42:	4505                	li	a0,1
    80005f44:	8d9fc0ef          	jal	8000281c <argint>

  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f48:	08000613          	li	a2,128
    80005f4c:	f5040593          	addi	a1,s0,-176
    80005f50:	4501                	li	a0,0
    80005f52:	903fc0ef          	jal	80002854 <argstr>
    80005f56:	87aa                	mv	a5,a0
    return -1;
    80005f58:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f5a:	1007c763          	bltz	a5,80006068 <sys_open+0x132>
    80005f5e:	f626                	sd	s1,296(sp)

  safestrcpy(
    myproc()->current_syscall,
    80005f60:	9a9fb0ef          	jal	80001908 <myproc>
  safestrcpy(
    80005f64:	02000613          	li	a2,32
    80005f68:	00003597          	auipc	a1,0x3
    80005f6c:	e6858593          	addi	a1,a1,-408 # 80008dd0 <etext+0xdd0>
    80005f70:	16850513          	addi	a0,a0,360
    80005f74:	e9ffa0ef          	jal	80000e12 <safestrcpy>
    "OPEN",
    sizeof(myproc()->current_syscall)
  );

  begin_op();
    80005f78:	81ffe0ef          	jal	80004796 <begin_op>

  if(omode & O_CREATE){
    80005f7c:	f4c42783          	lw	a5,-180(s0)
    80005f80:	2007f793          	andi	a5,a5,512
    80005f84:	0e078b63          	beqz	a5,8000607a <sys_open+0x144>
    ip = create(path, T_FILE, 0, 0);
    80005f88:	4681                	li	a3,0
    80005f8a:	4601                	li	a2,0
    80005f8c:	4589                	li	a1,2
    80005f8e:	f5040513          	addi	a0,s0,-176
    80005f92:	9fbff0ef          	jal	8000598c <create>
    80005f96:	84aa                	mv	s1,a0
    if(ip == 0){
    80005f98:	cd61                	beqz	a0,80006070 <sys_open+0x13a>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE &&
    80005f9a:	04449703          	lh	a4,68(s1)
    80005f9e:	478d                	li	a5,3
    80005fa0:	00f71763          	bne	a4,a5,80005fae <sys_open+0x78>
    80005fa4:	0464d703          	lhu	a4,70(s1)
    80005fa8:	47a5                	li	a5,9
    80005faa:	10e7e663          	bltu	a5,a4,800060b6 <sys_open+0x180>
    80005fae:	f24a                	sd	s2,288(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 ||
    80005fb0:	e61fe0ef          	jal	80004e10 <filealloc>
    80005fb4:	892a                	mv	s2,a0
    80005fb6:	10050c63          	beqz	a0,800060ce <sys_open+0x198>
    80005fba:	ee4e                	sd	s3,280(sp)
     (fd = fdalloc(f)) < 0){
    80005fbc:	93bff0ef          	jal	800058f6 <fdalloc>
    80005fc0:	89aa                	mv	s3,a0
  if((f = filealloc()) == 0 ||
    80005fc2:	10054263          	bltz	a0,800060c6 <sys_open+0x190>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(path[0] == '/'){
    80005fc6:	f5044783          	lbu	a5,-176(s0)
    80005fca:	02f00713          	li	a4,47
    80005fce:	10e78963          	beq	a5,a4,800060e0 <sys_open+0x1aa>
    safestrcpy(f->path, path, MAXPATH);
} else {
    char full[MAXPATH];

    if(path[0] == '.'){
    80005fd2:	02e00713          	li	a4,46
    80005fd6:	10e78e63          	beq	a5,a4,800060f2 <sys_open+0x1bc>
        safestrcpy(full, "/", MAXPATH);
    } else {
        full[0] = '/';
    80005fda:	02f00793          	li	a5,47
    80005fde:	ecf40423          	sb	a5,-312(s0)
        safestrcpy(full + 1, path, MAXPATH - 1);
    80005fe2:	07f00613          	li	a2,127
    80005fe6:	f5040593          	addi	a1,s0,-176
    80005fea:	ec940513          	addi	a0,s0,-311
    80005fee:	e25fa0ef          	jal	80000e12 <safestrcpy>
    }

    safestrcpy(f->path, full, MAXPATH);
    80005ff2:	08000613          	li	a2,128
    80005ff6:	ec840593          	addi	a1,s0,-312
    80005ffa:	02690513          	addi	a0,s2,38
    80005ffe:	e15fa0ef          	jal	80000e12 <safestrcpy>
}

  if(ip->type == T_DEVICE){
    80006002:	04449703          	lh	a4,68(s1)
    80006006:	478d                	li	a5,3
    80006008:	10f70063          	beq	a4,a5,80006108 <sys_open+0x1d2>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000600c:	4789                	li	a5,2
    8000600e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80006012:	02092023          	sw	zero,32(s2)
  }

  f->ip = ip;
    80006016:	00993c23          	sd	s1,24(s2)

  f->readable = !(omode & O_WRONLY);
    8000601a:	f4c42783          	lw	a5,-180(s0)
    8000601e:	0017c713          	xori	a4,a5,1
    80006022:	8b05                	andi	a4,a4,1
    80006024:	00e90423          	sb	a4,8(s2)

  f->writable =
      (omode & O_WRONLY) ||
    80006028:	0037f713          	andi	a4,a5,3
    8000602c:	00e03733          	snez	a4,a4
    80006030:	00e904a3          	sb	a4,9(s2)
      (omode & O_RDWR);

  if((omode & O_TRUNC) &&
    80006034:	4007f793          	andi	a5,a5,1024
    80006038:	c791                	beqz	a5,80006044 <sys_open+0x10e>
    8000603a:	04449703          	lh	a4,68(s1)
    8000603e:	4789                	li	a5,2
    80006040:	0cf70b63          	beq	a4,a5,80006116 <sys_open+0x1e0>
      ip->type == T_FILE){
    itrunc(ip);
  }

  iunlock(ip);
    80006044:	8526                	mv	a0,s1
    80006046:	995fd0ef          	jal	800039da <iunlock>
  end_op();
    8000604a:	86bfe0ef          	jal	800048b4 <end_op>

  state_update_file(
      myproc()->pid,
    8000604e:	8bbfb0ef          	jal	80001908 <myproc>
  state_update_file(
    80006052:	f5040693          	addi	a3,s0,-176
    80006056:	864a                	mv	a2,s2
    80006058:	85ce                	mv	a1,s3
    8000605a:	5908                	lw	a0,48(a0)
    8000605c:	693000ef          	jal	80006eee <state_update_file>
      fd,
      f,
      path
  );

  return fd;
    80006060:	854e                	mv	a0,s3
    80006062:	74b2                	ld	s1,296(sp)
    80006064:	7912                	ld	s2,288(sp)
    80006066:	69f2                	ld	s3,280(sp)
}
    80006068:	70f2                	ld	ra,312(sp)
    8000606a:	7452                	ld	s0,304(sp)
    8000606c:	6131                	addi	sp,sp,320
    8000606e:	8082                	ret
      end_op();
    80006070:	845fe0ef          	jal	800048b4 <end_op>
      return -1;
    80006074:	557d                	li	a0,-1
    80006076:	74b2                	ld	s1,296(sp)
    80006078:	bfc5                	j	80006068 <sys_open+0x132>
    if((ip = namei(path)) == 0){
    8000607a:	f5040513          	addi	a0,s0,-176
    8000607e:	acefe0ef          	jal	8000434c <namei>
    80006082:	84aa                	mv	s1,a0
    80006084:	c505                	beqz	a0,800060ac <sys_open+0x176>
    ilock(ip);
    80006086:	863fd0ef          	jal	800038e8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000608a:	04449703          	lh	a4,68(s1)
    8000608e:	4785                	li	a5,1
    80006090:	f0f715e3          	bne	a4,a5,80005f9a <sys_open+0x64>
    80006094:	f4c42783          	lw	a5,-180(s0)
    80006098:	f0078be3          	beqz	a5,80005fae <sys_open+0x78>
      iunlockput(ip);
    8000609c:	8526                	mv	a0,s1
    8000609e:	b27fd0ef          	jal	80003bc4 <iunlockput>
      end_op();
    800060a2:	813fe0ef          	jal	800048b4 <end_op>
      return -1;
    800060a6:	557d                	li	a0,-1
    800060a8:	74b2                	ld	s1,296(sp)
    800060aa:	bf7d                	j	80006068 <sys_open+0x132>
      end_op();
    800060ac:	809fe0ef          	jal	800048b4 <end_op>
      return -1;
    800060b0:	557d                	li	a0,-1
    800060b2:	74b2                	ld	s1,296(sp)
    800060b4:	bf55                	j	80006068 <sys_open+0x132>
    iunlockput(ip);
    800060b6:	8526                	mv	a0,s1
    800060b8:	b0dfd0ef          	jal	80003bc4 <iunlockput>
    end_op();
    800060bc:	ff8fe0ef          	jal	800048b4 <end_op>
    return -1;
    800060c0:	557d                	li	a0,-1
    800060c2:	74b2                	ld	s1,296(sp)
    800060c4:	b755                	j	80006068 <sys_open+0x132>
      fileclose(f);
    800060c6:	854a                	mv	a0,s2
    800060c8:	e09fe0ef          	jal	80004ed0 <fileclose>
    800060cc:	69f2                	ld	s3,280(sp)
    iunlockput(ip);
    800060ce:	8526                	mv	a0,s1
    800060d0:	af5fd0ef          	jal	80003bc4 <iunlockput>
    end_op();
    800060d4:	fe0fe0ef          	jal	800048b4 <end_op>
    return -1;
    800060d8:	557d                	li	a0,-1
    800060da:	74b2                	ld	s1,296(sp)
    800060dc:	7912                	ld	s2,288(sp)
    800060de:	b769                	j	80006068 <sys_open+0x132>
    safestrcpy(f->path, path, MAXPATH);
    800060e0:	08000613          	li	a2,128
    800060e4:	f5040593          	addi	a1,s0,-176
    800060e8:	02690513          	addi	a0,s2,38
    800060ec:	d27fa0ef          	jal	80000e12 <safestrcpy>
    800060f0:	bf09                	j	80006002 <sys_open+0xcc>
        safestrcpy(full, "/", MAXPATH);
    800060f2:	08000613          	li	a2,128
    800060f6:	00002597          	auipc	a1,0x2
    800060fa:	09258593          	addi	a1,a1,146 # 80008188 <etext+0x188>
    800060fe:	ec840513          	addi	a0,s0,-312
    80006102:	d11fa0ef          	jal	80000e12 <safestrcpy>
    80006106:	b5f5                	j	80005ff2 <sys_open+0xbc>
    f->type = FD_DEVICE;
    80006108:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000610c:	04649783          	lh	a5,70(s1)
    80006110:	02f91223          	sh	a5,36(s2)
    80006114:	b709                	j	80006016 <sys_open+0xe0>
    itrunc(ip);
    80006116:	8526                	mv	a0,s1
    80006118:	925fd0ef          	jal	80003a3c <itrunc>
    8000611c:	b725                	j	80006044 <sys_open+0x10e>

000000008000611e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000611e:	7175                	addi	sp,sp,-144
    80006120:	e506                	sd	ra,136(sp)
    80006122:	e122                	sd	s0,128(sp)
    80006124:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;
  
  safestrcpy(myproc()->current_syscall,
    80006126:	fe2fb0ef          	jal	80001908 <myproc>
    8000612a:	02000613          	li	a2,32
    8000612e:	00003597          	auipc	a1,0x3
    80006132:	caa58593          	addi	a1,a1,-854 # 80008dd8 <etext+0xdd8>
    80006136:	16850513          	addi	a0,a0,360
    8000613a:	cd9fa0ef          	jal	80000e12 <safestrcpy>
             "MKDIR",
             sizeof(myproc()->current_syscall));
  begin_op();
    8000613e:	e58fe0ef          	jal	80004796 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006142:	08000613          	li	a2,128
    80006146:	f7040593          	addi	a1,s0,-144
    8000614a:	4501                	li	a0,0
    8000614c:	f08fc0ef          	jal	80002854 <argstr>
    80006150:	02054363          	bltz	a0,80006176 <sys_mkdir+0x58>
    80006154:	4681                	li	a3,0
    80006156:	4601                	li	a2,0
    80006158:	4585                	li	a1,1
    8000615a:	f7040513          	addi	a0,s0,-144
    8000615e:	82fff0ef          	jal	8000598c <create>
    80006162:	c911                	beqz	a0,80006176 <sys_mkdir+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006164:	a61fd0ef          	jal	80003bc4 <iunlockput>
  end_op();
    80006168:	f4cfe0ef          	jal	800048b4 <end_op>
  return 0;
    8000616c:	4501                	li	a0,0
}
    8000616e:	60aa                	ld	ra,136(sp)
    80006170:	640a                	ld	s0,128(sp)
    80006172:	6149                	addi	sp,sp,144
    80006174:	8082                	ret
    end_op();
    80006176:	f3efe0ef          	jal	800048b4 <end_op>
    return -1;
    8000617a:	557d                	li	a0,-1
    8000617c:	bfcd                	j	8000616e <sys_mkdir+0x50>

000000008000617e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000617e:	7135                	addi	sp,sp,-160
    80006180:	ed06                	sd	ra,152(sp)
    80006182:	e922                	sd	s0,144(sp)
    80006184:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006186:	e10fe0ef          	jal	80004796 <begin_op>
  argint(1, &major);
    8000618a:	f6c40593          	addi	a1,s0,-148
    8000618e:	4505                	li	a0,1
    80006190:	e8cfc0ef          	jal	8000281c <argint>
  argint(2, &minor);
    80006194:	f6840593          	addi	a1,s0,-152
    80006198:	4509                	li	a0,2
    8000619a:	e82fc0ef          	jal	8000281c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000619e:	08000613          	li	a2,128
    800061a2:	f7040593          	addi	a1,s0,-144
    800061a6:	4501                	li	a0,0
    800061a8:	eacfc0ef          	jal	80002854 <argstr>
    800061ac:	02054563          	bltz	a0,800061d6 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800061b0:	f6841683          	lh	a3,-152(s0)
    800061b4:	f6c41603          	lh	a2,-148(s0)
    800061b8:	458d                	li	a1,3
    800061ba:	f7040513          	addi	a0,s0,-144
    800061be:	fceff0ef          	jal	8000598c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800061c2:	c911                	beqz	a0,800061d6 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800061c4:	a01fd0ef          	jal	80003bc4 <iunlockput>
  end_op();
    800061c8:	eecfe0ef          	jal	800048b4 <end_op>
  return 0;
    800061cc:	4501                	li	a0,0
}
    800061ce:	60ea                	ld	ra,152(sp)
    800061d0:	644a                	ld	s0,144(sp)
    800061d2:	610d                	addi	sp,sp,160
    800061d4:	8082                	ret
    end_op();
    800061d6:	edefe0ef          	jal	800048b4 <end_op>
    return -1;
    800061da:	557d                	li	a0,-1
    800061dc:	bfcd                	j	800061ce <sys_mknod+0x50>

00000000800061de <sys_chdir>:

uint64
sys_chdir(void)
{
    800061de:	7135                	addi	sp,sp,-160
    800061e0:	ed06                	sd	ra,152(sp)
    800061e2:	e922                	sd	s0,144(sp)
    800061e4:	e14a                	sd	s2,128(sp)
    800061e6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800061e8:	f20fb0ef          	jal	80001908 <myproc>
    800061ec:	892a                	mv	s2,a0
  
  safestrcpy(myproc()->current_syscall,
    800061ee:	f1afb0ef          	jal	80001908 <myproc>
    800061f2:	02000613          	li	a2,32
    800061f6:	00003597          	auipc	a1,0x3
    800061fa:	bea58593          	addi	a1,a1,-1046 # 80008de0 <etext+0xde0>
    800061fe:	16850513          	addi	a0,a0,360
    80006202:	c11fa0ef          	jal	80000e12 <safestrcpy>
             "CHDIR",
             sizeof(myproc()->current_syscall));
  begin_op();
    80006206:	d90fe0ef          	jal	80004796 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000620a:	08000613          	li	a2,128
    8000620e:	f6040593          	addi	a1,s0,-160
    80006212:	4501                	li	a0,0
    80006214:	e40fc0ef          	jal	80002854 <argstr>
    80006218:	04054363          	bltz	a0,8000625e <sys_chdir+0x80>
    8000621c:	e526                	sd	s1,136(sp)
    8000621e:	f6040513          	addi	a0,s0,-160
    80006222:	92afe0ef          	jal	8000434c <namei>
    80006226:	84aa                	mv	s1,a0
    80006228:	c915                	beqz	a0,8000625c <sys_chdir+0x7e>
    end_op();
    return -1;
  }
  ilock(ip);
    8000622a:	ebefd0ef          	jal	800038e8 <ilock>
  if(ip->type != T_DIR){
    8000622e:	04449703          	lh	a4,68(s1)
    80006232:	4785                	li	a5,1
    80006234:	02f71963          	bne	a4,a5,80006266 <sys_chdir+0x88>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006238:	8526                	mv	a0,s1
    8000623a:	fa0fd0ef          	jal	800039da <iunlock>
  
  // 🔥 تصحيح: يجب بقاء الحذف البرمجي للـ cwd القديم داخل نطاق الـ FS Transaction
  iput(p->cwd);
    8000623e:	15093503          	ld	a0,336(s2)
    80006242:	8b7fd0ef          	jal	80003af8 <iput>
  p->cwd = ip;
    80006246:	14993823          	sd	s1,336(s2)
  end_op();
    8000624a:	e6afe0ef          	jal	800048b4 <end_op>
  
  return 0;
    8000624e:	4501                	li	a0,0
    80006250:	64aa                	ld	s1,136(sp)
}
    80006252:	60ea                	ld	ra,152(sp)
    80006254:	644a                	ld	s0,144(sp)
    80006256:	690a                	ld	s2,128(sp)
    80006258:	610d                	addi	sp,sp,160
    8000625a:	8082                	ret
    8000625c:	64aa                	ld	s1,136(sp)
    end_op();
    8000625e:	e56fe0ef          	jal	800048b4 <end_op>
    return -1;
    80006262:	557d                	li	a0,-1
    80006264:	b7fd                	j	80006252 <sys_chdir+0x74>
    iunlockput(ip);
    80006266:	8526                	mv	a0,s1
    80006268:	95dfd0ef          	jal	80003bc4 <iunlockput>
    end_op();
    8000626c:	e48fe0ef          	jal	800048b4 <end_op>
    return -1;
    80006270:	557d                	li	a0,-1
    80006272:	64aa                	ld	s1,136(sp)
    80006274:	bff9                	j	80006252 <sys_chdir+0x74>

0000000080006276 <sys_exec>:

uint64
sys_exec(void)
{
    80006276:	7121                	addi	sp,sp,-448
    80006278:	ff06                	sd	ra,440(sp)
    8000627a:	fb22                	sd	s0,432(sp)
    8000627c:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000627e:	e4840593          	addi	a1,s0,-440
    80006282:	4505                	li	a0,1
    80006284:	db4fc0ef          	jal	80002838 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006288:	08000613          	li	a2,128
    8000628c:	f5040593          	addi	a1,s0,-176
    80006290:	4501                	li	a0,0
    80006292:	dc2fc0ef          	jal	80002854 <argstr>
    80006296:	87aa                	mv	a5,a0
    return -1;
    80006298:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000629a:	0c07c463          	bltz	a5,80006362 <sys_exec+0xec>
    8000629e:	f726                	sd	s1,424(sp)
    800062a0:	f34a                	sd	s2,416(sp)
    800062a2:	ef4e                	sd	s3,408(sp)
    800062a4:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800062a6:	10000613          	li	a2,256
    800062aa:	4581                	li	a1,0
    800062ac:	e5040513          	addi	a0,s0,-432
    800062b0:	a25fa0ef          	jal	80000cd4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800062b4:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800062b8:	89a6                	mv	s3,s1
    800062ba:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800062bc:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800062c0:	00391513          	slli	a0,s2,0x3
    800062c4:	e4040593          	addi	a1,s0,-448
    800062c8:	e4843783          	ld	a5,-440(s0)
    800062cc:	953e                	add	a0,a0,a5
    800062ce:	cc4fc0ef          	jal	80002792 <fetchaddr>
    800062d2:	02054663          	bltz	a0,800062fe <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800062d6:	e4043783          	ld	a5,-448(s0)
    800062da:	c3a9                	beqz	a5,8000631c <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800062dc:	855fa0ef          	jal	80000b30 <kalloc>
    800062e0:	85aa                	mv	a1,a0
    800062e2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800062e6:	cd01                	beqz	a0,800062fe <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800062e8:	6605                	lui	a2,0x1
    800062ea:	e4043503          	ld	a0,-448(s0)
    800062ee:	ceefc0ef          	jal	800027dc <fetchstr>
    800062f2:	00054663          	bltz	a0,800062fe <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800062f6:	0905                	addi	s2,s2,1
    800062f8:	09a1                	addi	s3,s3,8
    800062fa:	fd4913e3          	bne	s2,s4,800062c0 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++) {
    800062fe:	f5040913          	addi	s2,s0,-176
    80006302:	6088                	ld	a0,0(s1)
    80006304:	c931                	beqz	a0,80006358 <sys_exec+0xe2>
    if(argv[i] != 0)
      kfree(argv[i]);
    80006306:	f48fa0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++) {
    8000630a:	04a1                	addi	s1,s1,8
    8000630c:	ff249be3          	bne	s1,s2,80006302 <sys_exec+0x8c>
  }
  return -1;
    80006310:	557d                	li	a0,-1
    80006312:	74ba                	ld	s1,424(sp)
    80006314:	791a                	ld	s2,416(sp)
    80006316:	69fa                	ld	s3,408(sp)
    80006318:	6a5a                	ld	s4,400(sp)
    8000631a:	a0a1                	j	80006362 <sys_exec+0xec>
      argv[i] = 0;
    8000631c:	0009079b          	sext.w	a5,s2
    80006320:	078e                	slli	a5,a5,0x3
    80006322:	fd078793          	addi	a5,a5,-48
    80006326:	97a2                	add	a5,a5,s0
    80006328:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    8000632c:	e5040593          	addi	a1,s0,-432
    80006330:	f5040513          	addi	a0,s0,-176
    80006334:	a50ff0ef          	jal	80005584 <kexec>
    80006338:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000633a:	f5040993          	addi	s3,s0,-176
    8000633e:	6088                	ld	a0,0(s1)
    80006340:	c511                	beqz	a0,8000634c <sys_exec+0xd6>
    kfree(argv[i]);
    80006342:	f0cfa0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006346:	04a1                	addi	s1,s1,8
    80006348:	ff349be3          	bne	s1,s3,8000633e <sys_exec+0xc8>
  return ret;
    8000634c:	854a                	mv	a0,s2
    8000634e:	74ba                	ld	s1,424(sp)
    80006350:	791a                	ld	s2,416(sp)
    80006352:	69fa                	ld	s3,408(sp)
    80006354:	6a5a                	ld	s4,400(sp)
    80006356:	a031                	j	80006362 <sys_exec+0xec>
  return -1;
    80006358:	557d                	li	a0,-1
    8000635a:	74ba                	ld	s1,424(sp)
    8000635c:	791a                	ld	s2,416(sp)
    8000635e:	69fa                	ld	s3,408(sp)
    80006360:	6a5a                	ld	s4,400(sp)
}
    80006362:	70fa                	ld	ra,440(sp)
    80006364:	745a                	ld	s0,432(sp)
    80006366:	6139                	addi	sp,sp,448
    80006368:	8082                	ret

000000008000636a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000636a:	7139                	addi	sp,sp,-64
    8000636c:	fc06                	sd	ra,56(sp)
    8000636e:	f822                	sd	s0,48(sp)
    80006370:	f426                	sd	s1,40(sp)
    80006372:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006374:	d94fb0ef          	jal	80001908 <myproc>
    80006378:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000637a:	fd840593          	addi	a1,s0,-40
    8000637e:	4501                	li	a0,0
    80006380:	cb8fc0ef          	jal	80002838 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006384:	fc840593          	addi	a1,s0,-56
    80006388:	fd040513          	addi	a0,s0,-48
    8000638c:	efbfe0ef          	jal	80005286 <pipealloc>
    return -1;
    80006390:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006392:	0a054463          	bltz	a0,8000643a <sys_pipe+0xd0>
  fd0 = -1;
    80006396:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000639a:	fd043503          	ld	a0,-48(s0)
    8000639e:	d58ff0ef          	jal	800058f6 <fdalloc>
    800063a2:	fca42223          	sw	a0,-60(s0)
    800063a6:	08054163          	bltz	a0,80006428 <sys_pipe+0xbe>
    800063aa:	fc843503          	ld	a0,-56(s0)
    800063ae:	d48ff0ef          	jal	800058f6 <fdalloc>
    800063b2:	fca42023          	sw	a0,-64(s0)
    800063b6:	06054063          	bltz	a0,80006416 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800063ba:	4691                	li	a3,4
    800063bc:	fc440613          	addi	a2,s0,-60
    800063c0:	fd843583          	ld	a1,-40(s0)
    800063c4:	68a8                	ld	a0,80(s1)
    800063c6:	a56fb0ef          	jal	8000161c <copyout>
    800063ca:	00054e63          	bltz	a0,800063e6 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800063ce:	4691                	li	a3,4
    800063d0:	fc040613          	addi	a2,s0,-64
    800063d4:	fd843583          	ld	a1,-40(s0)
    800063d8:	0591                	addi	a1,a1,4
    800063da:	68a8                	ld	a0,80(s1)
    800063dc:	a40fb0ef          	jal	8000161c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800063e0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800063e2:	04055c63          	bgez	a0,8000643a <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800063e6:	fc442783          	lw	a5,-60(s0)
    800063ea:	07e9                	addi	a5,a5,26
    800063ec:	078e                	slli	a5,a5,0x3
    800063ee:	97a6                	add	a5,a5,s1
    800063f0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800063f4:	fc042783          	lw	a5,-64(s0)
    800063f8:	07e9                	addi	a5,a5,26
    800063fa:	078e                	slli	a5,a5,0x3
    800063fc:	94be                	add	s1,s1,a5
    800063fe:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006402:	fd043503          	ld	a0,-48(s0)
    80006406:	acbfe0ef          	jal	80004ed0 <fileclose>
    fileclose(wf);
    8000640a:	fc843503          	ld	a0,-56(s0)
    8000640e:	ac3fe0ef          	jal	80004ed0 <fileclose>
    return -1;
    80006412:	57fd                	li	a5,-1
    80006414:	a01d                	j	8000643a <sys_pipe+0xd0>
    if(fd0 >= 0)
    80006416:	fc442783          	lw	a5,-60(s0)
    8000641a:	0007c763          	bltz	a5,80006428 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000641e:	07e9                	addi	a5,a5,26
    80006420:	078e                	slli	a5,a5,0x3
    80006422:	97a6                	add	a5,a5,s1
    80006424:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006428:	fd043503          	ld	a0,-48(s0)
    8000642c:	aa5fe0ef          	jal	80004ed0 <fileclose>
    fileclose(wf);
    80006430:	fc843503          	ld	a0,-56(s0)
    80006434:	a9dfe0ef          	jal	80004ed0 <fileclose>
    return -1;
    80006438:	57fd                	li	a5,-1
}
    8000643a:	853e                	mv	a0,a5
    8000643c:	70e2                	ld	ra,56(sp)
    8000643e:	7442                	ld	s0,48(sp)
    80006440:	74a2                	ld	s1,40(sp)
    80006442:	6121                	addi	sp,sp,64
    80006444:	8082                	ret

0000000080006446 <sys_fsread>:

uint64
sys_fsread(void)
{
    80006446:	1101                	addi	sp,sp,-32
    80006448:	ec06                	sd	ra,24(sp)
    8000644a:	e822                	sd	s0,16(sp)
    8000644c:	1000                	addi	s0,sp,32
  uint64 uaddr;
  int max;

  argaddr(0, &uaddr);   
    8000644e:	fe840593          	addi	a1,s0,-24
    80006452:	4501                	li	a0,0
    80006454:	be4fc0ef          	jal	80002838 <argaddr>
  argint(1, &max);      
    80006458:	fe440593          	addi	a1,s0,-28
    8000645c:	4505                	li	a0,1
    8000645e:	bbefc0ef          	jal	8000281c <argint>

  return fslog_read_many((struct fs_event *)uaddr, max);
    80006462:	fe442583          	lw	a1,-28(s0)
    80006466:	fe843503          	ld	a0,-24(s0)
    8000646a:	1e1000ef          	jal	80006e4a <fslog_read_many>
    8000646e:	60e2                	ld	ra,24(sp)
    80006470:	6442                	ld	s0,16(sp)
    80006472:	6105                	addi	sp,sp,32
    80006474:	8082                	ret
	...

0000000080006480 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80006480:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80006482:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80006484:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80006486:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80006488:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000648a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000648c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000648e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80006490:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80006492:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80006494:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80006496:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80006498:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000649a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000649c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000649e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800064a0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800064a2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800064a4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800064a6:	9fcfc0ef          	jal	800026a2 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800064aa:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800064ac:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800064ae:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800064b0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800064b2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800064b4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800064b6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800064b8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800064ba:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800064bc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800064be:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800064c0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800064c2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800064c4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800064c6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800064c8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800064ca:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800064cc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800064ce:	10200073          	sret
	...

00000000800064de <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800064de:	1141                	addi	sp,sp,-16
    800064e0:	e422                	sd	s0,8(sp)
    800064e2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800064e4:	0c0007b7          	lui	a5,0xc000
    800064e8:	4705                	li	a4,1
    800064ea:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800064ec:	0c0007b7          	lui	a5,0xc000
    800064f0:	c3d8                	sw	a4,4(a5)
}
    800064f2:	6422                	ld	s0,8(sp)
    800064f4:	0141                	addi	sp,sp,16
    800064f6:	8082                	ret

00000000800064f8 <plicinithart>:

void
plicinithart(void)
{
    800064f8:	1141                	addi	sp,sp,-16
    800064fa:	e406                	sd	ra,8(sp)
    800064fc:	e022                	sd	s0,0(sp)
    800064fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006500:	bdcfb0ef          	jal	800018dc <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006504:	0085171b          	slliw	a4,a0,0x8
    80006508:	0c0027b7          	lui	a5,0xc002
    8000650c:	97ba                	add	a5,a5,a4
    8000650e:	40200713          	li	a4,1026
    80006512:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006516:	00d5151b          	slliw	a0,a0,0xd
    8000651a:	0c2017b7          	lui	a5,0xc201
    8000651e:	97aa                	add	a5,a5,a0
    80006520:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006524:	60a2                	ld	ra,8(sp)
    80006526:	6402                	ld	s0,0(sp)
    80006528:	0141                	addi	sp,sp,16
    8000652a:	8082                	ret

000000008000652c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000652c:	1141                	addi	sp,sp,-16
    8000652e:	e406                	sd	ra,8(sp)
    80006530:	e022                	sd	s0,0(sp)
    80006532:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006534:	ba8fb0ef          	jal	800018dc <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006538:	00d5151b          	slliw	a0,a0,0xd
    8000653c:	0c2017b7          	lui	a5,0xc201
    80006540:	97aa                	add	a5,a5,a0
  return irq;
}
    80006542:	43c8                	lw	a0,4(a5)
    80006544:	60a2                	ld	ra,8(sp)
    80006546:	6402                	ld	s0,0(sp)
    80006548:	0141                	addi	sp,sp,16
    8000654a:	8082                	ret

000000008000654c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000654c:	1101                	addi	sp,sp,-32
    8000654e:	ec06                	sd	ra,24(sp)
    80006550:	e822                	sd	s0,16(sp)
    80006552:	e426                	sd	s1,8(sp)
    80006554:	1000                	addi	s0,sp,32
    80006556:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006558:	b84fb0ef          	jal	800018dc <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000655c:	00d5151b          	slliw	a0,a0,0xd
    80006560:	0c2017b7          	lui	a5,0xc201
    80006564:	97aa                	add	a5,a5,a0
    80006566:	c3c4                	sw	s1,4(a5)
}
    80006568:	60e2                	ld	ra,24(sp)
    8000656a:	6442                	ld	s0,16(sp)
    8000656c:	64a2                	ld	s1,8(sp)
    8000656e:	6105                	addi	sp,sp,32
    80006570:	8082                	ret

0000000080006572 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006572:	1141                	addi	sp,sp,-16
    80006574:	e406                	sd	ra,8(sp)
    80006576:	e022                	sd	s0,0(sp)
    80006578:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000657a:	479d                	li	a5,7
    8000657c:	04a7ca63          	blt	a5,a0,800065d0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80006580:	0001f797          	auipc	a5,0x1f
    80006584:	72878793          	addi	a5,a5,1832 # 80025ca8 <disk>
    80006588:	97aa                	add	a5,a5,a0
    8000658a:	0187c783          	lbu	a5,24(a5)
    8000658e:	e7b9                	bnez	a5,800065dc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006590:	00451693          	slli	a3,a0,0x4
    80006594:	0001f797          	auipc	a5,0x1f
    80006598:	71478793          	addi	a5,a5,1812 # 80025ca8 <disk>
    8000659c:	6398                	ld	a4,0(a5)
    8000659e:	9736                	add	a4,a4,a3
    800065a0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800065a4:	6398                	ld	a4,0(a5)
    800065a6:	9736                	add	a4,a4,a3
    800065a8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800065ac:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800065b0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800065b4:	97aa                	add	a5,a5,a0
    800065b6:	4705                	li	a4,1
    800065b8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800065bc:	0001f517          	auipc	a0,0x1f
    800065c0:	70450513          	addi	a0,a0,1796 # 80025cc0 <disk+0x18>
    800065c4:	9a1fb0ef          	jal	80001f64 <wakeup>
}
    800065c8:	60a2                	ld	ra,8(sp)
    800065ca:	6402                	ld	s0,0(sp)
    800065cc:	0141                	addi	sp,sp,16
    800065ce:	8082                	ret
    panic("free_desc 1");
    800065d0:	00003517          	auipc	a0,0x3
    800065d4:	81850513          	addi	a0,a0,-2024 # 80008de8 <etext+0xde8>
    800065d8:	a3afa0ef          	jal	80000812 <panic>
    panic("free_desc 2");
    800065dc:	00003517          	auipc	a0,0x3
    800065e0:	81c50513          	addi	a0,a0,-2020 # 80008df8 <etext+0xdf8>
    800065e4:	a2efa0ef          	jal	80000812 <panic>

00000000800065e8 <virtio_disk_init>:
{
    800065e8:	1101                	addi	sp,sp,-32
    800065ea:	ec06                	sd	ra,24(sp)
    800065ec:	e822                	sd	s0,16(sp)
    800065ee:	e426                	sd	s1,8(sp)
    800065f0:	e04a                	sd	s2,0(sp)
    800065f2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800065f4:	00003597          	auipc	a1,0x3
    800065f8:	81458593          	addi	a1,a1,-2028 # 80008e08 <etext+0xe08>
    800065fc:	0001f517          	auipc	a0,0x1f
    80006600:	7d450513          	addi	a0,a0,2004 # 80025dd0 <disk+0x128>
    80006604:	d7cfa0ef          	jal	80000b80 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006608:	100017b7          	lui	a5,0x10001
    8000660c:	4398                	lw	a4,0(a5)
    8000660e:	2701                	sext.w	a4,a4
    80006610:	747277b7          	lui	a5,0x74727
    80006614:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006618:	18f71063          	bne	a4,a5,80006798 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000661c:	100017b7          	lui	a5,0x10001
    80006620:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80006622:	439c                	lw	a5,0(a5)
    80006624:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006626:	4709                	li	a4,2
    80006628:	16e79863          	bne	a5,a4,80006798 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000662c:	100017b7          	lui	a5,0x10001
    80006630:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80006632:	439c                	lw	a5,0(a5)
    80006634:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006636:	16e79163          	bne	a5,a4,80006798 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000663a:	100017b7          	lui	a5,0x10001
    8000663e:	47d8                	lw	a4,12(a5)
    80006640:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006642:	554d47b7          	lui	a5,0x554d4
    80006646:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000664a:	14f71763          	bne	a4,a5,80006798 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000664e:	100017b7          	lui	a5,0x10001
    80006652:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006656:	4705                	li	a4,1
    80006658:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000665a:	470d                	li	a4,3
    8000665c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000665e:	10001737          	lui	a4,0x10001
    80006662:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006664:	c7ffe737          	lui	a4,0xc7ffe
    80006668:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47f98917>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000666c:	8ef9                	and	a3,a3,a4
    8000666e:	10001737          	lui	a4,0x10001
    80006672:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006674:	472d                	li	a4,11
    80006676:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006678:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000667c:	439c                	lw	a5,0(a5)
    8000667e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006682:	8ba1                	andi	a5,a5,8
    80006684:	12078063          	beqz	a5,800067a4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006688:	100017b7          	lui	a5,0x10001
    8000668c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006690:	100017b7          	lui	a5,0x10001
    80006694:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006698:	439c                	lw	a5,0(a5)
    8000669a:	2781                	sext.w	a5,a5
    8000669c:	10079a63          	bnez	a5,800067b0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800066a0:	100017b7          	lui	a5,0x10001
    800066a4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800066a8:	439c                	lw	a5,0(a5)
    800066aa:	2781                	sext.w	a5,a5
  if(max == 0)
    800066ac:	10078863          	beqz	a5,800067bc <virtio_disk_init+0x1d4>
  if(max < NUM)
    800066b0:	471d                	li	a4,7
    800066b2:	10f77b63          	bgeu	a4,a5,800067c8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800066b6:	c7afa0ef          	jal	80000b30 <kalloc>
    800066ba:	0001f497          	auipc	s1,0x1f
    800066be:	5ee48493          	addi	s1,s1,1518 # 80025ca8 <disk>
    800066c2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800066c4:	c6cfa0ef          	jal	80000b30 <kalloc>
    800066c8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800066ca:	c66fa0ef          	jal	80000b30 <kalloc>
    800066ce:	87aa                	mv	a5,a0
    800066d0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800066d2:	6088                	ld	a0,0(s1)
    800066d4:	10050063          	beqz	a0,800067d4 <virtio_disk_init+0x1ec>
    800066d8:	0001f717          	auipc	a4,0x1f
    800066dc:	5d873703          	ld	a4,1496(a4) # 80025cb0 <disk+0x8>
    800066e0:	0e070a63          	beqz	a4,800067d4 <virtio_disk_init+0x1ec>
    800066e4:	0e078863          	beqz	a5,800067d4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800066e8:	6605                	lui	a2,0x1
    800066ea:	4581                	li	a1,0
    800066ec:	de8fa0ef          	jal	80000cd4 <memset>
  memset(disk.avail, 0, PGSIZE);
    800066f0:	0001f497          	auipc	s1,0x1f
    800066f4:	5b848493          	addi	s1,s1,1464 # 80025ca8 <disk>
    800066f8:	6605                	lui	a2,0x1
    800066fa:	4581                	li	a1,0
    800066fc:	6488                	ld	a0,8(s1)
    800066fe:	dd6fa0ef          	jal	80000cd4 <memset>
  memset(disk.used, 0, PGSIZE);
    80006702:	6605                	lui	a2,0x1
    80006704:	4581                	li	a1,0
    80006706:	6888                	ld	a0,16(s1)
    80006708:	dccfa0ef          	jal	80000cd4 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000670c:	100017b7          	lui	a5,0x10001
    80006710:	4721                	li	a4,8
    80006712:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006714:	4098                	lw	a4,0(s1)
    80006716:	100017b7          	lui	a5,0x10001
    8000671a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000671e:	40d8                	lw	a4,4(s1)
    80006720:	100017b7          	lui	a5,0x10001
    80006724:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006728:	649c                	ld	a5,8(s1)
    8000672a:	0007869b          	sext.w	a3,a5
    8000672e:	10001737          	lui	a4,0x10001
    80006732:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006736:	9781                	srai	a5,a5,0x20
    80006738:	10001737          	lui	a4,0x10001
    8000673c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006740:	689c                	ld	a5,16(s1)
    80006742:	0007869b          	sext.w	a3,a5
    80006746:	10001737          	lui	a4,0x10001
    8000674a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000674e:	9781                	srai	a5,a5,0x20
    80006750:	10001737          	lui	a4,0x10001
    80006754:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006758:	10001737          	lui	a4,0x10001
    8000675c:	4785                	li	a5,1
    8000675e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006760:	00f48c23          	sb	a5,24(s1)
    80006764:	00f48ca3          	sb	a5,25(s1)
    80006768:	00f48d23          	sb	a5,26(s1)
    8000676c:	00f48da3          	sb	a5,27(s1)
    80006770:	00f48e23          	sb	a5,28(s1)
    80006774:	00f48ea3          	sb	a5,29(s1)
    80006778:	00f48f23          	sb	a5,30(s1)
    8000677c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006780:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006784:	100017b7          	lui	a5,0x10001
    80006788:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000678c:	60e2                	ld	ra,24(sp)
    8000678e:	6442                	ld	s0,16(sp)
    80006790:	64a2                	ld	s1,8(sp)
    80006792:	6902                	ld	s2,0(sp)
    80006794:	6105                	addi	sp,sp,32
    80006796:	8082                	ret
    panic("could not find virtio disk");
    80006798:	00002517          	auipc	a0,0x2
    8000679c:	68050513          	addi	a0,a0,1664 # 80008e18 <etext+0xe18>
    800067a0:	872fa0ef          	jal	80000812 <panic>
    panic("virtio disk FEATURES_OK unset");
    800067a4:	00002517          	auipc	a0,0x2
    800067a8:	69450513          	addi	a0,a0,1684 # 80008e38 <etext+0xe38>
    800067ac:	866fa0ef          	jal	80000812 <panic>
    panic("virtio disk should not be ready");
    800067b0:	00002517          	auipc	a0,0x2
    800067b4:	6a850513          	addi	a0,a0,1704 # 80008e58 <etext+0xe58>
    800067b8:	85afa0ef          	jal	80000812 <panic>
    panic("virtio disk has no queue 0");
    800067bc:	00002517          	auipc	a0,0x2
    800067c0:	6bc50513          	addi	a0,a0,1724 # 80008e78 <etext+0xe78>
    800067c4:	84efa0ef          	jal	80000812 <panic>
    panic("virtio disk max queue too short");
    800067c8:	00002517          	auipc	a0,0x2
    800067cc:	6d050513          	addi	a0,a0,1744 # 80008e98 <etext+0xe98>
    800067d0:	842fa0ef          	jal	80000812 <panic>
    panic("virtio disk kalloc");
    800067d4:	00002517          	auipc	a0,0x2
    800067d8:	6e450513          	addi	a0,a0,1764 # 80008eb8 <etext+0xeb8>
    800067dc:	836fa0ef          	jal	80000812 <panic>

00000000800067e0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800067e0:	7159                	addi	sp,sp,-112
    800067e2:	f486                	sd	ra,104(sp)
    800067e4:	f0a2                	sd	s0,96(sp)
    800067e6:	eca6                	sd	s1,88(sp)
    800067e8:	e8ca                	sd	s2,80(sp)
    800067ea:	e4ce                	sd	s3,72(sp)
    800067ec:	e0d2                	sd	s4,64(sp)
    800067ee:	fc56                	sd	s5,56(sp)
    800067f0:	f85a                	sd	s6,48(sp)
    800067f2:	f45e                	sd	s7,40(sp)
    800067f4:	f062                	sd	s8,32(sp)
    800067f6:	ec66                	sd	s9,24(sp)
    800067f8:	1880                	addi	s0,sp,112
    800067fa:	8a2a                	mv	s4,a0
    800067fc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800067fe:	00c52c83          	lw	s9,12(a0)
    80006802:	001c9c9b          	slliw	s9,s9,0x1
    80006806:	1c82                	slli	s9,s9,0x20
    80006808:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000680c:	0001f517          	auipc	a0,0x1f
    80006810:	5c450513          	addi	a0,a0,1476 # 80025dd0 <disk+0x128>
    80006814:	becfa0ef          	jal	80000c00 <acquire>
  for(int i = 0; i < 3; i++){
    80006818:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000681a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000681c:	0001fb17          	auipc	s6,0x1f
    80006820:	48cb0b13          	addi	s6,s6,1164 # 80025ca8 <disk>
  for(int i = 0; i < 3; i++){
    80006824:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006826:	0001fc17          	auipc	s8,0x1f
    8000682a:	5aac0c13          	addi	s8,s8,1450 # 80025dd0 <disk+0x128>
    8000682e:	a8b9                	j	8000688c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80006830:	00fb0733          	add	a4,s6,a5
    80006834:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006838:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000683a:	0207c563          	bltz	a5,80006864 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000683e:	2905                	addiw	s2,s2,1
    80006840:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006842:	05590963          	beq	s2,s5,80006894 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80006846:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006848:	0001f717          	auipc	a4,0x1f
    8000684c:	46070713          	addi	a4,a4,1120 # 80025ca8 <disk>
    80006850:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006852:	01874683          	lbu	a3,24(a4)
    80006856:	fee9                	bnez	a3,80006830 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80006858:	2785                	addiw	a5,a5,1
    8000685a:	0705                	addi	a4,a4,1
    8000685c:	fe979be3          	bne	a5,s1,80006852 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80006860:	57fd                	li	a5,-1
    80006862:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006864:	01205d63          	blez	s2,8000687e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006868:	f9042503          	lw	a0,-112(s0)
    8000686c:	d07ff0ef          	jal	80006572 <free_desc>
      for(int j = 0; j < i; j++)
    80006870:	4785                	li	a5,1
    80006872:	0127d663          	bge	a5,s2,8000687e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006876:	f9442503          	lw	a0,-108(s0)
    8000687a:	cf9ff0ef          	jal	80006572 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000687e:	85e2                	mv	a1,s8
    80006880:	0001f517          	auipc	a0,0x1f
    80006884:	44050513          	addi	a0,a0,1088 # 80025cc0 <disk+0x18>
    80006888:	e90fb0ef          	jal	80001f18 <sleep>
  for(int i = 0; i < 3; i++){
    8000688c:	f9040613          	addi	a2,s0,-112
    80006890:	894e                	mv	s2,s3
    80006892:	bf55                	j	80006846 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006894:	f9042503          	lw	a0,-112(s0)
    80006898:	00451693          	slli	a3,a0,0x4

  if(write)
    8000689c:	0001f797          	auipc	a5,0x1f
    800068a0:	40c78793          	addi	a5,a5,1036 # 80025ca8 <disk>
    800068a4:	00a50713          	addi	a4,a0,10
    800068a8:	0712                	slli	a4,a4,0x4
    800068aa:	973e                	add	a4,a4,a5
    800068ac:	01703633          	snez	a2,s7
    800068b0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800068b2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800068b6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800068ba:	6398                	ld	a4,0(a5)
    800068bc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800068be:	0a868613          	addi	a2,a3,168
    800068c2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800068c4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800068c6:	6390                	ld	a2,0(a5)
    800068c8:	00d605b3          	add	a1,a2,a3
    800068cc:	4741                	li	a4,16
    800068ce:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800068d0:	4805                	li	a6,1
    800068d2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800068d6:	f9442703          	lw	a4,-108(s0)
    800068da:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800068de:	0712                	slli	a4,a4,0x4
    800068e0:	963a                	add	a2,a2,a4
    800068e2:	058a0593          	addi	a1,s4,88
    800068e6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800068e8:	0007b883          	ld	a7,0(a5)
    800068ec:	9746                	add	a4,a4,a7
    800068ee:	40000613          	li	a2,1024
    800068f2:	c710                	sw	a2,8(a4)
  if(write)
    800068f4:	001bb613          	seqz	a2,s7
    800068f8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800068fc:	00166613          	ori	a2,a2,1
    80006900:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006904:	f9842583          	lw	a1,-104(s0)
    80006908:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000690c:	00250613          	addi	a2,a0,2
    80006910:	0612                	slli	a2,a2,0x4
    80006912:	963e                	add	a2,a2,a5
    80006914:	577d                	li	a4,-1
    80006916:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000691a:	0592                	slli	a1,a1,0x4
    8000691c:	98ae                	add	a7,a7,a1
    8000691e:	03068713          	addi	a4,a3,48
    80006922:	973e                	add	a4,a4,a5
    80006924:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006928:	6398                	ld	a4,0(a5)
    8000692a:	972e                	add	a4,a4,a1
    8000692c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006930:	4689                	li	a3,2
    80006932:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006936:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000693a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000693e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006942:	6794                	ld	a3,8(a5)
    80006944:	0026d703          	lhu	a4,2(a3)
    80006948:	8b1d                	andi	a4,a4,7
    8000694a:	0706                	slli	a4,a4,0x1
    8000694c:	96ba                	add	a3,a3,a4
    8000694e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006952:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006956:	6798                	ld	a4,8(a5)
    80006958:	00275783          	lhu	a5,2(a4)
    8000695c:	2785                	addiw	a5,a5,1
    8000695e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006962:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006966:	100017b7          	lui	a5,0x10001
    8000696a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000696e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006972:	0001f917          	auipc	s2,0x1f
    80006976:	45e90913          	addi	s2,s2,1118 # 80025dd0 <disk+0x128>
  while(b->disk == 1) {
    8000697a:	4485                	li	s1,1
    8000697c:	01079a63          	bne	a5,a6,80006990 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80006980:	85ca                	mv	a1,s2
    80006982:	8552                	mv	a0,s4
    80006984:	d94fb0ef          	jal	80001f18 <sleep>
  while(b->disk == 1) {
    80006988:	004a2783          	lw	a5,4(s4)
    8000698c:	fe978ae3          	beq	a5,s1,80006980 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80006990:	f9042903          	lw	s2,-112(s0)
    80006994:	00290713          	addi	a4,s2,2
    80006998:	0712                	slli	a4,a4,0x4
    8000699a:	0001f797          	auipc	a5,0x1f
    8000699e:	30e78793          	addi	a5,a5,782 # 80025ca8 <disk>
    800069a2:	97ba                	add	a5,a5,a4
    800069a4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800069a8:	0001f997          	auipc	s3,0x1f
    800069ac:	30098993          	addi	s3,s3,768 # 80025ca8 <disk>
    800069b0:	00491713          	slli	a4,s2,0x4
    800069b4:	0009b783          	ld	a5,0(s3)
    800069b8:	97ba                	add	a5,a5,a4
    800069ba:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800069be:	854a                	mv	a0,s2
    800069c0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800069c4:	bafff0ef          	jal	80006572 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800069c8:	8885                	andi	s1,s1,1
    800069ca:	f0fd                	bnez	s1,800069b0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800069cc:	0001f517          	auipc	a0,0x1f
    800069d0:	40450513          	addi	a0,a0,1028 # 80025dd0 <disk+0x128>
    800069d4:	ac4fa0ef          	jal	80000c98 <release>
}
    800069d8:	70a6                	ld	ra,104(sp)
    800069da:	7406                	ld	s0,96(sp)
    800069dc:	64e6                	ld	s1,88(sp)
    800069de:	6946                	ld	s2,80(sp)
    800069e0:	69a6                	ld	s3,72(sp)
    800069e2:	6a06                	ld	s4,64(sp)
    800069e4:	7ae2                	ld	s5,56(sp)
    800069e6:	7b42                	ld	s6,48(sp)
    800069e8:	7ba2                	ld	s7,40(sp)
    800069ea:	7c02                	ld	s8,32(sp)
    800069ec:	6ce2                	ld	s9,24(sp)
    800069ee:	6165                	addi	sp,sp,112
    800069f0:	8082                	ret

00000000800069f2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800069f2:	1101                	addi	sp,sp,-32
    800069f4:	ec06                	sd	ra,24(sp)
    800069f6:	e822                	sd	s0,16(sp)
    800069f8:	e426                	sd	s1,8(sp)
    800069fa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800069fc:	0001f497          	auipc	s1,0x1f
    80006a00:	2ac48493          	addi	s1,s1,684 # 80025ca8 <disk>
    80006a04:	0001f517          	auipc	a0,0x1f
    80006a08:	3cc50513          	addi	a0,a0,972 # 80025dd0 <disk+0x128>
    80006a0c:	9f4fa0ef          	jal	80000c00 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006a10:	100017b7          	lui	a5,0x10001
    80006a14:	53b8                	lw	a4,96(a5)
    80006a16:	8b0d                	andi	a4,a4,3
    80006a18:	100017b7          	lui	a5,0x10001
    80006a1c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006a1e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006a22:	689c                	ld	a5,16(s1)
    80006a24:	0204d703          	lhu	a4,32(s1)
    80006a28:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006a2c:	04f70663          	beq	a4,a5,80006a78 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80006a30:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006a34:	6898                	ld	a4,16(s1)
    80006a36:	0204d783          	lhu	a5,32(s1)
    80006a3a:	8b9d                	andi	a5,a5,7
    80006a3c:	078e                	slli	a5,a5,0x3
    80006a3e:	97ba                	add	a5,a5,a4
    80006a40:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006a42:	00278713          	addi	a4,a5,2
    80006a46:	0712                	slli	a4,a4,0x4
    80006a48:	9726                	add	a4,a4,s1
    80006a4a:	01074703          	lbu	a4,16(a4)
    80006a4e:	e321                	bnez	a4,80006a8e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006a50:	0789                	addi	a5,a5,2
    80006a52:	0792                	slli	a5,a5,0x4
    80006a54:	97a6                	add	a5,a5,s1
    80006a56:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006a58:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006a5c:	d08fb0ef          	jal	80001f64 <wakeup>

    disk.used_idx += 1;
    80006a60:	0204d783          	lhu	a5,32(s1)
    80006a64:	2785                	addiw	a5,a5,1
    80006a66:	17c2                	slli	a5,a5,0x30
    80006a68:	93c1                	srli	a5,a5,0x30
    80006a6a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006a6e:	6898                	ld	a4,16(s1)
    80006a70:	00275703          	lhu	a4,2(a4)
    80006a74:	faf71ee3          	bne	a4,a5,80006a30 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006a78:	0001f517          	auipc	a0,0x1f
    80006a7c:	35850513          	addi	a0,a0,856 # 80025dd0 <disk+0x128>
    80006a80:	a18fa0ef          	jal	80000c98 <release>
}
    80006a84:	60e2                	ld	ra,24(sp)
    80006a86:	6442                	ld	s0,16(sp)
    80006a88:	64a2                	ld	s1,8(sp)
    80006a8a:	6105                	addi	sp,sp,32
    80006a8c:	8082                	ret
      panic("virtio_disk_intr status");
    80006a8e:	00002517          	auipc	a0,0x2
    80006a92:	44250513          	addi	a0,a0,1090 # 80008ed0 <etext+0xed0>
    80006a96:	d7df90ef          	jal	80000812 <panic>

0000000080006a9a <cslog_init>:
  safestrcpy(e->name, p->name, CS_NM);
}

void
cslog_init(void)
{
    80006a9a:	1141                	addi	sp,sp,-16
    80006a9c:	e406                	sd	ra,8(sp)
    80006a9e:	e022                	sd	s0,0(sp)
    80006aa0:	0800                	addi	s0,sp,16
  ringbuf_init(&cs_rb, "cslog", sizeof(struct cs_event));
    80006aa2:	03000613          	li	a2,48
    80006aa6:	00002597          	auipc	a1,0x2
    80006aaa:	44258593          	addi	a1,a1,1090 # 80008ee8 <etext+0xee8>
    80006aae:	0001f517          	auipc	a0,0x1f
    80006ab2:	33a50513          	addi	a0,a0,826 # 80025de8 <cs_rb>
    80006ab6:	1c6000ef          	jal	80006c7c <ringbuf_init>
  printf("CS sizeof(cs_event)=%ld RB_MAX_ELEM=%d\n", sizeof(struct cs_event), RB_MAX_ELEM);
    80006aba:	10000613          	li	a2,256
    80006abe:	03000593          	li	a1,48
    80006ac2:	00002517          	auipc	a0,0x2
    80006ac6:	42e50513          	addi	a0,a0,1070 # 80008ef0 <etext+0xef0>
    80006aca:	a63f90ef          	jal	8000052c <printf>
}
    80006ace:	60a2                	ld	ra,8(sp)
    80006ad0:	6402                	ld	s0,0(sp)
    80006ad2:	0141                	addi	sp,sp,16
    80006ad4:	8082                	ret

0000000080006ad6 <cslog_push>:

void
cslog_push(struct cs_event *e)
{
    80006ad6:	1141                	addi	sp,sp,-16
    80006ad8:	e406                	sd	ra,8(sp)
    80006ada:	e022                	sd	s0,0(sp)
    80006adc:	0800                	addi	s0,sp,16
    80006ade:	85aa                	mv	a1,a0
  e->seq = ++cs_seq;
    80006ae0:	00002717          	auipc	a4,0x2
    80006ae4:	5c070713          	addi	a4,a4,1472 # 800090a0 <cs_seq>
    80006ae8:	631c                	ld	a5,0(a4)
    80006aea:	0785                	addi	a5,a5,1
    80006aec:	e31c                	sd	a5,0(a4)
    80006aee:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    80006af0:	0001f517          	auipc	a0,0x1f
    80006af4:	2f850513          	addi	a0,a0,760 # 80025de8 <cs_rb>
    80006af8:	1b8000ef          	jal	80006cb0 <ringbuf_push>
}
    80006afc:	60a2                	ld	ra,8(sp)
    80006afe:	6402                	ld	s0,0(sp)
    80006b00:	0141                	addi	sp,sp,16
    80006b02:	8082                	ret

0000000080006b04 <cslog_read_many>:

int
cslog_read_many(struct cs_event *out, int max)
{
    80006b04:	1141                	addi	sp,sp,-16
    80006b06:	e406                	sd	ra,8(sp)
    80006b08:	e022                	sd	s0,0(sp)
    80006b0a:	0800                	addi	s0,sp,16
    80006b0c:	862e                	mv	a2,a1
  return ringbuf_read_many(&cs_rb, out, max);
    80006b0e:	85aa                	mv	a1,a0
    80006b10:	0001f517          	auipc	a0,0x1f
    80006b14:	2d850513          	addi	a0,a0,728 # 80025de8 <cs_rb>
    80006b18:	204000ef          	jal	80006d1c <ringbuf_read_many>
}
    80006b1c:	60a2                	ld	ra,8(sp)
    80006b1e:	6402                	ld	s0,0(sp)
    80006b20:	0141                	addi	sp,sp,16
    80006b22:	8082                	ret

0000000080006b24 <cslog_run_start>:

void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
    80006b24:	c14d                	beqz	a0,80006bc6 <cslog_run_start+0xa2>
{
    80006b26:	715d                	addi	sp,sp,-80
    80006b28:	e486                	sd	ra,72(sp)
    80006b2a:	e0a2                	sd	s0,64(sp)
    80006b2c:	fc26                	sd	s1,56(sp)
    80006b2e:	0880                	addi	s0,sp,80
    80006b30:	84aa                	mv	s1,a0
  if(p->pid <= 0) return;
    80006b32:	591c                	lw	a5,48(a0)
    80006b34:	00f05563          	blez	a5,80006b3e <cslog_run_start+0x1a>
  if(p->name[0] == 0) return;
    80006b38:	15854783          	lbu	a5,344(a0)
    80006b3c:	e791                	bnez	a5,80006b48 <cslog_run_start+0x24>

  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
    80006b3e:	60a6                	ld	ra,72(sp)
    80006b40:	6406                	ld	s0,64(sp)
    80006b42:	74e2                	ld	s1,56(sp)
    80006b44:	6161                	addi	sp,sp,80
    80006b46:	8082                	ret
    80006b48:	f84a                	sd	s2,48(sp)
  if(strncmp(p->name, "cscat", 5) == 0) return;
    80006b4a:	15850913          	addi	s2,a0,344
    80006b4e:	4615                	li	a2,5
    80006b50:	00002597          	auipc	a1,0x2
    80006b54:	3c858593          	addi	a1,a1,968 # 80008f18 <etext+0xf18>
    80006b58:	854a                	mv	a0,s2
    80006b5a:	a46fa0ef          	jal	80000da0 <strncmp>
    80006b5e:	e119                	bnez	a0,80006b64 <cslog_run_start+0x40>
    80006b60:	7942                	ld	s2,48(sp)
    80006b62:	bff1                	j	80006b3e <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    80006b64:	4621                	li	a2,8
    80006b66:	00002597          	auipc	a1,0x2
    80006b6a:	3ba58593          	addi	a1,a1,954 # 80008f20 <etext+0xf20>
    80006b6e:	854a                	mv	a0,s2
    80006b70:	a30fa0ef          	jal	80000da0 <strncmp>
    80006b74:	e119                	bnez	a0,80006b7a <cslog_run_start+0x56>
    80006b76:	7942                	ld	s2,48(sp)
    80006b78:	b7d9                	j	80006b3e <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    80006b7a:	03000613          	li	a2,48
    80006b7e:	4581                	li	a1,0
    80006b80:	fb040513          	addi	a0,s0,-80
    80006b84:	950fa0ef          	jal	80000cd4 <memset>
  e->ticks = ticks;
    80006b88:	00002797          	auipc	a5,0x2
    80006b8c:	5107a783          	lw	a5,1296(a5) # 80009098 <ticks>
    80006b90:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    80006b94:	d49fa0ef          	jal	800018dc <cpuid>
    80006b98:	faa42e23          	sw	a0,-68(s0)
  e->pid   = p->pid;
    80006b9c:	589c                	lw	a5,48(s1)
    80006b9e:	fcf42223          	sw	a5,-60(s0)
  e->state = p->state;
    80006ba2:	4c9c                	lw	a5,24(s1)
    80006ba4:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e->name, p->name, CS_NM);
    80006ba8:	4641                	li	a2,16
    80006baa:	85ca                	mv	a1,s2
    80006bac:	fcc40513          	addi	a0,s0,-52
    80006bb0:	a62fa0ef          	jal	80000e12 <safestrcpy>
  e.type = CS_RUN_START;
    80006bb4:	4785                	li	a5,1
    80006bb6:	fcf42023          	sw	a5,-64(s0)
  cslog_push(&e);
    80006bba:	fb040513          	addi	a0,s0,-80
    80006bbe:	f19ff0ef          	jal	80006ad6 <cslog_push>
    80006bc2:	7942                	ld	s2,48(sp)
    80006bc4:	bfad                	j	80006b3e <cslog_run_start+0x1a>
    80006bc6:	8082                	ret

0000000080006bc8 <sys_csread>:
#include "cslog.h"


uint64
sys_csread(void)
{
    80006bc8:	81010113          	addi	sp,sp,-2032
    80006bcc:	7e113423          	sd	ra,2024(sp)
    80006bd0:	7e813023          	sd	s0,2016(sp)
    80006bd4:	7c913c23          	sd	s1,2008(sp)
    80006bd8:	7d213823          	sd	s2,2000(sp)
    80006bdc:	7f010413          	addi	s0,sp,2032
    80006be0:	bb010113          	addi	sp,sp,-1104
  uint64 uaddr = 0;
    80006be4:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80006be8:	fc042a23          	sw	zero,-44(s0)

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
    80006bec:	fd840593          	addi	a1,s0,-40
    80006bf0:	4501                	li	a0,0
    80006bf2:	c47fb0ef          	jal	80002838 <argaddr>
  argint(1, &max);
    80006bf6:	fd440593          	addi	a1,s0,-44
    80006bfa:	4505                	li	a0,1
    80006bfc:	c21fb0ef          	jal	8000281c <argint>

  if(max <= 0) return 0;
    80006c00:	fd442783          	lw	a5,-44(s0)
    80006c04:	4501                	li	a0,0
    80006c06:	04f05c63          	blez	a5,80006c5e <sys_csread+0x96>
  if(max > 64) max = 64;
    80006c0a:	04000713          	li	a4,64
    80006c0e:	00f75663          	bge	a4,a5,80006c1a <sys_csread+0x52>
    80006c12:	04000793          	li	a5,64
    80006c16:	fcf42a23          	sw	a5,-44(s0)

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);
    80006c1a:	77fd                	lui	a5,0xfffff
    80006c1c:	3d078793          	addi	a5,a5,976 # fffffffffffff3d0 <end+0xffffffff7ff99588>
    80006c20:	97a2                	add	a5,a5,s0
    80006c22:	797d                	lui	s2,0xfffff
    80006c24:	3c890713          	addi	a4,s2,968 # fffffffffffff3c8 <end+0xffffffff7ff99580>
    80006c28:	9722                	add	a4,a4,s0
    80006c2a:	e31c                	sd	a5,0(a4)
    80006c2c:	fd442583          	lw	a1,-44(s0)
    80006c30:	6308                	ld	a0,0(a4)
    80006c32:	ed3ff0ef          	jal	80006b04 <cslog_read_many>
    80006c36:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80006c38:	cd1fa0ef          	jal	80001908 <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    80006c3c:	0014969b          	slliw	a3,s1,0x1
    80006c40:	9ea5                	addw	a3,a3,s1
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80006c42:	0046969b          	slliw	a3,a3,0x4
    80006c46:	3c890793          	addi	a5,s2,968
    80006c4a:	97a2                	add	a5,a5,s0
    80006c4c:	6390                	ld	a2,0(a5)
    80006c4e:	fd843583          	ld	a1,-40(s0)
    80006c52:	6928                	ld	a0,80(a0)
    80006c54:	9c9fa0ef          	jal	8000161c <copyout>
    80006c58:	02054063          	bltz	a0,80006c78 <sys_csread+0xb0>
    return -1;

  return n;
    80006c5c:	8526                	mv	a0,s1
}
    80006c5e:	45010113          	addi	sp,sp,1104
    80006c62:	7e813083          	ld	ra,2024(sp)
    80006c66:	7e013403          	ld	s0,2016(sp)
    80006c6a:	7d813483          	ld	s1,2008(sp)
    80006c6e:	7d013903          	ld	s2,2000(sp)
    80006c72:	7f010113          	addi	sp,sp,2032
    80006c76:	8082                	ret
    return -1;
    80006c78:	557d                	li	a0,-1
    80006c7a:	b7d5                	j	80006c5e <sys_csread+0x96>

0000000080006c7c <ringbuf_init>:
  return (void *)(rb->buf + idx * rb->elem_size);
}

void
ringbuf_init(struct ringbuf *rb, char *name, uint elem_size)
{
    80006c7c:	1101                	addi	sp,sp,-32
    80006c7e:	ec06                	sd	ra,24(sp)
    80006c80:	e822                	sd	s0,16(sp)
    80006c82:	e426                	sd	s1,8(sp)
    80006c84:	e04a                	sd	s2,0(sp)
    80006c86:	1000                	addi	s0,sp,32
    80006c88:	84aa                	mv	s1,a0
    80006c8a:	8932                	mv	s2,a2
  initlock(&rb->lock, name);
    80006c8c:	ef5f90ef          	jal	80000b80 <initlock>
  rb->head = 0;
    80006c90:	0004ac23          	sw	zero,24(s1)
  rb->tail = 0;
    80006c94:	0004ae23          	sw	zero,28(s1)
  rb->count = 0;
    80006c98:	0204a023          	sw	zero,32(s1)
  rb->seq = 0;
    80006c9c:	0204b423          	sd	zero,40(s1)
  rb->elem_size = elem_size;
    80006ca0:	0324a223          	sw	s2,36(s1)
}
    80006ca4:	60e2                	ld	ra,24(sp)
    80006ca6:	6442                	ld	s0,16(sp)
    80006ca8:	64a2                	ld	s1,8(sp)
    80006caa:	6902                	ld	s2,0(sp)
    80006cac:	6105                	addi	sp,sp,32
    80006cae:	8082                	ret

0000000080006cb0 <ringbuf_push>:

int
ringbuf_push(struct ringbuf *rb, void *elem)
{
    80006cb0:	1101                	addi	sp,sp,-32
    80006cb2:	ec06                	sd	ra,24(sp)
    80006cb4:	e822                	sd	s0,16(sp)
    80006cb6:	e426                	sd	s1,8(sp)
    80006cb8:	e04a                	sd	s2,0(sp)
    80006cba:	1000                	addi	s0,sp,32
    80006cbc:	84aa                	mv	s1,a0
    80006cbe:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006cc0:	f41f90ef          	jal	80000c00 <acquire>

  if(rb->count == RB_CAP){
    80006cc4:	5098                	lw	a4,32(s1)
    80006cc6:	20000793          	li	a5,512
    80006cca:	04f70063          	beq	a4,a5,80006d0a <ringbuf_push+0x5a>
  return (void *)(rb->buf + idx * rb->elem_size);
    80006cce:	50d0                	lw	a2,36(s1)
    80006cd0:	03048513          	addi	a0,s1,48
    80006cd4:	4c9c                	lw	a5,24(s1)
    80006cd6:	02c787bb          	mulw	a5,a5,a2
    80006cda:	1782                	slli	a5,a5,0x20
    80006cdc:	9381                	srli	a5,a5,0x20
    rb->tail = (rb->tail + 1) % RB_CAP;
    rb->count--;
  }

  memmove(slot_ptr(rb, rb->head), elem, rb->elem_size);
    80006cde:	85ca                	mv	a1,s2
    80006ce0:	953e                	add	a0,a0,a5
    80006ce2:	84efa0ef          	jal	80000d30 <memmove>
  rb->head = (rb->head + 1) % RB_CAP;
    80006ce6:	4c9c                	lw	a5,24(s1)
    80006ce8:	2785                	addiw	a5,a5,1
    80006cea:	1ff7f793          	andi	a5,a5,511
    80006cee:	cc9c                	sw	a5,24(s1)
  rb->count++;
    80006cf0:	509c                	lw	a5,32(s1)
    80006cf2:	2785                	addiw	a5,a5,1
    80006cf4:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80006cf6:	8526                	mv	a0,s1
    80006cf8:	fa1f90ef          	jal	80000c98 <release>
  return 0;
}
    80006cfc:	4501                	li	a0,0
    80006cfe:	60e2                	ld	ra,24(sp)
    80006d00:	6442                	ld	s0,16(sp)
    80006d02:	64a2                	ld	s1,8(sp)
    80006d04:	6902                	ld	s2,0(sp)
    80006d06:	6105                	addi	sp,sp,32
    80006d08:	8082                	ret
    rb->tail = (rb->tail + 1) % RB_CAP;
    80006d0a:	4cdc                	lw	a5,28(s1)
    80006d0c:	2785                	addiw	a5,a5,1
    80006d0e:	1ff7f793          	andi	a5,a5,511
    80006d12:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80006d14:	1ff00793          	li	a5,511
    80006d18:	d09c                	sw	a5,32(s1)
    80006d1a:	bf55                	j	80006cce <ringbuf_push+0x1e>

0000000080006d1c <ringbuf_read_many>:

int
ringbuf_read_many(struct ringbuf *rb, void *out, int max)
{
    80006d1c:	7139                	addi	sp,sp,-64
    80006d1e:	fc06                	sd	ra,56(sp)
    80006d20:	f822                	sd	s0,48(sp)
    80006d22:	f04a                	sd	s2,32(sp)
    80006d24:	0080                	addi	s0,sp,64
  int n = 0;
  char *dst = (char *)out;

  if(max <= 0)
    return 0;
    80006d26:	4901                	li	s2,0
  if(max <= 0)
    80006d28:	06c05163          	blez	a2,80006d8a <ringbuf_read_many+0x6e>
    80006d2c:	f426                	sd	s1,40(sp)
    80006d2e:	ec4e                	sd	s3,24(sp)
    80006d30:	e852                	sd	s4,16(sp)
    80006d32:	e456                	sd	s5,8(sp)
    80006d34:	84aa                	mv	s1,a0
    80006d36:	8a2e                	mv	s4,a1
    80006d38:	89b2                	mv	s3,a2

  acquire(&rb->lock);
    80006d3a:	ec7f90ef          	jal	80000c00 <acquire>
  int n = 0;
    80006d3e:	4901                	li	s2,0
  return (void *)(rb->buf + idx * rb->elem_size);
    80006d40:	03048a93          	addi	s5,s1,48
  while(n < max && rb->count > 0){
    80006d44:	509c                	lw	a5,32(s1)
    80006d46:	cb9d                	beqz	a5,80006d7c <ringbuf_read_many+0x60>
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006d48:	50d0                	lw	a2,36(s1)
  return (void *)(rb->buf + idx * rb->elem_size);
    80006d4a:	4ccc                	lw	a1,28(s1)
    80006d4c:	02c585bb          	mulw	a1,a1,a2
    80006d50:	1582                	slli	a1,a1,0x20
    80006d52:	9181                	srli	a1,a1,0x20
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006d54:	02c9053b          	mulw	a0,s2,a2
    80006d58:	1502                	slli	a0,a0,0x20
    80006d5a:	9101                	srli	a0,a0,0x20
    80006d5c:	95d6                	add	a1,a1,s5
    80006d5e:	9552                	add	a0,a0,s4
    80006d60:	fd1f90ef          	jal	80000d30 <memmove>
    rb->tail = (rb->tail + 1) % RB_CAP;
    80006d64:	4cdc                	lw	a5,28(s1)
    80006d66:	2785                	addiw	a5,a5,1
    80006d68:	1ff7f793          	andi	a5,a5,511
    80006d6c:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80006d6e:	509c                	lw	a5,32(s1)
    80006d70:	37fd                	addiw	a5,a5,-1
    80006d72:	d09c                	sw	a5,32(s1)
    n++;
    80006d74:	2905                	addiw	s2,s2,1
  while(n < max && rb->count > 0){
    80006d76:	fd2997e3          	bne	s3,s2,80006d44 <ringbuf_read_many+0x28>
    80006d7a:	894e                	mv	s2,s3
  }
  release(&rb->lock);
    80006d7c:	8526                	mv	a0,s1
    80006d7e:	f1bf90ef          	jal	80000c98 <release>

  return n;
    80006d82:	74a2                	ld	s1,40(sp)
    80006d84:	69e2                	ld	s3,24(sp)
    80006d86:	6a42                	ld	s4,16(sp)
    80006d88:	6aa2                	ld	s5,8(sp)
}
    80006d8a:	854a                	mv	a0,s2
    80006d8c:	70e2                	ld	ra,56(sp)
    80006d8e:	7442                	ld	s0,48(sp)
    80006d90:	7902                	ld	s2,32(sp)
    80006d92:	6121                	addi	sp,sp,64
    80006d94:	8082                	ret

0000000080006d96 <ringbuf_pop>:

int
ringbuf_pop(struct ringbuf *rb, void *dst)
{
    80006d96:	1101                	addi	sp,sp,-32
    80006d98:	ec06                	sd	ra,24(sp)
    80006d9a:	e822                	sd	s0,16(sp)
    80006d9c:	e426                	sd	s1,8(sp)
    80006d9e:	e04a                	sd	s2,0(sp)
    80006da0:	1000                	addi	s0,sp,32
    80006da2:	84aa                	mv	s1,a0
    80006da4:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006da6:	e5bf90ef          	jal	80000c00 <acquire>

  if(rb->count == 0){
    80006daa:	509c                	lw	a5,32(s1)
    80006dac:	cf9d                	beqz	a5,80006dea <ringbuf_pop+0x54>
  return (void *)(rb->buf + idx * rb->elem_size);
    80006dae:	50d0                	lw	a2,36(s1)
    80006db0:	03048593          	addi	a1,s1,48
    80006db4:	4cdc                	lw	a5,28(s1)
    80006db6:	02c787bb          	mulw	a5,a5,a2
    80006dba:	1782                	slli	a5,a5,0x20
    80006dbc:	9381                	srli	a5,a5,0x20
    release(&rb->lock);
    return -1;
  }

  memmove(dst, slot_ptr(rb, rb->tail), rb->elem_size);
    80006dbe:	95be                	add	a1,a1,a5
    80006dc0:	854a                	mv	a0,s2
    80006dc2:	f6ff90ef          	jal	80000d30 <memmove>
  rb->tail = (rb->tail + 1) % RB_CAP;
    80006dc6:	4cdc                	lw	a5,28(s1)
    80006dc8:	2785                	addiw	a5,a5,1
    80006dca:	1ff7f793          	andi	a5,a5,511
    80006dce:	ccdc                	sw	a5,28(s1)
  rb->count--;
    80006dd0:	509c                	lw	a5,32(s1)
    80006dd2:	37fd                	addiw	a5,a5,-1
    80006dd4:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80006dd6:	8526                	mv	a0,s1
    80006dd8:	ec1f90ef          	jal	80000c98 <release>
  return 0;
    80006ddc:	4501                	li	a0,0
    80006dde:	60e2                	ld	ra,24(sp)
    80006de0:	6442                	ld	s0,16(sp)
    80006de2:	64a2                	ld	s1,8(sp)
    80006de4:	6902                	ld	s2,0(sp)
    80006de6:	6105                	addi	sp,sp,32
    80006de8:	8082                	ret
    release(&rb->lock);
    80006dea:	8526                	mv	a0,s1
    80006dec:	eadf90ef          	jal	80000c98 <release>
    return -1;
    80006df0:	557d                	li	a0,-1
    80006df2:	b7f5                	j	80006dde <ringbuf_pop+0x48>

0000000080006df4 <fslog_init>:
static struct ringbuf fs_rb;
static uint64 fs_seq = 0;

void
fslog_init(void)
{
    80006df4:	1141                	addi	sp,sp,-16
    80006df6:	e406                	sd	ra,8(sp)
    80006df8:	e022                	sd	s0,0(sp)
    80006dfa:	0800                	addi	s0,sp,16
  // تهيئة الـ ring buffer الخاص بـ أحداث نظام الملفات
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
    80006dfc:	30800613          	li	a2,776
    80006e00:	00002597          	auipc	a1,0x2
    80006e04:	13058593          	addi	a1,a1,304 # 80008f30 <etext+0xf30>
    80006e08:	0003f517          	auipc	a0,0x3f
    80006e0c:	01050513          	addi	a0,a0,16 # 80045e18 <fs_rb>
    80006e10:	e6dff0ef          	jal	80006c7c <ringbuf_init>
}
    80006e14:	60a2                	ld	ra,8(sp)
    80006e16:	6402                	ld	s0,0(sp)
    80006e18:	0141                	addi	sp,sp,16
    80006e1a:	8082                	ret

0000000080006e1c <fslog_push>:

void
fslog_push(struct fs_event *e)
{
    80006e1c:	1141                	addi	sp,sp,-16
    80006e1e:	e406                	sd	ra,8(sp)
    80006e20:	e022                	sd	s0,0(sp)
    80006e22:	0800                	addi	s0,sp,16
    80006e24:	85aa                	mv	a1,a0
  // إضافة رقم تسلسلي لكل حدث لترتيبها في الواجهة الرسومية
  e->seq = ++fs_seq;
    80006e26:	00002717          	auipc	a4,0x2
    80006e2a:	28270713          	addi	a4,a4,642 # 800090a8 <fs_seq>
    80006e2e:	631c                	ld	a5,0(a4)
    80006e30:	0785                	addi	a5,a5,1
    80006e32:	e31c                	sd	a5,0(a4)
    80006e34:	e11c                	sd	a5,0(a0)
  ringbuf_push(&fs_rb, e);
    80006e36:	0003f517          	auipc	a0,0x3f
    80006e3a:	fe250513          	addi	a0,a0,-30 # 80045e18 <fs_rb>
    80006e3e:	e73ff0ef          	jal	80006cb0 <ringbuf_push>
}
    80006e42:	60a2                	ld	ra,8(sp)
    80006e44:	6402                	ld	s0,0(sp)
    80006e46:	0141                	addi	sp,sp,16
    80006e48:	8082                	ret

0000000080006e4a <fslog_read_many>:

int
fslog_read_many(struct fs_event *out, int max)
{
    80006e4a:	cb010113          	addi	sp,sp,-848
    80006e4e:	34113423          	sd	ra,840(sp)
    80006e52:	34813023          	sd	s0,832(sp)
    80006e56:	32913c23          	sd	s1,824(sp)
    80006e5a:	33213823          	sd	s2,816(sp)
    80006e5e:	33313423          	sd	s3,808(sp)
    80006e62:	0e80                	addi	s0,sp,848
    80006e64:	84aa                	mv	s1,a0
    80006e66:	89ae                	mv	s3,a1
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
    80006e68:	aa1fa0ef          	jal	80001908 <myproc>
  
  while(count < max){
    80006e6c:	05305863          	blez	s3,80006ebc <fslog_read_many+0x72>
    80006e70:	33413023          	sd	s4,800(sp)
    80006e74:	31513c23          	sd	s5,792(sp)
    80006e78:	8a2a                	mv	s4,a0
  int count = 0;
    80006e7a:	4901                	li	s2,0
    if(ringbuf_pop(&fs_rb, &e) != 0)
    80006e7c:	0003fa97          	auipc	s5,0x3f
    80006e80:	f9ca8a93          	addi	s5,s5,-100 # 80045e18 <fs_rb>
    80006e84:	cb840593          	addi	a1,s0,-840
    80006e88:	8556                	mv	a0,s5
    80006e8a:	f0dff0ef          	jal	80006d96 <ringbuf_pop>
    80006e8e:	e90d                	bnez	a0,80006ec0 <fslog_read_many+0x76>
      break;

    // نقل البيانات من مساحة النواة إلى مساحة المستخدم (User Space) ليعرضها الـ GUI
    uint64 dst = (uint64)out + count * sizeof(struct fs_event);
    if(copyout(p->pagetable, dst, (char *)&e, sizeof(struct fs_event)) < 0)
    80006e90:	30800693          	li	a3,776
    80006e94:	cb840613          	addi	a2,s0,-840
    80006e98:	85a6                	mv	a1,s1
    80006e9a:	050a3503          	ld	a0,80(s4)
    80006e9e:	f7efa0ef          	jal	8000161c <copyout>
    80006ea2:	04054163          	bltz	a0,80006ee4 <fslog_read_many+0x9a>
      break;
    count++;
    80006ea6:	2905                	addiw	s2,s2,1
  while(count < max){
    80006ea8:	30848493          	addi	s1,s1,776
    80006eac:	fd299ce3          	bne	s3,s2,80006e84 <fslog_read_many+0x3a>
    80006eb0:	894e                	mv	s2,s3
    80006eb2:	32013a03          	ld	s4,800(sp)
    80006eb6:	31813a83          	ld	s5,792(sp)
    80006eba:	a039                	j	80006ec8 <fslog_read_many+0x7e>
  int count = 0;
    80006ebc:	4901                	li	s2,0
    80006ebe:	a029                	j	80006ec8 <fslog_read_many+0x7e>
    80006ec0:	32013a03          	ld	s4,800(sp)
    80006ec4:	31813a83          	ld	s5,792(sp)
  }
  return count;
}
    80006ec8:	854a                	mv	a0,s2
    80006eca:	34813083          	ld	ra,840(sp)
    80006ece:	34013403          	ld	s0,832(sp)
    80006ed2:	33813483          	ld	s1,824(sp)
    80006ed6:	33013903          	ld	s2,816(sp)
    80006eda:	32813983          	ld	s3,808(sp)
    80006ede:	35010113          	addi	sp,sp,848
    80006ee2:	8082                	ret
    80006ee4:	32013a03          	ld	s4,800(sp)
    80006ee8:	31813a83          	ld	s5,792(sp)
    80006eec:	bff1                	j	80006ec8 <fslog_read_many+0x7e>

0000000080006eee <state_update_file>:
void
state_update_file(int pid, int fd, struct file *f, char *path)
{
    80006eee:	1141                	addi	sp,sp,-16
    80006ef0:	e422                	sd	s0,8(sp)
    80006ef2:	0800                	addi	s0,sp,16
  // TODO
}
    80006ef4:	6422                	ld	s0,8(sp)
    80006ef6:	0141                	addi	sp,sp,16
    80006ef8:	8082                	ret

0000000080006efa <state_remove_fd>:

void
state_remove_fd(int pid, int fd)
{
    80006efa:	1141                	addi	sp,sp,-16
    80006efc:	e422                	sd	s0,8(sp)
    80006efe:	0800                	addi	s0,sp,16
  // TODO
    80006f00:	6422                	ld	s0,8(sp)
    80006f02:	0141                	addi	sp,sp,16
    80006f04:	8082                	ret
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
