# NonlinearOptimizationTestFunctions.jl

Comprehensive collection of over 200 nonlinear optimization test functions with analytical gradients, metadata and domain-safe box-constraint handling.

## Highlights
- Verified analytical gradients (via ForwardDiff & Zygote)
- Rich metadata (global minima, bounds, modality, convexity, etc.)
- Domain-safe box-constraint wrapper (`with_box_constraints`)
- Over 350 automated tests with 100% critical-path coverage
- Compatible with Optim.jl, NLopt.jl, GalacticOptim.jl, BlackBoxOptim.jl

## Quick Links
- [Installation & Quick Start](manual/installation.md)
- [Box-Constraint Wrapper](manual/box_constraints.md)
- [Examples](manual/examples.md)
- [All Functions](manual/all_functions.md)
- [Properties](manual/properties.md)
- [Testing Strategy](manual/testing.md)
- [Roadmap](manual/roadmap.md)