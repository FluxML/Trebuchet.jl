include("index.jl")

vis = init(t)

function animate(o::Observable, time, sol, i)
   (i > length(sol)) && return
   a = Angles(0.0, sol.u[i][1], sol[i][2], sol[i][3])
   a.aq + a.sq < π && return
   @show i
   d = deepcopy(o.val)
   d["angles"] = a
   o[] = d
   sleep(time)
   animate(o, time, sol, i+1)
end

ground_sol = simulate(t, Val{:Ground}())
animate(vis.o, .4, ground_sol, 1)
