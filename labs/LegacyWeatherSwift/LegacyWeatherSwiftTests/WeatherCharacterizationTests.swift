//
//  WeatherCharacterizationTests.swift
//  LegacyWeatherSwiftTests
//
//  Example characterization tests for the legacy weather application.
//  These tests document the CURRENT behavior (bugs and all) to establish
//  a safety net before refactoring.

import XCTest
@testable import LegacyWeatherSwift

final class WeatherCharacterizationTests: XCTestCase {
    
    var weatherManager: TestableWeatherSingleton!
    
    override func setUp() {
        super.setUp()
        // Create a testable version of the singleton for isolation
        weatherManager = TestableWeatherSingleton()
    }
    
    override func tearDown() {
        weatherManager = nil
        super.tearDown()
    }
    
    // MARK: - Characterization Tests (Document Current Behavior)
    
    func test_temperature_formatting_celsius_exactly_as_current_system() {
        // CHARACTERIZATION: Document exact current temperature formatting
        weatherManager.isCelsius = true
        weatherManager.currentWeather = WeatherData(
            cityName: "London",
            temperature: 27.3,
            description: "clear sky",
            timestamp: Date()
        )
        
        let result = weatherManager.getTemperatureString()
        
        // Document CURRENT behavior - even if formatting seems odd
        XCTAssertEqual(result, "27°C", "Temperature formatting changed - characterization failed")
    }
    
    func test_temperature_formatting_fahrenheit_exactly_as_current_system() {
        // CHARACTERIZATION: Document exact Fahrenheit conversion behavior
        weatherManager.isCelsius = false
        weatherManager.currentWeather = WeatherData(
            cityName: "New York",
            temperature: 20.0, // 20°C should be 68°F
            description: "cloudy",
            timestamp: Date()
        )
        
        let result = weatherManager.getTemperatureString()
        
        // Document CURRENT conversion behavior
        XCTAssertEqual(result, "68°F", "Fahrenheit conversion changed - characterization failed")
    }
    
    func test_city_cycling_behavior_exactly_as_implemented() {
        // CHARACTERIZATION: Document how city selection works currently
        let initialCity = weatherManager.getCurrentCity()
        
        weatherManager.selectNextCity()
        let secondCity = weatherManager.getCurrentCity()
        
        weatherManager.selectNextCity()
        let thirdCity = weatherManager.getCurrentCity()
        
        // Document the CURRENT city cycling behavior
        XCTAssertEqual(initialCity, "London")
        XCTAssertEqual(secondCity, "New York")  
        XCTAssertEqual(thirdCity, "Tokyo")
        
        // Test wrap-around behavior
        weatherManager.selectNextCity() // Sydney
        weatherManager.selectNextCity() // Paris
        weatherManager.selectNextCity() // Should wrap to London
        
        XCTAssertEqual(weatherManager.getCurrentCity(), "London", "City cycling wrap-around changed")
    }
    
    func test_caching_behavior_exactly_as_current_implementation() {
        // CHARACTERIZATION: Document current caching logic with all its quirks
        let testDate = Date()
        weatherManager.fixedCurrentTime = testDate
        
        let testWeather = WeatherData(
            cityName: "London",
            temperature: 15.0,
            description: "rainy",
            timestamp: testDate
        )
        
        // Simulate setting cached data
        weatherManager.currentWeather = testWeather
        weatherManager.simulateCaching(data: testWeather, for: "London")
        
        // Test cache retrieval within valid time
        let cachedResult = weatherManager.testGetCachedWeatherIfValid(for: "London")
        XCTAssertNotNil(cachedResult, "Cache should return data within valid time")
        XCTAssertEqual(cachedResult?.cityName, "London")
        
        // Test cache expiry behavior
        weatherManager.fixedCurrentTime = testDate.addingTimeInterval(400) // Beyond 5-minute cache
        let expiredResult = weatherManager.testGetCachedWeatherIfValid(for: "London")
        XCTAssertNil(expiredResult, "Cache should expire after 5 minutes")
    }
    
    func test_error_handling_behavior_exactly_as_implemented() {
        // CHARACTERIZATION: Document current error handling patterns
        weatherManager.simulateError("Network error: Connection failed")
        
        XCTAssertEqual(weatherManager.errorMessage, "Network error: Connection failed")
        XCTAssertFalse(weatherManager.isLoading, "Loading should be false after error")
        XCTAssertNil(weatherManager.currentWeather, "Weather data should be nil after error")
        
        // Document error clearing behavior
        weatherManager.errorMessage = ""
        XCTAssertTrue(weatherManager.errorMessage.isEmpty, "Error should clear when set to empty")
    }
    
