#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 01 - Digital Output Fundamentals
// English version
// ============================================================================


// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "arduino-digital-pins",
    type: "web",
    author: [Arduino],
    title: [Digital Pins],
    source: [Arduino Documentation],
    url: "https://docs.arduino.cc/learn/microcontrollers/digital-pins/",
  ),

  (
    key: "arduino-language-reference",
    type: "web",
    author: [Arduino],
    title: [Arduino Language Reference],
    source: [Arduino Documentation],
    url: "https://docs.arduino.cc/language-reference/",
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
    key: "maazedu-guide",
    type: "manual",
    author: [MaaZEDU],
    title: [MaaZEDU Development Board Guide],
  ),
)


// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 1,
  language: "en",
  title: [Digital Output Fundamentals],
  subtitle: [GPIO Control with EduFramework],
)


// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Lab Overview

Digital Input/Output (Digital I/O) is a fundamental GPIO function that allows
a microcontroller to exchange logic states with external hardware. When a GPIO
pin is configured as an output, the program can set the logic state of the pin
to generate a digital signal #cite-ref(refs, "arduino-digital-pins").

This lab is designed to introduce Digital Output through the APIs provided by
EduFramework. An onboard LED on the MaaZEDU Development Board is used as a
visual output. By alternating between the `HIGH` and `LOW` logic states over
time, the program implements a basic LED blinking application.


== Objectives

#objectives(
  items: (
    [
      Explain the basic principle of Digital Output and the meaning of the
      `HIGH` and `LOW` logic states.
    ],

    [
      Identify the relationship between GPIO logic states and the state of an
      active-low LED.
    ],

    [
      Use the `pinMode()`, `digitalWrite()`, and `delay()` APIs to control
      Digital Output.
    ],

    [
      Develop and verify an LED blinking application on the MaaZEDU
      Development Board.
    ],
  ),
)


// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== Digital Output and Logic States

GPIO (General-Purpose Input/Output) pins can be configured to perform digital
input or output functions. When configured as a Digital Output, the logic state
of the pin is controlled by the program. In EduFramework, the output mode is
represented by `OUTPUT`, while the two logic states are represented by `HIGH`
and `LOW`.

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1fr, 1fr, 2.6fr),
    align: (center + horizon, center + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*State*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Value*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Meaning*]
      ],
    ),

    [`LOW`], [`0U`], [Low logic state.],
    [`HIGH`], [`1U`], [High logic state.],
  )
]

`HIGH` and `LOW` represent logic states rather than fixed voltage values. The
actual voltage levels and electrical limits of an I/O pin depend on the
characteristics of the microcontroller. For the S32K1xx family, these
specifications are defined in the NXP Data Sheet
#cite-ref(refs, "nxp-s32k-datasheet").


== Digital Output and Active-Low LEDs

LEDs are commonly used to visually represent the state of a digital output.
However, the relationship between the GPIO logic state and whether the LED is
on or off depends on how the LED is connected in the circuit.

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.2fr, 1.4fr, 1.4fr),
    align: (center + horizon, center + horizon, center + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Configuration*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*LED ON*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*LED OFF*]
      ],
    ),

    [Active-high], [`HIGH`], [`LOW`],
    [Active-low], [`LOW`], [`HIGH`],
  )
]

The onboard LEDs used in the hardware configuration of this lab operate
according to the active-low principle. Therefore, `LOW` turns the LED on,
whereas `HIGH` turns the LED off.

#note[
  `HIGH` and `LOW` describe the logic state of a GPIO pin, whereas ON and OFF
  describe the state of the connected device. The relationship between these
  states is determined by the hardware configuration.
]


== LED Blinking Cycle

An LED blinking application periodically changes the state of the LED. In this
lab, the LED remains on for `500 ms` and off for `500 ms`. Therefore, the
duration of one complete cycle is:

$ T = 500 " ms" + 500 " ms" = 1000 " ms" = 1 " s" $

#figure-block(
  caption: [Timing relationship of the LED blinking application],
)[
  #image(
    "../assets/images/blink_timing_diagram.png",
    width: 100%,
  )
]

The interval between state changes is generated using `delay()`, allowing both
LED states to be directly observed on the hardware.


// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

This lab directly uses an onboard LED on the MaaZEDU Development Board and
does not require any additional external components or wiring.

#hardware-table(
  caption: [Hardware used in this lab],

  rows: (
    (
      [MaaZEDU Development Board],
      [Development board based on the S32K144 microcontroller.],
    ),

    (
      [USB Cable],
      [Connects the board to the computer for power and program uploading.],
    ),
  ),
)


== Onboard LED Mapping

EduFramework provides Logical Pins for accessing the onboard LEDs from
application code. The hardware mapping used by the framework is shown below:

#pin-table(
  caption: [Onboard LED mapping on the MaaZEDU Development Board],

  rows: (
    (
      [Red LED],
      "LED_RED",
      "PTD15",
      [Digital Output],
    ),

    (
      [Blue LED],
      "LED_BLUE",
      "PTD16",
      [Digital Output],
    ),

    (
      [Green LED],
      "LED_GREEN",
      "PTD0",
      [Digital Output],
    ),
  ),
)

The main exercise uses `LED_RED`, which is mapped by EduFramework to the
S32K144 `PTD15` pin.


// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

The LED blinking application uses three APIs: `pinMode()` to configure a
Digital Output, `digitalWrite()` to set the logic state, and `delay()` to
provide a time interval between state changes. These APIs follow the familiar
Arduino programming model
#cite-ref(refs, "arduino-language-reference").


== `pinMode()`

