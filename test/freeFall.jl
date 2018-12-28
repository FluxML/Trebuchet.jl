using DifferentialEquations
using Plots

struct Params
    C
    g
    m
    H
end

p = Params(1.0, 9.8, 5.0, 1.0)

function freeFall!(du, u, p, t)
    C, g, m = p.C, p.g, p.m
    du[1] = u[2]
    du[2] = C/m * u[2]^2 - g
end


tspan = (0, 1.0)
ODEProblem(freeFall!, [p.H, 0.0], tspan, p) |> solve |> plot!
