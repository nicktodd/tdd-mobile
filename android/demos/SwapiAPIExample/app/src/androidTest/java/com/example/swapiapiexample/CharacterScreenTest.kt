package com.example.swapiapiexample

import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onAllNodesWithText
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import com.example.swapiapiexample.ui.CharacterViewModel
import com.example.swapiapiexample.data.repository.CharacterRepository
import com.example.swapiapiexample.data.model.Character
import com.example.swapiapiexample.data.repository.Result

/**
 * UI tests for CharacterScreen composable.
 *
 * IMPORTANT: WHY ARE THESE IN androidTest/ AND NOT test/?
 *
 * Location: app/src/androidTest/ (Instrumented Tests)
 * - These tests require an Android device or emulator to run
 * - Compose UI testing requires the Android runtime and framework
 * - These are slower than unit tests but necessary for UI validation
 *
 * Compare with: app/src/test/ (Unit Tests)
 * - CharacterViewModel tests run on the JVM (fast, no device needed)
 * - CharacterRepository tests run on the JVM (fast, no device needed)
 * - These test business logic without Android dependencies
 *
 * LEARNING OBJECTIVES:
 * 1. View tests are LIMITED - they only verify UI elements are displayed
 * 2. No business logic testing here - that's in ViewModel and Repository tests
 * 3. These tests demonstrate the "testing pyramid":
 *    - Many fast unit tests (ViewModel, Repository) ← Most of your tests
 *    - Few slower UI tests (CharacterScreen) ← Only what you can't test elsewhere
 * 4. Views have minimal testable code because we follow MVVM principles
 *    - All logic is in ViewModel
 *    - Views just display data and forward events
 *
 * What these tests DO verify:
 * - Correct UI elements appear for each state (title, loading text, error message)
 * - UI responds to state changes from ViewModel
 *
 * What these tests DON'T verify (tested elsewhere):
 * - Network calls (Repository tests)
 * - State management (ViewModel tests)
 * - Error handling logic (ViewModel tests)
 * - Data transformation (ViewModel/Repository tests)
 */
@RunWith(AndroidJUnit4::class)
class CharacterScreenTest {
    @get:Rule
    val composeTestRule = createComposeRule()

    /**
     * Test 1: Verify the title is always displayed.
     *
     * What this tests: The static title "Star Wars Characters" appears on screen.
     * What this DOESN'T test: Nothing about data loading, error handling, or business logic.
     *
     * Why this test is limited:
     * - It's just checking if text is rendered
     * - No logic being tested - just UI composition
     * - Compare to ViewModel tests which verify actual behavior
     */
    @Test
    fun title_isDisplayed() {
        // Arrange: Set up a fake repository that returns empty data
        val fakeRepository = FakeRepository()
        val viewModel = CharacterViewModel(fakeRepository)

        // Act: Render the CharacterScreen
        composeTestRule.setContent {
            CharacterScreen(
                repository = fakeRepository,
                viewModel = viewModel
            )
        }

        // Assert: Verify the title text is present
        composeTestRule.onNodeWithText("Star Wars Characters").assertExists()
    }

    /**
     * Test 2: Verify loading state displays correct UI elements.
     *
     * What this tests: When ViewModel is in Loading state, the UI shows loading indicator and text.
     * What this DOESN'T test:
     * - When/why loading state is triggered (ViewModel test)
     * - How long loading takes (ViewModel test)
     * - What happens after loading (ViewModel test)
     *
     * Why this test is limited:
     * - Only verifies UI elements exist, not the logic that creates the loading state
     * - The ViewModel (tested separately) controls when this state appears
     */
    @Test
    fun loadingState_showsLoadingIndicatorAndText() {
        // Arrange: Use a repository that delays indefinitely to maintain loading state
        val fakeRepository = FakeDelayingRepository()
        val viewModel = CharacterViewModel(fakeRepository)

        // Act: Render the screen (LaunchedEffect will trigger loading)
        composeTestRule.setContent {
            CharacterScreen(
                repository = fakeRepository,
                viewModel = viewModel
            )
        }

        // Assert: Verify loading text is displayed
        // NOTE: We're NOT testing if the loading indicator works correctly,
        // just that the text is present when in loading state
        composeTestRule.onNodeWithText("Loading characters...").assertExists()
    }

    /**
     * Test 3: Verify error state displays correct UI elements.
     *
     * What this tests: When ViewModel is in Error state, the UI shows error message and retry button.
     * What this DOESN'T test:
     * - Error handling logic (ViewModel test)
     * - Network error detection (Repository test)
     * - What happens when Retry is clicked (ViewModel test)
     * - Error message formatting (ViewModel test)
     *
     * Why this test is limited:
     * - Only verifies UI elements are rendered for error state
     * - All error handling logic is tested in ViewModel tests
     * - This just confirms the view responds correctly to ViewModel state
     */
    @Test
    fun errorState_showsErrorMessageAndRetryButton() {
        // Arrange: Use a repository that always returns an error
        val fakeRepository = FakeErrorRepository()
        val viewModel = CharacterViewModel(fakeRepository)

        // Act: Render the screen
        composeTestRule.setContent {
            CharacterScreen(
                repository = fakeRepository,
                viewModel = viewModel
            )
        }

        // Wait for error state to appear (network call happens in LaunchedEffect)
        composeTestRule.waitUntil(timeoutMillis = 3000) {
            composeTestRule
                .onAllNodesWithText("⚠️ Error")
                .fetchSemanticsNodes()
                .isNotEmpty()
        }

        // Assert: Verify all error UI elements are displayed
        composeTestRule.onNodeWithText("⚠️ Error").assertExists()
        composeTestRule.onNodeWithText("Network error occurred").assertExists()
        composeTestRule.onNodeWithText("Retry").assertExists()

        // NOTE: We're NOT testing what happens when Retry is clicked
        // That's tested in CharacterViewModelTest.retry_reloadsCharacters()
    }
}

/**
 * Fake Repositories for UI Testing
 *
 * These are test doubles that simulate different scenarios WITHOUT implementing any logic.
 * They allow us to test how the UI responds to different ViewModel states.
 *
 * IMPORTANT: These are NOT the same as the mocks in ViewModel tests!
 * - ViewModel tests use MockK to verify interactions and behavior
 * - These UI tests use simple fakes to put the ViewModel into specific states
 *
 * Why we need different fakes:
 * - FakeRepository: Returns success immediately (for testing Idle state)
 * - FakeDelayingRepository: Delays forever (keeps ViewModel in Loading state)
 * - FakeErrorRepository: Returns an error (puts ViewModel in Error state)
 */

// Fake #1: Returns successful empty result (for Idle/Success state testing)
class FakeRepository : CharacterRepository {
    override suspend fun getCharacters(page: Int): Result<List<Character>> {
        return Result.Success(emptyList())
    }
}

// Fake #2: Delays indefinitely to maintain Loading state
class FakeDelayingRepository : CharacterRepository {
    override suspend fun getCharacters(page: Int): Result<List<Character>> {
        // This keeps the ViewModel in Loading state for the entire test
        kotlinx.coroutines.delay(Long.MAX_VALUE)
        return Result.Success(emptyList())
    }
}

// Fake #3: Always returns an error to trigger Error state
class FakeErrorRepository : CharacterRepository {
    override suspend fun getCharacters(page: Int): Result<List<Character>> {
        // Return a specific error message that we can verify in the UI
        return Result.Error(Exception("Network error occurred"))
    }
}

