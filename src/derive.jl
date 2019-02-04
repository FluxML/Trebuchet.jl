# calculate required values from the solution (for the animation)

derive!(t::TrebuchetState, sol::AbstractODESolution) = derive(t, sol, t.sol)
function derive(t::TrebuchetState, sol::AbstractODESolution, s = Solution())
    stage = t.stage
    p = tuples(sol)
    for (x, y) in p
        derive(t, x, y, stage, s)
    end
    return s
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
