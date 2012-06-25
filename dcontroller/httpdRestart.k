K.import("konoha.assignment");
K.import("konoha.subproc");

void restartHttpd() {
	Subproc s = Subproc.new("", false);
	s.exec("sudo service httpd restart");
}

restartHttpd();
