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
#ifndef DSE_H_
#define DSE_H_
#include "dse_util.h"
#include <konoha2/konoha2.h>
struct dDserv {
	struct event_base *base;
	struct evhttp *httpd;
};

/* ************************************************************************ */

static struct dDserv *dserv_new(void)
{
	struct dDserv *dserv = dse_malloc(sizeof(struct dDserv));
	dserv->base = event_base_new();
	dserv->httpd = evhttp_new(dserv->base);
	return dserv;
}

static void dserv_close(struct dDserv *dserv)
{
	evhttp_free(dserv->httpd);
	event_base_free(dserv->base);
	dse_free(dserv, sizeof(struct dDserv));
}

/* ************************************************************************ */

struct dReq {
	int method;
	int context;
	int taskid;
	char logpoolip[16];
	char *script;
	char *scriptfilepath;
};

struct dRes {
	int taskid;
	int status;
	char *status_symbol;
	char *status_detail;
};

enum {
	E_METHOD_EVAL,
	E_METHOD_TYCHECK,
	E_STATUS_OK,
};

static struct dReq *newDReq()
{
	struct dReq *ret = (struct dReq *)malloc(sizeof(struct dReq));
	ret->method = 0;
	ret->context = 0;
	ret->taskid = 0;
	memset(ret->logpoolip, 16, 0);
	ret->script = NULL;
	ret->scriptfilepath = (char*)malloc(128);
	memset(ret->scriptfilepath, 128, 0);
	return ret;
}

static struct dRes *newDRes()
{
	struct dRes *ret = (struct dRes *)malloc(sizeof(struct dRes));
	ret->taskid = 0;
	ret->status = 0;
	ret->status_detail = NULL;
	ret->status_symbol = NULL;
	return ret;
}


/* ************************************************************************ */
#define JSON_INITGET(O, K) \
		json_t *K = json_object_get(O, #K)

static struct dReq *dse_parseJson(const char *input)
{
	json_t *root;
	json_error_t error;

	root = json_loads(input, 0, &error);
	if(!root) {
		D_("error occurs");
		return NULL;
	}
	JSON_INITGET(root, taskid);
	JSON_INITGET(root, type);
	JSON_INITGET(root, context);
	JSON_INITGET(root, method);
	JSON_INITGET(root, logpool);
	JSON_INITGET(root, script);

	struct dReq *ret = newDReq();
	if(strncmp(json_string_value(method), "eval", 4) == 0) {
		ret->method = E_METHOD_EVAL;
	}
	else if(strncmp(json_string_value(method), "tycheck", 7) == 0) {
		ret->method = E_METHOD_TYCHECK;
	}
	else{
		D_("error");
		return NULL;
	}
	// store file
	char *filename = ret->scriptfilepath;
	const char *str_context = json_string_value(context);
	size_t context_len = strlen(str_context);
	strncpy(filename, str_context, context_len);
	strncat(filename, ".k", context_len + 2);
	FILE *fp = fopen(filename, "w");
	const char *str_script= json_string_value(script);
	size_t script_len = strlen(str_script);
	fwrite(str_script, script_len, 1, fp);
	fflush(fp);
	fclose(fp);
	json_decref(root);
	return ret;
}


static struct dRes *dse_dispatch(struct dReq *req)
{
	konoha_t konoha = konoha_open();
	int ret;
	D_("scriptpath:%s", req->scriptfilepath);
	struct dRes *dres = newDRes();
	switch (req->method){
	case E_METHOD_EVAL: case E_METHOD_TYCHECK:
		ret = konoha_load(konoha, req->scriptfilepath);
		if(ret == 1) {
			// ok;
			dres->status = E_STATUS_OK;
		}
		break;
	//case E_METHOD_TYCHECK:
	//	break;
	default:
		D_("there's no such method");
		break;
	}
	konoha_close(konoha);
	return dres;
}


static void dse_send_reply(struct evhttp_request *req, struct dRes *dres)
{
	struct evbuffer *buf = evbuffer_new();
	switch(dres->status){
	case E_STATUS_OK:
		evhttp_send_reply(req, HTTP_OK, "OK", buf);
		break;
	default:
		break;
	}
}
#endif /* DSE_H_ */
