# Installation and Setup of NonlinearOptimizationTestFunctions.jl

The installation of the package is straightforward and is managed via the integrated **Julia Package Manager (Pkg)**.

### 1. Launching the Julia REPL

First, open a Julia session (REPL).

### 2. Standard Installation

You have two options for installing the package. Both methods result in the same compilation and setup:

#### Option A: Using Pkg Mode

Switch to Pkg mode by pressing the ] key in the Julia REPL. Then, use the `add` command:

    julia> ]
    (@v1.10) pkg> add NonlinearOptimizationTestFunctions

#### Option B: Using Julia Mode

Execute the following commands in the regular Julia REPL:

    julia> using Pkg
    julia> Pkg.add("NonlinearOptimizationTestFunctions")

The `Pkg.add` command automatically downloads and compiles the package and all necessary dependencies (such as `LinearAlgebra` or `ForwardDiff`).

### 3. Usage in the REPL

After installation, you can load the package and use it immediately:

    julia> using NonlinearOptimizationTestFunctions

    # Example: Call the Eggholder function at point (0, 0)
    julia> eggholder([0.0, 0.0])
    263.8569584730635

### 4. Installation of Additional Packages (Optional)

Many of the project's examples and benchmarks utilize external optimization frameworks. To leverage the package's full functionality and run the provided examples (like `benchmark_three_nm.jl` or `Optimize_with_nlopt.jl`), you must manually add these solvers.

The most important supported packages are:

| Purpose | Package | Installation Command |
| :--- | :--- | :--- |
| **Local Optimization** | Optim.jl | `Pkg.add("Optim")` |
| **SciML Interface** | Optimization.jl | `Pkg.add("Optimization")` |
| **NLopt Solvers** | NLopt.jl | `Pkg.add("NLopt")` |
| **Automatic Differentiation** | ForwardDiff.jl | `Pkg.add("ForwardDiff")` |
| **Constraints** (Future) | Ipopt.jl | `Pkg.add("Ipopt")` |

**Recommendation for Benchmarks:**

    julia> Pkg.add(["Optim", "NLopt", "Optimization"])

### 5. Updating

To keep the package and its dependencies up-to-date, you can use the `update` command in Pkg mode at any time:

    julia> ] # Switches to Pkg mode
    (@v1.10) pkg> update