#import "FutureMethods.h"

static NSString *const kMultitouchSupportFramework =  @"/System/Library/PrivateFrameworks/MultitouchSupport.framework";

static void *GetFunctionByName(NSString *library, char *func) {
    CFBundleRef bundle;
    CFURLRef bundleURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef) library, kCFURLPOSIXPathStyle, true);
    CFStringRef functionName = CFStringCreateWithCString(kCFAllocatorDefault, func, kCFStringEncodingASCII);
    bundle = CFBundleCreate(kCFAllocatorDefault, bundleURL);
    void *f = NULL;
    if (bundle) {
        f = CFBundleGetFunctionPointerForName(bundle, functionName);
        CFRelease(bundle);
    }
    CFRelease(functionName);
    CFRelease(bundleURL);
    return f;
}

MTActuatorCreateFromDeviceIDFunction *GetMTActuatorCreateFromDeviceIDFunction(void) {
    static dispatch_once_t onceToken;
    static MTActuatorCreateFromDeviceIDFunction *function;
    dispatch_once(&onceToken, ^{
        function = GetFunctionByName(kMultitouchSupportFramework,
                                     "MTActuatorCreateFromDeviceID");
    });
    return function;
}

MTActuatorOpenFunction *GetMTActuatorOpenFunction(void) {
    static dispatch_once_t onceToken;
    static MTActuatorOpenFunction *function;
    dispatch_once(&onceToken, ^{
        function = GetFunctionByName(kMultitouchSupportFramework,
                                     "MTActuatorOpen");
    });
    return function;
}

MTActuatorCloseFunction *GetMTActuatorCloseFunction(void) {
    static dispatch_once_t onceToken;
    static MTActuatorCloseFunction *function;
    dispatch_once(&onceToken, ^{
        function = GetFunctionByName(kMultitouchSupportFramework,
                                     "MTActuatorClose");
    });
    return function;
}

MTActuatorActuateFunction *GetMTActuatorActuateFunction(void) {
    static dispatch_once_t onceToken;
    static MTActuatorActuateFunction *function;
    dispatch_once(&onceToken, ^{
        function = GetFunctionByName(kMultitouchSupportFramework,
                                     "MTActuatorActuate");
    });
    return function;
}