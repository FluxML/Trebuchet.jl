module Trebuchet

using WebIO, JSExpr
using DifferentialEquations

export TrebuchetState, simulate, visualise, run

include("defs.jl")
include("utils.jl")
include("derive.jl")
include("transition.jl")
include("simulate.jl")
include("visualise.jl")

end
