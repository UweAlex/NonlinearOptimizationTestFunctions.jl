# src/functions/biggsexp2.jl
# Purpose: Implementation of the Biggs EXP2 test function.
# Global minimum: f(x*)=0 at x*=[1.0, 10.0].
# Bounds: 0 ≤ x_i ≤ 20.

export BIGGSEXP2_FUNCTION, biggsexp2, biggsexp2_gradient

function biggsexp2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("biggsexp2 requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    let
        TI = [0.1 * i for i in 1:10]
        YI = [exp(-t) - 5 * exp(-10 * t) for t in TI]
        s = zero(T)
        @inbounds for i in 1:10
            t = TI[i]
            term = exp(-t * x[1]) - 5 * exp(-t * x[2]) - YI[i]
            s += term * term
        end
        s
    end
end

function biggsexp2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("biggsexp2 requires exactly 2 dimensions"))
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
        @inbounds for i in 1:10
            t = TI[i]
            exp1 = exp(-t * x[1])
            exp2 = exp(-t * x[2])
            term = exp1 - 5 * exp2 - YI[i]
            grad[1] += 2 * term * (-t * exp1)
            grad[2] += 2 * term * (5 * t * exp2)
        end
    end
    grad
end

const BIGGSEXP2_FUNCTION = TestFunction(
    biggsexp2,
    biggsexp2_gradient,
    Dict{Symbol, Any}(
        :name => "biggsexp2",
        :description => "Properties based on Jamil & Yang (2013, p. 12); Sum-of-squares function with exact global minimum 0 at [1,10] for n=2.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{10} \left( e^{-t_i x_1} - 5 e^{-t_i x_2} - y_i \right)^2, \quad t_i=0.1i, \ y_i = e^{-t_i} - 5 e^{-10 t_i}.""",
        :start => () -> [0.01, 0.01],
        :min_position => () -> [1.0, 10.0],
        :min_value => () -> 0.0,
        :properties => ["continuous", "differentiable", "non-separable", "multimodal", "bounded"],
        :source => "Jamil & Yang (2013, p. 12)",
        :lb => () -> [0.0, 0.0],
        :ub => () -> [20.0, 20.0],
    )
)

# Optional: Validierung beim Laden
@assert "biggsexp2" == basename(@__FILE__)[1:end-3] "biggsexp2: Dateiname mismatch!"