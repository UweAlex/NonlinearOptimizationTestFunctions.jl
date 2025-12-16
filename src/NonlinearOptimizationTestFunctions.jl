# src/NonlinearOptimizationTestFunctions.jl
# Purpose: Core module for NonlinearOptimizationTestFunctions.jl
# Stand: 16. Dezember 2025 – FINAL: Alle Konstruktor-Probleme behoben
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

# ===================================================================
# 2. TestFunction struct
# ===================================================================

struct TestFunction
    f::Function
    grad::Function
    gradient!::Function
    f_original::Function
    grad_original::Function
    meta::Dict{Symbol,Any}
    name::String
    f_count::Ref{Int}
    grad_count::Ref{Int}

    # ===================================================================
    # Main constructor - creates new counters
    # ===================================================================
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

        new(
            f_wrapped,
            grad_wrapped,
            gradient_wrapped!,
            f,
            grad,
            meta,
            name,
            f_count,
            grad_count
        )
    end

    # ===================================================================
    # Alternative constructor - uses provided counter Refs
    # ===================================================================
    function TestFunction(
        f::Function,
        grad::Function,
        meta::Dict{Symbol,Any},
        f_count::Ref{Int},
        grad_count::Ref{Int}
    )
        required = [:name, :start, :min_position, :min_value, :properties, :lb, :ub]
        missing_keys = setdiff(required, keys(meta))
        isempty(missing_keys) || throw(ArgumentError("Missing required meta keys: $missing_keys"))

        meta[:properties] = Set(lowercase.(string.(meta[:properties])))
        invalid = setdiff(meta[:properties], VALID_PROPERTIES)
        isempty(invalid) || throw(ArgumentError("Invalid properties: $invalid"))

        name = meta[:name]
        gradient! = (G, x) -> copyto!(G, grad(x))

        # ✅ FIX: new() works inside struct definition, not TestFunction.new()
        new(
            f,
            grad,
            gradient!,
            f,
            grad,
            meta,
            name,
            f_count,
            grad_count
        )
    end
end

# ===================================================================
# 3. Metadata access helpers
# ===================================================================

function access_metadata(tf::TestFunction, key::Symbol, n::Union{Int,Nothing}=nothing)
    val = tf.meta[key]
    val isa Function || return val

    if "scalable" in tf.meta[:properties]
        if isnothing(n)
            error("Metadata :$key requires dimension n for scalable function $(tf.meta[:name])")
        end
        return val(n)
    else
        return val()
    end
end

start(tf::TestFunction, n::Union{Int,Nothing}=nothing) = access_metadata(tf, :start, n)
min_position(tf::TestFunction, n::Union{Int,Nothing}=nothing) = access_metadata(tf, :min_position, n)
min_value(tf::TestFunction, n::Union{Int,Nothing}=nothing) = access_metadata(tf, :min_value, n)
lb(tf::TestFunction, n::Union{Int,Nothing}=nothing) = access_metadata(tf, :lb, n)
ub(tf::TestFunction, n::Union{Int,Nothing}=nothing) = access_metadata(tf, :ub, n)
source(tf::TestFunction) = get(tf.meta, :source, "Unknown Source")

# ===================================================================
# 4. MODERN PROPERTY HANDLING
# ===================================================================

function property(tf::TestFunction, prop::AbstractString)
    p = lowercase(string(prop))
    p in VALID_PROPERTIES || throw(ArgumentError(
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

"""
    properties(tf::TestFunction) -> Vector{String}

Returns a vector containing all properties of the test function.
"""
function properties(tf::TestFunction)
    return sort(collect(tf.meta[:properties]))
end

export properties

get_f_count(tf::TestFunction) = tf.f_count[]
get_grad_count(tf::TestFunction) = tf.grad_count[]
reset_counts!(tf::TestFunction) = (tf.f_count[] = 0; tf.grad_count[] = 0)

dim(tf::TestFunction) = "scalable" in tf.meta[:properties] ? -1 : length(min_position(tf))

filter_testfunctions(pred, dict=TEST_FUNCTIONS) = [tf for tf in values(dict) if pred(tf)]

# ===================================================================
# 7. fixed() – convert scalable → fixed-dimension instance
# ===================================================================

"""
    fixed(tf::TestFunction; n::Union{Int,Nothing}=nothing) -> TestFunction
    fixed(tf::TestFunction, n::Int) -> TestFunction

Return a non-scalable `TestFunction` with fixed dimension.
"""
function fixed(tf::TestFunction; n::Union{Int,Nothing}=nothing)
    !scalable(tf) && return tf

    n_fixed = n !== nothing ? n :
              haskey(tf.meta, :default_n) ? tf.meta[:default_n] :
              error("Scalable function '$(tf.name)' has no :default_n and no explicit n given")

    tf_fixed = TestFunction(
        tf.f_original,
        tf.grad_original,
        deepcopy(tf.meta)
    )

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

export TEST_FUNCTIONS, TestFunction, filter_testfunctions
export start, min_position, min_value, lb, ub, dim
export property, bounded, scalable, differentiable, multimodal, separable
export get_f_count, get_grad_count, reset_counts!
export fixed
export optimization_problem
export source

include("l1_penalty_wrapper.jl")
using Optimization
include("optimization_integration.jl")

end # module NonlinearOptimizationTestFunctions