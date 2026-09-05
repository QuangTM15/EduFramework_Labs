// ============================================================================
// EduFramework Laboratory Series
// Reusable Documentation Components
// ============================================================================
//
// Components:
//   - objectives()
//   - note()
//   - warning()
//   - object-caption()
//   - api-table()
//   - api-detail()
//   - hardware-table()
//   - pin-table()
//   - figure-block()
//   - code-listing()
//   - procedure()
//   - expected-result()
//   - cite-ref()
//   - cite-refs()
//   - references()
//
// Design goals:
//   - Academic technical-document appearance
//   - No decorative icons
//   - Shared FPT visual language
//   - Vietnamese / English localization
//   - Automatic Lab.Section.Sequence object numbering
//
// ============================================================================

#import "theme.typ": (
  border-gray, code-label-gray, document-language, fpt-orange, soft-gray, table-header-gray, table-line, text-black,
  text-gray,
)


// ============================================================================
// 1. OBJECTIVES
// ============================================================================

#let objectives(
  items: (),
  intro: none,
) = context [
  #let lang = document-language.get()
  #let title = if lang == "en" { [OBJECTIVES] } else { [MỤC TIÊU] }

  #let default-intro = if lang == "en" {
    [The objectives of this laboratory are:]
  } else {
    [Các mục tiêu của bài lab bao gồm:]
  }

  #block(
    width: 100%,
    stroke: 0.55pt + border-gray,

    inset: (
      left: 16pt,
      right: 16pt,
      top: 14pt,
      bottom: 15pt,
    ),

    above: 7pt,
    below: 12pt,

    breakable: false,
  )[
    #set text(
      font: "Calibri",
      size: 10.3pt,
      fill: text-black,
    )

    #set par(
      justify: true,
      leading: 0.80em,
    )

    #text(
      size: 9pt,
      weight: "bold",
      tracking: 0.35pt,
      fill: text-black,
    )[
      #title
    ]

    #v(4pt)

    #line(
      length: 32pt,
      stroke: 1.6pt + fpt-orange,
    )

    #v(9pt)

    #if intro == none [
      #default-intro
    ] else [
      #intro
    ]

    #v(10pt)

    #for (index, item) in items.enumerate() [
      #grid(
        columns: (18pt, 1fr),
        column-gutter: 6pt,
        align: top,

        [
          #text(weight: "bold")[
            #(index + 1).
          ]
        ],

        [
          #item
        ],
      )

      #if index < items.len() - 1 [
        #v(6pt)
      ]
    ]
  ]
]


// ============================================================================
// 2. NOTE
// ============================================================================

#let note(body) = context [
  #let lang = document-language.get()
  #let title = if lang == "en" { [Note] } else { [Ghi chú] }

  #block(
    width: 82%,

    inset: (
      left: 10pt,
      right: 10pt,
      top: 5pt,
      bottom: 5pt,
    ),

    above: 10pt,
    below: 12pt,

    breakable: false,
  )[
    #set text(
      font: "Calibri",
      size: 9.7pt,
      fill: text-black,
    )

    #set par(
      justify: true,
      leading: 0.82em,
    )

    #align(center)[
      #text(
        weight: "bold",
        size: 10pt,
      )[
        #title
      ]
    ]

    #v(6pt)

    #text(style: "italic")[
      #body
    ]
  ]
]


// ============================================================================
// 3. WARNING
// ============================================================================

#let warning(body) = context [
  #let lang = document-language.get()
  #let title = if lang == "en" { [WARNING] } else { [CẢNH BÁO] }

  #block(
    width: 100%,
    fill: soft-gray,

    stroke: (
      left: 3pt + fpt-orange,
      top: 0.65pt + border-gray,
      right: 0.65pt + border-gray,
      bottom: 0.65pt + border-gray,
    ),

    inset: (
      left: 15pt,
      right: 15pt,
      top: 12pt,
      bottom: 12pt,
    ),

    above: 10pt,
    below: 12pt,

    breakable: false,
  )[
    #set text(
      font: "Calibri",
      size: 9.8pt,
      fill: text-black,
    )

    #set par(
      justify: true,
      leading: 0.82em,
    )

    #text(
      size: 9pt,
      weight: "bold",
      tracking: 0.4pt,
      fill: fpt-orange,
    )[
      #title
    ]

    #v(7pt)

    #body
  ]
]


