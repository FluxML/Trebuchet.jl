# Trebuchet.jl

Simulate and visualise a Trebuchet

## Add package
```julia
] add https://github.com/Roboneet/Trebuchet.jl
```

## Run example
```julia
# using Blink # if not on Juno or IJulia
using Trebuchet

t = TrebuchetState()
simulate(t)

target = 100 # or nothing
s = visualise(t, target)

if @isdefined(Blink)
  body!(Blink.Window(), s)
end

# to find the gradient w.r.t (wind_speed, release_angle, weight)
Trebuchet.grad([10.0, 1.0, 1.0])

```

Credits: http://www.virtualtrebuchet.com/#documentation_EquationsOfMotion
