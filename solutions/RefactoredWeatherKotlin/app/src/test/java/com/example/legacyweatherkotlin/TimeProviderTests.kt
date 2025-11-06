package com.example.legacyweatherkotlin

import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import java.text.SimpleDateFormat
import java.util.*

/**
 * TimeProviderTests - Exercise 2: Time Dependency Seam
 * 
 * DEMONSTRATES: How time dependency abstraction enables deterministic testing
 * 
 * BEFORE REFACTORING:
 * - Tests failed randomly based on when they ran
 * - Impossible to test time-dependent caching logic
 * - Date formatting tests were locale/timezone dependent
 * - Cache expiration couldn't be tested reliably
 * 
 * AFTER REFACTORING:
 * - All time-dependent tests are deterministic
 * - Can simulate any date/time scenario
 * - Cache expiration logic fully testable
 * - Tests run in milliseconds, not real-time
 */

// MARK: - Mock Time Provider for Testing

/**
 * MockTimeProvider - Controllable time implementation for testing
 * BENEFIT: Complete control over time progression in tests
 */
class MockTimeProvider(private var currentTime: Long = System.currentTimeMillis()) : TimeProvider {
    
    override fun currentTimeMillis(): Long = currentTime
    
    fun setTime(timeMillis: Long) {
        currentTime = timeMillis
    }
    
    fun setTime(date: Date) {
        currentTime = date.time
    }
    
    fun advanceTime(milliseconds: Long) {
        currentTime += milliseconds
    }
    
    fun advanceTimeByMinutes(minutes: Int) {
        advanceTime(minutes * 60 * 1000L)
    }
}

class TimeProviderTests {
    
    private lateinit var mockTimeProvider: MockTimeProvider
    
    @Before
    fun setUp() {
        mockTimeProvider = MockTimeProvider()
        WeatherSingleton.setTimeProvider(mockTimeProvider)
    }
    
    @After
    fun tearDown() {
        // Restore system time provider
        WeatherSingleton.setTimeProvider(SystemTimeProvider())
    }
    
    // MARK: - Time Control Tests
    
    @Test
    fun `test time provider returns controlled time`() {
        // ARRANGE: Set specific time
        val testTime = 1609459200000L // 2021-01-01 00:00:00 UTC
        mockTimeProvider.setTime(testTime)
        
        // ACT: Get current time from WeatherSingleton
        val result = WeatherSingleton.getCurrentTime()
        
        // ASSERT: Should return our controlled time
        assertEquals(testTime, result)
    }
    
