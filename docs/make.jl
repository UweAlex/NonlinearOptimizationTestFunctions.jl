using Documenter
using NonlinearOptimizationTestFunctions  # Dein Paket-Modul

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
        prettyurls=get(ENV, "CI", nothing) == "true",  # Schöne URLs auf GitHub Pages
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
        # Füge hier weitere Seiten hinzu, z. B.
        # "Benchmarks" => "benchmarks.md",
    ],
    doctest=true,      # Optional: Doctests ausführen
    strict=true,       # Fehlermeldungen bei Problemen
    checkdocs=:exports,  # Prüft, ob alle exportierten Symbole dokumentiert sind
)

deploydocs(
    repo="github.com/UweAlex/NonlinearOptimizationTestFunctions.jl.git",
    devbranch="main",
    branch="gh-pages",
    target="build",
    versions=["stable" => "v^", "v#.#.#", "dev" => "dev"],
    push_preview=true,  # Baut Previews für Pull Requests
)