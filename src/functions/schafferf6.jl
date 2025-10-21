# src/functions/schafferf6.jl
# Purpose: Implementation of the Schaffer F6 test function.
# Global minimum: f(x*)=0.0 at x*=zeros(n) (n-dependent position, constant value).
# Bounds: -100 ≤ x_i ≤ 100.

export SCHAFFERF6_FUNCTION, schafferf6, schafferf6_gradient

function schafferf6(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]  # Dynamisch: "schafferf6" [RULE_NAME_CONSISTENCY]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("$(func_name) requires at least 2 dimensions"))  # Dynamisch [RULE_ERROR_TEXT_DYNAMIC]
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    total = zero(T)
    @inbounds for i in 1:n
        x_next = (i < n) ? x[i+1] : x[1]  # Cyclic: x_{n+1} = x_1
        r_sq = x[i]^2 + x_next^2
        r = sqrt(r_sq)
        num = sin(r)^2
        den = (1 + 0.001 * r_sq)^2
        total += num / den
    end
    total
end

function schafferf6_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    func_name = basename(@__FILE__)[1:end-3]
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 2 && throw(ArgumentError("$(func_name) requires at least 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    grad = zeros(T, n)  # [RULE_GRADTYPE]
    @inbounds for i in 1:n
        # Explizite zyklische Indizes
        i_prev = i == 1 ? n : i - 1
        i_next = i == n ? 1 : i + 1
        
        # Term i: x[i] und x[i_next] (x[i] als erste Komponente)
        r_i_sq = x[i]^2 + x[i_next]^2
        r_i = sqrt(r_i_sq)
        if r_i > 1e-10  # Numerische Stabilität
            den_i = (1 + 0.001 * r_i_sq)^2
            sin_r_i = sin(r_i)
            cos_r_i = cos(r_i)
            num_i = sin_r_i^2
            
            partial_r_i_x_i = x[i] / r_i
            partial_num_i_x_i = 2 * sin_r_i * cos_r_i * partial_r_i_x_i
            partial_den_i_x_i = 2 * (1 + 0.001 * r_i_sq) * 0.001 * 2 * x[i]
            grad[i] += (partial_num_i_x_i * den_i - num_i * partial_den_i_x_i) / den_i^2
        end
        
        # Term i_prev: x[i_prev] und x[i] (x[i] als zweite Komponente)
        r_prev_sq = x[i_prev]^2 + x[i]^2
        r_prev = sqrt(r_prev_sq)
        if r_prev > 1e-10  # Numerische Stabilität
            den_prev = (1 + 0.001 * r_prev_sq)^2
            sin_r_prev = sin(r_prev)
            cos_r_prev = cos(r_prev)
            num_prev = sin_r_prev^2
            
            partial_r_prev_x_i = x[i] / r_prev
            partial_num_prev_x_i = 2 * sin_r_prev * cos_r_prev * partial_r_prev_x_i
            partial_den_prev_x_i = 2 * (1 + 0.001 * r_prev_sq) * 0.001 * 2 * x[i]
            grad[i] += (partial_num_prev_x_i * den_prev - num_prev * partial_den_prev_x_i) / den_prev^2
        end
    end
    grad
end

const SCHAFFERF6_FUNCTION = TestFunction(
    schafferf6,
    schafferf6_gradient,
    Dict(
        :name => basename(@__FILE__)[1:end-3],  # Dynamisch: "schafferf6" [RULE_NAME_CONSISTENCY]
        :description => "Schaffer F6 function; multimodal with cyclic dependency; properties based on Jamil & Yang (2013, p. 32, f136); originally from Schaffer et al. (1989).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^n \frac{\sin^2 \sqrt{x_i^2 + x_{i+1}^2}}{(1 + 0.001 (x_i^2 + x_{i+1}^2))^2}, \quad x_{n+1} = x_1.""",
        :start => (n::Int) -> begin n < 2 && throw(ArgumentError("Dimension must be at least 2")); zeros(n) end,
        :min_position => (n::Int) -> begin n < 2 && throw(ArgumentError("Dimension must be at least 2")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,  # Konstant [RULE_META_CONSISTENCY]
        :default_n => 2,  # [RULE_DEFAULT_N]
        :properties => ["continuous", "differentiable", "scalable", "multimodal", "non-separable"],
        :source => "Jamil & Yang (2013, p. 32)",  # Direkte Quelle mit Stelle
        :lb => (n::Int) -> begin n < 2 && throw(ArgumentError("Dimension must be at least 2")); fill(-100.0, n) end,
        :ub => (n::Int) -> begin n < 2 && throw(ArgumentError("Dimension must be at least 2")); fill(100.0, n) end,
    )
)