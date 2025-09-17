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
Prints the dimension of the Himmelblau test function using get_n, demonstrating how to access a specific function's dimension from TEST_FUNCTIONS.

    using NonlinearOptimizationTestFunctions

    # Print dimension of Himmelblau function
    function get_himmelblau_dimension()
        # Access Himmelblau function from TEST_FUNCTIONS (a Dict{String, TestFunction})
        tf = TEST_FUNCTIONS["himmelblau"]
        
        # Get dimension using get_n:
        # 1. Checks if 'scalable' is in tf.meta[:properties]
        # 2. Returns -1 for scalable functions
        # 3. For non-scalable (like Himmelblau), returns length(tf.meta[:min_position]())
        # 4. Throws ArgumentError if :min_position fails
        dim = get_n(tf)
        
        println("Dimension of Himmelblau function: $dim")
    end #function

    # Run the function
    get_himmelblau_dimension()

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

    using NonlinearOptimizationTestFunctions, Optim
    tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
    n = 2
    result_gd = optimize(tf.f, tf.gradient!, start(tf, n), GradientDescent(), Optim.Options(f_reltol=1e-6))
    result_lbfgs = optimize(tf.f, tf.gradient!, start(tf, n), LBFGS(), Optim.Options(f_reltol=1e-6))
    println("Gradient Descent on $(name(tf)): $(Optim.minimizer(result_gd)), $(Optim.minimum(result_gd))")
    println("L-BFGS on $(name(tf)): $(Optim.minimizer(result_lbfgs)), $(Optim.minimum(result_lbfgs))")

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
Optimizes all test functions using Optim.jl's L-BFGS algorithm, demonstrating batch processing of test functions.

    using NonlinearOptimizationTestFunctions, Optim
    n = 2
    for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
        result = optimize(tf.f, tf.gradient!, start(tf, n), LBFGS(), Optim.Options(f_reltol=1e-6))
        println("$(name(tf)): $(Optim.minimizer(result)), $(Optim.minimum(result))")
    end #for

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

