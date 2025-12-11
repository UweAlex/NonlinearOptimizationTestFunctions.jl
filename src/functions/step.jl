# src/functions/step.jl
# Purpose: Implementation of the Step test function.
# Global minimum: f(x*)=0.0 at x*=(0.0, ..., 0.0).
# Bounds: -100.0 ≤ x_i ≤ 100.0.

export STEP_FUNCTION, step, step_gradient

function step(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("step requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_val = zero(T)
    @inbounds for i in 1:n
        sum_val += floor(abs(x[i]))
    end
    sum_val
end

function step_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("step requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    grad
end

const STEP_FUNCTION = TestFunction(
    step,
    step_gradient,
    Dict(
        :name => "step",
        :description => "Discontinuous and non-differentiable due to floor function; Properties based on Jamil & Yang (2013, function 138); originally from benchmark collections.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^D \lfloor |x_i| \rfloor.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("step requires at least 1 dimension")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("step requires at least 1 dimension")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,
        :default_n => 2,
        :properties => ["partially differentiable", "separable", "scalable", "unimodal", "bounded", "non-convex"],
        :source => "Jamil & Yang (2013, function 138)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("step requires at least 1 dimension")); fill(-100.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("step requires at least 1 dimension")); fill(100.0, n) end,
    )
)

# Optional: Validierung beim Laden
