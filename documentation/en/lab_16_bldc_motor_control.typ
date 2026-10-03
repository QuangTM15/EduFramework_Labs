#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 16 - BLDC Motor Control
// English version
// ============================================================================

// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "mit-bldc",
    type: "web",
    author: [James L. Kirtley Jr.],
    title: [Course Notes 7: Permanent Magnet "Brushless DC" Motors],
    source: [MIT OpenCourseWare - 6.685 Electric Machines],
    year: [2013],
    url: "https\://ocw\.mit.edu/courses/6-685-electric-machines-fall-2013/resources/mit6_685f13_chapter7/",
  ),
  (
    key: "ieee-bldc-review",
    type: "web",
    author: [Deepak Mohanraj et al.],
    title: [A Review of BLDC Motor: State of Art, Advanced Control Techniques, and Applications],
    source: [IEEE Access, Vol. 10, pp. 54833-54869],
    year: [2022],
    url: "https\://doi.org/10.1109/ACCESS.2022.3175011",
  ),
  (
    key: "fab-esc",
    type: "web",
    author: [Luc Hanneuse],
    title: [Output Devices - Brushless Motor and ESC],
    source: [Fab Academy - Sorbonne Lab],
    year: [2019],
    url: "https\://fabacademy.org/2019/labs/sorbonne/students/hanneuse-luc/assignments/week12/",
  ),
  (
    key: "nxp-s32k-datasheet",
    type: "datasheet",
    author: [NXP Semiconductors],
    title: [S32K1xx MCU Family - Data Sheet],
    document: [S32K1XX],
    revision: [15],
    year: [2026],
    url: "https\://www\.nxp.com/docs/en/data-sheet/S32K1xx.pdf",
  ),
  (
    key: "arduino-language",
    type: "web",
    author: [Arduino],
    title: [Arduino Language Reference],
    source: [Arduino Documentation],
    url: "https\://docs.arduino.cc/language-reference/",
  ),
  (
    key: "eduframework-esc",
    type: "web",
    author: [EduFramework],
    title: [ESC Device API],
    source: [EduFramework Source Code],
    url: "https\://github.com/QuangTM15/s32k144-edu-framework",
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
  number: 16,
  language: "en",
  title: [BLDC Motor Control],
  subtitle: [Controlling a BLDC Motor through an ESC with EduFramework],
)

// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Lab Overview

A BLDC (Brushless DC) motor uses electronic commutation instead of mechanical
brushes and a commutator #cite-ref(refs, "mit-bldc") #cite-ref(refs, "ieee-bldc-review").
In the system used in this lab, the Electronic Speed Controller (ESC) performs
motor commutation and power control. The S32K144 does not directly control the
motor phases; instead, it sends a control signal to the ESC.

This lab focuses on using the EduFramework ESC API to initialize the ESC,
perform the safe startup process (arming), and change the throttle level,
thereby controlling the operation of the BLDC motor.

== Objectives

#objectives(
  items: (
    [Describe the roles of the BLDC motor and Electronic Speed Controller in a motor control system.],
    [Explain the meaning of a throttle command and the ESC arming process.],
    [Connect the MaaZEDU board, ESC, external power supply, and BLDC motor according to the lab configuration.],
    [Use `ESC_Init()`, `ESC_Arm()`, and `ESC_SetThrottle()` to control a BLDC motor.],
  ),
)

// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== BLDC Motor and Electronic Speed Controller

A BLDC motor uses permanent magnets on the rotor and windings on the stator.
Because mechanical brushes are not used, current in the windings must be
electronically commutated to produce rotational torque
#cite-ref(refs, "mit-bldc") #cite-ref(refs, "ieee-bldc-review").

In this lab, the ESC performs this task. The S32K144 does not directly control
the three `U`, `V`, and `W` terminals; the board only sends a control command to
the ESC. The ESC receives a separate power supply through `B+` and `B-` and
controls the three phases connected to the motor #cite-ref(refs, "fab-esc").

#note[
  The motor power supply must not be taken directly from a MaaZEDU GPIO.
  The external power supply must be suitable for the ESC and motor being used.
]

== Throttle Command and Arming

EduFramework uses a throttle command from `0%` to `100%`. With the default
configuration, `0%` corresponds to a pulse width of `1000 µs`, while `100%`
corresponds to `2000 µs`; intermediate values are mapped linearly within this
range #cite-ref(refs, "eduframework-esc").

