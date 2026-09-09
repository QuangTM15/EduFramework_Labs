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
//   Table 3.1.
//   Figure 4.1.
//   Listing 5.1.
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
#document-language.update("en")

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
            Page #counter(page).display("1")
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
    "Table"
  } else if kind == "figure" {
    "Figure"
  } else {
    "Listing"
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
      EDUFRAMEWORK DOCUMENTATION
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
          DEVELOPMENT GUIDE
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
          Setting Up the Development Environment and Creating an EduFramework Project
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
    Contents
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

= Introduction

EduFramework is a software development ecosystem for the NXP S32K144 microcontroller, designed to simplify application development through higher-level APIs and PlatformIO integration. The ecosystem provides a unified workflow from project organization and source-code development to building, uploading, and hardware debugging.

This document provides step-by-step instructions for setting up the development environment and creating an EduFramework project for the MaaZEDU board. After completing the setup, the environment can be used to continue with the EduFramework Laboratory Series or to develop custom applications for the S32K144.

The EduFramework ecosystem is organized into three main components: *EduFramework*, *Platform-NXPS32K*, and *EduFramework Laboratory Series*. Each component has a distinct role in the development workflow.

#guide-table(
  columns: (1.35fr, 2.65fr),
  headers: (
    [Component],
    [Role],
  ),
  rows: (
    (
      [EduFramework],
      [Application-development software layer that includes Arduino-style APIs, logical pin definitions, and device libraries for the S32K144.],
    ),
    (
      [Platform-NXPS32K],
      [Integrates the S32K144 and EduFramework with PlatformIO, supporting project configuration, build, upload, and debugging.],
    ),
    (
      [EduFramework Laboratory Series],
      [A collection of laboratory exercises, example projects, and documentation for using EduFramework by topic.],
    ),
  ),
  caption: [Main components of the EduFramework ecosystem],
)

EduFramework is the software component used directly by applications. Its Arduino-style APIs simplify common microcontroller operations, while device libraries support external modules and sensors. The framework repository also contains low-level driver source code and other components required for studying or further developing the framework.

#repo-link(
  "EduFramework Project",
  "https://github.com/QuangTM15/s32k144-edu-framework",
)

#v(5pt)

Platform-NXPS32K integrates the S32K144 with the PlatformIO ecosystem. The platform defines the board, framework, toolchain, and related tools so that PlatformIO can build, upload, and debug EduFramework projects. Platform definitions and configuration can be referenced directly in the project repository.

#repo-link(
  "Platform-NXPS32K",
  "https://github.com/QuangTM15/platform-nxps32k",
)

#v(5pt)

The EduFramework Laboratory Series provides topic-based laboratory exercises built on EduFramework and Platform-NXPS32K. The laboratories are designed to introduce the framework APIs progressively and apply them to hardware, providing a foundation for developing custom S32K144 applications. The Laboratory Series repository contains laboratory projects, completed documents, and the source files used to develop the documentation.

#repo-link(
  "EduFramework Labs and Documentation",
  "https://github.com/QuangTM15/EduFramework_Labs",
)

= Setting Up the Development Environment

Before creating an EduFramework project, the required development tools must be prepared on the computer. The environment used in this guide consists of Visual Studio Code, Git, and PlatformIO IDE. This section explains how to install and verify each component before creating a project.

== Installing Visual Studio Code

Visual Studio Code (VS Code) is used as the source-code editor and as the environment that hosts PlatformIO for EduFramework development.

Open the official Visual Studio Code website:

#resource-link(
  [Official Website],
  "Visual Studio Code",
  "https://code.visualstudio.com/",
)

Download the Visual Studio Code version appropriate for the operating system and install it according to the instructions on the official website. After installation, launch Visual Studio Code to verify that the application starts correctly.

#note[
  The Visual Studio Code interface and installation process may vary depending on the operating system and software version. The Development Guide does not require any special Visual Studio Code installation options.
]

== Installing and Configuring Git

Git is used for source-code management and allows PlatformIO to access EduFramework components hosted on GitHub. In addition to installing Git, user information must be configured so that Git can record the author of commits created on the computer.

=== Downloading and Installing Git

Open the official Git installation page:

#resource-link(
  [Installation Page],
  "Git - Install",
  "https://git-scm.com/install/",
)

On the installation page, select the Git version appropriate for the operating system.

#guide-figure(
  caption: [Official Git installation page],
)[
  #image(
    "../assets/images/git_download_page.png",
    width: 92%,
  )
]

After selecting the operating system, download the installer appropriate for the system. The following figure illustrates selecting a Git installer for Windows x64.

