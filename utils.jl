using DiffEqBase: AbstractODESolution

struct Lengths{T <: Float64}
    a::T # height of pivot
    b::T # length of long arm
    c::T # length of short arm
    d::T # lenght of weight arm
    e::T # length of sling
    u::T # radius of weight
    z::T # radius of projectile
end

ft_to_m(x) = x/3.281
Lengths(::Val{:ft}, args...) = Lengths(ft_to_m.(args)...)

struct Masses{T<:Float64}
    w::T # mass of weight
    p::T # mass of projectile
    a::T # mass of arm
end

lb_to_kg(x) = x/2.205
Masses(::Val{:lb}, args...) = Masses(lb_to_kg.(args)...)

struct Angles{T<:Float64} # in radians
    aq::T # angle between pivot stand and arm
    wq::T # angle between arm and weight
    sq::T # angle between arm and sling
end

struct AnglularVelocities{T<:Float64}
    aw::T # for aq
    ww::T # for wq
    sw::T # for sq
end

struct Inertias{T<:Float64}
    iw::T # inertia of weight
    ia::T # inertia of arm
end

struct Vec{T<:Float64}
    x::T
    y::T
end

struct Constants{T<:Float64}
    w::T # wind speed
    ρ::T # Density of Air
    Cd::T # Drag Co-efficient of Projectile
    Grav::T
    r::T # release angle of projectile [input]
end

struct Solution
    WeightCG
    WeightArm
    ArmSling
    Projectile
    SlingEnd
    ArmCG
    Time
    ReleaseVelocity
    ReleasePositon
end

Solution() = Solution([], [], [], [], [], [], [], -1, -1)

mutable struct Trebuchet
    l::Lengths
    m::Masses
    a::Angles
    aw::AnglularVelocities
    c::Constants
    i::Inertias
    stage::Union{Val{:Ground},Val{:Hang},Val{:Released},Val{:End}}
    rate::Integer
    function Trebuchet(l::Lengths, m::Masses, c, rate)
        θ = asin(l.a/l.b)
        sq = π - θ
        aq = π/2 + θ
        wq = -aq
        ai = m.a*((l.b + l.c)^2)/12
        wi = m.w*(l.u)^2/2 # inertia for disk
        a = Angles(aq, wq, sq)
        aw = AnglularVelocities(0.0, 0.0, 0.0)
        i = Inertias(wi, ai)
        new(l, m, a, aw, c, i, Val{:Ground}(), rate)
    end
end

struct TVis
    w::Blink.Window
    s::WebIO.Scope
    o::WebIO.Observable
end

function Base.merge!(a::Solution, b::Solution)
    % = (o, k) -> getfield(o, k)
    for k in [:WeightCG, :WeightArm, :ArmSling, :Projectile, :SlingEnd, :ArmCG, :Time]
        push!(%(a, k), %(b, k))
    end
end

derive(t::Trebuchet, a::Array, time) = derive(t, a, time, t.stage)

function derive(t::Trebuchet, sol::AbstractODESolution)
    s = Solution()
    stage = t.stage
    for (x, y) in tuples(sol)
        merge!(s, derive(t, x, y, stage))
        if ready(t, x, stage)
            transition(t, x, y, stage)
            return s
        end
    end
    return s
end

ready(t::Trebuchet, sol) = ready(t::trebuchet, sol, t.stage)
ready(t::Trebuchet, sol::Array, ::Val{:Ground}) = sol[1] + sol[3] < π
ready(t::Trebuchet, sol::Array, ::Val{:Hang}) = false

transition(t::Trebuchet, s::Array, ti) = transition(t::Trebuchet, s::Array, ti, t.stage)

function transition(t::Trebuchet, s::Array, ti, ::Val{:Ground})
        t.stage = Val{:Hang}()
        t.aw = AnglularVelocities(s[4:6]...)
        t.a = Angles(s[1:3]...)
end

function derive(t::Trebuchet, a::Array, time, ::Val{:Ground})
    (Aq, Wq, Sq,) = a
    l = t.l
    LAl, LAs, LW, LS, h = l.b, l.c, l.d, l.e, l.a
    LAcg = (LAl - LAs)/2
    SIN = sin
    COS = cos
    Solution(
        [LAs*SIN(Aq) + LW*SIN(Aq+Wq), -LAs*COS(Aq) - LW*COS(Aq+Wq)],
        [LAs*SIN(Aq), -LAs*COS(Aq)],
        [-LAl*SIN(Aq), LAl*COS(Aq)],
        [-LAl*SIN(Aq) - LS*SIN(Aq+Sq), LAl*COS(Aq) + LS*COS(Aq+Sq)],
        [-LAl*SIN(Aq) - LS*SIN(Aq+Sq), LAl*COS(Aq) + LS*COS(Aq+Sq)],
        [-LAcg*SIN(Aq), LAcg*COS(Aq)],
        [time], -1, -1
    )
end

function simulate(t::Trebuchet)

end
