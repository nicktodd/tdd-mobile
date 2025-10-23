//
//  TestingBestPracticesExamples.swift
//  MVVMExampleTests
//
//  Created by Nick Todd on 23/10/2025.
//

import XCTest
import Nimble
import Cuckoo
@testable import MVVMExample

/**
 * TESTING BEST PRACTICES EXAMPLES
 *
 * This file demonstrates advanced testing techniques and best practices
 * specifically for MVVM architecture with SwiftUI.
 *
 * Key concepts demonstrated:
 * 1. AAA Pattern (Arrange, Act, Assert)
 * 2. Test isolation and independence
 * 3. Mocking external dependencies
 * 4. Testing asynchronous behavior
 * 5. Testing error conditions
 * 6. Parameterized tests
 * 7. Test data builders
 * 8. Custom matchers with Nimble
 */

// MARK: - Advanced ViewModel Testing Techniques

class AdvancedViewModelTests: XCTestCase {
    
    var viewModel: UserListViewModel!
    var mockRepository: MockUserRepository!
    
    override func setUp() {
        super.setUp()
        // SETUP: Create fresh instances for each test to ensure isolation
        mockRepository = MockUserRepository()
        viewModel = UserListViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        // TEARDOWN: Clean up to prevent memory leaks and test interference
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Testing State Transitions
    
    /**
     * TESTING STATE TRANSITIONS
     *
     * This test demonstrates how to verify that the ViewModel correctly
     * transitions through different states during operations.
     */
    func testLoadUsersStateTransitions() {
        // ARRANGE
        let expectedUsers = User.mockUsers()
        stub(mockRepository) { stub in
            when(stub.getAllUsers()).thenReturn(expectedUsers)
        }
        
        // Initial state verification
        expect(self.viewModel.isLoading).to(beFalse())
        expect(self.viewModel.errorMessage).to(beNil())
        
        // ACT
        viewModel.loadUsers()
        
        // ASSERT - Verify loading state is set immediately
        expect(self.viewModel.isLoading).to(beTrue())
        expect(self.viewModel.errorMessage).to(beNil())
        
        // ASSERT - Verify final state after synchronous operation completes
        expect(self.viewModel.isLoading).to(beFalse())
        expect(self.viewModel.users).to(equal(expectedUsers))
        expect(self.viewModel.errorMessage).to(beNil())
    }
    
    // MARK: - Testing Edge Cases
    
    /**
     * TESTING EDGE CASES
     *
     * Edge cases are often where bugs hide. This test demonstrates
     * how to test boundary conditions and unusual inputs.
     */
    func testAddUserWithVariousInputFormats() {
        // Test data with different edge cases
        let testCases: [(input: String, expected: String?, shouldCallRepository: Bool)] = [
            ("Normal Name", "Normal Name", true),
            ("  Trimmed  ", "Trimmed", true),
            ("", nil, false),
            ("   ", nil, false),
            ("A", "A", true), // Single character
            (String(repeating: "X", count: 100), String(repeating: "X", count: 100), true) // Long name
        ]
        
        for (index, testCase) in testCases.enumerated() {
            // ARRANGE - Reset mock for each test case
            let newMock = MockUserRepository()
            viewModel = UserListViewModel(repository: newMock)
            
            if testCase.shouldCallRepository {
                stub(newMock) { stub in
                    when(stub.addUser(any())).then { user in
                        return User(id: index + 1, name: user.name)
                    }
                    when(stub.getAllUsers()).thenReturn([])
                }
            }
            
            viewModel.newUserName = testCase.input
            
            // ACT
            viewModel.addUser()
            
            // ASSERT
            if let expectedName = testCase.expected {
                let argumentCaptor = ArgumentCaptor<User>()
                verify(newMock).addUser(argumentCaptor.capture())
                expect(argumentCaptor.value?.name).to(equal(expectedName))
                expect(self.viewModel.errorMessage).to(beNil())
            } else {
                verifyNoMoreInteractions(newMock)
                expect(self.viewModel.errorMessage).to(contain("cannot be empty"))
            }
        }
    }
    
    // MARK: - Testing Computed Properties
    
    /**
     * TESTING COMPUTED PROPERTIES
     *
     * Computed properties often contain presentation logic that needs testing.
     * This demonstrates how to test various computed property scenarios.
     */
    func testUserCountTextVariations() {
        let testCases: [(userCount: Int, expectedText: String)] = [
            (0, "0 Users"),
            (1, "1 User"),
            (2, "2 Users"),
            (10, "10 Users"),
            (100, "100 Users")
        ]
        
        for testCase in testCases {
            // ARRANGE
            let users = (1...testCase.userCount).map { User(id: $0, name: "User \($0)") }
            viewModel.users = users
            
            // ACT & ASSERT
            expect(self.viewModel.userCountText).to(equal(testCase.expectedText))
        }
    }
    
    // MARK: - Testing Error Recovery
    
    /**
     * TESTING ERROR RECOVERY
     *
     * This test demonstrates how to verify that the ViewModel can recover
     * from error states and continue functioning normally.
     */
    func testErrorRecoveryAfterFailedOperation() {
        // ARRANGE - Set up a failing operation first
        stub(mockRepository) { stub in
            when(stub.deleteUser(withId: 1)).thenReturn(false)
            when(stub.getAllUsers()).thenReturn([])
        }
        
        // ACT - Perform failing operation
        viewModel.deleteUser(withId: 1)
        
        // ASSERT - Verify error state
        expect(self.viewModel.errorMessage).to(bePresent())
        
        // ARRANGE - Now set up successful operation
        stub(mockRepository) { stub in
            when(stub.deleteUser(withId: 2)).thenReturn(true)
            when(stub.getAllUsers()).thenReturn([])
        }
        
        // ACT - Clear error and perform successful operation
        viewModel.clearError()
        viewModel.deleteUser(withId: 2)
        
        // ASSERT - Verify recovery
        expect(self.viewModel.errorMessage).to(beNil())
        expect(self.viewModel.isLoading).to(beFalse())
    }
    
    // MARK: - Testing Interaction Patterns
    
    /**
     * TESTING METHOD CALL SEQUENCES
     *
     * This test verifies that the ViewModel calls repository methods
     * in the correct order and with the right parameters.
     */
    func testAddUserCallSequence() {
        // ARRANGE
        let expectedUser = User(id: 1, name: "Test User")
        let userList = [expectedUser]
        
        stub(mockRepository) { stub in
            when(stub.addUser(any())).thenReturn(expectedUser)
            when(stub.getAllUsers()).thenReturn([]).thenReturn(userList)
        }
        
        viewModel.newUserName = "Test User"
        
        // ACT
        viewModel.addUser()
        
        // ASSERT - Verify the sequence of calls
        let inOrder = InOrder()
        
        // First call should be to addUser
        verify(mockRepository, inOrder).addUser(any())
        
        // Then getAllUsers should be called to refresh the list
        verify(mockRepository, inOrder).getAllUsers()
        
        // Verify final state
        expect(self.viewModel.users).to(equal(userList))
        expect(self.viewModel.newUserName).to(beEmpty())
    }
}

// MARK: - Custom Nimble Matchers

/**
 * CUSTOM NIMBLE MATCHERS
 *
 * Custom matchers make tests more readable and expressive.
 * They encapsulate complex assertion logic and can be reused across tests.
 */

/// Matcher to check if a User has a specific name
func haveName(_ expectedName: String) -> Matcher<User> {
    return Matcher.define("have name <\(expectedName)>") { actualExpression, msg in
        guard let actualUser = try actualExpression.evaluate() else {
            return MatcherResult(status: .fail, message: msg.appendedBeNilHint())
        }
        
        let matches = actualUser.name == expectedName
        return MatcherResult(bool: matches, message: msg)
    }
}

/// Matcher to check if a User array contains a user with a specific ID
func containUserWithId(_ expectedId: Int) -> Matcher<[User]> {
    return Matcher.define("contain user with ID <\(expectedId)>") { actualExpression, msg in
        guard let actualUsers = try actualExpression.evaluate() else {
            return MatcherResult(status: .fail, message: msg.appendedBeNilHint())
        }
        
        let matches = actualUsers.contains { $0.id == expectedId }
        return MatcherResult(bool: matches, message: msg)
    }
}

// MARK: - Test Data Builders

/**
 * TEST DATA BUILDERS
 *
 * Builders make it easy to create test data with specific characteristics.
 * They make tests more readable and maintainable.
 */

class UserBuilder {
    private var id: Int = 1
    private var name: String = "Default User"
    
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
    
