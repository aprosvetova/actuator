#import <Foundation/Foundation.h>

@interface HapticActuator : NSObject

+ (instancetype)sharedActuator;

- (void)actuateTouchDownFeedback:(SInt32)actuationID;
- (void)actuateTouchUpFeedback:(SInt32)actuationID;

@end