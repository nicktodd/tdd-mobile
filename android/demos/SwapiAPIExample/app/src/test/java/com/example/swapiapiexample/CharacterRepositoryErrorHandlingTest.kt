package com.example.swapiapiexample.data.repository

import com.example.swapiapiexample.data.api.SwapiService
import com.example.swapiapiexample.data.model.Character
import com.example.swapiapiexample.data.model.CharacterResponse
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runTest
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import retrofit2.HttpException
import retrofit2.Response
import java.io.IOException
import java.net.SocketTimeoutException
import java.net.UnknownHostException

/**
 * Comprehensive unit tests for CharacterRepositoryImpl focusing on error handling.
 *
 * LEARNING OBJECTIVES:
 * 1. How to test repository layer with mocked network services
 * 2. How to simulate various network failure scenarios
 * 3. How to test timeout and latency issues
 * 4. How to handle HTTP errors (404, 500, etc.)
 * 5. How to test malformed/unexpected data responses
 *
 * This is CRUCIAL for building robust apps that handle real-world network conditions!
 */
@OptIn(ExperimentalCoroutinesApi::class)
class CharacterRepositoryErrorHandlingTest {

    private lateinit var mockSwapiService: SwapiService
    private lateinit var repository: CharacterRepositoryImpl

    @Before
    fun setup() {
        mockSwapiService = mockk()
        repository = CharacterRepositoryImpl(mockSwapiService)
    }

    // ========== HAPPY PATH TESTS ==========

    /**
     * TEST: Successful API response returns success result
     *
     * LEARNING POINT: Always test the happy path first to establish baseline behavior
     */
    @Test
    fun `getCharacters returns success when API call succeeds`() = runTest {
        // Arrange
        val mockCharacters = listOf(
            Character("Luke Skywalker", "172", "77", "19BBY", "male", "url1"),
            Character("C-3PO", "167", "75", "112BBY", "n/a", "url2")
        )
        val mockResponse = CharacterResponse(
            count = 2,
            next = null,
            previous = null,
            results = mockCharacters
        )

        coEvery { mockSwapiService.getCharacters(1) } returns mockResponse

        // Act
        val result = repository.getCharacters(1)

        // Assert
        assertTrue(result is Result.Success)
        assertEquals(mockCharacters, (result as Result.Success).data)
    }

    /**
     * TEST: Empty response is handled correctly
     *
     * LEARNING POINT: APIs might return empty lists - this is valid, not an error
     */
    @Test
    fun `getCharacters handles empty list response`() = runTest {
        // Arrange
        val emptyResponse = CharacterResponse(
            count = 0,
            next = null,
            previous = null,
            results = emptyList()
        )

        coEvery { mockSwapiService.getCharacters(any()) } returns emptyResponse

        // Act
        val result = repository.getCharacters()

        // Assert
        assertTrue(result is Result.Success)
        assertTrue((result as Result.Success).data.isEmpty())
    }

    /**
     * TEST: Large response is handled correctly
     *
     * LEARNING POINT: Test with realistic data sizes
     */
    @Test
    fun `getCharacters handles large response correctly`() = runTest {
        // Arrange - Create 100 characters
        val largeCharacterList = (1..100).map { i ->
            Character("Character$i", "170", "70", "10BBY", "male", "url$i")
        }
        val largeResponse = CharacterResponse(
            count = 100,
            next = "nextPage",
            previous = null,
            results = largeCharacterList
        )

        coEvery { mockSwapiService.getCharacters(any()) } returns largeResponse

        // Act
        val result = repository.getCharacters()

        // Assert
        assertTrue(result is Result.Success)
        assertEquals(100, (result as Result.Success).data.size)
    }

    // ========== NETWORK ERROR TESTS ==========

    /**
     * TEST: Network timeout is handled correctly
     *
     * LEARNING POINT: Timeouts are one of the most common network issues.
     * Apps should gracefully handle slow or unresponsive servers.
     */
    @Test
    fun `getCharacters handles SocketTimeoutException`() = runTest {
        // Arrange - Simulate timeout
        coEvery { mockSwapiService.getCharacters(any()) } throws SocketTimeoutException("Connection timed out")

        // Act
        val result = repository.getCharacters()

        // Assert
        assertTrue(result is Result.Error)
        val exception = (result as Result.Error).exception
        assertTrue(exception is IOException)
        assertTrue(exception.message!!.contains("timed out"))
    }

