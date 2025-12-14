# NonlinearOptimizationTestFunctions.jl

Comprehensive collection of **over 200 nonlinear optimization test functions** with analytical gradients, metadata and domain-safe box-constraint handling.

## Highlights

- More than 200 classic and modern benchmark functions
- Verified analytical gradients (ForwardDiff & Zygote)
- Rich metadata: global minima, bounds, modality, convexity, separability, scalability, etc.
- Domain-safe box-constraint wrapper (`with_box_constraints`)
- Over 350 rigorous automated tests with 100 % critical-path coverage
- Full compatibility with Optim.jl, NLopt.jl, GalacticOptim.jl, BlackBoxOptim.jl and more

## Quick Links

- [Installation & Quick Start](manual/installation.md)
- [Box-Constraint Wrapper](manual/box_constraints.md)
- [Examples](manual/examples.md)
- [All Functions](manual/all_functions.md)
- [Properties](manual/properties.md)
- [Testing Strategy](manual/testing.md)
- [Roadmap](manual/roadmap.md)
- [API Reference](api.md)