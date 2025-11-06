package com.example.legacyweatherkotlin

import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

/**
 * MethodExtractionTests - Exercise 3: Method Extraction
 * 
 * DEMONSTRATES: How extracting complex methods enables focused unit testing
 * 
 * BEFORE REFACTORING:
 * - Complex logic buried inside large methods
 * - Business logic mixed with network/state management
 * - Impossible to test logic without triggering side effects
 * - No way to test edge cases in isolation
 * 
 * AFTER REFACTORING:
 * - Pure functions extracted and independently testable
 * - Business logic separated from infrastructure concerns
 * - Each method has focused responsibility
 * - Easy to test edge cases and boundary conditions
 */
class MethodExtractionTests {
    
    @Before
    fun setUp() {
        // Set up test time provider if needed
        WeatherSingleton.setTimeProvider(SystemTimeProvider())
    }
    
    // MARK: - Temperature Conversion Tests
    
    @Test
    fun `test kelvin to celsius conversion`() {
        // ARRANGE
        val kelvin = 300.0
        
        // ACT
        val celsius = WeatherSingleton.kelvinToCelsius(kelvin)
        
        // ASSERT
        assertEquals(26.85, celsius, 0.01)
    }
    
    @Test
    fun `test kelvin to celsius at freezing point`() {
        // Freezing point of water
        val kelvin = 273.15
        
        val celsius = WeatherSingleton.kelvinToCelsius(kelvin)
        
        assertEquals(0.0, celsius, 0.01)
    }
    
    @Test
    fun `test kelvin to celsius at boiling point`() {
        // Boiling point of water
        val kelvin = 373.15
        
        val celsius = WeatherSingleton.kelvinToCelsius(kelvin)
        
        assertEquals(100.0, celsius, 0.01)
    }
    
    @Test
    fun `test kelvin to fahrenheit conversion`() {
        // ARRANGE
        val kelvin = 300.0
        
        // ACT
        val fahrenheit = WeatherSingleton.kelvinToFahrenheit(kelvin)
        
        // ASSERT
        assertEquals(80.33, fahrenheit, 0.01)
    }
    
    @Test
    fun `test kelvin to fahrenheit at freezing point`() {
        val kelvin = 273.15
        
        val fahrenheit = WeatherSingleton.kelvinToFahrenheit(kelvin)
        
        assertEquals(32.0, fahrenheit, 0.01)
    }
    
    @Test
    fun `test kelvin to fahrenheit at boiling point`() {
        val kelvin = 373.15
        
        val fahrenheit = WeatherSingleton.kelvinToFahrenheit(kelvin)
        
        assertEquals(212.0, fahrenheit, 0.01)
    }
    
    @Test
    fun `test convertTemperature to celsius`() {
        val kelvin = 293.15 // 20°C
        
        val result = WeatherSingleton.convertTemperature(kelvin, toCelsius = true)
        
        assertEquals(20.0, result, 0.01)
    }
    
    @Test
    fun `test convertTemperature to fahrenheit`() {
        val kelvin = 293.15 // 20°C = 68°F
        
        val result = WeatherSingleton.convertTemperature(kelvin, toCelsius = false)
        
        assertEquals(68.0, result, 0.01)
    }
    
    // MARK: - Temperature Formatting Tests
    
    @Test
    fun `test getTemperatureUnit for celsius`() {
        val unit = WeatherSingleton.getTemperatureUnit(true)
        
        assertEquals("°C", unit)
    }
    
    @Test
    fun `test getTemperatureUnit for fahrenheit`() {
        val unit = WeatherSingleton.getTemperatureUnit(false)
        
        assertEquals("°F", unit)
    }
    
    @Test
    fun `test formatTemperature in celsius`() {
        val kelvin = 295.15 // 22°C
        
        val formatted = WeatherSingleton.formatTemperature(kelvin, isCelsius = true)
        
        assertEquals("22°C", formatted)
    }
    
    @Test
    fun `test formatTemperature in fahrenheit`() {
        val kelvin = 295.15 // 71.33°F, rounds to 71
        
        val formatted = WeatherSingleton.formatTemperature(kelvin, isCelsius = false)
        
        assertEquals("71°F", formatted)
    }
    
