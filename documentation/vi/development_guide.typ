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
  command,
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
      #command
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
// 4.9 RESOURCE LINK
// ============================================================================

#let resource-link(
  label,
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
      #label
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

= Thiết lập môi trường phát triển

Trước khi tạo project EduFramework, cần chuẩn bị các công cụ phát triển trên máy tính. Môi trường được sử dụng trong tài liệu gồm Visual Studio Code, Git và PlatformIO IDE. Phần này hướng dẫn cài đặt và kiểm tra từng thành phần trước khi bắt đầu tạo project.

== Cài đặt Visual Studio Code

Visual Studio Code (VS Code) được sử dụng làm trình soạn thảo mã nguồn và là môi trường để tích hợp PlatformIO trong quá trình phát triển với EduFramework.

Truy cập trang chính thức của Visual Studio Code:

#resource-link(
  [Trang chính thức],
  "Visual Studio Code",
  "https://code.visualstudio.com/",
)

Tải phiên bản Visual Studio Code phù hợp với hệ điều hành đang sử dụng và thực hiện cài đặt theo hướng dẫn trên trang chính thức. Sau khi hoàn tất, khởi động Visual Studio Code để xác nhận ứng dụng hoạt động bình thường.

#note[
  Giao diện và quá trình cài đặt Visual Studio Code có thể khác nhau tùy theo hệ điều hành và phiên bản phần mềm. Development Guide không yêu cầu thay đổi cấu hình cài đặt đặc biệt của Visual Studio Code.
]


== Cài đặt và cấu hình Git

Git được sử dụng để quản lý mã nguồn và cho phép PlatformIO truy cập các thành phần của EduFramework được lưu trữ trên GitHub. Ngoài việc cài đặt Git, cần thiết lập thông tin người dùng để Git có thể ghi nhận tác giả của các commit được tạo trên máy tính.

=== Tải và cài đặt Git

Truy cập trang cài đặt chính thức của Git:

#resource-link(
  [Trang cài đặt],
  "Git - Install",
  "https://git-scm.com/install/",
)

Tại trang cài đặt, chọn phiên bản Git phù hợp với hệ điều hành đang sử dụng.

#guide-figure(
  caption: [Trang cài đặt chính thức của Git],
)[
  #image(
    "../assets/images/git_download_page.png",
    width: 92%,
  )
]

Sau khi lựa chọn hệ điều hành, tải bộ cài phù hợp với hệ thống. Hình dưới đây minh họa quá trình lựa chọn bộ cài Git trên Windows x64.

#guide-figure(
  caption: [Ví dụ lựa chọn bộ cài Git trên Windows],
)[
  #image(
    "../assets/images/git_download_version.png",
    width: 82%,
  )
]

Thực hiện cài đặt Git bằng bộ cài vừa tải xuống. Các tùy chọn mặc định của trình cài đặt có thể được giữ nguyên nếu không có yêu cầu cấu hình riêng.

Đối với Git for Windows, khi trình cài đặt yêu cầu lựa chọn trình soạn thảo mặc định của Git, chọn *Visual Studio Code* để sử dụng VS Code cho các thao tác Git cần mở trình soạn thảo.

#guide-figure(
  caption: [Lựa chọn Visual Studio Code làm trình soạn thảo mặc định của Git],
)[
  #image(
    "../assets/images/git_default_editor.png",
    width: 72%,
  )
]

Tiếp tục quá trình cài đặt với các tùy chọn mặc định cho đến khi hoàn tất.

=== Kiểm tra cài đặt Git

Sau khi cài đặt, mở terminal và thực hiện lệnh:

#command-block("git --version")

Nếu Git đã được cài đặt và có thể được truy cập từ terminal, kết quả sẽ hiển thị phiên bản Git hiện có trên hệ thống.

#guide-figure(
  caption: [Kiểm tra phiên bản Git sau khi cài đặt],
)[
  #image(
    "../assets/images/git_version.png",
    width: 70%,
  )
]

#note[
  Số phiên bản hiển thị có thể khác với hình minh họa. Chỉ cần lệnh `git --version` trả về thông tin phiên bản hợp lệ là quá trình cài đặt Git đã thành công.
]

=== Cấu hình thông tin người dùng Git

Git sử dụng `user.name` và `user.email` để xác định thông tin tác giả được ghi trong mỗi commit. Nếu sử dụng GitHub để lưu trữ repository, nên sử dụng địa chỉ email đã được liên kết với tài khoản GitHub để các commit có thể được nhận diện đúng với tài khoản tương ứng.

