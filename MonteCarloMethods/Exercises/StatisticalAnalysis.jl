module StatisticalAnalysis

function deleteNJackknife(sample::Array{T,1}, f::Function, n::Int = 1) where T
    
    if isempty(methods(f, [Array{T,1}]))
        error("F must act on the array!")
    end
    
    sample = sample[1:(end-mod(length(sample),n))]
    N = Int(length(sample)/n);
    f_obs = f(sample)
    
    f_theta = Array{typeof(f_obs),1}()
    for k = 1:N
        
        trunc_sample = vcat(sample[1:n*(k-1)], sample[(n*k+1):end])
        push!(f_theta, f(trunc_sample))

    end

    f_var = (N-1)/N *sum( (f_theta[:] .- f_obs).^2 )
    f_sig = sqrt(f_var)

    f_bias = sum(f_theta[:]) / N
    return (f_obs - (N-1)*(f_bias - f_obs) , f_sig)
end

function sampleMean(sample::Array, f::Function = x->x)
    fx = f.(sample)
    N = length(sample)
    mean = sum(fx[:])/N
    
    return mean 
end

function sampleVariance(sample::Array, f::Function = x->x)
    df = f.(sample) .- sampleMean(sample,f);
    N = length(sample)
    var = sum(df[:].^2)/(N-1)
    
    return var
end

function sampleSkewness(sample::Array,  f::Function = x->x)
    df = f.(sample) .- sampleMean(sample,f);
    skew = sampleMean(df.^3) / sampleMean(df.^2)^(3/2) 

    return skew
end


function binning(samples::Array{T,1},  k_max::Int = 10000) where T

    mean_0 = sampleMean(samples)
    var_0  = sampleVariance(samples)

    k_max = Int(min(k_max, floor(length(samples)/100)))
    k_block = 1:k_max

    var_data = Array{Float64,1}()
    for k in k_block
        
        # blocking of data
        n_b = Int(floor(length(samples)/k))
        n_trunc = Int(n_b * k)

        data = reshape(samples[1:n_trunc], (n_b, k))
        mean_k = sum(data, dims = 2) ./ k
        var_k = sum((mean_k .- mean_0).^2) ./ (n_b - 1)
        
        push!(var_data, var_k/n_b)

    end 

    return sqrt(var_data[end]), var_data
end

end