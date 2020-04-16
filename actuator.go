// Package actuator provides methods to actuate MacBook Force Touch trackpad.
package actuator

/*
#cgo CFLAGS: -x objective-c
#cgo LDFLAGS: -framework Foundation
#import <HapticActuator.h>
void actuateDown(int actuationId) {
	[[HapticActuator sharedActuator] actuateTouchDownFeedback: actuationId];
}

void actuateUp(int actuationId) {
	[[HapticActuator sharedActuator] actuateTouchUpFeedback: actuationId];
}
*/
import "C"

// Up actuates the trackpad upwards.
//
// It accepts feedback type as a parameter (one of HapticFeedbackType enum values).
func Up(feedbackType hapticFeedbackType) {
	C.actuateUp(C.int(feedbackType.getActuationID()))
}

// Down actuates the trackpad downwards.
//
// It accepts feedback type as a parameter (one of HapticFeedbackType enum values).
func Down(feedbackType hapticFeedbackType) {
	C.actuateDown(C.int(feedbackType.getActuationID()))
}
