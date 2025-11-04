package com.example.legacyweatherkotlin

import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.legacyweatherkotlin.ui.theme.LegacyWeatherKotlinTheme
import kotlinx.coroutines.delay
import java.text.SimpleDateFormat
import java.util.*

/**
 * MainActivity - The Ultimate Anti-Pattern Activity
 * This activity violates EVERY principle of good architecture:
 * - Directly uses singleton
 * - Mixes UI logic with business logic
 * - Has hardcoded values everywhere
 * - No separation of concerns
 * - Performs network operations in UI thread context
 * - Complex business logic mixed with UI rendering
 * - No proper error handling
 * - Massive methods with multiple responsibilities
 */
class MainActivity : ComponentActivity() {
    
    // More hardcoded values
    private val DEFAULT_CITIES = listOf("London", "New York", "Tokyo", "Sydney", "Paris")
    private var isFirstLaunch = true
    
    @OptIn(ExperimentalMaterial3Api::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        // Initialize singleton with context - poor dependency management
        WeatherSingleton.init(this)
        
        // Business logic in onCreate - wrong place!
        if (isFirstLaunch) {
            Log.d("MainActivity", "First launch, fetching default weather")
            WeatherSingleton.fetchWeather("London") // Hardcoded city
            isFirstLaunch = false
        }
        
        setContent {
            LegacyWeatherKotlinTheme {
                Scaffold(
                    modifier = Modifier.fillMaxSize(),
                    topBar = {
                        // UI logic mixed with business logic
                        TopAppBar(
                            title = { 
                                Text("Legacy Weather App - ${getCurrentDateString()}") 
                            },
                            colors = TopAppBarDefaults.topAppBarColors(
                                containerColor = getWeatherColor() // Business logic in UI!
                            ),
                            actions = {
                                IconButton(
                                    onClick = { 
                                        // Direct singleton call from UI
                                        WeatherSingleton.refreshWeather()
                                        showToastMessage("Refreshing weather...")
                                    }
                                ) {
                                    Icon(Icons.Default.Refresh, contentDescription = "Refresh")
                                }
                            }
                        )
                    }
                ) { innerPadding ->
                    WeatherScreen(modifier = Modifier.padding(innerPadding))
                }
            }
        }
    }
    
