//
//  DependencyBreakingExamples.swift
//  LegacyWeatherSwift
//
//  Examples of dependency breaking techniques for legacy Swift code.
//  These patterns help make untestable legacy code testable without major rewrites.

import Foundation

// MARK: - Example 1: Extract and Override Call (Seam Creation)

/**
 Problem: WeatherSingleton has hardcoded dependencies that make testing impossible
 
 Before (Untestable):
 ```
 class WeatherSingleton {
     func fetchWeather() {
         let data = URLSession.shared.dataTask(with: url) { ... } // Hard to test!
         let time = Date() // Always current time - hard to test!
     }
 }
 ```
 
 Solution: Create seams by extracting dependencies into overridable methods
 */

class RefactoredWeatherManager {
    
    // Seam 1: Network dependency - can be overridden in tests
    open func performNetworkRequest(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    // Seam 2: Time dependency - can be overridden in tests
    open func getCurrentTime() -> Date {
        return Date()
    }
    
    // Seam 3: Logging dependency - can be overridden in tests
    open func log(_ message: String) {
        print("[WeatherManager] \(message)")
    }
    
    // Now this method can be tested by overriding the seams
    func fetchWeather(for city: String) {
        let timestamp = getCurrentTime() // Testable!
        log("Fetching weather for \(city) at \(timestamp)") // Testable!
        
        guard let url = buildURL(for: city) else { return }
        
        performNetworkRequest(with: url) { data, response, error in
            // Network call is now testable through the seam
            self.handleNetworkResponse(data: data, response: response, error: error)
        }
    }
    
    private func buildURL(for city: String) -> URL? {
        // URL building logic
        return nil
    }
    
    private func handleNetworkResponse(data: Data?, response: URLResponse?, error: Error?) {
        // Response handling logic
    }
}

// MARK: - Example 2: Subclass and Override Method

/**
 Testing the refactored class using subclass technique:
 */

class TestableWeatherManager: RefactoredWeatherManager {
    
    var mockNetworkData: Data?
    var mockNetworkError: Error?
    var mockCurrentTime: Date?
    var loggedMessages: [String] = []
    
    override func performNetworkRequest(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        // Override to provide test data instead of real network call
        completion(mockNetworkData, nil, mockNetworkError)
    }
    
    override func getCurrentTime() -> Date {
        return mockCurrentTime ?? Date()
    }
    
    override func log(_ message: String) {
        loggedMessages.append(message)
        // Don't print to console in tests
    }
}

// MARK: - Example 3: Extract Interface (Protocol-based Dependency Breaking)

/**
 Problem: Singleton makes different concerns hard to test individually
 
 Solution: Extract protocols to break dependencies
 */

// MARK: - Example Data Model for Dependency Breaking Examples
struct ExampleWeatherData {
    let cityName: String
    let temperature: Double
    let description: String
    let timestamp: Date
}

protocol WeatherNetworkService {
    func fetchWeatherData(for city: String, completion: @escaping (Result<ExampleWeatherData, Error>) -> Void)
}

protocol WeatherCacheService {
    func getCachedWeather(for city: String) -> ExampleWeatherData?
    func cacheWeather(_ data: ExampleWeatherData, for city: String)
    func clearCache()
}

protocol TimeProvider {
    func currentTime() -> Date
}

protocol Logger {
    func log(_ message: String)
}

// Refactored weather manager with injected dependencies
class ModularWeatherManager {
    
    private let networkService: WeatherNetworkService
    private let cacheService: WeatherCacheService  
    private let timeProvider: TimeProvider
    private let logger: Logger
    
    init(networkService: WeatherNetworkService,
         cacheService: WeatherCacheService,
         timeProvider: TimeProvider,
         logger: Logger) {
        self.networkService = networkService
        self.cacheService = cacheService
        self.timeProvider = timeProvider
        self.logger = logger
    }
    