Nếu chưa có tài khoản GitHub, có thể tạo tài khoản tại trang chính thức:

#repo-link(
  "GitHub",
  "https://github.com/",
)

Thông tin tài khoản và địa chỉ email có thể được kiểm tra trong GitHub trước khi cấu hình Git. Hình dưới đây minh họa vị trí thông tin tài khoản trên GitHub.

#guide-figure(
  caption: [Ví dụ thông tin tài khoản và địa chỉ email trên GitHub],
)[
  #image(
    "../assets/images/git_profile.png",
    width: 92%,
  )
]

Mở terminal và thiết lập tên được sử dụng cho các commit bằng lệnh:

#command-block(
  "git config --global user.name \"Your Name\"",
)

Tiếp theo, thiết lập địa chỉ email:

#command-block(
  "git config --global user.email \"your-email@example.com\"",
)

Trong đó, `Your Name` là tên được ghi nhận trong commit và `your-email@example.com` là địa chỉ email của người dùng. Giá trị `user.name` không bắt buộc phải giống tên tài khoản GitHub.

Tùy chọn `--global` áp dụng các giá trị trên cho các repository Git của tài khoản người dùng hiện tại trên máy tính.

Sau khi cấu hình, kiểm tra lại thiết lập bằng lệnh:

#command-block(
  "git config --global --list",
)

Kết quả phải chứa các thông tin `user.name` và `user.email` đã thiết lập.

#config-block(
  filename: [Git global configuration],
)[
  user.name=Your Name
  user.email=your-email\@example.com
]

Hình dưới đây minh họa kết quả sau khi Git đã được cấu hình thành công.

#guide-figure(
  caption: [Kiểm tra cấu hình người dùng Git],
)[
  #image(
    "../assets/images/git_global_list.png",
    width: 78%,
  )
]

#expected-result[
  Git đã được cài đặt và cấu hình thành công. Lệnh `git --version` có thể được thực thi từ terminal, đồng thời kết quả của `git config --global --list` chứa `user.name` và `user.email` của người dùng.
]

== Cài đặt PlatformIO IDE

PlatformIO IDE được tích hợp vào Visual Studio Code thông qua extension chính thức của PlatformIO. Extension này cung cấp môi trường phát triển cho các project embedded và sẽ được sử dụng để build, upload và debug các project EduFramework.

Mở Visual Studio Code, chọn *Extensions* trên Activity Bar và tìm kiếm `PlatformIO IDE`. Chọn extension *PlatformIO IDE* do *PlatformIO* phát hành, sau đó chọn *Install* để bắt đầu cài đặt.

#guide-figure(
  caption: [Cài đặt PlatformIO IDE từ Visual Studio Code Extensions Marketplace],
)[
  #image(
    "../assets/images/platformio_install_extension.png",
    width: 94%,
  )
]

Sau khi cài đặt extension, PlatformIO sẽ thực hiện quá trình khởi tạo các thành phần cần thiết. Quá trình này có thể mất một khoảng thời gian trong lần khởi động đầu tiên.

#note[
  Trong lần khởi động đầu tiên, cần chờ PlatformIO hoàn tất quá trình khởi tạo trước khi tiếp tục. Thời gian thực hiện có thể khác nhau tùy thuộc vào hệ thống và kết nối mạng.
]

Sau khi quá trình khởi tạo hoàn tất, chọn biểu tượng *PlatformIO* trên Activity Bar, sau đó chọn *PIO Home → Open* để mở PlatformIO Home.

#guide-figure(
  caption: [Giao diện PlatformIO Home sau khi cài đặt thành công],
)[
  #image(
    "../assets/images/platformio_home.png",
    width: 94%,
  )
]

#expected-result[
  PlatformIO IDE đã được cài đặt và khởi tạo thành công. PlatformIO Home có thể được mở trực tiếp từ Visual Studio Code.
]

= Tạo project EduFramework đầu tiên

Phần này hướng dẫn tạo một project EduFramework tối thiểu trên S32K144, cấu hình project với PlatformIO, viết chương trình đầu tiên và nạp chương trình lên bo mạch MaaZEDU.

== Tạo cấu trúc project

Trong Visual Studio Code, chọn *File → Open Folder...*. Tạo một thư mục mới cho project, ví dụ `EduFramework_First_Project`, sau đó mở thư mục vừa tạo trong Visual Studio Code.

Trong Explorer của Visual Studio Code, tạo thư mục `src`, sau đó tạo file `main.c` bên trong thư mục này. Tại thư mục gốc của project, tạo thêm file `platformio.ini`.

Cấu trúc project ban đầu như sau:

