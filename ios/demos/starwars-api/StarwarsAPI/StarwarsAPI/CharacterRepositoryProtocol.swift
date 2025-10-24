//
//  CharacterRepositoryProtocol.swift
//  StarwarsAPI
//
//  Created by Nick Todd on 24/10/2025.
//

import Foundation

/// Protocol defining the contract for fetching Star Wars characters
/// This protocol enables dependency injection and makes the repository mockable for testing
protocol CharacterRepositoryProtocol {
    /// Fetches a list of Star Wars characters from the data source
    /// - Returns: An array of Character objects
    /// - Throws: RepositoryError for various failure conditions
    func fetchCharacters() async throws -> [Character]
}

/// Custom errors that can occur when fetching data from the repository
enum RepositoryError: Error, Equatable {
    case networkError(String)
    case invalidResponse
    case decodingError(String)
    case httpError(statusCode: Int)
    case timeout
    
    var localizedDescription: String {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let message):
            return "Failed to decode data: \(message)"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .timeout:
            return "Request timed out"
        }
    }
}
