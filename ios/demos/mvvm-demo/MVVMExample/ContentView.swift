//
//  ContentView.swift
//  MVVMExample
//
//  Created by Nick Todd on 23/10/2025.
//

import SwiftUI

/**
 * CONTENT VIEW (THE VIEW IN MVVM)
 *
 * This is the View layer in the MVVM pattern. It's responsible for:
 * 1. DISPLAY: Presenting data to the user
 * 2. USER INTERACTION: Handling user input and gestures
 * 3. DATA BINDING: Connecting to ViewModel's observable properties
 * 4. NO BUSINESS LOGIC: Views should be "dumb" - they only display and forward actions
 *
 * Key MVVM principles demonstrated:
 * - View observes ViewModel through @StateObject/@ObservedObject
 * - View calls ViewModel methods for user actions
 * - View automatically updates when ViewModel's @Published properties change
 * - No direct Model access - everything goes through ViewModel
 */
struct ContentView: View {
    
    /**
     * The ViewModel that this View observes
     * @StateObject ensures the ViewModel's lifecycle is managed by this View
     * and that UI updates happen when ViewModel's @Published properties change
     */
    @StateObject private var viewModel: UserListViewModel
    
    /**
     * Dependency injection through initializer
     * This allows us to provide different ViewModels for different contexts
     * (e.g., real ViewModel for production, mock ViewModel for previews/tests)
     */
    init(viewModel: UserListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with user count - demonstrates computed property binding
                headerView
                
                // Add user section - demonstrates two-way data binding
                addUserSection
                
                // User list - demonstrates collection binding and user interaction
                userListView
                
                Spacer()
            }
            .navigationTitle("MVVM Example")
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - View Components
    
    /**
     * Header section showing user count
     * Demonstrates how Views can use ViewModel's computed properties
     */
    private var headerView: some View {
        HStack {
            Text(viewModel.userCountText)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Loading indicator - demonstrates state-dependent UI
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    /**
     * Add user input section
     * Demonstrates two-way data binding with @Published properties
     */
    private var addUserSection: some View {
        HStack {
            TextField("Enter user name", text: $viewModel.newUserName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    // Allow adding user by pressing return
                    if viewModel.canAddUser {
                        viewModel.addUser()
                    }
                }
            
            Button("Add User") {
                viewModel.addUser()
            }
            .disabled(!viewModel.canAddUser) // Demonstrates computed property binding
            .padding(.leading, 8)
        }
        .padding()
    }
    
    /**
     * User list section
     * Demonstrates collection binding and user interaction handling
     */
    private var userListView: some View {
        List {
            ForEach(viewModel.users) { user in
                UserRowView(user: user) {
                    // Delete action - View forwards user action to ViewModel
                    viewModel.deleteUser(withId: user.id)
                }
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            // Pull-to-refresh - demonstrates command pattern
            viewModel.loadUsers()
        }
    }
}

/**
 * USER ROW VIEW
 *
 * A separate view component for displaying individual users
 * This demonstrates:
 * - View composition and reusability
 * - Separation of concerns (each view has a single responsibility)
 * - Callback patterns for handling user actions
 */
struct UserRowView: View {
    let user: User
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                
                Text("ID: \(user.id)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview {
    /**
     * Preview with mock data
     * This demonstrates how dependency injection makes Views easily previewable
     * We create a ViewModel with a repository containing sample data
     */
    let mockRepository = InMemoryUserRepository(initialUsers: User.mockUsers())
    let viewModel = UserListViewModel(repository: mockRepository)
    
    return ContentView(viewModel: viewModel)
}
