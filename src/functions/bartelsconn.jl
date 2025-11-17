# src/functions/bartelsconn.jl
# Purpose: Implementation of the Bartels Conn test function.
# Global minimum: f(x*)=1.0 at x*=[0.0, 0.0].
# Bounds: -500.0 ≤ x_i ≤ 500.0.

export BARTELSCONN_FUNCTION, bartelsconn, bartelsconn_gradient

function bartelsconn(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bartelsconn requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    x1, x2 = x
    u = x1^2 + x2^2 + x1 * x2
    v = sin(x1)
    w = cos(x2)
    abs(u) + abs(v) + abs(w)
end

function bartelsconn_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bartelsconn requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Optional: High-Prec Präzision setzen (nur bei BigFloat)
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    x1, x2 = x
    u = x1^2 + x2^2 + x1 * x2
    v = sin(x1)
    w = cos(x2)
    
    # Erweiterter NaN-Check für non-differentiable Punkte (MUST: Return NaN für ungültig, per [RULE_ERROR_HANDLING])
    if isapprox(u, 0, atol=1e-10) || isapprox(v, 0, atol=1e-10) || isapprox(w, 0, atol=1e-10)
        return fill(T(NaN), n)
    end
    
    du_dx1 = 2 * x1 + x2
    du_dx2 = 2 * x2 + x1
    grad[1] = sign(u) * du_dx1 + sign(v) * cos(x1)
    grad[2] = sign(u) * du_dx2 - sign(w) * sin(x2)
    grad
end

const BARTELSCONN_FUNCTION = TestFunction(
    bartelsconn,
    bartelsconn_gradient,
    Dict{Symbol, Any}(
        :name => "bartelsconn",
        :description => "Properties based on Jamil & Yang (2013, p. 6); Contains absolute value terms leading to non-differentiability at certain points (gradient returns NaN there).",
        :math => raw"""f(\mathbf{x}) = |x_1^2 + x_2^2 + x_1 x_2| + |\sin(x_1)| + |\cos(x_2)|.""",
        :start => () -> [1.0, 1.0],
        :min_position => () -> [0.0, 0.0],
        :min_value => () -> 1.0,
        :properties => ["multimodal", "non-convex", "non-separable", "partially differentiable", "bounded", "continuous"],
        :source => "Jamil & Yang (2013, p. 6)",
        :lb => () -> [-500.0, -500.0],
        :ub => () -> [500.0, 500.0],
    )
)

# Optional: Validierung beim Laden
@assert "bartelsconn" == basename(@__FILE__)[1:end-3] "bartelsconn: Dateiname mismatch!"