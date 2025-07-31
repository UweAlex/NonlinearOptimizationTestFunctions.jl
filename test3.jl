import Pkg
Pkg.add("NPZ")
using MLDatasets
using NPZ
using Flux

# Hole MNIST und speichere es als .npz-Datei
train_x, train_y = MNIST.traindata()
train_x = Float64.(reshape(train_x, 28*28, :)) ./ 255.0
train_y = Flux.onehotbatch(train_y .+ 1, 1:10) |> Matrix{Float64}

# Speichern
npzwrite("mnist_train_x.npy", train_x)
npzwrite("mnist_train_y.npy", train_y)
