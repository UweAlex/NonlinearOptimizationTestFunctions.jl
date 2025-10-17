# src/functions/shekel5.jl
# Purpose: Implementation of the Shekel 5 test function.
# Global minimum: f(x*)=-10.15319967905822 at x*≈[4.00003715, 4.00013327, 4.00003715, 4.00013327] [source approximates [4,4,4,4] and -10.1532].
# Bounds: 0 ≤ x_i ≤ 10.

export SHEKEL5_FUNCTION, shekel5, shekel5_gradient

function shekel5(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "shekel5" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("$(func_name) requires exactly 4 dimensions"))  # Dynamischer Fehlertext [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Local constants [RULE_NO_CONST_ARRAYS]
    A = [T(4) T(4) T(4) T(4);
         T(1) T(1) T(1) T(1);
         T(8) T(8) T(8) T(8);
         T(6) T(6) T(6) T(6);
         T(3) T(7) T(3) T(7)]
    c = [T(0.1), T(0.2), T(0.2), T(0.4), T(0.4)]
    
    f_val = zero(T)
    @inbounds for i in 1:5
        den = zero(T)
        @inbounds for j in 1:4
            den += (x[j] - A[i, j])^2
        end
        den += c[i]
        f_val -= inv(den)
    end
    f_val
end

function shekel5_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "shekel5" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("$(func_name) requires exactly 4 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, 4)  # [RULE_GRADTYPE]
    
    # Local constants [RULE_NO_CONST_ARRAYS]
    A = [T(4) T(4) T(4) T(4);
         T(1) T(1) T(1) T(1);
         T(8) T(8) T(8) T(8);
         T(6) T(6) T(6) T(6);
         T(3) T(7) T(3) T(7)]
    c = [T(0.1), T(0.2), T(0.2), T(0.4), T(0.4)]
    
    @inbounds for k in 1:4
        g_k = zero(T)
        @inbounds for i in 1:5
            den = zero(T)
            @inbounds for j in 1:4
                den += (x[j] - A[i, j])^2
            end
            den += c[i]
            g_k += 2 * (x[k] - A[i, k]) * inv(den^2)
        end
        grad[k] = g_k  # No redundant T-conversions [RULE_TYPE_CONVERSION_MINIMAL]
    end
    grad
end

const SHEKEL5_FUNCTION = TestFunction(
    shekel5,
    shekel5_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "shekel5" [RULE_NAME_CONSISTENCY]
        :description => "Shekel 5 test function; Properties based on Jamil & Yang (2013, p. 130) [minimum controversial: source -10.1532 (rounded) and pos [4,4,4,4], precise -10.15319967905822 at ≈[4.00003715, 4.00013327, 4.00003715, 4.00013327]]; originally from Box (1966).",
        :math => raw"""f(\mathbf{x}) = -\sum_{i=1}^{5} \frac{1}{\sum_{j=1}^{4} (x_j - a_{ij})^2 + c_i}, \quad \mathbf{a}_i \in A = \begin{bmatrix} 4 & 4 & 4 & 4 \\ 1 & 1 & 1 & 1 \\ 8 & 8 & 8 & 8 \\ 6 & 6 & 6 & 6 \\ 3 & 7 & 3 & 7 \end{bmatrix}, \quad \mathbf{c} = [0.1, 0.2, 0.2, 0.4, 0.4].""",
        :start => () -> [1.0, 1.0, 1.0, 1.0],
        :min_position => () -> [4.00003715, 4.00013327, 4.00003715, 4.00013327],
        :min_value => () -> -10.15319967905822,  # Precise computed value [RULE_MIN_VALUE_INDEPENDENT]
        :properties => ["continuous", "differentiable", "non-separable", "multimodal", "controversial"],
        :source => "Jamil & Yang (2013, p. 130)",
        :lb => () -> [0.0, 0.0, 0.0, 0.0],
        :ub => () -> [10.0, 10.0, 10.0, 10.0],
    )
)