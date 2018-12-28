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
    r::T # release angle of projectile [input]
    aq::T # angle between pivot stand and arm
    wq::T # angle between arm and weight
    sq::T # angle between arm and sling
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
end

mutable struct Trebuchet
    l::Lengths
    m::Masses
    a::Angles
    c::Constants
    i::Inertias
    stage::Union{Val{:Ground},Val{:Hang},Val{:Released}}



    function Trebuchet(l::Lengths, m::Masses, r::Float64, w::Float64, ρ, Cd)
        θ = asin(l.a/l.b)
        sq = π - θ
        aq = π/2 + θ
        wq = -aq
        ai = m.a*((l.b + l.c)^2)/12
        wi = m.w*(l.u)^2/2 # inertia for disk
        a = Angles(r, aq, wq, sq)
        i = Inertias(wi, ai)
        c = Constants(w, ρ, Cd, 9.8)
        new(l, m, a, c, i, Val{:Ground}())
    end
end

struct TVis
    w::Blink.Window
    s::WebIO.Scope
    o::WebIO.Observable
end

function simulate(t::Trebuchet)

end
