#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 03 - Fundamentals of Serial Monitor
// English version
// ============================================================================

// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "ut-serial",
    type: "web",
    author: [Jonathan Valvano and Ramesh Yerraballi],
    title: [Chapter 9: Serial Communication],
    source: [Introduction to Embedded Systems - The University of Texas at Austin],
    url: "https://users.ece.utexas.edu/~valvano/Volume1/IntroToEmbSys/Ch9_SerialCommunication.htm",
  ),
  (
    key: "uf-uart",
    type: "web",
    author: [University of Florida],
    title: [Lab 5: Asynchronous Serial Communication],
    source: [EEL4744C - Electrical & Computer Engineering Department],
    url: "https://mil.ufl.edu/4744/labs/lab5_f24_asynchronous_serial_communication.pdf",
  ),
  (
    key: "arduino-serial",
    type: "web",
    author: [Arduino],
    title: [Arduino Language Reference],
    source: [Arduino Documentation],
    url: "https://docs.arduino.cc/language-reference/",
  ),
  (
    key: "eduframework-serial",
    type: "web",
    author: [EduFramework],
    title: [Hardware Serial API],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
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
  number: 3,
  language: "en",
  title: [Fundamentals of Serial \
    Monitor],
  subtitle: [Monitoring System Status with EduFramework],
)

// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Lab Overview

During embedded system development, observing the internal state of a program is necessary for verifying software behavior and monitoring runtime data. A common method is to transmit information from the microcontroller to a computer through serial communication and display the data on a Serial Monitor.

UART (Universal Asynchronous Receiver/Transmitter) is an asynchronous serial communication mechanism commonly integrated into microcontrollers. Data is transmitted sequentially, one bit at a time, between devices without requiring a shared clock line for transmission and reception #cite-ref(refs, "ut-serial").

This lab is designed to introduce the Serial Monitor through the `Serial1` interface of EduFramework. The state of the onboard push button is transmitted to the computer for direct observation on the Serial Monitor. The Serial Monitor therefore becomes a fundamental tool that can be reused in subsequent labs to observe sensor values, system states, and processing results.

== Objectives

#objectives(
  items: (
    [
      Explain the basic principles of asynchronous serial communication and the role of UART in data transmission.
    ],
    [
      Describe the roles of TX, RX, baud rate, and the basic structure of a UART frame.
    ],
    [
      Use the `Serial1_begin()`, `Serial1_print()`, and `Serial1_println()` APIs to transmit data to the Serial Monitor.
    ],
    [
      Build and verify an application that monitors push-button events on the Serial Monitor.
    ],
  ),
)

// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== Serial Communication and Serial Monitor

In serial communication, data is transmitted sequentially one bit at a time rather than transmitting multiple bits simultaneously over multiple signal lines. This method is widely used in embedded systems to exchange data between microcontrollers and other devices #cite-ref(refs, "ut-serial").

A Serial Monitor is a tool for displaying data transmitted through a serial interface. In this lab, the Serial Monitor is used as an observation channel from the MaaZEDU Development Board to the computer. The program can transmit text strings that describe states or events to support verification of system operation.

== UART and Asynchronous Communication

UART performs asynchronous serial communication. Unlike synchronous communication, the two endpoints do not use a shared clock line to determine the timing of data transmission and reception. Instead, the devices must use compatible communication parameters, particularly the transmission rate #cite-ref(refs, "uf-uart").

A typical UART interface uses two signal directions:

#info-table(
  columns: (1fr, 1.3fr, 2.7fr),
  alignments: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Signal],
    [Name],
    [Function],
  ),
  rows: (
    (
      [`TX`],
      [Transmit],
      [Transmits data from the current device to the receiving device.],
    ),
    (
      [`RX`],
      [Receive],
      [Receives data transmitted by another device.],
    ),
  ),
  caption: [Basic UART signal directions],
)

This lab uses only the data transmission direction from the S32K144 to the computer. Therefore, the main content focuses on transmitting data through `Serial1`; data reception will be introduced in a later lab.

== Baud Rate

