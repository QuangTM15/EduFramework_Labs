#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 10 - NFC Card Detection with PN532
// English version
// ============================================================================

// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "coskun-nfc-survey",
    type: "web",
    author: [Vedat Coskun, Busra Ozdenizci and Kerem Ok],
    title: [The Survey on Near Field Communication],
    source: [Sensors, 15(6), 13348–13405],
    year: [2015],
    url: "https://doi.org/10.3390/s150613348",
  ),
  (
    key: "mohandes-attendance",
    type: "web",
    author: [Mohamed A. Mohandes],
    title: [Class Attendance Management System Using NFC Mobile Devices],
    source: [Intelligent Automation and Soft Computing, 23(2), 251–259],
    year: [2017],
    url: "https://doi.org/10.1080/10798587.2016.1204749",
  ),
  (
    key: "nxp-pn532-datasheet",
    type: "datasheet",
    author: [NXP Semiconductors],
    title: [PN532/C1 - Near Field Communication (NFC) Controller],
    document: [PN532_C1],
    revision: [3.6],
    year: [2017],
    url: "https://www.nxp.com/docs/en/nxp/data-sheets/PN532_C1.pdf",
  ),
  (
    key: "nxp-pn532-user-manual",
    type: "manual",
    author: [NXP Semiconductors],
    title: [PN532 User Manual],
    document: [UM0701-02],
    revision: [02],
    year: [2007],
    url: "https://www.nxp.com/docs/en/user-guide/141520.pdf",
  ),
  (
    key: "nxp-uid",
    type: "application-note",
    author: [NXP Semiconductors],
    title: [MIFARE Product and Handling of UIDs],
    document: [AN10927],
    revision: [4.1],
    year: [2018],
    url: "https://www.nxp.com/docs/en/application-note/AN10927.pdf",
  ),
  (
    key: "elechouse-pn532-v3",
    type: "manual",
    author: [Elechouse],
    title: [PN532 NFC RFID Module User Guide],
    revision: [Version 3],
    url: "https://easyelecmodule.com/wp-content/uploads/PN532_-Manual_V3.pdf",
  ),
  (
    key: "eduframework-pn532",
    type: "web",
    author: [EduFramework],
    title: [PN532 Device API and UART/HSU Driver],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
  (
    key: "maazedu-guide",
    type: "manual",
    author: [FPT Software],
    title: [MaaZEDU Development Board Guide],
    revision: [1.0],
  ),
)


// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 10,
  language: "en",
  title: [NFC Card Detection\
    with PN532],
  subtitle: [Reading Card UIDs over UART (HSU) Using EduFramework],
)

// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Lab Overview

Contactless identification allows a device to exchange information with a
card or tagged object without an electrical contact. Near Field Communication
(NFC) is a short-range wireless communication technology closely related to
Radio Frequency Identification (RFID) systems operating at `13.56 MHz`.
The survey by Coskun, Ozdenizci, and Ok discusses the foundations of NFC
and applications such as electronic cards, electronic ticketing, and
device-to-device interaction #cite-ref(refs, "coskun-nfc-survey").

In a card-reading system, a reader communicates wirelessly with a card
and forwards the acquired data to the application controller. For example,
Mohandes investigated an attendance management system using NFC-enabled
devices and cards in a university environment. This is an application
of contactless identification, rather than a study specifically concerned
with the PN532 module #cite-ref(refs, "mohandes-attendance").

This lab uses a *PN532 NFC RFID Module V3* and the MaaZEDU Development Board.
The PN532 communicates with the S32K144 microcontroller through UART/HSU.
EduFramework provides a device-level API to initialize the module, detect
ISO/IEC 14443 Type A cards, and display their UIDs on the Serial Monitor.
Low-level frame processing, target selection, and card-memory access are
outside the scope of the main exercise
#cite-ref(refs, "nxp-pn532-user-manual")
#cite-ref(refs, "eduframework-pn532").

== Objectives

#objectives(
  items: (
    [
      Describe the roles of an NFC reader, a card/tag, and a unique identifier
      (UID) in a basic contactless identification system.
    ],
    [
      Identify the PN532 UART/HSU interface and explain the crossed `TX` and
      `RX` connections between the module and MaaZEDU.
    ],
    [
      Distinguish reading a UID from accessing data stored on a card, and
      recognize the limitations of UID-based authentication.
    ],
    [
      Use `PN532_Begin()`, `PN532_IsCardPresent()`, `PN532_GetUID()`, and
      `PN532_End()` to identify cards through EduFramework.
    ],
    [
      Develop and verify a program that displays hexadecimal UIDs on the
      Serial Monitor and test it with compatible cards/tags.
    ],
  ),
)

// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== NFC and Contactless Identification Systems

NFC relies on short-range electromagnetic interaction. In *The Survey on
Near Field Communication*, Coskun and colleagues describe NFC as a
short-range communication technology based on inductive coupling and
supporting several operating modes. RFID and NFC share related technologies
and applications; however, not every RFID card should be treated as an
NFC device offering the full range of NFC communication capabilities
#cite-ref(refs, "coskun-nfc-survey").

The PN532 is a `13.56 MHz` contactless communication controller. The
PN532/C1 datasheet describes its support for multiple protocols and modes,
including communication with ISO/IEC 14443 Type A/MIFARE cards. Lab 10,
however, addresses one specific use case: *a reader detects a Type A card
and obtains its UID* #cite-ref(refs, "nxp-pn532-datasheet").

#info-table(
  columns: (1.4fr, 3.1fr),
  alignments: (left + horizon, left + horizon),
  headers: ([Component], [Role in the Exercise]),
  rows: (
    (
      [MaaZEDU / S32K144],
      [Controls the application, receives results over UART, and displays information on the Serial Monitor.],
    ),
    ([PN532 module], [Communicates wirelessly with the card and exchanges commands and responses with the MCU.]),
    ([NFC card/tag], [The detected object that supplies identification information.]),
    ([Serial Monitor], [Displays the UID obtained by the application from the PN532.]),
  ),
  caption: [Components of the card-identification system in Lab 10],
)

In this lab, UART provides the communication link *between the MCU and
the module*, whereas `13.56 MHz` radio communication occurs *between the
PN532 and the card*. These links serve different purposes and do not
operate at the same data rate
#cite-ref(refs, "nxp-pn532-datasheet")
#cite-ref(refs, "nxp-pn532-user-manual").

== PN532 and the Unique Identifier (UID)

During ISO/IEC 14443 Type A card detection, the PN532 can perform the
operations required to identify and select a card. A successful
`InListPassiveTarget` command can return `ATQA`, `SAK`, the UID length,
and the UID bytes. These response fields are described in NXP's
*PN532 User Manual* #cite-ref(refs, "nxp-pn532-user-manual").

A UID (*Unique Identifier*) is represented as a sequence of bytes.
According to NXP application note AN10927, ISO/IEC 14443 Type A UIDs
may be `4`, `7`, or `10 bytes` long. The same document explains that
not every UID is guaranteed to be globally unique under all conditions;
some products use Random IDs or Non-Unique IDs
#cite-ref(refs, "nxp-uid").

#info-table(
  columns: (1.2fr, 1.7fr, 2.1fr),
  alignments: (center + horizon, center + horizon, left + horizon),
  headers: ([UID Length], [Designation], [Notes]),
  rows: (
    ([`4 bytes`], [Single Size UID], [Selected through one cascade level.]),
    ([`7 bytes`], [Double Size UID], [Selected through two cascade levels.]),
    ([`10 bytes`], [Triple Size UID], [Selected through three cascade levels.]),
  ),
  caption: [ISO/IEC 14443 Type A UID lengths according to AN10927],
)

For example, the UID observed during the hardware test for this lab was:

```text
EE 68 17 05
```

This is a *hexadecimal* representation: each pair of characters denotes
one byte. The UID is printed for observation and comparison across scans.
The main program does not access user memory, authentication keys, or
application data stored on the card
#cite-ref(refs, "eduframework-pn532").

#warning[
  A UID can illustrate how cards are distinguished in a laboratory
  exercise, but *a UID alone must not be treated as proof of secure
  authentication*. NXP documents Random ID and Non-Unique ID cases in
  contactless card systems. The UID-comparison extension is therefore
  a data-processing demonstration, not a secure access-control solution
  #cite-ref(refs, "nxp-uid").
]

== UART/HSU Communication Between PN532 and S32K144

The PN532 supports SPI, I2C, and High Speed UART (`HSU`) host interfaces.
In UART communication, a device transmits data through `TX` and receives
through `RX`; consequently, one device's `TX` must connect to the other
device's `RX`. Both devices also require a common `GND` voltage reference
#cite-ref(refs, "nxp-pn532-datasheet")
#cite-ref(refs, "elechouse-pn532-v3").