1. **ackley** [Molga & Smutnicki (2005):2.9]: bounded, continuous, differentiable, multimodal, non-convex, non-separable, scalable. Minimum: 0 at (0, 0). Bounds: [(-5, -5), (5, 5)]. Dimensions: Any n >= 1.
2. **ackley2** [Jamil & Yang (2013):f2]: bounded, continuous, differentiable, unimodal, non-convex, non-separable. Minimum: -200 at (0, 0). Bounds: [(-32, -32), (32, 32)]. Dimensions: n=2.
3. **adjiman** [Jamil & Yang (2013):f5]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -2.02180678 at (2, 0.10578347). Bounds: [(-1, -1), (2, 1)]. Dimensions: n=2.
4. **alpinen1** [Jamil & Yang (2013):f6]: bounded, continuous, multimodal, non-convex, separable, partially differentiable, scalable. Minimum: 0 at (0, 0, ..., 0). Bounds: [(-10, -10), (10, 10)]. Dimensions: Any n >= 1.
5. **alpinen2** [Jamil & Yang (2013):f7]: bounded, continuous, differentiable, multimodal, non-convex, separable, scalable. Minimum: -2.8081311800070053^n at (7.917052698245946, ..., 7.917052698245946). Bounds: [(0, 0), (10, 10)]. Dimensions: Any n >= 1.
6. **axisparallelhyperellipsoid** [Molga & Smutnicki (2005):2.2]: continuous, convex, differentiable, scalable, separable. Minimum: 0 at (0, 0). Bounds: [(-Inf, -Inf), (Inf, Inf)]. Dimensions: Any n >= 1.
7. **bartelsconn** [Jamil & Yang (2013):f9]: bounded, continuous, multimodal, non-convex, non-separable, partially differentiable. Minimum: 1 at (0, 0). Bounds: [(-500, -500), (500, 500)]. Dimensions: n=2.
8. **beale** [Jamil & Yang (2013):f10]: bounded, continuous, differentiable, non-convex, non-separable, unimodal. Minimum: 0 at (3, 0.5). Bounds: [(-4.5, -4.5), (4.5, 4.5)]. Dimensions: n=2.
9. **bird** [Jamil & Yang (2013):f16]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -106.76453672 at (4.70105582, 3.15294602). Bounds: [(-6.28318531, -6.28318531), (6.28318531, 6.28318531)]. Dimensions: n=2.
10. **bohachevsky** [Jamil & Yang (2013):f17]: bounded, continuous, differentiable, multimodal, non-convex, scalable. Minimum: 0 at (0, 0). Bounds: [(-10, -10), (10, 10)]. Dimensions: Any n >= 1.
11. **bohachevsky2** [Jamil & Yang (2013): f18]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (0, 0). Bounds: [-100, 100]^2. Dimensions: n=2.
12. **booth** [Jamil & Yang (2013):f20]: bounded, continuous, convex, differentiable, separable, unimodal. Minimum: 0 at (1, 3). Bounds: [(-10, -10), (10, 10)]. Dimensions: n=2.
13. **boxbetts** [Jamil & Yang (2013): f21]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 10, 1). Bounds: [0.9, 1.2] x [9, 11.2] x [0.9, 1.2]. Dimensions: n=3.
14. **branin** [Molga & Smutnicki (2005):2.12]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: 0.397887 at (-3.14159265, 12.275). Bounds: [(-5, 0), (10, 15)]. Dimensions: n=2.
15. **brown** [Jamil & Yang (2013): f25]: Unimodal, non-separable, differentiable, scalable, continuous, bounded. Minimum: 0 at (0, ..., 0). Bounds: [-1, 4]^n. Dimensions: Any n >= 2.
16. **brent** [Jamil & Yang (2013): f24]: Unimodal, non-convex, non-separable, differentiable. Minimum: 0 at (0, 0). Bounds: [-10, 10]^2. Dimensions: n=2.
17. **bukin2** [Jamil & Yang (2013): f26]: bounded, Multimodal, differentiable. Minimum: 0 at (-10, 0). Bounds: [-15, -5] x [-3, 3]. Dimensions: n=2.
18. **bukin4** [Jamil & Yang (2013): f27], [Naser et al. (2024): 4.39]: Multimodal, non-convex, separable, partially differentiable, bounded, continuous. Minimum: 0 at (-10, 0). Bounds: [-15, -5] × [-3, 3]. Dimensions: n=2.
19. **bukin6** [Jamil & Yang (2013):f28]: bounded, continuous, multimodal, non-convex, partially differentiable. Minimum: 0 at (-10, 1). Bounds: [(-15, -3), (-5, 3)]. Dimensions: n=2.
20. **carromTable** [Jamil & Yang (2013): f146]: Multimodal, non-convex, non-separable, differentiable. Minimum: -24.1568155165 at (±9.646157266348881,±9.646134286497169). Bounds: [-10,10]^2. Dimensions: n=2.
21. **colville** [Jamil & Yang (2013): f36]: Unimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1,1,1,1). Bounds: [-10,10]^4. Dimensions: n=4.
22. **chen** [Jamil & Yang (2013): f311. **Chen V** [Naser et al. (2024)], [al-roomi.org]: Multimodal, non-convex, non-separable, differentiable, bounded, continuous. Minimum: -2000 at (0.388888888888889, 0.722222222222222). Bounds: [-500, 500]^2. Dimensions: n=2.
23. **crossintray** [Jamil & Yang (2013):f39]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -2.06261187 at (1.34940658, 1.34940658). Bounds: [(-10, -10), (10, 10)]. Dimensions: n=2.
24. **dejongf4** [Molga & Smutnicki (2005)]: bounded, continuous, convex, has_noise, partially differentiable, scalable, separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-1.28, -1.28), (1.28, 1.28)]. Dimensions: Any n >= 1.
25. **dejongf5modified** : bounded, continuous, differentiable, finite_at_inf, multimodal, non-convex, non-separable. Minimum: -0.99800384 at (-31.97833, -31.97833). Bounds: [(-65.536, -65.536), (65.536, 65.536)]. Dimensions: n=2.
26. **dejongf5original** [Molga & Smutnicki (2005):2.16]: bounded, continuous, differentiable, finite_at_inf, multimodal, non-convex, non-separable. Minimum: -500.01800977 at (-32, -32). Bounds: [(-65.536, -65.536), (65.536, 65.536)]. Dimensions: n=2.
27. **dekkersaarts** [Jamil & Yang (2013):f90]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -24776.51834232 at (0, 14.94511215). Bounds: [(-20, -20), (20, 20)]. Dimensions: n=2.
28. **dixonprice** [Molga & Smutnicki (2005)]: bounded, continuous, differentiable, non-convex, scalable, unimodal. Minimum: 0 at (1, 0.70710678). Bounds: [(-10, -10), (10, 10)]. Dimensions: Any n >= 1.
29. **dropwave** [Molga & Smutnicki (2005):2.17]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -1 at (0, 0). Bounds: [(-5.12, -5.12), (5.12, 5.12)]. Dimensions: n=2.
30. **easom** [Molga & Smutnicki (2005):2.13]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -1 at (3.14159265, 3.14159265). Bounds: [(-100, -100), (100, 100)]. Dimensions: n=2.
31. **eggholder** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -959.64066272 at (512, 404.2318058). Bounds: [(-512, -512), (512, 512)]. Dimensions: n=2.
32. **freudensteinroth** [Jamil & Yang (2013): f56]: Multimodal, non-convex, non-separable, differentiable, bounded, continuous. Minimum: 0.0 at (5.0, 4.0). Bounds: [-10, 10]^2. Dimensions: n=2.
33. **giunta** [Jamil & Yang (2013):f57]: bounded, continuous, differentiable, multimodal, non-convex, separable. Minimum: 0.06447042 at (0.46732003, 0.46732003). Bounds: [(-1, -1), (1, 1)]. Dimensions: n=2.
34. **goldsteinprice** [Molga & Smutnicki (2005):2.14]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: 3 at (0, -1). Bounds: [(-2, -2), (2, 2)]. Dimensions: n=2.
35. **griewank** [Molga & Smutnicki (2005):2.7]: bounded, continuous, differentiable, multimodal, scalable, separable. Minimum: 0 at (0, 0). Bounds: [(-600, -600), (600, 600)]. Dimensions: Any n >= 1.
36. **hartmanf3** [Jamil & Yang (2013):f62]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -3.86278215 at (0.11461434, 0.55564885, 0.85254695). Bounds: [(0, 0, 0), (1, 1, 1)]. Dimensions: n=3.
37. **himmelblau** [Jamil & Yang (2013):f65]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: 0 at (3, 2). Bounds: [(-5, -5), (5, 5)]. Dimensions: n=2.
38. **holdertable** [Jamil & Yang (2013):f146]: bounded, continuous, differentiable, multimodal, non-convex, separable. Minimum: -19.20850257 at (8.055023, 9.66459). Bounds: [(-10, -10), (10, 10)]. Dimensions: n=2.
39. **keane** [Jamil & Yang (2013):f69]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -0.67366752 at (0, 1.39324907). Bounds: [(0, 0), (10, 10)]. Dimensions: n=2.
40. **kearfott** [Unknown Source]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: 0 at (1.22474487, 0.70710678). Bounds: [(-3, -3), (4, 4)]. Dimensions: n=2.
41. **langermann** [Molga & Smutnicki (2005):2.10]: bounded, continuous, controversial, differentiable, multimodal, non-convex, non-separable. Minimum: -5.16212616 at (2.00299212, 1.00609594). Bounds: [(0, 0), (10, 10)]. Dimensions: n=2.
42. **levy** [Molga & Smutnicki (2005)]: bounded, continuous, differentiable, multimodal, non-convex, scalable. Minimum: 0 at (1, 1). Bounds: [(-10, -10), (10, 10)]. Dimensions: Any n >= 1.
43. **matyas** [Molga & Smutnicki (2005)]: bounded, continuous, convex, differentiable, non-separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-10, -10), (10, 10)]. Dimensions: n=2.
44. **mccormick** [Molga & Smutnicki (2005)]: bounded, continuous, differentiable, multimodal, non-convex. Minimum: -1.91322295 at (-0.54719755, -1.54719755). Bounds: [(-1.5, -3), (4, 4)]. Dimensions: n=2.
45. **michalewicz** [Molga & Smutnicki (2005):2.11]: bounded, continuous, differentiable, multimodal, non-separable, scalable. Minimum: -1.8013 at (2.20290552, 1.57079633). Bounds: [(0, 0), (3.14159265, 3.14159265)]. Dimensions: Any n >= 1.
46. **mishrabird** [Jamil & Yang (2013)]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -106.764537 at (-3.1302468, -1.5821422). Bounds: [(-10, -6.5), (0, 0)]. Dimensions: n=2.
47. **powell** [Jamil & Yang (2013): f91]: Unimodal, non-convex, non-separable, differentiable. Minimum: 0 at (0,0,0,0). Bounds: [-4,5]^4. Dimensions: n=4.
48. **quadratic** [Jamil & Yang (2013):f99]: continuous, convex, differentiable, non-separable, scalable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-Inf, -Inf), (Inf, Inf)]. Dimensions: Any n >= 1.
49. **rana** [Molga & Smutnicki (2005)]: bounded, continuous, multimodal, non-separable, partially differentiable. Minimum: -498.12463265 at (-500, -499.07331509). Bounds: [(-500, -500), (500, 500)]. Dimensions: n=2.
50. **rastrigin** [Molga & Smutnicki (2005):2.5]: bounded, continuous, differentiable, multimodal, non-convex, scalable, separable. Minimum: 0 at (0, 0). Bounds: [(-5.12, -5.12), (5.12, 5.12)]. Dimensions: Any n >= 1.
51. **rosenbrock** [Molga & Smutnicki (2005):2.4]: bounded, continuous, differentiable, non-convex, non-separable, unimodal. Minimum: 0 at (1, 1). Bounds: [(-5, -5), (5, 5)]. Dimensions: n=2.
52. **rotatedhyperellipsoid** [Molga & Smutnicki (2005):2.3]: bounded, continuous, convex, differentiable, non-separable, scalable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-65.536, -65.536), (65.536, 65.536)]. Dimensions: Any n >= 1.
53. **schaffern1** [Jamil & Yang (2013):f112]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: n=2.
54. **schaffern2** [Jamil & Yang (2013):f113]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: 0 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: n=2.
55. **schaffern4** [Jamil & Yang (2013):f115]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: 0.29257863 at (0, 1.25313183). Bounds: [(-100, -100), (100, 100)]. Dimensions: n=2.
56. **schwefel** [Molga & Smutnicki (2005):2.6]: bounded, continuous, differentiable, multimodal, non-convex, scalable, separable. Minimum: 0 at (420.96874632, 420.96874632). Bounds: [(-500, -500), (500, 500)]. Dimensions: Any n >= 1.
57. **shekel** [Molga & Smutnicki (2005):2.19]: bounded, continuous, differentiable, finite_at_inf, multimodal, non-convex, non-separable. Minimum: -10.53640982 at (4.00074653, 4.00059293, 3.9996634, 3.9995098). Bounds: [(0, 0, 0, 0), (10, 10, 10, 10)]. Dimensions: n=4.
58. **shubert** [Molga & Smutnicki (2005):2.18]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -186.7309 at (-1.42512843, -0.8003211). Bounds: [(-10, -10), (10, 10)]. Dimensions: n=2.
59. **sineenvelope** [Molga & Smutnicki (2005)]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -1 at (0, 0). Bounds: [(-100, -100), (100, 100)]. Dimensions: n=2.
60. **sixhumpcamelback** [Molga & Smutnicki (2005):2.15]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: -1.03162845 at (-0.08984201, 0.7126564). Bounds: [(-3, -2), (3, 2)]. Dimensions: n=2.
61. **sphere** [Molga & Smutnicki (2005):2.1]: bounded, continuous, convex, differentiable, scalable, separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-5.12, -5.12), (5.12, 5.12)]. Dimensions: Any n >= 1.
62. **step** [Jamil & Yang (2013):f137]: bounded, non-convex, partially differentiable, scalable, separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-5.12, -5.12), (5.12, 5.12)]. Dimensions: Any n >= 1.
63. **styblinskitang** [Naser (2024):4.270]: bounded, continuous, differentiable, multimodal, non-convex, scalable. Minimum: -78.33233 at (-2.903534, -2.903534). Bounds: [(-5, -5), (5, 5)]. Dimensions: Any n >= 1.
64. **sumofpowers** [Molga & Smutnicki (2005):2.8]: bounded, continuous, convex, differentiable, scalable, separable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-1, -1), (1, 1)]. Dimensions: Any n >= 1.
65. **threehumpcamel** [Jamil & Yang (2013):f29]: bounded, continuous, differentiable, multimodal, non-convex, non-separable. Minimum: 0 at (0, 0). Bounds: [(-5, -5), (5, 5)]. Dimensions: n=2.
66. **trid** [Jamil & Yang (2013):f150,f151]: bounded, continuous, convex, differentiable, non-separable, scalable, unimodal. Minimum: -2 at (2, 2). Bounds: [(-4, -4), (4, 4)]. Dimensions: Any n >= 1.
67. **wood** [Jamil & Yang (2013):f121]: bounded, continuous, differentiable, non-convex, non-separable, unimodal. Minimum: 0 at (1, 1, 1, 1). Bounds: [(-10, -10, -10, -10), (10, 10, 10, 10)]. Dimensions: n=4.
68. **zakharov** [Naser (2024):4.311]: bounded, continuous, convex, differentiable, non-separable, scalable, unimodal. Minimum: 0 at (0, 0). Bounds: [(-5, -5), (10, 10)]. Dimensions: Any n >= 1.

