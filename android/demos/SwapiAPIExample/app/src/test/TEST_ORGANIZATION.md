# Test Organization Guide

## Why Two Test Folders?

This project demonstrates proper test organization following Android best practices and the testing pyramid principle.

### 📁 `test/` - Unit Tests (JVM)
**Location:** `app/src/test/java/`

**Purpose:** Fast, isolated unit tests that run on the JVM without requiring an Android device.

**What goes here:**
- ViewModel tests (CharacterViewModelTest.kt)
- Repository tests (CharacterRepositoryErrorHandlingTest.kt)
- Business logic tests
- Data transformation tests
- Any code that doesn't require Android framework components

**Characteristics:**
- ✅ Very fast (milliseconds)
- ✅ Can run on CI/CD without emulators
- ✅ Easy to debug
- ✅ Should be the MAJORITY of your tests (80-90%)

**Dependencies:**
- JUnit
- MockK for mocking
- Coroutines Test for async testing

---

### 📁 `androidTest/` - Instrumented Tests (Android Runtime)
**Location:** `app/src/androidTest/java/`

**Purpose:** Tests that require the Android framework or need to run on a device/emulator.

**What goes here:**
- Compose UI tests (CharacterScreenTest.kt)
- Activity/Fragment tests
- Integration tests involving Android components
- Tests requiring Context, Resources, etc.

**Characteristics:**
- ⚠️ Slower (seconds to minutes)
- ⚠️ Requires Android device or emulator
- ⚠️ More complex setup
- ⚠️ Should be MINIMAL (10-20% of tests)

**Dependencies:**
- AndroidJUnit4 runner
- Compose UI Test
- Espresso (for View-based UI)

---

## The Testing Pyramid

```
        /\
       /UI\         ← Few (slow, brittle)
      /----\
     /Integ-\       ← Some (medium speed)
    /--------\
   /   Unit   \     ← Many (fast, reliable)
  /____________\
```

**This project follows the pyramid:**
- **Many unit tests** in `test/` - Fast feedback on business logic
- **Few UI tests** in `androidTest/` - Verify critical user flows

---

## Alternative: Robolectric

### What is Robolectric?

**Robolectric** is a framework that simulates the Android framework on the JVM, allowing you to run Android tests in `test/` (unit tests) instead of `androidTest/` (instrumented tests).

### How It Works:

```
Without Robolectric:
test/        → Pure JUnit (no Android APIs)
androidTest/ → Android Runtime (slow, needs device)

With Robolectric:
test/        → JUnit + Android APIs (simulated, faster)
androidTest/ → Android Runtime (still slow, for integration tests)
```

### Benefits:
- ✅ **Faster than instrumented tests** - No emulator startup (seconds vs minutes)
- ✅ **No device needed** - Runs on CI/CD without emulators
- ✅ **Test Android components as unit tests** - Activities, Fragments, Views, Context, etc.
- ✅ **Good for legacy code** - When you have Android dependencies in your ViewModels

### Drawbacks:
- ⚠️ **Not 100% accurate** - Simulates Android, doesn't use real framework
- ⚠️ **Configuration complexity** - Requires additional setup
- ⚠️ **Compose support is limited** - Better for traditional View system
- ⚠️ **Can hide real device issues** - Behavior may differ on actual devices

### Why This Project Doesn't Use Robolectric:

1. **Clean architecture** - ViewModels and Repositories have no Android dependencies (easy to test without Robolectric)
2. **Compose UI testing** - Robolectric's Compose support is less mature than instrumented testing
3. **Teaching clarity** - Clearer distinction between pure unit tests and UI tests
4. **Already configured** - Project has instrumented test infrastructure

### When You SHOULD Consider Robolectric:

- **Legacy code** with Android dependencies mixed into business logic
- **Traditional View system** (XML layouts, Activities, Fragments)
- **Testing utility classes** that use Context, Resources, etc.
- **Large test suites** where instrumented test time is a problem

### Example Robolectric Test:

```kotlin
// This would normally require androidTest/, but works in test/ with Robolectric
@RunWith(RobolectricTestRunner::class)
class MyActivityTest {
    @Test
    fun buttonClick_updatesText() {
        val activity = Robolectric.setupActivity(MainActivity::class.java)
        val button = activity.findViewById<Button>(R.id.button)
        val textView = activity.findViewById<TextView>(R.id.textView)
        
        button.performClick()
        
        assertEquals("Clicked!", textView.text)
    }
}
```

### Our Approach vs Robolectric:

| Aspect | This Project (MVVM) | With Robolectric |
|--------|---------------------|------------------|
| ViewModel tests | ✅ Pure JUnit (fast) | ✅ Pure JUnit (fast) |
| Repository tests | ✅ Pure JUnit (fast) | ✅ Pure JUnit (fast) |
| View tests | ⚠️ Instrumented (slow) | ✅ Robolectric (faster) |
| Setup complexity | Low | Medium |
| Test accuracy | High (real Android) | Medium (simulated) |

**Recommendation:** Start with the approach in this project (pure unit tests + minimal instrumented UI tests). Add Robolectric later if instrumented test times become a problem.

---

## Why View Tests Are Limited

### MVVM Separation of Concerns

```
View (Compose)              ← Minimal logic, minimal tests
    ↓ (state)
ViewModel                   ← Most logic, most tests
    ↓ (data)
Repository                  ← Data logic, good test coverage
    ↓
Network/Database            ← Mocked in tests
```

### What Gets Tested Where:

| What to Test | Where | Example |
|--------------|-------|---------|
| State management | ViewModel (unit test) | `CharacterViewModelTest` |
| Error handling | ViewModel (unit test) | `CharacterViewModelTest` |
| Network calls | Repository (unit test) | `CharacterRepositoryTest` |
| Data parsing | Repository (unit test) | `CharacterRepositoryTest` |
| **UI displays correctly** | **View (instrumented test)** | **`CharacterScreenTest`** |

### Why CharacterScreenTest is Limited:

1. **No business logic in the view** - All logic is in ViewModel
2. **Only verifies rendering** - "Does the UI show the right elements?"
3. **State comes from ViewModel** - ViewModel tests already verify state transitions
4. **Limited value** - Most bugs are in business logic, not rendering

---

## TDD Best Practices

### When writing a new feature:

1. **Start with Repository tests** (if needed)
   - Test data fetching/parsing
   - Test error cases
   
2. **Then ViewModel tests** (most important)
   - Test state transitions
   - Test user interactions
   - Test error handling
   
3. **Finally, minimal View tests** (if needed)
   - Just verify critical UI elements render
   - Don't test what's already tested in ViewModel

### Rule of Thumb:
- If it has logic → Unit test it
- If it's just displaying data → Maybe skip the test
- If it's a critical user flow → Add a UI test

---

## Running Tests

```bash
# Run unit tests (fast) - Do this constantly during development
./gradlew test

# Run instrumented tests (slow) - Do this before committing
./gradlew connectedAndroidTest

# Run a specific test class
./gradlew test --tests CharacterViewModelTest
```

---

## Summary for Training

**Key Takeaway:** Views have very limited unit tests because:
1. MVVM pushes logic into ViewModel (where it's easy to test)
2. Views just display data (hard to break, easy to verify manually)
3. UI tests are slow and expensive to maintain
4. The testing pyramid prioritizes fast unit tests over slow UI tests

**This is by design!** Good architecture makes most code easy to test without UI testing frameworks.

