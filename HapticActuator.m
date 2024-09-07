#import "HapticActuator.h"
#import "FutureMethods.h"

#import <IOKit/IOKitLib.h>

@interface HapticActuator ()

@property (nonatomic) UInt64 lastKnownMultitouchDeviceMultitouchID;

@end

@implementation HapticActuator {
    CFTypeRef _actuatorRef;
    MTActuatorCreateFromDeviceIDFunction *_MTActuatorCreateFromDeviceID;
    MTActuatorOpenFunction *_MTActuatorOpen;
    MTActuatorCloseFunction *_MTActuatorClose;
    MTActuatorActuateFunction *_MTActuatorActuate;
}

+ (instancetype)sharedActuator {
    static dispatch_once_t onceToken;
    static HapticActuator *sharedActuator;
    dispatch_once(&onceToken, ^{
        sharedActuator = [[HapticActuator alloc] init];
    });
    return sharedActuator;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _MTActuatorCreateFromDeviceID = GetMTActuatorCreateFromDeviceIDFunction();
        _MTActuatorOpen = GetMTActuatorOpenFunction();
        _MTActuatorClose = GetMTActuatorCloseFunction();
        _MTActuatorActuate = GetMTActuatorActuateFunction();

        if (!_MTActuatorCreateFromDeviceID ||
            !_MTActuatorOpen ||
            !_MTActuatorClose ||
            !_MTActuatorActuate) {
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    [self _htk_main_closeActuator];
    [super dealloc];
}

- (void)actuateTouchDownFeedback:(SInt32)actuationID {
    [self actuateActuationID:actuationID
                    unknown1:0
                    unknown2:0.0
                    unknown3:2.0];
}

- (void)actuateTouchUpFeedback:(SInt32)actuationID {
    [self actuateActuationID:actuationID
                    unknown1:0
                    unknown2:0.0
                    unknown3:0.0];
}

- (BOOL)actuateActuationID:(SInt32)actuationID
                  unknown1:(UInt32)unknown1
                  unknown2:(Float32)unknown2
                  unknown3:(Float32)unknown3 {
    [self _htk_main_openActuator];
    BOOL result = [self _htk_main_actuateActuationID:actuationID unknown1:unknown1 unknown2:unknown2 unknown3:unknown3];

    if (!result) {
        [self _htk_main_closeActuator];
        [self _htk_main_openActuator];
        result = [self _htk_main_actuateActuationID:actuationID unknown1:unknown1 unknown2:unknown2 unknown3:unknown3];
    }

    return result;
}

- (void)_htk_main_openActuator {
    if (_actuatorRef) {
        return;
    }

    if (self.lastKnownMultitouchDeviceMultitouchID) {
        const CFTypeRef actuatorRef = _MTActuatorCreateFromDeviceID(self.lastKnownMultitouchDeviceMultitouchID);
        if (!actuatorRef) {
            return;
        }
        _actuatorRef = actuatorRef;
    } else {
        io_iterator_t itreator = IO_OBJECT_NULL;
        // NOTE: `IOServiceGetMatchingServices` will take ownership of `matchingRef`. Do not release it.
        const CFMutableDictionaryRef matchingRef = IOServiceMatching("AppleMultitouchDevice");
        const kern_return_t result = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingRef, &itreator);
        if (result != KERN_SUCCESS) {
            return;
        }

        io_service_t service = IO_OBJECT_NULL;
        while ((service = IOIteratorNext(itreator)) != IO_OBJECT_NULL) {
            CFMutableDictionaryRef propertiesRef = NULL;
            const kern_return_t result = IORegistryEntryCreateCFProperties(service, &propertiesRef, CFAllocatorGetDefault(), 0);
            if (result != KERN_SUCCESS) {
                IOObjectRetain(service);
                continue;
            }

            NSMutableDictionary * const properties = (__bridge_transfer NSMutableDictionary *)propertiesRef;

            // Use first actuation supported build-in, multitouch device, which should be a track pad.
            NSString * const productProperty = (NSString *)properties[@"Product"];
            NSNumber * const acutuationSupportedProperty = (NSNumber *)properties[@"ActuationSupported"];
            NSNumber * const mtBuildInProperty = (NSNumber *)properties[@"MT Built-In"];
            if (!(acutuationSupportedProperty.boolValue && mtBuildInProperty.boolValue)) {
                IOObjectRetain(service);
                continue;
            }

            NSNumber * const multitouchIDProperty = (NSNumber *)properties[@"Multitouch ID"];
            const UInt64 multitouchDeviceMultitouchID = multitouchIDProperty.longLongValue;
            const CFTypeRef actuatorRef = _MTActuatorCreateFromDeviceID(multitouchDeviceMultitouchID);
            if (!actuatorRef) {
                IOObjectRetain(service);
                continue;
            }
            _actuatorRef = actuatorRef;
            self.lastKnownMultitouchDeviceMultitouchID = multitouchDeviceMultitouchID;

            IOObjectRelease(service);
            break;
        }
        IOObjectRelease(itreator);
        if (!_actuatorRef) {
            return;
        }
    }

    const IOReturn error = _MTActuatorOpen(_actuatorRef);
    if (error != kIOReturnSuccess) {
        CFRelease(_actuatorRef);
        _actuatorRef = NULL;
        return;
    }
}

- (void)_htk_main_closeActuator {
    if (!_actuatorRef) {
        return;
    }

    const IOReturn error = _MTActuatorClose(_actuatorRef);
    if (error != kIOReturnSuccess) {
    }
    CFRelease(_actuatorRef);
    _actuatorRef = NULL;
}

- (BOOL)_htk_main_actuateActuationID:(SInt32)actuationID unknown1:(UInt32)unknown1 unknown2:(Float32)unknown2 unknown3:(Float32)unknown3 {
    if (!_actuatorRef) {
        return NO;
    }

    const IOReturn error = _MTActuatorActuate(_actuatorRef, actuationID, unknown1, unknown2, unknown3);
    if (error != kIOReturnSuccess) {
        return NO;
    } else {
        return YES;
    }
}

@end