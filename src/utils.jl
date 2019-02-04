using DiffEqBase: AbstractODESolution

function shoot((ws, angle, w))
  t = TrebuchetState(;wind_speed=ws, release_angle=angle, weight=w)
  if w <= 0
      @info "negative weight"
      return (t, sling_end(t).x)
  end
  simulate(t)
  (t, endDist(t))
end

shoot(x...) = shoot(x)

ft2m(x) = x*0.3048
lb2kg(x) = x*0.45359237

Lengths(::Val{:ft}, args...) = Lengths(ft2m.(args)...)
Masses(::Val{:lb}, args...) = Masses(lb2kg.(args)...)
Solution() = Solution([], [], [], [], [], [], [], -1, -1)

function TrebuchetState(;wind_speed::T=1.0, release_angle::T=deg2rad(45), weight::T=98.09) where {T<:Real}
    release_angle = asin(sin(release_angle))::T
    l = Lengths(Val{:ft}(), T.((5.0, 6.792, 1.75, 2.0, 6.833, 2.727, 0.1245))...)
    m = Masses(Val{:lb}(), T.((weight, 0.328, 10.65))...)
    c = Constants(T.((wind_speed, 1.0, 1.0, 9.80665, release_angle))...)
    t = TrebuchetState(l, m, c, T(60.0))
    t.i = Inertias(lb2kg(T(1.0)) |> ft2m |> ft2m , t.i.ia)
    return t
end

Base.display(s::Solution) = Base.show(stdin, s)
Base.show(io::IO, ::MIME"text/plain", s::Solution) = Base.show(io, s)
Base.show(io::IO, s::Solution) = println(io, "Solution($(length(s.WeightCG)))")

approx_less(a, b, atol=1e-2) = isapprox(a, b, atol=atol) || a < b

Base.:+(a::Vec, b::Vec) = Vec(a.x + b.x, a.y + b.y)
Base.:-(a::Vec, b::Vec) = Vec(a.x - b.x, a.y - b.y)
Base.:/(a::Vec, b::Number) = Vec(a.x/b, a.y/b)
polar(r, θ) = Vec(r*cos(θ), r*sin(θ))

function ∠(a::Vec)
    θ = atan(a.y/a.x)
    a.x >= 0 && return θ
    a.y >= 0 && return π + θ
    -π + θ
end

function sling_end(t)
   l, a = t.l, t.a
   b, e = l.b, l.e
   aq, sq = a.aq, a.sq

   p = polar(b, π/2 + aq)
   q = polar(e, π/2 + aq + sq)
   p + q
end

function sling_velocity(t::TrebuchetState)
    l, a, aw_ = t.l, t.a, t.aw
    e, b = l.e, l.b
    aq, sq = a.aq, a.sq
    aw, sw = aw_.aw, aw_.sw
    sling_velocity(t, b, e, aq, sq, aw, sw)
end

sling_velocity(t::TrebuchetState, u::Array) = sling_velocity(t, t.l.b, t.l.e, u[1], u[3], u[4], u[6])
sling_velocity(t::TrebuchetState, b, e, aq, sq, aw, sw) =
  polar(-e*(sw + aw),  sq + aq) + polar(-b*aw, aq)

projectile_angle(t::TrebuchetState, u::Array) =
  ∠(sling_velocity(t, u))

endTime(t::TrebuchetState) = t.sol.Time[end]
endDist(t::TrebuchetState) = t.sol.Projectile[end][1]

function expand(init::T, diff::T, end_ele::T) where {T}
    l = floor(Int, (end_ele - init + diff)/diff)
    arr = zeros(T, l)
    ele = init
    index = 1
    while index <= l
        arr[index] = ele
        ele += diff
        index += 1
    end
    return arr
end
