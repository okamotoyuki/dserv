K.import("konoha.assignment");
K.import("konoha.subproc");

void mysqldRestart() {
	Subproc s = Subproc.new("sudo service mysql restart", false);
	s.fg();
}

mysqldRestart();
