/****************************************************************************
 * Copyright (c) 2012, the Konoha project authors. All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ***************************************************************************/

/* ************************************************************************ */
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <event.h>
#include <evhttp.h>
#include <event2/buffer.h>
#include <sys/queue.h>
#include <jansson.h>
#include <dse.h>
#include "dse_debug.h"
#define HTTPD_ADDR "0.0.0.0"
#define HTTPD_PORT 8080

#ifdef __cplusplus
extern "C" {
#endif


struct dse_request_t {
	int method;
	int context;
	int taskid;
	char logpoolip[16];
	char *script;
};



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

#define JSON_INITGET(O, K) \
		json_t *K = json_object_get(O, #K)


static struct dse_request_t *dse_parseJson(const char *input)
{
	json_t *root;
	json_error_t error;
	root = json_loads(input, 0, &error);
	if (!root) {
		D_("error occurs");
		return 1;
	}
	D_("now, parse");
	int i;
///	json_t *taskid, *type, *context,
//		*method, *logpool, *script;
//	taskid= json_object_get(root, "taskid");
	JSON_INITGET(root, taskid);
	JSON_INITGET(root, type);
	JSON_INITGET(root, context);
	JSON_INITGET(root, method);
	JSON_INITGET(root, logpool);
	JSON_INITGET(root, script);

	D_("taskid:%s, type:%s, context:%d",
			json_string_value(taskid),
			json_string_value(type),
			json_string_value(context)
			);
	D_("method:%s, logpool:%s",
			json_string_value(method),
			json_string_value(logpool)
			);
	D_("script:%s", json_string_value(script));
	json_decref(root);
	return 0;
}

void req_handler (struct evhttp_request *req, void *arg)
{
	struct evbuffer *buf = evbuffer_new();
	D_("event handler invoked\n");
	struct evbuffer *body = evhttp_request_get_input_buffer(req);

	size_t len = evbuffer_get_length(body);
	D_("size:%d, %d", len, req->body_size);
	if(req->type == EVHTTP_REQ_GET) {
		//evbuffer_add_printf(buf, "Reqested GET: %s\n", evhttp_request_uri(r));
		//evhttp_send_reply(r, HTTP_OK, "OK", buf);

		dump_http_header(req, buf, NULL);

	}
	else if(req->type == EVHTTP_REQ_POST) {
		// now, we fetch key values
		unsigned char *requestLine;
		requestLine = evbuffer_pullup(body, -1);
		// need to terminate;
		requestLine[len] = '\0';
		//D_("len:%lu, line:'%s'",readsize, requestLine);

		//now, parse json.
		dse_parseJson((const char*)requestLine);


		evbuffer_add_printf(buf, "Reqested POSPOS: %s\n", evhttp_request_uri(req));
		evhttp_send_reply(req, HTTP_OK, "OK", buf);
	}
	else {
		evhttp_send_error(req, HTTP_BADREQUEST, "Available GET only");
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
