
#include "types.h"

#define UART1_BASE 0x10001000L

#define RHR 0
#define THR 0
#define IER 1
#define FCR 2
#define LCR 3
#define LSR 5
#define LSR_TX_IDLE (1<<5)

#define LCR_BAUD_LATCH (1<<7)

static inline uint8 mmio_read(volatile uint8 *a){ return *a; }
static inline void  mmio_write(volatile uint8 *a, uint8 v){ *a = v; }

void
uartev_init(void)
{
  volatile uint8 *uart = (uint8*)UART1_BASE;

  // Disable interrupts.
  mmio_write(uart + IER, 0x00);

  // Special mode to set baud rate.
  mmio_write(uart + LCR, LCR_BAUD_LATCH);

  // LSB for baud rate of 38.4K.
  mmio_write(uart + 0 /*DLL*/, 0x03);
  // MSB for baud rate of 38.4K.
  mmio_write(uart + 1 /*DLM*/, 0x00);

  // Leave set-baud mode, and set word length to 8 bits, no parity.
  mmio_write(uart + LCR, 0x03);

  // Reset and enable FIFOs.
  mmio_write(uart + FCR, 0x07);
}

int
uartev_putc_try(int c)
{
  volatile uint8 *uart = (uint8*)UART1_BASE;

  // wait bounded time فقط (حتى ما نعلّق)
  for(int spins = 0; spins < 10000; spins++){
    if(mmio_read(uart + LSR) & LSR_TX_IDLE){
      mmio_write(uart + THR, (uint8)c);
      return 1;
    }
  }
  return 0; // drop byte
}

void
uartev_write(const void *buf, int n)
{
  const uint8 *p = (const uint8*)buf;
  for(int i = 0; i < n; i++){
    if(!uartev_putc_try(p[i]))
      break; // أو كمّلي وتجاهلي… حسب ما بدك
  }
}

