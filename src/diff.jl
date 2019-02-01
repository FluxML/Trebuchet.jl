Base.Integer(x::Dual{T,V,N}) where {T,V,N} =
    Dual{T}(Base.Integer(x.value), zero(Partials{N,Base.Integer}))

# just a hack for OrdinaryDiffEq.jl/src/solve.jl:389
Base.OneTo(x::Dual) = Base.OneTo(x.value)

function shoot((ws, angle, w))
  t = TrebuchetState(;wind_speed=ws, release_angle=angle, weight=w)
  simulate(t)
  (t, endDist(t))
end

grad(x) = ForwardDiff.gradient((x) -> shoot(Tuple(x))[2], x)
