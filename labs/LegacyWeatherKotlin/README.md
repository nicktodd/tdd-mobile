# TDD Legacy Refactoring Exercise - Weather App

## 🎯 **Primary Learning Objective**

Learn to apply **Test-Driven Development techniques** when refactoring legacy code that has:
- ❌ No existing tests
- ❌ Tightly coupled dependencies  
- ❌ Mixed concerns and responsibilities
- ❌ Hard-coded dependencies
- ❌ Impossible to unit test

## 🚨 **This is NOT about Architecture Patterns!**

This exercise focuses on **TDD as a refactoring tool**, not on learning Android architecture. You'll practice specific legacy code techniques that professional developers use daily.

## 📚 **What You'll Learn**

### **TDD Legacy Techniques:**
- **Characterization Testing** - Document existing behavior before changing it
- **Dependency Breaking** - Make untestable code testable
- **Safe Refactoring** - Change code structure while maintaining behavior
- **Working with Constraints** - Refactor within real-world limitations

### **Why This Matters:**
Most professional developers spend 80% of their time working with existing code, not writing new code. Learning to safely refactor legacy code using TDD is a critical career skill.

## 📱 What This App Does

- Displays current weather for various cities
- Shows temperature, humidity, wind speed, and pressure
- Provides weather advice based on conditions
- Supports temperature unit conversion (°C/°F)
- Offers quick city selection and search functionality

## 💀 The Problems (What's Wrong With This Code?)

### 🔥 Critical Anti-Patterns

#### 1. **The God Singleton** (`WeatherSingleton.kt`)
```kotlin
object WeatherSingleton {
    // This singleton does EVERYTHING - classic anti-pattern!
}
```
**Problems:**
- Violates Single Responsibility Principle
- Manages network calls, business logic, UI state, caching, and error handling
- Impossible to unit test properly
- Thread safety issues with global mutable state
- Memory leaks waiting to happen
- Tight coupling throughout the application

#### 2. **Massive Activity Class** (`MainActivity.kt`)
**Problems:**
- 500+ lines of mixed concerns in one file
- UI logic mixed with business logic
- Direct singleton dependencies
- Business logic in UI event handlers
- Complex formatting logic in UI layer
- No separation between presentation and domain logic

#### 3. **Security Nightmares**
```kotlin
private const val API_KEY = "your_api_key_here_exposed_in_code"
```
**Problems:**
- API key hardcoded in source code
- No environment-based configuration  
- Credentials exposed in version control
- Real API key committed to repository

#### 4. **Poor Error Handling**
```kotlin
private fun handleError(message: String) {
    errorMessage.value = message
    logMessage("WeatherSingleton", "ERROR: $message")
}
```
**Problems:**
- Generic error handling without context
- No retry mechanisms
- Poor user experience with error states
- No offline handling

#### 5. **Hard-coded Magic Values Everywhere**
```kotlin
if (cachedData != null && 
    cachedCity == city && 
    now - lastFetchTime < 300000) { // What's 300000?
val DEFAULT_CITIES = listOf("London", "New York", "Tokyo", "Sydney", "Paris")
temp > 305 -> Color(0xFFD32F2F) // What's 305? What temperature unit?
```

### 🤢 Architecture Violations

#### No Dependency Injection
- Direct singleton usage throughout
- Impossible to mock dependencies
- Tight coupling between layers

#### No Proper Data Layer
- Network responses mixed with domain models
- No repository pattern
- No caching strategy
- Direct API calls from singleton

#### No Proper Domain Layer
- Business logic scattered across UI and singleton
- No use cases or interactors
- Temperature conversion logic in multiple places
- Weather advice logic in Activity

#### No Proper Presentation Layer
- No ViewModels or proper state management
- UI logic mixed with business logic
- No proper loading/error states management

### 🧪 Testing Nightmares

#### Impossible to Unit Test
- Singleton dependencies can't be mocked
- Business logic mixed with Android components
- No interfaces or abstractions
- Static dependencies everywhere

#### No Test Coverage
- No existing unit tests
- No integration tests
- No UI tests

