#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 20 - Power Monitoring with INA219
// English version
// ============================================================================

// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "ti-ina219",
    type: "datasheet",
    author: [Texas Instruments],
    title: [INA219 Zerø-Drift, Bidirectional Current/Power Monitor With I2C Interface],
    document: [SBOS448G],
    revision: [G],
    year: [2015],
    url: "https://www.ti.com/lit/ds/symlink/ina219.pdf",
  ),
  (
    key: "ti-power-monitor",
    type: "application-note",
    author: [Patrick Simmons, Texas Instruments],
    title: [Getting Started with Digital Power Monitors],
    document: [SBOA511A],
    revision: [A],
    year: [2021],
    url: "https://www.ti.com/lit/an/sboa511a/sboa511a.pdf",
  ),
  (
    key: "openstax-power",
    type: "web",
    author: [OpenStax],
    title: [University Physics Volume 2 - 9.5 Electrical Energy and Power],
    source: [Rice University, OpenStax],
    url: "https://openstax.org/books/university-physics-volume-2/pages/9-5-electrical-energy-and-power",
  ),
  (
    key: "nxp-s32k",
    type: "datasheet",
    author: [NXP Semiconductors],
    title: [S32K1xx MCU Family - Data Sheet],
    document: [S32K1xx],
    url: "https://www.nxp.com/docs/en/data-sheet/S32K1xx.pdf",
  ),
  (
    key: "maazedu-guide",
    type: "manual",
    author: [FPT Software],
    title: [MaaZ Edu Development Board - User Manual],
    revision: [1.0],
    year: [2025],
  ),
  (
    key: "eduframework-ina219",
    type: "web",
    author: [EduFramework],
    title: [INA219 Device API - ina219.h, Release v3.1.2],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework/blob/v3.1.2/eduframework/include/ina219.h",
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 20,
  language: "en",
  title: [Voltage, Current, and Power Monitoring with INA219],
  subtitle: [Measuring Power Consumption of a Battery-Powered Load with EduFramework],
)

// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Overview

In a direct-current circuit, voltage and current are the two quantities
required to determine the electrical power delivered to a load. According
to the electrical power relationship, observing these quantities together
allows the instantaneous power consumption of the circuit to be evaluated
#cite-ref(refs, "openstax-power").

The INA219 is an integrated circuit for monitoring voltage, current, and
power. It measures the voltage across a shunt resistor connected in series
with the supply path and the bus voltage, then provides measurement data
through a digital interface #cite-ref(refs, "ti-ina219").

This lab uses the INA219 Device API provided by EduFramework to monitor a
load powered by two series-connected Li-ion cells (2S). The program reads
bus voltage, current, and power, then displays the results on the Serial
Monitor. Direct register configuration is outside the scope of the main
exercise #cite-ref(refs, "eduframework-ina219").

== Objectives

#objectives(
  items: (
    [Distinguish the INA219 bus voltage from the voltage across the shunt resistor.],
    [Explain the relationship between voltage, current, and power in a DC load circuit.],
    [Connect the INA219 to MaaZEDU and establish the current path through the load.],
    [Use `INA_Begin()`, `INA_ReadBusVoltage()`, `INA_ReadCurrent()`, and
      `INA_ReadPower()` to acquire and display the measured quantities.],
    [Compare measurements with the load switched on and off, and recognize measurement limitations.],
  ),
)

// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== Voltage, Current, and Power

In a DC circuit, the electrical power associated with a component is
determined by the voltage across it and the current flowing through it.
For a resistive load, the relationship among these quantities is described
by Ohm's law and the electrical power equation
#cite-ref(refs, "openstax-power").

$ I = V / R $

$ P = V times I $

Here, $V$ denotes voltage (`V`), $I$ denotes current (`A`), $R$ denotes
resistance (`Ω`), and $P$ denotes power (`W`). When current and power are
reported in `mA` and `mW`, respectively, multiplying voltage in `V` by
current in `mA` yields power in `mW` #cite-ref(refs, "openstax-power").

