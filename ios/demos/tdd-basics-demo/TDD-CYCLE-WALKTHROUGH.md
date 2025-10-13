# TDD Cycle Demonstration

This document walks through the Red-Green-Refactor cycle step by step, showing how TDD drives better design and implementation.

## Phase 1: RED - Write Failing Tests First

### Initial Test (This would fail initially)
```swift
func testAddition() {
    let result = calculator.add(2.0, 3.0)
    XCTAssertEqual(result, 5.0)
}
```

**Key Points:**
- Test written BEFORE implementation exists
- Focuses on WHAT the code should do, not HOW
- Drives API design through usage

### Why RED Phase is Important:
1. **Design First**: Tests force you to think about the interface
2. **Clear Requirements**: Tests document expected behavior
3. **Prevents Over-engineering**: You only write what's needed

## Phase 2: GREEN - Minimal Code to Pass

### Minimal Implementation
```swift
class Calculator {
    func add(_ a: Double, _ b: Double) -> Double {
        return a + b  // Simplest solution that works
    }
}
```

**Key Points:**
- Write the SIMPLEST code that makes tests pass
- Don't worry about perfect design yet
- Focus on making it work, not making it beautiful

### Why GREEN Phase is Important:
1. **Quick Feedback**: Immediate validation that approach works
2. **Momentum**: Small wins keep development moving
3. **Baseline**: Establishes working foundation

## Phase 3: REFACTOR - Improve Without Breaking

### Enhanced Implementation
```swift
public class Calculator {
    private var lastResult: Double = 0.0
    private var history: [String] = []
    
    public func add(_ a: Double, _ b: Double) -> Double {
        let result = a + b
        recordOperation("\(a) + \(b) = \(result)")
        lastResult = result
        return result
    }
    
    private func recordOperation(_ operation: String) {
        history.append(operation)
        print("CALCULATION: \(operation)")
    }
    
    public func getLastResult() -> Double { return lastResult }
    public func getHistory() -> [String] { return history }
}
```

**Key Points:**
- All tests still pass (behavior preserved)
- Code structure improved (added features)
- Design evolved based on emerging patterns

### Why REFACTOR Phase is Important:
1. **Technical Debt Prevention**: Keep code clean as it grows
2. **Design Evolution**: Allow better patterns to emerge
3. **Confidence**: Tests ensure nothing breaks during changes

## Mobile-Specific TDD Considerations

### Performance Testing
```swift
func testPerformanceRequirement() {
    let startTime = CFAbsoluteTimeGetCurrent()
    for i in 0..<1000 {
        calculator.add(Double(i), Double(i + 1))
    }
    let endTime = CFAbsoluteTimeGetCurrent()
    XCTAssertLessThan((endTime - startTime) * 1000, 100)
}
```

### Memory Efficiency
```swift
func testMemoryEfficiency() {
    for _ in 0..<1000 {
        calculator.add(1.0, 1.0)
    }
    XCTAssertLessThanOrEqual(calculator.getHistory().count, 1000)
}
```

### Error Handling
```swift
func testDivisionByZero() {
    XCTAssertThrowsError(try calculator.divide(10.0, 0.0)) { error in
        XCTAssertTrue(error is CalculatorError)
        if case CalculatorError.divisionByZero(let message) = error {
            XCTAssertTrue(message.contains("ERROR"))
        }
    }
}
```

## Benefits Demonstrated

1. **Early Bug Detection**: Edge cases caught during design
2. **Clear Documentation**: Tests serve as living examples
3. **Refactoring Safety**: Change implementation with confidence
4. **Design Quality**: API emerges from actual usage patterns

## When NOT to Use TDD in Mobile

- **UI Animations**: Complex visual behaviors hard to test
- **Platform Integration**: OS-specific features may need exploration
- **Rapid Prototyping**: When requirements are highly uncertain
- **Performance Optimization**: May need profiling-driven approach

## Next Steps

1. Run the tests and observe the cycle
2. Try adding a new operation (e.g., square root)
3. Practice RED-GREEN-REFACTOR for the new feature
4. Notice how existing tests protect against regressions
