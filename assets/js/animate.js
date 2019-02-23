var $$ = (e) => document.querySelector(e);

var round2 = (x) => Math.round(x*100)/100

function setVal(ele, val){
	if(!ele)return
	ele.innerText = val.toString();
}


function display(ctx, max, sol, {a}, scale, target){
	var p = (e, color="#000") => new Point(e[0]*scale, -e[1]*scale, color)
	// console.log(max);
	// var maxWidth = sol.Projectile[max[0]];
	// var toText = (e) => round2(e) + "m";
	// var wm = new Measure(p([0, -a - 2]), p([maxWidth[0], -a - 2]), p([0, -1]), p([0, 1]), toText(maxWidth[0]), color="#efd248");
	// var maxHeight = sol.Projectile[max[1]];
	// var hm = new Measure(p([maxHeight[0], -a]), p(maxHeight), p([-1, 0]), p([1, 0]), toText(maxHeight[1]), color="#efd248");
	// wm.draw(ctx);
	// hm.draw(ctx);

	if(target){
		var y = -(a);
		var T = p([target, y])
		var endx = sol.Projectile.slice(-1)[0][0];
		var X = p([endx, y])
		var dist = Math.abs(endx - target);
		if(dist >= 3){
			var sm = new SmallMeasure(T, X, round2(dist)+"m", scale);
			sm.draw(ctx)
		}
	}
}

function plot(ctx, sol, i, {a}, scale, target){
	var p = (e, color="#000") => new Point(e[0]*scale, -e[1]*scale, color)

	function trail(ctx, sol, i){
		var j = 0;
		for(j = 0; j < i; j++){
			(new Circle(p(sol.Projectile[j]), scale/20)).draw(ctx);
		}
	}

	var X = p(sol.WeightArm[i]);
	var Y = p(sol.ArmSling[i]);
	var Z = p(sol.SlingEnd[i]);
	var U = p(sol.WeightCG[i]);
	var P = p(sol.Projectile[i]);
	var O = p([0, 0]);
	var V = p([0, -a])

	var aLine = new Line(V, O, "#925c1d");
	var bcLine = new Line(X, Y);
	var dLine = new Line(X, U);
	var eLine = new Line(Y, Z);

	var aRect = aLine.toRect("#925c1d", scale*0.3);
	var bcRect = bcLine.toRect("#693d14", scale*0.19);

	var PCircle = new Circle(P, scale/5);
	var UCircle = new Circle(U, scale/3);

	var drawable = [
		aLine, bcLine, aRect,
		bcRect, dLine, eLine,
		PCircle, UCircle];
	if(target){
		var T = p([target, -a]);
		var TMark = new Target(T, scale);
		drawable.push(TMark)
	}

	drawable.forEach(e => e.draw(ctx));

	setVal($$("#time"), round2(sol.Time[i]) + "s");
	setVal($$("#distance"), round2(sol.Projectile[i][0]) + "m");
	setVal($$("#height"), round2(sol.Projectile[i][1] + a) + "m");
	trail(ctx, sol, i)
}

function wind_speed(p, ws){
	var parent = document.querySelector("div[data-webio-scope-id=" + p + "]");
	var child = document.createElement("div");
	parent.appendChild(child);
	child.className="wind_speed";
	child.setAttribute("dir", ws >= 0 ?"right" : "left");
	child.innerHTML = "<div></div><span>" + ws + "m/s</span>"

}

