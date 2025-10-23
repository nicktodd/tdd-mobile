package com.example.mvvmexample.data

/**
 * Repository Interface
 *
 * In MVVM, the Repository pattern abstracts the data source from the ViewModel.
 * This interface defines the contract for data operations without specifying implementation.
 *
 * Benefits for testing:
 * 1. DEPENDENCY INVERSION: The ViewModel depends on an abstraction (interface), not a concrete class
 * 2. MOCKABILITY: In unit tests, we can mock this interface using MockK
 * 3. FLEXIBILITY: We can swap implementations (in-memory, database, network) without changing ViewModel
 * 4. TESTABILITY: Tests can verify the ViewModel calls the right repository methods with correct parameters
 *
 * All methods are suspend functions to work with Kotlin coroutines for async operations.
 */
interface UserRepository {
    /**
     * Retrieves all users from the data source.
     * Suspend function allows this to be called from coroutines without blocking.
     */
    suspend fun getUsers(): List<User>

    /**
     * Adds a new user to the data source.
     */
    suspend fun addUser(user: User)
}

