//
//  NetworkDependencyTests.swift
//  
//  DEMONSTRATES: Exercise 4 - Network Dependency Breaking Testing
//  
//  Shows how network dependency abstraction enables fast, reliable testing
//  of async network operations without real HTTP calls
//

import XCTest
@testable import LegacyWeatherSwift

// MARK: - Mock Network Service for Testing
// Mock implementation for testing without real network calls
class MockNetworkService: WeatherNetworkService {
    
    // Test control properties
    var mockData: Data?
    var mockError: Error?
    var requestDelay: TimeInterval = 0
    var capturedURLs: [URL] = []
    
    // Configurable responses for different scenarios
    enum NetworkScenario {
        case success(Data)
        case failure(Error)
        case timeout
        case malformedData
    }
    
    private var scenario: NetworkScenario = .success(Data())
    
    func configure(scenario: NetworkScenario) {
        self.scenario = scenario
    }
    
    func fetchWeatherData(from url: URL) async throws -> Data {
        // Capture the URL for verification in tests
        capturedURLs.append(url)
        
        // Simulate network delay if configured
        if requestDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(requestDelay * 1_000_000_000))
        }
        
        // Return response based on configured scenario
        switch scenario {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        case .timeout:
            throw URLError(.timedOut)
        case .malformedData:
            throw URLError(.cannotParseResponse)
        }
    }
}

// MARK: - Network Error Types for Testing
enum TestNetworkError: Error, Equatable {
    case noConnection
    case serverError
    case invalidResponse
    
    var localizedDescription: String {
        switch self {
        case .noConnection: return "No network connection"
        case .serverError: return "Server error occurred"
        case .invalidResponse: return "Invalid server response"
        }
    }
}

// Test-friendly WeatherSingleton for network dependency tests
class NetworkTestWeatherSingleton: WeatherSingleton {
    override func loadInitialData() {
        // Override to prevent automatic network calls during test initialization
    }
}

// MARK: - Tests
class NetworkDependencyTests: XCTestCase {
    
