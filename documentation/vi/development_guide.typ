// ============================================================================
// EduFramework
// Development Guide
// ============================================================================
//
// Responsibilities:
//   - Development Guide cover page
//   - Table of contents
//   - Running header and footer
//   - Decimal page numbering
//   - Guide-specific object numbering
//   - Guide-specific documentation components
//
// Object numbering:
//   Table   -> Section.Sequence
//   Figure  -> Section.Sequence
//   Listing -> Section.Sequence
//
// Example:
//   Bảng 3.1.
//   Hình 4.1.
//   Mã nguồn 5.1.
//
// ============================================================================


// ============================================================================
// 1. IMPORTS
// ============================================================================

#import "../template/theme.typ": (
  border-gray, code-label-gray, document-language, fpt-orange, line-gray, soft-gray, table-header-gray, table-line,
  text-black, text-gray,
)

#import "../template/components.typ": cite-ref, cite-refs, expected-result, note, procedure, references, warning


// ============================================================================
// 2. DOCUMENT CONFIGURATION
// ============================================================================

#document-language.update("vi")

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
            EDUFRAMEWORK DEVELOPMENT GUIDE
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
            EduFramework Development Guide
          ]
        ],

        [
          #text(
            font: "Calibri",
            size: 7.5pt,
            weight: "bold",
            fill: text-black,
          )[
            Trang #counter(page).display("1")
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


// ============================================================================
// 3. TYPOGRAPHY
// ============================================================================

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

#set heading(
  numbering: "1.1.1",
)

#show heading.where(level: 1): it => block(
  above: 22pt,
  below: 12pt,
  breakable: false,
)[
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

#show table: it => block(
  above: 8pt,
  below: 8pt,
)[
  #it
]

#show strong: set text(weight: "bold")
#show emph: set text(style: "italic")


// ============================================================================
// 4. DEVELOPMENT GUIDE COMPONENTS
// ============================================================================


// ============================================================================
// 4.1 OBJECT CAPTION
// ============================================================================

#let guide-object-caption(
  kind,
  caption,
) = context [
  #let heading-state = counter(heading).get()

  #let section-number = if heading-state.len() > 0 {
    heading-state.at(0)
  } else {
    0
  }

  #let counter-key = "eduf-guide-" + kind + "-" + str(section-number)

  #let prefix = if kind == "table" {
    "Bảng"
  } else if kind == "figure" {
    "Hình"
  } else {
    "Mã nguồn"
  }

  #counter(counter-key).step()

  #let object-state = counter(counter-key).get()

  #let object-number = if object-state.len() > 0 {
    object-state.at(0) + 1
  } else {
    1
  }

  #align(center)[
    #text(
      font: "Calibri",
      size: 9pt,
      style: "italic",
      fill: text-gray,
    )[
      #prefix #section-number.#object-number. #caption
    ]
  ]
]


// ============================================================================
// 4.2 INFORMATION TABLE
// ============================================================================

#let guide-table(
  columns: (),
  headers: (),
  rows: (),
  caption: none,
  alignments: left + horizon,
) = context [

  #if headers.len() == 0 {
    panic("guide-table() requires at least one header.")
  }

  #if columns.len() != headers.len() {
    panic(
      "guide-table(): number of columns must match number of headers.",
    )
  }

  #for row in rows {
    if row.len() != headers.len() {
      panic(
        "guide-table(): every row must contain the same number of cells as the header.",
      )
    }
  }

  #block(
    width: 100%,
    above: 9pt,
    below: 14pt,
    breakable: false,
  )[
    #table(
      columns: columns,
      align: alignments,
      stroke: 0.4pt + table-line,

      table.header(
        repeat: true,

        ..headers.map(header => table.cell(
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
            size: 9.2pt,
            weight: "bold",
          )[
            #header
          ]
        ]),
      ),

      ..rows
        .map(row => (
          ..row.map(cell => table.cell(
            inset: 7pt,
          )[
            #set text(
              font: "Calibri",
              size: 9.3pt,
              fill: text-black,
            )

            #set par(
              justify: true,
              leading: 0.76em,
            )

            #cell
          ]),
        ))
        .flatten(),
    )

    #if caption != none [
      #v(6pt)

      #guide-object-caption(
        "table",
        caption,
      )
    ]
  ]
]


// ============================================================================
// 4.3 FIGURE BLOCK
// ============================================================================

#let guide-figure(
  body,
  caption: none,
) = block(
  width: 100%,
  above: 10pt,
  below: 14pt,
  breakable: false,
)[
  #align(center)[
    #body
  ]

  #if caption != none [
    #v(6pt)

    #guide-object-caption(
      "figure",
      caption,
    )
  ]
]


// ============================================================================
// 4.4 CODE LISTING
// ============================================================================

