using NPZ
using Optim
include("AlexOptimizer.jl")
using .AlexOptimizer

# === MNIST laden ===
train_x = npzread("..\mnist_train_x.npy")  # 784 × 60000
train_y = npzread("..\mnist_train_y.npy")  # 10 × 60000
N = size(train_x, 2)

# === Modell ===
function model(θ, x)
    W = reshape(θ[1:7840], 10, 784)
    b = θ[7841:end]
    return W * x .+ b
end

function softmax_cols(logits::Matrix{Float64})
    logits = logits .- maximum(logits, dims=1)
    exps = exp.(logits)
    return exps ./ sum(exps, dims=1)
end

function loss_and_grad(θ::Vector{Float64})
    W = reshape(θ[1:7840], 10, 784)
    b = θ[7841:end]
    logits = W * train_x .+ b
    probs = softmax_cols(logits)
    loss = -sum(train_y .* log.(probs)) / N
    delta = probs .- train_y
    dW = delta * train_x' / N
    db = sum(delta, dims=2) / N
    grad = vcat(vec(dW), vec(db))
    return loss, grad
end

# === Funktion für Optim.jl ===
f_calls = 0
g_calls = 0

function f(θ)
    global f_calls += 1
    loss, _ = loss_and_grad(θ)
    return loss
end

function g!(storage, θ)
    global g_calls += 1
    _, grad = loss_and_grad(θ)
    storage .= grad
end

# === Initialisierung ===
θ0 = randn(7840 + 10) * 0.01
max_iters = 50
tol = 1e-4
k_max = 30

# === L-BFGS Optimierung ===
println("== Optimierung mit L-BFGS ==")
f_calls = 0
g_calls = 0

result = Optim.optimize(f, g!, θ0, LBFGS(), Optim.Options(iterations = max_iters, g_tol = tol, store_trace = true))

θ_lbfgs = Optim.minimizer(result)
final_loss = loss_and_grad(θ_lbfgs)[1]
println("L-BFGS abgeschlossen.")
println("  Finaler Verlust       : $final_loss")
println("  Iterationen           : ", Optim.iterations(result))
println("  Funktionsauswertungen : $f_calls")
println("  Gradientenaufrufe     : $g_calls")

# === AlexOptimizer Optimierung ===
println("\n== Optimierung mit AlexOptimizer ==")
θ_alex, history, f_calls_alex, g_calls_alex = AlexOptimizer.optimize(loss_and_grad, θ0, k_max, 2*max_iters, tol)
final_loss_alex = loss_and_grad(θ_alex)[1]
println("AlexOptimizer abgeschlossen.")
println("  Finaler Verlust       : $final_loss_alex")
println("  Iterationen           : ", length(history)-1)
println("  Funktionsauswertungen : $f_calls_alex")
println("  Gradientenaufrufe     : $g_calls_alex")
