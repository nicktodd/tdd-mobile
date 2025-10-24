# SWAPI Demo - Asynchronous Testing and Error Handling

## Overview
This is a demonstration Android application that showcases **asynchronous testing** and **error handling** in a real-world scenario. The app fetches Star Wars character data from the [SWAPI (Star Wars API)](https://swapi.dev) and displays it in a simple list.

## Learning Focus
This project is specifically designed to teach:
1. **Asynchronous Testing** with Kotlin Coroutines
2. **Error Handling** for network operations
3. **Repository Pattern** for data access
4. **MVVM Architecture** for clean separation of concerns
5. **Mocking** with MockK
6. **Testing network failures, timeouts, and edge cases**

## Architecture

### Layers
1. **UI Layer** (`MainActivity.kt`)
   - Jetpack Compose UI
   - Displays loading, success, and error states
   - Retry functionality for errors

2. **ViewModel Layer** (`CharacterViewModel.kt`)
   - Manages UI state using StateFlow
   - Handles business logic
   - Coordinates with repository
   - Fully testable with mocked repository

3. **Repository Layer** (`CharacterRepositoryImpl.kt`)
   - Implements Repository pattern
   - Handles all network operations
   - Comprehensive error handling (timeouts, network errors, HTTP errors)
   - Abstracted behind `CharacterRepository` interface for easy mocking

4. **Data Layer**
   - `SwapiService` - Retrofit interface
   - `Character` - Data model
   - `CharacterResponse` - API response wrapper
   - `Result` - Sealed class for success/error results

## Key Features

### Error Handling
The repository handles multiple error scenarios:
- **Network Timeouts** (`SocketTimeoutException`)
- **No Internet Connection** (`UnknownHostException`, `IOException`)
- **HTTP Errors** (404, 500, 503, etc.)
- **Malformed Data** (JSON parsing errors)
- **Generic Exceptions**

### UI States
The ViewModel manages four distinct states:
- **Idle** - Initial state
- **Loading** - During network request
- **Success** - Data loaded successfully
- **Error** - Something went wrong (with user-friendly message)

## Testing Strategy

### Test Files

#### 1. `CharacterViewModelTest.kt`
**Purpose**: Tests the ViewModel with mocked repository

**Key Concepts Demonstrated**:
- Setting up TestDispatcher for coroutine testing
- Mocking suspend functions with MockK
- Testing StateFlow emissions
- Verifying repository interactions
- Testing error propagation from repository to ViewModel

**Test Categories**:
- ✅ Happy path tests (successful data loading)
- ✅ Error handling (network errors, timeouts, generic exceptions)
- ✅ Edge cases (empty lists, null messages)
- ✅ User actions (retry functionality)
- ✅ Multiple calls

#### 2. `CharacterRepositoryErrorHandlingTest.kt`
**Purpose**: Comprehensive testing of repository error scenarios

**Key Concepts Demonstrated**:
- Mocking Retrofit service
- Simulating network failures
- Testing timeout conditions
- Testing HTTP error codes
- Handling malformed data

**Test Categories**:
- ✅ Happy path (successful API calls)
- ✅ Network errors (timeout, no internet, connection lost)
- ✅ HTTP errors (404, 500, 503, 401)
- ✅ Malformed data (JSON parsing, null values)
- ✅ Pagination
- ✅ Error recovery

#### 3. `CharacterViewModelAdvancedAsyncTest.kt`
**Purpose**: Advanced asynchronous testing scenarios

**Key Concepts Demonstrated**:
- Using `StandardTestDispatcher` for time control
- Testing state transitions
- Simulating slow network responses
- Testing concurrent operations
- Virtual time advancement with `TestCoroutineScheduler`

**Test Categories**:
- ✅ Delayed responses and loading states
- ✅ Multiple rapid calls
- ✅ State transition sequences
- ✅ Timeout simulations
- ✅ Concurrent operations
- ✅ Error recovery patterns
- ✅ Boundary value testing

## Technologies Used

### Production Code
- **Kotlin** - Programming language
- **Jetpack Compose** - Modern UI toolkit
- **Kotlin Coroutines** - Asynchronous programming
- **StateFlow** - Reactive state management
- **Retrofit** - HTTP client
- **OkHttp** - Network operations
- **Gson** - JSON parsing

### Testing
- **JUnit 4** - Testing framework
- **MockK** - Mocking library for Kotlin
- **kotlinx-coroutines-test** - Coroutine testing utilities
- **TestDispatcher** - Control coroutine execution in tests
- **TestCoroutineScheduler** - Virtual time control

## Running the App

1. Open the project in Android Studio
2. Wait for Gradle sync to complete
3. Run the app on an emulator or physical device
4. The app will fetch and display Star Wars characters
5. Pull to refresh or use the retry button on errors

## Running Tests

### Run All Tests
```bash
./gradlew test
```

### Run Specific Test Class
```bash
./gradlew test --tests CharacterViewModelTest
./gradlew test --tests CharacterRepositoryErrorHandlingTest
./gradlew test --tests CharacterViewModelAdvancedAsyncTest
```

### View Test Report
After running tests, open:
```
app/build/reports/tests/testDebugUnitTest/index.html
```

## Key Learning Points

### 1. Testing Coroutines
```kotlin
@OptIn(ExperimentalCoroutinesApi::class)
class MyTest {
    private val testDispatcher = UnconfinedTestDispatcher()
    
    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
    }
    
    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }
    
    @Test
    fun myTest() = runTest {
        // Test code here
    }
}
```

### 2. Mocking Suspend Functions
```kotlin
coEvery { repository.getCharacters(any()) } returns Result.Success(data)
coVerify { repository.getCharacters(1) }
```

### 3. Testing StateFlow
```kotlin
val state = viewModel.uiState.value
assertTrue(state is ViewModel.UiState.Success)
```

### 4. Simulating Errors
```kotlin
coEvery { service.getCharacters(any()) } throws SocketTimeoutException()
coEvery { service.getCharacters(any()) } throws IOException("No internet")
```

### 5. Virtual Time Control
```kotlin
testScheduler.advanceTimeBy(1000) // Skip ahead 1 second
testScheduler.advanceUntilIdle()  // Complete all pending coroutines
```

## Common Testing Patterns

### Pattern 1: Arrange-Act-Assert (AAA)
All tests follow the AAA pattern:
```kotlin
@Test
fun myTest() = runTest {
    // Arrange - Set up mocks and data
    coEvery { repository.getData() } returns mockData
    
    // Act - Perform the action
    viewModel.loadData()
    
    // Assert - Verify the result
    assertTrue(viewModel.state.value is Success)
}
```

### Pattern 2: Error Testing
```kotlin
@Test
fun handlesError() = runTest {
    // Arrange - Mock an error
    coEvery { repository.getData() } returns Result.Error(exception)
    
    // Act
    viewModel.loadData()
    
    // Assert - Verify error is handled
    assertTrue(viewModel.state.value is Error)
}
```

### Pattern 3: State Transitions
```kotlin
@Test
fun testStateTransition() = runTest {
    // Collect states
    val states = mutableListOf<State>()
    launch { viewModel.state.collect { states.add(it) } }
    
    // Trigger action
    viewModel.loadData()
    
    // Verify sequence
    assertEquals(State.Loading, states[1])
    assertEquals(State.Success, states[2])
}
```

## Extending the Project

### Add More Error Scenarios
- Rate limiting (HTTP 429)
- Authentication failures
- Data validation errors
- Cache strategies

### Add More Tests
- UI tests with Compose testing
- Integration tests with real API (using test instance)
- Performance tests
- Memory leak tests

### Add More Features
- Pull-to-refresh
- Infinite scrolling
- Search functionality
- Offline caching with Room database
- Pagination with Paging 3 library

## Resources
- [SWAPI Documentation](https://swapi.dev)
- [Kotlin Coroutines Testing Guide](https://developer.android.com/kotlin/coroutines/test)
- [MockK Documentation](https://mockk.io)
- [Testing on Android](https://developer.android.com/training/testing)

## License
This is a demonstration project for educational purposes.

