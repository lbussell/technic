#!/usr/bin/env dotnet

#:package CliWrap@3.10.0

using CliWrap;
using CliWrap.Buffered;
using static System.Console;

internal static class Program
{
    private const string OpenscadEnvVar = "OPENSCAD_PATH";
    private const string Usage = $"""
        Usage: dotnet Render.cs -- path/to/part1.scad path/to/part2.scad ...
        Optionally set {OpenscadEnvVar} to your OpenSCAD executable if it is not on the PATH.
        """;

    private static async Task Main(string[] args)
    {
        if (args.Length == 0
            || args.Contains("--help", StringComparer.OrdinalIgnoreCase)
            || args.Contains("-h", StringComparer.OrdinalIgnoreCase))
        {
            WriteLine(Usage);
            return;
        }

        var openscad = GetOpenscad();
        Directory.CreateDirectory("renders");
        openscad.OutputDirectory = "renders";

        var imageTasks = args.Select(Part.Create)
                             .Select(openscad.RenderImage);

        var images = await Task.WhenAll(imageTasks);
        WriteLine(string.Join(Environment.NewLine, images.Select(image => image.Path)));
    }

    private static Openscad GetOpenscad()
    {
        var openscadExePath = Environment.GetEnvironmentVariable(OpenscadEnvVar);
        openscadExePath ??= "openscad";
        return new Openscad(openscadExePath);
    }
}

record Part
{
    private Part(string filePath) => FilePath = filePath;

    public static Part Create(string filePath)
    {
        if (!File.Exists(filePath))
            throw new FileNotFoundException("The specified file does not exist.", filePath);

        if (Path.GetExtension(filePath) != ".scad")
            throw new ArgumentException("The specified file is not a an '.scad' file.", nameof(filePath));

        return new(filePath);
    }

    public string FilePath { get; }
    public string Name => Path.GetFileNameWithoutExtension(FilePath);
}

class Openscad(string executablePath)
{
    private readonly Command _openScad = Cli.Wrap(executablePath);

    public string OutputDirectory { get; set; } = Directory.GetCurrentDirectory();

    public Task<RenderingResult> RenderImage(Part part) => Render(part, "png");

    private async Task<RenderingResult> Render(Part part, string format)
    {
        var fileName = $"{part.Name}.{format}";
        var output = Path.Combine(OutputDirectory, fileName);
        await RunAsync($"{part.FilePath} -o {output}");
        return new RenderingResult(fileName);
    }

    private Task<BufferedCommandResult> RunAsync(string arguments) =>
        _openScad.WithArguments(arguments).ExecuteBufferedAsync();
}

record RenderingResult(string Path);

record RenderSettings();

class RenderingException(string message) : Exception(message);
