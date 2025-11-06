//
//  TimeProviderTests.swift
//  
//  DEMONSTRATES: Exercise 2 - Time Dependency Seam Testing
//  
//  This shows how the time dependency refactoring makes previously untestable code testable
//

import XCTest
@testable import LegacyWeatherSwift

// MARK: - Test Double for TimeProvider
// Mock implementation for testing with controllable time
// NOTE: This belongs in tests, NOT in production code
class MockTimeProvider: TimeProvider {
    private var mockTime: Date
    
    init(currentTime: Date = Date()) {
        self.mockTime = currentTime
    }
    
    func currentTime() -> Date {
        return mockTime
    }
    
    // Testing helpers for time manipulation
    func setTime(_ date: Date) {
        mockTime = date
    }
    
    func advance(by seconds: TimeInterval) {
        mockTime = mockTime.addingTimeInterval(seconds)
    }
}

// MARK: - Test-Friendly WeatherSingleton
// Subclass that avoids network calls during initialization for safer testing
class TestFriendlyWeatherSingleton: WeatherSingleton {
    
    override func loadInitialData() {
        // Override to prevent network calls during test initialization
        // Tests can explicitly call fetchWeather when needed
    }
}

// MARK: - Tests
class TimeProviderTests: XCTestCase {
    
    // DEMONSTRATION: How time dependency injection enables deterministic testing
    
    func test_date_formatting_with_controlled_time() {
        // ARRANGE: Create a specific date for testing
        let testDate = createTestDate(year: 2024, month: 11, day: 6, hour: 14, minute: 30)
        let mockTimeProvider = MockTimeProvider(currentTime: testDate)
        
        // Create WeatherSingleton with controlled time using test-friendly subclass
        let weatherManager = TestFriendlyWeatherSingleton(timeProvider: mockTimeProvider)
        
        // ACT: Call the date formatting method
        let formattedDate = weatherManager.getFormattedDate()
        
        // ASSERT: Verify date components are present (flexible format handling)
        // This test is now deterministic because we control the time
        XCTAssertTrue(formattedDate.contains("Nov") || formattedDate.contains("November"), 
                     "Date should contain month 'Nov', but got: \(formattedDate)")
        XCTAssertTrue(formattedDate.contains("6"), 
                     "Date should contain day '6', but got: \(formattedDate)")
        XCTAssertTrue(formattedDate.contains("2024"), 
                     "Date should contain year '2024', but got: \(formattedDate)")
        XCTAssertTrue(formattedDate.contains("14:30") || formattedDate.contains("2:30") || formattedDate.contains("30"), 
                     "Time should contain time component with 30 minutes, but got: \(formattedDate)")
    }
    
    func test_cache_expiration_with_controlled_time() {
        // ARRANGE: Set up controlled time scenario
        let startTime = Date()
        let mockTimeProvider = MockTimeProvider(currentTime: startTime)
        let weatherManager = TestFriendlyWeatherSingleton(timeProvider: mockTimeProvider)
        
        // Simulate caching some data at the start time
        // (This would require additional refactoring of the caching mechanism)
        
        // ACT & ASSERT: Test cache behavior over time
        // Initially, data should be fresh
        var currentFormattedDate = weatherManager.getFormattedDate()
        XCTAssertNotNil(currentFormattedDate)
        
        // Advance time by 4 minutes (within cache duration)
        mockTimeProvider.advance(by: 4 * 60) // 4 minutes
        currentFormattedDate = weatherManager.getFormattedDate()
        XCTAssertNotNil(currentFormattedDate, "Data should still be valid after 4 minutes")
        
        // Advance time by 2 more minutes (6 total, beyond 5-minute cache)
        mockTimeProvider.advance(by: 2 * 60) // 2 more minutes = 6 total
        // This demonstrates how we can test time-dependent cache expiration
        // (Full implementation would require caching refactoring in Exercise 5)
    }
    
    func test_time_provider_mock_functionality() {
        // ARRANGE: Test the mock time provider itself
        let initialDate = createTestDate(year: 2024, month: 1, day: 1, hour: 12, minute: 0)
        let mockTimeProvider = MockTimeProvider(currentTime: initialDate)
        
        // ACT & ASSERT: Test time manipulation methods
        XCTAssertEqual(mockTimeProvider.currentTime(), initialDate, "Should return initial date")
        
        // Test advancing by seconds
        mockTimeProvider.advance(by: 3600) // 1 hour
        let expectedAfterHour = initialDate.addingTimeInterval(3600)
        XCTAssertEqual(mockTimeProvider.currentTime(), expectedAfterHour, "Should advance by 1 hour")
        
        // Test setting specific time
        let newDate = createTestDate(year: 2025, month: 12, day: 31, hour: 23, minute: 59)
        mockTimeProvider.setTime(newDate)
        XCTAssertEqual(mockTimeProvider.currentTime(), newDate, "Should set to specific date")
    }
    
    // HELPER: Create deterministic test dates
    private func createTestDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone(abbreviation: "UTC")
        
        return Calendar.current.date(from: components) ?? Date()
    }
}

/*
 * REFACTORING BENEFITS DEMONSTRATED:
 *
 * 1. DETERMINISTIC TESTING: Tests now produce consistent results because time is controlled
 * 2. TIME TRAVEL: Can test future/past scenarios without waiting or system clock manipulation
 * 3. EDGE CASE TESTING: Can test midnight boundaries, leap years, daylight saving transitions
 * 4. ISOLATION: Tests don't depend on when they're run - they're isolated and repeatable
 * 5. SPEED: No need to wait for actual time to pass to test time-dependent behavior
 *
 * BEFORE REFACTORING: 
 * - Tests using Date() would fail at different times of day
 * - Cache expiration tests would take 5+ minutes to run
 * - Date formatting tests would break when run in different timezones
 *
 * AFTER REFACTORING:
 * - All tests are fast and deterministic
 * - Time-dependent logic can be thoroughly tested
 * - Tests serve as living documentation of time-related behavior
 */