## Upcoming Test Functions

The following test functions are planned for implementation, based on standard benchmarks. They will be added with analytical gradients, metadata, and validation, consistent with the existing collection.

1. **Chichinadze** [Jamil & Yang (2013): f33]: Multimodal, non-convex, non-separable, differentiable. Minimum: -43.3159 at (5.90133, 0.5). Bounds: [-30,30]^2. Dimensions: n=2.
2. **CosineMixture** [Jamil & Yang (2013): f38]: Multimodal, non-convex, separable, differentiable, scalable. Minimum: -0.1*n at multiple. Bounds: [-1,1]^n. Dimensions: Any n >=1.
3. **Corana** [Jamil & Yang (2013): f37]: Multimodal, non-convex, separable, differentiable. Minimum: 0 at (0,0,0,0). Bounds: [-1000,1000]^4. Dimensions: n=4.
4. **Csendes** [Jamil & Yang (2013): f40]: Unimodal, non-convex, separable, non-differentiable at 0, scalable. Minimum: 0 at (0,0,...,0). Bounds: [-1,1]^n. Dimensions: Any n >=1.
5. **Cube** [Jamil & Yang (2013): f41]: Unimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1,1,1). Bounds: [-10,10]^3. Dimensions: n=3.
6. **Damavandi** [Jamil & Yang (2013): f42]: Multimodal, non-convex, non-separable, non-differentiable. Minimum: 0 at (2,2). Bounds: [0,14]^2. Dimensions: n=2.
7. **Ackley 4** [Jamil & Yang (2013): f4]: Multimodal, non-convex, non-separable, differentiable, scalable. Minimum: -3.917275 at {-1.479, -0.740} and {1.479, -0.740}. Bounds: [-35, 35]^n. Dimensions: any n.
8. **Adjiman** [Jamil & Yang (2013): f5]: Multimodal, non-convex, non-separable, differentiable. Minimum: -2.02181 at (2, 0.10578). Bounds: [-1, 2] x [-1, 1]. Dimensions: n=2.
9. **Brad** [Jamil & Yang (2013): f8]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0.00821487 at (0.0824, 1.133, 2.3437). Bounds: [-0.25, 0.25] x [0.01, 2.5] x [0.01, 2.5]. Dimensions: n=3.
10. **Biggs EXP2** [Jamil & Yang (2013): f11]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 10). Bounds: [0, 20]^2. Dimensions: n=2.
11. **Biggs EXP3** [Jamil & Yang (2013): f12]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 10, 5). Bounds: [0, 20]^3. Dimensions: n=3.
12. **Biggs EXP4** [Jamil & Yang (2013): f13]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 10, 1, 5). Bounds: [0, 20]^4. Dimensions: n=4.
13. **Biggs EXP5** [Jamil & Yang (2013): f14]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 10, 1, 5, 4). Bounds: [0, 20]^5. Dimensions: n=5.
14. **Biggs EXP6** [Jamil & Yang (2013): f15]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 10, 1, 5, 4, 3). Bounds: [-20, 20]^6. Dimensions: n=6.
15. **Bohachevsky 3** [Jamil & Yang (2013): f19]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (0, 0). Bounds: [-100, 100]^2. Dimensions: n=2.
16. **Branin RCOS 2** [Jamil & Yang (2013): f23]: Multimodal, non-convex, non-separable, differentiable. Minimum: 5.559037 at (-3.2, 12.53). Bounds: [-5, 15]^2. Dimensions: n=2.
17. **Chung Reynolds** [Jamil & Yang (2013): f34]: Unimodal, convex, partially-separable, differentiable, scalable. Minimum: 0 at (0, ..., 0). Bounds: [-100, 100]^n. Dimensions: any n.
18. **Cola** [Jamil & Yang (2013): f35]: Multimodal, non-convex, non-separable, differentiable. Minimum: 11.7464. Bounds: [0, 4] x [-4, 4]^16. Dimensions: n=17.
19. **Deb 1** [Jamil & Yang (2013): f43]: Multimodal, non-convex, separable, differentiable, scalable. Minimum: -1. Bounds: [-1, 1]^n. Dimensions: any n.
20. **deVilliers Glasser 1** [Jamil & Yang (2013): f46]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0. Bounds: [-500, 500]^4. Dimensions: n=4.
21. **deVilliers Glasser 2** [Jamil & Yang (2013): f47]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0. Bounds: [-500, 500]^5. Dimensions: n=5.
22. **Dolan** [Jamil & Yang (2013): f49]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0. Bounds: [-100, 100]^5. Dimensions: n=5.
23. **El-Attar-Vidyasagar-Dutta** [Jamil & Yang (2013): f51]: Unimodal, non-convex, non-separable, differentiable. Minimum: 0.470427 at (2.8425, 1.9202). Bounds: [-500, 500]^2. Dimensions: n=2.
24. **Egg Crate** [Jamil & Yang (2013): f52]: Multimodal, non-convex, separable, differentiable. Minimum: 0 at (0, 0). Bounds: [-5, 5]^2. Dimensions: n=2.
25. **Exponential** [Jamil & Yang (2013): f54]: Multimodal, non-convex, non-separable, differentiable, scalable. Minimum: 1 at (0, ..., 0). Bounds: [-1, 1]^n. Dimensions: any n.
26. **EX Function 1** [Jamil & Yang (2013): f55]: Multimodal, non-convex, separable, differentiable. Minimum: -1.28186 at (1.764, 11.150). Bounds: [0, 2] x [10, 12]. Dimensions: n=2.
27. **Gulf Research** [Jamil & Yang (2013): f60]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (50, 25, 1.5). Bounds: [0.1, 100] x [0, 25.6] x [0, 5]. Dimensions: n=3.
28. **Hansen** [Jamil & Yang (2013): f61]: Multimodal, non-convex, separable, differentiable. Multiple global minima. Bounds: [-10, 10]^2. Dimensions: n=2.
29. **Helical Valley** [Jamil & Yang (2013): f64]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 0, 0). Bounds: [-10, 10]^3. Dimensions: n=3.
30. **Hosaki** [Jamil & Yang (2013): f66]: Multimodal, non-convex, non-separable, differentiable. Minimum: -2.3458 at (4, 2). Bounds: [0, 5] x [0, 6]. Dimensions: n=2.
31. **Jennrich-Sampson** [Jamil & Yang (2013): f67]: Multimodal, non-convex, non-separable, differentiable. Minimum: 124.3612 at (0.2578, 0.2578). Bounds: [-1, 1]^2. Dimensions: n=2.
32. **Leon** [Jamil & Yang (2013): f70]: Unimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 1). Bounds: [-1.2, 1.2]^2. Dimensions: n=2.
33. **Miele Cantrell** [Jamil & Yang (2013): f73]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (0, 1, 1, 1). Bounds: [-1, 1]^4. Dimensions: n=4.
34. **Mishra 1** [Jamil & Yang (2013): f74]: Multimodal, non-convex, non-separable, differentiable, scalable. Minimum: 2. Bounds: [0, 1]^n. Dimensions: any n.
35. **Mishra 3** [Jamil & Yang (2013): f76]: Multimodal, non-convex, non-separable, differentiable. Minimum: -0.18467 at (-8.466, -10). Bounds: not specified. Dimensions: n=2.
36. **Mishra 4** [Jamil & Yang (2013): f77]: Multimodal, non-convex, non-separable, differentiable. Minimum: -0.199409 at (-9.94112, -10). Bounds: not specified. Dimensions: n=2.
37. **Mishra 5** [Jamil & Yang (2013): f78]: Multimodal, non-convex, non-separable, differentiable. Minimum: -1.01983 at (-1.98682, -10). Bounds: not specified. Dimensions: n=2.
38. **Mishra 6** [Jamil & Yang (2013): f79]: Multimodal, non-convex, non-separable, differentiable. Minimum: -2.28395 at (2.88631, 1.82326). Bounds: not specified. Dimensions: n=2.
39. **Mishra 7** [Jamil & Yang (2013): f80]: Multimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0. Bounds: not specified. Dimensions: any n.
40. **Mishra 8** [Jamil & Yang (2013): f81]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (2, -3). Bounds: not specified. Dimensions: n=2.
41. **Mishra 9** [Jamil & Yang (2013): f82]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (1, 2, 3). Bounds: not specified. Dimensions: n=3.
42. **Mishra 10** [Jamil & Yang (2013): f83]: Multimodal, non-convex, non-separable, differentiable. Minimum: 0 at (0,0) or (2,2). Bounds: not specified. Dimensions: n=2.
43. **Mishra 11** [Jamil & Yang (2013): f84]: Multimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0. Bounds: not specified. Dimensions: any n.
44. **Parsopoulos** [Jamil & Yang (2013): f85]: Multimodal, non-convex, separable, differentiable. Minimum: 0 at multiple points. Bounds: [-5, 5]^2. Dimensions: n=2.
45. **Pen Holder** [Jamil & Yang (2013): f86]: Multimodal, non-convex, non-separable, differentiable. Minimum: -0.96354 at (±9.646, ±9.646). Bounds: [-11, 11]^2. Dimensions: n=2.
46. **Pathological** [Jamil & Yang (2013): f87]: Multimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0 at (0, ..., 0). Bounds: [-100, 100]^n. Dimensions: any n.
47. **Pintér** [Jamil & Yang (2013): f89]: Multimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0 at (0, ..., 0). Bounds: [-10, 10]^n. Dimensions: any n.
48. **Periodic** [Jamil & Yang (2013): f90]: Multimodal, non-convex, separable, differentiable. Minimum: 0.9 at (0, 0). Bounds: [-10, 10]^2. Dimensions: n=2.
49. **Perm**: Unimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0 at (1,1/2,1/3,...,1/n). Bounds: [-n, n]^n. Dimensions: Any n >=1.
50. **Cigar**: Unimodal, convex, non-separable, differentiable, scalable. Minimum: 0 at (0,0,...,0). Bounds: [-10,10]^n. Dimensions: Any n >=2.

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
- **axisparallelhyperellipsoid**: Axis parallel hyper-ellipsoid function, Sum squares function, Weighted sphere model, Quadratic function (axis-aligned variant).
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
- **rotatedhyperellipsoid**: Rotated Hyper-Ellipsoid function, Schwefel's function 1.2, Extended sum squares function, Extended Rosenbrock function (in some contexts).
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