#include "Arduino.h"
#include "ds18b20.h"
#include <math.h>
int main(void)
{
    float temperature = 0.0F;
    setup();
    Serial1_begin(9600U);
    Serial1_println("DS18B20 Temperature Monitor");
    if (false == DS18B20_begin(GPIO7))
    {
        Serial1_println("DS18B20 initialization failed!");
        while (1)
        {
            delay(1000U);
        }
    }
    Serial1_println("DS18B20 initialized successfully.");
    while (1)
    {
        temperature = DS18B20_readCelsius();
        if (false == isnan(temperature))
        {
            Serial1_print("Temperature: ");
            Serial1_printFloat(temperature);
            Serial1_println(" C");
        }
        else
        {
            Serial1_println("Temperature reading failed!");
        }
        delay(1000U);
    }
    return 0;
}