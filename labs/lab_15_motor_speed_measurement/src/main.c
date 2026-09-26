#include "Arduino.h"
#include "hardware_serial.h"
#include "dc_motor.h"
#include "encoder.h"

int main(void)
{
    uint32_t previousTime = 0U;
    setup();
    Serial1_begin(9600U);
    DCMotor_Init(GPIO2, GPIO3, GPIO4, GPIO5);

    if (0U == Encoder_Init(GPIO8, GPIO9, 120U))
    {
        Serial1_println("Encoder initialization failed.");
        while (1)
        {
        }
    }
    Encoder_Reset();
    DCMotor_SetSpeed(255U);
    DCMotor_Forward();
    Serial1_println("Motor speed measurement started.");
    while (1)
    {
        Encoder_Update();
        if ((millis() - previousTime) >= 200U)
        {
            previousTime = millis();
            Serial1_print("RPM: ");
            Serial1_printFloat(Encoder_GetRpm());
            Serial1_println("");
        }
    }
    return 0;
}