#note[
  The relationship `P = V × I` can be used to check whether measured values
  are physically consistent. The power value returned by the INA219 comes
  from the device's calculated power register and is quantized according
  to the calibration scale. Therefore, the displayed power may not equal
  the exact product of the two rounded values shown on the Serial Monitor
  #cite-ref(refs, "ti-ina219").
]

== Current Measurement Using a Shunt Resistor

The INA219 measures the voltage difference across a shunt resistor, using
the convention $V_"shunt" = V_"IN+" - V_"IN−"$. The resistor is placed
in the supply path to the load. If the circuit has no additional current
branches, the current through the shunt is also the load current
#cite-ref(refs, "ti-ina219").

$ I = V_"shunt" / R_"shunt" $

The module used in this exercise has a shunt resistor marked `R100`,
corresponding to `0.1 Ω`. The EduFramework Beginner API uses this value,
the device address `0x40`, and an expected maximum current of `2 A` as
its default configuration #cite-ref(refs, "eduframework-ina219").

For example, a current of `8 mA` through a `0.1 Ω` shunt produces a voltage
difference of approximately `0.8 mV`. The INA219 datasheet specifies a
shunt-voltage resolution of `10 µV` per least significant bit. Offset
errors and shunt selection must therefore be considered when measuring
small currents #cite-ref(refs, "ti-ina219")
#cite-ref(refs, "ti-power-monitor").

== Bus Voltage and Power Measurements

The INA219 measures *bus voltage* at `VIN−` relative to `GND` and
*shunt voltage* between `VIN+` and `VIN−`. These are distinct measurements:
when current flows through the shunt, the source-side voltage at `VIN+`
differs from the bus voltage by the shunt-voltage drop
#cite-ref(refs, "ti-ina219").

$ V_"source" = V_"bus" + V_"shunt" $

The current and power registers use calibration factors established by
software. The INA219 supports bus-voltage measurements with an input
common-mode range of up to `26 V` and operates from a separate logic
supply of `3 V` to `5.5 V`. These are different voltages and must not be
connected interchangeably #cite-ref(refs, "ti-ina219").

#note[
  I2C data communication was introduced in Lab 11. Lab 20 uses only the
  `SDA` and `SCL` connections and the device-level API; the I2C protocol
  is not explained again here.
]

// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

The exercise uses a MaaZEDU Development Board equipped with an S32K144
microcontroller #cite-ref(refs, "nxp-s32k"), an INA219 module with an `R100`
shunt, a switched `2S` Li-ion battery pack, and a resistive load. During
the reported hardware test, the load was replaced with a light-dependent
resistor (LDR). Because an LDR's resistance varies with illumination, the
measured current should not be regarded as a fixed characteristic of the
load #cite-ref(refs, "maazedu-guide") #cite-ref(refs, "ti-ina219")
#cite-ref(refs, "openstax-power").

#hardware-table(
  caption: [Hardware required for Lab 20],
  rows: (
    ([MaaZEDU Development Board], [S32K144 controller board with a Serial Monitor interface.]),
    ([INA219 module (`R100`)], [Measures bus voltage and voltage across the `0.1 Ω` shunt.]),
    ([Switched 2S Li-ion battery pack], [Provides the DC supply for the monitored load branch.]),
    (
      [Resistive load],
      [Establishes current through the shunt; a fixed resistor is preferred for quantitative comparison.],
    ),
    ([Jumper wires and USB cable], [Connect the logic supply, I2C signals, and host computer.]),
  ),
)

== Pin Mapping and Wiring

In the EduFramework pin configuration for MaaZEDU, `I2C0_SDA` is assigned
to `PTA2`, and `I2C0_SCL` is assigned to `PTA3`. The `INA_Begin()` function
initializes the Wire layer automatically. Applications using the Beginner
API do not need a separate call to `Wire_begin()`
#cite-ref(refs, "eduframework-ina219").

#pin-table(
  caption: [Signal mapping between INA219 and MaaZEDU],
  rows: (
    ([INA219 `SDA`], "I2C0_SDA", "PTA2", [Sensor data line.]),
    ([INA219 `SCL`], "I2C0_SCL", "PTA3", [Sensor clock line.]),
  ),
)

