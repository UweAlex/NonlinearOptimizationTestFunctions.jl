# src/NonlinearOptimizationTestFunctions.jl
# Purpose: Defines the core module for nonlinear optimization test functions.
# Context: Provides TestFunction structure, metadata validation, function registry, and utility functions.
# Last modified: 17 September 2025

module NonlinearOptimizationTestFunctions

using LinearAlgebra  # Used for matrix operations in test functions
using ForwardDiff   # Used for automatic differentiation compatibility

# Define valid properties for test functions
# Purpose: Specifies the allowed properties that can be assigned to test functions in meta[:properties].
# Context: Ensures metadata consistency and validation during TestFunction construction.
const VALID_PROPERTIES = Set([
    "unimodal", "multimodal", "highly multimodal", "deceptive",
    "convex", "non-convex", "quasi-convex", "strongly convex",
    "separable", "non-separable", "partially separable", "fully non-separable",
    "differentiable", "partially differentiable", "scalable", "continuous", "bounded", "has_constraints",
    "controversial", "has_noise", "finite_at_inf"
]) #end const

# Default dimension for scalable functions
# Purpose: Provides a mutable default dimension for scalable functions when no dimension is specified.
# Context: Used by metadata access methods (e.g., start(tf)) for scalable functions.
const DEFAULT_N = Ref(2)  # Use Ref for mutability #end const

# TestFunction struct
# Purpose: Encapsulates a test function, its gradient, in-place gradient, metadata, and call counters.
# Context: Core data structure for storing and managing test functions in the package.
struct TestFunction
    f::Function           # The test function f(x) that computes the objective value
    grad::Function        # The gradient function grad(x) that computes the analytical gradient
    gradient!::Function   # The in-place gradient function gradient!(G, x) that modifies G with grad(x)
    meta::Dict{Symbol, Any}  # Metadata dictionary containing :name, :start, :min_position, :min_value, :properties, :lb, :ub
    f_count::Ref{Int}     # Counter for function evaluations, stored as Ref for mutability
    grad_count::Ref{Int}  # Counter for gradient evaluations, stored as Ref for mutability

    # Constructor for TestFunction
    # Purpose: Creates a TestFunction instance with wrapped functions to count calls and validates metadata.
    # Input:
    #   - f: Function, the test function f(x)::Real
    #   - grad: Function, the analytical gradient function grad(x)::Vector
    #   - meta: Dict{Symbol, Any}, metadata with required keys (:name, :start, :min_position, :min_value, :properties, :lb, :ub)
    # Output:
    #   - A new TestFunction instance with wrapped functions and initialized counters
    # Used in: src/include_testfunctions.jl, where individual test functions (e.g., ackley.jl) create TestFunction instances
    function TestFunction(f, grad, meta)
        # Validate required metadata keys
        required_keys = [:name, :start, :min_position, :min_value, :properties, :lb, :ub]
        missing_keys = setdiff(required_keys, keys(meta))
        isempty(missing_keys) || throw(ArgumentError("Missing required meta keys: $missing_keys"))  # Throw error if keys are missing #end if

        # Ensure all properties are valid and lowercase
        meta[:properties] = Set(lowercase.(string.(meta[:properties])))
        all(p in VALID_PROPERTIES for p in meta[:properties]) || throw(ArgumentError("Invalid properties: $(setdiff(meta[:properties], VALID_PROPERTIES))"))  # Throw error for invalid properties #end if

        # Initialize call counters
        f_count = Ref(0)    # Initialize function call counter to 0
        grad_count = Ref(0) # Initialize gradient call counter to 0

        # Wrap f to count function calls
        f_wrapped = x -> begin
            f_count[] += 1  # Increment function call counter
            f(x)            # Call the original function
        end #begin

        # Wrap grad to count gradient calls
        grad_wrapped = x -> begin
            grad_count[] += 1  # Increment gradient call counter
            grad(x)            # Call the original gradient function
        end #begin

        # Wrap gradient! to count in-place gradient calls
        gradient_wrapped! = (G, x) -> begin
            grad_count[] += 1      # Increment gradient call counter
            copyto!(G, grad(x))    # Copy gradient to G
        end #begin

        # Create and return new TestFunction instance
        new(f_wrapped, grad_wrapped, gradient_wrapped!, meta, f_count, grad_count)
    end #function
