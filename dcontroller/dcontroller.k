K.load("task.k");
K.load("setting.k");
K.load("fileReader.k");

void main() {
	String logpoolip = getLogPoolIP();
	String monitorScript = readFile("./monitor.k");
	Task monitor = new Task(1, "monitor", 1, "eval", logpoolip, monitorScript);
	Task recovery = new Task(2, "recovery", 2, "eval", logpoolip, "p(2);");
	monitor.sendTo("192.168.0.151", "/dse/command/");
	monitor.sync(1);
	recovery.sendTo("192.168.0.151","/dse/command/");
	return;
}

main();
