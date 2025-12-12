using Documenter
using NonlinearOptimizationTestFunctions

# DocTest setup
DocMeta.setdocmeta!(
    NonlinearOptimizationTestFunctions,
    :DocTestSetup,
    :(using NonlinearOptimizationTestFunctions);
    recursive=true,
)

makedocs(
    modules=[NonlinearOptimizationTestFunctions],
    authors="Uwe Alex",
    sitename="NonlinearOptimizationTestFunctions.jl",

    # Kein GitTools nötig – HTML repolink reicht für Navbar
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://uwealex.github.io/NonlinearOptimizationTestFunctions.jl",
        repolink="https://github.com/UweAlex/NonlinearOptimizationTestFunctions.jl",
        assets=String[],
    ), pages=[
        "Home" => "index.md",
        "Manual" => [
            "manual/installation.md",
            "manual/quickstart.md",
            "manual/box_constraints.md",
            "manual/examples.md",
            "manual/properties.md",
            "manual/testing.md",
            "manual/all_functions.md",
            "manual/roadmap.md",
        ],
        "API Reference" => "api.md",
    ], checkdocs=:warn,
)