end #struct

# Helper function: access_metadata
# Purpose: Internal function to access metadata with automatic or specified dimension handling for scalable functions.
# Input:
#   - tf: TestFunction, the test function instance
#   - key: Symbol, the metadata key (e.g., :start, :min_position)
#   - n: Union{Int, Nothing}, optional dimension for scalable functions (defaults to DEFAULT_N[])
# Output:
#   - Result of the metadata function call or value
# Used in: New methods (start, min_position, etc.) for object-oriented metadata access
function access_metadata(tf::TestFunction, key::Symbol, n::Union{Int, Nothing}=nothing)
    is_scalable = "scalable" in tf.meta[:properties]  # Direct check, independent of has_property
    meta_func = get(tf.meta, key, nothing)
    isnothing(meta_func) && throw(ArgumentError("Metadata key :$key not found for $(tf.meta[:name])")) #end if
    if is_scalable
        if isa(meta_func, Function)
            dim = isnothing(n) ? DEFAULT_N[] : n  # Use provided n or DEFAULT_N
            dim < 1 && throw(ArgumentError("Dimension must be at least 1 for $(tf.meta[:name])")) #end if
            try
                return meta_func(dim)  # Call with specified or default dimension
            catch e
                throw(ArgumentError("Metadata key :$key for $(tf.meta[:name]) failed with n=$dim: $e"))
            end #try
        else
            throw(ArgumentError("Metadata key :$key for $(tf.meta[:name]) must be a function for scalable functions"))
        end #if
    else
        if !isnothing(n)
            @warn "Dimension n=$n ignored for non-scalable function $(tf.meta[:name])"  # Warn if n is provided
        end #if
        if isa(meta_func, Function)
            try
                return meta_func()  # Call without arguments for non-scalable functions
            catch e
                throw(ArgumentError("Metadata key :$key for $(tf.meta[:name]) failed: $e"))
            end #try
        else
            return meta_func  # Return directly if it's a fixed value
        end #if
    end #if
end #function

# New methods for object-oriented metadata access
# Purpose: Provide intuitive, encapsulated access to metadata, supporting optional dimension for scalable functions.
start(tf::TestFunction, n::Union{Int, Nothing}=nothing) = access_metadata(tf, :start, n)
min_position(tf::TestFunction, n::Union{Int, Nothing}=nothing) = access_metadata(tf, :min_position, n)
min_value(tf::TestFunction, n::Union{Int, Nothing}=nothing) = access_metadata(tf, :min_value, n)
lb(tf::TestFunction, n::Union{Int, Nothing}=nothing) = access_metadata(tf, :lb, n)
ub(tf::TestFunction, n::Union{Int, Nothing}=nothing) = access_metadata(tf, :ub, n)
name(tf::TestFunction) = tf.meta[:name]  # Direct access for non-function metadata

# New method for accessing properties
# Purpose: Provides object-oriented access to properties, independent of has_property.
# Input:
#   - tf: TestFunction, the test function instance
#   - prop: String, the property to check (e.g., "bounded")
# Output:
#   - Boolean, true if the property is in tf.meta[:properties], false otherwise
function property(tf::TestFunction, prop::AbstractString)
    prop = lowercase(string(prop))
    prop in VALID_PROPERTIES || throw(ArgumentError("Invalid property: $prop")) #end if
    return prop in tf.meta[:properties]
end #function

# Specific property methods for common properties
# Purpose: Provides intuitive, object-oriented access to common properties.
bounded(tf::TestFunction) = property(tf, "bounded")
scalable(tf::TestFunction) = property(tf, "scalable")
differentiable(tf::TestFunction) = property(tf, "differentiable")
multimodal(tf::TestFunction) = property(tf, "multimodal")
separable(tf::TestFunction) = property(tf, "separable")
finite_at_inf(tf::TestFunction) = property(tf, "finite_at_inf")

# Helper function: set_default_n!
# Purpose: Sets the default dimension for scalable functions.
# Input:
#   - n: Int, the new default dimension
# Output:
#   - Nothing, modifies DEFAULT_N in place
# Used in: User code to change the default dimension for scalable functions
function set_default_n!(n::Int)
    n < 1 && throw(ArgumentError("Default dimension must be at least 1")) #end if
    DEFAULT_N[] = n
    return nothing
end #function

