# Test Functions

## Overview
The package includes test functions accessible via `TEST_FUNCTIONS`, designed for nonlinear optimization with scalable metadata. Each function provides analytical gradients and metadata compatible with optimization packages like Optim.jl, NLopt, ForwardDiff, and Zygote.

## Rosenbrock
Properties: multimodal, non-convex, non-separable, differentiable, scalable, bounded
Minimum: [1.0, ..., 1.0] with value 0.0
Bounds: [-5.0, 5.0]^n
Mathematical Formulation: \( f(x) = \sum_{i=1}^{n-1} [100(x_{i+1} - x_i^2)^2 + (1 - x_i)^2] \)
Example:

    rosenbrock([0.5, 0.5]) # Returns 6.5

Description: The Rosenbrock function, also known as the "banana function," has a global minimum inside a long, narrow, parabolic-shaped valley. Finding the valley is relatively easy, but converging to the global minimum is challenging due to its non-convex nature.

## Sphere
Properties: unimodal, convex, separable, differentiable, scalable, bounded
Minimum: [0.0, ..., 0.0] with value 0.0
Bounds: [-5.12, 5.12]^n
Mathematical Formulation: \( f(x) = \sum_{i=1}^n x_i^2 \)
Example:

    sphere([1.0, 1.0]) # Returns 2.0

Description: The Sphere function is a convex, unimodal function with a single global minimum at the origin. It is useful for testing the efficiency of optimization algorithms on simple problems.

## Scalable Metadata
Access metadata for arbitrary dimensions:

    ROSENBROCK_FUNCTION.meta[:lb](3) # Returns [-5.0, -5.0, -5.0]
    SPHERE_FUNCTION.meta[:start](4) # Returns [0.0, 0.0, 0.0, 0.0]

Each test function is represented as a `TestFunction` struct with the following metadata fields:
- `:name`: String identifier (e.g., "Rosenbrock", "Sphere").
- `:start`: Function returning the starting point for dimension \( n \) (default: 2).
- `:min_position`: Function returning the global minimum position for dimension \( n \).
- `:min_value`: Scalar value at the global minimum (e.g., 0.0).
- `:properties`: Set of properties (e.g., `Set(["multimodal", "non-convex", ...])`).
- `:lb`: Function returning the lower bounds for dimension \( n \).
- `:ub`: Function returning the upper bounds for dimension \( n \).
- `:description`: Brief description of the function.
- `:math`: LaTeX string for the mathematical formulation.

## Note
Properties are stored in lowercase to ensure consistency. When using `has_property`, provide properties in lowercase, e.g., `has_property(tf, "multimodal")` instead of `has_property(tf, "Multimodal")`.

Last modified: 14. Juli 2025, 09:09 AM CEST