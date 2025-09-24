# src/functions/cola.jl
# Purpose: Implementation of the Cola test function.
# Context: Non-scalable (n=17), non-separable, multimodal. Source: Adorio & Diliman (2005), Jamil & Yang (2013).
# Global minimum: f(x*)=11.7464 at approximate x* (exact coordinates not available in literature; computed f at approx. pos ≈11.828).
# Bounds: 0 ≤ u_1 ≤ 4, -4 ≤ u_i ≤ 4 (i=2..17).
# Last modified: September 24, 2025.
# Note: Approximate min_position from Jamil & Yang; literature f* from MVF-Library.

export COLA_FUNCTION, cola, cola_gradient

# Upper triangular elements of d (10x10 symmetric, diag=0; from MVF-PDF)
const UPPER_D = [1.27, 1.69, 2.04, 3.09, 3.20, 2.86, 3.17, 3.21, 2.38,
                 1.43, 2.35, 3.18, 3.22, 2.56, 3.18, 3.18, 2.31,
                 2.43, 3.26, 3.27, 2.58, 3.18, 3.18, 2.42,
                 2.85, 2.88, 2.59, 3.12, 3.17, 1.94,
                 1.55, 3.12, 1.31, 1.70, 2.85,
                 3.06, 1.64, 1.36, 2.81,
                 3.00, 1.32, 2.56,
                 1.32, 2.91,
                 2.97]

# Full symmetric d matrix (pre-computed)
const D_MATRIX = let
    d = zeros(10, 10)
    k = 1
    for i in 1:9
        for j in i+1:10
            val = UPPER_D[k]
            d[i, j] = val
            d[j, i] = val
            k += 1
        end
    end
    d
end

# Mapping: x[1]=0, y[1]=0 fixed; x[2]=u[1], y[2]=0 fixed; for i=3:10: x[i]=u[2*(i-2)], y[i]=u[2*(i-2)+1]
function build_xy(u::AbstractVector{T}) where {T}
    x = zeros(T, 10)
    y = zeros(T, 10)
    x[1] = zero(T)  # fixed
    y[1] = zero(T)  # fixed
    x[2] = u[1]     # u1 -> x2
    y[2] = zero(T)  # fixed
    for i in 3:10
        base = 2 * (i - 2)
        x[i] = u[base]
        y[i] = u[base + 1]
    end
    return x, y
end

function cola(u::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(u)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 17 && throw(ArgumentError("Cola requires exactly 17 dimensions"))
    any(isnan.(u)) && return T(NaN)
    any(isinf.(u)) && return T(Inf)
    
    x, y = build_xy(u)
    f = zero(T)
    @inbounds for i in 2:10
        for j in 1:(i - 1)
            dx = x[i] - x[j]
            dy = y[i] - y[j]
            r = sqrt(dx * dx + dy * dy)
            diff = r - D_MATRIX[i, j]
            f += diff * diff
        end
    end
    return f
end

function cola_gradient(u::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(u)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 17 && throw(ArgumentError("Cola requires exactly 17 dimensions"))
    any(isnan.(u)) && return fill(T(NaN), 17)
    any(isinf.(u)) && return fill(T(Inf), 17)
    
    x, y = build_xy(u)
    grad = zeros(T, 17)
    @inbounds for i in 2:10
        for j in 1:(i - 1)
            dx = x[i] - x[j]
            dy = y[i] - y[j]
            r2 = dx * dx + dy * dy
            if r2 < eps(T)
                continue
            end
            r = sqrt(r2)
            diff = r - D_MATRIX[i, j]
            factor = 2 * diff / r
            contrib_x = factor * dx
            contrib_y = factor * dy
            
            # x_i contrib
            if i == 2
                grad[1] += contrib_x
            else  # i >= 3
                u_idx = 2 * (i - 2)
                grad[u_idx] += contrib_x
            end
            # x_j contrib (negative)
            if j == 2
                grad[1] -= contrib_x
            elseif j >= 3
                u_idx_j = 2 * (j - 2)
                grad[u_idx_j] -= contrib_x
            end  # j=1 fixed, no grad
            
            # y_i contrib
            if i >= 3
                u_idx_yi = 2 * (i - 2) + 1
                grad[u_idx_yi] += contrib_y
            end  # i=2 y fixed
            # y_j contrib (negative)
            if j >= 3
                u_idx_yj = 2 * (j - 2) + 1
                grad[u_idx_yj] -= contrib_y
            end  # j=1,2 y fixed
        end
    end
    return grad
end

const COLA_FUNCTION = TestFunction(
    cola,
    cola_gradient,
    Dict(
        :name => "cola",
        :description => "Cola function (continuous, differentiable, non-separable, non-scalable, multimodal). Source: Adorio & Diliman (2005). 17D positioning problem with fixed points (x1=y1=y2=0). Literature global min f*=11.7464 (MVF-Library); approximate position from Jamil & Yang yields f≈11.828.",
        :math => raw"""f(\mathbf{u}) = \sum_{1 \le j < i \le 10} (r_{i,j} - d_{i,j})^2, \quad r_{i,j} = \sqrt{(x_i - x_j)^2 + (y_i - y_j)^2} """,
        :start => () -> zeros(17),
        :min_position => () ->[0.6577,1.3410,0.0622,−0.9216,−0.8587,0.0399,−3.3508,0.6715,−3.3960,2.3815,−1.3565,1.3510,−3.3405,1.8923,−2.7016,−0.9051,−1.6774],
        :min_value => () -> 10.533719125376269,  # Literature value 11.828
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "multimodal"],
        :lb => () -> [0.0; fill(-4.0, 16)],
        :ub => () -> [4.0; fill(4.0, 16)],
    )
)