#let guide-code(
  body,
  caption: none,
) = block(
  width: 100%,
  above: 9pt,
  below: 14pt,
  breakable: false,
)[
  #body

  #if caption != none [
    #v(6pt)

    #guide-object-caption(
      "listing",
      caption,
    )
  ]
]


// ============================================================================
// 4.5 COMMAND BLOCK
// ============================================================================

#let command-block(
  body,
  label: [Terminal],
) = block(
  width: 100%,
  above: 9pt,
  below: 12pt,
  breakable: false,
)[
  #block(
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
      top: 8pt,
      bottom: 9pt,
    ),
  )[
    #text(
      font: "Calibri",
      size: 8pt,
      weight: "bold",
      fill: text-gray,
    )[
      #label
    ]

    #v(6pt)

    #text(
      font: "Consolas",
      size: 8.8pt,
      fill: text-black,
    )[
      #body
    ]
  ]
]


// ============================================================================
// 4.6 CONFIGURATION BLOCK
// ============================================================================

#let config-block(
  body,
  filename: "",
) = block(
  width: 100%,
  above: 9pt,
  below: 12pt,
  breakable: false,
)[
  #block(
    width: 100%,
    stroke: 0.45pt + border-gray,
    inset: 0pt,
  )[
    #block(
      width: 100%,
      fill: table-header-gray,

      inset: (
        left: 10pt,
        right: 10pt,
        top: 5pt,
        bottom: 5pt,
      ),
    )[
      #text(
        font: "Consolas",
        size: 8.4pt,
        weight: "bold",
        fill: text-black,
      )[
        #filename
      ]
    ]

    #block(
      width: 100%,
      fill: soft-gray,

      inset: (
        left: 11pt,
        right: 10pt,
        top: 9pt,
        bottom: 9pt,
      ),
    )[
      #text(
        font: "Consolas",
        size: 8.8pt,
        fill: text-black,
      )[
        #body
      ]
    ]
  ]
]


// ============================================================================
// 4.7 FILE TREE
// ============================================================================

#let file-tree(
  body,
  title: none,
) = block(
  width: 100%,
  above: 9pt,
  below: 12pt,
  breakable: false,
)[
  #block(
    width: 100%,
    fill: soft-gray,
    stroke: 0.45pt + border-gray,

    inset: (
      left: 12pt,
      right: 10pt,
      top: 9pt,
      bottom: 9pt,
    ),
  )[
    #if title != none [
      #text(
        font: "Calibri",
        size: 8.5pt,
        weight: "bold",
        fill: text-gray,
      )[
        #title
      ]

      #v(7pt)
    ]

    #text(
      font: "Consolas",
      size: 8.8pt,
      fill: text-black,
    )[
      #body
    ]
  ]
]

// ============================================================================
// 4.8 REPOSITORY LINK
// ============================================================================

#let repo-link(
  name,
  url,
) = block(
  width: 100%,
  above: 7pt,
  below: 3pt,
  breakable: false,
)[
  #rect(
    width: 100%,
    fill: soft-gray,
    stroke: (
      left: 2pt + fpt-orange,
      top: 0.4pt + border-gray,
      right: 0.4pt + border-gray,
      bottom: 0.4pt + border-gray,
    ),
    inset: (
      left: 10pt,
      right: 10pt,
      top: 6pt,
      bottom: 6pt,
    ),
  )[
    #text(
      font: "Calibri",
      size: 8.5pt,
      weight: "bold",
      fill: text-gray,
    )[
      GitHub Repository
    ]

    #h(10pt)

    #link(url)[
      #text(
        font: "Consolas",
        size: 8.8pt,
        weight: "bold",
        fill: fpt-orange,
      )[
        #name
      ]
    ]
  ]
]


// ============================================================================
// 5. REFERENCES USED BY TEST CONTENT
// ============================================================================

#let refs = (
  (
    key: "platformio-docs",
    type: "web",
    author: [PlatformIO],
    title: [PlatformIO Documentation],
    url: "https://docs.platformio.org/",
  ),

  (
    key: "eduframework",
    type: "web",
    author: [EduFramework Project],
    title: [EduFramework for NXP S32K144],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
)


