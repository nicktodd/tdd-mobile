package com.example.mvvmexample.data

/**
 * Domain Model: User
 *
 * In MVVM, domain models are simple data classes that represent the core business entities.
 * They are:
 * - Immutable (using 'data class' and 'val')
 * - Free from Android dependencies
 * - Easy to test because they have no behavior, just data
 *
 * This makes them perfect for unit testing - we can create instances easily in tests
 * without any mocking or setup.
 */
data class User(
    val id: Long,
    val name: String
)

