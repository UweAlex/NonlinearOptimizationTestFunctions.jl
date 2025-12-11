# src/functions/shubert_shifted_rotated.jl
# Purpose: Implementation of the Shifted Rotated Shubert test function (CEC 2014 variant, fixed n=2).
# Global minimum: f(x*)=-186.7309088310 at transformed x* (18 positions in 2D).
# Bounds: -100 ≤ x_i ≤ 100 (adjusted for shift).

using LinearAlgebra
using Random
using ForwardDiff  # Für Gradient (Dual)

export SHUBERT_SHIFTED_ROTATED_FUNCTION, shubert_shifted_rotated, shubert_shifted_rotated_gradient

# Globale Konstanten für Reproduzierbarkeit (CEC-Style, seed=42; fixed n=2)
Random.seed!(42)
GLOBAL_O = randn(Float64, 2) * 80  # Shift ~ N(0,80^2) approx U[-80,80]
GLOBAL_Q = Matrix{Float64}(qr(randn(Float64, 2, 2)).Q)  # Orthogonal

function shubert_classic_inner(x::Real)
    # Hilfsfunktion: Innere Summe für klassische Shubert
    sum(j * cos((j+1)*x + j) for j in 1:5)
end

function shubert_shifted_rotated(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("shubert_shifted_rotated requires exactly 2 dimensions (Shubert is 2D-primary)"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Use global Q/o (cast to T for Dual support)
    o = T.(GLOBAL_O)
    Q = Matrix{T}(GLOBAL_Q)
    
    # Transform: z = Q * (x - o)
    z = Q * (x .- o)
    
    # Klassische Shubert auf z
    prod = one(T)
    for i in 1:n
        inner = shubert_classic_inner(z[i])
        prod *= inner
    end
    prod
end

function shubert_shifted_rotated_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("shubert_shifted_rotated requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # AutoDiff für Gradient (einfacher als analytisch für rotated)
    grad = ForwardDiff.gradient(shubert_shifted_rotated, x)
    grad
end

# Präzises klassisches Globalminimum (optimierter Wert, tol=1e-10)
CLASSIC_MIN_Z = [4.85805687, 5.48286421]

const SHUBERT_SHIFTED_ROTATED_FUNCTION = TestFunction(
    shubert_shifted_rotated,
    shubert_shifted_rotated_gradient,
    Dict(
        :name => "shubert_shifted_rotated",
        :description => "Shifted Rotated Shubert (CEC 2014 variant, product form with Q(x - o), fixed 2D); non-separable, highly multimodal (~760 local minima); tests invariance and coupling; based on classic Shubert with orthogonal rotation Q and shift o ~ U[-80,80].",
        :math => raw"""f(\mathbf{x}) = \prod_{i=1}^2 \sum_{j=1}^5 j \cos((j+1)[\mathbf{Q}(\mathbf{x}-\mathbf{o})]_i + j).""",
        :start => () -> zeros(2),
        :min_position => () -> GLOBAL_O + (GLOBAL_Q' * CLASSIC_MIN_Z),  # Dynamisch: x = o + Q' * z_classic
        :min_value => () -> -186.7309088310,  # Gerundet auf 10 Dezimalen (aus Optimierung)
        :default_n => 2,
        :properties => ["continuous", "differentiable", "multimodal", "non-separable"],
        :source => "CEC 2014; Jamil & Yang (2013, extended transformations)",
        :lb => () -> [-100.0, -100.0],
        :ub => () -> [100.0, 100.0],
    )
)

