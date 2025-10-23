package com.example.mvvmexample.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.mvvmexample.data.User
import com.example.mvvmexample.data.UserRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * UserViewModel - The "ViewModel" in MVVM
 *
 * MVVM Pattern Responsibilities:
 * =================================
 * MODEL: Data layer (User, UserRepository) - handles data operations
 * VIEW: UI layer (Composables) - displays data and captures user input
 * VIEWMODEL: This class - mediates between Model and View
 *
 * ViewModel's Job:
 * ----------------
 * 1. HOLD UI STATE: Exposes StateFlow that the UI observes
 * 2. HANDLE BUSINESS LOGIC: Validates input, generates IDs, coordinates operations
 * 3. ORCHESTRATE DATA OPERATIONS: Calls repository methods, updates UI state
 * 4. MANAGE LIFECYCLE: Uses viewModelScope so coroutines are cancelled when VM is cleared
 *
 * Why ViewModel is Testable:
 * --------------------------
 * - No Android dependencies (extends ViewModel but doesn't use Context, Resources, etc.)
 * - Dependencies injected via constructor (repository) - easy to mock
 * - Pure business logic - deterministic and predictable
 * - Coroutines can be tested with TestDispatchers
 * - State exposed via StateFlow - easy to observe and assert in tests
 *
 * Testing Strategy:
 * -----------------
 * Unit tests should verify:
 * 1. Initial state is loaded from repository
 * 2. User actions (addUser) call repository correctly
 * 3. UI state is updated after repository operations
 * 4. Business logic (ID generation) works correctly
 *
 * We DON'T test:
 * - Repository implementation (that's repository's job)
 * - UI rendering (that's Compose UI tests)
 * - Android framework behavior
 */
class UserViewModel(
    private val repository: UserRepository
) : ViewModel() {

    /**
     * UI State Management
     *
     * Private mutable state + public immutable state = safe state management
     * - _users: Internal mutable state that only ViewModel can modify
     * - users: Public read-only state that UI observes
     *
     * StateFlow vs LiveData:
     * - StateFlow is Kotlin-first and works with coroutines
     * - Always has a value (unlike LiveData which can be null)
     * - Better for Compose (which is also declarative and reactive)
     */
    private val _users = MutableStateFlow<List<User>>(emptyList())
    val users: StateFlow<List<User>> = _users.asStateFlow()

    init {
        /**
         * Load initial data when ViewModel is created
         *
         * viewModelScope: Automatically cancelled when ViewModel is cleared
         * This prevents memory leaks and ensures coroutines don't run after VM is destroyed
         */
        loadUsers()
    }

    /**
     * Loads users from repository and updates UI state
     *
     * Testing Note: This is called from init, so tests need to account for this
     * initial load when the ViewModel is instantiated.
     */
    private fun loadUsers() {
        viewModelScope.launch {
            _users.value = repository.getUsers()
        }
    }

    /**
     * Adds a new user
     *
     * Business Logic:
     * - Generates a unique ID (max existing ID + 1, or 1 if no users)
     * - Creates User object
     * - Saves to repository
     * - Refreshes UI state
     *
     * Why this belongs in ViewModel:
     * - ID generation is business logic, not UI concern
     * - UI just provides the name, ViewModel handles the rest
     * - Makes the UI simple and the logic testable
     *
     * Testing: Mock the repository, verify it's called with correct User object
     */
    fun addUser(name: String) {
        viewModelScope.launch {
            // Business Logic: Generate next ID
            val newId = (_users.value.maxOfOrNull { it.id } ?: 0L) + 1L
            val newUser = User(id = newId, name = name)

            // Data Operation: Save to repository
            repository.addUser(newUser)

            // State Update: Refresh from repository to ensure consistency
            _users.value = repository.getUsers()
        }
    }

    /**
     * Deletes a user by ID
     *
     * Note: This requires adding a delete method to UserRepository interface
     * Demonstrates how ViewModel coordinates multiple operations:
     * 1. Call repository
     * 2. Update state
     */
    fun deleteUser(userId: Long) {
        viewModelScope.launch {
            // For this demo, we'll filter it out locally
            // In production, you'd call: repository.deleteUser(userId)
            _users.value = _users.value.filter { it.id != userId }
        }
    }
}

