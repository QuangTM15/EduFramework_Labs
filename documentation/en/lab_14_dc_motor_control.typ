#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 14 - DC Motor Control
// English version
// ============================================================================


// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "purdue-actuators",
    type: "web",
    author: [Purdue University],
    title: [Lab 7: Implementing Actuators],
    source: [ME588 - Mechatronics],
    year: [2015],
    url: "https://engineering.purdue.edu/ME588/LabManual/2015_lab7.pdf",
  ),

  (
    key: "ut-motor-pwm",
    type: "web",
    author: [Jonathan W. Valvano and Andreas Gerstlauer],
    title: [ECE445M/ECE380L.12 - Lecture 8],
    source: [The University of Texas at Austin],
    year: [2025],
    url: "https://users.ece.utexas.edu/~gerstl/ece445m_s25/lectures/Lec08.pdf",
  ),

  (
    key: "toshiba-tb6612fng",
    type: "datasheet",
    author: [Toshiba Electronic Devices & Storage Corporation],
    title: [TB6612FNG - Driver IC for Dual DC Motor],
    document: [TB6612FNG],
    year: [2026],
    url: "https://toshiba.semicon-storage.com/info/docget.jsp?did=10660&prodName=TB6612FNG",
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
    revision: [1.0],
    year: [2025],
  ),

  (
    key: "eduframework-dc-motor",
    type: "web",
    author: [EduFramework],
    title: [DC Motor Device API],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
)


// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 14,
  language: "en",
  title: [DC Motor Control],
  subtitle: [Speed and Direction Control with a Motor Driver Module],
)


// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Lab Overview

PWM has been used in previous labs to control the output level applied to a
load. For power loads such as DC motors, a microcontroller does not normally
supply the motor current directly. Instead, a motor driver module is used as an
intermediate power stage between the control signals and the load.

H-bridge motor driver modules commonly provide three basic functions: changing
the direction of rotation, controlling the applied level using PWM, and placing
the motor in a stopped state. In this lab, the TB6612FNG is used as a typical
example of this type of module. The TB6612FNG supports bidirectional control,
PWM operation, stop, short brake, and standby
#cite-ref(refs, "toshiba-tb6612fng").

At the application level, EduFramework provides a DC Motor Device API that
allows the program to configure the motor control level, direction, and stop
state without directly manipulating each control signal of the H-bridge.

The lab exercise focuses on a simple operating sequence: the motor rotates
forward at approximately `50%` control level, stops, rotates in reverse at the
same level, and continuously repeats the sequence.

== Objectives

#objectives(
  items: (
    [
      Describe the role of a motor driver module in a DC motor control system.
    ],

    [
      Explain the basic principle of an H-bridge for direction control and the
      role of PWM in controlling the applied motor level.
    ],

    [
      Use the `DCMotor_Init()`, `DCMotor_SetSpeed()`, `DCMotor_Forward()`,
      `DCMotor_Reverse()`, and `DCMotor_Stop()` APIs.
    ],

    [
      Build and verify a motor control program that follows the sequence
      forward → stop → reverse → stop.
    ],
  ),
)


// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== DC Motor

A DC motor is an actuator that converts direct-current electrical energy into
rotational motion. In a basic control system, reversing the polarity applied
across the motor terminals changes the current direction through the motor and
therefore changes its direction of rotation. The application therefore requires
a power stage capable of controlling current in both directions rather than a
single digital output
#cite-ref(refs, "purdue-actuators").

For open-loop speed control, PWM can be used to change the average power applied
to the motor. The actual mechanical speed depends not only on the PWM value but
also on the motor characteristics, supply voltage, and mechanical load
#cite-ref(refs, "ut-motor-pwm").

== H-Bridge Motor Driver Module

An H-bridge is a structure commonly used to control the direction of a DC motor.
By changing the states of the power switches, the polarity applied across the
motor terminals can be reversed to produce two directions of rotation
#cite-ref(refs, "purdue-actuators").

An H-bridge motor driver module commonly provides the following groups of
signals:

- direction control signals;
- a PWM signal for controlling the applied level;
- an enable or standby signal, depending on the module.

Pin names, logic levels, and signal organization can differ between modules.
Therefore, when replacing the TB6612FNG with another motor driver module, its
technical documentation must be checked before making the connections.

In the hardware configuration used in this lab, the TB6612FNG serves as a
typical example. Channel A of the module uses four main control signals:

- `AIN1` and `AIN2`: select the operating state and direction;
- `PWMA`: PWM input for channel A;
- `STBY`: enables the module or places it in standby mode.

