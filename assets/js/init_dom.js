const template = '<canvas id="playground" width="1100" height="300"></canvas>'
		// <div id="controls">\
		//   <div><label>angle Aq</label><input type="number" id="aq"></div>\
    // 	<div><label>angle Wq</label><input type="number" id="wq"></div>\
    //   <div><label>angle Sq</label><input type="number" id="sq"></div>\
		// 	<div>\
		// 		Mario Mode: \
		// 		<span class="slider"></span>\
		// 	</div>\
		// 	\
		// </div>'

var main = document.createElement("div");
main.setAttribute("id", "main");
main.innerHTML = template;
document.body.appendChild(main);

function changeTo(v, config){
	Object.assign(config, v);
}
