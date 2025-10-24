package com.example.swapiapiexample.data.model

import com.google.gson.annotations.SerializedName

/**
 * API response wrapper for paginated character results from SWAPI
 */
data class CharacterResponse(
    @SerializedName("count")
    val count: Int,

    @SerializedName("next")
    val next: String?,

    @SerializedName("previous")
    val previous: String?,

    @SerializedName("results")
    val results: List<Character>
)

