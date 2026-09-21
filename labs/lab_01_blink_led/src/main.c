#include "Arduino.h"

int main()
{
    setup();
    pinMode(LED_RED, OUTPUT);
    while (1)
    {
        digitalWrite(LED_RED, HIGH);
        delay(500);
        digitalWrite(LED_RED, LOW);
        delay(500);
    }
    return 0;
}