When `STBY` is active and `PWMA` enables the output, the basic relationship
between `AIN1`, `AIN2`, and the channel A state can be summarized as follows
#cite-ref(refs, "toshiba-tb6612fng"):

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1fr, 1fr, 2.2fr),
    align: (center + horizon, center + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*AIN1*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*AIN2*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*State*]
      ],
    ),

    [`HIGH`], [`LOW`], [Rotation in one direction.],
    [`LOW`], [`HIGH`], [Rotation in the opposite direction.],
    [`LOW`], [`LOW`], [Stop with the output in a high-impedance state.],
    [`HIGH`], [`HIGH`], [Short brake.],
  )
]

The `DCMotor_Forward()` and `DCMotor_Reverse()` APIs represent two opposite
control configurations. The actual physical direction of rotation still depends
on how the motor terminals are connected to `AO1` and `AO2`.

== Speed Control with PWM

The principles of PWM, period, and duty cycle were introduced in Lab 05 and are
therefore not repeated in detail in this lab. In motor control, PWM is applied
to the control input of the driver module to change the average level applied
to the load. PWM and an H-bridge are commonly combined to control the speed and
direction of a DC motor
#cite-ref(refs, "purdue-actuators") #cite-ref(refs, "ut-motor-pwm").

The EduFramework DC Motor Device API uses a control range from `0` to `255`
#cite-ref(refs, "eduframework-dc-motor"):

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1fr, 1.3fr, 2.1fr),
    align: (center + horizon, center + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Value*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Control Level*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Meaning*]
      ],
    ),

    [`0`], [`0%`], [No speed control level is applied.],
    [`64`], [approximately `25%`], [Low control level.],
    [`128`], [approximately `50%`], [Mid-range control level.],
    [`191`], [approximately `75%`], [High control level.],
    [`255`], [`100%`], [Maximum control level.],
  )
]

These percentages describe command values within the control range, not the
actual motor rotational speed.


// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

The lab uses the MaaZEDU Development Board to generate control signals, an
H-bridge motor driver module as the power stage, and a DC motor as the load. An
external power supply is used to provide power for the motor.

#hardware-table(
  caption: [Hardware used in this lab],

  rows: (
    (
      [MaaZEDU Development Board],
      [Development board based on the S32K144 microcontroller.],
    ),

    (
      [TB6612FNG Motor Driver Module],
      [
        H-bridge module used as an example for controlling the speed and
        direction of a DC motor.
      ],
    ),

    (
      [DC Motor],
      [Direct-current motor used as the load in the lab exercise.],
    ),

    (
      [External Motor Power Supply],
      [Separate power source connected to the `VM` supply of the motor driver.],
    ),

    (
      [Jumper Wires],
      [Connect the power and control signals between the hardware blocks.],
    ),

    (
      [USB Cable],
      [
        Connects MaaZEDU to the computer for logic power and program
        uploading.
      ],
    ),
  ),
)

== Control Pin Mapping

The current EduFramework DC Motor API uses four signals: one PWM signal, two
direction control signals, and one standby signal. In the example TB6612FNG
configuration, `GPIO2` through `GPIO5` are connected to `PWMA`, `AIN1`, `AIN2`,
and `STBY`, respectively.

According to the MaaZEDU Development Board Guide, these Logical Pins are mapped
to `PTD14`, `PTD13`, `PTD12`, and `PTD11`, respectively
#cite-ref(refs, "maazedu-guide").

#pin-table(
  caption: [Pin mapping for the example TB6612FNG configuration],

  rows: (
    (
      [PWMA],
      "GPIO2",
      "PTD14",
      [PWM Output],
    ),

    (
      [AIN1],
      "GPIO3",
      "PTD13",
      [Digital Output],
    ),

    (
      [AIN2],
      "GPIO4",
      "PTD12",
      [Digital Output],
    ),

    (
      [STBY],
      "GPIO5",
      "PTD11",
      [Digital Output],
    ),
  ),
)

#note[
  If a different motor driver module is used, identify pins with equivalent
  functions and verify the required logic levels from the module
  documentation. Do not assume that every module uses the same pin names or
  operating-state table as the TB6612FNG.
]

== Logic Supply and Motor Supply

Some motor driver modules use separate logic and power supplies. For the
TB6612FNG, `VCC` powers the control logic, while `VM` supplies the motor power
stage. The datasheet specifies an operating range of `2.7 V` to `5.5 V` for
`VCC` and `2.5 V` to `13.5 V` for `VM`
#cite-ref(refs, "toshiba-tb6612fng").

In the example configuration used in this lab:

- the TB6612FNG `VCC` pin is connected to `3.3V` from MaaZEDU;
- `VM` is connected to an external power supply suitable for the motor;
- the GND terminals of MaaZEDU, the TB6612FNG, and the motor power supply are
  connected together;
- `AO1` and `AO2` are connected to the two terminals of the DC motor.