// ============================================================================
// 4. OBJECT CAPTION
// ============================================================================
//
// Number format:
//   <Lab>.<Top-level section>.<Sequence>
//
// Examples:
//   Bảng 1.3.1.
//   Hình 1.6.1.
//   Mã nguồn 1.6.1.
//
// Table/Figure/Listing counters are independent and restart in each
// top-level section.
// ============================================================================

#let object-caption(
  kind,
  caption,
) = context [
  #let lang = document-language.get()

  #let counter-key = if kind == "table" {
    "eduf-table"
  } else if kind == "figure" {
    "eduf-figure"
  } else {
    "eduf-listing"
  }

  #let prefix = if kind == "table" {
    if lang == "en" { "Table" } else { "Bảng" }
  } else if kind == "figure" {
    if lang == "en" { "Figure" } else { "Hình" }
  } else {
    if lang == "en" { "Listing" } else { "Mã nguồn" }
  }

  #counter(counter-key).step()

  #let lab-state = counter("eduf-lab").get()
  #let heading-state = counter(heading).get()
  #let object-state = counter(counter-key).get()

  #let lab-number = if lab-state.len() > 0 {
    lab-state.at(0)
  } else {
    0
  }

  #let section-number = if heading-state.len() > 0 {
    heading-state.at(0)
  } else {
    0
  }

  #let object-number = if object-state.len() > 0 {
    object-state.at(0) + 1
  } else {
    1
  }

  #align(center)[
    #text(
      font: "Calibri",
      size: 9pt,
      weight: "regular",
      style: "italic",
      fill: text-gray,
    )[
      #prefix #lab-number.#section-number.#object-number. #caption
    ]
  ]
]


// ============================================================================
// 5. API OVERVIEW TABLE
// ============================================================================
//
// Row:
//   ("digitalWrite", "(pin, value)", [Description])
// ============================================================================

#let api-table(
  rows: (),
  caption: none,
) = context [
  #let lang = document-language.get()
  #let description-label = if lang == "en" { [Description] } else { [Mô tả] }

  #block(
    width: 100%,
    above: 9pt,
    below: 14pt,
    breakable: false,
  )[
    #table(
      columns: (1.55fr, 2.45fr),

      align: (
        center + horizon,
        left + horizon,
      ),

      stroke: 0.4pt + table-line,

      table.header(
        repeat: true,

        table.cell(
          fill: table-header-gray,
          align: center + horizon,

          stroke: (
            top: 0.7pt + text-gray,
            bottom: 0.7pt + text-gray,
            left: 0.4pt + table-line,
            right: 0.4pt + table-line,
          ),

          inset: 7pt,
        )[
          #text(
            font: "Calibri",
            size: 9.3pt,
            weight: "bold",
          )[
            API
          ]
        ],

        table.cell(
          fill: table-header-gray,
          align: center + horizon,

          stroke: (
            top: 0.7pt + text-gray,
            bottom: 0.7pt + text-gray,
            left: 0.4pt + table-line,
            right: 0.4pt + table-line,
          ),

          inset: 7pt,
        )[
          #text(
            font: "Calibri",
            size: 9.3pt,
            weight: "bold",
          )[
            #description-label
          ]
        ],
      ),

      ..rows
        .map(row => (
          table.cell(
            align: center + horizon,
            inset: 7pt,
          )[
            #box(
              fill: code-label-gray,
              radius: 2pt,

              inset: (
                left: 5pt,
                right: 5pt,
                top: 2.5pt,
                bottom: 2.5pt,
              ),
            )[
              #text(
                font: "Consolas",
                size: 8.6pt,
                fill: text-black,
              )[
                #row.at(0)#row.at(1)
              ]
            ]
          ],

          table.cell(
            align: left + horizon,
            inset: 7pt,
          )[
            #set text(
              font: "Calibri",
              size: 9.3pt,
            )

            #set par(
              justify: true,
              leading: 0.76em,
            )

            #row.at(2)
          ],
        ))
        .flatten(),
    )

    #if caption != none [
      #v(6pt)
      #object-caption("table", caption)
    ]
  ]
]


