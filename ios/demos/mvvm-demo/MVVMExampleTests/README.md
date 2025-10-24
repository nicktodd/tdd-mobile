# Unit Tests - MVVM Example

This folder contains comprehensive unit tests for the MVVM Example iOS application, demonstrating best practices for testing in Swift using manual mocks.

## Test Structure

```
MVVMExampleTests/
├── README.md                     # This file
├── MockUserRepository.swift      # Manual mock implementation
├── UserTests.swift               # Model layer tests
├── UserRepositoryTests.swift     # Repository/Data layer tests
└── UserListViewModelTests.swift  # ViewModel layer tests
```

## Testing Philosophy

### Why Manual Mocks?

We use **manual mocks** instead of frameworks like Cuckoo because:

**Simple** - No external dependencies or complex setup  
**Educational** - Students see exactly how mocking works  
**Reliable** - No build phase scripts or tooling issues  
**Flexible** - Easy to customize for specific test scenarios  
**Maintainable** - Clear and straightforward implementation

### What We're Testing

#### 1. **Model Tests** (`UserTests.swift`)
- Data integrity (initialization, properties)
- Equatable conformance
- Factory methods for test data

#### 2. **Repository Tests** (`UserRepositoryTests.swift`)
- CRUD operations (Create, Read, Update, Delete)
- Edge cases (not found, empty data)
- Data persistence
- ID generation

#### 3. **ViewModel Tests** (`UserListViewModelTests.swift`)
- Business logic
- State management
- User interactions
- Integration with repository (using mocks)

## 🏗️ Test Structure: AAA Pattern

All tests follow the **Arrange-Act-Assert** pattern:

```swift
func testAddUser_ClearsInputFieldAfterAdding() {
    // Arrange - Set up test dependencies and data
    mockRepository.getAllUsersReturnValue = []
    mockRepository.addUserReturnValue = User(id: 1, name: "New User")
    viewModel = UserListViewModel(repository: mockRepository)
    viewModel.newUserName = "New User"
    
    // Act - Perform the action being tested
    viewModel.addUser()
    
    // Assert - Verify the expected outcome
    XCTAssertEqual(viewModel.newUserName, "", "Input field should be cleared")
}
```

## How to Use the Manual Mock

### 1. Create the Mock
```swift
let mockRepository = MockUserRepository()
```

### 2. Configure Return Values
```swift
mockRepository.getAllUsersReturnValue = [
    User(id: 1, name: "Alice"),
    User(id: 2, name: "Bob")
]
```

### 3. Use the Mock
```swift
let viewModel = UserListViewModel(repository: mockRepository)
viewModel.loadUsers()
```

### 4. Verify Behavior
```swift
XCTAssertTrue(mockRepository.getAllUsersCalled)
XCTAssertEqual(mockRepository.getAllUsersCallCount, 1)
```

## Test Naming Convention

We use descriptive test names following this pattern:

**`test_methodName_scenario_expectedResult`**

Examples:
- `testInit_LoadsUsersFromRepository()`
- `testAddUser_DoesNothingWhenNameIsEmpty()`
- `testDeleteUser_SetsErrorMessageWhenDeletionFails()`

**Benefits:**
- Self-documenting
- Easy to understand what failed
- Clear test intent

## Key Testing Concepts

### 1. Test Isolation
Each test is independent and doesn't affect others:
```swift
override func setUp() {
    super.setUp()
    mockRepository = MockUserRepository()
    // Create fresh mock for each test
}

override func tearDown() {
    mockRepository = nil
    viewModel = nil
    super.tearDown()
}
```

### 2. Testing State Changes
```swift
func testLoadUsers_ClearsErrorMessage() {
    // Arrange
    viewModel.errorMessage = "Previous error"
    
    // Act
    viewModel.loadUsers()
    
    // Assert
    XCTAssertNil(viewModel.errorMessage)
}
```

