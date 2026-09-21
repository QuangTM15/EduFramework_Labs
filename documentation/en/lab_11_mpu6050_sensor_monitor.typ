#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 11 - Motion Data Monitoring with MPU6050
// English version
// ============================================================================

// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "berkeley-imu",
    type: "web",
    author: [University of California, Berkeley],
    title: [Strapdown inertial navigation],
    source: [Rotations],
    url: "https\://rotations.berkeley.edu/strapdown-inertial-navigation/",
  ),
  (
    key: "cornell-i2c",
    type: "web",
    author: [Cornell University],
    title: [Inter-Integrated Circuit (I2C)],
    source: [ECE 4760 - Designing with Microcontrollers],
    url: "https\://people.ece.cornell.edu/land/courses/ece4760/PIC32/index_i2c.html",
  ),
  (
    key: "tdk-mpu6050",
    type: "datasheet",
    author: [InvenSense Inc.],
    title: [MPU-6000 and MPU-6050 Product Specification],
    document: [PS-MPU-6000A-00],
    revision: [3.4],
    year: [2013],
    url: "https\://invensense.tdk.com/wp-content/uploads/2015/02/MPU-6000-Datasheet.pdf",
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
    key: "maazedu-guide",
    type: "manual",
    author: [MaaZEDU],
    title: [MaaZEDU Development Board Guide],
    revision: [1.0],
    year: [2025],
  ),
  (
    key: "eduframework-mpu6050",
    type: "web",
    author: [EduFramework],
    title: [MPU6050 Device API],
    source: [EduFramework Source Code],
    url: "https\://github.com/QuangTM15/s32k144-edu-framework",
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 11,
  language: "en",
  title: [Motion Data Monitoring with MPU6050],
  subtitle: [Reading Acceleration and Angular Velocity Using the MPU6050 Device API with EduFramework],
)

// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Lab Overview

The MPU6050 is a motion sensor that integrates a three-axis accelerometer and a three-axis
gyroscope. These two sensing elements provide measurements along three mutually
perpendicular axes, allowing an embedded system to observe changes in motion and the
rotational rate of the object to which the sensor is attached
#cite-ref(refs, "berkeley-imu").

This lab focuses on using the MPU6050 through the EduFramework Device API rather than
accessing the sensor registers directly. The program initializes the module using the
default configuration, simultaneously reads acceleration, angular velocity, and sensor
temperature data, and then displays the results on the Serial Monitor. The Extension
section introduces selective-read APIs, calibration, and the advanced interface that
allows the I2C address as well as the accelerometer and gyroscope measurement ranges to
be changed #cite-ref(refs, "eduframework-mpu6050").

== Objectives

#objectives(
  items: (
    [
      Describe the roles of the accelerometer and gyroscope in a six-axis motion sensor.
    ],
    [
      Explain the basic components of I2C communication, including `SDA`, `SCL`, and
      device addressing.
    ],
    [
      Use the `MPU_Data_t` structure to access acceleration, angular velocity, and sensor
      temperature data provided by EduFramework.
    ],
    [
      Use `MPU_Begin()` and `MPU_ReadData()` to build an MPU6050 data-monitoring
      application on the Serial Monitor.
    ],
    [
      Recognize the advanced configuration capabilities of the MPU6050 Device API,
      including calibration, I2C address selection, and measurement-range configuration.
    ],
  ),
)

// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== Accelerometer and Gyroscope

A typical IMU uses three accelerometers and three rate gyroscopes arranged along three
mutually perpendicular axes. The gyroscope provides the components of the object's
angular velocity along the sensor axes, while the accelerometer provides measurements
of specific force along the corresponding axes #cite-ref(refs, "berkeley-imu").

In EduFramework, the MPU6050 accelerometer values are converted to units of `g`, while
the gyroscope data are converted to `dps` (degrees per second). When the module is
stationary, the accelerometer data still reflect the effect of gravity, so one axis may
have a magnitude close to `1 g` depending on the sensor orientation. Gyroscope data
while stationary are typically close to `0 dps`, but offset and noise are still present
#cite-ref(refs, "berkeley-imu") #cite-ref(refs, "eduframework-mpu6050").

#note[
  A gyroscope provides angular velocity, not the rotation angle directly. Deriving
  orientation, pitch, roll, or yaw from IMU data requires additional processing and is
  outside the scope of this lab.
]

== I2C Communication

I2C is a synchronous two-wire serial bus. `SCL` carries the clock signal, while `SDA`
is used to transfer data. Multiple devices can share the same bus and are distinguished
by the address assigned to each peripheral #cite-ref(refs, "cornell-i2c").

