package com.example.legacyweatherkotlin

import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

/**
 * NetworkDependencyTests - Exercise 4: Network Dependency Breaking
 * 
 * PURPOSE: Demonstrate how breaking the network dependency enables fast, reliable tests
 * 
 * BENEFITS OF NETWORK ABSTRACTION:
 * 1. SPEED: No actual HTTP calls, tests run in milliseconds
 * 2. RELIABILITY: No flaky tests due to network issues or API downtime
 * 3. CONTROL: Can simulate any network scenario (success, failure, timeout, errors)
 * 4. ISOLATION: Tests focus on business logic, not network infrastructure
 * 5. DETERMINISM: Same input always produces same output
 * 
 * PATTERN: Dependency Injection with Interface Segregation
 * - WeatherNetworkService interface defines contract
 * - RetrofitWeatherNetworkService implements real HTTP calls
 * - MockNetworkService provides controllable test double
 * 
 * COMPARISON TO SWIFT:
 * - Swift uses async/await pattern
 * - Kotlin uses callback pattern (matches existing Retrofit API)
 * - Both achieve same goal: testable network interactions
 */
class NetworkDependencyTests {
    
    /**
     * MockNetworkService - Test Double Pattern
     * 
     * PURPOSE: Simulates network behavior without actual HTTP calls
     * PATTERN: Test Double (specifically a Configurable Mock)
     * 
     * CAPABILITIES:
     * - Return pre-configured success responses
     * - Simulate various error scenarios
     * - Track call history for verification
     * - Provide immediate (synchronous-like) responses for testing
     */
    private class MockNetworkService : WeatherNetworkService {
        // Configuration: Set response before calling fetchWeather
        var mockResponse: Result<WeatherResponse>? = null
        
        // Tracking: Verify what was requested
        var lastCity: String? = null
        var lastApiKey: String? = null
        var callCount = 0
        
        override fun fetchWeather(
            city: String,
            apiKey: String,
            callback: (Result<WeatherResponse>) -> Unit
        ) {
            // Track the call
            lastCity = city
            lastApiKey = apiKey
            callCount++
            
            // Return configured response
            mockResponse?.let { callback(it) }
                ?: callback(Result.failure(Exception("MockNetworkService not configured")))
        }
        
        // Helper methods for test configuration
        fun setSuccessResponse(response: WeatherResponse) {
            mockResponse = Result.success(response)
        }
        
        fun setFailureResponse(error: Throwable) {
            mockResponse = Result.failure(error)
        }
        
        fun reset() {
            mockResponse = null
            lastCity = null
            lastApiKey = null
            callCount = 0
        }
    }
    
    private lateinit var mockNetworkService: MockNetworkService
    
    @Before
    fun setUp() {
        // PATTERN: Test Isolation - each test starts with clean state
        mockNetworkService = MockNetworkService()
        WeatherSingleton.setNetworkService(mockNetworkService)
        WeatherSingleton.suppressLogging = true // Suppress Android Log calls in unit tests
        WeatherSingleton.clearWeatherData()
    }
    
    @After
    fun tearDown() {
        // PATTERN: Test Cleanup - restore original state
        WeatherSingleton.resetNetworkService()
        WeatherSingleton.suppressLogging = false // Restore logging
        WeatherSingleton.clearWeatherData()
    }
    
    // MARK: - Test Helpers
    
    /**
     * Create a mock WeatherResponse for testing
     * BENEFIT: Centralized test data creation, easy to maintain
     */
    private fun createMockWeatherResponse(
        cityName: String = "London",
        temp: Double = 293.15,
        description: String = "clear sky",
        humidity: Int = 65,
        windSpeed: Double = 5.5,
        icon: String = "01d",
        feelsLike: Double = 291.15,
        pressure: Int = 1013
    ): WeatherResponse {
        return WeatherResponse(
            name = cityName,
            main = Main(
                temp = temp,
                feels_like = feelsLike,
                humidity = humidity,
                pressure = pressure
            ),
            weather = listOf(
                Weather(
                    main = "Clear",
                    description = description,
                    icon = icon
                )
            ),
            wind = Wind(speed = windSpeed)
        )
    }
    
    // MARK: - Basic Network Dependency Tests
    
    @Test
    fun `test network service injection is used`() {
        // BENEFIT: Verify dependency injection works
        val response = createMockWeatherResponse(cityName = "Paris")
        mockNetworkService.setSuccessResponse(response)
        
        WeatherSingleton.fetchWeather("Paris")
        
        // Verify mock was called (proves injection works)
        assertEquals("Paris", mockNetworkService.lastCity)
        assertEquals(1, mockNetworkService.callCount)
    }
    
