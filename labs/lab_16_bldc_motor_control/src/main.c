#include "Arduino.h"
#include "esc.h"

int main(void)
{
    setup();
    ESC_Init(GPIO2);
    ESC_Arm();
    while (1)
    {
        ESC_SetThrottle(20U);
        delay(3000U);
        ESC_SetThrottle(40U);
        delay(3000U);
        ESC_SetThrottle(60U);
        delay(3000U);
        ESC_SetThrottle(40U);
        delay(3000U);
        ESC_SetThrottle(20U);
        delay(3000U);
        ESC_SetThrottle(0U);
        delay(3000U);
    }
    return 0;
}