#file-tree(
  title: [Cấu trúc project EduFramework],
)[
  #text[
    EduFramework_First_Project/ \
    ├── platformio.ini \
    └── src/ \
    #h(1.5em)└── main.c
  ]
]

#guide-figure(
  caption: [Cấu trúc ban đầu của project EduFramework],
)[
  #image(
    "../assets/images/project_structure.png",
    width: 92%,
  )
]


== Mở project bằng PlatformIO

Sau khi tạo cấu trúc project, mở PlatformIO Home bằng biểu tượng PlatformIO trên Activity Bar. Chọn *PIO Home → Open → Open Project* để mở project.

#guide-figure(
  caption: [Mở project từ PlatformIO Home],
)[
  #image(
    "../assets/images/platformio_open_project.png",
    width: 94%,
  )
]

Chọn thư mục project vừa tạo. Thư mục được chọn phải chứa file `platformio.ini` và thư mục `src`.

#guide-figure(
  caption: [Lựa chọn thư mục project EduFramework],
)[
  #image(
    "../assets/images/platformio_select_project_folder.png",
    width: 72%,
  )
]


== Cấu hình project

Mở file `platformio.ini` và khai báo environment cho S32K144 như sau:

#guide-code(
  caption: [Cấu hình PlatformIO cho project EduFramework],
)[
  #raw(
    block: true,
    lang: "ini",
    "[env:s32k144]\nplatform = https://github.com/QuangTM15/platform-nxps32k.git\nboard = s32k144\nframework = eduframework\nupload_protocol = jlink\ndebug_tool = jlink",
  )
]

Trong cấu hình trên, `platform` xác định Platform-NXPS32K được sử dụng bởi project, `board` xác định bo mạch đích, `framework` lựa chọn EduFramework, trong khi `upload_protocol` và `debug_tool` cấu hình J-Link cho quá trình nạp chương trình và debug.

Sau khi lưu `platformio.ini`, PlatformIO sẽ nhận diện cấu hình project và chuẩn bị môi trường phát triển. Trong lần sử dụng đầu tiên, quá trình này có thể mất một khoảng thời gian do PlatformIO cần tải và cài đặt các thành phần cần thiết.

Các thư mục và file do PlatformIO quản lý, chẳng hạn `.pio` và `.vscode`, có thể xuất hiện trong project sau khi quá trình khởi tạo hoàn tất.

#guide-figure(
  caption: [Project EduFramework sau khi được PlatformIO khởi tạo],
)[
  #image(
    "../assets/images/platformio_project_initialized.png",
    width: 92%,
  )
]

#note[
  Không cần chỉnh sửa thủ công các file bên trong thư mục `.pio`. Nội dung trong thư mục này được PlatformIO quản lý và có thể được tạo lại trong quá trình build project.
]


== Viết chương trình đầu tiên

Mở file `src/main.c` và nhập chương trình sau:

#guide-code(
  caption: [Chương trình Blink LED đầu tiên với EduFramework],
)[
  #raw(
    block: true,
    lang: "c",
    "#include \"Arduino.h\"\n\nvolatile int counter = 0;\n\nint main(void)\n{\n    setup();\n\n    pinMode(LED_RED, OUTPUT);\n\n    while (1)\n    {\n        digitalWrite(LED_RED, LOW);\n        delay(500U);\n\n        digitalWrite(LED_RED, HIGH);\n        delay(500U);\n\n        counter++;\n    }\n\n    return 0;\n}",
  )
]

Hàm `setup()` phải được gọi trước khi sử dụng các API của EduFramework. Hàm này thực hiện quá trình khởi tạo tối thiểu các thành phần phần cứng và tài nguyên cần thiết để framework có thể hoạt động trước khi chương trình ứng dụng tiếp tục thực thi.

#warning[
  Khi phát triển ứng dụng với EduFramework,bắt buộc phải gọi`setup()`và phải gọi`setup()`trước khi sử dụng bất kỳ API nào của framework. Việc bỏ qua bước khởi tạo này có thể dẫn đến treo hệ thống hoặc các hành vi không mong muốn trong quá trình thực thi chương trình.
]

== Build project

Trước khi build, lưu toàn bộ các file đã chỉnh sửa.

Chọn biểu tượng *Build* trên thanh công cụ PlatformIO ở phía dưới Visual Studio Code để bắt đầu biên dịch project.

Khi quá trình build hoàn tất thành công, terminal sẽ hiển thị trạng thái `SUCCESS`.

#guide-figure(
  caption: [Kết quả build project EduFramework thành công],
)[
  #image(
    "../assets/images/platformio_build_success.png",
    width: 94%,
  )
]


