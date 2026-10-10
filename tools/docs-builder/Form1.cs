
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;

namespace EduFrameworkDocsBuilder;

public partial class Form1 : Form
{
    private readonly BuildService buildService;
    private readonly LabScanner scanner;
    private readonly FileOpenService fileOpenService;
    private readonly WatchService watchService;
    private PreviewForm? previewForm;
    private List<LabInfo> availableLabs = new();
    private static readonly Color Green = Color.FromArgb(22, 163, 74);
    private static readonly Color GreenHover = Color.FromArgb(21, 128, 61);
    private static readonly Color DarkGreen = Color.FromArgb(22, 101, 52);
    private static readonly Color Red = Color.FromArgb(220, 38, 38);
    private static readonly Color RedHover = Color.FromArgb(185, 28, 28);
    private static readonly Color Background = Color.FromArgb(243, 247, 244);
    private static readonly Color Dark = Color.FromArgb(31, 41, 55);
    private static readonly Color Border = Color.FromArgb(214, 225, 218);
    private static readonly Color Muted = Color.FromArgb(100, 116, 139);

    private readonly ComboBox labComboBox = new();
    private readonly RadioButton viRadio = new();
    private readonly RadioButton enRadio = new();
    private readonly RadioButton bothRadio = new();
    private readonly RichTextBox logBox = new();
    private readonly Label statusLabel = new();
    private bool isBusy = false;
    public Form1()
    {
        InitializeComponent();
        string repositoryRoot = RepositoryLocator.FindRoot();
        scanner = new LabScanner(repositoryRoot);
        buildService = new BuildService(repositoryRoot);
        watchService = new WatchService(repositoryRoot, buildService, message =>
        {
            if (IsDisposed || !IsHandleCreated)
                return;

            if (InvokeRequired)
                BeginInvoke(() => AppendLog(message));
            else
                AppendLog(message);
        });
        fileOpenService = new FileOpenService(repositoryRoot);
        BuildInterface();
        watchService.BuildSucceeded += language =>
        {
            if (IsDisposed || !IsHandleCreated)
                return;

            BeginInvoke(() =>
            {
                if (previewForm == null || previewForm.IsDisposed)
                    return;

                previewForm.SetBuildStatus(
                    $"Build succeeded [{language}]. Refreshing preview...");

                previewForm.RefreshPreview();
            });
        };
        FormClosed += (_, _) => watchService.Dispose();
        RefreshLabs();
    }
    private async Task ExecuteCommandAsync(
        string command,
        bool allLabs)
    {
        if (isBusy)
        {
            AppendLog("Another operation is already running.");
            return;
        }
        string labName = "";
        if (!allLabs)
        {
            if (labComboBox.SelectedItem is not LabInfo lab)
            {
                AppendLog("ERROR: No laboratory selected.");
                return;
            }
            labName = lab.Name;
        }
        string[] languages;
        if (bothRadio.Checked)
        {
            languages = new[] { "vi", "en" };
        }
        else if (enRadio.Checked)
        {
            languages = new[] { "en" };
        }
        else
        {
            languages = new[] { "vi" };
        }
        if (allLabs &&
            (command == "clean-all" || command == "build-all"))
        {
            string action = command == "clean-all"
                ? "delete all generated lab PDFs"
                : "build all laboratories";
            DialogResult confirmation = MessageBox.Show(
                $"Do you want to {action} for {string.Join(", ", languages)}?",
                "EduFramework Docs Builder",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);
            if (confirmation != DialogResult.Yes)
            {
                AppendLog("Operation cancelled.");
                return;
            }
        }
        isBusy = true;
        statusLabel.Text = "● Processing...";
        statusLabel.ForeColor = Color.DarkOrange;
        bool success = true;
        try
        {
            foreach (string language in languages)
            {
                bool result = await buildService.ExecuteAsync(
                    command,
                    labName,
                    language,
                    message =>
                    {
                        if (IsDisposed || !IsHandleCreated)
                        {
                            return;
                        }
                        if (InvokeRequired)
                        {
                            BeginInvoke(() => AppendLog(message));
                        }
                        else
                        {
                            AppendLog(message);
                        }
                    });
                if (!result)
                {
                    success = false;
                }
            }
            statusLabel.Text = success
                ? "● Operation completed"
                : "● Operation failed";
            statusLabel.ForeColor = success
                ? Green
                : Red;
            AppendLog(success
                ? "All requested operations completed."
                : "One or more operations failed.");
        }
        catch (Exception ex)
        {
            AppendLog($"ERROR: {ex.Message}");
            statusLabel.Text = "● Operation failed";
            statusLabel.ForeColor = Red;
        }
        finally
        {
            isBusy = false;
        }
    }

