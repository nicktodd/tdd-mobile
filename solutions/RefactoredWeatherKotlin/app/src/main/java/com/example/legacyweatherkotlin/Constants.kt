package com.example.legacyweatherkotlin

/**
 * Constants - Another Anti-Pattern Example
 * This file shows how NOT to organize constants:
 * - Mixed concerns (UI, business, network all together)
 * - No logical grouping
 * - Magic numbers without explanation
 * - Inconsistent naming
 */

// Network related constants mixed with UI constants
const val API_KEY_PLACEHOLDER = "your_api_key_here_exposed_in_code"
const val BASE_URL_WEATHER = "https://api.openweathermap.org/data/2.5/"
const val CACHE_DURATION = 300000 // What unit? Milliseconds? Who knows!
const val MAX_CITY_NAME_LENGTH = 50

// UI Colors as hardcoded hex values - should be in resources
const val HOT_WEATHER_COLOR = 0xFFFF5722
const val COLD_WEATHER_COLOR = 0xFF2196F3
const val ERROR_COLOR = 0xFFD32F2F
const val GRAY_TEXT_COLOR = 0xFF757575

// Temperature thresholds - mixed units and no documentation
const val VERY_HOT_THRESHOLD = 305 // Kelvin? Celsius? Fahrenheit?
const val HOT_THRESHOLD = 300
const val WARM_THRESHOLD = 295
const val MILD_THRESHOLD = 285
const val COOL_THRESHOLD = 275
const val COLD_THRESHOLD = 265

// Wind speed thresholds
const val VERY_WINDY_SPEED = 15 // m/s? mph? km/h?
const val BREEZY_SPEED = 8

// Humidity threshold
const val HIGH_HUMIDITY = 80 // Percentage

// UI sizing constants that should be in dimens.xml
const val WEATHER_ICON_SIZE = 60 // dp
const val PROGRESS_INDICATOR_SIZE = 48
const val SMALL_PROGRESS_SIZE = 16
const val CARD_ELEVATION = 4
const val LARGE_CARD_ELEVATION = 8

// Default cities - hardcoded business logic
val DEFAULT_CITIES_LIST = listOf(
    "London",    // Why London first?
    "New York",  // Why these specific cities?
    "Tokyo", 
    "Sydney", 
    "Paris"
)

// Error messages as constants - should be in strings.xml
const val EMPTY_RESPONSE_ERROR = "Empty response from server"
const val NETWORK_ERROR_PREFIX = "Network error: "
const val INVALID_CITY_ERROR = "Invalid city name!"
const val CITY_TOO_LONG_ERROR = "City name too long!"
const val ENTER_CITY_ERROR = "Please enter a city name!"
const val ENTER_VALID_CITY_ERROR = "Please enter a valid city name!"

// Toast messages - more hardcoded strings
const val REFRESHING_MESSAGE = "Refreshing weather..."
const val SEARCHING_PREFIX = "Searching for "
const val LOADING_PREFIX = "Loading weather for "
const val RETRYING_MESSAGE = "Retrying..."
const val UNIT_SWITCHED_MESSAGE = "Switched to "

// Weather condition mappings - business logic as constants
val SUNNY_ICONS = listOf("01d", "01n")
val PARTLY_CLOUDY_ICONS = listOf("02d", "02n")
val CLOUDY_ICONS = listOf("03d", "03n", "04d", "04n")
val RAINY_ICONS = listOf("09d", "09n", "10d", "10n")
val THUNDERSTORM_ICONS = listOf("11d", "11n")
val SNOW_ICONS = listOf("13d", "13n")
val MIST_ICONS = listOf("50d", "50n")

// More magic numbers
const val MIN_CITY_NAME_LENGTH = 2
const val PROGRESS_STROKE_WIDTH = 2
const val LARGE_PROGRESS_STROKE_WIDTH = 4
const val WEATHER_ICON_CORNER_RADIUS = 30

// Date format pattern - should be localized
const val DATE_FORMAT_PATTERN = "MMM dd, yyyy"
const val TIME_FORMAT_PATTERN = "HH:mm"

// Weather advice thresholds with no context
const val EXTREMELY_HOT_CELSIUS = 35
const val VERY_HOT_CELSIUS = 30
const val WARM_CELSIUS = 25
const val MILD_CELSIUS = 15
const val COOL_CELSIUS = 5
const val COLD_CELSIUS = -5