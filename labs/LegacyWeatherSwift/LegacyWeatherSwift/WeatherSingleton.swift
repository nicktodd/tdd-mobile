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

// MARK: - The God Singleton Anti-Pattern
class WeatherSingleton: ObservableObject {
    static let shared = WeatherSingleton()
    
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
    
    private init() {
        // ANTI-PATTERN: Work in initializer
        loadInitialData()
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
        
        // ANTI-PATTERN: Business logic scattered throughout
        let convertedTemp = isCelsius ? temp : (temp * 9/5) + 32
        let unit = isCelsius ? "°C" : "°F"
        
        // ANTI-PATTERN: Inconsistent formatting
        return String(format: "%.0f%@", convertedTemp, unit)
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
        // ANTI-PATTERN: Check cache in wrong place
        if let cached = getCachedWeatherIfValid(for: city) {
            logMessage("Using cached data for \(city)")
            currentWeather = cached
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // ANTI-PATTERN: URL construction in business logic
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(BASE_URL)?q=\(encodedCity)&appid=\(API_KEY)&units=metric") else {
            handleError("Invalid city name: \(city)")
            return
        }
        
        // ANTI-PATTERN: URLSession used directly, no abstraction
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.handleError("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self?.handleError("No data received")
                    return
                }
                
                // ANTI-PATTERN: JSON parsing in wrong layer
                do {
                    let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    let weatherData = WeatherData(
                        cityName: weatherResponse.name,
                        temperature: weatherResponse.main.temp,
                        description: weatherResponse.weather.first?.description ?? "Unknown",
                        timestamp: self?.currentTime() ?? Date()
                    )
                    
                    // ANTI-PATTERN: Multiple responsibilities in one method
                    self?.currentWeather = weatherData
                    self?.cacheWeatherData(weatherData, for: city)
                    self?.logMessage("Weather fetched successfully for \(city)")
                    
                } catch {
                    self?.handleError("Failed to parse weather data: \(error.localizedDescription)")
                }
            }
        }.resume()
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
    
    private func loadInitialData() {
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
    
    // Seam: Time dependency - can be overridden in tests
    open func currentTime() -> Date {
        return Date()
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