### 3. Testing Method Calls
```swift
func testDeleteUser_CallsRepositoryWithCorrectId() {
    // Arrange
    let user = User(id: 42, name: "Delete Me")
    
    // Act
    viewModel.deleteUser(user)
    
    // Assert
    XCTAssertEqual(mockRepository.deleteUserCalledWith, 42)
}
```

### 4. Testing Edge Cases
```swift
func testAddUser_DoesNothingWhenNameIsWhitespace() {
    viewModel.newUserName = "   "
    viewModel.addUser()
    XCTAssertEqual(mockRepository.addUserCallCount, 0)
}
```

## Running the Tests

### In Xcode
- **Run all tests**: `Cmd + U`
- **Run specific test class**: Click the diamond icon next to the class
- **Run specific test method**: Click the diamond icon next to the method

### From Command Line
```bash
xcodebuild test \
  -scheme MVVMExample \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Coverage

Our tests cover:

**ViewModel Tests**: 20+ test cases
- Initialization (3 tests)
- Load users (2 tests)
- Add user (5 tests)
- Delete user (4 tests)
- Computed properties (6 tests)

**Repository Tests**: 20+ test cases
- Initialization (2 tests)
- Get all users (2 tests)
- Get user by ID (3 tests)
- Add user (4 tests)
- Delete user (4 tests)
- Update user (4 tests)
- Integration (1 test)

**Model Tests**: 8 test cases
- Initialization (2 tests)
- Equatable (3 tests)
- Identifiable (1 test)
- Mock factory (2 tests)

## Best Practices Demonstrated

### 1. Test What, Not How
**Bad**: Testing internal implementation details  
**Good**: Testing observable behavior
```swift
// Good - tests behavior
XCTAssertEqual(viewModel.users.count, 2)

// Not - tests implementation
// XCTAssertTrue(viewModel.internalArray.isEmpty)
```

### 2. One Concept Per Test
```swift
// Each test verifies ONE specific behavior
func testAddUser_ClearsInputFieldAfterAdding()
func testAddUser_ReloadsUsersAfterAdding()
func testAddUser_CallsRepositoryWithCorrectUser()
```

### 3. Meaningful Test Data
```swift
// Bad - unclear
let user = User(id: 1, name: "A")

// Good - descriptive
let userToDelete = User(id: 42, name: "Delete Me")
```

### 4. Clear Assertions
```swift
// Good - includes failure message
XCTAssertEqual(
    viewModel.users.count, 
    2, 
    "ViewModel should contain 2 users"
)
```

## Common Patterns

### Setting Up Multiple Return Values
```swift
// Mock returns different values on successive calls
mockRepository.getAllUsersReturnValue = [user1]
viewModel = UserListViewModel(repository: mockRepository)

mockRepository.getAllUsersReturnValue = [user1, user2]
viewModel.loadUsers()
```

### Verifying No Interaction
```swift
viewModel.newUserName = ""
viewModel.addUser()

XCTAssertEqual(
    mockRepository.addUserCallCount, 
    0, 
    "Should not call repository with empty name"
)
```

### Testing Error Conditions
```swift
mockRepository.deleteUserReturnValue = false
viewModel.deleteUser(user)

XCTAssertNotNil(viewModel.errorMessage)
```

## What Makes a Good Unit Test?

### FAST
Tests run in milliseconds

### ISOLATED
Each test is independent

### REPEATABLE
Same result every time

### SELF-VALIDATING
Clear pass/fail

### TIMELY
Written with (or before) production code

## Testing Layers in MVVM

### Model Layer
- Simple data structures
- Minimal testing needed
- Focus on custom logic

### Repository Layer
- Test actual implementation
- No mocks needed for in-memory storage
- Test CRUD operations thoroughly

### ViewModel Layer
- Use mocks to isolate from dependencies
- Test business logic extensively
- Test state management
- Test user interactions

## Next Steps

1. **Run the tests** to ensure everything passes
2. **Add more tests** as you add features
3. **Check coverage** to find untested code
4. **Practice TDD** by writing tests first
