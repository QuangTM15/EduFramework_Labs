#include "Arduino.h"
#include "ntc.h"

int main(void)
{
    float temperature = 0.0F;
    setup();
    Serial1_begin(9600U);
    NTC_Init();
    Serial1_println("NTC Temperature Monitor");
    while (1)
    {
        temperature = NTC_ReadCelsius(ADC0_SE13);
        Serial1_print("Temperature: ");
        Serial1_printFloat(temperature);
        Serial1_println(" C");
        delay(1000U);
    }
    return 0;
}