# Helper function: get_f_count
# Purpose: Retrieves the number of function evaluations for a TestFunction.
# Input:
#   - tf: TestFunction, the test function instance
# Output:
#   - Integer, the number of times tf.f was called
# Used in: User code or tests (e.g., examples/count_calls.jl) to monitor function evaluations
function get_f_count(tf::TestFunction)
    return tf.f_count[]  # Return the current function call count
end #function

# Helper function: get_grad_count
# Purpose: Retrieves the number of gradient evaluations for a TestFunction.
# Input:
#   - tf: TestFunction, the test function instance
# Output:
#   - Integer, the number of times tf.grad or tf.gradient! was called
# Used in: User code or tests (e.g., examples/count_calls.jl) to monitor gradient evaluations
function get_grad_count(tf::TestFunction)
    return tf.grad_count[]  # Return the current gradient call count
end #function

# Helper function: reset_counts!
# Purpose: Resets the function and gradient call counters to zero.
# Input:
#   - tf: TestFunction, the test function instance
# Output:
#   - Nothing, modifies tf.f_count and tf.grad_count in place
# Used in: User code or tests (e.g., examples/count_calls.jl) to reset counters before new evaluations
function reset_counts!(tf::TestFunction)
    tf.f_count[] = 0    # Reset function call counter
    tf.grad_count[] = 0 # Reset gradient call counter
    return nothing
end #function

# Helper function: get_n
# Purpose: Determines the dimension of a TestFunction (fixed or scalable).
# Input:
#   - tf: TestFunction, the test function instance
# Output:
#   - Integer, the dimension (length of min_position for non-scalable functions, -1 for scalable)
# Used in: examples/get_himmelblau_dimension.jl, examples/list_functions_n_greater_than_2.jl, test/runtests.jl
function get_n(tf::TestFunction)
    is_scalable = "scalable" in tf.meta[:properties]  # Direct check, independent of has_property
    if is_scalable
        return -1  # Scalable functions have no fixed dimension
    else
        try
            return length(tf.meta[:min_position]())  # Return length of min_position for non-scalable functions
        catch e
            throw(ArgumentError("Invalid min_position for $(tf.meta[:name]): $e"))
        end #try
    end #if
end #function

# Helper function: has_property (DEPRECATED)
# Purpose: Checks if a TestFunction has a specific property (DEPRECATED in favor of property(tf, prop)).
# Input:
#   - tf: TestFunction, the test function instance
#   - prop: String, the property to check (e.g., "scalable", "multimodal")
# Output:
#   - Boolean, true if the property is in tf.meta[:properties], false otherwise
# Used in: test/runtests.jl (Filter and Properties Tests), examples/list_functions_n_greater_than_2.jl
@deprecate has_property(tf::TestFunction, prop::String) property(tf, prop)
function has_property(tf::TestFunction, prop::String)
    lprop = lowercase(prop)  # Convert property to lowercase
    lprop in VALID_PROPERTIES || throw(ArgumentError("Invalid property: $lprop")) #end if
    return lprop in tf.meta[:properties]  # Check if property exists
end #function

# Helper function: add_property
# Purpose: Creates a new TestFunction with an additional property in its metadata.
# Input:
#   - tf: TestFunction, the test function instance
#   - prop: String, the property to add (e.g., "bounded")
# Output:
#   - TestFunction, a new instance with the updated property set
# Used in: Potentially in user code to modify function properties, not used in provided examples
function add_property(tf::TestFunction, prop::String)
    lprop = lowercase(prop)  # Convert property to lowercase
    lprop in VALID_PROPERTIES || throw(ArgumentError("Invalid property: $lprop")) #end if
    new_meta = copy(tf.meta)  # Copy metadata
    new_meta[:properties] = union(tf.meta[:properties], [lprop])  # Add new property
    return TestFunction(tf.f, tf.grad, new_meta)  # Create new TestFunction
end #function