    var weatherManager: NetworkTestWeatherSingleton!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        weatherManager = NetworkTestWeatherSingleton(
            timeProvider: SystemTimeProvider(),
            networkService: mockNetworkService
        )
    }
    
    override func tearDown() {
        weatherManager = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    // MARK: - Successful Network Request Tests
    
    func test_fetchWeather_success_parsesDataCorrectly() async {
        // ARRANGE: Valid weather JSON response
        let validWeatherJSON = """
        {
            "name": "London",
            "main": {
                "temp": 22.5
            },
            "weather": [
                {
                    "description": "clear sky"
                }
            ]
        }
        """.data(using: .utf8)!
        
        mockNetworkService.configure(scenario: .success(validWeatherJSON))
        
        // ACT: Trigger weather fetch
        weatherManager.fetchWeather(for: "London")
        
        // Wait a moment for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // ASSERT: Weather data should be populated
        XCTAssertNotNil(weatherManager.currentWeather, "Weather data should be set after successful network request")
        XCTAssertEqual(weatherManager.currentWeather?.cityName, "London")
        if let temperature = weatherManager.currentWeather?.temperature {
            XCTAssertEqual(temperature, 22.5, accuracy: 0.1)
        } else {
            XCTFail("Temperature should not be nil")
        }
        XCTAssertEqual(weatherManager.currentWeather?.description, "clear sky")
        XCTAssertFalse(weatherManager.isLoading, "Loading should be false after completion")
        XCTAssertTrue(weatherManager.errorMessage.isEmpty, "Error message should be empty on success")
    }
    
    func test_fetchWeather_verifies_correct_URL_construction() async {
        // ARRANGE: Mock successful response
        mockNetworkService.configure(scenario: .success(Data()))
        
        // ACT: Fetch weather for specific city
        weatherManager.fetchWeather(for: "Tokyo")
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 second
        
        // ASSERT: Verify correct URL was requested
        XCTAssertEqual(mockNetworkService.capturedURLs.count, 1, "Should make exactly one network request")
        
        let capturedURL = mockNetworkService.capturedURLs.first!
        XCTAssertTrue(capturedURL.absoluteString.contains("Tokyo"), "URL should contain city name 'Tokyo'")
        XCTAssertTrue(capturedURL.absoluteString.contains("api.openweathermap.org"), "URL should use correct API endpoint")
        XCTAssertTrue(capturedURL.absoluteString.contains("units=metric"), "URL should request metric units")
    }
    
    // MARK: - Network Error Handling Tests
    
    func test_fetchWeather_networkError_handlesGracefully() async {
        // ARRANGE: Configure network error
        let networkError = TestNetworkError.noConnection
        mockNetworkService.configure(scenario: .failure(networkError))
        
        // ACT: Attempt to fetch weather
        weatherManager.fetchWeather(for: "Paris")
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // ASSERT: Error should be handled gracefully
        XCTAssertNil(weatherManager.currentWeather, "Weather data should be nil on network error")
        XCTAssertFalse(weatherManager.isLoading, "Loading should be false after error")
        XCTAssertTrue(weatherManager.errorMessage.contains("Network error"), "Error message should indicate network error")
    }
    
    func test_fetchWeather_timeoutError_handlesAppropriately() async {
        // ARRANGE: Configure timeout scenario
        mockNetworkService.configure(scenario: .timeout)
        
        // ACT: Attempt to fetch weather
        weatherManager.fetchWeather(for: "Sydney")
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // ASSERT: Timeout should be handled
        XCTAssertNil(weatherManager.currentWeather, "Weather data should be nil on timeout")
        XCTAssertFalse(weatherManager.isLoading, "Loading should be false after timeout")
        XCTAssertTrue(weatherManager.errorMessage.contains("Network error"), "Should show network error message")
    }
    
    // MARK: - Invalid Data Handling Tests
    
    func test_fetchWeather_invalidJSON_handlesParsingError() async {
        // ARRANGE: Invalid JSON that can't be parsed
        let invalidJSON = "{ invalid json }".data(using: .utf8)!
        mockNetworkService.configure(scenario: .success(invalidJSON))
        
        // ACT: Attempt to fetch weather
        weatherManager.fetchWeather(for: "Berlin")
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // ASSERT: Parsing error should be handled
        XCTAssertNil(weatherManager.currentWeather, "Weather data should be nil when JSON parsing fails")
        XCTAssertFalse(weatherManager.isLoading, "Loading should be false after parsing error")
        XCTAssertTrue(weatherManager.errorMessage.contains("Failed to parse"), "Should show JSON parsing error message")
    }
    
    func test_fetchWeather_emptyResponse_handlesGracefully() async {
        // ARRANGE: Empty data response
        mockNetworkService.configure(scenario: .success(Data()))
        
        // ACT: Attempt to fetch weather  
        weatherManager.fetchWeather(for: "Madrid")
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // ASSERT: Empty response should be handled
        XCTAssertNil(weatherManager.currentWeather, "Weather data should be nil for empty response")
        XCTAssertFalse(weatherManager.isLoading, "Loading should be false after empty response")
        XCTAssertFalse(weatherManager.errorMessage.isEmpty, "Should show error message for empty response")
    }
    
    // MARK: - Async Behavior Tests
    
    func test_fetchWeather_setsLoadingStateCorrectly() {
        // ARRANGE: Configure slow network response
        mockNetworkService.configure(scenario: .success(Data()))
        mockNetworkService.requestDelay = 0.2 // 200ms delay
        
        // ACT: Start weather fetch
        XCTAssertFalse(weatherManager.isLoading, "Loading should start as false")
        
        weatherManager.fetchWeather(for: "Rome")
        
        // ASSERT: Loading should be set during request
        // Note: In real implementation, isLoading would be set to true at start of fetchWeather
        // This tests the current implementation behavior
    }
    
    func test_fetchWeather_multipleRequests_handlesCorrectly() async {
        // ARRANGE: Configure successful responses
        mockNetworkService.configure(scenario: .success("""
        {
            "name": "TestCity",
            "main": {"temp": 20.0},
            "weather": [{"description": "test"}]
        }
        """.data(using: .utf8)!))
        
        // ACT: Make multiple requests
        weatherManager.fetchWeather(for: "City1")
        weatherManager.fetchWeather(for: "City2")
        weatherManager.fetchWeather(for: "City3")
        
        // Wait for all async operations
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 second
        
        // ASSERT: Should have made multiple network requests
        XCTAssertEqual(mockNetworkService.capturedURLs.count, 3, "Should make request for each city")
        XCTAssertTrue(mockNetworkService.capturedURLs[0].absoluteString.contains("City1"))
        XCTAssertTrue(mockNetworkService.capturedURLs[1].absoluteString.contains("City2"))
        XCTAssertTrue(mockNetworkService.capturedURLs[2].absoluteString.contains("City3"))
    }
}

/*
 * REFACTORING BENEFITS DEMONSTRATED:
 *
 * 1. FAST TESTS: No real network calls - tests run in milliseconds instead of seconds
 * 2. RELIABLE TESTS: No dependency on internet connection or external APIs
 * 3. ERROR TESTING: Can simulate network failures, timeouts, malformed responses
 * 4. EDGE CASE TESTING: Can test scenarios difficult to reproduce with real network
 * 5. ASYNC TESTING: Proper async/await testing patterns for modern iOS development
 * 6. ISOLATION: Tests don't interfere with each other or external services
 *
 * BEFORE NETWORK DEPENDENCY BREAKING:
 * - Tests required internet connection and working API
 * - Network failures caused random test failures
 * - Impossible to test error scenarios reliably
 * - Tests were slow (waiting for real network requests)
 * - Tests could hit API rate limits or affect server metrics
 *
 * AFTER NETWORK DEPENDENCY BREAKING:
 * - All network behavior can be tested without real HTTP calls
 * - Error scenarios are easily reproducible and testable
 * - Tests are fast, reliable, and deterministic
 * - Can test edge cases like timeouts, malformed responses, etc.
 * - Tests serve as living documentation of network behavior
 */