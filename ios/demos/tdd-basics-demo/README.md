# TDD Basics Demo - iOS (Swift)

## Objectives
- Red-Green-Refactor at scale: beyond the basics
- TDD mindset for mobile development challenges  
- When and when not to use TDD in mobile contexts
- Test-first vs test-after: advanced decision making

## Demo Overview

This demo demonstrates the core principles of Test-Driven Development (TDD) through a practical mobile calculator application. You'll see how the Red-Green-Refactor cycle works in practice and understand the benefits of TDD in mobile development.

## What This Demo Covers

### 1. Red-Green-Refactor Cycle
- **Red**: Write a failing test first
- **Green**: Write minimal code to make the test pass
- **Refactor**: Improve code structure without changing behavior
- **Continuous feedback loop**: Repeat the cycle

### 2. TDD Benefits in Mobile Development
- Early bug detection
- Clearer requirements definition
- Improved design focus
- Better code maintainability
- Confidence in refactoring

### 3. Mobile-Specific TDD Considerations
- Device and OS fragmentation testing
- Network variability handling
- Battery consumption awareness
- Security and privacy validation

## Demo Structure

```
tdd-basics-demo/
├── README.md
├── Package.swift                    # Swift package configuration
├── Sources/
│   ├── Calculator/                  # Calculator implementation
│   └── SpeakingClock/              # Speaking clock with dependencies
│       ├── Clock.swift
│       ├── SpeakingClock.swift
│       ├── SpeechSynthesizer.swift
│       └── TimeToTextConverter.swift
├── Tests/
│   ├── CalculatorTests/            # Calculator TDD examples
│   │   └── CalculatorTests.swift
│   └── SpeakingClockTests/         # Manual mocking examples
│       └── SpeakingClockTests.swift
└── cuckoo-demo/                    # Advanced mocking frameworks (optional)
    └── README.md
```

## Running the Demo

### Option 1: Using Xcode (Recommended)

1. **Open the package in Xcode**:
   ```bash
   open Package.swift
   ```
   Or double-click `Package.swift` in Finder.

2. **Run all tests**:
   - Press `Cmd+U` to run all tests
   - Or click the diamond icons next to test methods to run individually

3. **View test results**:
   - Test Navigator (Cmd+6) shows all tests
   - Results are displayed inline in the editor

### Option 2: Using VS Code with Swift Extension

If you have the Swift extension installed in VS Code, tests will appear in the Test Explorer and can be run directly from the editor.

### What You'll See

- **CalculatorTests.swift** - Demonstrates Red-Green-Refactor cycle
- **SpeakingClockTests.swift** - Shows manual mock implementations for testing with dependencies

## Key Learning Points

### When to Use TDD in Mobile Development
- **IDEAL for**: Business logic, data validation, API interactions
- **CHALLENGING for**: UI animations, platform-specific features
- **AVOID when**: Rapid prototyping, unclear requirements

### TDD vs Traditional Testing
- **Test-First**: Drives design, prevents over-engineering
- **Test-After**: Validates existing functionality, legacy integration

### Scaling TDD
- Modular design for testability
- Mock objects for external dependencies (see `SpeakingClockTests.swift`)
- Dependency injection patterns
- Code coverage analysis

## Manual Mocking Example

The `SpeakingClockTests.swift` file demonstrates how to create manual mocks without external frameworks:

```swift
// Manual mock with call tracking
class ClockMock: Clock {
    var stubbedTime: Date = Date()
    private(set) var getTimeCallCount = 0

    override func getTime() -> Date {
        getTimeCallCount += 1
        return stubbedTime
    }
}
```

**Benefits of manual mocks:**
- No external dependencies
- Full control over behavior
- Easy to understand and debug
- Works with any Swift project

**See `cuckoo-demo/` for examples using advanced mocking frameworks (Cuckoo, Nimble).**

## Next Steps
- Try modifying the calculator to add new operations
- Observe how existing tests protect against regressions
- Practice the Red-Green-Refactor cycle yourself

## Additional Resources
- [Swift Testing Documentation](https://swift.org/getting-started/#using-the-package-manager)
- [iOS Testing Guide](https://developer.apple.com/documentation/xctest)
- [TDD Best Practices for Mobile](https://example.com/mobile-tdd-practices)
