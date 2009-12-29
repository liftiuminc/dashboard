// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


/* Create a form and submit it. 
 * action is the url to post to
 * params is the key values 
 * method is the html method (POST or GET) - default "POST"
 * target is the window to target - default "_blank"
 */
function externalFormPost(action, params, method, target){
	var div = document.createElement("div");
	var f = document.createElement("form");
	f.action = action;
	f.id = "myform_" + Math.random();
	f.method = method || "POST";
	f.target = target || "_blank";
	f.style.display = "none";

	for (var name in params){
		var field = document.createElement("input");
		field.name = name;
		field.type = "hidden";
		field.value = params[name];
		f.appendChild(field);
	}

	document.body.appendChild(f);
	return document.getElementById(f.id).submit();
}


/* Reset a form to blank values */
function blankForm (f){
	for (var i = 0; i < f.elements.length; i++){
		var field = f.elements[i];
		switch (field.tagName.toLowerCase()){
		  case "select": f.elements[i].selectedIndex=0; break;
		  case "input":
			if (field.type == "text"){
				field.value = "";
			}
			break;
		  // Unsupported form element type
		  default : break;
		}
	}
}