Connect INA219 `VCC` to `3.3V`, `GND` to `GND`, `SDA` to `I2C0_SDA`, and
`SCL` to `I2C0_SCL`. The load-current path must follow this sequence:
`2S battery (+) → VIN+ → VIN− → load → 2S battery (−)`.
Connect the battery's negative terminal to the common `GND` shared by the
INA219 module and MaaZEDU. Do not connect the positive battery terminal
to the board's `3.3V` rail #cite-ref(refs, "ti-ina219")
#cite-ref(refs, "maazedu-guide").

#figure-block(
  caption: [Wiring diagram for MaaZEDU, INA219, the load, and the 2S battery pack],
)[
  #image("../assets/circuits/power_monitor_circuit.png", width: 94%)
]

#warning[
  Disconnect the battery before installing or changing any wiring.
  Do not short the battery terminals or connect the battery directly
  across `VIN+` and `VIN−` without a suitable load. Use a battery pack
  with appropriate protection, and verify the load resistance and power
  rating before closing the switch. The diagram is illustrative; the
  common `GND` connection between the battery's negative terminal and
  MaaZEDU must be completed #cite-ref(refs, "ti-ina219")
  #cite-ref(refs, "ti-power-monitor").
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

EduFramework v3.1.2 provides a Beginner API that manages one INA219 at
address `0x40` with a default `0.1 Ω` shunt. The main exercise reads each
quantity using a dedicated function, without requiring an application-
managed `INA219_t` context #cite-ref(refs, "eduframework-ina219").

== `INA_Begin()`

`INA_Begin()` initializes the Wire bus (if necessary), the INA219 device,
and the default calibration parameters. The function must complete
successfully before measurements are requested
#cite-ref(refs, "eduframework-ina219").

#api-detail(
  name: "INA_Begin",
  syntax: [INA_Begin();],
  description: [Initialize the default INA219 module on the I2C0 bus.],
  parameters: (),
  returns: [`true` if initialization succeeds; `false` if the device cannot be initialized.],
)

== `INA_ReadBusVoltage()`

This function reads the voltage at `VIN−` relative to `GND` and reports it
in `V`. The output should only be used if the function returns `true`
#cite-ref(refs, "eduframework-ina219") #cite-ref(refs, "ti-ina219").

#api-detail(
  name: "INA_ReadBusVoltage",
  syntax: [INA_ReadBusVoltage(voltage);],
  description: [Read bus voltage from the default device.],
  parameters: (
    (
      [voltage],
      [Address of the output variable],
      [Address of the variable receiving the voltage in `V`, for example `&voltage`.],
    ),
  ),
  returns: [`true` on successful reading; `false` if the measurement cannot be obtained.],
)

== `INA_ReadCurrent()` and `INA_ReadPower()`

`INA_ReadCurrent()` reads the calibrated current in `mA`;
`INA_ReadPower()` reads the calculated power from the INA219 register in
`mW`. The current is signed, depending on the direction of current flow
through the shunt #cite-ref(refs, "eduframework-ina219")
#cite-ref(refs, "ti-ina219").

#api-detail(
  name: "INA_ReadCurrent",
  syntax: [INA_ReadCurrent(current);],
  description: [Read the calibrated current in `mA`.],
  parameters: (
    ([current], [Address of the output variable], [Address of the variable receiving current in `mA`.]),
  ),
  returns: [`true` if the reading succeeds; `false` if it fails.],
)

#api-detail(
  name: "INA_ReadPower",
  syntax: [INA_ReadPower(power);],
  description: [Read the calculated power in `mW`.],
  parameters: (
    ([power], [Address of the output variable], [Address of the variable receiving power in `mW`.]),
  ),
  returns: [`true` if the reading succeeds; `false` if it fails.],
)

// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

== Requirements

Write a program that initializes the INA219 and displays three quantities:
bus voltage (`V`), current (`mA`), and power (`mW`). Use Serial1 at
`9600 baud`, with successive output iterations separated by a
`delay(1000U)` call. If initialization fails, the program shall report
the error and stop attempting measurements. If a measurement fails, the
program shall report the error and retry during the next loop iteration
#cite-ref(refs, "eduframework-ina219").

== Program

Use the following Beginner API program in `src/main.c`, as tested on
MaaZEDU:

