#include "Arduino.h"

int main(void)
{
    setup();

    while (1)
    {
        tone(GPIO7, 262U); /* C */
        delay(500U);

        tone(GPIO7, 294U); /* D */
        delay(500U);

        tone(GPIO7, 330U); /* E */
        delay(500U);

        tone(GPIO7, 349U); /* F */
        delay(500U);

        tone(GPIO7, 392U); /* G */
        delay(500U);

        tone(GPIO7, 440U); /* A */
        delay(500U);

        tone(GPIO7, 494U); /* B */
        delay(500U);

        noTone(GPIO7);
        delay(1000U);
    }

    return 0;
}