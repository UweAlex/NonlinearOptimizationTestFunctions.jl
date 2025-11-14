# src/functions/zakharov.jl
# Purpose: Implementation of the Zakharov test function.
# Global minimum: f(x*)=0.0 at x*=(0.0, ..., 0.0).
# Bounds: -5.0 ≤ x_i ≤ 10.0.

export ZAKHAROV_FUNCTION, zakharov, zakharov_gradient

function zakharov(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("zakharov requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_sq = zero(T)
    s = zero(T)
    @inbounds for i in 1:n
        sum_sq += x[i]^2
        s += 0.5 * i * x[i]
    end
    sum_sq + s^2 + s^4
end

function zakharov_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("zakharov requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    s = zero(T)
    @inbounds for i in 1:n
        s += 0.5 * i * x[i]
    end
    grad = zeros(T, n)
    @inbounds for k in 1:n
        grad[k] = 2 * x[k] + k * s + 2 * k * s^3
    end
    grad
end

const ZAKHAROV_FUNCTION = TestFunction(
    zakharov,
    zakharov_gradient,
    Dict{Symbol, Any}(
        :name => "zakharov",
        :description => "Zakharov function; Properties based on Jamil & Yang (2013, p. 39); ursprünglich aus Rahnamyan et al. (2007).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n x_i^2 + \left( \sum_{i=1}^n \frac{1}{2} i x_i \right)^2 + \left( \sum_{i=1}^n \frac{1}{2} i x_i \right)^4.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("zakharov requires at least 1 dimension")); ones(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("zakharov requires at least 1 dimension")); zeros(n) end,
        :min_value => (n::Int) -> begin n < 1 && throw(ArgumentError("zakharov requires at least 1 dimension")); 0.0 end,
        :default_n => 2,
        :properties => ["continuous", "differentiable", "non-separable", "scalable", "multimodal", "bounded"],
        :source => "Jamil & Yang (2013, p. 39)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("zakharov requires at least 1 dimension")); fill(-5.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("zakharov requires at least 1 dimension")); fill(10.0, n) end,
    )
)

# Optional: Validierung beim Laden
@assert "zakharov" == basename(@__FILE__)[1:end-3] "zakharov: Dateiname mismatch!"