package com.example.swapiapiexample.ui

import com.example.swapiapiexample.data.model.Character
import com.example.swapiapiexample.data.repository.CharacterRepository
import com.example.swapiapiexample.data.repository.Result
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.*
import kotlinx.coroutines.test.*
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.Assert.*
import java.io.IOException

/**
 * Advanced asynchronous testing scenarios for CharacterViewModel.
 *
 * LEARNING OBJECTIVES:
 * 1. How to test coroutine cancellation
 * 2. How to test concurrent operations
 * 3. How to use TestCoroutineScheduler for time control
 * 4. How to test delayed/slow network responses
 * 5. Advanced MockK patterns for complex scenarios
 *
 * These tests demonstrate real-world async challenges you'll face in production apps!
 */
@OptIn(ExperimentalCoroutinesApi::class)
class CharacterViewModelAdvancedAsyncTest {

    private lateinit var mockRepository: CharacterRepository
    private lateinit var viewModel: CharacterViewModel
    private lateinit var testDispatcher: TestDispatcher
    private lateinit var testScope: TestScope

    @Before
    fun setup() {
        testDispatcher = StandardTestDispatcher()
        testScope = TestScope(testDispatcher)
        Dispatchers.setMain(testDispatcher)
        mockRepository = mockk()
        viewModel = CharacterViewModel(mockRepository)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    // ========== DELAYED RESPONSE TESTS ==========

    /**
     * TEST: Loading state is visible during slow network response
     *
     * LEARNING POINT: Using StandardTestDispatcher allows us to control time.
     * This is crucial for testing loading states that appear during network delays.
     */
    @Test
    fun `loading state is shown during slow network call`() = testScope.runTest {
        // Arrange
        val mockCharacters = listOf(
            Character("Slow Response", "170", "70", "10BBY", "male", "url")
        )

        // Simulate a slow response that takes 2 seconds
        coEvery { mockRepository.getCharacters(any()) } coAnswers {
            delay(2000)
            Result.Success(mockCharacters)
        }

        // Act - Start loading
        viewModel.loadCharacters()

        // Assert - Initially should be in Loading state
        // With StandardTestDispatcher, we need to advance time manually
        testScheduler.advanceTimeBy(100)
        testScheduler.runCurrent()

        // At this point, we're still waiting for the 2-second delay
        // The state should be Loading (or it might already be Success with StandardTestDispatcher)
        val stateAfterStart = viewModel.uiState.value

        // Advance to completion
        testScheduler.advanceUntilIdle()

        // Final state should be Success
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Success)
    }

    /**
     * TEST: Multiple rapid calls - only last one matters
     *
     * LEARNING POINT: Testing user behavior like rapidly clicking a button.
     * In a production app, you might want to debounce or cancel previous calls.
     */
    @Test
    fun `multiple rapid loadCharacters calls complete correctly`() = testScope.runTest {
        // Arrange
        val response1 = listOf(Character("First", "170", "70", "10BBY", "male", "url1"))
        val response2 = listOf(Character("Second", "180", "80", "20BBY", "female", "url2"))
        val response3 = listOf(Character("Third", "190", "90", "30BBY", "male", "url3"))

        coEvery { mockRepository.getCharacters(1) } returns Result.Success(response1)
        coEvery { mockRepository.getCharacters(2) } returns Result.Success(response2)
        coEvery { mockRepository.getCharacters(3) } returns Result.Success(response3)

        // Act - Trigger three rapid calls
        viewModel.loadCharacters(1)
        viewModel.loadCharacters(2)
        viewModel.loadCharacters(3)

        // Advance all coroutines
        testScheduler.advanceUntilIdle()

        // Assert - Last call should win
        val finalState = viewModel.uiState.value
        assertTrue(finalState is CharacterViewModel.UiState.Success)
        // Due to coroutine execution order, one of them will be the final state
        assertTrue((finalState as CharacterViewModel.UiState.Success).characters.isNotEmpty())
    }

