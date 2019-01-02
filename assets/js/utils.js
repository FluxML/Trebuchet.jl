var __ = e => document.querySelector(e);
var marioMode = false;

var c = 180/Math.PI;
var deg = (e) => e*c;
var rad = (e) => e/c;

(function(obj){

	Object.assign(obj, {Point, Line, Rect, Circle, Cloud, Floor, Vec, drawarc, whereami});

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

	Point.prototype.corner = function(q, p, angle){
		var c = Math.cos(angle);
		var s = Math.sin(angle);
		return (new Point((q*c - p*s), (q*s - p*c)));
	}

	function Line(a, b, color="#000"){
		this.a = a;
		this.b = b;
		this.color = color;
	}
	Line.prototype.other = function(){return new Line(this.b, this.a, this.color)}
	Line.prototype.angle = function(){
		if( this.b.x - this.a.x >= 0 )
			return Math.atan((this.b.y - this.a.y)/(this.b.x - this.a.x))
		else if (this.b.y - this.a.y >= 0){
			return Math.PI + Math.atan((this.b.y - this.a.y)/(this.b.x - this.a.x))
		}else {
			return Math.atan((this.b.y - this.a.y)/(this.b.x - this.a.x)) - Math.PI
		}
	}

	Line.prototype.rel_point = function(r, angle, color="#000"){
		var t = this.angle() + angle;
		if(t > Math.PI){
			while(t > Math.PI){
				t -= 2*Math.PI
			}
		}

		if(t <= Math.PI){
			while(t <= Math.PI){
				t += 2*Math.PI
			}
		}

		return (new Point(r*Math.cos(t), r*Math.sin(t), color)).displace(this.a);
	}

	Line.prototype.draw = function(ctx){
		ctx.strokeStyle = this.color;
		ctx.beginPath();
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
		// var corner = a.corner(0, p, angle);

		var height = 2*p;
		var width = a.dist(b);
		return new Rect(a, angle, height, width, color);
	};

	function Vec(a, b, r){
		this.a = a;
		this.b = (new Line(a, b)).rel_point(r, 0);
	}

	Object.assign(Vec.prototype, Line.prototype);

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

		if(marioMode){
			ctx.fillStyle = this.borderColor;
			ctx.fillRect(0, 0, this.width + 2*this.borderWidth, this.height/2 - 1 + this.borderWidth);
			ctx.fillRect(0, 0, this.width + 2*this.borderWidth, -this.height/2 + 1 - this.borderWidth);
		}

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

	Circle.prototype.draw = function(ctx){
		ctx.beginPath();
		ctx.fillStyle = this.color;
		ctx.arc(this.center.x, this.center.y, this.radius, 0, 2*Math.PI);
		ctx.fill();
		if(marioMode){
			ctx.strokeStyle="#000";
			ctx.stroke()
		}
	}

	function Cloud(p){
		this.p = p;
	}

	Cloud.prototype.draw = function(ctx){
		var img = new Image(10, 10);
		img.src = "./assets/img/mario_clouds.png";

		var next = (x, y, img, dir, limit, acc) => {
			if(!marioMode)return;
			ctx.clearRect(x + acc, y, 50, 50);
			if(Math.abs(acc) >= limit){
				x += acc - dir*limit;
				acc = dir*limit;
				dir *= -1;
			}
			acc += dir*Math.random()*0.5;
			ctx.drawImage(img, x + acc, y, 50, 50);
			setTimeout(()=>next(x,y,img, dir, limit, acc), 100);
		}

		img.onload = () => {
			next(this.p.x, this.p.y, img, 1, 10, 0);
		}
	}

	function Floor(p, width, height){
		this.p = p;
		this.height = height;
		this.width = width;
	}
	Floor.prototype.draw = function(ctx) {
		var img = new Image();
		img.src = "./assets/img/mario_floor.png";
		img.onload = ()=>{
			var v = 0;
			while(v < this.width){
				ctx.drawImage(img, this.p.x + v, this.p.y, this.height, this.height);
				v += this.height;
			}

		}

	};

	function whereami(c, corner =null,color="#000"){

		if(corner){
			c.translate(corner.x, corner.y)
		}
		c.beginPath();
		c.fillStyle = color;
		c.arc(0, 0, 5, 0, 2*Math.PI);
		c.fill();
		if(corner){
			c.translate(-corner.x, -corner.y)
		}
	}

	function straight(c, color="#000"){
		c.beginPath();
		c.moveTo(50, 50);
		c.strokeStyle = color;
		c.lineTo(60, 60);
		c.stroke();
	}

	function pointOnCircle(r, a){
		return (new Point(r*Math.cos(a), r*Math.sin(a)));
	}

	function eeff(c, d, limit = 100, start = Math.PI/4, i=0){
		if(i == limit)return;

		var a = start + i*2*Math.PI/limit;
		var l = new Line(pointOnCircle(50, a),pointOnCircle(150, a));
		l.draw(c);
		if(d)
			l.toRect( "#eee", 11).draw(c);
		setTimeout(() => eeff(d, limit, start, i+1),100)
	}

	function drawarc(ctx, point, start, angle){
		console.log(start, angle)
		ctx.fillStyle = "#f00"
		ctx.beginPath();
		ctx.arc(point.x, point.y, 40, start, start + angle);
		ctx.fill();
	}

})(window);

function setInputs({ angles }){
	Object.keys(angles).forEach(name =>{
		var ele = __("#" + name);
		if(ele){
			ele.value = deg(angles[name]);
		}
	})
}

var init = (e) => {
	console.log(e)
	var s = __(".slider");
	if(s)
		s.addEventListener("click", function(e){
			marioMode = !marioMode;
			draw(config);
			if(marioMode == true){
				e.target.setAttribute("val","on");
			}else{
				e.target.setAttribute("val","off");
			}
		});
	(["aq", "sq", "wq"].forEach(name =>{

		var ele = __("#" + name);
		if(ele){
			ele.addEventListener("change", function(e){
				console.log("eeeee")
				if(!config.angles){
					config.angles = {};
				}
				config.angles[name] = rad(parseFloat(ele.value));
				draw(config);
			})
		}
	}));
}
