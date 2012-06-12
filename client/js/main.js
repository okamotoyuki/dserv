//var host = "192.168.0.9";
//var host = "127.0.0.1";
var host = "localhost";
var port = "8080";
var prev_script;
var prev_mode;
var script_color_selected = "green";
var script_color_hover = "forestgreen";
var script_color_normal = "mediumaquamarine";

var mode_color_selected = "hotpink";
var mode_color_hover = "wheat";
var mode_color_normal = "pink";

function hookXhr()
{
    var xhr = function(){
        this.readyState = 0; // uninitialized
        this.responseText = "";
        this.status = "";
        this.onreadstatechange = undefined;
        var xdr = new XDomainRequest();

        xdr.onprogress = function(){
            var f;
            this.xhr.readyState = 2; // loaded
            if( this.xhr && ( f = this.xhr.onreadystatechange ) ){
                f.apply( this.xhr );
            }
        };

        xdr.onload = function(){
            var f;
            this.xhr.readyState = 3;    // interactive
            if( this.xhr && ( f = this.xhr.onreadystatechange ) ){
                f.apply( this.xhr );
            }
            this.xhr.responseText = xdr.responseText;
            this.xhr.readyState = 4;    // complete
            this.xhr.status = "200";
            if( f ){
                f.apply( this.xhr );
            }
        };

        this.open = function( method, url, async ){
            return xdr.open( method, url, async );
            readyState = 1;
        }
        this.send = function( body ){
            xdr.send( body );
        };
        this.setRequestHeader = function( headerName, headerValue ){
        };
        this.getResponseHeader = function( headerName ){
            if( headerName.match( /^Content\-Type$/i ) ){
                return xdr.contentType;
            }else{
                return "";
            }
        };
        xdr.xhr = this;
        return this;
    };
    return new xhr();
}


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
		console.log(window.XDomainRequest ? true : false);
		$.ajax({
			type: 'POST',
			//url: 'http://' + host + '/cgi-bin/drecv.k',
			url: 'http://' + host + ':' + port + '/',
			data: JSON.stringify(json),
			xhr: window.XDomainRequest ? hookXhr : undefined,
			contentType: 'text/plain',
			success:function(msg) {
				console.log(msg);
			}
		});
	});
});