#note[
  The external supply voltage must match the rated voltage of the motor and
  remain within the allowed range of the motor driver module. Turn off the
  motor power supply before changing hardware connections.
]

== Connection Diagram

The following diagram illustrates the use of a TB6612FNG as the motor driver
module in this lab. MaaZEDU generates the control signals, the TB6612FNG
provides the power stage, and the external supply provides energy to the motor.

#figure-block(
  caption: [Example connection diagram using MaaZEDU, TB6612FNG, and a DC motor],
)[
  #image(
    "../assets/circuits/dc_motor_control_circuit.png",
    width: 100%,
  )
]


// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

This lab uses the EduFramework DC Motor Device API to control the motor at the
application level. The PWM and Digital Output operations required by the motor
driver module are handled inside the device layer, so the application does not
need to manipulate each control pin directly
#cite-ref(refs, "eduframework-dc-motor").

The current API is based on an interface with one PWM pin, two direction control
pins, and one standby pin.

== `DCMotor_Init()`

`DCMotor_Init()` initializes the pins required by the motor driver module. After
initialization, the motor is in a stopped state and the module is enabled.

#api-detail(
  name: "DCMotor_Init",

  syntax: [DCMotor_Init(pwmPin, in1Pin, in2Pin, stbyPin);],

  description: [
    Initialize the interface used to control one DC motor through a motor
    driver module.
  ],

  parameters: (
    (
      [pwmPin],
      [PWM-capable Logical Pin],
      [Pin connected to the PWM input of the motor driver module.],
    ),

    (
      [in1Pin],
      [Logical Pin],
      [Pin connected to the first direction-control input.],
    ),

    (
      [in2Pin],
      [Logical Pin],
      [Pin connected to the second direction-control input.],
    ),

    (
      [stbyPin],
      [Logical Pin],
      [Pin connected to the standby input of the motor driver module.],
    ),
  ),

  returns: [No return value.],
)

Example with the TB6612FNG:

```c
DCMotor_Init(GPIO2, GPIO3, GPIO4, GPIO5);
```

== `DCMotor_SetSpeed()`

`DCMotor_SetSpeed()` sets the speed control level within the range `0` to `255`.
The function changes only the PWM level and does not change the current
direction.

#api-detail(
  name: "DCMotor_SetSpeed",

  syntax: [DCMotor_SetSpeed(speed);],

  description: [
    Set the motor speed control level.
  ],

  parameters: (
    (
      [speed],
      [`0` to `255`],
      [
        Motor speed control value. `0` is the minimum value and `255` is the
        maximum value of the control range.
      ],
    ),
  ),

  returns: [No return value.],
)

Example:

```c
DCMotor_SetSpeed(128U);
```

The value `128` corresponds to approximately `50%` of the control range.

== `DCMotor_Forward()`

`DCMotor_Forward()` places the driver module in the forward configuration and
applies the previously configured speed level.

#api-detail(
  name: "DCMotor_Forward",

  syntax: [DCMotor_Forward();],

  description: [
    Rotate the motor in the forward direction.
  ],

  parameters: (),

  returns: [No return value.],
)

The actual physical direction depends on how the two motor terminals are
connected to the outputs of the motor driver module.

== `DCMotor_Reverse()`

`DCMotor_Reverse()` places the module in the opposite configuration to forward
rotation.

#api-detail(
  name: "DCMotor_Reverse",

  syntax: [DCMotor_Reverse();],

  description: [
    Rotate the motor in the reverse direction.
  ],

  parameters: (),

  returns: [No return value.],
)

== `DCMotor_Stop()`

`DCMotor_Stop()` sets the PWM control level to `0` and places the direction
control pins in the stop state. With the example TB6612FNG configuration, the
motor is stopped using the coast state
#cite-ref(refs, "toshiba-tb6612fng")
#cite-ref(refs, "eduframework-dc-motor").

#api-detail(
  name: "DCMotor_Stop",

  syntax: [DCMotor_Stop();],

  description: [
    Stop the motor using coast mode.
  ],

  parameters: (),

  returns: [No return value.],
)


// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

== Requirements

Build a program that controls a DC motor through a motor driver module.

- Initialize the control interface with `GPIO2`, `GPIO3`, `GPIO4`, and `GPIO5`.
- Set the speed control value to `128`, corresponding to approximately `50%`.
- Rotate forward for `3000 ms`.
- Stop the motor for `2000 ms`.
- Rotate in reverse for `3000 ms`.
- Stop the motor for `2000 ms`.
- Repeat the sequence continuously.

== Program

In `src/main.c`, implement the program as follows:

