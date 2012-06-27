K.import("konoha.assignment");
K.import("konoha.subproc");

void restartHttpd() {
	Subproc s = Subproc.new("sudo service httpd restart", false);
	s.fg();
}

restartHttpd();