`pinMode()` is used to configure the operating mode of a digital pin.

#api-detail(
  name: "pinMode",

  syntax: [pinMode(pin, mode);],

  description: [
    Configures the operating mode of the specified Logical Pin.
  ],

  parameters: (
    (
      [pin],
      [Logical Pin],
      [Pin to be configured, for example `LED_RED`.],
    ),

    (
      [mode],
      [`OUTPUT`],
      [Configures the pin as a Digital Output.],
    ),
  ),

  returns: [No return value.],
)

Example:

```c
pinMode(LED_RED, OUTPUT);
```


== `digitalWrite()`

`digitalWrite()` is used to set the logic state of a Digital Output pin.

#api-detail(
  name: "digitalWrite",

  syntax: [digitalWrite(pin, value);],

  description: [
    Sets the logic state of the specified Logical Pin.
  ],

  parameters: (
    (
      [pin],
      [Logical Pin],
      [Pin to be controlled, for example `LED_RED`.],
    ),

    (
      [value],
      [`HIGH` / `LOW`],
      [Logic state to be applied to the output pin.],
    ),
  ),

  returns: [No return value.],
)

Example:

```c
digitalWrite(LED_RED, LOW);
digitalWrite(LED_RED, HIGH);
```


== `delay()`

`delay()` creates a waiting period before the program continues with the next
instruction.

#api-detail(
  name: "delay",

  syntax: [delay(ms);],

  description: [
    Creates a time delay specified in milliseconds.
  ],

  parameters: (
    (
      [ms],
      [Time],
      [Required delay duration in milliseconds.],
    ),
  ),

  returns: [No return value.],
)

Example:

```c
delay(500U);
```

The statement above creates a delay of `500 ms`.


// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

Create a PlatformIO project using EduFramework for the MaaZEDU Development
Board.


== Requirements

Develop a program that continuously blinks the onboard red LED. The LED remains
on for `500 ms`, then turns off for `500 ms`, and the sequence repeats
continuously.


== Program

Implement the following program in `src/main.c`:

#code-listing(
  caption: [LED blinking program using EduFramework],
)[
  ```c
  #include "Arduino.h"

  int main(void)
  {
      setup();

      pinMode(LED_RED, OUTPUT);

      while (1)
      {
          digitalWrite(LED_RED, LOW);
          delay(500U);

          digitalWrite(LED_RED, HIGH);
          delay(500U);
      }

      return 0;
  }
  ```
]

`setup()` initializes EduFramework before its APIs are used. `pinMode()` then
configures `LED_RED` as a Digital Output. Inside the `while (1)` loop,
`digitalWrite()` alternately sets `LOW` and `HIGH`; each state is maintained
for `500 ms` using `delay()`.

Because the LED operates in an active-low configuration, `LOW` corresponds to
the ON state and `HIGH` corresponds to the OFF state.


== Verification

Build and upload the program to the MaaZEDU Development Board, then observe the
onboard red LED.

#expected-result[
  The red LED remains on for approximately `500 ms`, turns off for
  approximately `500 ms`, and repeats continuously. One complete blinking
  cycle lasts approximately `1 s`.
]


// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

In addition to the basic APIs used in the main exercise, EduFramework provides
additional and more advanced APIs for a variety of application requirements.
In this section, `digitalToggle()` is used to toggle the state of a Digital
Output, while `millis()` is used to track elapsed execution time without
creating a waiting period with `delay()`.


== Toggling the State with `digitalToggle()`

`digitalToggle()` toggles the current logic state of a Digital Output. If the
current state is `LOW`, the pin changes to `HIGH`; conversely, if the current
state is `HIGH`, the pin changes to `LOW`.

#api-detail(
  name: "digitalToggle",

  syntax: [digitalToggle(pin);],

  description: [
    Toggles the current logic state of the specified Logical Pin.
  ],

  parameters: (
    (
      [pin],
      [Logical Pin],
      [Digital Output pin whose state is to be toggled.],
    ),
  ),

  returns: [No return value.],
)

*Extension:* Rewrite the LED blinking program using `digitalToggle()` so that
the LED state still changes every `500 ms`.


== Timing with `millis()`

`delay()` creates a waiting period and holds the execution flow until the
specified duration has elapsed. In applications that need to continue
processing other tasks while tracking time, `millis()` can be used to determine
the elapsed time without stopping the main loop.

#api-detail(
  name: "millis",

  syntax: [millis();],

  description: [
    Reads the number of milliseconds elapsed since the system time base was
    initialized.
  ],

  parameters: (),

  returns: [
    Elapsed time in milliseconds.
  ],
)

A time interval can be checked using the following principle:

#code-listing(
  caption: [Checking a time interval using `millis()`],
)[
  ```c
  if ((millis() - previousTime) >= interval)
  {
      /* Periodic operation */
  }
  ```
]

Here, `previousTime` stores the timestamp of the previous operation, while
`interval` defines the time interval between two operations.

*Extension:* Rewrite the LED blinking application with a `500 ms` state-change
interval without using `delay()`. When the required interval has elapsed, use
`digitalToggle()` to change the LED state and update the timestamp.


== Extended Exercise

Develop a program that simultaneously controls the three onboard LEDs with
independent state-change intervals:

- `LED_RED`: `500 ms`.
- `LED_BLUE`: `1000 ms`.
- `LED_GREEN`: `1500 ms`.

Do not use `delay()` inside the main loop. Each LED must use an independent
timestamp so that timing one LED does not stop the processing of the other
LEDs.

#expected-result[
  The three LEDs blink simultaneously according to their respective time
  intervals and operate independently in terms of timing.
]


// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
