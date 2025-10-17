# src/functions/shekel7.jl
# Purpose: Implementation of the Shekel 7 test function.
# Global minimum: f(x*)=-10.402940566818653 at x*≈[4.00057291, 4.00068936, 3.99948971, 3.99960616] [source approximates -10.3999 at [4,4,4,4]].
# Bounds: 0 ≤ x_i ≤ 10.

export SHEKEL7_FUNCTION, shekel7, shekel7_gradient

function shekel7(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "shekel7" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("$(func_name) requires exactly 4 dimensions"))  # Dynamischer Fehlertext [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Local constants [RULE_NO_CONST_ARRAYS]
    A = [T(4) T(4) T(4) T(4);
         T(1) T(1) T(1) T(1);
         T(8) T(8) T(8) T(8);
         T(6) T(6) T(6) T(6);
         T(3) T(7) T(3) T(7);
         T(2) T(9) T(2) T(9);
         T(5) T(5) T(3) T(3)]
    c = [T(0.1), T(0.2), T(0.2), T(0.4), T(0.4), T(0.6), T(0.3)]
    
    f_val = zero(T)
    @inbounds for i in 1:7
        den = zero(T)
        @inbounds for j in 1:4
            den += (x[j] - A[i, j])^2
        end
        den += c[i]
        f_val -= inv(den)
    end
    f_val
end

function shekel7_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "shekel7" [RULE_NAME_CONSISTENCY]
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
         T(3) T(7) T(3) T(7);
         T(2) T(9) T(2) T(9);
         T(5) T(5) T(3) T(3)]
    c = [T(0.1), T(0.2), T(0.2), T(0.4), T(0.4), T(0.6), T(0.3)]
    
    @inbounds for k in 1:4
        g_k = zero(T)
        @inbounds for i in 1:7
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

const SHEKEL7_FUNCTION = TestFunction(
    shekel7,
    shekel7_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "shekel7" [RULE_NAME_CONSISTENCY]
        :description => "Shekel 7 test function; Properties based on Jamil & Yang (2013, p. 131) [minimum controversial: source -10.3999 (rounded) and pos [4,4,4,4], precise -10.402940566818653 at ≈[4.00057291, 4.00068936, 3.99948971, 3.99960616]]; originally from Box (1966).",
        :math => raw"""f(\mathbf{x}) = -\sum_{i=1}^{7} \frac{1}{\sum_{j=1}^{4} (x_j - a_{ij})^2 + c_i}, \quad \mathbf{a}_i \in A = \begin{bmatrix} 4 & 4 & 4 & 4 \\ 1 & 1 & 1 & 1 \\ 8 & 8 & 8 & 8 \\ 6 & 6 & 6 & 6 \\ 3 & 7 & 3 & 7 \\ 2 & 9 & 2 & 9 \\ 5 & 5 & 3 & 3 \end{bmatrix}, \quad \mathbf{c} = [0.1, 0.2, 0.2, 0.4, 0.4, 0.6, 0.3].""",
        :start => () -> [1.0, 1.0, 1.0, 1.0],
        :min_position => () -> [4.00057291, 4.00068936, 3.99948971, 3.99960616],
        :min_value => () -> -10.402940566818653,  # Precise computed value [RULE_MIN_VALUE_INDEPENDENT]
        :properties => ["continuous", "differentiable", "non-separable", "multimodal", "controversial"],
        :source => "Jamil & Yang (2013, p. 131)",
        :lb => () -> [0.0, 0.0, 0.0, 0.0],
        :ub => () -> [10.0, 10.0, 10.0, 10.0],
    )
)