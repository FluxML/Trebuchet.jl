function visualise(t, scale=10)
   w = Blink.Window()
   # opentools(w)
   position(w, 0, 0)

   width = abs(Int(round(t.sol.Projectile[end][1]*scale))) + 200
   size(w, width, 600)
   files = ["./assets/js/utils.js", "./assets/js/animate.js", "./assets/css/basic.css"]
   sc = Scope(imports=files)
   c = t.c

   r, ws = c.r, c.w

   onimport(sc,  @js function ()
      window.scale = $(scale);
      createCanvas("main");
      # @var fields = ["distance", "height", "time"]
      @var fields = Dict(
         "distance"=>[0.0, "m"],
         "height"=>[0.0, "m"],
         "time"=>[0.0, "m"],
         "release_angle"=>[$(rad2deg(r)), "deg"],
         "wind_speed"=>[$(ws), "m/s"],
      )
      createOutputBar("output", fields);
      animate("main", $(t.l), $(t.sol), "output")
   end)
   body!(w, sc)
end
