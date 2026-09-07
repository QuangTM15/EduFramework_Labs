#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 02 - Fundamentals of Digital Input
// English version
// ============================================================================


// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "arduino-digitalread",
    type: "web",
    author: [Arduino],
    title: [digitalRead()],
    source: [Arduino Language Reference],
    url: "https://docs.arduino.cc/language-reference/en/functions/digital-io/digitalread/",
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

  (
    key: "uw-gpio",
    type: "web",
    author: [University of Wisconsin-Madison],
    title: [GPIO Pins],
    source: [ECE353 - Introduction to Microprocessor Systems],
    url: "https://ece353.engr.wisc.edu/gpio-pins/gpio-pins/",
  ),

  (
    key: "ti-debounce",
    type: "application-note",
    author: [Texas Instruments],
    title: [Debounce a Switch],
    document: [SCEA094],
    url: "https://www.ti.com/document-viewer/lit/html/scea094",
  ),
)


// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 2,
  language: "en",
  title: [Fundamentals of Digital Input],
  subtitle: [Reading a Push Button and Controlling GPIO with EduFramework],
)


// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Lab Overview

Digital Input allows a microcontroller to receive logic states from external
signals through GPIO. When a pin is configured as a digital input, the program
can read the state at that pin and use the result to perform corresponding
control actions.

This lab is designed to introduce Digital Input through a push button and the
EduFramework APIs. The state of the push button is used to control an external
LED connected to GPIO.


== Objectives

#objectives(
  items: (
    [
      Explain the basic principles of Digital Input and logic states.
    ],
    [
      Use EduFramework to configure and read the state of a push button
      through GPIO.
    ],
    [
      Connect and control an external LED using GPIO.
    ],
    [
      Build and verify an application that uses a push button to change
      the state of an LED.
    ],
  ),
)


// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== Digital Input and Logic Levels

GPIO (General-Purpose Input/Output) can be configured as a digital input or
output. When configured as a Digital Input, a GPIO pin is used to read the
logic level of an external signal.

In EduFramework, Digital Input states are represented by `LOW` and `HIGH`.

#info-table(
  columns: (1fr, 1fr, 2.4fr),
  alignments: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [State],
    [Value],
    [Meaning],
  ),
  rows: (
    (
      [`LOW`],
      [`0U`],
      [A low logic level is detected at the Digital Input.],
    ),
    (
      [`HIGH`],
      [`1U`],
      [A high logic level is detected at the Digital Input.],
    ),
  ),
  caption: [Logic states of a Digital Input],
)

`HIGH` and `LOW` do not represent fixed voltage values. The voltage thresholds
recognized as logic high or logic low depend on the electrical characteristics
of the microcontroller. The limits for the S32K1xx are specified in the NXP
Data Sheet #cite-ref(refs, "nxp-s32k-datasheet").


== Push Button as a Digital Input

A push button has two basic states: pressed and released. When operating the
button changes the logic level at a Digital Input, the program can read this
level to determine the current state of the button.

In a typical application, a Digital Input can be read continuously in the main
loop so that the program can respond when the signal state changes.


== External LED and Current-Limiting Resistor

An LED (Light-Emitting Diode) is a polarized component with an anode and a
cathode. When an LED is driven from GPIO, a series resistor is used to limit
the current through the LED #cite-ref(refs, "uw-gpio").

When connecting an external LED to the development board, ensure the correct
LED polarity and use a common GND between the external circuit and the board.


// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

#hardware-table(
  caption: [Hardware required for the lab],
  rows: (
    (
      [MaaZEDU Development Board],
      [Development board based on the S32K144 microcontroller.],
    ),
    (
      [LED],
      [External LED used as a visual output.],
    ),
    (
      [330 Ω resistor],
      [Series resistor used to limit current through the LED.],
    ),
    (
      [Breadboard],
      [Used to assemble the LED and resistor circuit.],
    ),
    (
      [Jumper wires],
      [Used to connect the external circuit to the development board.],
    ),
  ),
)


== Pin Mapping

The lab uses the onboard `BTN0` push button as a Digital Input and Logical Pin
`GPIO0` as a Digital Output. The hardware mapping is shown in the table below
#cite-ref(refs, "maazedu-guide").

#pin-table(
  caption: [Digital I/O pin mapping used in the lab],
  rows: (
    (
      [Onboard push button],
      "BTN0",
      "PTC12",
      [Digital Input],
    ),
    (
      [External LED],
      "GPIO0",
      "PTE0",
      [Digital Output],
    ),
  ),
)


== External LED Connection

The external LED is connected in series with a current-limiting resistor
between `GPIO0` and GND. The connection is shown in the schematic below.

#figure-block(
  caption: [External LED connection to GPIO],
)[
  #image(
    "../assets/circuits/external_led_circuit.png.png",
    width: 82%,
  )
]

#note[
  An LED is a polarized component. Identify the anode and cathode correctly
  before powering the circuit.
]


// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

The lab uses the EduFramework Digital I/O APIs to configure an input, read its
logic state, and change the state of a Digital Output.


== `pinMode()` with `INPUT`

`pinMode()` configures the operating mode of a Logical Pin. In this lab, the
`INPUT` mode is used to configure a pin as a Digital Input.

