using Documenter
using NonlinearOptimizationTestFunctions

DocMeta.setdocmeta!(
    NonlinearOptimizationTestFunctions,
    :DocTestSetup,
    :(using NonlinearOptimizationTestFunctions);
    recursive=true,
)

makedocs(
    sitename="NonlinearOptimizationTestFunctions.jl",
    authors="Uwe Alex",
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", nothing) == "true",
        canonical="https://uwealex.github.io/NonlinearOptimizationTestFunctions.jl",
        assets=String[],
        size_threshold_ignore=["manual/all_functions.md"],  # Ignore size check for the large function list page
    ),
    modules=[NonlinearOptimizationTestFunctions],
    pages=[
        "Home" => "index.md",  # Bewege index.md nach docs/src/, falls noch nicht dort
        "Installation" => "manual/installation.md",
        "Quick Start" => "manual/quickstart.md",
        "Usage" => "manual/usage.md",
        "All Functions" => "manual/all_functions.md",
        "Box Constraints" => "manual/box_constraints.md",
        "Examples" => "manual/examples.md",
        "Properties" => "manual/properties.md",
        "Testing" => "manual/testing.md",
        "Roadmap" => "manual/roadmap.md",
    ],
    doctest=true,
    checkdocs=:exports,
    warnonly=[:missing_docs, :cross_references],
)

deploydocs(
    repo="github.com/UweAlex/NonlinearOptimizationTestFunctions.jl.git",
    devbranch="master",
    branch="gh-pages",
    versions=["stable" => "v^", "v#.#.#", "dev" => "dev"],
    push_preview=true,
)