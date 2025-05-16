#include "include/context_free_router/context_free_router_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "context_free_router_plugin.h"

void ContextFreeRouterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  context_free_router::ContextFreeRouterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
