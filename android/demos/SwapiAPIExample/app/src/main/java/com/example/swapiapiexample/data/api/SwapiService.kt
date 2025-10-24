package com.example.swapiapiexample.data.api

import com.example.swapiapiexample.data.model.CharacterResponse
import retrofit2.http.GET
import retrofit2.http.Query

/**
 * Retrofit service interface for the SWAPI API
 */
interface SwapiService {

    @GET("people/")
    suspend fun getCharacters(
        @Query("page") page: Int = 1
    ): CharacterResponse

    companion object {
        const val BASE_URL = "https://swapi.dev/api/"
    }
}

