var host = "192.168.0.9";
var prev_script;
var prev_mode;
var script_color_selected = "green";
var script_color_hover = "forestgreen";
var script_color_normal = "mediumaquamarine";

var mode_color_selected = "hotpink";
var mode_color_hover = "wheat";
var mode_color_normal = "pink";

$(document).ready(function() {
	$(".dse-select-script-type span").hover(function() {
		if (prev_script.text() != $(this).text()) {
			$(this).css({backgroundColor:script_color_hover});
		}
	}, function() {
		if (prev_script.text() != $(this).text()) {
			$(this).css({backgroundColor:script_color_normal});
		}
	});

	$(".dse-select-mode span").hover(function() {
		if (prev_mode.text() != $(this).text()) {
			$(this).css({backgroundColor:mode_color_hover});
		}
	}, function() {
		if (prev_mode.text() != $(this).text()) {
			$(this).css({backgroundColor:mode_color_normal});
		}
	});

	$(".dse-select-script-type span").each(function() {
		var text = $(this).text();
		if (text == "konoha") {
			prev_script = $(this);
			$(this).css({backgroundColor:script_color_selected});
		}
	});

	$(".dse-select-mode span").each(function() {
		var text = $(this).text();
		if (text == "typecheck") {
			prev_mode = $(this);
			$(this).css({backgroundColor:mode_color_selected});
		}
	});

	$(".dse-select-script-type span").click(function(event) {
		var type = event.srcElement.innerHTML;
		$(this).css({backgroundColor:script_color_selected});
		prev_script.css({backgroundColor:script_color_normal});
		prev_script = $(this);
	});

	$(".dse-select-mode span").click(function(event) {
		var mode = event.srcElement.innerHTML;
		$(this).css({backgroundColor:mode_color_selected});
		prev_mode.css({backgroundColor:mode_color_normal});
		prev_mode = $(this);
	});

	$(".dse-submit-button").click(function() {
		var script = $(".dse-script-area").val();
		var json = {
			"name": "DTask",
			"script" : prev_script.text(),
			"session_id" : "" + Math.floor(Math.random() * 1234),
			"mode" : prev_mode.text(),
			"resource" : "hoge",
			"logpool_server" : "192.168.0.5",
			"body" : script
		};
		console.log(prev_script.text());
		console.log(json);
		console.log(JSON.stringify(json));
		$.ajax({
			type: 'POST',
			url: 'http://' + host + '/cgi-bin/drecv.k',
			data: JSON.stringify(json),
			contentType: 'text/plain',
			success:function(msg) {
				console.log(msg);
			}
		});
	});
});
