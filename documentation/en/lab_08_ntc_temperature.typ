#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 08 - Temperature Measurement with NTC
// English version
// ============================================================================

// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "mit-thermistor",
    type: "web",
    author: [Massachusetts Institute of Technology],
    title: [Introduction to Electronics, Signals and Measurement],
    source: [MIT OpenCourseWare],
    year: [2006],
    url: "https://ocw.mit.edu/courses/6-071j-introduction-to-electronics-signals-and-measurement-spring-2006/837566791a647fbcef525979e34dc9bd_intro_to_elctro.pdf",
  ),
  (
    key: "psu-thermistor",
    type: "web",
    author: [Gerald Recktenwald],
    title: [Temperature Measurement with a Thermistor and an Arduino],
    source: [Portland State University],
    year: [2010],
    url: "https://web.cecs.pdx.edu/~gerry/class/EAS199B/howto/thermistorArduino/thermistorArduino.pdf",
  ),
  (
    key: "microchip-an897",
    type: "application-note",
    author: [Microchip Technology Inc.],
    title: [Thermistor Temperature Sensing with MCP6SX2 PGAs],
    document: [AN897],
    year: [2015],
    url: "https://www.microchip.com/en-us/application-notes/an897",
  ),
  (
    key: "nxp-s32k-cookbook",
    type: "application-note",
    author: [NXP Semiconductors],
    title: [S32K1xx Series Cookbook],
    document: [AN5413],
    revision: [5],
    year: [2020],
    url: "https://www.nxp.com/docs/en/application-note/AN5413.pdf",
  ),
  (
    key: "maazedu-guide",
    type: "manual",
    author: [MaaZEDU],
    title: [MaaZEDU Development Board Guide],
  ),
  (
    key: "eduframework-ntc",
    type: "web",
    author: [EduFramework],
    title: [NTC Device API],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 8,
  language: "en",
  title: [Temperature\
    Measurement with NTC],
  subtitle: [Reading Temperature with the NTC Device API in EduFramework],
)

// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Lab Overview

Temperature is a physical quantity commonly monitored in measurement and control systems. A thermistor is a resistive element whose resistance changes with temperature; for an NTC (Negative Temperature Coefficient) thermistor, resistance decreases as temperature increases #cite-ref(refs, "mit-thermistor").

In previous labs, analog signals were read as ADC values or used directly to control an output. This lab moves to the Device layer of EduFramework: the electrical signal from the NTC module is processed through the ADC and then converted into resistance and temperature so that the application can work directly with the physical quantity in degrees Celsius #cite-ref(refs, "psu-thermistor") #cite-ref(refs, "eduframework-ntc").

The lab exercise uses `NTC_ReadCelsius()` to read temperature from the NTC module and display the result on the Serial Monitor. Intermediate values such as voltage and resistance are reserved for the Extension section.

== Objectives

#objectives(
  items: (
    [
      Describe the basic operating principle of an NTC thermistor and the relationship between temperature and resistance.
    ],
    [
      Explain how a voltage divider converts the resistance variation of an NTC thermistor into an analog voltage that can be measured by an ADC.
    ],
    [
      Describe the conversion path from the analog signal of the NTC module to a temperature value in EduFramework.
    ],
    [
      Use `NTC_Init()` and `NTC_ReadCelsius()` to read temperature in degrees Celsius.
    ],
    [
      Build and verify a temperature monitoring application using the Serial Monitor.
    ],
  ),
)

// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== NTC Thermistor

A thermistor is a temperature-dependent resistor commonly used as a temperature-sensing element. The two basic categories are NTC and PTC. With an NTC thermistor, resistance decreases as temperature increases; with a PTC thermistor, resistance increases as temperature increases. The resistance-temperature characteristic of a thermistor is nonlinear #cite-ref(refs, "mit-thermistor").

In temperature measurement, the change in NTC resistance is an intermediate quantity. A microcontroller does not directly measure resistance with an ADC; the resistance variation must first be converted into a measurable voltage #cite-ref(refs, "psu-thermistor").

#note[
  An NTC thermistor is a temperature-sensitive element with a nonlinear characteristic. Its resistance cannot be treated as temperature through a simple linear relationship over the entire measurement range #cite-ref(refs, "mit-thermistor").
]

