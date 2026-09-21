#include "Arduino.h"

int main(void)
{
    uint16_t lightValue = 0U;

    setup();

    Serial1_begin(9600U);

    Serial1_println("EduFramework Analog Read");
    Serial1_println("LDR monitoring started.");

    while (1)
    {
        lightValue = analogRead(ADC0_SE12);

        Serial1_print("ADC: ");
        Serial1_printlnInt(lightValue);

        delay(500U);
    }

    return 0;
}