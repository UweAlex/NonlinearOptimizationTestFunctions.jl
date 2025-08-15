# NonlinearOptimizationTestFunctions
# Last modified: 15 August 2025

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

- **Ackley**: Multimodal, non-convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5, 5]^n (default) or [-32.768, 32.768]^n (benchmark). Dimensions: Any n >= 1. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **AxisParallelHyperEllipsoid**: Convex, differentiable, separable, scalable. Minimum: 0.0 at (0, ..., 0). Bounds: [-Inf, Inf]^n. Dimensions: Any n >= 1. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Beale**: Multimodal, non-convex, differentiable, bounded. Minimum: 0.0 at (3.0, 0.5). Bounds: [-4.5, 4.5]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Bohachevsky**: Multimodal, non-convex, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-10, 10]^n. Dimensions: Any n >= 2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Branin**: Multimodal, differentiable, non-convex, non-separable, bounded. Minimum: 0.397887 at (-pi, 12.275), (pi, 2.275), (9.424778, 2.475). Bounds: [-5, 10] x [0, 15]. Dimensions: n=2. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Bukin6**: Multimodal, non-convex, partially differentiable, bounded. Minimum: 0.0 at (-10.0, 1.0). Bounds: [-15, -5] x [-3, 3]. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **CrossInTray**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -2.06261 at (1.3491, 1.3491), (-1.3491, 1.3491), (1.3491, -1.3491), (-1.3491, -1.3491). Bounds: [-10, 10]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **De Jong F5**: Multimodal, non-convex, non-separable, differentiable, bounded, finite_at_inf. Minimum: 0.9980038388186492 at (-32.0, -32.0). Bounds: [-65.536, 65.536]^2. Dimensions: n=2. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **DixonPrice**: Unimodal, non-convex, differentiable, scalable, bounded. Minimum: 0.0 at (2^(-(2^i - 2)/2^i), ..., 2^(-(2^n - 2)/2^n)). Bounds: [-10, 10]^n. Dimensions: Any n >= 1. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **DropWave**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.0 at (0, 0). Bounds: [-5.12, 5.12]^2. Dimensions: n=2. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Easom**: Unimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.0 at (pi, pi). Bounds: [-100, 100]^2. Dimensions: n=2. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Eggholder**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -959.6406627208506 at (512.0, 404.2318058008512). Bounds: [-512, 512]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **GoldsteinPrice**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 3.0 at (0, -1). Bounds: [-2, 2]^2. Dimensions: n=2. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Griewank**: Multimodal, non-convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-600, 600]^n. Dimensions: Any n >= 1. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Hartmann**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -3.86278214782076 at (0.114614, 0.555649, 0.852547) for n=3. Bounds: [0, 1]^n. Dimensions: n=3, 4, 6. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Himmelblau**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0.0 at (3.0, 2.0), (-2.805118, 3.131312), (-3.779310, -3.283186), (3.584428, -1.848126). Bounds: [-5, 5]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Keane**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -0.673667521146855 at (0.0, 1.393249070031784), (1.393249070031784, 0.0). Bounds: [0, 10]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Langermann**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: approximately -5.1621259 at (2.002992, 1.006096). Bounds: [0, 10]^2. Dimensions: n=2. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Levy**: Multimodal, non-convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (1, ..., 1). Bounds: [-10, 10]^n. Dimensions: Any n >= 1. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **McCormick**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.913222954981037 at (-0.547197553, -1.547197553). Bounds: [-1.5, 4] x [-3, 4]. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Michalewicz**: Multimodal, non-convex, separable, differentiable, scalable, bounded. Minimum: -1.8013 (n=2), -4.687658 (n=5), -9.66015 (n=10). Bounds: [0, pi]^n. Dimensions: Any n >= 1. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Quadratic**: Unimodal, convex, non-separable, differentiable, scalable. Minimum: c - 0.25 * b^T A^-1 b at -0.5 * A^-1 b, where A is a positive definite matrix, b is a vector, and c is a scalar (default: A random positive definite, b=0, c=0). Bounds: [-Inf, Inf]^n. Dimensions: Any n >= 1. The quadratic function encapsulates parameters A, b, c, set on the first call or overridden if provided, making it ideal for testing optimization algorithms on non-separable problems with varying condition numbers. Example usage: `quadratic(ones(2), Symmetric([2.0 0.0; 0.0 2.0]), [1.0, 1.0], 0.5)` sets custom parameters; subsequent calls to `quadratic(x)` reuse these parameters. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Rana**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -498.12463264808594 at (-500.0, -499.0733150925747). Bounds: [-500, 500]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Rastrigin**: Multimodal, non-convex, separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5.12, 5.12]^n. Dimensions: Any n >= 1. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Rosenbrock**: Unimodal, non-convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (1, ..., 1). Bounds: [-5, 5]^n. Dimensions: Any n >= 2. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **RotatedHyperEllipsoid**: Unimodal, convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-65.536, 65.536]^n. Dimensions: Any n >= 1. The rotated hyper-ellipsoid function, also known as the sum squares function, is a convex, scalable test function with a single global minimum, suitable for testing optimization algorithms on non-separable problems. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Schwefel**: Multimodal, non-convex, separable, differentiable, scalable, bounded. Minimum: 0.0 at (420.9687, ..., 420.9687). Bounds: [-500, 500]^n. Dimensions: Any n >= 1. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Shekel**: Multimodal, non-convex, non-separable, differentiable, bounded, finite_at_inf. Minimum: -10.536409825004505 at (4.0, 4.0, 4.0, 4.0) for m=10. Bounds: [0, 10]^4. Dimensions: n=4. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Shubert**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -186.7309 at multiple points, e.g., (-1.4251286, -0.800321). Bounds: [-10, 10]^2. Dimensions: n=2. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **SineEnvelope**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.0 at (0.0, 0.0). Bounds: [-100, 100]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **SixHumpCamelback**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -1.031628453489877 at (±0.08984201368301331, ±0.7126564032704135). Bounds: [-3, 3] x [-2, 2]. Dimensions: n=2. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Sphere**: Unimodal, convex, separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5.12, 5.12]^n. Dimensions: Any n >= 2. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **Step (De Jong F3)**: Unimodal, non-convex, separable, partially differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5.12, 5.12]^n. Dimensions: Any n >= 1. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **StyblinskiTang**: Multimodal, non-convex, differentiable, scalable, bounded. Minimum: -39.166165*n at (-2.903534, ..., -2.903534). Bounds: [-5, 5]^n. Dimensions: Any n >= 1. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **SumOfPowers**: Unimodal, convex, separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-1, 1]^n. Dimensions: Any n >= 1. [Molga & Smutnicki (2005)](http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf)
- **ThreeHumpCamel**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0.0 at (0.0, 0.0). Bounds: [-5, 5]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Zakharov**: Unimodal, convex, non-separable, differentiable, scalable, bounded. Minimum: 0.0 at (0, ..., 0). Bounds: [-5, 10]^n. Dimensions: Any n >= 1. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)

