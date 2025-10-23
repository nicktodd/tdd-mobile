package com.example.mvvmexample.data

import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.async
import kotlinx.coroutines.test.runTest
import org.junit.Assert.*
import org.junit.Test

/**
 * Unit tests for the InMemoryUserRepository implementation.
 *
 * These tests focus only on the repository implementation itself (no ViewModel).
 * They intentionally do NOT use mocking (MockK) because we want to test the concrete
 * behavior of the in-memory repository. For repositories backed by databases or
 * network layers you'd either:
 *  - test the implementation directly (like here) using in-memory drivers (Room in-memory DB), or
 *  - mock collaborators when the repository itself depends on other layers.
 */
@OptIn(ExperimentalCoroutinesApi::class)
class InMemoryUserRepositoryTest {

    /**
     * Happy path: repository returns initial users passed to constructor.
     */
    @Test
    fun getUsers_returnsInitialUsers() = runTest {
        val initial = listOf(User(1L, "Alice"), User(2L, "Bob"))
        val repo = InMemoryUserRepository(initial)

        val users = repo.getUsers()

        assertEquals("Repository should return the initial users", initial, users)
    }

    /**
     * Adding a user should update the repository so subsequent getUsers() includes it.
     */
    @Test
    fun addUser_updatesRepository() = runTest {
        val repo = InMemoryUserRepository()
        val newUser = User(1L, "Charlie")

        repo.addUser(newUser)

        val users = repo.getUsers()
        assertEquals(1, users.size)
        assertEquals(newUser, users.first())
    }

    /**
     * Defensive copy / snapshot semantics: getUsers() returns a snapshot, not a live view.
     * We verify that a previously-obtained snapshot does not change when repository data changes.
     */
    @Test
    fun getUsers_returnsSnapshotNotLiveView() = runTest {
        val repo = InMemoryUserRepository()

        val snapshot = repo.getUsers() // should be empty
        repo.addUser(User(1L, "First"))

        // Snapshot captured earlier should NOT reflect later additions
        assertTrue("Previously captured snapshot should remain empty", snapshot.isEmpty())

        // Current repository state should include the added user
        val current = repo.getUsers()
        assertEquals(1, current.size)
        assertEquals("First", current.first().name)
    }

    /**
     * Concurrency test: many concurrent adds should all succeed.
     * This verifies the Mutex-based protection in the implementation.
     *
     * Edge note: This is still a unit test of the concrete implementation. It does
     * not require mocking. If the repository delegated to another async component
     * you'd mock that collaborator instead.
     */
    @Test
    fun concurrentAdds_areAllPresent() = runTest {
        val repo = InMemoryUserRepository()
        val n = 100

        // Launch many concurrent operations that add users
        val jobs = (1..n).map { i ->
            async {
                repo.addUser(User(i.toLong(), "User$i"))
            }
        }

        // Await all additions
        jobs.forEach { it.await() }

        val users = repo.getUsers()
        assertEquals("All concurrent adds should be present", n, users.size)

        // Sort by numeric id to avoid lexicographic ordering issues (User1, User10, ...)
        val namesSortedById = users.sortedBy { it.id }.map { it.name }
        val expected = (1..n).map { "User$it" }
        assertEquals(expected, namesSortedById)
    }
}