In EduFramework, the PN532 driver uses `Serial2` at a fixed baud rate of
`115200`. `Serial1` remains dedicated to Serial Monitor output at
`9600` baud, as in Lab 03. The application does not directly access
S32K144 LPUART registers because UART operations are encapsulated in
the driver layers #cite-ref(refs, "eduframework-pn532").

#info-table(
  columns: (1.25fr, 1.4fr, 2.35fr),
  alignments: (center + horizon, center + horizon, left + horizon),
  headers: ([Channel], [Baud Rate], [Purpose]),
  rows: (
    ([`Serial1`], [`9600`], [Outputs messages and UIDs to the Serial Monitor.]),
    ([`Serial2`], [`115200`], [Provides bidirectional UART/HSU communication with the PN532 module.]),
  ),
  caption: [Serial channels used in the exercise],
)

#note[
  `115200 baud` is the UART rate between MaaZEDU and PN532 as configured
  by the driver. It is neither the `13.56 MHz` NFC carrier frequency nor
  the wireless data rate used between the reader and the card
  #cite-ref(refs, "nxp-pn532-datasheet")
  #cite-ref(refs, "eduframework-pn532").
]

== From Card Detection to UID Display

According to the *PN532 User Manual*, `InListPassiveTarget` allows the
PN532 to detect and initialize a target in passive mode. With the Type A
`106 kbps` parameter, the chip performs the required operations to detect
a compatible card and returns identification data to the host
#cite-ref(refs, "nxp-pn532-user-manual").

The EduFramework PN532 driver encapsulates this exchange through its Easy
API. `PN532_Begin()` initializes UART and the module,
`PN532_IsCardPresent()` scans for a card, and `PN532_GetUID()` retrieves
the UID string cached after a successful scan. `PN532_End()` releases
the selected target in preparation for subsequent processing
#cite-ref(refs, "eduframework-pn532").

The application data flow can be summarized as follows:

`NFC card/tag` ⇄ `PN532 (RF 13.56 MHz)` ⇄ `UART2 (HSU)` ⇄ `S32K144` →
`Serial1` → `Serial Monitor`.

Frame construction, checksum verification, ACK handling, timeouts, and
response parsing are implemented in the driver. The main program therefore
does not need to process PN532 protocol byte arrays
#cite-ref(refs, "nxp-pn532-user-manual")
#cite-ref(refs, "eduframework-pn532").

// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

The lab uses a MaaZEDU Development Board, a red PN532 NFC RFID Module V3,
at least one compatible ISO/IEC 14443 Type A card or tag, jumper wires,
and a USB cable. Only UART/HSU is used in the main exercise; the SPI and
I2C lines are not connected to the module
#cite-ref(refs, "elechouse-pn532-v3")
#cite-ref(refs, "maazedu-guide").

#hardware-table(
  caption: [Hardware required for the exercise],
  rows: (
    (
      [MaaZEDU Development Board],
      [Board based on the S32K144 microcontroller with an external UART interface.],
    ),
    (
      [PN532 NFC RFID Module V3],
      [PN532-based card reader with an onboard PCB antenna and HSU interface selection.],
    ),
    (
      [NFC card/tag],
      [A compatible card or key fob used to verify UID detection.],
    ),
    (
      [Jumper Wires],
      [Four wires for power, GND, UART TX, and UART RX.],
    ),
    (
      [USB Cable],
      [Connects MaaZEDU to a computer for programming and Serial Monitor access.],
    ),
  ),
)

== UART Pin Mapping and PN532 Connections

In the EduFramework configuration used for this exercise, `Serial2`
uses the S32K144 `UART2_TX` and `UART2_RX` signals. MaaZEDU's transmit
pin connects to the PN532 receive pin, and vice versa. `Serial1` is
reserved for the Serial Monitor and is not connected to the PN532 module
#cite-ref(refs, "eduframework-pn532")
#cite-ref(refs, "maazedu-guide").

#pin-table(
  caption: [UART2 signal mapping used in Lab 10],
  rows: (
    ([PN532 `RXD`], "UART2_TX", "PTD7", [Data transmitted from MaaZEDU to the PN532 module.]),
    ([PN532 `TXD`], "UART2_RX", "PTD6", [Data transmitted from the PN532 module to MaaZEDU.]),
  ),
)

