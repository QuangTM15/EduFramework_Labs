#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 18 - CAN Loopback Communication
// English version
// ============================================================================

// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "umich-can",
    type: "web",
    author: [J. A. Cook, J. S. Freudenberg],
    title: [Controller Area Network (CAN)],
    source: [University of Michigan, EECS 461 Lecture Notes],
    year: [2008],
    url: "https\://eecs.umich.edu/courses/eecs461/doc/CAN_notes.pdf",
  ),
  (
    key: "ti-can",
    type: "application-note",
    author: [Steve Corrigan, Texas Instruments],
    title: [Introduction to the Controller Area Network (CAN)],
    document: [SLOA101B],
    revision: [B],
    year: [2016],
    url: "https\://www\.ti.com/lit/an/sloa101b/sloa101b.pdf",
  ),
  (
    key: "cia-can",
    type: "web",
    author: [CAN in Automation (CiA)],
    title: [CAN CC (Classical CAN)],
    source: [CiA CAN Knowledge],
    url: "https\://www\.can-cia.org/can-knowledge/can-cc",
  ),
  (
    key: "kvaser-can",
    type: "web",
    author: [Kvaser],
    title: [The CAN Bus Protocol Tutorial],
    source: [Kvaser Technical Tutorial],
    url: "https\://kvaser.com/can-protocol-tutorial/",
  ),
  (
    key: "nxp-cookbook",
    type: "application-note",
    author: [NXP Semiconductors],
    title: [S32K1xx Series Cookbook],
    document: [AN5413],
    revision: [5],
    year: [2020],
    url: "https\://www\.nxp.com/docs/en/application-note/AN5413.pdf",
  ),
  (
    key: "eduframework-can",
    type: "web",
    author: [EduFramework],
    title: [Arduino-style CAN API (can.h, can.c)],
    source: [EduFramework Source Code],
    url: "https\://github.com/QuangTM15/s32k144-edu-framework",
  ),
  (
    key: "maazedu-guide",
    type: "manual",
    author: [FPT Software],
    title: [MaaZ Edu Development Board User Manual],
    revision: [1.0],
    year: [2025],
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 18,
  language: "en",
  title: [CAN Loopback \
    Communication],
  subtitle: [Internal CAN Transmission and Reception with EduFramework],
)

// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Overview

Controller Area Network (CAN) is a serial communication protocol developed for
systems with distributed controllers, particularly in automotive applications.
Rather than requiring a separate connection between every pair of Electronic
Control Units (ECUs), multiple devices can exchange messages over a shared CAN
network #cite-ref(refs, "umich-can") #cite-ref(refs, "ti-can").

This lab introduces Classical CAN and demonstrates how to construct, transmit,
and receive a CAN frame using the Arduino-style CAN API of EduFramework on the
S32K144. Internal Loopback mode allows the FlexCAN controller to receive its own
transmitted frame, enabling verification on a single board without a second ECU
#cite-ref(refs, "eduframework-can").

Transmitted and received values are displayed on the Serial Monitor. The
exercise focuses on CAN IDs, frame formats, data length, and payload; physical
CAN bus communication between two ECUs will be covered in Lab 19.

== Objectives

#objectives(
  items: (
    [Describe the role of CAN in communication networks connecting vehicle ECUs.],
    [Distinguish standard 11-bit and extended 29-bit CAN IDs and identify the Classical CAN payload limit.],
    [Identify the principal fields of a CAN data frame and explain message priority.],
    [Explain Internal Loopback and the scope of verification provided by this mode.],
    [Use EduFramework CAN APIs to transmit, receive, and compare data on the Serial Monitor.],
  ),
)

// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== CAN in Automotive Systems

A vehicle may contain multiple ECUs responsible for functions such as engine
management, powertrain control, braking, and information display. These ECUs
must exchange status information and control data without an excessive increase
in wiring. CAN provides a shared communication mechanism for nodes on a network
#cite-ref(refs, "umich-can") #cite-ref(refs, "ti-can").

CAN is a message-oriented protocol. Each message carries an identifier (CAN ID)
rather than a fixed destination device address. On a conventional CAN bus, nodes
can observe transmitted messages; the application or controller determines which
messages should be processed #cite-ref(refs, "kvaser-can").