    @Test
    fun `test successful network call updates weather data`() {
        // BENEFIT: Test business logic without real network
        val response = createMockWeatherResponse(
            cityName = "Tokyo",
            temp = 298.15,
            description = "partly cloudy"
        )
        mockNetworkService.setSuccessResponse(response)
        
        WeatherSingleton.fetchWeather("Tokyo")
        
        // Verify state updates
        val weather = WeatherSingleton.currentWeather.value
        assertNotNull("Weather data should be set", weather)
        assertEquals("Tokyo", weather?.city)
        assertEquals(298.15, weather?.temperature ?: 0.0, 0.01)
        assertEquals("Partly Cloudy", weather?.description) // Capitalized
    }
    
    @Test
    fun `test network failure sets error message`() {
        // BENEFIT: Test error handling without causing real errors
        mockNetworkService.setFailureResponse(
            Exception("Connection timeout")
        )
        
        WeatherSingleton.fetchWeather("Berlin")
        
        // Verify error handling
        val error = WeatherSingleton.errorMessage.value
        assertTrue("Error message should contain failure info", 
            error.contains("Network error") || error.contains("Connection timeout"))
        assertNull("Weather data should remain null on error", 
            WeatherSingleton.currentWeather.value)
    }
    
    @Test
    fun `test loading state management during network call`() {
        // BENEFIT: Test UI state transitions without real network delay
        val response = createMockWeatherResponse()
        mockNetworkService.setSuccessResponse(response)
        
        // Initial state
        assertFalse("Should not be loading initially", 
            WeatherSingleton.isLoading.value)
        
        WeatherSingleton.fetchWeather("London")
        
        // After network call completes (mock responds immediately)
        assertFalse("Should not be loading after completion", 
            WeatherSingleton.isLoading.value)
    }
    
    // MARK: - Error Scenario Tests
    
    @Test
    fun `test HTTP error handling`() {
        // BENEFIT: Simulate specific HTTP errors without server
        mockNetworkService.setFailureResponse(
            Exception("HTTP 404: Not Found")
        )
        
        WeatherSingleton.fetchWeather("InvalidCity")
        
        assertTrue("Error message should mention network error",
            WeatherSingleton.errorMessage.value.contains("Network error"))
        assertNull("Weather should be null on error", 
            WeatherSingleton.currentWeather.value)
    }
    
    @Test
    fun `test network timeout simulation`() {
        // BENEFIT: Test timeout handling without waiting
        mockNetworkService.setFailureResponse(
            Exception("Request timed out")
        )
        
        WeatherSingleton.fetchWeather("RemoteCity")
        
        val error = WeatherSingleton.errorMessage.value
        assertTrue("Should handle timeout error",
            error.contains("Network error") || error.contains("timed out"))
    }
    
    @Test
    fun `test malformed response handling`() {
        // BENEFIT: Test edge cases that are hard to reproduce with real API
        // This simulates what would happen if API returned unexpected data
        mockNetworkService.setFailureResponse(
            Exception("JSON parsing error")
        )
        
        WeatherSingleton.fetchWeather("TestCity")
        
        assertNotNull("Should set error message", 
            WeatherSingleton.errorMessage.value)
        assertNull("Weather should remain null", 
            WeatherSingleton.currentWeather.value)
    }
    
    // MARK: - Multiple Cities Tests
    
    @Test
    fun `test fetching different cities updates data correctly`() {
        // BENEFIT: Test state management across multiple calls
        
        // First city
        val londonResponse = createMockWeatherResponse(
            cityName = "London",
            temp = 288.15
        )
        mockNetworkService.setSuccessResponse(londonResponse)
        WeatherSingleton.fetchWeather("London")
        
        assertEquals("London", WeatherSingleton.currentWeather.value?.city)
        assertEquals(288.15, WeatherSingleton.currentWeather.value?.temperature ?: 0.0, 0.01)
        
        // Second city
        val parisResponse = createMockWeatherResponse(
            cityName = "Paris",
            temp = 290.15
        )
        mockNetworkService.setSuccessResponse(parisResponse)
        WeatherSingleton.fetchWeather("Paris")
        
        assertEquals("Paris", WeatherSingleton.currentWeather.value?.city)
        assertEquals(290.15, WeatherSingleton.currentWeather.value?.temperature ?: 0.0, 0.01)
    }
    