// ============================================================================
// 6. COVER PAGE
// ============================================================================

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
        fill: text-black,
      )[
        EDUFRAMEWORK
      ]
    ],

    [
      #text(
        font: "Calibri",
        size: 9pt,
        fill: text-gray,
      )[
        S32K144 · MaaZEDU
      ]
    ],
  )

  #v(7pt)

  #line(
    length: 100%,
    stroke: 0.5pt + line-gray,
  )

  #v(3.0cm)

  #align(center)[
    #text(
      font: "Calibri",
      size: 12pt,
      weight: "bold",
      tracking: 1.5pt,
      fill: text-gray,
    )[
      TÀI LIỆU EDUFRAMEWORK
    ]
  ]

  #v(20pt)

  #align(center)[
    #block(width: 95%)[
      #align(center)[
        #text(
          font: "Calibri",
          size: 34pt,
          weight: "bold",
          fill: text-black,
        )[
          HƯỚNG DẪN PHÁT TRIỂN
        ]
      ]
    ]
  ]

  #v(18pt)

  #align(center)[
    #block(width: 86%)[
      #align(center)[
        #text(
          font: "Calibri",
          size: 15pt,
          fill: text-gray,
        )[
          Thiết lập môi trường phát triển và tạo dự án EduFramework
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
      PlatformIO · S32K144 · MaaZEDU
    ]
  ]

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
      FPT University
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


// ============================================================================
// 7. CONTENTS
// ============================================================================

#pagebreak()

#counter(page).update(1)
#counter(heading).update(0)

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
    Mục lục
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

// ============================================================================
// 8. DOCUMENT CONTENT
// ============================================================================

#pagebreak()

#counter(heading).update(0)

= Giới thiệu

EduFramework là một hệ sinh thái phát triển phần mềm dành cho vi điều khiển NXP S32K144, được xây dựng nhằm đơn giản hóa quá trình phát triển ứng dụng thông qua các API ở mức cao hơn và khả năng tích hợp với PlatformIO. Hệ thống hình thành một quy trình thống nhất từ tổ chức project và phát triển mã nguồn đến build, nạp chương trình và debug trên phần cứng.

Tài liệu này hướng dẫn từng bước quá trình thiết lập môi trường phát triển và tạo một project EduFramework trên bo mạch MaaZEDU. Sau khi hoàn thành các bước thiết lập, môi trường có thể được sử dụng để tiếp tục với EduFramework Laboratory Series hoặc phát triển các ứng dụng riêng trên S32K144.

Hệ sinh thái EduFramework được tổ chức thành ba thành phần chính: *EduFramework*, *Platform-NXPS32K* và *EduFramework Laboratory Series*. Mỗi thành phần đảm nhiệm một vai trò riêng trong quy trình phát triển.

#guide-table(
  columns: (1.35fr, 2.65fr),

  headers: (
    [Thành phần],
    [Vai trò],
  ),

  rows: (
    (
      [EduFramework],
      [Lớp phần mềm dành cho phát triển ứng dụng, bao gồm các API theo phong cách Arduino, định nghĩa chân logic và thư viện thiết bị cho S32K144.],
    ),
    (
      [Platform-NXPS32K],
      [Tích hợp S32K144 và EduFramework vào PlatformIO, hỗ trợ cấu hình project, build, upload và debug.],
    ),
    (
      [EduFramework Laboratory Series],
      [Hệ thống bài thực hành, project mẫu và tài liệu hướng dẫn khai thác EduFramework theo từng chủ đề.],
    ),
  ),

  caption: [Các thành phần chính của hệ sinh thái EduFramework],
)

EduFramework là thành phần phần mềm được ứng dụng sử dụng trực tiếp. Các API theo phong cách Arduino đơn giản hóa những thao tác phổ biến trên vi điều khiển, trong khi các thư viện thiết bị hỗ trợ làm việc với các module và cảm biến bên ngoài. Repository của framework cũng chứa mã nguồn các driver tầng thấp và những thành phần cần thiết cho việc nghiên cứu hoặc tiếp tục phát triển framework.

#repo-link(
  "EduFramework Project",
  "https://github.com/QuangTM15/s32k144-edu-framework",
)

#v(5pt)

Platform-NXPS32K đảm nhiệm việc tích hợp S32K144 với hệ sinh thái PlatformIO. Platform xác định board, framework, toolchain và các công cụ liên quan để PlatformIO có thể thực hiện quy trình build, upload và debug cho project EduFramework. Các định nghĩa và cấu hình của platform có thể được tham khảo trực tiếp trong repository của dự án.

#repo-link(
  "Platform-NXPS32K",
  "https://github.com/QuangTM15/platform-nxps32k",
)

#v(5pt)

EduFramework Laboratory Series xây dựng các bài thực hành theo từng chủ đề dựa trên EduFramework và Platform-NXPS32K. Các bài lab được thiết kế để từng bước làm quen với API của framework và áp dụng chúng vào phần cứng, từ đó tạo nền tảng cho việc phát triển các ứng dụng riêng trên S32K144. Repository của Laboratory Series lưu trữ các project thực hành, tài liệu hoàn chỉnh và mã nguồn dùng để phát triển tài liệu.

#repo-link(
  "EduFramework Labs and Documentation",
  "https://github.com/QuangTM15/EduFramework_Labs",
)
