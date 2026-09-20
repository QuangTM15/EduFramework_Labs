#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 09 - Distance Measurement with HC-SR04
// English version
// ============================================================================

// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "nyu-ultrasonic",
    type: "web",
    author: [New York University],
    title: [Lab: Ultrasonic Distance Sensor],
    source: [ITP Physical Computing],
    url: "https://itp.nyu.edu/physcomp/labs/lab-ultrasonic-distance-sensor/",
  ),
  (
    key: "osu-hcsr04",
    type: "web",
    author: [Oregon State University],
    title: [Sonar Rangefinder HC-SR04],
    source: [TekBots],
    url: "https://eecs.engineering.oregonstate.edu/education/hardware/hcsr04/",
  ),
  (
    key: "hcsr04-datasheet",
    type: "datasheet",
    author: [SparkFun Electronics],
    title: [HC-SR04 Ultrasonic Sensor Datasheet],
    source: [Technical Datasheet],
    url: "https://cdn.sparkfun.com/datasheets/Sensors/Proximity/HCSR04.pdf",
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
    key: "eduframework-ultrasonic",
    type: "web",
    author: [EduFramework],
    title: [Ultrasonic Device API],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 9,
  language: "en",
  title: [Distance Measurement with HC-SR04],
  subtitle: [Reading Distance with the Ultrasonic Device API in EduFramework],
)

// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Lab Overview

An ultrasonic sensor can determine the distance to an object without direct
physical contact. The HC-SR04 performs a measurement by transmitting an
ultrasonic signal, waiting for the reflected signal to return, and using the
signal travel time to determine distance #cite-ref(refs, "nyu-ultrasonic").

In EduFramework, the process of generating the trigger signal, measuring the
response time, and converting the result into distance is encapsulated in the
Ultrasonic Device API. The application can therefore work directly with a
distance value in centimeters instead of handling each measurement step
manually #cite-ref(refs, "eduframework-ultrasonic").

The lab exercise uses `ultrasonicBegin()` to initialize the HC-SR04 and
`ultrasonicRead()` to read the distance, then displays the result on the Serial
Monitor. Measurements in other units, multi-sample filtering, and timeout
configuration are reserved for the Extension section.

== Objectives

#objectives(
  items: (
    [
      Describe the basic principle of ultrasonic distance measurement.
    ],
    [
      Explain the roles of the `TRIG` and `ECHO` signals on the HC-SR04.
    ],
    [
      Explain the relationship between the ultrasonic response time and the
      distance to an object.
    ],
    [
      Use `ultrasonicBegin()` and `ultrasonicRead()` to measure distance in
      centimeters.
    ],
    [
      Build and verify a distance monitoring application using the Serial
      Monitor.
    ],
  ),
)

// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== Ultrasonic Distance Measurement

The HC-SR04 uses ultrasonic waves to measure the distance to an object. When a
measurement begins, the module transmits an ultrasonic signal at approximately
`40 kHz`. The signal travels through the air, reflects from the object, and
returns to the sensor. The elapsed time between transmission and reception of
the reflection is used to determine distance
#cite-ref(refs, "nyu-ultrasonic") #cite-ref(refs, "osu-hcsr04").

The measurement process can be represented as:

`Sensor` → `Ultrasonic wave` → `Object` → `Reflected wave` → `Sensor`

Because the signal must travel from the sensor to the object and then return,
the measured time corresponds to a round trip rather than only the one-way
distance from the sensor to the object #cite-ref(refs, "hcsr04-datasheet").

== TRIG and ECHO Signals

The HC-SR04 uses two main digital signals during a measurement. `TRIG` is the
input used to start a measurement, while `ECHO` is the output that represents
the response time of the ultrasonic signal. A `HIGH` pulse of at least
approximately `10 µs` on `TRIG` causes the module to transmit a burst of eight
`40 kHz` ultrasonic cycles
#cite-ref(refs, "hcsr04-datasheet") #cite-ref(refs, "osu-hcsr04").

After transmission, the width of the `HIGH` pulse on `ECHO` varies according to
the travel and reflection time of the ultrasonic wave. Therefore, measuring
the interval during which `ECHO` remains `HIGH` provides the information needed
to calculate distance
#cite-ref(refs, "nyu-ultrasonic") #cite-ref(refs, "hcsr04-datasheet").

