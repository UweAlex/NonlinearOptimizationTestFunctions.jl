# src/functions/gulfresearch.jl
# Purpose: Implementation of the Gulf Research Problem test function.
# Context: Non-scalable, 3D, from Jamil & Yang (2013), function 60.
# Global minimum: f(x*)=0 at x*=[50, 25, 1.5].
# Bounds: 0.1 ≤ x₁ ≤ 100, 0 ≤ x₂ ≤ 25.6, 0 ≤ x₃ ≤ 5 (exactly as in Jamil & Yang).
# Last modified: November 21, 2025.

export GULFRESEARCH_FUNCTION, gulfresearch, gulfresearch_gradient

function gulfresearch(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("gulfresearch requires exactly 3 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    x1, x2, x3 = x
    x1 <= zero(T) && return T(Inf)   # Bounds garantieren x1 >= 0.1 → sicher

    sum_sq = zero(T)
    m = 99
    @inbounds for i in 1:m
        ti = T(0.01 * i)
        log_ti = log(ti)
        ui = T(25) + (-T(50) * log_ti)^(T(2)/3)
        diff = ui - x2
        zj = diff^x3 / x1               # Originalformel – kein abs!
        inner = exp(-zj) - ti
        sum_sq += inner^2
    end
    sum_sq
end

function gulfresearch_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("gulfresearch requires exactly 3 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    x1, x2, x3 = x
    x1 <= zero(T) && return fill(T(Inf), n)

    grad = zeros(T, 3)
    m = 99
    @inbounds for i in 1:m
        ti = T(0.01 * i)
        log_ti = log(ti)
        ui = T(25) + (-T(50) * log_ti)^(T(2)/3)
        diff = ui - x2
        zj = diff^x3 / x1
        exp_mz = exp(-zj)
        inner = exp_mz - ti
        common = -2 * inner * exp_mz

        # ∂/∂x1
        grad[1] += common * (-zj / x1)

        # ∂/∂x2
        if diff != 0 && x3 != 0
            grad[2] += common * (-x3 * (diff^(x3 - 1)) / x1)
        end

        # ∂/∂x3
        if diff > 0 || isinteger(x3)   # log nur bei diff > 0 oder ganzzahligem x3
            grad[3] += common * (zj * log(abs(diff)))
        end
    end
    grad
end

const GULFRESEARCH_FUNCTION = TestFunction(
    gulfresearch,
    gulfresearch_gradient,
    Dict{Symbol, Any}(
        :name         => "gulfresearch",
        :description  => "Gulf Research and Development problem (least-squares). Properties based on Jamil & Yang (2013, p. 60).",
        :math         => raw"""f(\mathbf{x}) = \sum_{i=1}^{99} \left[ \exp\left( -\frac{(u_i - x_2)^{x_3}}{x_1} \right) - 0.01 i \right]^2, \quad u_i = 25 + [-50 \ln(0.01 i)]^{2/3}.""",
        :start        => () -> [30.0, 10.0, 2.0],   # weit weg vom Minimum, x2 > 0
        :min_position => () -> [50.0, 25.0, 1.5],
        :min_value    => () -> 0.0,
        :properties   => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :source       => "Jamil & Yang (2013, p. 60)",
        :lb           => () -> [0.1, 0.0, 0.0],
        :ub           => () -> [100.0, 25.6, 5.0],
    )
)

