// POSSIBLY CAN REMOVE AS PROBABLY ALL COVERED ELSEWHERE
//  MVVMExampleTests.swift
//  MVVMExampleTests
//
//  Created by Nick Todd on 23/10/2025.
//

import XCTest
@testable import MVVMExample

/**
 * MVVM EXAMPLE TESTS - MAIN TEST FILE
 *
 * This file has been refactored! The comprehensive test suite is now organized
 * into focused, single-responsibility test files:
 *
 * REFACTORED TEST ORGANIZATION:
 * 
 * ├── Models/UserTests.swift                       - Model validation tests
 * ├── Repositories/InMemoryUserRepositoryTests.swift - Repository CRUD tests
 * ├── ViewModels/UserListViewModelTests.swift     - ViewModel business logic
 * ├── ViewModels/UserListViewModelPresentationTests.swift - UI presentation logic
 * ├── Mocks/MockUserRepository.swift              - Mock implementations
 * ├── Architecture/MVVMArchitectureTests.swift    - Integration & architecture validation
 * └── BestPractices/TestingBestPracticesDemo.swift - Advanced testing patterns
 *
 * BENEFITS OF THIS REFACTORING:
 * 
 * 1. SINGLE RESPONSIBILITY: Each test file focuses on one component
 * 2. BETTER ORGANIZATION: Tests are grouped by architectural layer
 * 3. IMPROVED MAINTAINABILITY: Easier to find and update specific tests
 * 4. CLEARER NAMING: File names clearly indicate what is being tested
 * 5. REDUCED COUPLING: Tests are more isolated and independent
 *
 * See TestSuiteOverview.swift for detailed documentation of the testing approach.
 */

// MARK: - User Model Tests

/**
 * USER MODEL TESTS
 *
 * These tests verify the User model behaves correctly.
 * Since it's a simple struct, we mainly test:
 * - Initialization
 * - Equatable conformance
 * - Test helper methods
 */
class UserModelTests: XCTestCase {
    
    func testUserInitialization() {
        // Given
        let id = 1
        let name = "Test User"
        
        // When
        let user = User(id: id, name: name)
        
        // Then - Using Nimble for more readable assertions
        expect(user.id).to(equal(id))
        expect(user.name).to(equal(name))
    }
    
    func testUserEquality() {
        // Given
        let user1 = User(id: 1, name: "Alice")
        let user2 = User(id: 1, name: "Alice")
        let user3 = User(id: 2, name: "Alice")
        
        // Then
        expect(user1).to(equal(user2))
        expect(user1).toNot(equal(user3))
    }
    
    func testMockUserFactory() {
        // When
        let mockUser = User.mockUser()
        let customMockUser = User.mockUser(id: 5, name: "Custom User")
        let mockUsers = User.mockUsers()
        
        // Then
        expect(mockUser.id).to(equal(1))
        expect(mockUser.name).to(equal("Test User"))
        expect(customMockUser.id).to(equal(5))
        expect(customMockUser.name).to(equal("Custom User"))
        expect(mockUsers).to(haveCount(3))
    }
}

// MARK: - Repository Tests

/**
 * USER REPOSITORY TESTS
 *
 * These tests verify the InMemoryUserRepository implementation.
 * Key testing principles:
 * - Test the contract defined by UserRepositoryProtocol
 * - Verify CRUD operations work correctly
 * - Test edge cases (empty repository, non-existent users, etc.)
 * - Ensure data integrity and consistency
 */
class UserRepositoryTests: XCTestCase {
    
    var repository: InMemoryUserRepository!
    
    override func setUp() {
        super.setUp()
        // Create a fresh repository for each test to ensure isolation
        repository = InMemoryUserRepository()
    }
    
    override func tearDown() {
        repository = nil
        super.tearDown()
    }
    
    // MARK: - Read Operations Tests
    
    func testGetAllUsersWhenEmpty() {
        // When
        let users = repository.getAllUsers()
        
        // Then
        expect(users).to(beEmpty())
    }
    
