import MATLAB
include("StatisticalAnalysis.jl")
const StatA = StatisticalAnalysis

global LKR = 12

function lkr()

    a = 16807
    m = 2^31
    b = 1
    global LKR = mod(a*LKR, m) - b
    return  LKR/m
end


### TestRandomNumbers ###################################################

function testUniformity(generator::Function, N::Int, k::Int)

    # generate random numbers
    numbers = Array{Float64,1}()
    for i_number = 1:N
        push!(numbers, generator() )
    end

    moment_k = StatA.sampleMean(numbers.^k)
    sigma = sqrt(StatA.sampleVariance(numbers.^k) / N)
    moment_k_exact = 1/(k+1) 

    err = abs(moment_k - moment_k_exact)
    return (err, sigma, err/sigma)
end

function testIndependence(generator::Function, N::Int, k::Int, l::Int)

    # generate random numbers
    numbers_kl = Array{Float64,1}()
    for i_number = 1:N
        number = generator()^k * generator()^l
        push!(numbers_kl, number)
    end

    corr_kl = StatA.sampleMean(numbers_kl)
    sigma = sqrt(StatA.sampleVariance(numbers_kl) / N^2)
    coor_kl_exact = 1/(k+1)*1/(l+1) 

    err = abs(corr_kl - coor_kl_exact)
    return (err, sigma, err/sigma)
end

function testMarsaglia(generator::Function, d::Int, L::Int, N::Int)

    points_not_reached = Array{Float64,1}()

    lattice_dim = L*ones(Int, d)
    lattice = zeros(lattice_dim...)

    for i_point = 1:N 
        point = Array{Int, 1}(undef, d)
            for idx_d = 1:d
                point[idx_d] = Int(ceil(generator()*L))
            end
        lattice[point...] = 1 
        push!(points_not_reached, (1-sum(lattice)/L^d)*100)
    end

    msession = MATLAB.MSession()    # creates a MATLAB session
    MATLAB.put_variable(msession, :N, collect(1:N))  # put x to session s1
    MATLAB.put_variable(msession, :P, points_not_reached)
    MATLAB.eval_string(msession, "plot(N, P)")  # evaluate sin(x) in session s1
    close(msession)
end

function testHyperplane(generator::Function, N::Int)

    y = Array{Float64,1}()
    x = Array{Float64,1}()

    for i_point = 1:N
        push!(x, generator())
        push!(y, generator()) 
    end

    msession = MATLAB.MSession()    # creates a MATLAB session
    MATLAB.put_variable(msession, :x, x)  # put x to session s1
    MATLAB.put_variable(msession, :y, y)
    MATLAB.eval_string(msession, "plot(x, y, '.b')")  # evaluate sin(x) in session s1
    close(msession)
end

