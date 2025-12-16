# properties.md

# Test Function Properties

This page documents the **properties** used to classify benchmark functions in `NonlinearOptimizationTestFunctions.jl`.  
Properties are string tags stored in a `Set{String}` and describe mathematical characteristics of each function. They are rigorously validated against a fixed list to ensure consistency.

## Current Statistics (as of December 2025)

The package currently contains **205** benchmark functions.

Property distribution:

| Count | Property                  | Percentage |
|-------|---------------------------|------------|
| 196   | continuous                | 95.6%     |
| 173   | differentiable            | 84.4%     |
| 155   | bounded                   | 75.6%     |
| 147   | multimodal                | 71.7%     |
| 141   | non-separable             | 68.8%     |
| 73    | scalable                  | 35.6%     |
| 71    | non-convex                | 34.6%     |
| 55    | separable                 | 26.8%     |
| 55    | unimodal                  | 26.8%     |
| 24    | partially differentiable  | 11.7%     |
| 14    | convex                    | 6.8%      |
| 11    | controversial             | 5.4%      |
| 5     | has_noise                 | 2.4%      |
| 5     | highly multimodal         | 2.4%      |
| 4     | deceptive                 | 2.0%      |
| 4     | ill-conditioned           | 2.0%      |
| 3     | finite_at_inf             | 1.5%      |
| 3     | partially separable       | 1.5%      |

Total distinct properties: **18**

## Available Properties

The package defines the following valid properties:

| Property                  | Description                                                                 | Common Examples                  |
|---------------------------|-----------------------------------------------------------------------------|----------------------------------|
| bounded                   | Finite box constraints (`lb` and `ub` are defined and finite)               | beale, branin, michalewicz       |
| continuous                | Continuous everywhere in the domain                                         | Most functions                   |
| controversial             | Global minimum or value debated in literature                               | langermann                       |
| convex                    | Convex (unique global minimum)                                              | sphere, quadratic                |
| deceptive                 | Designed to mislead certain optimizers                                      | Rare                             |
| differentiable            | Differentiable everywhere                                                   | rosenbrock, ackley               |
| finite_at_inf             | Function value remains finite as variables → ±∞                             | Rare                             |
| fully non-separable       | Completely non-separable (strong interactions)                              | Rare                             |
| has_constraints           | Additional constraints beyond box bounds                                    | Rare in this package             |
| has_noise                 | Stochastic noise in evaluation                                              | quartic (noisy variants)         |
| highly multimodal         | Very large number of local minima                                           | rastrigin, weierstrass           |
| multimodal                | Multiple local minima                                                       | branin, eggholder                |
| non-convex                | Not convex                                                                  | ackley, rosenbrock               |
| non-separable             | Variables are coupled                                                       | rosenbrock, ackley               |
| partially differentiable  | Differentiable almost everywhere                                            | bartelsconn                      |
| partially separable       | Some variables independent                                                  | Rare                             |
| quasi-convex              | Quasi-convex                                                                | Rare                             |
| scalable                  | Defined for arbitrary dimension n ≥ 2                                       | rosenbrock, rastrigin            |
| separable                 | Fully separable (optimize each variable independently)                      | sphere, sumofpowers              |
| strongly convex           | Strongly convex                                                             | quadratic                        |
| unimodal                  | Single global minimum (no local minima)                                      | sphere                           |
| ill-conditioned           | Poorly conditioned Hessian (slow convergence)                               | rosenbrock                       |

> Only these properties are allowed. Adding new ones requires extending `VALID_PROPERTIES` and updating tests.

## Accessing Properties

Use dedicated accessor functions – **never** access `tf.meta[:properties]` directly.

### Primary Accessor

property(tf::TestFunction, prop::AbstractString) -> Bool

- Returns `true` if the property is present.
- Throws clear error for invalid names.

Example:
property(tf, "multimodal")   # → true or false

### Convenience Shortcuts

bounded(tf)         -> Bool
scalable(tf)        -> Bool
differentiable(tf)  -> Bool
multimodal(tf)      -> Bool
separable(tf)       -> Bool

### List All Properties

properties(tf::TestFunction) -> Vector{String}

- Returns sorted vector of all properties (alphabetical order).

Example:
properties(tf)
# → ["bounded", "continuous", "differentiable", "multimodal", "non-convex", "non-separable"]

### Filtering Functions by Property

The package provides a helper for easy filtering:

filter_testfunctions(predicate) -> Vector{TestFunction}

Examples:

# All bounded functions
bounded_funcs = filter_testfunctions(bounded)

# All multimodal functions
multimodal_funcs = filter_testfunctions(multimodal)

# Bounded AND scalable functions
bounded_scalable = filter_testfunctions(tf -> bounded(tf) && scalable(tf))

# Highly multimodal functions
highly_multimodal = filter_testfunctions(tf -> property(tf, "highly multimodal"))

# All convex functions
convex_funcs = filter_testfunctions(tf -> convex(tf))

This is the recommended way to explore or benchmark subsets of the collection.

## Other Metadata Accessors

| Accessor                     | Returns                                      | Notes                            |
|------------------------------|----------------------------------------------|----------------------------------|
| name(tf)                     | String (function name)                       | Direct field access              |
| dim(tf)                      | Int or -1 (if scalable)                      | -1 means arbitrary dimension     |
| start(tf, n=nothing)         | Vector{Float64} (start point)                | Requires n for scalable          |
| min_position(tf, n=nothing)  | Vector{Float64} (global minimizer)           | Requires n for scalable          |
| min_value(tf, n=nothing)     | Float64 (global minimum value)               | Requires n for scalable          |
| lb(tf, n=nothing)            | Vector{Float64} (lower bounds)               | Requires n for scalable          |
| ub(tf, n=nothing)            | Vector{Float64} (upper bounds)               | Requires n for scalable          |
| source(tf)                   | String (literature reference or "Unknown Source") | Fallback if missing         |

These accessors handle scalable functions automatically (pass `n` when needed).

## Design Philosophy

- **Consistency enforced**: Test suite checks logical implications and incompatibilities (e.g., `convex` cannot coexist with `multimodal`).
- **No raw metadata access**: Use accessors for future-proofing and clarity.
- **Extensible**: New properties can be added by updating `VALID_PROPERTIES` and tests.

For questions or to suggest new properties/functions, open an issue on the repository.