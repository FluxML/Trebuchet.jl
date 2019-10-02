# Trebuchet.jl

Simulate and visualise a Trebuchet.

## Add package
```julia
] add https://github.com/FluxML/Trebuchet.jl
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

```

## Note:
The code corresponding to [this](https://fluxml.ai/2019/03/05/dp-vs-rl.html) blog post can be found [here](https://github.com/FluxML/model-zoo/blob/10bd26ca21079b1c6ee246dd1938beab55178949/games/differentiable-programming/trebuchet/DiffRL.jl)

## References
http://www.virtualtrebuchet.com/#documentation_EquationsOfMotion
