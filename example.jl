include("index.jl")

t = Trebuchet()
simulate(t)

@show endTime(t), endDist(t)
visualise(t)
