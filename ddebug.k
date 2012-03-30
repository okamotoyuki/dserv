using konoha.ntrace.*;

IS_DEBUG = true;
IS_NTRACE = false;


void info (String msg)
{
	OUT << "INFO: " + msg << EOL;
}

void debug(String msg)
{
	if (IS_DEBUG) {
		if (IS_NTRACE) {
			System.ntraceNotice("debug", {"msg": msg});
		} else {
			OUT << "DBG: " + msg << EOL;
		}
	}
}
