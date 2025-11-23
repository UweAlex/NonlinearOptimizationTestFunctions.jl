# src/functions/brad.jl
# Purpose: Implementation of the Brad test function.
# Global minimum: f(x*) ≈ 0.0082148773 at x* ≈ [0.08241, 1.133, 2.3437].
# Bounds: -0.25 ≤ x₁ ≤ 0.25, 0.01 ≤ x₂,x₃ ≤ 2.5.
# Source: Brad (1970); data from Moré et al. (1981)

export BRAD_FUNCTION, brad, brad_gradient

function brad(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("brad requires exactly 3 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    T <: BigFloat && setprecision(256)

    x1, x2, x3 = x
    if x2 ≤ zero(T) || x3 ≤ zero(T)
        return T(Inf)
    end

    let U = 1:15,
        V = 16 .- U,
        W = min.(U, V),
        Y = T[0.14, 0.18, 0.22, 0.25, 0.29, 0.32, 0.35, 0.39,
              0.37, 0.58, 0.73, 0.96, 1.34, 2.10, 4.39]

        s = zero(T)
        @inbounds for i in eachindex(U)
            denom = V[i]*x2 + W[i]*x3
            denom ≤ zero(T) && return T(Inf)
            residual = Y[i] - x1 - U[i]/denom
            s += residual*residual
        end
        s
    end
end

function brad_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("brad requires exactly 3 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    T <: BigFloat && setprecision(256)

    x1, x2, x3 = x
    grad = zeros(T, 3)

    if x2 ≤ zero(T) || x3 ≤ zero(T)
        return fill(T(Inf), 3)
    end

    let U = 1:15,
        V = 16 .- U,
        W = min.(U, V),
        Y = T[0.14, 0.18, 0.22, 0.25, 0.29, 0.32, 0.35, 0.39,
              0.37, 0.58, 0.73, 0.96, 1.34, 2.10, 4.39]

        @inbounds for i in eachindex(U)
            denom = V[i]*x2 + W[i]*x3
            denom ≤ zero(T) && return fill(T(Inf), 3)
            inv_denom² = inv(denom*denom)
            residual = Y[i] - x1 - U[i]/denom

            grad[1] -= 2*residual
            grad[2] += 2*residual * (U[i]*V[i]*inv_denom²)
            grad[3] += 2*residual * (U[i]*W[i]*inv_denom²)
        end
    end
    grad
end

const BRAD_FUNCTION = TestFunction(
    brad,
    brad_gradient,
    Dict{Symbol, Any}(
        :name         => "brad",
        :description  => "Brad function (Brad, 1970). Non-scalable (n=3), continuous, differentiable, non-separable, multimodal least-squares problem from exponential fitting.",
        :math         => raw"""f(\mathbf{x}) = \sum_{i=1}^{15} \left( y_i - x_1 - \frac{i}{(16-i)x_2 + \min(i,16-i)x_3} \right)^2""",
        :start        => () -> [0.0, 1.0, 1.0],
        :min_position => () -> [0.08241056, 1.13303609, 2.34369518],
        :min_value    => () -> 0.008214877306578994,
        :properties   => ["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"],
        :source       => "Brad (1970); data from Moré et al. (1981)",
        :lb           => () -> [-0.25, 0.01, 0.01],
        :ub           => () -> [0.25, 2.5, 2.5],
    )
)

@assert "brad" == basename(@__FILE__)[1:end-3] "brad: Dateiname mismatch!"