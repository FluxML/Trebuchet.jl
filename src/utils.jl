using DiffEqBase: AbstractODESolution

ft2m(x) = x*0.3048
lb2kg(x) = x*0.45359237

Lengths(::Val{:ft}, args...) = Lengths(ft2m.(args)...)
Masses(::Val{:lb}, args...) = Masses(lb2kg.(args)...)
Solution() = Solution([], [], [], [], [], [], [], -1, -1)

function TrebuchetState(;wind_speed::T=1.0, release_angle::T=deg2rad(45), weight::T=98.09) where {T<:Float64}
    l = Lengths(Val{:ft}(), 5.0, 6.792, 1.75, 2.0, 6.833, 2.727, 0.1245)
    m = Masses(Val{:lb}(), weight, 0.328, 10.65)
    c = Constants(wind_speed, 1.0, 1.0, 9.80665, release_angle)
    t = TrebuchetState(l, m, c, 60)
    t.i = Inertias(lb2kg(1.0) |> ft2m |> ft2m , t.i.ia)
    return t
end

Base.display(s::Solution) = Base.show(stdin, s)
Base.show(io::IO, ::MIME"text/plain", s::Solution) = Base.show(io, s)
Base.show(io::IO, s::Solution) = println(io, "Solution($(length(s.WeightCG)))")

derive!(t::TrebuchetState, sol::AbstractODESolution) = derive(t, sol, t.sol)
function derive(t::TrebuchetState, sol::AbstractODESolution, s = Solution())
    stage = t.stage
    p = tuples(sol)
    for (x, y) in p
        derive(t, x, y, stage, s)
    end
    transition(t, p[end][1], stage)
    return s
end

transition(t::TrebuchetState, s::Array) = transition(t::TrebuchetState, s::Array, t.stage)

function transition(t::TrebuchetState, s::Array, ::Val{:Ground})
    t.stage = Val{:Hang}()
    t.aw = AnglularVelocities(s[4:6]...)
    t.a = Angles(s[1:3]...)
end

function transition(t::TrebuchetState, s::Array, ::Val{:Hang})
    t.stage = Val{:Released}()
    t.aw = AnglularVelocities(s[4:6]...)
    t.a = Angles(s[1:3]...)
    t.p = sling_end(t)
    t.v = sling_velocity(t)
end

function transition(t::TrebuchetState, s::Array, ::Val{:Released})
    t.stage = Val{:End}()
end

function derive(t::TrebuchetState, a::Array, time, ::Union{Val{:Ground},Val{:Hang}}, s=Solution())
    (Aq, Wq, Sq,) = a
    l = t.l
    LAl, LAs, LW, LS, h = l.b, l.c, l.d, l.e, l.a
    LAcg = (LAl - LAs)/2
    SIN = sin
    COS = cos
    push!(s.WeightCG, [LAs*SIN(Aq) + LW*SIN(Aq+Wq), -LAs*COS(Aq) - LW*COS(Aq+Wq)])
    push!(s.WeightArm, [LAs*SIN(Aq), -LAs*COS(Aq)])
    push!(s.ArmSling, [-LAl*SIN(Aq), LAl*COS(Aq)])
    push!(s.Projectile, [-LAl*SIN(Aq) - LS*SIN(Aq+Sq), LAl*COS(Aq) + LS*COS(Aq+Sq)])
    push!(s.SlingEnd,[-LAl*SIN(Aq) - LS*SIN(Aq+Sq), LAl*COS(Aq) + LS*COS(Aq+Sq)])
    push!(s.ArmCG, [-LAcg*SIN(Aq), LAcg*COS(Aq)])
    push!(s.Time, time)
    return s
end

function derive(t::TrebuchetState, a::Array, time, ::Val{:Released}, s=Solution())
    (Px, Py,) = a
    l, an = t.l, t.a
    LAl, LAs, LW, LS, h = l.b, l.c, l.d, l.e, l.a
    Aq, Wq, Sq = an.aq, an.wq, an.sq
    LAcg = (LAl - LAs)/2
    SIN = sin
    COS = cos
    push!(s.WeightCG, [LAs*SIN(Aq) + LW*SIN(Aq+Wq), -LAs*COS(Aq) - LW*COS(Aq+Wq)])
    push!(s.WeightArm, [LAs*SIN(Aq), -LAs*COS(Aq)])
    push!(s.ArmSling, [-LAl*SIN(Aq), LAl*COS(Aq)])
    push!(s.Projectile, [Px, Py])
    push!(s.SlingEnd,[-LAl*SIN(Aq) - LS*SIN(Aq+Sq), LAl*COS(Aq) + LS*COS(Aq+Sq)])
    push!(s.ArmCG, [-LAcg*SIN(Aq), LAcg*COS(Aq)])
    push!(s.Time, time)
    return s
end

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