// ============================================================================
// 6. API DETAIL
// ============================================================================
//
// Recommended parameter row:
//   ([pin], [Logical Pin], [Logical pin identifier.])
//
// Two-field rows are also accepted:
//   ([pin], [Logical pin identifier.])
//
// In the two-field form the type/value column displays "—".
// ============================================================================

#let api-detail(
  name: "",
  syntax: none,
  parameters: (),
  description: none,
  returns: none,
) = context [
  #let lang = document-language.get()

  #let syntax-label = if lang == "en" { [Syntax] } else { [Cú pháp] }
  #let parameters-label = if lang == "en" { [Parameters] } else { [Tham số] }
  #let parameter-label = if lang == "en" { [Parameter] } else { [Tham số] }
  #let type-label = if lang == "en" {
    [Type / accepted value]
  } else {
    [Kiểu / giá trị chấp nhận]
  }
  #let description-label = if lang == "en" { [Description] } else { [Mô tả] }
  #let returns-label = if lang == "en" { [Return value] } else { [Giá trị trả về] }

  #block(
    width: 100%,
    above: 8pt,
    below: 14pt,
  )[
    #set text(
      font: "Calibri",
      size: 9.7pt,
      fill: text-black,
    )

    #set par(
      justify: true,
      leading: 0.80em,
    )

    #text(
      font: "Consolas",
      size: 9.8pt,
      weight: "bold",
      fill: text-black,
    )[
      #name
    ]

    #v(3pt)

    #line(
      length: 100%,
      stroke: 0.6pt + border-gray,
    )

    #if description != none [
      #v(7pt)
      #description
    ]

    #if syntax != none [
      #v(9pt)

      #text(
        size: 9pt,
        weight: "bold",
      )[
        #syntax-label
      ]

      #v(4pt)

      #block(
        width: 100%,
        fill: rgb("#F6F6F6"),

        stroke: (
          left: 1.5pt + border-gray,
        ),

        inset: (
          left: 10pt,
          right: 10pt,
          top: 6pt,
          bottom: 6pt,
        ),
      )[
        #text(
          font: "Consolas",
          size: 8.7pt,
        )[
          #syntax
        ]
      ]
    ]

    #if parameters.len() > 0 [
      #v(9pt)

      #text(
        size: 9pt,
        weight: "bold",
      )[
        #parameters-label
      ]

      #v(4pt)

      #table(
        columns: (0.75fr, 1.35fr, 2.4fr),

        align: (
          center + horizon,
          center + horizon,
          left + horizon,
        ),

        stroke: 0.35pt + rgb("#DDDDDD"),
        inset: 5pt,

        table.header(
          repeat: true,

          table.cell(fill: table-header-gray, align: center + horizon)[
            #text(size: 8.6pt, weight: "bold")[#parameter-label]
          ],

          table.cell(fill: table-header-gray, align: center + horizon)[
            #text(size: 8.6pt, weight: "bold")[#type-label]
          ],

          table.cell(fill: table-header-gray, align: center + horizon)[
            #text(size: 8.6pt, weight: "bold")[#description-label]
          ],
        ),

        ..parameters
          .map(parameter => (
            [
              #text(
                font: "Consolas",
                size: 8.5pt,
                weight: "bold",
              )[
                #parameter.at(0)
              ]
            ],

            [
              #if parameter.len() >= 3 [
                #parameter.at(1)
              ] else [
                —
              ]
            ],

            [
              #if parameter.len() >= 3 [
                #parameter.at(2)
              ] else [
                #parameter.at(1)
              ]
            ],
          ))
          .flatten(),
      )
    ]

    #if returns != none [
      #v(9pt)

      #text(
        size: 9pt,
        weight: "bold",
      )[
        #returns-label
      ]

      #v(4pt)

      #returns
    ]
  ]
]


