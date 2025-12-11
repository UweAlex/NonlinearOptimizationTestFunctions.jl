# NonlinearOptimizationTestFunctions
# Last modified: 25 Nov 2025, 12:07 PM CEST

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Usage](#usage)
  - [Enforcing Box Constraints via L1 Exact Penalty (`with_box_constraints`)](#enforcing-box-constraints-via-l1-exact-penalty-with_box_constraints)
  - [Examples](#examples)
    - [Getting Himmelblau Dimension](#getting-himmelblau-dimension)
    - [Listing Test Functions with Dimension n > 2](#listing-test-functions-with-dimension-n--2)
    - [Evaluating the Eggholder Function](#evaluating-the-eggholder-function)
    - [Comparing Optimization Methods](#comparing-optimization-methods)
    - [Computing Hessian with Zygote](#computing-hessian-with-zygote)
    - [Listing Test Functions and Properties](#listing-test-functions-and-properties)
    - [Optimizing All Functions](#optimizing-all-functions)
    - [Optimizing with NLopt](#optimizing-with-nlopt)
    - [High-Precision Optimization with BigFloat](#high-precision-optimization-with-bigfloat)
    - [Filtering Test Functions by Properties](#filtering-test-functions-by-properties)
    - [Tracking Function and Gradient Calls](#tracking-function-and-gradient-calls)
  - [New Object-Oriented Interface for Metadata and Properties](#new-object-oriented-interface-for-metadata-and-properties)
    - [Setting the Default Dimension](#setting-the-default-dimension)
    - [Accessing Metadata](#accessing-metadata)
    - [Accessing Properties](#accessing-properties)
    - [Example Usage](#example-usage)
    - [Notes](#notes)
- [Tests of the Test Functions](#tests-of-the-test-functions)
- [Test Functions](FUNCTIONS.md)
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

### Box Constraints via L1 Exact Penalty (with_box_constraints)

Many test functions in this package are defined with box constraints (:lb, :ub) that represent the valid domain of the function. Evaluating the original objective or its analytical gradient outside these bounds typically results in DomainError, NaN, or undefined behavior (e.g. logarithm of negative values or square root of negative arguments).

Unconstrained optimization algorithms (L-BFGS, CG, Newton, Nelder–Mead, etc.) do not enforce these bounds by default. As a consequence, direct application to bounded test problems is either unsafe or leads to inconsistent comparisons between solvers.

Added in v0.5: with_box_constraints(tf) returns a new TestFunction instance that

• evaluates the original function and gradient exclusively within the feasible domain [lb, ub],
• enforces hard box constraints using the L1 exact penalty method,
• provides a mathematically valid subgradient of the penalized objective,
• incurs no dynamic memory allocations during optimization,
• enables domain-safe and reproducible benchmarking of both gradient-based and derivative-free methods.

Usage

    using NonlinearOptimizationTestFunctions

    tf  = BRANIN_FUNCTION
    ctf = with_box_constraints(tf)

    res = optimize(ctf.f, ctf.grad, [100.0, -50.0], LBFGS())

Properties

• Domain safety: the original objective and gradient are invoked only at feasible points.
• Correctness: the returned gradient is a valid subgradient of the L1-penalized objective.
• Performance: projection is performed using a pre-allocated buffer; no allocations occur during iteration.
• Consistency: all optimizers operate on an identical objective function.

Observed behavior on bounded test problems

| Solver        | Without wrapper                     | With with_box_constraints           |
|---------------|-------------------------------------|--------------------------------------|
| L-BFGS        | DomainError or divergence           | convergence (typically < 50 evaluations) |
| Nelder–Mead   | invalid function evaluations        | valid and comparable results         |
| Newton/Zygote | undefined or incorrect gradients    | correct constrained solution         |

Example: safe evaluation of all bounded functions

    for (name, tf) in TEST_FUNCTIONS
        bounded(tf) || continue
        ctf = with_box_constraints(tf)
        res = optimize(ctf.f, ctf.grad, start(ctf), LBFGS(),
                       Optim.Options(iterations = 10_000))
        @printf("%-30s  success: %s\n", name,
                abs(minimum(res) - min_value(tf)) < 1e-6)
    end

This mechanism removes a frequent source of irreproducibility and runtime errors when benchmarking optimization algorithms on box-constrained test problems.

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

#### High-Precision Optimization with BigFloat
Demonstrates high-precision optimization using BigFloat (256-bit precision) on the Wayburn-Seader 1 function with L-BFGS and a very tight gradient tolerance (1e-100). This is useful for ill-conditioned or sensitive problems where standard Float64 precision may lead to numerical instability.

    using NonlinearOptimizationTestFunctions
    using Optim
    using Base.MPFR

    setprecision(BigFloat, 256)

    tf = WAYBURNSEADER1_FUNCTION
    x0 = BigFloat[0, 0]
    options = Optim.Options(g_tol=BigFloat(1e-100))
    result = optimize(tf.f, tf.gradient!, x0, LBFGS(), options)
    println(Optim.minimizer(result))
    println(Optim.minimum(result))  

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
- **partially differentiable**: The gradient exists almost everywhere in the domain, but the function has isolated points, edges, or lower-dimensional sets where it is not differentiable (e.g. due to absolute values, floor, sign, max, or piecewise definitions).  
  **Important note**: This tag follows a long-standing **convention in the global optimization and benchmarking community** (used in CEC, BBOB, CUTEst, MORÉ, al-roomi.org, Jamil & Yang 2013, etc.) and **does NOT correspond to the strict mathematical definition** from multivariate analysis (where “partially differentiable” only means that all partial derivatives exist). In test function suites, the label is deliberately pragmatic: it signals that gradient-based methods will work on most of the domain but may fail or require subgradients at certain locations (typical examples: Step functions, Tripod, Xin-She-Yang, many functions with |⋅| terms).
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