The MPU6050 uses I2C as the host interface in this lab configuration. The least
significant address bit is determined by the `AD0` pin: when `AD0` is low, the slave
address is `0x68`; when `AD0` is high, the address becomes `0x69`
#cite-ref(refs, "tdk-mpu6050").

The data flow in this lab can be represented as:

`MPU6050` → `I2C` → `Wire / LPI2C` → `MPU6050 Device API` → `Application`

// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

The lab uses the MaaZEDU Development Board and an MPU6050 module. MaaZEDU is a
development board based on the S32K144 microcontroller
#cite-ref(refs, "maazedu-guide").

The module is powered from `3.3V`, shares `GND` with the board, and exchanges data
through the I2C interface #cite-ref(refs, "tdk-mpu6050").

#hardware-table(
  caption: [Hardware used in the lab exercise],
  rows: (
    (
      [MaaZEDU Development Board],
      [Development board based on the S32K144 microcontroller.],
    ),
    (
      [MPU6050 module],
      [Sensor module integrating a three-axis accelerometer and a three-axis gyroscope.],
    ),
    (
      [Jumper wires],
      [Connect power and I2C signals between the MPU6050 and MaaZEDU.],
    ),
    (
      [USB Cable],
      [
        Connect the board to the computer for power, program upload, and Serial Monitor
        access.
      ],
    ),
  ),
)

== I2C Signal Mapping

In the current EduFramework configuration, the I2C0 interface uses the `I2C0_SCL` and
`I2C0_SDA` signals. These signals are used by the Wire API and by the MPU6050 Device API
in this lab exercise #cite-ref(refs, "eduframework-mpu6050").

#pin-table(
  caption: [MPU6050 signal mapping used in the lab exercise],
  rows: (
    (
      [MPU6050 `SCL`],
      "I2C0_SCL",
      "PTA3",
      [I2C Clock],
    ),
    (
      [MPU6050 `SDA`],
      "I2C0_SDA",
      "PTA2",
      [I2C Data],
    ),
  ),
)

== Connecting the MPU6050

In the default lab configuration, `VCC` is connected to `3.3V`, `GND` to `GND`, `SCL`
to `I2C0_SCL`, and `SDA` to `I2C0_SDA`. The `AD0` pin is held low by connecting it to
`GND`, so the Device uses the default address `0x68`
#cite-ref(refs, "tdk-mpu6050") #cite-ref(refs, "eduframework-mpu6050").

#figure-block(
  caption: [MPU6050 connection diagram with MaaZEDU Development Board],
)[
  #image(
    "../assets/circuits/mpu6050_circuit.png",
    width: 88%,
  )
]

#note[
  The `INT` pin is not used in this lab exercise. Data are read actively through
  `MPU_ReadData()` according to the program cycle.
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

The EduFramework MPU6050 Device provides a group of simple APIs for basic applications
and a group of advanced APIs for cases that require detailed configuration. The main lab
exercise uses `MPU_Data_t`, `MPU_Begin()`, and `MPU_ReadData()`; the advanced
configuration APIs are introduced in the Extension section
#cite-ref(refs, "eduframework-mpu6050").

== `MPU_Data_t` Structure

`MPU_Data_t` groups the values from one sensor read into a single structure. The
application can access each field directly after `MPU_ReadData()` completes successfully
#cite-ref(refs, "eduframework-mpu6050").

#block(breakable: false)[
  #code-listing(
    caption: [`MPU_Data_t` data structure],
  )[
    ```c
    typedef struct
    {
        float accelX;
        float accelY;
        float accelZ;
        float gyroX;
        float gyroY;
        float gyroZ;
        float temperature;
    } MPU_Data_t;
    ```
  ]
]

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.1fr, 2.2fr, 1fr),
    align: (center + horizon, left + horizon, center + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,
    table.header(
      repeat: true,
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Field*]
      ],
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Quantity*]
      ],
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Unit*]
      ],
    ),
    [`accelX`], [Acceleration / specific force along the X-axis], [`g`],
    [`accelY`], [Acceleration / specific force along the Y-axis], [`g`],
    [`accelZ`], [Acceleration / specific force along the Z-axis], [`g`],
    [`gyroX`], [Angular velocity along the X-axis], [`dps`],
    [`gyroY`], [Angular velocity along the Y-axis], [`dps`],
    [`gyroZ`], [Angular velocity along the Z-axis], [`dps`],
    [`temperature`], [Internal MPU6050 sensor temperature], [`°C`],
  )
]

#note[
  The `temperature` field reflects the internal temperature of the MPU6050 sensor. This
  value should not be used as a direct measurement of the surrounding ambient
  temperature #cite-ref(refs, "tdk-mpu6050").
]

