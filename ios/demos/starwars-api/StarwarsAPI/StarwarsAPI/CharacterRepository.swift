//
//  CharacterRepository.swift
//  StarwarsAPI
//
//  Created by Nick Todd on 24/10/2025.
//

import Foundation

/// Concrete implementation of CharacterRepositoryProtocol that fetches data from SWAPI
class CharacterRepository: CharacterRepositoryProtocol {
    private let baseURL = "https://swapi.dev/api/people/"
    private let urlSession: URLSession
    
    /// Initializes the repository with a URLSession
    /// - Parameter urlSession: The URLSession to use for network requests (allows injection for testing)
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    /// Fetches characters from the SWAPI endpoint
    /// This method demonstrates async/await patterns for network calls
    /// - Returns: An array of Character objects
    /// - Throws: RepositoryError for various failure conditions
    func fetchCharacters() async throws -> [Character] {
        // Validate URL
        guard let url = URL(string: baseURL) else {
            throw RepositoryError.invalidResponse
        }
        
        // Create URLRequest with timeout configuration
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        
        do {
            // Perform async network request
            // The 'async' keyword here means this function will suspend until data arrives
            let (data, response) = try await urlSession.data(for: request)
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw RepositoryError.invalidResponse
            }
            
            // Check for HTTP errors
            guard (200...299).contains(httpResponse.statusCode) else {
                throw RepositoryError.httpError(statusCode: httpResponse.statusCode)
            }
            
            // Decode JSON response
            do {
                let decoder = JSONDecoder()
                let characterResponse = try decoder.decode(CharacterResponse.self, from: data)
                return characterResponse.results
            } catch {
                // Provide detailed decoding error information
                throw RepositoryError.decodingError(error.localizedDescription)
            }
            
        } catch let error as RepositoryError {
            // Re-throw our custom errors
            throw error
        } catch let urlError as URLError {
            // Handle URLError cases (no internet, timeout, etc.)
            if urlError.code == .timedOut {
                throw RepositoryError.timeout
            } else {
                throw RepositoryError.networkError(urlError.localizedDescription)
            }
        } catch {
            // Handle any other unexpected errors
            throw RepositoryError.networkError(error.localizedDescription)
        }
    }
}
