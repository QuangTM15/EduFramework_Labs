#include "Arduino.h"
#include "lcd_tft.h"

int main(void)
{
    setup();
    if (false == TFT_Begin())
    {
        while (1)
        {
            /* TFT initialization failed. */
        }
    }
    TFT_FillScreen(TFT_BLACK);

    TFT_SetCursor(20U, 30U);
    TFT_SetTextColor(TFT_YELLOW);
    TFT_SetTextBackground(TFT_BLACK);
    TFT_SetTextSize(3U);
    TFT_Println("EduFramework");

    TFT_SetCursor(20U, 75U);
    TFT_SetTextColor(TFT_CYAN);
    TFT_SetTextSize(2U);
    TFT_Println("S32K144 TFT");

    TFT_DrawLine(20U, 105U, 220U, 105U, TFT_WHITE);

    TFT_DrawRect(20U, 125U, 80U, 50U, TFT_GREEN);
    TFT_FillRect(140U, 125U, 80U, 50U, TFT_BLUE);

    TFT_DrawCircle(60U, 220U, 25U, TFT_RED);
    TFT_FillCircle(180U, 220U, 25U, TFT_MAGENTA);

    while (1)
    {
        /* Display remains unchanged. */
    }
}