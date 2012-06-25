K.import("konoha.assignment");
K.import("konoha.subproc");

void mysqldRestart() {
	Subproc s = Subproc.new("", false);
	s.exec("sudo service mysqld restart");
}

mysqldRestart();
