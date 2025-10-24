//
//  CharacterListViewModelTests.swift
//  StarwarsAPITests
//
//  Created by Nick Todd on 24/10/2025.
//

import XCTest
@testable import StarwarsAPI

/// Tests for CharacterListViewModel
/// These tests demonstrate async testing with manual mocks and testing UI state changes
@MainActor
final class CharacterListViewModelTests: XCTestCase {
    
    var viewModel: CharacterListViewModel!
    var mockRepository: MockCharacterRepository!
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        
        // Create a mock repository
        mockRepository = MockCharacterRepository()
        
        // Inject the mock into our ViewModel
        // This is the key to testing: we control the repository's behavior
        viewModel = CharacterListViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Test: Successful Character Loading
    
    /// Tests that the ViewModel successfully loads characters and updates its state
    ///
    /// Purpose: Demonstrates testing async ViewModel operations with mocked dependencies
    ///
    /// Key concepts:
    /// 1. We use @MainActor on the test class because ViewModels update UI state
    /// 2. Test functions are marked 'async' to use await
    /// 3. We verify state changes at different points in the async operation
    /// 4. Mock repositories let us control exactly what data is returned
    func testLoadCharactersSuccess() async {
        // GIVEN: Mock repository configured with test data
        let mockCharacters = [
            Character(
                name: "Luke Skywalker",
                height: "172",
                mass: "77",
                hairColor: "blond",
                skinColor: "fair",
                eyeColor: "blue",
                birthYear: "19BBY",
                gender: "male",
                url: "https://swapi.dev/api/people/1/"
            ),
            Character(
                name: "Darth Vader",
                height: "202",
                mass: "136",
                hairColor: "none",
                skinColor: "white",
                eyeColor: "yellow",
                birthYear: "41.9BBY",
                gender: "male",
                url: "https://swapi.dev/api/people/4/"
            )
        ]
        
        mockRepository.mockCharacters = mockCharacters
        mockRepository.shouldThrowError = false
        
        // Verify initial state
        XCTAssertTrue(viewModel.characters.isEmpty, "Characters should initially be empty")
        XCTAssertFalse(viewModel.isLoading, "Should not be loading initially")
        XCTAssertFalse(viewModel.hasError, "Should not have error initially")
        
        // WHEN: We call loadCharacters
        // Note: This is an async function, so we await it
        await viewModel.loadCharacters()
        
        // THEN: ViewModel state should be updated correctly
        XCTAssertEqual(viewModel.characters.count, 2, "Should have 2 characters")
        XCTAssertEqual(viewModel.characters[0].name, "Luke Skywalker", "First character should be Luke")
        XCTAssertEqual(viewModel.characters[1].name, "Darth Vader", "Second character should be Vader")
        
        // Verify filtered characters are also set
        XCTAssertEqual(viewModel.filteredCharacters.count, 2, "Filtered characters should match")
        
        // Verify loading and error states
        XCTAssertFalse(viewModel.isLoading, "Should not be loading after completion")
        XCTAssertFalse(viewModel.hasError, "Should not have error on success")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil on success")
        
        // Verify the mock was called
        XCTAssertTrue(mockRepository.fetchCharactersWasCalled, "Repository should have been called")
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 1, "Repository should be called exactly once")
    }
    
    // MARK: - Test: Network Error Handling
    
    /// Tests that the ViewModel properly handles network errors
    ///
    /// Purpose: Demonstrates testing error conditions in async ViewModel code
    ///
    /// Key concepts:
    /// 1. Mock repositories can be configured to throw specific errors
    /// 2. We verify that error state is properly set in the ViewModel
    /// 3. Loading state should be false after an error
    /// 4. Error messages should be user-friendly
    func testLoadCharactersNetworkError() async {
        // GIVEN: Mock repository configured to throw a network error
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = .networkError("No internet connection")
        
        // WHEN: We try to load characters
        await viewModel.loadCharacters()
        
        // THEN: Error state should be set appropriately
        XCTAssertTrue(viewModel.hasError, "Should have error flag set")
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set")
        XCTAssertEqual(viewModel.errorMessage, "Network error: No internet connection",
                      "Error message should match the thrown error")
        
        // Characters should be empty on error
        XCTAssertTrue(viewModel.characters.isEmpty, "Characters should be empty on error")
        XCTAssertTrue(viewModel.filteredCharacters.isEmpty, "Filtered characters should be empty on error")
        
        // Loading should be false
        XCTAssertFalse(viewModel.isLoading, "Should not be loading after error")
        
        // Repository should have been called
        XCTAssertTrue(mockRepository.fetchCharactersWasCalled, "Repository should have been called")
    }
    
    // MARK: - Test: HTTP Error Handling
    
    /// Tests handling of HTTP errors (like 404 or 500)
    ///
    /// Purpose: Shows how to test different error types with async/await
    func testLoadCharactersHTTPError() async {
        // GIVEN: Mock repository configured to throw HTTP error
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = .httpError(statusCode: 404)
        
        // WHEN: We load characters
        await viewModel.loadCharacters()
        
        // THEN: Error state should reflect HTTP error
        XCTAssertTrue(viewModel.hasError, "Should have error")
        XCTAssertEqual(viewModel.errorMessage, "HTTP error with status code: 404",
                      "Error message should indicate HTTP status code")
        XCTAssertFalse(viewModel.isLoading, "Should not be loading")
    }
    
    // MARK: - Test: Timeout Error Handling
    
    /// Tests handling of timeout errors
    ///
    /// Purpose: Demonstrates testing specific error conditions
    func testLoadCharactersTimeoutError() async {
        // GIVEN: Mock configured to throw timeout error
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = .timeout
        
        // WHEN: We load characters
        await viewModel.loadCharacters()
        
        // THEN: Should show timeout error
        XCTAssertTrue(viewModel.hasError, "Should have error")
        XCTAssertEqual(viewModel.errorMessage, "Request timed out", "Should show timeout message")
    }
    
    // MARK: - Test: Decoding Error Handling
    
    /// Tests handling of JSON decoding errors
    ///
    /// Purpose: Shows how ViewModels should handle malformed data
    func testLoadCharactersDecodingError() async {
        // GIVEN: Mock configured to throw decoding error
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = .decodingError("Invalid JSON format")
        
        // WHEN: We load characters
        await viewModel.loadCharacters()
        
        // THEN: Should show decoding error
        XCTAssertTrue(viewModel.hasError, "Should have error")
        XCTAssertEqual(viewModel.errorMessage, "Failed to decode data: Invalid JSON format",
                      "Should show decoding error message")
    }
    
    // MARK: - Test: Search Functionality
    
    /// Tests the search/filter functionality
    ///
    /// Purpose: Demonstrates testing synchronous state changes alongside async operations
    ///
    /// Key concepts:
    /// 1. First we load data (async operation)
    /// 2. Then we test filtering (synchronous property change)
    /// 3. We verify that filteredCharacters updates when searchText changes
    func testSearchFiltering() async {
        // GIVEN: ViewModel with loaded characters
        mockRepository.mockCharacters = [
            Character(name: "Luke Skywalker", height: "172", mass: "77",
                     hairColor: "blond", skinColor: "fair", eyeColor: "blue",
                     birthYear: "19BBY", gender: "male",
                     url: "https://swapi.dev/api/people/1/"),
            Character(name: "Darth Vader", height: "202", mass: "136",
                     hairColor: "none", skinColor: "white", eyeColor: "yellow",
                     birthYear: "41.9BBY", gender: "male",
                     url: "https://swapi.dev/api/people/4/"),
            Character(name: "Leia Organa", height: "150", mass: "49",
                     hairColor: "brown", skinColor: "light", eyeColor: "brown",
                     birthYear: "19BBY", gender: "female",
                     url: "https://swapi.dev/api/people/5/")
        ]
        
        await viewModel.loadCharacters()
        
        // Initially, all characters should be shown
        XCTAssertEqual(viewModel.filteredCharacters.count, 3, "Should show all characters initially")
        
        // WHEN: We set a search text for "Luke"
        viewModel.searchText = "Luke"
        
        // THEN: Only matching characters should be in filteredCharacters
        XCTAssertEqual(viewModel.filteredCharacters.count, 1, "Should filter to 1 character")
        XCTAssertEqual(viewModel.filteredCharacters[0].name, "Luke Skywalker",
                      "Filtered character should be Luke")
        
        // WHEN: We search for "vader" (case-insensitive)
        viewModel.searchText = "vader"
        
        // THEN: Should find Darth Vader
        XCTAssertEqual(viewModel.filteredCharacters.count, 1, "Should filter to 1 character")
        XCTAssertEqual(viewModel.filteredCharacters[0].name, "Darth Vader",
                      "Should find Vader with case-insensitive search")
        
        // WHEN: We clear the search
        viewModel.searchText = ""
        
        // THEN: All characters should be shown again
        XCTAssertEqual(viewModel.filteredCharacters.count, 3, "Should show all characters when search is cleared")
    }
    
    // MARK: - Test: Search with No Results
    
    /// Tests search when no characters match
    ///
    /// Purpose: Ensures edge cases are handled correctly
    func testSearchNoResults() async {
        // GIVEN: ViewModel with loaded characters
        mockRepository.mockCharacters = [
            Character(name: "Luke Skywalker", height: "172", mass: "77",
                     hairColor: "blond", skinColor: "fair", eyeColor: "blue",
                     birthYear: "19BBY", gender: "male",
                     url: "https://swapi.dev/api/people/1/")
        ]
        
        await viewModel.loadCharacters()
        
        // WHEN: We search for something that doesn't exist
        viewModel.searchText = "Yoda"
        
        // THEN: Filtered characters should be empty
        XCTAssertTrue(viewModel.filteredCharacters.isEmpty,
                     "Should have no filtered characters when search doesn't match")
        
        // But original characters should still be there
        XCTAssertEqual(viewModel.characters.count, 1,
                      "Original characters array should not be affected by search")
    }
    
    // MARK: - Test: Empty Results from API
    
    /// Tests handling of empty results from the API
    ///
    /// Purpose: Shows how to test edge cases where API returns no data
    func testLoadCharactersEmptyResults() async {
        // GIVEN: Mock configured to return empty array
        mockRepository.mockCharacters = []
        mockRepository.shouldThrowError = false
        
        // WHEN: We load characters
        await viewModel.loadCharacters()
        
        // THEN: Should not be an error, just empty
        XCTAssertFalse(viewModel.hasError, "Empty results should not be an error")
        XCTAssertTrue(viewModel.characters.isEmpty, "Characters should be empty")
        XCTAssertTrue(viewModel.filteredCharacters.isEmpty, "Filtered characters should be empty")
        XCTAssertFalse(viewModel.isLoading, "Should not be loading")
    }
    
    // MARK: - Test: Multiple Loads
    
    /// Tests that multiple consecutive loads work correctly
    ///
    /// Purpose: Demonstrates testing scenarios where async operations are called multiple times
    ///
    /// Why this matters: Users might trigger refresh multiple times,
    /// and we need to ensure state is properly managed
    func testMultipleLoadCharactersCalls() async {
        // GIVEN: Mock with initial data
        mockRepository.mockCharacters = [
            Character(name: "Luke Skywalker", height: "172", mass: "77",
                     hairColor: "blond", skinColor: "fair", eyeColor: "blue",
                     birthYear: "19BBY", gender: "male",
                     url: "https://swapi.dev/api/people/1/")
        ]
        
        // WHEN: We load characters multiple times
        await viewModel.loadCharacters()
        XCTAssertEqual(viewModel.characters.count, 1, "First load should have 1 character")
        
        // Change mock data
        mockRepository.mockCharacters = [
            Character(name: "Darth Vader", height: "202", mass: "136",
                     hairColor: "none", skinColor: "white", eyeColor: "yellow",
                     birthYear: "41.9BBY", gender: "male",
                     url: "https://swapi.dev/api/people/4/"),
            Character(name: "Leia Organa", height: "150", mass: "49",
                     hairColor: "brown", skinColor: "light", eyeColor: "brown",
                     birthYear: "19BBY", gender: "female",
                     url: "https://swapi.dev/api/people/5/")
        ]
        
        await viewModel.loadCharacters()
        
        // THEN: Should have updated data
        XCTAssertEqual(viewModel.characters.count, 2, "Second load should have 2 characters")
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 2,
                      "Repository should have been called twice")
    }
    
    // MARK: - Test: Error Recovery
    
    /// Tests that the ViewModel can recover from an error state
    ///
    /// Purpose: Demonstrates testing state transitions: success -> error -> success
    ///
    /// Why this matters: After an error, users should be able to retry and succeed
    func testErrorRecovery() async {
        // GIVEN: First load succeeds
        mockRepository.mockCharacters = [
            Character(name: "Luke Skywalker", height: "172", mass: "77",
                     hairColor: "blond", skinColor: "fair", eyeColor: "blue",
                     birthYear: "19BBY", gender: "male",
                     url: "https://swapi.dev/api/people/1/")
        ]
        
        await viewModel.loadCharacters()
        XCTAssertFalse(viewModel.hasError, "Initial load should succeed")
        XCTAssertEqual(viewModel.characters.count, 1, "Should have 1 character")
        
        // WHEN: Second load fails
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = .networkError("Connection lost")
        
        await viewModel.loadCharacters()
        XCTAssertTrue(viewModel.hasError, "Should have error after failed load")
        
        // WHEN: Third load succeeds (recovery)
        mockRepository.shouldThrowError = false
        mockRepository.mockCharacters = [
            Character(name: "Darth Vader", height: "202", mass: "136",
                     hairColor: "none", skinColor: "white", eyeColor: "yellow",
                     birthYear: "41.9BBY", gender: "male",
                     url: "https://swapi.dev/api/people/4/")
        ]
        
        await viewModel.loadCharacters()
        
        // THEN: Should recover from error state
        XCTAssertFalse(viewModel.hasError, "Error state should be cleared on successful load")
        XCTAssertNil(viewModel.errorMessage, "Error message should be cleared")
        XCTAssertEqual(viewModel.characters.count, 1, "Should have new data")
    }
}
