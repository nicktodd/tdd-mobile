//
//  Constants.swift  
//  LegacyWeatherSwift
//
//  Another anti-pattern: Poorly organized constants scattered everywhere
//  This file demonstrates how NOT to organize application constants

import Foundation

// ANTI-PATTERN: Random constants mixed together with no logical grouping
let MYSTERIOUS_CACHE_MULTIPLIER = 1.5 // What does this do? Nobody knows!
let SOME_ANIMATION_DURATION: Double = 0.42 // Why 0.42? Historical reasons...

// ANTI-PATTERN: Mixed data types and purposes
class AppConstants {
    // Network related (sort of)
    static let DEFAULT_TIMEOUT = 30.0
    static let RETRY_COUNT = 3
    static let API_VERSION = "2.5" // Hardcoded API version
    
    // UI related (mixed in randomly) 
    static let BUTTON_CORNER_RADIUS: CGFloat = 8.0
    static let LOADING_ANIMATION_SPEED = 1.2
    static let ERROR_DISPLAY_DURATION = 3.0
    
    // Business logic constants (scattered)
    static let MIN_TEMPERATURE = -273.15 // Absolute zero in Celsius
    static let MAX_CACHE_SIZE = 50 // Number of cached items
    static let TEMPERATURE_PRECISION = 1 // Decimal places
    
    // Random magic numbers with no explanation
    static let MAGIC_OFFSET = 42 // Don't change this, the app will break!
    static let ANOTHER_MAGIC_NUMBER = 1.618 // Golden ratio? Or is it?
    static let BUFFER_SIZE = 1024 * 8 // Why 8KB? Lost in history...
    
    // Error messages (should be localized but aren't)
    static let NETWORK_ERROR = "Something went wrong with the network"
    static let GENERIC_ERROR = "Oops! An error occurred"
    static let LOADING_MESSAGE = "Please wait while we fetch your data..."
    
    // Feature flags (hardcoded instead of being configurable)
    static let ENABLE_CACHING = true
    static let ENABLE_DEBUG_LOGGING = true // This should not be hardcoded!
    static let ENABLE_CRASH_REPORTING = false
    
    // App configuration (mixed with constants)
    static let APP_NAME = "Legacy Weather"
    static let VERSION = "1.0.0" // Should be read from Info.plist
    static let BUILD_NUMBER = "42" // Should be read from Info.plist
}

// ANTI-PATTERN: Another constants container with overlapping purposes
struct WeatherConstants {
    // API related
    static let BASE_URL = "https://api.openweathermap.org/data/2.5"
    static let WEATHER_ENDPOINT = "/weather"
    static let UNITS_METRIC = "metric"
    static let UNITS_IMPERIAL = "imperial"
    
    // Default cities (business logic in constants!)
    static let DEFAULT_CITIES = ["London", "New York", "Tokyo", "Sydney", "Paris"]
    static let FALLBACK_CITY = "London"
    
    // Cache configuration (should be configurable)
    static let CACHE_DURATION: TimeInterval = 300 // 5 minutes
    static let MAX_CACHE_AGE: TimeInterval = 3600 // 1 hour
    
    // UI constants mixed in
    static let REFRESH_ANIMATION_DURATION = 1.0
    static let WEATHER_ICON_SIZE: CGFloat = 80.0
}

// ANTI-PATTERN: Global variables pretending to be constants
var globalDebugMode = true // Should not be mutable global state!
var currentEnvironment = "production" // Configuration should be elsewhere

// ANTI-PATTERN: Computed properties that do work (side effects)
struct ProblematicConstants {
    static var currentTimestamp: String {
        // This does work every time it's accessed - not a constant!
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
    
    static var randomValue: Int {
        // Non-deterministic "constant" - very problematic!
        return Int.random(in: 1...100)
    }
}

// ANTI-PATTERN: Constants that should be enums
struct StringConstants {
    static let WEATHER_SUNNY = "sunny"
    static let WEATHER_CLOUDY = "cloudy"  
    static let WEATHER_RAINY = "rainy"
    static let WEATHER_SNOWY = "snowy"
    // These should be an enum for type safety!
}

// ANTI-PATTERN: Platform-specific values hardcoded
struct PlatformConstants {
    // These should be determined at runtime or from system info
    static let IS_IPHONE = true // What about iPad?
    static let SCREEN_WIDTH: CGFloat = 375.0 // What about different screen sizes?
    static let STATUS_BAR_HEIGHT: CGFloat = 44.0 // Changes with device!
}

// The "correct" way would be to organize these properly:
/*

enum TemperatureUnit: String, CaseIterable {
    case celsius = "metric"
    case fahrenheit = "imperial"
}

struct NetworkConfig {
    static let baseURL = URL(string: "https://api.openweathermap.org/data/2.5")!
    static let timeout: TimeInterval = 30.0
    static let retryCount = 3
}

struct CacheConfig {
    static let duration: TimeInterval = 300
    static let maxSize = 50
}

struct UIConstants {
    static let cornerRadius: CGFloat = 8.0
    static let animationDuration: TimeInterval = 0.3
    
    struct Colors {
        static let primaryBlue = Color.blue
        static let errorRed = Color.red
    }
}

*/