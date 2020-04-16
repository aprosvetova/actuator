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

static const UInt64 kKnownAppleMultitouchDeviceMultitouchIDs[] = {
    0x200000001000000,
    0x300000080500000
};

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
        const size_t count = sizeof(kKnownAppleMultitouchDeviceMultitouchIDs) / sizeof(UInt64);
        for (size_t index = 0; index < count; index++) {
            const UInt64 multitouchDeviceMultitouchID = kKnownAppleMultitouchDeviceMultitouchIDs[index];
            const CFTypeRef actuatorRef = _MTActuatorCreateFromDeviceID(multitouchDeviceMultitouchID);
            if (actuatorRef) {
                _actuatorRef = actuatorRef;
                self.lastKnownMultitouchDeviceMultitouchID = multitouchDeviceMultitouchID;
                break;
            }
        }
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