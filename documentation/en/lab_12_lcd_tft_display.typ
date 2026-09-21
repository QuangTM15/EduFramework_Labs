#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 12 - Information Display on TFT
// English version
// ============================================================================

// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "cornell-tft",
    type: "web",
    author: [Cornell University],
    title: [TFT LCD Display],
    source: [ECE 4760 - Designing with Microcontrollers],
    url: "https://people.ece.cornell.edu/land/courses/ece4760/PIC32/index_TFT_display.html",
  ),
  (
    key: "uw-tft",
    type: "web",
    author: [University of Wisconsin-Madison],
    title: [ILI9341 LCD Controller],
    source: [ECE353 - Introduction to Microprocessor Systems],
    url: "https://ece353.engr.wisc.edu/external-devices/ili9341/",
  ),
  (
    key: "sitronix-st7789",
    type: "datasheet",
    author: [Sitronix Technology Corporation],
    title: [ST7789V - 240RGB x 320 dot 262K Color with Frame Memory Single-Chip TFT Controller/Driver],
    revision: [1.3],
    year: [2014],
    url: "https://orientdisplay.com/controller-datasheets/sitronix/st7789v-lcd-controller-datasheet/",
  ),
  (
    key: "nxp-s32k-datasheet",
    type: "datasheet",
    author: [NXP Semiconductors],
    title: [S32K1xx MCU Family - Data Sheet],
    document: [S32K1XX],
    revision: [15],
    year: [2026],
    url: "https://www\.nxp.com/docs/en/data-sheet/S32K1xx.pdf",
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
    key: "eduframework-tft",
    type: "web",
    author: [EduFramework],
    title: [LCD TFT Device API],
    source: [EduFramework Source Code],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
)

// ============================================================================
// DOCUMENT WRAPPER
// ============================================================================

#show: lab.with(
  number: 12,
  language: "en",
  title: [Information Display on TFT],
  subtitle: [Displaying Text and Basic Graphics Using the TFT Device API with EduFramework],
)

// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Lab Overview

A TFT display allows an embedded system to present information using graphical elements
such as pixels, text, lines, and basic geometric shapes. Each pixel is defined by a
position within the display area and a color value; from these basic elements, software
can build visual interfaces for system status, sensor data, or control information
#cite-ref(refs, "cornell-tft").

This lab focuses on using a TFT display through the EduFramework Device API. Instead of
working directly with the command set of the display controller, the application uses
high-level APIs to initialize the display, configure text color and position, and draw
graphics primitives.

== Objectives

#objectives(
  items: (
    [
      Describe the pixel coordinate system and how graphical elements are positioned on a
      TFT display.
    ],
    [
      Explain 16-bit color representation using the RGB565 format.
    ],
    [
      Describe the default TFT Device configuration in EduFramework, including the
      display area dimensions and control Logical Pins.
    ],
    [
      Use `TFT_Begin()`, text APIs, and graphics APIs to display information on a TFT
      screen.
    ],
    [
      Recognize the extended capabilities of the TFT Device API, including backlight
      control, numeric output, custom colors, and the context-based Advanced API.
    ],
  ),
)

// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== Coordinate System and Pixels

A graphical display is organized as a grid of pixels. In the coordinate system used in
this lab, the pixel at the upper-left corner has coordinate `(0, 0)`, the `x` coordinate
increases from left to right, and the `y` coordinate increases from top to bottom. Each
graphical element is defined using the corresponding pixel coordinates
#cite-ref(refs, "uw-tft").

The coordinate system can be visualized as follows:

```text
(0,0) --------------------> x
  |
  |
  |
  |
  v
  y
```

An individual pixel is identified by a coordinate pair `(x, y)`. A line uses two
endpoints, while a rectangle uses the coordinates of its starting corner together with
its width and height. Graphics primitives such as pixels, lines, rectangles, and circles
provide the basis for building more complex graphical elements
#cite-ref(refs, "cornell-tft").

#note[
  Valid coordinates depend on the current display dimensions. When drawing graphics, the
  application should choose coordinates and dimensions that keep each element within the
  intended display area.
]

== RGB565 Color

A common way to represent color on a TFT display is to use `16 bits` for each pixel. In
the RGB565 format, `5 bits` are allocated to the red component, `6 bits` to green, and
`5 bits` to blue #cite-ref(refs, "cornell-tft").

The bit layout can be represented as follows:

