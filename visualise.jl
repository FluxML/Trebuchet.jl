function init(t::Trebuchet)
    w = Blink.Window()
    opentools(w)
    files = ["./assets/js/init_dom.js","./assets/js/utils.js","./assets/js/draw.js","./assets/css/style.css"]

    s = Scope(imports=files)
    o = Observable(s, "trebuchet", Dict(
        "lengths"=> t.l,
        "masses"=> t.m,
        "angles"=> t.a
        ))

    onimport(s, @js function ()
        @var config = Dict(
            "canvas"=> __("#main #playground"),
            "lengths"=> $(t.l),
            "masses"=> $(t.m),
            "angles"=> $(t.a),
            "scale"=> 40,
            "padding"=> 22
        )
        window.config = config;
        init();
        draw(config);
    end)

    onjs(o, @js (v) -> begin
        # console.log("v.angles", v["angles"])
        changeTo(v, window.config)
        draw(window.config);
    end)

    body!(w, s)
    TVis(w, s, o)
end
