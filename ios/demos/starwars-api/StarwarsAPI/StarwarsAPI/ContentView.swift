//
//  ContentView.swift
//  StarwarsAPI
//
//  Created by Nick Todd on 24/10/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CharacterListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main content
                if viewModel.isLoading {
                    ProgressView("Loading characters...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if viewModel.hasError {
                    ErrorView(message: viewModel.errorMessage ?? "Unknown error") {
                        Task {
                            await viewModel.loadCharacters()
                        }
                    }
                } else {
                    CharacterListView(characters: viewModel.filteredCharacters)
                }
            }
            .navigationTitle("Star Wars Characters")
            .searchable(text: $viewModel.searchText, prompt: "Search characters")
            .task {
                // Load characters when the view appears
                // .task automatically cancels if the view disappears
                await viewModel.loadCharacters()
            }
        }
    }
}

/// Displays the list of Star Wars characters
struct CharacterListView: View {
    let characters: [Character]
    
    var body: some View {
        List(characters) { character in
            CharacterRow(character: character)
        }
        .listStyle(.insetGrouped)
    }
}

/// Displays a single character row with details
struct CharacterRow: View {
    let character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(character.name)
                .font(.headline)
            
            HStack(spacing: 16) {
                DetailLabel(icon: "ruler", text: "\(character.height) cm")
                DetailLabel(icon: "scalemass", text: "\(character.mass) kg")
            }
            
            HStack(spacing: 16) {
                DetailLabel(icon: "calendar", text: character.birthYear)
                DetailLabel(icon: "person", text: character.gender.capitalized)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Displays a small detail with an icon
struct DetailLabel: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

/// Displays an error message with retry button
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
