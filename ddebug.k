using konoha.ntrace.*;

IS_NTRACE = false;

void debug(String msg)
{
	if (IS_NTRACE) {
		System.ntraceNotice("debug", {"msg": msg});
	} else {
		OUT << msg << EOL;
	}
}
