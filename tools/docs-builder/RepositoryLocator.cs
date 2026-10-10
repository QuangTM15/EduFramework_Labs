
using System;
using System.IO;

namespace EduFrameworkDocsBuilder;

public static class RepositoryLocator
{
    public static string FindRoot()
    {
        DirectoryInfo? directory =
            new DirectoryInfo(AppContext.BaseDirectory);
        while (directory != null)
        {
            string root = directory.FullName;
            bool hasDocumentation = Directory.Exists(
                Path.Combine(root, "documentation"));
            bool hasBuildScript = File.Exists(
                Path.Combine(root, "tools", "lab.ps1"));
            if (hasDocumentation && hasBuildScript)
            {
                return root;
            }
            directory = directory.Parent;
        }
        throw new DirectoryNotFoundException(
            "EduFramework_Labs repository not found. " +
            "Please run Docs Builder inside the repository.");
    }
}
