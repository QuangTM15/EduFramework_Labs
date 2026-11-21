#import "../template/lab.typ": *
#import "../template/components.typ": *

// ============================================================================
// EduFramework Laboratory Series
// Lab 07 - Tone Fundamentals
// English version
// ============================================================================


// ============================================================================
// 0. REFERENCES
// ============================================================================

#let refs = (
  (
    key: "umn-pitch",
    type: "web",
    author: [University of Minnesota],
    title: [Pitch is Frequency],
    source: [Introduction to Sensation and Perception],
    url: "https://pressbooks.umn.edu/sensationandperception/chapter/pitch-is-frequency/",
  ),

  (
    key: "usc-buzzer",
    type: "web",
    author: [University of Southern California],
    title: [EE 109 Unit H - Timers],
    source: [EE 109 - Introduction to Embedded Systems],
    url: "https://bytes.usc.edu/files/ee109/slides/EE109UnitH_Ultrasonic.pdf",
  ),

  (
    key: "augusta-buzzer",
    type: "manual",
    author: [Augusta University],
    title: [PHYS 1111L Laboratory Manual],
    source: [PHYS 1111L],
    year: [2023],
    url: "https://spots.augusta.edu/tcolbert/PHYS1111L-Lab/Spring2023/PHYS1111L_LabManual.pdf",
  ),

  (
    key: "arduino-language-reference",
    type: "web",
    author: [Arduino],
    title: [Arduino Language Reference],
    source: [Arduino Documentation],
    url: "https://docs.arduino.cc/language-reference/",
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
    key: "eduframework-tone",
    type: "web",
    author: [EduFramework],
    title: [Tone, PWM and Logical Pin API],
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
  number: 7,
  language: "en",
  title: [Tone Fundamentals],
  subtitle: [Generating Sound with a Passive Buzzer using EduFramework],
)


// ============================================================================
// 1. INTRODUCTION
// ============================================================================

= Introduction

== Overview

Sound is commonly used in embedded systems to indicate status, issue alerts,
or provide feedback to the user. With a passive buzzer, sound can be generated
using a periodic signal; changing the signal frequency changes the perceived
pitch #cite-ref(refs, "usc-buzzer")
#cite-ref(refs, "augusta-buzzer").

This lab introduces the generation of simple tones using EduFramework. A
passive buzzer is connected to `GPIO7`, and the program sequentially generates
different frequencies to produce a series of tones with increasing pitch. The
lab focuses on three main concepts: periodic signals, the relationship between
frequency and pitch, and buzzer control using the framework API. The program
plays eight notes from C5 to C6.

== Objectives

#objectives(
  items: (
    [
      Explain the basic principle of generating sound with a passive buzzer.
    ],

    [
      Describe the relationship among period, frequency, and sound pitch.
    ],

    [
      Use `tone()` and `noTone()` to control tones with EduFramework.
    ],

    [
      Build and verify a program that plays an ascending scale with short pauses between notes.
    ],
  ),
)


// ============================================================================
// 2. BACKGROUND
// ============================================================================

= Background

== Passive Buzzer and Control Signal

A passive buzzer does not generate a fixed tone when driven by a constant logic
level. To produce sound, the buzzer must be excited by a signal that changes
periodically over time. In embedded-system exercises, a square wave is a common
way to generate this excitation signal #cite-ref(refs, "usc-buzzer")
#cite-ref(refs, "augusta-buzzer").

A square wave alternates between two logic levels. When these transitions
repeat at a regular rate, the signal has a defined frequency. By changing the
control frequency, the same buzzer can produce tones with different pitches
#cite-ref(refs, "usc-buzzer").

Within the scope of this lab, the buzzer is treated as a simple sound-output
device. More advanced characteristics such as frequency response, sound
pressure level, or the electrical model of the buzzer element are not
considered.

== Period and Frequency

A periodic signal repeats after a defined interval of time. The time required
to complete one repetition is called the period and is commonly denoted by
$T$. Frequency indicates the number of cycles that occur in one second and is
expressed in hertz (Hz) #cite-ref(refs, "umn-pitch").

