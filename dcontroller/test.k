K.load("task.k");
K.load("setting.k");

void main() {
	Task t1 = new Task(1, "hoge", 1, "eval", "192.168.0.5", "K.import(\"konoha\");\nK.import(\"konoha.subproc\");\np(1);");
	t1.sendTo(getDseHost(), getDsePort());
	return;
}

main();
