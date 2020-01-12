#include <avr/sleep.h>
#include <avr/interrupt.h>

// Control two servos over SPI

#define MAX_VAL  70
#define MIN_VAL  35

ISR (TIM0_OVF_vect)
{
    static uint8_t count;
    if (++count == 3) {
        // start over
        count = 0;
        TCCR0A = 0xf0; // Set on match
        TCCR0B |= 0xc0; // Force set ouput to 1
        TCCR0A = 0xa0; // Clean on match
    }
}
// Protocol:
// 8 bit messages
// - BEGIN = 0xff
// - CONFIG = [ <rsv> {1} , <value> {7} ]
//   - <rsv> = 0
//   - <value> = Servo value (0 - 127)

void process_word(uint8_t which, uint8_t value) {
    if (which) {
        OCR0B = value;
    } else {
        OCR0A = value;
    }
}

#define CLK_PIN 0x08
#define DATA_PIN 0x10

enum { STATE_SYNC, STATE_RECV, STATE_NULL };
ISR (PCINT0_vect)
{
    // Number of consecutive ones. 8 consecutive ones means restart the sequence
    static uint8_t ones = 0;
    static uint8_t state = STATE_NULL;
    static uint8_t recv_remaining = 0;
    static uint8_t word = 0;
    static uint8_t which = 0; // Which servo is currently programmed

    // Only perform operation on rising edge (pin should be ON)
    if (PINB & CLK_PIN) {
        switch (state) {
            case STATE_NULL:
                if (PINB & DATA_PIN) {
                    state = STATE_SYNC;
                }
                break;
            case STATE_SYNC:
                if (!(PINB & DATA_PIN)) {
                    ones = 0;
                    word = 0;
                    which = 0;
                    recv_remaining = 7;
                    state = STATE_RECV;
                }
                break;
            case STATE_RECV:
                --recv_remaining;
                if (PINB & DATA_PIN) {
                    if (++ones == 8) { // 8 consecutive ones: switch to sync state
                        state = STATE_SYNC;
                        return;
                    }
                    word |= 1 << recv_remaining;
                } else {
                    ones = 0;
                }
                if (recv_remaining == 0) {
                    process_word(which, word);
                    ++which;
                    word = 0;
                    recv_remaining = 8;
                }
                break;
        }
    }
}

int main (void)
{
    DDRB |= 0x03; // Enable output on PWM pins

    // PORTB |= DATA_PIN | CLK_PIN; // Enable pull-up on bus lines

    OCR0A = 34;
    TCCR0A = 0xa0; // Clear on match, normal mode
    TCCR0B = 0x04; // Internal clock / 1024 prescaler (9.6MHz / 256 / 256 =~ 146Hz)

    TIMSK0 = 0x02; // Trigger interrupt on counter overflow


    // Spi communication
    GIMSK |= 0x20; // Enable pin change interrupts (PCINT)
    PCMSK |= CLK_PIN; // Enable PCINT3 for clock signal

    sei(); // Enable interrupts


    /* sleep forever */
    for (;;)
        sleep_mode();
    return (0);
}
