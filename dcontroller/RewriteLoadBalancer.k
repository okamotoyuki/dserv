// written by shinpei

K.import("konoha");
K.import("konoha.string");
K.import("konoha.bytes");
K.import("posix.file")
K.import("konoha.subproc");
K.import("konoha.pcre");

void recover() {
	FILE f = System.fopen("./apache.conf", "r");
	int bufsize = 32;
	Bytes buf = Bytes.new(bufsize);
	int ret = bufsize;
	String str = "";
	while (ret == bufsize) {
		buf.setAll(0);
		ret = f.read(buf, 0, bufsize);
		if (ret < bufsize) {
			String tmp = buf.toString();
			str = str + tmp.substring(0, ret);
		} else {
			str = str + buf.toString();
		}
	}
	f.close();

	str = str.replace(/0.152/, "0.153");
	FILE f2 = System.fopen("./apache.conf.new", "w");
	int len = str.getSize();
	p(len)
	f2.write(str.toBytes(), 0, len);
	f2.close();

	//	Subproc s = new Subproc("sudo service httpd restart");
	//	s.fg();

	Subproc log = new Subproc("logger TaskDone", false);
	log.fg();
}


recover();
