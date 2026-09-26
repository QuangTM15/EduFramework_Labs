#include "Arduino.h"
#include "dc_motor.h"

int main(void)
{
    setup();
    DCMotor_Init(GPIO2, GPIO3, GPIO4, GPIO5);
    while (1)
    {
        DCMotor_SetSpeed(128U);
        DCMotor_Forward();
        delay(3000U);
        DCMotor_Stop();
        delay(2000U);
        DCMotor_SetSpeed(128U);
        DCMotor_Reverse();
        delay(3000U);
        DCMotor_Stop();
        delay(2000U);
    }
    return 0;
}