#api-detail(
  name: "pinMode",
  syntax: [pinMode(pin, INPUT);],
  description: [
    Configure the specified Logical Pin as a Digital Input.
  ],
  parameters: (
    (
      [pin],
      [Logical Pin],
      [Pin to be configured as a digital input.],
    ),
    (
      [mode],
      [`INPUT`],
      [Digital Input mode.],
    ),
  ),
  returns: [No return value.],
)

Example:

```c
pinMode(BTN0, INPUT);
```


== `digitalRead()`

`digitalRead()` is used to read the current logic state of a Logical Pin
#cite-ref(refs, "arduino-digitalread").

#api-detail(
  name: "digitalRead",
  syntax: [digitalRead(pin);],
  description: [
    Read the current logic state of the specified Logical Pin.
  ],
  parameters: (
    (
      [pin],
      [Logical Pin],
      [Digital Input pin whose state is read.],
    ),
  ),
  returns: [
    `HIGH` when a high logic level is detected; `LOW` when a low logic level
    is detected.
  ],
)

Example:

```c
if (HIGH == digitalRead(BTN0))
{
    /* Button is pressed */
}
```


== `digitalToggle()`

`digitalToggle()` toggles the current logic state of a Digital Output.

#api-detail(
  name: "digitalToggle",
  syntax: [digitalToggle(pin);],
  description: [
    Toggle the current logic state of the specified Logical Pin.
  ],
  parameters: (
    (
      [pin],
      [Logical Pin],
      [Digital Output pin whose state is toggled.],
    ),
  ),
  returns: [No return value.],
)

Example:

```c
digitalToggle(GPIO0);
```


// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

== Requirements

Develop a program that uses `BTN0` to control an external LED connected to
`GPIO0`. The program must satisfy the following requirements:

- The external LED is initially off.
- Each time `BTN0` is pressed, the LED state is toggled once.
- Holding `BTN0` does not cause the LED to toggle continuously.
- After `BTN0` is released, the program is ready to detect the next press.


== Program

Implement the following program in `src/main.c`:

#code-listing(
  caption: [Program for controlling an external LED with a push button],
)[
  ```c
  #include "Arduino.h"

  int main(void)
  {
      bool pressed = false;

      setup();

      pinMode(BTN0, INPUT);
      pinMode(GPIO0, OUTPUT);

      digitalWrite(GPIO0, LOW);

      while (1)
      {
          if ((HIGH == digitalRead(BTN0)) && (false == pressed))
          {
              digitalToggle(GPIO0);
              pressed = true;
          }

          if (LOW == digitalRead(BTN0))
          {
              pressed = false;
          }
      }

      return 0;
  }
  ```
]

`BTN0` is configured as a Digital Input and `GPIO0` as a Digital Output. The
LED is initialized with `digitalWrite(GPIO0, LOW)`.

The `pressed` variable records whether the current button press has already
been processed. When `BTN0` is `HIGH` and `pressed` is `false`, the program
calls `digitalToggle()` to toggle the LED and sets `pressed` to `true`.
Therefore, continuing to hold the button does not toggle the LED repeatedly.

When the button is released and `digitalRead(BTN0)` returns `LOW`, `pressed`
is reset to `false`. The program can then process the next button press.


== Verification

Build and upload the program to the MaaZEDU Development Board. Observe the
external LED while pressing, holding, and releasing `BTN0`.

#expected-result[
  The external LED is initially off. Each time `BTN0` is pressed, the LED
  changes state exactly once. Holding the button does not cause continuous
  toggling. After the button is released, the next press toggles the LED again.
]


// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

== External Push Button and Pull Resistors

When a Digital Input is not actively connected to a high or low logic level,
the state at the pin may be undefined. A pull-up or pull-down resistor is used
to establish a default input state when the switch is open.

The S32K1xx integrates pull-up and pull-down resistors for I/O pins. Under
3.3 V I/O conditions, the Data Sheet specifies an internal pull-resistor range
of `20 kΩ` to `60 kΩ` #cite-ref(refs, "nxp-s32k-datasheet").

EduFramework provides two Digital Input modes with internal pull resistors:

#info-table(
  columns: (1.4fr, 2.6fr),
  alignments: (
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Mode],
    [Function],
  ),
  rows: (
    (
      [`INPUT_PULLUP`],
      [Digital Input with an internal pull-up resistor.],
    ),
    (
      [`INPUT_PULLDOWN`],
      [Digital Input with an internal pull-down resistor.],
    ),
  ),
  caption: [Digital Input modes with internal pull resistors],
)

Example:

```c
pinMode(pin, INPUT_PULLUP);
pinMode(pin, INPUT_PULLDOWN);
```

*Extension:* Replace the onboard push button with an external push button
connected to another GPIO Logical Pin. Select `INPUT_PULLUP` or
`INPUT_PULLDOWN` according to the circuit connection and adjust the condition
used to detect the pressed state.


== Button Debouncing

The mechanical contacts of a push button can generate several short
transitions while closing or opening. This phenomenon is called contact bounce
and can cause one physical action to be detected as multiple digital events
#cite-ref(refs, "ti-debounce").

Debouncing is the process of suppressing these unwanted transitions. Depending
on the application requirements, debouncing can be implemented in hardware or
software.

EduFramework automatically enables the passive input filter for Logical Pins
identified as onboard push buttons. This mechanism helps filter short input
pulses, but it does not replace a complete debounce method in every case.

*Extension:* Use an external push button and propose a software debounce method
that processes the button state only after the signal has remained stable for
a defined period.


// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
