# src/functions/deb1.jl
# Purpose: Implementation of the Deb's Function No.1 test function.
# Context: Scalable, from Rönkkönen (2009).
# Global minimum: f(x*)=-1 at multiple points, e.g., x_i = {-0.9, -0.7, -0.5, -0.3, -0.1, 0.1, 0.3, 0.5, 0.7, 0.9} for each dimension (10^n global minima).
# Bounds: -1 ≤ x_i ≤ 1.
# Last modified: September 24, 2025.

export DEB1_FUNCTION, deb1, deb1_gradient

function deb1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("Deb1 requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_sq = zero(T)
    @inbounds for i in 1:n
        arg = 5 * pi * x[i]
        s = sin(arg)
        sum_sq += s^6
    end
    return -one(T) / n * sum_sq
end

function deb1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("Deb1 requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    factor = -5 * pi / n
    @inbounds for i in 1:n
        arg = 5 * pi * x[i]
        s = sin(arg)
        c = cos(arg)
        grad[i] = factor * 6 * s^5 * c
    end
    return grad
end

const DEB1_FUNCTION = TestFunction(
    deb1,
    deb1_gradient,
    Dict(
        :name => "deb1",
        :description => "Deb's Function No.1 (Rönkkönen, 2009): A scalable, separable, multimodal function with 10^D evenly spaced global minima at f=-1.",
        :math => raw"""f(\mathbf{x}) = -\frac{1}{D} \sum_{i=1}^{D} \sin^{6}(5 \pi x_i) """,
        :start => (n::Int) -> (n < 1 && throw(ArgumentError("At least 1 dimension")); zeros(n)),
        :min_position => (n::Int) -> (n < 1 && throw(ArgumentError("At least 1 dimension")); fill(-0.9, n)),
        :min_value => (n::Int) -> (n < 1 && throw(ArgumentError("At least 1 dimension")); -1.0),
        :properties => ["bounded", "continuous", "differentiable", "separable", "multimodal", "scalable"],
        :lb => (n::Int) -> (n < 1 && throw(ArgumentError("At least 1 dimension")); fill(-1.0, n)),
        :ub => (n::Int) -> (n < 1 && throw(ArgumentError("At least 1 dimension")); fill(1.0, n)),
    )
)