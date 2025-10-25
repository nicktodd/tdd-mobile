//
//  CharacterRepositoryTests.swift
//  StarwarsAPITests
//
//  Created by Nick Todd on 24/10/2025.
//

import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import StarwarsAPI

/// Tests for CharacterRepository
/// These tests demonstrate asynchronous testing patterns and error condition testing
/// without making actual network calls (we'll use URLProtocol mocking)
final class CharacterRepositoryTests: XCTestCase {
    var repository: CharacterRepository!
    var urlSession: URLSession!

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
    HTTPStubs.removeAllStubs()
        urlSession = URLSession(configuration: configuration)
        repository = CharacterRepository(urlSession: urlSession)
    }

    override func tearDown() {
        repository = nil
        urlSession = nil
    HTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    // MARK: - Test: Successful Data Fetch
    
    /// Tests that the repository successfully fetches and decodes character data
    ///
    /// Purpose: Demonstrates async/await testing pattern for successful API calls
    ///
    /// Key async testing concepts:
    /// 1. Use 'await' keyword to call async functions in tests
    /// 2. Test functions must be marked 'async' to use await
    /// 3. XCTest automatically waits for async operations to complete
    /// 4. No need for XCTestExpectation in modern async/await tests
    func testFetchCharactersSuccess() async throws {
        // GIVEN: Stub API response with valid character data using OHHTTPStubs
        let mockJSON = """
        {
            "count": 2,
            "next": null,
            "previous": null,
            "results": [
                {
                    "name": "Luke Skywalker",
                    "height": "172",
                    "mass": "77",
                    "hair_color": "blond",
                    "skin_color": "fair",
                    "eye_color": "blue",
                    "birth_year": "19BBY",
                    "gender": "male",
                    "url": "https://swapi.dev/api/people/1/"
                },
                {
                    "name": "C-3PO",
                    "height": "167",
                    "mass": "75",
                    "hair_color": "n/a",
                    "skin_color": "gold",
                    "eye_color": "yellow",
                    "birth_year": "112BBY",
                    "gender": "n/a",
                    "url": "https://swapi.dev/api/people/2/"
                }
            ]
        }
        """
        let mockData = mockJSON.data(using: .utf8)!
        stub(condition: isHost("swapi.dev")) { _ in
            HTTPStubsResponse(data: mockData, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        // WHEN: We call the async fetchCharacters method
        let characters = try await repository.fetchCharacters()

        // THEN: We should get the expected characters
        XCTAssertEqual(characters.count, 2, "Should return 2 characters")
        XCTAssertEqual(characters[0].name, "Luke Skywalker", "First character should be Luke")
        XCTAssertEqual(characters[1].name, "C-3PO", "Second character should be C-3PO")
    }
    
    // MARK: - Test: Network Error
    
    /// Tests that the repository properly handles network errors
    ///
    /// Purpose: Demonstrates testing async error conditions
    ///
    /// Key concepts:
    /// 1. Use 'await' with 'XCTAssertThrowsError' for async throwing functions
    /// 2. We can inspect the thrown error to verify it's the correct type
    /// 3. Network errors are converted to our custom RepositoryError
    func testFetchCharactersNetworkError() async {
        // GIVEN: Stub a network error using OHHTTPStubs
        stub(condition: isHost("swapi.dev")) { _ in
            let error = URLError(.notConnectedToInternet)
            return HTTPStubsResponse(error: error)
        }

        // WHEN/THEN: Should throw a network error
        await XCTAssertThrowsErrorAsync(
            try await repository.fetchCharacters(),
            "Should throw an error when network fails"
        ) { error in
            guard case RepositoryError.networkError = error else {
                XCTFail("Expected RepositoryError.networkError, got \(error)")
                return
            }
        }
    }
    
    // MARK: - Test: HTTP Error (404)
    
    /// Tests that the repository handles HTTP error responses correctly
    ///
    /// Purpose: Demonstrates testing HTTP error codes with async/await
    ///
    /// Why this matters: APIs return different status codes for different errors
    /// (404 Not Found, 500 Server Error, etc.) and we need to handle them appropriately
    func testFetchCharactersHTTPError404() async {
        // GIVEN: Stub a 404 Not Found response
        stub(condition: isHost("swapi.dev")) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        // WHEN/THEN: Should throw an HTTP error
        await XCTAssertThrowsErrorAsync(
            try await repository.fetchCharacters(),
            "Should throw HTTP error for 404"
        ) { error in
            guard case RepositoryError.httpError(let statusCode) = error else {
                XCTFail("Expected RepositoryError.httpError, got \(error)")
                return
            }
            XCTAssertEqual(statusCode, 404, "Status code should be 404")
        }
    }
    
    // MARK: - Test: HTTP Error (500)
    
    /// Tests server error handling (500 Internal Server Error)
    ///
    /// Purpose: Shows how to test different HTTP status codes
    func testFetchCharactersHTTPError500() async {
        // GIVEN: Stub a 500 server error response
        stub(condition: isHost("swapi.dev")) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 500, headers: nil)
        }

        // WHEN/THEN: Should throw an HTTP error with status 500
        await XCTAssertThrowsErrorAsync(
            try await repository.fetchCharacters(),
            "Should throw HTTP error for 500"
        ) { error in
            guard case RepositoryError.httpError(let statusCode) = error else {
                XCTFail("Expected RepositoryError.httpError, got \(error)")
                return
            }
            XCTAssertEqual(statusCode, 500, "Status code should be 500")
        }
    }
    
    // MARK: - Test: Invalid/Malformed JSON
    
    /// Tests that the repository handles malformed JSON appropriately
    ///
    /// Purpose: Demonstrates testing JSON decoding errors in async context
    ///
    /// Why this matters: APIs might return malformed JSON due to bugs or
    /// middleware issues, and we need to handle this gracefully
    func testFetchCharactersInvalidJSON() async {
        // GIVEN: Invalid JSON response
        let invalidJSON = """
        {
            "count": 1,
            "results": "this should be an array, not a string"
        }
        """
        stub(condition: isHost("swapi.dev")) { _ in
            HTTPStubsResponse(data: invalidJSON.data(using: .utf8)!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        // WHEN/THEN: Should throw a decoding error
        await XCTAssertThrowsErrorAsync(
            try await repository.fetchCharacters(),
            "Should throw decoding error for invalid JSON"
        ) { error in
            guard case RepositoryError.decodingError = error else {
                XCTFail("Expected RepositoryError.decodingError, got \(error)")
                return
            }
        }
    }
    
    // MARK: - Test: Timeout Error
    
    /// Tests that timeout errors are properly handled
    ///
    /// Purpose: Demonstrates testing timeout scenarios in async code
    ///
    /// Note: We simulate a timeout by returning a URLError with .timedOut code
    func testFetchCharactersTimeout() async {
        // GIVEN: Stub a timeout error
        stub(condition: isHost("swapi.dev")) { _ in
            let error = URLError(.timedOut)
            return HTTPStubsResponse(error: error)
        }

        // WHEN/THEN: Should throw a timeout error
        await XCTAssertThrowsErrorAsync(
            try await repository.fetchCharacters(),
            "Should throw timeout error"
        ) { error in
            guard case RepositoryError.timeout = error else {
                XCTFail("Expected RepositoryError.timeout, got \(error)")
                return
            }
        }
    }
    
    // MARK: - Test: Empty Response
    
    /// Tests handling of empty but valid response
    ///
    /// Purpose: Ensures the repository correctly handles edge cases
    /// where the API returns no results
    func testFetchCharactersEmptyResults() async throws {
        // GIVEN: Valid JSON but with no results
        let emptyJSON = """
        {
            "count": 0,
            "next": null,
            "previous": null,
            "results": []
        }
        """
        stub(condition: isHost("swapi.dev")) { _ in
            HTTPStubsResponse(data: emptyJSON.data(using: .utf8)!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        // WHEN: We fetch characters
        let characters = try await repository.fetchCharacters()

        // THEN: Should return an empty array (not throw an error)
        XCTAssertTrue(characters.isEmpty, "Should return empty array for no results")
    }
}

// ...existing code...

// MARK: - Async Test Helpers

/// Helper function to test async throwing code
/// This makes async error testing more readable
func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    errorHandler: (Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        XCTFail(message.isEmpty ? "Expected error to be thrown" : message, file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