In the EduFramework Ultrasonic Device, `TRIG` is configured as a Digital Output
and `ECHO` as a Digital Input. The Device API sequentially generates the
trigger pulse, waits for `ECHO`, measures the pulse width, and processes the
result #cite-ref(refs, "eduframework-ultrasonic").

== From ECHO Time to Distance

Let $t$ be the time required for the ultrasonic wave to travel from the sensor
to the object and return, and let $v$ be the speed of sound. The one-way
distance $d$ is determined by:

$ d = (v times t) / 2 $

The division by `2` is required because the measured time includes both the
outgoing and return paths of the signal. For the HC-SR04, the `ECHO` time in
microseconds can be converted to distance using the approximate relationship
`µs / 58 = cm` #cite-ref(refs, "hcsr04-datasheet").

The current EduFramework implementation uses the factor `0.017` to convert the
`ECHO` pulse width in microseconds into centimeters:

`distance_cm = duration_us × 0.017`

This value corresponds to the distance conversion based on the round-trip
travel time of the ultrasonic wave #cite-ref(refs, "hcsr04-datasheet")
#cite-ref(refs, "eduframework-ultrasonic").

The Ultrasonic Device also uses a timeout to prevent the program from waiting
indefinitely when a valid `ECHO` signal is not received. With the default
configuration, the timeout is `30000 µs`; when a measurement is invalid, the
distance API returns `ULTRASONIC_INVALID_DISTANCE_CM`
#cite-ref(refs, "eduframework-ultrasonic").

// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

The lab exercise uses the MaaZEDU Development Board and an HC-SR04 module. The
module has four pins: `VCC`, `GND`, `TRIG`, and `ECHO`. The `TRIG` and `ECHO`
signals are connected to EduFramework GPIO Logical Pins
#cite-ref(refs, "nyu-ultrasonic")
#cite-ref(refs, "eduframework-ultrasonic").

#hardware-table(
  caption: [Hardware used in the lab exercise],
  rows: (
    (
      [MaaZEDU Development Board],
      [Development board based on the S32K144 microcontroller.],
    ),
    (
      [HC-SR04 ultrasonic sensor],
      [Ultrasonic sensor module used to measure distance to an object.],
    ),
    (
      [Jumper wires],
      [Connect power and the `TRIG` and `ECHO` signals between HC-SR04 and MaaZEDU.],
    ),
    (
      [USB Cable],
      [
        Connect the board to the computer for power, programming, and Serial
        Monitor communication.
      ],
    ),
  ),
)

== Pin Mapping

The lab uses `GPIO2` for the `TRIG` signal and `GPIO1` for the `ECHO` signal.
On the MaaZEDU Development Board, `GPIO2` maps to `PTD14`, while `GPIO1` maps
to `PTD17` #cite-ref(refs, "maazedu-guide").

#pin-table(
  caption: [HC-SR04 signal mapping used in the lab exercise],
  rows: (
    (
      [HC-SR04 `TRIG`],
      "GPIO2",
      "PTD14",
      [Digital Output],
    ),
    (
      [HC-SR04 `ECHO`],
      "GPIO1",
      "PTD17",
      [Digital Input],
    ),
  ),
)

== Connecting the HC-SR04

In the hardware configuration verified for this lab exercise, the HC-SR04 is
powered from `5V`, shares `GND` with MaaZEDU, has `TRIG` connected to `GPIO2`,
and has `ECHO` connected to `GPIO1`. The HC-SR04 uses a `5V` supply in the
operating configuration described for the module
#cite-ref(refs, "nyu-ultrasonic")
#cite-ref(refs, "osu-hcsr04").

#figure-block(
  caption: [HC-SR04 connection to the MaaZEDU Development Board],
)[
  #image(
    "../assets/circuits/ultrasonic_distance_circuit.png",
    width: 86%,
  )
]

#note[
  The lab exercise uses the `GPIO2` and `GPIO1` Logical Pins instead of
  manipulating raw microcontroller pin names directly. This keeps the program
  at the EduFramework API level and follows the MaaZEDU pin mapping
  #cite-ref(refs, "maazedu-guide") #cite-ref(refs, "eduframework-ultrasonic").
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

