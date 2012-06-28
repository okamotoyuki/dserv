#include <logpool/pool_plugin.h>
#include <stdio.h>

static bool val_gt(void *v0, void *v1, uint16_t l0, uint16_t l1)
{
   return strncmp(v0, v1, 4) == 0;
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
   p1->key  = "task";
   p1->klen = strlen("task");
   p1->val  = "done";
   p1->vlen = strlen("done");
   p1->val_cmp = val_gt;
   p2->bev = bev;
   p3->bev = bev;
   return pool_plugin_init((struct pool_plugin *) p0);
}

