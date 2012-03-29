using konoha.json.*;

LOGPOOL_DEFAULT_IP = "127.0.0.1";
DEFAULT_SESSION_ID = "12345";

DSEScriptType = int;
DSEExecMode = int;

TYPE_DSCRIPT = 0;
TYPE_KONOHA = 1;
TYPE_SH = 2;

MODE_TYPECHECK = 0;
MODE_MONITOR = 1;
MODE_COMMIT = 2;
MODE_DEBUG = 3;

class DSEProtocolHeader {
	DSEScriptType type;
	DSEExecMode mode;

	int contentLength;
	//@Const int DSCRIPT = 1

	DSEProtocolHeader (DSEScriptType type, DSEExecMode mode) {
		_type = type;
		_mode = mode;
		_contentLength = 0;
	}

	@Public String dump () {
		String[] type_string = ["dscript", "konoha", "sh"];
		String[] mode_string = ["typecheck", "monitor", "commit", "debug"];
	
		// is ready??
		String header_str = "";
		if ( 0 <= _type && _type <= 2 && 0<= _mode && _mode <= 3) {
			header_str = type_string[_type] + " " + mode_string[_mode] + " " + "DSE/0.1" + EOL;
		} else {
			// not ready.
			return  "";
		}
		header_str += "Content-Length: " + _contentLength + EOL;
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
				 String logpool_server, String body)
	{
		_name = name;
		_script = script;
		_mode = mode;
		_session_id = session_id;
		_resource = resource;
		_logpool_server = logpool_server;
		_body = body;
	}

    @Static DTaskRequest parseJson(Json json) {
        DTaskRequest req = new DTaskRequest();
        req.name      = ("name" in? json)      ? json["name"]      : "<name>";
        req.script    = ("script" in? json)    ? json["script"]    : "konoha";
        req.mode      = ("mode" in? json)      ? json["mode"]      : "<mode>";
		req.session_id = ("session_id" in? json)  ? json["session_id"]: DEFAULT_SESSION_ID;
        req.resource  = ("resource" in? json)  ? json["resource"]  : "<resource>";
        req.logpool_server   = ("logpool_server" in? json)   ? json["logpool_server"]   : LOGPOOL_DEFAULT_IP;
        req.body      = ("body" in? json)      ? json["body"]      : "";
        return req;
    }

	@Public DSEProtocolHeader makeHeader() {
		Map inverseTypeMap = {dscript: 0, konoha: 1, sh: 2};
		Map inverseModeMap = {typecheck: 0, monitor: 1, commit: 2, debug: 3};
		DSEProtocolHeader header = new DSEProtocolHeader(inverseTypeMap[_script], inverseModeMap[_mode]);
		return header;
	}
}

class DTaskResponse {
	String result;
	String message;
	DTaskRequest req;
	
	DTaskResponse(String result, String message, DTaskRequest req)
	{
		_result = result;
		_message = message;
		_req = req;
	}

    Json generateJson() {
        Json json = new Json();
        json["result"]  = _result;
        if (_message.getSize() > 0) json["message"] = _message;
        return json;
    }

	@Public DSEProtocolHeader makeHeader() {
		Map inverseTypeMap = {dscript: 0, konoha: 1, sh: 2};
		Map inverseModeMap = {typecheck: 0, monitor: 1, commit: 2, debug: 3};

		DSEProtocolHeader header = new DSEProtocolHeader(inverseTypeMap[req.script], inverseModeMap[req.mode]);
		return header;
	}
}