```text
15            11 10             5 4               0
+---------------+----------------+-----------------+
|  Red - 5 bit  | Green - 6 bit  |  Blue - 5 bit   |
+---------------+----------------+-----------------+
```

EduFramework provides commonly used predefined color constants:

```c
TFT_BLACK
TFT_WHITE
TFT_RED
TFT_GREEN
TFT_BLUE
TFT_YELLOW
TFT_CYAN
TFT_MAGENTA
```

The graphics APIs receive these 16-bit color values to determine the color of the pixel
or graphical element being drawn #cite-ref(refs, "eduframework-tft").

The ST7789 supports the `16-bit RGB565` pixel-data format in addition to other color
modes. EduFramework uses RGB565 for the TFT Device API color interface
#cite-ref(refs, "sitronix-st7789") #cite-ref(refs, "eduframework-tft").

// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

The lab exercise uses the MaaZEDU Development Board and an LCD TFT module supported by
the current EduFramework configuration. MaaZEDU is a development board based on the
S32K144 microcontroller #cite-ref(refs, "maazedu-guide").

#hardware-table(
  caption: [Hardware used in the lab exercise],
  rows: (
    (
      [MaaZEDU Development Board],
      [Development board based on the S32K144 microcontroller.],
    ),
    (
      [LCD TFT module],
      [TFT display using a controller compatible with the current EduFramework implementation.],
    ),
    (
      [Jumper wires],
      [Connect power, SPI, and control signals between the TFT and MaaZEDU.],
    ),
    (
      [USB Cable],
      [
        Connect the board to the computer for power and program upload.
      ],
    ),
  ),
)

== Default TFT Device Configuration

The EduFramework Beginner API uses a default hardware configuration so that the
application can initialize the display using only `TFT_Begin()`. The current
configuration uses a `240 x 280` pixel display area, `xOffset = 0`, `yOffset = 20`, and
the control Logical Pins shown in the table below
#cite-ref(refs, "eduframework-tft").

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.45fr, 1.35fr, 2.1fr),
    align: (left + horizon, center + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,
    table.header(
      repeat: true,
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Parameter*]
      ],
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Default*]
      ],
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Role*]
      ],
    ),
    [Width], [`240` pixels], [Display-area width.],
    [Height], [`280` pixels], [Display-area height.],
    [X Offset], [`0`], [Starting column offset in controller memory.],
    [Y Offset], [`20`], [Starting row offset in controller memory.],
    [CS], [`GPIO0`], [TFT Chip Select.],
    [DC], [`GPIO1`], [Selects command or display data.],
    [RST], [`GPIO2`], [TFT hardware reset.],
    [BLK], [`GPIO3`], [Backlight control.],
  )
]

#note[
  These values are the default Beginner API configuration in the current EduFramework
  version. When the hardware uses different pins or dimensions, the Advanced API allows
  the application to provide a custom configuration.
]

== TFT Connection

The display uses `SPI_SCK` as the clock signal and `SPI_SOUT` as the data line from the
MCU to the TFT. In the default configuration, the `CS`, `DC`, `RST`, and `BLK` signals
use `GPIO0` through `GPIO3`, respectively #cite-ref(refs, "eduframework-tft").

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.45fr, 1.45fr, 2.1fr),
    align: (left + horizon, center + horizon, left + horizon),
    stroke: 0.4pt + table-line,
    inset: 7pt,
    table.header(
      repeat: true,
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*TFT*]
      ],
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*MaaZEDU*]
      ],
      table.cell(fill: table-header-gray)[
        #align(center + horizon)[*Function*]
      ],
    ),
    [`VCC`], [`3.3V`], [Power supply for the TFT module.],
    [`GND`], [`GND`], [Common ground between the module and the board.],
    [`SCL / SCK`], [`SPI_SCK`], [SPI clock.],
    [`SDA / MOSI`], [`SPI_SOUT`], [SPI data from the MCU to the TFT.],
    [`CS`], [`GPIO0`], [Chip Select.],
    [`DC`], [`GPIO1`], [Data / Command select.],
    [`RES / RST`], [`GPIO2`], [Hardware Reset.],
    [`BLK / BL`], [`GPIO3`], [Backlight control.],
  )
]

#figure-block(
  caption: [LCD TFT connection diagram with MaaZEDU Development Board],
)[
  #image(
    "../assets/circuits/lcd_tft_circuit.png",
    width: 88%,
  )
]

