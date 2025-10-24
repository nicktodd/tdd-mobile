//
//  UserTests.swift
//  MVVMExampleTests
//
//  Tests for the User model
//

import XCTest
import Nimble
@testable import MVVMExample

/**
 * USER MODEL TESTS
 *
 * These tests verify the User model behaves correctly.
 * Since it's a simple struct, we mainly test:
 * - Initialization
 * - Equatable conformance
 * - Test helper methods
 */
class UserTests: XCTestCase {
    
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
