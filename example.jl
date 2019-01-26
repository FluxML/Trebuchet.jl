using Trebuchet

function Base.run(ws, r)
    t = TrebuchetState(;wind_speed=ws, release_angle=deg2rad(r))
    simulate(t)
    scope = visualise(t)

    if @isdefined(IJulia) || @isdefined(Juno)
      return scope
    elseif @isdefined(Blink)
      body!(Blink.Window(), scope)
    else
      println("to visualise, use Blink or run this on Juno or IJulia")
    end
end


run(-10.0, 33.2)
