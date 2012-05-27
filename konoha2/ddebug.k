
/* written by shinpei */

//using konoha.ntrace.*;


void info (String msg) {
	p("INFO: " + msg);
}

void debug(String msg) {
	boolean isDebug = true;
	boolean isNtrace = false;
	if (isDebug){
		if (isNtrace) {
			//			System.ntraceNotice("debug", {"msg": msg});
		} else {
			OUT << "DBG: " + msg << EOL;
		}
	}
}
