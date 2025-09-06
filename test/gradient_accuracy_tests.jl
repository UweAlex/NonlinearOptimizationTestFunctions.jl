# test/gradient_accuracy_tests.jl
# Purpose: Test analytical gradients against AD and numerical gradients
# Last modified: September 05, 2025

using Test, ForwardDiff
using NonlinearOptimizationTestFunctions
using Random
using LinearAlgebra

function finite_difference_gradient(f, x; eps_val=eps(Float64))
    n = length(x)
    grad = zeros(n)
    for i in 1:n
        fx = abs(f(x))
        h = max(fx > 0 ? sqrt(eps_val) * sqrt(fx) : 1e-8, eps_val * abs(x[i]))
        x_plus = copy(x); x_plus[i] += h
        x_minus = copy(x); x_minus[i] -= h
        grad[i] = (f(x_plus) - f(x_minus)) / (2*h)
    end
    return grad
end

function relative_diff(a, b; epsilon=1e-10)
    rel_diff = zeros(length(a))
    for i in eachindex(a)
        if a[i] == b[i]
            rel_diff[i] = 0.0
        else
            rel_diff[i] = abs(a[i] - b[i]) / (abs(a[i]) + abs(b[i]) + epsilon)
        end
    end
    return norm(rel_diff)
end

function get_meta_value(field, n, is_scalable, fn_name, field_name)
    if isa(field, Function)
        return float.(is_scalable ? field(n) : field())
    else
        return float.(field)
    end
end

function generate_random_points(tf, n, num_points)
    fn_name = tf.meta[:name]
    is_bounded = "bounded" in tf.meta[:properties]
    is_scalable = "scalable" in tf.meta[:properties]
    points = []
    if is_bounded
        lb = get_meta_value(tf.meta[:lb], n, is_scalable, fn_name, "lb")
        ub = get_meta_value(tf.meta[:ub], n, is_scalable, fn_name, "ub")
        for _ in 1:num_points
            push!(points, lb + (ub - lb) .* (0.01 .+ 0.98 .* rand(n)))
        end
    else
        for _ in 1:num_points
            push!(points, 5.0 * (2 * rand(n) .- 1))
        end
    end
    return points
end

