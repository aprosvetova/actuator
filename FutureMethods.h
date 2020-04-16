#import <Cocoa/Cocoa.h>

typedef CFTypeRef MTActuatorCreateFromDeviceIDFunction(UInt64 deviceID);
typedef IOReturn MTActuatorOpenFunction(CFTypeRef actuatorRef);
typedef IOReturn MTActuatorCloseFunction(CFTypeRef actuatorRef);
typedef IOReturn MTActuatorActuateFunction(CFTypeRef actuatorRef, SInt32 actuationID, UInt32 unknown1, Float32 unknown2, Float32 unknown3);

MTActuatorCreateFromDeviceIDFunction *GetMTActuatorCreateFromDeviceIDFunction(void);
MTActuatorOpenFunction *GetMTActuatorOpenFunction(void);
MTActuatorCloseFunction *GetMTActuatorCloseFunction(void);
MTActuatorActuateFunction *GetMTActuatorActuateFunction(void);