At the physical layer, high-speed CAN uses two differential signal lines,
`CAN_H` and `CAN_L`, to exchange data between nodes through CAN transceivers.
The CAN controller in the MCU handles the protocol, while the transceiver
converts signals between the controller and the physical bus
#cite-ref(refs, "ti-can").

== Classical CAN and Data Frame Structure

Classical CAN supports two identifier formats: Standard CAN uses an 11-bit CAN ID,
whereas Extended CAN uses a 29-bit CAN ID. A Classical CAN data frame contains
between `0` and `8 bytes` of payload #cite-ref(refs, "cia-can").

#info-table(
  columns: (1.6fr, 1.1fr, 2.4fr),
  alignments: (left + horizon, center + horizon, left + horizon),
  headers: ([Format], [CAN ID], [Characteristics]),
  rows: (
    ([Standard], [11-bit], [Identifier range from `0x000` to `0x7FF`.]),
    ([Extended], [29-bit], [Identifier range from `0x00000000` to `0x1FFFFFFF`.]),
  ),
  caption: [Identifier formats supported by Classical CAN],
)

A CAN data frame contains fields used for synchronization, message
identification, data transmission, and error detection. Its main fields are
summarized below #cite-ref(refs, "cia-can") #cite-ref(refs, "kvaser-can").

#info-table(
  columns: (1.3fr, 3.7fr),
  alignments: (left + horizon, left + horizon),
  headers: ([Field], [Purpose]),
  rows: (
    ([SOF], [Indicates the beginning of a CAN frame.]),
    ([Arbitration], [Contains the identifier and information used to arbitrate bus access.]),
    ([Control], [Contains control information, including the DLC indicating the data field length in Classical CAN.]),
    ([Data], [Contains a data frame payload of `0` to `8 bytes`.]),
    ([CRC], [Enables detection of errors in a transmitted frame.]),
    ([ACK], [Allows a receiving node to acknowledge reception of a valid frame.]),
    ([EOF], [Marks the end of a CAN frame.]),
  ),
  caption: [Main fields of a Classical CAN data frame],
)

In EduFramework, an application only needs to provide `id`, `format`, `length`,
and `data[]`. Protocol fields such as SOF, CRC, and ACK are handled by the CAN
controller below the application layer #cite-ref(refs, "eduframework-can").

== CAN IDs, Bus Arbitration, and Error Detection

When multiple nodes attempt to transmit simultaneously, CAN uses
non-destructive arbitration based on message identifiers. For data frames of the
same format, the numerically lower identifier has higher priority. A node that
loses arbitration stops transmitting and waits to retry when the bus becomes
available #cite-ref(refs, "cia-can") #cite-ref(refs, "kvaser-can").

CAN also provides error-detection mechanisms, including CRC checking, bit
monitoring, and frame format checking. On a conventional bus, the ACK field
informs the transmitter that at least one other node received a valid frame;
however, an ACK does not guarantee that the destination ECU's application has
processed the data #cite-ref(refs, "cia-can") #cite-ref(refs, "kvaser-can").

#note[
  Arbitration, CRC, and ACK are introduced to establish an understanding of
  the CAN protocol. The Loopback exercise does not verify arbitration among
  multiple ECUs or the operation of the CAN physical layer.
]

== Internal Loopback

In Normal mode, frames are transmitted through the CAN interface and can be
received by other nodes on the bus. Internal Loopback creates an internal
reception path within the CAN controller: a transmitted frame is routed back to
the controller's receive logic without passing through the external `CAN_H` and
`CAN_L` lines #cite-ref(refs, "eduframework-can").

In EduFramework, `CAN_setMode(CAN_MODE_LOOPBACK)` enables this mode. The exercise
can therefore verify frame construction, transmission, reception, and receive
queue access on a single MCU. A `PASS` result confirms that the compared fields
match during the internal test; it does not replace testing on a physical CAN
bus.

// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

