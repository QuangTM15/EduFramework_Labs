// ============================================================================
// EduFramework Laboratory Series
// Global Documentation Theme
// ============================================================================
//
// Responsibilities:
//   - A4 page layout
//   - Running header and footer
//   - Typography and paragraph spacing
//   - Heading hierarchy and numbering
//   - Code and table base styling
//   - Shared colors
//   - Current document language state
//
// Semantic blocks belong in components.typ.
// Laboratory-level structure belongs in lab.typ.
// ============================================================================


// ============================================================================
// 1. COLOR SYSTEM
// ============================================================================

#let fpt-orange = rgb("#F37021")
#let text-black = rgb("#1A1A1A")
#let text-gray = rgb("#555555")
#let line-gray = rgb("#A8A8A8")
#let border-gray = rgb("#B8B8B8")
#let soft-gray = rgb("#F7F7F7")
#let medium-gray = rgb("#EAEAEA")
#let table-line = rgb("#9E9E9E")
#let table-header-gray = rgb("#ECECEC")
#let code-label-gray = rgb("#F2F2F2")


// ============================================================================
// 2. DOCUMENT LANGUAGE STATE
// ============================================================================
//
// "vi" -> Vietnamese labels
// "en" -> English labels
//
// lab.typ updates this state once for the whole document.
// ============================================================================

#let document-language = state("eduf-language", "vi")


// ============================================================================
// 3. GLOBAL THEME
// ============================================================================

#let apply-theme(
  body,
  language: "vi",
) = [

  #document-language.update(language)

  // ==========================================================================
  // 3.1 PAGE CONFIGURATION
  // ==========================================================================

  #set page(
    paper: "a4",

    margin: (
      top: 2.5cm,
      bottom: 2.3cm,
      left: 2.3cm,
      right: 2.3cm,
    ),

    header: context [
      #block(width: 100%)[
        #rect(
          width: 100%,
          height: 5pt,
          fill: fpt-orange,
        )

        #v(5pt)

        #grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),

          [
            #text(
              font: "Calibri",
              size: 8pt,
              weight: "bold",
              fill: text-black,
            )[
              EDUFRAMEWORK LABORATORY SERIES
            ]
          ],

          [
            #text(
              font: "Calibri",
              size: 8pt,
              fill: text-gray,
            )[
              S32K144 · MaaZEDU
            ]
          ],
        )

        #v(4pt)

        #line(
          length: 100%,
          stroke: 0.45pt + line-gray,
        )
      ]
    ],

    footer: context [
      #let lang = document-language.get()
      #let page-word = if lang == "en" { "Page" } else { "Trang" }

      #block(width: 100%)[
        #line(
          length: 100%,
          stroke: 0.45pt + line-gray,
        )

        #v(4pt)

        #grid(
          columns: (1fr, auto),

          [
            #text(
              font: "Calibri",
              size: 7.5pt,
              fill: text-gray,
            )[
              EduFramework Laboratory Series
            ]
          ],

          [
            #text(
              font: "Calibri",
              size: 7.5pt,
              weight: "bold",
              fill: text-black,
            )[
              #page-word #counter(page).display("1")
            ]
          ],
        )

        #v(1pt)

        #grid(
          columns: (1fr, auto),

          [
            #text(
              font: "Calibri",
              size: 7pt,
              fill: text-gray,
            )[
              S32K144 · MaaZEDU
            ]
          ],

          [
            #text(
              font: "Calibri",
              size: 7pt,
              weight: "bold",
              fill: fpt-orange,
            )[
              FPT University
            ]
          ],
        )
      ]
    ],
  )


  // ==========================================================================
  // 3.2 GLOBAL TYPOGRAPHY
  // ==========================================================================

  #set text(
    font: "Calibri",
    size: 10.5pt,
    fill: text-black,
  )

  #set par(
    justify: true,
    leading: 0.78em,
    spacing: 0.65em,
    first-line-indent: 0pt,
  )


  // ==========================================================================
  // 3.3 LISTS
  // ==========================================================================

  #set list(
    indent: 20pt,
    body-indent: 8pt,
    spacing: 4pt,
  )

  #set enum(
    indent: 20pt,
    body-indent: 8pt,
    spacing: 4pt,
  )


  // ==========================================================================
  // 3.4 HEADINGS
  // ==========================================================================

  #set heading(
    numbering: "1.1.1",
  )

  #show heading.where(level: 1): it => block(
    above: 22pt,
    below: 12pt,
    breakable: false,
  )[
    // Object numbering restarts in each top-level section.
    #counter("eduf-table").update(0)
    #counter("eduf-figure").update(0)
    #counter("eduf-listing").update(0)

    #text(
      font: "Calibri",
      size: 16pt,
      weight: "bold",
      fill: text-black,
    )[
      #counter(heading).display()
      #h(7pt)
      #it.body
    ]

    #v(6pt)

    #line(
      length: 100%,
      stroke: 1.25pt + fpt-orange,
    )
  ]

  #show heading.where(level: 2): it => block(
    above: 17pt,
    below: 8pt,
    breakable: false,
  )[
    #text(
      font: "Calibri",
      size: 12.5pt,
      weight: "bold",
      fill: text-black,
    )[
      #counter(heading).display()
      #h(6pt)
      #it.body
    ]
  ]

  #show heading.where(level: 3): it => block(
    above: 13pt,
    below: 6pt,
    breakable: false,
  )[
    #text(
      font: "Calibri",
      size: 10.8pt,
      weight: "bold",
      fill: text-black,
    )[
      #counter(heading).display()
      #h(5pt)
      #it.body
    ]
  ]


  // ==========================================================================
  // 3.5 INLINE CODE
  // ==========================================================================

  #show raw.where(block: false): it => box(
    fill: code-label-gray,
    radius: 2pt,
    inset: (
      left: 3pt,
      right: 3pt,
      top: 1pt,
      bottom: 1pt,
    ),
  )[
    #text(
      font: "Consolas",
      size: 9.2pt,
      fill: text-black,
    )[
      #it
    ]
  ]


  // ==========================================================================
  // 3.6 BLOCK CODE
  // ==========================================================================

  #show raw.where(block: true): it => block(
    width: 100%,

    fill: soft-gray,

    stroke: (
      left: 2pt + fpt-orange,
      top: 0.4pt + border-gray,
      right: 0.4pt + border-gray,
      bottom: 0.4pt + border-gray,
    ),

    inset: (
      left: 11pt,
      right: 10pt,
      top: 9pt,
      bottom: 9pt,
    ),

    above: 8pt,
    below: 8pt,

    breakable: true,
  )[
    #set text(
      font: "Consolas",
      size: 8.8pt,
    )

    #it
  ]


  // ==========================================================================
  // 3.7 TABLE BASE SPACING
  // ==========================================================================

  #show table: it => block(
    above: 8pt,
    below: 8pt,
  )[
    #it
  ]


  // ==========================================================================
  // 3.8 EMPHASIS
  // ==========================================================================

  #show strong: set text(weight: "bold")
  #show emph: set text(style: "italic")


  // ==========================================================================
  // 3.9 BODY
  // ==========================================================================

  #body
]
