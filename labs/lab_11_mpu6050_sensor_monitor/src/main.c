#include "Arduino.h"
#include "MPU6050.h"

int main(void)
{
    MPU_Data_t data;

    setup();

    Serial1_begin(9600U);

    Serial1_println("MPU6050 Sensor Monitor");
    Serial1_println("----------------------");

    if (false == MPU_Begin())
    {
        Serial1_println("MPU6050 initialization failed.");

        while (1)
        {
            delay(1000U);
        }
    }

    Serial1_println("MPU6050 initialized.");

    while (1)
    {
        if (true == MPU_ReadData(&data))
        {
            Serial1_print("Accel X: ");
            Serial1_printFloat(data.accelX);
            Serial1_print(" g | Y: ");
            Serial1_printFloat(data.accelY);
            Serial1_print(" g | Z: ");
            Serial1_printFloat(data.accelZ);
            Serial1_println(" g");

            Serial1_print("Gyro X: ");
            Serial1_printFloat(data.gyroX);
            Serial1_print(" dps | Y: ");
            Serial1_printFloat(data.gyroY);
            Serial1_print(" dps | Z: ");
            Serial1_printFloat(data.gyroZ);
            Serial1_println(" dps");

            Serial1_print("Temperature: ");
            Serial1_printFloat(data.temperature);
            Serial1_println(" C");

            Serial1_println("----------------------");
        }
        else
        {
            Serial1_println("MPU6050 read failed.");
        }

        delay(1000U);
    }
}