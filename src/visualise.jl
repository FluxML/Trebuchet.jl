function visualise(t, target=nothing)

   top, right, bottom, left = boundingbox(t, target)

   path = p -> normpath("$(@__DIR__)/$p")
   files = path.(["../assets/js/utils.js", "../assets/js/animate.js", "../assets/css/basic.css"])
   sc = Scope(imports=files)
   c = t.c
   r, ws = c.r, c.w

   bb = Dict(
      "top"=>top,
      "right"=>right,
      "bottom"=>bottom,
      "left"=>left
   )

   fields = Dict(
      "distance"=>[0.0, "m"],
      "height"=>[0.0, "m"],
      "time"=>[0.0, "m"],
      "release_angle"=>[rad2deg(r), "deg"],
      "wind_speed"=>[ws, "m/s"],
   )
   if target != nothing
      fields["target"] = [target, "m"]
   end

   id = sc.id
   onimport(sc,  @js function ()
      createCanvas($(id), "main");
      createOutputBar($(id), "output", $(fields));
      animate($(id), "main", $(t.l), $(t.sol), $(bb), $(target), $(ws))
   end)


   sc(dom"div#_container_"())
end

function boundingbox(t, target)
   col = (y, i) -> map(x -> x[i], y)

   xs = col(t.sol.Projectile, 1)
   ys = col(t.sol.Projectile, 2)

   top = max(ys...)
   right = max(xs...)
   bottom = min(ys...)
   left = min(xs...)
   if target != nothing
      right = max(target, right)
      left = min(target, left)
   end
   return top, right, bottom, left
end
