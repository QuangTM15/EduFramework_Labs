#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 04 - Fundamentals of Analog Read
// English version
// ============================================================================

// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "iowa-sampling",
    type: "web",
    author: [Iowa State University],
    title: [Chapter 6: Sampling Theory],
    source: [EE/CprE/HSSE Lab],
    url: "https://class.ece.iastate.edu/mmina/ee418/Notes/Chapter6SamplingTheory-less-book%20stuff.pdf",
  ),
  (
    key: "cmu-photoresistor",
    type: "web",
    author: [Carnegie Mellon University],
    title: [Reading a Photoresistor: How Light Is It?],
    source: [60-223 Introduction to Physical Computing],
    url: "https://courses.ideate.cmu.edu/60-223/s2026/tutorials/reading-a-photoresistor",
  ),
  (
    key: "arduino-analogread",
    type: "web",
    author: [Arduino],
    title: [analogRead()],
    source: [Arduino Language Reference],
    url: "https://docs.arduino.cc/language-reference/en/functions/analog-io/analogRead/",
  ),
  (
    key: "arduino-analogread-resolution",
    type: "web",
    author: [Arduino],
    title: [analogReadResolution()],
    source: [Arduino Language Reference],
    url: "https://docs.arduino.cc/language-reference/en/functions/analog-io/analogReadResolution/",
  ),
  (
    key: "nxp-s32k-datasheet",
    type: "datasheet",
    author: [NXP Semiconductors],
    title: [S32K1xx MCU Family - Data Sheet],
    document: [S32K1XX],
    revision: [15],
    year: [2026],
    url: "https://www.nxp.com/docs/en/data-sheet/S32K1xx.pdf",
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
    key: "eduframework-analog",
    type: "web",
    author: [EduFramework],
    title: [Analog API],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 4,
  language: "en",
  title: [Fundamentals of \
    Analog Read],
  subtitle: [Reading Analog Signals with EduFramework],
)

// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Lab Overview

In embedded systems, many physical quantities do not exist only in two logic states such as `HIGH` and `LOW`, but vary continuously with environmental conditions. To allow a microcontroller to process these signals, an analog voltage must be converted into a digital value through an Analog-to-Digital Converter (ADC).

This lab introduces analog signal reading using the ADC and the EduFramework `analogRead()` API. An LDR photoresistor is connected in a voltage divider to produce a voltage that changes with lighting conditions. The acquired ADC value is transmitted to the Serial Monitor for observation using the knowledge introduced in the previous lab.

The exercise focuses on raw ADC values rather than conversion to lux. This allows the relationship between analog signals, sampling, ADC resolution, and digital values to be observed directly on the hardware.

== Objectives

#objectives(
  items: (
    [
      Distinguish between analog signals and digital representations used in embedded systems.
    ],
    [
      Explain the basic ADC concepts of sampling, quantization, and resolution.
    ],
    [
      Describe how a photoresistor and a voltage divider produce a voltage signal that can be applied to an ADC input.
    ],
    [
      Use `analogRead()` to read a 12-bit ADC value through EduFramework.
    ],
    [
      Build and verify an application that monitors changes in light level on the Serial Monitor.
    ],
  ),
)

// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== Analog Signals and Digital Representation

An analog signal can vary continuously in time and amplitude. In contrast, a digital system processes data as discrete values. Therefore, when a physical quantity is converted into an analog voltage, the microcontroller requires a conversion process to represent that voltage as digital data.

Sampling is the process of converting a continuous-time signal into a sequence of discrete samples #cite-ref(refs, "iowa-sampling"). The ADC plays an important role in this data acquisition process: the input voltage is sampled and the result is represented by a numerical code that the program can process.

== Analog-to-Digital Conversion

The analog-to-digital conversion process can be described using two basic concepts: sampling and quantization.

*Sampling* determines the value of an analog signal at discrete points in time. The time interval between two consecutive samples is called the sampling period, commonly denoted by $T_s$. The sampling frequency $F_s$ is related by:

$ F_s = 1 / T_s $

After sampling, the amplitude of each sample must be represented using a finite number of levels. The process of assigning an analog value to one of the available digital levels is called *quantization*. Because the number of representable levels is finite, the resulting digital value is only a discrete representation of the input voltage. Quantization error is the difference that occurs when the actual value is rounded to the nearest LSB level; increasing ADC resolution reduces the size of each quantization step #cite-ref(refs, "iowa-sampling").

== ADC Resolution

Resolution defines the number of bits used to represent the conversion result. For an ADC with a resolution of $N$ bits, the number of representable codes is:

$ 2^N $

The S32K1xx integrates ADCs with a resolution of up to 12 bits #cite-ref(refs, "nxp-s32k-datasheet"). EduFramework currently configures the analog read path in 12-bit mode #cite-ref(refs, "eduframework-analog"). Therefore:

$ 2^12 = 4096 $

The raw ADC result contains 4096 codes, from `0` to `4095`.

