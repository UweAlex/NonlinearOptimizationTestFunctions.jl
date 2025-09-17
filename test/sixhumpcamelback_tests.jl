using Test, Optim, ForwardDiff, LinearAlgebra
using NonlinearOptimizationTestFunctions: SIXHUMPCAMELBACK_FUNCTION, sixhumpcamelback, sixhumpcamelback_gradient, SIXHUMPCAMELBACK_MINIMA

function finite_difference_gradient(f, x, h=1e-6)
    n = length(x)
    grad = zeros(n)
    for i in 1:n
        x_plus = copy(x)
        x_minus = copy(x)
        x_plus[i] += h
        x_minus[i] -= h
        grad[i] = (f(x_plus) - f(x_minus)) / (2h)
    end
    return grad
end

@testset "Six-Hump Camelback Tests" begin
    tf = SIXHUMPCAMELBACK_FUNCTION
    n = 2

    @testset "Basic Tests" begin
        @test tf.meta[:name] == "sixhumpcamelback"
        @test tf.meta[:dimension] == 2
        @test tf.meta[:lb]() == [-3.0, -2.0]
        @test tf.meta[:ub]() == [3.0, 2.0]
        @test tf.meta[:min_value]() ≈ -1.031628453489877 atol=1e-6
        @test_throws ArgumentError sixhumpcamelback([1.0])
        @test isnan(sixhumpcamelback([NaN, 0.0]))
        @test isinf(sixhumpcamelback([Inf, 0.0]))
        @test isfinite(sixhumpcamelback([0.0, 0.0]))
        min_pos = tf.meta[:min_position]()
        @test begin
            if isapprox(min_pos, [0.08984201368301331, -0.7126564032704135], atol=1e-6) ||
               isapprox(min_pos, [-0.08984201368301331, 0.7126564032704135], atol=1e-6)
                true
            else
                false
            end
        end
    end
end