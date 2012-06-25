K.import("konoha.assignment");
K.import("konoha.subproc");

void monitor() {
	Subproc s = Subproc.new("/usr/bin/dvmstat --logpool=192.168.0.2 1", false);
	s.bg();
}

monitor();
