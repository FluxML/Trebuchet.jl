# Trebuchet.jl

Simulate and visualise a Trebuchet

## Add package
```
] add https://github.com/Roboneet/Trebuchet.jl
```

## Run example
```
# using Blink # if not on Juno or IJulia
using Trebuchet

t = TrebuchetState(;wind_speed=10.0, release_angle=deg2rad(33.25))
simulate(t)
scope = visualise(t)

if @isdefined(Blink)
  body!(Blink.Window(), scope)
end

```

Credits: http://www.virtualtrebuchet.com/#documentation_EquationsOfMotion
