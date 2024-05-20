# DMA and mmap tips

[BCM2835 registers](https://elinux.org/BCM2835_registers)


The address for `mmap()` has to be a multiple of the page size returned by `sysconf(_SC_PAGE_SIZE)`.

```bash
getconf PAGE_SIZE
4096
```

Example (non-working pseudocode):

```c
#include <sys/mman.h>

// Base Physical Address of the BCM 2835 peripheral registers
#define BCM2835_PERI_BASE 0x20000000
// Base Physical Address of the Clock/timer registers
#define GPIO_CLOCK_BASE (BCM2835_PERI_BASE + 0x00101000)
#define GPIO_PWM (BCM2835_PERI_BASE + 0x0020C000)

#define	PWM_CONTROL 0
// Defines for PWM Clock, word offsets (ie 4 byte multiples)
#define PWMCLK_CNTL 40
#define	PWMCLK_DIV 41

// BCM Magic
#define	BCM_PASSWORD 0x5A000000

// BLOCK_SIZE = sysconf(_SC_PAGE_SIZE)
#define	BLOCK_SIZE = 4096

static volatile unsigned int *clk;
static volatile unsigned int *pwm;
int fd;

// init memory maps:
// if ((fd = open("/dev/mem", O_RDWR | O_SYNC | O_CLOEXEC)) < 0) {...}
// clk = (uint32_t *) mmap(0, BLOCK_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, GPIO_CLOCK_BASE);
// if (clk == MAP_FAILED) {...}
// pwm = (uint32_t *) mmap(0, BLOCK_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, GPIO_PWM);
// if (pwm == MAP_FAILED) {...}

void bcm_set_pwm_clock(uint32_t divisor)
{
    divisor &= 4095;
    uint32_t pwm_control;

    pwm_control = *(pwm + PWM_CONTROL); // preserve PWM_CONTROL
    *(pwm + PWM_CONTROL) = 0; // Stop PWM

    // Stop PWM clock
    // https://www.airspayce.com/mikem/bcm2835/group__lowlevel.html#ga639da6963ab76e3109b9909f3a9e6171
    // bcm2835_peri_write(clk + PWMCLK_CNTL, BCM_PASSWORD | 0x01);

    // Not using bcm2835.h:
    *(clk + PWMCLK_CNTL) = BCM_PASSWORD | 0x01; // Stop PWM Clock

    // Without the delay when DIV is adjusted the clock sometimes switches to very slow.
    delayMicroseconds(110); // prevent issue with clock going slow
    // Wait for clock to be not BUSY
    while ((*(clk + PWMCLK_CNTL) & 0x80) != 0) 
        delayMicroseconds(1);

    *(clk + PWMCLK_DIV)  = BCM_PASSWORD | (divisor << 12);

    *(clk + PWMCLK_CNTL) = BCM_PASSWORD | 0x11; // Start PWM clock
    *(pwm + PWM_CONTROL) = pwm_control; // restore PWM_CONTROL
}

```



Get peripheral base addresses without `bcm_host_get_peripheral_address();` from `bcm_host.h`

```bash
hexdump /proc/device-tree/soc/ranges
```

```c
// gcc -o soc_ranges soc_ranges.c
// ./soc_ranges
// Addr: fe000000 size: 00000000
#include <stdio.h>
#include <stdlib.h>

static unsigned get_dt_ranges(unsigned offset)
{
   unsigned address = ~0;
   FILE *fp = fopen("/proc/device-tree/soc/ranges", "rb");
   if (fp)
   {
      unsigned char buf[4];
      fseek(fp, offset, SEEK_SET);
      if (fread(buf, 1, sizeof buf, fp) == sizeof buf)
         address = buf[0] << 24 | buf[1] << 16 | buf[2] << 8 | buf[3] << 0;
      fclose(fp);
   }
   return address;
}

int main (int argc, char* argv[])
{
 unsigned address = get_dt_ranges(8);
 unsigned size = get_dt_ranges(4);
 printf("Addr: %08x size: %08x \r\n", address, size);
 return 0;
}
```


Clocks summary:

```bash
cat /sys/kernel/debug/clk/clk_summary
```