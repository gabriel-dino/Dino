using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Text;
using System.Windows.Forms;

[assembly: AssemblyTitle("DINO - Desert Run")]
[assembly: AssemblyDescription("DINO portable Windows x64 launcher")]
[assembly: AssemblyVersion("1.2.0.0")]

internal static class Launcher
{
    // Quote according to CommandLineToArgvW, including trailing backslashes.
    private static string Quote(string value)
    {
        var result = new StringBuilder("\"");
        int slashes = 0;
        foreach (char c in value)
        {
            if (c == '\\') { slashes++; continue; }
            result.Append('\\', c == '"' ? slashes * 2 + 1 : slashes);
            result.Append(c);
            slashes = 0;
        }
        result.Append('\\', slashes * 2);
        return result.Append('"').ToString();
    }

    [STAThread]
    private static int Main(string[] args)
    {
        string directory = Path.Combine(Path.GetTempPath(), "Dino-" + Guid.NewGuid().ToString("N"));
        try
        {
            Directory.CreateDirectory(directory);
            using (Stream stream = Assembly.GetExecutingAssembly().GetManifestResourceStream("Dino.Payload.zip"))
            using (var archive = new ZipArchive(stream, ZipArchiveMode.Read))
                archive.ExtractToDirectory(directory);

            var arguments = new StringBuilder();
            foreach (string arg in args) arguments.Append(Quote(arg)).Append(' ');
            var start = new ProcessStartInfo(Path.Combine(directory, "Dino.exe"), arguments.ToString());
            start.WorkingDirectory = directory;
            start.UseShellExecute = false;
            using (Process game = Process.Start(start))
            {
                game.WaitForExit();
                return game.ExitCode;
            }
        }
        catch (Exception error)
        {
            MessageBox.Show(error.Message, "DINO - Desert Run", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
        finally
        {
            try { Directory.Delete(directory, true); }
            catch (IOException) { }
            catch (UnauthorizedAccessException) { }
        }
    }
}
