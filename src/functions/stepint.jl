# src/functions/stepint.jl
# Purpose: Implementation of the Stepint test function.
# Global minimum: f(x*)=25 - 6*D at x*≈(-5.12, ..., -5.12).
# Bounds: -5.12 ≤ x_i ≤ 5.12.

export STEPINT_FUNCTION, stepint, stepint_gradient

function stepint(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("stepint requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_val = zero(T)
    @inbounds for i in 1:n
        sum_val += floor(x[i])
    end
    sum_val + 25
end

function stepint_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("stepint requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    grad
end

const STEPINT_FUNCTION = TestFunction(
    stepint,
    stepint_gradient,
    Dict(
        :name => "stepint",
        :description => "Discontinuous and non-differentiable due to floor function; Properties based on Jamil & Yang (2013, function 141); Adapted for consistency: paper states min=0 at x=0 but formula gives f(0)=25; actual global min=25-6D at x_i≈-5.12 (floor(x_i)=-6 for all i).",
        :math => raw"""f(\mathbf{x}) = 25 + \sum_{i=1}^D \lfloor x_i \rfloor.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("stepint requires at least 1 dimension")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("stepint requires at least 1 dimension")); fill(-5.12, n) end,
        :min_value => (n::Int) -> 25 - 6 * n,
        :default_n => 2,
        :properties => ["partially differentiable", "separable", "scalable", "unimodal", "bounded", "non-convex"],
        :source => "Jamil & Yang (2013, function 141)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("stepint requires at least 1 dimension")); fill(-5.12, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("stepint requires at least 1 dimension")); fill(5.12, n) end,
    )
)

# Optional: Validierung beim Laden
@assert "stepint" == basename(@__FILE__)[1:end-3] "stepint: Dateiname mismatch!"