# src/functions/brent.jl
# Purpose: Implements the Brent test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctions. Non-scalable, unimodal function with a parabolic bowl and a Gaussian bump.
# Last modified: August 31, 2025

# Export the function, gradient, and constant for external use, following project conventions
export BRENT_FUNCTION, brent, brent_gradient

using LinearAlgebra
using ForwardDiff

# Brent function: f(x) = (x1 + 10)^2 + (x2 + 10)^2 + exp(-x1^2 - x2^2)
# Input: x::AbstractVector (no type restriction to handle ForwardDiff.Dual and edge cases)
# Throws ArgumentError for empty input or incorrect dimension (n != 2)
function brent(x::AbstractVector)
    # Check for empty input as required by edge case tests
    isempty(x) && throw(ArgumentError("Input vector cannot be empty"))
    # Check dimension (Brent is non-scalable, fixed at n=2)
    n = length(x)
    n != 2 && throw(ArgumentError("Brent requires exactly 2 dimensions"))
    # Handle NaN and Inf inputs
    any(isnan.(x)) && return NaN
    any(isinf.(x)) && return Inf
    # Extract components for clarity
    x1, x2 = x
    # Compute function value: quadratic terms + Gaussian term
    return (x1 + 10)^2 + (x2 + 10)^2 + exp(-x1^2 - x2^2)
end

# Gradient of the Brent function
# Returns: Vector with partial derivatives [∂f/∂x1, ∂f/∂x2]
# Compatible with ForwardDiff for automatic differentiation
function brent_gradient(x::AbstractVector)
    # Check for empty input
    isempty(x) && throw(ArgumentError("Input vector cannot be empty"))
    # Check dimension
    n = length(x)
    n != 2 && throw(ArgumentError("Brent requires exactly 2 dimensions"))
    # Handle NaN and Inf inputs
    any(isnan.(x)) && return fill(NaN, 2)
    any(isinf.(x)) && return fill(Inf, 2)
    # Extract components
    x1, x2 = x
    # Compute exponential term once for efficiency
    exp_term = exp(-x1^2 - x2^2)
    # Partial derivatives
    g1 = 2 * (x1 + 10) - 2 * x1 * exp_term
    g2 = 2 * (x2 + 10) - 2 * x2 * exp_term
    return [g1, g2]
end

# Define the TestFunction instance for Brent
# Follows the required structure: f, grad, meta with specific keys
# Metadata functions are parameterless since the function is non-scalable
const BRENT_FUNCTION = TestFunction(
    brent,  # Function
    brent_gradient,  # Gradient
    Dict(
        :name => "brent",  # Function name (string)
        :start => () -> [0.0, 0.0],  # Starting point for optimization
        :min_position => () -> [-10.0, -10.0],  # Global minimum location
        :min_value => 0.0,  # Function value at minimum
        :properties => Set(["continuous", "differentiable", "non-separable", "unimodal", "bounded"]),  # Properties from jamil2013.txt
        :lb => () -> [-10.0, -10.0],  # Lower bounds
        :ub => () -> [10.0, 10.0],  # Upper bounds
        :in_molga_smutnicki_2005 => false,  # Not in Molga & Smutnicki (2005)
        :description => "The Brent function is a non-scalable, unimodal test function with a parabolic bowl centered at (-10, -10) and a Gaussian bump at the origin.",  # Descriptive text
        :math => "f(x) = (x_1 + 10)^2 + (x_2 + 10)^2 + \\exp(-x_1^2 - x_2^2)"  # LaTeX formula
    )
)