    @Test
    fun `test cached data is not returned for different city`() {
        // BENEFIT: Test cache invalidation logic with controlled time
        
        // Setup time provider for caching test
        val mockTime = MockTimeProvider()
        mockTime.setTime(1000000L)
        WeatherSingleton.setTimeProvider(mockTime)
        
        // Fetch London
        val londonResponse = createMockWeatherResponse(cityName = "London")
        mockNetworkService.setSuccessResponse(londonResponse)
        WeatherSingleton.fetchWeather("London")
        
        assertEquals(1, mockNetworkService.callCount)
        
        // Fetch Paris (should not use London's cache)
        val parisResponse = createMockWeatherResponse(cityName = "Paris")
        mockNetworkService.setSuccessResponse(parisResponse)
        mockTime.advanceTime(1000) // Advance time but still within cache window
        WeatherSingleton.fetchWeather("Paris")
        
        // Should make another network call (different city)
        assertEquals(2, mockNetworkService.callCount)
        assertEquals("Paris", WeatherSingleton.currentWeather.value?.city)
        
        // Cleanup
        WeatherSingleton.setTimeProvider(SystemTimeProvider())
    }
    
    // MARK: - API Key Tests
    
    @Test
    fun `test correct API key is passed to network service`() {
        // BENEFIT: Verify configuration is passed correctly
        val response = createMockWeatherResponse()
        mockNetworkService.setSuccessResponse(response)
        
        WeatherSingleton.fetchWeather("London")
        
        assertNotNull("API key should be passed", mockNetworkService.lastApiKey)
        assertFalse("API key should not be empty", 
            mockNetworkService.lastApiKey.isNullOrEmpty())
    }
    
    // MARK: - Weather Data Transformation Tests
    
    @Test
    fun `test weather response is transformed correctly`() {
        // BENEFIT: Test data transformation without network
        val response = createMockWeatherResponse(
            cityName = "Sydney",
            temp = 295.15,
            description = "scattered clouds",
            humidity = 70,
            windSpeed = 8.2,
            icon = "03d",
            feelsLike = 293.15,
            pressure = 1015
        )
        mockNetworkService.setSuccessResponse(response)
        
        WeatherSingleton.fetchWeather("Sydney")
        
        val weather = WeatherSingleton.currentWeather.value
        assertNotNull(weather)
        assertEquals("Sydney", weather?.city)
        assertEquals(295.15, weather?.temperature ?: 0.0, 0.01)
        assertEquals("Scattered Clouds", weather?.description)
        assertEquals(70, weather?.humidity)
        assertEquals(8.2, weather?.windSpeed ?: 0.0, 0.01)
        assertEquals("03d", weather?.icon)
        assertEquals(293.15, weather?.feelsLike ?: 0.0, 0.01)
        assertEquals(1015, weather?.pressure)
    }
    
    @Test
    fun `test description capitalization in transformation`() {
        // BENEFIT: Test string transformation logic in isolation
        val response = createMockWeatherResponse(
            description = "light rain shower"
        )
        mockNetworkService.setSuccessResponse(response)
        
        WeatherSingleton.fetchWeather("London")
        
        assertEquals("Light Rain Shower", 
            WeatherSingleton.currentWeather.value?.description)
    }
    
    // MARK: - Extreme Weather Data Tests
    
    @Test
    fun `test extreme temperature values`() {
        // BENEFIT: Test edge cases that are hard to get from real API
        val response = createMockWeatherResponse(
            temp = 233.15, // -40°C/-40°F
            feelsLike = 228.15 // -45°C
        )
        mockNetworkService.setSuccessResponse(response)
        
        WeatherSingleton.fetchWeather("Antarctica")
        
        val weather = WeatherSingleton.currentWeather.value
        assertNotNull(weather)
        assertEquals(233.15, weather?.temperature ?: 0.0, 0.01)
        assertEquals(228.15, weather?.feelsLike ?: 0.0, 0.01)
    }
    
    @Test
    fun `test very high temperature values`() {
        // BENEFIT: Test extreme high temperatures
        val response = createMockWeatherResponse(
            temp = 323.15, // 50°C/122°F
            feelsLike = 328.15 // 55°C
        )
        mockNetworkService.setSuccessResponse(response)
        
        WeatherSingleton.fetchWeather("Death Valley")
        
        val weather = WeatherSingleton.currentWeather.value
        assertNotNull(weather)
        assertEquals(323.15, weather?.temperature ?: 0.0, 0.01)
    }
    
