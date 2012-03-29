using konoha.socket.*;
using konoha.json.*;

include "drequest.k";

String servIP = "127.0.0.1";
int servPort = 9999;
int servFamily = CSock.AF_INET;
Map servSockInfo = new Map();
	
String clientIP = "127.0.0.1";
int clientFamily = CSock.AF_INET;

class DSEClient {
	CSock s;
	int ret;
	int fd;
	String serverIP;
	int serverPort;
	int clientPort;

	int major_version = 0;
	int minor_version = 1;
	int build_id = 2;

	DSEClient (String serverIP, int serverPort) {
		_serverIP = serverIP;
		_serverPort = serverPort;
		_clientPort = 9998;

	}
	String printVersion() {
		return major_version + "." + minor_version + "." + build_id;
	}
	
	void connectToServer () {
		fd = s.socket(CSock.AF_INET, CSock.SOCK_STREAM, 0);
		ret = s.bind(fd, "", _clientPort, CSock.AF_INET);
		ret = s.connect(fd, _serverIP, _serverPort, CSock.AF_INET);
	}
	
	Map dumpName () {
		return s.name(fd);
	}

	Map dumpPeerName () {
		return s.peername(fd);
	}

	String  sendRequest (DTaskRequest req) {
		String response_json = "";
		Bytes body_buf = new byte[0];
		body_buf.writeJson(req);
		DSEProtocolHeader header = req.makeHeader();

		// set information
		header.contentLength = body_buf.getSize();

		Bytes header_buf = new byte[0];
		String header_str = header.dump();
		header_buf = header_str.encode();
		print header_str ;
		print body_buf.decode();
		ret = s.sendto(fd, header_buf, 0, serverIP, serverPort, CSock.AF_INET);
		ret = s.sendto(fd, body_buf, 0, serverIP, serverPort, CSock.AF_INET);
		OUT << "send size: " + ret << EOL;


		// first, get response header;
		Bytes buf = new byte[64];
		ret = s.recv(fd, buf, 0);
		print "response header size is: " + ret;
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
				print "content length is :" + contentLength;
				
				// puts recieved response at the header
				response_json = recvdata[lineidx+2: ];
			} else {
				// ERROR, wrong format, or protocol
				print "Is this DSE Protocol??"
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
				print "content length is :" + contentLength;
				
				response_json = recvdata[lineidx+2: ];
			} else {
				// ERROR, wrong format, or protocol
				print "Is this DSE Protocol??"
				return response_json;
			}
		}

		// now, recieve leftover
		Bytes recvbuf;
		while (ret == 64) {
			recvbuf = new byte[64];
			ret = s.recv(fd, recvbuf, 0);
			OUT << "additional recv data size=" << ret << EOL;
			String recvText = recvbuf.decode();
			response_json += recvText;
		}
		return response_json;
	}

	void closeClient () {
		/*String error =  s.perror();
		if (!(error in? "Success")) {
			print error;
		}
		*/
		s.close();
	}
}


int main (String[] args) {
	DSEClient client = new DSEClient(servIP, servPort);
	OUT << "DSE Client: v" + client.printVersion() << EOL;
	DTaskRequest myreq;
	if (args.getSize() == 0) {
		client.connectToServer();
		//OUT << client.dumpName() << EOL;
		//OUT << client.dumpPeerName() << EOL;
		myreq = new DTaskRequest("mytask", "konoha", "typecheck",
											  "1223", "hoge", "localhost",
											  "int i = 1;");
	} else {
		// parse options
		parse_option(args);

	}
	String response = client.sendRequest(myreq);
	m = Json.parse(response);
	print m;
	client.closeClient();

	OUT << "DSE Client END" << EOL;
}
