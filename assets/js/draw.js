var draw = (function(config){
	var derive = function(config){
		var {scale, lengths, angles} = config;

		var derived = {}
		derived.lengths = {}

		for (var l in lengths){
			derived.lengths[l] = lengths[l] * scale;
		}

		var {a, b, c, d, e, u, z} = derived.lengths;

		derived.angles = {}

		var theta = Math.asin(a/b);
		var pi = Math.PI;

		// console.log(config.angles)

		derived.angles.aq = (angles && angles.aq != undefined) ? angles.aq : (pi/2 + theta);
		derived.angles.sq = (angles && angles.sq != undefined) ? angles.sq : (pi - theta);
		derived.angles.wq = (angles && angles.wq != undefined) ? angles.wq : (-(pi/2 + theta));

		// console.log(derived.angles);
		setInputs(derived);

		var {aq, sq, wq} = derived.angles;
		var {sin, cos} = Math;

		derived.points = {}
		derived.points.O = new Point(0, 0, color="#da7e29");
		derived.points.V = new Point(0, a);
		derived.points.X = new Point(c*sin(aq), c*cos(aq));
		derived.points.Y = new Point(-b*sin(aq), -b*cos(aq));
		derived.points.Z = new Point(-b*sin(aq) - e*sin(aq+sq), -b*cos(aq) - e*cos(aq+sq));
		derived.points.U = new Point(c*sin(aq) + d*sin(aq+wq), c*cos(aq) + d*cos(aq+wq));


		var {X, Y, U, Z, O, V} = derived.points;

		console.log([Z.x, Z.y])

		derived.lines = {}
		derived.lines.aLine = new Line(O, V);
		derived.lines.bcLine = new Line(X, Y);
		derived.lines.dLine = new Line(X, U);
		derived.lines.eLine = new Line(Y, Z);

		var {aLine, bcLine, dLine, eLine} = derived.lines;

		derived.rects = {};
		derived.rects.bcRect = bcLine.toRect("#693d14", config.scale*0.13);
		derived.rects.aRect = aLine.toRect("#925c1d", config.scale*0.17);

		derived.circles = {};
		derived.circles.UCircle = new Circle(U, u, "#ad8c65");
		derived.circles.ZCircle = new Circle(Z, z, "#000");
		return derived
	};

	function makeClouds(n, canvas){
		var rp = (i) => new Point(canvas.width*(Math.random()*0.7 + i)/n, Math.random()*canvas.height*0.3);
		return (new Array(n)).fill(0).map((_, i) => new Cloud(rp(i)));
	}

	function refresh(config){
		var derived = derive(config);
		var ctx = config.canvas.getContext('2d');
		ctx.clearRect(0, 0, config.canvas.width, config.canvas.height);

		if(marioMode){
			document.body.style.background = "#6bafec";
			makeClouds(3, config.canvas).forEach(ele => ele.draw(config.canvas.getContext('2d')));
			(new Floor(new Point(0, config.canvas.height - config.padding + 3), config.canvas.width, config.padding)).draw(ctx);
		}else{
			document.body.style.background = '#fff';
		}

		(new Point(derived.lengths.e + derived.lengths.b + 2*config.padding, config.canvas.height - config.padding - 2*derived.lengths.a)).translate(ctx, () => {
			var drawall = (obj, ctx) => Object.keys(obj).forEach(k => obj[k].draw(ctx));
			drawall(derived.lines, ctx);
			drawall(derived.rects, ctx);
			drawall(derived.circles, ctx);
		});
	}
	return refresh
})();
