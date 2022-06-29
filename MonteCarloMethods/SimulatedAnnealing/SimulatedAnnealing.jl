import Random
import StatsBase
import MATLAB
using ProgressMeter

function genProposal(state::Array{Float64,2})

    proposal = copy(state)

    n, = size(state)
    idx1, idx2 = StatsBase.sample(2:(n-1), 2, replace=false)

    #swap states
    proposal[[idx1, idx2],:] .= proposal[[idx2, idx1],:] 

    return proposal
end

function costFunction(state::Array{Float64,2})

    cost = diff(state, dims = 1).^2
    cost = sqrt.(sum(cost, dims = 2))
    cost = sum(cost)

    return cost
end

function simulatedAnnealing(inital_state::T, N_s::Int, beta::Array{Float64}, cost_fnc::Function, proposal_fnc::Function) where T 

    data = Array{Array{T,1},1}() 

    state = inital_state
    @showprogress "Minimizing " for j in 1:length(beta)

        b = beta[j]

        states_for_beta = Array{T,1}() 
        for k in 1:N_s
            trial_state = proposal_fnc(state)

            delta_cost = cost_fnc(trial_state) - cost_fnc(state)
            p = min(1, exp(-b*delta_cost))
            if rand() <= p
                state = trial_state
            end

            push!(states_for_beta, state)
        end 
        push!(data, states_for_beta)   

    end

    return data

end

function sampleMean(sample::Array, f::Function = x->x)
    fx = f.(sample)
    N = length(sample)
    return sum(fx[:])/N
end

function sampleVariance(sample::Array, f::Function = x->x)
    df = f.(sample) .- sampleMean(sample,f);
    N = length(sample)
    var = sum(df[:].^2)/(N-1)  
end

function sampleMax(sample::Array, f::Function = x->x)
    fx = f.(sample)
    return max(fx...)
end
   
function sampleMin(sample::Array, f::Function = x->x)
    fx = f.(sample)
    return min(fx...)
end

function main()

    n_dots = 20;
    idx = Random.randperm!(collect(1:n_dots))
    phi = rand(n_dots)*2*pi
    phi = phi[idx]
    inital_state = hcat(3*cos.(phi), 2*sin.(phi))
    inital_state = vcat(inital_state, transpose(inital_state[1,:]))

    #r = 1
    #phi = collect(1:10) .* (2*pi)/10
    #circle = hcat(r*cos.(phi), r*sin.(phi))
    #cluster_1 = hcat(r*cos.(phi) .+ 4, r*sin.(phi) .+ 0)  
    #cluster_2 = hcat(r*cos.(phi) .+ 0, r*sin.(phi) .+ 4)
    #cluster_3 = hcat(r*cos.(phi) .+ 0, r*sin.(phi) .- 4)

    #points = vcat(cluster_1, cluster_2, cluster_3)
    #idx = Random.randperm!(collect(1:length(points[:,1])))
    #inital_state = points[idx, :]
    #inital_state = vcat(points, transpose(points[1,:]))

    N_s = 1000

    delta_beta = 0.02
    beta_max = 10
    beta_min = 0.1

    beta = collect(beta_min:delta_beta:beta_max)

    data = simulatedAnnealing(inital_state, N_s, beta, costFunction, genProposal)

    # data evaluation
    configs = Array{Array{Float64,2},1}()
    configs_label = Array{Float64, 1}()
    
    @showprogress "Progress data " for j = 1:length(beta)

        configs = vcat(configs, data[j])
        configs_label = vcat(configs_label, beta[j]*ones(N_s,1))
    end
    cost_avg = sampleMean.(data, costFunction)
    cost_var = sampleVariance.(data, costFunction) 
    cost_max = sampleMax.(data, costFunction)
    cost_min = sampleMin.(data, costFunction)

    MATLAB.write_matfile("simulatedAnnealing.mat"; 
        inital_state = inital_state,
        configs = configs,
        configs_label = configs_label,
        beta = beta,
        cost_avg = cost_avg,
        cost_var = cost_var,
        cost_min = cost_min,
        cost_max = cost_max)

    return data
end
