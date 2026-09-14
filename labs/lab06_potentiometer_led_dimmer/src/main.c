#include "Arduino.h"

int main(void)
{
    int adcValue = 0;
    int pwmValue = 0;
    setup();
    pinMode(LED_RED, OUTPUT);
    while (1)
    {
        adcValue = analogRead(ADC0_SE12);
        pwmValue = (adcValue * 255) / 4095;
        analogWrite(LED_RED, pwmValue);
    }
    return 0;
}