== Voltage Divider and Analog Signal

A common method for measuring a thermistor with a microcontroller is to connect the NTC thermistor and a fixed resistor as a voltage divider. As the NTC resistance changes, the voltage at the midpoint also changes and can be applied to an ADC input #cite-ref(refs, "psu-thermistor") #cite-ref(refs, "microchip-an897").

For the configuration used by the EduFramework NTC Device:

`VREF` → `R_FIXED` → `ADC(AO)` → `NTC` → `GND`

the voltage at the ADC input is determined by the voltage-divider relationship:

$ V_"ADC" = V_"REF" times (R_"NTC" / (R_"FIXED" + R_"NTC")) $

From the measured voltage, the NTC resistance can be derived as:

$ R_"NTC" = R_"FIXED" times (V_"ADC" / (V_"REF" - V_"ADC")) $

This relationship corresponds to the way `NTC_ReadResistance()` converts the measured voltage into resistance in the current EduFramework implementation #cite-ref(refs, "psu-thermistor") #cite-ref(refs, "eduframework-ntc").

The S32K144 integrates an ADC to convert an analog voltage into digital data. EduFramework uses its Analog API layer to perform ADC measurements for the NTC Device #cite-ref(refs, "nxp-s32k-cookbook") #cite-ref(refs, "eduframework-ntc").

== From Analog Signal to Temperature

The temperature measurement path in this lab can be represented as follows:

`Temperature` → `NTC resistance` → `AO voltage` → `ADC` → `Resistance` → `Temperature`

The ADC measurement and resistance calculation steps are encapsulated by the Device API. Therefore, the application does not need to read the ADC and perform the voltage-divider calculation manually before obtaining a temperature value #cite-ref(refs, "eduframework-ntc").

In the current implementation, `NTC_ReadCelsius()` calls `NTC_ReadResistance()` to obtain the resistance and then uses a lookup table for a `10 kΩ` B3950 NTC thermistor with linear interpolation between adjacent points to determine the temperature. The lookup table covers temperature points from `-20 °C` to `80 °C`; when the resistance lies outside the two ends of the table, the implementation returns the corresponding boundary temperature #cite-ref(refs, "eduframework-ntc").

The MIT material presents the NTC characteristic as resistance-versus-temperature data, showing that different temperature regions correspond to different resistance ranges #cite-ref(refs, "mit-thermistor"). EduFramework currently applies discrete data based on this principle in its internal lookup table and interpolates between adjacent points #cite-ref(refs, "eduframework-ntc").

// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

The lab uses the MaaZEDU Development Board together with an NTC module that provides an analog `AO` output. MaaZEDU uses the S32K144 microcontroller; the module's `AO` signal is connected to an ADC Logical Pin in EduFramework, and the resulting temperature is observed through the Serial Monitor #cite-ref(refs, "maazedu-guide") #cite-ref(refs, "eduframework-ntc").

#hardware-table(
  caption: [Hardware used in the lab exercise],
  rows: (
    (
      [MaaZEDU Development Board],
      [Development board based on the S32K144 microcontroller.],
    ),
    (
      [NTC temperature sensor module],
      [NTC thermistor module with an analog `AO` output for temperature measurement.],
    ),
    (
      [Jumper wires],
      [Connect power, GND, and the analog signal between the NTC module and MaaZEDU.],
    ),
    (
      [USB Cable],
      [
        Connect the board to the computer for power, programming, and Serial Monitor communication.
      ],
    ),
  ),
)

== Pin Mapping

The NTC Device API accepts an analog Logical Pin as its input parameter. This lab uses `ADC0_SE13` to receive the `AO` signal from the NTC module #cite-ref(refs, "eduframework-ntc").

#pin-table(
  caption: [NTC signal mapping used in the lab exercise],
  rows: (
    (
      [NTC `AO`],
      "ADC0_SE13",
      "PTC15",
      [Analog Input / ADC0 Channel 13],
    ),
  ),
)

== Connecting the NTC Module

