using Documenter
using NonlinearOptimizationTestFunctions

# Setup DocTest, falls du @doctest verwendest
DocMeta.setdocmeta!(
    NonlinearOptimizationTestFunctions,
    :DocTestSetup,
    :(using NonlinearOptimizationTestFunctions);
    recursive=true,
)

makedocs(
    modules=[NonlinearOptimizationTestFunctions],
    authors="Uwe Alex",
    repo="https://github.com/UweAlex/NonlinearOptimizationTestFunctions.jl.git",
    sitename="NonlinearOptimizationTestFunctions.jl",
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://uwealex.github.io/NonlinearOptimizationTestFunctions.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Manual" => [
            "manual/installation.md",
            "manual/quickstart.md",
            "manual/box_constraints.md",
            "manual/examples.md",
            "manual/properties.md",
            "manual/testing.md",
            "manual/all_functions.md",  # Beachte: korrektes File
            "manual/roadmap.md",
        ],
        "API Reference" => "api.md",
    ],
    checkdocs=:skip  # überspringt fehlende Docstrings
)

# Deployment vorbereiten (lokal testen, ohne Push)
deploydocs(
    repo="github.com/UweAlex/NonlinearOptimizationTestFunctions.jl.git",
    target="build",
    devbranch="main",
    push_preview=true
)
