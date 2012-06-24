K.import("konoha");
K.import("konoha.bytes");
K.import("posix.file");

String readFile(String filepath) {
	FILE f = System.fopen(filepath, "r");
	int bufsize = 32;
	Bytes buf = Bytes.new(bufsize);
	int ret = bufsize;
	String str = "";
	while(ret == bufsize) {
		buf.setAll(0); // zero clear
		ret = f.read(buf, 0, bufsize);
		if (ret < bufsize) {
			String tmp = buf.toString();
			str = str + tmp;
		} else {
			str = str + buf.toString();
		}
	}
	return str;
}
