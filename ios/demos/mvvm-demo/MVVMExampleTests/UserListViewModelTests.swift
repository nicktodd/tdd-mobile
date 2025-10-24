//
//  UserListViewModelTests.swift
//  MVVMExampleTests
//
//  Unit tests for UserListViewModel
//

import XCTest
@testable import MVVMExample

/**
 * VIEWMODEL TESTS
 *
 * These tests verify that the UserListViewModel correctly:
 * - Loads users from the repository
 * - Adds new users
 * - Deletes users
 * - Updates state appropriately
 * - Provides correct computed properties
 *
 * Test Structure: Arrange-Act-Assert (AAA) pattern
 * - Arrange: Set up the mock and test data
 * - Act: Call the method being tested
 * - Assert: Verify the expected behavior occurred
 */
class UserListViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    var mockRepository: MockUserRepository!
    var viewModel: UserListViewModel!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        // Note: We create viewModel in each test after setting up the mock
    }
    
    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_LoadsUsersFromRepository() {
        // Arrange
        let expectedUsers = [
            User(id: 1, name: "Alice"),
            User(id: 2, name: "Bob")
        ]
        mockRepository.getAllUsersReturnValue = expectedUsers
        
        // Act
        viewModel = UserListViewModel(repository: mockRepository)
        
        // Assert
        XCTAssertTrue(mockRepository.getAllUsersCalled, "Repository should be called during init")
        XCTAssertEqual(viewModel.users, expectedUsers, "ViewModel should contain users from repository")
    }
    
    func testInit_SetsLoadingToFalseAfterLoad() {
        // Arrange
        mockRepository.getAllUsersReturnValue = []
        
        // Act
        viewModel = UserListViewModel(repository: mockRepository)
        
        // Assert
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after initialization")
    }
    
    func testInit_HandlesEmptyUserList() {
        // Arrange
        mockRepository.getAllUsersReturnValue = []
        
        // Act
        viewModel = UserListViewModel(repository: mockRepository)
        
        // Assert
        XCTAssertEqual(viewModel.users.count, 0, "ViewModel should handle empty user list")
    }
    
    // MARK: - Load Users Tests
    
    func testLoadUsers_UpdatesUsersProperty() {
        // Arrange
        let initialUsers = [User(id: 1, name: "Initial User")]
        let updatedUsers = [
            User(id: 2, name: "Updated User 1"),
            User(id: 3, name: "Updated User 2")
        ]
        
        mockRepository.getAllUsersReturnValue = initialUsers
        viewModel = UserListViewModel(repository: mockRepository)
        XCTAssertEqual(viewModel.users, initialUsers)
        
        // Change the mock to return different users
        mockRepository.getAllUsersReturnValue = updatedUsers
        
        // Act
        viewModel.loadUsers()
        
        // Assert
        XCTAssertEqual(viewModel.users, updatedUsers, "Users should be updated after loadUsers()")
        XCTAssertEqual(mockRepository.getAllUsersCallCount, 2, "Repository should be called twice")
    }
    
    func testLoadUsers_ClearsErrorMessage() {
        // Arrange
        mockRepository.getAllUsersReturnValue = []
        viewModel = UserListViewModel(repository: mockRepository)
        viewModel.errorMessage = "Previous error"
        
        // Act
        viewModel.loadUsers()
        
        // Assert
        XCTAssertNil(viewModel.errorMessage, "Error message should be cleared when loading users")
    }
    
    // MARK: - Add User Tests
    
    func testAddUser_CallsRepositoryWithCorrectUser() {
        // Arrange
        mockRepository.getAllUsersReturnValue = []
        mockRepository.addUserReturnValue = User(id: 1, name: "New User")
        viewModel = UserListViewModel(repository: mockRepository)
        viewModel.newUserName = "New User"
        
        // Act
        viewModel.addUser()
        
        // Assert
        XCTAssertEqual(mockRepository.addUserCallCount, 1, "Repository addUser should be called once")
        XCTAssertEqual(mockRepository.addUserCalledWith?.name, "New User", "Repository should receive correct user name")
    }
    
    func testAddUser_ReloadsUsersAfterAdding() {
        // Arrange
        mockRepository.getAllUsersReturnValue = []
        mockRepository.addUserReturnValue = User(id: 1, name: "New User")
        viewModel = UserListViewModel(repository: mockRepository)
        
        let initialCallCount = mockRepository.getAllUsersCallCount
        viewModel.newUserName = "New User"
        
        // Act
        viewModel.addUser()
        
        // Assert
        XCTAssertEqual(mockRepository.getAllUsersCallCount, initialCallCount + 1, "Should reload users after adding")
    }
    
    func testAddUser_ClearsInputFieldAfterAdding() {
        // Arrange
        mockRepository.getAllUsersReturnValue = []
        mockRepository.addUserReturnValue = User(id: 1, name: "New User")
        viewModel = UserListViewModel(repository: mockRepository)
        viewModel.newUserName = "New User"
        
        // Act
        viewModel.addUser()
        
        // Assert
        XCTAssertEqual(viewModel.newUserName, "", "Input field should be cleared after adding user")
    }
    
    func testAddUser_DoesNothingWhenNameIsEmpty() {
        // Arrange
        mockRepository.getAllUsersReturnValue = []
        viewModel = UserListViewModel(repository: mockRepository)
        viewModel.newUserName = ""
        
        // Act
        viewModel.addUser()
        
        // Assert
        XCTAssertEqual(mockRepository.addUserCallCount, 0, "Repository should not be called with empty name")
    }
    
    func testAddUser_DoesNothingWhenNameIsWhitespace() {
        // Arrange
        mockRepository.getAllUsersReturnValue = []
        viewModel = UserListViewModel(repository: mockRepository)
        viewModel.newUserName = "   "
        
        // Act
        viewModel.addUser()
        
        // Assert
        XCTAssertEqual(mockRepository.addUserCallCount, 0, "Repository should not be called with whitespace-only name")
    }
    
    // MARK: - Delete User Tests
    
    func testDeleteUser_CallsRepositoryWithCorrectId() {
        // Arrange
        let userToDelete = User(id: 42, name: "Delete Me")
        mockRepository.getAllUsersReturnValue = [userToDelete]
        mockRepository.deleteUserReturnValue = true
        viewModel = UserListViewModel(repository: mockRepository)
        
        // Act
        viewModel.deleteUser(withId: userToDelete.id)
        
        // Assert
        XCTAssertEqual(mockRepository.deleteUserCalledWith, 42, "Repository should be called with correct user ID")
    }
    
    func testDeleteUser_ReloadsUsersAfterDeletion() {
        // Arrange
        let user = User(id: 1, name: "Delete Me")
        mockRepository.getAllUsersReturnValue = [user]
        mockRepository.deleteUserReturnValue = true
        viewModel = UserListViewModel(repository: mockRepository)
        
        let initialCallCount = mockRepository.getAllUsersCallCount
        
        // Act
        viewModel.deleteUser(withId: user.id)
        
        // Assert
        XCTAssertEqual(mockRepository.getAllUsersCallCount, initialCallCount + 1, "Should reload users after deletion")
    }
    
    func testDeleteUser_SetsErrorMessageWhenDeletionFails() {
        // Arrange
        let user = User(id: 1, name: "Cannot Delete")
        mockRepository.getAllUsersReturnValue = [user]
        mockRepository.deleteUserReturnValue = false
        viewModel = UserListViewModel(repository: mockRepository)
        
        // Act
        viewModel.deleteUser(withId: user.id)
        
        // Assert
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set when deletion fails")
        XCTAssertTrue(viewModel.errorMessage?.contains("delete") ?? false, "Error message should mention deletion")
    }
    
    func testDeleteUser_DoesNotSetErrorWhenDeletionSucceeds() {
        // Arrange
        let user = User(id: 1, name: "Delete Me")
        mockRepository.getAllUsersReturnValue = [user]
        mockRepository.deleteUserReturnValue = true
        viewModel = UserListViewModel(repository: mockRepository)
        
        // Act
        viewModel.deleteUser(withId: user.id)
        
        // Assert
        XCTAssertNil(viewModel.errorMessage, "Error message should not be set when deletion succeeds")
    }
    
    // MARK: - Computed Property Tests
    
    // MARK: - Computed Property Tests
    
    func testUsersCount_ReturnsCorrectCount() {
        // Arrange
        let users = [
            User(id: 1, name: "User 1"),
            User(id: 2, name: "User 2"),
            User(id: 3, name: "User 3")
        ]
        mockRepository.getAllUsersReturnValue = users
        
        // Act
        viewModel = UserListViewModel(repository: mockRepository)
        
        // Assert
        XCTAssertEqual(viewModel.users.count, 3, "User count should match number of users")
    }
    
    func testUsersCount_ReturnsZeroForEmptyList() {
        // Arrange
        mockRepository.getAllUsersReturnValue = []
        
        // Act
        viewModel = UserListViewModel(repository: mockRepository)
        
        // Assert
        XCTAssertEqual(viewModel.users.count, 0, "User count should be zero for empty list")
    }
    
    func testUserCountText_ReturnsSingularForOneUser() {
        // Arrange
        mockRepository.getAllUsersReturnValue = [User(id: 1, name: "Solo User")]
        
        // Act
        viewModel = UserListViewModel(repository: mockRepository)
        
        // Assert
        XCTAssertEqual(viewModel.userCountText, "1 User", "Should use singular form for one user")
    }
    
    func testUserCountText_ReturnsPluralForMultipleUsers() {
        // Arrange
        mockRepository.getAllUsersReturnValue = [
            User(id: 1, name: "User 1"),
            User(id: 2, name: "User 2")
        ]
        
        // Act
        viewModel = UserListViewModel(repository: mockRepository)
        
        // Assert
        XCTAssertEqual(viewModel.userCountText, "2 Users", "Should use plural form for multiple users")
    }
    
    func testUserCountText_ReturnsPluralForZeroUsers() {
        // Arrange
        mockRepository.getAllUsersReturnValue = []
        
        // Act
        viewModel = UserListViewModel(repository: mockRepository)
        
        // Assert
        XCTAssertEqual(viewModel.userCountText, "0 Users", "Should use plural form for zero users")
    }
}
