using WebIO
using Blink
using JSExpr
using DifferentialEquations
using Plots

include("utils.jl")
include("simulate.jl")
include("visualise.jl")

ratio = 180/π
rad(x) = x/ratio
°(x) = x * ratio

l = Lengths(Val{:ft}(), 5.0, 6.792, 1.75, 2.0, 6.833, 0.727, 0.1245)
m = Masses(Val{:lb}(), 98.09, 0.328, 10.65)
c = Constants(0.0, 1.0, 1.0, 9.80665, rad(45))
t = Trebuchet(l, m, c, 60)
t.i = Inertias(1.0 |> lb_to_kg |> ft_to_m |> ft_to_m, t.i.ia)
