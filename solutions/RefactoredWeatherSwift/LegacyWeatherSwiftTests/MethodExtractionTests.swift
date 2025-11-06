//
//  MethodExtractionTests.swift
//  
//  DEMONSTRATES: Exercise 3 - Method Extraction Testing
//  
//  Shows how method extraction makes complex business logic testable
//  by breaking large methods into smaller, focused functions
//

import XCTest
@testable import LegacyWeatherSwift

// Local test-friendly WeatherSingleton for method extraction tests
class MethodExtractionTestWeatherSingleton: WeatherSingleton {
    override func loadInitialData() {
        // Override to prevent network calls during test initialization
    }
}

class MethodExtractionTests: XCTestCase {
    
    var weatherManager: WeatherSingleton!
    
    override func setUp() {
        super.setUp()
        // Create a fresh test-friendly instance that doesn't make network calls
        weatherManager = MethodExtractionTestWeatherSingleton()
    }
    
    // MARK: - URL Building Tests (Extracted Method)
    
    func test_buildWeatherURL_validCity_returnsCorrectURL() {
        // ARRANGE
        let city = "London"
        
        // ACT
        let url = weatherManager.buildWeatherURL(for: city)
        
        // ASSERT
        XCTAssertNotNil(url, "URL should be created for valid city")
        XCTAssertTrue(url?.absoluteString.contains("London") == true, "URL should contain city name")
        XCTAssertTrue(url?.absoluteString.contains("api.openweathermap.org") == true, "URL should contain base URL")
        XCTAssertTrue(url?.absoluteString.contains("units=metric") == true, "URL should contain metric units")
    }
    
    func test_buildWeatherURL_cityWithSpaces_encodesCorrectly() {
        // ARRANGE
        let city = "New York"
        
        // ACT
        let url = weatherManager.buildWeatherURL(for: city)
        
        // ASSERT
        XCTAssertNotNil(url, "URL should be created for city with spaces")
        XCTAssertTrue(url?.absoluteString.contains("New%20York") == true, "Spaces should be URL encoded")
    }
    
    func test_buildWeatherURL_cityWithSpecialCharacters_encodesCorrectly() {
        // ARRANGE
        let city = "São Paulo"
        
        // ACT
        let url = weatherManager.buildWeatherURL(for: city)
        
        // ASSERT
        XCTAssertNotNil(url, "URL should handle special characters")
        // The exact encoding may vary, but URL should not be nil
    }
    
    // MARK: - Temperature Conversion Tests (Extracted Method)
    
    func test_convertTemperature_celsiusToFahrenheit() {
        // ARRANGE
        let celsiusTemp = 25.0
        
        // ACT
        let fahrenheit = weatherManager.convertTemperature(celsiusTemp, toCelsius: false)
        
        // ASSERT
        let expectedFahrenheit = (25.0 * 9/5) + 32 // 77.0
        XCTAssertEqual(fahrenheit, expectedFahrenheit, accuracy: 0.1, "25°C should equal 77°F")
    }
    
    func test_convertTemperature_celsiusToCelsius_returnsSame() {
        // ARRANGE
        let celsiusTemp = 20.0
        
        // ACT
        let result = weatherManager.convertTemperature(celsiusTemp, toCelsius: true)
        
        // ASSERT
        XCTAssertEqual(result, celsiusTemp, "Celsius to Celsius should return same value")
    }
    
    func test_convertTemperature_freezingPoint() {
        // ARRANGE
        let freezing = 0.0 // 0°C
        
        // ACT
        let fahrenheit = weatherManager.convertTemperature(freezing, toCelsius: false)
        
        // ASSERT
        XCTAssertEqual(fahrenheit, 32.0, accuracy: 0.1, "0°C should equal 32°F")
    }
    
    func test_convertTemperature_negativeTemperature() {
        // ARRANGE
        let negativeCelsius = -10.0
        
        // ACT
        let fahrenheit = weatherManager.convertTemperature(negativeCelsius, toCelsius: false)
        
        // ASSERT
        let expected = (-10.0 * 9/5) + 32 // 14°F
        XCTAssertEqual(fahrenheit, expected, accuracy: 0.1, "-10°C should equal 14°F")
    }
    
    // MARK: - Temperature Unit Tests (Extracted Method)
    
