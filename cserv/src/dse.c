//#include "http_io.h"
//#include "dse.h"
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <event.h>
#include <evhttp.h>

#define HTTPD_ADDR "0.0.0.0"
#define HTTPD_PORT 8080


#ifdef __cplusplus
extern "C" {
#endif

void req_handler (struct evhttp_request *r, void *arg)
{
	if (r->type != EVHTTP_REQ_GET) 
		evhttp_send_error(r, HTTP_BADREQUEST, "Available GET only");
	else
		evhttp_send_error(r, HTTP_NOTFOUND, "Not Found");
}

int main (int argc, char **av)
{
	struct event_base *ev_base;
	struct evhttp *httpd;

	ev_base = event_base_new();
	httpd = evhttp_new(ev_base);
	if (evhttp_bind_socket(httpd, HTTPD_ADDR, HTTPD_PORT) < 0) {
		perror("evhttp_bind_socket");
		exit(EXIT_FAILURE);
	}
	evhttp_set_gencb(httpd, req_handler, NULL);
	event_base_dispatch(ev_base);
	evhttp_free(httpd);
	event_base_free(ev_base);
}

#ifdef __cplusplus
}
#endif
