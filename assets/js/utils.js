var __ = e => document.querySelector(e);

var c = 180/Math.PI;
var deg = (e) => e*c;
var rad = (e) => e/c;

(function(obj){

	Object.assign(obj, {Point, Line, Rect, Circle, Measure, Target, SmallMeasure});

	function Point(x, y, color="#000"){
		this.x = x;
		this.y = y;
		this.color = color;
	}

	Point.prototype.displace = function(other){
		this.x += other.x;
		this.y += other.y;
		return this;
	}

	Point.prototype.clone = function(){return new Point(this.x, this.y)}

	Point.prototype.draw = function(ctx){
		ctx.fillStyle = this.color;
		ctx.beginPath();
		ctx.arc(this.x,this.y, 2, 0, Math.PI*2);
		ctx.fill();
	}

	Point.prototype.translate = function(ctx, f){
		ctx.translate(this.x, this.y);
		f();
		ctx.translate(-this.x, -this.y);
	}

	Point.prototype.dist = function(other){
		return Math.sqrt(Math.pow(other.x - this.x,2) + Math.pow(other.y - this.y,2))
	}

	function Line(a, b, color="#000"){
		this.a = a;
		this.b = b;
		this.color = color;
	}

	Line.prototype.draw = function(ctx, dashed=false){
		ctx.strokeStyle = this.color;
		ctx.beginPath();
		if(dashed){
			ctx.setLineDash([2, 1]);
		}
		ctx.moveTo(this.a.x, this.a.y);
		ctx.lineTo(this.b.x, this.b.y);
		ctx.stroke();
	}

	Line.prototype.toRect = function(color="#000", p=4) {
		var angle = Math.atan((this.b.y - this.a.y)/(this.b.x - this.a.x));
		var a = this.a;
		var b = this.b;
		if(a.x > b.x){
			a = this.b;
			b = this.a
		}
		var height = 2*p;
		var width = a.dist(b);
		return new Rect(a, angle, height, width, color);
	};

	function Rect(pivot, angle, height, width,color){
		this.pivot = pivot;
		this.angle = angle;
		this.height = height;
		this.width = width;
		this.color = color;
		this.borderColor = "#000";
		this.borderWidth = 1;
	}

	Rect.prototype.draw = function(ctx){
		ctx.translate(this.pivot.x, this.pivot.y);

		ctx.rotate(this.angle);

		ctx.fillStyle = this.color;
		ctx.fillRect(0, 0, this.width, this.height/2 - 1);
		ctx.fillRect(0, 0, this.width, -this.height/2 + 1);

		ctx.rotate(-this.angle);
		ctx.translate(-this.pivot.x, -this.pivot.y);
	}

	function Circle(center, radius, color="#000"){
		this.center = center;
		this.radius = radius;
		this.color = color;
	}

	Circle.prototype.draw = function(ctx, fill=true){
		ctx.beginPath();
		ctx.arc(this.center.x, this.center.y, this.radius, 0, 2*Math.PI);
		if(fill){
			ctx.fillStyle = this.color;
			ctx.fill();
		}else{
			ctx.strokeStyle = this.color;
			// ctx.strokeWidth =
			ctx.stroke();
		}
	}

	function Target(point, radius, color="#f00"){
		this.point = point;
		this.radius = radius;
		this.color = color;
	}

	Target.prototype.draw = function(ctx){
		var {point, radius, color} = this;
		var a = new Circle(point, 0.25*radius, color);
		var b = new Circle(point, 0.5*radius, color);
		var c = new Circle(point, radius, color);

		a.draw(ctx)
		b.draw(ctx, false);
		c.draw(ctx, false);

	}

	function Measure(a, b, p, q, val, color="#000", textColor="#000"){
		this.a = a;
		this.b = b;
		this.p = p;
		this.q = q;
		this.val = val;
		this.color = color;
		this.textColor = textColor;
	}

	Measure.prototype.draw = function(ctx){
		var c = new Point((this.a.x + this.b.x)/2, (this.a.y + this.b.y)/2);
		(new Line(this.a, this.b).toRect(this.color, 2)).draw(ctx);
		var makeLines = (a, p, q) => {
			var ap = new Line(a, p.clone().displace(a));
			var aq = new Line(a, q.clone().displace(a));
			return [ap.toRect(this.color, 2), aq.toRect(this.color, 2)];
		}
		makeLines(this.a, this.p, this.q).forEach(e => e.draw(ctx));
		makeLines(this.b, this.p, this.q).forEach(e => e.draw(ctx))
		// ctx.textAlign = "center";
		ctx.fillStyle = this.textColor;
		var w = ctx.measureText(this.val).width;
		var h = 11;
		var tx = c.x - w/2;
		var ty = c.y + h/2;
		ctx.font = h + "px arial";
		var padding = 10;
		ctx.clearRect(tx - padding, ty - h - padding, w + 2*padding, h + 2*padding);
		ctx.fillText(this.val, tx, ty);
	}

	function SmallMeasure(a, b, dist, scale, color="#f00", textColor="#222"){
		this.a = a;
		this.b = b;
		this.dist = dist;
		this.color = color;
		this.scale = scale;
		this.textColor = textColor;
	}
	SmallMeasure.prototype.draw = function(ctx){
		var {a, b, dist, color, scale} = this;
		{
			var line = new Line(a, b, color);
			var ca = new Circle(a, scale/5, color);
			var cb = new Circle(b, scale/5, color);
			line.draw(ctx, true);
			([ca, cb]).forEach(w => w.draw(ctx));
		}

		var c = new Point((a.x + b.x)/2, (a.y + b.y)/2);
		ctx.fillStyle = this.textColor;
		ctx.textAlign = "center";
		ctx.fillText(dist, c.x, c.y- 0.3*scale);
	}
})(window);
