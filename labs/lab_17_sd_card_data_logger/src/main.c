#include "Arduino.h"
#include "sd_card.h"

#include <stdio.h>

int main(void)
{
    SD_File_t file = {SD_INVALID_HANDLE};
    int adcValue = 0;
    uint8_t sample = 0U;
    char line[32];
    setup();
    Serial1_begin(9600U);
    if (false == SD_Begin(GPIO4))
    {
        Serial1_println("SD initialization failed.");
        while (1)
        {
        }
    }
    if (false == SD_Open(&file, "data.csv", SD_FILE_WRITE))
    {
        Serial1_println("File open failed.");
        while (1)
        {
        }
    }
    SD_WriteLine(&file, "sample,adc_value");
    for (sample = 1U; sample <= 10U; sample++)
    {
        adcValue = analogRead(ADC0_SE12);
        snprintf(
            line,
            sizeof(line),
            "%u,%d",
            (unsigned int)sample,
            adcValue);
        SD_WriteLine(&file, line);
        Serial1_print("Sample ");
        Serial1_printInt(sample);
        Serial1_print(" | ADC: ");
        Serial1_printlnInt(adcValue);
        delay(1000U);
    }
    SD_Close(&file);
    SD_End();
    Serial1_println("Logging complete.");
    while (1)
    {
    }
    return 0;
}