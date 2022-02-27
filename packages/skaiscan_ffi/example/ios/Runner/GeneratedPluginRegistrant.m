//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<path_provider_ios/FLTPathProviderPlugin.h>)
#import <path_provider_ios/FLTPathProviderPlugin.h>
#else
@import path_provider_ios;
#endif

#if __has_include(<skaiscan_ffi/SkaiscanFfiPlugin.h>)
#import <skaiscan_ffi/SkaiscanFfiPlugin.h>
#else
@import skaiscan_ffi;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [SkaiscanFfiPlugin registerWithRegistrar:[registry registrarForPlugin:@"SkaiscanFfiPlugin"]];
}

@end
