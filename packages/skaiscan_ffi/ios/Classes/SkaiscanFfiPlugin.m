#import "SkaiscanFfiPlugin.h"
#if __has_include(<skaiscan_ffi/skaiscan_ffi-Swift.h>)
#import <skaiscan_ffi/skaiscan_ffi-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "skaiscan_ffi-Swift.h"
#endif

@implementation SkaiscanFfiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSkaiscanFfiPlugin registerWithRegistrar:registrar];
}
@end