#info-table(
  columns: (1.4fr, 1.55fr, 2.05fr),
  alignments: (center + horizon, center + horizon, left + horizon),
  headers: ([PN532 Module Pin], [MaaZEDU], [Function]),
  rows: (
    ([`VCC`], [`3.3V`], [Supplies power to the module.]),
    ([`GND`], [`GND`], [Provides a common voltage reference.]),
    ([`RXD` / `RX`], [`UART2_TX`], [Receives commands from the S32K144.]),
    ([`TXD` / `TX`], [`UART2_RX`], [Sends responses to the S32K144.]),
  ),
  caption: [PN532 module connections in UART/HSU mode],
)

#figure-block(
  caption: [Wiring diagram of the PN532 UART/HSU module and MaaZEDU Development Board],
)[
  #image(
    "../assets/circuits/pn532_nfc_detection_circuit.png",
    width: 88%,
  )
]

== Selecting HSU Mode on the Module

The PN532 V3 module has two interface-selection switches. According to
the *Elechouse PN532 NFC RFID Module User Guide*, `HSU` mode is selected
when both switches are `OFF`; other settings select I2C or SPI. On this
module version, the HSU pins share physical connector positions with
the I2C pins, while their UART signal labels are printed on the back
of the PCB #cite-ref(refs, "elechouse-pn532-v3").

#info-table(
  columns: (1.4fr, 1.3fr, 1.3fr),
  alignments: (center + horizon, center + horizon, center + horizon),
  headers: ([Mode], [Channel 1], [Channel 2]),
  rows: (
    ([`HSU / UART`], [`OFF`], [`OFF`]),
    ([`I2C`], [`ON`], [`OFF`]),
    ([`SPI`], [`OFF`], [`ON`]),
  ),
  caption: [Interface-selection switch settings for PN532 Module V3],
)

#warning[
  Disconnect power before changing wiring or switch settings. Check
  the `TXD` and `RXD` markings on the *back* of the V3 module; do not
  interpret `SDA` and `SCL` printed on the front as UART signal names.
  Supply `3.3 V` as verified with the MaaZEDU configuration. When using
  another module version, consult its corresponding hardware guide
  #cite-ref(refs, "elechouse-pn532-v3").
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

EduFramework provides straightforward functions for obtaining card
information without requiring an application to declare a `PN532_Card_t`
structure or parse protocol frames. The four *Easy API* functions used
in the main exercise are `PN532_Begin()`, `PN532_IsCardPresent()`,
`PN532_GetUID()`, and `PN532_End()`
#cite-ref(refs, "eduframework-pn532").

== `PN532_Begin()`

`PN532_Begin()` initializes `Serial2` at `115200 baud`, wakes the module
through HSU, checks the chip firmware version, and performs the necessary
configuration for card-reading mode. It takes no parameters; the
application only needs to check the initialization result
#cite-ref(refs, "eduframework-pn532").

#api-detail(
  name: "PN532_Begin",
  syntax: [PN532_Begin();],
  description: [Initialize UART/HSU and prepare the PN532 for card detection.],
  parameters: (),
  returns: [
    `PN532_STATUS_OK` on successful initialization; a `PN532_STATUS_*`
    error status if initialization cannot be completed.
  ],
)

Example:

```c
if (PN532_STATUS_OK == PN532_Begin())
{
    Serial1_println("PN532 ready.");
}
```

Detailed error statuses can be converted into text using
`PN532_StatusString()`. The main exercise only reports whether
initialization succeeds or fails.

== `PN532_IsCardPresent()`

`PN532_IsCardPresent()` requests the detection of one ISO/IEC 14443
Type A card. When a card is found, the driver caches its identification
information; therefore, `PN532_GetUID()` can be called immediately
after this function returns `true`
#cite-ref(refs, "eduframework-pn532").

#api-detail(
  name: "PN532_IsCardPresent",
  syntax: [PN532_IsCardPresent();],
  description: [Scan for a compatible card and cache its information after successful detection.],
  parameters: (),
  returns: [
    `true` if a card is detected and its information is read successfully;
    `false` if no card is found or communication fails.
  ],
)

Example:

```c
if (true == PN532_IsCardPresent())
{
    Serial1_println("Card detected.");
}
```

#note[
  `PN532_IsCardPresent()` performs an actual communication transaction
  and may wait for a response from the module. A `false` result does not
  distinguish the absence of a card from a communication error. The
  detailed cause can be examined using `PN532_GetLastError()` in the
  Extension section #cite-ref(refs, "eduframework-pn532").
]

== `PN532_GetUID()`

`PN532_GetUID()` does not initiate another scan. It only returns the UID
string cached during the most recent successful card detection. The
driver formats the UID bytes as space-separated hexadecimal pairs
#cite-ref(refs, "eduframework-pn532").

