include("index.jl")

t = Trebuchet(;wind_speed=10.0, release_angle=deg2rad(33.2))
simulate(t)

@show endTime(t), endDist(t)
visualise(t)
