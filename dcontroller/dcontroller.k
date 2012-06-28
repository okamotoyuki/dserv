K.import("konoha.subproc");
K.load("task.k");
K.load("setting.k");
K.load("fileReader.k");

void main() {
	String logpoolip = getLogPoolIP();
	String monitor = readFile("./monitor.k");
	String recovery1 = readFile("./httpdRestart.k");
	String recovery2 = readFile("./mysqldRestart.k");
	Task resourceMonitor = new Task(1, "resourceMonitor", 1, "eval", logpoolip, monitor);
	Task httpdRestart = new Task(2, "httpdRestart", 2, "eval", logpoolip, recovery1);
	Task mysqldRestart = new Task(3, "mysqldRestart", 3, "eval", logpoolip, recovery2);
	resourceMonitor.sendTo("192.168.0.151", "/dse/command/");
	Subproc sync1 = new Subproc("./a.out, mod_sync1.bc", false);
	sync1.fg();
	httpdRestart.sendTo("192.168.0.151","/dse/command/");
//	httpdRestart.sync(); TODO
	Subproc sync2 = new Subproc("./a.out mod_sync2.bc", false);
	sync2.fg();
	mysqldRestart.sendTo("192.168.0.5", "/dse/command/");
	return;
}

main();