The main exercise requires only two Ultrasonic Device APIs:
`ultrasonicBegin()` and `ultrasonicRead()`. Time measurements, unit conversion,
multi-sample filtering, and timeout configuration are reserved for the
Extension section #cite-ref(refs, "eduframework-ultrasonic").

== `ultrasonicBegin()`

`ultrasonicBegin()` initializes the default ultrasonic sensor using two Logical
Pins for `TRIG` and `ECHO`. The API configures `TRIG` as an output, `ECHO` as an
input, and uses the default timeout of the Ultrasonic Device
#cite-ref(refs, "eduframework-ultrasonic").

#api-detail(
  name: "ultrasonicBegin",
  syntax: [ultrasonicBegin(trigPin, echoPin);],
  description: [
    Initialize the default HC-SR04 sensor and configure the `TRIG` and `ECHO`
    pins.
  ],
  parameters: (
    (
      [trigPin],
      [Digital Logical Pin],
      [Digital pin connected to the HC-SR04 `TRIG` pin.],
    ),
    (
      [echoPin],
      [Digital Logical Pin],
      [Digital pin connected to the HC-SR04 `ECHO` pin.],
    ),
  ),
  returns: [
    No return value.
  ],
)

Example:

```c
ultrasonicBegin(GPIO2, GPIO1);
```

== `ultrasonicRead()`

`ultrasonicRead()` performs one measurement using the default sensor and
returns the distance in centimeters. If a valid `ECHO` pulse is not measured
before the timeout, the API returns `ULTRASONIC_INVALID_DISTANCE_CM`, whose
value is `-1.0F` #cite-ref(refs, "eduframework-ultrasonic").

#api-detail(
  name: "ultrasonicRead",
  syntax: [ultrasonicRead();],
  description: [
    Perform a measurement with the HC-SR04 and return the distance in
    centimeters.
  ],
  parameters: (),
  returns: [
    Distance in centimeters when the measurement succeeds;
    `ULTRASONIC_INVALID_DISTANCE_CM` when a timeout or invalid measurement
    occurs.
  ],
)

Example:

```c
float distance = ultrasonicRead();
```

// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

== Requirements

Build a program that measures distance with the HC-SR04 using `TRIG` connected
to `GPIO2` and `ECHO` connected to `GPIO1`. The program initializes `Serial1`
at a baud rate of `9600`, reads the distance in centimeters, and updates the
result on the Serial Monitor every `500 ms`.

If the measurement is invalid, the program displays `Distance: Timeout`. After
the program operates correctly, change the distance between the sensor and a
flat object to observe the corresponding change in the result.

== Program

In `src/main.c`, implement the program that has been verified on hardware as
follows:

#block(breakable: false)[
  #code-listing(
    caption: [Program for measuring distance with the HC-SR04],
  )[
    ```c
    #include "Arduino.h"
    #include "ultrasonic.h"

    int main(void)
    {
        float distance = ULTRASONIC_INVALID_DISTANCE_CM;

        setup();

        Serial1_begin(9600U);
        ultrasonicBegin(GPIO2, GPIO1);

        Serial1_println("HC-SR04 Distance Monitor");

        while (1)
        {
            distance = ultrasonicRead();

            if (ULTRASONIC_INVALID_DISTANCE_CM != distance)
            {
                Serial1_print("Distance: ");
                Serial1_printFloat(distance);
                Serial1_println(" cm");
            }
            else
            {
                Serial1_println("Distance: Timeout");
            }

            delay(500U);
        }

        return 0;
    }
    ```
  ]
]

`setup()` initializes the underlying components of EduFramework.
`Serial1_begin()` initializes the Serial Monitor channel, while
`ultrasonicBegin(GPIO2, GPIO1)` initializes the sensor with `GPIO2` assigned to
`TRIG` and `GPIO1` assigned to `ECHO`
#cite-ref(refs, "eduframework-ultrasonic").

In the main loop, `ultrasonicRead()` triggers the sensor, measures the `ECHO`
time, and converts the result into centimeters. The program checks the return
value before printing the result so that a valid measurement can be
distinguished from a timeout #cite-ref(refs, "eduframework-ultrasonic").

The application processing flow can be summarized as:

`Object` → `HC-SR04` → `ECHO time` → `ultrasonicRead()` → `Distance` →
`Serial1` → `Serial Monitor` #cite-ref(refs, "eduframework-ultrasonic").

== Verification

