# MVVM Design Pattern Example with Unit Testing

This project demonstrates the **Model-View-ViewModel (MVVM)** design pattern in SwiftUI with comprehensive unit testing using **Cuckoo** and **Nimble**.

## 🎯 Project Purpose

This example is designed to teach:
- **MVVM Architecture** implementation in SwiftUI
- **Dependency Injection** for testability
- **Repository Pattern** for data abstraction
- **Unit Testing** best practices with mocks
- **Test-Driven Development** approaches

## 📁 Project Structure

### Core Architecture Files

```
MVVMExample/
├── User.swift                    # Model layer
├── UserRepository.swift          # Data/Repository layer  
├── UserListViewModel.swift       # ViewModel layer
├── ContentView.swift            # View layer
└── MVVMExampleApp.swift         # Dependency injection setup
```

### Testing Files

```
MVVMExampleTests/
├── MVVMExampleTests.swift              # Main test suite
├── MockUserRepository.swift            # Mock implementations
└── TestingBestPracticesExamples.swift  # Advanced testing patterns
```

## 🏗️ MVVM Architecture Explained

### Model (`User.swift`)
**Purpose**: Represents data and business entities
- Simple, immutable data structures
- No UI dependencies
- Easy to test and reason about
- Contains factory methods for testing

```swift
struct User: Identifiable, Equatable {
    let id: Int
    let name: String
}
```

### Repository (`UserRepository.swift`)
**Purpose**: Abstracts data access and provides a clean API
- **Protocol-based** for easy mocking in tests
- **Dependency inversion** - ViewModel depends on abstraction, not concrete implementation
- **Single responsibility** - only handles data operations
- **Swappable implementations** (in-memory, Core Data, network, etc.)

```swift
protocol UserRepositoryProtocol {
    func getAllUsers() -> [User]
    func addUser(_ user: User) -> User
    func deleteUser(withId id: Int) -> Bool
    // ... other CRUD operations
}
```

### ViewModel (`UserListViewModel.swift`)
**Purpose**: Mediates between View and Model, contains presentation logic
- **ObservableObject** for SwiftUI integration
- **@Published properties** for automatic UI updates
- **Command methods** for handling user actions
- **Input validation** and error handling
- **Presentation logic** (formatting, computed properties)
- **No UI dependencies** - purely business logic

```swift
@MainActor
class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
        loadUsers()
    }
}
```

### View (`ContentView.swift`)
**Purpose**: Presents data and handles user interaction
- **Declarative UI** with SwiftUI
- **Data binding** to ViewModel's @Published properties
- **No business logic** - just presentation and user input forwarding
- **Dependency injection** through initializer

## 🧪 Unit Testing Strategy

### Testing Philosophy

This project demonstrates **comprehensive unit testing** with focus on:

1. **Isolation** - Each component tested independently
2. **Mocking** - External dependencies replaced with mocks
3. **Behavior verification** - Testing what the code does, not how
4. **Readable assertions** - Using Nimble for expressive tests
5. **Edge case coverage** - Testing boundary conditions and error scenarios

### Testing Tools Used

#### **XCTest** 
Apple's standard testing framework
- Test lifecycle management
- Basic assertions
- Performance testing

#### **Nimble**
Matcher framework for more expressive assertions
```swift
// Instead of XCTAssertEqual
expect(user.name).to(equal("Alice"))

// More readable async testing
expect(viewModel.users).toEventually(haveCount(3))

// Flexible matching
expect(users).to(contain(user))
```

#### **Cuckoo**
Mocking framework for creating test doubles
```swift
// Create mock
let mockRepository = MockUserRepository()

// Stub behavior
stub(mockRepository) { stub in
    when(stub.getAllUsers()).thenReturn([user1, user2])
}

// Verify interactions
verify(mockRepository).addUser(any())
```

### Test Categories

#### 1. **Model Tests** (`UserModelTests`)
- Data structure integrity
- Equality comparisons
- Factory method functionality

#### 2. **Repository Tests** (`UserRepositoryTests`)
- CRUD operations
- Data consistency
- Edge cases (empty repository, non-existent users)
- Error conditions

