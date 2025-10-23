//
//  MVVMExampleApp.swift
//  MVVMExample
//
//  Created by Nick Todd on 23/10/2025.
//

import SwiftUI

/**
 * MVVM EXAMPLE APP
 *
 * This is the app's entry point and where we configure the dependency injection
 * for our MVVM architecture.
 *
 * Key responsibilities:
 * 1. DEPENDENCY SETUP: Create and configure the dependencies (Repository, ViewModel)
 * 2. OBJECT GRAPH: Wire together the object relationships
 * 3. ROOT VIEW: Provide the initial view with its dependencies
 *
 * Dependency Injection Benefits:
 * - TESTABILITY: Easy to substitute mocks for testing
 * - FLEXIBILITY: Can change implementations without changing dependent code
 * - SINGLE RESPONSIBILITY: Each class has a clear, focused purpose
 * - LOOSE COUPLING: Classes depend on abstractions, not concrete implementations
 */
@main
struct MVVMExampleApp: App {
    
    /**
     * Create the repository instance
     * In a real app, you might choose different implementations based on configuration:
     * - InMemoryUserRepository for prototyping/testing
     * - CoreDataUserRepository for local persistence
     * - NetworkUserRepository for server-based storage
     */
    private let userRepository: UserRepositoryProtocol = {
        // Start with some sample data to make the demo more interesting
        let sampleUsers = [
            User(id: 1, name: "Alice Johnson"),
            User(id: 2, name: "Bob Smith"),
            User(id: 3, name: "Charlie Brown")
        ]
        return InMemoryUserRepository(initialUsers: sampleUsers)
    }()
    
    /**
     * Create the ViewModel with its repository dependency
     * The ViewModel doesn't know or care what type of repository it's getting,
     * it only knows it conforms to UserRepositoryProtocol
     */
    private let userListViewModel: UserListViewModel
    
    /**
     * Initialize the App with its dependencies
     * This ensures all dependencies are created when the app starts
     */
    init() {
        self.userListViewModel = UserListViewModel(repository: userRepository)
    }
    
    var body: some Scene {
        WindowGroup {
            /**
             * Inject the ViewModel into the ContentView
             * This completes our dependency chain:
             * App -> Repository -> ViewModel -> View
             */
            ContentView(viewModel: userListViewModel)
        }
    }
}

// MARK: - App Configuration Extensions

extension MVVMExampleApp {
    /**
     * Factory method for creating ViewModels with different repositories
     * Useful for testing different scenarios or environments
     * 
     * This approach is more appropriate for dependency injection at the component level
     * rather than trying to mutate the entire App struct.
     */
    static func createViewModel(with repository: UserRepositoryProtocol? = nil) -> UserListViewModel {
        let repo = repository ?? {
            let sampleUsers = [
                User(id: 1, name: "Alice Johnson"),
                User(id: 2, name: "Bob Smith"),
                User(id: 3, name: "Charlie Brown")
            ]
            return InMemoryUserRepository(initialUsers: sampleUsers)
        }()
        
        return UserListViewModel(repository: repo)
    }
}
