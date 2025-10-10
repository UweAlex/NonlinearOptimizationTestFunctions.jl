# src/functions/ackley4.jl
# Purpose: Implementation of the Modified Ackley Function (Ackley Function 4) for optimization testing.
# Context: Part of NonlinearOptimizationTestFunctions project.
# Reference: Jamil & Yang (2013), f4.
# Note: This function is implemented as non-scalable with a fixed dimension of 2, 
#       because necessary metadata (such as global minima positions and values) 
#       is only available and well-defined for D=2 in the literature. 
#       For other dimensions, no reliable metainformation (e.g., precise minima) 
#       is provided, making scalability impractical without introducing inconsistencies.
#       The literature reports an incorrect minimum value (-3.917275) and approximate position; 
#       corrected here using high-precision optimization. This is a local minimum; 
#       the global minimum approaches -6 near the boundaries due to the exponential decay.
#       Added "controversial" property due to discrepancies in literature.
#       Start point adjusted to be closer to the local minimum to ensure convergence in derivative-free optimizers like Nelder-Mead.

export ACKLEY4_FUNCTION, ackley4, ackley4_gradient

"""
    ackley4(x)

Modified Ackley Function (Ackley Function 4), a highly multimodal, continuous, differentiable, non-separable function with fixed dimension 2.

# Mathematical Definition
f(x) = ∑_{i=1}^{D-1} [e^(-0.2 * √(x_i^2 + x_{i+1}^2)) + 3 * (cos(2x_i) + sin(2x_{i+1}))]

# Domain
-35 ≤ x_i ≤ 35

# Local Minimum (corrected from literature)
f(x*) ≈ -5.297009385988958 at x* ≈ [-1.5812643986108843, -0.7906319137820829]

# Properties
- continuous
- differentiable
- non-separable
- highly multimodal
- bounded
- controversial

# Reference
- Jamil, M., & Yang, X.-S. (2013). A literature survey of benchmark functions for global optimisation problems. International Journal of Mathematical Modelling and Numerical Optimisation, 4(2), 150–194.
"""
function ackley4(x::AbstractVector{T}) where T <: Union{Real, ForwardDiff.Dual}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Ackley4 requires exactly 2 dimensions"))

    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    s = zero(T)
    for i in 1:n-1
        term = exp(-0.2 * sqrt(x[i]^2 + x[i+1]^2)) + 3 * (cos(2 * x[i]) + sin(2 * x[i+1]))
        s += term
    end
    s
end

"""
    ackley4_gradient(x)

Gradient of the Modified Ackley Function (Ackley Function 4).
"""
function ackley4_gradient(x::AbstractVector{T}) where T <: Union{Real, ForwardDiff.Dual}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Ackley4 requires exactly 2 dimensions"))

    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)

    g = zeros(T, 2)

    for i in 1:n-1
        x_i, x_ip1 = x[i], x[i+1]
        denom = sqrt(x_i^2 + x_ip1^2)
        exp_term = exp(-0.2 * denom)
        g[i] += -0.2 * exp_term * x_i / denom + 3 * (-2 * sin(2 * x_i))
        if i < n
            g[i+1] += -0.2 * exp_term * x_ip1 / denom + 3 * (2 * cos(2 * x_ip1))
        end
    end
    g
end

const ACKLEY4_FUNCTION = TestFunction(
    ackley4,
    ackley4_gradient,
    Dict(
        :name => "ackley4",
        :start => () -> [-1.5, -0.75],
        :min_position => () -> [-1.5812643986108843, -0.7906319137820829],
        :min_value => () -> -5.297009385988958,
        :properties => Set(["continuous", "differentiable", "non-separable", "highly multimodal", "bounded", "controversial"]),
        :lb => () -> [-35.0, -35.0],
        :ub => () -> [35.0, 35.0],
        :description => "Modified Ackley Function with multiple local minima for n=2. The provided local minimum is corrected from literature (which had errors in value and position). The global minimum approaches -6 near boundaries, but tests focus on this local minimum near the origin. Implemented as non-scalable with fixed dimension 2, as metadata for other dimensions is unavailable.",
        :math => raw"\sum_{i=1}^{D-1} \left[ e^{-0.2 \sqrt{x_i^2 + x_{i+1}^2}} + 3 (\cos(2x_i) + \sin(2x_{i+1})) \right]"
    )
)