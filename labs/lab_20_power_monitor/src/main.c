/**
 * @file main.c
 * @brief Lab 20 - INA219 Battery Power Monitoring.
 */

#include "Arduino.h"
#include "ina219.h"

int main(void)
{
    float voltage = 0.0f;
    float current = 0.0f;
    float power = 0.0f;
    setup();
    Serial1_begin(9600U);
    Serial1_println("=== Lab 20: INA219 Power Monitor ===");
    if (false == INA_Begin())
    {
        Serial1_println("INA219 initialization failed.");
        while (1)
        {
            delay(1000U);
        }
    }
    Serial1_println("INA219 initialized.");
    while (1)
    {
        if ((true == INA_ReadBusVoltage(&voltage)) &&
            (true == INA_ReadCurrent(&current)) &&
            (true == INA_ReadPower(&power)))
        {
            Serial1_print("Voltage: ");
            Serial1_printFloat(voltage);
            Serial1_println(" V");
            Serial1_print("Current: ");
            Serial1_printFloat(current);
            Serial1_println(" mA");
            Serial1_print("Power: ");
            Serial1_printFloat(power);
            Serial1_println(" mW");
            Serial1_println("------------------------");
        }
        else
        {
            Serial1_println("INA219 read failed.");
        }
        delay(1000U);
    }
    return 0;
}
