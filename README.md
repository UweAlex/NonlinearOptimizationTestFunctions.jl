# NonlinearOptimizationTestFunctions
# Last modified: 13 August 2025, 09:04 AM CEST

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

1. Evaluating the Eggholder Function (examples/Evaluate_eggholder.jl):
   Evaluates the Eggholder function and its analytical gradient at the origin, demonstrating basic usage of a test function and its gradient.

        using NonlinearOptimizationTestFunctions
        println(eggholder([0,0]))
        println(eggholder_gradient([0,0]))

2. Comparing Optimization Methods (examples/Compare_optimization_methods.jl):
   Compares Gradient Descent and L-BFGS on the Rosenbrock function, demonstrating how to use TestFunction with Optim.jl to evaluate different algorithms.

        using NonlinearOptimizationTestFunctions, Optim
        tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
        n = 2
        result_gd = optimize(tf.f, tf.gradient!, tf.meta[:start](n), GradientDescent(), Optim.Options(f_reltol=1e-6))
        result_lbfgs = optimize(tf.f, tf.gradient!, tf.meta[:start](n), LBFGS(), Optim.Options(f_reltol=1e-6))
        println("Gradient Descent on $(tf.meta[:name]): $(Optim.minimizer(result_gd)), $(Optim.minimum(result_gd))")
        println("L-BFGS on $(tf.meta[:name]): $(Optim.minimizer(result_lbfgs)), $(Optim.minimum(result_lbfgs))")

3. Computing Hessian with Zygote (examples/Compute_hessian_with_zygote.jl):
   Performs three Newton steps on the Rosenbrock function using analytical gradients and Zygote's Hessian computation, showcasing integration with automatic differentiation.

        using NonlinearOptimizationTestFunctions, Zygote, LinearAlgebra
        tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
        n = 2
        x = tf.meta[:start](n)
        x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
        x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
        x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
        println("Nach 3 Newton-Schritten für $(tf.meta[:name]): $x")

4. Listing Test Functions and Properties (examples/List_all_available_test_functions_and_their_properties.jl):
   Displays all available test functions with their start points, minima, and properties, useful for inspecting function characteristics.

        using NonlinearOptimizationTestFunctions
        n = 2
        for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
            println("$(tf.meta[:name]): Start at $(tf.meta[:start](n)), Minimum at $(tf.meta[:min_position](n)), Value $(tf.meta[:min_value]), Properties: $(join(tf.meta[:properties], ", "))")
        end

5. Optimizing All Functions (examples/Optimize_all_functions.jl):
   Optimizes all test functions using Optim.jl's L-BFGS algorithm, demonstrating batch processing of test functions.

        using NonlinearOptimizationTestFunctions, Optim
        n = 2
        for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
            result = optimize(tf.f, tf.gradient!, tf.meta[:start](n), LBFGS(), Optim.Options(f_reltol=1e-6))
            println("$(tf.meta[:name]): $(Optim.minimizer(result)), $(Optim.minimum(result))")
        end

6. Optimizing with NLopt (examples/Optimize_with_nlopt.jl):
   Optimizes the Rosenbrock function using NLopt.jl's LD_LBFGS algorithm, highlighting compatibility with external optimization libraries.

        using NonlinearOptimizationTestFunctions
        if isdefined(Main, :NLopt)
            using NLopt
            tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
            n = 2
            opt = Opt(:LD_LBFGS, n)
            NLopt.ftol_rel!(opt, 1e-6)
            NLopt.lower_bounds!(opt, tf.meta[:lb](n))
            NLopt.upper_bounds!(opt, tf.meta[:ub](n))
            NLopt.min_objective!(opt, (x, grad) -> begin
                f = tf.f(x)
                if length(grad) > 0
                    tf.gradient!(grad, x)
                end
                f
            end)
            minf, minx, ret = optimize(opt, tf.meta[:start](n))
            println("$(tf.meta[:name]): $minx, $minf")
        else
            println("NLopt.jl is not installed. Please install it to run this example.")
        end

## Test Functions

The package includes a variety of test functions for nonlinear optimization, each defined in src/functions/<functionname>.jl. Below is a complete list of available functions, their properties, minima, bounds, and supported dimensions, based on precise values from sources like al-roomi.org, sfu.ca, and Molga & Smutnicki (2005). **All functions are fully implemented with function evaluations, analytical gradients, and metadata, validated through the test suite, including checks for empty input vectors, NaN, Inf, and small inputs (e.g., 1e-308).**

