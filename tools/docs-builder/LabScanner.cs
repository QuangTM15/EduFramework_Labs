
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace EduFrameworkDocsBuilder;

public sealed class LabInfo
{
    public string Name { get; init; } = "";
    public bool HasVietnamese { get; set; }
    public bool HasEnglish { get; set; }

    public override string ToString() => Name;
}

public sealed class LabScanner
{
    private readonly string repositoryRoot;
    public LabScanner(string repositoryRoot)
    {
        this.repositoryRoot = repositoryRoot;
    }

    public List<LabInfo> Scan()
    {
        var labs = new Dictionary<string, LabInfo>(
            StringComparer.Ordinal);
        ScanLanguage("vi", labs);
        ScanLanguage("en", labs);
        return labs.Values
            .OrderBy(lab => lab.Name, StringComparer.Ordinal)
            .ToList();
    }
    private void ScanLanguage(string language, Dictionary<string, LabInfo> labs)
    {
        string directory = Path.Combine(
            repositoryRoot,
            "documentation",
            language);
        if (!Directory.Exists(directory))
        {
            return;
        }
        foreach (string file in Directory.EnumerateFiles(
            directory, "lab_*.typ", SearchOption.TopDirectoryOnly))
        {
            string name = Path.GetFileNameWithoutExtension(file);
            if (!labs.TryGetValue(name, out LabInfo? lab))
            {
                lab = new LabInfo { Name = name };
                labs.Add(name, lab);
            }
            if (language == "vi")
            {
                lab.HasVietnamese = true;
            }
            else
            {
                lab.HasEnglish = true;
            }
        }
    }
}
