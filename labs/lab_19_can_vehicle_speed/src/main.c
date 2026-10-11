#include "Arduino.h"
#include "can.h"
#define ECU 1 // 0: Transmitter, 1: Receiver
#define CAN_BITRATE 500000UL
#define CAN_ID 0x100UL
int main(void)
{
    CAN_Frame_t txFrame = {0};
    CAN_Frame_t rxFrame = {0};
    uint16_t speed = 0U;
    uint8_t sequence = 0U;
    bool increasing = true;
    setup();
    Serial1_begin(9600U);
    if (false == CAN_begin(CAN_BITRATE))
    {
        Serial1_println("CAN initialization failed.");
        while (1)
        {
        }
    }

#if (ECU == 0)
    Serial1_println("=== ECU A: Transmitter ===");
    txFrame.id = CAN_ID;
    txFrame.format = CAN_STANDARD;
    txFrame.length = 3U;
    while (1)
    {
        txFrame.data[0] = sequence;
        txFrame.data[1] = (uint8_t)(speed & 0xFFU);
        txFrame.data[2] = (uint8_t)(speed >> 8U);
        if (true == CAN_send(&txFrame))
        {
            Serial1_print("TX | SEQ: ");
            Serial1_printInt(sequence);
            Serial1_print(" | Speed: ");
            Serial1_printInt(speed);
            Serial1_println(" km/h");
        }
        else
        {
            Serial1_println("CAN transmission failed.");
        }
        sequence++;
        if (true == increasing)
        {
            if (speed < 200U)
            {
                speed += 10U;
            }
            else
            {
                increasing = false;
                speed -= 10U;
            }
        }
        else
        {
            if (speed > 0U)
            {
                speed -= 10U;
            }
            else
            {
                increasing = true;
                speed += 10U;
            }
        }
        delay(500U);
    }
#elif (ECU == 1)
    Serial1_println("=== ECU B: Receiver ===");
    while (1)
    {
        if (true == CAN_available())
        {
            if (true == CAN_read(&rxFrame))
            {
                if ((CAN_ID == rxFrame.id) &&
                    (CAN_STANDARD == rxFrame.format) &&
                    (3U == rxFrame.length))
                {
                    sequence = rxFrame.data[0];
                    speed = (uint16_t)rxFrame.data[1] |
                            ((uint16_t)rxFrame.data[2] << 8U);
                    Serial1_print("RX | SEQ: ");
                    Serial1_printInt(sequence);
                    Serial1_print(" | Speed: ");
                    Serial1_printInt(speed);
                    Serial1_println(" km/h");
                }
            }
        }
    }
#else
#error "Invalid ECU selection"
#endif
}
