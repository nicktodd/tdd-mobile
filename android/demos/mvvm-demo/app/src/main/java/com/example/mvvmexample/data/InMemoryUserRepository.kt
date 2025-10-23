package com.example.mvvmexample.data

import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

/**
 * In-Memory Repository Implementation
 *
 * This is a concrete implementation of UserRepository that stores data in memory.
 *
 * Design Notes:
 * - Uses a Mutex for thread-safe access to the mutable list (coroutine-safe)
 * - Can be initialized with seed data for demos or testing
 * - Returns defensive copies (toList()) to prevent external mutation
 *
 * In Production:
 * - This could be replaced with a RoomRepository (database) or NetworkRepository (API)
 * - The ViewModel wouldn't need to change at all - that's the power of the interface!
 *
 * For Testing:
 * - We DON'T use this in ViewModel unit tests (we use mocks instead)
 * - This keeps tests focused on ViewModel behavior, not repository implementation
 */
class InMemoryUserRepository(initialUsers: List<User> = emptyList()) : UserRepository {
    private val mutex = Mutex()
    private val users = initialUsers.toMutableList()

    override suspend fun getUsers(): List<User> = mutex.withLock {
        // Return a defensive copy to prevent external modification
        users.toList()
    }

    override suspend fun addUser(user: User): Unit = mutex.withLock {
        users.add(user)
    }
}
