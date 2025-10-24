package com.example.swapiapiexample.data.repository

/**
 * A sealed class that represents the result of an operation.
 * This is used to handle both success and error cases in a type-safe manner.
 */
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val exception: Exception) : Result<Nothing>()

    /**
     * Returns true if this is a Success result
     */
    fun isSuccess(): Boolean = this is Success

    /**
     * Returns true if this is an Error result
     */
    fun isError(): Boolean = this is Error
}

