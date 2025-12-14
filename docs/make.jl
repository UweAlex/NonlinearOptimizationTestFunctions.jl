using Documenter
using NonlinearOptimizationTestFunctions

DocMeta.setdocmeta!(
    NonlinearOptimizationTestFunctions,
    :DocTestSetup,
    :(using NonlinearOptimizationTestFunctions);
    recursive = true,
)

makedocs(
    sitename = "NonlinearOptimizationTestFunctions.jl",
    authors = "Uwe Alex",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://uwealex.github.io/NonlinearOptimizationTestFunctions.jl",
        assets = String[],
    ),
    modules = [NonlinearOptimizationTestFunctions],
    pages = [],  # Leer, da keine .md-Dateien mehr existieren – baut nur autogenerierte Docs
    doctest = true,
    checkdocs = :exports,
    warnonly = [:missing_docs, :cross_references],  # Warnt, bricht nicht ab
)

deploydocs(
    repo = "github.com/UweAlex/NonlinearOptimizationTestFunctions.jl.git",
    devbranch = "master",
    branch = "gh-pages",
    versions = ["stable" => "v^", "v#.#.#", "dev" => "dev"],
    push_preview = true,
)