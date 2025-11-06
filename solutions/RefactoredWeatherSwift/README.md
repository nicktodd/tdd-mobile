# 🏆 **Refactored Weather App - Swift Solution**

> **Complete TDD legacy refactoring solution demonstrating all key exercises**

## 📋 **Solution Overview**

This is the **complete refactored solution** for the legacy weather application, demonstrating proper TDD legacy refactoring techniques. Every refactoring corresponds to specific exercises in the original README, showing students the target architecture they should achieve.

## 🗂️ **Key Code Locations**

### **📁 Source Code Implementations**
- **WeatherSingleton.swift** - Main legacy class with progressive refactoring applied
  - Lines 28-36: `TimeProvider` protocol (Exercise 2)
  - Lines 46-56: `WeatherNetworkService` protocol & implementation (Exercise 4)  
  - Lines 93-98: Dual dependency injection constructor (Exercise 2 & 4)
  - Lines 202-212: Async/await network method (Exercise 4)
  - Lines 265-290: Extracted temperature conversion methods (Exercise 3)

### **🧪 Test Code Demonstrations**
- **TimeProviderTests.swift** - Time dependency testing (Exercise 2)
  - Lines 15-22: `MockTimeProvider` with time control
  - Lines 38-43: `TestFriendlyWeatherSingleton` subclass technique
  - Lines 50-70: Deterministic date formatting tests
- **MethodExtractionTests.swift** - Method extraction benefits (Exercise 3)
  - Lines 14-18: Test-friendly subclass avoiding network calls
  - Lines 30-50: URL building tests, Lines 70-90: Temperature conversion tests
  - Lines 120-140: JSON parsing tests
- **NetworkDependencyTests.swift** - Network abstraction testing (Exercise 4)
  - Lines 24-60: `MockNetworkService` with scenario control
  - Lines 100-140: Success path testing with async/await
  - Lines 150-190: Error simulation (timeouts, malformed data, network failures)
  - Lines 220-250: Fast, reliable tests without real HTTP calls

---

## 🔄 **Refactorings Applied**

### **Exercise 2-4: Foundation Refactoring** 🟢

#### ✅ **Time Dependency Seam (Exercise 2)**

**📁 See Implementation:**
- `WeatherSingleton.swift` lines 28-36: TimeProvider protocol & SystemTimeProvider
- `WeatherSingleton.swift` lines 93-98: Dependency injection constructor
- `TimeProviderTests.swift` lines 15-22: MockTimeProvider for testing

```swift
// Before: Untestable time dependency
func getFormattedDate() -> String {
    let formatter = DateFormatter()
    return formatter.string(from: Date()) // ← Always current time
}

// After: Testable time seam
protocol TimeProvider {
    func currentTime() -> Date
}

class SystemTimeProvider: TimeProvider {
    func currentTime() -> Date { Date() }
}

// In production: uses real time
// In tests: controllable mock time
```

#### ✅ **Method Extraction with Test Protection (Exercise 3)**

**📁 See Implementation:**
- `WeatherSingleton.swift` lines 175-195: buildWeatherURL(), performNetworkRequest() 
- `WeatherSingleton.swift` lines 265-290: convertTemperature(), getTemperatureUnit()
- `MethodExtractionTests.swift` lines 30-260: Comprehensive tests for each extracted method

```swift
// Before: Mixed temperature conversion logic
func getTemperatureString() -> String {
    guard let temp = currentWeather?.temperature else { return "N/A" }
    let convertedTemp = isCelsius ? temp : (temp * 9/5) + 32 // ← Extract this
    let unit = isCelsius ? "°C" : "°F"
    return String(format: "%.0f%@", convertedTemp, unit)
}

// After: Extracted and testable
func convertTemperature(from temperature: Double, to unit: TemperatureUnit) -> Double {
    switch unit {
    case .celsius: return temperature
    case .fahrenheit: return (temperature * 9/5) + 32
    }
}
```

#### ✅ **Network Dependency Breaking (Exercise 4)**

**📁 See Implementation:**
- `WeatherSingleton.swift` lines 46-56: WeatherNetworkService protocol & SystemNetworkService  
- `WeatherSingleton.swift` lines 202-212: Async/await performNetworkRequest() method
- `NetworkDependencyTests.swift` lines 24-60: MockNetworkService for testing
- `NetworkDependencyTests.swift` lines 100-290: Comprehensive async network testing

