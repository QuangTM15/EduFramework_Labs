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
// 8. TEST CONTENT
// ============================================================================

#pagebreak()

#counter(heading).update(0)

= Giới thiệu

Tài liệu Hướng dẫn Phát triển EduFramework cung cấp cấu trúc tài liệu cho quá trình thiết lập môi trường phát triển, tạo dự án, build, upload và debug ứng dụng trên vi điều khiển S32K144 với EduFramework.

Phần nội dung hiện tại chỉ được sử dụng để kiểm tra bố cục và các thành phần trình bày trước khi nội dung chính thức của tài liệu được xây dựng.

== Văn bản và mã nội tuyến

Một dự án EduFramework sử dụng file cấu hình `platformio.ini` và đặt mã nguồn ứng dụng chính trong `src/main.c`.

Tên framework `eduframework`, tên board `s32k144` và giao thức `jlink` có thể được thể hiện bằng kiểu mã nội tuyến để phân biệt với phần văn bản thông thường.

#note[
  Các thành phần trong phần kiểm tra này được sử dụng để đánh giá hình thức trình bày. Nội dung sẽ được thay thế bằng nội dung chính thức sau khi hệ thống tài liệu được xác nhận.
]

#warning[
  Các thao tác liên quan đến kết nối phần cứng, nạp chương trình và debug cần được kiểm tra trên hệ thống thực tế trước khi đưa vào hướng dẫn chính thức.
]

= Thành phần hệ sinh thái

Bảng dưới đây được sử dụng để kiểm tra component bảng của Development Guide.

#guide-table(
  columns: (1.35fr, 2.65fr),

  headers: (
    [Thành phần],
    [Vai trò],
  ),

  rows: (
    (
      [EduFramework],
      [Cung cấp các API và thư viện phục vụ phát triển ứng dụng trên S32K144.],
    ),

    (
      [Platform-NXPS32K],
      [Cung cấp phần tích hợp cần thiết để sử dụng S32K144 trong môi trường PlatformIO.],
    ),

    (
      [EduFramework Laboratory Series],
      [Cung cấp hệ thống bài thực hành và các project ví dụ sử dụng EduFramework.],
    ),
  ),

  caption: [Các thành phần chính của hệ sinh thái EduFramework],
)

== Kiểm tra danh sách

Các nội dung hướng dẫn có thể sử dụng danh sách khi cần mô tả một tập hợp thành phần:

- Môi trường phát triển.
- Project configuration.
- Application source code.
- Build và upload.
- Debug.

Danh sách đánh số cũng có thể được sử dụng khi thứ tự thực hiện có ý nghĩa:

+ Chuẩn bị môi trường phát triển.
+ Tạo project.
+ Viết mã nguồn.
+ Build chương trình.
+ Upload firmware.

= Hình minh họa

Development Guide sẽ sử dụng hình ảnh khi cần minh họa giao diện, kết nối phần cứng hoặc quy trình thao tác.

#guide-figure(
  caption: [Ví dụ khu vực dành cho hình minh họa],
)[
  #rect(
    width: 72%,
    height: 48mm,
    fill: soft-gray,
    stroke: 0.6pt + border-gray,
  )[
    #align(center + horizon)[
      #text(
        font: "Calibri",
        size: 11pt,
        fill: text-gray,
      )[
        HÌNH MINH HỌA
      ]
    ]
  ]
]

== Hình thứ hai trong cùng section

#guide-figure(
  caption: [Kiểm tra thứ tự đánh số hình trong cùng một section],
)[
  #rect(
    width: 58%,
    height: 30mm,
    fill: soft-gray,
    stroke: 0.6pt + border-gray,
  )
]

= Project và cấu hình

== Cấu trúc project

Component `file-tree()` được sử dụng để thể hiện cấu trúc thư mục.

#file-tree(
  title: [Cấu trúc project EduFramework tối thiểu],
)[
  my_eduframework_project/
  ├── platformio.ini
  └── src/
  └── main.c
]

== File cấu hình

Component `config-block()` được sử dụng cho các file cấu hình như `platformio.ini`.

#config-block(
  filename: "platformio.ini",
)[
  [env:s32k144]
  platform = https://github.com/QuangTM15/platform-nxps32k.git
  board = s32k144
  framework = eduframework
  upload_protocol = jlink
  debug_tool = jlink
]

== Terminal command

Component `command-block()` được sử dụng cho những lệnh cần nhập trong terminal.

#command-block[
  git --version
]

#command-block(
  label: [PowerShell],
)[
  typst compile --root . documentation/vi/development_guide.typ docs/vi/development_guide.pdf
]

= Mã nguồn

Mã nguồn ứng dụng có thể được trình bày dưới dạng listing và đánh số theo section.

#guide-code(
  caption: [Cấu trúc chương trình EduFramework tối thiểu],
)[
  ```c
  #include "Arduino.h"

  int main(void)
  {
      setup();

      while (1)
      {
      }

      return 0;
  }
  ```
]

== Mã nguồn thứ hai

#guide-code(
  caption: [Ví dụ kiểm tra thứ tự mã nguồn],
)[
  ```c
  digitalWrite(LED_BUILTIN, LOW);
  delay(500);
  digitalWrite(LED_BUILTIN, HIGH);
  delay(500);
  ```
]

= Các bước thao tác

Component `procedure()` hiện có trong Laboratory Series không phụ thuộc bộ đếm của bài lab nên có thể được sử dụng lại trong Development Guide.

#procedure(
  steps: (
    (
      [Mở project],
      [
        Mở thư mục project trong Visual Studio Code và xác nhận rằng file
        `platformio.ini` nằm ở thư mục gốc của project.
      ],
    ),

    (
      [Kiểm tra cấu hình],
      [
        Kiểm tra tên board, framework và công cụ upload được khai báo trong
        `platformio.ini`.
      ],
    ),

    (
      [Build project],
      [
        Thực hiện build để kiểm tra cấu hình project và mã nguồn trước khi
        upload firmware lên phần cứng.
      ],
    ),
  ),
)

#expected-result[
  Sau khi hoàn thành các bước kiểm tra, project có cấu trúc hợp lệ và có thể được sử dụng làm cơ sở cho quá trình build, upload và debug.
]

= Kiểm tra trích dẫn

Development Guide có thể tái sử dụng hệ thống trích dẫn và tài liệu tham khảo hiện có.

PlatformIO cung cấp hệ thống tài liệu riêng cho việc cấu hình project và sử dụng PlatformIO Core #cite-ref(refs, "platformio-docs").

EduFramework được phát triển trong repository riêng của dự án #cite-ref(refs, "eduframework").

Có thể trích dẫn nhiều nguồn đồng thời bằng cùng hệ thống #cite-refs(refs, ("platformio-docs", "eduframework")).

= Tài liệu tham khảo

#references(refs)