#### 3. **ViewModel Tests** (`UserListViewModelTests`)
- **Business logic** verification
- **State management** testing
- **Error handling** scenarios
- **Command execution** with mocked dependencies
- **Computed properties** validation

#### 4. **Advanced Testing Patterns** (`TestingBestPracticesExamples`)
- State transitions
- Error recovery
- Custom matchers
- Test data builders
- Parameterized tests

## 🔍 Key Testing Patterns Demonstrated

### 1. Arrange-Act-Assert (AAA) Pattern
```swift
func testAddUserSuccess() {
    // ARRANGE
    let mockRepo = MockUserRepository()
    stub(mockRepo) { stub in
        when(stub.addUser(any())).thenReturn(User(id: 1, name: "Test"))
    }
    let viewModel = UserListViewModel(repository: mockRepo)
    
    // ACT
    viewModel.newUserName = "Test User"
    viewModel.addUser()
    
    // ASSERT
    expect(viewModel.users).toEventually(haveCount(1))
    verify(mockRepo).addUser(any())
}
```

### 2. Mock Verification
```swift
// Verify method was called
verify(mockRepository).getAllUsers()

// Verify method was called with specific arguments
verify(mockRepository).addUser(User(id: 0, name: "Test"))

// Verify method was called specific number of times
verify(mockRepository, times(2)).getAllUsers()

// Verify no unexpected calls
verifyNoMoreInteractions(mockRepository)
```

### 3. Argument Capture
```swift
let argumentCaptor = ArgumentCaptor<User>()
verify(mockRepository).addUser(argumentCaptor.capture())
expect(argumentCaptor.value?.name).to(equal("Expected Name"))
```

### 4. Async Testing
```swift
// Test loading states
expect(viewModel.isLoading).to(beTrue())
expect(viewModel.users).toEventually(equal(expectedUsers))
expect(viewModel.isLoading).toEventually(beFalse())
```

### 5. Custom Matchers
```swift
func haveName(_ expectedName: String) -> Matcher<User> {
    return Matcher.define("have name <\(expectedName)>") { actualExpression, msg in
        guard let actualUser = try actualExpression.evaluate() else {
            return MatcherResult(status: .fail, message: msg.appendedBeNilHint())
        }
        let matches = actualUser.name == expectedName
        return MatcherResult(bool: matches, message: msg)
    }
}

// Usage
expect(user).to(haveName("Alice"))
```

## 🚀 Benefits of This Architecture

### **Testability**
- Each layer can be tested in isolation
- Dependencies are injected, making mocking easy
- Business logic is separated from UI and data concerns

### **Maintainability**  
- Clear separation of concerns
- Changes to one layer don't affect others
- Easy to add new features or modify existing ones

### **Scalability**
- New ViewModels can reuse existing repositories
- New repository implementations can be swapped in
- UI changes don't affect business logic

### **Reliability**
- Comprehensive test coverage catches regressions
- Mock testing ensures components work correctly in isolation
- Edge cases and error conditions are thoroughly tested

## 🔧 Running the Tests

### Command Line
```bash
# Run all tests
xcodebuild test -scheme MVVMExample -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test class
xcodebuild test -scheme MVVMExample -only-testing:MVVMExampleTests/UserListViewModelTests
```

### Xcode
1. Open the project in Xcode
2. Press `Cmd+U` to run all tests
3. Use Test Navigator to run individual tests
4. View test coverage in the Report Navigator

## 📚 Learning Outcomes

After studying this example, you should understand:

1. **MVVM Pattern Implementation** in SwiftUI
2. **Dependency Injection** for loose coupling
3. **Repository Pattern** for data abstraction
4. **Mock-based Unit Testing** strategies
5. **Test Organization** and best practices
6. **Async Testing** techniques
7. **Custom Test Matchers** creation
8. **Test Data Management** patterns

## 🎓 Next Steps

To extend this example:

1. **Add Core Data** repository implementation
2. **Add Network** repository with API calls
3. **Add Navigation** between multiple screens
4. **Add User Editing** functionality
5. **Add Search/Filtering** capabilities
6. **Add Integration Tests** for full user workflows
7. **Add UI Tests** with XCUITest
8. **Add Performance Tests** for large datasets

This project serves as a solid foundation for understanding MVVM architecture and comprehensive unit testing in iOS development.