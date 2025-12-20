# src/NonlinearOptimizationTestFunctions.jl
# Purpose: Core module for NonlinearOptimizationTestFunctions.jl
# Stand: 18. Dezember 2025 – Mit automatischen Property-Accessoren (korrigierter Export)
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

    # Main constructor - creates new counters
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

    # Alternative constructor - uses provided counter Refs (for wrappers like l1_penalty)
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
        isnothing(n) && error("Metadata :$key requires dimension n for scalable function $(tf.name)")
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
# 3.1 User-friendly accessors
# ===================================================================

name(tf::TestFunction) = tf.name
description(tf::TestFunction) = get(tf.meta, :description, "No description available.")
math(tf::TestFunction) = get(tf.meta, :math, raw"Placeholder: f(\mathbf{x}) = \dots")

function default_n(tf::TestFunction)
    scalable(tf) || error("default_n is only defined for scalable functions")
    tf.meta[:default_n]  # per RULE_DEFAULT_N: MUST exist
end

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

# ===================================================================
# 5. Auto-generate accessor functions for all valid properties + static export
# ===================================================================

# *** NOTE ON THIS BLOCK ***
# This section automatically generates boolean accessor functions (e.g. scalable(tf), convex(tf))
# for every property in VALID_PROPERTIES and exports them.
# It uses @eval and dynamic Expr building to create a static `export` statement.
# While it may look "magical" to Julia beginners, it is safe, idiomatic for this use case,
# runs only at module load time, and has zero runtime cost.
# All generated functions are fully documented via docstrings.

export_expr = Expr(:export)

for prop in VALID_PROPERTIES
    func_name = Symbol(replace(lowercase(prop), r"[ -]" => ""))

    @eval begin
        """
            $($func_name)(tf::TestFunction) -> Bool

        Check if the test function has the "$($prop)" property.
        """
        $func_name(tf::TestFunction) = property(tf, $prop)
    end

    push!(export_expr.args, func_name)
end

# Static export of all generated accessors
@eval $export_expr

# ===================================================================
# 6. Utility functions
# ===================================================================

"""
    properties(tf::TestFunction) -> Vector{String}
Returns a sorted vector of all properties.
"""
function properties(tf::TestFunction)
    sort(collect(tf.meta[:properties]))
end

export properties

get_f_count(tf::TestFunction) = tf.f_count[]
get_grad_count(tf::TestFunction) = tf.grad_count[]
reset_counts!(tf::TestFunction) = (tf.f_count[] = 0; tf.grad_count[] = 0)

dim(tf::TestFunction) = scalable(tf) ? -1 : length(min_position(tf))

filter_testfunctions(pred, dict=TEST_FUNCTIONS) = [tf for tf in values(dict) if pred(tf)]

# ===================================================================
# 7. fixed() – convert scalable → fixed-dimension instance
# ===================================================================

"""
    fixed(tf::TestFunction; n::Union{Int,Nothing}=nothing) -> TestFunction
    fixed(tf::TestFunction, n::Int) -> TestFunction

Return a fixed-dimension `TestFunction`. For scalable functions, uses `n` or `:default_n`.
"""
function fixed(tf::TestFunction; n::Union{Int,Nothing}=nothing)
    !scalable(tf) && return tf

    n_fixed = n !== nothing ? n : tf.meta[:default_n]  # per rule: MUST exist

    tf_fixed = TestFunction(
        tf.f_original,
        tf.grad_original,
        deepcopy(tf.meta),
        tf.f_count,
        tf.grad_count
    )

    for (key, val) in tf_fixed.meta
        if val isa Function
            tf_fixed.meta[key] = let n = n_fixed
                () -> val(n)
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
export property, get_f_count, get_grad_count, reset_counts!
export fixed, name, description, math, default_n, source
export optimization_problem

include("l1_penalty_wrapper.jl")
using Optimization
include("optimization_integration.jl")

end # module NonlinearOptimizationTestFunctions