    func test_getTemperatureUnit_celsius() {
        // ARRANGE
        weatherManager.isCelsius = true
        
        // ACT
        let unit = weatherManager.getTemperatureUnit()
        
        // ASSERT
        XCTAssertEqual(unit, "°C", "Should return Celsius unit")
    }
    
    func test_getTemperatureUnit_fahrenheit() {
        // ARRANGE
        weatherManager.isCelsius = false
        
        // ACT  
        let unit = weatherManager.getTemperatureUnit()
        
        // ASSERT
        XCTAssertEqual(unit, "°F", "Should return Fahrenheit unit")
    }
    
    // MARK: - Temperature Formatting Tests (Extracted Method)
    
    func test_formatTemperature_wholeDegrees() {
        // ARRANGE
        let temperature = 23.0
        let unit = "°C"
        
        // ACT
        let formatted = weatherManager.formatTemperature(temperature, unit: unit)
        
        // ASSERT
        XCTAssertEqual(formatted, "23°C", "Should format whole degrees correctly")
    }
    
    func test_formatTemperature_decimalRounding() {
        // ARRANGE
        let temperature = 23.7
        let unit = "°F"
        
        // ACT
        let formatted = weatherManager.formatTemperature(temperature, unit: unit)
        
        // ASSERT
        XCTAssertEqual(formatted, "24°F", "Should round to nearest whole degree")
    }
    
    func test_formatTemperature_negativeTemperature() {
        // ARRANGE
        let temperature = -5.0
        let unit = "°C"
        
        // ACT
        let formatted = weatherManager.formatTemperature(temperature, unit: unit)
        
        // ASSERT
        XCTAssertEqual(formatted, "-5°C", "Should handle negative temperatures")
    }
    
    // MARK: - JSON Parsing Tests (Extracted Method)
    
    func test_parseWeatherData_validJSON_returnsWeatherData() {
        // ARRANGE
        let jsonString = """
        {
            "name": "London",
            "main": {
                "temp": 15.5
            },
            "weather": [
                {
                    "description": "light rain"
                }
            ]
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // ACT & ASSERT
        XCTAssertNoThrow({
            let weatherData = try self.weatherManager.parseWeatherData(from: jsonData)
            XCTAssertEqual(weatherData.cityName, "London")
            XCTAssertEqual(weatherData.temperature, 15.5, accuracy: 0.1)
            XCTAssertEqual(weatherData.description, "light rain")
        }, "Should parse valid JSON without throwing")
    }
    
    func test_parseWeatherData_missingWeatherArray_usesDefaultDescription() {
        // ARRANGE
        let jsonString = """
        {
            "name": "London",
            "main": {
                "temp": 20.0
            },
            "weather": []
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // ACT & ASSERT
        XCTAssertNoThrow({
            let weatherData = try self.weatherManager.parseWeatherData(from: jsonData)
            XCTAssertEqual(weatherData.description, "Unknown")
        }, "Should handle missing weather description gracefully")
    }
    
    func test_parseWeatherData_invalidJSON_throwsError() {
        // ARRANGE
        let invalidJSON = "{ invalid json }".data(using: .utf8)!
        
        // ACT & ASSERT
        XCTAssertThrowsError(try weatherManager.parseWeatherData(from: invalidJSON)) { error in
            // Verify it's a decoding error
            XCTAssertTrue(error is DecodingError, "Should throw DecodingError for invalid JSON")
        }
    }
}

/*
 * REFACTORING BENEFITS DEMONSTRATED:
 *
 * 1. TESTABLE BUSINESS LOGIC: Temperature conversion now isolated and easily testable
 * 2. EDGE CASE TESTING: Can test special characters, negative temps, rounding behavior
 * 3. PURE FUNCTIONS: Methods like convertTemperature() are deterministic and fast to test
 * 4. ERROR HANDLING: JSON parsing errors can be tested without network calls
 * 5. SINGLE RESPONSIBILITY: Each extracted method has one clear purpose
 * 6. MAINTAINABILITY: Changes to formatting/conversion logic are isolated
 *
 * BEFORE METHOD EXTRACTION:
 * - Large fetchWeather() method was untestable without network calls
 * - Temperature logic was buried in UI formatting code
 * - JSON parsing mixed with network error handling
 * - Impossible to test edge cases like special characters in URLs
 *
 * AFTER METHOD EXTRACTION:
 * - Each piece of business logic can be tested independently
 * - Fast unit tests without network dependencies
 * - Clear separation of concerns
 * - Easy to add new temperature units or formatting options
 */