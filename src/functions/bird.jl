# src/functions/bird.jl
# Purpose: Implementation of the Bird test function.
# Global minimum: f(x*) ≈ -106.76453671958178 at two symmetric points.
# Bounds: -2π ≤ x_i ≤ 2π.

export BIRD_FUNCTION, bird, bird_gradient

function bird(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bird requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    if T <: BigFloat
        setprecision(256)
    end
    
    x1, x2 = x
    sin(x1) * exp((1 - cos(x2))^2) + cos(x2) * exp((1 - sin(x1))^2) + (x1 - x2)^2
end

function bird_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("bird requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    x1, x2 = x
    a = 1 - cos(x2)
    b = 1 - sin(x1)
    exp_a = exp(a^2)
    exp_b = exp(b^2)
    
    # ∂f/∂x1 - KORRIGIERT: negatives Vorzeichen hinzugefügt
    grad[1] = cos(x1) * exp_a - 2 * cos(x2) * b * cos(x1) * exp_b + 2 * (x1 - x2)
    
    # ∂f/∂x2
    grad[2] = 2 * sin(x1) * a * sin(x2) * exp_a - sin(x2) * exp_b + 2 * (x2 - x1)
    
    grad
end


const BIRD_FUNCTION = TestFunction(
    bird,
    bird_gradient,
    Dict{Symbol, Any}(
        :name => "bird",
        :description => "Properties based on Jamil & Yang (2013, p. 9); Highly multimodal with two symmetric global minima. The reported minima are high-precision numerical approximations obtained via global optimization; they are not critical points (∇f ≠ 0) and the exact analytical positions are unknown. Gradient norm at reported minima ≈ 4.95.",
      :math => raw"""f(\mathbf{x}) = \sin x_1 \exp\left((1 - \cos x_2)^2\right) + \cos x_2 \exp\left((1 - \sin x_1)^2\right) + (x_1 - x_2)^2.""",
        :start => () -> [0.0, 0.0],
 :min_position => () -> [4.701043130240078, 3.152938503721135],
  :min_value => () -> -106.76453674926468,
      :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"],
        :source => "Jamil & Yang (2013, p. 9)",
        :lb => () -> [-2π, -2π],
        :ub => () -> [2π, 2π],
    )
)

@assert "bird" == basename(@__FILE__)[1:end-3] "bird: Dateiname mismatch!"