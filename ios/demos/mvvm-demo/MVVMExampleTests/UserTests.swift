//
//  UserTests.swift
//  MVVMExampleTests
//
//  Unit tests for the User model
//

import XCTest
@testable import MVVMExample

/**
 * MODEL TESTS
 *
 * These tests verify the User model behavior.
 * Models are typically simple, so we focus on:
 * - Initialization
 * - Equality
 * - Any custom logic or helper methods
 */
class UserTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testInit_SetsPropertiesCorrectly() {
        // Arrange & Act
        let user = User(id: 42, name: "Test User")
        
        // Assert
        XCTAssertEqual(user.id, 42, "ID should be set correctly")
        XCTAssertEqual(user.name, "Test User", "Name should be set correctly")
    }
    
    func testInit_HandlesEmptyName() {
        // Arrange & Act
        let user = User(id: 1, name: "")
        
        // Assert
        XCTAssertEqual(user.name, "", "Should allow empty name")
    }
    
    // MARK: - Equatable Tests
    
    func testEquatable_ReturnsTrueForIdenticalUsers() {
        // Arrange
        let user1 = User(id: 1, name: "Alice")
        let user2 = User(id: 1, name: "Alice")
        
        // Act & Assert
        XCTAssertEqual(user1, user2, "Users with same ID and name should be equal")
    }
    
    func testEquatable_ReturnsFalseForDifferentIds() {
        // Arrange
        let user1 = User(id: 1, name: "Alice")
        let user2 = User(id: 2, name: "Alice")
        
        // Act & Assert
        XCTAssertNotEqual(user1, user2, "Users with different IDs should not be equal")
    }
    
    func testEquatable_ReturnsFalseForDifferentNames() {
        // Arrange
        let user1 = User(id: 1, name: "Alice")
        let user2 = User(id: 1, name: "Bob")
        
        // Act & Assert
        XCTAssertNotEqual(user1, user2, "Users with different names should not be equal")
    }
    
    // MARK: - Identifiable Tests
    
    func testIdentifiable_UsesIdProperty() {
        // Arrange
        let user = User(id: 123, name: "Test")
        
        // Act & Assert
        XCTAssertEqual(user.id, 123, "Identifiable should use the id property")
    }
    
    // MARK: - Mock Users Factory Tests
    
    func testMockUsers_ReturnsNonEmptyArray() {
        // Act
        let users = User.mockUsers()
        
        // Assert
        XCTAssertGreaterThan(users.count, 0, "Mock users should return a non-empty array")
    }
    
    func testMockUsers_ReturnsUsersWithUniqueIds() {
        // Act
        let users = User.mockUsers()
        let ids = users.map { $0.id }
        let uniqueIds = Set(ids)
        
        // Assert
        XCTAssertEqual(uniqueIds.count, ids.count, "All mock users should have unique IDs")
    }
    
    func testMockUsers_ReturnsUsersWithNonEmptyNames() {
        // Act
        let users = User.mockUsers()
        
        // Assert
        for user in users {
            XCTAssertFalse(user.name.isEmpty, "All mock users should have non-empty names")
        }
    }
}