#note[
  The `SDA` label on the TFT module in this lab refers to the SPI `MOSI` data line, not
  the `SDA` signal of I2C communication. The TFT does not use the `SPI_SIN / MISO` line
  in this lab exercise.
]

// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

The EduFramework TFT Device API organizes display operations into initialization, text
rendering, and graphics-primitives groups. The Beginner API uses an internal context and
the default hardware configuration, so the application does not need to manage the
ST7789 controller command sequence directly #cite-ref(refs, "eduframework-tft").

== Initializing the TFT with `TFT_Begin()`

`TFT_Begin()` initializes the TFT Device using the default EduFramework configuration.
The API prepares SPI communication, the control Logical Pins, and the display context
before the application performs graphical operations
#cite-ref(refs, "eduframework-tft").

#api-detail(
  name: "TFT_Begin",
  syntax: [TFT_Begin();],
  description: [
    Initialize the TFT Device using the default EduFramework configuration.
  ],
  parameters: (),
  returns: [
    `true` when the TFT is initialized successfully; `false` when initialization does not
    complete successfully.
  ],
)

Example:

```c
if (true == TFT_Begin())
{
    TFT_FillScreen(TFT_BLACK);
}
```

== Background Color and Graphics Primitives

`TFT_FillScreen()` fills the entire display area with one color. The graphics-primitives
APIs allow the application to work with pixels, lines, rectangles, and circles. Similar
primitives are commonly used in TFT graphics libraries to construct higher-level display
elements #cite-ref(refs, "cornell-tft") #cite-ref(refs, "eduframework-tft").

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.55fr, 2.45fr),
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
    [`TFT_FillScreen(color)`], [Fill the entire display with one color.],
    [`TFT_DrawPixel(x, y, color)`], [Draw one pixel at the specified coordinate.],
    [`TFT_DrawLine(x0, y0, x1, y1, color)`], [Draw a line between two points.],
    [`TFT_DrawRect(x, y, width, height, color)`], [Draw a rectangle outline.],
    [`TFT_FillRect(x, y, width, height, color)`], [Draw a filled rectangle.],
    [`TFT_DrawCircle(x, y, radius, color)`], [Draw a circle using its center and radius.],
    [`TFT_FillCircle(x, y, radius, color)`], [Draw a filled circle.],
  )
]

== Displaying Text

The TFT Device maintains the cursor position, text color, background color, and text
size. After these properties are configured, `TFT_Print()` or `TFT_Println()` uses the
current state to render a string on the display #cite-ref(refs, "eduframework-tft").

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.65fr, 2.35fr),
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
    [`TFT_SetCursor(x, y)`], [Set the starting position for the next text output.],
    [`TFT_SetTextColor(color)`], [Set the character color.],
    [`TFT_SetTextBackground(color)`], [Set the character background color.],
    [`TFT_SetTextSize(size)`], [Set the font scale factor.],
    [`TFT_Print(text)`], [Display a string at the current cursor position.],
    [`TFT_Println(text)`], [Display a string and move the cursor to the next line.],
  )
]

Example:

```c
TFT_SetCursor(20U, 30U);
TFT_SetTextColor(TFT_YELLOW);
TFT_SetTextBackground(TFT_BLACK);
TFT_SetTextSize(3U);
TFT_Println("EduFramework");
```

#note[
  The font is managed internally by the TFT Device implementation. The application does
  not need to access the font bitmap directly to perform basic text operations.
]

// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

== Requirements

Build a program that displays a static interface on the TFT using the EduFramework
Beginner API. The interface consists of two lines of text, one separator line, one
outlined rectangle, one filled rectangle, one outlined circle, and one filled circle.

The program must use the default EduFramework TFT configuration and must not call the
`ST7789_*` functions directly in the main lab exercise.

== Program

In `src/main.c`, implement the hardware-verified program as follows:

