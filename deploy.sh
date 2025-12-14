#!/bin/bash
# deploy.sh für NonlinearOptimizationTestFunctions.jl
set -e  # Skript bei Fehler abbrechen

echo "=== Deploy-Skript gestartet ==="

# --- 1. Alle lokalen Änderungen committen und pushen ---
echo "Staging aller Änderungen..."
git add -A

echo "Committen der Änderungen..."
if git diff --quiet --staged; then
    echo "Keine Änderungen zum Committen."
else
    git commit -m "Deploy: Update code and documentation"
    echo "Änderungen committet."
fi

echo "Pushen zum main-Branch..."
git push origin main

# --- 2. Optional: Neuen Version-Tag erstellen und pushen ---
read -p "Neuen Version-Tag erstellen (z.B. v0.1.1) oder Enter zum Überspringen: " TAG

if [ ! -z "$TAG" ]; then
    echo "Erstelle Tag $TAG..."
    git tag -a "$TAG" -m "Release $TAG"
    git push origin "$TAG"
    echo "Tag $TAG erfolgreich gepusht."
else
    echo "Kein Tag erstellt – übersprungen."
fi

echo "Source code & tag deployed"

# --- 3. Dokumentation bauen & deployen ---
echo "Building and deploying documentation..."

# Aggressive Reinigung gegen hartnäckige Pkg-Probleme (MethodError, Caching)
echo "Performing hard Pkg reset: Deleting Manifest.toml files..."
rm -f Manifest.toml
rm -f docs/Manifest.toml

echo "Pkg.instantiate() im docs-Projekt..."
julia --project=docs -e 'using Pkg; Pkg.instantiate()'

echo "Starte make.jl → baut Docs und deployt via deploydocs()..."
julia --project=docs docs/make.jl

echo "=== Deployment abgeschlossen! ==="
echo "Die Dokumentation sollte in wenigen Minuten live sein unter:"
echo "https://uwealex.github.io/NonlinearOptimizationTestFunctions.jl/"
echo ""
echo "Stable-Version: https://uwealex.github.io/NonlinearOptimizationTestFunctions.jl/stable"
echo "Dev-Version:    https://uwealex.github.io/NonlinearOptimizationTestFunctions.jl/dev"