# NonlinearOptimizationTestFunctions
# Last modified: 17 September 2025, 12:07 PM CEST

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Usage](#usage)
  - [Examples](#examples)
    - [Getting Himmelblau Dimension](#getting-himmelblau-dimension)
    - [Listing Test Functions with Dimension n > 2](#listing-test-functions-with-dimension-n--2)
    - [Evaluating the Eggholder Function](#evaluating-the-eggholder-function)
    - [Comparing Optimization Methods](#comparing-optimization-methods)
    - [Computing Hessian with Zygote](#computing-hessian-with-zygote)
    - [Listing Test Functions and Properties](#listing-test-functions-and-properties)
    - [Optimizing All Functions](#optimizing-all-functions)
    - [Optimizing with NLopt](#optimizing-with-nlopt)
    - [Filtering Test Functions by Properties](#filtering-test-functions-by-properties)
    - [Tracking Function and Gradient Calls](#tracking-function-and-gradient-calls)
  - [New Object-Oriented Interface for Metadata and Properties](#new-object-oriented-interface-for-metadata-and-properties)
    - [Setting the Default Dimension](#setting-the-default-dimension)
    - [Accessing Metadata](#accessing-metadata)
    - [Accessing Properties](#accessing-properties)
    - [Example Usage](#example-usage)
    - [Notes](#notes)
- [Tests of the Test Functions](#tests-of-the-test-functions)
- [Test Functions](#test-functions)
- [Upcoming Test Functions](#upcoming-test-functions)
- [Roadmap](ROADMAP.md)
- [Properties of Test Functions](#properties-of-test-functions)
- [Valid Properties](#valid-properties)
  - [Modality](#modality)
  - [Convexity](#convexity)
  - [Separability](#separability)
  - [Differentiability](#differentiability)
  - [Other Properties](#other-properties)
- [Running Tests](#running-tests)
- [License](#license)
- [Alternative Names for Test Functions](#alternative-names-for-test-functions)
- [References](#references)
## Introduction

NonlinearOptimizationTestFunctions is a Julia package designed for testing and benchmarking nonlinear optimization algorithms. It provides a comprehensive collection of standard test functions, each equipped with analytical gradients, metadata, and validation mechanisms. The package supports scalable and non-scalable functions, ensuring compatibility with high-dimensional optimization problems and automatic differentiation tools like ForwardDiff. Key features include:

- Standardized Test Functions: A curated set of well-known optimization test functions (e.g., Rosenbrock, Ackley, Branin) with consistent interfaces.
- Analytical Gradients: Each function includes an analytical gradient for efficient optimization and testing.
- TestFunction Structure: Encapsulates function, gradient, and metadata (e.g., name, start point, global minimum, properties, bounds).
- Validation and Flexibility: Metadata validation ensures correctness, and properties like unimodal, multimodal, or differentiable enable filtering for specific use cases.
- Integration with Optimization Libraries: Seamless compatibility with Optim.jl, NLopt.jl, and other Julia optimization packages.

The package is ideal for researchers, developers, and students evaluating optimization algorithms, offering a robust framework for nonlinear optimization benchmarking.

## Installation

To install the package, use the Julia Package Manager:

    using Pkg
    Pkg.add("NonlinearOptimizationTestFunctions")

Ensure dependencies like LinearAlgebra, ForwardDiff, and Optim are installed automatically. For specific examples, additional packages (e.g., NLopt, Zygote) may be required.

## Usage

The package provides a TestFunction structure containing the function (f), gradient (grad), in-place gradient (gradient!), and metadata (meta). Functions are stored in TEST_FUNCTIONS, a dictionary mapping function names to TestFunction instances. Below are examples demonstrating the package's capabilities, corresponding to files in the examples directory.

### Examples

#### Getting Himmelblau Dimension
Prints the dimension of the Himmelblau test function using tf.dim(), demonstrating how to access a specific function's dimension from TEST_FUNCTIONS.

		using NonlinearOptimizationTestFunctions

		# Print dimension of Himmelblau function

		# Access Himmelblau function from TEST_FUNCTIONS (a Dict{String, TestFunction})
		tf = TEST_FUNCTIONS["himmelblau"]
		
		# Get dimension using tf.dim():
			# 1. Checks if 'scalable' is in tf.meta[:properties] via has_property
			# 2. Returns -1 for scalable functions
		dim = tf.dim()
		
		println("Dimension of Himmelblau function: $dim")


#### Listing Test Functions with Dimension n > 2
Lists all non-scalable test functions with dimension n > 2 using get_n, showing how to iterate over TEST_FUNCTIONS and filter by dimension.

    using NonlinearOptimizationTestFunctions

    # List non-scalable functions with n > 2
    function list_functions_n_greater_than_2()
        println("Non-scalable test functions with dimension n > 2:")
        
        # Iterate over TEST_FUNCTIONS (a Dict{String, TestFunction})
        for tf in values(TEST_FUNCTIONS)
            # Determine dimension using get_n:
            # 1. Checks if 'scalable' is in tf.meta[:properties]
            # 2. Returns -1 for scalable functions
            # 3. For non-scalable, returns length(tf.meta[:min_position]())
            # 4. Throws ArgumentError if :min_position fails
            dim = get_n(tf)
            
            # Filter non-scalable functions with n > 2
            if dim > 2
                meta = tf.meta
                println("Function: $(meta[:name]), Dimension: $dim, Properties: $(meta[:properties]), Minimum: $(meta[:min_value]) at $(meta[:min_position]()), Bounds: [$(meta[:lb]()), $(meta[:ub]())]")
            end #if
        end #for
    end #function

    # Run the function
    list_functions_n_greater_than_2()

#### Evaluating the Eggholder Function
Evaluates the Eggholder function and its analytical gradient at the origin, demonstrating basic usage of a test function and its gradient.

    using NonlinearOptimizationTestFunctions
    println(eggholder([0,0]))
    println(eggholder_gradient([0,0]))

#### Comparing Optimization Methods
Compares Gradient Descent and L-BFGS on the Rosenbrock function, demonstrating how to use TestFunction with Optim.jl to evaluate different algorithms.

		# examples/Compare_optimization_methods.jl
		# Purpose: Compares Gradient Descent and L-BFGS optimization methods on the Rosenbrock function.
		# Context: Part of NonlinearOptimizationTestFunctions, demonstrating the flexibility of the TestFunction interface.
		# Last modified: 18 September 2025, 10:55 AM CEST

		using NonlinearOptimizationTestFunctions, Optim

		# Load the Rosenbrock function
		tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION

		# Set the number of dimensions (default for Rosenbrock is n=2)
		n = 2

		# Perform optimization using Gradient Descent
		result_gd = optimize(
			tf.f,              # Objective function
			tf.gradient!,      # Gradient function
			tf.start(n),       # Starting point 
			GradientDescent(), # Optimization algorithm
			Optim.Options(f_reltol=1e-6) # Convergence tolerance
		)

		# Perform optimization using L-BFGS
		result_lbfgs = optimize(
			tf.f,              # Objective function
			tf.gradient!,      # Gradient function
			tf.start(n),       # Starting point 
			LBFGS(),           # Optimization algorithm
			Optim.Options(f_reltol=1e-6) # Convergence tolerance
		)

# Print results
println("Gradient Descent on $(tf.name): minimizer = $(Optim.minimizer(result_gd)), minimum = $(Optim.minimum(result_gd))")
println("L-BFGS on $(tf.name): minimizer = $(Optim.minimizer(result_lbfgs)), minimum = $(Optim.minimum(result_lbfgs))")

#### Computing Hessian with Zygote
Performs three Newton steps on the Rosenbrock function using analytical gradients and Zygote's Hessian computation, showcasing integration with automatic differentiation.

    using NonlinearOptimizationTestFunctions, Zygote, LinearAlgebra
    tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
    n = 2
    x = start(tf, n)
    x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
    x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
    x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
    println("Nach 3 Newton-Schritten für $(name(tf)): $x")

#### Listing Test Functions and Properties
Displays all available test functions with their start points, minima, and properties, useful for inspecting function characteristics.

    using NonlinearOptimizationTestFunctions
    n = 2
    for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
        println("$(name(tf)): Start at $(start(tf, n)), Minimum at $(min_position(tf, n)), Value $(min_value(tf, n)), Properties: $(join(tf.meta[:properties], ", "))")
    end #for

#### Optimizing All Functions
Optimizes all test functions using Optim.jl, with bounds for bounded functions; constrained functions planned for Q1 2026 (see ROADMAP.md).

	using NonlinearOptimizationTestFunctions, Optim

	# Main loop: Iterates over all test functions in the suite, retrieves their dimension and metadata (start point, bounds),
	# and optimizes them using NelderMead (unbounded) or Fminbox(NelderMead) (bounded). Outputs the minimizer and minimum value.
	for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
		# Get dimension from metadata or use default_n for scalable functions
		local dim = get_n(tf)
		local n = dim == -1 ? tf.meta[:default_n] : dim

		# Validate default_n for scalable functions
		if dim == -1 && !haskey(tf.meta, :default_n)
			error("No :default_n defined for scalable function $(tf.meta[:name])")
		end

		# Get start point (use n for scalable functions only)
		local start_point = dim == -1 ? tf.meta[:start](n) : tf.meta[:start]()
		local lb = haskey(tf.meta, :lb) ? (dim == -1 ? tf.meta[:lb](n) : tf.meta[:lb]()) : nothing
		local ub = haskey(tf.meta, :ub) ? (dim == -1 ? tf.meta[:ub](n) : tf.meta[:ub]()) : nothing

		# Validate inputs
		if length(start_point) != n
			error("Start point dimension ($(length(start_point))) does not match function dimension ($n) for $(tf.meta[:name])")
		end

		# Perform optimization
		if has_property(tf, "bounded") && lb !== nothing && ub !== nothing
			# Bounded optimization using Fminbox(NelderMead)
			local clamped_start_point = clamp.(start_point, lb, ub)
			local result = optimize(tf.f, lb, ub, clamped_start_point, Fminbox(NelderMead()), Optim.Options(f_reltol=1e-6))
		else
			# Unbounded optimization
			local result = optimize(tf.f, start_point, NelderMead(), Optim.Options(f_reltol=1e-6))
		end

		# Print results
		println("$(tf.meta[:name]): minimizer = $(Optim.minimizer(result)), minimum = $(Optim.minimum(result))")
		println("--------------------------------------------------")
	end

#### Optimizing with NLopt
Optimizes the Rosenbrock function using NLopt.jl's LD_LBFGS algorithm, highlighting compatibility with external optimization libraries.

    using NonlinearOptimizationTestFunctions
    if isdefined(Main, :NLopt)
        using NLopt
        tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
        n = 2
        opt = Opt(:LD_LBFGS, n)
        NLopt.ftol_rel!(opt, 1e-6)
        NLopt.lower_bounds!(opt, lb(tf, n))
        NLopt.upper_bounds!(opt, ub(tf, n))
        NLopt.min_objective!(opt, (x, grad) -> begin
            f = tf.f(x)
            if length(grad) > 0
                tf.gradient!(grad, x)
            end #if
            f
        end) #begin
        minf, minx, ret = optimize(opt, start(tf, n))
        println("$(name(tf)): $minx, $minf")
    else
        println("NLopt.jl is not installed. Please install it to run this example.")
    end #if

#### Filtering Test Functions by Properties
Filters test functions based on specific properties (e.g., multimodal or finite_at_inf), demonstrating how to select functions for targeted benchmarking.

    using NonlinearOptimizationTestFunctions
    multimodal_funcs = filter_testfunctions(tf -> property(tf, "multimodal"))
    println("Multimodal functions: ", [name(tf) for tf in multimodal_funcs])
    finite_at_inf_funcs = filter_testfunctions(tf -> property(tf, "finite_at_inf"))
    println("Functions with finite_at_inf: ", [name(tf) for tf in finite_at_inf_funcs])

#### Tracking Function and Gradient Calls
Tracks the number of function and gradient evaluations for the Rosenbrock function during evaluation and optimization, demonstrating the use of call counters and selective gradient counter resetting.

    using NonlinearOptimizationTestFunctions, Optim

    # Track function and gradient calls for Rosenbrock
    function run_count_calls_example()
        # Select the Rosenbrock test function
        tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
        n = 2  # Dimension for scalable function

        # Reset both counters before starting
        reset_counts!(tf)  # Reset function and gradient call counters to 0
        println("After full reset - Function calls: ", get_f_count(tf))  # Should print 0
        println("After full reset - Gradient calls: ", get_grad_count(tf))  # Should print 0

        # Evaluate function at start point
        x = start(tf, n)  # Get start point [1.0, 1.0]
        f_value = tf.f(x)  # Compute function value
        println("Function value at start point $x: ", f_value)  # Should print 24.0
        println("Function calls after evaluation: ", get_f_count(tf))  # Should print 1
        println("Gradient calls after evaluation: ", get_grad_count(tf))  # Should print 0

        # Evaluate gradient at start point
        grad_value = tf.grad(x)  # Compute gradient
        println("Gradient at start point $x: ", grad_value)  # Should print [400.0, -200.0]
        println("Function calls after gradient evaluation: ", get_f_count(tf))  # Should print 1
        println("Gradient calls after gradient evaluation: ", get_grad_count(tf))  # Should print 1

        # Reset only the gradient counter
        reset_grad_count!(tf)  # Reset only gradient call counter to 0
        println("After gradient reset - Function calls: ", get_f_count(tf))  # Should print 1
        println("After gradient reset - Gradient calls: ", get_grad_count(tf))  # Should print 0

        # Perform optimization with L-BFGS
        result = optimize(tf.f, tf.gradient!, x, LBFGS(), Optim.Options(f_reltol=1e-6))
        println("Optimization result - Minimizer: ", Optim.minimizer(result))
        println("Optimization result - Minimum: ", Optim.minimum(result))
        println("Function calls after optimization: ", get_f_count(tf))  # Prints total function calls
        println("Gradient calls after optimization: ", get_grad_count(tf))  # Prints total gradient calls

        # Reset both counters again
        reset_counts!(tf)  # Reset both counters to 0
        println("After second full reset - Function calls: ", get_f_count(tf))  # Should print 0
        println("After second full reset - Gradient calls: ", get_grad_count(tf))  # Should print 0
    end #function

    # Run the function
    run_count_calls_example()

### New Object-Oriented Interface for Metadata and Properties

The package provides a modern, object-oriented interface to access metadata and properties of test functions, offering a clean and intuitive way to interact with `TestFunction` instances. These methods support both scalable and non-scalable functions, with scalable functions allowing an optional dimension parameter (`n`) to specify the problem size. If no dimension is provided for scalable functions, the default dimension (`DEFAULT_N`, initially set to 2) is used. Below is a comprehensive list of the new methods, their purpose, and usage examples.

#### Setting the Default Dimension
The `set_default_n!` function sets the global default dimension (`DEFAULT_N`) for scalable functions when no explicit dimension is provided.

    set_default_n!(n::Int)

- Purpose: Modifies the global default dimension for scalable functions.
- Input: `n` - An integer (must be ≥ 1) specifying the new default dimension.
- Output: None (modifies `DEFAULT_N` in place).
- Example:
    using NonlinearOptimizationTestFunctions
    set_default_n!(4)  # Set default dimension to 4
    tf = ACKLEY_FUNCTION
    x = start(tf)  # Returns start point for n=4
    println("Start point with default n=4: ", x)

#### Accessing Metadata
The following methods provide access to a test function's metadata, such as start points, global minima, bounds, and name. For scalable functions, an optional `n` parameter specifies the dimension; otherwise, `DEFAULT_N` is used. For non-scalable functions, any provided `n` is ignored with a warning.

- `start(tf::TestFunction, n::Union{Int, Nothing}=nothing)`
  - Purpose: Returns the recommended start point for optimization.
  - Output: A vector representing the start point.
  - Example:
      tf = ACKLEY_FUNCTION
      x = start(tf)      # Start point for default n=2
      x_n = start(tf, 4) # Start point for n=4
      println("Start point (n=2): ", x)
      println("Start point (n=4): ", x_n)

- `min_position(tf::TestFunction, n::Union{Int, Nothing}=nothing)`
  - Purpose: Returns the position of the global minimum.
  - Output: A vector representing the coordinates of the global minimum.
  - Example:
      tf = ROSENBROCK_FUNCTION
      min_pos = min_position(tf)  # Minimum at [1, 1] for n=2
      println("Global minimum position: ", min_pos)

- `min_value(tf::TestFunction, n::Union{Int, Nothing}=nothing)`
  - Purpose: Returns the value of the function at its global minimum.
  - Output: A scalar representing the minimum value.
  - Example:
      tf = ROSENBROCK_FUNCTION
      min_val = min_value(tf)  # Minimum value is 0
      println("Global minimum value: ", min_val)

- `lb(tf::TestFunction, n::Union{Int, Nothing}=nothing)`
  - Purpose: Returns the lower bounds for the function's domain.
  - Output: A vector representing the lower bounds.
  - Example:
      tf = ACKLEY_FUNCTION
      bounds = lb(tf)  # Lower bounds [-5, -5] for n=2
      println("Lower bounds: ", bounds)

- `ub(tf::TestFunction, n::Union{Int, Nothing}=nothing)`
  - Purpose: Returns the upper bounds for the function's domain.
  - Output: A vector representing the upper bounds.
  - Example:
      tf = ACKLEY_FUNCTION
      bounds = ub(tf)  # Upper bounds [5, 5] for n=2
      println("Upper bounds: ", bounds)

- `name(tf::TestFunction)`
  - Purpose: Returns the name of the test function.
  - Output: A string representing the function's name.
  - Example:
      tf = BRANIN_FUNCTION
      func_name = name(tf)  # Returns "branin"
      println("Function name: ", func_name)

#### Accessing Properties
The following methods allow checking the mathematical properties of test functions (e.g., bounded, scalable, multimodal), enabling filtering and analysis based on function characteristics.

- `property(tf::TestFunction, prop::AbstractString)`
  - Purpose: Checks if the test function has a specific property (e.g., "bounded", "scalable").
  - Input: `prop` - A string specifying the property (must be in `VALID_PROPERTIES`).
  - Output: A boolean indicating whether the property is present.
  - Example:
      tf = ACKLEY_FUNCTION
      is_bounded = property(tf, "bounded")  # Returns true
      is_convex = property(tf, "convex")    # Returns false
      println("Is bounded: ", is_bounded)
      println("Is convex: ", is_convex)

- `bounded(tf::TestFunction)`
  - Purpose: Checks if the function is defined within finite bounds.
  - Output: A boolean (true if the function has the "bounded" property).
  - Example:
      tf = BRANIN_FUNCTION
      is_bounded = bounded(tf)  # Returns true
      println("Is bounded: ", is_bounded)

- `scalable(tf::TestFunction)`
  - Purpose: Checks if the function supports arbitrary dimensions (n ≥ 1).
  - Output: A boolean (true if the function has the "scalable" property).
  - Example:
      tf = SPHERE_FUNCTION
      is_scalable = scalable(tf)  # Returns true
      println("Is scalable: ", is_scalable)

- `differentiable(tf::TestFunction)`
  - Purpose: Checks if the function is differentiable across its domain.
  - Output: A boolean (true if the function has the "differentiable" property).
  - Example:
      tf = ROSENBROCK_FUNCTION
      is_diff = differentiable(tf)  # Returns true
      println("Is differentiable: ", is_diff)

- `multimodal(tf::TestFunction)`
  - Purpose: Checks if the function has multiple local minima.
  - Output: A boolean (true if the function has the "multimodal" property).
  - Example:
      tf = ACKLEY_FUNCTION
      is_multi = multimodal(tf)  # Returns true
      println("Is multimodal: ", is_multi)

- `separable(tf::TestFunction)`
  - Purpose: Checks if the function can be optimized independently along each dimension.
  - Output: A boolean (true if the function has the "separable" property).
  - Example:
      tf = SPHERE_FUNCTION
      is_sep = separable(tf)  # Returns true
      println("Is separable: ", is_sep)

- `finite_at_inf(tf::TestFunction)`
  - Purpose: Checks if the function returns finite values when evaluated at infinity.
  - Output: A boolean (true if the function has the "finite_at_inf" property).
  - Example:
      tf = DEJONGF5ORIGINAL_FUNCTION
      is_finite = finite_at_inf(tf)  # Returns true
      println("Finite at infinity: ", is_finite)

#### Example Usage
The following example demonstrates the use of the new interface for a scalable (Ackley) and non-scalable (Branin) function:

    using NonlinearOptimizationTestFunctions

    # Scalable function (Ackley)
    tf = ACKLEY_FUNCTION
    println("Function: ", name(tf))
    println("Start point (default n=2): ", start(tf))
    println("Start point (n=4): ", start(tf, 4))
    println("Lower bounds (n=2): ", lb(tf))
    println("Is bounded: ", bounded(tf))
    println("Is scalable: ", scalable(tf))
    println("Is multimodal: ", multimodal(tf))
    set_default_n!(4)
    println("Start point (new default n=4): ", start(tf))

    # Non-scalable function (Branin)
    tf = BRANIN_FUNCTION
    println("Function: ", name(tf))
    println("Start point: ", start(tf))
    println("Global minimum position: ", min_position(tf))
    println("Global minimum value: ", min_value(tf))
    println("Is bounded: ", bounded(tf))
    println("Is scalable: ", scalable(tf))
    println("Start point (n=4, ignored): ", start(tf, 4))  # Warns that n is ignored

#### Notes
- For scalable functions, methods like `start(tf, n)`, `lb(tf, n)`, etc., allow specifying the dimension explicitly, overriding `DEFAULT_N`.
- For non-scalable functions, any provided `n` is ignored, and a warning is issued to inform the user.
- The `property` method accepts any valid property from `VALID_PROPERTIES` (see [Valid Properties](#valid-properties)), enabling flexible querying of function characteristics.
- These methods encapsulate metadata access, ensuring a consistent and robust interface for optimization tasks.

### Tests of the Test Functions

The test suite of the `NonlinearOptimizationTestFunctions` package ensures that all test functions are correctly implemented and that their metadata and mathematical properties meet expectations. The tests are organized in `runtests.jl` and include:

1. Filter and Property Tests: Verification of metadata such as `bounded`, `continuous`, `multimodal`, `convex`, `differentiable`, `has_noise`, `partially differentiable`, and `finite_at_inf` for consistency and correctness.
2. Edge Case Tests: Validation of behavior for invalid inputs (empty vectors, `NaN`, `Inf`), extreme values (e.g., `1e-308`), and bounds for bounded functions.
3. Gradient Accuracy Tests: Comparison of analytical gradients with automatic (ForwardDiff) and numerical gradients at 40 random points, the start point, and (for bounded functions) points near the lower and upper bounds, with special handling for non-differentiable functions.
4. Minimum Tests: Validation of global minima through optimization with `Optim.jl` (Nelder-Mead for non-differentiable functions or boundary minima, gradient-based methods for interior minima) and checking gradient norms at minima.
5. Zygote Hessian Tests: Verification of compatibility with Zygote for computing Hessian matrices for selected functions (e.g., Rosenbrock, Sphere).
6. Function-Specific Tests: Individual test files (e.g., `brown_tests.jl`, `dejongf5modified_tests.jl`) verify function values, metadata, edge cases, and optimization results for each test function.

The tests utilize `Optim.jl` for optimizations, `ForwardDiff` and `Zygote` for automatic differentiation, and handle special cases such as non-differentiable functions or numerical instabilities. Debugging outputs (e.g., using `@show`) assist in verifying optimization results, while some warnings indicate potential metadata errors.

Average Number of Tests per Function: On average, each test function undergoes approximately 50–60 tests. This includes 5–10 tests for metadata and edge cases in function-specific test files (e.g., 23 tests in `brown_tests.jl`, 24 in `dejongf5modified_tests.jl`), 42–43 gradient accuracy tests per function (40 random points, 1 start point, and 1–2 bound points for bounded functions in `gradient_accuracy_tests.jl`), and 2–5 optimization and minimum validation tests in `minima_tests.jl`.

## Test Functions

The package includes a variety of test functions for nonlinear optimization, each defined in `src/functions/<functionname>.jl`. Below is a complete list of available functions, their properties, minima, bounds, and supported dimensions, based on precise values from sources like al-roomi.org, sfu.ca, and Molga & Smutnicki (2005). All functions are fully implemented with function evaluations, analytical gradients, and metadata, validated through the test suite, including checks for empty input vectors, NaN, Inf, and small inputs (e.g., 1e-308). Functions throw appropriate errors (e.g., `ArgumentError` for empty input or incorrect dimensions) to ensure robustness.

## Test Functions

- **ackley** [Molga & Smutnicki (2005): 2.9]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable, scalable. Global minimum: 0 at (0, 0, ..., 0). Bounds: [(-5, -5), (5, 5)]. Dimensions: Any \( n \geq 1 \).
- **ackley2** [Jamil & Yang (2013): f2]: Bounded, continuous, differentiable, unimodal, non-convex, non-separable. Global minimum: -200 at (0, 0). Bounds: [(-32, -32), (32, 32)]. Dimensions: \( n = 2 \).
- **ackley4** [Jamil & Yang (2013): f4]: Multimodal, non-convex, non-separable, differentiable. Minimum: -3.917275 at {-1.479, -0.740} and {1.479, -0.740}. Bounds: [-35, 35]^n. Dimensions: n=2.
- **adjiman** [Jamil & Yang (2013): f5]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: -2.02180678 at (2, 0.10578347). Bounds: [(-1, -1), (2, 1)]. Dimensions: \( n = 2 \).
- **alpinen1** [Jamil & Yang (2013): f6]: Bounded, continuous, multimodal, non-convex, separable, partially differentiable, scalable. Global minimum: 0 at (0, 0, ..., 0). Bounds: [(-10, -10), (10, 10)]. Dimensions: Any \( n \geq 1 \).
- **alpinen2** [Jamil & Yang (2013): f7]: Bounded, continuous, differentiable, multimodal, non-convex, separable, scalable. Global minimum: \(-2.8081311800070053^n\) at (7.917052698245946, ..., 7.917052698245946). Bounds: [(0, 0), (10, 10)]. Dimensions: Any \( n \geq 1 \).
- **axisParallelHyperEllipsoid** [Molga & Smutnicki (2005): 2.2]: Continuous, convex, differentiable, scalable, separable. Global minimum: 0 at (0, 0, ..., 0). Bounds: \((-\infty, -\infty), (\infty, \infty)\). Dimensions: Any \( n \geq 1 \).
- **bartelsconn** [Jamil & Yang (2013): f9]: Bounded, continuous, multimodal, non-convex, non-separable, partially differentiable. Global minimum: 1 at (0, 0). Bounds: [(-500, -500), (500, 500)]. Dimensions: \( n = 2 \).
- **beale** [Jamil & Yang (2013): f10]: Bounded, continuous, differentiable, non-convex, non-separable, unimodal. Global minimum: 0 at (3, 0.5). Bounds: [(-4.5, -4.5), (4.5, 4.5)]. Dimensions: \( n = 2 \).
- **becker_lago** [Price (1977) via Jamil & Yang (2013, No. 96):] bounded, continuous, multimodal, separable. Minimum: 0 at (5, 5). Bounds: [(-10, -10), (10, 10)]. Dimensions: n = 2.
- **biggsexp2** [Jamil & Yang (2013): f11]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 10). Bounds: [0, 20]^2. Dimensions: n=2.
- **biggsexp3** [Jamil & Yang (2013): f12]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 10, 5). Bounds: [0, 20]^3. Dimensions: n=3.
- **biggsexp4** [Jamil & Yang (2013): f13]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 10, 1, 5). Bounds: [0, 20]^4. Dimensions: n=4.
- **biggsexp5** [Jamil & Yang (2013): f14]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 10, 1, 5, 4). Bounds: [0, 20]^5. Dimensions: n=5.
- **biggsexp6** [Jamil & Yang (2013): f15]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 10, 1, 5, 4, 3). Bounds: [-20, 20]^6. Dimensions: n=6.
- **bird** [Jamil & Yang (2013): f16]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: -106.76453672 at (4.70105582, 3.15294602). Bounds: [(-6.28318531, -6.28318531), (6.28318531, 6.28318531)]. Dimensions: \( n = 2 \).
- **bohachevsky1** [Jamil & Yang (2013): f17]: Bounded, continuous, differentiable, multimodal, non-convex, separable, non-scalable. Global minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: \( n = 2 \).
- **bohachevsky2** [Jamil & Yang (2013): f18]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable, non-scalable. Global minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: \( n = 2 \).
- **bohachevsky3** [Jamil & Yang (2013): f19]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable, non-scalable. Global minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: \( n = 2 \).
- **booth** [Jamil & Yang (2013): f20]: Bounded, continuous, convex, differentiable, separable, unimodal. Global minimum: 0 at (1, 3). Bounds: [(-10, -10), (10, 10)]. Dimensions: \( n = 2 \).
- **boxbetts** [Jamil & Yang (2013): f21]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: 0 at (1, 10, 1). Bounds: [0.9, 1.2] × [9, 11.2] × [0.9, 1.2]. Dimensions: \( n = 3 \).
- **brad** [Jamil & Yang (2013): f8]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0.00821487 at (0.0824, 1.133, 2.3437). Bounds: [-0.25, 0.25] x [0.01, 2.5] x [0.01, 2.5]. Dimensions: n=3.
- **branin** [Molga & Smutnicki (2005): 2.12]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: 0.397887 at (-π, 12.275). Bounds: [(-5, 0), (10, 15)]. Dimensions: \( n = 2 \).
- **braninrcos2** [Jamil & Yang (2013): f23]: Multimodal, non-convex, non-separable, differentiable. Minimum: 5.559037 at (-3.2, 12.53). Bounds: [-5, 15]^2. Dimensions: n=2.
- **braninrcos2** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (-3.172, 12.586). Bounds: [(-5, -5), (15, 15)]. Dimensions: 2.
- **brent** [Jamil & Yang (2013): f24]: Bounded, continuous, differentiable, unimodal, non-convex, non-separable. Global minimum: 0 at (0, 0). Bounds: [(-10, -10), (10, 10)]. Dimensions: \( n = 2 \).
- **brown** [Jamil & Yang (2013): f25]: Bounded, continuous, differentiable, unimodal, non-separable, scalable. Global minimum: 0 at (0, ..., 0). Bounds: [(-1, -1), (4, 4)]. Dimensions: Any \( n \geq 2 \).
- **bukin2** [Jamil & Yang (2013): f26]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: 0 at (-10, 0). Bounds: [(-15, -5), (-3, 3)]. Dimensions: \( n = 2 \).
- **bukin4** [Jamil & Yang (2013): f27], [Naser et al. (2024): 4.39]: Bounded, continuous, differentiable, multimodal, non-convex, separable, partially differentiable. Global minimum: 0 at (-10, 0). Bounds: [(-15, -5), (-3, 3)]. Dimensions: \( n = 2 \).
- **bukin6** [Jamil & Yang (2013): f28]: Bounded, continuous, differentiable, multimodal, non-convex, partially differentiable. Global minimum: 0 at (-10, 1). Bounds: [(-15, -3), (-5, 3)]. Dimensions: \( n = 2 \).
- **carromtable** [Jamil & Yang (2013): f146]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: -24.1568155165 at (±9.646157266348881, ±9.646134286497169). Bounds: [(-10, -10), (10, 10)]. Dimensions: \( n = 2 \).
- **chen** [Jamil & Yang (2013): f31] : bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: Unknown at (0.38888889, 0.72222222). Bounds: [(-500, -500), (500, 500)]. Dimensions: 2.
- **chenv** [Naser et al. (2024)], [al-roomi.org]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: -2000 at (0.388888888888889, 0.722222222222222). Bounds: [(-500, -500), (500, 500)]. Dimensions: \( n = 2 \).
- **chichinadze** [Jamil & Yang (2013): f33]: Multimodal, non-convex, non-separable, differentiable. Minimum: -43.3159 at (5.90133, 0.5). Bounds: [-30,30]^2. Dimensions: n=2.
- **chungreynolds** [Jamil & Yang (2013): f34]: Unimodal, convex, partially-separable, differentiable, scalable. Minimum: 0 at (0, ..., 0). Bounds: [-100, 100]^n. Dimensions: any n.
- **cola** [Jamil & Yang (2013): f35]: Multimodal, non-convex, non-separable, differentiable. Minimum: 11.7464. Bounds: [0, 4] x [-4, 4]^16. Dimensions: n=17.
- **colville** [Jamil & Yang (2013): f36]: Bounded, continuous, differentiable, unimodal, non-convex, non-separable. Global minimum: 0 at (1, 1, 1, 1). Bounds: [(-10, -10, -10, -10), (10, 10, 10, 10)]. Dimensions: \( n = 4 \).
- **corana** [Jamil & Yang (2013): f37]: Multimodal, non-convex, separable, differentiable. Minimum: 0 at (0,0,0,0). Bounds: [-1000,1000]^4. Dimensions: n=4.
- **cosinemixture** [Jamil & Yang (2013): f38]: Multimodal, non-convex, separable, differentiable, scalable. Minimum: -0.1*n at multiple. Bounds: [-1,1]^n. Dimensions: Any n >=1.
- **crossintray** [Jamil & Yang (2013): f39]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: -2.06261187 at (1.34940658, 1.34940658). Bounds: [(-10, -10), (10, 10)]. Dimensions: \( n = 2 \).
- **csendes** [Jamil & Yang (2013): f40]: Unimodal, non-convex, separable, non-differentiable at 0, scalable. Minimum: 0 at (0,0,...,0). Bounds: [-1,1]^n. Dimensions: Any n >=1.
- **cube** [Jamil & Yang (2013): f41]: Unimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1,1,1). Bounds: [-10,10]^3. Dimensions: n=3.
- **damavandi** [Jamil & Yang (2013): f42]: Multimodal, non-convex, non-separable, non-differentiable. Minimum: 0 at (2,2). Bounds: [0,14]^2. Dimensions: n=2.
- **deb1** [Jamil & Yang (2013): f43]: Multimodal, non-convex, separable, differentiable, scalable. Minimum: -1. Bounds: [-1, 1]^n. Dimensions: any n.
- **deb3** [[Jamil & Yang (2013): f43]:  bounded, continuous, differentiable, multimodal, scalable, separable. Minimum: -1 at (0.07969939, 0.07969939). Bounds: [(-1, -1), (1, 1)]. Dimensions: -1.
- **dejongf4** [Molga & Smutnicki (2005)]: Bounded, continuous, convex, has_noise, partially differentiable, scalable, separable, unimodal. Global minimum: 0 at (0, 0, ..., 0). Bounds: [(-1.28, -1.28), (1.28, 1.28)]. Dimensions: Any \( n \geq 1 \).
- **dejongf5modified**: Bounded, continuous, differentiable, finite_at_inf, multimodal, non-convex, non-separable. Global minimum: -0.99800384 at (-31.97833, -31.97833). Bounds: [(-65.536, -65.536), (65.536, 65.536)]. Dimensions: \( n = 2 \).
- **dejongf5original** [Molga & Smutnicki (2005): 2.16]: Bounded, continuous, differentiable, finite_at_inf, multimodal, non-convex, non-separable. Global minimum: -500.01800977 at (-32, -32). Bounds: [(-65.536, -65.536), (65.536, 65.536)]. Dimensions: \( n = 2 \).
- **dekkersaarts** [Jamil & Yang (2013): f90]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: -24776.51834232 at (0, 14.94511215). Bounds: [(-20, -20), (20, 20)]. Dimensions: \( n = 2 \).
- **devilliersglasser1** [Jamil & Yang (2013):f46]: bounded, continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (60.137, 1.371, 3.112, 1.761). Bounds: [(0, 0, 0, 0), (500, 500, 500, 500)]. Dimensions: 4.
- **devilliersglasser2** [Jamil & Yang (2013):f47]: bounded, continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (53.81, 1.27, 3.012, 2.13, 0.507). Bounds: [(0, 0, 0, 0, 0), (500, 500, 500, 500, 500)]. Dimensions: 5.
- **dixonprice** [Molga & Smutnicki (2005)]: Bounded, continuous, differentiable, non-convex, scalable, unimodal. Global minimum: 0 at (1, \( \frac{1}{\sqrt{2}} \approx 0.70710678 \), ...). Bounds: [(-10, -10), (10, 10)]. Dimensions: Any \( n \geq 1 \).
- **dolan** [Jamil & Yang (2013)]: bounded, continuous, controversial, differentiable, multimodal, non-separable. Minimum: Unknown at (98.96425831, 100, 100, 99.22432367, -0.24998753). Bounds: [(-100, -100, -100, -100, -100), (100, 100, 100, 100, 100)]. Dimensions: 5.
- **dropwave** [Molga & Smutnicki (2005): 2.17]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: -1 at (0, 0). Bounds: [(-5.12, -5.12), (5.12, 5.12)]. Dimensions: \( n = 2 \).
- **easom** [Molga & Smutnicki (2005): 2.13]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: -1 at (\(\pi, \pi\)). Bounds: [(-100, -100), (100, 100)]. Dimensions: \( n = 2 \).
- **eggcrate** [Jamil & Yang (2013): f52]: Multimodal, non-convex, separable, differentiable. Minimum: 0 at (0, 0). Bounds: [-5, 5]^2. Dimensions: n=2.
- **eggholder** [Jamil & Yang (2013)]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: 
- **elattarvidyasagardutta** [Jamil & Yang (2013): f51]: Unimodal, non-convex, non-separable, differentiable. Minimum: 0.470427 at (2.8425, 1.9202). Bounds: [-500, 500]^2. Dimensions: n=2.
- **exponential** [Jamil & Yang (2013)]: bounded, continuous, differentiable, non-separable, scalable, unimodal. Minimum: -1 at (0, 0). Bounds: [(-1, -1), (1, 1)]. Dimensions: -1.
- **freudensteinroth** [Jamil & Yang (2013): f56]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: 0 at (5, 4). Bounds: [(-10, -10), (10, 10)]. Dimensions: \( n = 2 \).
- **giunta** [Jamil & Yang (2013): f57]: Bounded, continuous, differentiable, multimodal, non-convex, separable. Global minimum: 0.06447042 at (0.46732003, 0.46732003). Bounds: [(-1, -1), (1, 1)]. Dimensions: \( n = 2 \).
- **goldsteinprice** [Molga & Smutnicki (2005): 2.14]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: 3 at (0, -1). Bounds: [(-2, -2), (2, 2)]. Dimensions: \( n = 2 \).
- **griewank** [Molga & Smutnicki (2005): 2.7]: Bounded, continuous, differentiable, multimodal, scalable, separable. Global minimum: 0 at (0, 0, ..., 0). Bounds: [(-600, -600), (600, 600)]. Dimensions: Any \( n \geq 1 \).
- **gulfresearch** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (50, 25, 1.5). Bounds: [(0.1, 0, 0), (100, 25.6, 5)]. Dimensions: 3.
- **hansen** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, separable. Minimum: Unknown at (-7.589893, -7.708314). Bounds: [(-10, -10), (10, 10)]. Dimensions: 2.
- **hartman6** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (0.20169, 0.15001, 0.476874, 0.275332, 0.311652, 0.6573). Bounds: [(0, 0, 0, 0, 0, 0), (1, 1, 1, 1, 1, 1)]. Dimensions: 6.
- **hartmanf3** [Jamil & Yang (2013): f62]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: -3.86278215 at (0.11461434, 0.55564885, 0.85254695). Bounds: [(0, 0, 0), (1, 1, 1)]. Dimensions: \( n = 3 \).
- **helicalvalley** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (1, 0, 0). Bounds: [(-10, -10, -10), (10, 10, 10)]. Dimensions: 3.
- **himmelblau** [Jamil & Yang (2013): f65]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: 0 at (3, 2). Bounds: [(-5, -5), (5, 5)]. Dimensions: \( n = 2 \).
- **holderTable** [Jamil & Yang (2013): f146]: Bounded, continuous, differentiable, multimodal, non-convex, separable. Global minimum: -19.20850257 at (8.055023, 9.66459). Bounds: [(-10, -10), (10, 10)]. Dimensions: \( n = 2 \).
- **hosaki** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-separable. Minimum:  -2.345811576101292				 at (4, 2). Bounds: [(0, 0), (5, 6)]. Dimensions: 2.
- **jennrichsampson** [Unknown Source]: bounded, continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (0.25782543, 0.25782502). Bounds: [(-1, -1), (1, 1)]. Dimensions: 2.
- **keane** [Jamil & Yang (2013): f69]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: -0.67366752 at (0, 1.39324907). Bounds: [(0, 0), (10, 10)]. Dimensions: \( n = 2 \).
- **kearfott** [Jamil & Yang (2013)]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: 0 at (1.22474487, 0.70710678). Bounds: [(-3, -3), (4, 4)]. Dimensions: \( n = 2 \).
- **langermann** [Molga & Smutnicki (2005): 2.10]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: -5.16212616 at (2.00299212, 1.00609594). Bounds: [(0, 0), (10, 10)]. Dimensions: \( n = 2 \).
- **leon** [Unknown Source]: bounded, continuous, differentiable, non-separable, unimodal. Minimum: Unknown at (1, 1). Bounds: [(-1.2, -1.2), (1.2, 1.2)]. Dimensions: 2.
- **levyjamil** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-convex, scalable. Minimum: 0 at (1, 1). Bounds: [(-10, -10), (10, 10)]. Dimensions: scalable (n ≥ 1).
- **matyas** [Molga & Smutnicki (2005)]: Bounded, continuous, convex, differentiable, non-separable, unimodal. Global minimum: 0 at (0, 0). Bounds: [(-10, -10), (10, 10)]. Dimensions: \( n = 2 \).
- **mccormick** [Molga & Smutnicki (2005)]: Bounded, continuous, differentiable, multimodal, non-convex. Global minimum: -1.91322295 at (-0.54719755, -1.54719755). Bounds: [(-1.5, -3), (4, 4)]. Dimensions: \( n = 2 \).
- **michalewicz** [Molga & Smutnicki (2005): 2.11]: Bounded, continuous, differentiable, multimodal, non-separable, scalable. Global minimum: -1.8013 at (2.20290552, 1.57079633). Bounds: [(0, 0), (π, π)]. Dimensions: Any \( n \geq 1 \).
- **mishra1** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-separable, scalable. Minimum: 2 at (1, 1). Bounds: [(0, 0), (1, 1)]. Dimensions: -1.
- **mishra10** [Jamil & Yang (2013):] bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: 0 at (0, 0). Bounds: [(-10, -10), (10, 10)]. Dimensions: n = 2.
- **mishra11** [Jamil & Yang (2013):] bounded, continuous, differentiable, multimodal, non-convex, non-separable, scalable. Minimum: 0 at (1, 1). Bounds: [(0, 0), (10, 10)]. Dimensions: scalable (n ≥ 1).
- **mishra2** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-separable, scalable. Minimum: 2 at (1, 1). Bounds: [(0, 0), (1, 1)]. Dimensions: -1.
- **mishra3** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (-8.46661378, -9.99852131). Bounds: [(-10, -10), (10, 10)]. Dimensions: 2.
- **mishra4** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (-9.94112, -10). Bounds: [(-10, -10), (10, 10)]. Dimensions: 2.
- **mishra5** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (-1.98682, -10). Bounds: [(-10, -10), (10, 10)]. Dimensions: 2.
- **mishra6** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (2.88630722, 1.82326033). Bounds: [(-10, -10), (10, 10)]. Dimensions: 2.
- **mishra7** [Jamil & Yang (2013)]: continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (1, 2). Bounds: [(-10, -10), (10, 10)]. Dimensions: 2.
- **mishra8** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (2, -3). Bounds: [(-10, -10), (10, 10)]. Dimensions: 2.
- **mishra9** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-separable. Minimum: Unknown at (1, 2, 3). Bounds: [(-10, -10, -10), (10, 10, 10)]. Dimensions: 3.
- **mshrabird** [Jamil & Yang (2013)]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: -106.764537 at (-3.1302468, -1.5821422). Bounds: [(-10, -6.5), (0, 0)]. Dimensions: \( n = 2 \).
- **mvf_shubert** [Adorio (2005, p. 12):] continuous, differentiable, multimodal, separable. Minimum: -24.06249888 at (-0.49139084, 5.79179447). Bounds: [(-10, -10), (10, 10)]. Dimensions: n = 2.
- **mvf_shubert2** [Adorio (2005, p. 13):] continuous, differentiable, multimodal, separable. Minimum: -25.741771 at (-1.42512843, -1.42512843). Bounds: [(-10, -10), (10, 10)]. Dimensions: n = 2.
- **mvf_shubert3** [Adorio (2005, p. 13):] continuous, differentiable, multimodal, scalable, separable. Minimum: -24.06249888 at (-0.49139083, -0.49139083). Bounds: [(-10, -10), (10, 10)]. Dimensions: scalable (n ≥ 1).
- **parsopoulos** [Jamil & Yang (2013):] bounded, continuous, differentiable, multimodal, non-convex, separable. Minimum: 0 at (1.57079633, 0). Bounds: [(-5, -5), (5, 5)]. Dimensions: n = 2.
- **pathological** [Jamil & Yang (2013):] bounded, continuous, differentiable, multimodal, non-convex, non-separable, scalable. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **paviani** [Jamil & Yang (2013):] bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -45.77846971 at (9.350266, 9.350266, 9.350266, 9.350266, 9.350266, 9.350266, 9.350266, 9.350266, 9.350266, 9.350266). Bounds: [(2.001, 2.001, 2.001, 2.001, 2.001, 2.001, 2.001, 2.001, 2.001, 2.001), (9.999, 9.999, 9.999, 9.999, 9.999, 9.999, 9.999, 9.999, 9.999, 9.999)]. Dimensions: n = 10.
- **penholder** [Jamil & Yang (2013):] bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -0.96353483 at (9.64616767, 9.64616767). Bounds: [(-11, -11), (11, 11)]. Dimensions: n = 2.
- **periodic** [Jamil & Yang (2013):] bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: 0.9 at (0, 0). Bounds: [(-10, -10), (10, 10)]. Dimensions: n = 2.
- **pinter** [Jamil & Yang (2013):] bounded, continuous, differentiable, multimodal, non-convex, non-separable, scalable. Minimum: 0 at (0, 0). Bounds: [(-10, -10), (10, 10)]. Dimensions: scalable (n ≥ 1).
- **powell** [Jamil & Yang (2013): f91]: Bounded, continuous, differentiable, unimodal, non-convex, non-separable. Global minimum: 0 at (0, 0, 0, 0). Bounds: [(-4, -4, -4, -4), (5, 5, 5, 5)]. Dimensions: \( n = 4 \).
- **powellsingular** [Jamil & Yang (2013):] bounded, continuous, differentiable, non-separable, scalable, unimodal. Minimum: 0 at (0, 0, 0, 0). Bounds: [(-4, -4, -4, -4), (5, 5, 5, 5)]. Dimensions: scalable (n ≥ 1).
- **powellsingular2** [Jamil & Yang (2013):] bounded, continuous, differentiable, non-separable, scalable, unimodal. Minimum: 0 at (0, 0, 0, 0). Bounds: [(-4, -4, -4, -4), (5, 5, 5, 5)]. Dimensions: scalable (n ≥ 1).
- **powellsum** [Jamil & Yang (2013):] bounded, continuous, differentiable, scalable, separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-1, -1), (1, 1)]. Dimensions: scalable (n ≥ 1).
- **price1** [Jamil & Yang (2013):] continuous, multimodal, separable. Minimum: 0 at (5, 5). Bounds: [(-500, -500), (500, 500)]. Dimensions: n = 2.
- **price2** [Jamil & Yang (2013):] continuous, differentiable, multimodal. Minimum: 0.9 at (0, 0). Bounds: [(-10, -10), (10, 10)]. Dimensions: n = 2.
- **price4** [Jamil & Yang (2013):] bounded, continuous, differentiable, multimodal, non-separable. Minimum: 0 at (0, 0). Bounds: [(-500, -500), (500, 500)]. Dimensions: n = 2.
- **qing** [Jamil & Yang (2013):] continuous, differentiable, multimodal, scalable, separable. Minimum: 0 at (1, 1.41421356). Bounds: [(-500, -500), (500, 500)]. Dimensions: scalable (n ≥ 1).
- **quadratic** [Jamil & Yang (2013):] bounded, continuous, convex, differentiable, non-separable, unimodal. Minimum: -3873.72418219 at (0.19388017, 0.48513391). Bounds: [(-10, -10), (10, 10)]. Dimensions: n = 2.
- **quartic** [Jamil & Yang (2013):] bounded, continuous, differentiable, has_noise, scalable, separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-1.28, -1.28), (1.28, 1.28)]. Dimensions: scalable (n ≥ 1).
- **quintic** [Jamil & Yang (2013):] continuous, differentiable, multimodal, separable. Minimum: 0 at (-1, -1). Bounds: [(-10, -10), (10, 10)]. Dimensions: n = 2.
- **rana** [Jamil & Yang (2013); Naser et al. (2024):] bounded, continuous, differentiable, multimodal, non-separable, scalable. Minimum: -464.2739277 at (-500, -500). Bounds: [(-500, -500), (500, 500)]. Dimensions: scalable (n ≥ 1).
- **rastrigin** [Molga & Smutnicki (2005): 2.5]:  bounded, continuous, differentiable, multimodal, non-convex, scalable, separable. Minimum: 0 at (0, 0). Bounds: [(-5.12, -5.12), (5.12, 5.12)]. Dimensions: scalable (n ≥ 1).
- **ripple1** [Jamil & Yang (2013):] bounded, continuous, differentiable, multimodal, non-separable. Minimum: -2.2 at (0.1, 0.1). Bounds: [(0, 0), (1, 1)]. Dimensions: n = 2.
- **ripple25** [Jamil & Yang (2013):] bounded, continuous, differentiable, multimodal, non-separable. Minimum: -2 at (0.1, 0.1). Bounds: [(0, 0), (1, 1)]. Dimensions: n = 2.
- **rosenbrock** [Jamil & Yang (2013):] bounded, continuous, differentiable, ill-conditioned, non-separable, scalable, unimodal. Minimum: 0 at (1, 1). Bounds: [(-30, -30), (30, 30)]. Dimensions: scalable (n ≥ 1).
- **rosenbrock_modified** [Jamil & Yang (2013):] bounded, continuous, controversial, deceptive, differentiable, ill-conditioned, multimodal, non-separable. Minimum: 34.04024311 at (-0.90955374, -0.95057171). Bounds: [(-2, -2), (2, 2)]. Dimensions: n = 2.
- **rotatedellipse** [Jamil & Yang (2013):] continuous, convex, differentiable, non-separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-500, -500), (500, 500)]. Dimensions: n = 2.
- **rotatedellipse2** [Jamil & Yang (2013):] bounded, continuous, convex, differentiable, non-separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-500, -500), (500, 500)]. Dimensions: n = 2.
- **rotatedhyperellipsoid** [Molga & Smutnicki (2005): 2.3]: bounded, continuous, convex, differentiable, non-separable, scalable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-65.536, -65.536), (65.536, 65.536)]. Dimensions: scalable (n ≥ 1).
- **rump** [Al-Roomi (2015):] bounded, continuous, non-separable, partially differentiable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-500, -500), (500, 500)]. Dimensions: n = 2.
- **salomon** [Jamil & Yang (2013, p. 27):] continuous, differentiable, multimodal, non-separable, scalable. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **sargan** [Jamil & Yang (2013, p. 27):] continuous, differentiable, multimodal, non-separable, scalable. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **schaffer1** [Jamil & Yang (2013, p. 136, Function 112):] bounded, continuous, differentiable, multimodal, non-separable. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: n = 2.
- **schaffer2** [Jamil & Yang (2013, p. 28):] bounded, continuous, differentiable, non-separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: n = 2.
- **schaffer3** [Jamil & Yang (2013, p. 28):] continuous, differentiable, non-separable, unimodal. Minimum: 0.00156686 at (0, 1.25311559). Bounds: [(-100, -100), (100, 100)]. Dimensions: n = 2.
- **schaffer6** [Al-Roomi (2015, Schaffer's Function No. 06):] bounded, continuous, differentiable, multimodal, non-separable. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: n = 2.
- **schafferf6** [Jamil & Yang (2013, p. 32):] continuous, differentiable, multimodal, non-separable, scalable. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **schaffern2** [Mishra (2007, p. 4):] bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: n = 2.
- **schaffern4** [Al-Roomi (2015, Modified Schaffer's Function No. 04):] bounded, continuous, multimodal, non-convex, non-separable, partially differentiable. Minimum: 0.29257863 at (0, 1.25313183). Bounds: [(-100, -100), (100, 100)]. Dimensions: n = 2.
- **schmidtvetters** [Jamil & Yang (2013, p. 116):] controversial, multimodal, non-separable, partially differentiable. Minimum: 0.19397252 at (7.07083412, 10, 3.14159293). Bounds: [(0, 0, 0), (10, 10, 10)]. Dimensions: n = 3.
- **schumersteiglitz** [Schumer, M. A. and Steiglitz, K. (1968). Adaptive Step Size Random Search. IEEE Transactions on Automatic Control, 13(3), 270–276.:] continuous, differentiable, scalable, separable, unimodal. Minimum: 0 at (0, ..., 0). Bounds: [(-10, ..., -10), (10, ..., 10)]. Dimensions: scalable (n ≥ 1).
- **schwefel** [Jamil & Yang (2013, p. 118):] continuous, differentiable, partially separable, scalable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **schwefel12** [Jamil & Yang (2013, p. 29):] continuous, differentiable, non-separable, scalable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **schwefel220** [Jamil & Yang (2013, p. 77):] continuous, partially differentiable, scalable, separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **schwefel221** [Jamil & Yang (2013, p. 123):] continuous, partially differentiable, scalable, separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **schwefel222** [Jamil & Yang (2013, p. 124):] continuous, non-separable, partially differentiable, scalable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **schwefel223** [Jamil & Yang (2013, p. 125):] continuous, differentiable, scalable, separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-10, -10), (10, 10)]. Dimensions: scalable (n ≥ 1).
- **schwefel225** [Jamil & Yang (2013, p. 127):] continuous, differentiable, multimodal, separable. Minimum: 0 at (1, 1). Bounds: [(0, 0), (10, 10)]. Dimensions: n = 2.
- **schwefel226** [Jamil & Yang (2013, p. 30):] continuous, differentiable, multimodal, scalable, separable. Minimum: -418.98288727 at (420.96874358, 420.96874358). Bounds: [(-500, -500), (500, 500)]. Dimensions: scalable (n ≥ 1).
- **schwefel236** [Jamil & Yang (2013, p. 129):] continuous, differentiable, non-separable, unimodal. Minimum: -3456 at (12, 12). Bounds: [(0, 0), (500, 500)]. Dimensions: n = 2.
- **schwefel24** [Jamil & Yang (2013, p. 30):] continuous, differentiable, multimodal, separable. Minimum: 0 at (1, 1). Bounds: [(0, 0), (10, 10)]. Dimensions: n = 2.
- **schwefel26** [Jamil & Yang (2013, p. 31):] continuous, differentiable, non-separable, unimodal. Minimum: 0 at (1, 3). Bounds: [(-100, -100), (100, 100)]. Dimensions: n = 2.
- **shekel** [Jamil & Yang (2013, p. 30):] bounded, continuous, differentiable, finite_at_inf, multimodal, non-convex, non-separable. Minimum: -10.53640982 at (4.00074653, 4.00059293, 3.9996634, 3.9995098). Bounds: [(0, 0, 0, 0), (10, 10, 10, 10)]. Dimensions: n = 4.
- **shekel5** [Jamil & Yang (2013, p. 130):] continuous, controversial, differentiable, multimodal, non-separable. Minimum: -10.15319968 at (4.00003715, 4.00013327, 4.00003715, 4.00013327). Bounds: [(0, 0, 0, 0), (10, 10, 10, 10)]. Dimensions: n = 4.
- **shekel7** [Jamil & Yang (2013, p. 131):] continuous, controversial, differentiable, multimodal, non-separable. Minimum: -10.40294057 at (4.00057291, 4.00068936, 3.99948971, 3.99960616). Bounds: [(0, 0, 0, 0), (10, 10, 10, 10)]. Dimensions: n = 4.
- **shubert_additive_cosine** [Jamil & Yang (2013, p. 56):] continuous, differentiable, multimodal, scalable, separable. Minimum: -25.741771 at (-1.42512843, -1.42512843). Bounds: [(-10, -10), (10, 10)]. Dimensions: scalable (n ≥ 1).
- **shubert_additive_sine** [Jamil & Yang (2013, p. 55):] continuous, differentiable, multimodal, scalable, separable. Minimum: -29.67590005 at (-7.397285, -7.397285). Bounds: [(-10, -10), (10, 10)]. Dimensions: scalable (n ≥ 1).
- **shubert_classic** [Jamil & Yang (2013, p. 55):] continuous, controversial, differentiable, highly multimodal, non-separable. Minimum: -186.73090883 at (4.85805688, 5.48286421). Bounds: [(-10, -10), (10, 10)]. Dimensions: n = 2.
- **shubert_coupled** [Jamil & Yang (2013, p. 56):] continuous, differentiable, highly multimodal, non-separable, scalable. Minimum: -186.73090883 at (4.85805688, 5.48286421). Bounds: [(-10, -10), (10, 10)]. Dimensions: scalable (n ≥ 1).
- **shubert_generalized** [Jamil & Yang (2013, p. 56):] continuous, differentiable, multimodal, scalable, separable. Minimum: -25.741771 at (-1.42512843, -1.42512843). Bounds: [(-10, -10), (10, 10)]. Dimensions: scalable (n ≥ 1).
- **shubert_hybrid_rastrigin** [Jamil & Yang (2013, p. 56):] bounded, continuous, differentiable, ill-conditioned, multimodal, non-separable. Minimum: -79.36953021 at (-0.81305187, -1.41787744). Bounds: [(-10, -10), (10, 10)]. Dimensions: n = 2.
- **shubert_noisy** [Jamil & Yang (2013, p.55):] continuous, differentiable, has_noise, multimodal, non-separable. Minimum: -186.73090883 at (4.85805688, 5.48286421). Bounds: [(-10, -10), (10, 10)]. Dimensions: n = 2.
- **shubert_rotated** [Jamil & Yang (2013, p. 55):] continuous, differentiable, highly multimodal, non-separable, scalable. Minimum: -186.73090883 at (4.85805688, 5.48286421). Bounds: [(-10, -10), (10, 10)]. Dimensions: scalable (n ≥ 1).
- **shubert_shifted** [Jamil & Yang (2013, p. 55):] continuous, differentiable, highly multimodal, non-separable, scalable. Minimum: -186.73090883 at (4.85805688, 5.48286421). Bounds: [(-10, -10), (10, 10)]. Dimensions: scalable (n ≥ 1).
- **shubert_shifted_rotated** [CEC 2014; Jamil & Yang (2013, extended transformations):] continuous, differentiable, multimodal, non-separable. Minimum: -186.73090883 at (55.82260356, -69.31153727). Bounds: [(-100, -100), (100, 100)]. Dimensions: n = 2.
- **sineenvelope** [Molga & Smutnicki (2005):] bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -1 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: n = 2.
- **sixhumpcamelback** [Jamil & Yang (2013, p. 10):] bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -1.03162845 at (0.08984201, -0.7126564). Bounds: [(-3, -2), (3, 2)]. Dimensions: n = 2.
- **sphere** [Jamil & Yang (2013, p. 33):] bounded, continuous, convex, differentiable, scalable, separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-5.12, -5.12), (5.12, 5.12)]. Dimensions: scalable (n ≥ 1).
- **sphere_noisy** [BBOB f101 / Nevergrad:] continuous, convex, differentiable, has_noise, scalable, separable. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **sphere_rotated** [CEC 2005 Problem Definitions:] continuous, convex, differentiable, non-separable, scalable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **sphere_shifted** [CEC 2005 Special Session:] continuous, convex, differentiable, scalable, separable, unimodal. Minimum: 0 at (1, 1). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **step** [Jamil & Yang (2013, function 138):] bounded, non-convex, partially differentiable, scalable, separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **step2** [Jamil & Yang (2013, function 139):] bounded, non-convex, partially differentiable, scalable, separable, unimodal. Minimum: 0 at (-0.5, -0.5). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **step3** [Jamil & Yang (2013, function 140):] bounded, non-convex, partially differentiable, scalable, separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **step_ellipsoidal** [BBOB 2009 Noiseless Functions f7:] continuous, ill-conditioned, non-separable, partially differentiable, scalable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: scalable (n ≥ 1).
- **stepint** [Jamil & Yang (2013, function 141):] bounded, non-convex, partially differentiable, scalable, separable, unimodal. Minimum: 13 at (-5.12, -5.12). Bounds: [(-5.12, -5.12), (5.12, 5.12)]. Dimensions: scalable (n ≥ 1).
- **stretched_v_sine_wave** [Jamil & Yang (2013, function 142):] bounded, continuous, differentiable, non-separable, scalable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-10, -10), (10, 10)]. Dimensions: scalable (n ≥ 1).
- **styblinski_tang** [Jamil & Yang (2013, function 144):] bounded, continuous, differentiable, multimodal, non-convex, scalable, separable. Minimum: -78.33233141 at (-2.90353403, -2.90353403). Bounds: [(-5, -5), (5, 5)]. Dimensions: scalable (n ≥ 1).
- **sumofpowers** [Jamil & Yang (2013, p. 32):] bounded, continuous, convex, differentiable, scalable, separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-1, -1), (1, 1)]. Dimensions: scalable (n ≥ 1).
- **ThreeHumpCamel** [Jamil & Yang (2013): f29]: Bounded, continuous, differentiable, multimodal, non-convex, non-separable. Global minimum: 0 at (0, 0). Bounds: [(-5, -5), (5, 5)]. Dimensions: \( n = 2 \).
- **Trid** [Jamil & Yang (2013): f150, f151]: Bounded, continuous, convex, differentiable, non-separable, scalable, unimodal. Global minimum: -2 at (2, 2, ..., 2). Bounds: [(-4, -4), (4, 4)]. Dimensions: Any \( n \geq 1 \).
- **Wood** [Jamil & Yang (2013): f121]: Bounded, continuous, differentiable, non-convex, non-separable, unimodal. Global minimum: 0 at (1, 1, 1, 1). Bounds: [(-10, -10, -10, -10), (10, 10, 10, 10)]. Dimensions: \( n = 4 \).
- **Zakharov** [Naser (2024): 4.311]: Bounded, continuous, convex, differentiable, non-separable, scalable, unimodal. Global minimum: 0 at (0, 0, ..., 0). Bounds: [(-5, -5), (10, 10)]. Dimensions: Any \( n \geq 1 \).
## Upcoming Test Functions

The following test functions are planned for implementation, based on standard benchmarks. They will be added with analytical gradients, metadata, and validation, consistent with the existing collection.


- **Cigar**: Unimodal, convex, non-separable, differentiable, scalable. Minimum: 0 at (0,0,...,0). Bounds: [-10,10]^n. Dimensions: Any n >=2.
- **EX Function 1** [Jamil & Yang (2013): f55]: Multimodal, non-convex, separable, differentiable. Minimum: -1.28186 at (1.764, 11.150). Bounds: [0, 2] x [10, 12]. Dimensions: n=2.
- **Gulf Research** [Jamil & Yang (2013): f60]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (50, 25, 1.5). Bounds: [0.1, 100] x [0, 25.6] x [0, 5]. Dimensions: n=3.
- **Hansen** [Jamil & Yang (2013): f61]: Multimodal, non-convex, separable, differentiable. Multiple global minima. Bounds: [-10, 10]^2. Dimensions: n=2.
- **Hosaki** [Jamil & Yang (2013): f66]: Multimodal, non-convex, non-separable, differentiable. Minimum: -2.3458 at (4, 2). Bounds: [0, 5] x [0, 6]. Dimensions: n=2.
- **Jennrich-Sampson** [Jamil & Yang (2013): f67]: Multimodal, non-convex, non-separable, differentiable. Minimum: 124.3612 at (0.2578, 0.2578). Bounds: [-1, 1]^2. Dimensions: n=2.
- **Leon** [Jamil & Yang (2013): f70]: Unimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 1). Bounds: [-1.2, 1.2]^2. Dimensions: n=2.
- **Miele Cantrell** [Jamil & Yang (2013): f73]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (0, 1, 1, 1). Bounds: [-1, 1]^4. Dimensions: n=4.
- **Parsopoulos** [Jamil & Yang (2013): f85]: Multimodal, non-convex, separable, differentiable. Minimum: 0 at multiple points. Bounds: [-5, 5]^2. Dimensions: n=2.
- **Pathological** [Jamil & Yang (2013): f87]: Multimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0 at (0, ..., 0). Bounds: [-100, 100]^n. Dimensions: any n.
- **Pen Holder** [Jamil & Yang (2013): f86]: Multimodal, non-convex, non-separable, differentiable. Minimum: -0.96354 at (±9.646, ±9.646). Bounds: [-11, 11]^2. Dimensions: n=2.
- **Periodic** [Jamil & Yang (2013): f90]: Multimodal, non-convex, separable, differentiable. Minimum: 0.9 at (0, 0). Bounds: [-10, 10]^2. Dimensions: n=2.
- **Perm**: Unimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0 at (1,1/2,1/3,...,1/n). Bounds: [-n, n]^n. Dimensions: Any n >=1.
- **Pintér** [Jamil & Yang (2013): f89]: Multimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0 at (0, ..., 0). Bounds: [-10, 10]^n. Dimensions: any n.
- **deVilliers Glasser 1** [Jamil & Yang (2013): f46]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0. Bounds: [-500, 500]^4. Dimensions: n=4.
- **deVilliers Glasser 2** [Jamil & Yang (2013): f47]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0. Bounds: [-500, 500]^5. Dimensions: n=5.

## Properties of Test Functions

The following properties are used to characterize the test functions in this package, as defined in `VALID_PROPERTIES` in `src/NonlinearOptimizationTestFunctions.jl`. Properties like `continuous` (stetig), `differentiable`, and `partially differentiable` are standard mathematical terms and not further explained. This list is based on standard optimization literature, including [Molga & Smutnicki (2005)].

- **bounded**: The function is defined within finite bounds (e.g., \( x \in [-a, a]^n \)).
- **continuous**: The function is continuous (no explanation needed).
- **controversial**: The function's properties or behavior may be debated in literature.
- **convex**: The function is convex, ensuring a single global optimum.
- **deceptive**: The function misleads optimization algorithms toward suboptimal solutions.
- **differentiable**: The function is differentiable (no explanation needed).
- **finite_at_inf**: The function yields finite values even as inputs approach infinity.
- **fully non-separable**: The function's variables are fully interdependent, preventing any decomposition.
- **has_constraints**: The function includes constraints (e.g., equality or inequality constraints).
- **has_noise**: The function includes stochastic or noisy components.
- **highly multimodal**: The function has a very large number of local minima/maxima.
- **multimodal**: The function has multiple local minima/maxima, with at least one global optimum.
- **non-convex**: The function is not convex, allowing multiple optima or complex landscapes.
- **non-separable**: The function's variables are interdependent, preventing decomposition into independent subproblems.
- **partially differentiable**: The function is differentiable only in some variables or regions (no explanation needed).
- **partially separable**: The function can be partially decomposed into independent subproblems.
- **quasi-convex**: The function has convex level sets, but is not strictly convex.
- **scalable**: The function can be defined for any dimension \( n \geq 1 \).
- **separable**: The function can be optimized independently along each dimension.
- **strongly convex**: The function is convex with a unique global optimum and strong curvature.
- **unimodal**: The function has exactly one global minimum/maximum and no local optima.

## Valid Properties

Each test function is associated with a set of properties that describe its mathematical characteristics, enabling filtering for specific use cases (e.g., multimodal or scalable functions). The following properties are defined in the package and can be assigned to test functions via their metadata (`meta[:properties]`). Note that not all properties are assigned to every function; for example, `finite_at_inf` is currently only applied to `De Jong F5` and `Shekel`, while `Langermann` does not have this property despite returning finite values at infinity.

### Modality
- **unimodal**: The function has a single global minimum and no local minima.
- **multimodal**: The function has multiple local minima, making it challenging for optimization algorithms.
- **highly multimodal**: A subset of multimodal functions with a particularly large number of local minima.
- **deceptive**: The function has features that may mislead optimization algorithms toward suboptimal solutions.

### Convexity
- **convex**: The function is convex, ensuring a unique global minimum for continuous functions.
- **non-convex**: The function is not convex, potentially having multiple minima or saddle points.
- **quasi-convex**: The function is not convex but has a convex sublevel set, useful for certain optimization algorithms.
- **strongly convex**: The function is convex with a strong curvature, guaranteeing faster convergence for some methods.

### Separability
- **separable**: The function can be optimized independently along each dimension.
- **non-separable**: The function's variables are interdependent, requiring joint optimization.
- **partially separable**: The function can be partially decomposed into separable components.
- **fully non-separable**: The function is entirely non-separable, with strong interdependencies across all variables.

### Differentiability
- **differentiable**: The function has a well-defined gradient everywhere in its domain.
- **partially differentiable**: The function is differentiable in parts of its domain but may have non-differentiable points.

### Other Properties
- **scalable**: The function can be defined for any number of dimensions (n >= 1).
- **continuous**: The function is continuous across its domain.
- **bounded**: The function is defined within finite bounds (e.g., [a, b]^n), and evaluations outside these bounds are typically undefined or irrelevant. Tests for bounded functions check finite values at the bounds (`lb`, `ub`) instead of at infinity.
- **has_constraints**: The function includes explicit constraints (e.g., equality or inequality constraints).
- **controversial**: The function has debated properties or inconsistent definitions in the literature.
- **has_noise**: The function includes stochastic or noisy components, simulating real-world uncertainty.
- **finite_at_inf**: The function returns finite values when evaluated at infinity (e.g., f([Inf, ..., Inf]) is finite).

These properties are validated in the test suite (e.g., `test/runtests.jl`) to ensure consistency and correctness.

## Running Tests

To run the test suite, execute:

    cd /c/Users/uweal/NonlinearOptimizationTestFunctions
    julia --project=. -e 'using Pkg; Pkg.resolve(); Pkg.instantiate(); include("test/runtests.jl")'

Tests cover function evaluations, metadata validation, edge cases (NaN, Inf, 1e-308, empty input vectors, and bounds for bounded functions), and optimization with Optim.jl. For functions marked as `bounded`, tests verify finite values at the lower and upper bounds (`lb`, `ub`) instead of infinity, reflecting their constrained domain. Extensive gradient tests are conducted in `test/runtests.jl` to ensure the correctness of analytical gradients. These gradients are rigorously validated by comparing them against numerical gradients computed via finite differences and gradients obtained through automatic differentiation (AD) using ForwardDiff, ensuring high accuracy and reliability. All tests, including those for the newly added Deckkers-Aarts, Shekel, SchafferN2, and SchafferN4 functions, pass as of the last update, ensuring robustness and correctness.

## License

This package is licensed under the MIT License. See LICENSE for details.

## Alternative Names for Test Functions

Some test functions are referred to by different names in the literature. Below is a list connecting the names used in this package to common alternatives.

- **ackley**: Ackley's function, Ackley No. 1, Ackley Path Function.
- **alpinen1**: Alpine No. 1 function, Alpine function.
- **alpinen2**: Alpine No. 2 function, Alpine function.
- **axisparallelhyperellipsoid**: Axis parallel hyper-ellipsoid function, Sum squares function, Weighted sphere model, Quadratic function (axis-aligned variant), Weighted Sphere (Ellipsoid).
- **beale**: Beale's function.
- **bird**: Bird's function.
- **bohachevsky**: Bohachevsky's function, Bohachevsky No. 1 (for the standard variant).
- **booth**: Booth's function.
- **branin**: Branin's rcos function, Branin-Hoo function, Branin function.
- **bukin6**: Bukin function No. 6.
- **crossintray**: Cross-in-Tray function.
- **deckkersaarts**: Deckkers-Aarts function, Deckkers and Aarts function.
- **dejongf4**: De Jong F4, Quartic function with noise, Noisy quartic function.
- **dejongf5**: De Jong F5, Foxholes function.
- **dixonprice**: Dixon-Price function.
- **dropwave**: Drop-Wave function.
- **easom**: Easom's function.
- **eggholder**: Egg Holder function, Egg Crate function, Holder Table function.
- **giunta**: Giunta function.
- **goldsteinprice**: Goldstein-Price function.
- **griewank**: Griewank's function, Griewangk’s function, Griewank function.
- **hartmann**: Hartmann function (Hartmann 3, 4 or 6).
- **himmelblau**: Himmelblau's function.
- **holdertable**: Holder Table function.
- **kearfott**: Kearfott's function.
- **keane**: Keane's function, Bump function.
- **langermann**: Langermann's function.
- **levy**: Levy function No. 13, Levy N.13.
- **matyas**: Matyas function.
- **mccormick**: McCormick's function.
- **michalewicz**: Michalewicz's function.
- **mishrabird**: Mishra's Bird function (often associated with a constraint).
- **quadratic**: Quadratic function, Paraboloid, General quadratic form (often customized with matrix A, vector b, scalar c).
- **rana**: Rana's function.
- **rastrigin**: Rastrigin's function.
- **rosenbrock**: Rosenbrock's valley, De Jong F2, Banana function.
- **rotatedhyperellipsoid**: Rotated Hyper-Ellipsoid function, Schwefel's function 1.2, Extended sum squares function, Extended Rosenbrock function (in some contexts), Rotated Ellipsoid.
- **schaffern1**: Schaffer function N. 1.
- **schaffern2**: Schaffer function N. 2.
- **schaffern4**: Schaffer function N. 4.
- **schwefel**: Schwefel's function, Schwefel 2.26, Schwefel Problem 2.26.
- **shekel**: Shekel's function, Shekel's foxholes, Foxholes function.
- **shubert**: Shubert's function.
- **sineenvelope**: Sine Envelope Sine Wave Sine function, Sine envelope function.
- **sixhumpcamelback**: Six-Hump Camelback function, Camel function, Six-hump camel function.
- **sphere**: Sphere function, De Jong F1, Quadratic sphere, Parabola function, Sum of squares (unweighted).
- **step**: Step function, De Jong F3.
- **styblinskitang**: Styblinski-Tang function, Tang function.
- **sumofpowers**: Sum of different powers function, Absolute value function, Sum of increasing powers.
- **threehumpcamel**: Three-Hump Camel function, Camel Three Humps function.
- **zakharov**: Zakharov's function.

## References

- Al-Roomi, A. R. (2015). Unconstrained Single-Objective Benchmark Functions Repository. Dalhousie University. https://www.al-roomi.org/benchmarks/unconstrained
- Gavana, A. (2013). Test functions index. Retrieved February 2013, from http://infinity77.net/global_optimization/test_functions.html (Note: Original source unavailable; referenced via Al-Roomi (2015) and opfunu Python library: https://github.com/thieu1995/opfunu/blob/master/opfunu/cec_based/cec.py)
- Hedar, A.-R. (2005). Global optimization test problems. http://www-optima.amp.i.kyoto-u.ac.jp/member/student/hedar/Hedar_files/TestGO.htm
- Jamil, M., & Yang, X.-S. (2013). A literature survey of benchmark functions for global optimisation problems. *International Journal of Mathematical Modelling and Numerical Optimisation*, 4(2), 150–194. https://arxiv.org/abs/1308.4008
- Molga, M., & Smutnicki, C. (2005). Test functions for optimization needs. http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf
- Naser, M.Z., al-Bashiti, M.K., Teymori Gharah Tapeh, A., Dadras Eslamlou, A