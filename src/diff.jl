Base.Integer(x::Dual{T,V,N}) where {T,V,N} =
    Dual{T}(Int(value(x)), convert(Partials{N,Int}, partials(x)))

# just a hack for OrdinaryDiffEq.jl/src/solve.jl:378
Base.OneTo(x::Dual) = value(x)

function shoot((ws, angle, w))
  t = TrebuchetState(;wind_speed=ws, release_angle=angle, weight=w)
  simulate(t)
  (t, endDist(t))
end

grad(x) = ForwardDiff.gradient((x) -> shoot(Tuple(x))[2], x)

# x - 1
Base.prevfloat(x::Dual{T, V, N}) where {T,V,N} = Dual{T}(prevfloat(x.value), x.partials)