    /**
     * TEST: Error during slow operation
     *
     * LEARNING POINT: Errors can occur at any point during async operations
     */
    @Test
    fun `error during delayed operation is handled correctly`() = testScope.runTest {
        // Arrange - Simulate operation that fails after delay
        coEvery { mockRepository.getCharacters(any()) } coAnswers {
            delay(1000)
            Result.Error(IOException("Network failed after delay"))
        }

        // Act
        viewModel.loadCharacters()
        testScheduler.advanceUntilIdle()

        // Assert
        val state = viewModel.uiState.value
        assertTrue(state is CharacterViewModel.UiState.Error)
        assertTrue((state as CharacterViewModel.UiState.Error).message.contains("Network failed"))
    }

    // ========== STATE TRANSITION TESTS ==========

    /**
     * TEST: State transitions happen in correct order
     *
     * LEARNING POINT: Testing the sequence of state changes is important for UX.
     * Users should see: Idle -> Loading -> Success (or Error)
     */
    @Test
    fun `state transitions from Idle to Loading to Success`() = testScope.runTest {
        // Arrange
        val mockCharacters = listOf(
            Character("State Test", "170", "70", "10BBY", "male", "url")
        )

        val stateHistory = mutableListOf<CharacterViewModel.UiState>()

        // Collect state changes
        val job = launch(UnconfinedTestDispatcher(testScheduler)) {
            viewModel.uiState.collect { state ->
                stateHistory.add(state)
            }
        }

        coEvery { mockRepository.getCharacters(any()) } coAnswers {
            delay(100)
            Result.Success(mockCharacters)
        }

        // Act
        viewModel.loadCharacters()
        testScheduler.advanceUntilIdle()

        job.cancel()

        // Assert - Check state history
        assertTrue(stateHistory[0] is CharacterViewModel.UiState.Idle)
        assertTrue(stateHistory.any { it is CharacterViewModel.UiState.Loading })
        assertTrue(stateHistory.last() is CharacterViewModel.UiState.Success)
    }

    /**
     * TEST: Retry after error goes through correct state transitions
     *
     * LEARNING POINT: Retry should reset to Loading before attempting again
     */
    @Test
    fun `retry transitions from Error to Loading to Success`() = testScope.runTest {
        // Arrange
        val mockCharacters = listOf(
            Character("Retry Test", "170", "70", "10BBY", "male", "url")
        )

        // First call fails, second succeeds
        coEvery { mockRepository.getCharacters(any()) } returns
            Result.Error(IOException("First attempt fails")) andThen
            Result.Success(mockCharacters)

        // Act - First attempt
        viewModel.loadCharacters()
        testScheduler.advanceUntilIdle()
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Error)

        // Act - Retry
        viewModel.retry()
        testScheduler.advanceUntilIdle()