### 🔧 Code Quality Issues

#### Naming and Organization
- Methods doing multiple things
- Poor class organization
- Mixed concerns in single files
- No proper package structure

#### Performance Issues
- Network calls on main thread context
- Poor caching implementation
- Memory leaks with context references
- No proper lifecycle management

## 🛠️ **TDD Legacy Code Techniques You'll Practice**

### **1. Characterization Testing** 📸
Document current behavior (bugs included) before changing anything:
```kotlin
@Test
fun `characterize_current_temperature_formatting_exactly`() {
    // Capture EXACT current output - even if it's wrong
    WeatherSingleton.isCelsius.value = true
    val result = WeatherSingleton.getTemperatureString()
    
    // Don't "fix" the behavior yet - just document it
    assertEquals("27°C", result) // Current behavior, right or wrong
}
```

### **2. Dependency Breaking Techniques** ⚡
Make untestable code testable using seams:
```kotlin
// Current problem: Hard to test due to static dependencies
object WeatherSingleton {
    fun fetchWeather(city: String) {
        val response = URL("https://api...").readText() // Can't test!
    }
}

// TDD Solution: Extract and Override pattern
open class WeatherManager {
    open fun makeApiCall(url: String): String = URL(url).readText()
    
    fun fetchWeather(city: String) {
        val response = makeApiCall(buildApiUrl(city))
        processResponse(response)
    }
}

// Now testable through inheritance
class TestableWeatherManager : WeatherManager() {
    override fun makeApiCall(url: String): String = """{"temp":300}"""
}
```

### **3. Safe Refactoring Under Tests** 🔄
Change structure while preserving behavior:
- Write characterization tests first
- Refactor in small steps
- Keep tests green throughout
- Use IDE refactoring tools with confidence

## 🎯 **TDD Exercise Phases**

### **Phase 1: Characterization Testing (45 minutes)** 🔍
**Goal**: Create a safety net of tests that document current behavior

#### **What You'll Do:**
1. **Document Temperature Logic**
   ```kotlin
   @Test
   fun `characterize_temperature_thresholds`() {
       // Test current hardcoded thresholds (305 Kelvin, etc.)
       val hotColor = WeatherSingleton.getTemperatureColor(306.0)
       assertEquals(Color(0xFFFF5722), hotColor)
   }
   ```

2. **Capture Validation Rules**
   ```kotlin
   @Test
   fun `characterize_city_validation_rules`() {
       // Document current validation behavior
       assertTrue(WeatherSingleton.isValidCityName("London"))
       assertFalse(WeatherSingleton.isValidCityName("A"))
   }
   ```

3. **Record String Formatting**
   ```kotlin
   @Test
   fun `characterize_weather_advice_generation`() {
       val weather = WeatherData(temperature = 308.0, humidity = 85)
       val advice = WeatherSingleton.getWeatherAdvice(weather)
       
       // Capture exact current advice (even if poorly written)
       assertTrue(advice.contains("Extremely hot"))
   }
   ```

#### **TDD Rules for Phase 1:**
- ❌ **Don't "fix" anything yet** - just document current behavior
- ✅ **Write tests that pass with current code**
- ✅ **Capture edge cases and weird behavior**
- ✅ **Create your safety net before changing anything**

### **Phase 2: Dependency Breaking (60 minutes)** ⚡
**Goal**: Make the untestable code testable using TDD techniques

#### **Technique 1: Extract and Override**
```kotlin
// Make WeatherSingleton testable by adding override points
object WeatherSingleton {
    // Add extension point for testing
    open fun performNetworkCall(url: String): String {
        return URL(url).readText()
    }
    
    fun fetchWeather(city: String) {
        val response = performNetworkCall(buildUrl(city))
        // ... rest of logic
    }
}
```

#### **Technique 2: Dependency Injection Points**
```kotlin
// Add constructor injection capability
class WeatherManager(
    private val networkProvider: NetworkProvider = RealNetworkProvider()
) {
    fun fetchWeather(city: String): WeatherData {
        val response = networkProvider.makeRequest(buildUrl(city))
        return parseResponse(response)
    }
}
```

