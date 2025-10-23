# MVVM Design Pattern Demo with Unit Testing

This Android project demonstrates the **Model-View-ViewModel (MVVM)** architectural pattern with a focus on writing **genuine unit tests** using **Kotest** and **MockK**.

## 📚 Project Structure

```
com.example.mvvmexample/
├── data/                           # MODEL Layer
│   ├── User.kt                     # Domain model (data class)
│   ├── UserRepository.kt           # Repository interface (abstraction)
│   └── InMemoryUserRepository.kt   # Concrete implementation
│
├── ui/                             # VIEW & VIEWMODEL Layers
│   ├── UserViewModel.kt            # Business logic & state management
│   └── UserListScreen.kt           # Compose UI (View)
│
└── MainActivity.kt                 # App entry point & DI setup

test/
└── ui/
    └── UserViewModelTest.kt        # Pure unit tests with Kotest & MockK
```

## 🎯 What This Demo Shows

### 1. **MVVM Architecture Principles**
- **Separation of Concerns**: Each layer has a single responsibility
- **Dependency Inversion**: ViewModel depends on repository interface, not implementation
- **Unidirectional Data Flow**: User Input → View → ViewModel → Repository → ViewModel → View
- **Reactive UI**: StateFlow updates automatically trigger UI recomposition

### 2. **Testability by Design**
- **Constructor Injection**: Dependencies passed in, easy to mock
- **Interface-based Design**: Repository interface allows mocking
- **No Android Dependencies in ViewModel**: Pure Kotlin, testable in JVM
- **Clear Business Logic**: ID generation, state management - all testable

### 3. **Genuine Unit Tests (Not Integration Tests)**
- **Mock Dependencies**: Use MockK to mock UserRepository
- **Test in Isolation**: ViewModel tests don't depend on repository implementation
- **Fast Execution**: No database, no network, no Android framework
- **Deterministic**: TestDispatchers make coroutines predictable

## 🛠️ Technologies Used

| Technology | Purpose |
|------------|---------|
| **Kotlin** | Primary language |
| **Jetpack Compose** | Modern declarative UI |
| **ViewModel** | Lifecycle-aware business logic container |
| **StateFlow** | Reactive state management |
| **Coroutines** | Asynchronous operations |
| **Kotest** | BDD-style testing framework |
| **MockK** | Kotlin-first mocking library |
| **kotlinx-coroutines-test** | Testing coroutines deterministically |

## 🧪 Unit Testing Strategy

### What We Test
✅ **ViewModel Business Logic**
- ID generation algorithm
- State updates after operations
- Correct repository method calls
- Edge cases (empty lists, non-existent users)