#block(breakable: false)[
  #code-listing(
    caption: [Program for displaying text and basic graphics on the TFT],
  )[
    ```c
    #include "Arduino.h"
    #include "lcd_tft.h"

    int main(void)
    {
        setup();

        if (false == TFT_Begin())
        {
            while (1)
            {
                /* TFT initialization failed. */
            }
        }

        TFT_FillScreen(TFT_BLACK);

        TFT_SetCursor(20U, 30U);
        TFT_SetTextColor(TFT_YELLOW);
        TFT_SetTextBackground(TFT_BLACK);
        TFT_SetTextSize(3U);
        TFT_Println("EduFramework");

        TFT_SetCursor(20U, 75U);
        TFT_SetTextColor(TFT_CYAN);
        TFT_SetTextSize(2U);
        TFT_Println("S32K144 TFT");

        TFT_DrawLine(20U, 105U, 220U, 105U, TFT_WHITE);

        TFT_DrawRect(20U, 125U, 80U, 50U, TFT_GREEN);
        TFT_FillRect(140U, 125U, 80U, 50U, TFT_BLUE);

        TFT_DrawCircle(60U, 220U, 25U, TFT_RED);
        TFT_FillCircle(180U, 220U, 25U, TFT_MAGENTA);

        while (1)
        {
            /* Display remains unchanged. */
        }
    }
    ```
  ]
]

== Program Explanation

`setup()` initializes the underlying EduFramework components. `TFT_Begin()` then
initializes the TFT Device using the default configuration; if initialization fails, the
program remains in the error loop and does not perform any further display operations
#cite-ref(refs, "eduframework-tft").

After the Device is ready, `TFT_FillScreen(TFT_BLACK)` creates a black background across
the entire display area. The text APIs configure the cursor position, text color,
background color, and text size before the two strings `"EduFramework"` and
`"S32K144 TFT"` are rendered.

The following instructions use graphics primitives to create a separator line, two
rectangles, and two circles. `TFT_DrawRect()` and `TFT_DrawCircle()` draw only the
outlines, while `TFT_FillRect()` and `TFT_FillCircle()` fill the complete internal area
with the specified color #cite-ref(refs, "eduframework-tft").

After all content has been drawn, the program does not need to update the display
further. The final loop keeps the application running while the content already written
to the TFT remains visible.

== Verification

Build and upload the program to the MaaZEDU Development Board. Observe the display after
the board starts.

The display should show a black background with two lines of text at the top. Below the
text is a white horizontal line, followed by a green outlined rectangle and a blue
filled rectangle. At the bottom, a red outlined circle and a magenta filled circle are
displayed.

The expected TFT output is illustrated below:

#figure-block(
  image("../assets/images/lcd_tft_display_example.png", width: 50%),
  caption: [Expected output on the TFT display.],
)

#block(breakable: false)[
  #expected-result[
    The TFT is initialized successfully and displays both lines of text together with all
    elements at the intended positions. The colors, positions, and fill styles of the
    elements correspond to the parameters passed to the TFT Device API.
  ]
]

// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

The Beginner API provides common operations using the default TFT configuration. In
addition to the APIs used in the main exercise, the TFT Device also supports backlight
control, numeric output, custom RGB565 colors, display-dimension queries, and a
context-based Advanced API for other hardware configurations
#cite-ref(refs, "eduframework-tft").

== Backlight Control

The backlight can be controlled directly using:

```c
TFT_BacklightOn();
TFT_BacklightOff();
```

In the default configuration, the backlight signal uses `GPIO3`
#cite-ref(refs, "eduframework-tft").

These APIs allow the application to turn off the backlight when the display is not needed
and turn it on again when interaction with the display is required.

== Displaying Numeric Values

In addition to character strings, the Beginner API provides functions for displaying
integer and floating-point values:

#block(
  width: 100%,
  breakable: false,
)[
  #table(
    columns: (1.65fr, 2.35fr),
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
    [`TFT_PrintInt(value)`], [Display an integer value.],
    [`TFT_PrintlnInt(value)`], [Display an integer value and move to the next line.],
    [`TFT_PrintFloat(value, decimals)`], [Display a floating-point value with the selected number of decimal places.],
    [`TFT_PrintlnFloat(value, decimals)`], [Display a floating-point value and move to the next line.],
  )
]

Example:

```c
TFT_SetCursor(20U, 30U);
TFT_SetTextColor(TFT_WHITE);
TFT_SetTextBackground(TFT_BLACK);
TFT_SetTextSize(2U);

TFT_Print("Temperature: ");
TFT_PrintFloat(23.56F, 2U);
```

These APIs are suitable for applications that display sensor data because the application
does not need to convert numeric values to strings before rendering them
#cite-ref(refs, "eduframework-tft").

== Creating Custom Colors with `TFT_Color565()`

