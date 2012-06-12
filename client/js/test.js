
function hoge() {
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open("POST", "http://localhost:8080", true);
	xmlhttp.send();
}

$(document).ready(function() {
	hoge();
})