For a periodic signal, frequency and period are inversely related:

$ f = 1 / T $

where:

- $f$ is the frequency, measured in hertz.
- $T$ is the period, measured in seconds.

Therefore, a higher frequency corresponds to a shorter period. For example, a
`500 Hz` signal repeats faster than a `250 Hz` signal, so the time between
cycles of the `500 Hz` signal is shorter.

== Frequency and Pitch

Pitch is the perception of how high or low a sound is. For simple periodic
tones, pitch is closely related to frequency: increasing the frequency raises
the perceived pitch, while decreasing the frequency lowers it
#cite-ref(refs, "umn-pitch").

This relationship forms the basis of the exercise. When the buzzer receives a
sequence of signals with increasing frequencies, the resulting tones are also
heard as progressively higher in pitch #cite-ref(refs, "usc-buzzer").

#info-table(
  columns: (1.4fr, 1.6fr, 2.6fr),
  alignments: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Frequency],
    [Period],
    [Perceived Pitch],
  ),
  rows: (
    (
      [Lower],
      [Longer],
      [Lower-pitched sound.],
    ),
    (
      [Higher],
      [Shorter],
      [Higher-pitched sound.],
    ),
  ),
  caption: [Qualitative relationship among frequency, period, and pitch],
)

== Frequency and Tone Duration

Frequency determines the pitch of a tone, while duration determines how long
the tone is maintained. These quantities serve different purposes: a tone can
keep the same frequency while being played for a shorter or longer interval
depending on the application. Buzzer exercises commonly describe frequency in
hertz and duration separately in milliseconds
#cite-ref(refs, "augusta-buzzer").

In Lab 07, each of the first seven notes is played for `300 ms`, while the final C6 note lasts `450 ms`. An `80 ms` silent interval separates consecutive notes. After the final note, the buzzer remains silent for `1000 ms` before the sequence repeats.


// ============================================================================
// 3. HARDWARE SETUP
// ============================================================================

= Hardware Setup

== Required Hardware

This lab uses a MaaZEDU Development Board based on the S32K144 microcontroller
and an external passive buzzer #cite-ref(refs, "maazedu-guide").

#hardware-table(
  caption: [Hardware required for the lab],
  rows: (
    (
      [MaaZEDU Development Board],
      [Development board based on the S32K144 microcontroller.],
    ),

    (
      [Passive Buzzer],
      [Sound-output device driven by a periodic signal.],
    ),

    (
      [Jumper wires],
      [Connect the buzzer to the board.],
    ),

    (
      [USB Cable],
      [Connect the board to the computer for power and programming.],
    ),
  ),
)

== Passive Buzzer Connection

`GPIO7` is a PWM-capable Logical Pin in EduFramework and is used as the buzzer
control output in this lab #cite-ref(refs, "eduframework-tone").

#info-table(
  columns: (1.5fr, 1.2fr, 2.6fr),
  alignments: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),
  headers: (
    [Device],
    [Connection],
    [Function],
  ),
  rows: (
    (
      [Passive Buzzer positive terminal (+)],
      [`GPIO7`],
      [Receives the control signal used to generate sound.],
    ),
    (
      [Passive Buzzer negative terminal (-)],
      [`GND`],
      [Connects to GND on the MaaZEDU Development Board.],
    ),
  ),
  caption: [Passive Buzzer connection for Lab 07],
)

#figure-block(
  caption: [Passive Buzzer connection to GPIO7],
)[
  #image(
    "../assets/circuits/tone_passive_buzzer_circuit.png",
    width: 74%,
  )
]


// ============================================================================
// 4. EDUFRAMEWORK API
// ============================================================================

= EduFramework API

The Arduino Language Reference uses `tone()` and `noTone()` for tone generation
and stopping operations #cite-ref(refs, "arduino-language-reference").
EduFramework provides APIs with the same names and an interface suitable for
the MaaZEDU platform.

== `tone()`

