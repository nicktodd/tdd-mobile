//
//  WeatherSingleton.swift
//  LegacyWeatherSwift
//
//  The Ultimate Anti-Pattern Weather Manager
//  This class violates pretty much every SOLID principle and does EVERYTHING:
//  - Network calls
//  - Data storage
//  - Business logic
//  - UI state management
//  - Error handling (poorly)
//  - Date formatting
//  - Temperature conversion
//  - Caching (badly)
//
//  NOTE: Some methods have been made 'open' to allow for testing via subclassing.
//  This is a legacy technique called "Subclass and Override Method" for dependency breaking.

import Foundation
import SwiftUI
import Combine

// REFACTORING APPLIED: Exercise 2 - Time Dependency Seam
// BEFORE: WeatherSingleton directly calls Date() making it untestable  
// AFTER: Time dependency is abstracted behind TimeProvider protocol

// MARK: - Time Dependency Abstraction (Exercise 2)

// Time dependency abstraction protocol
protocol TimeProvider {
    func currentTime() -> Date
}

// Real implementation using system time
// NOTE: Mock implementations belong in test files, not production code
class SystemTimeProvider: TimeProvider {
    func currentTime() -> Date {
        return Date()
    }
}

// MARK: - Network Dependency Abstraction (Exercise 4)

// Network dependency abstraction protocol
// BENEFIT: Allows testing without real network calls
protocol WeatherNetworkService {
    func fetchWeatherData(from url: URL) async throws -> Data
}