    private void RefreshWorkspace()
    {
        if (isBusy)
        {
            AppendLog("Cannot refresh while an operation is running.");
            return;
        }

        // Stop Watch and close Live Preview.
        StopWatch();

        // Clear previous output.
        logBox.Clear();

        // Rescan laboratories without logging.
        RefreshLabs(false);

        // Reset application status.
        statusLabel.Text = "● Ready";
        statusLabel.ForeColor = Green;
    }

    private void StartWatch()
    {
        if (isBusy)
        {
            AppendLog("Cannot start Watch during another operation.");
            return;
        }
        if (watchService.IsWatching)
        {
            if (previewForm != null && !previewForm.IsDisposed)
            {
                previewForm.Activate();
            }
            return;
        }
        if (labComboBox.SelectedItem is not LabInfo lab)
        {
            AppendLog("ERROR: No laboratory selected.");
            return;
        }
        if (bothRadio.Checked)
        {
            AppendLog(
                "Live Preview currently supports one language at a time.");
            return;
        }
        string language = enRadio.Checked ? "en" : "vi";
        bool started = watchService.Start(
            lab.Name,
            new[] { language });
        if (!started)
        {
            return;
        }
        string pdfPath = Path.Combine(
            RepositoryLocator.FindRoot(),
            "docs",
            language,
            lab.Name + ".pdf");
        previewForm = new PreviewForm(pdfPath);
        previewForm.FormClosed += (_, _) =>
        {
            if (watchService.IsWatching)
            {
                StopWatch();
            }
            previewForm = null;
        };
        previewForm.Show(this);
        statusLabel.Text = "● Watching...";
        statusLabel.ForeColor = Green;
    }

    private void StopWatch()
    {
        bool wasWatching = watchService.IsWatching;
        if (wasWatching)
        {
            watchService.Stop();
        }
        if (previewForm != null && !previewForm.IsDisposed)
        {
            PreviewForm form = previewForm;
            previewForm = null;
            form.Close();
            form.Dispose();
        }
        if (wasWatching)
        {
            AppendLog("Live Preview stopped.");
        }
        statusLabel.Text = "● Ready";
        statusLabel.ForeColor = Green;
    }
    private void OpenSelectedFile(bool openPdf)
    {
        if (labComboBox.SelectedItem is not LabInfo lab)
        {
            AppendLog("ERROR: No laboratory selected.");
            return;
        }
        if (isBusy)
        {
            AppendLog("Please wait until the current operation finishes.");
            return;
        }
        string[] languages;
        if (bothRadio.Checked)
        {
            languages = new[] { "vi", "en" };
        }
        else if (enRadio.Checked)
        {
            languages = new[] { "en" };
        }
        else
        {
            languages = new[] { "vi" };
        }
        bool success = true;
        foreach (string language in languages)
        {
            bool result = openPdf
                ? fileOpenService.OpenPdf(
                    lab.Name,
                    language,
                    AppendLog)
                : fileOpenService.OpenSource(
                    lab.Name,
                    language,
                    AppendLog);
            if (!result)
            {
                success = false;
            }
        }
        statusLabel.Text = success
            ? "● File opened"
            : "● Open failed";
        statusLabel.ForeColor = success ? Green : Red;
    }