function Animation(parent_name, ele_name, lengths, sol, bb, target){
	this.ele_name = ele_name;
	this.selector = "div[data-webio-scope-id=" + parent_name + "] #" + ele_name
	this.canvas = document.querySelector(this.selector);

	this.ctx = this.canvas.getContext("2d");
	this.lengths = lengths;
	this.sol = sol;
	this.bb = bb;
	this.index = 0;
	this.scale = window.scale;
	this.origin = null;
	this.pad =  100; // in pixels
	this.reserved = 110; // in pixels
	this.running = false;
	this.max_i = [0, 0];
	this.time = 10;
	this.end = sol.WeightCG.length;
	this.target = target;

	this.resize = function(){
		var {ele_name, bb, scale, pad, reserved, canvas} = this;

		var {top, bottom, left, right} = bb;

		var {a, b, c} = lengths;

		right = Math.max(c, right);
		left = Math.min(left,  -b);
		top = Math.max(top, c);
		bottom = Math.min(bottom, -a);

		var width =  right - left;
		var height =  top - bottom;

		var ar = width/height;

		var maxWidth, maxHeight;
		var is_iJulia = false;
		if($$(".notebook_app")){
			is_iJulia = true;
			// inside IJulia
			console.log("IJulia detected")
			var outputArea = canvas.parentNode.parentNode;
			maxWidth = outputArea.offsetWidth - pad;
			maxHeight = maxWidth*height/width;
		}else{
			maxWidth = window.innerWidth - pad;
			maxHeight = window.innerHeight - pad - reserved;
		}

		scale = maxWidth/width;

		if(!is_iJulia && height*scale > maxHeight){
			scale = maxHeight/height;
		}
		scale = Math.min(scale, canvas.height/(2*lengths.a))
		canvas.width = width*scale + pad;
		canvas.height = height*scale + pad;
		this.origin = new Point(pad/2 - left*scale, pad/2 + top*scale);
		this.scale = scale;
	}

	this.run = function(){
		this.running = true;
		this.resize();
		this.index = 0;
		// this.index = this.end;
		this.draw();
	}

	this.draw = function(){
		var {canvas, ctx, max_i, sol, lengths, time, origin, scale, target, ws} = this;
		// console.log(scale)
		var i = this.index;
		var len = this.end;
		if(i == len){

			origin.translate(ctx, () => {
				display(ctx, max_i, sol, lengths, scale, target);
				plot(ctx, sol, i-1, lengths, scale, target);

			});
			this.running = false;
			return
		}
		var comp = (i, j) => {
			if(sol.Projectile[i][j] > sol.Projectile[max_i[j]][j]){
				max_i[j] = i
			}
		}
		ctx.clearRect(0, 0, canvas.width, canvas.height)
		comp(i, 0);
		comp(i, 1);
		origin.translate(ctx, () => plot(ctx, sol, i, lengths, scale, target));
		this.index += 1
		setTimeout(this.draw.bind(this), time);
	}


}

function animate(parent_name, ele_name, lengths, sol, bb, target, ws){
	wind_speed(parent_name, ws);
	var a = new Animation(parent_name, ele_name, lengths, sol, bb, target);
	window.onresize = () => {
		a.resize();
		if(!a.running){
			a.draw();
		}
	}
	a.run();
}

function _createCanvas(parent_name, ele_name){
	var ele = document.createElement("canvas")
	ele.setAttribute("id", ele_name);
	$$("div[data-webio-scope-id=" + parent_name + "]").appendChild(ele);
}

var format = (name) =>
	name.split("_").map(ele => ele[0].toUpperCase() + ele.slice(1)).join(" ")

var field = (name, val) => '<div class="field">\
	<label>' + format(name) + '</label>\
	<div id="' + name + '">' + round2(val[0]) + val[1] + '</div>\
</div>'

function _createOutputBar(parent_name, ele_name, fields){
	var ele = document.createElement("div")
	ele.setAttribute("id", ele_name);
	ele.innerHTML = Object.keys(fields).map(e=>field(e, fields[e])).join("")
	$$("div[data-webio-scope-id=" + parent_name + "]").appendChild(ele);
}

var maybe = (create, old) =>
	(function(p, ele){
		$$("div[data-webio-scope-id=" + p +"] #" + ele) ? old(...arguments) : create(...arguments)
	})

var createCanvas = maybe(_createCanvas, (p, e, w) => $$("#" + e).width = w)
var createOutputBar = maybe(_createOutputBar, (p, el, f) =>
		$$("#" + el).innerHTML = Object.keys(f).map(e=>field(e, f[e])).join("")
);