    func testGetAllUsersWithData() {
        // Given
        let initialUsers = User.mockUsers()
        repository = InMemoryUserRepository(initialUsers: initialUsers)
        
        // When
        let users = repository.getAllUsers()
        
        // Then
        expect(users).to(haveCount(3))
        expect(users).to(equal(initialUsers))
    }
    
    func testGetUserByIdSuccess() {
        // Given
        let testUser = User.mockUser(id: 1, name: "Test User")
        _ = repository.addUser(testUser)
        
        // When
        let foundUser = repository.getUserById(1)
        
        // Then
        expect(foundUser).toNot(beNil())
        expect(foundUser?.name).to(equal("Test User"))
    }
    
    func testGetUserByIdNotFound() {
        // When
        let foundUser = repository.getUserById(999)
        
        // Then
        expect(foundUser).to(beNil())
    }
    
    // MARK: - Create Operations Tests
    
    func testAddUserGeneratesId() {
        // Given
        let userToAdd = User(id: 0, name: "New User") // ID should be ignored
        
        // When
        let addedUser = repository.addUser(userToAdd)
        
        // Then
        expect(addedUser.id).to(equal(1)) // First user should get ID 1
        expect(addedUser.name).to(equal("New User"))
        expect(repository.userCount).to(equal(1))
    }
    
    func testAddMultipleUsersIncrementIds() {
        // Given
        let user1 = User(id: 0, name: "User 1")
        let user2 = User(id: 0, name: "User 2")
        
        // When
        let addedUser1 = repository.addUser(user1)
        let addedUser2 = repository.addUser(user2)
        
        // Then
        expect(addedUser1.id).to(equal(1))
        expect(addedUser2.id).to(equal(2))
        expect(repository.userCount).to(equal(2))
    }
    
    func testAddUserWithExistingData() {
        // Given
        let initialUsers = [User(id: 5, name: "Existing User")]
        repository = InMemoryUserRepository(initialUsers: initialUsers)
        let newUser = User(id: 0, name: "New User")
        
        // When
        let addedUser = repository.addUser(newUser)
        
        // Then
        expect(addedUser.id).to(equal(6)) // Should be next after highest existing ID
        expect(repository.userCount).to(equal(2))
    }
    
    // MARK: - Delete Operations Tests
    
    func testDeleteUserSuccess() {
        // Given
        let user = repository.addUser(User(id: 0, name: "To Delete"))
        let userId = user.id
        
        // When
        let deleteResult = repository.deleteUser(withId: userId)
        
        // Then
        expect(deleteResult).to(beTrue())
        expect(repository.userCount).to(equal(0))
        expect(repository.getUserById(userId)).to(beNil())
    }
    
    func testDeleteUserNotFound() {
        // When
        let deleteResult = repository.deleteUser(withId: 999)
        
        // Then
        expect(deleteResult).to(beFalse())
    }
    
    // MARK: - Update Operations Tests
    
    func testUpdateUserSuccess() {
        // Given
        let originalUser = repository.addUser(User(id: 0, name: "Original Name"))
        let updatedUser = User(id: originalUser.id, name: "Updated Name")
        
        // When
        let result = repository.updateUser(updatedUser)
        
        // Then
        expect(result).toNot(beNil())
        expect(result?.name).to(equal("Updated Name"))
        expect(repository.getUserById(originalUser.id)?.name).to(equal("Updated Name"))
    }
    
    func testUpdateUserNotFound() {
        // Given
        let nonExistentUser = User(id: 999, name: "Non-existent")
        
        // When
        let result = repository.updateUser(nonExistentUser)
        
        // Then
        expect(result).to(beNil())
    }
    
    // MARK: - Utility Tests
    
    func testClearAllUsers() {
        // Given
        _ = repository.addUser(User(id: 0, name: "User 1"))
        _ = repository.addUser(User(id: 0, name: "User 2"))
        
        // When
        repository.clearAllUsers()
        
        // Then
        expect(repository.userCount).to(equal(0))
        expect(repository.getAllUsers()).to(beEmpty())
    }
}

// MARK: - Mock Repository for ViewModel Tests

/**
 * MOCK USER REPOSITORY
 *
 * This demonstrates how to create a mock using Cuckoo.
 * The mock allows us to:
 * 1. Control the behavior of dependencies in tests
 * 2. Verify that the ViewModel calls the repository correctly
 * 3. Test error scenarios by making the mock return specific values
 * 4. Isolate the ViewModel from the actual repository implementation
 */