### What We DON'T Test
❌ Repository implementation (has its own tests)
❌ UI rendering (that's UI testing)
❌ Android framework behavior
❌ Database/Network (that's integration testing)

### Key Testing Concepts Demonstrated

#### 1. **Mocking with MockK**
```kotlin
val mockRepository = mockk<UserRepository>()
coEvery { mockRepository.getUsers() } returns listOf(...)
```
- Controls what dependencies return
- Isolates ViewModel from repository implementation

#### 2. **Verifying Interactions**
```kotlin
coVerify { mockRepository.addUser(match { it.id == 1L }) }
```
- Ensures ViewModel calls repository correctly
- Verifies business logic without testing implementation

#### 3. **Testing Coroutines**
```kotlin
val testDispatcher = StandardTestDispatcher()
runTest(testDispatcher) {
    advanceUntilIdle()  // Execute all pending coroutines
}
```
- Makes async code testable synchronously
- Deterministic execution for reliable tests

#### 4. **BDD-Style with Kotest**
```kotlin
describe("UserViewModel initialization") {
    it("should load users from repository on creation") {
        // Arrange, Act, Assert
    }
}
```
- Readable test structure
- Hierarchical organization

## 🏗️ MVVM Layers Explained

### MODEL Layer (`data/`)
**Responsibility**: Data operations and business entities
- `User`: Immutable domain model
- `UserRepository`: Interface defining data operations
- `InMemoryUserRepository`: Concrete implementation

**Key Principle**: Repository pattern abstracts data source from ViewModel

### VIEWMODEL Layer (`ui/UserViewModel.kt`)
**Responsibility**: Business logic, state management, coordination
- Exposes `StateFlow<List<User>>` for UI to observe
- Handles user actions (`addUser`, `deleteUser`)
- Contains business logic (ID generation)
- Coordinates repository operations
- Uses `viewModelScope` for lifecycle-aware coroutines

**Why Testable**:
- No Android dependencies
- Constructor injection
- Pure business logic
- Exposed state is observable

### VIEW Layer (`ui/UserListScreen.kt`)
**Responsibility**: Display data and capture user input
- Observes ViewModel's StateFlow
- Renders UI based on state
- Delegates actions to ViewModel
- No business logic

**Key Principle**: View is "dumb" - it displays and delegates, doesn't decide

## 📖 Code Comments Guide

Each file contains extensive inline comments explaining:
- **Why** design decisions were made
- **How** components interact
- **What** makes code testable
- **Testing strategies** for each component

### Files with Teaching Comments
1. **User.kt**: Domain model principles
2. **UserRepository.kt**: Interface-based design for testability
3. **InMemoryUserRepository.kt**: Implementation notes
4. **UserViewModel.kt**: MVVM responsibilities, state management, testability
5. **UserViewModelTest.kt**: Unit testing principles, mocking strategy, test structure
6. **UserListScreen.kt**: View responsibilities, reactive UI
7. **MainActivity.kt**: Dependency injection, architecture overview

## 🚀 Running the Tests

### Option 1: Command Line
```bash
./gradlew test
```

### Option 2: Android Studio
1. Sync Gradle dependencies (File → Sync Project with Gradle Files)
2. Right-click on `UserViewModelTest.kt`
3. Select "Run 'UserViewModelTest'"

### Expected Output
```
✓ UserViewModel initialization
  ✓ should load users from repository on creation
  ✓ should start with empty list when repository is empty
  
✓ addUser function
  ✓ should add user to repository and update state
  ✓ should generate correct ID for subsequent users
  
✓ deleteUser function
  ✓ should remove user from state
  ✓ should handle deleting non-existent user gracefully
  
✓ edge cases
  ✓ should generate ID 1 when starting from empty list
```

## 🔄 Running the App

1. Sync Gradle dependencies
2. Run the app on an emulator or device
3. You'll see a list with 3 pre-seeded users
4. Tap the **+** button to add new users
5. Tap the **delete** icon to remove users

## 📝 Key Takeaways

### Unit Test vs Integration Test

**This Demo: Unit Tests**
- Mock repository with MockK
- Test ViewModel in isolation
- Fast (milliseconds)
- No Android framework needed
- Deterministic and reliable

**Not This Demo: Integration Tests**
- Would use real repository implementation
- Test multiple components together
- Slower (requires I/O)
- Tests component interactions
- More brittle

### MVVM Benefits for Testing

1. **Clear Boundaries**: Each layer has distinct responsibilities
2. **Dependency Injection**: Easy to swap real implementations with mocks
3. **No Framework Dependencies**: ViewModel is pure Kotlin
4. **Observable State**: Easy to verify state changes
5. **Single Responsibility**: Each component does one thing well

### Kotest & MockK Advantages

**Kotest**:
- Readable BDD-style syntax
- JUnit 5 platform support
- Rich assertion library
- Hierarchical test organization

**MockK**:
- Kotlin-first (not Java-based like Mockito)
- Great support for suspend functions (`coEvery`, `coVerify`)
- Relaxed mocks for convenience
- Powerful matching (`match { }`)

## 🎓 Learning Path

1. **Start with**: Read `User.kt` and `UserRepository.kt` - understand domain models and interfaces
2. **Then**: Study `UserViewModel.kt` - see how business logic is organized
3. **Next**: Examine `UserViewModelTest.kt` - understand unit testing strategy
4. **Finally**: Look at `UserListScreen.kt` - see how View observes ViewModel

## 🔧 Extending This Example

Want to practice? Try adding:
- [ ] Edit user functionality
- [ ] Search/filter users
- [ ] Sort users by name
- [ ] Validation (e.g., name can't be empty)
- [ ] Error handling (repository returns Result type)
- [ ] Loading states (show spinner while loading)

For each feature:
1. Add business logic to ViewModel
2. Write unit tests FIRST (TDD!)
3. Update repository interface if needed
4. Update UI last

## 📚 References

- [Android ViewModel Guide](https://developer.android.com/topic/libraries/architecture/viewmodel)
- [Kotest Documentation](https://kotest.io/)
- [MockK Documentation](https://mockk.io/)
- [Kotlin Coroutines Testing](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-test/)

---

**Happy Testing!** 🎉

Remember: Good architecture makes testing easy. If something is hard to test, it's usually a sign of poor design.

