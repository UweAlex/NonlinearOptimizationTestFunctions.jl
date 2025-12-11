# src/functions/rosenbrock.jl
# Purpose: Implementation of the Rosenbrock test function (Benchmark #105).
# Context: Scalable, non-separable, unimodal function with a narrow valley; challenging for optimization due to ill-conditioning.
# Global minimum: f(x*)=0.0 at x*=(1, ..., 1).
# Bounds: -30 ≤ x_i ≤ 30.
# Last modified: October 04, 2025.
# Properties based on Jamil & Yang (2013).

export ROSENBROCK_FUNCTION, rosenbrock, rosenbrock_gradient

function rosenbrock(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Rosenbrock requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    total = zero(T)
    @inbounds for i in 1:(n-1)
        xi = x[i]
        xi1 = x[i+1]
        term1 = 100 * (xi1 - xi^2)^2
        term2 = (xi - 1)^2
        total += term1 + term2
    end
    total
end

function rosenbrock_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Rosenbrock requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    @inbounds for i in 1:n
        if i == 1
            # grad[1] = -400 (x[2] - x[1]^2) x[1] + 2 (x[1] - 1)
            u = x[2] - x[1]^2
            grad[1] = -400 * u * x[1] + 2 * (x[1] - 1)
        elseif i == n
            # grad[n] = 200 (x[n] - x[n-1]^2)
            u = x[n] - x[n-1]^2
            grad[n] = 200 * u
        else
            # From previous term: 200 (x[i] - x[i-1]^2)
            # From current term: -400 (x[i+1] - x[i]^2) x[i] + 2 (x[i] - 1)
            u_prev = x[i] - x[i-1]^2
            u_curr = x[i+1] - x[i]^2
            grad[i] = 200 * u_prev - 400 * u_curr * x[i] + 2 * (x[i] - 1)
        end
    end
    grad
end

const ROSENBROCK_FUNCTION = TestFunction(
    rosenbrock,
    rosenbrock_gradient,
    Dict(
        :name => "rosenbrock",
        :description => "Rosenbrock function: sum_{i=1}^{n-1} [100 (x_{i+1} - x_i^2)^2 + (x_i - 1)^2]. Features a narrow parabolic valley, making it ill-conditioned and challenging for gradient-based methods. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{n-1} [100(x_{i+1} - x_i^2)^2 + (x_i - 1)^2]. """,
        :start => (n::Int) -> begin n < 2 && throw(ArgumentError("Dimension must be at least 2")); vcat(fill(-1.2, n-1), 1.0) end,
        :min_position => (n::Int) -> begin n < 2 && throw(ArgumentError("Dimension must be at least 2")); ones(n) end,
        :min_value => (n::Int) -> 0.0,  # Constant, but (n::Int) to match scalable call signature in tests
        :default_n => 2,  # Standard for Rosenbrock
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "scalable", "unimodal", "ill-conditioned"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jamil & Yang (2013), Benchmark Function #105",
        :lb => (n::Int) -> begin n < 2 && throw(ArgumentError("Dimension must be at least 2")); fill(-30.0, n) end,
        :ub => (n::Int) -> begin n < 2 && throw(ArgumentError("Dimension must be at least 2")); fill(30.0, n) end,
    )
)