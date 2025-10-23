package com.example.mvvmexample

import com.example.mvvmexample.data.User
import com.example.mvvmexample.data.UserRepository
import com.example.mvvmexample.ui.UserViewModel
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.Assert.*

/**
 * UserViewModel Unit Tests - Comprehensive MVVM Testing Example
 *
 * UNIT TEST PRINCIPLES DEMONSTRATED HERE:
 * ========================================
 *
 * 1. ISOLATION: Each test focuses on ONE behavior of the ViewModel
 *    - We mock the UserRepository so tests don't depend on its implementation
 *    - Tests are independent - they don't share state or affect each other
 *
 * 2. FAST: No real I/O, no Android framework, just pure Kotlin
 *    - Mocking eliminates slow operations
 *    - Tests run in milliseconds
 *
 * 3. REPEATABLE: Same inputs always produce same outputs
 *    - TestDispatchers make coroutines deterministic
 *    - No random data, no timestamps, no network variability
 *
 * 4. SELF-VALIDATING: Tests clearly pass or fail
 *    - Assertions provide clear error messages
 *    - No manual inspection needed
 *
 * 5. THOROUGH: Tests cover the behavior contract
 *    - Initial load behavior
 *    - Add user behavior
 *    - Delete user behavior
 *    - State updates
 *
 * TESTING TOOLS EXPLAINED:
 * ========================
 *
 * JUnit 4:
 * - Industry standard testing framework
 * - @Test annotates test methods
 * - @Before/@After for setup/teardown
 * - Works seamlessly with Android Studio
 *
 * MockK:
 * - Mocking framework for Kotlin
 * - coEvery/coVerify for suspend functions
 * - Allows us to control what repository returns
 * - Verifies ViewModel calls repository correctly
 *
 * kotlinx-coroutines-test:
 * - StandardTestDispatcher: Controls coroutine execution
 * - runTest: Provides test coroutine scope
 * - advanceUntilIdle: Executes all pending coroutines
 * - Makes async code testable synchronously
 *
 * WHY THESE ARE UNIT TESTS, NOT INTEGRATION TESTS:
 * =================================================
 * - We mock UserRepository (don't use real implementation)
 * - We don't test repository's behavior (that's its own test)
 * - We focus solely on ViewModel's logic and coordination
 * - No database, no network, no Android framework
 * - Tests run in pure JVM (no emulator/device needed)
 */
@OptIn(ExperimentalCoroutinesApi::class)
class ExampleUnitTest {

    /**
     * Test Setup: TestDispatcher
     *
     * Why we need this:
     * - ViewModel uses viewModelScope which normally runs on Main dispatcher
     * - Unit tests don't have Android Main thread
     * - StandardTestDispatcher gives us control over coroutine execution
     * - We can advance time and execution deterministically
     */
    private val testDispatcher = StandardTestDispatcher()

    /**
     * @Before runs before each test
     * Sets up the test environment
     */
    @Before
    fun setup() {
        // Replace Main dispatcher with test dispatcher
        Dispatchers.setMain(testDispatcher)
    }

    /**
     * @After runs after each test
     * Cleans up the test environment
     */
    @After
    fun tearDown() {
        // Clean up after all tests
        Dispatchers.resetMain()
    }

    // ===========================
    // INITIALIZATION TESTS
    // ===========================

    /**
     * Test: ViewModel should load users from repository when created
     *
     * This verifies that the init block properly calls the repository
     * and updates the StateFlow with the returned data.
     */
    @Test
    fun shouldLoadUsersFromRepositoryOnCreation() = runTest(testDispatcher) {
        // ARRANGE: Set up test data and mock behavior
        val mockRepository = mockk<UserRepository>()
        val expectedUsers = listOf(
            User(1L, "Alice"),
            User(2L, "Bob")
        )

        /**
         * coEvery: Define mock behavior for suspend function
         * When repository.getUsers() is called, return expectedUsers
         *
         * This is what makes it a UNIT test:
         * - We control exactly what the dependency returns
         * - We're not testing repository implementation
         * - We're testing how ViewModel handles the data
         */
        coEvery { mockRepository.getUsers() } returns expectedUsers

        // ACT: Create ViewModel (init block triggers loadUsers())
        val viewModel = UserViewModel(mockRepository)

        /**
         * advanceUntilIdle: Execute all pending coroutines
         * Without this, the coroutine launched in init wouldn't complete
         * TestDispatcher doesn't auto-advance time like production dispatchers
         */
        advanceUntilIdle()

        // ASSERT: Verify ViewModel state matches expected data
        assertEquals(expectedUsers, viewModel.users.value)

        /**
         * coVerify: Confirm repository method was called
         * Ensures ViewModel actually used the dependency
         * Important: We verify the interaction, not the implementation
         */
        coVerify(exactly = 1) { mockRepository.getUsers() }
    }

