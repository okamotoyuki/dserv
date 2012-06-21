K.load("task.k");
K.load("setting.k");

void main() {
	Task t1 = new Task(1, "hoge", 1, "eval", "192.168.0.5", "p(1);");
	Task t2 = new Task(2, "hoge", 2, "eval", "192.168.0.5", "p(2);");
	t1.sendTo(getDseHost(), getDsePort());
	t2.sendTo(getDseHost(), getDsePort());
	return;
}

main();