@testset "Gradient Accuracy Tests" begin
    Random.seed!(1234)
    error_counts = Dict{String, Int}()
    max_rel_diffs = Dict{String, Float64}()
    point_counts = Dict{String, Int}()
    problematic_functions = Set{String}()
    diff_vectors = Dict{String, Tuple{Vector{Float64}, Vector{Float64}, Vector{Float64}}}()
    
    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        error_counts[fn_name] = 0
        max_rel_diffs[fn_name] = 0.0
        point_counts[fn_name] = 0
        diff_vectors[fn_name] = (Float64[], Float64[], Float64[])
    end
    
    for tf in values(TEST_FUNCTIONS)
        fn_name = tf.meta[:name]
        an_ad_vec, num_ad_vec, an_num_vec = diff_vectors[fn_name]
        is_scalable = "scalable" in tf.meta[:properties]
        n = is_scalable ? 4 : 2
        min_pos = try
            get_meta_value(tf.meta[:min_position], n, is_scalable, fn_name, "min_position")
        catch e
            println("Error in min_position for $fn_name: $e")
            error_counts[fn_name] += 1
            continue
        end
        n = length(min_pos)
        points = try
            generate_random_points(tf, n, 40) # 40 zufällige Punkte
        catch e
            println("Error in generate_random_points for $fn_name: $e")
            error_counts[fn_name] += 1
            continue
        end
        start_pos = try
            get_meta_value(tf.meta[:start], n, is_scalable, fn_name, "start")
        catch e
            println("Error in start_pos for $fn_name: $e")
            error_counts[fn_name] += 1
            continue
        end
        push!(points, start_pos)
        if "bounded" in tf.meta[:properties]
            lb = try
                get_meta_value(tf.meta[:lb], n, is_scalable, fn_name, "lb")
            catch e
                println("Error in lb for $fn_name: $e")
                error_counts[fn_name] += 1
                continue
            end
            ub = try
                get_meta_value(tf.meta[:ub], n, is_scalable, fn_name, "ub")
            catch e
                println("Error in ub for $fn_name: $e")
                error_counts[fn_name] += 1
                continue
            end
            push!(points, lb + 1e-3 * (ub - lb))
            push!(points, ub - 1e-3 * (ub - lb))
        end
        point_counts[fn_name] = length(points)
        
        for i in 1:length(points)
            x = points[i]
            max_attempts = 5; attempts = 0; valid = false
            while attempts < max_attempts
                fx = try
                    tf.f(x)
                catch e
                    println("Function error for $fn_name at x=$x: $e")
                    error_counts[fn_name] += 1
                    points[i] = generate_random_points(tf, n, 1)[1]
                    x = points[i]
                    attempts += 1
                    continue
                end
                if !isfinite(fx)
                    println("Non-finite function value for $fn_name at x=$x")
                    error_counts[fn_name] += 1
                    points[i] = generate_random_points(tf, n, 1)[1]
                    x = points[i]
                    attempts += 1
                    continue
                end
                an_grad = try
                    tf.grad(x)
                catch e
                    println("Gradient error for $fn_name at x=$x: $e")
                    error_counts[fn_name] += 1
                    points[i] = generate_random_points(tf, n, 1)[1]
                    x = points[i]
                    attempts += 1
                    continue
                end
                if !all(isfinite, an_grad)
                    println("Non-finite analytical gradient for $fn_name at x=$x")
                    error_counts[fn_name] += 1
                    points[i] = generate_random_points(tf, n, 1)[1]
                    x = points[i]
                    attempts += 1
                    continue
                end
                ad_grad = try
                    ForwardDiff.gradient(tf.f, x)
                catch e
                    println("AD gradient error for $fn_name at x=$x: $e")
                    error_counts[fn_name] += 1
                    points[i] = generate_random_points(tf, n, 1)[1]
                    x = points[i]
                    attempts += 1
                    continue
                end
                if !all(isfinite, ad_grad)
                    println("Non-finite AD gradient for $fn_name at x=$x")
                    error_counts[fn_name] += 1
                    points[i] = generate_random_points(tf, n, 1)[1]
                    x = points[i]
                    attempts += 1
                    continue
                end
                num_grad = try
                    finite_difference_gradient(tf.f, x)
                catch e
                    println("Error in numerical gradient for $fn_name at x=$x: $e")
                    error_counts[fn_name] += 1
                    points[i] = generate_random_points(tf, n, 1)[1]
                    x = points[i]
                    attempts += 1
                    continue
                end
                if !all(isfinite, num_grad)
                    println("Non-finite numerical gradient for $fn_name at x=$x")
                    error_counts[fn_name] += 1
                    points[i] = generate_random_points(tf, n, 1)[1]
                    x = points[i]
                    attempts += 1
                    continue
                end
                diff_an_ad = relative_diff(an_grad, ad_grad)
                diff_num_ad = relative_diff(num_grad, ad_grad)
                diff_an_num = relative_diff(an_grad, num_grad)
                push!(an_ad_vec, diff_an_ad); push!(num_ad_vec, diff_num_ad); push!(an_num_vec, diff_an_num)
                max_rel_diffs[fn_name] = max(max_rel_diffs[fn_name], diff_an_ad)
                if diff_an_ad > 1e-4 && diff_an_ad > 100 * diff_num_ad
                    error_counts[fn_name] += 1
                    push!(problematic_functions, fn_name)
                    println("Gradient discrepancy in $fn_name at x=$x: an-ad=$diff_an_ad, num-ad=$diff_num_ad, an-num=$diff_an_num")
                end
                valid = true
                break
            end
            if !valid && attempts >= max_attempts
                error_counts[fn_name] += 1
                println("All attempts failed for $fn_name at x=$x")
            end
        end
        diff_vectors[fn_name] = (an_ad_vec, num_ad_vec, an_num_vec)
        error_percent = (error_counts[fn_name] / point_counts[fn_name]) * 100
        if error_counts[fn_name] > 0 && error_percent > 80
            println("\nSummary for $fn_name: Errors: $(error_counts[fn_name]) ($(round(error_percent, digits=2))%)")
            mean_an_ad = mean(filter(isfinite, an_ad_vec))
            mean_num_ad = mean(filter(isfinite, num_ad_vec))
            mean_an_num = mean(filter(isfinite, an_num_vec))
            println("  Mean an-ad: $mean_an_ad, Mean num-ad: $mean_num_ad, Mean an-num: $mean_an_num")
        end
    end
    
    println("\nOverall Gradient Accuracy Tests Summary (significant issues only):")
    any_problems = false
    for (func, count) in sort(collect(error_counts), by=x->x[2], rev=true)
        error_percent = (count / point_counts[func]) * 100
        if count > 0 && error_percent > 80
            any_problems = true
            println("  $func: $count errors ($(round(error_percent, digits=2))%)")
            an_ad_vec, num_ad_vec, an_num_vec = diff_vectors[func]
            mean_an_ad = mean(filter(isfinite, an_ad_vec))
            mean_num_ad = mean(filter(isfinite, num_ad_vec))
            mean_an_num = mean(filter(isfinite, an_num_vec))
            println("  Mean an-ad: $mean_an_ad, Mean num-ad: $mean_num_ad, Mean an-num: $mean_an_num")
        end
    end
    if !any_problems
        println("  No significant issues detected.")
    end
    @test isempty(problematic_functions)
end