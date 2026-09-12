#include "Arduino.h"

int main(void)
{
    int pwmValue = 0U;
    setup();
    pinMode(LED_RED, OUTPUT);
    while (1)
    {
        /* Fade in: 0 -> 255 */
        for (pwmValue = 0U; pwmValue <= 255U; pwmValue++)
        {
            analogWrite(LED_RED, pwmValue);
            delay(5U);
        }
        /* Fade out: 255 -> 0 */
        for (pwmValue = 255U; pwmValue > 0U; pwmValue--)
        {
            analogWrite(LED_RED, pwmValue);
            delay(5U);
        }
        analogWrite(LED_RED, 0U);
    }
    return 0;
}