    @Test
    fun `test zero humidity`() {
        // BENEFIT: Test boundary conditions
        val response = createMockWeatherResponse(humidity = 0)
        mockNetworkService.setSuccessResponse(response)
        
        WeatherSingleton.fetchWeather("Desert")
        
        assertEquals(0, WeatherSingleton.currentWeather.value?.humidity)
    }
    
    @Test
    fun `test maximum humidity`() {
        // BENEFIT: Test boundary conditions
        val response = createMockWeatherResponse(humidity = 100)
        mockNetworkService.setSuccessResponse(response)
        
        WeatherSingleton.fetchWeather("Rainforest")
        
        assertEquals(100, WeatherSingleton.currentWeather.value?.humidity)
    }
    
    @Test
    fun `test calm wind conditions`() {
        // BENEFIT: Test zero/minimal values
        val response = createMockWeatherResponse(windSpeed = 0.0)
        mockNetworkService.setSuccessResponse(response)
        
        WeatherSingleton.fetchWeather("Calm Area")
        
        assertEquals(0.0, WeatherSingleton.currentWeather.value?.windSpeed ?: -1.0, 0.01)
    }
    
    @Test
    fun `test hurricane force winds`() {
        // BENEFIT: Test extreme values
        val response = createMockWeatherResponse(windSpeed = 50.0)
        mockNetworkService.setSuccessResponse(response)
        
        WeatherSingleton.fetchWeather("Hurricane Zone")
        
        assertEquals(50.0, WeatherSingleton.currentWeather.value?.windSpeed ?: 0.0, 0.01)
    }
    
    // MARK: - Cache Interaction with Network Tests
    
    @Test
    fun `test cache prevents unnecessary network calls`() {
        // BENEFIT: Test caching behavior with controllable time and network
        val mockTime = MockTimeProvider()
        mockTime.setTime(1000000L)
        WeatherSingleton.setTimeProvider(mockTime)
        
        val response = createMockWeatherResponse()
        mockNetworkService.setSuccessResponse(response)
        
        // First call - should hit network
        WeatherSingleton.fetchWeather("London")
        assertEquals(1, mockNetworkService.callCount)
        
        // Second call within cache window - should use cache
        mockTime.advanceTime(60000) // 1 minute later
        WeatherSingleton.fetchWeather("London")
        assertEquals("Should not make second network call (cache hit)", 
            1, mockNetworkService.callCount)
        
        // Cleanup
        WeatherSingleton.setTimeProvider(SystemTimeProvider())
    }
    
    @Test
    fun `test cache expires and makes new network call`() {
        // BENEFIT: Test cache expiration with controlled time
        val mockTime = MockTimeProvider()
        mockTime.setTime(1000000L)
        WeatherSingleton.setTimeProvider(mockTime)
        
        val response = createMockWeatherResponse()
        mockNetworkService.setSuccessResponse(response)
        
        // First call
        WeatherSingleton.fetchWeather("London")
        assertEquals(1, mockNetworkService.callCount)
        
        // Call after cache expiry
        mockTime.advanceTime(400000) // 6+ minutes later
        WeatherSingleton.fetchWeather("London")
        assertEquals("Should make new network call (cache expired)", 
            2, mockNetworkService.callCount)
        
        // Cleanup
        WeatherSingleton.setTimeProvider(SystemTimeProvider())
    }
    
    // MARK: - Error Recovery Tests
    
    @Test
    fun `test recovery after network error`() {
        // BENEFIT: Test error recovery without real network issues
        
        // First call fails
        mockNetworkService.setFailureResponse(Exception("Network error"))
        WeatherSingleton.fetchWeather("London")
        
        assertNull("Weather should be null after error", 
            WeatherSingleton.currentWeather.value)
        assertNotEquals("", WeatherSingleton.errorMessage.value)
        
        // Second call succeeds
        val response = createMockWeatherResponse()
        mockNetworkService.setSuccessResponse(response)
        WeatherSingleton.fetchWeather("London")
        
        assertNotNull("Weather should be set after recovery", 
            WeatherSingleton.currentWeather.value)
        assertEquals("Error should be cleared", "", WeatherSingleton.errorMessage.value)
    }
    
    // MARK: - MockTimeProvider (reused from TimeProviderTests)
    
    private class MockTimeProvider : TimeProvider {
        private var currentTimeMillis: Long = 0
        
        fun setTime(timeMillis: Long) {
            currentTimeMillis = timeMillis
        }
        
        fun advanceTime(millis: Long) {
            currentTimeMillis += millis
        }
        
        override fun currentTimeMillis(): Long = currentTimeMillis
    }
}
