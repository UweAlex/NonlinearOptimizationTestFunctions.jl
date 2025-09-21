# src/functions/biggsexp3.jl
# Purpose: Implementation of the Biggs EXP3 Function for optimization testing.
# Context: Part of NonlinearOptimizationTestFunctions project.
# Reference: Biggs (1971), Jamil & Yang (2013), f12.
# Note: This function is implemented as non-scalable with a fixed dimension of 3, 
#       as defined in the literature. The global minimum is exactly 0 at [1.0, 10.0, 5.0].

__precompile__()

module BiggsEXP3Module

export BIGGSEXP3_FUNCTION, biggsexp3, biggsexp3_gradient

using NonlinearOptimizationTestFunctions: TestFunction

const TI = [0.1 * i for i in 1:10]
const YI = [exp(-t) - 5 * exp(-10 * t) for t in TI]

"""
    biggsexp3(x)

Biggs EXP3 Function, a continuous, differentiable, non-separable, multimodal function with fixed dimension 3.

# Mathematical Definition
f(x) = \\sum_{i=1}^{10} \\left( e^{-t_i x_1} - x_3 e^{-t_i x_2} - y_i \\right)^2

where t_i = 0.1 i, y_i = e^{-t_i} - 5 e^{-10 t_i}

# Domain
0 ≤ x_i ≤ 20

# Global Minimum
f(x*) = 0 at x* = [1, 10, 5]

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
function biggsexp3(x::AbstractVector{T}) where {T <: Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Biggs EXP3 requires exactly 3 dimensions"))

    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)

    s = zero(T)
    for i in 1:10
        t = TI[i]
        term = exp(-t * x[1]) - x[3] * exp(-t * x[2]) - YI[i]
        s += term * term
    end
    s
end

"""
    biggsexp3_gradient(x)

Gradient of the Biggs EXP3 Function.
"""
function biggsexp3_gradient(x::AbstractVector{T}) where {T <: Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Biggs EXP3 requires exactly 3 dimensions"))

    any(isnan.(x)) && return fill(T(NaN), 3)
    any(isinf.(x)) && return fill(T(Inf), 3)

    g = zeros(T, 3)
    for i in 1:10
        t = TI[i]
        exp1 = exp(-t * x[1])
        exp2 = exp(-t * x[2])
        term = exp1 - x[3] * exp2 - YI[i]
        g[1] += 2 * term * (-t * exp1)
        g[2] += 2 * term * (x[3] * t * exp2)
        g[3] += 2 * term * (-exp2)
    end
    g
end

const BIGGSEXP3_FUNCTION = TestFunction(
    biggsexp3,
    biggsexp3_gradient,
    Dict(
        :name => "biggsexp3",
        :start => () -> [0.01, 0.01, 0.01],
        :min_position => () -> [1.0, 10.0, 5.0],
        :min_value => () -> 0.0,
        :properties => Set(["continuous", "differentiable", "non-separable", "multimodal", "bounded"]),
        :lb => () -> [0.0, 0.0, 0.0],
        :ub => () -> [20.0, 20.0, 20.0],
        :description => "Biggs EXP3 Function, a sum-of-squares function with exact global minimum 0 at [1,10,5] for n=3. Implemented as non-scalable with fixed dimension 3.",
        :math => raw"\sum_{i=1}^{10} \left( e^{-t_i x_1} - x_3 e^{-t_i x_2} - y_i \right)^2 \quad t_i=0.1i, \, y_i = e^{-t_i} - 5 e^{-10 t_i}"
    )
)

end  # module BiggsEXP3Module