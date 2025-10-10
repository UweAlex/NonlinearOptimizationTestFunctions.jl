# src/functions/biggsexp2.jl
# Purpose: Implementation of the Biggs EXP2 Function for optimization testing.
# Context: Part of NonlinearOptimizationTestFunctions project.
# Reference: Biggs (1971), Jamil & Yang (2013), f11.
# Note: This function is implemented as non-scalable with a fixed dimension of 2, 
#       as defined in the literature. The global minimum is exactly 0 at [1.0, 10.0].

export BIGGSEXP2_FUNCTION, biggsexp2, biggsexp2_gradient

const TI = [0.1 * i for i in 1:10]
const YI = [exp(-t) - 5 * exp(-10 * t) for t in TI]

"""
    biggsexp2(x)

Biggs EXP2 Function, a continuous, differentiable, non-separable, multimodal function with fixed dimension 2.

# Mathematical Definition
f(x) = \\sum_{i=1}^{10} \\left( e^{-t_i x_1} - 5 e^{-t_i x_2} - y_i \\right)^2

where t_i = 0.1 i, y_i = e^{-t_i} - 5 e^{-10 t_i}

# Domain
0 ≤ x_i ≤ 20

# Global Minimum
f(x*) = 0 at x* = [1, 10]

# Properties
- continuous
- differentiable
- non-separable
- multimodal
- bounded

# Reference
- Biggs, M. C. (1971). Minimization algorithms making use of non-quadratic properties of the objective function. Journal of the Institute of Mathematics and its Applications, 8(3), 315–327.
- Jamil, M., & Yang, X.-S. (2013). A literature survey of benchmark functions for global optimisation problems. International Journal of Mathematical Modelling and Numerical Optimisation, 4(2), 150–194.
"""
function biggsexp2(x::AbstractVector{T}) where T <: Union{Real, ForwardDiff.Dual}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Biggs EXP2 requires exactly 2 dimensions"))

    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    s = zero(T)
    for i in 1:10
        t = TI[i]
        term = exp(-t * x[1]) - 5 * exp(-t * x[2]) - YI[i]
        s += term * term
    end
    s
end

"""
    biggsexp2_gradient(x)

Gradient of the Biggs EXP2 Function.
"""
function biggsexp2_gradient(x::AbstractVector{T}) where T <: Union{Real, ForwardDiff.Dual}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Biggs EXP2 requires exactly 2 dimensions"))

    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)

    g = zeros(T, 2)
    for i in 1:10
        t = TI[i]
        exp1 = exp(-t * x[1])
        exp2 = exp(-t * x[2])
        term = exp1 - 5 * exp2 - YI[i]
        g[1] += 2 * term * (-t * exp1)
        g[2] += 2 * term * (5 * t * exp2)
    end
    g
end

const BIGGSEXP2_FUNCTION = TestFunction(
    biggsexp2,
    biggsexp2_gradient,
    Dict(
        :name => "biggsexp2",
        :start => () -> [0.01, 0.01],
        :min_position => () -> [1.0, 10.0],
        :min_value => () -> 0.0,
        :properties => Set(["continuous", "differentiable", "non-separable", "multimodal", "bounded"]),
        :lb => () -> [0.0, 0.0],
        :ub => () -> [20.0, 20.0],
        :description => "Biggs EXP2 Function, a sum-of-squares function with exact global minimum 0 at [1,10] for n=2. Implemented as non-scalable with fixed dimension 2.",
        :math => raw"\sum_{i=1}^{10} \left( e^{-t_i x_1} - 5 e^{-t_i x_2} - y_i \right)^2 \quad t_i=0.1i, \, y_i = e^{-t_i} - 5 e^{-10 t_i}"
    )
)