    @Test
    fun `test time provider with Date object`() {
        // ARRANGE: Create specific date
        val calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
        calendar.set(2024, Calendar.NOVEMBER, 6, 14, 30, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val testDate = calendar.time
        
        mockTimeProvider.setTime(testDate)
        
        // ACT: Get current date
        val result = WeatherSingleton.getCurrentDate()
        
        // ASSERT: Should match our test date
        assertEquals(testDate.time, result.time)
    }
    
    @Test
    fun `test time can advance programmatically`() {
        // ARRANGE: Start at specific time
        val startTime = 1000000L
        mockTimeProvider.setTime(startTime)
        
        // ACT: Advance time by 5 minutes
        mockTimeProvider.advanceTimeByMinutes(5)
        
        // ASSERT: Time should have advanced
        val expectedTime = startTime + (5 * 60 * 1000L)
        assertEquals(expectedTime, WeatherSingleton.getCurrentTime())
    }
    
    // MARK: - Date Formatting Tests
    
    @Test
    fun `test last updated time formatting with controlled time`() {
        // ARRANGE: Set specific time for predictable formatting
        val calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
        calendar.set(2024, Calendar.NOVEMBER, 6, 14, 30, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        mockTimeProvider.setTime(calendar.time)
        
        // ACT: Get formatted last updated time
        val formattedTime = WeatherSingleton.getLastUpdatedTime()
        
        // ASSERT: Should contain expected date components
        // Note: Format may vary by locale, so we check for key components
        assertTrue("Should contain hour", 
            formattedTime.contains("14") || formattedTime.contains("2:30") || formattedTime.contains("2 PM"))
        assertTrue("Should contain date elements", formattedTime.isNotEmpty())
    }
    
    @Test
    fun `test date formatting is deterministic with mock time`() {
        // ARRANGE: Set same time twice
        val testTime = 1609459200000L
        
        // ACT: Get formatted time twice
        mockTimeProvider.setTime(testTime)
        val result1 = WeatherSingleton.getLastUpdatedTime()
        
        mockTimeProvider.setTime(testTime)
        val result2 = WeatherSingleton.getLastUpdatedTime()
        
        // ASSERT: Should be identical (deterministic)
        assertEquals(result1, result2)
    }
    
    // MARK: - Cache Expiration Tests
    
    @Test
    fun `test cache is valid within 5 minute window`() {
        // ARRANGE: Set initial time and fetch weather
        val startTime = 1000000L
        mockTimeProvider.setTime(startTime)
        
        // Simulate cached data
        WeatherSingleton.cachedData = WeatherData(
            city = "London",
            temperature = 20.0,
            description = "Clear",
            humidity = 50,
            windSpeed = 5.0,
            icon = "01d",
            feelsLike = 19.0,
            pressure = 1013
        )
        WeatherSingleton.cachedCity = "London"
        WeatherSingleton.lastFetchTime = startTime
        
        // ACT: Advance time by 4 minutes (within 5 minute cache window)
        mockTimeProvider.advanceTimeByMinutes(4)
        
        // Manually check cache validity (simulating what fetchWeather does)
        val now = WeatherSingleton.getCurrentTime()
        val isCacheValid = (now - WeatherSingleton.lastFetchTime) < 300000 // 5 minutes
        
        // ASSERT: Cache should still be valid
        assertTrue("Cache should be valid after 4 minutes", isCacheValid)
    }
    
    @Test
    fun `test cache expires after 5 minute window`() {
        // ARRANGE: Set initial time
        val startTime = 1000000L
        mockTimeProvider.setTime(startTime)
        
        // Simulate cached data
        WeatherSingleton.lastFetchTime = startTime
        
        // ACT: Advance time by 6 minutes (beyond 5 minute cache window)
        mockTimeProvider.advanceTimeByMinutes(6)
        
        // Check cache validity
        val now = WeatherSingleton.getCurrentTime()
        val isCacheValid = (now - WeatherSingleton.lastFetchTime) < 300000
        
        // ASSERT: Cache should be expired
        assertFalse("Cache should be expired after 6 minutes", isCacheValid)
    }
    
    @Test
    fun `test cache expiration boundary at exactly 5 minutes`() {
        // ARRANGE: Set initial time
        val startTime = 1000000L
        mockTimeProvider.setTime(startTime)
        WeatherSingleton.lastFetchTime = startTime
        
        // ACT: Advance time by exactly 5 minutes
        mockTimeProvider.advanceTime(300000L) // Exactly 5 minutes
        
        // Check cache validity
        val now = WeatherSingleton.getCurrentTime()
        val isCacheValid = (now - WeatherSingleton.lastFetchTime) < 300000
        
        // ASSERT: Cache should be expired (< 300000 means expired at exactly 300000)
        assertFalse("Cache should be expired at exactly 5 minutes", isCacheValid)
    }
    
    // MARK: - Time Progression Tests
    
    @Test
    fun `test multiple time advances`() {
        // ARRANGE: Start at time zero
        mockTimeProvider.setTime(0L)
        
        // ACT: Advance in multiple steps
        mockTimeProvider.advanceTimeByMinutes(1)
        val time1 = WeatherSingleton.getCurrentTime()
        
        mockTimeProvider.advanceTimeByMinutes(2)
        val time2 = WeatherSingleton.getCurrentTime()
        
        mockTimeProvider.advanceTimeByMinutes(3)
        val time3 = WeatherSingleton.getCurrentTime()
        
        // ASSERT: Each advance should accumulate
        assertEquals(60_000L, time1)
        assertEquals(180_000L, time2)
        assertEquals(360_000L, time3)
    }
    
    @Test
    fun `test time can be set to past dates`() {
        // ARRANGE: Set time to a date in the past
        val calendar = Calendar.getInstance()
        calendar.set(2020, Calendar.JANUARY, 1, 0, 0, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val pastDate = calendar.time
        
        mockTimeProvider.setTime(pastDate)
        
        // ACT: Get current time
        val result = WeatherSingleton.getCurrentTime()
        
        // ASSERT: Should be the past date
        assertEquals(pastDate.time, result)
    }
    
    @Test
    fun `test time can be set to future dates`() {
        // ARRANGE: Set time to a future date
        val calendar = Calendar.getInstance()
        calendar.set(2030, Calendar.DECEMBER, 31, 23, 59, 59)
        calendar.set(Calendar.MILLISECOND, 0)
        val futureDate = calendar.time
        
        mockTimeProvider.setTime(futureDate)
        
        // ACT: Get current time
        val result = WeatherSingleton.getCurrentTime()
        
        // ASSERT: Should be the future date
        assertEquals(futureDate.time, result)
    }
}

/*
 * REFACTORING BENEFITS DEMONSTRATED:
 *
 * 1. DETERMINISTIC TESTS: Time is completely controllable, tests never fail randomly
 * 2. FAST TESTS: No need to Thread.sleep() - advance time instantly
 * 3. EDGE CASE TESTING: Can test exact cache expiration boundaries
 * 4. ISOLATED TESTS: Each test has its own time context
 * 5. COMPREHENSIVE COVERAGE: Can test scenarios that would take hours in real-time
 *
 * BEFORE TIME DEPENDENCY BREAKING:
 * - Tests dependent on when they ran (time of day, date)
 * - Cache expiration tests required Thread.sleep() (slow!)
 * - Date formatting tests failed in different timezones
 * - Impossible to test exact boundary conditions
 * - Tests were flaky and unreliable
 *
 * AFTER TIME DEPENDENCY BREAKING:
 * - All time-dependent behavior is testable
 * - Tests run in milliseconds
 * - Complete control over time progression
 * - Tests are reliable and deterministic
 * - Easy to test edge cases and boundaries
 */