`tone()` starts generating a square wave at the specified frequency on a
PWM-capable Logical Pin. In the current implementation, the signal is generated
with a `50%` duty cycle #cite-ref(refs, "eduframework-tone").

#api-detail(
  name: "tone",
  syntax: [tone(pin, frequency);],
  description: [
    Starts a tone at the specified frequency on a PWM Logical Pin.
  ],
  parameters: (
    (
      [pin],
      [PWM Logical Pin],
      [
        Pin used to control the buzzer, for example `GPIO7`.
      ],
    ),

    (
      [frequency],
      [Frequency (Hz)],
      [
        Frequency of the tone to be generated, measured in hertz.
      ],
    ),
  ),
  returns: [No return value.],
)

Example:

```c
tone(GPIO7, 523U);
```

In EduFramework, `tone()` does not include a duration parameter. The signal
continues until its frequency is changed by another call to `tone()` or it is
stopped by `noTone()` #cite-ref(refs, "eduframework-tone"). Therefore, the
duration of each tone in this lab is determined by placing `delay()` after the
`tone()` call.

`tone()` uses the framework PWM layer to prepare the corresponding output, so
the program does not need to call `pinMode(GPIO7, OUTPUT)` before generating a
tone #cite-ref(refs, "eduframework-tone").

== `noTone()`

`noTone()` stops the signal currently being generated on the specified Logical
Pin #cite-ref(refs, "eduframework-tone").

#api-detail(
  name: "noTone",
  syntax: [noTone(pin);],
  description: [
    Stops the tone on the specified PWM Logical Pin.
  ],
  parameters: (
    (
      [pin],
      [PWM Logical Pin],
      [Pin currently being used to generate a tone.],
    ),
  ),
  returns: [No return value.],
)

Example:

```c
noTone(GPIO7);
```

In this exercise, `noTone()` is called after each note to stop the output and introduce a silent interval. The program waits for `80 ms` after each of the first seven notes and `1000 ms` after the final note before repeating.

== PWM Resource Note

Channels within the same FTM of the S32K1xx share a common 16-bit counter
#cite-ref(refs, "nxp-s32k-cookbook"). Because the output frequency depends on
this shared counter, functions that require different frequencies should not be
used simultaneously on pins belonging to the same FTM.

According to the current EduFramework PWM mapping, the Logical Pins are divided
into the following groups #cite-ref(refs, "eduframework-tone"):

#info-table(
  columns: (1.2fr, 3.8fr),
  alignments: (
    center + horizon,
    left + horizon,
  ),
  headers: (
    [PWM Group],
    [Logical Pin],
  ),
  rows: (
    (
      [Group 1],
      [`LED_RED`, `LED_BLUE`, `LED_GREEN`],
    ),
    (
      [Group 2],
      [`GPIO7`, `GPIO8`],
    ),
    (
      [Group 3],
      [`GPIO2`, `GPIO3`, `GPIO4`, `GPIO5`, `GPIO6`],
    ),
  ),
  caption: [Logical Pin groups that share PWM resources],
)

#note[
  Do not use `tone()` and `analogWrite()` simultaneously on two pins that belong
  to the same PWM group. For example, `GPIO7` and `GPIO8` both belong to Group 2.
  EduFramework currently does not implement runtime resource locking, so the
  application is responsible for selecting appropriate pins.
]


// ============================================================================
// 5. LAB EXERCISE
// ============================================================================

= Lab Exercise

== Requirements

Develop a program that uses a passive buzzer connected to `GPIO7` to play the ascending C-major scale from C5 to C6.

The program must satisfy the following requirements:

- Play eight notes in sequence: C5, D5, E5, F5, G5, A5, B5, and C6 (upper C).
- Play each of the first seven notes for `300 ms` and the final C6 note for `450 ms`.
- Call `noTone()` after every note, inserting an `80 ms` silent interval between consecutive notes.
- After the final note, keep the buzzer silent for `1000 ms`, then repeat the sequence continuously.

== Program

Implement the program in `src/main.c` as tested on the hardware:

