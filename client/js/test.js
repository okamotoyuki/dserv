
function hoge() {
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open("POST", "http://localhost/dse/command/", true);
	xmlhttp.send();
}

$(document).ready(function() {
	hoge();
})

