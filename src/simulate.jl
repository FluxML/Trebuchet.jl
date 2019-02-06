# Equations:
# http://www.virtualtrebuchet.com/#documentation_EquationsOfMotion

function simulate(t)
   time = 0.0
   while !isa(t.stage, Val{:End})
      s = simulate_(t, time)
      time = s.t[end]
      derive!(t, s)
      transition(t, s[end])
   end
   return t.sol
end

simulate_(t::TrebuchetState, time) = simulate_(t, time, t.stage)

function simulate_(t::TrebuchetState, time, ::Val{:Ground})
    a = t.a
    aw = t.aw
    u0 = oftype.(t.m.w, [a.aq, a.wq, a.sq, aw.aw, aw.ww, aw.sw])
    ti = oftype.(t.m.w, (time, time + 1.0))
    prob = ODEProblem(stage1!, u0, ti, t)

    string_tension = (u, time, it, θ) -> begin
        m = t.m.p
        time == it.tprev && return 0
        acc = (sling_velocity(t, u) - sling_velocity(t, it.uprev))/(time - it.tprev)
        Tn = -acc.x*m/sin(θ)
    end


    ccb = ContinuousCallback(
        (u, time, it) -> begin
            mg = t.m.p * t.c.Grav
            θ = u[1] + u[3] - π
            Tn = string_tension(u, time, it, θ)
            t.Tn = Tn
            mg - Tn*cos(θ)
        end,
        (i) -> terminate!(i))

    dcb = DiscreteCallback(
        (u, time, it) -> t.Tn < zero(typeof(t.Tn)), # loose string case
        (i) -> terminate!(i)
    )
    solve(prob, Euler(), dt = 1/t.rate, callback=CallbackSet(ccb, dcb))
end

function simulate_(t::TrebuchetState, time, ::Val{:Hang})
    a, aw = t.a, t.aw
    r = t.c.r
    u0 = oftype.(t.m.w, [a.aq, a.wq, a.sq, aw.aw, aw.ww, aw.sw])
    ti = oftype.(t.m.w, (time, time + 1.0))
    prob = ODEProblem(stage2!, u0, ti, t)

    cb = ContinuousCallback(
        (u, time, it) -> sin(projectile_angle(t, u) - r),
        (i) -> terminate!(i))

    solve(prob, Euler(), dt = 1/t.rate, callback=cb)
end


function simulate_(t::TrebuchetState, time, ::Val{:Released})
    a = t.l.a
    u0 = oftype.(t.m.w, [t.p.x, t.p.y, t.v.x, t.v.y])
    ti = oftype.(t.m.w, (time, 5.0 + time))
    prob = ODEProblem(stage3!, u0, ti, t)

    cb = ContinuousCallback(
        (u, time, it) -> u[2] + a,
        (it) -> terminate!(it))

    solve(prob, Euler(), dt = 1/t.rate, callback=cb)
end

function stage1!(du, u, p::TrebuchetState, t)
    l, a, m, i = p.l, p.a, p.m, p.i
    LAl, LAs, LW, LS, h = l.b, l.c, l.d, l.e, l.a
    mA, mW, mP = m.a, m.w, m.p
    IA3, IW3 = i.iw, i.ia
    LAcg = (LAl - LAs)/2
    Grav = p.c.Grav
    SIN = sin
    COS = cos

    Aq = u[1]
    Wq = u[2]
    Sq = u[3]
    Aw = u[4]
    Ww = u[5]
    Sw = u[6]

    M11 = -mP*LAl^2*(-1+2*SIN(Aq)*COS(Sq)/SIN(Aq+Sq)) + IA3 + IW3 + mA*LAcg^2 + mP*LAl^2*SIN(Aq)^2/SIN(Aq+Sq)^2 + mW*(LAs^2+LW^2+2*LAs*LW*COS(Wq))
    M12 = IW3 + LW*mW*(LW+LAs*COS(Wq))
    M21 = IW3 + LW*mW*(LW+LAs*COS(Wq))
    M22 = IW3 + mW*LW^2
    r1 = Grav*LAcg*mA*SIN(Aq) + LAl*LS*mP*(SIN(Sq)*(Aw+Sw)^2+COS(Sq)*(COS(Aq+Sq)*Sw*(Sw+2*Aw)/SIN(Aq+Sq)+(COS(Aq+Sq)/SIN(Aq+Sq)+LAl*COS(Aq)/(LS*SIN(Aq+Sq)))*Aw^2)) + LAl*mP*SIN(Aq)*(LAl*SIN(Sq)*Aw^2-LS*(COS(Aq+Sq)*Sw*(Sw+2*Aw)/SIN(Aq+Sq)+(COS(Aq+Sq)/SIN(Aq+Sq)+LAl*COS(Aq)/(LS*SIN(Aq+Sq)))*Aw^2))/SIN(Aq+Sq) - Grav*mW*(LAs*SIN(Aq)+LW*SIN(Aq+Wq)) - LAs*LW*mW*SIN(Wq)*(Aw^2-(Aw+Ww)^2)
    r2 = -LW*mW*(Grav*SIN(Aq+Wq)+LAs*SIN(Wq)*Aw^2)

    dAq = Aw
    dWq = Ww
    dSq = Sw
    dAw = (r1*M22-r2*M12)/(M11*M22-M12*M21)
    dWw = -(r1*M21-r2*M11)/(M11*M22-M12*M21)
    dSw = -COS(Aq+Sq)*dSq*(dSq+2*dAq)/SIN(Aq+Sq) - (COS(Aq+Sq)/SIN(Aq+Sq)+LAl*COS(Aq)/(LS*SIN(Aq+Sq)))*dAq^2 - (LAl*SIN(Aq)+LS*SIN(Aq+Sq))*dAw/(LS*SIN(Aq+Sq))

    du[1] = dAq
    du[2] = dWq
    du[3] = dSq
    du[4] = dAw
    du[5] = dWw
    du[6] = dSw
