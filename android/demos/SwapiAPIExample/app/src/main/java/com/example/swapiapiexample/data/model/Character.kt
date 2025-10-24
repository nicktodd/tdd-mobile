package com.example.swapiapiexample.data.model

import com.google.gson.annotations.SerializedName

/**
 * Represents a Star Wars character from the SWAPI API
 */
data class Character(
    @SerializedName("name")
    val name: String,

    @SerializedName("height")
    val height: String,

    @SerializedName("mass")
    val mass: String,

    @SerializedName("birth_year")
    val birthYear: String,

    @SerializedName("gender")
    val gender: String,

    @SerializedName("url")
    val url: String
)

