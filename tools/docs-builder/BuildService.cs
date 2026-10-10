
using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace EduFrameworkDocsBuilder;

public sealed class BuildService
{
    private readonly string repositoryRoot;
    private readonly string scriptPath;
    public BuildService(string repositoryRoot)
    {
        this.repositoryRoot = repositoryRoot;
        scriptPath = Path.Combine(
            repositoryRoot,
            "tools",
            "lab.ps1");
    }
    public async Task<bool> ExecuteAsync(
        string command,
        string labName,
        string language,
        Action<string> log)
    {
        if (!File.Exists(scriptPath))
        {
            log($"ERROR: Build script not found: {scriptPath}");
            return false;
        }
        var startInfo = new ProcessStartInfo
        {
            FileName = "powershell.exe",
            WorkingDirectory = repositoryRoot,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding = Encoding.UTF8
        };
        startInfo.ArgumentList.Add("-NoProfile");
        startInfo.ArgumentList.Add("-NonInteractive");
        startInfo.ArgumentList.Add("-ExecutionPolicy");
        startInfo.ArgumentList.Add("Bypass");
        startInfo.ArgumentList.Add("-File");
        startInfo.ArgumentList.Add(scriptPath);
        startInfo.ArgumentList.Add(command);
        startInfo.ArgumentList.Add(labName);
        startInfo.ArgumentList.Add(language);
        log($"Executing: {command} {labName} [{language}]");
        try
        {
            using var process = new Process
            {
                StartInfo = startInfo
            };
            process.OutputDataReceived += (_, e) =>
            {
                if (e.Data != null)
                {
                    log(e.Data);
                }
            };
            process.ErrorDataReceived += (_, e) =>
            {
                if (e.Data != null)
                {
                    log($"ERROR: {e.Data}");
                }
            };
            if (!process.Start())
            {
                log("ERROR: Failed to start PowerShell.");
                return false;
            }
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            await process.WaitForExitAsync();
            if (process.ExitCode != 0)
            {
                log(
                    $"Command failed (exit code {process.ExitCode}).");
                return false;
            }
            log("Command completed successfully.");
            return true;
        }
        catch (Exception ex)
        {
            log($"ERROR: {ex.Message}");
            return false;
        }
    }
}
