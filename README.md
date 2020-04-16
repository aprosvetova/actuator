# Actuate your Force Touch trackpad

[![go.dev reference](https://img.shields.io/badge/go.dev-reference-007d9c?logo=go&logoColor=white&style=flat-square)](https://pkg.go.dev/github.com/aprosvetova/actuator)

**Warning! The code relies on private macOS APIs, so no guarantees.**

## Example

```go
package main

import (
    "github.com/aprosvetova/actuator"
    "time"
)

func main() {
    for {
        actuator.Down(actuator.HapticFeedbackTypeStrong)
        time.Sleep(20 * time.Millisecond)
        actuator.Up(actuator.HapticFeedbackTypeStrong)
        time.Sleep(100 * time.Millisecond)
    }
}
```