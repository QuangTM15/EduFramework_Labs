#include "Arduino.h"

int main(void)
{
    bool pressed = false;

    setup();

    pinMode(BTN0, INPUT);
    pinMode(GPIO0, OUTPUT);

    digitalWrite(GPIO0, LOW);

    while (1)
    {
        if ((HIGH == digitalRead(BTN0)) && (false == pressed))
        {
            digitalToggle(GPIO0);
            pressed = true;
        }

        if (LOW == digitalRead(BTN0))
        {
            pressed = false;
        }
    }

    return 0;
}