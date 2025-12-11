# src/functions/wavy.jl
# Purpose: Implementation of the Wavy test function.
# Global minimum: f(x*)=0.0 at x*=zeros(n).
# Bounds: -π ≤ x_i ≤ π.

export WAVY_FUNCTION, wavy, wavy_gradient

function wavy(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("wavy requires at least 1 dimension"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    k = 10.0  # Fixed parameter from source
    sum_term = zero(T)
    @inbounds for i in 1:n
        xi = x[i]
        sum_term += cos(k * xi) * exp(-xi^2 / 2)  # [RULE_TYPE_CONVERSION_MINIMAL]
    end
    1 - sum_term / n
end

function wavy_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("wavy requires at least 1 dimension"))  # [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    k = 10.0  # Fixed parameter
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for j in 1:n
        xj = x[j]
        term = cos(k * xj) * exp(-xj^2 / 2)
        dterm = -k * sin(k * xj) * exp(-xj^2 / 2) - xj * term
        grad[j] = -(dterm / n)
    end
    grad
end

const WAVY_FUNCTION = TestFunction(
    wavy,
    wavy_gradient,
    Dict{Symbol, Any}(
        :name => "wavy",  # [RULE_NAME_CONSISTENCY]
        :description => "Wavy Function; Properties based on Jamil & Yang (2013, p. 38); originally from [23]. Multimodal with ~10^n local minima for k=10.",
        :math => raw"""f(\mathbf{x}) = 1 - \frac{1}{n} \sum_{i=1}^{n} \cos(10 x_i) e^{-x_i^2 / 2}.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("wavy requires at least 1 dimension")); fill(1.0, n) end,  # Neutral start, away from minimum
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("wavy requires at least 1 dimension")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # [RULE_META_CONSISTENCY]
        :default_n => 2,  # [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "separable", "scalable", "multimodal"],
        :source => "Jamil & Yang (2013, p. 38)",  # [RULE_PROPERTIES_SOURCE]
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("wavy requires at least 1 dimension")); fill(-π, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("wavy requires at least 1 dimension")); fill(π, n) end,
    )
)

# Optional: Validierung beim Laden
