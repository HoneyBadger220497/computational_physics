import MATLAB
import Distributions

using Trapz



function classicIntegral(a::Float64, b::Float64)

    phi = collect(range(0,2*pi, length = 10000))
    p = exp.( 1im * b * cos.(phi) .+ 1im * a .* phi) 

    z_real = trapz(phi, real.(p))
    z_imag = trapz(phi, imag.(p))
    z = z_real .+ 1im * z_imag

    f = exp.(1im * phi) .* p
    f_bar_real = trapz(phi, real.(f))
    f_bar_imag = trapz(phi, imag.(f))
    f_bar = f_bar_real .+ 1im * f_bar_imag

    return  f_bar/z
end

function langevinIntegration(a::Float64, b::Float64)

    ### generate phi with langevin
    eta = Distributions.Normal(0., 1)
    dt = 0.0001
    t_therm = 10 
    t_meas = 0.1
    x = pi
    N = 10000

    function langewin_Update(x, dt)

        ds = 1im*b*sin(x) - 1im*a
        x_new = x - ds*dt + rand(eta)*sqrt(2*dt)

        return x_new
    end

    phi = Array{Complex{Float64},1}()
    
    # thermailze
    n_therm = Int(ceil(t_therm/dt))
    for i_l = 1:n_therm

        x = langewin_Update(x, dt)
    end

    # generate phi
    n_meas = Int(ceil(t_meas/dt))
    for i_m = 1:N

        for i_l = 1:n_meas
            x = langewin_Update(x, dt)
        end

        push!(phi, x)
    end

    ### estimate mean
    mean = sum(exp.(1im*phi)) / N

    println("scatter plot")
    msession = MATLAB.MSession()    # creates a MATLAB session
    MATLAB.put_variable(msession, :phi, phi) 
    MATLAB.eval_string(msession, "plot(real(phi), imag(phi), '.b')") 
    close(msession)

    return mean
end