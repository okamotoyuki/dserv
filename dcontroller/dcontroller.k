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
//	resourceMonitor.sync(1);
//	httpdRestart.sendTo("192.168.0.151","/dse/command/");
//	mysqldRestart.sendTo("192.168.0.151", "/dse/commnd/");
	return;
}

main();
