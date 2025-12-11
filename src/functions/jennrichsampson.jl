# src/functions/jennrichsampson.jl
# Purpose: Implementation of the Jennrich-Sampson test function.
# Context: Non-scalable (n=2), continuous, differentiable, non-separable, multimodal.
# Global minimum: f(x*)=124.36218236 at x*=[0.257825, 0.257825].
# Bounds: -1 ≤ x_i ≤ 1.
# Last modified: September 27, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export JENNRICHSAMPSON_FUNCTION, jennrichsampson, jennrichsampson_gradient

function jennrichsampson(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Jennrich-Sampson requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2 = x[1], x[2]
    sum_sq = zero(T)
    @inbounds for i in 1:10
        term = 2 + 2*i - (exp(i * x1) + exp(i * x2))
        sum_sq += term^2
    end
    sum_sq
end

function jennrichsampson_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Jennrich-Sampson requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    x1, x2 = x[1], x[2]
    grad = zeros(T, 2)
    @inbounds for i in 1:10
        exp1 = exp(i * x1)
        exp2 = exp(i * x2)
        term = 2 + 2*i - (exp1 + exp2)
        grad[1] += 2 * term * (-i * exp1)
        grad[2] += 2 * term * (-i * exp2)
    end
    grad
end

const JENNRICHSAMPSON_FUNCTION = TestFunction(
    jennrichsampson,
    jennrichsampson_gradient,
    Dict(
        :name => "jennrichsampson",
        :description => "The Jennrich-Sampson function. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{10} \left(2 + 2i - (e^{i x_1} + e^{i x_2})\right)^2 """,
        :start => () -> [0.0, 0.0],
         :min_position => () -> [0.2578252136705121, 0.2578252136701835],
  :min_value => () -> 124.36218235561489,

        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jennrich and Sampson (1968)",
        :lb => () -> [-1.0, -1.0],
        :ub => () -> [1.0, 1.0],
    )
)