== Nạp chương trình lên bo mạch

Kết nối bo mạch MaaZEDU với máy tính bằng cổng USB được sử dụng cho quá trình nạp chương trình và debug.

Sau khi bo mạch đã được kết nối, chọn biểu tượng *Upload* trên thanh công cụ PlatformIO để nạp chương trình lên S32K144.

PlatformIO sử dụng cấu hình `upload_protocol = jlink` trong `platformio.ini` để thực hiện quá trình nạp chương trình. Khi quá trình hoàn tất thành công, terminal sẽ hiển thị trạng thái `SUCCESS`.

#guide-figure(
  caption: [Kết quả upload chương trình lên S32K144 thành công],
)[
  #image(
    "../assets/images/platformio_upload_success.png",
    width: 94%,
  )
]

= Debugging

PlatformIO tích hợp debugger trực tiếp trong Visual Studio Code, cho phép tạm dừng chương trình, thực thi từng bước và theo dõi giá trị của các biến trong quá trình chạy. Phần này sử dụng project đã tạo ở phần trước để thực hiện một phiên debug cơ bản trên S32K144.

== Bắt đầu phiên debug

Đảm bảo bo mạch MaaZEDU vẫn được kết nối với máy tính qua cổng USB dùng cho nạp chương trình và debug.

Trong Visual Studio Code, chọn biểu tượng PlatformIO trên Activity Bar. Trong mục *Debug*, chọn *Start Debugging* để bắt đầu phiên debug.

#guide-figure(
  caption: [Bắt đầu phiên debug từ PlatformIO],
)[
  #image(
    "../assets/images/debug_start_session.png",
    width: 92%,
  )
]

PlatformIO sẽ chuẩn bị chương trình, kết nối với debugger và khởi động phiên debug. Sau khi quá trình hoàn tất, Visual Studio Code chuyển sang giao diện *Run and Debug*.

Trong cấu hình hiện tại, chương trình có thể tạm dừng tại đầu hàm `main()` khi phiên debug bắt đầu. Từ thời điểm này, có thể sử dụng các công cụ debug để điều khiển quá trình thực thi chương trình.


== Thanh điều khiển và breakpoint

Khi phiên debug đang hoạt động, thanh điều khiển debug xuất hiện ở phía trên cửa sổ Visual Studio Code.

#guide-figure(
  caption: [Giao diện debug, thanh điều khiển và breakpoint],
)[
  #image(
    "../assets/images/debug_toolbar_breakpoint.png",
    width: 94%,
  )
]

Các nút trên thanh điều khiển được sắp xếp từ trái sang phải như sau:

#guide-table(
  columns: (1.3fr, 1.1fr, 2.6fr),

  headers: (
    [Công cụ],
    [Phím tắt],
    [Chức năng],
  ),

  rows: (
    (
      [Continue],
      [`F5`],
      [Tiếp tục chạy chương trình cho đến khi gặp breakpoint tiếp theo hoặc một điều kiện làm chương trình dừng lại.],
    ),
    (
      [Step Over],
      [`F10`],
      [Thực thi dòng hiện tại và chuyển sang dòng tiếp theo mà không đi vào bên trong hàm được gọi tại dòng đó.],
    ),
    (
      [Step Into],
      [`F11`],
      [Đi vào bên trong hàm được gọi tại dòng hiện tại để tiếp tục debug từng lệnh bên trong hàm.],
    ),
    (
      [Step Out],
      [`Shift + F11`],
      [Tiếp tục chạy cho đến khi thoát khỏi hàm hiện tại và quay lại hàm gọi.],
    ),
    (
      [Restart],
      [`Ctrl + Shift + F5`],
      [Khởi động lại phiên debug từ đầu.],
    ),
    (
      [Stop],
      [`Shift + F5`],
      [Kết thúc phiên debug hiện tại.],
    ),
  ),

  caption: [Các công cụ điều khiển debug cơ bản],
)

Breakpoint là một điểm dừng được đặt tại một dòng mã nguồn. Khi chương trình chạy tới dòng có breakpoint, debugger sẽ tạm dừng quá trình thực thi để có thể quan sát biến và trạng thái chương trình.

Để đặt breakpoint, nhấp vào vùng lề bên trái số dòng cần dừng. Một dấu tròn màu đỏ xuất hiện tại dòng đó. Nhấp lại vào cùng vị trí để bỏ breakpoint.

Trong project hiện tại, đặt breakpoint tại dòng:

#guide-code(
  caption: [Dòng lệnh được sử dụng làm breakpoint],
)[
  #raw(
    block: true,
    lang: "c",
    "counter++;",
  )
]


== Theo dõi biến với Watch

Cửa sổ *Watch* cho phép theo dõi trực tiếp giá trị của một biến hoặc biểu thức trong quá trình debug.

Trong giao diện *Run and Debug*, mở mục *Watch*, chọn biểu tượng `+` và nhập:

#command-block("counter")

#guide-figure(
  caption: [Thêm biến counter vào cửa sổ Watch],
)[
  #image(
    "../assets/images/debug_add_watch.png",
    width: 55%,
  )
]

Sau khi được thêm vào Watch, giá trị của `counter` sẽ được cập nhật mỗi khi chương trình tạm dừng trong phiên debug.


== Tiếp tục chương trình và quan sát kết quả

Sau khi đặt breakpoint tại `counter++` và thêm biến `counter` vào Watch, chọn *Continue* (`F5`) để tiếp tục chạy chương trình.

Chương trình sẽ thực thi cho đến khi gặp breakpoint tại dòng `counter++`, sau đó debugger sẽ tạm dừng tại vị trí này. Giá trị hiện tại của `counter` có thể được quan sát trong cửa sổ Watch.

#guide-figure(
  caption: [Quan sát giá trị counter tại breakpoint],
)[
  #image(
    "../assets/images/debug_breakpoint_watch_result.png",
    width: 94%,
  )
]

Tiếp tục chọn *Continue* (`F5`) để chương trình chạy qua một chu kỳ tiếp theo. Khi breakpoint được kích hoạt lại, giá trị của `counter` thay đổi theo quá trình thực thi chương trình.

Các công cụ *Step Over*, *Step Into* và *Step Out* có thể được sử dụng khi cần quan sát chi tiết hơn luồng thực thi của chương trình tại vị trí đang dừng.

= Xử lý sự cố

Phần này sẽ được hoàn thiện sau quá trình kiểm thử toàn bộ quy trình thiết lập và phát triển EduFramework trên một môi trường máy tính mới. Các vấn đề thực tế liên quan đến cài đặt công cụ, khởi tạo PlatformIO, build, upload và debug sẽ được tổng hợp cùng với hướng xử lý tương ứng.


= Bước tiếp theo

Sau khi hoàn thành các bước trong tài liệu này, môi trường phát triển EduFramework đã sẵn sàng để xây dựng, nạp và debug các ứng dụng trên S32K144 thông qua PlatformIO.

EduFramework Laboratory Series tiếp tục giới thiệu các chức năng của framework thông qua hệ thống bài thực hành theo từng chủ đề. Các bài thực hành được xây dựng từ những chức năng cơ bản như Digital Output và Digital Input, sau đó mở rộng sang các ngoại vi và thiết bị được hỗ trợ bởi EduFramework.

Toàn bộ tài liệu thực hành, project mẫu và mã nguồn liên quan được duy trì tại:

#repo-link(
  "EduFramework Laboratory Series",
  "https://github.com/QuangTM15/EduFramework_Labs",
)

Các thành phần của EduFramework và Platform-NXPS32K có thể được tham khảo trực tiếp tại các repository tương ứng:

#repo-link(
  "EduFramework",
  "https://github.com/QuangTM15/s32k144-edu-framework",
)

#repo-link(
  "Platform-NXPS32K",
  "https://github.com/QuangTM15/platform-nxps32k",
)


= Tài liệu tham khảo

#references((
  (
    key: "git-docs",
    type: "web",
    author: [Git],
    title: [Git Documentation],
    url: "https://git-scm.com/doc",
  ),
  (
    key: "github-docs",
    type: "web",
    author: [GitHub],
    title: [GitHub Docs],
    url: "https://docs.github.com/",
  ),
  (
    key: "vscode-docs",
    type: "web",
    author: [Microsoft],
    title: [Visual Studio Code Documentation],
    url: "https://code.visualstudio.com/docs",
  ),
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
    author: [QuangTM15],
    title: [EduFramework for NXP S32K144],
    url: "https://github.com/QuangTM15/s32k144-edu-framework",
  ),
  (
    key: "platform-nxps32k",
    type: "web",
    author: [QuangTM15],
    title: [Platform-NXPS32K],
    url: "https://github.com/QuangTM15/platform-nxps32k",
  ),
  (
    key: "eduframework-labs",
    type: "web",
    author: [QuangTM15],
    title: [EduFramework Laboratory Series],
    url: "https://github.com/QuangTM15/EduFramework_Labs",
  ),
))
