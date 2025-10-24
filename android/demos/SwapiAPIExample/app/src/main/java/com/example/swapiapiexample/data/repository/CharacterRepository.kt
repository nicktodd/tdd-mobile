package com.example.swapiapiexample.data.repository

import com.example.swapiapiexample.data.model.Character

/**
 * Repository interface for fetching Star Wars character data.
 * This abstraction allows us to easily mock the repository in tests.
 */
interface CharacterRepository {
    /**
     * Fetches a list of characters from the API
     * @param page The page number to fetch (default is 1)
     * @return Result containing either a list of characters or an error
     */
    suspend fun getCharacters(page: Int = 1): Result<List<Character>>
}

