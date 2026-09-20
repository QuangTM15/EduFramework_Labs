#include "Arduino.h"
#include "ultrasonic.h"

int main(void)
{
    float distance = ULTRASONIC_INVALID_DISTANCE_CM;
    setup();
    Serial1_begin(9600U);
    ultrasonicBegin(GPIO2, GPIO1);
    Serial1_println("HC-SR04 Distance Monitor");
    while (1)
    {
        distance = ultrasonicRead();
        if (ULTRASONIC_INVALID_DISTANCE_CM != distance)
        {
            Serial1_print("Distance: ");
            Serial1_printFloat(distance);
            Serial1_println(" cm");
        }
        else
        {
            Serial1_println("Distance: Timeout");
        }
        delay(500U);
    }
    return 0;
}