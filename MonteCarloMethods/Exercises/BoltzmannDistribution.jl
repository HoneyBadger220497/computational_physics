import MATLAB
import Distributions

include("StatisticalAnalysis.jl")
const StatA = StatisticalAnalysis

function randBoltzLE(N::Int, dt)

    eta = Distributions.Normal(0., 1)

    function langewin_Update(x, dt)
        x_new = x + (2/x - x)*dt + rand(eta)*sqrt(2*dt)
        
        while x_new <= 0
            x_new = x + (2/x - x)*dt + rand(eta)*sqrt(2*dt)
        end

        return x_new
    end

    numbers = Array{Float64,1}()
    
    # thermailze
    x = 2
    t_therm = 10 
    n_therm = Int(ceil(t_therm/dt))
    for i_l = 1:n_therm

        x = langewin_Update(x, dt)
    end

    # generate numbers
    t_meas = 0.1
    n_meas = Int(ceil(t_meas/dt))
    for i_m = 1:N

        for i_l = 1:n_meas
            x = langewin_Update(x, dt)
        end

        push!(numbers, x)
    end

    return numbers
end

function randBoltzRejU(N::Int)

    h(x) = 0.1
    p(x) = sqrt(2/pi) * x^2 * exp(-x^2/2)
    ch = 10*sqrt(2)^3/sqrt(pi) * exp(-1)

    numbers = Array{Float64,1}()
    n = 0
    a_rate = 0
    while length(numbers)<N
        x = 10*rand()
        if rand() <= p(x)/(ch*h(x))
            push!(numbers, x)
            a_rate += 1
        end
        n += 1
    end 

    a_rate = a_rate / n
    return (numbers, a_rate)

end

function randBoltzRejG(N::Int)

    d = Distributions.Normal(2., 1.)
    td = Distributions.truncated(d, 0.0, 10)

    p(x) = sqrt(2/pi) * x^2 * exp(-x^2/2)

    g(x) = exp(-(x-2)^2/2)  / sqrt(2*pi)
    cg = 2.1

    numbers = Array{Float64,1}()
    n = 0
    a_rate = 0
    while length(numbers)<N
        x = rand(td)
        if rand() <= p(x)/(cg*g(x))
            push!(numbers, x)
            a_rate += 1
        end
        n += 1
    end 

    a_rate = a_rate / n
    return (numbers, a_rate)

end

function randBoltzMC(N::Int, sig::Float64 = 0.1)

    d = Distributions.Normal(0., sig)

    # define desired probability distribution
    p(x) = sqrt(2/pi) * x^2 * exp(-x^2/2)

    # difine proposal subroutine
    function proposeUpdate(x)

        x_prime = x + rand(d)
        while x_prime < 0
            x_prime = x + rand(d)
        end

        return x_prime
    end

    # init storage
    numbers = Array{Float64,1}(undef, N)

    # thermailze
    x = 2
    n_therm = 1000
    n = 0;
    for j = 1:n_therm
        x_prime = proposeUpdate(x)
        if rand() <= min(1, p(x_prime)/p(x))
            x = x_prime
        end
    end

    # calculate numbers
    n_measure = 100
    for j = 1:N
        
        for r = 1:n_measure
            x_prime = proposeUpdate(x)
            if rand() <= min(1, p(x_prime)/p(x))
                x = x_prime
            end
        end
        
        numbers[j] = x
        
    end
    
    return numbers
end

function plotDistributions()

    h(x) = 0.1
    g(x) = exp(-(x-2)^2/2)  / sqrt(2*pi)
    p(x) = sqrt(2/pi) * x^2 * exp(-x^2/2)

    Ch = 10*sqrt(2)^3/sqrt(pi) * exp(-1)
    Cg = 2.1 
    x = 0:0.01:10

    msession = MATLAB.MSession()    # creates a MATLAB session
    MATLAB.put_variable(msession, :x, x) 
    MATLAB.put_variable(msession, :h, Ch.*h.(x))
    MATLAB.put_variable(msession, :g, Cg.*g.(x))
    MATLAB.put_variable(msession, :p, p.(x))
    MATLAB.eval_string(msession, "plot(x, h, '-r')") 
    MATLAB.eval_string(msession, "hold on") 
    MATLAB.eval_string(msession, "plot(x, p, '-b')") 
    MATLAB.eval_string(msession, "plot(x, g, '-m')") 
    MATLAB.eval_string(msession, "hold off") 
    close(msession)

end

function testNumbers(numbers::Array{Float64,1}, n_b::Int = 1)

    # calc mean 
    m, m_sig = StatA.deleteNJackknife(numbers, StatA.sampleMean, n_b)
    m_sol = sqrt(2)^3/sqrt(pi)

    println("Mean:")
    println("Mean = $(m) +- $(m_sig)")
    println("Mean_exact = $(m_sol)")
    println("The difference = $(abs(m - m_sol)) ~ $(abs(m - m_sol)/m_sig)")

    # calc variance
    v, v_sig = StatA.deleteNJackknife(numbers, StatA.sampleVariance, n_b)
    v_sol = (3*pi-8) / pi
    println("Variance:")
    println("Var = $(v) +- $(v_sig)")
    println("Var_exact = $(v_sol)")
    println("The difference = $(abs(v - v_sol)) ~ $(abs(v - v_sol)/v_sig)")

    # calc scewness
    s, s_sig = StatA.deleteNJackknife(numbers, StatA.sampleSkewness, n_b)
    s_sol = sqrt(2)^3*(16-5*pi) / (3pi-8)^(3/2)
    println("Skewness:")
    println("Skew = $(s) +- $(s_sig)")
    println("Skew_exact = $(s_sol)")
    println("The difference = $(abs(s - s_sol)) ~ $(abs(s - s_sol)/s_sig)")
    return
end

function calcAutoCorrelation(A::Array{Float64,1}, t_max::Int)

    mu = StatA.sampleMean(A)
    var = StatA.sampleVariance(A)

    ac = Array{Float64,1}(undef,t_max)
    N = length(A)
    for t = 1:t_max

        n = N-t
        A_i   = A[1:n]
        A_ipt = A[(1+t):(n+t)]

        A_i_bar    = StatA.sampleMean(A_i)
        A_ipt_bar  =StatA.sampleMean(A_ipt)

        ac[t] = sum(  (A_i .-A_i_bar).*(A_ipt .- A_ipt_bar)  ) / 
                sqrt(sum((A_i .- A_i_bar).^2) * sum((A_ipt .- A_ipt_bar).^2))
    end

    return ac
end

function plotAutoCorrelations(ac::Array{Float64,1}, dt::Float64)

    t = collect(1:length(ac)) .* dt

    msession = MATLAB.MSession()    # creates a MATLAB session
    MATLAB.put_variable(msession, :t, t) 
    MATLAB.put_variable(msession, :ac, ac)
    MATLAB.eval_string(msession, "plot(t, ac, '-r')") 

    close(msession)
end

function estimateAutoCorrelationTime(ac::Array{Float64,1})

    return 1/2 + sum(ac)
end

function plotBinning(numbers::Array{Float64,1}, N_max::Int=1000)
    sig,var_data = StatA.binning(numbers, N_max)
    t = 1:length(var_data) 

    msession = MATLAB.MSession()    # creates a MATLAB session
    MATLAB.put_variable(msession, :t, t) 
    MATLAB.put_variable(msession, :v, sqrt.(var_data))
    MATLAB.eval_string(msession, "plot(t, v, '-r')") 

    close(msession)

end