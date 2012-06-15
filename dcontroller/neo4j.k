/*
 * written by motoki yoan
 */

K.import("konoha");
K.import("konoha.string");
K.import("konoha.curl");
K.import("konoha.json");

/* ----------------------------------------------------------------- */
/* [internal method] */

String _post(String url, String field) {
	Curl c = new Curl();
	String str = "";
	c.setOpt(CURLOPT_URL, url);
	//p(field);
	c.appendHeader("Content-Type: application/json");
	c.setOpt(CURLOPT_POSTFIELDS, field);
	c.setOpt(CURLOPT_WRITEDATA, str);
	c.perform();
	return str;
}

String _get(String url) {
	Curl c = new Curl();
	String str = "";
	c.setOpt(CURLOPT_URL, url);
	c.appendHeader("Content-Type: application/json");
	c.setOpt(CURLOPT_WRITEDATA, str);
	c.perform();
	//p(str);
	return str;
}

String _put(String url, String field) {
	Curl c = new Curl();
	String str = "";
	c.setOpt(CURLOPT_URL, url);
	c.appendHeader("Content-Type: application/json");
	c.setOpt(CURLOPT_PUT, 1);
	c.setOpt(CURLOPT_READDATA, field);
	c.setOpt(CURLOPT_WRITEDATA, str);
	c.perform();
	//p(str);
	return str;
}

String _delete(String url, String field) {
	Curl c = new Curl();
	String str = "";
	c.setOpt(CURLOPT_URL, url);
	c.appendHeader("Content-Type: application/json");
	c.setOpt(CURLOPT_READDATA, field);
	c.setOpt(CURLOPT_WRITEDATA, str);
	c.perform();
	//p(str);
	return str;
}

K.load("relationship.k");
K.load("node.k");
K.load("db.k");