#block(breakable: false)[
  #code-listing(
    caption: [Lab 20 program for voltage, current, and power monitoring],
  )[
    ```c
    #include "Arduino.h"
    #include "ina219.h"

    int main(void)
    {
        float voltage = 0.0f;
        float current = 0.0f;
        float power = 0.0f;

        setup();
        Serial1_begin(9600U);
        Serial1_println("=== Lab 20: INA219 Power Monitor ===");

        if (false == INA_Begin())
        {
            Serial1_println("INA219 initialization failed.");
            while (1)
            {
                delay(1000U);
            }
        }
        Serial1_println("INA219 initialized.");

        while (1)
        {
            if ((true == INA_ReadBusVoltage(&voltage)) &&
                (true == INA_ReadCurrent(&current)) &&
                (true == INA_ReadPower(&power)))
            {
                Serial1_print("Voltage: ");
                Serial1_printFloat(voltage);
                Serial1_println(" V");
                Serial1_print("Current: ");
                Serial1_printFloat(current);
                Serial1_println(" mA");
                Serial1_print("Power: ");
                Serial1_printFloat(power);
                Serial1_println(" mW");
                Serial1_println("------------------------");
            }
            else
            {
                Serial1_println("INA219 read failed.");
            }
            delay(1000U);
        }
        return 0;
    }
    ```
  ]
]

== Program Explanation

`setup()` prepares the EduFramework runtime, while
`Serial1_begin(9600U)` opens the monitoring interface. `INA_Begin()`
configures the sensor at its default address. Following successful
initialization, the three measurement functions write their results to
`voltage`, `current`, and `power`, respectively
#cite-ref(refs, "eduframework-ina219").

The `&&` condition requires all three operations to succeed before
values are printed. The measurements are obtained through successive
read transactions, rather than as a simultaneous sample frame.
`delay(1000U)` introduces a wait between processing iterations; the
actual reporting interval also includes the time spent reading the
device and transmitting Serial output #cite-ref(refs, "eduframework-ina219").

== Verification

Build and upload the program, then open Serial Monitor at `9600 baud`.
With the load's power switch open, no current flows through an ideal
load branch. When the switch is closed, the bus voltage, current, and
power readings update according to the actual circuit conditions
#cite-ref(refs, "openstax-power") #cite-ref(refs, "ti-ina219").

The following is an example of data observed during a hardware test with
an LDR load and the 2S battery switch closed:

```text
Voltage: 7.952 V
Current: 1.200 mA
Power: 10.000 mW
------------------------
```

These values are *illustrative experimental observations*, not
reference specifications or guaranteed limits for the INA219. The
measured values may change with load resistance, illumination, battery
condition, and measurement error. The displayed power is also affected
by the resolution of the device's power register
#cite-ref(refs, "ti-ina219") #cite-ref(refs, "ti-power-monitor").

#block(breakable: false)[
  #expected-result[
    When power is supplied to the load branch, Serial Monitor displays
    bus voltage, current, and power in their respective units. When the
    load is disconnected, the measured current and power tend toward
    zero; small nonzero readings may occur because of sensor offset and
    measurement limitations.
  ]
]

// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

The main exercise uses one sensor with the default configuration.
Additional EduFramework APIs support shunt-voltage measurements,
collective acquisition of multiple quantities, and independent INA219
contexts for different shunt resistances and measurement configurations
#cite-ref(refs, "eduframework-ina219").

== Reading Shunt Voltage and a Measurement Frame

The Beginner API also provides the following functions:

#info-table(
  columns: (2.0fr, 3.0fr),
  alignments: (left + horizon, left + horizon),
  headers: ([API], [Function]),
  rows: (
    ([`INA_IsInitialized()`], [Check whether the default device is initialized.]),
    ([`INA_ReadShuntVoltage()`], [Read the voltage difference `VIN+ − VIN−` in `mV`.]),
    ([`INA_ReadData()`], [Read four measured quantities into an `INA_Data_t` variable.]),
    ([`INA_GetLastStatus()`], [Retrieve the most recent status code for diagnostics.]),
  ),
  caption: [Additional INA219 Beginner APIs],
)