Baud rate represents the symbol rate of the communication interface. In typical binary UART communication, each symbol corresponds to one bit; therefore, the baud rate determines the transmission interval of each bit. Both endpoints must use compatible configurations so that the transmitted data can be interpreted correctly #cite-ref(refs, "ut-serial").

For example, when the program initializes:

```c
Serial1_begin(9600U);
```

the `Serial1` interface is configured to operate at `9600` baud. The Serial Monitor on the computer must also use the same baud rate.

#note[
  With the current default clock configuration of EduFramework, Serial communication should use low baud rates to ensure stable operation. In this laboratory series, `9600 baud` is recommended and used as the default configuration for the Serial Monitor.

  This limitation is related to the current framework configuration and is not a general limitation of the LPUART peripheral on the S32K144.
]

== Basic UART Frame Structure

Because UART does not use a shared clock line, data must be organized into a frame so that the receiver can identify the beginning and end of the data. A basic UART frame consists of a start bit, data bits, and a stop bit; a parity bit may also be included depending on the configuration #cite-ref(refs, "uf-uart").

A common configuration is `8N1`, consisting of:

#info-table(
  columns: (1.3fr, 2.7fr),
  alignments: (
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Component],
    [Meaning],
  ),
  rows: (
    (
      [1 Start bit],
      [Marks the beginning of a data frame.],
    ),
    (
      [8 Data bits],
      [Contains the eight data bits to be transmitted.],
    ),
    (
      [No parity],
      [No parity bit is used.],
    ),
    (
      [1 Stop bit],
      [Marks the end of the frame before the next data is transmitted.],
    ),
  ),
  caption: [General structure of an 8N1 UART configuration],
)

// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

This lab uses the onboard push button on the MaaZEDU Development Board and the PlatformIO Serial Monitor; therefore, no additional components or external circuit are required.

#hardware-table(
  caption: [Hardware used in the lab exercise],
  rows: (
    (
      [MaaZEDU Development Board],
      [Development board based on the S32K144 microcontroller.],
    ),
    (
      [USB Cable],
      [
        Connects the board to the computer for power, program upload, and use of the Serial Monitor.
      ],
    ),
  ),
)

== Interfaces Used

The `BTN0` push button is used to generate the event to be monitored. EduFramework maps `BTN0` to the `PTC12` pin of the S32K144 #cite-ref(refs, "maazedu-guide").

#pin-table(
  caption: [Digital Input mapping used in the lab exercise],
  rows: (
    (
      [Onboard push button],
      "BTN0",
      "PTC12",
      [Digital Input],
    ),
  ),
)

For Serial data, EduFramework uses `Serial1` for the Serial Monitor and debug information through the board debug interface. `Serial1` is mapped to the `LPUART1` peripheral #cite-ref(refs, "eduframework-serial").

#info-table(
  columns: (1.2fr, 1.4fr, 2.6fr),
  alignments: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Interface],
    [Peripheral],
    [Role in this lab],
  ),
  rows: (
    (
      [`Serial1`],
      [`LPUART1`],
      [Transmits data from the S32K144 to the Serial Monitor on the computer.],
    ),
  ),
  caption: [Serial interface used in the lab exercise],
)

The data flow in this lab can be represented as follows:

`BTN0` → program running on the S32K144 → `Serial1` → Serial Monitor.

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

This lab uses three basic `Serial1` APIs: `Serial1_begin()` to initialize the interface, `Serial1_print()` to transmit a string, and `Serial1_println()` to transmit a string followed by a line termination. These APIs belong to the Arduino-style API layer of EduFramework #cite-ref(refs, "eduframework-serial").

== `Serial1_begin()`

`Serial1_begin()` initializes the `Serial1` interface with the specified baud rate.

#api-detail(
  name: "Serial1_begin",
  syntax: [Serial1_begin(baudRate);],
  description: [
    Initializes `Serial1` for data transmission and reception at the specified baud rate.
  ],
  parameters: (
    (
      [baudRate],
      [Baud rate],
      [Transmission rate used for Serial communication.],
    ),
  ),
  returns: [No return value.],
)

