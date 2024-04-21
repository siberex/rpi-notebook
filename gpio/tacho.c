/**
 * Fan tachometer signal display with Interrupt Service Routine (ISR).
 * 
 * Compile then run with sudo
 * 
 * Test:
 * gpio mode 0 up
 * gpio mode 0 down
 * 
 * See also:
 * https://github.com/WiringPi/WiringPi/blob/master/examples/isr.c
 * https://github.com/WiringPi/WiringPi/blob/master/examples/isr3.c
*/

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <wpiExtensions.h>
#include <unistd.h>
#include <sys/time.h>

// globalCounter:
//      Global variable to count interrupts
//      Should be declared volatile to make sure the compiler doesn't cache it.
static volatile int globalCounter;
// volatile long long gStartTime, gEndTime;

// Interrupt handler
static void isrInterruptHandler (void) { 
    struct timeval now;
    // gettimeofday(&now, 0);

    // if (0 == gStartTime) {
    //     gStartTime = now.tv_sec * 1000000LL + now.tv_usec;
    // } else {
    //     gEndTime = now.tv_sec * 1000000LL + now.tv_usec;
    // }

    globalCounter++;
}

/*
 *********************************************************************************
 * main
 *********************************************************************************
 */
int main(void)
{
    int count = 0;
    globalCounter = 0;

    // Init with wPi numbering scheme
    wiringPiSetup();

    // GPIO 6, physical 31, wPi 22
    //wiringPiISR(22, INT_EDGE_FALLING, &isrInterruptHandler);

    // GPIO 23, physical 16, wPi 4
    wiringPiISR(4, INT_EDGE_FALLING, &isrInterruptHandler);

    delay(1000);

    // Tacho signal produces two pulses per revolution
    count = globalCounter / 2;

    // RPM
    count = count * 60;
    printf("%d RPM\n", count);
    return 0;
}