This lab uses one MaaZEDU Development Board equipped with an S32K144 MCU and
FlexCAN0. Because transmission and reception take place in Internal Loopback
mode, no second ECU, external CAN transceiver, or `CAN_H`/`CAN_L` wiring is
required.

#hardware-table(
  caption: [Hardware required for the exercise],
  rows: (
    ([MaaZEDU Development Board], [S32K144 board used to run the CAN Loopback application.]),
    ([12V DC Adapter], [External power supply required for CAN operation on MaaZEDU.]),
    ([USB Cable], [Connection to the computer for programming and Serial Monitor access.]),
  ),
)

== Interfaces Used

EduFramework uses the S32K144 `FlexCAN0` peripheral. On MaaZEDU, `CAN0_TX` is
mapped to `PTE5` and `CAN0_RX` to `PTE4`, as documented for the board
#cite-ref(refs, "maazedu-guide") #cite-ref(refs, "nxp-cookbook").

#info-table(
  columns: (1.15fr, 1fr, 2.8fr),
  alignments: (center + horizon, center + horizon, left + horizon),
  headers: ([Signal], [MCU Pin], [Function]),
  rows: (
    ([`CAN0_TX`], [`PTE5`], [Transmit path from the CAN controller to the transceiver in Normal mode.]),
    ([`CAN0_RX`], [`PTE4`], [Receive path from the transceiver to the CAN controller in Normal mode.]),
    (
      [`Serial1`],
      [`LPUART1`],
      [Displays transmitted data, received data, and verification results on the Serial Monitor.],
    ),
  ),
  caption: [Interfaces relevant to Lab 18],
)

These CAN pins are listed for hardware identification; the Loopback exercise
does not require connecting them with wires. Do not short `CAN_H` to `CAN_L`, as
they are separate lines used for differential CAN communication
#cite-ref(refs, "ti-can").

== Power Configuration and Connections

According to the MaaZEDU Development Board Guide, the board's CAN function
requires an external power source #cite-ref(refs, "maazedu-guide"). This lab
uses the configuration verified on MaaZEDU: move the power-selection jumper to
the external-power position, connect a `12V` adapter, and retain the USB
connection for programming and Serial Monitor access.

#note[
  Turn off the power before changing the jumper position. Connect the adapter
  to the designated board power connector; never apply `12V` directly to MCU
  pins or signal pins. Internal Loopback requires no external CAN wiring. The
  external-power requirement is specific to the MaaZEDU configuration used in
  this exercise.
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

EduFramework provides an Arduino-style CAN API built on the FlexCAN driver. The
application does not need to configure Message Buffers, receive interrupts, or
the receive queue directly; these resources are managed by the lower layers
#cite-ref(refs, "eduframework-can").

== `CAN_Frame_t`

`CAN_Frame_t` represents a Classical CAN frame at the application level. The
fields used in this lab are listed below.

#info-table(
  columns: (1.1fr, 3.9fr),
  alignments: (left + horizon, left + horizon),
  headers: ([Field], [Description]),
  rows: (
    ([`id`], [CAN identifier of the message.]),
    ([`format`], [Identifier format: `CAN_STANDARD` or `CAN_EXTENDED`.]),
    ([`length`], [Number of payload bytes, from `0` to `8`.]),
    ([`data[]`], [Byte array containing the payload, up to `CAN_MAX_DATA_LENGTH`.]),
  ),
  caption: [Fields of CAN_Frame_t],
)

This lab uses `id = 0x100`, `format = CAN_STANDARD`, and `length = 1`, with the
transmitted value stored in `data[0]`. The identifier `0x100` is selected for
this example; it is not a universally assigned vehicle-speed message ID.

== `CAN_begin()`

#api-detail(
  name: "CAN_begin",
  syntax: [CAN_begin(bitRate);],
  description: [Initializes CAN at the specified bit rate; the initial operating mode is Normal.],
  parameters: (
    ([bitRate], [CAN bitrate], [Transmission bit rate in bits per second; this lab uses `500000` bit/s.]),
  ),
  returns: [`true` if initialization succeeds; `false` if initialization fails or the bit rate is invalid.],
)

The value `500000UL` corresponds to `500 kbit/s` and is used in NXP's CAN 2.0
example #cite-ref(refs, "nxp-cookbook").

