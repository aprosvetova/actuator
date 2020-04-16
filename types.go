package actuator

type hapticFeedbackType int

// HapticFeedbackType is an enumerable of available haptic strength values.
const (
	HapticFeedbackTypeWeak hapticFeedbackType = iota
	HapticFeedbackTypeMedium
	HapticFeedbackTypeStrong
)

func (t hapticFeedbackType) getActuationID() int {
	switch t {
	case HapticFeedbackTypeWeak:
		return 3
	case HapticFeedbackTypeMedium:
		return 4
	case HapticFeedbackTypeStrong:
		return 6
	default:
		return 0
	}
}