Example:

```c
Serial1_begin(9600U);
```

In this laboratory series, `9600 baud` is used for the Serial Monitor with the current EduFramework configuration.

== `Serial1_print()`

`Serial1_print()` transmits a string through `Serial1` without automatically terminating the line.

#api-detail(
  name: "Serial1_print",
  syntax: [Serial1_print(text);],
  description: [
    Transmits the specified string through `Serial1`.
  ],
  parameters: (
    (
      [text],
      [String],
      [Content to be transmitted to the Serial Monitor.],
    ),
  ),
  returns: [No return value.],
)

Example:

```c
Serial1_print("System status: ");
```

Subsequent transmitted data continues to appear on the same line until a line termination operation is performed.

== `Serial1_println()`

`Serial1_println()` transmits a string through `Serial1` and automatically terminates the line after the transmitted string #cite-ref(refs, "eduframework-serial").

#api-detail(
  name: "Serial1_println",
  syntax: [Serial1_println(text);],
  description: [
    Transmits the specified string through `Serial1` and terminates the line.
  ],
  parameters: (
    (
      [text],
      [String],
      [Content to be transmitted to the Serial Monitor.],
    ),
  ),
  returns: [No return value.],
)

Example:

```c
Serial1_println("System started.");
```

Unlike `Serial1_print()`, data transmitted using `Serial1_println()` terminates the current line, and subsequent content is displayed on a new line. The corresponding organization of `print()` and `println()` is also used in the Arduino Serial model #cite-ref(refs, "arduino-serial").

// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

== Requirements

Build a program that uses `BTN0` as an event source and displays the push-button state on the Serial Monitor. The program must satisfy the following requirements:

- Initialize `Serial1` at `9600` baud.
- Display a message when the system starts.
- When `BTN0` is pressed, the Serial Monitor displays the corresponding message exactly once.
- When `BTN0` is released, the Serial Monitor displays the corresponding message exactly once.
- Holding the button does not cause the same message to be printed continuously.

== Program

In `src/main.c`, implement the program as follows:

#code-listing(
  caption: [Program for monitoring push-button events using the Serial Monitor],
)[
  ```c
  #include "Arduino.h"

  int main(void)
  {
      bool pressed = false;

      setup();

      pinMode(BTN0, INPUT);

      Serial1_begin(9600U);

      Serial1_print("EduFramework ");
      Serial1_println("Serial Monitor");
      Serial1_println("System started.");

      while (1)
      {
          if ((HIGH == digitalRead(BTN0)) && (false == pressed))
          {
              Serial1_println("BTN0 pressed.");
              pressed = true;
          }

          if ((LOW == digitalRead(BTN0)) && (true == pressed))
          {
              Serial1_println("BTN0 released.");
              pressed = false;
          }
      }

      return 0;
  }
  ```
]

After `setup()` initializes EduFramework, `BTN0` is configured as a Digital Input, and `Serial1_begin(9600U)` initializes Serial communication at `9600` baud.

The `Serial1_print()` and `Serial1_println()` APIs are used to display startup information. In the main loop, the `pressed` variable records the processing state of the push button. This mechanism follows the event-detection principle used in Lab 02; however, instead of controlling a Digital Output, the event is converted into information that can be observed on the Serial Monitor.

When `BTN0` changes to the pressed state, the `BTN0 pressed.` message is transmitted once. When the button is released, the program transmits `BTN0 released.` and becomes ready to process the next press event.

== Verification

Build and upload the program to the MaaZEDU Development Board. Then open the Serial Monitor and configure the baud rate to `9600`.

Observe the displayed content when the program starts, then press, hold, and release `BTN0` in sequence.

#block(breakable: false)[
  #expected-result[
    The Serial Monitor displays the system startup information. Each time `BTN0` is pressed, the `BTN0 pressed.` message appears exactly once; when the button is released, the `BTN0 released.` message appears exactly once. Holding the button does not cause the same message to repeat continuously.
  ]
]

// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

