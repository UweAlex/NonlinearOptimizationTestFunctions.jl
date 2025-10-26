# src/functions/dixonprice.jl
# Purpose: Implements the Dixon-Price test function with its gradient for nonlinear optimization.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia.
# Last modified: October 22, 2025

export DIXONPRICE_FUNCTION, dixonprice, dixonprice_gradient

using LinearAlgebra, ForwardDiff

"""
    dixonprice(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the Dixon-Price function value at point `x`. Works for any dimension n ≥ 1.
Returns `NaN` for inputs containing `NaN`, and `Inf` for inputs containing `Inf`.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function dixonprice(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    sum = (x[1] - 1)^2
    @inbounds for i in 2:n
        sum += i * (2 * x[i]^2 - x[i-1])^2
    end
    sum
end

"""
    dixonprice_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
Computes the gradient of the Dixon-Price function. Returns a vector of length n.
Throws `ArgumentError` if the input vector is empty or has incorrect dimensions.
"""
function dixonprice_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    grad = zeros(T, n)
    grad[1] = 2 * (x[1] - 1)
    if n > 1
        grad[1] -= 4 * (2 * x[2]^2 - x[1])
        @inbounds for i in 2:(n-1)
            grad[i] = 8 * i * (2 * x[i]^2 - x[i-1]) * x[i] - 2 * (i + 1) * (2 * x[i+1]^2 - x[i])
        end
        grad[n] = 8 * n * (2 * x[n]^2 - x[n-1]) * x[n]
    end
    grad
end

const DIXONPRICE_FUNCTION = TestFunction(
    dixonprice,
    dixonprice_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],
        :start => (n::Int) -> begin func_name = basename(@__FILE__)[1:end-3]; n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension")); fill(1.0, n) end,
        :min_position => (n::Int) -> begin func_name = basename(@__FILE__)[1:end-3]; n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension")); [2^(-(2^i - 2) / 2^i) for i in 1:n] end,
        :min_value => (n::Int) -> begin func_name = basename(@__FILE__)[1:end-3]; n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension")); 0.0 end,
        :properties => ["differentiable", "non-convex", "scalable", "unimodal", "bounded", "continuous"],
        :default_n => 2,
        :lb => (n::Int) -> begin func_name = basename(@__FILE__)[1:end-3]; n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension")); fill(-10.0, n) end,
        :ub => (n::Int) -> begin func_name = basename(@__FILE__)[1:end-3]; n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension")); fill(10.0, n) end,
        :description => "Dixon-Price function: Unimodal, non-convex, scalable function with global minimum at zero. Properties based on [Jamil & Yang (2013, Entry 14)]; originally from [Dixon & Price (1971)].",
        :math => raw"(x_1 - 1)^2 + \sum_{i=2}^n i (2 x_i^2 - x_{i-1})^2",
        :source => "Jamil & Yang (2013, Entry 14)"
    )
)