#api-detail(
  name: "PN532_GetUID",
  syntax: [PN532_GetUID();],
  description: [Retrieve the current card UID as a hexadecimal string.],
  parameters: (),
  returns: [
    A UID string such as `EE 68 17 05` if the cached data are valid;
    an empty string if no valid UID is available in the driver cache.
  ],
)

Example:

```c
Serial1_print("UID: ");
Serial1_println(PN532_GetUID());
```

The returned string is managed by the driver; no UID array declaration
or per-byte conversion is required. The application uses the string
for display and does not modify the data through the returned pointer
#cite-ref(refs, "eduframework-pn532").

== `PN532_End()`

`PN532_End()` releases the selected target and clears the card information
cached by the Easy API. It does not power down the PN532 module; the
application can continue scanning in the next loop iteration
#cite-ref(refs, "eduframework-pn532").

#api-detail(
  name: "PN532_End",
  syntax: [PN532_End();],
  description: [Release the selected card after its UID has been processed.],
  parameters: (),
  returns: [
    `true` if the target is released successfully; `false` if there is
    no valid target or the operation fails.
  ],
)

Example:

```c
(void)PN532_End();
```

The main exercise calls this function after printing the UID. If a card
remains within the antenna field, a subsequent scan may detect it again,
so the same UID can appear repeatedly on the Serial Monitor.

The `Serial1_begin()`, `Serial1_print()`, and `Serial1_println()` functions
were introduced in Lab 03. Lab 10 reuses these APIs for output and does
not repeat their detailed syntax documentation.

// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

== Requirements

Develop an application that detects cards through the PN532 and displays
their UIDs on the Serial Monitor. The program must meet these requirements:

- Use the PN532 V3 module in `HSU` mode, connected to `UART2_TX` and `UART2_RX`.
- Initialize `Serial1` at `9600 baud` and display startup and initialization messages.
- Enter the scanning loop only after `PN532_Begin()` succeeds.
- When a compatible card is detected, retrieve its UID through the Easy API and print it in hexadecimal format.
- Release the selected target after processing its UID and continue waiting for the next scan.

The exercise does not require creating data structures, manipulating UID
byte arrays, or directly implementing PN532 protocol commands. The white
card and NFC key fob supplied with the module can be used for verification
if they are compatible with the ISO/IEC 14443 Type A mode selected by
the driver #cite-ref(refs, "eduframework-pn532").

== Program

Implement the following program, which has been verified on the hardware,
in `src/main.c`:

#block(breakable: false)[
  #code-listing(
    caption: [PN532 NFC card detection and UID display program],
  )[
    ```c
    #include "Arduino.h"
    #include "pn532.h"

    int main(void)
    {
        setup();

        Serial1_begin(9600U);
        Serial1_println("PN532 NFC Card Detection");

        if (PN532_STATUS_OK == PN532_Begin())
        {
            Serial1_println("PN532 ready.");
        }
        else
        {
            Serial1_println("PN532 initialization failed.");

            while (1)
            {
                delay(1000U);
            }
        }

        while (1)
        {
            if (true == PN532_IsCardPresent())
            {
                Serial1_print("UID: ");
                Serial1_println(PN532_GetUID());

                (void)PN532_End();
                delay(500U);
            }

            delay(100U);
        }

        return 0;
    }
    ```
  ]
]

`setup()` prepares the underlying EduFramework components, and
`Serial1_begin(9600U)` opens the logging channel. `PN532_Begin()`
automatically initializes `Serial2` at `115200 baud` and prepares the
PN532; therefore, the main program does not call `Serial2_begin()`
separately #cite-ref(refs, "eduframework-pn532").

Within the loop, `PN532_IsCardPresent()` attempts to detect a card.
After successful detection, `PN532_GetUID()` returns the formatted UID
string for display. The program calls `PN532_End()` to release the target,
waits `500 ms`, and then continues the loop after an additional
`delay(100U)`.

#note[
  `delay(100U)` introduces a wait *after* a loop iteration; it does
  not guarantee that the PN532 scans exactly every `100 ms`. Scanning
  involves UART/HSU communication, response waiting, and driver timeouts,
  so the interval between displayed readings also depends on the
  communication transaction #cite-ref(refs, "eduframework-pn532").
]

== Verification

Build and upload the program to MaaZEDU, then open the Serial Monitor at
`9600 baud`. Check for `PN532 ready.` to confirm successful module
initialization. Present a card within the antenna field and observe its
UID on the Serial Monitor. Another card can be tested to compare the
returned identification values.

