package com.example.legacyweatherkotlin

import android.content.Context
import android.util.Log
import java.text.SimpleDateFormat
import java.util.*

/**
 * WeatherUtils - A Utility Class Anti-Pattern
 * This class demonstrates poor utility design:
 * - Static methods doing too much
 * - Mixed responsibilities
 * - Context dependencies in utilities
 * - No proper error handling
 * - Hardcoded values
 */
class WeatherUtils {
    
    companion object {
        
        // Static context reference - memory leak waiting to happen!
        private var applicationContext: Context? = null
        
        fun initialize(context: Context) {
            applicationContext = context.applicationContext
        }
        
        // Utility method that does too much and has side effects
        fun processWeatherData(response: WeatherResponse): WeatherData? {
            Log.d("WeatherUtils", "Processing weather data for ${response.name}")
            
            // Business logic mixed with data transformation
            val weather = response.weather.firstOrNull() ?: return null
            
            // Side effect: logging in utility method
            Log.d("WeatherUtils", "Weather condition: ${weather.description}")
            
            // More business logic in utility
            val processedDescription = weather.description
                .split(" ")
                .joinToString(" ") { word ->
                    word.replaceFirstChar { 
                        if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString() 
                    }
                }
            
            return WeatherData(
                city = response.name,
                temperature = response.main.temp,
                description = processedDescription,
                humidity = response.main.humidity,
                windSpeed = response.wind.speed,
                icon = weather.icon,
                feelsLike = response.main.feels_like,
                pressure = response.main.pressure
            )
        }
        
        // Temperature conversion with hardcoded logic
        fun convertTemperature(kelvin: Double, toCelsius: Boolean = true): Double {
            return if (toCelsius) {
                kelvin - 273.15
            } else {
                (kelvin - 273.15) * 9/5 + 32
            }
        }
        
        // String formatting that should be in UI layer
        fun formatTemperature(kelvin: Double, unit: String): String {
            val converted = if (unit == "C") {
                convertTemperature(kelvin, true)
            } else {
                convertTemperature(kelvin, false)
            }
            
            return "${converted.toInt()}°$unit"
        }
        
        // Validation logic mixed with utility
        fun isValidCityName(cityName: String?): Boolean {
            if (cityName == null) return false
            
            val trimmed = cityName.trim()
            
            // Hardcoded validation rules
            if (trimmed.length < 2 || trimmed.length > 50) return false
            
            // Complex regex in utility method
            val validPattern = Regex("^[a-zA-Z\\s\\-']+$")
            if (!validPattern.matches(trimmed)) return false
            
            // More business rules
            val forbiddenWords = listOf("test", "admin", "null", "undefined")
            if (forbiddenWords.any { trimmed.lowercase().contains(it) }) return false
            
            return true
        }
        
        // Date formatting utility with hardcoded patterns
        fun formatLastUpdated(timestamp: Long? = null): String {
            val time = timestamp ?: System.currentTimeMillis()
            val formatter = SimpleDateFormat("'Last updated:' HH:mm", Locale.getDefault())
            return formatter.format(Date(time))
        }
        
        // Business logic for weather advice in utility class
        fun generateWeatherAdvice(weatherData: WeatherData): String {
            val tempCelsius = convertTemperature(weatherData.temperature)
            val advice = mutableListOf<String>()
            
            // Hardcoded temperature advice
            when {
                tempCelsius > 35 -> advice.add("⚠️ Extremely hot! Stay indoors with AC.")
                tempCelsius > 30 -> advice.add("🌡️ Very hot. Drink lots of water.")
                tempCelsius > 25 -> advice.add("☀️ Perfect weather for activities!")
                tempCelsius > 15 -> advice.add("🌤️ Pleasant. Light jacket for evening.")
                tempCelsius > 5 -> advice.add("🧥 Cool weather. Dress warmly.")
                tempCelsius > -5 -> advice.add("❄️ Cold! Multiple layers needed.")
                else -> advice.add("🥶 Extreme cold! Limit outdoor exposure.")
            }
            
            // More hardcoded business rules
            if (weatherData.humidity > 80) {
                advice.add("💧 High humidity makes it feel hotter.")
            }
            
            if (weatherData.windSpeed > 15) {
                advice.add("💨 Very windy. Secure loose items.")
            }
            
            // String contains logic - fragile
            val description = weatherData.description.lowercase()
            when {
                description.contains("rain") -> advice.add("☂️ Bring an umbrella!")
                description.contains("snow") -> advice.add("⛄ Watch for slippery conditions.")
                description.contains("storm") -> advice.add("⛈️ Stay indoors if possible.")
                description.contains("fog") || description.contains("mist") -> 
                    advice.add("🌫️ Reduced visibility. Drive carefully.")
            }
            
            return advice.joinToString(" ")
        }
        
        // Utility method that depends on singleton - tight coupling
        fun refreshWeatherForCurrentCity(): Boolean {
            val currentCity = WeatherSingleton.currentCity
            if (currentCity.isNotEmpty()) {
                WeatherSingleton.fetchWeather(currentCity)
                return true
            }
            return false
        }
        
        // Method that modifies global state - not a pure utility
        fun clearAllWeatherData() {
            WeatherSingleton.clearWeatherData()
            Log.d("WeatherUtils", "Cleared all weather data")
        }
        
        // Utility method with side effects and context dependency
        fun logWeatherStats(weatherData: WeatherData) {
            Log.d("WeatherStats", "=== Weather Statistics ===")
            Log.d("WeatherStats", "City: ${weatherData.city}")
            Log.d("WeatherStats", "Temperature: ${formatTemperature(weatherData.temperature, "C")}")
            Log.d("WeatherStats", "Humidity: ${weatherData.humidity}%")
            Log.d("WeatherStats", "Wind: ${weatherData.windSpeed} m/s")
            Log.d("WeatherStats", "Pressure: ${weatherData.pressure} hPa")
            Log.d("WeatherStats", "========================")
        }
        
        // Complex calculation that should be in domain layer
        fun calculateComfortIndex(temperature: Double, humidity: Int, windSpeed: Double): String {
            val tempC = convertTemperature(temperature)
            
            // Complex algorithm with magic numbers
            val heatIndex = when {
                tempC < 27 -> tempC
                else -> {
                    val t = tempC
                    val h = humidity.toDouble()
                    
                    // Magic formula with no explanation
                    val hi = -8.784695 + 1.61139411 * t + 2.33854884 * h + 
                            (-0.14611605 * t * h) + (-0.012308094 * t * t) +
                            (-0.016424828 * h * h) + (0.002211732 * t * t * h) +
                            (0.00072546 * t * h * h) + (-0.000003582 * t * t * h * h)
                    hi
                }
            }
            
            // Wind chill calculation
            val windChill = when {
                tempC > 10 -> tempC
                windSpeed < 4.8 -> tempC
                else -> {
                    // Another magic formula
                    13.12 + 0.6215 * tempC - 11.37 * Math.pow(windSpeed * 3.6, 0.16) + 
                    0.3965 * tempC * Math.pow(windSpeed * 3.6, 0.16)
                }
            }
            
            val finalTemp = if (tempC > 27 && humidity > 40) heatIndex else windChill
            
            return when {
                finalTemp > 40 -> "Dangerous"
                finalTemp > 32 -> "Very Uncomfortable"
                finalTemp > 27 -> "Uncomfortable"
                finalTemp > 21 -> "Comfortable"
                finalTemp > 15 -> "Cool"
                finalTemp > 5 -> "Cold"
                finalTemp > -5 -> "Very Cold"
                else -> "Extreme Cold"
            }
        }
    }
}