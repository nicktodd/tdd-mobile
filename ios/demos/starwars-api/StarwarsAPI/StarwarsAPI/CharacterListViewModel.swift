//
//  CharacterListViewModel.swift
//  StarwarsAPI
//
//  Created by Nick Todd on 24/10/2025.
//

import Foundation
import Combine

/// ViewModel for managing the character list state and business logic
/// Uses @MainActor to ensure all UI updates happen on the main thread
@MainActor
class CharacterListViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Array of characters to display in the UI
    /// @Published automatically notifies SwiftUI views when this changes
    @Published var characters: [Character] = []
    
    /// Filtered characters based on search query
    @Published var filteredCharacters: [Character] = []
    
    /// Current search query text
    @Published var searchText: String = "" {
        didSet {
            filterCharacters()
        }
    }
    
    /// Loading state indicator for the UI
    @Published var isLoading: Bool = false
    
    /// Error message to display to the user
    @Published var errorMessage: String?
    
    /// Flag indicating whether an error occurred
    @Published var hasError: Bool = false
    
    // MARK: - Dependencies
    
    /// Repository for fetching character data
    /// Using a protocol allows us to inject a mock for testing
    private let repository: CharacterRepositoryProtocol
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with a repository
    /// - Parameter repository: The repository to use for data fetching (defaults to real implementation)
    init(repository: CharacterRepositoryProtocol = CharacterRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    /// Fetches characters from the repository
    /// This is an async function that can be called from SwiftUI's .task modifier
    func loadCharacters() async {
        // Reset error state
        hasError = false
        errorMessage = nil
        isLoading = true
        
        do {
            // Await the async repository call
            // The function suspends here until data arrives or an error occurs
            let fetchedCharacters = try await repository.fetchCharacters()
            
            // Update the published properties
            // These updates will trigger UI refreshes in SwiftUI
            self.characters = fetchedCharacters
            self.filteredCharacters = fetchedCharacters
            self.isLoading = false
            
        } catch let error as RepositoryError {
            // Handle our custom repository errors
            handleError(error)
        } catch {
            // Handle any unexpected errors
            handleError(RepositoryError.networkError(error.localizedDescription))
        }
    }
    
    /// Filters characters based on the current search text
    private func filterCharacters() {
        if searchText.isEmpty {
            filteredCharacters = characters
        } else {
            filteredCharacters = characters.filter { character in
                character.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    /// Handles errors by setting appropriate state
    /// - Parameter error: The RepositoryError that occurred
    private func handleError(_ error: RepositoryError) {
        self.isLoading = false
        self.hasError = true
        self.errorMessage = error.localizedDescription
    }
}
