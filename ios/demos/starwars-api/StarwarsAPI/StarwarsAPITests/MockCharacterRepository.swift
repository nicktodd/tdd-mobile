//
//  MockCharacterRepository.swift
//  StarwarsAPITests
//
//  Created by Nick Todd on 24/10/2025.
//

import Foundation
@testable import StarwarsAPI

/// Manual mock implementation of CharacterRepositoryProtocol for testing
/// This mock allows us to control the behavior of the repository in tests
/// without making actual network calls
class MockCharacterRepository: CharacterRepositoryProtocol {
    
    // MARK: - Mock Configuration Properties
    
    /// Set this to control what data the mock returns
    var mockCharacters: [Character] = []
    
    /// Set this to make the mock throw an error
    var shouldThrowError: Bool = false
    
    /// The specific error to throw when shouldThrowError is true
    var errorToThrow: RepositoryError = .networkError("Mock network error")
    
    /// Tracks whether fetchCharacters was called
    var fetchCharactersWasCalled: Bool = false
    
    /// Tracks how many times fetchCharacters was called
    var fetchCharactersCallCount: Int = 0
    
    /// Simulated delay in seconds (useful for testing loading states)
    var simulatedDelay: TimeInterval = 0
    
    // MARK: - CharacterRepositoryProtocol Implementation
    
    /// Mock implementation of fetchCharacters
    /// - Returns: The configured mock characters
    /// - Throws: The configured error if shouldThrowError is true
    func fetchCharacters() async throws -> [Character] {
        // Track that this method was called
        fetchCharactersWasCalled = true
        fetchCharactersCallCount += 1
        
        // Simulate network delay if configured
        if simulatedDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }
        
        // Throw error if configured to do so
        if shouldThrowError {
            throw errorToThrow
        }
        
        // Return mock data
        return mockCharacters
    }
    
    // MARK: - Helper Methods for Testing
    
    /// Resets the mock to its initial state
    func reset() {
        mockCharacters = []
        shouldThrowError = false
        errorToThrow = .networkError("Mock network error")
        fetchCharactersWasCalled = false
        fetchCharactersCallCount = 0
        simulatedDelay = 0
    }
}
