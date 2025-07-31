#test.jl


using LinearAlgebra, Statistics, Random, Optim, LineSearches
using Optim: optimize # Add this line
include("AlexOptimizer.jl")
using .AlexOptimizer

# === TESTPROBLEM ===
function quadratic_function(x, A)
    return 0.5 * dot(x, A * x)
end

function quadratic_gradient(x, A)
    return A * x
end

function create_quadratic_problem(n=100)
    A = Diagonal(1.0:n)
    x_star = zeros(n)
    f_star = 0.0
    return A, x_star, f_star
end

# === VERGLEICHSALGORITHMEN ===
mutable struct CallCounter
    f_calls::Int
    g_calls::Int
end

function sgd(x0, A, η=0.01, γ=0.9, max_iters=1000, tol=1e-10)
    counter = CallCounter(0, 0)
    x = copy(x0)
    v = zeros(length(x))
    history = Float64[]
    for iter in 1:max_iters
        fx = quadratic_function(x, A)
        grad = quadratic_gradient(x, A)
        counter.f_calls += 1
        counter.g_calls += 1
        push!(history, fx)
        v = γ * v + η * grad
        x = x - v
        if norm(x) < tol
            break
        end
    end
    return x, history, counter.f_calls, counter.g_calls
end

function adam(x0, A, c=0.1, β1=0.9, β2=0.999, ϵ=1e-8, max_iters=1000, tol=1e-10)
    counter = CallCounter(0, 0)
    x = copy(x0)
    m = zeros(length(x))
    v = zeros(length(x))
    t = 0
    history = Float64[]
    for iter in 1:max_iters
        fx = quadratic_function(x, A)
        grad = quadratic_gradient(x, A)
        counter.f_calls += 1
        counter.g_calls += 1
        push!(history, fx)
        t += 1
        m = β1 * m + (1 - β1) * grad
        v = β2 * v + (1 - β2) * (grad .^ 2)
        m_hat = m / (1 - β1^t)
        v_hat = v / (1 - β2^t)
        η = c / (100 * norm(grad) + 1e-6)
        x = x - η * m_hat ./ (sqrt.(v_hat) .+ ϵ)
        if norm(x) < tol
            break
        end
    end
    return x, history, counter.f_calls, counter.g_calls
end

function rmsprop(x0, A, c=0.1, γ=0.9, ϵ=1e-8, max_iters=1000, tol=1e-10)
    counter = CallCounter(0, 0)
    x = copy(x0)
    v = zeros(length(x))
    history = Float64[]
    for iter in 1:max_iters
        fx = quadratic_function(x, A)
        grad = quadratic_gradient(x, A)
        counter.f_calls += 1
        counter.g_calls += 1
        push!(history, fx)
        v = γ * v + (1 - γ) * (grad .^ 2)
        η = c / (100 * norm(grad) + 1e-6)
        x = x - η * grad ./ (sqrt.(v) .+ ϵ)
        if norm(x) < tol
            break
        end
    end
    return x, history, counter.f_calls, counter.g_calls
end

function lbfgs(x0, A, max_iters=1000, tol=1e-10)
    counter = CallCounter(0, 0)
    f(x) = begin
        counter.f_calls += 1
        quadratic_function(x, A)
    end
    g!(storage, x) = begin
        counter.g_calls += 1
        storage .= quadratic_gradient(x, A)
    end
    result = optimize(f, g!, x0, LBFGS(linesearch=LineSearches.HagerZhang()), Optim.Options(iterations=max_iters, x_tol=tol, store_trace=true))
    history = [tr.value for tr in Optim.trace(result)]
    return Optim.minimizer(result), history, counter.f_calls, counter.g_calls
end

function alex_optimize(x0, A, k_max=90, max_iters=1000, tol=1e-10)
    counter = CallCounter(0, 0)
    function loss_fn(x)
        counter.f_calls += 1
        counter.g_calls += 1
        fx = quadratic_function(x, A)
        grad = quadratic_gradient(x, A)
        return fx, grad
    end
    x, history = AlexOptimizer.optimize(loss_fn, x0, k_max, max_iters, tol)
    return x, history, counter.f_calls, counter.g_calls
end

# === TESTAUSFÜHRUNG ===
function run_test(n=100)
    A, x_star, f_star = create_quadratic_problem(n)
    x0 = fill(100.0, n)
    max_iters = 1000
    tol = 1e-10

    println("Testproblem: f(x) = 0.5 * x^T A x, A = diag(1, 2, ..., 100), x0 = (100, ..., 100)")
    println("Startpunkt f(x0) = ", quadratic_function(x0, A))
    println("Optimaler Wert f(x*) = $f_star")
    println("Abbruchkriterium: ||x||_2 < $tol\n")

    # SGD
    x_sgd, hist_sgd, f_calls_sgd, g_calls_sgd = sgd(x0, A, 0.01, 0.9, max_iters, tol)
    println("SGD: Funktionsaufrufe = $f_calls_sgd, Gradientenaufrufe = $g_calls_sgd, f(x) = ", quadratic_function(x_sgd, A), ", ||x||_2 = ", norm(x_sgd))

    # Adam
    x_adam, hist_adam, f_calls_adam, g_calls_adam = adam(x0, A, 0.1, 0.9, 0.999, 1e-8, max_iters, tol)
    println("Adam: Funktionsaufrufe = $f_calls_adam, Gradientenaufrufe = $g_calls_adam, f(x) = ", quadratic_function(x_adam, A), ", ||x||_2 = ", norm(x_adam))

    # RMSprop
    x_rmsprop, hist_rmsprop, f_calls_rmsprop, g_calls_rmsprop = rmsprop(x0, A, 0.1, 0.9, 1e-8, max_iters, tol)
    println("RMSprop: Funktionsaufrufe = $f_calls_rmsprop, Gradientenaufrufe = $g_calls_rmsprop, f(x) = ", quadratic_function(x_rmsprop, A), ", ||x||_2 = ", norm(x_rmsprop))

    # L-BFGS
    x_lbfgs, hist_lbfgs, f_calls_lbfgs, g_calls_lbfgs = lbfgs(x0, A, max_iters, tol)
    println("L-BFGS: Funktionsaufrufe = $f_calls_lbfgs, Gradientenaufrufe = $g_calls_lbfgs, f(x) = ", quadratic_function(x_lbfgs, A), ", ||x||_2 = ", norm(x_lbfgs))

    # Alex
    x_alex, hist_alex, f_calls_alex, g_calls_alex = alex_optimize(x0, A, 20, max_iters, tol)
    println("Alex: Funktionsaufrufe = $f_calls_alex, Gradientenaufrufe = $g_calls_alex, f(x) = ", quadratic_function(x_alex, A), ", ||x||_2 = ", norm(x_alex))
end

# === AUSFÜHRUNG ===
run_test(100)