// Real implementation using URLSession
// NOTE: Mock implementations belong in test files, not production code
class SystemNetworkService: WeatherNetworkService {
    func fetchWeatherData(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

// MARK: - The God Singleton Anti-Pattern
class WeatherSingleton: ObservableObject {
    static let shared = WeatherSingleton()
    
    // REFACTORED: Time dependency injection (Exercise 2)
    // This allows us to control time in tests, making the class testable
    private let timeProvider: TimeProvider
    
    // REFACTORED: Network dependency injection (Exercise 4)
    // This allows us to test without real network calls
    private let networkService: WeatherNetworkService
    
    // ANTI-PATTERN: All state mixed together in one place
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isCelsius = true
    
    // ANTI-PATTERN: Poor caching - not thread safe, no expiration
    private var cachedData: WeatherData?
    private var cachedCity: String?
    private var cacheTimestamp: Date?
    
    // ANTI-PATTERN: Hardcoded values scattered everywhere
    private let API_KEY = "aaef9b932f92edd04d656cdff0468dd0" // Should be in config!
    private let BASE_URL = "https://api.openweathermap.org/data/2.5/weather"
    private let CACHE_DURATION: TimeInterval = 300 // 5 minutes, should be configurable
    
    // ANTI-PATTERN: Business logic mixed with data access
    private let defaultCities = ["London", "New York", "Tokyo", "Sydney", "Paris"]
    private var selectedCityIndex = 0
    
    // REFACTORED: Dependency injection for testability (Exercise 2 & 4)
    // NOTE: Made internal to allow test subclassing (characterization testing technique)
    init(timeProvider: TimeProvider = SystemTimeProvider(), 
         networkService: WeatherNetworkService = SystemNetworkService()) {
        self.timeProvider = timeProvider
        self.networkService = networkService
        // ANTI-PATTERN: Work in initializer
        loadInitialData()
    }
    
    // REFACTORED: Factory method for testing with dependency injection  
    static func create(timeProvider: TimeProvider = SystemTimeProvider(),
                      networkService: WeatherNetworkService = SystemNetworkService()) -> WeatherSingleton {
        return WeatherSingleton(timeProvider: timeProvider, networkService: networkService)
    }
    
    // MARK: - Public Interface (poorly designed)
    
    func getCurrentCity() -> String {
        return defaultCities[selectedCityIndex]
    }
    
    func selectNextCity() {
        selectedCityIndex = (selectedCityIndex + 1) % defaultCities.count
        clearCache() // Force refresh for new city
        fetchWeather(for: getCurrentCity())
    }
    
    func toggleTemperatureUnit() {
        isCelsius.toggle()
        // ANTI-PATTERN: No need to refetch, but we do anyway due to poor design
        updateTemperatureDisplay()
    }
    
    func refreshWeather() {
        clearCache()
        fetchWeather(for: getCurrentCity())
    }
    
    func getTemperatureString() -> String {
        guard let temp = currentWeather?.temperature else { return "N/A" }
        
        // REFACTORED: Exercise 3 - Extract temperature conversion logic
        let convertedTemp = convertTemperature(temp, toCelsius: isCelsius)
        let unit = getTemperatureUnit()
        
        // REFACTORED: Exercise 3 - Extract formatting logic  
        return formatTemperature(convertedTemp, unit: unit)
    }
    
    // REFACTORED: Exercise 3 - Extracted temperature conversion
    // BENEFIT: Pure function - easily testable with different inputs
    open func convertTemperature(_ celsius: Double, toCelsius: Bool) -> Double {
        return toCelsius ? celsius : (celsius * 9/5) + 32
    }
    
    // REFACTORED: Exercise 3 - Extracted unit logic
    // BENEFIT: Single responsibility - just determines unit
    open func getTemperatureUnit() -> String {
        return isCelsius ? "°C" : "°F"
    }
    
    // REFACTORED: Exercise 3 - Extracted formatting logic
    // BENEFIT: Formatting logic separated and testable
    open func formatTemperature(_ temperature: Double, unit: String) -> String {
        return String(format: "%.0f%@", temperature, unit)
    }
    
    func getFormattedDate() -> String {
        // ANTI-PATTERN: Multiple formatters created unnecessarily
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: currentTime())
    }
    
    // MARK: - Network Layer (tightly coupled)
    
    func fetchWeather(for city: String) {
        // Check cache first
        if let cached = getCachedWeatherIfValid(for: city) {
            logMessage("Using cached data for \(city)")
            currentWeather = cached
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // REFACTORED: Exercise 3 - Method extraction for URL building
        guard let url = buildWeatherURL(for: city) else {
            handleError("Invalid city name: \(city)")
            return
        }
        
        // REFACTORED: Exercise 3 - Method extraction for network request
        performNetworkRequest(url: url, city: city)
    }
    
    // REFACTORED: Exercise 3 - Extracted URL building logic
    // BENEFIT: Now testable independently of network calls
    open func buildWeatherURL(for city: String) -> URL? {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "\(BASE_URL)?q=\(encodedCity)&appid=\(API_KEY)&units=metric")
    }
    
    // REFACTORED: Exercise 4 - Network request with dependency injection & async/await
    // BENEFIT: Uses injected network service, testable without real network calls
    open func performNetworkRequest(url: URL, city: String) {
        Task { @MainActor in
            do {
                let data = try await networkService.fetchWeatherData(from: url)
                isLoading = false
                handleNetworkResponse(data: data, error: nil, city: city)
            } catch {
                isLoading = false
                handleNetworkResponse(data: nil, error: error, city: city)
            }
        }
    }
    
    // REFACTORED: Exercise 3 - Extracted response handling logic
    // BENEFIT: Business logic separated from network mechanics
    open func handleNetworkResponse(data: Data?, error: Error?, city: String) {
        if let error = error {
            handleError("Network error: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else {
            handleError("No data received")
            return
        }
        
        // REFACTORED: Exercise 3 - Extract parsing logic
        do {
            let weatherData = try parseWeatherData(from: data)
            processSuccessfulWeatherFetch(weatherData, for: city)
        } catch {
            handleError("Failed to parse weather data: \(error.localizedDescription)")
        }
    }
    
    // REFACTORED: Exercise 3 - Extracted JSON parsing logic
    // BENEFIT: Pure function - easily testable with sample data
    open func parseWeatherData(from data: Data) throws -> WeatherData {
        let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return WeatherData(
            cityName: weatherResponse.name,
            temperature: weatherResponse.main.temp,
            description: weatherResponse.weather.first?.description ?? "Unknown",
            timestamp: currentTime()
        )
    }
    
    // REFACTORED: Exercise 3 - Extracted success handling logic
    // BENEFIT: Clear single responsibility - handle successful data
    private func processSuccessfulWeatherFetch(_ weatherData: WeatherData, for city: String) {
        currentWeather = weatherData
        cacheWeatherData(weatherData, for: city)
        logMessage("Weather fetched successfully for \(city)")
    }
    
    // MARK: - Caching Logic (poorly implemented)
    
    private func getCachedWeatherIfValid(for city: String) -> WeatherData? {
        // ANTI-PATTERN: Complex caching logic mixed with business rules
        guard let cachedData = self.cachedData,
              let cachedCity = self.cachedCity,
              let timestamp = self.cacheTimestamp else {
            return nil
        }
        
        // ANTI-PATTERN: Time logic scattered, not testable
        let timeSinceCache = currentTime().timeIntervalSince(timestamp)
        let isCacheValid = timeSinceCache < CACHE_DURATION
        let isSameCity = cachedCity.lowercased() == city.lowercased()
        
        return (isCacheValid && isSameCity) ? cachedData : nil
    }
    
    private func cacheWeatherData(_ data: WeatherData, for city: String) {
        // ANTI-PATTERN: No thread safety, no size limits
        cachedData = data
        cachedCity = city
        cacheTimestamp = currentTime()
        
        logMessage("Cached weather data for \(city)")
    }
    
    private func clearCache() {
        cachedData = nil
        cachedCity = nil
        cacheTimestamp = nil
        isCelsius = true // ANTI-PATTERN: Reset temperature unit randomly
        logMessage("Cache cleared")
    }
    
    // MARK: - Utility Methods (should be elsewhere)
    
    private func updateTemperatureDisplay() {
        // ANTI-PATTERN: Unnecessary work due to poor architecture
        if currentWeather != nil {
            objectWillChange.send() // Force UI update
        }
    }
    
    // REFACTORED: Made open so tests can override and avoid network calls in init
    open func loadInitialData() {
        // ANTI-PATTERN: Network call in init
        fetchWeather(for: getCurrentCity())
    }
    
    // MARK: - Error Handling (inconsistent)
    
    private func handleError(_ message: String) {
        errorMessage = message
        logMessage("ERROR: \(message)")
        
        // ANTI-PATTERN: Side effects in error handler
        isLoading = false
        currentWeather = nil
    }
    
    // MARK: - Seams for Testing (dependency breaking techniques)
    
    // REFACTORED: Time dependency now uses injected provider (Exercise 2)
    // BEFORE: return Date() - always current time, untestable
    // AFTER: uses timeProvider - controllable in tests
    open func currentTime() -> Date {
        return timeProvider.currentTime()
    }
    
    // Seam: Logging dependency - can be overridden in tests  
    open func logMessage(_ message: String) {
        print("[WeatherSingleton] \(message)")
    }
}

// MARK: - Data Models (should be in separate files)

struct WeatherData {
    let cityName: String
    let temperature: Double
    let description: String  
    let timestamp: Date
}

// MARK: - Network Models (should be in separate files)

struct WeatherResponse: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
    
    struct Main: Codable {
        let temp: Double
    }
    
    struct Weather: Codable {
        let description: String
    }
}