#!/usr/local/bin/konoha 

/*
 * dserv.k : dse server program
 * written by Shinpei Nakata
 *
 */

K.import("konoha.bytes");
K.import("konoha.socket");
K.import("konoha.array");
K.import("konoha");
K.import("konoha.pcre");
K.import("konoha.hashmap");
K.import("konoha.subproc");
   //using konoha.io.*;
   //using konoha.json.*;
   //using konoha.subprocess.*;
   //using konoha.ntrace.*;
   //using konoha.posix.*;
   //using konoha.socket.*;

String[] g_dtask_script = new String[0];
g_dtask_script.add("dscript");
g_dtask_script.add("konoha")
g_dtask_script.add("sh");

String[] g_dtask_mode = new String[0];
g_dtask_mode.add("typecheck");
g_dtask_mode.add("commit");
g_dtask_mode.add("monitor");
g_dtask_mode.add("debug");

K.load("drequest.k");

// typedefs
//Req = DTaskRequest;
//Res = DTaskResponse;

//DTaskFunc = Func<Req=>Res>;


DTaskResponse doTypecheck(DTaskRequest req) {
	Subproc s = new Subproc();
	String script_source = "/tmp/" + req.session_id + ".k";
	System.ntraceNotice("script_source", {source : script_source});
	OutputStream ous = new OutputStream(script_source);
	if (ous == null) {
		return new DTaskResponse("error", "cannot create file", req);
	}
	ous << req.body << EOL;
	ous.close();
	System.ntraceNotice("tcheck", {script: req.body});

	// we need synchronous evaluation for type check
	s.call("konoha -c " + script_source, false);
	String response_str = "";
	// FIXME: below code won't run on MacOSX
	if(s.isError()) {
		response_str = s.error();
	}
	if (response_str != "" && "(error)" in? response_str) {
		return new Res("error", response_str, req);
	} else {
		response_str = "type check success";
		return new Res("success", response_str, req);
	}
}

DTaskRequest doCommit(DTaskRequest req) {
	Subproc s = new Subproc();
	String script_source = "/tmp/" + req.session_id + ".k";
	System.ntraceNotice("script_source", {source : script_source});
	OutputStream ous = new OutputStream(script_source);
	if (ous == null) {
		return new DTaskResponse("error", "cannot create file");
	}
	ous << req.body << EOL;
	ous.close();
	
	s.start("konoha " + script_source);
	String str_stdout = "";
	String str_stderr = "";
	boolean flagError = false;
	// it wont wait more than 1 secs;
	for (int i = 0; i < 20; i++) {
		if (!s.isAlive()) {
			System.ntraceNotice("aliveness", {"isAlive": "" + s.isAlive()});
			break;
		}
		if (s.isRead()) {
			str_stdout += s.read();
		}
		if (s.isError()) {
			str_stderr += s.error();
			if ("(error)" in? str_stderr) {
				flagError = true;
			}
		}
		System.usleep(50_000);
	}

	print "hoge";
	if (flagError) {
		debug( "ERROR!!: " + str_stderr);
		return new DTaskResponse("error", str_stderr);
	} else {
		OUT << str_stdout << EOL;;
		return new DTaskResponse("success", str_stdout);
	}
}

DTaskResponse doMonitor(DTaskRequest req) {
	Subproc s = new Subproc();
	String script_source = "/tmp/" + req.session_id + ".k";
	System.ntraceNotice("mode", {mode : "monitor-mode"});
	System.ntraceNotice("script_source", {source : script_source});
	OutputStream ous = new OutputStream(script_source);
	if (ous == null) {
		return new DTaskResponse("error", "cannot create file");
	}
	ous << req.body << EOL;
	ous.close();
	
	s.start("konoha " + script_source);
	String str_stdout = "";
	String str_stderr = "";
	boolean flagError = false;
	// it wont wait more than 1 secs;
	for (int i = 0; i < 20; i++) {
		if (!s.isAlive()) {
			System.ntraceNotice("aliveness", {"isAlive": "" + s.isAlive()});
			break;
		}
		if (s.isRead()) {
			str_stdout += s.read();
		}
		if (s.isError()) {
			str_stderr += s.error();
			if ("(error)" in? str_stderr) {
				flagError = true;
			}
		}
		System.usleep(50_000);
	}
	
	if (flagError) {
		System.ntraceNotice("errstr", {"errstr": str_stderr, "stdstr": str_stdout});
		return new DTaskResponse("error", str_stderr);
	} else {
		System.ntraceNotice("errstr", {"errstr": str_stderr, "stdstr": str_stdout});
		return new DTaskResponse("success", str_stdout);
	}
}


DTaskResponse doDebug(DTaskRequest req) {
	// stub
	return new DTaskResponse("Not implemented yet","debug mode");
}


Map[DTaskFunc] task_functions = new Map[DTaskFunc]();
task_functions.set("typecheck", doTypecheck);
task_functions.set("commit", doCommit);
task_functions.set("monitor", doMonitor);
task_functions.set("debug", doDebug);