- **Ackley**: Multimodal, non-convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5, 5]^n (default) or [-32.768, 32.768]^n (benchmark). Dimensions: Any n >= 1.
- **AxisParallelHyperEllipsoid**: Convex, differentiable, separable, scalable. Minimum: 0.0 at (0, ..., 0). Bounds: [-Inf, Inf]^n. Dimensions: Any n >= 1.
- **Beale**: Multimodal, non-convex, differentiable. Minimum: 0.0 at (3.0, 0.5). Bounds: [-4.5, 4.5]^2. Dimensions: n=2.
- **Bohachevsky**: Multimodal, non-convex, differentiable, scalable. Minimum: 0.0 at (0, ..., 0). Bounds: [-10, 10]^n. Dimensions: Any n >= 2.
- **Branin**: Multimodal, differentiable, non-convex, non-separable, bounded. Minimum: 0.397887 at (-pi, 12.275), (pi, 2.275), (9.424778, 2.475). Bounds: [-5, 10] x [0, 15]. Dimensions: n=2.
- **Bukin6**: Multimodal, non-convex, partially differentiable, bounded. Minimum: 0.0 at (-10.0, 1.0). Bounds: [-15, -5] x [-3, 3]. Dimensions: n=2.
- **CrossInTray**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -2.06261 at (1.3491, 1.3491), (-1.3491, 1.3491), (1.3491, -1.3491), (-1.3491, -1.3491). Bounds: [-10, 10]^2. Dimensions: n=2.
- **DixonPrice**: Unimodal, non-convex, differentiable, scalable. Minimum: 0.0 at (2^(-(2^i - 2)/2^i), ..., 2^(-(2^n - 2)/2^n)). Bounds: [-10, 10]^n. Dimensions: Any n >= 1.
- **DropWave**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.0 at (0, 0). Bounds: [-5.12, 5.12]^2. Dimensions: n=2.
- **Easom**: Unimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.0 at (pi, pi). Bounds: [-100, 100]^2. Dimensions: n=2.
- **Eggholder**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -959.6406627208506 at (512.0, 404.2318058008512). Bounds: [-512, 512]^2. Dimensions: n=2.
- **GoldsteinPrice**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 3.0 at (0, -1). Bounds: [-2, 2]^2. Dimensions: n=2.
- **Griewank**: Multimodal, non-convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-600, 600]^n. Dimensions: Any n >= 1.
- **Hartmann**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -3.86278214782076 at (0.114614, 0.555649, 0.852547) for n=3. Bounds: [0, 1]^n. Dimensions: n=3, 4, 6.
- **Himmelblau**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0.0 at (3.0, 2.0), (-2.805118, 3.131312), (-3.779310, -3.283186), (3.584428, -1.848126). Bounds: [-5, 5]^2. Dimensions: n=2.
- **Keane**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -0.673667521146855 at (0.0, 1.393249070031784), (1.393249070031784, 0.0). Bounds: [0, 10]^2. Dimensions: n=2.
- **Langermann**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: approximately -5.1621259 at (2.002992, 1.006096). Bounds: [0, 10]^2. Dimensions: n=2.
- **Levy**: Multimodal, non-convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (1, ..., 1). Bounds: [-10, 10]^n. Dimensions: Any n >= 1.
- **McCormick**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.913222954981037 at (-0.547197553, -1.547197553). Bounds: [-1.5, 4] x [-3, 4]. Dimensions: n=2.
- **Michalewicz**: Multimodal, non-convex, separable, differentiable, scalable, bounded. Minimum: -1.8013 (n=2), -4.687658 (n=5), -9.66015 (n=10). Bounds: [0, pi]^n. Dimensions: Any n >= 1.
- **Quadratic**: Unimodal, convex, non-separable, differentiable, scalable. Minimum: c - 0.25 * b^T A^-1 b at -0.5 * A^-1 b, where A is a positive definite matrix, b is a vector, and c is a scalar (default: A random positive definite, b=0, c=0). Bounds: [-Inf, Inf]^n. Dimensions: Any n >= 1. The quadratic function encapsulates parameters A, b, c, set on the first call or overridden if provided, making it ideal for testing optimization algorithms on non-separable problems with varying condition numbers. Example usage: `quadratic(ones(2), Symmetric([2.0 0.0; 0.0 2.0]), [1.0, 1.0], 0.5)` sets custom parameters; subsequent calls to `quadratic(x)` reuse these parameters.
- **Rana**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -498.12463264808594 at (-500.0, -499.0733150925747). Bounds: [-500, 500]^2. Dimensions: n=2.
- **Rastrigin**: Multimodal, non-convex, separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5.12, 5.12]^n. Dimensions: Any n >= 1.
- **Rosenbrock**: Unimodal, non-convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (1, ..., 1). Bounds: [-5, 5]^n. Dimensions: Any n >= 2.
- **RotatedHyperEllipsoid**: Unimodal, convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-65.536, 65.536]^n. Dimensions: Any n >= 1. The rotated hyper-ellipsoid function, also known as the sum squares function, is a convex, scalable test function with a single global minimum, suitable for testing optimization algorithms on non-separable problems.
- **Schwefel**: Multimodal, non-convex, separable, differentiable, scalable, bounded. Minimum: 0.0 at (420.9687, ..., 420.9687). Bounds: [-500, 500]^n. Dimensions: Any n >= 1.
- **Shekel**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -10.536409825004505 at (4.0, 4.0, 4.0, 4.0) for m=10. Bounds: [0, 10]^4. Dimensions: n=4.
- **Shubert**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -186.7309 at multiple points, e.g., (-1.4251286, -0.800321). Bounds: [-10, 10]^2. Dimensions: n=2.
- **SineEnvelope**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.0 at (0.0, 0.0). Bounds: [-100, 100]^2. Dimensions: n=2.
- **SixHumpCamelback**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.031628453489877 at (±0.08984201368301331, ±0.7126564032704135). Bounds: [-3, 3] x [-2, 2]. Dimensions: n=2.
- **Sphere**: Unimodal, convex, separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5.12, 5.12]^n. Dimensions: Any n >= 2.
- **Step (De Jong F3)**: Unimodal, non-convex, separable, partially differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5.12, 5.12]^n. Dimensions: Any n >= 1.
- **StyblinskiTang**: Multimodal, non-convex, differentiable, scalable, bounded. Minimum: -39.166165*n at (-2.903534, ..., -2.903534). Bounds: [-5, 5]^n. Dimensions: Any n >= 1.
- **SumOfPowers**: Unimodal, convex, separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-1, 1]^n. Dimensions: Any n >= 1.
- **Zakharov**: Unimodal, convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5, 10]^n. Dimensions: Any n >= 1.