Build and upload the program to the MaaZEDU Development Board, then open the
Serial Monitor at a baud rate of `9600`. Place a flat object in front of the
HC-SR04 and observe the distance value. Move the object farther from the sensor
and then closer again to verify the trend in the measured result.

The Serial Monitor output has the following form:

```text
HC-SR04 Distance Monitor
Distance: 10.24 cm
Distance: 10.19 cm
Distance: 20.36 cm
Distance: 30.41 cm
```

When a valid measurement is not received within the timeout period, the
program displays:

```text
Distance: Timeout
```

#block(breakable: false)[
  #expected-result[
    The Serial Monitor updates the result approximately every `500 ms`. When
    the object is moved farther from the sensor, the distance value tends to
    increase; when the object is moved closer, the value tends to decrease. If
    a valid `ECHO` signal is not received before the timeout, the program
    displays `Timeout`. This behavior is consistent with the HC-SR04 response
    time measurement principle and the processing implemented in the
    Ultrasonic Device #cite-ref(refs, "nyu-ultrasonic")
    #cite-ref(refs, "eduframework-ultrasonic").
  ]
]

// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

The main exercise uses only distance measurements in centimeters. The
Ultrasonic Device also provides APIs for unit conversion, observing response
time, changing the timeout, and processing multiple measurement samples
#cite-ref(refs, "eduframework-ultrasonic").

== Reading Distance in Inches with `ultrasonicReadInch()`

`ultrasonicReadInch()` performs a measurement with the default sensor and
returns the distance in inches. The API uses the distance measurement result
and performs the unit conversion inside the Device
#cite-ref(refs, "eduframework-ultrasonic").

#api-detail(
  name: "ultrasonicReadInch",
  syntax: [ultrasonicReadInch();],
  description: [
    Read the distance from the HC-SR04 and return the result in inches.
  ],
  parameters: (),
  returns: [
    Distance in inches when the measurement succeeds;
    `ULTRASONIC_INVALID_DISTANCE_CM` when the measurement is invalid.
  ],
)

Example:

```c
float distanceInch = ultrasonicReadInch();
```

Extension: Modify the program to display the distance in both centimeters and
inches on the Serial Monitor.

The result can be presented in the following form:

```text
Distance: 25.40 cm
Distance: 10.00 inch
```

== Filtering Measurements with `ultrasonicReadFiltered()`

A single measurement can vary between consecutive readings.
`ultrasonicReadFiltered()` collects multiple distance samples before returning
a processed result. With the current default configuration, the Device
collects `20` samples, sorts them, removes the `5` lowest and `5` highest
samples, and then averages the remaining samples
#cite-ref(refs, "eduframework-ultrasonic").

#api-detail(
  name: "ultrasonicReadFiltered",
  syntax: [ultrasonicReadFiltered();],
  description: [
    Collect multiple distance samples and return a processed value from the
    middle group of samples.
  ],
  parameters: (),
  returns: [
    Filtered distance in centimeters when valid data is available;
    `ULTRASONIC_INVALID_DISTANCE_CM` if no valid result is obtained.
  ],
)

Example:

```c
float filteredDistance = ultrasonicReadFiltered();
```

Extension: Keep the object at a fixed position and compare the results of
`ultrasonicRead()` and `ultrasonicReadFiltered()` on the Serial Monitor.

Example:

```text
Raw: 25.36 cm
Filtered: 25.18 cm
```

== Additional Ultrasonic APIs

EduFramework also provides several additional APIs
#cite-ref(refs, "eduframework-ultrasonic"):

- `ultrasonicReadDuration()` returns the `ECHO` pulse width in microseconds.

- `ultrasonicSetTimeout(timeoutUs)` changes the timeout of the default
  measurement.

- The `Ultrasonic_Begin()`, `Ultrasonic_ReadCm()`,
  `Ultrasonic_ReadInch()`, and `Ultrasonic_ReadCmFiltered()` API group uses an
  `Ultrasonic_t` object to support multiple sensor instances in the same
  application.

These APIs are not required for the main exercise. They are useful when the
application needs to observe the response time directly, adjust the timeout,
or use multiple ultrasonic sensors in one system
#cite-ref(refs, "eduframework-ultrasonic").

Extension: Use `ultrasonicReadDuration()` to display both the `ECHO` duration
and the distance, then observe how the two values change as the object is moved.

// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