```swift
// Before: Untestable direct URLSession usage
func fetchWeather(for city: String) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        // Complex logic mixed with network call
    }.resume()
}

// After: Injectable network service
protocol WeatherNetworkService {
    func fetchWeatherData(from url: URL) async throws -> Data
}

class SystemNetworkService: WeatherNetworkService {
    func fetchWeatherData(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

// Test implementation with controlled responses
class MockNetworkService: WeatherNetworkService { /* ... */ }
```

---

## 🎓 **Educational Value**

This solution demonstrates **real-world TDD legacy refactoring** that students will encounter in professional iOS development:

- **Realistic Legacy Problems**: God objects, mixed concerns, untestable code
- **Practical TDD Techniques**: Characterization testing, seam creation, safe refactoring
- **Modern iOS Architecture**: Async/await, protocol-oriented programming, dependency injection
- **Comprehensive Testing**: Unit tests, mock objects, async testing patterns

### **🎯 Learning Objectives**
- See **complete refactored solution** with all TDD techniques applied
- Study **dependency injection patterns** in iOS/SwiftUI applications  
- Examine **comprehensive test coverage** with realistic test scenarios
- Understand **async/await testing** patterns for modern iOS development
- Learn **progressive refactoring** strategies from working examples

---

## ✅ **Solution Benefits Achieved**

### **🔧 Testable Architecture**
The refactored solution demonstrates how to transform untestable legacy code into a maintainable, testable architecture:

- **Dependency Injection**: All external dependencies (time, network) are injected and mockable
- **Protocol Abstraction**: Clean interfaces separate concerns and enable testing
- **Method Extraction**: Complex methods broken into focused, testable units
- **Async/Await Testing**: Modern iOS concurrency patterns with proper test coverage

### **🧪 Comprehensive Test Suite**
Every refactoring is backed by comprehensive tests demonstrating:

- **Fast Execution**: No real network calls or time dependencies in tests
- **Reliable Results**: Deterministic behavior with controllable mocks
- **Edge Case Coverage**: Error scenarios, timeouts, malformed data handling
- **Documentation**: Tests serve as living documentation of system behavior

### **🚀 Modern iOS Patterns**
The solution showcases current iOS development best practices:
- All business logic embedded in view code
- Direct singleton dependencies throughout
- Complex animations mixed with data logic
- Hardcoded styling and business rules
- Debug information in production UI

```swift
// More problematic patterns:
struct ContentView: View {
    @StateObject private var weatherManager = WeatherSingleton.shared
    
    // ANTI-PATTERN: Business logic in computed properties
    private var backgroundGradient: LinearGradient {
        let description = weatherManager.currentWeather?.description ?? ""
        
        // Complex business rules in UI layer
        if description.contains("rain") { /* ... */ }
        else if description.contains("cloud") { /* ... */ }
        // ... more business logic in view
    }
    
    var body: some View {
        // 500+ lines of mixed UI and business logic
    }
}
```

### **📊 Technical Debt Metrics (Baseline)**
- `ContentView.swift` - Massive view controller (575 lines)
- `WeatherSingleton.swift` - God object with seams for testing (246 lines)  
- **Total:** 821+ lines of legacy code to refactor
- **Complexity:** High cyclomatic complexity, deep nesting, multiple responsibilities
- **Dependencies:** Hardcoded external dependencies, no dependency injection
- **Test Coverage:** 0% - completely untestable in current state

### **🐛 Known Issues In Production**
- **Protocol-Oriented Design**: Clean interfaces for dependency abstraction
- **Async/Await Concurrency**: Modern iOS networking patterns
- **SwiftUI Integration**: Proper observable object patterns
- **Memory Management**: Avoiding retain cycles and leaks

Students can compare their exercise results against this complete solution to understand the target architecture and see how all the techniques come together in a cohesive, maintainable application.

---

## 🧭 **Quick Navigation Guide**

### **Want to see a specific technique?**

🕒 **Time Dependency Breaking** → `WeatherSingleton.swift` (lines 28-36) + `TimeProviderTests.swift`
🔧 **Method Extraction** → `WeatherSingleton.swift` (lines 265-290) + `MethodExtractionTests.swift`  
🌐 **Network Dependency Breaking** → `WeatherSingleton.swift` (lines 46-56, 202-212) + `NetworkDependencyTests.swift`
🧪 **Characterization Testing** → `WeatherCharacterizationTests.swift` (complete file)