    @Test
    fun `test formatTemperature rounds correctly`() {
        val kelvin = 295.65 // 22.5°C, rounds to 22
        
        val formatted = WeatherSingleton.formatTemperature(kelvin, isCelsius = true)
        
        assertEquals("22°C", formatted)
    }
    
    // MARK: - Description Capitalization Tests
    
    @Test
    fun `test capitalize single word description`() {
        val description = "clear"
        
        val result = WeatherSingleton.capitalizeDescription(description)
        
        assertEquals("Clear", result)
    }
    
    @Test
    fun `test capitalize multi-word description`() {
        val description = "partly cloudy"
        
        val result = WeatherSingleton.capitalizeDescription(description)
        
        assertEquals("Partly Cloudy", result)
    }
    
    @Test
    fun `test capitalize already capitalized description`() {
        val description = "Clear Sky"
        
        val result = WeatherSingleton.capitalizeDescription(description)
        
        assertEquals("Clear Sky", result)
    }
    
    @Test
    fun `test capitalize mixed case description`() {
        val description = "broken clouds"
        
        val result = WeatherSingleton.capitalizeDescription(description)
        
        assertEquals("Broken Clouds", result)
    }
    
    @Test
    fun `test capitalize empty string`() {
        val description = ""
        
        val result = WeatherSingleton.capitalizeDescription(description)
        
        assertEquals("", result)
    }
    
    @Test
    fun `test capitalize description with multiple spaces`() {
        val description = "light  rain"
        
        val result = WeatherSingleton.capitalizeDescription(description)
        
        // Should handle multiple spaces gracefully
        assertTrue(result.contains("Light"))
        assertTrue(result.contains("Rain"))
    }
    
    // MARK: - URL Building Tests
    
    @Test
    fun `test buildWeatherUrl with simple city name`() {
        val city = "London"
        
        val url = WeatherSingleton.buildWeatherUrl(city)
        
        assertTrue("URL should contain base URL", url.contains("api.openweathermap.org"))
        assertTrue("URL should contain city", url.contains("q=London"))
        assertTrue("URL should contain API key", url.contains("appid="))
        assertTrue("URL should request standard units", url.contains("units=standard"))
    }
    
    @Test
    fun `test buildWeatherUrl with city containing spaces`() {
        val city = "New York"
        
        val url = WeatherSingleton.buildWeatherUrl(city)
        
        assertTrue("URL should contain city", url.contains("New York"))
    }
    
    @Test
    fun `test buildWeatherUrl with special characters`() {
        val city = "São Paulo"
        
        val url = WeatherSingleton.buildWeatherUrl(city)
        
        assertTrue("URL should contain city", url.contains("São Paulo"))
    }
    
    // MARK: - Weather Response Parsing Tests
    
    @Test
    fun `test parseWeatherResponse with valid data`() {
        // ARRANGE: Create mock API response
        val response = WeatherResponse(
            name = "London",
            main = Main(
                temp = 295.15,
                feels_like = 293.15,
                humidity = 65,
                pressure = 1013
            ),
            weather = listOf(
                Weather(
                    main = "Clear",
                    description = "clear sky",
                    icon = "01d"
                )
            ),
            wind = Wind(speed = 3.5)
        )
        
        // ACT: Parse the response
        val weatherData = WeatherSingleton.parseWeatherResponse(response)
        
        // ASSERT: Verify all fields are correctly mapped
        assertEquals("London", weatherData.city)
        assertEquals(295.15, weatherData.temperature, 0.01)
        assertEquals("Clear Sky", weatherData.description) // Should be capitalized
        assertEquals(65, weatherData.humidity)
        assertEquals(3.5, weatherData.windSpeed, 0.01)
        assertEquals("01d", weatherData.icon)
        assertEquals(293.15, weatherData.feelsLike, 0.01)
        assertEquals(1013, weatherData.pressure)
    }
    
    @Test
    fun `test parseWeatherResponse capitalizes description`() {
        val response = WeatherResponse(
            name = "Paris",
            main = Main(temp = 290.0, feels_like = 288.0, humidity = 70, pressure = 1010),
            weather = listOf(Weather(main = "Clouds", description = "broken clouds", icon = "04d")),
            wind = Wind(speed = 5.0)
        )
        
        val weatherData = WeatherSingleton.parseWeatherResponse(response)
        
        assertEquals("Broken Clouds", weatherData.description)
    }
    
