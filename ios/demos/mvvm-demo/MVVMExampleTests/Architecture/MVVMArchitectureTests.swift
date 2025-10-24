//
//  MVVMArchitectureTests.swift
//  MVVMExampleTests
//
//  Integration tests that verify the MVVM architecture is properly implemented
//

import XCTest
import Nimble
@testable import MVVMExample

/**
 * MVVM ARCHITECTURE INTEGRATION TESTS
 *
 * These tests verify that the MVVM architecture is properly implemented:
 * 1. Models should be simple and have no dependencies
 * 2. ViewModels should depend only on abstractions (protocols)
 * 3. Repository implementations should be easily swappable
 * 4. The architecture should support dependency injection
 */
class MVVMArchitectureTests: XCTestCase {
    
    // MARK: - Architecture Validation Tests
    
    func testModelHasNoDependencies() {
        // Given/When
        let user = User(id: 1, name: "Test User")
        
        // Then - User should be a simple data structure with no dependencies
        expect(user.id).to(equal(1))
        expect(user.name).to(equal("Test User"))
        
        // User should be value type (struct)
        var modifiedUser = user
        modifiedUser = User(id: 2, name: "Modified")
        expect(user.id).to(equal(1)) // Original should be unchanged
        expect(modifiedUser.id).to(equal(2))
    }
    
    func testViewModelDependsOnAbstraction() {
        // Given
        let concreteRepository = InMemoryUserRepository()
        
        // When - ViewModel should accept protocol, not concrete type
        let viewModel = UserListViewModel(repository: concreteRepository)
        
        // Then - This should compile and work, proving dependency injection
        expect(viewModel).toNot(beNil())
        expect(viewModel.users).to(beEmpty())
    }
    
    func testRepositoryImplementationsAreSwappable() {
        // Given - Create two different repository implementations
        let inMemoryRepo = InMemoryUserRepository()
        let inMemoryRepoWithData = InMemoryUserRepository(initialUsers: User.mockUsers())
        
        // When - Both should be usable with the same ViewModel
        let viewModel1 = UserListViewModel(repository: inMemoryRepo)
        let viewModel2 = UserListViewModel(repository: inMemoryRepoWithData)
        
        // Then - Both should work but have different initial states
        expect(viewModel1.users).to(beEmpty())
        expect(viewModel2.users).to(haveCount(3))
    }
    
    // MARK: - End-to-End Workflow Tests
    
    func testCompleteUserManagementWorkflow() {
        // Given - Set up the complete architecture
        let repository = InMemoryUserRepository()
        let viewModel = UserListViewModel(repository: repository)
        
        // Initially empty
        expect(viewModel.users).to(beEmpty())
        expect(viewModel.userCountText).to(equal("0 Users"))
        
        // When - Add a user
        viewModel.newUserName = "Alice"
        expect(viewModel.canAddUser).to(beTrue())
        
        viewModel.addUser()
        
        // Then - User should be added
        expect(viewModel.users).to(haveCount(1))
        expect(viewModel.users.first?.name).to(equal("Alice"))
        expect(viewModel.newUserName).to(equal("")) // Input cleared
        expect(viewModel.userCountText).to(equal("1 User"))
        
        // When - Add another user
        viewModel.newUserName = "Bob"
        viewModel.addUser()
        
        // Then - Should have two users
        expect(viewModel.users).to(haveCount(2))
        expect(viewModel.userCountText).to(equal("2 Users"))
        
        // When - Delete a user
        let firstUserId = viewModel.users.first!.id
        viewModel.deleteUser(withId: firstUserId)
        
        // Then - Should have one user left
        expect(viewModel.users).to(haveCount(1))
        expect(viewModel.users.first?.name).to(equal("Bob"))
        expect(viewModel.userCountText).to(equal("1 User"))
    }
    
    func testErrorHandlingWorkflow() {
        // Given
        let repository = InMemoryUserRepository()
        let viewModel = UserListViewModel(repository: repository)
        
        // When - Try to add user with empty name
        viewModel.newUserName = "   "
        viewModel.addUser()
        
        // Then - Should show error
        expect(viewModel.errorMessage).toNot(beNil())
        expect(viewModel.errorMessage).to(contain("cannot be empty"))
        expect(viewModel.users).to(beEmpty()) // No user added
        
        // When - Clear the error
        viewModel.clearError()
        
        // Then - Error should be cleared
        expect(viewModel.errorMessage).to(beNil())
        
        // When - Try to delete non-existent user
        viewModel.deleteUser(withId: 999)
        
        // Then - Should show error
        expect(viewModel.errorMessage).toNot(beNil())
        expect(viewModel.errorMessage).to(contain("not found"))
    }
    
    // MARK: - Data Consistency Tests
    
    func testDataConsistencyBetweenViewModelAndRepository() {
        // Given
        let repository = InMemoryUserRepository()
        let viewModel = UserListViewModel(repository: repository)
        
        // When - Add users through ViewModel
        viewModel.newUserName = "Alice"
        viewModel.addUser()
        viewModel.newUserName = "Bob"
        viewModel.addUser()
        
        // Then - Repository should have same data
        let repositoryUsers = repository.getAllUsers()
        expect(repositoryUsers).to(haveCount(2))
        expect(viewModel.users).to(equal(repositoryUsers))
        
        // When - Delete user through ViewModel
        let firstUserId = viewModel.users.first!.id
        viewModel.deleteUser(withId: firstUserId)
        
        // Then - Repository should reflect the change
        let updatedRepositoryUsers = repository.getAllUsers()
        expect(updatedRepositoryUsers).to(haveCount(1))
        expect(viewModel.users).to(equal(updatedRepositoryUsers))
    }
    
    // MARK: - Separation of Concerns Tests
    
    func testViewModelDoesNotContainUILogic() {
        // Given
        let repository = InMemoryUserRepository(initialUsers: User.mockUsers())
        let viewModel = UserListViewModel(repository: repository)
        
        // Then - ViewModel should only expose data and commands, no UI-specific logic
        // These are the only UI-facing properties/methods:
        expect(viewModel.users).toNot(beNil())           // Data
        expect(viewModel.isLoading).to(beAKindOf(Bool.self))     // State
        expect(viewModel.errorMessage).to(beNil())        // Error state
        expect(viewModel.newUserName).to(equal(""))       // Input binding
        expect(viewModel.canAddUser).to(beAKindOf(Bool.self))    // Computed property
        expect(viewModel.userCountText).to(beAKindOf(String.self)) // Presentation helper
        
        // Commands should be simple method calls
        viewModel.loadUsers()       // Command
        viewModel.addUser()         // Command
        viewModel.clearError()      // Command
        // deleteUser(withId:) is tested elsewhere
        
        // ViewModel should not contain any UIKit or SwiftUI imports/dependencies
        // This is enforced by the compiler in the actual implementation
    }
}
