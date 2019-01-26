struct Lengths
    a # height of pivot
    b # length of long arm
    c # length of short arm
    d # lenght of weight arm
    e # length of sling
    u # radius of weight
    z # radius of projectile
end

struct Masses
    w # mass of weight
    p # mass of projectile
    a # mass of arm
end

struct Angles # in radians
    aq # angle between pivot stand and arm
    wq # angle between arm and weight
    sq # angle between arm and sling
end

struct AnglularVelocities
    aw # for aq
    ww # for wq
    sw # for sq
end

struct Inertias
    iw # inertia of weight
    ia # inertia of arm
end

struct Vec
    x
    y
end

struct Constants
    w # wind speed
    ρ # Density of Air
    Cd # Drag Co-efficient of Projectile
    Grav
    r # release angle of projectile [input]
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
    p # projectile point [stage 3]
    v # projectile speed [stage 3]
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
