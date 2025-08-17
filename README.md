# NonlinearOptimizationTestFunctions
# Last modified: 17 August 2025, 14:51 PM CEST

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Usage](#usage)
  - [Examples](#examples)
    - [Evaluating the Eggholder Function](#evaluating-the-eggholder-function)
    - [Comparing Optimization Methods](#comparing-optimization-methods)
    - [Computing Hessian with Zygote](#computing-hessian-with-zygote)
    - [Listing Test Functions and Properties](#listing-test-functions-and-properties)
    - [Optimizing All Functions](#optimizing-all-functions)
    - [Optimizing with NLopt](#optimizing-with-nlopt)
    - [Filtering Test Functions by Properties](#filtering-test-functions-by-properties)
- [Test Functions](#test-functions)
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
        result_gd = optimize(tf.f, tf.gradient!, tf.meta[:start](n), GradientDescent(), Optim.Options(f_reltol=1e-6))
        result_lbfgs = optimize(tf.f, tf.gradient!, tf.meta[:start](n), LBFGS(), Optim.Options(f_reltol=1e-6))
        println("Gradient Descent on $(tf.meta[:name]): $(Optim.minimizer(result_gd)), $(Optim.minimum(result_gd))")
        println("L-BFGS on $(tf.meta[:name]): $(Optim.minimizer(result_lbfgs)), $(Optim.minimum(result_lbfgs))")

#### Computing Hessian with Zygote
Performs three Newton steps on the Rosenbrock function using analytical gradients and Zygote's Hessian computation, showcasing integration with automatic differentiation.

        using NonlinearOptimizationTestFunctions, Zygote, LinearAlgebra
        tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
        n = 2
        x = tf.meta[:start](n)
        x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
        x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
        x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
        println("Nach 3 Newton-Schritten für $(tf.meta[:name]): $x")

#### Listing Test Functions and Properties
Displays all available test functions with their start points, minima, and properties, useful for inspecting function characteristics.

        using NonlinearOptimizationTestFunctions
        n = 2
        for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
            println("$(tf.meta[:name]): Start at $(tf.meta[:start](n)), Minimum at $(tf.meta[:min_position](n)), Value $(tf.meta[:min_value]), Properties: $(join(tf.meta[:properties], ", "))")
        end

#### Optimizing All Functions
Optimizes all test functions using Optim.jl's L-BFGS algorithm, demonstrating batch processing of test functions.

        using NonlinearOptimizationTestFunctions, Optim
        n = 2
        for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
            result = optimize(tf.f, tf.gradient!, tf.meta[:start](n), LBFGS(), Optim.Options(f_reltol=1e-6))
            println("$(tf.meta[:name]): $(Optim.minimizer(result)), $(Optim.minimum(result))")
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

#### Filtering Test Functions by Properties
Filters test functions based on specific properties (e.g., multimodal or finite_at_inf), demonstrating how to select functions for targeted benchmarking.

        using NonlinearOptimizationTestFunctions
        multimodal_funcs = filter_testfunctions(tf -> has_property(tf, "multimodal"))
        println("Multimodal functions: ", [tf.meta[:name] for tf in multimodal_funcs])
        finite_at_inf_funcs = filter_testfunctions(tf -> has_property(tf, "finite_at_inf"))
        println("Functions with finite_at_inf: ", [tf.meta[:name] for tf in finite_at_inf_funcs])

## Test Functions

The package includes a variety of test functions for nonlinear optimization, each defined in src/functions/<functionname>.jl. Below is a complete list of available functions, their properties, minima, bounds, and supported dimensions, based on precise values from sources like al-roomi.org, sfu.ca, and Molga & Smutnicki (2005). **All functions are fully implemented with function evaluations, analytical gradients, and metadata, validated through the test suite, including checks for empty input vectors, NaN, Inf, and small inputs (e.g., 1e-308). Functions throw appropriate errors (e.g., ArgumentError for empty input or incorrect dimensions) to ensure robustness.**

- **Ackley** [Jamil & Yang (2013): f1]: Multimodal, non-convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5, 5]^n (default) or [-32.768, 32.768]^n (benchmark). Dimensions: Any n >= 1.
- **AxisParallelHyperEllipsoid** [Jamil & Yang (2013): f143]: Convex, differentiable, separable, scalable. Minimum: 0.0 at (0, ..., 0). Bounds: [-Inf, Inf]^n. Dimensions: Any n >= 1.
- **Beale** [Jamil & Yang (2013): f10]: Multimodal, non-convex, differentiable, bounded. Minimum: 0.0 at (3.0, 0.5). Bounds: [-4.5, 4.5]^2. Dimensions: n=2.
- **Bird** [Jamil & Yang (2013): f16]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -106.764537 at (4.701055816, 3.15294602) and (-1.582142172, -3.130246801). Bounds: [-2π, 2π]^2. Dimensions: n=2.
- **Bohachevsky** [Jamil & Yang (2013): f17]: Multimodal, non-convex, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-10, 10]^n. Dimensions: Any n >= 2.
- **Booth** [Jamil & Yang (2013): f20]: Unimodal, convex, non-separable, differentiable, bounded. Minimum: 0.0 at (1.0, 3.0). Bounds: [-10, 10]^2. Dimensions: n=2.
- **Branin** [Jamil & Yang (2013): f22]: Multimodal, differentiable, non-convex, non-separable, bounded. Minimum: 0.397887 at (-pi, 12.275), (pi, 2.275), (9.424778, 2.475). Bounds: [-5, 10] x [0, 15]. Dimensions: n=2.
- **Bukin6** [Jamil & Yang (2013): f28]: Multimodal, non-convex, partially differentiable, bounded. Minimum: 0.0 at (-10.0, 1.0). Bounds: [-15, -5] x [-3, 3]. Dimensions: n=2.
- **CrossInTray** [Jamil & Yang (2013): f39]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -2.06261 at (1.3491, 1.3491), (-1.3491, 1.3491), (1.3491, -1.3491), (-1.3491, -1.3491). Bounds: [-10, 10]^2. Dimensions: n=2.
- **De Jong F4** [Jamil & Yang (2013): f44]: Unimodal, convex, separable, partially differentiable, scalable, bounded, has_noise. Minimum: 0.0 (deterministic part) at (0, ..., 0), plus additive Uniform[0,1) noise. Bounds: [-1.28, 1.28]^n. Dimensions: Any n >= 1.
- **De Jong F5** [Jamil & Yang (2013): f46]: Multimodal, non-convex, non-separable, differentiable, bounded, finite_at_inf. Minimum: 0.9980038388186492 at (-32.0, -32.0). Bounds: [-65.536, 65.536]^2. Dimensions: n=2.
- **DeckkersAarts** [Jamil & Yang (2013): f45]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -50233.6967 at (0, 14.945108) and (0, -14.945108). Bounds: [-20, 20]^2. Dimensions: n=2.
- **DixonPrice** [Jamil & Yang (2013): f48]: Unimodal, non-convex, differentiable, scalable, bounded. Minimum: 0.0 at (2^(-(2^i - 2)/2^i), ..., 2^(-(2^n - 2)/2^n)). Bounds: [-10, 10]^n. Dimensions: Any n >= 1.
- **DropWave**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.0 at (0, 0). Bounds: [-5.12, 5.12]^2. Dimensions: n=2. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Easom** [Jamil & Yang (2013): f50]: Unimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.0 at (pi, pi). Bounds: [-100, 100]^2. Dimensions: n=2.
- **Eggholder** [Jamil & Yang (2013): f53]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -959.6406627208506 at (512.0, 404.2318058008512). Bounds: [-512, 512]^2. Dimensions: n=2.
- **GoldsteinPrice** [Jamil & Yang (2013): f58]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 3.0 at (0, -1). Bounds: [-2, 2]^2. Dimensions: n=2.
- **Griewank** [Jamil & Yang (2013): f59]: Multimodal, non-convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-600, 600]^n. Dimensions: Any n >= 1.
- **Hartmann** [Jamil & Yang (2013): f62, f63]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -3.86278214782076 at (0.114614, 0.555649, 0.852547) for n=3. Bounds: [0, 1]^n. Dimensions: n=3, 4, 6.
- **Himmelblau** [Jamil & Yang (2013): f65]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0.0 at (3.0, 2.0), (-2.805118, 3.131312), (-3.779310, -3.283186), (3.584428, -1.848126). Bounds: [-5, 5]^2. Dimensions: n=2.
- **HolderTable** [Jamil & Yang (2013): f145]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -19.2085 at (8.05502, 9.66459) and others. Bounds: [-10, 10]^2. Dimensions: n=2.
- **Keane** [Jamil & Yang (2013): f69]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -0.673667521146855 at (0.0, 1.393249070031784), (1.393249070031784, 0.0). Bounds: [0, 10]^2. Dimensions: n=2.
- **Langermann** [Jamil & Yang (2013): f68]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: approximately -5.1621259 at (2.002992, 1.006096). Bounds: [0, 10]^2. Dimensions: n=2.
- **Levy** [Jamil & Yang (2013): f73]: Multimodal, non-convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (1, ..., 1). Bounds: [-10, 10]^n. Dimensions: Any n >= 1.
- **Matyas** [Jamil & Yang (2013): f71]: Unimodal, convex, non-separable, differentiable, bounded. Minimum: 0.0 at (0.0, 0.0). Bounds: [-10, 10]^2. Dimensions: n=2.
- **McCormick** [Jamil & Yang (2013): f72]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.913222954981037 at (-0.547197553, -1.547197553). Bounds: [-1.5, 4] x [-3, 4]. Dimensions: n=2.
- **Michalewicz** [Jamil & Yang (2013): f75]: Multimodal, non-convex, separable, differentiable, scalable, bounded. Minimum: -1.8013 (n=2), -4.687658 (n=5), -9.66015 (n=10). Bounds: [0, pi]^n. Dimensions: Any n >= 1.
- **Quadratic** [Jamil & Yang (2013): f99]: Unimodal, convex, non-separable, differentiable, scalable. Minimum: c - 0.25 * b^T A^-1 b at -0.5 * A^-1 b, where A is a positive definite matrix, b is a vector, and c is a scalar (default: A random positive definite, b=0, c=0). Bounds: [-Inf, Inf]^n. Dimensions: Any n >= 1. The quadratic function encapsulates parameters A, b, c, set on the first call or overridden if provided, making it ideal for testing optimization algorithms on non-separable problems with varying condition numbers. Example usage: `quadratic(ones(2), Symmetric([2.0 0.0; 0.0 2.0]), [1.0, 1.0], 0.5)` sets custom parameters; subsequent calls to `quadratic(x)` reuse these parameters.
- **Rana** [Jamil & Yang (2013): f102]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -498.12463264808594 at (-500.0, -499.0733150925747). Bounds: [-500, 500]^2. Dimensions: n=2.
- **Rastrigin** [Jamil & Yang (2013): f103]: Multimodal, non-convex, separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5.12, 5.12]^n. Dimensions: Any n >= 1.
- **Rosenbrock** [Jamil & Yang (2013): f105]: Unimodal, non-convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (1, ..., 1). Bounds: [-5, 5]^n. Dimensions: Any n >= 2.
- **RotatedHyperEllipsoid** [Jamil & Yang (2013): f119]: Unimodal, convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-65.536, 65.536]^n. Dimensions: Any n >= 1. The rotated hyper-ellipsoid function, also known as the sum squares function, is a convex, scalable test function with a single global minimum, suitable for testing optimization algorithms on non-separable problems.
- **Schwefel** [Jamil & Yang (2013): f128]: Multimodal, non-convex, separable, differentiable, scalable, bounded. Minimum: 0.0 at (420.9687, ..., 420.9687). Bounds: [-500, 500]^n. Dimensions: Any n >= 1.
- **Shekel** [Jamil & Yang (2013): f132]: Multimodal, non-convex, non-separable, differentiable, bounded, finite_at_inf. Minimum: -10.536409825004505 at (4.000747838, 4.000592862, 3.999663587, 3.999510115) for m=10. Bounds: [0, 10]^4. Dimensions: n=4.
- **Shubert** [Jamil & Yang (2013): f133]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -186.7309 at multiple points, e.g., (-1.4251286, -0.800321). Bounds: [-10, 10]^2. Dimensions: n=2.
- **SineEnvelope** [Jamil & Yang (2013): f134]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.0 at (0.0, 0.0). Bounds: [-100, 100]^2. Dimensions: n=2.
- **SixHumpCamelback** [Jamil & Yang (2013): f30]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.031628453489877 at (±0.08984201368301331, ±0.7126564032704135). Bounds: [-3, 3] x [-2, 2]. Dimensions: n=2.
- **Sphere** [Jamil & Yang (2013): f137]: Unimodal, convex, separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5.12, 5.12]^n. Dimensions: Any n >= 2.
- **Step (De Jong F3)** [Jamil & Yang (2013): f138]: Unimodal, non-convex, separable, partially differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5.12, 5.12]^n. Dimensions: Any n >= 1.
- **StyblinskiTang** [Jamil & Yang (2013): f144]: Multimodal, non-convex, differentiable, scalable, bounded. Minimum: -39.166165*n at (-2.903534, ..., -2.903534). Bounds: [-5, 5]^n. Dimensions: Any n >= 1.
- **SumOfPowers** [Jamil & Yang (2013): f93]: Unimodal, convex, separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-1, 1]^n. Dimensions: Any n >= 1.
- **ThreeHumpCamel** [Jamil & Yang (2013): f29]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0.0 at (0.0, 0.0). Bounds: [-5, 5]^2. Dimensions: n=2.
- **Zakharov** [Jamil & Yang (2013): f172]: Unimodal, convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5, 10]^n. Dimensions: Any n >= 1.
- **Giunta** [Jamil & Yang (2013): f57]: Multimodal, non-convex, separable, differentiable, bounded. Minimum: 0.06447042053690566 at (0.4673200277395354, 0.4673200277395354). Bounds: [-1, 1]^2. Dimensions: n=2.
- **Kearfott** [Jamil & Yang (2013): f70]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0.0 at multiple points, e.g., (1.224744871391589, 0.7071067811865476). Bounds: [-3, 4]^2. Dimensions: n=2.

## Upcoming Test Functions

The following test functions are planned for implementation, based on standard benchmarks. They will be added with analytical gradients, metadata, and validation, consistent with the existing collection.

- **MishraBird** [Jamil & Yang (2013): f31]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -106.764537 at (-3.1302468, -1.5821422) and (-6.7745761, -2.4183762). Bounds: [-10, 0] x [-6.5, 0]. Dimensions: n=2.
- **SchafferN1** [Jamil & Yang (2013): f112]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0 at (0,0). Bounds: [-100, 100]^2. Dimensions: n=2.
- **SchafferN2** [Jamil & Yang (2013): f113]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0 at (0,0). Bounds: [-100, 100]^2. Dimensions: n=2.
- **SchafferN4** [Jamil & Yang (2013): f115]: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0.292579 at (0,1.25313) and others. Bounds: [-100, 100]^2. Dimensions: n=2.
- **Trid** [Jamil & Yang (2013): f150]: Unimodal, convex, non-separable, differentiable, scalable. Minimum: -n(n+4)(n-1)/6 at i*(n+1-i) for i=1 to n. Bounds: [-n^2, n^2]^n. Dimensions: Any n >= 2.
- **Wood** [Jamil & Yang (2013): f161]: Unimodal, non-convex, non-separable, differentiable, fixed. Minimum: 0 at (1,1,1,1). Bounds: [-10,10]^4. Dimensions: n=4.
- **Powell** [Jamil & Yang (2013): f91]: Unimodal, non-convex, non-separable, differentiable, fixed. Minimum: 0 at (0,0,0,0). Bounds: [-4,5]^4. Dimensions: n=4.
- **Perm** [Jamil & Yang (2013): f88]: Unimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0 at (1,1/2,1/3,...,1/n). Bounds: [-n, n]^n. Dimensions: Any n >=1.
- **PowerSum** [Jamil & Yang (2013): f93]: Unimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0 at specific point. Bounds: [0, n]^n. Dimensions: Any n >=1.
- **Colville** [Jamil & Yang (2013): f36]: Unimodal, non-convex, non-separable, differentiable, fixed. Minimum: 0 at (1,1,1,1). Bounds: [-10,10]^4. Dimensions: n=4.
- **FreudensteinRoth** [Jamil & Yang (2013): f56]: Multimodal, non-convex, non-separable, differentiable, fixed. Minimum: 0 at (5,4, -0.5, -0.5). Bounds: [-10,10]^4. Dimensions: n=4.
- **Brown** [Jamil & Yang (2013): f25]: Multimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0 at (0,0,...,0). Bounds: [-1,4]^n. Dimensions: Any n >=2.
- **AlpineN1** [Jamil & Yang (2013): f6]: Multimodal, non-convex, separable, non-differentiable, scalable. Minimum: 0 at (0,0,...,0). Bounds: [-10,10]^n. Dimensions: Any n >=1.
- **AlpineN2** [Jamil & Yang (2013): f7]: Multimodal, non-convex, separable, differentiable, scalable. Minimum: -2.808^n at (7.917,7.917,...,7.917). Bounds: [0,10]^n. Dimensions: Any n >=1.
- **BartelsConn** [Jamil & Yang (2013): f9]: Multimodal, non-convex, non-separable, non-differentiable, fixed. Minimum: 1 at (0,0). Bounds: [-500,500]^2. Dimensions: n=2.
- **CarromTable** [Jamil & Yang (2013): f32]: Multimodal, non-convex, non-separable, differentiable, fixed. Minimum: -24.1568155165 at multiple. Bounds: [-10,10]^2. Dimensions: n=2.
- **Chichinadze** [Jamil & Yang (2013): f33]: Multimodal, non-convex, non-separable, differentiable, fixed. Minimum: -43.3159 at (5.90133, 0.5). Bounds: [-30,30]^2. Dimensions: n=2.
- **Cigar** [Jamil & Yang (2013): f125]: Unimodal, convex, non-separable, differentiable, scalable. Minimum: 0 at (0,0,...,0). Bounds: [-10,10]^n. Dimensions: Any n >=2.
- **CosineMixture** [Jamil & Yang (2013): f38]: Multimodal, non-convex, separable, differentiable, scalable. Minimum: -0.1*n at multiple. Bounds: [-1,1]^n. Dimensions: Any n >=1.
- **Corana** [Jamil & Yang (2013): f37]: Multimodal, non-convex, separable, differentiable, fixed. Minimum: 0 at (0,0,0,0). Bounds: [-1000,1000]^4. Dimensions: n=4.
- **Csendes** [Jamil & Yang (2013): f40]: Unimodal, non-convex, separable, non-differentiable at 0, scalable. Minimum: 0 at (0,0,...,0). Bounds: [-1,1]^n. Dimensions: Any n >=1.
- **Cube** [Jamil & Yang (2013): f41]: Unimodal, non-convex, non-separable, differentiable, fixed. Minimum: 0 at (1,1,1). Bounds: [-10,10]^3. Dimensions: n=3.
- **Damavandi** [Jamil & Yang (2013): f42]: Multimodal, non-convex, non-separable, non-differentiable, fixed. Minimum: 0 at (2,2). Bounds: [0,14]^2. Dimensions: n=2.

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
- **bounded**: The function is defined within finite bounds (e.g., [a, b]^n), and evaluations outside these bounds are typically undefined or irrelevant. Tests for bounded functions check finite values at the bounds (`lb`, `ub`) rather than at infinity.
- **has_constraints**: The function includes explicit constraints (e.g., equality or inequality constraints).
- **controversial**: The function has debated properties or inconsistent definitions in the literature.
- **has_noise**: The function includes stochastic or noisy components, simulating real-world uncertainty.
- **finite_at_inf**: The function returns finite values when evaluated at infinity (e.g., f([Inf, ..., Inf]) is finite).

These properties are validated in the test suite (e.g., `test/runtests.jl`) to ensure consistency and correctness.

## Running Tests

To run the test suite, execute:

    cd /c/Users/uweal/NonlinearOptimizationTestFunctions
    julia --project=. -e 'using Pkg; Pkg.resolve(); Pkg.instantiate(); include("test/runtests.jl")'

Tests cover function evaluations, metadata validation, edge cases (NaN, Inf, 1e-308, empty input vectors, and bounds for bounded functions), and optimization with Optim.jl. For functions marked as `bounded`, tests verify finite values at the lower and upper bounds (`lb`, `ub`) instead of infinity, reflecting their constrained domain. Extensive gradient tests are conducted in `test/runtests.jl` to ensure the correctness of analytical gradients. These gradients are rigorously validated by comparing them against numerical gradients computed via finite differences and gradients obtained through automatic differentiation (AD) using ForwardDiff, ensuring high accuracy and reliability. All tests, including those for the newly added Deckkers-Aarts and Shekel functions, pass as of the last update, ensuring robustness and correctness.

## License

This package is licensed under the MIT License. See LICENSE for details.

## Alternative Names for Test Functions

Some test functions are referred to by different names in the literature. Below is a list connecting the names used in this package to common alternatives.

- **ackley**: Ackley's function, Ackley No. 1, Ackley Path Function.
- **axisparallelhyperellipsoid**: Axis parallel hyper-ellipsoid function, Sum squares function, Weighted sphere model, Quadratic function (axis-aligned variant).
- **beale**: Beale's function.
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
- **goldsteinprice**: Goldstein-Price function.
- **griewank**: Griewank's function, Griewangk’s function, Griewank function.
- **hartmann**: Hartmann function (Hartmann 3, 4 or 6).
- **himmelblau**: Himmelblau's function.
- **keane**: Keane's function, Bump function.
- **langermann**: Langermann's function.
- **levy**: Levy function No. 13, Levy N.13.
- **matyas**: Matyas function.
- **mccormick**: McCormick's function.
- **michalewicz**: Michalewicz's function.
- **quadratic**: Quadratic function, Paraboloid, General quadratic form (often customized with matrix A, vector b, scalar c).
- **rana**: Rana's function.
- **rastrigin**: Rastrigin's function.
- **rosenbrock**: Rosenbrock's valley, De Jong F2, Banana function.
- **rotatedhyperellipsoid**: Rotated Hyper-Ellipsoid function, Schwefel's function 1.2, Extended sum squares function, Extended Rosenbrock function (in some contexts).
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
- **giunta**: Giunta function.
- **kearfott**: Kearfott's function.

## References

- Al-Roomi, A. R. (2015). Unconstrained Single-Objective Benchmark Functions Repository. Dalhousie University. https://www.al-roomi.org/benchmarks/unconstrained
- Gavana, A. (2013). Test functions index. Retrieved February 2013, from http://infinity77.net/global_optimization/test_functions.html (Note: Original source unavailable; referenced via Al-Roomi (2015) and opfunu Python library: https://github.com/thieu1995/opfunu/blob/master/opfunu/cec_based/cec.py)
- Hedar, A.-R. (2005). Global optimization test problems. http://www-optima.amp.i.kyoto-u.ac.jp/member/student/hedar/Hedar_files/TestGO.htm
- Jamil, M., & Yang, X.-S. (2013). A literature survey of benchmark functions for global optimisation problems. *International Journal of Mathematical Modelling and Numerical Optimisation*, 4(2), 150–194. https://arxiv.org/abs/1308.4008
- Molga, M., & Smutnicki, C. (2005). Test functions for optimization needs. http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf
- Suganthan, P. N., Hansen, N., Liang, J. J., Deb, K., Chen, Y.-P., Auger, A., & Tiwari, S. (2005). Problem definitions and evaluation criteria for the CEC 2005 special session on real-parameter optimization. IEEE CEC-Website. https://www.lri.fr/~hansen/Tech-Report-May-30-05.pdf
- Unknown Author. (n.d.). Mathematical Test Functions for Global Optimization. https://www.geocities.ws/eadorio/mvf.pdf 