### **Want to understand the testing patterns?**

📝 **Mock Objects** → `TimeProviderTests.swift` lines 15-22 (MockTimeProvider)
🎭 **Test Doubles** → `NetworkDependencyTests.swift` lines 24-60 (MockNetworkService)  
🏗️ **Test Subclasses** → `MethodExtractionTests.swift` lines 14-18 (TestFriendlyWeatherSingleton)
⚡ **Async Testing** → `NetworkDependencyTests.swift` lines 100-140 (async/await patterns)

### **Want to see the progressive refactoring?**

1. **Start Here**: Original `WeatherSingleton.swift` with progressive improvements applied
2. **Exercise 2**: Lines 28-36 (TimeProvider) + `TimeProviderTests.swift`
3. **Exercise 3**: Lines 265-290 (Method Extraction) + `MethodExtractionTests.swift`  
4. **Exercise 4**: Lines 46-56, 202-212 (Network) + `NetworkDependencyTests.swift`

---

## 📁 **Project Structure**

```
LegacyWeatherSwift/
├── LegacyWeatherSwift/
│   ├── WeatherSingleton.swift       # Main refactored singleton with all improvements
│   ├── ContentView.swift            # SwiftUI view (preserved legacy patterns for teaching)
│   ├── Constants.swift              # Configuration and constants
│   └── DependencyBreakingExamples.swift # Additional refactoring examples
├── LegacyWeatherSwiftTests/
│   ├── TimeProviderTests.swift      # Exercise 2: Time dependency testing
│   ├── MethodExtractionTests.swift  # Exercise 3: Method extraction testing  
│   ├── NetworkDependencyTests.swift # Exercise 4: Network abstraction testing
│   └── WeatherCharacterizationTests.swift # Legacy behavior documentation
└── README.md                        # This comprehensive solution guide
```

### **Key Dependencies**
- **Foundation**: Core system frameworks
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **XCTest**: Unit testing framework

---

## 🎓 **Educational Value**

This solution demonstrates **real-world TDD legacy refactoring** that students will encounter in professional iOS development:

### **1. Characterization Testing** 📸
Document current behavior (bugs included) before changing anything:
```swift
func test_temperature_formatting_celsius_exactly_as_current_system() {
    // Capture EXACT current output - even if it's wrong
    weatherManager.isCelsius = true
    weatherManager.currentWeather = WeatherData(
        cityName: "London", temperature: 27.3, 
        description: "clear sky", timestamp: Date()
    )
    
    let result = weatherManager.getTemperatureString()
    
    // Don't "fix" the behavior yet - just document it
    XCTAssertEqual(result, "27°C") // Current behavior, right or wrong
}
```

### **2. Dependency Breaking Techniques** ⚡
Make untestable code testable using seams:
```swift
// Current problem: Hard to test due to static dependencies
class WeatherSingleton {
    func fetchWeather(for city: String) {
        let data = URLSession.shared.dataTask(with: url) { ... } // Can't test!
        let time = Date() // Always current time!
    }
}

// Solution: Create seams (override points for testing)
class WeatherSingleton {
    // Seam: Can be overridden in test subclass
    open func performNetworkRequest(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, error)
        }.resume()
    }
    
    // Seam: Can be overridden to control time in tests
    open func getCurrentTime() -> Date {
        return Date()
    }
    
    func fetchWeather(for city: String) {
        let time = getCurrentTime() // Now testable!
        performNetworkRequest(url: buildURL(city)) { data, error in
            // Now testable through seam override!
        }
    }
}
```

- **Realistic Legacy Problems**: God objects, mixed concerns, untestable code
- **Practical TDD Techniques**: Characterization testing, seam creation, safe refactoring
- **Modern iOS Architecture**: Async/await, protocol-oriented programming, dependency injection
- **Comprehensive Testing**: Unit tests, mock objects, async testing patterns
- **Performance Considerations**: Memory management, caching, async operations

---

**This refactored solution represents the gold standard for TDD legacy refactoring in iOS development.** 🏆

---

## 🏗️ **Progressive TDD Legacy Refactoring Exercises**

> **Each exercise builds on the previous, teaching specific TDD legacy techniques**

---

