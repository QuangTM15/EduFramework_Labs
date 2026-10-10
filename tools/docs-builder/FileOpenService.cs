
using System;
using System.Diagnostics;
using System.IO;

namespace EduFrameworkDocsBuilder;

public sealed class FileOpenService
{
    private readonly string repositoryRoot;
    public FileOpenService(string repositoryRoot)
    {
        this.repositoryRoot = repositoryRoot;
    }
    public bool OpenSource(
        string labName,
        string language,
        Action<string> log)
    {
        string path = Path.Combine(
            repositoryRoot,
            "documentation",
            language,
            labName + ".typ");
        return OpenFile(path, log);
    }
    public bool OpenPdf(
        string labName,
        string language,
        Action<string> log)
    {
        string path = Path.Combine(
            repositoryRoot,
            "docs",
            language,
            labName + ".pdf");
        return OpenFile(path, log);
    }
    private static bool OpenFile(
        string path,
        Action<string> log)
    {
        if (!File.Exists(path))
        {
            log($"ERROR: File not found: {path}");
            return false;
        }
        try
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = path,
                UseShellExecute = true
            };
            using Process? process = Process.Start(startInfo);
            if (process == null)
            {
                log($"ERROR: Unable to open: {path}");
                return false;
            }
            log($"Opened: {path}");
            return true;
        }
        catch (Exception ex)
        {
            log($"ERROR: Cannot open {path}: {ex.Message}");
            return false;
        }
    }
}
