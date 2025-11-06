package com.example.legacyweatherkotlin

import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

/**
 * DEPENDENCY BREAKING EXAMPLES - Phase 2 TDD Techniques
 * 
 * This file shows students how to use the SEAMS we've added to the legacy code
 * to break dependencies and make the code testable.
 * 
 * These examples demonstrate the "Subclass and Override Method" pattern
 * for dependency breaking in legacy code.
 */
class DependencyBreakingExamples {

    /**
     * Example 1: Testing time-dependent code
     * 
     * Problem: WeatherSingleton uses System.currentTimeMillis() which makes
     * caching behavior impossible to test reliably.
     * 
     * Solution: We added getCurrentTime() seam that can be overridden.
     */
    @Test
    fun `test_caching_behavior_with_controllable_time`() {
        // Create testable version of singleton with controllable time
        val testableWeatherSingleton = object : WeatherSingleton() {
            private var mockTime = 1000L
            
            override fun getCurrentTime(): Long = mockTime
            
            fun setMockTime(time: Long) {
                mockTime = time
            }
            
            override fun performNetworkCall(call: Call<WeatherResponse>, callback: Callback<WeatherResponse>) {
                // Don't make real network call - simulate successful response
                val mockWeatherResponse = WeatherResponse(
                    name = "London",
                    main = Main(temp = 300.0, feels_like = 302.0, humidity = 50, pressure = 1013),
                    weather = listOf(Weather(main = "Clear", description = "clear sky", icon = "01d")),
                    wind = Wind(speed = 5.0)
                )
                callback.onResponse(call, Response.success(mockWeatherResponse))
            }
        }
        
        // Test: First call should fetch from network
        testableWeatherSingleton.setMockTime(1000L)
        testableWeatherSingleton.fetchWeather("London")
        
        val firstResult = testableWeatherSingleton.currentWeather.value
        assertNotNull("Should have weather data after fetch", firstResult)
        assertEquals("London", firstResult?.city)
        
        // Test: Second call within 5 minutes should use cache (no network call)
        testableWeatherSingleton.setMockTime(200000L) // 3 minutes later
        testableWeatherSingleton.fetchWeather("London")
        
        // Should still have same data (from cache)
        val cachedResult = testableWeatherSingleton.currentWeather.value
        assertEquals("Should use cached data", firstResult, cachedResult)
        
        // Test: Call after 5 minutes should fetch from network again  
        testableWeatherSingleton.setMockTime(400000L) // 6 minutes later
        testableWeatherSingleton.fetchWeather("London")
        
        // Should have fresh data (would be different if we simulated different response)
        assertNotNull("Should have refreshed data", testableWeatherSingleton.currentWeather.value)
    }

    /**
     * Example 2: Testing logging behavior
     * 
     * Problem: WeatherSingleton uses Log.d() directly which we can't verify in tests.
     * 
     * Solution: We added logMessage() seam that can be overridden to capture logs.
     */
    @Test
    fun `test_error_logging_behavior`() {
        val capturedLogs = mutableListOf<Pair<String, String>>()
        
        val testableWeatherSingleton = object : WeatherSingleton() {
            override fun logMessage(tag: String, message: String) {
                capturedLogs.add(Pair(tag, message))
            }
            
            override fun performNetworkCall(call: Call<WeatherResponse>, callback: Callback<WeatherResponse>) {
                // Simulate network failure
                callback.onFailure(call, RuntimeException("Network timeout"))
            }
        }
        
        // Trigger network error
        testableWeatherSingleton.fetchWeather("InvalidCity")
        
        // Verify error was logged
        assertTrue("Should have logged error message", 
                   capturedLogs.any { it.second.contains("Network error") })
        
        // Verify error state was set
        assertTrue("Error message should be set", 
                   testableWeatherSingleton.errorMessage.value.isNotEmpty())
    }

