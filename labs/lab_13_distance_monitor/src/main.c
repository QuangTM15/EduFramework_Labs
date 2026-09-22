#include "Arduino.h"
#include "ultrasonic.h"
#include "lcd_tft.h"

int main(void)
{
    float distance = ULTRASONIC_INVALID_DISTANCE_CM;
    setup();
    pinMode(LED_RED, OUTPUT);
    digitalWrite(LED_RED, HIGH);
    ultrasonicBegin(GPIO4, GPIO5);
    TFT_Begin();
    TFT_FillScreen(TFT_BLACK);
    TFT_SetTextColor(TFT_WHITE);
    TFT_SetTextBackground(TFT_BLACK);
    TFT_SetTextSize(2U);
    TFT_SetCursor(55U, 40U);
    TFT_Print("DISTANCE");
    while (1)
    {
        distance = ultrasonicRead();
        TFT_FillRect(30U, 100U, 180U, 50U, TFT_BLACK);
        TFT_SetCursor(55U, 110U);
        TFT_SetTextSize(3U);
        if (ULTRASONIC_INVALID_DISTANCE_CM != distance)
        {
            TFT_PrintFloat(distance, 1U);
            TFT_Print(" cm");
            if (distance <= 5.0f)
            {
                digitalToggle(LED_RED);
            }
            else
            {
                digitalWrite(LED_RED, LOW);
            }
        }
        else
        {
            TFT_Print("--.- cm");
            digitalWrite(LED_RED, HIGH);
        }
        delay(500U);
    }
    return 0;
}
