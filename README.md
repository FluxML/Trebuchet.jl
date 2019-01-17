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

t = TrebuchetState()
simulate(t)

if @isdefined(Blink)
  body!(Blink.Window(), visualise(t))
else
  visualise(t)
end

```

Credits: http://www.virtualtrebuchet.com/#documentation_EquationsOfMotion