end

function stage2!(du, u, p::TrebuchetState, t)
    l, a, m, i = p.l, p.a, p.m, p.i
    LAl, LAs, LW, LS, h = l.b, l.c, l.d, l.e, l.a
    mA, mW, mP = m.a, m.w, m.p
    IA3, IW3 = i.iw, i.ia

    LAcg = (LAl - LAs)/2
    Grav = p.c.Grav
    COS = cos
    SIN = sin

    Aq = u[1]
    Wq = u[2]
    Sq = u[3]
    Aw = u[4]
    Ww = u[5]
    Sw = u[6]


    M11 = IA3 + IW3 + mA*LAcg^2 + mP*(LAl^2+LS^2+2*LAl*LS*COS(Sq)) + mW*(LAs^2+LW^2+2*LAs*LW*COS(Wq))
    M12 = IW3 + LW*mW*(LW+LAs*COS(Wq))
    M13 = LS*mP*(LS+LAl*COS(Sq))
    M21 = IW3 + LW*mW*(LW+LAs*COS(Wq))
    M22 = IW3 + mW*LW^2
    M31 = LS*mP*(LS+LAl*COS(Sq))
    M33 = mP*LS^2

    r1 = Grav * LAcg * mA * SIN(Aq) + Grav * mP * ( LAl * SIN(Aq) + LS * SIN(Aq+Sq) ) - Grav * mW * ( LAs * SIN(Aq) + LW* SIN(Aq+Wq)) - LAl * LS * mP * SIN(Sq) * ( Aw^2 - ( Aw + Sw )^2 ) - LAs * LW * mW * SIN(Wq) * ( Aw^2 - (Aw+Ww)^2)
    r2 = -LW * mW * (Grav * SIN(Aq+Wq) + LAs * SIN(Wq) * Aw^2)
    r3 = LS * mP * ( Grav * SIN(Aq + Sq) - LAl * SIN(Sq) * Aw^2 )

    dAq = Aw
    dWq = Ww
    dSq = Sw
    dAw = -( r1 * M22 * M33 - r2 * M12 * M33 - r3 * M13 * M22 ) / ( M13 * M22 * M31 - M33 * ( M11 * M22 - M12 * M21))
    dWw = ( r1 * M21 * M33 - r2 * (M11 * M33 - M13 * M31 ) - r3 * M13 * M21) / ( M13 * M22 * M31 - M33 * ( M11 * M22 - M12 * M21))
    dSw = ( r1 * M22 * M31 - r2 * M12 * M31 - r3 * (M11 * M22 - M12 * M21)) / (M13 * M22 * M31 - M33 * ( M11 * M22 - M12 * M21))

    du[1] = dAq
    du[2] = dWq
    du[3] = dSq
    du[4] = dAw
    du[5] = dWw
    du[6] = dSw
end

function stage3!(du, u, pr::TrebuchetState, t)
    c = pr.c
    Grav = c.Grav
    ρ = c.ρ
    WS = c.w
    Aeff = π*(pr.l.z)^2
    mP = pr.m.p
    Cd = c.Cd

    Pvx = u[3]
    Pvy = u[4]

    dPx = Pvx
    dPy = Pvy
    dPvx = -(ρ*Cd*Aeff*(Pvx-WS)*sqrt(Pvy^2+(WS-Pvx)^2))/(2*mP)
    dPvy = -Grav - (ρ*Cd*Aeff*Pvy*sqrt(Pvy^2+(WS-Pvx)^2))/(2*mP)

    du[1] = dPx
    du[2] = dPy
    du[3] = dPvx
    du[4] = dPvy
end
