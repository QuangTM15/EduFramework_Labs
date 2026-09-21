#include "Arduino.h"
#include "rc522.h"

int main(void)
{
    rc522_uid_t uid = {{0U}, 0U, 0U};
    uint8_t i = 0U;
    setup();
    Serial1_begin(9600U);
    if (true == RC522_PCD_Init(GPIO0, GPIO1))
    {
        Serial1_println("RC522 ready.");
    }
    else
    {
        Serial1_println("RC522 initialization failed.");
    }
    while (1)
    {
        if (true == RC522_PICC_IsNewCardPresent())
        {
            if (true == RC522_PICC_ReadCardSerial(&uid))
            {
                Serial1_print("UID: ");
                for (i = 0U; i < uid.size; i++)
                {
                    Serial1_printInt((int)uid.bytes[i]);
                    Serial1_print(" ");
                }
                Serial1_println("");
                RC522_PICC_HaltA();
                delay(500U);
            }
        }
        delay(20U);
    }
    return 0;
}