## 🟢 **EASY Exercises (Foundation Skills)**

### **Exercise 1: Basic Characterization Testing** (20 minutes)
**TDD Skill:** Document existing behavior to create safety net

**🎯 Challenge:** Write characterization tests that lock in current behavior
```swift
// Test what the system ACTUALLY does (not what it should do)
func test_temperature_conversion_current_behavior() {
    let singleton = WeatherSingleton.shared
    singleton.isCelsius = false
    
    // Set a known temperature and capture EXACT output
    singleton.currentWeather = WeatherData(/* ... */)
    let result = singleton.getTemperatureString()
    
    // Document the CURRENT result - even if it seems wrong!
    XCTAssertEqual(result, "??°F") // Fill in actual output
}
```

**✅ Success Criteria:**
- [ ] Test temperature formatting in both Celsius and Fahrenheit
- [ ] Test city cycling behavior (what happens after the last city?)
- [ ] Test error message formatting with different error types
- [ ] Test date formatting with a fixed date (use seam to control time)

**💡 Learning Focus:** Understanding that characterization tests document reality, not requirements

---

### **Exercise 2: Create Your First Seam** (25 minutes)
**TDD Skill:** Break dependency on external system (time)

**🎯 Challenge:** Make the date/time dependency testable
```swift
// Current problem: Date() always returns current time - untestable!
func getFormattedDate() -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: Date()) // <- This is the problem!
}

// Your solution: Create a seam
open func currentTime() -> Date {
    return Date() // Production behavior
}

func getFormattedDate() -> String {
    let formatter = DateFormatter()  
    formatter.dateStyle = .medium
    return formatter.string(from: currentTime()) // <- Now testable!
}
```

**✅ Success Criteria:**
- [ ] Add `currentTime()` seam to WeatherSingleton
- [ ] Update `getFormattedDate()` to use the seam
- [ ] Create testable subclass that overrides `currentTime()`
- [ ] Write test that verifies specific date formatting
- [ ] Ensure characterization tests still pass

**💡 Learning Focus:** Seams allow you to control external dependencies in tests

---

### **Exercise 3: Test-Drive a Simple Extraction** (30 minutes)
**TDD Skill:** Extract method safely with test coverage

**🎯 Challenge:** Extract temperature conversion logic into a separate method
```swift
// Current: Conversion logic mixed in getTemperatureString()
func getTemperatureString() -> String {
    guard let temp = currentWeather?.temperature else { return "N/A" }
    
    // This logic should be extracted
    let convertedTemp = isCelsius ? temp : (temp * 9/5) + 32
    let unit = isCelsius ? "°C" : "°F"
    
    return String(format: "%.0f%@", convertedTemp, unit)
}

// Your goal: Extract to testable method
func convertTemperature(_ celsius: Double, isCelsius: Bool) -> Double {
    return isCelsius ? celsius : (celsius * 9/5) + 32
}
```

**✅ Success Criteria:**
- [ ] Write tests for temperature conversion edge cases (0°, -40°, 100°)
- [ ] Extract conversion logic to separate method using TDD
- [ ] Update original method to use extracted method  
- [ ] Verify all existing tests still pass
- [ ] Test both positive and negative temperatures

**💡 Learning Focus:** Test-first extraction ensures no behavior changes

---

## 🟡 **MEDIUM Exercises (Intermediate Skills)**

### **Exercise 4: Break Network Dependency** (35 minutes)
**TDD Skill:** Create seam for external service calls

**🎯 Challenge:** Make network requests testable without hitting real API

**Current Problem:**
```swift
// Untestable - always hits real network
URLSession.shared.dataTask(with: url) { data, response, error in
    // Complex logic mixed with network call
}.resume()
```

**Your Mission:**
1. Create `performNetworkRequest()` seam
2. Update `fetchWeather()` to use seam  
3. Create testable subclass for tests
4. Write tests for success and failure scenarios

**✅ Success Criteria:**
- [ ] Network seam created and implemented
- [ ] Test successful weather data parsing
- [ ] Test network error handling
- [ ] Test invalid city name handling
- [ ] Test malformed JSON response handling
- [ ] All characterization tests still pass

**💡 Learning Focus:** Complex dependencies need careful seam placement

---

### **Exercise 5: Characterize Cache Behavior** (40 minutes)
**TDD Skill:** Document complex stateful behavior with edge cases