## Running Tests

To run the test suite, execute:

    cd /c/Users/uweal/NonlinearOptimizationTestFunctions
    julia --project=. -e 'using Pkg; Pkg.instantiate(); include("test/runtests.jl")'

Tests cover function evaluations, metadata validation, edge cases (NaN, Inf, 1e-308, empty input vectors), and optimization with Optim.jl. Gradient tests are centralized in test/runtests.jl for consistency.

## License

This package is licensed under the MIT License. See LICENSE for details.

## Alternative Names for Test Functions

Some test functions are referred to by different names in the literature. Below is a list connecting the names used in this package to common alternatives:

- **ackley**: Ackley's function, Ackley No. 1, Ackley Path Function.
- **axisparallelhyperellipsoid**: Axis parallel hyper-ellipsoid function, Sum squares function, De Jong F2.
- **beale**: Beale's function.
- **bohachevsky**: Bohachevsky's function.
- **branin**: Branin's rcos function, Branin-Hoo function.
- **bukin6**: Bukin function No. 6.
- **crossintray**: Cross-in-Tray function.
- **dejongf4**: De Jong F4, Quartic function with noise, Noisy quartic function.
- **dixonprice**: Dixon-Price function.
- **dropwave**: Drop-Wave function.
- **easom**: Easom's function.
- **eggholder**: Egg Holder function, Egg Crate function.
- **goldsteinprice**: Goldstein-Price function.
- **griewank**: Griewank's function, Griewangk’s function.
- **hartmann**: Hartmann function (Hartmann 3, 4 or 6).
- **himmelblau**: Himmelblau's function.
- **keane**: Keane's function, Bump function.
- **langermann**: Langermann's function.
- **levy**: Levy function No. 13, Levy N.13.
- **mccormick**: McCormick's function.
- **michalewicz**: Michalewicz's function.
- **quadratic**: Quadratic function, Paraboloid.
- **rana**: Rana's function.
- **rastrigin**: Rastrigin's function.
- **rosenbrock**: Rosenbrock's valley, De Jong F2, Banana function.
- **rotatedhyperellipsoid**: Rotated Hyper-Ellipsoid function, Sum squares function, Weighted sphere function.
- **schwefel**: Schwefel's function, Schwefel 2.26.
- **shekel**: Shekel's foxholes, De Jong F5, Foxholes function.
- **shubert**: Shubert's function.
- **sineenvelope**: Sine Envelope Sine Wave Sine function.
- **sixhumpcamelback**: Six-Hump Camelback function, Camel function.
- **sphere**: Sphere function, De Jong F1, Quadratic sphere.
- **step**: Step function, De Jong F3.
- **styblinskitang**: Styblinski-Tang function.
- **sumofpowers**: Sum of different powers function, Absolute value function.
- **zakharov**: Zakharov's function.

## References

    - Molga, M., & Smutnicki, C. (2005). Test functions for optimization needs. http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf
    - Jamil, M., & Yang, X.-S. (2013). A literature survey of benchmark functions for global optimisation problems. https://arxiv.org/abs/1308.4008
    - Hedar, A.-R. (2005). Global optimization test problems. http://www-optima.amp.i.kyoto-u.ac.jp/member/student/hedar/Hedar_files/TestGO.htm
    - Suganthan, P. N., et al. (2005). Problem definitions and evaluation criteria for the CEC 2005 special session on real-parameter optimization. IEEE CEC-Website.
    - Al-Roomi (o. J.). Test Functions Repository. https://www.al-roomi.org
    - https://www.geocities.ws/eadorio/mvf.pdf