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
 * Unit tests for UserViewModel.
 *
 * File purpose:
 * - Tests focus exclusively on ViewModel behavior and its interactions with the
 *   `UserRepository` abstraction (mocked with MockK).
 * - This file replaces the older `ExampleUnitTest.kt` to make the intent explicit.
 */
@OptIn(ExperimentalCoroutinesApi::class)
class UserViewModelTest {

    // Use a test dispatcher to control coroutine execution deterministically
    private val testDispatcher = StandardTestDispatcher()

    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    // ------------------------------
    // Initialization / loading tests
    // ------------------------------

    @Test
    fun loadsUsersFromRepositoryOnCreation() = runTest(testDispatcher) {
        val mockRepository = mockk<UserRepository>()
        val expectedUsers = listOf(User(1L, "Alice"), User(2L, "Bob"))

        coEvery { mockRepository.getUsers() } returns expectedUsers

        val viewModel = UserViewModel(mockRepository)
        advanceUntilIdle()

        assertEquals(expectedUsers, viewModel.users.value)
        coVerify(exactly = 1) { mockRepository.getUsers() }
    }

    @Test
    fun startsWithEmptyListWhenRepositoryIsEmpty() = runTest(testDispatcher) {
        val mockRepository = mockk<UserRepository>()
        coEvery { mockRepository.getUsers() } returns emptyList()

        val viewModel = UserViewModel(mockRepository)
        advanceUntilIdle()

        assertTrue(viewModel.users.value.isEmpty())
    }

    // ------------------------------
    // Add-user behavior
    // ------------------------------

    @Test
    fun addUser_callsRepositoryAndUpdatesState() = runTest(testDispatcher) {
        val mockRepository = mockk<UserRepository>(relaxed = true)

        val initialUsers = emptyList<User>()
        val userName = "Charlie"
        val expectedUser = User(1L, userName)

        coEvery { mockRepository.getUsers() } returnsMany listOf(initialUsers, listOf(expectedUser))
        coEvery { mockRepository.addUser(any()) } returns Unit

        val viewModel = UserViewModel(mockRepository)
        advanceUntilIdle()

        viewModel.addUser(userName)
        advanceUntilIdle()

        assertEquals(1, viewModel.users.value.size)
        assertEquals(userName, viewModel.users.value.first().name)
        assertEquals(1L, viewModel.users.value.first().id)

        coVerify {
            mockRepository.addUser(match { it.name == userName && it.id == 1L })
        }
        coVerify(exactly = 2) { mockRepository.getUsers() }
    }

    @Test
    fun generatesCorrectIdForSubsequentUsers() = runTest(testDispatcher) {
        val mockRepository = mockk<UserRepository>(relaxed = true)
        val existingUsers = listOf(User(1L, "Alice"), User(2L, "Bob"))

        coEvery { mockRepository.getUsers() } returnsMany listOf(existingUsers, existingUsers + User(3L, "Charlie"))
        coEvery { mockRepository.addUser(any()) } returns Unit

        val viewModel = UserViewModel(mockRepository)
        advanceUntilIdle()

        viewModel.addUser("Charlie")
        advanceUntilIdle()

        coVerify { mockRepository.addUser(match { it.id == 3L && it.name == "Charlie" }) }
    }

    // ------------------------------
    // Delete-user behavior
    // ------------------------------

    @Test
    fun deleteUser_removesUserFromState() = runTest(testDispatcher) {
        val mockRepository = mockk<UserRepository>()
        val users = listOf(User(1L, "Alice"), User(2L, "Bob"), User(3L, "Charlie"))
        coEvery { mockRepository.getUsers() } returns users

        val viewModel = UserViewModel(mockRepository)
        advanceUntilIdle()

        viewModel.deleteUser(2L)
        advanceUntilIdle()

        assertEquals(2, viewModel.users.value.size)
        assertEquals(listOf("Alice", "Charlie"), viewModel.users.value.map { it.name })
    }

    @Test
    fun deleteNonExistentUser_doesNotChangeState() = runTest(testDispatcher) {
        val mockRepository = mockk<UserRepository>()
        val users = listOf(User(1L, "Alice"))
        coEvery { mockRepository.getUsers() } returns users

        val viewModel = UserViewModel(mockRepository)
        advanceUntilIdle()

        viewModel.deleteUser(999L)
        advanceUntilIdle()

        assertEquals(1, viewModel.users.value.size)
        assertEquals("Alice", viewModel.users.value.first().name)
    }

    // ------------------------------
    // Edge-case / sequential-add tests
    // ------------------------------

    @Test
    fun idGenerationStartsAtOneWhenRepositoryEmpty() = runTest(testDispatcher) {
        val mockRepository = mockk<UserRepository>(relaxed = true)
        coEvery { mockRepository.getUsers() } returnsMany listOf(emptyList(), listOf(User(1L, "First")))
        coEvery { mockRepository.addUser(any()) } returns Unit

        val viewModel = UserViewModel(mockRepository)
        advanceUntilIdle()

        viewModel.addUser("First")
        advanceUntilIdle()

        coVerify { mockRepository.addUser(match { it.id == 1L }) }
    }

    @Test
    fun multipleSequentialAdds_generateIncreasingIds() = runTest(testDispatcher) {
        val mockRepository = mockk<UserRepository>(relaxed = true)

        coEvery { mockRepository.getUsers() } returnsMany listOf(
            emptyList(),
            listOf(User(1L, "First")),
            listOf(User(1L, "First"), User(2L, "Second")),
            listOf(User(1L, "First"), User(2L, "Second"), User(3L, "Third"))
        )
        coEvery { mockRepository.addUser(any()) } returns Unit

        val viewModel = UserViewModel(mockRepository)
        advanceUntilIdle()

        viewModel.addUser("First")
        advanceUntilIdle()
        viewModel.addUser("Second")
        advanceUntilIdle()
        viewModel.addUser("Third")
        advanceUntilIdle()

        assertEquals(3, viewModel.users.value.size)

        coVerify { mockRepository.addUser(match { it.id == 1L && it.name == "First" }) }
        coVerify { mockRepository.addUser(match { it.id == 2L && it.name == "Second" }) }
        coVerify { mockRepository.addUser(match { it.id == 3L && it.name == "Third" }) }
    }
}