**🎯 Challenge:** The caching logic has subtle bugs - find and document them!

**Investigation Areas:**
```swift
// Questions your tests should answer:
// - How long is cache valid?
// - What happens when switching cities?
// - Does cache work with different temperature units?
// - What about edge cases around cache expiration timing?
```

**Detective Work:**
1. Write tests that explore cache timing boundaries
2. Test cache behavior across city changes
3. Test cache with temperature unit toggles
4. Document any surprising behaviors you find

**✅ Success Criteria:**
- [ ] Test cache hit within valid time (< 5 minutes)
- [ ] Test cache miss after expiration (> 5 minutes) 
- [ ] Test cache invalidation on city change
- [ ] Test cache behavior with temperature unit changes
- [ ] Document at least 2 cache-related bugs/quirks
- [ ] All tests reflect ACTUAL behavior, not desired behavior

**💡 Learning Focus:** Legacy systems often have subtle behavioral quirks worth preserving

---

### **Exercise 6: Extract Service Class** (45 minutes)
**TDD Skill:** Extract cohesive responsibility using dependency injection

**🎯 Challenge:** Extract weather caching into a separate, testable service

**Your Mission:**
```swift
// Create this interface and implementation
protocol WeatherCacheService {
    func getCachedWeather(for city: String) -> WeatherData?
    func cacheWeather(_ data: WeatherData, for city: String)
    func clearCache()
}

class WeatherCache: WeatherCacheService {
    // Move caching logic here
}
```

**Progressive Steps:**
1. Create protocol with tests
2. Implement WeatherCache class with TDD
3. Create seam in WeatherSingleton for cache dependency
4. Replace direct cache usage with injected service
5. Verify all existing behavior preserved

**✅ Success Criteria:**
- [ ] WeatherCacheService protocol defined
- [ ] WeatherCache implementation with full test coverage
- [ ] Cache dependency injected into WeatherSingleton  
- [ ] All caching behavior preserved exactly
- [ ] New cache service is independently testable

**💡 Learning Focus:** Dependency injection enables better testing and modularity

---

## 🔴 **DIFFICULT Exercises (Advanced Skills)**

### **Exercise 7: Untangle the God Object** (60 minutes)
**TDD Skill:** Large-scale refactoring with comprehensive test safety net

**🎯 Challenge:** Break WeatherSingleton into 4 focused classes while preserving ALL behavior

**Target Architecture:**
```swift
protocol WeatherRepository {
    func getWeather(for city: String) async -> Result<WeatherData, Error>
}

class WeatherManager: ObservableObject {
    private let repository: WeatherRepository
    private let formatter: WeatherFormatter
    // UI state only
}

class NetworkWeatherRepository: WeatherRepository {
    // Network + caching logic only  
}

class WeatherFormatter {
    // All formatting/display logic
}
```

**Strategic Approach:**
1. Start with comprehensive characterization tests
2. Extract one responsibility at a time
3. Maintain backward compatibility with facade pattern
4. Move UI state management to separate class
5. Test each extraction thoroughly

**✅ Success Criteria:**
- [ ] WeatherFormatter extracted with full test coverage
- [ ] WeatherRepository abstraction created  
- [ ] NetworkWeatherRepository implements complex caching logic
- [ ] WeatherManager handles only UI state
- [ ] Original singleton becomes facade (delegates to new classes)
- [ ] ALL characterization tests pass unchanged
- [ ] New architecture is significantly more testable

**💡 Learning Focus:** Large refactoring requires incremental steps with test protection

---

### **Exercise 8: SwiftUI View Refactoring** (50 minutes)
**TDD Skill:** Extract business logic from UI layer

**🎯 Challenge:** Remove ALL business logic from ContentView

**Current Problems:**
- 575 lines of mixed UI and business logic
- Complex computed properties with business rules
- Direct singleton dependencies
- Business logic in view lifecycle methods

**Your Mission:**
1. Create WeatherViewModel to handle UI logic
2. Extract computed properties to view model
3. Remove direct singleton dependencies
4. Create proper separation of concerns

**Progressive Extraction:**
```swift
class WeatherViewModel: ObservableObject {
    @Published var backgroundGradient: LinearGradient
    @Published var weatherIconName: String
    
    private let weatherManager: WeatherManager
    
    // Move ALL business logic here
    func updateBackground(for description: String) { }
    func selectWeatherIcon(for description: String) -> String { }
}
```

