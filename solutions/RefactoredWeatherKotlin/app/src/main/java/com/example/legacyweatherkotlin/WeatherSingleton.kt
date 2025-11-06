package com.example.legacyweatherkotlin

import android.content.Context
import android.util.Log
import androidx.compose.runtime.mutableStateOf
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Query
import java.text.SimpleDateFormat
import java.util.*

// REFACTORING APPLIED: Exercise 2 - Time Dependency Seam
// BEFORE: WeatherSingleton directly calls System.currentTimeMillis() making it untestable  
// AFTER: Time dependency is abstracted behind TimeProvider interface

// MARK: - Time Dependency Abstraction (Exercise 2)

/**
 * Time dependency abstraction interface
 * BENEFIT: Allows deterministic testing by injecting controllable time provider
 */
interface TimeProvider {
    fun currentTimeMillis(): Long
    fun currentDate(): Date = Date(currentTimeMillis())
}

/**
 * Real implementation using system time
 * NOTE: Mock implementations belong in test files, not production code
 */
class SystemTimeProvider : TimeProvider {
    override fun currentTimeMillis(): Long = System.currentTimeMillis()
}

// MARK: - Network Dependency Abstraction (Exercise 4)

/**
 * Network dependency abstraction interface
 * BENEFIT: Allows testing without real network calls, fast and reliable tests
 * PATTERN: Interface segregation - single responsibility for weather network operations
 */
interface WeatherNetworkService {
    /**
     * Fetch weather data for a city
     * @param city The city name to fetch weather for
     * @param apiKey The API key for authentication
     * @param callback The callback to handle success or failure
     * BENEFIT: Async operation with clear success/failure handling
     */
    fun fetchWeather(
        city: String,
        apiKey: String,
        callback: (Result<WeatherResponse>) -> Unit
    )
}

/**
 * Real implementation using Retrofit
 * NOTE: Mock implementations belong in test files, not production code
 * PATTERN: Adapter pattern - wraps Retrofit's callback API into our interface
 */
class RetrofitWeatherNetworkService(private val weatherService: WeatherService) : WeatherNetworkService {
    override fun fetchWeather(
        city: String,
        apiKey: String,
        callback: (Result<WeatherResponse>) -> Unit
    ) {
        val call = weatherService.getCurrentWeather(city, apiKey)
        call.enqueue(object : Callback<WeatherResponse> {
            override fun onResponse(call: Call<WeatherResponse>, response: Response<WeatherResponse>) {
                if (response.isSuccessful && response.body() != null) {
                    callback(Result.success(response.body()!!))
                } else {
                    callback(Result.failure(Exception("HTTP ${response.code()}: ${response.message()}")))
                }
            }
            
            override fun onFailure(call: Call<WeatherResponse>, t: Throwable) {
                callback(Result.failure(t))
            }
        })
    }
}

/**
 * WeatherSingleton - The Ultimate Anti-Pattern
 * This class violates pretty much every SOLID principle and does EVERYTHING:
 * - Network calls
 * - Data storage 
 * - Business logic
 * - UI state management
 * - Error handling (poorly)
 * - Date formatting
 * - Temperature conversion
 * - Caching (badly)
 * 
 * NOTE: Some methods have been made 'open' to allow for testing via inheritance.
 * This is a legacy technique called "Subclass and Override Method" for dependency breaking.
 * 
 * SEAMS FOR TESTING (Dependency Breaking Points):
 * - getCurrentTime(): Can be overridden to control time in tests
 * - performNetworkCall(): Can be overridden to avoid real network calls
 * - logMessage(): Can be overridden to capture log output in tests
 * 
 * REFACTORED: Exercise 2 - Time dependency injection added
 * REFACTORED: Exercise 4 - Network dependency injection added
 */
object WeatherSingleton {
    
    // REFACTORED: Exercise 2 - Injected time dependency
    // This allows us to control time in tests, making the class testable
    private var timeProvider: TimeProvider = SystemTimeProvider()
    
    // Factory method to set time provider (primarily for testing)
    fun setTimeProvider(provider: TimeProvider) {
        timeProvider = provider
    }
    
    // REFACTORED: Exercise 4 - Injected network dependency
    // This allows us to test network interactions without real HTTP calls
    // Lazy initialization to avoid creating Retrofit instance unnecessarily in tests
    private var networkService: WeatherNetworkService? = null
    
    // Factory method to set network service (primarily for testing)
    fun setNetworkService(service: WeatherNetworkService) {
        networkService = service
    }
    
    // Factory method to reset network service to default (useful after tests)
    fun resetNetworkService() {
        networkService = null
    }
    
    // Flag to suppress logging in unit tests (Android Log not available in unit tests)
    // Using var with public visibility allows direct assignment in tests
    var suppressLogging = false
    
    // Hard-coded API key - security nightmare!
    private const val API_KEY = "aaef9b932f92edd04d656cdff0468dd0"
    private const val BASE_URL = "https://api.openweathermap.org/data/2.5/"
    
