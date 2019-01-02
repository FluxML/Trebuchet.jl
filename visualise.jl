function visualise(t, scale=10)
   w = Blink.Window()
   # opentools(w)
   position(w, 0, 0)
   width = t.sol.Projectile[end][1]*scale + 200
   size(w, Int(round(width)), 600)
   files = ["./assets/js/utils.js", "./assets/js/animate.js", "./assets/css/basic.css"]
   sc = Scope(imports=files)
   onimport(sc,  @js function ()
      window.scale = $(scale);
      createCanvas("main");
      @var fields = ["distance", "height", "time"]
      createOutputBar("output", fields);
      animate("main", $(t.l), $(t.sol), "output")
   end)
   body!(w, sc)
end
