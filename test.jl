include("index.jl")

vis = init(t)

function animate(t::Trebuchet, o::Observable, time, sol, i, f)
   (i > length(sol)) && return i

   f(sol[i]) && return i
   @show i
   a = Angles(sol[i][1], sol[i][2], sol[i][3])
   d = deepcopy(o.val)
   d["angles"] = a
   o[] = d
   sleep(time)
   t.a = a
   animate(t, o, time, sol, i+1, f)
end

ground_sol = simulate(t, Val{:Ground}())
i_end = animate(t, vis.o, t.rate/1000, ground_sol, 1, (sol) -> false)

s = derive(t, ground_sol)

println("ground derived")

hang_sol = simulate(t, t.stage)

println("hang simulated")

j_end = animate(t, vis.o, t.rate/1000, hang_sol, 1, (sol) -> false)
