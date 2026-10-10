# EduFramework Labs — Documentation Builder

This repository contains the source files and generated PDFs for the **EduFramework Labs** documentation series. The documentation is written in [Typst](https://typst.app/) and can be compiled either through the **EduFramework Docs Builder** Windows application or from the command line.

> This setup is for **documentation authoring only**. It does not install PlatformIO, embedded toolchains, board drivers, or hardware debugging tools.

## Requirements

- Windows 10/11 (64-bit)
- Internet access for first-time installation and .NET package restore
- Windows Package Manager (`winget`) for automatic dependency installation
- Git to clone the repository

The setup script checks for **Typst**, **.NET 10 SDK**, and **Microsoft Edge WebView2 Runtime**. Missing dependencies are installed through `winget`. Existing installations are reused. The application is published as a self-contained Windows x64 executable, so the .NET SDK is needed for **building the application**, not for launching the published executable.

## 1. Clone and set up

Open PowerShell:

```powershell
git clone https://github.com/QuangTM15/EduFramework_Labs.git
cd EduFramework_Labs
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1
```

The script installs any missing prerequisites, restores/builds the .NET application, and publishes the executable to:

```text
tools/docs-builder/publish/EduFrameworkDocsBuilder.exe
```

If a newly installed command is not detected immediately, open a new PowerShell window and run setup again. The script is designed to be rerun safely.

## 2. Repository layout

```text
EduFramework_Labs/
├── documentation/
│   ├── vi/                    # Vietnamese Typst source files
│   │   └── lab_01_blink_led.typ
│   ├── en/                    # English Typst source files
│   │   └── lab_01_blink_led.typ
│   ├── template/              # Shared Typst layout and components
│   └── assets/                # Figures, circuits, and other assets
├── docs/
│   ├── vi/                    # Generated Vietnamese PDFs
│   │   └── lab_01_blink_led.pdf
│   └── en/                    # Generated English PDFs
│       └── lab_01_blink_led.pdf
├── labs/                      # Embedded lab projects
├── tools/
│   ├── lab.ps1                # Documentation build CLI
│   └── docs-builder/
│       ├── *.cs               # WinForms application source code
│       ├── EduFrameworkDocsBuilder.csproj
│       └── publish/           # Locally generated application executable
├── lab.cmd                    # Command-line wrapper
└── setup.ps1                  # Documentation tooling setup
```

**`documentation/` contains editable `.typ` source files. `docs/` contains compiled `.pdf` output.** Files under `documentation/template/` and `documentation/assets/` are shared by the lab documents. Do not edit generated PDFs as the source of truth; edit the corresponding `.typ` file and rebuild.

## 3. Open Docs Builder

From the repository root, run:

```powershell
.\tools\docs-builder\publish\EduFrameworkDocsBuilder.exe
```

You can also open the EXE in File Explorer. **Keep the EXE inside the cloned repository**, since the application automatically searches parent directories for the repository's `documentation/` directory and `tools/lab.ps1` build script.

### Application actions

| Action          | Description                                                        |
| --------------- | ------------------------------------------------------------------ |
| **Refresh**     | Stop Watch, close Live Preview, clear the log, and rescan labs     |
| **Build**       | Compile the selected lab to PDF                                    |
| **Rebuild**     | Clean and compile the selected lab again                           |
| **Clean**       | Remove the selected generated PDF                                  |
| **Build All**   | Compile all available labs for the selected language(s)            |
| **Clean All**   | Remove generated lab PDFs for the selected language(s)             |
| **Watch**       | Recompile the selected lab on source changes and show Live Preview |
| **Stop Watch**  | Stop automatic compilation and close Live Preview                  |
| **Open Source** | Open the selected `.typ` source file                               |
| **Open PDF**    | Open the generated PDF                                             |

Choose a laboratory and select **Vietnamese**, **English**, or **Both** as available. Live Preview supports one language at a time. Build errors and other command output appear in the Build Log.

## 4. Create or edit a lab

1. Create a new Typst file in `documentation/vi/` and/or `documentation/en/`. For example, `documentation/vi/lab_20_example.typ`.
2. Follow the structure and shared template conventions used by existing labs. Use assets from `documentation/assets/` where needed.
3. Use the **same filename** in `vi/` and `en/` for bilingual versions.
4. Open Docs Builder and click **Refresh** to discover the new lab.
5. Select the lab and language, then click **Build** or **Watch**.
6. Find the generated PDF at `docs/vi/lab_20_example.pdf` or `docs/en/lab_20_example.pdf`.

The GUI discovers source files named `lab_*.typ`. A source file is **Typst markup/code**, not a PDF; the corresponding PDF is generated by the build command.

## 5. Build without the GUI

From the repository root, use the existing `lab.cmd` wrapper:

```powershell
# Build one Vietnamese lab
.\lab.cmd build lab_01_blink_led vi

# Build one English lab
.\lab.cmd build lab_01_blink_led en

# Rebuild a lab
.\lab.cmd rebuild lab_01_blink_led vi

# Remove a generated lab PDF
.\lab.cmd clean lab_01_blink_led vi
```

You can also call the PowerShell build script directly:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\lab.ps1 build lab_01_blink_led vi
```

Other supported commands include `build-all`, `clean-all`, `list`, and `help`. Run the help command to inspect the available CLI usage:

```powershell
.\lab.cmd help
```