#guide-figure(
  caption: [Example of selecting a Git installer on Windows],
)[
  #image(
    "../assets/images/git_download_version.png",
    width: 82%,
  )
]

Install Git using the downloaded installer. The installer default options can be retained unless a specific configuration is required.

For Git for Windows, when the installer asks for the default Git editor, select *Visual Studio Code* so that VS Code is used for Git operations that require an editor.

#guide-figure(
  caption: [Selecting Visual Studio Code as the default Git editor],
)[
  #image(
    "../assets/images/git_default_editor.png",
    width: 72%,
  )
]

Continue the installation using the default options until it is complete.

=== Verifying the Git Installation

After installation, open a terminal and run:

#command-block("git --version")

If Git is installed and accessible from the terminal, the output will display the Git version available on the system.

#guide-figure(
  caption: [Verifying the Git version after installation],
)[
  #image(
    "../assets/images/git_version.png",
    width: 70%,
  )
]

#note[
  The displayed version number may differ from the figure. The Git installation is successful as long as the `git --version` command returns valid version information.
]

=== Configuring Git User Information

Git uses `user.name` and `user.email` to identify the author recorded in each commit. When using GitHub to host repositories, it is recommended to use an email address associated with the GitHub account so that commits can be attributed to the corresponding account.

If a GitHub account is not available, one can be created on the official website:

#resource-link(
  [Official Website],
  "GitHub",
  "https://github.com/",
)

Account information and email addresses can be checked on GitHub before configuring Git. The following figure illustrates where the account information can be found on GitHub.

#guide-figure(
  caption: [Example of GitHub account and email information],
)[
  #image(
    "../assets/images/git_profile.png",
    width: 92%,
  )
]

Open a terminal and configure the name used for commits with:

#command-block(
  "git config --global user.name \"Your Name\"",
)

Next, configure the email address:

#command-block(
  "git config --global user.email \"your-email@example.com\"",
)

Here, `Your Name` is the name recorded in commits and `your-email\@example.com` is the user email address. The `user.name` value does not have to match the GitHub username.

The `--global` option applies these values to Git repositories for the current user account on the computer.

After configuration, verify the settings with:

#command-block(
  "git config --global --list",
)

The output should contain the configured `user.name` and `user.email` values.

#config-block(
  filename: [Git global configuration],
)[
  user.name=Your Name
  user.email=your-email\@example.com
]

The following figure illustrates the result after Git has been configured successfully.

#guide-figure(
  caption: [Verifying the Git user configuration],
)[
  #image(
    "../assets/images/git_global_list.png",
    width: 78%,
  )
]

#expected-result[
  Git has been installed and configured successfully. The `git --version` command can be executed from the terminal, and the output of `git config --global --list` contains the user's `user.name` and `user.email` values.
]

== Installing PlatformIO IDE

PlatformIO IDE is integrated into Visual Studio Code through the official PlatformIO extension. This extension provides a development environment for embedded projects and is used to build, upload, and debug EduFramework projects.

Open Visual Studio Code, select *Extensions* on the Activity Bar, and search for `PlatformIO IDE`. Select the *PlatformIO IDE* extension published by *PlatformIO*, then select *Install* to begin the installation.

#guide-figure(
  caption: [Installing PlatformIO IDE from the Visual Studio Code Extensions Marketplace],
)[
  #image(
    "../assets/images/platformio_install_extension.png",
    width: 94%,
  )
]

After the extension is installed, PlatformIO initializes the required components. This process may take some time during the first launch.

#note[
  During the first launch, wait for PlatformIO to complete initialization before continuing. The required time may vary depending on the system and network connection.
]

After initialization is complete, select the *PlatformIO* icon on the Activity Bar, then select *PIO Home → Open* to open PlatformIO Home.

#guide-figure(
  caption: [PlatformIO Home after successful installation],
)[
  #image(
    "../assets/images/platformio_home.png",
    width: 94%,
  )
]

#expected-result[
  PlatformIO IDE has been installed and initialized successfully. PlatformIO Home can be opened directly from Visual Studio Code.
]

= Creating the First EduFramework Project

This section explains how to create a minimal EduFramework project for the S32K144, configure the project with PlatformIO, write the first program, and upload it to the MaaZEDU board.

== Creating the Project Structure

In Visual Studio Code, select *File → Open Folder...*. Create a new project folder, for example `EduFramework_First_Project`, then open the newly created folder in Visual Studio Code.

In the Visual Studio Code Explorer, create the `src` directory, then create `main.c` inside it. In the project root directory, also create `platformio.ini`.