    func buildMany(_ count: Int) -> [User] {
        return (1...count).map { index in
            User(id: id + index - 1, name: "\(name) \(index)")
        }
    }
}

// MARK: - Testing with Custom Matchers and Builders

class CustomMatchersAndBuildersTests: XCTestCase {
    
    func testCustomMatchers() {
        // ARRANGE
        let user = UserBuilder()
            .withId(42)
            .withName("Alice")
            .build()
        
        let users = UserBuilder()
            .withName("User")
            .buildMany(3)
        
        // ASSERT
        expect(user).to(haveName("Alice"))
        expect(users).to(containUserWithId(1))
        expect(users).to(containUserWithId(2))
        expect(users).to(containUserWithId(3))
        expect(users).toNot(containUserWithId(99))
    }
    
    func testUserBuilder() {
        // ACT
        let simpleUser = UserBuilder().build()
        let customUser = UserBuilder()
            .withId(100)
            .withName("Custom User")
            .build()
        let multipleUsers = UserBuilder()
            .withName("Batch User")
            .buildMany(5)
        
        // ASSERT
        expect(simpleUser.id).to(equal(1))
        expect(simpleUser.name).to(equal("Default User"))
        
        expect(customUser.id).to(equal(100))
        expect(customUser.name).to(equal("Custom User"))
        
        expect(multipleUsers).to(haveCount(5))
        expect(multipleUsers[0].name).to(equal("Batch User 1"))
        expect(multipleUsers[4].name).to(equal("Batch User 5"))
    }
}