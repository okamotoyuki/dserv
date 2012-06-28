K.import("konoha.json");
K.import("konoha.curl");
K.import("konoha");

class Task {
	int taskid;
	String type;
	int context;
	String method;
	String logpool;
	String script;

	Task(int taskid, String type, int context, String method, String logpool, String script) {
		this.taskid = taskid;
		this.type = type;
		this.context = context;
		this.method = method;
		this.logpool = logpool;
		this.script = script;
	}

	void sendTo(String host, String port) {
		Json sdata = new Json();
		sdata.setString("taskid", this.taskid + ""); // TODO setInt();
		sdata.setString("type", this.type);
		sdata.setString("context", this.context); // TODO setInt();
		sdata.setString("method", this.method);
		sdata.setString("logpool", this.logpool);
		sdata.setString("script", this.script);

		String req = sdata.dump();
		String res = "";

		Curl c = new Curl();
		String url = "http://" + host + port;
		c.setOpt(CURLOPT_URL, url);
		c.appendHeader("Content-Type: application/json");
		c.setOpt(CURLOPT_POSTFIELDS, req);
		c.setOpt(CURLOPT_WRITEDATA, res);
		c.perform();
		return;
	}

	void sync() {
		// syncronize
		return;
	}
}
