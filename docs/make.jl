# docs/make.jl
using Documenter
using NonlinearOptimizationTestFunctions

makedocs(
    sitename = "NonlinearOptimizationTestFunctions",
    authors = "aox",
    modules = [NonlinearOptimizationTestFunctions],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://yourusername.github.io/NonlinearOptimizationTestFunctions/stable",
        assets = ["assets/custom.css"]
    ),
    pages = [
        "Home" => "index.md",
        "Installation" => "installation.md",
        "Test Functions" => "functions.md",
        "Demos" => "demos.md",
        "API Reference" => "api.md"
    ],
    warnonly = [:missing_docs],
    checkdocs = :all,
    doctest = true
)

deploydocs(
    repo = "github.com/yourusername/NonlinearOptimizationTestFunctions.jl.git",
    devbranch = "main",
    push_preview = true
)