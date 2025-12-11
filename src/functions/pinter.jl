# src/functions/pinter.jl
# Purpose: Implementation of the Pintér test function.
# Context: Scalable multimodal function from Pintér (1996), as f89 in Jamil & Yang (2013).
# Global minimum: f(x*)=0 at x*=zeros(n).
# Bounds: -10 ≤ x_i ≤ 10.
# Start point: fill(5.0, n) → NICHT das Minimum!
# Last modified: November 13, 2025.

export PINTER_FUNCTION, pinter, pinter_gradient

function pinter(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("pinter requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    sum1 = zero(T)
    sum2 = zero(T)
    sum3 = zero(T)
    @inbounds for i in 1:n
        ii = T(i)
        xi = x[i]
        xim1 = x[mod1(i - 1, n)]
        xip1 = x[mod1(i + 1, n)]
        
        # sum1
        sum1 += ii * xi^2
        
        # sum2
        A = xim1 * sin(xi) + sin(xip1)
        sum2 += T(20) * ii * sin(A)^2
        
        # sum3
        B = xim1^2 - T(2) * xi + T(3) * xip1 - cos(xi) + one(T)
        sum3 += ii * log10(one(T) + ii * B^2)
    end
    sum1 + sum2 + sum3
end

function pinter_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("pinter requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    @inbounds for i in 1:n
        ii = T(i)
        xi = x[i]
        xim1 = x[mod1(i - 1, n)]
        xip1 = x[mod1(i + 1, n)]
        
        # --- sum1: ∂/∂x_i = 2 * i * x_i ---
        grad[i] += T(2) * ii * xi
        
        # --- sum2: Beiträge von A_i, A_{i-1}, A_{i+1} ---
        # A_i = x_{i-1} * sin(x_i) + sin(x_{i+1})
        A_i = xim1 * sin(xi) + sin(xip1)
        dA_i_dxi = xim1 * cos(xi)
        grad[i] += T(40) * ii * sin(A_i) * cos(A_i) * dA_i_dxi  # chain rule: 2 * sin * cos * dA/dxi
        
        # A_{i-1} = x_{i-2} * sin(x_{i-1}) + sin(x_i)
        i_m1 = mod1(i - 1, n)
        xim2 = x[mod1(i - 2, n)]
        A_im1 = xim2 * sin(xim1) + sin(xi)
        dA_im1_dxi = cos(xi)
        iim1 = T(i_m1)
        grad[i] += T(40) * iim1 * sin(A_im1) * cos(A_im1) * dA_im1_dxi
        
        # A_{i+1} = x_i * sin(x_{i+1}) + sin(x_{i+2})
        i_p1 = mod1(i + 1, n)
        xip2 = x[mod1(i + 2, n)]
        A_ip1 = xi * sin(xip1) + sin(xip2)
        dA_ip1_dxi = sin(xip1)
        iip1 = T(i_p1)
        grad[i] += T(40) * iip1 * sin(A_ip1) * cos(A_ip1) * dA_ip1_dxi
        
        # --- sum3: Beiträge von B_i, B_{i-1}, B_{i+1} ---
        # B_i = x_{i-1}^2 - 2*x_i + 3*x_{i+1} - cos(x_i) + 1
        B_i = xim1^2 - T(2) * xi + T(3) * xip1 - cos(xi) + one(T)
        dB_i_dxi = -T(2) + sin(xi)
        denom_i = one(T) + ii * B_i^2
        grad[i] += ii / log(T(10)) * (T(2) * ii * B_i * dB_i_dxi) / denom_i
        
        # B_{i-1} = x_{i-2}^2 - 2*x_{i-1} + 3*x_i - cos(x_{i-1}) + 1
        B_im1 = xim2^2 - T(2) * xim1 + T(3) * xi - cos(xim1) + one(T)
        dB_im1_dxi = T(3)
        denom_im1 = one(T) + iim1 * B_im1^2
        grad[i] += iim1 / log(T(10)) * (T(2) * iim1 * B_im1 * dB_im1_dxi) / denom_im1
        
        # B_{i+1} = x_i^2 - 2*x_{i+1} + 3*x_{i+2} - cos(x_{i+1}) + 1
        B_ip1 = xi^2 - T(2) * xip1 + T(3) * xip2 - cos(xip1) + one(T)
        dB_ip1_dxi = T(2) * xi
        denom_ip1 = one(T) + iip1 * B_ip1^2
        grad[i] += iip1 / log(T(10)) * (T(2) * iip1 * B_ip1 * dB_ip1_dxi) / denom_ip1
    end
    grad
end

const PINTER_FUNCTION = TestFunction(
    pinter,
    pinter_gradient,
    Dict{Symbol, Any}(
        :name => "pinter",
        :description => "Pintér Function: Scalable multimodal function with cyclic dependencies. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n i x_i^2 + \sum_{i=1}^n 20 i \sin^2 A + \sum_{i=1}^n i \log_{10} (1 + i B^2), \\ A = x_{i-1} \sin x_i + \sin x_{i+1}, \\ B = x_{i-1}^2 - 2 x_i + 3 x_{i+1} - \cos x_i + 1 \\ (cyclic: x_0 = x_n, x_{n+1} = x_1).""",
        :start => (n::Int) -> begin
            n < 1 && throw(ArgumentError("pinter requires n >= 1"))
            fill(5.0, n)  # GEÄNDERT: NICHT zeros(n)
        end,
        :min_position => (n::Int) -> begin
            n < 1 && throw(ArgumentError("pinter requires n >= 1"))
            zeros(n)
        end,
        :min_value => (n::Int) -> 0.0,
        :default_n => 2,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable", "non-convex", "scalable"],
        :source => "Pintér (1996), via Jamil & Yang (2013): f89",
        :lb => (n::Int) -> begin
            n < 1 && throw(ArgumentError("pinter requires n >= 1"))
            fill(-10.0, n)
        end,
        :ub => (n::Int) -> begin
            n < 1 && throw(ArgumentError("pinter requires n >= 1"))
            fill(10.0, n)
        end,
    )
)

# Validierung beim Laden