**✅ Success Criteria:**
- [ ] WeatherViewModel extracts all computed business logic
- [ ] ContentView becomes pure UI layout (< 200 lines)
- [ ] No direct singleton dependencies in views
- [ ] All business logic has unit test coverage
- [ ] UI behavior unchanged (visual regression testing)

**💡 Learning Focus:** UI and business logic separation enables better testing

---

### **Exercise 9: Performance & Memory Optimization** (45 minutes)
**TDD Skill:** Test-drive performance improvements

**🎯 Challenge:** Identify and fix performance/memory issues using TDD

**Investigation Areas:**
- Memory leaks from singleton references
- Unnecessary network requests
- DateFormatter creation in loops
- Cache memory usage growth

**Your Detective Work:**
1. Write performance characterization tests
2. Identify bottlenecks and memory issues  
3. Fix issues while maintaining behavior
4. Add performance regression tests

**Test-Driven Performance Fixes:**
```swift
func test_date_formatter_reuse_performance() {
    let startTime = CFAbsoluteTimeGetCurrent()
    
    // Test that formatters are reused, not recreated
    for _ in 0..<1000 {
        _ = weatherManager.getFormattedDate()
    }
    
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    XCTAssertLessThan(timeElapsed, 0.1) // Should be fast with reuse
}
```

**✅ Success Criteria:**
- [ ] Memory leak tests for singleton lifecycle
- [ ] Performance tests for formatter reuse
- [ ] Cache size limit tests  
- [ ] Network request deduplication tests
- [ ] All performance issues resolved with test coverage
- [ ] No behavioral regressions introduced

**💡 Learning Focus:** Performance improvements need test protection too

---

## 📈 **Progress Tracking & Reflection**

### **Completion Checklist**
Track your progress through the learning journey:

**Foundation Skills (Easy)** 
- [ ] Exercise 1: Basic Characterization Testing
- [ ] Exercise 2: Create Your First Seam  
- [ ] Exercise 3: Test-Drive Simple Extraction

**Intermediate Skills (Medium)**
- [ ] Exercise 4: Break Network Dependency
- [ ] Exercise 5: Characterize Cache Behavior
- [ ] Exercise 6: Extract Service Class

**Advanced Skills (Difficult)**  
- [ ] Exercise 7: Untangle the God Object
- [ ] Exercise 8: SwiftUI View Refactoring
- [ ] Exercise 9: Performance & Memory Optimization

### **Reflection Questions**
After each exercise, consider:
1. **What made this refactoring safe?** (Answer: Comprehensive tests)
2. **What would happen without characterization tests?** (Answer: High risk of breaking behavior)
3. **How did seams help with testing?** (Answer: Enabled dependency control)
4. **What's the difference between characterization and unit tests?** (Answer: Document current vs. specify desired behavior)

### **Final Assessment**
By completion, you should have:
- **90%+ test coverage** on extracted components
- **Zero behavioral regressions** (all characterization tests green)  
- **Modular architecture** with clear separation of concerns
- **Testable components** that can be developed with TDD going forward
- **Deep understanding** of legacy code improvement techniques

---

## � **Legacy Code Smell Detection Guide**

### **Before You Start: Identify the Problems**

Use this checklist to spot anti-patterns in the legacy code:

#### **🚩 Singleton Smells**
- [ ] Static `shared` instances everywhere
- [ ] Multiple responsibilities in one class (300+ lines)
- [ ] Direct access to global state from UI
- [ ] Impossible to unit test in isolation

#### **🚩 Dependency Smells**  
- [ ] Hardcoded `URLSession.shared` calls
- [ ] Direct `Date()` usage (time dependencies)
- [ ] `print()` statements instead of proper logging
- [ ] File system access without abstraction

#### **🚩 SwiftUI/iOS Specific Smells**
- [ ] Business logic in computed properties
- [ ] @Published properties mixed with data access
- [ ] View lifecycle methods doing non-UI work
- [ ] ObservableObject with too many concerns

#### **🚩 Testing Smells**
- [ ] Zero unit tests (0% coverage)
- [ ] "Cannot test this because..." statements
- [ ] Tests that require network connectivity
- [ ] Tests that depend on current date/time