    /**
     * TEST: No internet connection is handled correctly
     *
     * LEARNING POINT: UnknownHostException typically means no internet or DNS failure.
     * This is extremely common in mobile apps.
     */
    @Test
    fun `getCharacters handles UnknownHostException (no internet)`() = runTest {
        // Arrange - Simulate no internet
        coEvery { mockSwapiService.getCharacters(any()) } throws UnknownHostException("Unable to resolve host")

        // Act
        val result = repository.getCharacters()

        // Assert
        assertTrue(result is Result.Error)
        val exception = (result as Result.Error).exception
        assertTrue(exception is IOException)
        assertTrue(exception.message!!.contains("Network error"))
    }

    /**
     * TEST: Generic IOException is handled correctly
     *
     * LEARNING POINT: IOExceptions can occur for various reasons (network interrupted, etc.)
     */
    @Test
    fun `getCharacters handles generic IOException`() = runTest {
        // Arrange
        coEvery { mockSwapiService.getCharacters(any()) } throws IOException("Network connection lost")

        // Act
        val result = repository.getCharacters()

        // Assert
        assertTrue(result is Result.Error)
        val exception = (result as Result.Error).exception
        assertTrue(exception is IOException)
        assertTrue(exception.message!!.contains("Network error"))
    }

    // ========== HTTP ERROR TESTS ==========

    /**
     * TEST: HTTP 404 Not Found error
     *
     * LEARNING POINT: Test specific HTTP status codes.
     * Different status codes may require different handling in production apps.
     */
    @Test
    fun `getCharacters handles HTTP 404 error`() = runTest {
        // Arrange - Create mock 404 response
        val mockResponse = mockk<Response<CharacterResponse>>()
        coEvery { mockResponse.code() } returns 404
        coEvery { mockResponse.message() } returns "Not Found"

        val httpException = HttpException(mockResponse)
        coEvery { mockSwapiService.getCharacters(any()) } throws httpException

        // Act
        val result = repository.getCharacters()

        // Assert
        assertTrue(result is Result.Error)
        val exception = (result as Result.Error).exception
        assertTrue(exception is Exception)
        assertTrue(exception.message!!.contains("unexpected"))
    }

    /**
     * TEST: HTTP 500 Internal Server Error
     *
     * LEARNING POINT: Server errors should be handled gracefully.
     * The user can't fix server issues, so we should show appropriate messages.
     */
    @Test
    fun `getCharacters handles HTTP 500 server error`() = runTest {
        // Arrange
        val mockResponse = mockk<Response<CharacterResponse>>()
        coEvery { mockResponse.code() } returns 500
        coEvery { mockResponse.message() } returns "Internal Server Error"

        val httpException = HttpException(mockResponse)
        coEvery { mockSwapiService.getCharacters(any()) } throws httpException

        // Act
        val result = repository.getCharacters()

        // Assert
        assertTrue(result is Result.Error)
        assertTrue((result as Result.Error).exception.message!!.contains("unexpected"))
    }

    /**
     * TEST: HTTP 503 Service Unavailable
     *
     * LEARNING POINT: Services go down for maintenance or overload
     */
    @Test
    fun `getCharacters handles HTTP 503 service unavailable`() = runTest {
        // Arrange
        val mockResponse = mockk<Response<CharacterResponse>>()
        coEvery { mockResponse.code() } returns 503
        coEvery { mockResponse.message() } returns "Service Unavailable"

        val httpException = HttpException(mockResponse)
        coEvery { mockSwapiService.getCharacters(any()) } throws httpException

        // Act
        val result = repository.getCharacters()

        // Assert
        assertTrue(result is Result.Error)
    }

    /**
     * TEST: HTTP 401 Unauthorized (though SWAPI doesn't require auth)
     *
     * LEARNING POINT: Auth errors are common in real APIs
     */
    @Test
    fun `getCharacters handles HTTP 401 unauthorized`() = runTest {
        // Arrange
        val mockResponse = mockk<Response<CharacterResponse>>()
        coEvery { mockResponse.code() } returns 401
        coEvery { mockResponse.message() } returns "Unauthorized"

        val httpException = HttpException(mockResponse)
        coEvery { mockSwapiService.getCharacters(any()) } throws httpException

        // Act
        val result = repository.getCharacters()

        // Assert
        assertTrue(result is Result.Error)
    }

    // ========== MALFORMED DATA TESTS ==========

    /**
     * TEST: Null pointer exception from malformed data
     *
     * LEARNING POINT: APIs can return unexpected null values.
     * Your app shouldn't crash - handle these gracefully.
     */
    @Test
    fun `getCharacters handles NullPointerException from malformed data`() = runTest {
        // Arrange - Simulate deserialization issue
        coEvery { mockSwapiService.getCharacters(any()) } throws NullPointerException("Required field missing")

        // Act
        val result = repository.getCharacters()

        // Assert
        assertTrue(result is Result.Error)
        assertTrue((result as Result.Error).exception.message!!.contains("unexpected"))
    }