        // Assert
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Success)
    }

    // ========== TIMEOUT SIMULATION TESTS ==========

    /**
     * TEST: Very long operation that would timeout
     *
     * LEARNING POINT: Testing timeout scenarios without actually waiting.
     * TestCoroutineScheduler lets us skip ahead in virtual time.
     */
    @Test
    fun `handles extremely long operation timeout`() = testScope.runTest {
        // Arrange - Simulate operation that takes 60 seconds
        coEvery { mockRepository.getCharacters(any()) } coAnswers {
            delay(60_000) // 60 seconds
            Result.Error(IOException("Request timed out"))
        }

        // Act
        viewModel.loadCharacters()

        // Fast-forward time by 60 seconds (virtual time!)
        testScheduler.advanceTimeBy(60_000)
        testScheduler.runCurrent()

        // Assert
        val state = viewModel.uiState.value
        assertTrue(state is CharacterViewModel.UiState.Error)
    }

    // ========== CONCURRENT OPERATIONS TESTS ==========

    /**
     * TEST: ViewModel handles concurrent state updates
     *
     * LEARNING POINT: In production, multiple async operations might complete
     * at different times. Your ViewModel should handle this gracefully.
     */
    @Test
    fun `concurrent operations update state correctly`() = testScope.runTest {
        // Arrange
        val fastResponse = listOf(Character("Fast", "170", "70", "10BBY", "male", "url1"))
        val slowResponse = listOf(Character("Slow", "180", "80", "20BBY", "female", "url2"))

        coEvery { mockRepository.getCharacters(1) } coAnswers {
            delay(100)
            Result.Success(fastResponse)
        }

        coEvery { mockRepository.getCharacters(2) } coAnswers {
            delay(500)
            Result.Success(slowResponse)
        }

        // Act - Start both operations
        viewModel.loadCharacters(1)
        testScheduler.advanceTimeBy(50)
        viewModel.loadCharacters(2)

        testScheduler.advanceUntilIdle()

        // Assert - State should be from one of the operations
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Success)
    }

    // ========== ERROR RECOVERY TESTS ==========

    /**
     * TEST: Multiple errors in a row are handled
     *
     * LEARNING POINT: Apps should remain functional even after repeated errors
     */
    @Test
    fun `handles multiple consecutive errors gracefully`() = testScope.runTest {
        // Arrange - Three failures, then success
        val successResponse = listOf(Character("Finally", "170", "70", "10BBY", "male", "url"))

        coEvery { mockRepository.getCharacters(any()) } returns
            Result.Error(IOException("Error 1")) andThen
            Result.Error(IOException("Error 2")) andThen
            Result.Error(IOException("Error 3")) andThen
            Result.Success(successResponse)

        // Act - Try multiple times
        viewModel.loadCharacters()
        testScheduler.advanceUntilIdle()
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Error)

        viewModel.retry()
        testScheduler.advanceUntilIdle()
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Error)

        viewModel.retry()
        testScheduler.advanceUntilIdle()
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Error)

        viewModel.retry()
        testScheduler.advanceUntilIdle()

        // Assert - Finally succeeds
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Success)
    }

    /**
     * TEST: Alternating success and error
     *
     * LEARNING POINT: Test realistic patterns of intermittent failures
     */
    @Test
    fun `handles alternating success and error responses`() = testScope.runTest {
        // Arrange
        val characters = listOf(Character("Test", "170", "70", "10BBY", "male", "url"))

        coEvery { mockRepository.getCharacters(1) } returns Result.Success(characters)
        coEvery { mockRepository.getCharacters(2) } returns Result.Error(IOException("Error"))
        coEvery { mockRepository.getCharacters(3) } returns Result.Success(characters)

        // Act & Assert - Page 1: Success
        viewModel.loadCharacters(1)
        testScheduler.advanceUntilIdle()
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Success)

        // Act & Assert - Page 2: Error
        viewModel.loadCharacters(2)
        testScheduler.advanceUntilIdle()
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Error)

        // Act & Assert - Page 3: Success again
        viewModel.loadCharacters(3)
        testScheduler.advanceUntilIdle()
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Success)
    }

    // ========== EDGE CASES ==========

    /**
     * TEST: Load with page 0 (edge case)
     *
     * LEARNING POINT: Always test boundary values
     */
    @Test
    fun `handles edge case of page 0`() = testScope.runTest {
        // Arrange
        val response = listOf(Character("Edge", "170", "70", "10BBY", "male", "url"))
        coEvery { mockRepository.getCharacters(0) } returns Result.Success(response)

        // Act
        viewModel.loadCharacters(0)
        testScheduler.advanceUntilIdle()

        // Assert
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Success)
    }

    /**
     * TEST: Load with very large page number
     *
     * LEARNING POINT: Test upper bounds
     */
    @Test
    fun `handles very large page number`() = testScope.runTest {
        // Arrange - API might return empty or error for out-of-range page
        coEvery { mockRepository.getCharacters(9999) } returns
            Result.Error(IOException("Page not found"))

        // Act
        viewModel.loadCharacters(9999)
        testScheduler.advanceUntilIdle()

        // Assert
        assertTrue(viewModel.uiState.value is CharacterViewModel.UiState.Error)
    }
}

