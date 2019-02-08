# state transitions

transition(t::TrebuchetState, s::Array) = transition(t::TrebuchetState, s::Array, t.stage)

function transition(t::TrebuchetState, s::Array, ::Val{:Ground})
    t.aw = AnglularVelocities(s[4:6]...)
    t.a = Angles(s[1:3]...)
    if isa(t.terminated, Val{:Ground})
        t.stage = Val{:Hang}()
    elseif t.Tn < zero(typeof(t.Tn))
        @warn "Weight is too light ($(t.m.w))"
        t.stage = Val{:End}()
    end
end

function transition(t::TrebuchetState, s::Array, ::Val{:Hang})
    t.aw = AnglularVelocities(s[4:6]...)
    t.a = Angles(s[1:3]...)
    t.p = sling_end(t)
    t.v = sling_velocity(t)
    t.sol.ReleaseVelocity = t.p
    t.sol.ReleasePositon = t.v
    if isa(t.terminated, Val{:Hang})
        t.stage = Val{:Released}()
    end
end

function transition(t::TrebuchetState, s::Array, ::Val{:Released})
    t.p = Vec(s[1], s[2])
    t.v = Vec(s[3], s[4])
    if isa(t.terminated, Val{:Released})
        t.stage = Val{:End}()
    end
end
