# src/functions/styblinski_tang.jl
# Purpose: Implementation of the Styblinski-Tang test function.
# Global minimum: f(x*)=-39.16616570377141 * n at x*=(-2.903534027771177, ..., -2.903534027771177).
# Bounds: -5.0 ≤ x_i ≤ 5.0.

export STYBLINSKI_TANG_FUNCTION, styblinski_tang, styblinski_tang_gradient

function styblinski_tang(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("styblinski_tang requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_val = zero(T)
    @inbounds for i in 1:n
        xi = x[i]
        sum_val += (xi^4 - 16 * xi^2 + 5 * xi) / 2
    end
    sum_val
end

function styblinski_tang_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("styblinski_tang requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    @inbounds for i in 1:n
        xi = x[i]
        grad[i] = 2 * xi^3 - 16 * xi + 2.5
    end
    grad
end

const STYBLINSKI_TANG_FUNCTION = TestFunction(
    styblinski_tang,
    styblinski_tang_gradient,
    Dict(
        :name => "styblinski_tang",
        :description => "Properties based on Jamil & Yang (2013, function 144); formula indicates separable and scalable, adapted accordingly despite source listing non-separable/non-scalable; Minimum computed precisely via solving derivative=0 (source approx -39.16618); originally from [80].",
        :math => raw"""f(\mathbf{x}) = \frac{1}{2} \sum_{i=1}^D (x_i^4 - 16x_i^2 + 5x_i).""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("styblinski_tang requires at least 1 dimension")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("styblinski_tang requires at least 1 dimension")); fill(-2.903534027771177, n) end,
        :min_value => (n::Int) -> -39.16616570377141 * n,
        :default_n => 2,
        :properties => ["continuous", "differentiable", "separable", "scalable", "multimodal", "bounded", "non-convex"],
        :source => "Jamil & Yang (2013, function 144)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("styblinski_tang requires at least 1 dimension")); fill(-5.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("styblinski_tang requires at least 1 dimension")); fill(5.0, n) end,
    )
)

# Optional: Validierung beim Laden
@assert "styblinski_tang" == basename(@__FILE__)[1:end-3] "styblinski_tang: Dateiname mismatch!"