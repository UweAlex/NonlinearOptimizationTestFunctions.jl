# src/functions/schwefel226.jl
# Purpose: Implementation of the Schwefel 2.26 test function.
# Global minimum: f(x*)=-418.9828872724338 at x*≈[420.9687, ..., 420.9687] (n-independent value).
# Bounds: -500 ≤ x_i ≤ 500.

export SCHWEFEL226_FUNCTION, schwefel226, schwefel226_gradient

function schwefel226(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel226" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_term = zero(T)
    @inbounds for i in 1:n
        abs_xi = abs(x[i])
        sqrt_abs = sqrt(abs_xi)
        term = x[i] * sin(sqrt_abs)
        sum_term += term
    end
    -sum_term / n
end

function schwefel226_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schwefel226" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("$(func_name) requires at least 1 dimension"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    one_over_n = inv(n)
    @inbounds for i in 1:n
        xi = x[i]
        if xi == zero(T)
            grad[i] = zero(T)
        else
            abs_xi = abs(xi)
            sqrt_abs = sqrt(abs_xi)
            sin_term = sin(sqrt_abs)
            cos_term = cos(sqrt_abs)
            sgn = sign(xi)
            deriv = sin_term + xi * cos_term * sgn / (2 * sqrt_abs)
            grad[i] = -one_over_n * deriv  # No redundant T-conversions [RULE_TYPE_CONVERSION_MINIMAL]
        end
    end
    grad
end

const SCHWEFEL226_FUNCTION = TestFunction(
    schwefel226,
    schwefel226_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "schwefel226" [RULE_NAME_CONSISTENCY]
        :description => "Schwefel's Problem 2.26 test function; Properties based on Jamil & Yang (2013, p. 30); originally from Schwefel (1977). Multiple global minima due to periodic sin term.",
        :math => raw"""f(\mathbf{x}) = -\frac{1}{D} \sum_{i=1}^{D} x_i \sin \sqrt{|x_i|}.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(420.96874357691473, n) end,
        :min_value => (n::Int) -> -418.9828872724338,  # Konstant: (n::Int) -> value [RULE_META_CONSISTENCY]
        :default_n => 2,  # Kleinste n >1 für allgemein skalierbar [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "separable", "scalable", "multimodal"],
        :source => "Jamil & Yang (2013, p. 30)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(-500.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(500.0, n) end,
    )
)