    /**
     * Test: ViewModel should handle empty repository state
     */
    @Test
    fun shouldStartWithEmptyListWhenRepositoryIsEmpty() = runTest(testDispatcher) {
        // ARRANGE: Mock repository returning empty list
        val mockRepository = mockk<UserRepository>()
        coEvery { mockRepository.getUsers() } returns emptyList()

        // ACT
        val viewModel = UserViewModel(mockRepository)
        advanceUntilIdle()

        // ASSERT
        assertTrue("Users list should be empty", viewModel.users.value.isEmpty())
    }

    // ===========================
    // ADD USER TESTS
    // ===========================

    /**
     * Test: Adding a user should update repository and StateFlow
     *
     * This verifies the complete flow:
     * 1. ViewModel generates correct ID
     * 2. Repository.addUser is called with correct data
     * 3. ViewModel refreshes state from repository
     */
    @Test
    fun shouldAddUserToRepositoryAndUpdateState() = runTest(testDispatcher) {
        // ARRANGE
        val mockRepository = mockk<UserRepository>(relaxed = true)

        /**
         * Mock Setup Strategy:
         * 1. Initially return empty list
         * 2. After add, return list with new user
         *
         * This simulates real repository behavior without using real implementation
         */
        val initialUsers = emptyList<User>()
        val userName = "Charlie"
        val expectedUser = User(1L, userName)

        // First call (during init): return empty
        // Second call (after addUser): return list with new user
        coEvery { mockRepository.getUsers() } returnsMany listOf(
            initialUsers,
            listOf(expectedUser)
        )

        // Mock addUser to do nothing (relaxed mock handles this)
        coEvery { mockRepository.addUser(any()) } returns Unit

        val viewModel = UserViewModel(mockRepository)

        // ACT: Add a user
        advanceUntilIdle() // Complete init
        viewModel.addUser(userName)
        advanceUntilIdle() // Complete addUser

        // ASSERT: Verify state was updated
        assertEquals(1, viewModel.users.value.size)
        assertEquals(userName, viewModel.users.value.first().name)

        /**
         * Verify Business Logic: ID Generation
         * ViewModel should generate ID = 1 for first user
         * This tests ViewModel's logic, not repository's
         */
        assertEquals(1L, viewModel.users.value.first().id)

        /**
         * Verify Interaction: Repository was called correctly
         *
         * This is key to unit testing:
         * - We verify ViewModel CALLED repository with correct parameters
         * - We don't test repository's implementation
         * - We trust repository does its job (it has its own tests)
         */
        coVerify {
            mockRepository.addUser(
                match { user ->
                    user.name == userName && user.id == 1L
                }
            )
        }

        // Verify getUsers was called twice: once in init, once after addUser
        coVerify(exactly = 2) { mockRepository.getUsers() }
    }

    /**
     * Test: ID generation logic for subsequent users
     *
     * Business Rule: newId = maxExistingId + 1
     */
    @Test
    fun shouldGenerateCorrectIdForSubsequentUsers() = runTest(testDispatcher) {
        // ARRANGE: Start with existing users
        val mockRepository = mockk<UserRepository>(relaxed = true)
        val existingUsers = listOf(
            User(1L, "Alice"),
            User(2L, "Bob")
        )

        /**
         * Testing Business Logic: ID Generation
         *
         * The ViewModel must generate newId = maxId + 1
         * This is pure business logic that belongs in ViewModel
         * Perfect candidate for unit testing!
         */
        coEvery { mockRepository.getUsers() } returnsMany listOf(
            existingUsers,
            existingUsers + User(3L, "Charlie")
        )
        coEvery { mockRepository.addUser(any()) } returns Unit

        val viewModel = UserViewModel(mockRepository)

        // ACT
        advanceUntilIdle()
        viewModel.addUser("Charlie")
        advanceUntilIdle()

        // ASSERT: New user should have ID = 3 (max of 2 + 1)
        coVerify {
            mockRepository.addUser(
                match { it.id == 3L && it.name == "Charlie" }
            )
        }
    }

    // ===========================
    // DELETE USER TESTS
    // ===========================