== `CAN_setMode()`

#api-detail(
  name: "CAN_setMode",
  syntax: [CAN_setMode(mode);],
  description: [Selects the CAN controller's operating mode after initialization.],
  parameters: (
    ([mode], [CAN operating mode], [This lab uses `CAN_MODE_LOOPBACK` to receive transmitted frames internally.]),
  ),
  returns: [`true` if the mode changes successfully; `false` if the mode is invalid or the controller is not ready.],
)

Both `CAN_begin()` and `CAN_setMode()` must succeed before the program attempts
to transmit data #cite-ref(refs, "eduframework-can").

== `CAN_send()`

#api-detail(
  name: "CAN_send",
  syntax: [CAN_send(&txFrame);],
  description: [Transmits a CAN data frame using blocking operation, waiting for completion or a driver timeout.],
  parameters: (
    ([frame], [CAN Frame], [Address of the `CAN_Frame_t` containing the frame to transmit.]),
  ),
  returns: [`true` if transmission completes successfully; `false` if transmission fails or the frame is invalid.],
)

A valid frame must use an identifier within the range permitted by its
`format`, and its `length` must not exceed `8 bytes`
#cite-ref(refs, "eduframework-can").

== `CAN_available()` and `CAN_read()`

#api-detail(
  name: "CAN_available",
  syntax: [CAN_available();],
  description: [Checks whether at least one received frame is present in the CAN receive queue.],
  parameters: (),
  returns: [`true` if a frame is available; `false` if no data is available or CAN is not initialized.],
)

#api-detail(
  name: "CAN_read",
  syntax: [CAN_read(&rxFrame);],
  description: [Removes and reads the oldest frame from the receive queue without blocking.],
  parameters: (
    ([frame], [CAN Frame], [Address of the `CAN_Frame_t` variable that receives the frame.]),
  ),
  returns: [`true` if a frame is read successfully; `false` if the queue is empty or the argument is invalid.],
)

EduFramework stores received data in a queue using interrupt-driven reception.
The application checks `CAN_available()` and then uses `CAN_read()` to retrieve
and process frames in the main loop #cite-ref(refs, "eduframework-can").

// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

== Requirements

Develop a CAN Loopback program on one S32K144 board. Initialize CAN at
`500 kbit/s` and switch to `CAN_MODE_LOOPBACK`. Every second, the program
transmits a Standard CAN frame with ID `0x100`, DLC `1`, and an incrementing data
byte.

After transmission, the program reads the returned frame and displays `TX`,
`RX`, and `PASS` when the CAN ID, format, DLC, and payload byte match. The Serial
Monitor operates at `9600 baud`.

== Program

Use the following program in `src/main.c`, as verified on the MaaZEDU
Development Board:

#block(breakable: false)[
  #code-listing(
    caption: [CAN transmission and reception in Internal Loopback mode],
  )[
    ```c
    #include "Arduino.h"
    #include "can.h"
    int main(void)
    {
        CAN_Frame_t txFrame = {0};
        CAN_Frame_t rxFrame = {0};
        uint8_t value = 0U;
        setup();
        Serial1_begin(9600U);
        if ((false == CAN_begin(500000UL)) ||
            (false == CAN_setMode(CAN_MODE_LOOPBACK)))
        {
            Serial1_println("CAN initialization failed.");
            while (1) {}
        }
        Serial1_println("=== CAN Loopback Demo ===");
        txFrame.id = 0x100UL;
        txFrame.format = CAN_STANDARD;
        txFrame.length = 1U;
        while (1)
        {
            txFrame.data[0] = value;
            if (true == CAN_send(&txFrame))
            {
                Serial1_print("TX: ");
                Serial1_printInt(value);
                Serial1_println("");
                if (true == CAN_available())
                {
                    if (true == CAN_read(&rxFrame))
                    {
                        Serial1_print("RX: ");
                        Serial1_printInt(rxFrame.data[0]);
                        Serial1_println("");
                        if ((txFrame.id == rxFrame.id) && (txFrame.format == rxFrame.format) &&
                            (txFrame.length == rxFrame.length) &&
                            (txFrame.data[0] == rxFrame.data[0]))
                        {
                            Serial1_println("Result: PASS");
                        }
                        else
                        {
                            Serial1_println("Result: FAIL");
                        }
                    }
                }
            }
            else
            {
                Serial1_println("CAN transmission failed.");
            }
            Serial1_println("----------------");
            value++;
            delay(1000U);
        }
    }
    ```
  ]
]