    // Global mutable state - thread safety nightmare!
    var currentWeather = mutableStateOf<WeatherData?>(null)
    var isLoading = mutableStateOf(false)
    var errorMessage = mutableStateOf("")
    var lastUpdated = mutableStateOf("")
    
    // More global state - mixing mutableStateOf with regular variables (inconsistent!)
    var isCelsius = mutableStateOf(true) // Fixed: Now observable by Compose
    var currentCity = "London" // Hard-coded default
    var cachedData: WeatherData? = null
    var cachedCity: String? = null // Track which city data is cached for
    var lastFetchTime = 0L
    
    // Retrofit instance created in singleton - poor lifecycle management
    // REFACTORED: Exercise 4 - Now lazily initialized only when needed
    private val retrofit by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }
    
    private val weatherService by lazy { 
        retrofit.create(WeatherService::class.java)
    }
    
    // REFACTORED: Exercise 4 - Get network service (injected or default)
    // BENEFIT: Tests can inject mock service, production uses real Retrofit
    private fun getNetworkService(): WeatherNetworkService {
        return networkService ?: RetrofitWeatherNetworkService(weatherService)
    }
    
    // Initialize method that takes context - singleton with dependencies!
    fun init(context: Context) {
        logMessage("WeatherSingleton", "Initializing weather singleton with context")
        // Could store context here - memory leak waiting to happen!
    }
    
    // REFACTORED: Exercise 2 - Time provider now uses injected dependency
    // BENEFIT: Tests can inject MockTimeProvider for deterministic time control
    open fun getCurrentTime(): Long {
        return timeProvider.currentTimeMillis()
    }
    
    // Additional helper for getting Date object
    fun getCurrentDate(): Date {
        return timeProvider.currentDate()
    }
    
    // SEAM: Logging - can be overridden to capture logs in tests  
    open fun logMessage(tag: String, message: String) {
        if (!suppressLogging) {
            Log.d(tag, message)
        }
    }
    
    // SEAM: Network calls - can be overridden to avoid real network in tests
    open fun performNetworkCall(call: Call<WeatherResponse>, callback: Callback<WeatherResponse>) {
        call.enqueue(callback)
    }
    
    // REFACTORED: Exercise 3 - Extracted data parsing methods
    // BENEFIT: Business logic separated from network/state management
    
    /**
     * Parse WeatherResponse into WeatherData domain object
     * BENEFIT: Pure transformation logic, easy to test without network calls
     */
    fun parseWeatherResponse(response: WeatherResponse): WeatherData {
        return WeatherData(
            city = response.name,
            temperature = response.main.temp,
            description = capitalizeDescription(response.weather[0].description),
            humidity = response.main.humidity,
            windSpeed = response.wind.speed,
            icon = response.weather[0].icon,
            feelsLike = response.main.feels_like,
            pressure = response.main.pressure
        )
    }
    
    /**
     * Capitalize weather description
     * BENEFIT: Simple string formatting logic, easily testable
     */
    fun capitalizeDescription(description: String): String {
        return description.split(" ")
            .joinToString(" ") { word ->
                word.replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
            }
    }
    
    /**
     * Build weather API URL (for future use if moving away from Retrofit)
     * BENEFIT: URL construction logic can be tested independently
     */
    fun buildWeatherUrl(city: String): String {
        return "${BASE_URL}weather?q=$city&appid=$API_KEY&units=standard"
    }

    fun fetchWeather(city: String = currentCity) {
        currentCity = city
        isLoading.value = true
        errorMessage.value = ""
        
        // Poor caching logic mixed in business logic - FIXED: Now checks city AND time
        val now = getCurrentTime() // SEAM: Using overridable time method
        if (cachedData != null && 
            cachedCity == city && // Check if cached data is for the same city
            now - lastFetchTime < 300000) { // 5 minutes
            currentWeather.value = cachedData
            isLoading.value = false
            updateLastUpdatedTime()
            return
        }
        
        logMessage("WeatherSingleton", "Fetching weather for $city") // SEAM: Using overridable logging
        
        // REFACTORED: Exercise 4 - Using injected network service
        // BENEFIT: Tests can inject mock service for fast, reliable testing
        getNetworkService().fetchWeather(city, API_KEY) { result ->
            result.fold(
                onSuccess = { weatherResponse ->
                    // REFACTORED: Using extracted parsing method
                    val weatherData = parseWeatherResponse(weatherResponse)
                    
                    // Update global state
                    currentWeather.value = weatherData
                    cachedData = weatherData
                    cachedCity = city // Store which city this data is for
                    lastFetchTime = now
                    updateLastUpdatedTime()
                    
                    logMessage("WeatherSingleton", "Weather data updated successfully") // SEAM: Using overridable logging
                    isLoading.value = false
                },
                onFailure = { error ->
                    handleError("Network error: ${error.message}")
                    logMessage("WeatherSingleton", "Network error: ${error.message}") // SEAM: Using overridable logging
                    isLoading.value = false
                }
            )
        }
    }
    
    // REFACTORED: Exercise 3 - Extracted temperature conversion methods
    // BENEFIT: Pure functions that are easy to test in isolation
    
    /**
     * Convert temperature from Kelvin to Celsius
     * BENEFIT: Pure function, no dependencies, easy to test
     */
    fun kelvinToCelsius(kelvin: Double): Double {
        return kelvin - 273.15
    }
    
    /**
     * Convert temperature from Kelvin to Fahrenheit
     * BENEFIT: Pure function, no dependencies, easy to test
     */
    fun kelvinToFahrenheit(kelvin: Double): Double {
        return (kelvin - 273.15) * 9 / 5 + 32
    }
    
    /**
     * Convert temperature based on current unit preference
     * BENEFIT: Extracted conversion logic can be tested independently
     */
    fun convertTemperature(kelvin: Double, toCelsius: Boolean): Double {
        return if (toCelsius) kelvinToCelsius(kelvin) else kelvinToFahrenheit(kelvin)
    }
    
    /**
     * Get temperature unit symbol
     * BENEFIT: Simple, testable business logic extraction
     */
    fun getTemperatureUnit(isCelsius: Boolean): String {
        return if (isCelsius) "°C" else "°F"
    }
    
    /**
     * Format temperature with unit
     * BENEFIT: Formatting logic separated from conversion logic
     */
    fun formatTemperature(kelvin: Double, isCelsius: Boolean): String {
        val converted = convertTemperature(kelvin, isCelsius)
        val unit = getTemperatureUnit(isCelsius)
        return "${converted.toInt()}$unit"
    }
    
    // Business logic using extracted methods
    fun getTemperatureString(): String {
        val temp = currentWeather.value?.temperature ?: return "N/A"
        return formatTemperature(temp, isCelsius.value)
    }
    
    fun getFeelsLikeString(): String {
        val temp = currentWeather.value?.feelsLike ?: return "N/A"
        return "Feels like ${formatTemperature(temp, isCelsius.value)}"
    }
    
    // More business logic
    fun toggleTemperatureUnit() {
        isCelsius.value = !isCelsius.value // Fixed: Now updates mutableStateOf properly
    }
    
    fun getHumidityString(): String {
        return "${currentWeather.value?.humidity ?: 0}%"
    }
    
    fun getWindSpeedString(): String {
        val windSpeed = currentWeather.value?.windSpeed ?: return "N/A"
        return "${windSpeed} m/s"
    }
    
    fun getPressureString(): String {
        return "${currentWeather.value?.pressure ?: 0} hPa"
    }
    
    // Date formatting logic in singleton - REFACTORED: Uses injected time provider
    private fun updateLastUpdatedTime() {
        val formatter = SimpleDateFormat("HH:mm", Locale.getDefault())
        val currentTime = Date(getCurrentTime()) // REFACTORED: Uses TimeProvider
        lastUpdated.value = "Last updated: ${formatter.format(currentTime)}"
    }
    
    // Public method for testing date formatting
    fun getLastUpdatedTime(): String {
        val formatter = SimpleDateFormat("MMM dd, yyyy HH:mm", Locale.getDefault())
        return formatter.format(getCurrentDate())
    }
    
    // Error handling mixed with state management - SEAM: Uses overridable logging
    private fun handleError(message: String) {
        errorMessage.value = message
        logMessage("WeatherSingleton", "ERROR: $message") // SEAM: Using overridable logging
    }
    
    // Method to refresh - but just calls fetchWeather with side effects
    fun refreshWeather() {
        cachedData = null // Clear cache
        cachedCity = null // Clear cached city
        fetchWeather()
    }
    
    // Method to clear all data - but modifies global state
    fun clearWeatherData() {
        currentWeather.value = null
        cachedData = null
        cachedCity = null // Clear cached city
        errorMessage.value = ""
        lastUpdated.value = ""
        lastFetchTime = 0L
        isLoading.value = false // Reset loading state
        isCelsius.value = true // Reset temperature unit to default
    }
}

// Data classes mixed with singleton file - poor organization
data class WeatherData(
    val city: String,
    val temperature: Double,
    val description: String,
    val humidity: Int,
    val windSpeed: Double,
    val icon: String,
    val feelsLike: Double,
    val pressure: Int
)

// API response classes in same file - no separation of concerns
data class WeatherResponse(
    val name: String,
    val main: Main,
    val weather: List<Weather>,
    val wind: Wind
)

data class Main(
    val temp: Double,
    val feels_like: Double,
    val humidity: Int,
    val pressure: Int
)

data class Weather(
    val main: String,
    val description: String,
    val icon: String
)

data class Wind(
    val speed: Double
)

// Retrofit service interface in same file - more poor organization
interface WeatherService {
    @GET("weather")
    fun getCurrentWeather(
        @Query("q") cityName: String,
        @Query("appid") apiKey: String
    ): Call<WeatherResponse>
}