To observe the voltage across the shunt resistor, declare a `float`
variable and pass its address to `INA_ReadShuntVoltage()`. The result is
positive when the current direction follows the convention from `VIN+`
to `VIN−` #cite-ref(refs, "eduframework-ina219")
#cite-ref(refs, "ti-ina219").

```c
float shuntMv = 0.0f;
if (true == INA_ReadShuntVoltage(&shuntMv))
{
    Serial1_printFloat(shuntMv);
}
```

When all four quantities are required, `INA_ReadData()` accepts the
address of an `INA_Data_t` variable. This variable stores only the
measurement results; device state and calibration for the default
sensor remain managed internally by the driver
#cite-ref(refs, "eduframework-ina219").

```c
INA_Data_t data = {0};
if (true == INA_ReadData(&data))
{
    Serial1_printFloat(data.busVoltageV);
    Serial1_printFloat(data.shuntVoltageMv);
    Serial1_printFloat(data.currentMa);
    Serial1_printFloat(data.powerMw);
}
```

== Advanced API and Device Contexts

Unlike the Beginner API, the Advanced API uses an application-declared
`INA219_t` context. Each context stores the I2C address, shunt
resistance, calibration factors, and conversion settings. The Wire
layer must be initialized first with `Wire_begin()`
#cite-ref(refs, "eduframework-ina219").

#info-table(
  columns: (2.2fr, 2.8fr),
  alignments: (left + horizon, left + horizon),
  headers: ([Advanced API], [Purpose]),
  rows: (
    ([`INA219_begin()`], [Initialize a context with the address, shunt resistance, and expected current.]),
    ([`INA219_readData()`], [Read four quantities into `INA_Data_t`.]),
    ([`INA219_setCalibration()`], [Recalculate calibration for the shunt resistance and expected current.]),
    ([`INA219_getDefaultConfig()`], [Populate `INA219_Config_t` with default settings.]),
    ([`INA219_configure()`], [Set the measurement range, ADC settings, and operating mode.]),
    ([`INA219_readSourceVoltage()`], [Read the estimated voltage at `VIN+`.]),
  ),
  caption: [Representative INA219 Advanced APIs],
)

For example, when a module uses an actual shunt resistance of `0.02 Ω`,
that value must be supplied to `INA219_begin()` rather than retaining
the `0.1 Ω` assumption. Successful initialization returns the status
code `INA219_STATUS_OK`; other Advanced API functions also return status
codes instead of `true`/`false` #cite-ref(refs, "eduframework-ina219").

#block(breakable: false)[
  #code-listing(
    caption: [Example of using the Advanced API with a custom shunt resistor],
  )[
    ```c
    INA219_t ina = {0};
    INA_Data_t data = {0};

    Wire_begin();
    if (INA219_STATUS_OK == INA219_begin(
            &ina, 0x40U, 0.02f, 2.0f))
    {
        if (INA219_STATUS_OK == INA219_readData(&ina, &data))
        {
            Serial1_printFloat(data.currentMa);
        }
    }
    ```
  ]
]

This snippet illustrates how to use the Advanced API within an
application in which `Serial1` has already been initialized; it does
not replace the complete `main.c` of the main exercise. Use `0.02 Ω`
only if the physical module has a corresponding shunt resistance.
Changing a software parameter does not alter the actual resistance
or current-carrying capacity of the hardware
#cite-ref(refs, "eduframework-ina219")
#cite-ref(refs, "ti-power-monitor").

== Extension Exercise

Replace the LDR with a fixed resistor whose resistance has been
measured using a multimeter and whose power rating is suitable for
the circuit. After verifying the wiring, measure voltage, current,
and power, then calculate theoretical current and power using the
measured resistance. Record the differences and identify possible
sources of measurement error, including resistor tolerance, offset,
and INA219 resolution #cite-ref(refs, "openstax-power")
#cite-ref(refs, "ti-power-monitor").

#expected-result[
  Prepare a comparison table containing calculated values for the fixed
  load and measurements displayed on the Serial Monitor. The accuracy
  of the sensor must not be inferred from a single measurement;
  reference values and the actual test conditions are required.
]

// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
