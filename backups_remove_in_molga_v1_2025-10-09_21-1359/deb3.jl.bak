# src/functions/deb3.jl
# Purpose: Implementation of the Deb's Function No.3 test function.
# Context: Scalable, from Rönkkönen (2009).
# Global minimum: f(x*)=-1 at multiple points (5^n global minima).
# Bounds: -1 ≤ x_i ≤ 1.
# Last modified: September 24, 2025.

export DEB3_FUNCTION, deb3, deb3_gradient

using LinearAlgebra: sign  # for sign function

function deb3(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("Deb3 requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_s6 = zero(T)
    @inbounds for i in 1:n
        xi = x[i]
        u = abs(xi)^(3//4)
        arg = 5 * pi * (u - 0.05)
        s6 = sin(arg)^6
        sum_s6 += s6
    end
    return -sum_s6 / n
end

function deb3_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("Deb3 requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    factor = -one(T) / n
    @inbounds for i in 1:n
        xi = x[i]
        u = abs(xi)^(3//4)
        arg = 5 * pi * (u - 0.05)
        s = sin(arg)
        c = cos(arg)
        if abs(xi) > 1e-12
            du_dxi = (3//4) * abs(xi)^(-1//4) * sign(xi)
        else
            du_dxi = zero(T)  # Approximate to avoid Inf
        end
        darg_dxi = 5 * pi * du_dxi
        ds6_darg = 6 * s^5 * c
        grad[i] = factor * ds6_darg * darg_dxi
    end
    return grad
end

const DEB3_FUNCTION = TestFunction(
    deb3,
    deb3_gradient,
    Dict(
        :name => "deb3",
        :description => "Deb's Function No.3 (Rönkkönen, 2009): A scalable, separable, multimodal function with 5^D evenly spaced global minima at f=-1.",
        :math => raw"""f(\mathbf{x}) = -\frac{1}{D} \sum_{i=1}^{D} \sin^6 \left(5 \pi (x_i^{3/4} - 0.05)\right) """,
        :start => (n::Int) -> (n < 1 && throw(ArgumentError("At least 1 dimension")); zeros(n)),
        :min_position => (n::Int) -> (n < 1 && throw(ArgumentError("At least 1 dimension")); fill(0.07969939268869583, n)),
        :min_value => (n::Int) -> (n < 1 && throw(ArgumentError("At least 1 dimension")); -1.0),
        :properties => ["bounded", "continuous", "differentiable", "separable", "multimodal", "scalable"],
        :default_n => 2,
        :lb => (n::Int) -> (n < 1 && throw(ArgumentError("At least 1 dimension")); fill(-1.0, n)),
        :ub => (n::Int) -> (n < 1 && throw(ArgumentError("At least 1 dimension")); fill(1.0, n)),
    )
)
