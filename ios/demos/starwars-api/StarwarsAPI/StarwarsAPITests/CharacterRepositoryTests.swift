//
//  CharacterRepositoryTests.swift
//  StarwarsAPITests
//
//  Created by Nick Todd on 24/10/2025.
//

import XCTest
@testable import StarwarsAPI

/// Tests for CharacterRepository
/// These tests demonstrate asynchronous testing patterns and error condition testing
/// without making actual network calls (we'll use URLProtocol mocking)
final class CharacterRepositoryTests: XCTestCase {
    
    var repository: CharacterRepository!
    var mockURLSession: URLSession!
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        
        // Configure a mock URLSession using URLProtocol
        // This allows us to intercept network requests and return mock data
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockURLSession = URLSession(configuration: configuration)
        
        // Inject the mock session into our repository
        repository = CharacterRepository(urlSession: mockURLSession)
    }
    
    override func tearDown() {
        repository = nil
        mockURLSession = nil
        MockURLProtocol.reset()
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
        // GIVEN: Mock API response with valid character data
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
        
        // Configure the mock to return this data
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://swapi.dev/api/people/")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // WHEN: We call the async fetchCharacters method
        // Note: We use 'await' because this is an async function
        // The test will suspend here until the async operation completes
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
        // GIVEN: A network error scenario
        MockURLProtocol.mockError = URLError(.notConnectedToInternet)
        
        // WHEN/THEN: Calling fetchCharacters should throw a network error
        // Note: We await inside a closure passed to XCTAssertThrowsError
        await XCTAssertThrowsErrorAsync(
            try await repository.fetchCharacters(),
            "Should throw an error when network fails"
        ) { error in
            // Verify it's the correct error type
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
        // GIVEN: A 404 Not Found response
        MockURLProtocol.mockData = Data() // Empty data
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://swapi.dev/api/people/")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        
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
        // GIVEN: A 500 server error response
        MockURLProtocol.mockData = Data()
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://swapi.dev/api/people/")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        
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
        
        MockURLProtocol.mockData = invalidJSON.data(using: .utf8)
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://swapi.dev/api/people/")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
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
        // GIVEN: A timeout error
        MockURLProtocol.mockError = URLError(.timedOut)
        
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
        
        MockURLProtocol.mockData = emptyJSON.data(using: .utf8)
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://swapi.dev/api/people/")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // WHEN: We fetch characters
        let characters = try await repository.fetchCharacters()
        
        // THEN: Should return an empty array (not throw an error)
        XCTAssertTrue(characters.isEmpty, "Should return empty array for no results")
    }
}

// MARK: - MockURLProtocol

/// Custom URLProtocol for intercepting and mocking network requests
/// This allows us to test network code without making actual HTTP calls
class MockURLProtocol: URLProtocol {
    
    // Static properties to configure mock responses
    static var mockData: Data?
    static var mockResponse: HTTPURLResponse?
    static var mockError: Error?
    
    /// Reset all mock data between tests
    static func reset() {
        mockData = nil
        mockResponse = nil
        mockError = nil
    }
    
    // MARK: - URLProtocol Override Methods
    
    /// Determines if this protocol can handle the request
    override class func canInit(with request: URLRequest) -> Bool {
        return true // Handle all requests
    }
    
    /// Returns a canonical version of the request (required override)
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    /// Starts loading the request with mock data
    override func startLoading() {
        // Return error if configured
        if let error = MockURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        // Return response if configured
        if let response = MockURLProtocol.mockResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        // Return data if configured
        if let data = MockURLProtocol.mockData {
            client?.urlProtocol(self, didLoad: data)
        }
        
        // Finish loading
        client?.urlProtocolDidFinishLoading(self)
    }
    
    /// Stops loading (required override)
    override func stopLoading() {
        // Nothing to do
    }
}

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