#### **What You'll Practice:**
1. **Creating Seams** - Add extension points in legacy code
2. **Interface Extraction** - Abstract external dependencies  
3. **Dependency Injection** - Make dependencies configurable
4. **Test Double Creation** - Build mocks and fakes

### **Phase 3: Refactor Under Test (90 minutes)** �  
**Goal**: Improve code structure while maintaining behavior

#### **TDD Refactoring Process:**
1. **Red**: Write test for desired new structure
2. **Green**: Make minimal change to pass test
3. **Refactor**: Improve implementation
4. **Repeat**: Continue with small steps

#### **Example Refactoring Sequence:**
```kotlin
// Step 1: Extract method (test-first)
@Test
fun `converts_temperature_units_correctly`() {
    val celsius = TemperatureConverter.kelvinToCelsius(300.0)
    assertEquals(26.85, celsius, 0.01)
}

// Step 2: Create the class to make test pass
class TemperatureConverter {
    companion object {
        fun kelvinToCelsius(kelvin: Double): Double = kelvin - 273.15
    }
}

// Step 3: Refactor original code to use new class
```

## 🚫 **Realistic Legacy Constraints**

To simulate real-world legacy refactoring, you have constraints:

### **You CANNOT (initially):**
- ❌ Change public method signatures (other code depends on them)
- ❌ Remove WeatherSingleton completely (too many dependencies)
- ❌ Add new dependencies to MainActivity (would break builds)
- ❌ Change the API contract (external integration)

### **You MUST work incrementally:**
- ✅ Add tests before changing behavior
- ✅ Make small, safe changes
- ✅ Preserve existing functionality
- ✅ Work within existing structure until tests provide safety

### **This teaches you:**
- How to work with real legacy constraints
- Incremental improvement techniques  
- Risk management in refactoring
- Building confidence through testing

## 📊 **Success Metrics - Track Your Progress**

### **Baseline Measurements (Before):**
- [ ] **Lines of code in MainActivity:** ~627 lines
- [ ] **Public methods in WeatherSingleton:** ~15 methods
- [ ] **Hardcoded constants:** ~20+ magic numbers
- [ ] **Testable methods:** 0 (all tightly coupled)
- [ ] **Test coverage:** 0%
- [ ] **Cyclomatic complexity:** High (nested conditionals)

### **After Phase 1 (Characterization):**
- [ ] **Characterization tests written:** ___ tests
- [ ] **Behaviors documented:** ___ scenarios
- [ ] **Edge cases captured:** ___ cases
- [ ] **Safety net confidence:** High/Medium/Low

### **After Phase 2 (Dependency Breaking):**
- [ ] **Seams created:** ___ extension points
- [ ] **Dependencies made injectable:** ___ dependencies  
- [ ] **Test doubles created:** ___ mocks/fakes
- [ ] **Isolated units:** ___ testable classes

### **After Phase 3 (Refactoring):**
- [ ] **Methods extracted:** ___ smaller methods
- [ ] **Classes created:** ___ focused classes
- [ ] **Test coverage achieved:** ___%
- [ ] **Complexity reduced:** High/Medium/Low
- [ ] **Maintainability improved:** ✅

## 🧪 **TDD Legacy Best Practices**

### **1. Characterization Test Strategy**
```kotlin
// Capture behavior first, judge later
@Test 
fun `documents_current_caching_behavior`() {
    // Even if caching is broken, document how it currently works
    WeatherSingleton.fetchWeather("London")
    Thread.sleep(100) // Current code has timing issues
    WeatherSingleton.fetchWeather("London") 
    
    // Verify current behavior (may be buggy)
    assertEquals(1, actualNetworkCallCount) // Document what actually happens
}
```

### **2. Dependency Breaking Patterns**
```kotlin
// Pattern: Subclass and Override Method
class TestableWeatherSingleton : WeatherSingleton() {
    override fun getCurrentTime(): Long = 12345L // Controllable time
    override fun makeNetworkCall(url: String) = mockResponse
}

// Pattern: Extract Interface  
interface TimeProvider {
    fun getCurrentTime(): Long
}

// Pattern: Dependency Injection
class WeatherService(private val timeProvider: TimeProvider = SystemTimeProvider())
```

