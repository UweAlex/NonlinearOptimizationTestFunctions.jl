# src/functions/biggsexp5.jl
# Purpose: Implementation of the Biggs EXP5 test function.
# Global minimum: f(x*)=0 at x*=[1.0, 10.0, 1.0, 5.0, 4.0].
# Bounds: 0 ≤ x_i ≤ 20.

export BIGGSEXP5_FUNCTION, biggsexp5, biggsexp5_gradient

function biggsexp5(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 5 && throw(ArgumentError("biggsexp5 requires exactly 5 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    if T <: BigFloat
        setprecision(256)
    end
    
    let
        TI = 0.1 .* (1:11)
        YI = exp.(-TI) .- 5 .* exp.(-10 .* TI) .+ 3 .* exp.(-4 .* TI)
        x1, x2, x3, x4, x5 = x
        s = zero(T)
        @inbounds for i in eachindex(TI)
            t = TI[i]
            e = x3 * exp(-t * x1) - x4 * exp(-t * x2) + 3 * exp(-t * x5) - YI[i]
            s += e^2
        end
        s
    end
end

function biggsexp5_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 5 && throw(ArgumentError("biggsexp5 requires exactly 5 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    let
        TI = 0.1 .* (1:11)
        YI = exp.(-TI) .- 5 .* exp.(-10 .* TI) .+ 3 .* exp.(-4 .* TI)
        x1, x2, x3, x4, x5 = x
        @inbounds for i in eachindex(TI)
            t = TI[i]
            exp1 = exp(-t * x1)
            exp2 = exp(-t * x2)
            exp5 = exp(-t * x5)
            e = x3 * exp1 - x4 * exp2 + 3 * exp5 - YI[i]
            factor = 2 * e
            grad[1] += factor * (x3 * (-t) * exp1)
            grad[2] += factor * (x4 * t * exp2)
            grad[3] += factor * exp1
            grad[4] += factor * (-exp2)
            grad[5] += factor * (3 * (-t) * exp5)
        end
    end
    grad
end

const BIGGSEXP5_FUNCTION = TestFunction(
    biggsexp5,
    biggsexp5_gradient,
    Dict{Symbol, Any}(
        :name => "biggsexp5",
        :description => "Properties based on Jamil & Yang (2013, p. 12); Multimodal sum-of-squares function with exact global minimum 0 at [1,10,1,5,4] for n=5.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{11} \left( x_3 e^{-t_i x_1} - x_4 e^{-t_i x_2} + 3 e^{-t_i x_5} - y_i \right)^2, \quad t_i = 0.1i, \ y_i = e^{-t_i} - 5 e^{-10 t_i} + 3 e^{-4 t_i}.""",
        :start => () -> [0.01, 0.01, 0.01, 0.01, 0.01],
        :min_position => () -> [1.0, 10.0, 1.0, 5.0, 4.0],
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "non-separable", "multimodal", "bounded"],
        :source => "Jamil & Yang (2013, p. 12)",
        :lb => () -> [0.0, 0.0, 0.0, 0.0, 0.0],
        :ub => () -> [20.0, 20.0, 20.0, 20.0, 20.0],
    )
)

@assert "biggsexp5" == basename(@__FILE__)[1:end-3] "biggsexp5: Dateiname mismatch!"