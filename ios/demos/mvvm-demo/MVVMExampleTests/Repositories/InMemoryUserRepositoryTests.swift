//
//  InMemoryUserRepositoryTests.swift
//  MVVMExampleTests
//
//  Tests for the InMemoryUserRepository implementation
//

import XCTest
import Nimble
@testable import MVVMExample

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
class InMemoryUserRepositoryTests: XCTestCase {
    
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