The initial project structure is as follows:

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
  caption: [Initial structure of the EduFramework project],
)[
  #image(
    "../assets/images/project_structure.png",
    width: 92%,
  )
]

== Opening the Project with PlatformIO

After creating the project structure, open PlatformIO Home using the PlatformIO icon on the Activity Bar. Select *PIO Home → Open → Open Project* to open the project.

#guide-figure(
  caption: [Opening the project from PlatformIO Home],
)[
  #image(
    "../assets/images/platformio_open_project.png",
    width: 94%,
  )
]

Select the project folder that was just created. The selected folder must contain `platformio.ini` and the `src` directory.

#guide-figure(
  caption: [Selecting the EduFramework project folder],
)[
  #image(
    "../assets/images/platformio_select_project_folder.png",
    width: 72%,
  )
]

== Configuring the Project

Open `platformio.ini` and define the S32K144 environment as follows:

#guide-code(
  caption: [PlatformIO configuration for the EduFramework project],
)[
  #raw(
    block: true,
    lang: "ini",
    "[env:s32k144]\nplatform = https://github.com/QuangTM15/platform-nxps32k.git\nboard = s32k144\nframework = eduframework\nupload_protocol = jlink\ndebug_tool = jlink",
  )
]

In this configuration, `platform` specifies the Platform-NXPS32K platform used by the project, `board` identifies the target board, `framework` selects EduFramework, while `upload_protocol` and `debug_tool` configure J-Link for uploading and debugging.

After saving `platformio.ini`, PlatformIO recognizes the project configuration and prepares the development environment. On first use, this process may take some time because PlatformIO needs to download and install the required components.

PlatformIO-managed directories and files, such as `.pio` and `.vscode`, may appear in the project after initialization is complete.

#guide-figure(
  caption: [EduFramework project after PlatformIO initialization],
)[
  #image(
    "../assets/images/platformio_project_initialized.png",
    width: 92%,
  )
]

#note[
  Files inside the `.pio` directory do not need to be edited manually. The contents of this directory are managed by PlatformIO and may be regenerated during the project build process.
]

== Writing the First Program

Open `src/main.c` and enter the following program:

#guide-code(
  caption: [First Blink LED program with EduFramework],
)[
  #raw(
    block: true,
    lang: "c",
    "#include \"Arduino.h\"\n\nvolatile int counter = 0;\n\nint main(void)\n{\n    setup();\n\n    pinMode(LED_RED, OUTPUT);\n\n    while (1)\n    {\n        digitalWrite(LED_RED, LOW);\n        delay(500U);\n\n        digitalWrite(LED_RED, HIGH);\n        delay(500U);\n\n        counter++;\n    }\n\n    return 0;\n}",
  )
]

The `setup()` function must be called before using any EduFramework API. This function performs the minimum initialization of hardware components and resources required for the framework to operate before the application continues execution.

#warning[
  When developing an application with EduFramework, `setup()` must be called before any framework API is used. Omitting this initialization may cause the system to hang or result in unexpected behavior during program execution.
]

== Building the Project

Before building, save all modified files.

Select the *Build* icon on the PlatformIO toolbar at the bottom of Visual Studio Code to compile the project.

When the build completes successfully, the terminal displays the `SUCCESS` status.

#guide-figure(
  caption: [Successful EduFramework project build],
)[
  #image(
    "../assets/images/platformio_build_success.png",
    width: 94%,
  )
]

== Uploading the Program to the Board

Connect the MaaZEDU board to the computer using the USB port used for program upload and debugging.

After the board is connected, select the *Upload* icon on the PlatformIO toolbar to upload the program to the S32K144.

PlatformIO uses the `upload_protocol = jlink` setting in `platformio.ini` to perform the upload. When the process completes successfully, the terminal displays the `SUCCESS` status.

#guide-figure(
  caption: [Successful program upload to the S32K144],
)[
  #image(
    "../assets/images/platformio_upload_success.png",
    width: 94%,
  )
]

= Debugging

PlatformIO integrates a debugger directly into Visual Studio Code, allowing the program to be paused, executed step by step, and variable values to be monitored during execution. This section uses the project created previously to perform a basic debugging session on the S32K144.

== Starting a Debug Session

Ensure that the MaaZEDU board remains connected to the computer through the USB port used for uploading and debugging.

In Visual Studio Code, select the PlatformIO icon on the Activity Bar. Under *Debug*, select *Start Debugging* to start a debugging session.

#guide-figure(
  caption: [Starting a debugging session from PlatformIO],
)[
  #image(
    "../assets/images/debug_start_session.png",
    width: 92%,
  )
]

