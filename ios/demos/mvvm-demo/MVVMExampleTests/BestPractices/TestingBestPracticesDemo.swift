//
//  TestingBestPracticesDemo.swift
//  MVVMExampleTests
//
//  Demonstrates testing best practices and common patterns
//

import XCTest
import Nimble
import Cuckoo
@testable import MVVMExample

/**
 * TESTING BEST PRACTICES DEMONSTRATION
 *
 * This file demonstrates various testing best practices:
 * 1. Using test doubles (mocks, stubs, fakes)
 * 2. Testing asynchronous code
 * 3. Testing error conditions
 * 4. Parameterized tests
 * 5. Testing edge cases
 * 6. Proper test organization
 */
class TestingBestPracticesDemo: XCTestCase {
    
    // MARK: - Test Data Builders
    
    /// Example of using the Builder pattern for test data
    class UserBuilder {
        private var id: Int = 1
        private var name: String = "Test User"
        
        func withId(_ id: Int) -> UserBuilder {
            self.id = id
            return self
        }
        
        func withName(_ name: String) -> UserBuilder {
            self.name = name
            return self
        }
        
        func build() -> User {
            return User(id: id, name: name)
        }
    }
    
    func testUserBuilderPattern() {
        // Given
        let user = UserBuilder()
            .withId(42)
            .withName("Alice")
            .build()
        
        // Then
        expect(user.id).to(equal(42))
        expect(user.name).to(equal("Alice"))
    }
    
    // MARK: - Parameterized Tests
    
    func testUserCountTextForVariousCounts() {
        let testCases = [
            (count: 0, expected: "0 Users"),
            (count: 1, expected: "1 User"),
            (count: 2, expected: "2 Users"),
            (count: 5, expected: "5 Users"),
            (count: 100, expected: "100 Users")
        ]
        
        let mockRepository = MockUserRepositoryProtocol()
        stub(mockRepository) { stub in
            when(stub.getAllUsers()).thenReturn([])
        }
        
        let viewModel = UserListViewModel(repository: mockRepository)
        
        for testCase in testCases {
            // Given
            let users = (0..<testCase.count).map { User(id: $0, name: "User \($0)") }
            viewModel.users = users
            
            // Then
            expect(viewModel.userCountText).to(equal(testCase.expected),
                                             description: "Failed for count: \(testCase.count)")
        }
    }
    
    // MARK: - Edge Cases Testing
    
    func testEdgeCasesForUserNames() {
        let mockRepository = MockUserRepositoryProtocol()
        stub(mockRepository) { stub in
            when(stub.getAllUsers()).thenReturn([])
        }
        
        let viewModel = UserListViewModel(repository: mockRepository)
        
        let edgeCaseNames = [
            "",           // Empty string
            " ",          // Single space
            "   ",        // Multiple spaces
            "\n",         // Newline
            "\t",         // Tab
            "a",          // Single character
            String(repeating: "a", count: 1000) // Very long name
        ]
        
        for name in edgeCaseNames {
            // Given
            viewModel.newUserName = name
            viewModel.isLoading = false
            
            // When/Then
            let canAdd = viewModel.canAddUser
            let trimmedIsEmpty = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            expect(canAdd).to(equal(!trimmedIsEmpty),
                           description: "Failed for name: '\(name)'")
        }
    }
    
    // MARK: - Error Condition Testing
    
    func testRepositoryErrorHandling() {
        // This demonstrates how you might test error conditions
        // if your repository threw errors instead of returning optionals
        
        let mockRepository = MockUserRepositoryProtocol()
        
        // Simulate a repository that fails
        stub(mockRepository) { stub in
            when(stub.getAllUsers()).thenReturn([])
            when(stub.deleteUser(withId: any())).thenReturn(false)
        }
        
        let viewModel = UserListViewModel(repository: mockRepository)
        
        // When
        viewModel.deleteUser(withId: 1)
        
        // Then
        expect(viewModel.errorMessage).toNot(beNil())
        expect(viewModel.errorMessage).to(contain("Failed to delete"))
    }
    
    // MARK: - Testing State Transitions
    
    func testLoadingStateTransitions() {
        let mockRepository = MockUserRepositoryProtocol()
        stub(mockRepository) { stub in
            when(stub.getAllUsers()).thenReturn(User.mockUsers())
        }
        
        let viewModel = UserListViewModel(repository: mockRepository)
        
        // Initial state after loading
        expect(viewModel.isLoading).to(beFalse())
        expect(viewModel.users).toNot(beEmpty())
        expect(viewModel.errorMessage).to(beNil())
        
        // When loading again
        viewModel.loadUsers()
        
        // Should transition through loading state
        expect(viewModel.isLoading).to(beTrue())
        
        // Eventually should complete
        expect(viewModel.isLoading).toEventually(beFalse(), timeout: .seconds(1))
    }
    
    // MARK: - Custom Matchers Example
    
    /// Custom Nimble matcher for checking if a User has valid properties
    func beAValidUser() -> Predicate<User> {
        return Predicate.define("be a valid user") { actualExpression, message in
            guard let user = try actualExpression.evaluate() else {
                return PredicateResult(status: .fail, message: message.appendedBeNilHint())
            }
            
            let hasValidId = user.id > 0
            let hasValidName = !user.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let isValid = hasValidId && hasValidName
            
            return PredicateResult(
                bool: isValid,
                message: message.appended(details: "User(id: \(user.id), name: '\(user.name)')")
            )
        }
    }
    
    func testCustomMatcher() {
        // Given
        let validUser = User(id: 1, name: "Valid User")
        let invalidUser1 = User(id: 0, name: "Invalid ID")
        let invalidUser2 = User(id: 1, name: "")
        
        // Then
        expect(validUser).to(beAValidUser())
        expect(invalidUser1).toNot(beAValidUser())
        expect(invalidUser2).toNot(beAValidUser())
    }
}
