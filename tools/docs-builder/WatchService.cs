
using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace EduFrameworkDocsBuilder;

public sealed class WatchService : IDisposable
{
    private readonly string repositoryRoot;
    private readonly BuildService buildService;
    private readonly Action<string> log;

    private readonly object sync = new();
    private readonly SemaphoreSlim buildLock = new(1, 1);

    private FileSystemWatcher? viWatcher;
    private FileSystemWatcher? enWatcher;

    private CancellationTokenSource? sessionCts;
    private CancellationTokenSource? debounceCts;

    private string labName = "";
    private string[] languages = Array.Empty<string>();

    private bool isWatching;
    private bool disposed;
    public event Action<string>? BuildSucceeded;

    public bool IsWatching
    {
        get
        {
            lock (sync)
            {
                return isWatching;
            }
        }
    }

    public WatchService(
        string repositoryRoot,
        BuildService buildService,
        Action<string> log)
    {
        this.repositoryRoot = repositoryRoot;
        this.buildService = buildService;
        this.log = log;
    }

    public bool Start(string selectedLab, string[] selectedLanguages)
    {
        if (IsWatching)
        {
            log("Watch is already running.");
            return false;
        }

        if (selectedLanguages.Length == 0)
        {
            log("ERROR: No language selected.");
            return false;
        }

        foreach (string language in selectedLanguages)
        {
            string source = Path.Combine(
                repositoryRoot,
                "documentation",
                language,
                selectedLab + ".typ");

            if (!File.Exists(source))
            {
                log($"ERROR: Source file not found: {source}");
                return false;
            }
        }

        lock (sync)
        {
            labName = selectedLab;
            languages = (string[])selectedLanguages.Clone();
            sessionCts = new CancellationTokenSource();
            isWatching = true;
        }

        try
        {
            foreach (string language in languages)
            {
                var watcher = new FileSystemWatcher(
                    Path.Combine(repositoryRoot, "documentation", language))
                {
                    Filter = labName + ".typ",
                    NotifyFilter =
                        NotifyFilters.LastWrite |
                        NotifyFilters.FileName |
                        NotifyFilters.Size,
                    IncludeSubdirectories = false,
                    EnableRaisingEvents = false
                };
                watcher.Changed += (_, _) => OnSourceChanged(language);
                watcher.Created += (_, _) => OnSourceChanged(language);
                watcher.Renamed += (_, _) => OnSourceChanged(language);
                watcher.Error += (_, e) =>
                    log($"ERROR: File watcher: {e.GetException().Message}");
                if (language == "vi")
                    viWatcher = watcher;
                else
                    enWatcher = watcher;
                watcher.EnableRaisingEvents = true;
            }
            log($"Watching: {labName} [{string.Join(", ", languages)}]");
            return true;
        }
        catch (Exception ex)
        {
            log($"ERROR: Cannot start Watch: {ex.Message}");
            Stop();
            return false;
        }
    }
    private void OnSourceChanged(string language)
    {
        CancellationToken token;
        lock (sync)
        {
            if (!isWatching || sessionCts == null)
                return;
            debounceCts?.Cancel();
            debounceCts?.Dispose();
            debounceCts = CancellationTokenSource.CreateLinkedTokenSource(
                sessionCts.Token);
            token = debounceCts.Token;
        }
        _ = DebounceAndBuildAsync(language, token);
    }
    private async Task DebounceAndBuildAsync(
        string language,
        CancellationToken token)
    {
        try
        {
            await Task.Delay(500, token);
            await buildLock.WaitAsync(token);
            try
            {
                token.ThrowIfCancellationRequested();
                log($"Change detected: {labName}.typ [{language}]");
                bool success = await buildService.ExecuteAsync(
                    "build",
                    labName,
                    language,
                    log);
                if (!token.IsCancellationRequested)
                {
                    log(success
                        ? $"Auto-build succeeded [{language}]."
                        : $"Auto-build failed [{language}].");

                    if (success)
                    {
                        BuildSucceeded?.Invoke(language);
                    }
                }
            }
            finally
            {
                buildLock.Release();
            }
        }
        catch (OperationCanceledException)
        {
            // Expected when changes are merged or Watch stops.
        }
        catch (Exception ex)
        {
            log($"ERROR: Watch: {ex.Message}");
        }
    }
    public void Stop()
    {
        lock (sync)
        {
            if (!isWatching)
                return;
            isWatching = false;
            sessionCts?.Cancel();
            debounceCts?.Cancel();
            viWatcher?.Dispose();
            enWatcher?.Dispose();
            viWatcher = null;
            enWatcher = null;
            log("Watch stopped.");
        }
    }
    public void Dispose()
    {
        if (disposed)
            return;
        Stop();
        disposed = true;
    }
}
