//
//  ContentView.swift
//  LegacyWeatherSwift
//
//  The Massive View Controller Anti-Pattern
//  This view does EVERYTHING and violates many SwiftUI best practices:
//  - All business logic mixed in the view
//  - Direct dependency on singleton
//  - No separation of concerns
//  - Hardcoded styling and layout
//  - Complex state management in UI layer
//  - No reusable components

import SwiftUI

struct ContentView: View {
    @StateObject private var weatherManager = WeatherSingleton.shared
    @State private var showingAlert = false
    @State private var animationOffset: CGFloat = 0
    @State private var lastRefreshTime = Date()
    
    // ANTI-PATTERN: Business logic in the view
    private var backgroundGradient: LinearGradient {
        // ANTI-PATTERN: Complex logic in computed property
        guard let weather = weatherManager.currentWeather else {
            return LinearGradient(
                colors: [.gray, .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        // ANTI-PATTERN: Business rules scattered in UI code
        let description = weather.description.lowercased()
        
        if description.contains("rain") || description.contains("drizzle") {
            return LinearGradient(
                colors: [.blue, .gray],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if description.contains("cloud") {
            return LinearGradient(
                colors: [.gray, .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if description.contains("sun") || description.contains("clear") {
            return LinearGradient(
                colors: [.yellow, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [.blue, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // ANTI-PATTERN: More business logic in view
    private var weatherIconName: String {
        guard let weather = weatherManager.currentWeather else {
            return "questionmark.circle"
        }
        
        let description = weather.description.lowercased()
        
        // ANTI-PATTERN: Complex conditional logic in UI
        if description.contains("rain") {
            return "cloud.rain.fill"
        } else if description.contains("drizzle") {
            return "cloud.drizzle.fill"
        } else if description.contains("snow") {
            return "snow"
        } else if description.contains("cloud") {
            return "cloud.fill"
        } else if description.contains("sun") || description.contains("clear") {
            return "sun.max.fill"
        } else if description.contains("mist") || description.contains("fog") {
            return "cloud.fog.fill"
        } else {
            return "cloud.sun.fill"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // ANTI-PATTERN: Complex layout logic mixed with business logic
                backgroundGradient
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 1.0), value: weatherManager.currentWeather?.description)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Section
                        headerSection
                        
                        // Weather Display Section  
                        if weatherManager.isLoading {
                            loadingSection
                        } else if !weatherManager.errorMessage.isEmpty {
                            errorSection
                        } else {
                            weatherDisplaySection
                        }
                        
                        // Controls Section
                        controlsSection
                        
                        // Debug Section (should not be in production UI!)
                        debugSection
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
                .refreshable {
                    // ANTI-PATTERN: Business logic in UI refresh
                    lastRefreshTime = Date()
                    weatherManager.refreshWeather()
                }
            }
        }
        .alert("Weather Error", isPresented: $showingAlert) {
            Button("OK") {
                showingAlert = false
                weatherManager.errorMessage = ""
            }
            Button("Retry") {
                showingAlert = false
                weatherManager.errorMessage = ""
                weatherManager.refreshWeather()
            }
        } message: {
            Text(weatherManager.errorMessage)
        }
        .onChange(of: weatherManager.errorMessage) { errorMessage in
            // ANTI-PATTERN: Side effects in view
            if !errorMessage.isEmpty {
                showingAlert = true
                // ANTI-PATTERN: Animation logic in business logic handler
                withAnimation(.easeInOut(duration: 0.5)) {
                    animationOffset = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        animationOffset = 0
                    }
                }
            }
        }
        .onAppear {
            // ANTI-PATTERN: Business initialization in view lifecycle
            if weatherManager.currentWeather == nil {
                weatherManager.fetchWeather(for: weatherManager.getCurrentCity())
            }
        }
    }
    
    // MARK: - View Sections (should be separate components)
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            // ANTI-PATTERN: Hardcoded styling mixed with layout
            Text("Legacy Weather")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            
            // ANTI-PATTERN: Business logic for time display in view
            Text("Last updated: \(formatLastUpdateTime())")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var loadingSection: some View {
        VStack(spacing: 20) {
            // ANTI-PATTERN: Custom loading animation when system one would do
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Fetching weather data...")
                .foregroundColor(.white)
                .font(.headline)
            
            // ANTI-PATTERN: Unnecessary loading animation
            HStack {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(.white.opacity(0.7))
                        .frame(width: 10, height: 10)
                        .scaleEffect(loadingAnimationScale(for: index))
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: weatherManager.isLoading
                        )
                }
            }
        }
        .padding()
        .frame(height: 200)
    }
    
    private var errorSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .offset(x: animationOffset)
            
            Text("Oops! Something went wrong")
                .font(.headline)
                .foregroundColor(.white)
            
            // ANTI-PATTERN: Business logic for error formatting in view
            Text(formatErrorMessage())
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                // ANTI-PATTERN: Business logic in button action
                weatherManager.errorMessage = ""
                weatherManager.refreshWeather()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .padding()
                .background(.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.red.opacity(0.1))
                .stroke(.red, lineWidth: 1)
        )
    }
    
    private var weatherDisplaySection: some View {
        VStack(spacing: 20) {
            // City Display
            cityDisplaySection
            
            // Temperature Display
            temperatureDisplaySection
            
            // Weather Description
            weatherDescriptionSection
            
            // Weather Details
            weatherDetailsSection
        }
    }
    
    private var cityDisplaySection: some View {
        HStack {
            Button(action: {
                // ANTI-PATTERN: Direct singleton access with animation
                withAnimation(.spring()) {
                    weatherManager.selectNextCity()
                }
            }) {
                HStack {
                    Image(systemName: "location.circle.fill")
                        .font(.title2)
                    
                    Text(weatherManager.getCurrentCity())
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "chevron.right.circle")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                }
                .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var temperatureDisplaySection: some View {
        VStack(spacing: 10) {
            // Weather Icon
            Image(systemName: weatherIconName)
                .font(.system(size: 80))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
            
            // Temperature
            HStack(alignment: .top, spacing: 5) {
                Text(weatherManager.getTemperatureString())
                    .font(.system(size: 72, weight: .thin))
                    .foregroundColor(.white)
                
                Button(action: {
                    // ANTI-PATTERN: UI animation mixed with business logic
                    withAnimation(.bouncy) {
                        weatherManager.toggleTemperatureUnit()
                    }
                }) {
                    Image(systemName: "thermometer")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .background(
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 35, height: 35)
                        )
                }
                .padding(.top, 10)
            }
        }
        .padding()
    }
    
    private var weatherDescriptionSection: some View {
        HStack {
            Text(weatherManager.currentWeather?.description.capitalized ?? "Unknown")
                .font(.title2)
                .foregroundColor(.white)
                .textCase(.none)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var weatherDetailsSection: some View {
        VStack(spacing: 15) {
            HStack {
                detailItem(
                    icon: "clock",
                    title: "Last Updated",
                    value: weatherManager.getFormattedDate()
                )
                
                Spacer()
                
                detailItem(
                    icon: "location",
                    title: "City",
                    value: weatherManager.getCurrentCity()
                )
            }
            
            // ANTI-PATTERN: Complex business logic for cache status in UI
            HStack {
                detailItem(
                    icon: "externaldrive",
                    title: "Cache Status", 
                    value: getCacheStatusString()
                )
                
                Spacer()
                
                detailItem(
                    icon: "network",
                    title: "Data Source",
                    value: "OpenWeatherMap API"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var controlsSection: some View {
        VStack(spacing: 15) {
            Text("Controls")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                // Refresh Button
                Button(action: {
                    // ANTI-PATTERN: Animation coupled with business logic
                    lastRefreshTime = Date()
                    withAnimation(.easeInOut(duration: 1.0)) {
                        weatherManager.refreshWeather()
                    }
                }) {
                    VStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title)
                        Text("Refresh")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue.opacity(0.3))
                    )
                }
                
                // Temperature Toggle Button
                Button(action: {
                    weatherManager.toggleTemperatureUnit()
                }) {
                    VStack {
                        Image(systemName: weatherManager.isCelsius ? "c.circle.fill" : "f.circle.fill")
                            .font(.title)
                        Text(weatherManager.isCelsius ? "°C" : "°F")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.orange.opacity(0.3))
                    )
                }
                
                // City Change Button
                Button(action: {
                    weatherManager.selectNextCity()
                }) {
                    VStack {
                        Image(systemName: "location.circle.fill")
                            .font(.title)
                        Text("City")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.green.opacity(0.3))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Debug Info (Should not be in production!)")
                .font(.headline)
                .foregroundColor(.red)
            
            Group {
                // ANTI-PATTERN: Debug info in production UI
                Text("Singleton Instance: \(ObjectIdentifier(weatherManager).debugDescription)")
                Text("Is Loading: \(weatherManager.isLoading)")
                Text("Error Message: '\(weatherManager.errorMessage)'")
                Text("Current City Index: \(getCurrentCityIndex())")
                Text("Temperature Unit: \(weatherManager.isCelsius ? "Celsius" : "Fahrenheit")")
                Text("Last Refresh: \(formatDebugTime(lastRefreshTime))")
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.red.opacity(0.2))
                .stroke(.red, lineWidth: 1)
        )
    }
    
    // MARK: - Helper Methods (business logic in view!)
    
    private func detailItem(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.caption2)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // ANTI-PATTERN: Business logic methods in view
    private func formatLastUpdateTime() -> String {
        guard let weather = weatherManager.currentWeather else {
            return "Never"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        
        return formatter.string(from: weather.timestamp)
    }
    
    private func formatErrorMessage() -> String {
        let message = weatherManager.errorMessage
        
        // ANTI-PATTERN: Error processing logic in UI
        if message.contains("Network error") {
            return "Check your internet connection and try again."
        } else if message.contains("Invalid city") {
            return "The selected city could not be found."
        } else if message.contains("Failed to parse") {
            return "The weather service returned unexpected data."
        } else {
            return message.isEmpty ? "An unknown error occurred." : message
        }
    }
    
    private func getCacheStatusString() -> String {
        // ANTI-PATTERN: Cache logic duplicated in UI layer
        if weatherManager.currentWeather != nil {
            return "Data Available"
        } else {
            return "No Data"
        }
    }
    
    private func getCurrentCityIndex() -> Int {
        // ANTI-PATTERN: Accessing private singleton logic through reflection-like behavior
        let cities = ["London", "New York", "Tokyo", "Sydney", "Paris"]
        let currentCity = weatherManager.getCurrentCity()
        
        return cities.firstIndex(of: currentCity) ?? 0
    }
    
    private func formatDebugTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        
        return formatter.string(from: date)
    }
    
    private func loadingAnimationScale(for index: Int) -> CGFloat {
        return weatherManager.isLoading ? 1.0 + (0.3 * CGFloat(index)) : 1.0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
