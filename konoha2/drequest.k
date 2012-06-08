// written by shinpei

//using konoha.json.*;
K.import("konoha");
K.import("konoha.string");

K.load("ddebug.k");

String logpoolDefaultIP = "127.0.0.1";
String defaultSessionID = "12345";

//Type DSEScriptType = int;
//Type DSEExecMode = int;

int typeDscript = 0;
int typeKonoha = 1;
int typeShell = 2;

int modeTypecheck = 0;
int modeMonitor = 1;
int modeCommit = 2;
int modeDebug = 3;

class DSEProtocolHeader {
	int type;
	int mode;

	int contentLength;
	//@Const int DSCRIPT = 1

	DSEProtocolHeader (int type, int mode) {
		this.type = type;
		this.mode = mode;
		this.contentLength = 0;
	}

	@Public String dump () {
		String[] type_string = ["dscript", "konoha", "sh"];
		String[] mode_string = ["typecheck", "monitor", "commit", "debug"];
	
		// is ready??
		String header_str = "";
		if ( 0 <= this.type && this.type <= 2 && 0<= this.mode && this.mode <= 3) {
			header_str = type_string[this.type] + " " + mode_string[this.mode] + " " + "DSE/0.1" + EOL;
		} else {
			// not ready.
			return  "";
		}
		header_str += "Content-Length: " + this.contentLength + EOL;
		header_str += EOL;
		return header_str;
	}
}

class DTaskRequest {
	String name;
	String script;
	String mode;
	String session_id;
	String resource;
	String logpool_server;
	String body;

	DTaskRequest(String name, String script, String mode,
				 String session_id, String resource,
				 String logpool_server, String body)	{
		this.name = name;
		this.script = script;
		this.mode = mode;
		this.session_id = session_id;
		this.resource = resource;
		this.logpool_server = logpool_server;
		this.body = body;
	}

	@Public DSEProtocolHeader makeHeader() {
		Map inverseTypeMap = {dscript: 0, konoha: 1, sh: 2};
		Map inverseModeMap = {typecheck: 0, monitor: 1, commit: 2, debug: 3};
		DSEProtocolHeader header = new DSEProtocolHeader(inverseTypeMap[this.script], inverseModeMap[this.mode]);
		return header;
	}
}

class DTaskResponse {
	String result;
	String message;
	DTaskRequest req;
	
	DTaskResponse(String result, String message, DTaskRequest req)	{
		this.result = result;
		this.message = message;
		this.req = req;
	}

	/*
	  Json generateJson() {
        Json json = new Json();
        json["result"]  = this.result;
        if (this.message.getSize() > 0) json["message"] = this.message;
        return json;
    }
	*/

	/*
	@Public DSEProtocolHeader makeHeader() {
		Map inverseTypeMap = {dscript: 0, konoha: 1, sh: 2};
		Map inverseModeMap = {typecheck: 0, monitor: 1, commit: 2, debug: 3};
		if (req != null) {
			debug("#########################");
			debug("type: " + req.script + " mode: " + req.mode);
			debug("#########################");
			DSEProtocolHeader header = new DSEProtocolHeader(inverseTypeMap[req.script], inverseModeMap[req.mode]);
			return header;
		} else {
			return null;
		}
	}
	*/
}