The throttle percentage is the command value sent to the ESC, not the actual
percentage of motor speed. The resulting RPM also depends on the motor, ESC,
power supply, load, and operating conditions. If the actual speed is required,
the system must use a measurement mechanism such as an encoder.

Before controlling the motor, the ESC must be placed in a safe startup state.
In EduFramework, `ESC_Arm()` sends the minimum throttle and maintains this state
for `3000 ms` before program execution continues
#cite-ref(refs, "eduframework-esc").

// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

This lab uses the MaaZEDU Development Board with an S32K144 microcontroller from
the S32K1xx family #cite-ref(refs, "nxp-s32k-datasheet"). The ESC uses a
separate power supply and drives the BLDC motor through its three phase outputs.

#hardware-table(
  caption: [Hardware used in the lab],
  rows: (
    (
      [MaaZEDU Development Board],
      [Development board based on the S32K144 microcontroller.],
    ),
    (
      [Electronic Speed Controller],
      [Receives the RC PWM signal and controls the power stage of the BLDC motor.],
    ),
    (
      [BLDC Motor],
      [Three-phase motor connected to the `U`, `V`, and `W` outputs of the ESC.],
    ),
    (
      [External DC Power Supply],
      [External supply suitable for the ESC and motor being used.],
    ),
    (
      [Jumper wires],
      [Connect GPIO2 and GND between the MaaZEDU board and the ESC.],
    ),
    (
      [USB Cable],
      [Connect the board to the computer for programming.],
    ),
  ),
)

== Control Pin Mapping

The lab uses `GPIO2` as the ESC control pin. On the MaaZEDU board, `GPIO2` is
mapped to `PTD14` #cite-ref(refs, "maazedu-guide"). EduFramework identifies
this Logical Pin as supporting the PWM function required by the ESC
#cite-ref(refs, "eduframework-esc").

#pin-table(
  caption: [ESC control signal mapping],
  rows: (
    (
      [ESC PWM input],
      "GPIO2",
      "PTD14",
      [ESC control signal],
    ),
  ),
)

== ESC and Motor Connections

Connect `GPIO2` to the `PWM` input of the ESC and connect MaaZEDU GND to the
control-side GND of the ESC. Connect the external power supply to `B+` and `B-`.
Connect the ESC outputs `U`, `V`, and `W` directly to the three wires of the
BLDC motor.

#figure-block(
  caption: [Connection diagram for the MaaZEDU board, ESC, and BLDC motor],
)[
  #image(
    "../assets/circuits/bldc_motor_esc_circuit.png",
    width: 88%,
  )
]

#note[
  Disconnect the motor power supply before changing any wiring. Secure the motor
  before operation and begin verification at a low throttle level. Do not apply
  power until the supply voltage and current capability have been confirmed to
  be suitable for the ESC and motor.
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

The main exercise uses three ESC Device APIs for initialization, arming, and
setting the throttle #cite-ref(refs, "eduframework-esc").

== `ESC_Init()`

#api-detail(
  name: "ESC_Init",
  syntax: [ESC_Init(pin);],
  description: [Initializes the ESC on a Logical Pin that supports PWM.],
  parameters: (
    (
      [pin],
      [Logical Pin],
      [ESC control pin. This lab uses `GPIO2`.],
    ),
  ),
  returns: [
    `true` if initialization succeeds; `false` if the selected pin is unsuitable
    or initialization fails.
  ],
)

== `ESC_Arm()`

#api-detail(
  name: "ESC_Arm",
  syntax: [ESC_Arm();],
  description: [Sends the minimum throttle and performs the ESC arming interval.],
  parameters: (),
  returns: [No return value.],
)

In EduFramework, the arming process lasts `3000 ms`, and the function is
blocking during this interval.

== `ESC_SetThrottle()`

#api-detail(
  name: "ESC_SetThrottle",
  syntax: [ESC_SetThrottle(percent);],
  description: [Sends a throttle command to the ESC as a percentage.],
  parameters: (
    (
      [percent],
      [Throttle],
      [Value from `0%` to `100%`; values above `100%` are limited to `100%`.],
    ),
  ),
  returns: [No return value.],
)