== `MPU_Begin()`

`MPU_Begin()` initializes the MPU6050 using the default EduFramework configuration. The
API initializes the Wire layer, uses address `0x68`, wakes the sensor, and configures the
accelerometer range to `±2 g` and the gyroscope range to `±250 dps`
#cite-ref(refs, "eduframework-mpu6050").

#api-detail(
  name: "MPU_Begin",
  syntax: [MPU_Begin();],
  description: [
    Initialize the MPU6050 using the default EduFramework configuration.
  ],
  parameters: (),
  returns: [
    `true` when initialization and communication verification succeed; `false` when the
    sensor cannot be communicated with or configured.
  ],
)

Example:

```c
if (true == MPU_Begin())
{
    /* MPU6050 is ready. */
}
```

== `MPU_ReadData()`

`MPU_ReadData()` performs one MPU6050 measurement-frame read and simultaneously updates
the acceleration, gyroscope, and temperature fields in `MPU_Data_t`. The API returns
data only when the Device has been initialized successfully
#cite-ref(refs, "eduframework-mpu6050").

#api-detail(
  name: "MPU_ReadData",
  syntax: [MPU_ReadData(data);],
  description: [
    Read one measurement frame and update the supplied data structure.
  ],
  parameters: (
    (
      [data],
      [MPU data structure],
      [Storage for acceleration, gyroscope, and temperature data after the read.],
    ),
  ),
  returns: [
    `true` when the data are read successfully; `false` when the Device has not been
    initialized, the parameter is invalid, or I2C communication fails.
  ],
)

Example:

```c
MPU_Data_t data;

if (true == MPU_ReadData(&data))
{
    Serial1_printFloat(data.accelX);
}
```

// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

== Requirements

Build a program that monitors motion data from the MPU6050 and displays the results on
the Serial Monitor. The program uses `MPU_Begin()` to initialize the Device, then calls
`MPU_ReadData()` every `1000 ms` to obtain three-axis acceleration, three-axis gyroscope,
and sensor-temperature data.

The Serial Monitor uses a baud rate of `9600`. If initialization fails, the program must
report the error and must not continue reading the sensor. If an individual read fails,
the program prints an error message for that read and retries on the next cycle.

== Program

In `src/main.c`, implement the hardware-verified program as follows:

#block(breakable: false)[
  #code-listing(
    caption: [MPU6050 data-monitoring program],
  )[
    ```c
    #include "Arduino.h"
    #include "MPU6050.h"
    int main(void)
    {
        MPU_Data_t data;
        setup();
        Serial1_begin(9600U);
        Serial1_println("MPU6050 Sensor Monitor");
        Serial1_println("----------------------");
        if (false == MPU_Begin())
        {
            Serial1_println("MPU6050 initialization failed.");
            while (1)
            {
                delay(1000U);
            }
        }
        Serial1_println("MPU6050 initialized.");
        while (1)
        {
            if (true == MPU_ReadData(&data))
            {
                Serial1_print("Accel X: ");
                Serial1_printFloat(data.accelX);
                Serial1_print(" g | Y: ");
                Serial1_printFloat(data.accelY);
                Serial1_print(" g | Z: ");
                Serial1_printFloat(data.accelZ);
                Serial1_println(" g");
                Serial1_print("Gyro X: ");
                Serial1_printFloat(data.gyroX);
                Serial1_print(" dps | Y: ");
                Serial1_printFloat(data.gyroY);
                Serial1_print(" dps | Z: ");
                Serial1_printFloat(data.gyroZ);
                Serial1_println(" dps");
                Serial1_print("Temperature: ");
                Serial1_printFloat(data.temperature);
                Serial1_println(" C");
                Serial1_println("----------------------");
            }
            else
            {
                Serial1_println("MPU6050 read failed.");
            }
            delay(1000U);
        }
    }
    ```
  ]
]

== Program Explanation

`setup()` initializes the underlying EduFramework components, and
`Serial1_begin(9600U)` prepares the Serial Monitor channel. `MPU_Begin()` then performs
the complete initialization required for the default MPU6050 configuration. If the API
returns `false`, the program remains in the error loop to avoid continuing with a Device
that is not ready #cite-ref(refs, "eduframework-mpu6050").

Inside the main loop, `MPU_ReadData(&data)` reads one measurement frame. When the read is
successful, all data have already been converted and stored in `data`, so the application
only needs to access the `accelX`, `accelY`, `accelZ`, `gyroX`, `gyroY`, `gyroZ`, and
`temperature` fields. The results are sent to the Serial Monitor using the Serial APIs
introduced in previous labs #cite-ref(refs, "eduframework-mpu6050").

