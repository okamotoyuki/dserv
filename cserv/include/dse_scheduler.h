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

#ifndef DSE_SCHEDULER_H_
#define DSE_SCHEDULER_H_

#include <pthread.h>

#define DREQ_QUEUE_SIZE 16
#define next(index) (((index) + 1) % DREQ_QUEUE_SIZE)

struct dScheduler {
	struct dReq *dReqQueue[DREQ_QUEUE_SIZE];
	int front;
	int last;
	pthread_mutex_t lock;
	pthread_cond_t cond;
};

static struct dScheduler *newDScheduler(void)
{
	struct dScheduler *dscd = dse_malloc(sizeof(struct dScheduler));
	dscd->front = 0;
	dscd->last = 0;
	pthread_mutex_init(&dscd->lock, NULL);
	pthread_cond_init(&dscd->cond, NULL);
	return dscd;
}

static void deleteDScheduler(struct dScheduler *dscd)
{
	pthread_mutex_destroy(&dscd->lock);
	pthread_cond_destroy(&dscd->cond);
	dse_free(dscd, sizeof(struct dScheduler));
}

static bool dse_enqueue(struct dScheduler *dscd, struct dReq *dreq)
{
	int front = dscd->front;
	int last = dscd->last;
	if(next(front) == last) return false;
	dscd->dReqQueue[front] = dreq;
	dscd->front = next(front);
	return true;
}

static struct dReq *dse_dequeue(struct dScheduler *dscd)
{
	int front = dscd->front;
	int last = dscd->last;
	if(front == last) return NULL;
	struct dReq *dreq = dscd->dReqQueue[last];
	dscd->last = next(last);
	return dreq;
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

static void *dse_dispatch(void *arg)
{
	kplatform_t *dse = platform_dse();
	konoha_t konoha;
	logpool_t *lp;
	struct dScheduler *dscd = (struct dScheduler *)arg;
	struct dReq *dreq;
	struct dRes *dres;
	int ret;
	void *logpool_args;
	while(true) {
		pthread_mutex_lock(&dscd->lock);
		if(!(dreq = dse_dequeue(dscd))) {
			pthread_cond_wait(&dscd->cond, &dscd->lock);
			dreq = dse_dequeue(dscd);
		}
		pthread_mutex_unlock(&dscd->lock);
		D_("scriptpath:%s", dreq->scriptfilepath);
		dres = newDRes();
		konoha = konoha_open((const kplatform_t *)dse);
		switch (dreq->method){
			case E_METHOD_EVAL: case E_METHOD_TYCHECK:
				lp = dse_openlog(dreq->logpoolip);
				dse_record(lp, &logpool_args, "task",
						KEYVALUE_u("context", dreq->context),
						KEYVALUE_s("status", "start"),
						LOG_END);
				ret = konoha_load(konoha, dreq->scriptfilepath);
				dse_record(lp, &logpool_args, "task",
						KEYVALUE_u("context", dreq->context),
						KEYVALUE_s("status", "done"),
						LOG_END);

				dse_closelog(lp);
				//		eval_actor(dreq);
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
		dse_send_reply(dreq->req, dres);
		deleteDReq(dreq);
		deleteDRes(dres);
	}
}

#endif /* DSE_SCHEDULER_H_ */
