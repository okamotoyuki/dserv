K.load("task.k");

void main() {
	Task t1 = new Task(1, "hoge", 10012, "eval", "192.168.0.2", "p(1);");
	t1.sendTo("192.168.0.151", "/dse/command/");
	return;
}

main();
