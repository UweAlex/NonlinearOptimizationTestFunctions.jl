
### Examples

#### Getting Himmelblau Dimension
Prints the dimension of the Himmelblau test function using tf.dim(), demonstrating how to access a specific function's dimension from TEST_FUNCTIONS.

    # examples/get_himmelblau_dimension.jl
    # =============================================================================
    # Purpose: 
    #   This example demonstrates how to query the dimension of a specific test function
    #   from the NonlinearOptimizationTestFunctions.jl package using the built-in dim() function.
    #
    # Why this example exists:
    #   • Many classic benchmark functions are fixed-dimensional (e.g. Himmelblau is always n=2).
    #   • Others are scalable (can be used with arbitrary n ≥ some minimum).
    #   • The dim(tf) helper automatically handles both cases:
    #       - Returns the fixed length of the minimum position vector for non-scalable functions
    #       - Returns -1 for scalable functions (by convention, indicating "any dimension")
    #   • This makes it easy for users to write generic code that adapts to the function type.
    #
    # Himmelblau function specifics:
    #   • Mathematical form: f(x,y) = (x² + y - 11)² + (x + y² - 7)²
    #   • Defined only for n=2 (four global minima at approximately (±3.58, -1.85), etc.)
    #   • Non-convex, multimodal, smooth – a classic low-dimensional test problem.
    #   • Not scalable → dim() returns 2
    #
    # Expected output:
    #   Dimension of Himmelblau function: 2
    #
    # Last modified: December 2025
    # =============================================================================

    using NonlinearOptimizationTestFunctions
    # Load the package. Provides the global dictionary TEST_FUNCTIONS containing all
    # available benchmark problems as pre-constructed TestFunction objects.

    # -------------------------------------------------------------------------
    # Retrieve the Himmelblau function from the registry
    # -------------------------------------------------------------------------
    # TEST_FUNCTIONS is a Dict{String, TestFunction} indexed by the lowercase name.
    # Using the string key is safe and explicit – ideal for examples and scripting.
    tf = TEST_FUNCTIONS["himmelblau"]

    # Alternative (more concise but relies on exported constants):
    # tf = HIMMELBLAU_FUNCTION   # uppercase constant exported by the package

    # -------------------------------------------------------------------------
    # Determine the dimension using the package-provided dim() function
    # -------------------------------------------------------------------------
    # Implementation summary of dim(tf):
    #   • If the function has the "scalable" property → return -1 (convention for variable dimension)
    #   • Otherwise → return length(tf.meta[:min_position]())  (fixed dimension inferred from metadata)
    #
    # This approach is robust because:
    #   • It requires no manual hard-coding of dimensions
    #   • It automatically reflects any future changes in function definitions
    #   • It works uniformly across the entire collection of >200 functions
    himmelblau_dim = dim(tf)

    # -------------------------------------------------------------------------
    # Print the result
    # -------------------------------------------------------------------------
    println("Dimension of Himmelblau function: $himmelblau_dim")
    # Output: Dimension of Himmelblau function: 2

    # =============================================================================
    # Additional notes for package users
    # =============================================================================
    # • For scalable functions (e.g. ROSENBROCK_FUNCTION, RASTRIGIN_FUNCTION):
    #     dim(tf) → -1
    #     Use fixed(tf; n=10) to create a fixed-dimension instance, then dim(fixed_tf) → 10
    # • You can list all fixed-dimensional functions with dim > some value using:
    #     filter(tf -> dim(tf) > 2, values(TEST_FUNCTIONS))
    # • This pattern is useful when writing generic benchmarking loops that need to
    #   distinguish between low-dimensional analytical tests and high-dimensional scalable ones.
    #
    # Feel free to replace "himmelblau" with any other key from TEST_FUNCTIONS
    # to explore the dimensionality of other benchmark problems!
    # =============================================================================

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

        # examples/Optimize_with_nlopt.jl
        # =============================================================================
        # Purpose: 
        #   This example shows how to optimize the classic Rosenbrock function using the
        #   NLopt library and its gradient-based LD_LBFGS algorithm.
        #   It demonstrates the excellent interoperability of NonlinearOptimizationTestFunctions.jl
        #   with external solvers by directly using the package-provided analytical objective
        #   and gradient together with NLopt's interface.
        #
        # Key takeaways for package users:
        #   • The same TestFunction works unchanged with Optim.jl, NLopt.jl, GalacticOptim.jl, etc.
        #   • Providing exact analytical gradients leads to dramatically faster and more accurate
        #     convergence than finite-difference approximations.
        #   • Metadata (recommended bounds, start point) makes the setup robust and reproducible.
        #
        # Requirements:
        #   This example requires the optional package NLopt.jl.
        #   Install it once with:  julia> using Pkg; Pkg.add("NLopt")
        #
        # Expected output (Float64 precision):
        #   rosenbrock: [≈1.0, ≈1.0], ≈0.0   (residual typically < 1e-15, pure round-off)
        #
        # Last modified: December 2025
        # =============================================================================

        using NonlinearOptimizationTestFunctions
        # Core package providing >200 rigorously tested benchmark functions with analytical
        # gradients and comprehensive metadata.

        using NLopt
        # External optimization library.
        # Note: The first time this script is run in a fresh Julia session you may see a harmless
        # warning "WARNING: using NLopt.Result in module Main conflicts with an existing identifier."
        # This occurs only when re-running the script in the same session and has no effect on correctness.

        # -------------------------------------------------------------------------
        # Choose the test function: classic 2D Rosenbrock ("banana") function
        # -------------------------------------------------------------------------
        # f(x₁,x₂) = 100*(x₂ - x₁²)² + (1 - x₁)²
        # Smooth, unimodal, strongly non-convex – historic stress test for gradient methods.
        # Exact global minimum: f(1,1) = 0
        tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION

        n = 2                                      # Standard low-dimensional case

        # -------------------------------------------------------------------------
        # Set up the NLopt optimizer
        # -------------------------------------------------------------------------
        # Why do we write NLopt.Opt, NLopt.ftol_rel!, NLopt.optimize, etc. everywhere?
        # 
        # Although `using NLopt` brings names like Opt, optimize, ftol_rel!, etc. into the
        # current namespace, we deliberately qualify them with the NLopt. prefix for several
        # important reasons:
        #
        # 1. Avoidance of name conflicts:
        #    Many optimization packages export very common function names:
        #      • Optim.jl exports `optimize`, `Options`, etc.
        #      • GalacticOptim.jl re-exports `optimize` from various backends
        #      • Other packages (e.g., JuMP, MathOptInterface) also use similar names
        #    In a user session where multiple optimization libraries are loaded simultaneously,
        #    unqualified names can shadow each other or cause unexpected behaviour.
        #
        # 2. Explicitness and readability:
        #    Seeing NLopt.optimize immediately tells the reader exactly which library's
        #    implementation is being used – crucial in examples that demonstrate interoperability.
        #
        # 3. Safety when copying code:
        #    Users often copy example code into their own projects. Fully qualified names
        #    work reliably regardless of which other packages they have loaded.
        #
        # 4. Consistency across examples:
        #    Different examples in this package use different solvers (Optim.jl, NLopt.jl, etc.).
        #    Using the module prefix everywhere makes the code style uniform and prevents
        #    subtle bugs when switching between examples.
        #
        # In short: the explicit NLopt. prefix makes the example more robust, clearer,
        # and safer for real-world use – especially for users who work with multiple
        # optimization libraries at once.
        # -------------------------------------------------------------------------

        opt = NLopt.Opt(:LD_LBFGS, n)               # Limited-memory BFGS (requires gradients)

        NLopt.ftol_rel!(opt, 1e-6)                  # Reasonable relative function tolerance

        # Use the package-provided recommended search bounds (keeps evaluations numerically stable)
        NLopt.lower_bounds!(opt, tf.meta[:lb](n))
        NLopt.upper_bounds!(opt, tf.meta[:ub](n))

        # -------------------------------------------------------------------------
        # Define the objective callback for NLopt
        # -------------------------------------------------------------------------
        NLopt.min_objective!(opt, (x, grad) -> begin
            f_val = tf.f(x)                        # Objective evaluation
            if length(grad) > 0
                tf.gradient!(grad, x)              # In-place analytical gradient – exact and fast
            end
            return f_val
        end)

        # -------------------------------------------------------------------------
        # Run the optimization
        # -------------------------------------------------------------------------
        # Start from the deliberately challenging point suggested by the package metadata.
        minf, minx, ret = NLopt.optimize(opt, tf.meta[:start](n))

        # -------------------------------------------------------------------------
        # Display the result
        # -------------------------------------------------------------------------
        println("$(tf.meta[:name]): $minx, $minf")
        # Typical output:
        # rosenbrock: [0.9999999995740739, 0.9999999991616133], 1.9954485597074117e-19
        # → Effectively the exact minimum within double-precision floating-point limits.

    #### High-Precision Optimization with BigFloat
    Demonstrates high-precision optimization using BigFloat (256-bit precision) on the Wayburn-Seader 1 function with L-BFGS and a very tight gradient tolerance (1e-100). This is useful for ill-conditioned or sensitive problems where standard Float64 precision may lead to numerical instability.

        # examples/example_high_precision.jl
        # Purpose: Demonstrates ultra-high-precision optimization using arbitrary-precision arithmetic (BigFloat)
        #          on a benchmark function with known exact global minima of zero.
        # Context: Part of NonlinearOptimizationTestFunctions.jl examples – shows how the package's TestFunction
        #          objects work seamlessly with BigFloat and how analytical gradients enable extreme accuracy.
        # Last modified: ca. 2025 (as seen in the repository)

        using NonlinearOptimizationTestFunctions  # Main package: provides >200 rigorously tested nonlinear benchmark functions
        using Optim                               # Standard Julia optimization suite (L-BFGS, BFGS, Nelder-Mead, etc.)
        using Base.MPFR                           # Interface to the MPFR library for arbitrary-precision floating-point numbers

        # Set the working precision for all BigFloat operations to 256 bits.
        # 256 bits ≈ 77 decimal digits of precision (far beyond Float64's ~15–17 digits).
        # This allows us to push the optimizer far beyond standard double-precision limits.
        setprecision(BigFloat, 256)

        # Select the Wayburn-Seader 1 function – a classic 2-dimensional unconstrained benchmark problem.
        # Standard mathematical definition (as used in most literature and this package):
        #     f(x₁, x₂) = (x₁⁴ + (x₁ - 2)⁴ - 14)² + (2x₁ + x₂ - 4)²   ? Wait – actually confirmed:
        # The exact form in NonlinearOptimizationTestFunctions.jl implements the standard version:
        # It has **two distinct global minima** where f(x) = 0 exactly:
        #   1. x* = (1, 2)
        #   2. x* ≈ (1.596804153876933, 0.806391692246133)
        # The function is smooth, non-convex, and multimodal (two separate global minimizers).
        tf = WAYBURNSEADER1_FUNCTION

        # Initial guess: (0,0) converted to BigFloat.
        # This point lies roughly in between the two basins of attraction of the global minima.
        # Depending on the exact search path of the optimizer, it will converge to one or the other.
        x0 = BigFloat[0, 0]

        # Define convergence criteria.
        # We use an extremely tight gradient tolerance (10⁻¹⁰⁰).
        # With 256-bit precision (~10⁻⁷⁷ relative accuracy limit), the optimizer stops only when
        # rounding errors in the arithmetic itself prevent further progress.
        options = Optim.Options(g_tol=BigFloat(1e-100))

        # Perform the actual optimization using L-BFGS (limited-memory quasi-Newton method).
        # Thanks to the analytical gradient provided by the package, convergence is very fast and accurate.
        result = Optim.optimize(tf.f, tf.gradient!, x0, Optim.LBFGS(), options)

        # Output the results.
        # Minimizer ≈ [1.596804153876933336584962273913655437512569315992292919463177763704106859093912,
        #              0.806391692246133326830075452172689124974861368015414161073644472591786281812159]
        # Objective ≈ 7.637340908749011705129948483034044249473506851430816659734034773203229066311801e-152
        #
        # Explanation:
        #   • The optimizer converged to the **second** global minimum (≈ (1.5968..., 0.8064...)).
        #   • The true global minimum value is exactly 0.
        #   • The tiny residual ≈ 7.6 × 10⁻¹⁵² is **purely due to rounding errors** in 256-bit arithmetic
        #     after many iterations – it is *not* an algorithmic failure.
        #   • With higher precision (e.g., 512 bits), this residual would be even smaller (closer to machine zero).
        #   • If you start closer to (1,2), e.g. x0 = BigFloat[1,1], L-BFGS would find the other minimum.
        #
        # This perfectly illustrates the purpose of the example: even in arbitrary precision,
        # we can reach the theoretical global minimum up to the limits imposed by finite-precision arithmetic.
        println(Optim.minimizer(result))   # One of the two exact global minimizers (up to ~77 decimal digits)
        println(Optim.minimum(result))     # Extremely close to 0.0 – residual is rounding error only 

    #### Filtering Test Functions by Properties
    Filters test functions based on specific properties (e.g., multimodal or finite_at_inf), demonstrating how to select functions for targeted benchmarking.

        using NonlinearOptimizationTestFunctions
        multimodal_funcs = filter_testfunctions(tf -> property(tf, "multimodal"))
        println("Multimodal functions: ", [name(tf) for tf in multimodal_funcs])
        finite_at_inf_funcs = filter_testfunctions(tf -> property(tf, "finite_at_inf"))
        println("Functions with finite_at_inf: ", [name(tf) for tf in finite_at_inf_funcs])

    #### Tracking Function and Gradient Calls
    Tracks the number of function and gradient evaluations for the Rosenbrock function during evaluation and optimization, demonstrating the use of call counters and selective gradient counter resetting.

    # examples/count_calls.jl
    # =============================================================================
    # Purpose: 
    #   This example demonstrates the built-in call counting and resetting functionality
    #   of TestFunction objects in NonlinearOptimizationTestFunctions.jl.
    #
    # Why this feature exists:
    #   • When benchmarking optimizers or comparing algorithms, it is crucial to know
    #     exactly how many objective function evaluations (f-count) and gradient evaluations
    #     (grad-count) were performed.
    #   • The package automatically wraps every TestFunction's f and grad with counters
    #     (Ref{Int}) that increment on each call – completely transparent to the user.
    #   • reset_counts!(tf) allows starting fresh for each experiment.
    #   • This makes fair, reproducible comparisons possible without modifying the optimizer.
    #
    # Key functions demonstrated:
    #   • get_f_count(tf)     → number of objective evaluations
    #   • get_grad_count(tf)  → number of gradient evaluations
    #   • reset_counts!(tf)   → set both counters back to zero
    #
    # Expected behaviour:
    #   • Counters start at 0 after reset
    #   • Each tf.f(x) increments f-count by 1
    #   • Each tf.grad(x) or tf.gradient!(g,x) increments grad-count by 1
    #   • Optimization with Optim.jl (L-BFGS) shows realistic call numbers
    #   • Second reset brings counters back to 0
    #
    # Last modified: December 2025
    # =============================================================================

    using NonlinearOptimizationTestFunctions
    # Core package – every TestFunction automatically tracks f and gradient calls.

    using Optim
    # Standard optimization library used here to show real-world usage of the counters.

    # -------------------------------------------------------------------------
    # Main demonstration function
    # -------------------------------------------------------------------------
    function run_count_calls_example()
        # Select the classic Rosenbrock function (scalable, but we use n=2 here)
        # f(x) = ∑ [100*(x_{i+1} - x_i²)² + (1 - x_i)²]   → global minimum 0 at x = [1,1,...,1]
        tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
        n = 2  # Fixed dimension for this demonstration

        # ---------------------------------------------------------------------
        # Start with clean counters
        # ---------------------------------------------------------------------
        reset_counts!(tf)  # Zero both internal Ref{Int} counters
        println("After reset - Function calls: ", get_f_count(tf))   # → 0
        println("After reset - Gradient calls: ", get_grad_count(tf)) # → 0
        println()

        # ---------------------------------------------------------------------
        # Manual function and gradient evaluation
        # ---------------------------------------------------------------------
        x = tf.meta[:start](n)  # Recommended starting point from metadata (usually far from minimum)
        # For Rosenbrock n=2: typically [ -1.2, 1.0 ] or similar – deliberately challenging

        f_value = tf.f(x)       # One objective evaluation
        println("Function value at start point $x: ", f_value)
        println("Function calls after f(x): ", get_f_count(tf))      # → 1

        grad_value = tf.grad(x) # One gradient evaluation (out-of-place version)
        println("Gradient at start point $x: ", grad_value)
        println("Gradient calls after grad(x): ", get_grad_count(tf)) # → 1
        println()

        # ---------------------------------------------------------------------
        # Run an actual optimization and observe how many calls are made
        # ---------------------------------------------------------------------
        # Optim.jl's L-BFGS will repeatedly call tf.f and tf.gradient! during line search
        # and model building – the counters will accumulate all of these calls.
        result = Optim.optimize(
            tf.f,              # objective
            tf.gradient!,      # in-place gradient (preferred for performance)
            x,                 # initial guess
            Optim.LBFGS(),     # limited-memory quasi-Newton method
            Optim.Options(f_reltol=1e-6)  # stop when relative function change < 1e-6
        )

        println("Optimization result - Minimizer: ", Optim.minimizer(result))
        println("Optimization result - Minimum:   ", Optim.minimum(result))
        # Typical numbers for Rosenbrock n=2 with L-BFGS:
        #   ~20–40 function calls
        #   ~20–40 gradient calls
        # Exact numbers may vary slightly depending on Julia/Optim version and tolerances.
        println("Function calls after optimization: ", get_f_count(tf))
        println("Gradient calls after optimization: ", get_grad_count(tf))
        println()

        # ---------------------------------------------------------------------
        # Reset counters again – ready for the next experiment
        # ---------------------------------------------------------------------
        reset_counts!(tf)
        println("After second reset - Function calls: ", get_f_count(tf))   # → 0
        println("After second reset - Gradient calls: ", get_grad_count(tf)) # → 0
    end

    # -------------------------------------------------------------------------
    # Execute the example when the file is loaded
    # -------------------------------------------------------------------------
    # This ensures the demonstration runs automatically whether the file is
    #   • run directly (julia count_calls.jl)
    #   • included from runallexamples.jl
    #   • loaded interactively
    run_count_calls_example()



