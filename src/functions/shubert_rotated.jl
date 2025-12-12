# src/functions/shubert_rotated.jl
# Purpose: Implementation of the rotated Shubert test function (CEC 2021 F7).
# Global minimum: f(x*)≈-186.73 at x*≈[4.858, 5.483] (n=2, with Q=identity).
# Bounds: -10 ≤ x_i ≤ 10.
# Last modified: December 11, 2025.

export SHUBERT_ROTATED_FUNCTION, shubert_rotated, shubert_rotated_gradient

# Fixed Q = identity(n) for reproducibility
function compute_Q(n::Int)
    Matrix{Float64}(I, n, n) # Orthogonal, Kond=1 [RULE_SOURCE_FORMULA_CONSISTENCY]
end

function shubert_rotated(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("shubert_rotated requires at least 2 dimensions")) # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    Q = compute_Q(n)
    Qx = Q * x # Rotated
    prod = one(T)
    @inbounds for i in 1:n
        inner_sum = zero(T)
        @inbounds for j in 1:5 # j=1..5
            inner_sum += j * cos((j + 1) * Qx[i] + j)
        end
        prod *= inner_sum
    end
    prod
end

function shubert_rotated_gradient(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("shubert_rotated requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    Q = compute_Q(n)
    Qx = Q * x
    grad_Qx = zeros(T, n) # ∂f / ∂(Qx)
    @inbounds for i in 1:n
        ∂g_i = zero(T)
        @inbounds for j in 1:5
            ∂g_i -= j * (j + 1) * sin((j + 1) * Qx[i] + j)
        end
        prod_other = one(T)
        @inbounds for k in 1:n
            if k != i
                g_k = zero(T)
                @inbounds for j in 1:5
                    g_k += j * cos((j + 1) * Qx[k] + j)
                end
                prod_other *= g_k
            end
        end
        grad_Qx[i] = ∂g_i * prod_other
    end
    grad = Q' * grad_Qx # Chain Rule: ∂f/∂x = Q' * ∂f/∂(Qx)
    grad
end

const SHUBERT_ROTATED_FUNCTION = TestFunction(
    shubert_rotated,
    shubert_rotated_gradient,
    Dict(
        :name => "shubert_rotated", # "shubert_rotated" [RULE_NAME_CONSISTENCY]
        :description => "Rotated Shubert function; non-separable with ≈760 local minima in 2D; fixed Q=identity for reproducibility (in CEC random orthogonal Q, Kond=1); properties based on Jamil & Yang (2013, p. 55, f133-Rotated); CEC 2021 F7.",
        :math => raw"""f(\mathbf{x}) = \prod_{i=1}^n \sum_{j=1}^5 j \cos((j+1)(Q\mathbf{x})_i + j), \ Q \ orthogonal.""",
        :start => (n::Int) -> begin
            n < 2 && throw(ArgumentError("At least 2 dimensions"))
            zeros(n)
        end,
        :min_position => (n::Int) -> begin
            n < 2 && throw(ArgumentError("At least 2 dimensions"))
            [4.8580568784680462, 5.4828642069447433]
        end, # Für Q=eye, n=2
        :min_value => (n::Int) -> -186.73090883102375, # Konstant für n=2 [RULE_META_CONSISTENCY]
        :default_n => 2, # [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "scalable", "highly multimodal", "multimodal", "non-separable", "non-convex"],
        :source => "Jamil & Yang (2013, p. 55)", # Direkte Quelle mit Stelle
        :lb => (n::Int) -> begin
            n < 2 && throw(ArgumentError("At least 2 dimensions"))
            fill(-10.0, n)
        end,
        :ub => (n::Int) -> begin
            n < 2 && throw(ArgumentError("At least 2 dimensions"))
            fill(10.0, n)
        end,
    )
)