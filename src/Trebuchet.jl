module Trebuchet

using WebIO, JSExpr
using DifferentialEquations
using ForwardDiff
using ForwardDiff: Dual, Partials

export TrebuchetState, simulate, visualise, run

include("defs.jl")
include("diff.jl")
include("utils.jl")
include("simulate.jl")
include("visualise.jl")

end