// ============================================================================
// 7. HARDWARE TABLE
// ============================================================================

#let hardware-table(
  rows: (),
  caption: none,
) = context [
  #let lang = document-language.get()
  #let hardware-label = if lang == "en" { [Hardware] } else { [Phần cứng] }
  #let description-label = if lang == "en" { [Description] } else { [Mô tả] }

  #block(
    width: 100%,
    above: 9pt,
    below: 14pt,
    breakable: false,
  )[
    #table(
      columns: (1.55fr, 2.45fr),

      align: (
        left + horizon,
        left + horizon,
      ),

      stroke: 0.4pt + table-line,

      table.header(
        repeat: true,

        table.cell(
          fill: table-header-gray,
          align: center + horizon,
          stroke: 0.7pt + table-line,
          inset: 7pt,
        )[
          #text(
            font: "Calibri",
            size: 9.3pt,
            weight: "bold",
          )[
            #hardware-label
          ]
        ],

        table.cell(
          fill: table-header-gray,
          align: center + horizon,
          stroke: 0.7pt + table-line,
          inset: 7pt,
        )[
          #text(
            font: "Calibri",
            size: 9.3pt,
            weight: "bold",
          )[
            #description-label
          ]
        ],
      ),

      ..rows
        .map(row => (
          table.cell(
            align: left + horizon,
            inset: 7pt,
          )[
            #set text(
              font: "Calibri",
              size: 9.3pt,
            )

            #row.at(0)
          ],

          table.cell(
            align: left + horizon,
            inset: 7pt,
          )[
            #set text(
              font: "Calibri",
              size: 9.3pt,
            )

            #set par(
              justify: true,
              leading: 0.76em,
            )

            #row.at(1)
          ],
        ))
        .flatten(),
    )

    #if caption != none [
      #v(6pt)
      #object-caption("table", caption)
    ]
  ]
]


// ============================================================================
// 8. PIN MAPPING TABLE
// ============================================================================

#let pin-table(
  rows: (),
  caption: none,
) = context [
  #let lang = document-language.get()

  #let component-label = if lang == "en" { [Component] } else { [Thành phần] }
  #let logical-label = [Logical Pin]
  #let mcu-label = [MCU Pin]
  #let function-label = if lang == "en" { [Function] } else { [Chức năng] }

  #block(
    width: 100%,
    above: 9pt,
    below: 14pt,
    breakable: false,
  )[
    #table(
      columns: (
        1.35fr,
        1.35fr,
        1.15fr,
        1.65fr,
      ),

      align: (
        center + horizon,
        center + horizon,
        center + horizon,
        center + horizon,
      ),

      stroke: 0.4pt + table-line,

      table.header(
        repeat: true,

        table.cell(fill: table-header-gray, align: center + horizon, inset: 7pt)[
          #text(font: "Calibri", size: 9pt, weight: "bold")[#component-label]
        ],

        table.cell(fill: table-header-gray, align: center + horizon, inset: 7pt)[
          #text(font: "Calibri", size: 9pt, weight: "bold")[#logical-label]
        ],

        table.cell(fill: table-header-gray, align: center + horizon, inset: 7pt)[
          #text(font: "Calibri", size: 9pt, weight: "bold")[#mcu-label]
        ],

        table.cell(fill: table-header-gray, align: center + horizon, inset: 7pt)[
          #text(font: "Calibri", size: 9pt, weight: "bold")[#function-label]
        ],
      ),

      ..rows
        .map(row => (
          table.cell(align: center + horizon, inset: 7pt)[
            #set text(font: "Calibri", size: 9pt)
            #row.at(0)
          ],

          table.cell(align: center + horizon, inset: 7pt)[
            #box(
              fill: code-label-gray,
              radius: 2pt,
              inset: (
                left: 5pt,
                right: 5pt,
                top: 2.5pt,
                bottom: 2.5pt,
              ),
            )[
              #text(font: "Consolas", size: 8.4pt)[#row.at(1)]
            ]
          ],

          table.cell(align: center + horizon, inset: 7pt)[
            #box(
              fill: code-label-gray,
              radius: 2pt,
              inset: (
                left: 5pt,
                right: 5pt,
                top: 2.5pt,
                bottom: 2.5pt,
              ),
            )[
              #text(font: "Consolas", size: 8.4pt)[#row.at(2)]
            ]
          ],

          table.cell(align: center + horizon, inset: 7pt)[
            #set text(font: "Calibri", size: 9pt)
            #row.at(3)
          ],
        ))
        .flatten(),
    )

    #if caption != none [
      #v(6pt)
      #object-caption("table", caption)
    ]
  ]
]


