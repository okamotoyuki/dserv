#include <logpool/pool_plugin.h>
#include <stdio.h>

static bool val_gt(void *v0, void *v1, uint16_t l0, uint16_t l1)
{
   int n0 = strtol(v0, NULL, 10);
   int n1 = strtol(v1, NULL, 10);
   fprintf(stderr, "%s:%d %d, %d\n", __FILE__, __LINE__, n0, n1);
   return n0 < n1;
}

struct pool_plugin *dump_init(struct bufferevent *bev)
{
   struct pool_plugin_print *p0 = POOL_PLUGIN_CLONE(pool_plugin_print);
   struct pool_plugin_val_filter *p1 =
POOL_PLUGIN_CLONE(pool_plugin_val_filter);
   struct pool_plugin_response *p2 = POOL_PLUGIN_CLONE(pool_plugin_response);
   struct pool_plugin_close *p3 = POOL_PLUGIN_CLONE(pool_plugin_close);
   p0->base.apply  = &p1->base;
   p1->base.apply  = &p2->base;
   p2->base.apply  = &p3->base;
   p1->key  = "cpu_sys";
   p1->klen = strlen("cpu_sys");
   p1->val  = "10";
   p1->vlen = strlen("10");
   p1->val_cmp = val_gt;
   p2->bev = bev;
   p3->bev = bev;
   return pool_plugin_init((struct pool_plugin *) p0);
}

