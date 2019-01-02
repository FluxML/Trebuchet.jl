function visualise(t)
   w = Blink.Window()
   opentools(w)
   files = ["./assets/js/utils.js", "./assets/js/animate.js"]
   sc = Scope(imports=files)
   onimport(sc,  @js function ()
      createCanvas("main");
      animate("main", $(t.l), $(t.sol))
   end)
   body!(w, sc)
end