#info-table(
  columns: (1.2fr, 1.4fr, 2fr),
  alignments: (
    center + horizon,
    center + horizon,
    center + horizon,
  ),
  headers: (
    [Resolution],
    [Number of Codes],
    [Raw Value Range],
  ),
  rows: (
    (
      [12-bit],
      [`4096`],
      [`0` to `4095`],
    ),
  ),
  caption: [Representation of a 12-bit ADC Result in EduFramework],
)

The values `0` and `4095` are the codes at the two ends of the conversion range, not units of voltage or light intensity. The relationship between an ADC code and voltage depends on the ADC reference voltage. In this lab, EduFramework configures the resolution at a fixed 12 bits, so the application does not need to change the resolution before reading.

== LDR Photoresistor

A photoresistor, commonly called an LDR (Light-Dependent Resistor), is a component whose resistance changes with the amount of incident light #cite-ref(refs, "cmu-photoresistor"). Therefore, an LDR can be used as a light-sensitive element in applications that need to detect relative changes in lighting conditions.

The ADC does not directly measure the resistance of the LDR. To convert the resistance change into a quantity that the ADC can read, the LDR is combined with a fixed resistor to form a voltage divider #cite-ref(refs, "cmu-photoresistor").

This lab uses the LDR to observe the trend of changing light conditions and does not perform calibration in lux. The ADC value depends on the characteristics of the LDR, the fixed resistor, the supply voltage, and the actual lighting conditions.

== Voltage Divider with LDR

The voltage divider used in this exercise consists of the LDR on the supply side and a fixed `10 kΩ` resistor on the GND side. The midpoint between the two components is connected to the ADC input. With this configuration, the voltage at the measurement point can be expressed by the voltage-divider relationship:

$ V_"ADC" = V_"CC" times (R_"fixed" / (R_"LDR" + R_"fixed")) $

When increased illumination causes the LDR resistance to decrease, the midpoint voltage increases, and the ADC therefore produces a larger digital value. When the LDR is covered and the light level decreases, the opposite trend occurs. This relationship was verified on the circuit used in the exercise.

#note[
  The ADC value represents the voltage at the midpoint of the voltage divider. It is not a measurement of light intensity in lux unless the sensor has been calibrated.
]

// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

This lab uses an LDR and a `10 kΩ` resistor to create an external voltage divider. The midpoint voltage is applied to an ADC channel of the S32K144.

#hardware-table(
  caption: [Hardware Used in the Exercise],
  rows: (
    (
      [MaaZEDU Development Board],
      [Development board based on the S32K144 microcontroller.],
    ),
    (
      [LDR],
      [Photoresistor used to produce a signal that changes with light level.],
    ),
    (
      [10 kΩ Resistor],
      [Fixed resistor used to form a voltage divider with the LDR.],
    ),
    (
      [Breadboard],
      [Used to assemble the voltage-divider circuit.],
    ),
    (
      [Jumper Wires],
      [Connect the power, GND, and ADC signal between the board and the external circuit.],
    ),
    (
      [USB Cable],
      [
        Connects the board to the computer for power, programming, and Serial Monitor communication.
      ],
    ),
  ),
)

== ADC Pin Mapping

EduFramework currently supports two Logical Pins for Analog Input: `ADC0_SE12` and `ADC0_SE13` #cite-ref(refs, "eduframework-analog"). This exercise uses `ADC0_SE12`, which is mapped to `PTC14` on the S32K144.

#pin-table(
  caption: [Analog Input Mapping Used in the Exercise],
  rows: (
    (
      [LDR Voltage-Divider Output],
      "ADC0_SE12",
      "PTC14",
      [Analog Input / ADC0 Channel 12],
    ),
  ),
)

== LDR Circuit Connection

The LDR is connected from the circuit supply to the ADC measurement point. The `10 kΩ` resistor is connected from the ADC measurement point to GND. The midpoint is connected to `ADC0_SE12` (`PTC14`). The board and the external circuit must share a common GND.

#figure-block(
  caption: [Connection Diagram of the LDR and 10 kΩ Resistor to the Analog Input],
)[
  #image(
    "../assets/circuits/ldr_voltage_divider_circuit.png",
    width: 78%,
  )
]

With the connection verified on the hardware, increasing the light level increases the ADC value, while covering the LDR decreases the ADC value. A fixed threshold is not required in this lab because the actual value varies with the component and environmental conditions.

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

== `analogRead()`

`analogRead()` performs one ADC conversion on the specified Analog Logical Pin and waits until the result is available. In the current version of EduFramework, the supported inputs are `ADC0_SE12` and `ADC0_SE13` #cite-ref(refs, "eduframework-analog").

#api-detail(
  name: "analogRead",
  syntax: [analogRead(pin);],
  description: [
    Reads an Analog Input and returns the raw ADC result.
  ],
  parameters: (
    (
      [pin],
      [Analog Logical Pin],
      [
        Analog pin to read. The current version supports `ADC0_SE12` and `ADC0_SE13`.
      ],
    ),
  ),
  returns: [
    Raw ADC value when the conversion succeeds; `-1` if the pin is invalid or initialization/conversion fails.
  ],
)

