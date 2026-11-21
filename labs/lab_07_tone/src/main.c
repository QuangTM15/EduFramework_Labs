#include "Arduino.h"

int main(void)
{
    setup();
    while (1)
    {
        tone(GPIO7, 523U); /* C5 - Do */
        delay(300U);
        noTone(GPIO7);
        delay(80U);
        tone(GPIO7, 587U); /* D5 - Re */
        delay(300U);
        noTone(GPIO7);
        delay(80U);
        tone(GPIO7, 659U); /* E5 - Mi */
        delay(300U);
        noTone(GPIO7);
        delay(80U);
        tone(GPIO7, 698U); /* F5 - Fa */
        delay(300U);
        noTone(GPIO7);
        delay(80U);
        tone(GPIO7, 784U); /* G5 - Sol */
        delay(300U);
        noTone(GPIO7);
        delay(80U);
        tone(GPIO7, 880U); /* A5 - La */
        delay(300U);
        noTone(GPIO7);
        delay(80U);
        tone(GPIO7, 988U); /* B5 - Si */
        delay(300U);
        noTone(GPIO7);
        delay(80U);
        tone(GPIO7, 1047U); /* C6 - Do */
        delay(450U);
        noTone(GPIO7);
        delay(1000U);
    }
    return 0;
}
