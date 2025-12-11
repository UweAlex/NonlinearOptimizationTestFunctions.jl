# src/functions/eggcrate.jl
# Purpose: Implementation of the Egg Crate test function.
# Context: Non-scalable, 2-dimensional, multimodal, separable function.
# Global minimum: f(x*)=0 at x*=[0,0].
# Bounds: -5 ≤ x_i ≤ 5.
# Last modified: September 26, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export EGGRATE_FUNCTION, eggcrate, eggcrate_gradient

function eggcrate(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Egg Crate requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x
    x1^2 + x2^2 + 25 * (sin(x1)^2 + sin(x2)^2)
end

function eggcrate_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Egg Crate requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x
    grad = zeros(T, 2)
    @inbounds begin
        grad[1] = 2 * x1 + 50 * sin(x1) * cos(x1)
        grad[2] = 2 * x2 + 50 * sin(x2) * cos(x2)
    end
    grad
end

const EGGRATE_FUNCTION = TestFunction(
    eggcrate,
    eggcrate_gradient,
    Dict(
        :name => "eggcrate",
        :description => "Egg Crate test function as standardized in Jamil & Yang (2013). Multimodal, separable function in 2 dimensions. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = x_1^2 + x_2^2 + 25 (\sin^2 x_1 + \sin^2 x_2).""",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "separable", "multimodal"],
        :source => "Jamil & Yang (2013)",
        :lb => () -> [-5.0, -5.0],
        :ub => () -> [5.0, 5.0],
    )
)