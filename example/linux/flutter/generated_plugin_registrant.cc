//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <context_free_router/context_free_router_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) context_free_router_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ContextFreeRouterPlugin");
  context_free_router_plugin_register_with_registrar(context_free_router_registrar);
}
