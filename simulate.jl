# Equations:
# http://www.virtualtrebuchet.com/#documentation_EquationsOfMotion

function simulate(t::Trebuchet, ::Val{:Ground})
    a = t.a
    aw = t.aw
    u0 = Float64.([a.aq, a.wq, a.sq, aw.aw, aw.ww, aw.sw])
    ti = (0, 1.0)
    prob = ODEProblem(stage1!, u0, ti, t)

    cb = ContinuousCallback((u, _, __) -> u[1] + u[3] < π ? 0 : 1,
     (i) -> terminate!(i),
     save_positions = (false,false))
    solve(prob, RK4(), saveat=1/(t.rate), callback=cb)
end

list = []

Base.:+(a::Vec, b::Vec) = Vec(a.x + b.x, a.y + b.y)
γ(a::Vec) = asin(a.y/ sqrt(a.x^2 + a.y^2))

function projectile_angle(t::Trebuchet, u::Array)
    l, c = t.l, t.c
    e, b = l.e, l.b
    r = c.r

    aq = u[1]
    sq = u[3]
    aw = u[4]
    sw = u[6]

    p = Vec(e*sw*cos(sq + aq), e*sw*sin(sq + aq))
    q = Vec(b*aw*cos(aq), b*aw*sin(aq))

    γ(p + q)
end

function simulate(t::Trebuchet, ::Val{:Hang})
    a, aw = t.a, t.aw
    r = t.c.r
    u0 = Float64.([a.aq, a.wq, a.sq, aw.aw, aw.ww, aw.sw])
    ti = (0, 1.0)
    prob = ODEProblem(stage2!, u0, ti, t)

    i = 0
    cb = ContinuousCallback(
    (u, time, it) -> projectile_angle(t, u) - r,
    (i) -> terminate!(i),
    save_positions = (true,false))

    solve(prob, RK4(), callback=cb)
end


# function simulate(t::Trebuchet, ::Val{:Released})
#     u0 = [t.p.x, t.p.y, t.v.x, t.v.y]
#     ti = (0, 1.0)
#     prob = ODEProblem(stage3!, u0, ti, t)
#     solve(prob)
# end

function stage1!(du, u, p::Trebuchet, t)
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

function stage2!(du, u, p::Trebuchet, t)
    l, a, m, i = p.l, p.a, p.m, p.i
    LAl, LAs, LW, LS, h = l.b, l.c, l.d, l.e, l.a
    mA, mW, mP = m.a, m.w, m.p
    IA3, IW3 = i.iw, i.ia

    LAcg = (LAl - LAs)/2
    Grav = p.c.Grav

    Aq = u[1]
    Wq = u[2]
    Sq = u[3]
    Aw = u[4]
    Ww = u[5]
    Sw = u[6]

    M11 = IA3 + IW3 + mA*LAcg^2 + mP*(LAl^2+LS^2+2*LAl*LS*cos(Sq)) + mW*(LAs^2+LW^2+2*LAs*LW*cos(Wq))
    M12 = IW3 + LW*mW*(LW+LAs*cos(Wq))
    M13 = LS*mP*(LS+LAl*cos(Sq))
    M21 = IW3 + LW*mW*(LW+LAs*cos(Wq))
    M22 = IW3 + mW*LW^2
    M31 = LS*mP*(LS+LAl*cos(Sq))
    M33 = mP*LS^2

    r1 = Grav*LAcg*mA*sin(Aq) + Grav*mP*(LAl*sin(Aq)+LS*sin(Aq+Sq)) - Grav*mW*(LAs*sin(Aq)+LW*sin(Aq+Wq)) - LAl*LS*mP*sin(Sq)*(Aw^2-(Aw+Sw)^2) - LAs*LW*mW*sin(Wq)*(Aw^2-(Aw+Ww)^2)
    r2 = -LW*mW*(Grav*sin(Aq+Wq)+LAs*sin(Wq)*Aw^2)
    r3 = LS*mP*(Grav*sin(Aq+Sq)-LAl*sin(Sq)*Aw^2)

    dAq = Aw
    dWq = Ww
    dSq = Sw
    dAw = -(r1*M22*M33-r2*M12*M33-r3*M13*M22)/(M13*M22*M31-M33*(M11*M22-M12*M21))
    dWw = (r1*M21*M33-r2*(M11*M33-M13*M31)-r3*M13*M21)/(M13*M22*M31-M33*(M11*M22-M12*M21))
    dSw = (r1*M22*M31-r2*M12*M31-r3*(M11*M22-M12*M21))/(M13*M22*M31-M33*(M11*M22-M12*M21))

    du[1] = dAq
    du[2] = dWq
    du[3] = dSq
    du[4] = dAw
    du[5] = dWw
    du[6] = dSw
end

function stage3!(du, u, pr::Trebuchet, t)
    c = pr.c
    Grav = c.Grav
    ρ = c.ρ
    ws = c.w
    Aeff = π*(pr.l.z)^2
    mP = pr.m.p
    Cd = c.Cd

    Pvx = u[3]
    Pvy = u[4]

    dPx = Pvx
    dPy = Pvy
    dPvx = -(ρ*Cd*Aeff*(Pvx-WS)*sqrt(Pvy^2+(WS-Pvx)^2))/(2*mP)
    dPvy = -Grav - (ρ*Cd*Aeff*Pvy*sqrt(Pvy^2+(WS-Pvx)^2))/(2*mP)
end