The application flow can be summarized as:

`Motion` → `MPU6050` → `I2C` → `MPU_ReadData()` → `MPU_Data_t` → `Serial1`
→ `Serial Monitor`

`delay(1000U)` creates a one-second interval between updates, making the Serial Monitor
output easier to observe.

== Verification

Build and upload the program to the MaaZEDU Development Board, then open the Serial
Monitor at a baud rate of `9600`.

First, place the module at rest on a stable surface. When one sensor axis is nearly
aligned with gravity, the acceleration component on that axis has a magnitude close to
`1 g`, while the gyroscope values on all three axes remain close to `0 dps`. Actual
values may differ slightly because of module orientation, sensor offset, and noise
#cite-ref(refs, "berkeley-imu").

Next, tilt the module to observe how acceleration is distributed among the axes, then
rotate the module to observe changes in the gyroscope values. The values are not required
to match a fixed set of numbers; the objective is to verify that the measurements respond
appropriately to physical motion.

Data observed during hardware testing have the following form:

```text
MPU6050 Sensor Monitor
----------------------
MPU6050 initialized.
Accel X: 0.060 g | Y: 0.005 g | Z: 1.030 g
Gyro X: 1.901 dps | Y: -1.534 dps | Z: -0.191 dps
Temperature: 46.412 C
----------------------
```

#block(breakable: false)[
  #expected-result[
    The Serial Monitor continuously displays three-axis acceleration and gyroscope data
    together with the sensor temperature. When the module is tilted or rotated, the
    corresponding values change with the motion; when the module is stationary, the
    gyroscope values remain near `0 dps`, while the acceleration values reflect the
    gravity component according to the sensor orientation.
  ]
]

// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

The main lab exercise uses the Beginner API to keep the configuration and program flow
simple. The MPU6050 Device also provides selective-read APIs, calibration, and a
context-based Advanced API so that an application can choose the I2C address, measurement
ranges, and number of calibration samples when required
#cite-ref(refs, "eduframework-mpu6050").

== Selective Reading and Status Checking

In addition to `MPU_ReadData()`, the Beginner API provides functions for reading
individual groups of data:

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.6fr, 2.4fr),
    align: (left + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,
    table.header(
      repeat: true,
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*API*]
      ],
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Function*]
      ],
    ),
    [`MPU_IsInitialized()`], [Check the initialization state of the default Device.],
    [`MPU_ReadAcceleration()`], [Read acceleration along the X, Y, and Z axes.],
    [`MPU_ReadGyroscope()`], [Read gyroscope data along the X, Y, and Z axes.],
    [`MPU_ReadTemperature()`], [Read the internal MPU6050 sensor temperature.],
  )
]

Each selective-read API performs a new sensor read before returning the result. Therefore,
when an application needs acceleration, gyroscope, and temperature data at the same time,
`MPU_ReadData()` is more appropriate because the values are obtained from the same
measurement frame and require only one Device read cycle
#cite-ref(refs, "eduframework-mpu6050").

Example when only acceleration is required:

```c
float x = 0.0F;
float y = 0.0F;
float z = 0.0F;

if (true == MPU_ReadAcceleration(&x, &y, &z))
{
    /* Use acceleration data. */
}
```

== Calibration with `MPU_Calibrate()`

`MPU_Calibrate()` calibrates the default MPU6050 by collecting multiple samples while
the sensor is stationary and calculating accelerometer and gyroscope offsets. In the
current implementation, the Beginner API uses `500` samples. The algorithm assumes that
the module is held steady with the `+Z` axis close to `+1 g` during calibration
#cite-ref(refs, "eduframework-mpu6050").

#api-detail(
  name: "MPU_Calibrate",
  syntax: [MPU_Calibrate();],
  description: [
    Calibrate the default MPU6050 and update the offsets applied to subsequent readings.
  ],
  parameters: (),
  returns: [
    `true` when the complete calibration process finishes successfully; `false` when the
    Device has not been initialized or an error occurs while collecting samples.
  ],
)

#note[
  Keep the module stationary and approximately level throughout calibration. Moving the
  sensor while samples are being collected causes the resulting offsets to no longer
  represent the intended static condition.
]

== I2C Address and the `AD0` Pin

The default lab configuration connects `AD0` to `GND`, corresponding to address `0x68`.
The MPU6050 also allows `AD0` to be driven to a logic-high level to use address `0x69`.
This mechanism allows two MPU6050 devices to coexist on one I2C bus when one Device uses
address `0x68` and the other uses `0x69` #cite-ref(refs, "tdk-mpu6050").

