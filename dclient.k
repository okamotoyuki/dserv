/* 
 * DSE client
 * shinpei(c)2012
 */

using konoha.socket.*;
using konoha.json.*;

include "drequest.k";
include "optparse.k";

String servIP = "127.0.0.1";
int servPort = 9999;
int servFamily = CSock.AF_INET;
Map servSockInfo = new Map();
	
String clientIP = "127.0.0.1";
int clientFamily = CSock.AF_INET;

/* option handlers */

String filepath;
// boolean parseFileOption (String arg) {
// 	filepath = arg;
// 	return true;
// }

class DSEClient {
	CSock s;
	int ret;
	int fd;
	String serverIP;
	int serverPort;
	int clientPort;

	int major_version = 0;
	int minor_version = 1;
	int build_id = 6;

	OptionParser op;

	String filepath;
	DTaskRequest dtask;

	String type;
	String mode;
	String name;

	DSEClient (String serverIP, int serverPort) {
		_serverIP = serverIP;
		_serverPort = serverPort;
		_clientPort = 9998;

		/* set option */
		_op = new OptionParser();
		Func<String=>boolean> f = delegate(this, parseFileOption);
	    _op.addOption('-f', '--file', f, "specify script source file", "FILE");
		_op.addOption('-t', '--type', delegate(this, parseTypeOption), "speficy script type", "TYPE");
		_op.addOption('-m', '--mode', delegate(this, parseModeOption), "speficy execution mode", "MODE");
		_op.addOption('-n', '--name', delegate(this, parseNameOption), "speficy dtask name", "NAME");

		/* initialize */
		_filepath = "";
		_type = "konoha";
		_mode = "commit";
		_name = "defaultTask";
	}
	
	boolean parseFileOption (String arg) {
		_filepath = arg;
		debug(_filepath);
		return true;
	}

	boolean parseTypeOption(String arg)	{
		_type = arg;
		print _type;
		return true;
	}

	boolean parseModeOption(String arg)	{
		_mode = arg;
		print _mode;
		return true;
	}

	boolean parseNameOption(String arg)	{
		_name = arg;
		print _name;
		return true;
	}

	String printVersion() {
		return major_version + "." + minor_version + "." + build_id;
	}
	
	void connectToServer () {
		fd = s.socket(CSock.AF_INET, CSock.SOCK_STREAM, 0);
		s.optset(fd, CSock.SO_REUSEADDR, 1);
		ret = s.bind(fd, "", _clientPort, CSock.AF_INET);
		ret = s.connect(fd, _serverIP, _serverPort, CSock.AF_INET);
	}
	
	Map dumpName () {
		return s.name(fd);
	}

	Map dumpPeerName () {
		return s.peername(fd);
	}

	String recvResponse () {
		// first, get response header;
		String response_json = "";
		Bytes buf = new byte[64];
		ret = s.recv(fd, buf, 0);
		debug("response header size is: " + ret);
		String recvdata = buf.decode();
		int contentLength = 0;

		if (ret != -1 && ret == 64) {
			if ("\n\n" in? recvdata) {
				int idx = recvdata.indexOf("Content-Length: ");
				int lineidx = recvdata.indexOf("\n\n");
				idx += "Content-Length: ".getSize();
				String length = recvdata[idx: ];
				length = length.replace("\n\n", "");
				contentLength = (int)length;
				OUT <<  "content length is :" + contentLength << EOL;
				
				// puts recieved response at the header
				response_json = recvdata[lineidx+2: ];
			} else {
				// ERROR, wrong format, or protocol
				ERR << "Recvdata isn't following DSE protocol" << EOL;
				return response_json;
			}
		} else {
			// It already received enough data
			if ("\n\n" in? recvdata) {
				int idx = recvdata.indexOf("Content-Length: ");
				int lineidx = recvdata.indexOf("\n\n");
				idx += "Content-Length: ".getSize();
				String length = recvdata[idx: ];
				length = length.replace("\n\n", "");
				contentLength = (int)length;
				debug("content length is :" + contentLength);
				
				response_json = recvdata[lineidx+2: ];
			} else {
				// ERROR, wrong format, or protocol
				OUT << "Is this DSE Protocol??" << EOL;
				return response_json;
			}
		}

		// now, recieve leftover
		Bytes recvbuf;
		while (ret == 64) {
			recvbuf = new byte[64];
			ret = s.recv(fd, recvbuf, 0);
			debug("additional recv data size=" + ret);
			String recvText = recvbuf.decode();
			response_json += recvText;
		}
		return response_json;
	}

	void setupRequest () {
		if (filepath == "") {
			_dtask = new DTaskRequest(
				 "mytask", "konoha", "typecheck",
				 "1223", "hoge", "localhost",
				 "int i = 1;");
			return;
		}

		InputStream ins = new InputStream(filepath);
		String text = "";
		foreach(String line in ins) {
			debug(line);
			text += line;
		}
		
		_dtask = new DTaskRequest (_name, _type, _mode,
								   "1234", "hoge", "localhost",
								   text);

	}

	boolean sendRequest () {
		Bytes body_buf = new byte[0];
		body_buf.writeJson(_dtask);
		String writeText = body_buf.decode();
		Json js = Json.parse(writeText);
		String hoge2 = js["mode"];
		String hoge = js["name"];
		DSEProtocolHeader header = _dtask.makeHeader();
		// set information
		header.contentLength = body_buf.getSize();
		String header_str = header.dump();		
		String sending_data = header_str + writeText;
		Bytes sending_buf = sending_data.encode();
		int total_sendsize = 0;
		ret = s.send(fd, sending_buf, 0);
		total_sendsize += ret;
		s.shutdown(); // send FIN
		OUT << "total send size: " + total_sendsize << EOL;
		return true;
	}

	void closeClient () {
		s.close();
	}
}

int main (String[] args)
{
	DSEClient client = new DSEClient(servIP, servPort);

	OUT << "DSE Client: v" + client.printVersion() << EOL;
	DTaskRequest myreq;
	if (args.getSize() > 0) {
		// parse options
		if (!client.op.parse(args)) {
			print "Something wrong with your arguments";
			return 0;
		}
	}
	client.connectToServer();
	client.setupRequest();
	String response = "";
	if (client.sendRequest()) {
		response = client.recvResponse();
	} else {
		ERR << "Request failed" << EOL;
		return 0;
	}
	Json m = Json.parse(response);
	
	client.closeClient();

	debug("DSE Client END");
	return 0;
}
