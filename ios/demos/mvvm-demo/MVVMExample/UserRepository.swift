//
//  UserRepository.swift
//  MVVMExample
//
//  Created by Nick Todd on 23/10/2025.
//

import Foundation

/**
 * USER REPOSITORY PROTOCOL
 *
 * The Repository pattern provides an abstraction layer between the ViewModel and data storage.
 * This protocol defines the contract for user data operations.
 *
 * Benefits of using a protocol for the repository:
 * 1. TESTABILITY: Easy to mock for unit tests
 * 2. FLEXIBILITY: Can swap implementations (in-memory, Core Data, network, etc.)
 * 3. DEPENDENCY INVERSION: Higher-level modules don't depend on concrete implementations
 * 4. SINGLE RESPONSIBILITY: Separates data access logic from business logic
 */

// MARK: - AutoMockable
protocol UserRepositoryProtocol {
    /**
     * Retrieves all users from the data source
     * - Returns: Array of all users
     */
    func getAllUsers() -> [User]
    
    /**
     * Retrieves a specific user by their ID
     * - Parameter id: The unique identifier of the user
     * - Returns: The user if found, nil otherwise
     */
    func getUserById(_ id: Int) -> User?
    
    /**
     * Adds a new user to the data source
     * - Parameter user: The user to add
     * - Returns: The added user (may include generated ID)
     */
    func addUser(_ user: User) -> User
    
    /**
     * Removes a user from the data source
     * - Parameter id: The unique identifier of the user to remove
     * - Returns: true if the user was successfully removed, false otherwise
     */
    func deleteUser(withId id: Int) -> Bool
    
    /**
     * Updates an existing user in the data source
     * - Parameter user: The user with updated information
     * - Returns: The updated user if successful, nil if user not found
     */
    func updateUser(_ user: User) -> User?
}

/**
 * IN-MEMORY USER REPOSITORY
 *
 * This is a concrete implementation of UserRepositoryProtocol that stores users in memory.
 * Perfect for examples, prototypes, and testing scenarios.
 *
 * Key characteristics:
 * - Thread-safe operations (using private queues if needed in real apps)
 * - Auto-incrementing IDs for new users
 * - Simple CRUD operations
 * - Data persists only during app lifetime
 */
class InMemoryUserRepository: UserRepositoryProtocol {
    
    // MARK: - Private Properties
    
    /// Internal storage for users - private to ensure encapsulation
    private var users: [User] = []
    
    /// Counter for generating unique IDs - private to prevent external manipulation
    private var nextId: Int = 1
    
    // MARK: - Initializer
    
    /**
     * Initializes the repository with optional seed data
     * - Parameter initialUsers: Optional array of users to populate the repository
     */
    init(initialUsers: [User] = []) {
        // Copy the users array
        self.users = []
        for user in initialUsers {
            self.users.append(user)
        }
        
        // Set nextId to be one higher than the highest existing ID
        var maxId = 0
        for user in self.users {
            if user.id > maxId {
                maxId = user.id
            }
        }
        self.nextId = maxId + 1
    }
    
    // MARK: - UserRepositoryProtocol Implementation
    
    func getAllUsers() -> [User] {
        return users
    }
    
    func getUserById(_ id: Int) -> User? {
        return users.first { $0.id == id }
    }
    
    func addUser(_ user: User) -> User {
        // Create a new user with auto-generated ID
        let newUser = User(id: nextId, name: user.name)
        users.append(newUser)
        nextId += 1
        return newUser
    }
    
    func deleteUser(withId id: Int) -> Bool {
        if let index = users.firstIndex(where: { $0.id == id }) {
            users.remove(at: index)
            return true
        }
        return false
    }
    
    func updateUser(_ user: User) -> User? {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            return user
        }
        return nil
    }
}

// MARK: - Repository Extensions for Testing

extension InMemoryUserRepository {
    /**
     * Convenience method for testing - gets the count of users
     * This helps in assertions without exposing the internal users array
     */
    var userCount: Int {
        return users.count
    }
    
    /**
     * Testing helper to reset the repository to empty state
     * Useful for setting up clean test conditions
     */
    func clearAllUsers() {
        users.removeAll()
        nextId = 1
    }
}