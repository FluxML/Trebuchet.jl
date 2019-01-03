var $$ = (e) => document.querySelector(e);
var scale = 10;
var p = (e, color="#000") => new Point(e[0]*scale, -e[1]*scale, color)
var round2 = (x) => Math.round(x*100)/100

function setVal(ele, val){
	if(!ele)return
	ele.innerText = val.toString();
}

function trail(ctx, sol, i){
	var j = 0;
	for(j = 0; j < i; j++){
		(new Circle(p(sol.Projectile[j]), scale/20)).draw(ctx);
	}
}

function display(ctx, max, sol, {a}){
	console.log(max);
	var maxWidth = sol.Projectile[max[0]];
	var toText = (e) => round2(e) + "m";
	var wm = new Measure(p([0, -a - 2]), p([maxWidth[0], -a - 2]), p([0, -1]), p([0, 1]), toText(maxWidth[0]), color="#efd248");
	var maxHeight = sol.Projectile[max[1]];
	var hm = new Measure(p([maxHeight[0], -a]), p(maxHeight), p([-1, 0]), p([1, 0]), toText(maxHeight[1]), color="#efd248");
	wm.draw(ctx);
	hm.draw(ctx);
}

function plot(ctx, sol, i, {a}){

	var X = p(sol.WeightArm[i]);
	var Y = p(sol.ArmSling[i]);
	var Z = p(sol.SlingEnd[i]);
	var U = p(sol.WeightCG[i]);
	var P = p(sol.Projectile[i]);
	var O = p([0, 0]);
	var V = p([0, -a])

	var aLine = new Line(V, O);
	var bcLine = new Line(X, Y);
	var dLine = new Line(X, U);
	var eLine = new Line(Y, Z);

	var aRect = aLine.toRect("#925c1d", scale*0.3);
	var bcRect = bcLine.toRect("#693d14", scale*0.19);

	var PCircle = new Circle(P, scale/5);
	var UCircle = new Circle(U, scale/3);

	[bcLine, aRect, bcRect, dLine, eLine, PCircle, UCircle].forEach(e => e.draw(ctx));


	setVal($$("#time"), round2(sol.Time[i]));
	setVal($$("#distance"), round2(sol.Projectile[i][0]));
	setVal($$("#height"), round2(sol.Projectile[i][1] + a));
	trail(ctx, sol, i)

}


function animate(ele_name, lengths, sol){

	var i = 0;
	var canvas = document.querySelector("#" + ele_name);
	var ctx = canvas.getContext("2d");
	var len = sol.WeightCG.length;
	var max_i = [len - 1, Math.round(len/2)];
	var origin = new Point(100, canvas.height - 8*scale);
	var time = 10;

	// origin.translate(ctx,
	// 	() => new Array(len).fill(0).map((_, i) => plot(ctx, sol, i, lengths)))

	var comp = (i, j) => {
		if(sol.Projectile[i][j] > sol.Projectile[max_i[j]][j]){
			max_i[j] = i
		}
	}

	var next = (i) =>{
		if(i == len){
			origin.translate(ctx, ()=>display(ctx, max_i, sol, lengths));
				return
		}
		ctx.clearRect(0, 0, canvas.width, canvas.height)
		comp(i, 0);
		comp(i, 1);
		origin.translate(ctx, () => plot(ctx, sol, i, lengths))
		setTimeout(() => next(i + 1), time);
	}
	next(0);
}



function createCanvas(ele_name){
	var ele = document.createElement("canvas")
	ele.setAttribute("id", ele_name);
	ele.width = window.innerWidth;
	ele.height = 450;
	document.body.appendChild(ele);
}

var format = (name) =>
	name.split("_").map(ele => ele[0].toUpperCase() + ele.slice(1)).join(" ")

function createOutputBar(ele_name, fields){
	var ele = document.createElement("div")
	ele.setAttribute("id", ele_name);
	var field = (name, val) => '<div class="field">\
		<label>' + format(name) + '</label>\
		<div id="' + name + '">' + round2(val[0]) + val[1] + '</div>\
	</div>'

	ele.innerHTML = Object.keys(fields).map(e=>field(e, fields[e])).join("")

	document.body.appendChild(ele);
}