#### **🚩 Architecture Smells**
- [ ] God objects (classes doing everything)
- [ ] Anemic models (structs with no behavior)
- [ ] Missing error boundaries
- [ ] No separation between UI and business logic

### **🎯 Smell-Driven Exercise Selection**

**Found Singleton Smells?** → Start with Exercises 1-3 (Characterization + Seams)
**Found Dependency Smells?** → Focus on Exercises 4-6 (Dependency Breaking)
**Found Architecture Smells?** → Tackle Exercises 7-9 (Strategic Refactoring)

---

## �🚀 **Getting Started**

### **Prerequisites**
- Xcode 15.0 or later
- iOS 17.0 deployment target  
- Basic familiarity with SwiftUI and Combine
- Understanding of iOS unit testing with XCTest

### **Setup Instructions**
1. Open `LegacyWeatherSwift.xcodeproj` in Xcode
2. **Important**: Add the Swift files to the project target if they're not already included:
   - Right-click on the `LegacyWeatherSwift` folder in Xcode
   - Select "Add Files to 'LegacyWeatherSwift'"
   - Add `WeatherSingleton.swift`, `Constants.swift`, and `DependencyBreakingExamples.swift`
   - Ensure they're added to the `LegacyWeatherSwift` target
3. Build the project to ensure it compiles successfully
4. Run the app in the simulator to see the current behavior
5. **Optional**: Replace the hardcoded API key in `WeatherSingleton.swift` with your own OpenWeatherMap API key (the provided key works for learning purposes)
6. Run the existing tests to see the current test coverage (should be minimal)

**Troubleshooting:**
- If you see "Cannot find 'WeatherSingleton' in scope" errors, ensure all Swift files are added to the project target
- If preview errors occur, the app should still build and run normally

### **🎯 Success Criteria**

By the end of this exercise, you should have:
- **Comprehensive characterization tests** covering all major behaviors
- **Testable seams** for all external dependencies  
- **Focused unit tests** for individual components
- **At least one major refactoring** (e.g., extracted WeatherNetworkService)
- **No behavior changes** - all characterization tests still pass
- **Improved test coverage** from 0% to 60%+

---

## 📁 **Project Structure**

```
LegacyWeatherSwift/
├── LegacyWeatherSwift/
│   ├── LegacyWeatherSwiftApp.swift     # App entry point
│   ├── ContentView.swift               # Massive view controller (575 lines)
│   ├── WeatherSingleton.swift          # God object singleton (246 lines)
│   └── DependencyBreakingExamples.swift # Refactoring examples and patterns
├── LegacyWeatherSwiftTests/
│   ├── WeatherCharacterizationTests.swift # Example characterization tests
│   └── LegacyWeatherSwiftTests.swift      # Basic test setup
└── LegacyWeatherSwiftUITests/             # UI test placeholder
```

---

## 🎓 **Learning Resources**

### **Key TDD Legacy Techniques**
1. **Characterization Testing** - Document current behavior before changing anything
2. **Seam Identification** - Find points where you can break dependencies  
3. **Subclass and Override Method** - Classic dependency breaking technique
4. **Extract and Override Call** - Pull out dependencies into overridable methods
5. **Introduce Static Setter** - Quick way to make global state testable
6. **Parameterize Constructor** - Make dependencies explicit through constructor injection

### **Refactoring Safety Rules**
- ✅ **Never change behavior without tests protecting you**
- ✅ **Make one small change at a time** 
- ✅ **Run tests after every change**
- ✅ **Keep characterization tests passing throughout**
- ✅ **Add new tests before making changes**

### **iOS-Specific Considerations**
- **SwiftUI State Management** - `@Published` properties and view updates
- **Async/Await Integration** - Modern concurrency with legacy callback patterns
- **Protocol-Oriented Programming** - Swift's approach to dependency injection
- **Value Types vs Reference Types** - Proper model design for testability

---

## 🔧 **Exercise-Specific Troubleshooting**

### **Exercise 1-3 (Easy) Common Issues** 🟢

**❌ "My characterization test keeps failing"**
- ✅ **Solution:** You're probably testing desired behavior instead of actual behavior
- ✅ **Debug:** Run the code manually and capture the EXACT output
- ✅ **Remember:** Document reality, not requirements

**❌ "I can't make the date testable"**  
- ✅ **Solution:** Look for `Date()` calls - these need seams
- ✅ **Pattern:** Extract to `currentTime()` method you can override
- ✅ **Test:** Use fixed date in test subclass

