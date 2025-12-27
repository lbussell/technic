#!/usr/bin/env dotnet

#:package CliWrap@3.10.0

using CliWrap;
using CliWrap.Buffered;
using System.Text.Json;
using System.Text.Json.Serialization;
using static System.Console;

internal static class Program
{
    private const string OpenscadEnvVar = "OPENSCAD_PATH";
    private const string Usage = $"""
        Usage: dotnet Render.cs -- parts.json
        Optionally set {OpenscadEnvVar} to your OpenSCAD executable if it is not on the PATH.
        """;

    private static async Task<int> Main(string[] args)
    {
        if (args.Length != 1
            || args.Contains("--help", StringComparer.OrdinalIgnoreCase)
            || args.Contains("-h", StringComparer.OrdinalIgnoreCase))
        {
            WriteLine(Usage);
            return 1;
        }

        var jsonPath = args[0];
        var jsonContent = File.ReadAllText(jsonPath);
        var partsConfig = JsonSerializer.Deserialize(jsonContent, JsonContext.Default.PartsConfig);

        if (partsConfig is null)
        {
            WriteLine("Failed to parse JSON file.");
            return 1;
        }

        IEnumerable<Part> parts = [
            ..partsConfig.Parts,
            ..partsConfig.Matrix.SelectMany(m => m.Expand()),
        ];

        var openscad = GetOpenscad();
        Directory.CreateDirectory("renders");
        Directory.CreateDirectory("stl");

        var renderTasks =
            parts.SelectMany(part => new[]
                {
                    openscad.RenderImage(part, outputDirectory: "renders"),
                    openscad.RenderStl(part, outputDirectory: "stl")
                });

        var results = await Task.WhenAll(renderTasks);
        WriteLine($"Rendered {results.Length} items.");
        return 0;
    }

    private static Openscad GetOpenscad()
    {
        var openscadExePath = Environment.GetEnvironmentVariable(OpenscadEnvVar);
        openscadExePath ??= "openscad";
        return new Openscad(openscadExePath);
    }
}

record PartMatrix
{
    public string Path { get; init; } = "";
    public Dictionary<string, JsonElement> Parameters { get; init; } = [];

    public IEnumerable<Part> Expand()
    {
        if (Parameters == null || Parameters.Count == 0)
        {
            yield return Part.Create(Path);
            yield break;
        }

        // Extract parameter names and their value arrays
        var parameterSets = new List<(string Key, List<object> Values)>();
        foreach (var (key, jsonElement) in Parameters)
        {
            var values = new List<object>();
            if (jsonElement.ValueKind == JsonValueKind.Array)
            {
                foreach (var element in jsonElement.EnumerateArray())
                {
                    values.Add(ParseJsonValue(element));
                }
            }
            else
            {
                values.Add(ParseJsonValue(jsonElement));
            }
            parameterSets.Add((key, values));
        }

        // Generate all combinations (cartesian product)
        foreach (var combination in CartesianProduct(parameterSets))
        {
            var parameters = combination.ToDictionary(x => x.Key, x => x.Value);
            var name = GenerateUniqueName(Path, parameters);
            yield return Part.Create(Path, name, parameters);
        }
    }

    private static object ParseJsonValue(JsonElement element)
    {
        return element.ValueKind switch
        {
            JsonValueKind.Number => element.TryGetInt32(out var intValue) ? intValue : element.GetDouble(),
            JsonValueKind.String => element.GetString() ?? "",
            JsonValueKind.True => true,
            JsonValueKind.False => false,
            _ => element.ToString()
        };
    }

    private static string GenerateUniqueName(string filePath, Dictionary<string, object> parameters)
    {
        var baseName = System.IO.Path.GetFileNameWithoutExtension(filePath);
        var paramParts = parameters.Select(kvp =>
        {
            var shortKey = string.Concat(kvp.Key.Split('_').Select(part => part[0]));
            var value = kvp.Value.ToString()?.Replace(".", "") ?? "";
            return $"{shortKey}{value}";
        });
        return $"{baseName}_{string.Join("_", paramParts)}";
    }

    private static IEnumerable<List<(string Key, object Value)>> CartesianProduct(
        List<(string Key, List<object> Values)> sets)
    {
        if (sets.Count == 0)
        {
            yield return new List<(string, object)>();
            yield break;
        }

        var first = sets[0];
        var rest = sets.Skip(1).ToList();

        foreach (var value in first.Values)
        {
            foreach (var restCombination in CartesianProduct(rest))
            {
                var combination = new List<(string Key, object Value)> { (first.Key, value) };
                combination.AddRange(restCombination);
                yield return combination;
            }
        }
    }
}

record PartsConfig
{
    public IEnumerable<PartMatrix> Matrix { get; init; } = [];
    public IEnumerable<Part> Parts { get; init; } = [];
}

[JsonSourceGenerationOptions(PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase)]
[JsonSerializable(typeof(PartsConfig))]
internal partial class JsonContext : JsonSerializerContext
{
}

record Part
{
    public string Path { get; init; } = "";
    public string? Name { get; init; }
    public Dictionary<string, object> Parameters { get; init; } = [];

    public static Part Create(string filePath, string? name = null, Dictionary<string, object>? parameters = null)
    {
        if (!File.Exists(filePath))
            throw new FileNotFoundException("The specified file does not exist.", filePath);

        if (System.IO.Path.GetExtension(filePath) != ".scad")
            throw new ArgumentException("The specified file is not a an '.scad' file.", nameof(filePath));

        return new Part { Path = filePath, Name = name, Parameters = parameters ?? [] };
    }

    public string FilePath => Path;
    public string FileName => Name ?? System.IO.Path.GetFileNameWithoutExtension(Path);
}

class Openscad(string executablePath)
{
    private readonly Command _openScad = Cli.Wrap(executablePath);

    public Task<RenderingResult> RenderImage(Part part, string outputDirectory) =>
        Render(part, "png", outputDirectory);

    public Task<RenderingResult> RenderStl(Part part, string outputDirectory) =>
        Render(part, "stl", outputDirectory);

    private async Task<RenderingResult> Render(Part part, string format, string outputDirectory)
    {
        var fileName = $"{part.FileName}.{format}";
        var output = Path.Combine(outputDirectory, fileName);
        var arguments = $"{part.FilePath} -o {output}";

        if (part.Parameters != null)
        {
            foreach (var (key, value) in part.Parameters)
            {
                arguments += $" -D {key}={FormatParameterValue(value)}";
            }
        }

        await RunAsync(arguments);
        WriteLine(output);
        return new RenderingResult(fileName);
    }

    private static string FormatParameterValue(object value) => value switch
    {
        string s => $"\"{s}\"",
        bool b => b ? "true" : "false",
        _ => value.ToString() ?? ""
    };

    private Task<BufferedCommandResult> RunAsync(string arguments) =>
        _openScad.WithArguments(arguments).ExecuteBufferedAsync();
}

record RenderingResult(string Path);

record RenderSettings();

class RenderingException(string message) : Exception(message);
