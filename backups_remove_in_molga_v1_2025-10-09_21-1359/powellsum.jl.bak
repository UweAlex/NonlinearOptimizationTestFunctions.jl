# src/functions/powellsum.jl
# Powell Sum Function (f93)
# f(x) = sum_{i=1}^n |x_i|^(i+1)
# Domain: -1 <= x_i <= 1
# Global minimum: 0 at x = (0, ..., 0)
# Last modified: 2025-10-01
# Properties: separable, scalable, unimodal, continuous, differentiable
# Properties source: Jamil & Yang (2013)

export POWELLSUM_FUNCTION, powellsum, powellsum_gradient

function powellsum(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    s = zero(T)
    @inbounds for i in 1:n
        p = i + 1
        s += abs(x[i])^p
    end
    s
end

function powellsum_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    grad = zeros(T, n)
    @inbounds for i in 1:n
        p = i + 1
        xi = x[i]
        abs_xi = abs(xi)
        if abs_xi == zero(T)
            grad[i] = zero(T)
        else
            grad[i] = p * sign(xi) * abs_xi^(p - 1)
        end
    end
    grad
end

const POWELLSUM_FUNCTION = TestFunction(
    powellsum,
    powellsum_gradient,
    Dict(
        :name => "powellsum",
        :description => "Powell Sum Function with separable terms. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n |x_i|^{i+1}.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("n must be >= 1")); fill(0.5, n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("n must be >= 1")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "separable", "scalable", "unimodal"],
        :default_n => 2,
        :properties_source => "Jamil & Yang (2013)",
        :source => "Rahnamyan et al. (2007a)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("n must be >= 1")); fill(-1.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("n must be >= 1")); fill(1.0, n) end,
    )
)