#block(breakable: false)[
  #code-listing(
    caption: [C5–C6 scale generation with a Passive Buzzer],
  )[
    ```c
    #include "Arduino.h"
    int main(void)
    {
        setup();
        while (1)
        {
            tone(GPIO7, 523U); /* C5 - Do */
            delay(300U);
            noTone(GPIO7);
            delay(80U);
            tone(GPIO7, 587U); /* D5 - Re */
            delay(300U);
            noTone(GPIO7);
            delay(80U);
            tone(GPIO7, 659U); /* E5 - Mi */
            delay(300U);
            noTone(GPIO7);
            delay(80U);
            tone(GPIO7, 698U); /* F5 - Fa */
            delay(300U);
            noTone(GPIO7);
            delay(80U);
            tone(GPIO7, 784U); /* G5 - Sol */
            delay(300U);
            noTone(GPIO7);
            delay(80U);
            tone(GPIO7, 880U); /* A5 - La */
            delay(300U);
            noTone(GPIO7);
            delay(80U);
            tone(GPIO7, 988U); /* B5 - Si */
            delay(300U);
            noTone(GPIO7);
            delay(80U);
            tone(GPIO7, 1047U); /* C6 - Do */
            delay(450U);
            noTone(GPIO7);
            delay(1000U);
        }
        return 0;
    }
    ```
  ]
]

Each `tone()` call specifies the frequency of one musical note. `delay(300U)` maintains each of the first seven notes for `300 ms`, while `delay(450U)` maintains the final C6 note for `450 ms`. The frequencies increase from `523 Hz` to `1047 Hz`, producing progressively higher perceived pitches #cite-ref(refs, "umn-pitch").

After each note, `noTone(GPIO7)` stops the output signal. Seven `80 ms` pauses separate the eight musical notes. After C6, the program waits only `1000 ms` before restarting at C5; it does not insert an additional `80 ms` delay.

The frequency values are written directly in the program to emphasize the `frequency` parameter. Naming notes with constants is introduced in the Extension section.

== Verification

Build and upload the program to the MaaZEDU Development Board. Listen to the passive buzzer and verify that:

- Each sequence contains eight ascending notes from C5 to C6.
- The first seven notes last approximately `300 ms` each, while the final C6 lasts approximately `450 ms`.
- Consecutive notes are separated by approximately `80 ms` of silence.
- A silent interval of approximately `1000 ms` follows C6 before the sequence repeats.

#block(breakable: false)[
  #expected-result[
    The passive buzzer plays an ascending eight-note C5–C6 scale. Each of the first seven notes lasts approximately `300 ms`, and the final note lasts approximately `450 ms`. An `80 ms` pause separates consecutive notes, followed by a `1000 ms` pause after the final note before the sequence repeats.
  ]
]


// ============================================================================
// 6. EXTENSION
// ============================================================================

= Extension

When a program uses many tones, writing raw frequency values at every location
can make the source code more difficult to read. A simple approach is to assign
names to commonly used values with constants.

== Naming Frequencies with Constants

For example, the frequency of the C5 note in the exercise can be defined as:

```c
#define NOTE_C5 523U
```

The API call can then be written as:

```c
tone(GPIO7, NOTE_C5);
```

The constant name expresses the meaning of the value in the program without
changing the frequency passed to the API.

== Extension Exercise: Create a Short Melody

Replace the ascending sequence in the main exercise with a short melody of your
own design.

Requirements:

- Use at least four different frequencies.
- Use at least two different tone durations.
- Include at least one silent interval between parts of the melody.
- Constants such as `NOTE_...` may be defined to improve source-code
  readability.
- Repeat the melody so that it can be verified multiple times on the hardware.

No fixed solution is provided for this extension. The frequencies, tone order,
and durations are selected according to the melody being created.

#expected-result[
  The passive buzzer produces a melody different from the sequence used in the
  main exercise, with noticeable changes in pitch, duration, and silent
  intervals.
]


// ============================================================================
// 7. REFERENCES
// ============================================================================

= References

#references(refs)
