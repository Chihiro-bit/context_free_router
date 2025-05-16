#ifndef FLUTTER_PLUGIN_CONTEXT_FREE_ROUTER_PLUGIN_H_
#define FLUTTER_PLUGIN_CONTEXT_FREE_ROUTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace context_free_router {

class ContextFreeRouterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ContextFreeRouterPlugin();

  virtual ~ContextFreeRouterPlugin();

  // Disallow copy and assign.
  ContextFreeRouterPlugin(const ContextFreeRouterPlugin&) = delete;
  ContextFreeRouterPlugin& operator=(const ContextFreeRouterPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace context_free_router

#endif  // FLUTTER_PLUGIN_CONTEXT_FREE_ROUTER_PLUGIN_H_