    // Business logic method in Activity - wrong place!
    private fun getCurrentDateString(): String {
        val formatter = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())
        return formatter.format(Date())
    }
    
    // More business logic in Activity
    private fun getWeatherColor(): Color {
        val temp = WeatherSingleton.currentWeather.value?.temperature
        return when {
            temp == null -> Color(0xFF2196F3)
            temp > 300 -> Color(0xFFFF5722) // Hot - hardcoded values!
            temp > 285 -> Color(0xFFFF9800) // Warm
            temp > 273 -> Color(0xFF4CAF50) // Mild
            else -> Color(0xFF2196F3) // Cold
        }
    }
    
    // UI shows toast - business logic mixed with UI
    private fun showToastMessage(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }
    
    @Composable
    fun WeatherScreen(modifier: Modifier = Modifier) {
        val context = LocalContext.current
        
        // Direct singleton access in Composable - poor architecture!
        val currentWeather by WeatherSingleton.currentWeather
        val isLoading by WeatherSingleton.isLoading
        val errorMessage by WeatherSingleton.errorMessage
        val lastUpdated by WeatherSingleton.lastUpdated
        val isCelsius by WeatherSingleton.isCelsius // Fixed: Now observing temperature unit state
        
        // Local state management mixed with global state
        var searchCity by remember { mutableStateOf("") }
        var selectedCityIndex by remember { mutableStateOf(0) }
        val keyboardController = LocalSoftwareKeyboardController.current
        
        Column(
            modifier = modifier
                .fillMaxSize()
                .padding(16.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            
            // Search section with business logic mixed in
            Card(
                modifier = Modifier.fillMaxWidth(),
                elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Text(
                        text = "Search Weather",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                    
                    // Input field with validation logic mixed in UI
                    OutlinedTextField(
                        value = searchCity,
                        onValueChange = { 
                            searchCity = it
                            // Input validation in UI layer - wrong place!
                            if (it.length > 50) {
                                showToastMessage("City name too long!")
                                return@OutlinedTextField
                            }
                        },
                        label = { Text("Enter city name") },
                        leadingIcon = { Icon(Icons.Default.Search, contentDescription = null) },
                        modifier = Modifier.fillMaxWidth(),
                        keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                        keyboardActions = KeyboardActions(
                            onSearch = {
                                // Business logic in UI callback
                                if (searchCity.isNotEmpty()) {
                                    if (isValidCityName(searchCity)) {
                                        WeatherSingleton.fetchWeather(searchCity)
                                        keyboardController?.hide()
                                        showToastMessage("Searching for $searchCity...")
                                    } else {
                                        showToastMessage("Invalid city name!")
                                    }
                                }
                            }
                        )
                    )
                    
                    Button(
                        onClick = {
                            // More business logic in UI onClick
                            if (searchCity.isNotEmpty()) {
                                if (isValidCityName(searchCity)) {
                                    WeatherSingleton.fetchWeather(searchCity)
                                    showToastMessage("Searching for $searchCity...")
                                } else {
                                    showToastMessage("Please enter a valid city name!")
                                }
                            } else {
                                showToastMessage("Please enter a city name!")
                            }
                        },
                        modifier = Modifier.fillMaxWidth(),
                        enabled = !isLoading
                    ) {
                        if (isLoading) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(16.dp),
                                strokeWidth = 2.dp
                            )
                        } else {
                            Text("Search Weather")
                        }
                    }
                }
            }
            
            // Quick city selection with hardcoded cities
            Card(
                modifier = Modifier.fillMaxWidth(),
                elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Quick Select",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                    
                    // Hardcoded city list with business logic in UI
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        DEFAULT_CITIES.forEachIndexed { index, city ->
                            AssistChip(
                                onClick = {
                                    selectedCityIndex = index
                                    WeatherSingleton.fetchWeather(city)
                                    showToastMessage("Loading weather for $city...")
                                },
                                label = { Text(city) },
                                modifier = Modifier.weight(1f)
                            )
                        }
                    }
                }
            }
            
            // Temperature unit toggle with business logic
            Card(
                modifier = Modifier.fillMaxWidth(),
                elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                        .clickable {
                            // Business logic in UI click handler
                            WeatherSingleton.toggleTemperatureUnit()
                            showToastMessage(
                                "Switched to ${if (isCelsius) "Celsius" else "Fahrenheit"}" // Fixed: Using observed state
                            )
                        },
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Temperature Unit",
                        style = MaterialTheme.typography.titleMedium
                    )
                    Text(
                        text = if (isCelsius) "°C" else "°F", // Fixed: Using observed state
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.primary
                    )
                }
            }
            
            // Main weather display with complex UI logic
            if (isLoading) {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(32.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(48.dp),
                                strokeWidth = 4.dp
                            )
                            Text(
                                text = "Loading weather data...",
                                style = MaterialTheme.typography.bodyLarge
                            )
                        }
                    }
                }
            }
            
            // Error handling in UI
            if (errorMessage.isNotEmpty()) {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = Color(0xFFFFEBEE) // Hardcoded error color
                    ),
                    elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(
                            text = "Error",
                            style = MaterialTheme.typography.titleMedium,
                            color = Color(0xFFD32F2F), // Hardcoded error color
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = errorMessage,
                            style = MaterialTheme.typography.bodyMedium,
                            color = Color(0xFF757575) // Hardcoded text color
                        )
                        Button(
                            onClick = {
                                // Business logic in error handling UI
                                WeatherSingleton.clearWeatherData()
                                WeatherSingleton.fetchWeather("London") // Hardcoded fallback
                                showToastMessage("Retrying...")
                            },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = Color(0xFFD32F2F)
                            )
                        ) {
                            Text("Retry")
                        }
                    }
                }
            }
            
            // Weather data display with massive UI logic and business logic mixed
            currentWeather?.let { weather ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(20.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        // City name with business logic for formatting
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = weather.city.uppercase(), // String manipulation in UI
                                style = MaterialTheme.typography.headlineMedium,
                                fontWeight = FontWeight.Bold
                            )
                            // Weather icon logic in UI
                            Card(
                                modifier = Modifier.size(60.dp),
                                shape = RoundedCornerShape(30.dp),
                                colors = CardDefaults.cardColors(
                                    containerColor = getWeatherIconColor(weather.icon)
                                )
                            ) {
                                Box(
                                    modifier = Modifier.fillMaxSize(),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = getWeatherEmoji(weather.icon),
                                        fontSize = 30.sp
                                    )
                                }
                            }
                        }
                        
                        // Temperature display with business logic
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.Bottom
                        ) {
                            Text(
                                text = WeatherSingleton.getTemperatureString(),
                                style = MaterialTheme.typography.displayLarge,
                                fontWeight = FontWeight.Bold,
                                color = getTemperatureColor(weather.temperature) // Business logic!
                            )
                            Column(horizontalAlignment = Alignment.End) {
                                Text(
                                    text = weather.description.uppercase(), // String manipulation
                                    style = MaterialTheme.typography.titleMedium,
                                    textAlign = TextAlign.End
                                )
                                Text(
                                    text = WeatherSingleton.getFeelsLikeString(),
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = Color.Gray // Hardcoded color
                                )
                            }
                        }
                        
                        Divider() // Hardcoded divider
                        
                        // Weather details grid with business logic mixed in
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceEvenly
                        ) {
                            WeatherDetailItem(
                                title = "Humidity",
                                value = WeatherSingleton.getHumidityString(),
                                icon = "💧"
                            )
                            WeatherDetailItem(
                                title = "Wind",
                                value = WeatherSingleton.getWindSpeedString(),
                                icon = "💨"
                            )
                            WeatherDetailItem(
                                title = "Pressure",
                                value = WeatherSingleton.getPressureString(),
                                icon = "🌡️"
                            )
                        }
                        
                        // Last updated with formatting logic in UI
                        if (lastUpdated.isNotEmpty()) {
                            Text(
                                text = lastUpdated,
                                style = MaterialTheme.typography.bodySmall,
                                color = Color.Gray, // Hardcoded color
                                modifier = Modifier.fillMaxWidth(),
                                textAlign = TextAlign.Center
                            )
                        }
                    }
                }
                
                // Weather advice with complex business logic in UI
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = getAdviceBackgroundColor(weather)
                    ),
                    elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(
                            text = "Weather Advice",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = getWeatherAdvice(weather), // Complex business logic in UI!
                            style = MaterialTheme.typography.bodyMedium
                        )
                    }
                }
            }
        }
    }
    
    // Lots of business logic methods mixed in Activity class - wrong place!
    private fun isValidCityName(city: String): Boolean {
        // Complex validation logic in Activity
        val trimmedCity = city.trim()
        if (trimmedCity.length < 2) return false
        if (trimmedCity.length > 50) return false
        if (!trimmedCity.all { it.isLetter() || it.isWhitespace() || it == '-' || it == '\'' }) return false
        return true
    }
    
    private fun getWeatherIconColor(icon: String): Color {
        // Business logic for icon colors - should be in a proper service/utility
        return when {
            icon.contains("01") -> Color(0xFFFFEB3B) // Sunny
            icon.contains("02") -> Color(0xFFFF9800) // Partly cloudy
            icon.contains("03") || icon.contains("04") -> Color(0xFF9E9E9E) // Cloudy
            icon.contains("09") || icon.contains("10") -> Color(0xFF2196F3) // Rainy
            icon.contains("11") -> Color(0xFF673AB7) // Thunderstorm
            icon.contains("13") -> Color(0xFFE1F5FE) // Snow
            icon.contains("50") -> Color(0xFFBDBDBD) // Mist
            else -> Color(0xFF607D8B)
        }
    }
    
    private fun getWeatherEmoji(icon: String): String {
        // More business logic in Activity
        return when {
            icon.contains("01") -> "☀️"
            icon.contains("02") -> "⛅"
            icon.contains("03") -> "☁️"
            icon.contains("04") -> "☁️"
            icon.contains("09") -> "🌦️"
            icon.contains("10") -> "🌧️"
            icon.contains("11") -> "⛈️"
            icon.contains("13") -> "❄️"
            icon.contains("50") -> "🌫️"
            else -> "🌤️"
        }
    }
    
    private fun getTemperatureColor(temp: Double): Color {
        // Temperature color business logic in Activity
        return when {
            temp > 305 -> Color(0xFFD32F2F) // Very hot
            temp > 300 -> Color(0xFFFF5722) // Hot
            temp > 295 -> Color(0xFFFF9800) // Warm
            temp > 285 -> Color(0xFFFFEB3B) // Mild
            temp > 275 -> Color(0xFF4CAF50) // Cool
            temp > 265 -> Color(0xFF2196F3) // Cold
            else -> Color(0xFF1976D2) // Very cold
        }
    }
    
    private fun getAdviceBackgroundColor(weather: WeatherData): Color {
        // UI color logic based on business rules
        return when {
            weather.temperature > 300 -> Color(0xFFFFF3E0)
            weather.humidity > 80 -> Color(0xFFE8F5E8)
            weather.windSpeed > 10 -> Color(0xFFE3F2FD)
            else -> Color(0xFFF5F5F5)
        }
    }
    
    private fun getWeatherAdvice(weather: WeatherData): String {
        // Complex business logic for weather advice - should be in service layer
        val temp = weather.temperature - 273.15 // Kelvin to Celsius
        val advice = mutableListOf<String>()
        
        when {
            temp > 35 -> advice.add("⚠️ Extremely hot! Stay hydrated and avoid direct sunlight.")
            temp > 30 -> advice.add("🌡️ Very hot weather. Wear light clothing and drink plenty of water.")
            temp > 25 -> advice.add("☀️ Warm and pleasant. Perfect for outdoor activities!")
            temp > 15 -> advice.add("🌤️ Mild temperature. Light jacket recommended for evening.")
            temp > 5 -> advice.add("🧥 Cool weather. Wear warm clothing.")
            temp > -5 -> advice.add("❄️ Cold! Bundle up and watch for icy conditions.")
            else -> advice.add("🥶 Freezing cold! Wear multiple layers and limit time outdoors.")
        }
        
        if (weather.humidity > 80) {
            advice.add("💧 High humidity - it may feel warmer than actual temperature.")
        }
        
        if (weather.windSpeed > 15) {
            advice.add("💨 Very windy conditions. Secure loose objects.")
        } else if (weather.windSpeed > 8) {
            advice.add("🍃 Breezy conditions.")
        }
        
        if (weather.description.lowercase().contains("rain")) {
            advice.add("☂️ Don't forget your umbrella!")
        }
        
        if (weather.description.lowercase().contains("snow")) {
            advice.add("⛄ Snowy conditions. Drive carefully and wear appropriate footwear.")
        }
        
        return advice.joinToString(" ")
    }
    
    @Composable
    fun WeatherDetailItem(
        title: String,
        value: String,
        icon: String
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text = icon,
                fontSize = 24.sp
            )
            Text(
                text = title,
                style = MaterialTheme.typography.bodySmall,
                color = Color.Gray // Hardcoded color
            )
            Text(
                text = value,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    LegacyWeatherKotlinTheme {
        // Even the preview is problematic - no proper preview setup
        Text("Weather App Preview")
    }
}