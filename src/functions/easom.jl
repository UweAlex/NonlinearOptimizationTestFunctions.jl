# src/functions/easom.jl
# Purpose: Implementation of the Easom test function.
# Global minimum: f(x*)= -1.0 at x*=[π, π].
# Bounds: -100 ≤ x_i ≤ 100.

export EASOM_FUNCTION, easom, easom_gradient

function easom(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("easom requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # Passe an gewünschte Bits an; [RULE_HIGH_PREC_SUPPORT]
    end
    
    x1, x2 = x[1], x[2]
    -cos(x1) * cos(x2) * exp(-((x1 - π)^2 + (x2 - π)^2))
end

function easom_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("easom requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)  # Passe an gewünschte Bits an; [RULE_HIGH_PREC_SUPPORT]
    end
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    x1, x2 = x[1], x[2]
    exp_term = exp(-((x1 - π)^2 + (x2 - π)^2))
    grad[1] = cos(x2) * exp_term * (sin(x1) + 2 * (x1 - π) * cos(x1))
    grad[2] = cos(x1) * exp_term * (sin(x2) + 2 * (x2 - π) * cos(x2))
    grad
end

const EASOM_FUNCTION = TestFunction(
    easom,
    easom_gradient,
    Dict{Symbol, Any}(
        :name => "easom",  # Hartkodiert [RULE_NAME_CONSISTENCY]
        :description => "Easom function. Properties based on Jamil & Yang (2013, p. 19); originally from Easom (1990).",
        :math => raw"""f(\mathbf{x}) = -\cos(x_1) \cos(x_2) \exp\left( -((x_1 - \pi)^2 + (x_2 - \pi)^2) \right).""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [π, π],
        :min_value => () -> -1.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"],
        :source => "Jamil & Yang (2013, p. 19)",
        :lb => () -> [-100.0, -100.0],
        :ub => () -> [100.0, 100.0],
        :in_molga_smutnicki_2005 => true,  # Legacy-Key für Test-Kompatibilität
    )
)

# Optional: Validierung beim Laden
@assert "easom" == basename(@__FILE__)[1:end-3] "easom: Dateiname mismatch!"