import MATLAB
include("StatisticalAnalysis.jl")
const StatA = StatisticalAnalysis

const RWalk =  Array{Tuple{Float64,Float64},1}

function walkRandom(N::Int, stepwidth::Float64 = 1.)

    track = RWalk()
    push!(track, (0.,0.))
    udlr = [(0,1), (0,-1), (1,0), (-1,0)]
    for i_step in 1:N
        push!(track, track[end] .+ rand(udlr).*stepwidth)
    end

    return track
    
end

function walkRandomNB(N::Int, stepwidth::Float64 = 1.)

    track = RWalk()
    push!(track, (0.,0.))
    udlr = [(0,1), (0,-1), (1,0), (-1,0)]
    last_dir = (0,0)
    for i_step in 1:N

        dir = rand(filter(x -> x != last_dir, udlr))
        push!(track, track[end] .+ dir.*stepwidth)
        last_dir = -1 .* dir
    end

    return track
    
end

function plotWalk(track::RWalk)

    x_cords = [ track[i_step][1] for i_step in 1:length(track) ]
    y_cords = [ track[i_step][2] for i_step in 1:length(track) ]

    msession = MATLAB.MSession()    # creates a MATLAB session
    MATLAB.put_variable(msession, :x, x_cords)  # put x to session s1
    MATLAB.put_variable(msession, :y, y_cords)
    MATLAB.eval_string(msession, "plot(x, y)")  # evaluate sin(x) in session s1
    MATLAB.eval_string(msession, "xlim( xlim() + [-1,1])")  # evaluate sin(x) in session s1
    MATLAB.eval_string(msession, "ylim( ylim() + [-1,1])")  # evaluate sin(x) in session s1
    close(msession)

end

function distanceWalked(track::RWalk)
    
    return sqrt(track[end][1]^2 + track[end][2]^2)
end


function main()

    # parameter
    N = 10000 # number of walks
    n = 100 # steps per walk  
    dx = 1. # stepsize

    # evaluate random walks with backtrack
    r_walks = [walkRandom(n, dx) for i_walk in 1:N ]
    d_walks = distanceWalked.(r_walks)
    
    d_mean, sig = StatA.deleteNJackknife(d_walks, StatA.sampleMean)
    d_max = max(d_walks...)

    # evaluate random walks without backtrack
    r_walks_nb = [walkRandomNB(n, dx) for i_walk in 1:N ]
    d_walks_nb = distanceWalked.(r_walks_nb)

    d_mean_nb, sig_nb = StatA.deleteNJackknife(d_walks_nb, StatA.sampleMean)
    d_max_nb = max(d_walks_nb...)

    ## display results
    println("Mean distance walked d = $(d_mean) +- $(sig)")
    println("Maximum distance walked d = $(d_max)")
    println("Mean distance walked without backtrack d = $(d_mean_nb) +- $(sig_nb)")
    println("Maximum distance walked without backtrack d = $(d_max_nb)")
    return
end