// ============================================================================
// 9. FIGURE BLOCK
// ============================================================================
//
// Usage:
//
// #figure-block(
//   caption: [Sơ đồ kết nối phần cứng],
// )[
//   #image("...", width: 70%)
// ]
// ============================================================================

#let figure-block(
  body,
  caption: none,
) = block(
  width: 100%,
  above: 10pt,
  below: 14pt,
)[
  #align(center)[
    #body
  ]

  #if caption != none [
    #v(6pt)
    #object-caption("figure", caption)
  ]
]


// ============================================================================
// 10. CODE LISTING
// ============================================================================

#let code-listing(
  body,
  caption: none,
) = block(
  width: 100%,
  above: 9pt,
  below: 14pt,
)[
  #body

  #if caption != none [
    #v(6pt)
    #object-caption("listing", caption)
  ]
]


// ============================================================================
// 11. PROCEDURE / DESIGN GUIDELINES
// ============================================================================
//
// The component intentionally explains reasoning steps rather than
// "click-this-button" operational instructions.
// ============================================================================

#let procedure(
  steps: (),
) = block(
  width: 100%,
  above: 9pt,
  below: 14pt,
)[
  #for (index, step) in steps.enumerate() [
    #block(
      width: 100%,
      above: if index == 0 { 0pt } else { 13pt },
      below: 6pt,
      breakable: false,
    )[
      #text(
        font: "Calibri",
        size: 10pt,
        weight: "bold",
        fill: text-black,
      )[
        #context {
          let lang = document-language.get()

          if lang == "en" {
            [Step #(index + 1). #step.at(0)]
          } else {
            [Bước #(index + 1). #step.at(0)]
          }
        }
      ]
    ]

    #block(
      width: 100%,
      below: 2pt,
    )[
      #set text(
        font: "Calibri",
        size: 10pt,
        fill: text-black,
      )

      #set par(
        justify: true,
        leading: 0.82em,
      )

      #step.at(1)
    ]
  ]
]


// ============================================================================
// 12. EXPECTED RESULT
// ============================================================================

#let expected-result(body) = context [
  #let lang = document-language.get()
  #let title = if lang == "en" { [EXPECTED RESULT] } else { [KẾT QUẢ MONG ĐỢI] }

  #block(
    width: 100%,

    stroke: (
      top: 0.8pt + border-gray,
    ),

    inset: (
      top: 9pt,
      bottom: 4pt,
    ),

    above: 10pt,
    below: 14pt,
  )[
    #text(
      font: "Calibri",
      size: 9pt,
      weight: "bold",
      tracking: 0.3pt,
      fill: text-black,
    )[
      #title
    ]

    #v(7pt)

    #set text(
      font: "Calibri",
      size: 10pt,
    )

    #set par(
      justify: true,
      leading: 0.8em,
    )

    #body
  ]
]


// ============================================================================
// 13. REFERENCES AND CITATIONS
// ============================================================================
//
// Compact numbered references.
//
// Example:
//
// [1] Arduino, Digital Pins, Arduino Documentation.
// [2] NXP Semiconductors, S32K1xx Series Cookbook,
//     Application Note AN5413, Rev. 5, 2020.
//
// If a reference contains a URL, its title is clickable.
// ============================================================================

#let reference-link-color = rgb("#4A4A4A")


// ============================================================================
// Reference lookup
// ============================================================================