## Upcoming Test Functions

The following test functions are planned for implementation, based on standard benchmarks. They will be added with analytical gradients, metadata, and validation, consistent with the existing collection.

- **Booth**: Unimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0.0 at (1.0, 3.0). Bounds: [-10, 10]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Matyas**: Unimodal, convex, non-separable, differentiable, bounded. Minimum: 0.0 at (0.0, 0.0). Bounds: [-10, 10]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **HolderTable**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -19.2085 at (8.05502, 9.66459) and others. Bounds: [-10, 10]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Bird**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -106.764537 at (4.701055816, 3.15294602) and (-1.582142172, -3.130246801). Bounds: [-2π, 2π]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **DeckkersAarts**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -24777 at (0, 15) and (0, -15). Bounds: [-20, 20]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Giunta**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0.06447042 at (0.4583428, 0.4583428). Bounds: [-1, 1]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Kearfott**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -0.352386 at multiple points. Bounds: [-3, 4]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **MishraBird**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: -106.764537 at (-3.1302468, -1.5821422) and (-6.7745761, -2.4183762). Bounds: [-10, 0] x [-6.5, 0]. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **SchafferN1**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0 at (0,0). Bounds: [-100, 100]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **SchafferN2**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0 at (0,0). Bounds: [-100, 100]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **SchafferN4**: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0.292579 at (0,1.25313) and others. Bounds: [-100, 100]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Trid**: Unimodal, convex, non-separable, differentiable, scalable. Minimum: -n(n+4)(n-1)/6 at i*(n+1-i) for i=1 to n. Bounds: [-n^2, n^2]^n. Dimensions: Any n >= 2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Wood**: Unimodal, non-convex, non-separable, differentiable, fixed. Minimum: 0 at (1,1,1,1). Bounds: [-10,10]^4. Dimensions: n=4. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Powell**: Unimodal, non-convex, non-separable, differentiable, fixed. Minimum: 0 at (0,0,0,0). Bounds: [-4,5]^4. Dimensions: n=4. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Perm**: Unimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0 at (1,1/2,1/3,...,1/n). Bounds: [-n, n]^n. Dimensions: Any n >=1. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **PowerSum**: Unimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0 at specific point. Bounds: [0, n]^n. Dimensions: Any n >=1. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Colville**: Unimodal, non-convex, non-separable, differentiable, fixed. Minimum: 0 at (1,1,1,1). Bounds: [-10,10]^4. Dimensions: n=4. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **FreudensteinRoth**: Multimodal, non-convex, non-separable, differentiable, fixed. Minimum: 0 at (5,4, -0.5, -0.5). Bounds: [-10,10]^4. Dimensions: n=4. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Brown**: Multimodal, non-convex, non-separable, differentiable, scalable. Minimum: 0 at (0,0,...,0). Bounds: [-1,4]^n. Dimensions: Any n >=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **AlpineN1**: Multimodal, non-convex, separable, non-differentiable, scalable. Minimum: 0 at (0,0,...,0). Bounds: [-10,10]^n. Dimensions: Any n >=1. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **AlpineN2**: Multimodal, non-convex, separable, differentiable, scalable. Minimum: -2.808^n at (7.917,7.917,...,7.917). Bounds: [0,10]^n. Dimensions: Any n >=1. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **BartelsConn**: Multimodal, non-convex, non-separable, non-differentiable, fixed. Minimum: 1 at (0,0). Bounds: [-500,500]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **CarromTable**: Multimodal, non-convex, non-separable, differentiable, fixed. Minimum: -24.1568155165 at multiple. Bounds: [-10,10]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Chichinadze**: Multimodal, non-convex, non-separable, differentiable, fixed. Minimum: -43.3159 at (5.90133, 0.5). Bounds: [-30,30]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Cigar**: Unimodal, convex, non-separable, differentiable, scalable. Minimum: 0 at (0,0,...,0). Bounds: [-10,10]^n. Dimensions: Any n >=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **CosineMixture**: Multimodal, non-convex, separable, differentiable, scalable. Minimum: -0.1*n at multiple. Bounds: [-1,1]^n. Dimensions: Any n >=1. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Corana**: Multimodal, non-convex, separable, differentiable, fixed. Minimum: 0 at (0,0,0,0). Bounds: [-1000,1000]^4. Dimensions: n=4. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Csendes**: Unimodal, non-convex, separable, non-differentiable at 0, scalable. Minimum: 0 at (0,0,...,0). Bounds: [-1,1]^n. Dimensions: Any n >=1. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Cube**: Unimodal, non-convex, non-separable, differentiable, fixed. Minimum: 0 at (1,1,1). Bounds: [-10,10]^3. Dimensions: n=3. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)
- **Damavandi**: Multimodal, non-convex, non-separable, non-differentiable, fixed. Minimum: 0 at (2,2). Bounds: [0,14]^2. Dimensions: n=2. [Jamil & Yang (2013)](https://arxiv.org/abs/1308.4008)

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

Tests cover function evaluations, metadata validation, edge cases (NaN, Inf, 1e-308, empty input vectors, and bounds for bounded functions), and optimization with Optim.jl. For functions marked as `bounded`, tests verify finite values at the lower and upper bounds (`lb`, `ub`) instead of infinity, reflecting their constrained domain. Gradient tests are centralized in test/runtests.jl for consistency. All tests, including those for the newly added De Jong F5 function, pass as of the last update, ensuring robustness and correctness.

## License

This package is licensed under the MIT License. See LICENSE for details.

## Alternative Names for Test Functions

Some test functions are referred to by different names in the literature. Below is a list connecting the names used in this package to common alternatives.

- **ackley**: Ackley's function, Ackley No. 1, Ackley Path Function.
- **axisparallelhyperellipsoid**: Axis parallel hyper-ellipsoid function, Sum squares function, Weighted sphere model, Quadratic function (axis-aligned variant).
- **beale**: Beale's function.
- **bohachevsky**: Bohachevsky's function, Bohachevsky No. 1 (for the standard variant).
- **branin**: Branin's rcos function, Branin-Hoo function, Branin function.
- **bukin6**: Bukin function No. 6.
- **crossintray**: Cross-in-Tray function.
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

## References

- Molga, M., & Smutnicki, C. (2005). Test functions for optimization needs. http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf
- Jamil, M., & Yang, X.-S. (2013). A literature survey of benchmark functions for global optimisation problems. https://arxiv.org/abs/1308.4008
- Hedar, A.-R. (2005). Global optimization test problems. http://www-optima.amp.i.kyoto-u.ac.jp/member/student/hedar/Hedar_files/TestGO.htm
- Suganthan, P. N., et al. (2005). Problem definitions and evaluation criteria for the CEC 2005 special session on real-parameter optimization. IEEE CEC-Website.
- Al-Roomi (o. J.). Test Functions Repository. https://www.al-roomi.org
- https://www.geocities.ws/eadorio/mvf.pdf