    func test_temperature_unit_toggle_side_effects() {
        // CHARACTERIZATION: Document what happens when toggling temperature units
        let initialUnit = weatherManager.isCelsius
        
        weatherManager.toggleTemperatureUnit()
        
        XCTAssertNotEqual(weatherManager.isCelsius, initialUnit, "Temperature unit should toggle")
        
        // Document any side effects of temperature toggling
        weatherManager.toggleTemperatureUnit()
        
        XCTAssertEqual(weatherManager.isCelsius, initialUnit, "Double toggle should return to original")
    }
    
    func test_date_formatting_exactly_as_current_implementation() {
        // CHARACTERIZATION: Document current date formatting behavior
        let testDate = Date(timeIntervalSince1970: 1699027200) // Fixed date for consistent testing
        weatherManager.fixedCurrentTime = testDate
        
        let result = weatherManager.getFormattedDate()
        
        // This will capture the EXACT current formatting
        // Note: This might vary by locale, which is part of the characterization
        XCTAssertFalse(result.isEmpty, "Formatted date should not be empty")
        XCTAssertTrue(result.contains("Nov") || result.contains("11"), "Should contain date information")
    }
    
    // MARK: - Test Edge Cases and Boundary Conditions
    
    func test_edge_case_nil_weather_data_handling() {
        // CHARACTERIZATION: What happens with nil weather data?
        weatherManager.currentWeather = nil
        
        let tempString = weatherManager.getTemperatureString()
        let dateString = weatherManager.getFormattedDate()
        
        XCTAssertEqual(tempString, "N/A", "Should return N/A for nil weather temperature")
        XCTAssertFalse(dateString.isEmpty, "Date string should still work without weather data")
    }
    
    func test_boundary_cache_expiration_timing() {
        // CHARACTERIZATION: Test exact cache timing boundaries
        let testDate = Date()
        weatherManager.fixedCurrentTime = testDate
        
        let testWeather = WeatherData(
            cityName: "Tokyo", 
            temperature: 25.0,
            description: "sunny",
            timestamp: testDate
        )
        
        weatherManager.simulateCaching(data: testWeather, for: "Tokyo")
        
        // Test just before expiration (299 seconds)
        weatherManager.fixedCurrentTime = testDate.addingTimeInterval(299)
        XCTAssertNotNil(weatherManager.testGetCachedWeatherIfValid(for: "Tokyo"), 
                       "Cache should be valid at 299 seconds")
        
        // Test at exactly 300 seconds (cache duration)
        weatherManager.fixedCurrentTime = testDate.addingTimeInterval(300)
        XCTAssertNil(weatherManager.testGetCachedWeatherIfValid(for: "Tokyo"), 
                    "Cache should expire at exactly 300 seconds")
    }
}

// MARK: - Testable Subclass (Dependency Breaking Technique)

/// Testable version of WeatherSingleton that breaks external dependencies
/// This is an example of the "Subclass and Override Method" legacy refactoring technique
class TestableWeatherSingleton: WeatherSingleton {
    
    // Override seams to make testing deterministic
    var fixedCurrentTime: Date?
    var loggedMessages: [String] = []
    
    override func currentTime() -> Date {
        return fixedCurrentTime ?? super.currentTime()
    }
    
    override func logMessage(_ message: String) {
        loggedMessages.append(message)
        // Don't call super to avoid console spam in tests
    }
    
    // Expose private methods for characterization testing
    func testGetCachedWeatherIfValid(for city: String) -> WeatherData? {
        // Use reflection or recreate the private logic for testing
        // This is a characterization testing technique
        return getCachedWeatherIfValid(for: city)
    }
    
    func simulateCaching(data: WeatherData, for city: String) {
        cacheWeatherData(data, for: city)
    }
    
    func simulateError(_ message: String) {
        handleError(message)
    }
    
    // Make private methods accessible for testing (another dependency breaking technique)
    private func getCachedWeatherIfValid(for city: String) -> WeatherData? {
        // This would need to access the private cache properties
        // In a real scenario, you might need to expose these or use other techniques
        return nil // Placeholder - would implement actual cache logic
    }
    
    private func cacheWeatherData(_ data: WeatherData, for city: String) {
        // Placeholder - would implement actual caching
    }
    
    private func handleError(_ message: String) {
        errorMessage = message
        isLoading = false
        currentWeather = nil
    }
}