class MockUserRepositoryProtocol: UserRepositoryProtocol, Mock {
    
    func getAllUsers() -> [User] {
        return cuckoo_manager.call("getAllUsers() -> [User]",
                                 parameters: (),
                                 escapingParameters: ()) as [User]
    }
    
    func getUserById(_ id: Int) -> User? {
        return cuckoo_manager.call("getUserById(Int) -> User?",
                                 parameters: (id),
                                 escapingParameters: (id)) as User?
    }
    
    func addUser(_ user: User) -> User {
        return cuckoo_manager.call("addUser(User) -> User",
                                 parameters: (user),
                                 escapingParameters: (user)) as User
    }
    
    func deleteUser(withId id: Int) -> Bool {
        return cuckoo_manager.call("deleteUser(withId: Int) -> Bool",
                                 parameters: (id),
                                 escapingParameters: (id)) as Bool
    }
    
    func updateUser(_ user: User) -> User? {
        return cuckoo_manager.call("updateUser(User) -> User?",
                                 parameters: (user),
                                 escapingParameters: (user)) as User?
    }
    
    var cuckoo_manager = CuckooManager()
}

// MARK: - ViewModel Tests

/**
 * USER LIST VIEW MODEL TESTS
 *
 * These are the most important tests as they verify the business logic.
 * Key testing strategies:
 * 1. MOCK DEPENDENCIES: Use MockUserRepositoryProtocol to control repository behavior
 * 2. TEST PUBLISHED PROPERTIES: Verify @Published properties update correctly
 * 3. TEST COMMANDS: Verify user actions trigger correct repository calls
 * 4. TEST ERROR HANDLING: Verify error states are handled properly
 * 5. TEST COMPUTED PROPERTIES: Verify presentation logic works correctly
 */
class UserListViewModelTests: XCTestCase {
    
    var viewModel: UserListViewModel!
    var mockRepository: MockUserRepositoryProtocol!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepositoryProtocol()
        viewModel = UserListViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitializationLoadsUsers() {
        // Given
        let expectedUsers = User.mockUsers()
        stub(mockRepository) { stub in
            when(stub.getAllUsers()).thenReturn(expectedUsers)
        }
        
        // When
        let newViewModel = UserListViewModel(repository: mockRepository)
        
        // Then
        expect(newViewModel.users).to(equal(expectedUsers))
        verify(mockRepository).getAllUsers()
    }
    
    // MARK: - Load Users Tests
    
    func testLoadUsersSuccess() {
        // Given
        let expectedUsers = User.mockUsers()
        stub(mockRepository) { stub in
            when(stub.getAllUsers()).thenReturn(expectedUsers)
        }
        
        // When
        viewModel.loadUsers()
        
        // Then
        expect(self.viewModel.users).to(equal(expectedUsers))
        expect(self.viewModel.isLoading).to(beFalse())
        expect(self.viewModel.errorMessage).to(beNil())
        verify(mockRepository).getAllUsers()
    }
    
    func testLoadUsersShowsLoadingState() {
        // Given
        stub(mockRepository) { stub in
            when(stub.getAllUsers()).thenReturn([])
        }
        
        // When
        viewModel.loadUsers()
        
        // Then - Check that loading state is set immediately
        expect(self.viewModel.isLoading).to(beTrue())
        expect(self.viewModel.errorMessage).to(beNil())
    }
    
    // MARK: - Add User Tests
    
    func testAddUserSuccess() {
        // Given
        let userToAdd = User(id: 1, name: "New User")
        let allUsersAfterAdd = [userToAdd]
        
        stub(mockRepository) { stub in
            when(stub.addUser(any())).thenReturn(userToAdd)
            when(stub.getAllUsers()).thenReturn([]).thenReturn(allUsersAfterAdd)
        }
        
        viewModel.newUserName = "New User"
        
        // When
        viewModel.addUser()
        
        // Then
        expect(self.viewModel.users).to(equal(allUsersAfterAdd))
        expect(self.viewModel.newUserName).to(equal("")) // Should clear input
        expect(self.viewModel.isLoading).to(beFalse())
        
        verify(mockRepository).addUser(any())
        verify(mockRepository, times(2)).getAllUsers() // Once on init, once after add
    }
    
