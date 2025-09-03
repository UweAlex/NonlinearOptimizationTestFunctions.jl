# minima_tests.jl
# Purpose: Test gradients at minima and optimize gradient norm if necessary
# Last modified: September 03, 2025

using Test, Optim
using NonlinearOptimizationTestFunctions
using LinearAlgebra

function get_meta_value(field, n, is_scalable, fn_name, field_name)
    if isa(field, Function)
        return float.(is_scalable ? field(n) : field())
    else
        return float.(field)
    end
end

@testset "Gradient at Minima Tests" begin
    error_counts = Dict{String, Int}()
    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        error_counts[fn_name] = 0
    end
    
    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        is_cont = "continuous" in tf.meta[:properties] || "partially continuous" in tf.meta[:properties]
        is_diff = "differentiable" in tf.meta[:properties]
        is_part_diff = "partially differentiable" in tf.meta[:properties]
        is_scalable = "scalable" in tf.meta[:properties]
        if !is_cont
            println("Skipping $fn_name: not continuous")
            continue
        end
        if !is_diff || is_part_diff
            println("Skipping $fn_name: not differentiable or partially differentiable")
            continue
        end
        n = is_scalable ? 4 : 2
        min_pos = try
            get_meta_value(tf.meta[:min_position], n, is_scalable, fn_name, "min_position")
        catch e
            println("Skipping $fn_name: error in min_position: $e")
            error_counts[fn_name] += 1
            continue
        end
        min_fx = try
            tf.f(min_pos)
        catch e
            println("Skipping $fn_name: error in min_fx: $e")
            error_counts[fn_name] += 1
            continue
        end
        if !isfinite(min_fx)
            println("Skipping $fn_name: non-finite min_fx")
            error_counts[fn_name] += 1
            continue
        end
        is_bounded = "bounded" in tf.meta[:properties]
        inside_bounds = true
        if is_bounded
            lb = try
                get_meta_value(tf.meta[:lb], n, is_scalable, fn_name, "lb")
            catch e
                println("Skipping $fn_name: error in lb: $e")
                error_counts[fn_name] += 1
                continue
            end
            ub = try
                get_meta_value(tf.meta[:ub], n, is_scalable, fn_name, "ub")
            catch e
                println("Skipping $fn_name: error in ub: $e")
                error_counts[fn_name] += 1
                continue
            end
            for i in 1:n
                if isapprox(min_pos[i], lb[i], atol=1e-3) || isapprox(min_pos[i], ub[i], atol=1e-3)
                    inside_bounds = false
                    break
                end
            end
        end
        if !inside_bounds
            println("Skipping $fn_name: min_pos=$min_pos is on boundary")
            continue
        end
        try
            an_grad_min = tf.grad(min_pos)
            grad_norm = norm(an_grad_min)
            println("Checking $fn_name at min_pos=$min_pos: norm=$grad_norm, fx=$min_fx")
            if !isapprox(grad_norm, 0.0, atol=1e-3)
                println("Gradient not zero at alleged minimum for $fn_name. Optimizing gradient norm...")
                obj_func = x -> norm(tf.grad(x))^2
                res = optimize(obj_func, min_pos, LBFGS())
                new_pos = Optim.minimizer(res)
                new_norm = norm(tf.grad(new_pos))
                new_fx = tf.f(new_pos)
                println("Optimized position: $new_pos, new gradient norm: $new_norm, new fx=$new_fx")
            end
            @test isapprox(grad_norm, 0.0, atol=1e-3)
        catch e
            println("Error computing gradient for $fn_name at min_pos=$min_pos: $e")
            error_counts[fn_name] += 1
        end
    end
    
    println("\nOverall Gradient at Minima Tests Summary:")
    any_problems = false
    for (func, count) in sort(collect(error_counts), by=x->x[2], rev=true)
        if count > 0
            any_problems = true
            println("  $func: $count errors")
        end
    end
    if !any_problems
        println("  No issues detected.")
    end
end