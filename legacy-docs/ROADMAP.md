# Roadmap for NonlinearOptimizationTestFunctions.jl

## Introduction
Welcome to the roadmap for the NonlinearOptimizationTestFunctions.jl suite! This document outlines future development plans, focusing on extending the suite to include test functions with constraints for constrained optimization in Julia, compatible with Optim.jl and other optimization frameworks.

## Support for Test Functions with Constraints
Objective: Extend the suite to include test functions with inequality and equality constraints, enabling testing of constrained optimization algorithms such as IPNewton in Optim.jl.

### Motivation
- Many real-world optimization problems involve constraints (e.g., sum(x_i) <= 0).
- The goal is to enhance the suite for constrained optimization, starting with a complete implementation of shubert_constrained.jl.

### Planned Implementation
- Property "constrained": Add "constrained" to VALID_PROPERTIES in NonlinearOptimizationTestFunctions.jl to support functions with constraints.
- Constraints Format: Store constraints in a dictionary: :constraints => Dict(:inequality => Vector{Function}, :equality => Vector{Function}).
  - Example for shubert_constrained.jl: :constraints => Dict(:inequality => [(x::AbstractVector) -> sum(x)], :equality => []), representing sum(x_i) <= 0.
- Test Updates: Modify runtests.jl to validate :constraints for start points and minima, ensuring feasibility.
- Optim.jl Integration: Add tests using constrained algorithms (e.g., IPNewton) to verify compatibility.
- Additional Functions: Implement further constrained functions, such as constrained_rastrigin.jl and constrained_ackley.jl.

### Example: shubert_constrained.jl
The shubert_constrained.jl function serves as the first complete implementation of a constrained test function. Details:
- Function: Based on the classical Shubert function, defined as f(x) = prod_{i=1}^n sum_{j=1}^5 j * cos((j+1)x_i + j), with a linear constraint sum(x_i) <= 0.
- Properties: ["continuous", "differentiable", "non-separable", "scalable", "multimodal", "constrained"].
- Global Minimum: -186.7309 at feasible points, e.g., [-7.0835, 4.8580] for n=2.
- Bounds: -10.0 <= x_i <= 10.0 for each dimension.
- Constraints: Stored as :constraints => Dict(:inequality => [(x::AbstractVector) -> sum(x)], :equality => []).
- Tests: Validate the minimum, gradient (via ForwardDiff), and constraint feasibility. Integration with Optim.jl’s IPNewton algorithm will be tested.
- Source: Jamil & Yang (2013, p. 55).

### Timeline
| Phase | Tasks | Timeframe | Status |
|-------|-------|-----------|--------|
| Phase 1 | Validate shubert_constrained.jl, add "constrained" to VALID_PROPERTIES | Q1 2026 | In Planning |
| Phase 2 | Implement additional constrained functions (e.g., constrained_rastrigin.jl) | Q2 2026 | Planned |
| Phase 3 | Test with Optim.jl (IPNewton) and update documentation | Q3 2026 | Planned |

### Visual Timeline
Below is a Gantt chart for the planned development:

gantt
    title Roadmap: Constrained Test Functions
    dateFormat  YYYY-MM-DD
    section Planning
    Research & Design       :active,  des1, 2026-01-01, 3m
    Implementation          :         des2, after des1, 3m
    Tests with Optim.jl     :         des3, after des2, 3m
    Documentation           :         des4, after des3, 3m

### Links
- Discussion: [Issue #123](https://github.com/USER/NonlinearOptimizationTestFunctions.jl/issues/123)
- Project: [Constrained Test Functions Project](https://github.com/USER/NonlinearOptimizationTestFunctions.jl/projects/1)
- Code: See src/functions/shubert_constrained.jl for the initial implementation.

### Feedback
We welcome your suggestions! Please create a [new issue](https://github.com/USER/NonlinearOptimizationTestFunctions.jl/issues/new) or comment on [Issue #123](https://github.com/USER/NonlinearOptimizationTestFunctions.jl/issues/123).

## Additional Future Developments
- Support for additional properties (e.g., "ill-conditioned").
- Integration with other optimization frameworks (e.g., NLopt).

*Last Updated: October 17, 2025*