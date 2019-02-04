# state transitions

transition(t::TrebuchetState, s::Array) = transition(t::TrebuchetState, s::Array, t.stage)

function transition(t::TrebuchetState, s::Array, ::Val{:Ground})
    t.aw = AnglularVelocities(s[4:6]...)
    t.a = Angles(s[1:3]...)
    if t.Tn >= zero(typeof(t.Tn))
        mg = t.m.p * t.c.Grav
        Tn = t.Tn
        θ = s[1] + s[3] - π
        v = mg - Tn*cos(θ)
        if approx_less(v, zero(v), 1e-4)
            t.stage = Val{:Hang}()
        end
    else
        @info "Weight is too light ($(t.m.w))"
        t.stage = Val{:End}()
    end
end

function transition(t::TrebuchetState, s::Array, ::Val{:Hang})
    t.stage = Val{:Released}()
    t.aw = AnglularVelocities(s[4:6]...)
    t.a = Angles(s[1:3]...)
    t.p = sling_end(t)
    t.v = sling_velocity(t)
    t.sol.ReleaseVelocity = t.p
    t.sol.ReleasePositon = t.v
end

function transition(t::TrebuchetState, s::Array, ::Val{:Released})
    t.p = Vec(s[1], s[2])
    t.v = Vec(s[3], s[4])
    py = s[2] + t.l.a
    if approx_less(py, zero(py))
        t.stage = Val{:End}()
    end
end