Example:

```c
int value = analogRead(ADC0_SE12);
```

// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

== Requirements

Build a program that reads the LDR through `ADC0_SE12` and continuously displays the raw ADC value on the Serial Monitor. The program uses a baud rate of `9600` and updates the result approximately every `500 ms`.

Change the lighting conditions by illuminating the LDR more strongly or covering it to observe the trend in the ADC value.

== Program

In `src/main.c`, implement the program that was verified on the hardware as follows:

#block(breakable: false)[
  #code-listing(
    caption: [Program for Reading the LDR through Analog Input],
  )[
    ```c
    #include "Arduino.h"

    int main(void)
    {
        uint16_t lightValue = 0U;

        setup();

        Serial1_begin(9600U);

        Serial1_println("EduFramework Analog Read");
        Serial1_println("LDR monitoring started.");

        while (1)
        {
            lightValue = analogRead(ADC0_SE12);

            Serial1_print("ADC: ");
            Serial1_printlnInt(lightValue);

            delay(500U);
        }

        return 0;
    }
    ```
  ]
]

`setup()` initializes the fundamental components of EduFramework. Then, `Serial1_begin(9600U)` initializes the Serial Monitor channel using the configuration introduced in Lab 03.

In the main loop, `analogRead(ADC0_SE12)` performs one ADC read and stores the result in `lightValue`. This value is sent to the Serial Monitor using the Serial APIs introduced previously. `delay(500U)` creates an interval between two consecutive updates, making the changes slow enough to observe.

The application flow can be summarized as:

`Light` → `LDR + voltage divider` → `ADC0_SE12` → `analogRead()` → `Serial1` → `Serial Monitor`.

== Verification

Build and upload the program to the MaaZEDU Development Board, then open the Serial Monitor at a baud rate of `9600`.

Observe the ADC value under three conditions: ambient light, stronger illumination on the LDR, and the LDR covered. A specific ADC value is not required; the objective is to verify a stable trend as the lighting conditions change.

The Serial Monitor output has the following form:

```text
EduFramework Analog Read
LDR monitoring started.
ADC: ...
ADC: ...
ADC: ...
```

#block(breakable: false)[
  #expected-result[
    The Serial Monitor updates one ADC value approximately every `500 ms`. With the voltage-divider circuit used in the exercise, the value increases when the LDR is illuminated more strongly and decreases when the LDR is covered. The value remains within the 12-bit ADC code range from `0` to `4095`.
  ]
]

// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

The main exercise uses `analogRead()` to focus on the Analog Input concept and raw ADC values. EduFramework also provides an API for converting the result to millivolts and a group of APIs for non-blocking ADC reads #cite-ref(refs, "eduframework-analog").

== Reading Voltage with `analogReadMilliVolts()`

`analogReadMilliVolts()` performs an analog read and converts the raw ADC result to millivolts according to the reference voltage configured in EduFramework.

#api-detail(
  name: "analogReadMilliVolts",
  syntax: [analogReadMilliVolts(pin);],
  description: [
    Reads an Analog Input and returns the value converted to millivolts.
  ],
  parameters: (
    (
      [pin],
      [Analog Logical Pin],
      [Analog pin to read, for example `ADC0_SE12`.],
    ),
  ),
  returns: [
    Voltage value in millivolts when successful; `-1` if the operation fails.
  ],
)

Example:

```c
int voltageMv = analogReadMilliVolts(ADC0_SE12);
```

In the current version of EduFramework, this conversion uses the default reference value of `5000 mV` configured in `wiring_analog.c` #cite-ref(refs, "eduframework-analog"). Therefore, when the result is used as an accurate voltage measurement, the actual reference voltage of the system must match the configuration used in the framework.

*Extension:* Replace the raw ADC value on the Serial Monitor with the value in millivolts and observe the relationship between the two representations as the lighting conditions change.

== Non-blocking ADC Read

`analogRead()` is a blocking API: the function starts the conversion and returns only after the result is available. For an application that needs to continue other processing while waiting for the ADC, EduFramework provides three APIs:

- `analogStart(pin)` starts one conversion and returns immediately.
- `analogAvailable()` checks whether the result is available.
- `analogGetResult()` retrieves the result of the completed conversion.

The usage flow can be represented by the following short example:

#block(breakable: false)[
  #code-listing(
    caption: [Principle of Non-blocking ADC Reading],
  )[
    ```c
    analogStart(ADC0_SE12);

    /* Other application processing */

    if (0U != analogAvailable())
    {
        value = analogGetResult();
    }
    ```
  ]
]

*Extension:* Rewrite the LDR reading section of the exercise using `analogStart()` → `analogAvailable()` → `analogGetResult()` without using `analogRead()`. After receiving the result, display the value on the Serial Monitor and start the next conversion. Do not change the hardware circuit.

// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
