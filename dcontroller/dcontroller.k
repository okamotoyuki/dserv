K.load("task.k");

void main() {
	Task monitor = new Task(1, "monitor", 1, "eval", "192.168.0.2", "p(1);");
	Task recovery = new Task(2, "recovery", 2, "eval", "192.168.0.2", "p(2);");
	monitor.sendTo("192.168.0.151", "/dse/command/");
	monitor.sync(1);
	recovery.sendTo("192.168.0.151","/dse/command/");
	return;
}

main();