    func fetchWeather(for city: String) {
        logger.log("Fetching weather for \(city)")
        
        // Check cache first
        if let cachedWeather = cacheService.getCachedWeather(for: city) {
            logger.log("Using cached weather for \(city)")
            // Handle cached result - process cachedWeather here
            _ = cachedWeather // Placeholder to avoid unused variable warning
            return
        }
        
        // Fetch from network
        networkService.fetchWeatherData(for: city) { [weak self] (result: Result<ExampleWeatherData, Error>) in
            switch result {
            case .success(let weatherData):
                self?.cacheService.cacheWeather(weatherData, for: city)
                self?.logger.log("Successfully fetched weather for \(city)")
            case .failure(let error):
                self?.logger.log("Failed to fetch weather: \(error)")
            }
        }
    }
}

// Mock implementations for testing
class MockWeatherNetworkService: WeatherNetworkService {
    var mockResult: Result<ExampleWeatherData, Error>?
    
    func fetchWeatherData(for city: String, completion: @escaping (Result<ExampleWeatherData, Error>) -> Void) {
        if let result = mockResult {
            completion(result)
        }
    }
}

class MockWeatherCacheService: WeatherCacheService {
    private var cache: [String: ExampleWeatherData] = [:]
    
    func getCachedWeather(for city: String) -> ExampleWeatherData? {
        return cache[city]
    }
    
    func cacheWeather(_ data: ExampleWeatherData, for city: String) {
        cache[city] = data
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

// MARK: - Example 4: Parameterize Constructor (Legacy Technique)

/**
 Problem: Constructor creates dependencies internally, making testing hard
 
 Before:
 ```
 class WeatherService {
     private let urlSession = URLSession.shared  // Hard-coded dependency
     
     init() {
         // Dependencies created here - can't substitute for testing
     }
 }
 ```
 
 Solution: Add parameters to constructor while maintaining backward compatibility
 */

class ParameterizedWeatherService {
    
    private let urlSession: URLSession
    private let apiKey: String
    
    // Legacy constructor - maintains compatibility
    convenience init() {
        self.init(urlSession: URLSession.shared, apiKey: "default-api-key")
    }
    
    // New constructor - allows dependency injection
    init(urlSession: URLSession, apiKey: String) {
        self.urlSession = urlSession
        self.apiKey = apiKey
    }
    
    func fetchWeather() {
        // Now uses injected URLSession instead of hardcoded one
        // This makes the class testable
    }
}

// MARK: - Example 5: Introduce Static Setter (Quick Dirty Fix)

/**
 Problem: Global state is used throughout the application
 
 Solution: Introduce setter to allow test substitution (not ideal, but works for legacy code)
 */

class GlobalWeatherConfig {
    
    private static var _instance: GlobalWeatherConfig = GlobalWeatherConfig()
    
    // Add setter for testing (breaks singleton pattern intentionally for testing)
    static func setInstance(_ instance: GlobalWeatherConfig) {
        _instance = instance
    }
    
    static var shared: GlobalWeatherConfig {
        return _instance
    }
    
    var apiKey: String = "production-key"
    var baseURL: String = "https://api.openweathermap.org"
    
    // Make init internal so it can be overridden for testing
    init() {}
}

// Test usage:
class TestableGlobalWeatherConfig: GlobalWeatherConfig {
    override init() {
        super.init()
        self.apiKey = "test-key"
        self.baseURL = "https://test-api.example.com"
    }
}

// In tests:
func setupTestConfig() {
    GlobalWeatherConfig.setInstance(TestableGlobalWeatherConfig())
}

// MARK: - Refactoring Progression Examples

/**
 Example progression from legacy singleton to testable code:
 
 Stage 1: Legacy Singleton (Current State)
 - Everything in one class
 - Hard dependencies
 - No tests possible
 
 Stage 2: Add Seams (Minimal Change)
 - Extract methods for dependencies  
 - Make methods 'open' for overriding
 - Can write characterization tests
 
 Stage 3: Extract Protocols (Moderate Change)
 - Define interfaces for major dependencies
 - Implement protocols with legacy behavior
 - Can inject test doubles
 
 Stage 4: Full Modularization (Major Change)
 - Separate concerns into different classes
 - Constructor injection
 - Pure unit testing possible
 */