### **Exercise 4-6 (Medium) Common Issues** 🟡

**❌ "Network tests are flaky/slow"**
- ✅ **Solution:** You're hitting real network - create proper seam
- ✅ **Pattern:** `performNetworkRequest()` seam with mock data in tests
- ✅ **Verify:** Tests should run in milliseconds, not seconds

**❌ "Cache tests are inconsistent"**
- ✅ **Solution:** Time dependency not controlled in tests
- ✅ **Pattern:** Use time seam to control cache expiration
- ✅ **Debug:** Cache behavior depends on timing - make it deterministic

**❌ "Extracted service breaks existing behavior"**
- ✅ **Solution:** Characterization tests should catch this
- ✅ **Check:** Are you running ALL tests after each change?
- ✅ **Pattern:** Extract-preserve-test-cleanup cycle

### **Exercise 7-9 (Hard) Common Issues** 🔴

**❌ "God object refactoring breaks everything"**
- ✅ **Solution:** Too big steps - go smaller and incremental
- ✅ **Pattern:** Extract one responsibility at a time
- ✅ **Safety:** Keep facade to preserve existing interfaces

**❌ "SwiftUI view model isn't updating UI"**
- ✅ **Solution:** Missing @Published or ObservableObject conformance
- ✅ **Check:** @StateObject in view connected to @Published in view model
- ✅ **Debug:** Use SwiftUI inspector to verify state binding

**❌ "Performance tests are unreliable"**
- ✅ **Solution:** CI/local performance differences
- ✅ **Pattern:** Test relative performance, not absolute times
- ✅ **Focus:** Test algorithmic improvements, not hardware speed

### **General TDD Legacy Troubleshooting** 

**❌ "I don't know where to start"**
- ✅ **Start with:** Exercise 1 - just document current behavior
- ✅ **Don't:** Try to fix everything at once
- ✅ **Remember:** Characterization first, improvement second

**❌ "Tests are too complex/coupled"**
- ✅ **Solution:** You need more seams - look for external dependencies
- ✅ **Pattern:** Each test should control one variable, use seams for others
- ✅ **Refactor:** Test code needs refactoring too

**❌ "Refactoring is taking forever"**
- ✅ **Solution:** Smaller steps with test validation at each step
- ✅ **Pattern:** Red-Green-Refactor cycle, even for legacy code
- ✅ **Check:** Are you changing behavior AND structure at same time? (Don't!)

---

## 🎓 **Exercise Learning Outcomes**

### **What Each Exercise Teaches You**

**🟢 Easy Exercises (Foundation)**
- **Exercise 1:** How to document legacy behavior without judgment
- **Exercise 2:** Basic seam creation for controllable dependencies  
- **Exercise 3:** Safe extraction with comprehensive test coverage

**🟡 Medium Exercises (Building Skills)**
- **Exercise 4:** Complex dependency breaking for external services
- **Exercise 5:** Deep behavioral analysis of stateful systems
- **Exercise 6:** Service extraction with dependency injection

**🔴 Hard Exercises (Mastery)**  
- **Exercise 7:** Large-scale architecture refactoring
- **Exercise 8:** UI/business logic separation
- **Exercise 9:** Performance optimization with test protection

### **Key TDD Legacy Patterns You'll Master**

1. **Characterization Testing** - Document first, improve second
2. **Seam Creation** - Break dependencies for testability
3. **Subclass and Override** - Classic legacy testing technique
4. **Extract and Override Call** - Method-level dependency breaking
5. **Introduce Static Setter** - Quick global state testing fixes
6. **Test-Drive Extraction** - Safe refactoring with test protection
7. **Facade Pattern** - Maintain compatibility during refactoring
8. **Dependency Injection** - Make dependencies explicit and replaceable

---

## 🏁 **Next Steps**

After completing this exercise:
1. **Apply techniques to your own legacy code** - Use these patterns on real projects
2. **Explore advanced iOS testing** - Learn about UI testing, integration testing
3. **Study design patterns** - Repository, MVVM, Clean Architecture for iOS
4. **Practice incremental refactoring** - Make small, safe improvements over time

---

**Remember:** The goal is not to rewrite everything, but to make legacy code gradually better through safe, test-driven improvements. Real-world legacy systems require patience and incremental progress! 🚀