#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <unistd.h>
#include <sys/types.h>
#include <string.h>
#include <fcntl.h>
#include <event.h>

#define BUF 256

void
file_read(int fd, short event, void *arg)
{
	char buf[BUF];
	int len;
	struct event*ev= arg;

	event_add(ev, NULL);
	len= read(fd, buf, sizeof(buf) - 1);
	if (len == -1) {
		warn ("can not read");
		return;
	} else if (len == 0) {
		warnx ("close");
		return;
	}

	buf[len] = '\0';
	if (strstr(buf, "TaskDone")) {
		(void) printf ("%s", buf);
	}
}

int
main (int argc, char *argv[])
{
	int fd;
	int flags= O_RDONLY;
	char*file= argv[1];
	if ( (fd = open (file, flags) ) == -1) {
		err(EXIT_FAILURE, "can not open(%s,%d)", file, flags);
	}
	struct event evfile;
	event_init ();
	event_set (&evfile, fd, EV_READ, file_read, &evfile);
	event_add (&evfile, NULL);
	event_dispatch ();

	exit (EXIT_SUCCESS);
}
