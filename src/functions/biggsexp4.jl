# src/functions/biggsexp4.jl
# Purpose: Implementation of the Biggs EXP4 test function.
# Global minimum: f(x*)=0 at x*=[1.0, 10.0, 1.0, 5.0].
# Bounds: 0 ≤ x_i ≤ 20.

export BIGGSEXP4_FUNCTION, biggsexp4, biggsexp4_gradient

function biggsexp4(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("biggsexp4 requires exactly 4 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    let
        TI = [0.1 * i for i in 1:10]
        YI = [exp(-t) - 5 * exp(-10 * t) for t in TI]
        x1, x2, x3, x4 = x
        sum_sq = zero(T)
        @inbounds for i in 1:10
            t_i = TI[i]
            y_i = YI[i]
            e_i = x3 * exp(-t_i * x1) - x4 * exp(-t_i * x2) - y_i
            sum_sq += e_i^2
        end
        sum_sq
    end
end

function biggsexp4_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("biggsexp4 requires exactly 4 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    let
        TI = [0.1 * i for i in 1:10]
        YI = [exp(-t) - 5 * exp(-10 * t) for t in TI]
        x1, x2, x3, x4 = x
        @inbounds for i in 1:10
            t_i = TI[i]
            y_i = YI[i]
            exp1 = exp(-t_i * x1)
            exp2 = exp(-t_i * x2)
            e_i = x3 * exp1 - x4 * exp2 - y_i
            factor = 2 * e_i
            grad[1] += factor * (x3 * (-t_i) * exp1)
            grad[2] += factor * (x4 * t_i * exp2)
            grad[3] += factor * exp1
            grad[4] += factor * (-exp2)
        end
    end
    grad
end

const BIGGSEXP4_FUNCTION = TestFunction(
    biggsexp4,
    biggsexp4_gradient,
    Dict{Symbol, Any}(
        :name => "biggsexp4",
        :description => "Properties based on Jamil & Yang (2013, p. 12); Multimodal sum-of-squares function with exact global minimum 0 at [1,10,1,5] for n=4.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{10} \left( x_3 e^{-t_i x_1} - x_4 e^{-t_i x_2} - y_i \right)^2, \quad t_i=0.1i, \ y_i = e^{-t_i} - 5 e^{-10 t_i}.""",
        :start => () -> [0.01, 0.01, 0.01, 0.01],
        :min_position => () -> [1.0, 10.0, 1.0, 5.0],
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "non-separable", "multimodal", "bounded"],
        :source => "Jamil & Yang (2013, p. 12)",
        :lb => () -> [0.0, 0.0, 0.0, 0.0],
        :ub => () -> [20.0, 20.0, 20.0, 20.0],
    )
)

# Optional: Validierung beim Laden