`ESC_SetThrottle()` controls the command value sent to the ESC; this API does
not measure the actual motor RPM.

// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

== Requirements

Develop a program to control a BLDC motor through an ESC connected to `GPIO2`.
After initialization and arming, the program changes the throttle according to
the following sequence:

`20%` → `40%` → `60%` → `40%` → `20%` → `0%`

Each throttle level is maintained for `3000 ms`. After returning to `0%`, the
sequence repeats continuously. The objective is to observe the motor response
as the throttle command increases and decreases; RPM measurement is not
required in this lab.

== Program

In `src/main.c`, implement the program that has been verified on the hardware:

#block(breakable: false)[
  #code-listing(
    caption: [BLDC motor control program using a throttle sequence],
  )[
    ```c
    #include "Arduino.h"
    #include "esc.h"

    int main(void)
    {
        setup();

        ESC_Init(GPIO2);
        ESC_Arm();

        while (1)
        {
            ESC_SetThrottle(20U);
            delay(3000U);

            ESC_SetThrottle(40U);
            delay(3000U);

            ESC_SetThrottle(60U);
            delay(3000U);

            ESC_SetThrottle(40U);
            delay(3000U);

            ESC_SetThrottle(20U);
            delay(3000U);

            ESC_SetThrottle(0U);
            delay(3000U);
        }

        return 0;
    }
    ```
  ]
]

`setup()` initializes EduFramework. `ESC_Init(GPIO2)` prepares the control
output, `ESC_Arm()` performs the arming process, and `ESC_SetThrottle()` then
sends the specified throttle levels in sequence. `delay(3000U)` maintains each
level for three seconds so that the response can be observed clearly
#cite-ref(refs, "arduino-language").

The exercise does not use encoder feedback, so it verifies only the motor
response to the command and does not determine the actual RPM.

== Verification

Build and upload the program to the MaaZEDU board. Check `GPIO2`, GND, `B+`,
`B-`, and the three `U/V/W` wires before applying power to the ESC. After
arming, observe the motor as the throttle increases from `20%` to `60%` and
then decreases to `0%`.

#block(breakable: false)[
  #expected-result[
    The ESC completes the arming process before the motor receives the throttle
    sequence. The motor responds to the `20%`, `40%`, and `60%` commands, then
    decreases through `40%` and `20%` before stopping at `0%`. The sequence
    repeats continuously. The result should demonstrate stable changes in
    response to the command; a linear relationship between throttle percentage
    and actual RPM is not required.
  ]
]

// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

In addition to the three APIs used in the main exercise, EduFramework provides
additional APIs for configuring and monitoring ESC commands
#cite-ref(refs, "eduframework-esc").

#info-table(
  columns: (1.5fr, 2.8fr),
  alignments: (
    left + horizon,
    left + horizon,
  ),
  headers: (
    [API],
    [Purpose],
  ),
  rows: (
    (
      [`ESC_SetPulseRange()`],
      [Changes the minimum and maximum pulse values used to map `0%` to `100%` throttle.],
    ),
    (
      [`ESC_SetMicroseconds()`],
      [Directly sends a pulse width in microseconds within the configured range.],
    ),
    (
      [`ESC_GetThrottle()`],
      [Reads the most recent throttle command stored in software.],
    ),
    (
      [`ESC_GetMicroseconds()`],
      [Reads the most recent pulse-width command.],
    ),
    (
      [`ESC_IsInitialized()`],
      [Checks whether the ESC Device has been initialized.],
    ),
    (
      [`ESC_End()`],
      [Stops the output managed by the ESC Device and resets its internal state.],
    ),
  ),
  caption: [Advanced ESC APIs],
)

#note[
  `ESC_GetThrottle()` and `ESC_GetMicroseconds()` return only the commands that
  have been sent; they do not provide motor speed or physical feedback.
  `ESC_SetPulseRange()` should be changed only when the control range of the
  actual ESC has been identified.
]

== Extension Exercise

Replace the fixed throttle sequence with a potentiometer connected to an Analog
Input. Read the ADC value, scale it to a throttle command within an appropriate
range, and then use `ESC_SetThrottle()` to control the motor.

`Potentiometer` → `analogRead()` → `scale ADC` → `ESC_SetThrottle()` → `BLDC`

// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
