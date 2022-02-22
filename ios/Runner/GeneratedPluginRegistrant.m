//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<camera/CameraPlugin.h>)
#import <camera/CameraPlugin.h>
#else
@import camera;
#endif

#if __has_include(<flutter_isolate/FlutterIsolatePlugin.h>)
#import <flutter_isolate/FlutterIsolatePlugin.h>
#else
@import flutter_isolate;
#endif

#if __has_include(<fluttertoast/FluttertoastPlugin.h>)
#import <fluttertoast/FluttertoastPlugin.h>
#else
@import fluttertoast;
#endif

#if __has_include(<google_ml_kit/GoogleMlKitPlugin.h>)
#import <google_ml_kit/GoogleMlKitPlugin.h>
#else
@import google_ml_kit;
#endif

#if __has_include(<path_provider_ios/FLTPathProviderPlugin.h>)
#import <path_provider_ios/FLTPathProviderPlugin.h>
#else
@import path_provider_ios;
#endif

#if __has_include(<permission_handler/PermissionHandlerPlugin.h>)
#import <permission_handler/PermissionHandlerPlugin.h>
#else
@import permission_handler;
#endif

#if __has_include(<skaiscan_ffi/SkaiscanFfiPlugin.h>)
#import <skaiscan_ffi/SkaiscanFfiPlugin.h>
#else
@import skaiscan_ffi;
#endif

#if __has_include(<tflite_flutter/TfliteFlutterPlugin.h>)
#import <tflite_flutter/TfliteFlutterPlugin.h>
#else
@import tflite_flutter;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [CameraPlugin registerWithRegistrar:[registry registrarForPlugin:@"CameraPlugin"]];
  [FlutterIsolatePlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterIsolatePlugin"]];
  [FluttertoastPlugin registerWithRegistrar:[registry registrarForPlugin:@"FluttertoastPlugin"]];
  [GoogleMlKitPlugin registerWithRegistrar:[registry registrarForPlugin:@"GoogleMlKitPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [SkaiscanFfiPlugin registerWithRegistrar:[registry registrarForPlugin:@"SkaiscanFfiPlugin"]];
  [TfliteFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"TfliteFlutterPlugin"]];
}

@end