EduFramework defines two address constants:

```c
MPU6050_ADDRESS_DEFAULT   /* 0x68 */
MPU6050_ADDRESS_ALT       /* 0x69 */
```

The Beginner API always uses the default address. When address selection is required, the
application uses the Advanced API and a separate `MPU6050_t` context. With the Advanced
API, the Wire layer must be initialized before `MPU6050_begin()` is called
#cite-ref(refs, "eduframework-mpu6050").

Example:

#block(breakable: false)[
  #code-listing(
    caption: [Initializing the MPU6050 with a custom I2C address],
  )[
    ```c
    MPU6050_t mpu;
    Wire_begin();
    if (true == MPU6050_begin(&mpu, MPU6050_ADDRESS_ALT))
    {
        /* Device at address 0x69 is ready. */
    }
    ```
  ]
]

== Customizing Measurement Ranges

The MPU6050 Product Specification supports four accelerometer full-scale ranges and four
gyroscope full-scale ranges. EduFramework exposes these choices through the Advanced API
#cite-ref(refs, "tdk-mpu6050") #cite-ref(refs, "eduframework-mpu6050").

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.35fr, 1.35fr),
    align: (center + horizon, center + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,
    table.header(
      repeat: true,
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Accelerometer*]
      ],
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Gyroscope*]
      ],
    ),
    [`MPU6050_RANGE_2_G`], [`MPU6050_RANGE_250_DEG`],
    [`MPU6050_RANGE_4_G`], [`MPU6050_RANGE_500_DEG`],
    [`MPU6050_RANGE_8_G`], [`MPU6050_RANGE_1000_DEG`],
    [`MPU6050_RANGE_16_G`], [`MPU6050_RANGE_2000_DEG`],
  )
]

The corresponding configuration APIs are:

```c
MPU6050_setAccelerometerRange(&mpu, MPU6050_RANGE_4_G);
MPU6050_setGyroRange(&mpu, MPU6050_RANGE_500_DEG);
```

A larger measurement range allows the sensor to represent motion with a larger amplitude,
while the sensitivity in counts per unit changes with the selected range. The measurement
range should therefore be selected according to the expected motion amplitude of the
application rather than always using the largest range #cite-ref(refs, "tdk-mpu6050").

== Context-Based Advanced API

The Advanced API stores the address, measurement ranges, measurement data, and
calibration offsets in `MPU6050_t`. This model allows the application to control the
Device configuration instead of relying on the default context used by the Beginner API
#cite-ref(refs, "eduframework-mpu6050").

The main APIs are:

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.8fr, 2.2fr),
    align: (left + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,
    table.header(
      repeat: true,
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Advanced API*]
      ],
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Role*]
      ],
    ),
    [`MPU6050_begin()`], [Initialize a context using the selected I2C address.],
    [`MPU6050_setAccelerometerRange()`], [Change the accelerometer measurement range.],
    [`MPU6050_setGyroRange()`], [Change the gyroscope measurement range.],
    [`MPU6050_read()`], [Read a measurement frame into the context.],
    [`MPU6050_calibrate()`], [Calibrate using a sample count selected by the application.],
    [
      `MPU6050_getAccelerationX()`, `MPU6050_getAccelerationY()`,
      `MPU6050_getAccelerationZ()`
    ],
    [Read the stored acceleration value for each axis from the context.],

    [
      `MPU6050_getGyroX()`, `MPU6050_getGyroY()`, `MPU6050_getGyroZ()`
    ],
    [Read the stored gyroscope value for each axis from the context.],

    [`MPU6050_getTemperature()`], [Read the stored temperature from the context.],
  )
]

The Beginner API is suitable when only one MPU6050 with the standard configuration is
required. The Advanced API is appropriate when the application requires a different
address, a different measurement range, a custom calibration sample count, or explicit
management of the Device context.

== Extension Exercise

Configure the MPU6050 at address `0x69` by setting `AD0` to a logic-high level and use
the Advanced API to:

- initialize a separate `MPU6050_t`;
- select an accelerometer range of `±4 g`;
- select a gyroscope range of `±500 dps`;
- perform calibration using a sample count selected by the program;
- read the data and display acceleration and gyroscope values on the Serial Monitor.

Do not use `MPU_Begin()` in this exercise. The objective is to work directly with
`MPU6050_begin()`, the range-configuration APIs, and `MPU6050_calibrate()`.

#block(breakable: false)[
  #expected-result[
    The MPU6050 is initialized successfully at address `0x69`, data continue to be read
    and displayed after the measurement ranges are changed, and the stationary gyroscope
    values improve after an appropriate calibration process.
  ]
]

// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
