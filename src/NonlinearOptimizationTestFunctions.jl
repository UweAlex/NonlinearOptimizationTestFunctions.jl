# src/NonlinearOptimizationTestFunctions.jl
# Purpose: Core module for NonlinearOptimizationTestFunctions.jl
# Stand: 29. November 2025 – precompile-sicher + tf.scalable ready
module NonlinearOptimizationTestFunctions
__precompile__(false)
using LinearAlgebra
using ForwardDiff


# ===================================================================
# 1. VALID PROPERTIES & DEFAULTS
# ===================================================================

const VALID_PROPERTIES = Set{String}([
    "bounded", "continuous", "controversial", "convex", "deceptive",
    "differentiable", "finite_at_inf", "fully non-separable",
    "has_constraints", "has_noise", "highly multimodal", "multimodal",
    "non-convex", "non-separable", "partially differentiable",
    "partially separable", "quasi-convex", "scalable", "separable",
    "strongly convex", "unimodal", "ill-conditioned"
])

const DEFAULT_N = Ref(2)  # mutable default dimension for scalable functions

# ===================================================================
# 2. TestFunction struct
# ===================================================================

struct TestFunction
    f::Function
    grad::Function
    gradient!::Function
    meta::Dict{Symbol,Any}
    name::String
    f_count::Ref{Int}
    grad_count::Ref{Int}

    function TestFunction(f, grad, meta)
        required = [:name, :start, :min_position, :min_value, :properties, :lb, :ub]
        missing_keys = setdiff(required, keys(meta))
        isempty(missing_keys) || throw(ArgumentError("Missing required meta keys: $missing_keys"))

        meta[:properties] = Set(lowercase.(string.(meta[:properties])))
        invalid = setdiff(meta[:properties], VALID_PROPERTIES)
        isempty(invalid) || throw(ArgumentError("Invalid properties: $invalid"))

        name = meta[:name]
        f_count = Ref(0)
        grad_count = Ref(0)

        f_wrapped = x -> (f_count[] += 1; f(x))
        grad_wrapped = x -> (grad_count[] += 1; grad(x))
        gradient_wrapped! = (G, x) -> (grad_count[] += 1; copyto!(G, grad(x)))

        new(f_wrapped, grad_wrapped, gradient_wrapped!, meta, name, f_count, grad_count)
    end
end

# ===================================================================
# 3. Metadata access helpers
# ===================================================================

function access_metadata(tf::TestFunction, key::Symbol, n::Union{Int,Nothing}=nothing)
    is_scalable = "scalable" in tf.meta[:properties]
    val = get(tf.meta, key, nothing)
    val === nothing && throw(ArgumentError("Metadata key :$key not found for $(tf.name)"))

    if is_scalable
        isa(val, Function) || throw(ArgumentError(":$key must be a function for scalable function $(tf.name)"))
        dim = isnothing(n) ? DEFAULT_N[] : n
        dim ≥ 1 || throw(ArgumentError("Dimension must be ≥ 1"))
        return val(dim)
    else
        isa(val, Function) ? val() : val
    end
end

start(tf::TestFunction, n::Union{Int,Nothing}=nothing) = access_metadata(tf, :start, n)
min_position(tf::TestFunction, n::Union{Int,Nothing}=nothing) = access_metadata(tf, :min_position, n)
min_value(tf::TestFunction, n::Union{Int,Nothing}=nothing) = access_metadata(tf, :min_value, n)
lb(tf::TestFunction, n::Union{Int,Nothing}=nothing) = access_metadata(tf, :lb, n)
ub(tf::TestFunction, n::Union{Int,Nothing}=nothing) = access_metadata(tf, :ub, n)

# ===================================================================
# 4. MODERN PROPERTY HANDLING (precompile-safe + tf.scalable)
# ===================================================================

function property(tf::TestFunction, prop::AbstractString)
    p = lowercase(string(prop))
    p in (p, VALID_PROPERTIES) || throw(ArgumentError(
        "Invalid property '$p'. Allowed: $(join(sort(collect(VALID_PROPERTIES)), ", "))"
    ))
    return p in tf.meta[:properties]
end

has_property(tf::TestFunction, prop::AbstractString) = property(tf, prop)
has_property(tf::TestFunction, prop::Symbol) = has_property(tf, string(prop))
@deprecate has_property(tf, prop) property(tf, prop)

Base.getproperty(tf::TestFunction, sym::Symbol) =
    sym in fieldnames(TestFunction) ? getfield(tf, sym) : getproperty(tf.meta, sym)

