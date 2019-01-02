function visualise(t)
   w = Blink.Window()
   # opentools(w)
   size(w, 1000, 600)
   files = ["./assets/js/utils.js", "./assets/js/animate.js", "./assets/css/basic.css"]
   sc = Scope(imports=files)
   onimport(sc,  @js function ()
      createCanvas("main");
      @var fields = ["distance", "height", "time"]
      createOutputBar("output", fields);
      animate("main", $(t.l), $(t.sol), "output")
   end)
   body!(w, sc)
end
