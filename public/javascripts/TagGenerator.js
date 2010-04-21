var TagGenerator = {
	dimRegexp : /^([0-9]{2,4})x([0-9]{2,4})/,
	deliveryHost : "http://cdn.liftium.com/" // default
};

TagGenerator.generateTag = function(f) {
  try {
	var pubid = $("pubid").value;
	if (pubid.toString() === ""){
		alert("You must select a publisher to continue.");	
		return false;
	}
	var size = $("size").value;
	if (size.toString() === ""){
		alert("You must select a size to continue.");	
		return false;
	}
	var comments = $("comments").checked;

	if ($("delivery_iframe").checked){
		var t = $("tag").value = TagGenerator.generateIframeTag(pubid, size, comments);
		$("tag").value = t;
		if ($("preview").checked){
			$("preview_div").innerHTML = t;
			$("preview_iframe").hide();
			$("preview_div").show();
		}
	} else if ($("delivery_adserver").checked){
		$("tag").value = TagGenerator.generateAdServerTag(pubid, size, comments);
		if ($("preview").checked){
			$("preview_div").innerHTML = "";
			TagGenerator.doPreview();
		}
	} else {
		$("tag").value = TagGenerator.generateScriptTag(pubid, size, comments);
		if ($("preview").checked){
			$("preview_div").innerHTML = "";
			TagGenerator.doPreview();
		}
	}

	return false;
  } catch (e) {
	alert("Tag Generator Error " + e.message);
	return false;
  }
};

TagGenerator.generateIframeTag = function(pubid, size, comments){
	var url = TagGenerator.deliveryHost + "tag_iframe?pubid=" + pubid + '&size=' + size;
	var t = '';
	if (comments){ t += '<!-- Begin Liftium Tag -->\n'; }

	var dim = size.match(TagGenerator.dimRegexp);
	if (! dim){
		return false;
	}

	t += '<iframe src="' + url + '" width="' + dim[1] + '" height="' + dim[2] + '"' + 
		' noresize="true" scrolling="no" frameborder="0" marginheight="0"' +
		' marginwidth="0" style="border:none" target="_blank"></iframe>';

	if (comments){ t += '\n<!-- End Liftium Tag -->\n'; }
	return t;
};

TagGenerator.generateScriptTag = function(pubid, size, comments){
        var t = '';
        if (comments){
                t += '<!-- Begin Liftium set up. \n' +
                     'This only needs to appear once on your page, anywhere above the tag. -->\n';
        }

        t += '<script>LiftiumOptions = {pubid:' + pubid + '}<\/script>\n' +
            '<script src="' + TagGenerator.deliveryHost + 'js/Liftium.js"><\/script>\n';

        if (comments){ t += '<!-- End Liftium set up -->\n'; }
        if (comments){ t += '<!-- Display Tag. Put this in the exact place where you want the ad -->\n'; }
        t += '<script>Liftium.callAd("' + size + '")<\/script>';
        return t;
};

TagGenerator.generateAdServerTag = function(pubid, size, comments){
        var t = '<script src="' + TagGenerator.deliveryHost + 'callAd?pubid=' + pubid + '&slot=' + size + '"><\/script>';
        return t;
};

TagGenerator.doPreview = function(){
	var size = $("size").value;
	var dim = size.match(TagGenerator.dimRegexp);
	if (! dim){
		return false;
	}

	var iframe = document.getElementById("preview_iframe");
	iframe.width=dim[1];
	iframe.height=dim[2];
	iframe.style.display="block";

	var f = document.getElementById("preview_form");
	f.html.value = $("tag").value; 
	return f.submit();
};
