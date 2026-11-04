#include "Arduino.h"
#include "pn532.h"

int main(void)
{
    setup();
    Serial1_begin(9600U);
    Serial1_println("PN532 NFC Card Detection");
    if (PN532_STATUS_OK == PN532_Begin())
    {
        Serial1_println("PN532 ready.");
    }
    else
    {
        Serial1_println("PN532 initialization failed.");
        while (1)
        {
            delay(1000U);
        }
    }
    while (1)
    {
        if (true == PN532_IsCardPresent())
        {
            Serial1_print("UID: ");
            Serial1_println(PN532_GetUID());
            (void)PN532_End();
            delay(500U);
        }
        delay(100U);
    }
    return 0;
}