`setup()` initializes the EduFramework environment, and
`Serial1_begin(9600U)` prepares the Serial Monitor. After `CAN_begin(500000UL)`
completes, the program calls `CAN_setMode(CAN_MODE_LOOPBACK)` to receive
transmitted frames internally.

`txFrame` is configured with Standard CAN ID `0x100` and a one-byte payload.
Within the loop, `value` is assigned to `txFrame.data[0]` and transmitted using
`CAN_send()`. If transmission succeeds and a frame is available in the queue,
`CAN_read()` stores it in `rxFrame`. The program compares `id`, `format`,
`length`, and `data[0]` to determine the `PASS` or `FAIL` result.

The variable `value` ranges from `0` to `255` and increments on each loop
iteration. After `255`, the value wraps to `0` because it is an unsigned 8-bit
integer. `delay(1000U)` introduces a one-second pause between consecutive tests.

== Verification

After setting the jumper to external-power mode and connecting the `12V`
adapter, upload the program to the MaaZEDU Development Board. Open the Serial
Monitor at `9600 baud` and observe the TX/RX values in successive cycles.

The following output was verified on the hardware:

```text
=== CAN Loopback Demo ===
TX: 0
RX: 0
Result: PASS
----------------
TX: 1
RX: 1
Result: PASS
----------------
TX: 2
RX: 2
Result: PASS
----------------
```

Continue monitoring subsequent cycles to verify that the data value increases
consistently and the compared fields remain equal. In this program, if no frame
is available at the exact time `CAN_available()` is called, the corresponding
cycle will not display `RX` or `PASS`. Verification therefore relies on frames
that have actually been read and compared, rather than on successful
transmission alone.

#block(breakable: false)[
  #expected-result[
    FlexCAN0 initializes successfully and enters Internal Loopback mode. For
    each received frame, CAN ID `0x100`, Standard format, DLC `1`, and the RX
    payload byte match the TX values. The Serial Monitor displays
    `Result: PASS` over consecutive cycles without an external CAN bus
    connection.
  ]
]

// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

The main exercise uses blocking transmission and polls the receive queue for
new data. EduFramework also provides APIs and operating modes for more advanced
CAN applications #cite-ref(refs, "eduframework-can").

#info-table(
  columns: (1.6fr, 3.1fr),
  alignments: (left + horizon, left + horizon),
  headers: ([API / Mode], [Function]),
  rows: (
    ([`CAN_sendNonBlocking()`], [Starts a CAN transmission without waiting for the operation to finish.]),
    ([`CAN_isTxBusy()`], [Checks whether a non-blocking transmission is currently active.]),
    ([`CAN_isTxComplete()`], [Checks the successful-completion flag for the most recently started transmission.]),
    ([`CAN_onReceive()`], [Registers a callback invoked in interrupt context after a frame enters the receive queue.]),
    ([`CAN_MODE_NORMAL`], [Enables normal CAN communication over the physical bus.]),
    ([`CAN_MODE_LISTEN_ONLY`], [Monitors CAN traffic without actively transmitting frames.]),
    ([`CAN_EXTENDED`], [Selects the extended 29-bit CAN identifier format.]),
    ([`CAN_end()`], [Stops CAN operation and resets the CAN API layer state.]),
  ),
  caption: [Advanced CAN features available in EduFramework],
)

== Extension Exercise

Modify the transmitted frame to carry two data bytes instead of one. After
each transmission, verify both received payload bytes before displaying
`PASS`. Keep Internal Loopback mode enabled; no additional hardware is needed.

Non-blocking transmission, receive callbacks, and Normal mode will be used in
Lab 19 when two ECUs exchange data over a physical CAN bus.

// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
