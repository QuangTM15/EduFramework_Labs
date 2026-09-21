#include "Arduino.h"
int main(void)
{
    bool pressed = false;
    setup();
    pinMode(BTN0, INPUT);
    Serial1_begin(9600U);
    Serial1_print("EduFramework ");
    Serial1_println("Serial Monitor");
    Serial1_println("System started.");
    while (1)
    {
        if ((HIGH == digitalRead(BTN0)) && (false == pressed))
        {
            Serial1_println("BTN0 pressed.");
            pressed = true;
        }
        if ((LOW == digitalRead(BTN0)) && (true == pressed))
        {
            Serial1_println("BTN0 released.");
            pressed = false;
        }
    }
    return 0;
}
