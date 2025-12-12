#!/bin/bash
# deploy.sh
# Kombiniertes Skript: Quellcode pushen + Dokumentation bauen und deployen

set -e  # Stoppt bei Fehlern

# --- 1. Push Quellcode auf master ---
echo "=== Pushing source code to master ==="
cd /c/Users/uweal/NonlinearOptimizationTestFunctions.jl

git add .
git commit -m "new testfunctions"
git push origin master

# Tag erstellen und pushen
VERSION="v0.6.7"
git tag $VERSION
git push origin $VERSION
echo "Source code pushed and tagged as $VERSION"

# --- 2. Build Dokumentation ---
echo "=== Building documentation ==="
julia --project=docs -e 'include("docs/make.jl")'

# --- 3. Deploy Dokumentation auf gh-pages ---
echo "=== Deploying documentation to gh-pages ==="
cd docs/build

# Git-Repo initialisieren, falls noch nicht vorhanden
if [ ! -d ".git" ]; then
    git init
    git remote add origin https://github.com/UweAlex/NonlinearOptimizationTestFunctions.jl.git
fi

git checkout -B gh-pages
git add .
git commit -m "Deploy docs $VERSION"
git push -f origin gh-pages

echo "Deployment complete!"
