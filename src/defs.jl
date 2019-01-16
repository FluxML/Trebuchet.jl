struct Lengths{T <: Float64}
    a::T # height of pivot
    b::T # length of long arm
    c::T # length of short arm
    d::T # lenght of weight arm
    e::T # length of sling
    u::T # radius of weight
    z::T # radius of projectile
end

struct Masses{T<:Float64}
    w::T # mass of weight
    p::T # mass of projectile
    a::T # mass of arm
end

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

mutable struct Solution
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

mutable struct TrebuchetState
    l::Lengths
    m::Masses
    a::Angles # [stage 1 & 2]
    aw::AnglularVelocities # [stage 1 & 2]
    c::Constants
    i::Inertias
    stage::Union{Val{:Ground},Val{:Hang},Val{:Released},Val{:End}}
    rate::Integer
    p::Union{Vec,Integer} # projectile point [stage 3]
    v::Union{Vec,Integer} # projectile speed [stage 3]
    sol::Solution
    function TrebuchetState(l::Lengths, m::Masses, c, rate)
        θ = asin(l.a/l.b)
        sq = π - θ
        aq = π/2 + θ
        wq = -aq
        ai = m.a*((l.b + l.c)^2)/12
        wi = m.w*(l.u)^2/2 # inertia for disk
        a = Angles(aq, wq, sq)
        aw = AnglularVelocities(0.0, 0.0, 0.0)
        i = Inertias(wi, ai)
        new(l, m, a, aw, c, i, Val{:Ground}(), rate, -1, -1, Solution())
    end
end
