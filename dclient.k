/* DSE client
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
	int build_id = 5;

	OptionParser op;

	String filepath;
	
	DSEClient (String serverIP, int serverPort) {
		_serverIP = serverIP;
		_serverPort = serverPort;
		_clientPort = 9998;

		/* set option */
		op = new OptionParser();
		//		Func<String=>void> f = parseFileOption;
		Func<String=>boolean> f = delegate(DSEClient, parseFileOption);
	    op.addOption('-f', '--file', f, "specify script", "FILE");
	}

	@Static boolean parseFileOption (String arg) {
		filepath = arg;
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
				print "content length is :" + contentLength;
				
				response_json = recvdata[lineidx+2: ];
			} else {
				// ERROR, wrong format, or protocol
				print "Is this DSE Protocol??";
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

	Boolean sendRequest (DTaskRequest req) {
		Bytes body_buf = new byte[0];
		body_buf.writeJson(req);
		String writeText = body_buf.decode();
		print writeText;
		print writeText.getSize();
		Json js = Json.parse(writeText);
		String hoge2 = js["mode"];
		String hoge = js["name"];
		print hoge + hoge2;
		DSEProtocolHeader header = req.makeHeader();
		// set information
		header.contentLength = body_buf.getSize();
		String header_str = header.dump();		
		String sending_data = header_str + writeText;
		Bytes sending_buf = sending_data.encode();
		int total_sendsize = 0;
		ret = s.send(fd, sending_buf, 0);
		total_sendsize += ret;
		/*
		Bytes header_buf;


		header_buf = header_str.encode();
		//		ret = s.sendto(fd, header_buf, 0, serverIP, serverPort, CSock.AF_INET);
		ret = s.send(fd, header_buf, 0);
		if (ret != -1) {
			total_sendsize += ret;
		} else {
			// error 
			ERR << "sendto failed!" << EOL;
			return false;
		}
		//		ret = s.sendto(fd, body_buf, 0, serverIP, serverPort, CSock.AF_INET);
		ret = s.send(fd, body_buf, 0);
		if (ret != -1) {
			total_sendsize += ret;
		} else {
			ERR << "sendto failed!" << EOL;
			return false;
		}
		*/
		s.shutdown(); // send FIN
		OUT << "total send size: " + total_sendsize << EOL;
		return true;
	}

	void closeClient () {
		s.close();
	}
}

Boolean parse_option(String[] args, DSEClient client)
{
	
	int argc = args.getSize();
	if (argc % 2 == 1) return false;
	
		
	return true;
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
	myreq = new DTaskRequest(
				 "mytask", "konoha", "typecheck",
				 "1223", "hoge", "localhost",
				 "int i = 1;");
	String response = "";
	if (client.sendRequest(myreq)) {
		response = client.recvResponse();
	} else {
		ERR << "Request failed" << EOL;
		return 0;
	}
	Json m = Json.parse(response);
	print m;
	
	client.closeClient();

	debug("DSE Client END");
	return 0;
}
