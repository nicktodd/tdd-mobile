package com.example.swapiapiexample.data.repository

import com.example.swapiapiexample.data.api.SwapiService
import com.example.swapiapiexample.data.model.Character
import kotlinx.coroutines.delay
import java.io.IOException
import java.net.SocketTimeoutException

/**
 * Implementation of CharacterRepository that fetches data from the SWAPI API.
 * This class handles all network operations and error cases.
 */
class CharacterRepositoryImpl(
    private val swapiService: SwapiService,
    private val networkDelayMs: Long = 0 // For simulating network latency in tests
) : CharacterRepository {

    /**
     * Fetches characters from the SWAPI API with comprehensive error handling
     */
    override suspend fun getCharacters(page: Int): Result<List<Character>> {
        return try {
            // Simulate network delay if configured (useful for testing)
            if (networkDelayMs > 0) {
                delay(networkDelayMs)
            }

            val response = swapiService.getCharacters(page)
            Result.Success(response.results)

        } catch (e: SocketTimeoutException) {
            // Handle timeout specifically - this is important for demonstrating timeout testing
            Result.Error(IOException("Request timed out. Please check your internet connection.", e))

        } catch (e: IOException) {
            // Handle network errors (no internet, server unreachable, etc.)
            Result.Error(IOException("Network error occurred. Please check your connection.", e))

        } catch (e: Exception) {
            // Handle any other unexpected errors
            Result.Error(Exception("An unexpected error occurred: ${e.message}", e))
        }
    }
}