`TFT_Color565()` converts red, green, and blue color components into a `16-bit` RGB565
value used by the graphics APIs. Each input component is represented in the range `0` to
`255`, after which the framework packs the values into RGB565 format
#cite-ref(refs, "eduframework-tft").

Example:

```c
uint16_t orange;

orange = TFT_Color565(255U, 128U, 0U);

TFT_FillRect(20U, 20U, 80U, 40U, orange);
```

This API allows colors to be created beyond the set of predefined color constants.

== Querying Display Dimensions

The application can read the current TFT Device dimensions using:

```c
uint16_t width;
uint16_t height;

width = TFT_Width();
height = TFT_Height();
```

`TFT_Width()` and `TFT_Height()` help the code avoid direct dependence on the values
`240` and `280`, especially when the application is used with another display
configuration #cite-ref(refs, "eduframework-tft").

== Address Window in the TFT Controller

A TFT controller does not necessarily need to update the entire display for every
operation. A rectangular region can be defined by column and row limits, and subsequent
pixel data are written into the selected region. This arrangement allows only the area
that needs to change to be updated instead of rewriting the complete frame
#cite-ref(refs, "uw-tft").

The ST7789 provides the `CASET` command to set the column range, `RASET` to set the row
range, and `RAMWR` to begin writing pixel data into frame memory
#cite-ref(refs, "sitronix-st7789").

The EduFramework Advanced API exposes this mechanism through:

```c
ST7789_SetAddressWindow(&tft, x0, y0, x1, y1);
```

In typical applications, the framework graphics APIs handle this operation internally;
the application only needs to call `ST7789_SetAddressWindow()` directly when developing
low-level graphics functionality or implementing a custom optimization.

== Context-Based Advanced API

The Beginner API manages a default TFT context and uses fixed pin, dimension, and offset
configuration. When the application requires a different configuration, the Advanced API
allows a separate `ST7789_t` context to be created
#cite-ref(refs, "eduframework-tft").

Example initialization:

#block(breakable: false)[
  #code-listing(
    caption: [Initializing the TFT with the Advanced API],
  )[
    ```c
    ST7789_t tft;

    ST7789_Init(
        &tft,
        GPIO0,
        GPIO1,
        GPIO2,
        240U,
        280U,
        0U,
        20U
    );
    ```
  ]
]

The parameters correspond to the context, `CS`, `DC`, `RST`, width, height, `xOffset`,
and `yOffset`. The application can change these values when the TFT hardware uses a
different connection or display area #cite-ref(refs, "eduframework-tft").

The main graphics APIs at the Advanced level include:

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
    [`ST7789_Init()`], [Initialize a TFT context using the selected configuration.],
    [`ST7789_SetAddressWindow()`], [Set the frame-memory region for pixel-write operations.],
    [`ST7789_DrawPixel()`], [Draw one pixel.],
    [`ST7789_DrawLine()`], [Draw a line.],
    [`ST7789_DrawRect()`], [Draw a rectangle outline.],
    [`ST7789_FillRect()`], [Draw a filled rectangle.],
    [`ST7789_FillScreen()`], [Fill the entire display area.],
    [`ST7789_DrawCircle()`], [Draw a circle.],
    [`ST7789_FillCircle()`], [Draw a filled circle.],
    [`ST7789_DrawChar()`], [Draw one character using the specified position and properties.],
    [`ST7789_DrawString()`], [Draw a string using the specified position and properties.],
  )
]

#note[
  The Beginner API uses the generic `TFT_*` naming scheme, while the current Advanced API
  directly exposes the `ST7789_*` implementation. Therefore, another display can use this
  Advanced API only when its controller and control method are compatible with the current
  ST7789 implementation.
]

== Extension Exercise

Build a simple information screen using the Beginner API to:

- create a custom color using `TFT_Color565()`;
- display an integer using `TFT_PrintInt()`;
- display a floating-point value using `TFT_PrintFloat()`;
- use `TFT_Width()` and `TFT_Height()` instead of hard-coding the display dimensions;
- turn the backlight off for a period of time and turn it on again using the backlight APIs.

Then select one graphical element and try to implement it again using the Advanced API
with a separate `ST7789_t` context.

#block(breakable: false)[
  #expected-result[
    The display correctly presents the numeric data and custom color, the display
    dimensions are obtained from the TFT Device instead of being hard-coded, the
    backlight can be turned on or off through the API, and one graphics primitive is
    implemented successfully using an `ST7789_t` context.
  ]
]

// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
