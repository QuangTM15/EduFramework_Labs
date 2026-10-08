#include "Arduino.h"
#include "can.h"
int main(void)
{
    CAN_Frame_t txFrame = {0};
    CAN_Frame_t rxFrame = {0};
    uint8_t value = 0U;
    setup();
    Serial1_begin(9600U);
    if ((false == CAN_begin(500000UL)) ||(false == CAN_setMode(CAN_MODE_LOOPBACK)))
    { 
        Serial1_println("CAN initialization failed.");
        while (1) {}
    }
    Serial1_println("=== CAN Loopback Demo ===");
    txFrame.id = 0x100UL;
    txFrame.format = CAN_STANDARD;
    txFrame.length = 1U;
    while (1)
    {
        txFrame.data[0] = value;
        if (true == CAN_send(&txFrame))
        {
            Serial1_print("TX: ");
            Serial1_printInt(value);
            Serial1_println("");
            if (true == CAN_available())
            {
                if (true == CAN_read(&rxFrame))
                {
                    Serial1_print("RX: ");
                    Serial1_printInt(rxFrame.data[0]);
                    Serial1_println("");
                    if ((txFrame.id == rxFrame.id) && (txFrame.format == rxFrame.format) 
                    &&(txFrame.length == rxFrame.length) &&(txFrame.data[0] == rxFrame.data[0]))
                    {
                        Serial1_println("Result: PASS");
                    }
                    else
                    {
                        Serial1_println("Result: FAIL");
                    }
                }
            }
        }
        else
        {
            Serial1_println("CAN transmission failed.");
        }
        Serial1_println("----------------");
        value++;
        delay(1000U);
    }
}