    func testAddUserWithEmptyName() {
        // Given
        viewModel.newUserName = "   " // Whitespace only
        
        // When
        viewModel.addUser()
        
        // Then
        expect(self.viewModel.errorMessage).to(equal("User name cannot be empty"))
        verifyNoMoreInteractions(mockRepository) // Should not call repository
    }
    
    func testAddUserTrimsWhitespace() {
        // Given
        let expectedUser = User(id: 1, name: "Trimmed User")
        stub(mockRepository) { stub in
            when(stub.addUser(any())).thenReturn(expectedUser)
            when(stub.getAllUsers()).thenReturn([]).thenReturn([expectedUser])
        }
        
        viewModel.newUserName = "  Trimmed User  "
        
        // When
        viewModel.addUser()
        
        // Then
        let argumentCaptor = ArgumentCaptor<User>()
        verify(mockRepository).addUser(argumentCaptor.capture())
        expect(argumentCaptor.value?.name).to(equal("Trimmed User"))
    }
    
    // MARK: - Delete User Tests
    
    func testDeleteUserSuccess() {
        // Given
        let remainingUsers = [User(id: 2, name: "Remaining User")]
        stub(mockRepository) { stub in
            when(stub.deleteUser(withId: 1)).thenReturn(true)
            when(stub.getAllUsers()).thenReturn([]).thenReturn(remainingUsers)
        }
        
        // When
        viewModel.deleteUser(withId: 1)
        
        // Then
        expect(self.viewModel.users).to(equal(remainingUsers))
        expect(self.viewModel.isLoading).to(beFalse())
        expect(self.viewModel.errorMessage).to(beNil())
        
        verify(mockRepository).deleteUser(withId: 1)
        verify(mockRepository, times(2)).getAllUsers()
    }
    
    func testDeleteUserFailure() {
        // Given
        stub(mockRepository) { stub in
            when(stub.deleteUser(withId: 999)).thenReturn(false)
            when(stub.getAllUsers()).thenReturn([])
        }
        
        // When
        viewModel.deleteUser(withId: 999)
        
        // Then
        expect(self.viewModel.errorMessage).to(equal("Failed to delete user. User not found."))
        expect(self.viewModel.isLoading).to(beFalse())
        
        verify(mockRepository).deleteUser(withId: 999)
    }
    
    // MARK: - Error Handling Tests
    
    func testClearError() {
        // Given
        viewModel.errorMessage = "Test error"
        
        // When
        viewModel.clearError()
        
        // Then
        expect(self.viewModel.errorMessage).to(beNil())
    }
    
    // MARK: - Computed Properties Tests
    
    func testCanAddUserWhenNameIsValid() {
        // Given
        viewModel.newUserName = "Valid Name"
        viewModel.isLoading = false
        
        // Then
        expect(self.viewModel.canAddUser).to(beTrue())
    }
    
    func testCanAddUserWhenNameIsEmpty() {
        // Given
        viewModel.newUserName = ""
        viewModel.isLoading = false
        
        // Then
        expect(self.viewModel.canAddUser).to(beFalse())
    }
    
    func testCanAddUserWhenLoading() {
        // Given
        viewModel.newUserName = "Valid Name"
        viewModel.isLoading = true
        
        // Then
        expect(self.viewModel.canAddUser).to(beFalse())
    }
    
    func testUserCountTextSingular() {
        // Given
        viewModel.users = [User.mockUser()]
        
        // Then
        expect(self.viewModel.userCountText).to(equal("1 User"))
    }
    
    func testUserCountTextPlural() {
        // Given
        viewModel.users = User.mockUsers() // 3 users
        
        // Then
        expect(self.viewModel.userCountText).to(equal("3 Users"))
    }
    
    func testUserCountTextZero() {
        // Given
        viewModel.users = []
        
        // Then
        expect(self.viewModel.userCountText).to(equal("0 Users"))
    }
}
