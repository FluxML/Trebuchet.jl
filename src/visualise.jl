function visualise(t, scale=10)
   width = abs(Int(round(t.sol.Projectile[end][1]*scale))) + 200
   path = p -> normpath("$(@__DIR__)/$p")
   files = path.(["../assets/js/utils.js", "../assets/js/animate.js", "../assets/css/basic.css"])
   sc = Scope(imports=files)
   c = t.c
   r, ws = c.r, c.w

   fields = Dict(
      "distance"=>[0.0, "m"],
      "height"=>[0.0, "m"],
      "time"=>[0.0, "m"],
      "release_angle"=>[rad2deg(r), "deg"],
      "wind_speed"=>[ws, "m/s"],
   )

   onimport(sc,  @js function ()
      window.scale = $(scale);
      createCanvas("_container_", "main", $(width));
      createOutputBar("_container_", "output", $(fields));
      animate("main", $(t.l), $(t.sol), "output")
   end)

   sc(dom"div#_container_"())
end