#let reference-index(refs, key) = {
  let result = none

  for (index, item) in refs.enumerate() {
    if item.key == key {
      result = index
    }
  }

  result
}


#let reference-number(refs, key) = {
  let index = reference-index(refs, key)

  if index == none {
    panic("Unknown reference key: " + key)
  }

  index + 1
}


// ============================================================================
// In-text citations
// ============================================================================
//
// #cite-ref(refs, "arduino-digital-pins")
// -> [1]
//
// #cite-refs(refs, ("arduino-digital-pins", "nxp-s32k-datasheet"))
// -> [1], [2]
// ============================================================================

#let cite-ref(refs, key) = {
  let number = reference-number(refs, key)

  text(
    font: "Calibri",
    size: 9pt,
    fill: reference-link-color,
  )[
    [#number]
  ]
}


#let cite-refs(refs, keys) = {
  let result = []

  for (index, key) in keys.enumerate() {
    if index > 0 {
      result += [, ]
    }

    result += cite-ref(refs, key)
  }

  result
}


// ============================================================================
// Reference validation
// ============================================================================

#let valid-reference-type(reference-type) = (
  reference-type == "manual"
    or reference-type == "datasheet"
    or reference-type == "application-note"
    or reference-type == "standard"
    or reference-type == "book"
    or reference-type == "article"
    or reference-type == "web"
)


// ============================================================================
// Clickable reference title
// ============================================================================

#let reference-title(item) = {
  if "url" in item {
    link(item.url)[
      #text(
        font: "Calibri",
        size: 9.3pt,
        style: "italic",
        fill: reference-link-color,
      )[
        #item.title
      ]
    ]
  } else {
    text(
      font: "Calibri",
      size: 9.3pt,
      style: "italic",
      fill: text-black,
    )[
      #item.title
    ]
  }
}


// ============================================================================
// Single reference entry
// ============================================================================

#let reference-entry(number, item) = {
  if not ("key" in item) {
    panic("Reference entry is missing required field: key")
  }

  if not ("author" in item) {
    panic("Reference '" + item.key + "' is missing required field: author")
  }

  if not ("title" in item) {
    panic("Reference '" + item.key + "' is missing required field: title")
  }

  if "type" in item {
    if not valid-reference-type(item.type) {
      panic(
        "Unsupported reference type in '" + item.key + "': " + item.type,
      )
    }
  }

  let entry = []

  entry += item.author
  entry += [, ]

  entry += reference-title(item)

  if "document" in item {
    entry += [, ]
    entry += item.document
  }

  if "source" in item {
    entry += [, ]
    entry += item.source
  }

  if "publisher" in item {
    entry += [, ]
    entry += item.publisher
  }

  if "revision" in item {
    entry += [, Rev. ]
    entry += item.revision
  }

  if "year" in item {
    entry += [, ]
    entry += item.year
  }

  entry += [.]

  block(
    width: 100%,
    breakable: false,
  )[
    #grid(
      columns: (28pt, 1fr),
      column-gutter: 6pt,
      align: top,

      [
        #text(
          font: "Calibri",
          size: 9.3pt,
          fill: text-black,
        )[
          [#number]
        ]
      ],

      [
        #set text(
          font: "Calibri",
          size: 9.3pt,
          fill: text-black,
        )

        #set par(
          justify: true,
          leading: 0.82em,
        )

        #entry
      ],
    )
  ]
}


// ============================================================================
// Reference list
// ============================================================================

#let references(refs) = block(
  width: 100%,
  above: 5pt,
  below: 8pt,
)[
  #if refs.len() == 0 [
    #context {
      let lang = document-language.get()

      text(
        font: "Calibri",
        size: 9.5pt,
        style: "italic",
        fill: text-gray,
      )[
        #if lang == "en" [
          No references are listed for this laboratory.
        ] else [
          Bài lab này chưa có tài liệu tham khảo.
        ]
      ]
    }
  ] else [
    #for (index, item) in refs.enumerate() [
      #reference-entry(index + 1, item)

      #if index < refs.len() - 1 [
        #v(6pt)
      ]
    ]
  ]
]
