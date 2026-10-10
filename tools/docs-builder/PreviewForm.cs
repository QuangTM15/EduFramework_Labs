
using System;
using System.Drawing;
using System.IO;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Web.WebView2.WinForms;

namespace EduFrameworkDocsBuilder;

public sealed class PreviewForm : Form
{
    private readonly WebView2 viewer;
    private readonly Label statusLabel;
    private readonly string pdfPath;
    private bool initialized;
    public PreviewForm(string pdfPath)
    {
        this.pdfPath = pdfPath;
        Text = "EduFramework - Live PDF Preview";
        Size = new Size(900, 1100);
        MinimumSize = new Size(550, 600);
        StartPosition = FormStartPosition.CenterScreen;
        BackColor = Color.White;
        var header = new Panel
        {
            Dock = DockStyle.Top,
            Height = 48,
            BackColor = Color.FromArgb(248, 250, 252)
        };
        statusLabel = new Label
        {
            Text = "Initializing preview...",
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft,
            Padding = new Padding(16, 0, 0, 0),
            ForeColor = Color.FromArgb(51, 65, 85)
        };
        header.Controls.Add(statusLabel);
        viewer = new WebView2
        {
            Dock = DockStyle.Fill
        };
        Controls.Add(viewer);
        Controls.Add(header);
        Shown += async (_, _) => await InitializePreviewAsync();
    }
    private async Task InitializePreviewAsync()
    {
        try
        {
            await viewer.EnsureCoreWebView2Async();
            initialized = true;
            RefreshPreview();
        }
        catch (Exception ex)
        {
            statusLabel.Text = $"Preview error: {ex.Message}";
        }
    }

    public void RefreshPreview()
    {
        if (!initialized || IsDisposed)
        {
            return;
        }
        if (!File.Exists(pdfPath))
        {
            statusLabel.Text = "PDF not found. Waiting for build...";
            return;
        }
        statusLabel.Text =
            $"Preview updated: {DateTime.Now:HH:mm:ss}";
        string pdfUrl = new Uri(pdfPath).AbsoluteUri;
        viewer.CoreWebView2.Navigate(pdfUrl);
    }

    public void SetBuildStatus(string message)
    {
        if (IsDisposed)
        {
            return;
        }
        statusLabel.Text = message;
    }
}
