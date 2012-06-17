K.import("konoha.curl");
K.load("setting.k");

Json createJsonData(Node currentNode) {
	String tid = "taskid";
	String type = "type";
	String ctx = "context";
	String mth = "method";
	String lp = "logpool";
	String scr = "script";

	Json sdata = new Json();
	sdata.setString(tid, currentNode.getPropertyString(tid));
	sdata.setString(type, currentNode.getPropertyString(type));
	sdata.setString(ctx, currentNode.getPropertyString(tid)); // FIXME
	sdata.setString(mth, "eval");
	sdata.setString(lp, "192.168.0.5");
	p(currentNode.getPropertyString(scr));
	sdata.setString(scr, currentNode.getPropertyString(scr));

	return sdata;
}

void postToDse(Json field) {
	Curl c = new Curl();
	String host = getDseHost();
	String port = getDsePort();
	String url = "http://" + host + port;
	p("URL..." + url);
	String request = field.dump();
	String response = "";
	c.setOpt(CURLOPT_URL, url);
	c.appendHeader("Content-Type: application/json");
	c.setOpt(CURLOPT_POSTFIELDS, request);
	c.setOpt(CURLOPT_WRITEDATA, response);
	c.perform();
	p("Request..." + request);
	p("Response..." + response);
	return;
}

void sendNode(Node currentNode) {
	Json sdata;
	Json[] rss;
	String rsName;
	Node next;

	String flowType = currentNode.getPropertyString("FlowType");
	if(flowType == "endEvent") return;
	rss = currentNode.getRelationships();
	rsName = rss[0].getString("type");
	p("Relationship..." + rsName);
	if(flowType == "startEvent") {
		next = currentNode.getEndNode(rsName);
		sendNode(next);
		return;
	}
	sdata = createJsonData(currentNode);
	postToDse(sdata);
	next = currentNode.getEndNode(rsName);
	sendNode(next);
	return;
}

void sendNodes(int startIdx) {
// create DB
	GraphDatabaseService db = new GraphDatabaseService("http://localhost", 7474);
	p("Getting...rootNode");
	Node currentNode = db.getNode(startIdx);
	sendNode(currentNode);
}