    /**
     * Test: Deleting a user should remove it from state
     */
    @Test
    fun shouldRemoveUserFromState() = runTest(testDispatcher) {
        // ARRANGE
        val mockRepository = mockk<UserRepository>()
        val users = listOf(
            User(1L, "Alice"),
            User(2L, "Bob"),
            User(3L, "Charlie")
        )
        coEvery { mockRepository.getUsers() } returns users

        val viewModel = UserViewModel(mockRepository)

        // ACT: Delete user with ID 2
        advanceUntilIdle()
        viewModel.deleteUser(2L)
        advanceUntilIdle()

        // ASSERT: Bob should be removed
        assertEquals(2, viewModel.users.value.size)
        assertEquals(listOf("Alice", "Charlie"), viewModel.users.value.map { it.name })
    }

    /**
     * Test: Deleting non-existent user should not crash or change state
     */
    @Test
    fun shouldHandleDeletingNonExistentUserGracefully() = runTest(testDispatcher) {
        // ARRANGE
        val mockRepository = mockk<UserRepository>()
        val users = listOf(User(1L, "Alice"))
        coEvery { mockRepository.getUsers() } returns users

        val viewModel = UserViewModel(mockRepository)

        // ACT: Try to delete user that doesn't exist
        advanceUntilIdle()
        viewModel.deleteUser(999L)
        advanceUntilIdle()

        // ASSERT: State should be unchanged
        assertEquals(1, viewModel.users.value.size)
        assertEquals("Alice", viewModel.users.value.first().name)
    }

    // ===========================
    // EDGE CASE TESTS
    // ===========================

    /**
     * Test: ID generation from empty list
     *
     * This tests the ?: 0L fallback in maxOfOrNull
     * Edge case: What happens when there are no existing users?
     * Expected: ID should be 1
     */
    @Test
    fun shouldGenerateIdOneWhenStartingFromEmptyList() = runTest(testDispatcher) {
        val mockRepository = mockk<UserRepository>(relaxed = true)
        coEvery { mockRepository.getUsers() } returnsMany listOf(
            emptyList(),
            listOf(User(1L, "First"))
        )
        coEvery { mockRepository.addUser(any()) } returns Unit

        val viewModel = UserViewModel(mockRepository)

        advanceUntilIdle()
        viewModel.addUser("First")
        advanceUntilIdle()

        coVerify { mockRepository.addUser(match { it.id == 1L }) }
    }

    /**
     * Test: Multiple sequential additions
     *
     * Verifies that ID generation works correctly across multiple operations
     */
    @Test
    fun shouldHandleMultipleSequentialAddsCorrectly() = runTest(testDispatcher) {
        // ARRANGE
        val mockRepository = mockk<UserRepository>(relaxed = true)

        // Mock returns progressively more users
        coEvery { mockRepository.getUsers() } returnsMany listOf(
            emptyList(),
            listOf(User(1L, "First")),
            listOf(User(1L, "First"), User(2L, "Second")),
            listOf(User(1L, "First"), User(2L, "Second"), User(3L, "Third"))
        )
        coEvery { mockRepository.addUser(any()) } returns Unit

        val viewModel = UserViewModel(mockRepository)
        advanceUntilIdle()

        // ACT: Add three users sequentially
        viewModel.addUser("First")
        advanceUntilIdle()
        viewModel.addUser("Second")
        advanceUntilIdle()
        viewModel.addUser("Third")
        advanceUntilIdle()

        // ASSERT: All three users should be in the state
        assertEquals(3, viewModel.users.value.size)

        // Verify each add was called with correct ID
        coVerify { mockRepository.addUser(match { it.id == 1L && it.name == "First" }) }
        coVerify { mockRepository.addUser(match { it.id == 2L && it.name == "Second" }) }
        coVerify { mockRepository.addUser(match { it.id == 3L && it.name == "Third" }) }
    }
}

/**
 * SUMMARY: What Makes These Good Unit Tests
 * ==========================================
 *
 * ✅ FAST: Run in milliseconds, no I/O
 * ✅ ISOLATED: Each test is independent
 * ✅ FOCUSED: Each test verifies ONE behavior
 * ✅ READABLE: Clear arrange/act/assert structure with comments
 * ✅ MAINTAINABLE: Mock setup is simple and clear
 * ✅ DETERMINISTIC: Always produce same result
 * ✅ COMPREHENSIVE: Cover happy paths, edge cases, and business logic
 *
 * What We Test:
 * - ViewModel's business logic (ID generation)
 * - State management (StateFlow updates)
 * - Coordination with repository (correct method calls)
 * - Coroutine behavior (async operations complete correctly)
 *
 * What We Don't Test (and why):
 * - Repository implementation: That's repository's unit tests
 * - UI rendering: That's Compose UI tests
 * - Android framework: We trust the framework works
 * - Network/Database: Those are integration test concerns
 *
 * This separation of concerns makes tests:
 * - Easier to write
 * - Easier to understand
 * - Easier to maintain
 * - Faster to run
 * - More reliable
 */
