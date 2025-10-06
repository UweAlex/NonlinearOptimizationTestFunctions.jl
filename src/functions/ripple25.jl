# src/functions/ripple25.jl
# Purpose: Implementation of the Ripple 25 test function.
# Global minimum: f(x*)= -2.0 at x*=[0.1, 0.1].
# Bounds: 0 ≤ x_i ≤ 1.

export RIPPLE25_FUNCTION, ripple25, ripple25_gradient

function ripple25(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Ripple 25 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    total = zero(T)
    ln2 = log(T(2))
    @inbounds for i in 1:2
        xi = x[i]
        exp_arg = 2 * ln2 * ((xi - T(0.1)) / T(0.8))^2
        g = exp(-exp_arg)
        sin6 = sin(5 * pi * xi)^6
        total -= g * sin6
    end
    total
end

function ripple25_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Ripple 25 requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    ln2 = log(T(2))
    @inbounds for i in 1:2
        xi = x[i]
        exp_arg = 2 * ln2 * ((xi - T(0.1)) / T(0.8))^2
        g = exp(-exp_arg)
        sin6 = sin(5 * pi * xi)^6
        
        # dg/dxi = -g * (4 * ln2 * (xi - 0.1) / 0.8^2)
        dg_dxi = -g * (4 * ln2 * (xi - T(0.1)) / T(0.64))
        
        # d_sin6/dxi = 6 * sin^5(5 π xi) * cos(5 π xi) * 5 π
        d_sin6_dxi = 6 * sin(5 * pi * xi)^5 * cos(5 * pi * xi) * (5 * pi)
        
        grad[i] = - (dg_dxi * sin6 + g * d_sin6_dxi)
    end
    grad
end

const RIPPLE25_FUNCTION = TestFunction(
    ripple25,
    ripple25_gradient,
    Dict(
        :name => "ripple25",
        :description => "Ripple 25 function. Volatile due to high-frequency sine^6 term and Gaussian envelope; complex range from oscillations, depending on x distribution/values. Represented in [0,1] with global min at x=[0.1,0.1], f=-2.0. Non-separable. Multimodal with numerous local minima. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{2} -e^{-2 \ln 2 \left(\frac{x_i - 0.1}{0.8}\right)^2} \sin^6(5 \pi x_i). """,
        :start => () -> [0.5, 0.5],
        :min_position => () -> [0.1, 0.1],
        :min_value => () -> -2.0,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "multimodal"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jamil, M. & Yang, X.-S. A Literature Survey of Benchmark Functions For Global Optimization Problems Int. Journal of Mathematical Modelling and Numerical Optimisation, 2013, 4, 150-194.",
        :lb => () -> [0.0, 0.0],
        :ub => () -> [1.0, 1.0],
    )
)