    private void BuildInterface()
    {
        SuspendLayout();
        Text = "EduFramework Docs Builder";
        ClientSize = new Size(900, 720);
        MinimumSize = new Size(800, 660);
        StartPosition = FormStartPosition.CenterScreen;
        Font = new Font("Segoe UI", 10);
        BackColor = Background;
        var root = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            Padding = new Padding(26, 20, 26, 14),
            ColumnCount = 1,
            RowCount = 5
        };
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 100));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 164));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 220));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 48));
        Controls.Add(root);
        BuildHeader(root);
        BuildSelection(root);
        BuildActions(root);
        BuildLog(root);
        BuildFooter(root);
        ResumeLayout();
    }
    private void BuildHeader(TableLayoutPanel root)
    {
        var header = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 2
        };
        header.ColumnStyles.Add(
            new ColumnStyle(SizeType.Percent, 100));
        header.ColumnStyles.Add(
            new ColumnStyle(SizeType.Absolute, 56));
        var textPanel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 2
        };
        textPanel.RowStyles.Add(
            new RowStyle(SizeType.Absolute, 44));
        textPanel.RowStyles.Add(
            new RowStyle(SizeType.Absolute, 26));
        textPanel.Controls.Add(new Label
        {
            Text = "EduFramework Docs Builder",
            Font = new Font("Segoe UI", 20, FontStyle.Bold),
            ForeColor = DarkGreen,
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft
        }, 0, 0);
        textPanel.Controls.Add(new Label
        {
            Text = "Typst Documentation Manager",
            ForeColor = Muted,
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft
        }, 0, 1);
        var help = CreateButton(
            "",
            Color.White,
            DarkGreen,
            Color.FromArgb(240, 250, 244),
            "help");
        help.Dock = DockStyle.Fill;
        help.Margin = new Padding(5, 7, 0, 17);
        help.Click += (_, _) => ShowHelp();
        header.Controls.Add(textPanel, 0, 0);
        header.Controls.Add(help, 1, 0);
        root.Controls.Add(header, 0, 0);
    }

    private void BuildSelection(TableLayoutPanel root)
    {
        var card = new Panel
        {
            Dock = DockStyle.Fill,
            BackColor = Color.White,
            Margin = new Padding(0, 4, 0, 4),
            Padding = new Padding(18, 12, 18, 10)
        };
        card.Resize += (_, _) => RoundControl(card, 12);
        var layout = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 4,
            ColumnCount = 1
        };
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 29));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 43));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 29));
        layout.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        layout.Controls.Add(CreateLabel("Laboratory"), 0, 0);
        labComboBox.Dock = DockStyle.Fill;
        labComboBox.DropDownStyle = ComboBoxStyle.DropDownList;
        labComboBox.Font = new Font("Segoe UI", 10);
        labComboBox.Margin = new Padding(0, 0, 0, 8);
        labComboBox.SelectedIndexChanged += (_, _) => UpdateLanguageAvailability();
        layout.Controls.Add(labComboBox, 0, 1);
        layout.Controls.Add(CreateLabel("Language"), 0, 2);
        var languages = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            WrapContents = false
        };
        ConfigureRadio(viRadio, "Vietnamese", true);
        ConfigureRadio(enRadio, "English", false);
        ConfigureRadio(bothRadio, "Both", false);
        languages.Controls.AddRange(new Control[]
        {
            viRadio, enRadio, bothRadio
        });
        layout.Controls.Add(languages, 0, 3);
        card.Controls.Add(layout);
        root.Controls.Add(card, 0, 1);
    }

    private void BuildActions(TableLayoutPanel root)
    {
        var actions = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 3,
            RowCount = 3,
            Padding = new Padding(0, 13, 0, 13)
        };
        for (int i = 0; i < 3; i++)
        {
            actions.ColumnStyles.Add(
                new ColumnStyle(SizeType.Percent, 100f / 3));
            actions.RowStyles.Add(
                new RowStyle(SizeType.Percent, 100f / 3));
        }
        AddAction(actions, "Build", "play",
            Green, Color.White, GreenHover, 0, 0);
        AddAction(actions, "Rebuild", "refresh",
            Green, Color.White, GreenHover, 1, 0);
        AddAction(actions, "Clean", "trash",
            Red, Color.White, RedHover, 2, 0);
        AddAction(actions, "Build All", "layers",
            Green, Color.White, GreenHover, 0, 1);
        AddAction(actions, "Clean All", "trash",
            Red, Color.White, RedHover, 1, 1);
        AddAction(actions, "Watch", "watch",
            Green, Color.White, GreenHover, 2, 1);
        AddAction(actions, "Stop Watch", "stop",
            Red, Color.White, RedHover, 0, 2);
        AddAction(actions, "Open Source", "source",
            Color.White, Dark, Background, 1, 2);
        AddAction(actions, "Open PDF", "pdf",
            Color.White, Dark, Background, 2, 2);
        root.Controls.Add(actions, 0, 2);
    }

    private void BuildLog(TableLayoutPanel root)
    {
        var card = new Panel
        {
            Dock = DockStyle.Fill,
            BackColor = Dark,
            Padding = new Padding(16, 13, 16, 13)
        };

        card.Resize += (_, _) => RoundControl(card, 12);

        var layout = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 2
        };

        layout.RowStyles.Add(
            new RowStyle(SizeType.Absolute, 34));

        layout.RowStyles.Add(
            new RowStyle(SizeType.Percent, 100));

        var title = new Label
        {
            Text = "BUILD LOG",
            ForeColor = Color.White,
            Font = new Font("Segoe UI", 10, FontStyle.Bold),
            Dock = DockStyle.Fill
        };
        logBox.Dock = DockStyle.Fill;
        logBox.BorderStyle = BorderStyle.None;
        logBox.ReadOnly = true;
        logBox.BackColor = Dark;
        logBox.ForeColor = Color.FromArgb(134, 239, 172);
        logBox.Font = new Font("Consolas", 9);
        logBox.Text = "[EduFramework Docs Builder] Ready.";
        layout.Controls.Add(title, 0, 0);
        layout.Controls.Add(logBox, 0, 1);
        card.Controls.Add(layout);
        root.Controls.Add(card, 0, 3);
    }

    private void BuildFooter(TableLayoutPanel root)
    {
        var footer = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 2
        };
        footer.ColumnStyles.Add(
            new ColumnStyle(SizeType.Percent, 100));
        footer.ColumnStyles.Add(
            new ColumnStyle(SizeType.Absolute, 145));
        statusLabel.Text = "● Ready";
        statusLabel.ForeColor = Green;
        statusLabel.Dock = DockStyle.Fill;
        statusLabel.TextAlign = ContentAlignment.MiddleLeft;
        var refresh = CreateButton(
            "Refresh",
            Color.White,
            DarkGreen,
            Background,
            "refresh");
        refresh.Dock = DockStyle.Fill;
        refresh.Margin = new Padding(6, 7, 0, 4);
        refresh.Click += (_, _) => RefreshWorkspace();
        footer.Controls.Add(statusLabel, 0, 0);
        footer.Controls.Add(refresh, 1, 0);
        root.Controls.Add(footer, 0, 4);
    }

    private static Label CreateLabel(string text)
    {
        return new Label
        {
            Text = text,
            Dock = DockStyle.Fill,
            ForeColor = Dark,
            Font = new Font("Segoe UI", 10, FontStyle.Bold)
        };
    }

    private static void ConfigureRadio(
        RadioButton radio,
        string text,
        bool selected)
    {
        radio.Text = text;
        radio.Checked = selected;
        radio.AutoSize = true;
        radio.ForeColor = Dark;
        radio.Margin = new Padding(0, 4, 28, 0);
    }

    private static Button CreateButton(
        string text,
        Color background,
        Color foreground,
        Color hover,
        string icon)
    {
        var button = new Button
        {
            Text = text,
            BackColor = background,
            ForeColor = foreground,
            FlatStyle = FlatStyle.Flat,
            Cursor = Cursors.Hand,
            Font = new Font("Segoe UI", 10, FontStyle.Bold),
            TextImageRelation = TextImageRelation.ImageBeforeText,
            ImageAlign = ContentAlignment.MiddleCenter,
            TextAlign = ContentAlignment.MiddleCenter
        };
        button.FlatAppearance.BorderSize = 0;
        button.Image = IconFactory.Create(icon, foreground, 19);
        button.MouseEnter += (_, _) =>
            button.BackColor = hover;
        button.MouseLeave += (_, _) =>
            button.BackColor = background;
        button.Resize += (_, _) =>
            RoundControl(button, 9);
        return button;
    }

    private void AddAction(
        TableLayoutPanel panel,
        string text,
        string icon,
        Color background,
        Color foreground,
        Color hover,
        int column,
        int row)
    {
        var button = CreateButton(
            text, background, foreground, hover, icon);
        button.Dock = DockStyle.Fill;
        button.Margin = new Padding(5);
        button.Click += async (_, _) =>
        {
            switch (text)
            {
                case "Build":
                    await ExecuteCommandAsync("build", false);
                    break;
                case "Rebuild":
                    await ExecuteCommandAsync("rebuild", false);
                    break;
                case "Clean":
                    await ExecuteCommandAsync("clean", false);
                    break;
                case "Build All":
                    await ExecuteCommandAsync("build-all", true);
                    break;
                case "Clean All":
                    await ExecuteCommandAsync("clean-all", true);
                    break;
                case "Open Source":
                    OpenSelectedFile(false);
                    break;
                case "Open PDF":
                    OpenSelectedFile(true);
                    break;
                case "Watch":
                    StartWatch();
                    break;

                case "Stop Watch":
                    StopWatch();
                    break;
                default:
                    AppendLog($"{text} clicked.");
                    break;
            }
        };
        panel.Controls.Add(button, column, row);
    }
    private void AppendLog(string message)
    {
        logBox.AppendText(
            Environment.NewLine +
            $"[{DateTime.Now:HH:mm:ss}] {message}");

        logBox.SelectionStart = logBox.TextLength;
        logBox.ScrollToCaret();
    }
    private static void RoundControl(Control control, int radius)
    {
        if (control.Width <= 0 || control.Height <= 0)
        {
            return;
        }
        using var path = new GraphicsPath();
        int diameter = radius * 2;
        var rect = new Rectangle(
            0, 0, control.Width, control.Height);
        path.AddArc(rect.Left, rect.Top,
            diameter, diameter, 180, 90);
        path.AddArc(rect.Right - diameter, rect.Top,
            diameter, diameter, 270, 90);
        path.AddArc(rect.Right - diameter,
            rect.Bottom - diameter,
            diameter, diameter, 0, 90);
        path.AddArc(rect.Left,
            rect.Bottom - diameter,
            diameter, diameter, 90, 90);
        path.CloseFigure();
        var oldRegion = control.Region;
        control.Region = new Region(path);
        oldRegion?.Dispose();
    }
    private void RefreshLabs(bool showLog = true)
    {
        string? previousSelection =
            labComboBox.SelectedItem?.ToString();
        availableLabs = scanner.Scan();
        labComboBox.BeginUpdate();
        labComboBox.Items.Clear();
        foreach (LabInfo lab in availableLabs)
        {
            labComboBox.Items.Add(lab);
        }
        labComboBox.EndUpdate();
        if (availableLabs.Count == 0)
        {
            viRadio.Enabled = false;
            enRadio.Enabled = false;
            bothRadio.Enabled = false;
            if (showLog)
            {
                AppendLog($"Found {availableLabs.Count} laboratories.");
            }
            return;
        }
        int previousIndex = availableLabs.FindIndex(
            lab => lab.Name == previousSelection);
        labComboBox.SelectedIndex =
            previousIndex >= 0 ? previousIndex : 0;
        UpdateLanguageAvailability();
        if (showLog)
        {
            AppendLog("No laboratory source files found.");
        }
    }
    private void UpdateLanguageAvailability()
    {
        if (labComboBox.SelectedItem is not LabInfo lab)
        {
            viRadio.Enabled = false;
            enRadio.Enabled = false;
            bothRadio.Enabled = false;
            return;
        }
        viRadio.Enabled = lab.HasVietnamese;
        enRadio.Enabled = lab.HasEnglish;
        bothRadio.Enabled =
            lab.HasVietnamese && lab.HasEnglish;
        if (bothRadio.Checked && !bothRadio.Enabled)
        {
            viRadio.Checked = lab.HasVietnamese;
            enRadio.Checked = !lab.HasVietnamese && lab.HasEnglish;
        }
        else if (viRadio.Checked && !viRadio.Enabled)
        {
            enRadio.Checked = lab.HasEnglish;
        }
        else if (enRadio.Checked && !enRadio.Enabled)
        {
            viRadio.Checked = lab.HasVietnamese;
        }
    }
    private static void ShowHelp()
    {
        MessageBox.Show(
            "EduFramework Docs Builder\n\n" +
            "Build: Compile selected laboratory.\n" +
            "Rebuild: Clean and compile again.\n" +
            "Clean: Remove selected PDF.\n" +
            "Build All: Compile all laboratories.\n" +
            "Clean All: Remove all lab PDFs.\n" +
            "Watch: Automatically compile on source changes.\n" +
            "Stop Watch: Stop watching files.\n" +
            "Open Source: Open Typst source.\n" +
            "Open PDF: Open generated PDF.\n" +
            "Refresh: Rescan laboratories.",
            "Help - EduFramework Docs Builder",
            MessageBoxButtons.OK,
            MessageBoxIcon.Information
        );
    }
}
