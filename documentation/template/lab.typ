// ============================================================================
// EduFramework Laboratory Series
// Laboratory Document Wrapper
// ============================================================================
//
// Responsibilities:
//   - Laboratory metadata
//   - Cover page
//   - Table of contents
//   - Decimal page numbering
//   - Lab number state used by object captions
//   - Language selection
//
// The cover page is not numbered.
// The Contents page starts at page 1.
// Main content continues with page 2, page 3, ... without resetting.
//
// Typical usage:
//
// #import "../template/lab.typ": *
// #import "../template/components.typ": *
//
// #show: lab.with(
//   number: 1,
//   language: "vi",
//   title: [Cơ bản về Digital Output],
//   subtitle: [Điều khiển GPIO với EduFramework],
// )
//
// ============================================================================

#import "theme.typ": *


#let lab(
  body,
  number: 1,
  language: "vi",
  title: [Laboratory],
  subtitle: none,
  platform: [S32K144 · MaaZEDU],
  institution: [FPT University],
  series: [EDUFRAMEWORK LABORATORY SERIES],
) = [

  // ==========================================================================
  // 1. APPLY THEME AND DOCUMENT METADATA
  // ==========================================================================

  #show: apply-theme.with(language: language)

  #counter("eduf-lab").update(number)
  #document-language.update(language)

  #let document-type = if language == "en" {
    [LABORATORY]
  } else {
    [BÀI THỰC HÀNH]
  }

  #let contents-title = if language == "en" {
    [Contents]
  } else {
    [Mục lục]
  }


  // ==========================================================================
  // 2. COVER PAGE
  // ==========================================================================

  #page(
    header: none,
    footer: none,

    margin: (
      top: 2.0cm,
      bottom: 1.8cm,
      left: 2.3cm,
      right: 2.3cm,
    ),
  )[

    // ------------------------------------------------------------------------
    // Top identity
    // ------------------------------------------------------------------------

    #block(width: 100%)[
      #rect(
        width: 100%,
        height: 8pt,
        fill: fpt-orange,
      )

      #v(10pt)

      #grid(
        columns: (1fr, auto),
        align: (left + horizon, right + horizon),

        [
          #text(
            font: "Calibri",
            size: 9pt,
            weight: "bold",
            tracking: 0.2pt,
            fill: text-black,
          )[
            #series
          ]
        ],

        [
          #text(
            font: "Calibri",
            size: 9pt,
            fill: text-gray,
          )[
            #platform
          ]
        ],
      )

      #v(7pt)

      #line(
        length: 100%,
        stroke: 0.5pt + line-gray,
      )
    ]


    // ------------------------------------------------------------------------
    // Main cover identity
    // ------------------------------------------------------------------------

    #v(2.55cm)

    #align(center)[
      #text(
        font: "Calibri",
        size: 12pt,
        weight: "bold",
        tracking: 1.5pt,
        fill: text-gray,
      )[
        #document-type
      ]
    ]

    #v(16pt)

    #align(center)[
      #text(
        font: "Calibri",
        size: 25pt,
        weight: "bold",
        tracking: 0.6pt,
        fill: fpt-orange,
      )[
        LAB #if number < 10 { "0" }#number
      ]
    ]

    #v(25pt)

    #align(center)[
      #block(width: 94%)[
        #align(center)[
          #text(
            font: "Calibri",
            size: 36pt,
            weight: "bold",
            fill: text-black,
          )[
            #title
          ]
        ]
      ]
    ]

    #if subtitle != none [
      #v(16pt)

      #align(center)[
        #block(width: 86%)[
          #align(center)[
            #text(
              font: "Calibri",
              size: 15pt,
              fill: text-gray,
            )[
              #subtitle
            ]
          ]
        ]
      ]
    ]

    #v(30pt)

    #align(center)[
      #line(
        length: 125pt,
        stroke: 1.8pt + fpt-orange,
      )
    ]

    #v(24pt)

    #align(center)[
      #text(
        font: "Calibri",
        size: 12pt,
        weight: "bold",
        fill: text-black,
      )[
        #platform
      ]
    ]


    // ------------------------------------------------------------------------
    // Bottom identity
    // ------------------------------------------------------------------------

    #v(1fr)

    #align(center)[
      #text(
        font: "Calibri",
        size: 10pt,
        fill: text-gray,
      )[
        EduFramework
      ]
    ]

    #v(5pt)

    #align(center)[
      #text(
        font: "Calibri",
        size: 11.5pt,
        weight: "bold",
        fill: text-black,
      )[
        #institution
      ]
    ]

    #v(10pt)

    #align(center)[
      #line(
        length: 70pt,
        stroke: 1.6pt + fpt-orange,
      )
    ]
  ]


  // ==========================================================================
  // 3. CONTENTS
  // ==========================================================================
  //
  // Cover is excluded from visible numbering.
  // Contents starts at page 1.
  // No page-number reset occurs after Contents.
  // ==========================================================================

  #pagebreak()

  #counter(page).update(1)
  #counter(heading).update(0)

  #counter("eduf-table").update(0)
  #counter("eduf-figure").update(0)
  #counter("eduf-listing").update(0)

  #block(
    above: 10pt,
    below: 16pt,
    breakable: false,
  )[
    #text(
      font: "Calibri",
      size: 20pt,
      weight: "bold",
      fill: text-black,
    )[
      #contents-title
    ]

    #v(7pt)

    #line(
      length: 100%,
      stroke: 1.25pt + fpt-orange,
    )
  ]

  #v(8pt)

  #set text(
    font: "Calibri",
    size: 10.5pt,
    fill: text-black,
  )

  #outline(
    title: none,
    depth: 2,
    indent: auto,
  )


  // ==========================================================================
  // 4. MAIN LABORATORY CONTENT
  // ==========================================================================

  #pagebreak()

  // Do NOT reset the page counter here.
  // The first content page follows the Contents page numerically.

  #counter(heading).update(0)
  #counter("eduf-table").update(0)
  #counter("eduf-figure").update(0)
  #counter("eduf-listing").update(0)

  #body
]
