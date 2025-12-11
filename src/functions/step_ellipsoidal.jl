# src/functions/step_ellipsoidal.jl
# Purpose: Implementation of the Step Ellipsoidal (BBOB f7/f18) test function.
# Global minimum: f(x*)=f_opt at x*=x_opt (simplified to 0 here).
# Bounds: -100 ≤ x_i ≤ 100.
# Note: Simplified without full rotation/rounding/penalty for core structure; gradient is piece-wise zero on plateaus.

export STEP_ELLIPSOIDAL_FUNCTION, step_ellipsoidal, step_ellipsoidal_gradient

function step_ellipsoidal(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("step_ellipsoidal requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Simplified: x_opt=0, R=I, no rounding (tilde_z ≈ z), gamma(n)=1, f_opt=0, no f_pen (assume inside bounds)
    # Lambda for ill-conditioning: Lambda_i = 10^{(i-1)/(n-1)}
    lambda = T[10^((i-1)/(n-1)) for i in 1:n]
    z = lambda .* x  # hat_z ≈ z for simplicity
    z1_abs = abs(z[1]) / T(1e4)
    
    sum_term = zero(T)
    @inbounds for i in 1:n
        a = (i-1)/(n-1)
        sum_term += 10^(2 * a) * z[i]^2
    end
    
    f_val = T(0.1) * max(z1_abs, sum_term)
    f_val
end

function step_ellipsoidal_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("step_ellipsoidal requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    # Piece-wise gradient: zero on most plateaus, non-zero only when abs term dominates
    lambda = T[10^((i-1)/(n-1)) for i in 1:n]
    z = lambda .* x
    z1_abs = abs(z[1]) / T(1e4)
    
    sum_term = zero(T)
    @inbounds for i in 1:n
        a = (i-1)/(n-1)
        sum_term += 10^(2 * a) * z[i]^2
    end
    
    grad = zeros(T, n)
    scale = T(0.1)
    
    if sum_term > z1_abs  # Sum (ellipsoid) dominates: full ellipsoid gradient
        @inbounds for i in 1:n
            a = (i-1)/(n-1)
            # Deriv: scale * 2 * 10^(2a) * z_i * lambda_i
            grad[i] = scale * 2 * 10^(2 * a) * z[i] * lambda[i]
        end
    else  # Abs term dominates: gradient only in first component
        if n >= 1
            sign_z1 = sign(z[1])
            grad[1] = scale * (sign_z1 / T(1e4)) * lambda[1]
        end
        # Other components remain zero (plateau)
    end
    
    grad
end

const STEP_ELLIPSOIDAL_FUNCTION = TestFunction(
    step_ellipsoidal,
    step_ellipsoidal_gradient,
    Dict(
        :name => "step_ellipsoidal",
        :description => "Step Ellipsoidal (BBOB f7/f18) benchmark function with plateaus and discontinuities; Properties based on BBOB 2009 Noiseless Functions f7 (Step Ellipsoidal); gradient zero almost everywhere except near boundaries.",
        :math => raw"""f(\mathbf{z}) = 0.1 \max\left( \frac{|\tilde{z}_1|}{10^4}, \sum_{i=1}^D 10^{2(i-1)/(D-1)} \tilde{z}_i^2 \right) + f_\mathrm{pen}(x) + f_\mathrm{opt}.""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,
        :default_n => 2,
        :properties => ["continuous", "non-separable", "scalable", "partially differentiable", "ill-conditioned", "unimodal"],
        :source => "BBOB 2009 Noiseless Functions f7",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(-100.0, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("Dimension must be at least 1")); fill(100.0, n) end,
    )
)
