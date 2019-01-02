function plotTrebuchet(ctx, sol, i, {a}){
	
	var scale = 10;
	var p = (e, color="#000") => new Point(e[0]*scale, -e[1]*scale, color)
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

	var aRect = aLine.toRect("#925c1d", scale*0.17);
	var bcRect = bcLine.toRect("#693d14", scale*0.13);

	var PCircle = new Circle(P, scale/5);
	var UCircle = new Circle(U, scale/3);

	[bcLine, dLine, eLine, PCircle, UCircle, aLine, aRect, bcRect].forEach(e => e.draw(ctx));
}


function animate(ele_name, lengths, sol){
	var i = 0 | 0;
	var canvas = document.querySelector("#" + ele_name);
	var ctx = canvas.getContext("2d");
	var len = sol.WeightCG.length | 0;

	var origin = new Point(100, canvas.height - 20);
	
	var time = 10;

	// origin.translate(ctx,
	// 	() => new Array(len).fill(0).map((_, i) => plotTrebuchet(ctx, sol, i, lengths)))

	var next = (i) =>{
		if(i == len)return;
		ctx.clearRect(0, 0, canvas.width, canvas.height)
		origin.translate(ctx, () => plotTrebuchet(ctx, sol, i, lengths))
		setTimeout(() => next(i + 1), time);
	}
	next(0);

	
	console.log(sol.Projectile[len - 1])
}



function createCanvas(ele_name){
	var ele = document.createElement("canvas")
	ele.setAttribute("id", ele_name);
	ele.width = 1000;
	
	ele.style.border = "1px solid #20205a";
	document.body.appendChild(ele);
}