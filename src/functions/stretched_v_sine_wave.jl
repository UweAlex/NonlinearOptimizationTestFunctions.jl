# src/functions/stretched_v_sine_wave.jl
# Purpose: Implementation of the Stretched V Sine Wave test function.
# Global minimum: f(x*)=0.0 at x*=(0.0, ..., 0.0).
# Bounds: -10.0 ≤ x_i ≤ 10.0.

export STRETCHED_V_SINE_WAVE_FUNCTION, stretched_v_sine_wave, stretched_v_sine_wave_gradient

function stretched_v_sine_wave(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("stretched_v_sine_wave requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum_val = zero(T)
    @inbounds for i in 1:n-1
        u = x[i]^2 + x[i+1]^2
        term = u^0.25 * (sin(50 * u^0.1)^2 + 0.1)
        sum_val += term
    end
    sum_val
end

function stretched_v_sine_wave_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("stretched_v_sine_wave requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    @inbounds for i in 1:n-1
        u = x[i]^2 + x[i+1]^2
        if u > 0
            sin_term = sin(50 * u^0.1)
            cos_term = cos(50 * u^0.1)
            inner = sin_term^2 + 0.1
            du_dx_i = 2 * x[i]
            du_dx_ip1 = 2 * x[i+1]
            
            # Partial wrt u
            partial_u = 0.25 * u^(-0.75) * inner + u^0.25 * (2 * sin_term * cos_term * 50 * 0.1 * u^(-0.9))
            
            grad[i] += partial_u * du_dx_i
            grad[i+1] += partial_u * du_dx_ip1
        end
    end
    grad
end

const STRETCHED_V_SINE_WAVE_FUNCTION = TestFunction(
    stretched_v_sine_wave,
    stretched_v_sine_wave_gradient,
    Dict(
        :name => "stretched_v_sine_wave",
        :description => "Properties based on Jamil & Yang (2013, function 142); originally from Schaffer et al. (1989).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{D-1} (x_i^2 + x_{i+1}^2)^{0.25} \left[ \sin^2 \left\{ 50 (x_i^2 + x_{i+1}^2)^{0.1} \right\} + 0.1 \right].""",
        :start => (n::Int) -> begin n < 2 && throw(ArgumentError("stretched_v_sine_wave requires at least 2 dimensions")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 2 && throw(ArgumentError("stretched_v_sine_wave requires at least 2 dimensions")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,
        :default_n => 2,
        :properties => ["continuous", "differentiable", "non-separable", "scalable", "unimodal", "bounded"],
        :source => "Jamil & Yang (2013, function 142)",
        :lb => (n::Int) -> begin n < 2 && throw(ArgumentError("stretched_v_sine_wave requires at least 2 dimensions")); fill(-10.0, n) end,
        :ub => (n::Int) -> begin n < 2 && throw(ArgumentError("stretched_v_sine_wave requires at least 2 dimensions")); fill(10.0, n) end,
    )
)

# Optional: Validierung beim Laden
@assert "stretched_v_sine_wave" == basename(@__FILE__)[1:end-3] "stretched_v_sine_wave: Dateiname mismatch!"