In the hardware configuration verified for this lab exercise, the NTC module is powered from `3.3V`, shares `GND` with MaaZEDU, and provides its `AO` signal to `ADC0_SE13`. The module's `DO` pin is not used in the main exercise. The NTC Device analog measurement path supports ADC Logical Pins such as `ADC0_SE12` and `ADC0_SE13` #cite-ref(refs, "maazedu-guide") #cite-ref(refs, "eduframework-ntc").

#figure-block(
  caption: [NTC module connection to the MaaZEDU Development Board],
)[
  #image(
    "../assets/circuits/ntc_temperature_circuit.png",
    width: 82%,
  )
]

#note[
  The main exercise uses only the analog `AO` output. The digital `DO` output available on some NTC modules can be used for threshold detection and is introduced in the Extension section #cite-ref(refs, "eduframework-ntc").
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

The main exercise requires only two NTC Device APIs: `NTC_Init()` and `NTC_ReadCelsius()`. Voltage and resistance measurements, together with additional functions, are reserved for the Extension section #cite-ref(refs, "eduframework-ntc").

== `NTC_Init()`

`NTC_Init()` initializes the default configuration of the NTC Device.

#api-detail(
  name: "NTC_Init",
  syntax: [NTC_Init();],
  description: [
    Initialize the default configuration of the NTC Device before performing measurements.
  ],
  parameters: (),
  returns: [
    No return value.
  ],
)

Example:

```c
NTC_Init();
```

== `NTC_ReadCelsius()`

`NTC_ReadCelsius()` reads the NTC analog signal, calculates the resistance, and returns the converted temperature in degrees Celsius. The API accepts the analog Logical Pin connected to the module's `AO` pin #cite-ref(refs, "eduframework-ntc").

#api-detail(
  name: "NTC_ReadCelsius",
  syntax: [NTC_ReadCelsius(pin);],
  description: [
    Read the NTC module through an Analog Input and return the temperature in degrees Celsius.
  ],
  parameters: (
    (
      [pin],
      [Analog Logical Pin],
      [
        Analog pin connected to the `AO` output of the NTC module, for example `ADC0_SE13`.
      ],
    ),
  ),
  returns: [
    Temperature in degrees Celsius when the measurement succeeds; `-273.15F` when the measurement or conversion fails.
  ],
)

Example:

```c
float temperature = NTC_ReadCelsius(ADC0_SE13);
```

// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

== Requirements

Build a program that reads temperature from the NTC module through `ADC0_SE13` and displays the result on the Serial Monitor. The program initializes `Serial1` at a baud rate of `9600`, initializes the NTC Device once, and updates the temperature value every `1000 ms`.

After the program operates stably, change the temperature around the thermistor by gently touching it or placing the sensor near a safe heat source to observe the trend in the measured result. A fixed temperature value is not required; the objective is to verify that the measurement responds appropriately when the thermal condition changes.

== Program

In `src/main.c`, implement the program that has been verified on hardware as follows:

#block(breakable: false)[
  #code-listing(
    caption: [Program for reading temperature from the NTC module],
  )[
    ```c
    #include "Arduino.h"
    #include "ntc.h"

    int main(void)
    {
        float temperature = 0.0F;

        setup();

        Serial1_begin(9600U);
        NTC_Init();

        Serial1_println("NTC Temperature Monitor");

        while (1)
        {
            temperature = NTC_ReadCelsius(ADC0_SE13);

            Serial1_print("Temperature: ");
            Serial1_printFloat(temperature);
            Serial1_println(" C");

            delay(1000U);
        }

        return 0;
    }
    ```
  ]
]

`setup()` initializes the underlying components of EduFramework. `Serial1_begin()` initializes the Serial Monitor channel using the configuration introduced in Lab 03, while `NTC_Init()` initializes the default configuration of the NTC Device #cite-ref(refs, "eduframework-ntc").

In the main loop, `NTC_ReadCelsius(ADC0_SE13)` performs the required NTC Device measurement path and returns the temperature in degrees Celsius. The result is printed to the Serial Monitor, and `delay(1000U)` then creates a one-second interval between updates.

The application processing flow can be summarized as:

`Temperature` → `NTC module` → `ADC0_SE13` → `NTC_ReadCelsius()` → `Serial1` → `Serial Monitor` #cite-ref(refs, "eduframework-ntc").

