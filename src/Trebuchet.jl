module Trebuchet

using WebIO, JSExpr
using OrdinaryDiffEq

export TrebuchetState, simulate, visualise, run, shoot

include("defs.jl")
include("utils.jl")
include("derive.jl")
include("transition.jl")
include("simulate.jl")
include("visualise.jl")

end