### **3. Safe Refactoring Rules**
- **One thing at a time:** Change either structure OR behavior, never both
- **Keep tests green:** If tests fail, you changed behavior accidentally  
- **Small steps:** Each refactoring should take < 5 minutes
- **Commit frequently:** Save progress after each green state

## 🚀 Getting Started

### Prerequisites
- Android Studio Arctic Fox or later
- Minimum SDK 24
- Internet connection for weather API

### Setup
1. The app includes a working API key for demonstration purposes
2. **Optional**: Get your own free API key from [OpenWeatherMap](https://openweathermap.org/api)
3. **Optional**: Replace the hardcoded API key in `WeatherSingleton.kt` with your own
4. Build and run the project

### API Information
This app uses the OpenWeatherMap Current Weather API:
- Base URL: `https://api.openweathermap.org/data/2.5/`
- Endpoint: `/weather?q={city}&appid={api_key}`
- Free tier: 1000 calls/day

## 🎓 Learning Outcomes

After completing this exercise, students will understand:

1. **Why separation of concerns matters**
2. **The dangers of singleton anti-patterns**
3. **How to apply TDD to legacy code**
4. **Proper Android architecture patterns**
5. **The importance of dependency injection**
6. **How to write testable code**

## � **Exercise Files Reference**

### **Code Files:**
- `MainActivity.kt` - Massive activity with mixed concerns (627 lines)
- `WeatherSingleton.kt` - God object with seams for testing (259 lines)  
- `Constants.kt` - Poorly organized constants and magic values
- `RefactoringMetrics.kt` - Measurement framework for tracking progress

### **Test Files:**
- `WeatherCharacterizationTests.kt` - Example characterization tests
- `DependencyBreakingExamples.kt` - Examples of using seams for testing

### **Key Features Added for TDD Exercise:**
- **Seams in WeatherSingleton**: `getCurrentTime()`, `logMessage()`, `performNetworkCall()`
- **Measurement Framework**: Baseline metrics and progress tracking
- **Example Tests**: Show students exactly what to write
- **Testing Dependencies**: Mockito, coroutines-test, MockWebServer

## 📚 **TDD Legacy Resources**

### **Essential Reading:**
- ["Working Effectively with Legacy Code"](https://www.goodreads.com/book/show/44919.Working_Effectively_with_Legacy_Code) by Michael Feathers
- ["Refactoring"](https://refactoring.com/) by Martin Fowler  
- [Android Testing Guide](https://developer.android.com/training/testing)

### **TDD Legacy Techniques:**
- **Characterization Testing** - Document existing behavior before changes
- **Seam Identification** - Find extension points in legacy code  
- **Dependency Breaking** - Make untestable code testable
- **Test-Driven Refactoring** - Improve design through testing

### **Android-Specific Resources:**
- [Unit Testing Best Practices](https://developer.android.com/training/testing/unit-testing)
- [Mockito for Android](https://site.mockito.org/)
- [Testing Coroutines](https://kotlinlang.org/docs/coroutines-testing.html)

---

## 🎯 **Final Learning Objectives Check**

After completing this exercise, you should be able to:

- ✅ **Write characterization tests** to document legacy behavior safely
- ✅ **Identify and create seams** in tightly-coupled legacy code
- ✅ **Apply dependency breaking techniques** (Extract & Override, Interface Extraction)  
- ✅ **Refactor incrementally** using Red-Green-Refactor cycle
- ✅ **Work within legacy constraints** while making gradual improvements
- ✅ **Measure and track progress** during refactoring efforts
- ✅ **Build confidence** in changing legacy code through comprehensive testing

## ⚠️ **Final Reminder**

**This is intentionally bad code for educational purposes!** 

Every anti-pattern demonstrated here should be **avoided** in production code. This exercise teaches you to **recognize and fix** these problems using TDD techniques.

**Happy Legacy Refactoring!** 🔧