# ===================================================================
# 5. Convenience property shortcuts
# ===================================================================

bounded(tf::TestFunction) = property(tf, "bounded")
scalable(tf::TestFunction) = property(tf, "scalable")
differentiable(tf::TestFunction) = property(tf, "differentiable")
multimodal(tf::TestFunction) = property(tf, "multimodal")
separable(tf::TestFunction) = property(tf, "separable")

# ===================================================================
# 6. Utility functions
# ===================================================================

set_default_n!(n::Int) = (n ≥ 1 || throw(ArgumentError("n ≥ 1 required"));
DEFAULT_N[] = n)

get_f_count(tf::TestFunction) = tf.f_count[]
get_grad_count(tf::TestFunction) = tf.grad_count[]
reset_counts!(tf::TestFunction) = (tf.f_count[] = 0; tf.grad_count[] = 0)

dim(tf::TestFunction) = "scalable" in tf.meta[:properties] ? -1 : length(min_position(tf))


function use_testfunction(tf::TestFunction, x::Vector{T}, n::Union{Int,Nothing}=nothing) where T
    isempty(x) && throw(ArgumentError("x must not be empty"))
    is_scalable = "scalable" in tf.meta[:properties]
    d = is_scalable ? (isnothing(n) ? DEFAULT_N[] : n) : dim(tf)
    length(x) == d || throw(ArgumentError("wrong dimension for $(tf.name)"))
    (f=tf.f(x), grad=tf.grad(x))
end

filter_testfunctions(pred, dict=TEST_FUNCTIONS) = [tf for tf in values(dict) if pred(tf)]

# ===================================================================
# 7. fixed() – convert scalable → fixed-dimension instance
# ===================================================================

"""
    fixed(tf::TestFunction; n::Union{Int,Nothing}=nothing) -> TestFunction
    fixed(tf::TestFunction, n::Int) -> TestFunction

Return a non-scalable `TestFunction` with fixed dimension.
Uses `tf.meta[:default_n]` if no `n` is given.
Future-proof: automatically binds all dimension-dependent metadata.
"""
function fixed(tf::TestFunction; n::Union{Int,Nothing}=nothing)
    !scalable(tf) && return tf

    n_fixed = n !== nothing ? n :
              haskey(tf.meta, :default_n) ? tf.meta[:default_n] :
              error("Scalable function '$(tf.name)' has no :default_n and no explicit n given")

    # Use the real constructor – tf.f and tf.grad are already wrapped with counters
    tf_fixed = TestFunction(
        tf.f,
        tf.grad,
        deepcopy(tf.meta)
    )

    # Bind all dimension-dependent metadata
    for (key, val) in tf_fixed.meta
        if val isa Function
            try
                _ = val(n_fixed)
                tf_fixed.meta[key] = let n = n_fixed
                    () -> val(n)
                end
            catch
            end
        end
    end

    filter!(!=("scalable"), tf_fixed.meta[:properties])
    return tf_fixed
end

fixed(tf::TestFunction, n::Int) = fixed(tf; n=n)

# ===================================================================
# 8. Registry & includes
# ===================================================================

const TEST_FUNCTIONS = Dict{String,TestFunction}()

include("include_testfunctions.jl")

for name in names(@__MODULE__, all=true)
    s = string(name)
    endswith(s, "_FUNCTION") || continue
    val = getfield(@__MODULE__, name)
    val isa TestFunction || continue
    TEST_FUNCTIONS[val.name] = val
end

# Export everything
for tf in values(TEST_FUNCTIONS)
    fn_sym = Symbol(lowercase(tf.name))
    grad_sym = Symbol(lowercase(tf.name) * "_gradient")
    const_sym = Symbol(uppercase(tf.name) * "_FUNCTION")
    isdefined(@__MODULE__, fn_sym) && @eval export $fn_sym
    isdefined(@__MODULE__, grad_sym) && @eval export $grad_sym
    isdefined(@__MODULE__, const_sym) && @eval export $const_sym
end

export TEST_FUNCTIONS, TestFunction, filter_testfunctions, use_testfunction
export start, min_position, min_value, lb, ub, dim
export property, bounded, scalable, differentiable, multimodal, separable
export get_f_count, get_grad_count, reset_counts!, set_default_n!
export fixed
export optimization_problem

include("l1_penalty_wrapper.jl")
using Optimization
include("optimization_integration.jl")

end # module NonlinearOptimizationTestFunctions