PlatformIO prepares the program, connects to the debugger, and starts the debugging session. When this process is complete, Visual Studio Code switches to the *Run and Debug* interface.

With the current configuration, the program may pause at the beginning of `main()` when the debugging session starts. From this point, the debug controls can be used to control program execution.

== Debug Controls and Breakpoints

When a debugging session is active, the debug control toolbar appears at the top of the Visual Studio Code window.

#guide-figure(
  caption: [Debug interface, control toolbar, and breakpoint],
)[
  #image(
    "../assets/images/debug_toolbar_breakpoint.png",
    width: 94%,
  )
]

The buttons on the debug control toolbar are arranged from left to right as follows:

#guide-table(
  columns: (1.3fr, 1.1fr, 2.6fr),
  headers: (
    [Tool],
    [Shortcut],
    [Function],
  ),
  rows: (
    (
      [Continue],
      [`F5`],
      [Continues program execution until the next breakpoint or another condition causes execution to stop.],
    ),
    (
      [Step Over],
      [`F10`],
      [Executes the current line and moves to the next line without entering a function called on that line.],
    ),
    (
      [Step Into],
      [`F11`],
      [Enters the function called on the current line so that its instructions can be debugged step by step.],
    ),
    (
      [Step Out],
      [`Shift + F11`],
      [Continues execution until the current function returns to its caller.],
    ),
    (
      [Restart],
      [`Ctrl + Shift + F5`],
      [Restarts the debugging session from the beginning.],
    ),
    (
      [Stop],
      [`Shift + F5`],
      [Stops the current debugging session.],
    ),
  ),
  caption: [Basic debug control tools],
)

A breakpoint is a stopping point placed on a source-code line. When program execution reaches a line containing a breakpoint, the debugger pauses execution so that variables and program state can be inspected.

To set a breakpoint, click in the gutter to the left of the desired source-code line. A red circle appears on that line. Click the same location again to remove the breakpoint.

In the current project, set a breakpoint on the following line:

#guide-code(
  caption: [Statement used as the breakpoint location],
)[
  #raw(
    block: true,
    lang: "c",
    "counter++;",
  )
]

== Monitoring Variables with Watch

The *Watch* panel allows the value of a variable or expression to be monitored directly during debugging.

In the *Run and Debug* interface, open the *Watch* section, select the `+` icon, and enter:

#command-block("counter")

#guide-figure(
  caption: [Adding the counter variable to the Watch panel],
)[
  #image(
    "../assets/images/debug_add_watch.png",
    width: 55%,
  )
]

After it is added to Watch, the value of `counter` is updated whenever program execution pauses during the debugging session.

== Continuing Program Execution and Observing the Result

After setting the breakpoint at `counter++` and adding `counter` to Watch, select *Continue* (`F5`) to resume program execution.

The program executes until it reaches the breakpoint at `counter++`, at which point the debugger pauses. The current value of `counter` can then be observed in the Watch panel.

#guide-figure(
  caption: [Observing the counter value at the breakpoint],
)[
  #image(
    "../assets/images/debug_breakpoint_watch_result.png",
    width: 94%,
  )
]

Select *Continue* (`F5`) again to allow the program to run through another cycle. When the breakpoint is triggered again, the value of `counter` changes according to program execution.

The *Step Over*, *Step Into*, and *Step Out* tools can be used when a more detailed view of the execution flow is required at the current stopping point.

= Troubleshooting

This section will be completed after the entire EduFramework setup and development workflow has been tested on a clean computer environment. Practical issues related to tool installation, PlatformIO initialization, build, upload, and debugging will be collected together with their corresponding solutions.

= Next Steps

After completing the steps in this guide, the EduFramework development environment is ready to build, upload, and debug applications for the S32K144 through PlatformIO.

The EduFramework Laboratory Series continues by introducing framework functionality through topic-based laboratory exercises. The laboratories begin with fundamental functions such as Digital Output and Digital Input, then expand to peripherals and devices supported by EduFramework.

All laboratory documents, example projects, and related source code are maintained at:

#repo-link(
  "EduFramework Laboratory Series",
  "https://github.com/QuangTM15/EduFramework_Labs",
)

EduFramework and Platform-NXPS32K can be referenced directly in their respective repositories:

#repo-link(
  "EduFramework",
  "https://github.com/QuangTM15/s32k144-edu-framework",
)

#repo-link(
  "Platform-NXPS32K",
  "https://github.com/QuangTM15/platform-nxps32k",
)

= References

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
