module Trebuchet

using WebIO, JSExpr
using DifferentialEquations

export TrebuchetState, simulate, visualise, run

include("defs.jl")
include("utils.jl")
include("simulate.jl")
include("visualise.jl")

end
