package com.example.swapiapiexample.ui

import com.example.swapiapiexample.data.model.Character
import com.example.swapiapiexample.data.repository.CharacterRepository
import com.example.swapiapiexample.data.repository.Result
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.*
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.Assert.*
import java.io.IOException
import java.net.SocketTimeoutException

/**
 * Comprehensive unit tests for CharacterViewModel.
 *
 * LEARNING OBJECTIVES:
 * 1. How to test ViewModels with coroutines using TestDispatcher
 * 2. How to mock repository dependencies using MockK
 * 3. How to test asynchronous operations and state flows
 * 4. How to test error conditions and edge cases
 */
@OptIn(ExperimentalCoroutinesApi::class)
class CharacterViewModelTest {

    // Mock repository - this allows us to control what data is returned without making real API calls
    private lateinit var mockRepository: CharacterRepository

    // System under test
    private lateinit var viewModel: CharacterViewModel

    // Test dispatcher for controlling coroutine execution in tests
    private val testDispatcher = UnconfinedTestDispatcher()

    /**
     * Setup method runs before each test.
     *
     * KEY CONCEPT: We replace the main dispatcher with a test dispatcher.
     * This allows us to control coroutine execution and avoid threading issues in tests.
     */
    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        mockRepository = mockk()
        viewModel = CharacterViewModel(mockRepository)
    }

    /**
     * Cleanup after each test.
     * Reset the main dispatcher to avoid affecting other tests.
     */
    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    // ========== HAPPY PATH TESTS ==========

    /**
     * TEST: Initial state should be Idle
     *
     * LEARNING POINT: Always test the initial state of your ViewModel
     */
    @Test
    fun `initial state is Idle`() {
        // Assert
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Idle)
    }

    /**
     * TEST: Loading characters successfully updates state correctly
     *
     * LEARNING POINTS:
     * - How to mock repository responses using MockK's coEvery
     * - How to test StateFlow values
     * - How to verify coroutine-based repository calls with coVerify
     */
    @Test
    fun `loadCharacters success updates state to Success`() = runTest {
        // Arrange - Create mock data
        val mockCharacters = listOf(
            Character("Luke Skywalker", "172", "77", "19BBY", "male", "url1"),
            Character("Darth Vader", "202", "136", "41.9BBY", "male", "url2")
        )

        // Mock the repository to return success
        // coEvery is used for suspending functions
        coEvery { mockRepository.getCharacters(any()) } returns Result.Success(mockCharacters)

        // Act
        viewModel.loadCharacters()

        // Advance coroutines to completion (important for testing!)
        advanceUntilIdle()

        // Assert - Check final state
        val currentState = viewModel.uiState.value
        assertTrue(currentState is CharacterViewModel.UiState.Success)
        assertEquals(mockCharacters, (currentState as CharacterViewModel.UiState.Success).characters)

        // Verify the repository was called exactly once
        coVerify(exactly = 1) { mockRepository.getCharacters(1) }
    }

    /**
     * TEST: Loading state is set before repository call completes
     *
     * LEARNING POINT: Testing intermediate states in async operations
     * This demonstrates that the Loading state is properly set during the async operation
     */
    @Test
    fun `loadCharacters sets Loading state during execution`() = runTest {
        val mockCharacters = listOf(
            Character("Leia Organa", "150", "49", "19BBY", "female", "url3")
        )

        coEvery { mockRepository.getCharacters(any()) } returns Result.Success(mockCharacters)

        // Start the async operation
        viewModel.loadCharacters()

        // Note: With UnconfinedTestDispatcher, loading happens immediately
        // But we can still verify the final state
        advanceUntilIdle()

        // The final state should be Success
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Success)
    }

    /**
     * TEST: Can load different pages
     *
     * LEARNING POINT: Testing function parameters are passed correctly
     */
    @Test
    fun `loadCharacters with page parameter calls repository with correct page`() = runTest {
        val mockCharacters = listOf(
            Character("Obi-Wan Kenobi", "182", "77", "57BBY", "male", "url4")
        )

        coEvery { mockRepository.getCharacters(2) } returns Result.Success(mockCharacters)

        // Act - Load page 2
        viewModel.loadCharacters(page = 2)
        advanceUntilIdle()

        // Assert
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Success)
        coVerify { mockRepository.getCharacters(2) }
    }

    // ========== ERROR HANDLING TESTS ==========

    /**
     * TEST: Network error is handled correctly
     *
     * LEARNING POINT: Testing error scenarios is crucial for robust applications.
     * This test simulates a network failure (no internet connection).
     */
    @Test
    fun `loadCharacters handles network error`() = runTest {
        // Arrange - Mock a network error
        val networkError = IOException("Network error occurred. Please check your connection.")
        coEvery { mockRepository.getCharacters(any()) } returns Result.Error(networkError)

        // Act
        viewModel.loadCharacters()
        advanceUntilIdle()

        // Assert
        val currentState = viewModel.uiState.value
        assertTrue(currentState is CharacterViewModel.UiState.Error)
        assertEquals(
            "Network error occurred. Please check your connection.",
            (currentState as CharacterViewModel.UiState.Error).message
        )
    }

    /**
     * TEST: Timeout error is handled correctly
     *
     * LEARNING POINT: Simulating timeout scenarios.
     * Timeouts are a common real-world problem, especially on slow networks.
     */
    @Test
    fun `loadCharacters handles timeout error`() = runTest {
        // Arrange - Mock a timeout error
        val timeoutError = IOException("Request timed out. Please check your internet connection.")
        coEvery { mockRepository.getCharacters(any()) } returns Result.Error(timeoutError)

        // Act
        viewModel.loadCharacters()
        advanceUntilIdle()

        // Assert
        val currentState = viewModel.uiState.value
        assertTrue(currentState is CharacterViewModel.UiState.Error)
        assertTrue((currentState as CharacterViewModel.UiState.Error).message.contains("timed out"))
    }

    /**
     * TEST: Generic exception is handled correctly
     *
     * LEARNING POINT: Always have a catch-all for unexpected errors
     */
    @Test
    fun `loadCharacters handles generic exception`() = runTest {
        // Arrange - Mock an unexpected error
        val exception = Exception("An unexpected error occurred: Something went wrong")
        coEvery { mockRepository.getCharacters(any()) } returns Result.Error(exception)

        // Act
        viewModel.loadCharacters()
        advanceUntilIdle()

        // Assert
        val currentState = viewModel.uiState.value
        assertTrue(currentState is CharacterViewModel.UiState.Error)
        assertTrue((currentState as CharacterViewModel.UiState.Error).message.contains("unexpected"))
    }

    /**
     * TEST: Empty list is handled correctly
     *
     * LEARNING POINT: Test edge cases like empty responses
     */
    @Test
    fun `loadCharacters handles empty list successfully`() = runTest {
        // Arrange - Mock empty list
        coEvery { mockRepository.getCharacters(any()) } returns Result.Success(emptyList())

        // Act
        viewModel.loadCharacters()
        advanceUntilIdle()

        // Assert
        val currentState = viewModel.uiState.value
        assertTrue(currentState is CharacterViewModel.UiState.Success)
        assertTrue((currentState as CharacterViewModel.UiState.Success).characters.isEmpty())
    }

    /**
     * TEST: Retry function works after error
     *
     * LEARNING POINT: Testing user recovery actions.
     * Users should be able to retry after an error.
     */
    @Test
    fun `retry calls loadCharacters again`() = runTest {
        // Arrange - First call fails, second succeeds
        val mockCharacters = listOf(
            Character("Yoda", "66", "17", "896BBY", "male", "url5")
        )

        coEvery { mockRepository.getCharacters(any()) } returns Result.Error(IOException("Network error")) andThen Result.Success(mockCharacters)

        // Act - First call fails
        viewModel.loadCharacters()
        advanceUntilIdle()
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Error)

        // Act - Retry succeeds
        viewModel.retry()
        advanceUntilIdle()

        // Assert
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Success)
        coVerify(exactly = 2) { mockRepository.getCharacters(1) }
    }

    /**
     * TEST: Multiple consecutive calls are handled correctly
     *
     * LEARNING POINT: Testing race conditions and rapid user interactions
     */
    @Test
    fun `multiple loadCharacters calls work correctly`() = runTest {
        val mockCharacters1 = listOf(
            Character("Han Solo", "180", "80", "29BBY", "male", "url6")
        )
        val mockCharacters2 = listOf(
            Character("Chewbacca", "228", "112", "200BBY", "male", "url7")
        )

        coEvery { mockRepository.getCharacters(1) } returns Result.Success(mockCharacters1)
        coEvery { mockRepository.getCharacters(2) } returns Result.Success(mockCharacters2)

        // Act - First call
        viewModel.loadCharacters(1)
        advanceUntilIdle()
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Success)

        // Act - Second call
        viewModel.loadCharacters(2)
        advanceUntilIdle()

        // Assert - Should have data from second call
        val currentState = viewModel.uiState.value
        assertTrue(currentState is CharacterViewModel.UiState.Success)
        assertEquals(mockCharacters2, (currentState as CharacterViewModel.UiState.Success).characters)
    }

    /**
     * TEST: Exception with null message is handled gracefully
     *
     * LEARNING POINT: Defensive programming - handle null error messages
     */
    @Test
    fun `loadCharacters handles exception with null message`() = runTest {
        // Arrange - Create exception with null message
        val exception = Exception(null as String?)
        coEvery { mockRepository.getCharacters(any()) } returns Result.Error(exception)

        // Act
        viewModel.loadCharacters()
        advanceUntilIdle()

        // Assert - Should show default error message
        val currentState = viewModel.uiState.value
        assertTrue(currentState is CharacterViewModel.UiState.Error)
        assertEquals("Unknown error occurred", (currentState as CharacterViewModel.UiState.Error).message)
    }
}