== Verification

Build and upload the program to the MaaZEDU Development Board, then open the Serial Monitor at a baud rate of `9600`. Observe the temperature value while the sensor is in a stable environment, then safely warm the thermistor and verify the trend in the displayed value.

The Serial Monitor output has the following form:

```text
NTC Temperature Monitor
Temperature: 28.91 C
Temperature: 29.02 C
Temperature: 29.14 C
Temperature: 29.27 C
```

#block(breakable: false)[
  #expected-result[
    The Serial Monitor updates the temperature approximately every `1000 ms`. Under stable thermal conditions, consecutive values fluctuate within a similar range. When the thermistor is warmed, the displayed temperature tends to increase; when the heat source is removed and the sensor gradually cools, the value tends to return toward the ambient temperature. This response is consistent with the NTC principle and the conversion path implemented in the NTC Device #cite-ref(refs, "mit-thermistor") #cite-ref(refs, "eduframework-ntc").
  ]
]

// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

The main exercise uses only the final temperature value to keep the program concise. The NTC Device also provides APIs for observing intermediate measurement quantities or using other operating modes of the module #cite-ref(refs, "eduframework-ntc").

== Observing Voltage with `NTC_ReadMilliVolts()`

`NTC_ReadMilliVolts()` reads the analog output of the module and returns the value converted to millivolts through the EduFramework Analog API #cite-ref(refs, "eduframework-ntc").

#api-detail(
  name: "NTC_ReadMilliVolts",
  syntax: [NTC_ReadMilliVolts(pin);],
  description: [
    Read the voltage at the analog output of the NTC module and return the value in millivolts.
  ],
  parameters: (
    (
      [pin],
      [Analog Logical Pin],
      [Analog pin connected to the `AO` output of the NTC module.],
    ),
  ),
  returns: [
    Voltage in millivolts when successful; `-1` if the pin is invalid or the ADC measurement fails.
  ],
)

Example:

```c
int voltageMv = NTC_ReadMilliVolts(ADC0_SE13);
```

== Observing Resistance with `NTC_ReadResistance()`

`NTC_ReadResistance()` uses the measured voltage and the NTC Device voltage-divider configuration to calculate the thermistor resistance #cite-ref(refs, "eduframework-ntc").

#api-detail(
  name: "NTC_ReadResistance",
  syntax: [NTC_ReadResistance(pin);],
  description: [
    Calculate the NTC resistance from the analog measurement and return the result in ohms.
  ],
  parameters: (
    (
      [pin],
      [Analog Logical Pin],
      [Analog pin connected to the `AO` output of the NTC module.],
    ),
  ),
  returns: [
    Resistance in ohms when the measurement is valid; `-1.0F` if the measurement or calculation fails.
  ],
)

Example:

```c
float resistance = NTC_ReadResistance(ADC0_SE13);
```

*Extension:* Modify the program to print voltage, resistance, and temperature simultaneously in order to observe the processing sequence:

`AO voltage` → `NTC resistance` → `Temperature`.

The result can be presented in the following form:

```text
Voltage: ... mV
Resistance: ... Ohm
Temperature: ... C
```

== Additional NTC APIs

EduFramework also provides the following additional APIs #cite-ref(refs, "eduframework-ntc"):

- `NTC_ReadRaw(pin)` returns the raw ADC value from the analog input.

- `NTC_ReadFahrenheit(pin)` returns the temperature in degrees Fahrenheit.

- `NTC_ReadThreshold(pin)` reads the digital `DO` output state of the NTC module if the hardware includes a comparator and the pin is connected.

- `NTC_SetConfig()` allows the NTC Device calculation configuration to be changed.

- `NTC_GetConfig()` retrieves the current NTC configuration.

The configuration APIs and the `DO` output are not required for the main exercise. They are useful when a different NTC type, voltage-divider configuration, or threshold-detection mode is required compared with the basic configuration #cite-ref(refs, "eduframework-ntc").

*Extension:* Select one of the APIs above and add it to the program without changing the main temperature-reading function. For example, display the temperature in Fahrenheit or connect the `DO` pin to a Digital Input to observe the threshold state.

// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
