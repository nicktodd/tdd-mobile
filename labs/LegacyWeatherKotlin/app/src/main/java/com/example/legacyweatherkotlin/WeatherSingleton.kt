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
 */
object WeatherSingleton {
    
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
    private val retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .addConverterFactory(GsonConverterFactory.create())
        .build()
    
    private val weatherService = retrofit.create(WeatherService::class.java)
    
    // Initialize method that takes context - singleton with dependencies!
    fun init(context: Context) {
        logMessage("WeatherSingleton", "Initializing weather singleton with context")
        // Could store context here - memory leak waiting to happen!
    }
    
    // SEAM: Time provider - can be overridden in tests
    open fun getCurrentTime(): Long {
        return System.currentTimeMillis()
    }
    
    // SEAM: Logging - can be overridden to capture logs in tests  
    open fun logMessage(tag: String, message: String) {
        Log.d(tag, message)
    }
    
    // SEAM: Network calls - can be overridden to avoid real network in tests
    open fun performNetworkCall(call: Call<WeatherResponse>, callback: Callback<WeatherResponse>) {
        call.enqueue(callback)
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
        
        // Direct network call in singleton - using seam for testability
        val call = weatherService.getCurrentWeather(city, API_KEY)
        performNetworkCall(call, object : Callback<WeatherResponse> { // SEAM: Using overridable network call
            override fun onResponse(call: Call<WeatherResponse>, response: Response<WeatherResponse>) {
                if (response.isSuccessful) {
                    val weatherResponse = response.body()
                    if (weatherResponse != null) {
                        // Business logic mixed with network response handling
                        val weatherData = WeatherData(
                            city = weatherResponse.name,
                            temperature = weatherResponse.main.temp,
                            description = weatherResponse.weather[0].description.capitalize(),
                            humidity = weatherResponse.main.humidity,
                            windSpeed = weatherResponse.wind.speed,
                            icon = weatherResponse.weather[0].icon,
                            feelsLike = weatherResponse.main.feels_like,
                            pressure = weatherResponse.main.pressure
                        )
                        
                        // Update global state
                        currentWeather.value = weatherData
                        cachedData = weatherData
                        cachedCity = city // Store which city this data is for
                        lastFetchTime = now
                        updateLastUpdatedTime()
                        
                        logMessage("WeatherSingleton", "Weather data updated successfully") // SEAM: Using overridable logging
                    } else {
                        handleError("Empty response from server")
                    }
                } else {
                    // Poor error handling
                    handleError("Error: ${response.code()} - ${response.message()}")
                }
                isLoading.value = false
            }
            
            override fun onFailure(call: Call<WeatherResponse>, t: Throwable) {
                handleError("Network error: ${t.message}")
                isLoading.value = false
                logMessage("WeatherSingleton", "Network error: ${t.message}") // SEAM: Using overridable logging
            }
        })
    }
    
    // Business logic mixed in singleton
    fun getTemperatureString(): String {
        val temp = currentWeather.value?.temperature ?: return "N/A"
        return if (isCelsius.value) { // Fixed: Now reads from mutableStateOf
            "${(temp - 273.15).toInt()}°C"
        } else {
            "${((temp - 273.15) * 9/5 + 32).toInt()}°F"
        }
    }
    
    fun getFeelsLikeString(): String {
        val temp = currentWeather.value?.feelsLike ?: return "N/A"
        return if (isCelsius.value) { // Fixed: Now reads from mutableStateOf
            "Feels like ${(temp - 273.15).toInt()}°C"
        } else {
            "Feels like ${((temp - 273.15) * 9/5 + 32).toInt()}°F"
        }
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
    
    // Date formatting logic in singleton - SEAM: Uses overridable time method
    private fun updateLastUpdatedTime() {
        val formatter = SimpleDateFormat("HH:mm", Locale.getDefault())
        val currentTime = Date(getCurrentTime()) // SEAM: Using overridable time
        lastUpdated.value = "Last updated: ${formatter.format(currentTime)}"
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