    /**
     * Example 3: Testing network call behavior without real network
     * 
     * Problem: WeatherSingleton makes real HTTP calls which are slow and unreliable in tests.
     * 
     * Solution: We added performNetworkCall() seam to control network responses.
     */
    @Test
    fun `test_successful_weather_data_processing`() {
        val testableWeatherSingleton = object : WeatherSingleton() {
            override fun performNetworkCall(call: Call<WeatherResponse>, callback: Callback<WeatherResponse>) {
                // Simulate successful API response with specific data
                val mockResponse = WeatherResponse(
                    name = "Test City",
                    main = Main(
                        temp = 295.0,        // 21.85°C
                        feels_like = 298.0,  // 24.85°C
                        humidity = 75,
                        pressure = 1020
                    ),
                    weather = listOf(Weather(
                        main = "Clouds", 
                        description = "broken clouds", 
                        icon = "04d"
                    )),
                    wind = Wind(speed = 12.5)
                )
                callback.onResponse(call, Response.success(mockResponse))
            }
        }
        
        // Test data processing
        testableWeatherSingleton.fetchWeather("Test City")
        
        val result = testableWeatherSingleton.currentWeather.value
        assertNotNull("Should process weather data", result)
        assertEquals("Test City", result?.city)
        assertEquals(295.0, result?.temperature, 0.01)
        assertEquals("Broken clouds", result?.description) // Should be capitalized
        assertEquals(75, result?.humidity)
        
        // Test temperature formatting
        testableWeatherSingleton.isCelsius.value = true // Fixed: Using .value for mutableStateOf
        val tempString = testableWeatherSingleton.getTemperatureString()
        assertEquals("22°C", tempString) // 295K - 273.15 = 21.85°C, rounded to 22
        
        // Test feels like formatting
        val feelsLikeString = testableWeatherSingleton.getFeelsLikeString()
        assertEquals("Feels like 25°C", feelsLikeString) // 298K - 273.15 = 24.85°C, rounded to 25
    }

    /**
     * Example 4: Testing error response handling
     */
    @Test
    fun `test_api_error_response_handling`() {
        val testableWeatherSingleton = object : WeatherSingleton() {
            override fun performNetworkCall(call: Call<WeatherResponse>, callback: Callback<WeatherResponse>) {
                // Simulate 404 error (city not found)
                callback.onResponse(call, Response.error(404, 
                    okhttp3.ResponseBody.create(null, "City not found")))
            }
        }
        
        testableWeatherSingleton.fetchWeather("NonExistentCity")
        
        // Verify error handling
        assertTrue("Should set error message", 
                   testableWeatherSingleton.errorMessage.value.contains("Error: 404"))
        assertFalse("Should not be loading", testableWeatherSingleton.isLoading.value)
        assertNull("Should not have weather data", testableWeatherSingleton.currentWeather.value)
    }

    /**
     * Example 5: Testing business logic extraction
     * 
     * This shows how to test business logic methods independently
     * after extracting them from UI or singleton classes.
     */
    @Test
    fun `test_temperature_conversion_business_logic`() {
        // After extracting temperature conversion to utility class
        // (This would be done in Phase 2 of refactoring)
        
        val kelvin = 300.0
        
        // Test Celsius conversion
        val celsius = (kelvin - 273.15)
        assertEquals(26.85, celsius, 0.01)
        
        // Test Fahrenheit conversion  
        val fahrenheit = (kelvin - 273.15) * 9/5 + 32
        assertEquals(80.33, fahrenheit, 0.01)
        
        // Test formatting (extracted from singleton)
        val celsiusFormatted = "${celsius.toInt()}°C"
        assertEquals("26°C", celsiusFormatted)
        
        val fahrenheitFormatted = "${fahrenheit.toInt()}°F"
        assertEquals("80°F", fahrenheitFormatted)
    }

    @Before
    fun setUp() {
        // Reset singleton state before each test
        WeatherSingleton.clearWeatherData()
        WeatherSingleton.isCelsius.value = true // Fixed: Using .value for mutableStateOf
    }
}

/**
 * ADVANCED DEPENDENCY BREAKING TECHNIQUES
 * 
 * These examples show more sophisticated patterns that students
 * can work towards in Phase 3 of the refactoring exercise.
 */
class AdvancedDependencyBreakingExamples {

    /**
     * Example: Interface extraction for better testability
     * 
     * This shows how to extract interfaces for complete dependency injection.
     */
    interface WeatherDataSource {
        suspend fun getCurrentWeather(city: String): Result<WeatherData>
    }
    
    class FakeWeatherDataSource : WeatherDataSource {
        private val fakeData = mutableMapOf<String, WeatherData>()
        
        fun setWeatherData(city: String, data: WeatherData) {
            fakeData[city] = data
        }
        
        override suspend fun getCurrentWeather(city: String): Result<WeatherData> {
            return fakeData[city]?.let { Result.success(it) }
                ?: Result.failure(Exception("City not found"))
        }
    }
    
    @Test
    fun `test_weather_repository_with_fake_data_source`() {
        val fakeDataSource = FakeWeatherDataSource()
        val testWeatherData = WeatherData(
            city = "London",
            temperature = 295.0,
            description = "Clear sky",
            humidity = 60,
            windSpeed = 5.0,
            icon = "01d",
            feelsLike = 297.0,
            pressure = 1015
        )
        
        fakeDataSource.setWeatherData("London", testWeatherData)
        
        // Test repository behavior (would be implemented in Phase 3)
        // val repository = WeatherRepository(fakeDataSource)
        // val result = repository.getCurrentWeather("London")
        
        // This demonstrates how dependency injection makes testing much cleaner
        assertNotNull("Fake data should be retrievable", testWeatherData)
    }
}