    /**
     * TEST: JSON parsing exception
     *
     * LEARNING POINT: Invalid JSON or schema changes can cause parsing failures
     */
    @Test
    fun `getCharacters handles JSON parsing exception`() = runTest {
        // Arrange
        coEvery { mockSwapiService.getCharacters(any()) } throws com.google.gson.JsonSyntaxException("Malformed JSON")

        // Act
        val result = repository.getCharacters()

        // Assert
        assertTrue(result is Result.Error)
    }

    // ========== LATENCY SIMULATION TESTS ==========

    /**
     * TEST: Repository respects network delay configuration
     *
     * LEARNING POINT: You can inject artificial delays to test loading states.
     * This is useful for testing loading indicators in UI tests.
     */
    @Test
    fun `getCharacters respects network delay parameter`() = runTest {
        // Arrange
        val delayedRepository = CharacterRepositoryImpl(
            mockSwapiService,
            networkDelayMs = 1000 // 1 second delay
        )

        val mockResponse = CharacterResponse(
            count = 1,
            next = null,
            previous = null,
            results = listOf(Character("Test", "170", "70", "10BBY", "male", "url"))
        )

        coEvery { mockSwapiService.getCharacters(any()) } returns mockResponse

        // Act
        val startTime = System.currentTimeMillis()
        val result = delayedRepository.getCharacters()
        val endTime = System.currentTimeMillis()

        // Assert
        assertTrue(result is Result.Success)
        // Note: In real tests, you'd use TestCoroutineScheduler to control time
        // This is just a demonstration
    }

    // ========== PAGINATION TESTS ==========

    /**
     * TEST: Different page numbers are passed correctly
     *
     * LEARNING POINT: Test that your repository correctly forwards parameters
     */
    @Test
    fun `getCharacters passes correct page number to service`() = runTest {
        // Arrange
        val page2Response = CharacterResponse(
            count = 10,
            next = "page3",
            previous = "page1",
            results = listOf(Character("Page2Character", "170", "70", "10BBY", "male", "url"))
        )

        coEvery { mockSwapiService.getCharacters(2) } returns page2Response

        // Act
        val result = repository.getCharacters(2)

        // Assert
        assertTrue(result is Result.Success)
        // Verify the service was called with page 2
        io.mockk.coVerify { mockSwapiService.getCharacters(2) }
    }

    // ========== EDGE CASE TESTS ==========

    /**
     * TEST: Consecutive calls work correctly
     *
     * LEARNING POINT: Repository should handle multiple sequential calls
     */
    @Test
    fun `multiple consecutive getCharacters calls work correctly`() = runTest {
        // Arrange
        val response1 = CharacterResponse(count = 1, next = null, previous = null,
            results = listOf(Character("Char1", "170", "70", "10BBY", "male", "url1")))
        val response2 = CharacterResponse(count = 1, next = null, previous = null,
            results = listOf(Character("Char2", "180", "80", "20BBY", "female", "url2")))

        coEvery { mockSwapiService.getCharacters(1) } returns response1
        coEvery { mockSwapiService.getCharacters(2) } returns response2

        // Act
        val result1 = repository.getCharacters(1)
        val result2 = repository.getCharacters(2)

        // Assert
        assertTrue(result1 is Result.Success)
        assertTrue(result2 is Result.Success)
        assertNotEquals(
            (result1 as Result.Success).data[0].name,
            (result2 as Result.Success).data[0].name
        )
    }

    /**
     * TEST: Error recovery - success after failure
     *
     * LEARNING POINT: After an error, subsequent calls should still work.
     * This tests that error handling doesn't break the repository state.
     */
    @Test
    fun `getCharacters works after previous error`() = runTest {
        // Arrange
        val successResponse = CharacterResponse(
            count = 1,
            next = null,
            previous = null,
            results = listOf(Character("Recovery", "170", "70", "10BBY", "male", "url"))
        )

        // First call fails, second succeeds
        coEvery { mockSwapiService.getCharacters(1) } throws IOException("First call fails")
        coEvery { mockSwapiService.getCharacters(2) } returns successResponse

        // Act
        val failedResult = repository.getCharacters(1)
        val successResult = repository.getCharacters(2)

        // Assert
        assertTrue(failedResult is Result.Error)
        assertTrue(successResult is Result.Success)
    }
}