The basic APIs in the main exercise focus on transmitting strings. In measurement and monitoring applications, the observed data often also includes numeric values such as event counts, ADC values, or calculated sensor results. EduFramework provides additional APIs for directly printing integer and floating-point values through `Serial1` #cite-ref(refs, "eduframework-serial").

== Printing Integer Values

`Serial1_printInt()` transmits a signed integer value through `Serial1`, while `Serial1_printlnInt()` performs the same operation and terminates the line after the value.

#info-table(
  columns: (1.5fr, 1.5fr, 2.4fr),
  alignments: (
    left + horizon,
    left + horizon,
    left + horizon,
  ),
  headers: (
    [API],
    [Syntax],
    [Function],
  ),
  rows: (
    (
      [`Serial1_printInt()`],
      [`Serial1_printInt(value);`],
      [Prints an integer value without automatically terminating the line.],
    ),
    (
      [`Serial1_printlnInt()`],
      [`Serial1_printlnInt(value);`],
      [Prints an integer value and terminates the line.],
    ),
  ),
  caption: [APIs for printing integer values through Serial1],
)

Example:

```c
Serial1_print("Value: ");
Serial1_printlnInt(value);
```

Separating the descriptive text from the numeric value makes the information on the Serial Monitor easier to read.

== Printing Floating-Point Values

For floating-point data, EduFramework provides `Serial1_printFloat()` and `Serial1_printlnFloat()`. In the current version of EduFramework, floating-point values are displayed with three digits after the decimal point #cite-ref(refs, "eduframework-serial").

#info-table(
  columns: (1.5fr, 1.5fr, 2.4fr),
  alignments: (
    left + horizon,
    left + horizon,
    left + horizon,
  ),
  headers: (
    [API],
    [Syntax],
    [Function],
  ),
  rows: (
    (
      [`Serial1_printFloat()`],
      [`Serial1_printFloat(value);`],
      [Prints a floating-point value without automatically terminating the line.],
    ),
    (
      [`Serial1_printlnFloat()`],
      [`Serial1_printlnFloat(value);`],
      [Prints a floating-point value and terminates the line.],
    ),
  ),
  caption: [APIs for printing floating-point values through Serial1],
)

Example:

```c
Serial1_print("Temperature: ");
Serial1_printFloat(temperature);
Serial1_println(" C");
```

These APIs will be reused in later labs related to ADC and sensors when measured values need to be observed directly on the Serial Monitor.

== Extension Exercise: Counting Button Presses

Extend the main program to track the total number of times `BTN0` has been pressed since system startup. Each valid press event must increment the counter only once.

After each press, the Serial Monitor should display output in the following form:

```text
BTN0 pressed. Count: 1
BTN0 pressed. Count: 2
BTN0 pressed. Count: 3
```

Use `Serial1_print()` together with an appropriate integer-printing API to create a line containing both descriptive text and the counter value.

Do not change the event-detection requirement of the main program: holding the button must not cause the counter to increase continuously.

#expected-result[
  Each time `BTN0` is pressed and recognized as a new event, the counter value increases by one. The Serial Monitor displays the accumulated number of presses in the correct event sequence.
]

== `Serial1` and `Serial2`

EduFramework provides two hardware Serial interfaces intended for different purposes #cite-ref(refs, "eduframework-serial").

#info-table(
  columns: (1.1fr, 1.3fr, 2.8fr),
  alignments: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Interface],
    [Peripheral],
    [Intended Use],
  ),
  rows: (
    (
      [`Serial1`],
      [`LPUART1`],
      [
        Serial Monitor and debug information through the board debug interface.
      ],
    ),
    (
      [`Serial2`],
      [`LPUART2`],
      [
        UART communication with external devices or modules through the corresponding UART pins.
      ],
    ),
  ),
  caption: [Roles of Serial1 and Serial2 in EduFramework],
)

In labs that require data observation on a computer, `Serial1` is used as the preferred monitoring channel. `Serial2` is reserved for applications that need to exchange data with external UART devices. Data reception and command processing through UART will be introduced in a later lab.

// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
