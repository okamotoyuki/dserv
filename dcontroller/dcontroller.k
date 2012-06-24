K.load("task.k");
K.load("setting.k");

void main() {
	Task t1 = new Task(1, "hoge", 1, "eval", "0.0.0.0", "p(1);");
	t1.sendTo(getDseHost(), getDsePort());
	return;
}

main();