# Main function: use_testfunction
# Purpose: Evaluates a test function and its gradient at a given point.
# Input:
#   - tf: TestFunction, the test function instance
#   - x: Vector{T} where T<:Union{Real, ForwardDiff.Dual}, the input point
#   - n: Union{Int, Nothing}, optional dimension for scalable functions (defaults to DEFAULT_N[])
# Output:
#   - Named tuple (f, grad), where f is the function value and grad is the gradient
# Used in: User code for evaluating functions, not directly used in provided examples
function use_testfunction(tf::TestFunction, x::Vector{T}, n::Union{Int, Nothing}=nothing) where {T<:Union{Real, ForwardDiff.Dual}}
    isempty(x) && throw(ArgumentError("Input vector x must not be empty")) #end if
    is_scalable = "scalable" in tf.meta[:properties]  # Direct check, independent of has_property
    dim = is_scalable ? (isnothing(n) ? DEFAULT_N[] : n) : get_n(tf)  # Use provided n, DEFAULT_N, or fixed dimension
    dim < 1 && throw(ArgumentError("Dimension must be at least 1 for $(tf.meta[:name])")) #end if
    if !isnothing(n) && !is_scalable
        @warn "Dimension n=$n ignored for non-scalable function $(tf.meta[:name])"  # Warn if n is provided for non-scalable
    end #if
    length(x) == dim || throw(ArgumentError("Input vector must have dimension $dim for $(tf.meta[:name])")) #end if
    return (f=tf.f(x), grad=tf.grad(x))  # Return function value and gradient
end #function

# Helper function: filter_testfunctions
# Purpose: Filters test functions based on a predicate function.
# Input:
#   - predicate: Function, a function that takes a TestFunction and returns a Boolean
#   - test_functions: Dict{String, TestFunction}, the collection to filter (defaults to TEST_FUNCTIONS)
# Output:
#   - Vector{TestFunction}, the filtered list of test functions
# Used in: test/runtests.jl (Filter and Properties Tests)
function filter_testfunctions(predicate::Function, test_functions=TEST_FUNCTIONS)
    return [tf for tf in values(test_functions) if predicate(tf)]  # Filter functions by predicate
end #function

# Global dictionary to store all test functions
# Purpose: Maps function names to their TestFunction instances.
# Context: Populated by including function definitions and registering TestFunction instances.
const TEST_FUNCTIONS = Dict{String, TestFunction}() #end const

# Include all test function definitions
# Purpose: Loads all test function implementations from src/functions/*.jl.
# Context: Populates TEST_FUNCTIONS with test functions like ackley.jl, rosenbrock.jl, etc.
include("include_testfunctions.jl")  # Include all function definitions

# Register all TestFunction instances
# Purpose: Iterates over module symbols to find and register TestFunction instances ending with _FUNCTION.
# Context: Ensures all test functions are added to TEST_FUNCTIONS dictionary.
for name in names(@__MODULE__, all=true)
    try
        if endswith(string(name), "_FUNCTION")  # Check for symbols ending with _FUNCTION
            tf = getfield(@__MODULE__, name)    # Get the TestFunction instance
            if tf isa TestFunction              # Verify it’s a TestFunction
                TEST_FUNCTIONS[tf.meta[:name]] = tf  # Register in TEST_FUNCTIONS
            end #if
        end #if
    catch e
        @warn "Failed to load TestFunction for $name: $e"  # Warn on failure
    end #try
end #for

# Export function and gradient symbols
# Purpose: Exports function names, gradient names, and TestFunction constants for external use.
# Context: Ensures functions like ackley, ackley_gradient, and ACKLEY_FUNCTION are accessible.
for tf in values(TEST_FUNCTIONS)
    export_name = Symbol(lowercase(tf.meta[:name]))              # e.g., :ackley
    export_gradient = Symbol(lowercase(tf.meta[:name]) * "_gradient")  # e.g., :ackley_gradient
    export_constant = Symbol(uppercase(tf.meta[:name]) * "_FUNCTION")  # e.g., :ACKLEY_FUNCTION
    if isdefined(@__MODULE__, export_name)
        @eval export $export_name  # Export function name
    end #if
    if isdefined(@__MODULE__, export_gradient)
        @eval export $export_gradient  # Export gradient name
    end #if
    if isdefined(@__MODULE__, export_constant)
        @eval export $export_constant  # Export constant
    end #if
end #for

# Export public interface
# Purpose: Exports module-level functions and constants for external use.
export TEST_FUNCTIONS, filter_testfunctions, TestFunction, use_testfunction, has_property, add_property, get_n, get_f_count, get_grad_count, reset_counts!, set_default_n!, start, min_position, min_value, lb, ub, name, property, bounded, scalable, differentiable, multimodal, separable, finite_at_inf

end #module