#block(breakable: false)[
  #code-listing(
    caption: [DC motor control program using EduFramework],
  )[
    ```c
    #include "Arduino.h"
    #include "dc_motor.h"

    int main(void)
    {
        setup();

        DCMotor_Init(GPIO2, GPIO3, GPIO4, GPIO5);

        while (1)
        {
            DCMotor_SetSpeed(128U);
            DCMotor_Forward();
            delay(3000U);

            DCMotor_Stop();
            delay(2000U);

            DCMotor_SetSpeed(128U);
            DCMotor_Reverse();
            delay(3000U);

            DCMotor_Stop();
            delay(2000U);
        }

        return 0;
    }
    ```
  ]
]

== Program Explanation

`setup()` initializes the basic EduFramework components. Then,
`DCMotor_Init(GPIO2, GPIO3, GPIO4, GPIO5)` configures the four control pins used
by the DC Motor API. In the example TB6612FNG configuration, these pins
correspond to `PWMA`, `AIN1`, `AIN2`, and `STBY`.

Inside the main loop, `DCMotor_SetSpeed(128U)` sets the control level to
approximately half of the `0..255` range. `DCMotor_Forward()` places the module
in the forward configuration, and the motor remains in this state for
`3000 ms`.

Next, `DCMotor_Stop()` places the motor in the coast stop state for `2000 ms`.
The program then applies the same speed level, calls `DCMotor_Reverse()` to
change the direction configuration, and keeps the motor rotating in reverse for
`3000 ms`. The motor is stopped for another `2000 ms` before the next cycle
begins.

The program flow can be summarized as:

`Forward 50%` → `Stop` → `Reverse 50%` → `Stop` → repeat.

== Verification

Build and upload the program to the MaaZEDU Development Board. Apply external
power to the motor driver module and observe the motor over several consecutive
cycles.

Verify the following states:

- The motor rotates in one direction for approximately `3 s`.
- The motor coasts to a stop and remains stopped for approximately `2 s`.
- The motor rotates in the opposite direction for approximately `3 s`.
- The motor remains stopped for approximately `2 s` before the sequence repeats.

#expected-result[
  The DC motor continuously repeats the sequence forward → stop → reverse →
  stop. Both rotation states use the same control value of `128`, corresponding
  to approximately `50%` of the DC Motor Device API control range. Each
  rotation state lasts approximately `3 s`, and each stop state lasts
  approximately `2 s`.
]


// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

The main exercise uses one speed level and coast stopping to focus on basic
motor control. The DC Motor Device API also provides functions for exploring
additional motor-control states.

== Changing the Speed Level

Replace the value `128` in the program with different values and observe the
relative change in motor speed:

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1fr, 1.4fr, 2.1fr),
    align: (center + horizon, center + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,

    table.header(
      repeat: true,

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Value*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Control Level*]
      ],

      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Observation*]
      ],
    ),

    [`64`], [approximately `25%`], [Low rotation level.],
    [`128`], [approximately `50%`], [Level used in the main exercise.],
    [`191`], [approximately `75%`], [Higher rotation level.],
    [`255`], [`100%`], [Maximum control level.],
  )
]

*Extension:* Apply the four values above one at a time while keeping the same
rotation direction and observe the trend. RPM measurement is not required; the
actual motor speed will be measured with an encoder in Lab 15.

== Coast Stop and Short Brake

The TB6612FNG supports both coast stop and short-brake states
#cite-ref(refs, "toshiba-tb6612fng"). In EduFramework:

- `DCMotor_Stop()` uses coast stopping;
- `DCMotor_Brake()` requests the short-brake state.

Syntax:

```c
DCMotor_Stop();
DCMotor_Brake();
```

#api-detail(
  name: "DCMotor_Brake",

  syntax: [DCMotor_Brake();],

  description: [
    Stop the motor using the short-brake state of the H-bridge.
  ],

  parameters: (),

  returns: [No return value.],
)

*Extension:* Run the motor at the same speed level, then separately test
`DCMotor_Stop()` and `DCMotor_Brake()`. Observe the difference between the two
stopping methods without changing the hardware.

== Standby Mode

The `STBY` pin of the TB6612FNG places the module in standby and disables the
power outputs #cite-ref(refs, "toshiba-tb6612fng"). EduFramework provides
`DCMotor_Standby()` to control this state.

#api-detail(
  name: "DCMotor_Standby",

  syntax: [DCMotor_Standby(standby);],

  description: [
    Enable the motor driver module or place it in standby mode.
  ],

  parameters: (
    (
      [standby],
      [`0` / non-zero],
      [
        `0` enables the module; a non-zero value places the module in standby.
      ],
    ),
  ),

  returns: [No return value.],
)

Example:

```c
DCMotor_Standby(1U);
delay(2000U);
DCMotor_Standby(0U);
```

*Extension:* Add a standby interval to the control sequence and verify that the
motor is not driven while the module remains in standby.


// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
