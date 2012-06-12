//#include "http_io.h"
//#include "dse.h"
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <event.h>
#include <evhttp.h>
#include <sys/queue.h>
#define HTTPD_ADDR "0.0.0.0"
#define HTTPD_PORT 8080

#ifdef __cplusplus
extern "C" {
#endif


#define D_(fmt, ...) fprintf(stderr, fmt, ##__VA_ARGS__)

void dump_http_header(struct evhttp_request *req, struct evbuffer *evb, void *ctx)
{
	struct evkeyvalq *head = evhttp_request_get_input_headers(req);
	struct evkeyval *entry;
	TAILQ_FOREACH(entry, head, next) {
		evbuffer_add_printf(evb, "%s:%s<br>", entry->key, entry->value);
	}
	evhttp_add_header(req->output_headers, "Access-Control-Allow-Origin", "http://localhost:8080/");
	evhttp_add_header(req->output_headers, "Access-Control-Max-Age", "6238800");
	evhttp_add_header(req->output_headers, "Access-Control-Allow-Method", "POST");

	evhttp_send_reply(req, HTTP_OK, "OK", evb);

}
void req_handler (struct evhttp_request *r, void *arg)
{
	struct evbuffer *buf = evbuffer_new();

	if(r->type == EVHTTP_REQ_GET) {
		//evbuffer_add_printf(buf, "Reqested GET: %s\n", evhttp_request_uri(r));
		//evhttp_send_reply(r, HTTP_OK, "OK", buf);
		dump_http_header(r, buf, NULL);

	}
	else if(r->type == EVHTTP_REQ_POST) {
		evbuffer_add_printf(buf, "Reqested POST: %s\n", evhttp_request_uri(r));
		evhttp_send_reply(r, HTTP_OK, "OK", buf);
	}
	else {
		evhttp_send_error(r, HTTP_BADREQUEST, "Available GET only");
	}
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
