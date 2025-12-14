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
    ),
    modules=[NonlinearOptimizationTestFunctions],
    pages=[
        "Home" => "index.md",
        "Installation" => "installation.md",
        "Quick Start" => "quickstart.md",
        "Available Test Functions" => "functions.md",
        "API Reference" => "api.md",
        # Füge hier weitere Seiten hinzu, falls vorhanden
    ],
    doctest=true,           # Führt Doctests aus
    checkdocs=:exports,     # Prüft, ob alle exportierten Funktionen dokumentiert sind
    # strict = true          ← ENTFERNT! Existiert nicht mehr
    warnonly=[:missing_docs, :cross_references],  # Optional: Nur Warnungen bei fehlenden DocStrings etc., kein Abbruch
)

deploydocs(
    repo="github.com/UweAlex/NonlinearOptimizationTestFunctions.jl.git",
    devbranch="master",     # Dein Default-Branch ist master
    branch="gh-pages",
    versions=["stable" => "v^", "v#.#.#", "dev" => "dev"],
    push_preview=true,
)