    @Test
    fun `test parseWeatherResponse with cold temperature`() {
        val response = WeatherResponse(
            name = "Moscow",
            main = Main(temp = 263.15, feels_like = 260.0, humidity = 80, pressure = 1020),
            weather = listOf(Weather(main = "Snow", description = "light snow", icon = "13d")),
            wind = Wind(speed = 8.0)
        )
        
        val weatherData = WeatherSingleton.parseWeatherResponse(response)
        
        assertEquals(263.15, weatherData.temperature, 0.01)
        assertEquals("Light Snow", weatherData.description)
    }
    
    @Test
    fun `test parseWeatherResponse with hot temperature`() {
        val response = WeatherResponse(
            name = "Dubai",
            main = Main(temp = 313.15, feels_like = 318.0, humidity = 45, pressure = 1008),
            weather = listOf(Weather(main = "Clear", description = "clear sky", icon = "01d")),
            wind = Wind(speed = 2.0)
        )
        
        val weatherData = WeatherSingleton.parseWeatherResponse(response)
        
        assertEquals(313.15, weatherData.temperature, 0.01)
        assertEquals(318.0, weatherData.feelsLike, 0.01)
    }
    
    @Test
    fun `test parseWeatherResponse with high wind speed`() {
        val response = WeatherResponse(
            name = "Chicago",
            main = Main(temp = 280.0, feels_like = 275.0, humidity = 60, pressure = 1015),
            weather = listOf(Weather(main = "Clouds", description = "overcast clouds", icon = "04d")),
            wind = Wind(speed = 15.5)
        )
        
        val weatherData = WeatherSingleton.parseWeatherResponse(response)
        
        assertEquals(15.5, weatherData.windSpeed, 0.01)
    }
    
    // MARK: - Edge Case Tests
    
    @Test
    fun `test temperature conversion with absolute zero`() {
        val kelvin = 0.0
        
        val celsius = WeatherSingleton.kelvinToCelsius(kelvin)
        
        assertEquals(-273.15, celsius, 0.01)
    }
    
    @Test
    fun `test temperature conversion with negative result`() {
        val kelvin = 250.0 // -23.15°C
        
        val celsius = WeatherSingleton.kelvinToCelsius(kelvin)
        
        assertEquals(-23.15, celsius, 0.01)
    }
    
    @Test
    fun `test temperature conversion with very high temperature`() {
        val kelvin = 500.0 // 226.85°C
        
        val celsius = WeatherSingleton.kelvinToCelsius(kelvin)
        
        assertEquals(226.85, celsius, 0.01)
    }
    
    @Test
    fun `test formatTemperature with negative celsius`() {
        val kelvin = 263.15 // -10°C
        
        val formatted = WeatherSingleton.formatTemperature(kelvin, isCelsius = true)
        
        assertEquals("-10°C", formatted)
    }
    
    @Test
    fun `test formatTemperature with zero celsius`() {
        val kelvin = 273.15 // 0°C
        
        val formatted = WeatherSingleton.formatTemperature(kelvin, isCelsius = true)
        
        assertEquals("0°C", formatted)
    }
}

/*
 * REFACTORING BENEFITS DEMONSTRATED:
 *
 * 1. FOCUSED TESTS: Each method can be tested in isolation without complex setup
 * 2. PURE FUNCTIONS: Temperature conversion has no side effects, easy to reason about
 * 3. EDGE CASE COVERAGE: Can test boundary conditions (freezing, boiling, negative temps)
 * 4. FAST TESTS: No network calls, no state management, tests run in microseconds
 * 5. COMPREHENSIVE COVERAGE: Test all conversion paths, formatting variations, parsing scenarios
 * 6. MAINTAINABILITY: When business rules change, tests clearly show what broke
 *
 * BEFORE METHOD EXTRACTION:
 * - Had to set up entire singleton state to test temperature conversion
 * - Needed mock network responses to test description capitalization
 * - Impossible to test URL building logic without Retrofit setup
 * - Couldn't test parsing without triggering network calls
 * - Tests were slow, complex, and brittle
 *
 * AFTER METHOD EXTRACTION:
 * - Pure functions test in isolation with simple inputs
 * - No mocking or complex setup required
 * - Each test focuses on one piece of logic
 * - Easy to add new test cases
 * - Tests serve as living documentation of business rules
 */