DTaskResponse process_request(String text) {
	debug(text);
	Json json = Json.parse(text);
	String s = json["name"];
	debug("size=" + text.getSize());
	debug(s);
    DTaskRequest req = DtaskRequest.parseJson(Json.parse(text));
	debug( "MODE=" + req.mode);
    if (req.script in? DTASK_SCRIPT == false) {
        return new DTaskResponse("failed", "invalid dtask script", req);
    }
    else if (req.mode in? DTASK_MODE == false) {
        return new DTaskResponse("failed", "invalid dtask mode", req);
    }


	DTaskFunc task = task_functions[req.mode];
	DTaskResponse rs = task(req);
	//	System.ntraceNotice("res", {mode: rs});
	return rs;
}

class DSEServer {
	CSock s;
	int fd;
	String bindIP;
	int servingPort;
	int clientPort;

	int major_version = 0;
	int minor_version = 1;
	int build_id = 5;

	DSEServer (String bindIP, int servingPort) {
		_bindIP = bindIP;
		_servingPort = servingPort;
	}

	void startServer() {

	}

	String printVersion() {
		return major_version + "." + minor_version + "." + build_id;
	}
}

boolean verifyReqestHeader (String requestText) {
	if (requestText.getSize() == 0) {
		return false;
	}

	if (!("DSE/0.1" in? requestText) && ("Content-Length" in? requestText)) {
		debug(requestText);
		return false;
	}

	return true;
}


int main (String[] args) {
	DSEServer server = new DSEServer();
	OUT << "DSE Server: v" + server.printVersion() << EOL;

	CSock s;
	int ret;

	String servIP = "127.0.0.1"; // we cannot use "localhost" here
	int servPort = 9999;
	int servFamily = CSock.AF_INET;
	Map servSockInfo = new Map();
	
	String clientIP = "127.0.0.1";
	int clientPort = 9998;
	int clientFamily = CSock.AF_INET;
	
	OUT << "servPort: " << servPort << EOL;
	
	int fd = s.socket(servFamily, CSock.SOCK_STREAM, 0);
	s.optset(fd, CSock.SO_REUSEADDR, 1);
	ret = s.bind(fd, "", servPort, servFamily);
	ret = s.listen(fd, 1);
	OUT <<  "accepting..." << EOL;
	int servFd = s.accept(fd, servSockInfo);

	OUT << "accept done." << EOL;

	
	int[] rfd = [fd, servFd]; // fdsets
	ret = s.select(rfd, null, null, 1, 5_000_000);

	// recv request header first
	Bytes recvbuf = new byte[64];
	recvbuf.setAll(0);
	ret = s.recv(rfd[0], recvbuf, 0);
	
	String recvdata = recvbuf.decode();
	debug(recvdata);
	int contentLength;
	String recvRequestData;
	debug("Request recv size is " + ret + " bytes");

	if (!verifyReqestHeader(recvdata)) {
		ERR << "Request verification is failed." << EOL;
		return 0;
	}

	int idx = 0;
	int lineidx = 0;
	int total_recvsize = ret;
	if (ret != -1 ) {
		if ("\n\n" in? recvdata) {
			// recieved header, and a part of body
			idx = recvdata.indexOf("Content-Length: ");
			lineidx = recvdata.indexOf("\n\n");
			idx += "Content-Length: ".getSize();
			String length = recvdata[idx: ];
			length = length.replace("\n\n", "");
			contentLength = (int)length;
			debug("Requests' content length is: " + contentLength + " bytes");
			recvRequestData = recvdata[lineidx+2: ];
		} else {
			ERR << "Recvdata isn't following DSE protocol" << EOL;
		}
	} else {
		// ret == -1, error.
		ERR << "recv failed." << EOL;
		return 0;
	}

	// check if there are no more packets
	debug("first recv size= " + recvdata.getSize());
	debug("prefetchsize = " + recvRequestData.getSize());
	debug("contentLength = " + contentLength);

	debug("prefetchdText = '" + recvRequestData + "'");
	while (ret != -1 && total_recvsize < contentLength + idx) {
		recvbuf.setAll(0);
		ret = s.recv(rfd[0], recvbuf, 0);
		if (ret != -1) {
			String recvText = recvbuf.decode();
			recvRequestData += recvText;
			debug("recv added, present recv data = " + recvRequestData.getSize());
			total_recvsize += ret;
		}
	}

	/*
	// additional recv
	while (ret == 64) {
		Bytes tmpbuf = new byte[64];
		ret = s.recv(rfd[0], tmpbuf, 0);
		debug("additionaly recv "  + ret + " bytes from client");
		String recvText = tmpbuf.decode();
		recvRequestData += recvText;
	}
	*/

	debug("Recv data size = " + total_recvsize);
	
	DTaskResponse res = process_request(recvRequestData);
	if (res.req == null) {
		s.close(servFd); s.close(fd);
		OUT << "DSE hasn't recv any data" << EOL;
		return 0;
	}

	Json json = res.generateJson();
	String send_text = json.stringify();
	//first send response header.
	DSEProtocolHeader header = res.makeHeader();
	header.contentLength = send_text.getSize();
	String header_str = header.dump();
	Bytes header_buf = header_str.encode();
	ret = s.sendto(rfd[0], header_buf, 0, servIP, servPort, CSock.AF_INET);
	int total_sendsize = ret;
	Bytes data_buf = send_text.encode();
	ret = s.sendto(rfd[0], data_buf, 0, servIP, servPort, CSock.AF_INET);
	total_sendsize+= ret;
	debug("total send bytes: " + total_sendsize);

	s.close(servFd);
	s.close(fd);
	debug("DSE SERVER EXIT");
	return 0;
}
