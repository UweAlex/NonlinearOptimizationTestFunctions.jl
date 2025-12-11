# src/functions/biggsexp6.jl
# Purpose: Implementation of the Biggs EXP6 test function.
# Global minimum: f(x*)=0 at x*=[1.0, 10.0, 1.0, 5.0, 4.0, 3.0].
# Bounds: -20 ≤ x_i ≤ 20.

export BIGGSEXP6_FUNCTION, biggsexp6, biggsexp6_gradient

function biggsexp6(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 6 && throw(ArgumentError("biggsexp6 requires exactly 6 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    if T <: BigFloat
        setprecision(256)
    end
    
    let
        TI = 0.1 .* (1:13)
        YI = exp.(-TI) .- 5 .* exp.(-10 .* TI) .+ 3 .* exp.(-4 .* TI)
        x1, x2, x3, x4, x5, x6 = x
        s = zero(T)
        @inbounds for i in eachindex(TI)
            t = TI[i]
            e1 = exp(-t * x1)
            e2 = exp(-t * x2)
            e5 = exp(-t * x5)
            term = x3 * e1 - x4 * e2 + x6 * e5 - YI[i]
            s += term^2
        end
        s
    end
end

function biggsexp6_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 6 && throw(ArgumentError("biggsexp6 requires exactly 6 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    let
        TI = 0.1 .* (1:13)
        YI = exp.(-TI) .- 5 .* exp.(-10 .* TI) .+ 3 .* exp.(-4 .* TI)
        x1, x2, x3, x4, x5, x6 = x
        @inbounds for i in eachindex(TI)
            t = TI[i]
            e1 = exp(-t * x1)
            e2 = exp(-t * x2)
            e5 = exp(-t * x5)
            term = x3 * e1 - x4 * e2 + x6 * e5 - YI[i]
            factor = 2 * term
            grad[1] += factor * (x3 * (-t) * e1)
            grad[2] += factor * (x4 * t * e2)
            grad[3] += factor * e1
            grad[4] += factor * (-e2)
            grad[5] += factor * (x6 * (-t) * e5)
            grad[6] += factor * e5
        end
    end
    grad
end

const BIGGSEXP6_FUNCTION = TestFunction(
    biggsexp6,
    biggsexp6_gradient,
    Dict{Symbol, Any}(
        :name => "biggsexp6",
        :description => "Properties based on Jamil & Yang (2013, p. 12); Multimodal sum-of-squares function with exact global minimum 0 at [1,10,1,5,4,3] for n=6.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{13} \left( x_3 e^{-t_i x_1} - x_4 e^{-t_i x_2} + x_6 e^{-t_i x_5} - y_i \right)^2, \quad t_i=0.1i, \ y_i = e^{-t_i} - 5 e^{-10 t_i} + 3 e^{-4 t_i}.""",
        :start => () -> [1.0, 2.0, 1.0, 1.0, 1.0, 1.0],
        :min_position => () -> [1.0, 10.0, 1.0, 5.0, 4.0, 3.0],
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "non-separable", "multimodal", "bounded"],
        :source => "Jamil & Yang (2013, p. 12)",
        :lb => () -> fill(-20.0, 6),
        :ub => () -> fill(20.0, 6),
    )
)

