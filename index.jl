using WebIO
using Blink
using JSExpr
using DifferentialEquations
using Plots

include("utils.jl")
include("simulate.jl")
include("visualise.jl")

°(x) = x * π/180

l = Lengths(7.0, 8.0, 1.75, 2.0, 6.833, 0.52, 0.249)
m = Masses(98.09, 0.328, 1.65)
t = Trebuchet(l, m, °(45), 1.0, 1.0, 1.0)
