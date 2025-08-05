# src/NonlinearOptimizationTestFunctions.jl
# Purpose: Defines the core module for nonlinear optimization test functions.
# Context: Provides TestFunction structure, metadata validation, and function registry.
# Last modified: 20 July 2025

module NonlinearOptimizationTestFunctions

using LinearAlgebra
using ForwardDiff

const VALID_PROPERTIES = Set([
    "unimodal", "multimodal", "highly multimodal", "deceptive",
    "convex", "non-convex", "quasi-convex", "strongly convex",
    "separable", "non-separable", "partially separable", "fully non-separable",
    "differentiable","partially differentiable", "scalable", "continuous", "bounded", "has_constraints",
    "controversial"  # Neue Eigenschaft hinzugefügt
])

struct TestFunction
    f::Function
    grad::Function
    gradient!::Function
    meta::Dict{Symbol, Any}
    function TestFunction(f, grad, meta)
        required_keys = [:name, :start, :min_position, :min_value, :properties, :lb, :ub]
        missing_keys = setdiff(required_keys, keys(meta))
        isempty(missing_keys) || throw(ArgumentError("Missing required meta keys: $missing_keys"))
        meta[:properties] = Set(lowercase.(string.(meta[:properties])))
        all(p in VALID_PROPERTIES for p in meta[:properties]) || throw(ArgumentError("Invalid properties: $(setdiff(meta[:properties], VALID_PROPERTIES))"))
        gradient! = (G, x) -> copyto!(G, grad(x))
        new(f, grad, gradient!, meta)
    end
end

function has_property(tf::TestFunction, prop::String)
    lprop = lowercase(prop)
    lprop in VALID_PROPERTIES || throw(ArgumentError("Invalid property: $lprop"))
    return lprop in tf.meta[:properties]
end

function add_property(tf::TestFunction, prop::String)
    lprop = lowercase(prop)
    lprop in VALID_PROPERTIES || throw(ArgumentError("Invalid property: $lprop"))
    new_meta = copy(tf.meta)
    new_meta[:properties] = union(tf.meta[:properties], [lprop])
    return TestFunction(tf.f, tf.grad, new_meta)
end

function use_testfunction(tf::TestFunction, x::Vector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    isempty(x) && throw(ArgumentError("Input vector x must not be empty"))
    return (f=tf.f(x), grad=tf.grad(x))
end

function filter_testfunctions(predicate::Function, test_functions=TEST_FUNCTIONS)
    return [tf for tf in values(test_functions) if predicate(tf)]
end

const TEST_FUNCTIONS = Dict{String, TestFunction}()

include("include_testfunctions.jl")

for name in names(@__MODULE__, all=true)
    try
        if endswith(string(name), "_FUNCTION")
            tf = getfield(@__MODULE__, name)
            if tf isa TestFunction
                TEST_FUNCTIONS[tf.meta[:name]] = tf
            end
        end
    catch e
        @warn "Failed to load TestFunction for $name: $e"
    end
end

for tf in values(TEST_FUNCTIONS)
    export_name = Symbol(lowercase(tf.meta[:name]))
    export_gradient = Symbol(lowercase(tf.meta[:name]) * "_gradient")
    export_constant = Symbol(uppercase(tf.meta[:name]) * "_FUNCTION")
    isdefined(@__MODULE__, export_name) && @eval export $export_name
    isdefined(@__MODULE__, export_gradient) && @eval export $export_gradient
    isdefined(@__MODULE__, export_constant) && @eval export $export_constant
end

export TEST_FUNCTIONS, filter_testfunctions, TestFunction, use_testfunction, has_property, add_property

end # module