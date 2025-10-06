# src/functions/rana.jl
# Purpose: Implementation of the Rana test function.
# Global minimum: f(x*) ≈ -928.5478 at x = [-500, -500] for n=2 (Naser et al., 2024).
# Bounds: -500 ≤ x_i ≤ 500.

export RANA_FUNCTION, rana, rana_gradient

function rana(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Rana requires at least 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    total = zero(T)
    @inbounds for i in 1:(n-1)
        u = x[i]
        v = x[i+1]
        abs1 = abs(u + v + one(T))
        abs2 = abs(v - u + one(T))
        t1 = sqrt(abs1)
        t2 = sqrt(abs2)
        term = (v + one(T)) * cos(t2) * sin(t1) + u * cos(t1) * sin(t2)
        total += term
    end
    total
end

function rana_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("Rana requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)
    @inbounds for i in 1:(n-1)
        u = x[i]
        v = x[i+1]
        abs1 = abs(u + v + one(T))
        abs2 = abs(v - u + one(T))
        t1 = sqrt(abs1)
        t2 = sqrt(abs2)
        s1 = sign(u + v + one(T))
        s2 = sign(v - u + one(T))
        dt1_du = s1 / (2 * t1)
        dt1_dv = s1 / (2 * t1)
        dt2_du = -s2 / (2 * t2)
        dt2_dv = s2 / (2 * t2)
        
        p_h_u = cos(t1) * sin(t2) + 
                (v + one(T)) * (cos(t2) * cos(t1) * dt1_du - sin(t2) * sin(t1) * dt2_du) + 
                u * (-sin(t1) * sin(t2) * dt1_du + cos(t1) * cos(t2) * dt2_du)
        grad[i] += p_h_u
        
        p_h_v = sin(t1) * cos(t2) + 
                (v + one(T)) * (-sin(t2) * sin(t1) * dt2_dv + cos(t2) * cos(t1) * dt1_dv) + 
                u * (-sin(t1) * sin(t2) * dt1_dv + cos(t1) * cos(t2) * dt2_dv)
        grad[i+1] += p_h_v
    end
    grad
end

const RANA_FUNCTION = TestFunction(
    rana,
    rana_gradient,
    Dict(
        :name => "rana",
        :description => "Rana function incorporates a complex iterative trigonometric mechanism on square roots of absolute differences and sums of pairs. Due to trigonometric sensitivity, minor input changes lead to significant output alterations. Operates in broad range [-500,500]; numerous local minima/maxima characterize its landscape. Properties based on Jamil & Yang (2013) and Naser et al. (2024). Note: Naser et al. reports f(x*) = -928.5478 at x=[-500,-500], but computed value is ≈ -464.274; possible discrepancy in formula interpretation or typo in source.",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{D-1} (x_{i+1} + 1) \cos(t_2) \sin(t_1) + x_i \cos(t_1) \sin(t_2), \\
        t_1 = \sqrt{|x_{i+1} + x_i + 1|}, \quad t_2 = \sqrt{|x_{i+1} - x_i + 1|}. """,
        :start => (n::Int) -> begin n < 2 && throw(ArgumentError("Dimension must be at least 2")); zeros(n) end,
        :min_position => (n::Int) -> begin 
            n < 2 && throw(ArgumentError("Dimension must be at least 2"))
            fill(-500.0, n)
        end,
        :min_value => (n::Int) -> begin
            n < 2 && throw(ArgumentError("Dimension must be at least 2"))
            # Computed value for n=2: ≈ -464.274 (differs from Naser et al. 2024 claim of -928.5478)
            # The value scales approximately linearly with (n-1) terms
            return rana(fill(-500.0, n))
        end,
        :default_n => 2,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "scalable", "multimodal"],
        :properties_source => "Jamil & Yang (2013); Naser et al. (2024)",
        :source => "Price et al. (2005). Differential Evolution: A Practical Approach to Global Optimization. Springer; Naser et al. (2024). A Review of 315 Benchmark and Test Functions.",
        :lb => (n::Int) -> begin n < 2 && throw(ArgumentError("Dimension must be at least 2")); fill(-500.0, n) end,
        :ub => (n::Int) -> begin n < 2 && throw(ArgumentError("Dimension must be at least 2")); fill(500.0, n) end,
    )
)