The following log was recorded during the actual Lab 10 hardware test:

```text
PN532 NFC Card Detection
PN532 ready.
UID: EE 68 17 05
UID: EE 68 17 05
UID: EE 68 17 05
UID: EE 68 17 05
UID: EE 68 17 05
```

Repeated display of the same UID indicates that the application can
continue detecting a card that remains in the antenna field. The value
`EE 68 17 05` belongs to the card used in this test; it is not a fixed
UID of the PN532 module. The UID observed with another card depends on
that card #cite-ref(refs, "nxp-uid")
#cite-ref(refs, "eduframework-pn532").

Check the following during verification:

- The application displays `PN532 ready.` after successful initialization.
- The UID is displayed as hexadecimal byte pairs separated by spaces.
- Moving the card away from the antenna stops new UID output; presenting it again allows another reading.
- If initialization fails, the application reports the failure and does not scan for cards.

#block(breakable: false)[
  #expected-result[
    The PN532 operates in UART/HSU mode and initializes successfully.
    When a compatible ISO/IEC 14443 Type A card enters the reading field,
    the Serial Monitor displays its UID in hexadecimal format. The
    application prints a UID only after successful card detection and
    remains ready for subsequent scans.
  ]
]

// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

The main exercise only detects a card and prints its UID. The following
optional tasks introduce additional PN532 and EduFramework capabilities
without changing the mandatory Lab 10 program
#cite-ref(refs, "nxp-pn532-user-manual")
#cite-ref(refs, "eduframework-pn532").

== Inspecting Card Information

After `PN532_IsCardPresent()` succeeds, the driver can provide the UID
length, `ATQA`, and `SAK` of the detected card through
`PN532_GetUIDLength()`, `PN532_GetATQA()`, and `PN532_GetSAK()`. These
fields are associated with the Type A initialization and selection
process described in NXP's PN532 documentation
#cite-ref(refs, "nxp-pn532-user-manual")
#cite-ref(refs, "eduframework-pn532").

Additionally, `PN532_GetCardType()` returns a *heuristic* card-type
label based on the available identification fields. This label is not
conclusive evidence of the exact chip type or card capabilities.

*Extension task:* Display the UID length and the preliminary card-type
label after a scan. Compare the information obtained from two different
cards or tags.

== Distinguishing Cards by UID and LED Feedback

A previously observed UID can be stored and compared with the string
returned by `PN532_GetUID()`. The application can display `MATCH` when
the values agree and `NOT MATCH` otherwise. The green and red MaaZEDU
LEDs can provide visual feedback using the Digital Output functions
introduced in Labs 01 and 02. Mohandes's study of NFC-based attendance
management illustrates the broader concept of using card information
in a management application #cite-ref(refs, "mohandes-attendance").

*Extension task:* Read and store a reference card UID, compare it with
subsequent readings, and control the LEDs according to the result.
Do not regard UID comparison as secure authentication: NXP documents
Random IDs and Non-Unique IDs, while practical systems require suitable
authentication and security measures #cite-ref(refs, "nxp-uid").

== Diagnosing Communication Status

When `PN532_IsCardPresent()` returns `false`, the Boolean value alone
cannot identify the cause. EduFramework provides `PN532_GetLastError()`
to retrieve the latest operation status, `PN532_StatusString()` to
convert it into a readable label, and `PN532_GetDiagnostics()` to
inspect response-wait stages or received UART bytes
#cite-ref(refs, "eduframework-pn532").

*Extension task:* Distinguish the absence of a card from a timeout or
an invalid response. Add diagnostic output only after the basic UID
reading application operates reliably.

== Reading Data Stored on a Card

The PN532 supports data exchange with certain MIFARE card families.
In EduFramework, reading a MIFARE Classic block requires appropriate
authentication before calling `PN532_ReadBlock()`; the retrieved data
can then be obtained using `PN532_GetBlockHex()`. The driver also
providves separate operations for Ultralight/NTAG cards, which are
not used in the main exercise
#cite-ref(refs, "nxp-pn532-user-manual")
#cite-ref(refs, "eduframework-pn532").

#warning[
  Do not write blocks, sector trailers, lock pages, OTP pages, or
  configuration pages without first identifying the card type and the
  meaning of each memory region. Write operations may change data or
  configuration irreversibly. This extension is limited to examining
  read operations on cards that the user is authorized to access
  #cite-ref(refs, "eduframework-pn532").
]

// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
