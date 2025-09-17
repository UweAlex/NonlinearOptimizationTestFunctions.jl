# src/functions/chichinadze.jl
# Purpose: Defines the Chichinadze test function, its analytical gradient, and metadata.
# Context: Part of NonlinearOptimizationTestFunctions, used for testing optimization algorithms.
# Last modified: September 13, 2025

# Main function: chichinadze
# Purpose: Computes the Chichinadze function value at a given point x.
# Input:
#   - x: Vector{T}, input vector of length 2 where T <: Union{Real, ForwardDiff.Dual}
# Output:
#   - Real, the function value
# Used in: TestFunction.f for optimization and testing
function chichinadze(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Input vector must have length 2"))  # Validate dimension
    x1, x2 = x
    return x1^2 - 12*x1 + 11 + 10*cos(pi*x1/2) + 8*sin(5*pi*x1/2) - sqrt(0.2)*exp(-0.5*(x2 - 0.5)^2)
end #function

# Helper function: chichinadze_gradient
# Purpose: Computes the analytical gradient of the Chichinadze function at a given point x.
# Input:
#   - x: Vector{T}, input vector of length 2 where T <: Union{Real, ForwardDiff.Dual}
# Output:
#   - Vector{Real}, the gradient vector
# Used in: TestFunction.grad for optimization and gradient accuracy tests
function chichinadze_gradient(x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    length(x) == 2 || throw(ArgumentError("Input vector must have length 2"))  # Validate dimension
    x1, x2 = x
    grad = zeros(T, 2)
    grad[1] = 2*x1 - 12 - 5*pi*sin(pi*x1/2) + 20*pi*cos(5*pi*x1/2)  # Partial derivative w.r.t. x1
    grad[2] = sqrt(0.2) * (x2 - 0.5) * exp(-0.5*(x2 - 0.5)^2)        # Partial derivative w.r.t. x2
    return grad
end #function

# TestFunction definition
# Purpose: Defines the Chichinadze TestFunction with function, gradient, and metadata.
# Context: Registered in TEST_FUNCTIONS for use in optimization and testing.
const CHICHINADZE_FUNCTION = let
    meta = Dict{Symbol, Any}(
        :name => "chichinadze",
        :start => () -> [0.0, 0.0],                     # Starting point
        :min_position => () -> [6.189866586965680, 0.5],         # Global minimum position
        :min_value => () -> -42.94438701899099,        # Global minimum value (corrected)
        :properties => ["multimodal", "non-convex", "non-separable", "differentiable", "bounded"],  # Properties
        :lb => () -> [-30.0, -30.0],                   # Lower bounds
        :ub => () -> [30.0, 30.0]                      # Upper bounds
    )
    TestFunction(chichinadze, chichinadze_gradient, meta)
end #let

# Export function and gradient for external use
export chichinadze, chichinadze_gradient, CHICHINADZE_FUNCTION