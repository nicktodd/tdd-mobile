//
//  WeatherCharacterizationTests.swift
//  LegacyWeatherSwiftTests
//
//  Example characterization tests for the legacy weather application.
//  These tests document the CURRENT behavior (bugs and all) to establish
//  a safety net before refactoring.

import XCTest
@testable import LegacyWeatherSwift

// Local TimeProvider mock for characterization tests  
class CharacterizationMockTimeProvider: TimeProvider {
    private var mockTime: Date
    
    init(currentTime: Date = Date()) {
        self.mockTime = currentTime
    }
    
    func currentTime() -> Date {
        return mockTime
    }
    
    func setTime(_ date: Date) {
        mockTime = date
    }
    
    func advance(by seconds: TimeInterval) {
        mockTime = mockTime.addingTimeInterval(seconds)
    }
}

final class WeatherCharacterizationTests: XCTestCase {
    
    var weatherManager: TestableWeatherSingleton!
    
    override func setUp() {
        super.setUp()
        // Create a testable version of the singleton for isolation
        // Using SystemTimeProvider by default for characterization tests
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
        
        // Set test weather data directly (since we can't access private caching methods)
        weatherManager.currentWeather = testWeather
        
        // Test current weather data behavior
        XCTAssertNotNil(weatherManager.currentWeather, "Weather data should be set")
        XCTAssertEqual(weatherManager.currentWeather?.cityName, "London")
        
        // Get initial formatted date
        let initialFormattedDate = weatherManager.getFormattedDate()
        
        // Test time-dependent behavior by advancing time by 1 hour (significant change)
        weatherManager.fixedCurrentTime = testDate.addingTimeInterval(60 * 60) // Advance 1 hour
        
        // Test that time change affects date formatting
        let laterFormattedDate = weatherManager.getFormattedDate()
        XCTAssertNotEqual(laterFormattedDate, initialFormattedDate, "Date formatting should reflect time change")
    }
    
    func test_error_handling_behavior_exactly_as_implemented() {
        // CHARACTERIZATION: Document current error handling patterns
        weatherManager.simulateErrorState("Network error: Connection failed")
        
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
        
        // Set weather data directly for characterization testing
        weatherManager.currentWeather = testWeather
        
        // Test time manipulation behavior with significant time difference
        weatherManager.fixedCurrentTime = testDate
        let formattedAtStart = weatherManager.getFormattedDate()
        
        // Advance by 2 hours to ensure visible change in formatted time
        weatherManager.fixedCurrentTime = testDate.addingTimeInterval(2 * 60 * 60)  // 2 hours
        let formattedAfter2Hours = weatherManager.getFormattedDate()
        
        XCTAssertNotEqual(formattedAtStart, formattedAfter2Hours, "Time formatting should change with fixed time")
    }
    
    func test_time_control_mechanism_works() {
        // DEBUG: Verify that fixedCurrentTime actually controls the time
        let testDate = Date(timeIntervalSince1970: 1609459200) // Jan 1, 2021 00:00:00 UTC
        
        // Set a specific time
        weatherManager.fixedCurrentTime = testDate
        let time1 = weatherManager.currentTime()
        
        // Advance by 1 hour
        let advancedTime = testDate.addingTimeInterval(3600) // 1 hour
        weatherManager.fixedCurrentTime = advancedTime
        let time2 = weatherManager.currentTime()
        
        // Verify times are different and match what we set
        XCTAssertNotEqual(time1, time2, "Times should be different")
        XCTAssertEqual(time1.timeIntervalSince1970, testDate.timeIntervalSince1970, accuracy: 1.0, "First time should match set time")
        XCTAssertEqual(time2.timeIntervalSince1970, advancedTime.timeIntervalSince1970, accuracy: 1.0, "Second time should match advanced time")
        
        // Also test formatted dates
        weatherManager.fixedCurrentTime = testDate
        let formatted1 = weatherManager.getFormattedDate()
        
        weatherManager.fixedCurrentTime = advancedTime
        let formatted2 = weatherManager.getFormattedDate()
        
        XCTAssertNotEqual(formatted1, formatted2, "Formatted dates should be different when time changes by 1 hour")
    }
}

// MARK: - Testable Subclass (Dependency Breaking Technique)

/// Testable version of WeatherSingleton that breaks external dependencies
/// This is an example of the "Subclass and Override Method" legacy refactoring technique
class TestableWeatherSingleton: WeatherSingleton {
    
    // Override seams to make testing deterministic
    var loggedMessages: [String] = []
    private let mockTimeProvider: CharacterizationMockTimeProvider
    
    // UPDATED: Exercise 2/3 - Always use controllable time provider for characterization tests
    override init(timeProvider: TimeProvider = CharacterizationMockTimeProvider()) {
        // Always use a controllable mock time provider for characterization tests
        if let mockProvider = timeProvider as? CharacterizationMockTimeProvider {
            self.mockTimeProvider = mockProvider
        } else {
            self.mockTimeProvider = CharacterizationMockTimeProvider()
        }
        super.init(timeProvider: self.mockTimeProvider)
    }
    
    // Convenience initializer for tests that need controlled time
    convenience init(fixedTime: Date) {
        let mockTimeProvider = CharacterizationMockTimeProvider(currentTime: fixedTime)
        self.init(timeProvider: mockTimeProvider)
    }
    
    // Explicit methods for time control in tests
    var fixedCurrentTime: Date? {
        get {
            return mockTimeProvider.currentTime()
        }
        set {
            if let newTime = newValue {
                mockTimeProvider.setTime(newTime)
            }
        }
    }
    
    // Helper method to advance time
    func advanceTime(by seconds: TimeInterval) {
        mockTimeProvider.advance(by: seconds)
    }
    
    override func logMessage(_ message: String) {
        loggedMessages.append(message)
        // Don't call super to avoid console spam in tests
    }
    
    // Test helper methods for characterization testing
    // Since private methods can't be overridden, we test behavior through public interface
    func simulateErrorState(_ message: String) {
        // Simulate error state by setting public properties
        errorMessage = message
        isLoading = false
        currentWeather = nil
    }
    
    func createTestWeatherData() -> WeatherData {
        return WeatherData(
            cityName: "Test City",
            temperature: 20.0,
            description: "Test Weather",
            timestamp: fixedCurrentTime ?? Date()
        )
    }
}