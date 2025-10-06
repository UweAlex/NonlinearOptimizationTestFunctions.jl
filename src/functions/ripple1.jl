# src/functions/ripple1.jl
# Purpose: Implementation of the Ripple 1 test function.
# Global minimum: f(x*)= -2.2 at x*=[0.1, 0.1].
# Bounds: 0 ≤ x_i ≤ 1.

export RIPPLE1_FUNCTION, ripple1, ripple1_gradient

function ripple1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Ripple 1 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    total = zero(T)
    ln2 = log(T(2))
    @inbounds for i in 1:2
        xi = x[i]
        exp_arg = 2 * ln2 * ((xi - T(0.1)) / T(0.8))^2
        g = exp(-exp_arg)
        sin6 = sin(5 * pi * xi)^6
        cos2 = T(0.1) * cos(500 * pi * xi)^2
        inner = sin6 + cos2
        total -= g * inner
    end
    total
end

function ripple1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Ripple 1 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    ln2 = log(T(2))
    @inbounds for i in 1:2
        xi = x[i]
        exp_arg = 2 * ln2 * ((xi - T(0.1)) / T(0.8))^2
        g = exp(-exp_arg)
        sin6 = sin(5 * pi * xi)^6
        cos2 = T(0.1) * cos(500 * pi * xi)^2
        inner = sin6 + cos2
        
        # dg/dxi = -g * (4 * ln2 * (xi - 0.1) / 0.8^2)
        dg_dxi = -g * (4 * ln2 * (xi - T(0.1)) / T(0.64))
        
        # d_inner/dxi = 6 sin^5 (5πxi) cos(5πxi) * 5π + 0.1 * 2 cos(500πxi) (-sin(500πxi)) * 500π
        d_sin6_dxi = 6 * sin(5 * pi * xi)^5 * cos(5 * pi * xi) * (5 * pi)
        d_cos2_dxi = T(0.1) * 2 * cos(500 * pi * xi) * (-sin(500 * pi * xi)) * (500 * pi)
        d_inner_dxi = d_sin6_dxi + d_cos2_dxi
        
        grad[i] = - (dg_dxi * inner + g * d_inner_dxi)
    end
    grad
end

const RIPPLE1_FUNCTION = TestFunction(
    ripple1,
    ripple1_gradient,
    Dict(
        :name => "ripple1",
        :description => "Ripple 1 function. Volatile due to high-frequency cosine and strong sin^6 power; complex range from oscillations, depending on x distribution/values. Represented in [0,1] with global min at x=[0.1,0.1], f=-2.2. Non-separable. Multimodal with 252004 local minima. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{2} -e^{-2 \ln 2 \left(\frac{x_i - 0.1}{0.8}\right)^2} \left(\sin^6(5 \pi x_i) + 0.1 \cos^2(500 \pi x_i)\right). """,
        :start => () -> [0.5, 0.5],
        :min_position => () -> [0.1, 0.1],
        :min_value => () -> -2.2,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "multimodal"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jamil, M. & Yang, X.-S. A Literature Survey of Benchmark Functions For Global Optimization Problems Int. Journal of Mathematical Modelling and Numerical Optimisation, 2013, 4, 150-194.",
        :lb => () -> [0.0, 0.0],
        :ub => () -> [1.0, 1.0],
    )
)