//
//  User.swift
//  MVVMExample
//
//  Created by Nick Todd on 23/10/2025.
//

import Foundation

/**
 * USER MODEL
 * 
 * In the MVVM pattern, the Model represents the data and business logic of the application.
 * This User struct is a simple data model that represents a user entity with just the
 * essential properties needed for our example.
 *
 * Key characteristics of a good Model in MVVM:
 * - Contains only data and data-related logic
 * - No UI dependencies
 * - Easily testable
 * - Can be used across different ViewModels
 * - Immutable when possible (using struct instead of class)
 */
struct User: Identifiable, Equatable {
    /// Unique identifier for the user
    /// Using Int for simplicity in this educational example
    let id: Int
    
    /// The user's display name
    let name: String
    
    /**
     * Default initializer for creating a User
     * 
     * - Parameters:
     *   - id: Unique identifier for the user
     *   - name: The user's display name
     */
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: - Model Extensions for Testing

extension User {
    /**
     * Factory method for creating mock users in tests
     * This makes it easier to create test data with sensible defaults
     */
    static func mockUser(id: Int = 1, name: String = "Test User") -> User {
        return User(id: id, name: name)
    }
    
    /**
     * Factory method for creating multiple mock users
     * Useful for testing scenarios with collections of users
     */
    static func mockUsers() -> [User] {
        return [
            User(id: 1, name: "Alice Johnson"),
            User(id: 2, name: "Bob Smith"),
            User(id: 3, name: "Charlie Brown")
        ]
    }
}