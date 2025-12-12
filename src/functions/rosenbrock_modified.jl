# src/functions/rosenbrock_modified.jl
# Purpose: Implementation of the Rosenbrock Modified test function (Benchmark #106).
# Context: Non-scalable (n=2), multimodal variant of Rosenbrock with added Gaussian perturbation; global min perturbed from standard.
# Global minimum: f(x*)=34.040243106640844 at x*≈[-0.90955374, -0.95057172].
# Bounds: -2 ≤ x_i ≤ 2.
# Last modified: December 11, 2025.
# Properties based on Jamil & Yang (2013).

export ROSENBROCK_MODIFIED_FUNCTION, rosenbrock_modified, rosenbrock_modified_gradient

function rosenbrock_modified(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Rosenbrock Modified requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    x1, x2 = x[1], x[2]
    u = x2 - x1^2
    rosen = 100 * u^2 + (1 - x1)^2
    g = exp(-10 * ((x1 + 1)^2 + (x2 + 1)^2))
    T(74) + rosen - 400 * g
end

function rosenbrock_modified_gradient(x::AbstractVector{T}) where {T<:Union{Real,ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Rosenbrock Modified requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)

    x1, x2 = x[1], x[2]
    u = x2 - x1^2
    g = exp(-10 * ((x1 + 1)^2 + (x2 + 1)^2))

    grad = zeros(T, 2)
    grad[1] = -400 * u * x1 + 2 * (x1 - 1) + 8000 * (x1 + 1) * g
    grad[2] = 200 * u + 8000 * (x2 + 1) * g
    grad
end

const ROSENBROCK_MODIFIED_FUNCTION = TestFunction(
    rosenbrock_modified,
    rosenbrock_modified_gradient,
    Dict(
        :name => "rosenbrock_modified",
        :description => "Rosenbrock Modified function: 74 + 100(x_2 - x_1^2)^2 + (1 - x_1)^2 - 400 exp(-[(x_1 + 1)^2 + (x_2 + 1)^2]/0.1). Multimodal variant with Gaussian perturbation creating a deceptive local minimum near (1,1). Computed min_value via implementation for precision; literature values approximate (e.g., 34.04). Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = 74 + 100(x_2 - x_1^2)^2 + (1 - x_1)^2 - 400 e^{-\frac{(x_1 + 1)^2 + (x_2 + 1)^2}{0.1}}.""",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [-0.9095537365025769, -0.9505717126589607],
        :min_value => () -> 34.04024310664062,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "multimodal", "deceptive", "non-convex", "controversial", "ill-conditioned"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jamil & Yang (2013), Benchmark Function #106",
        :lb => () -> [-2.0, -2.0],
        :ub => () -> [2.0, 2.0],
    )
)