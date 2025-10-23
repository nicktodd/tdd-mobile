package com.example.mvvmexample.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.mvvmexample.data.User

/**
 * UserListScreen - The "View" in MVVM
 *
 * VIEW RESPONSIBILITIES IN MVVM:
 * ==============================
 * 1. DISPLAY DATA: Show what the ViewModel exposes
 * 2. CAPTURE INPUT: Collect user interactions
 * 3. DELEGATE TO VIEWMODEL: Pass actions to ViewModel, don't handle logic
 * 4. OBSERVE STATE: React to ViewModel state changes
 *
 * What the View SHOULD NOT do:
 * - Business logic (that's ViewModel's job)
 * - Data operations (that's Repository's job)
 * - Direct repository access (violates MVVM)
 *
 * Why This Separation Matters:
 * - UI can change without affecting business logic
 * - Business logic can be unit tested without UI
 * - Multiple UIs (phone, tablet, watch) can share same ViewModel
 * - UI tests focus on rendering, unit tests focus on logic
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UserListScreen(
    viewModel: UserViewModel,
    modifier: Modifier = Modifier
) {
    /**
     * State Observation
     *
     * collectAsStateWithLifecycle:
     * - Collects StateFlow in a lifecycle-aware way
     * - Automatically starts/stops collection based on lifecycle
     * - Prevents memory leaks when UI is not visible
     * - Re-renders UI when state changes
     *
     * This is the reactive connection: ViewModel changes state → UI updates automatically
     */
    val users by viewModel.users.collectAsStateWithLifecycle()

    // Local UI state for the text field (not business state, so not in ViewModel)
    var newUserName by remember { mutableStateOf("") }
    var showDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("MVVM Demo - User List") }
            )
        },
        floatingActionButton = {
            /**
             * User Interaction → ViewModel Action
             * Button click triggers dialog, not immediate ViewModel call
             * Keeps UI in control of UX flow
             */
            FloatingActionButton(
                onClick = { showDialog = true }
            ) {
                Icon(Icons.Default.Add, contentDescription = "Add User")
            }
        }
    ) { padding ->
        Column(
            modifier = modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            if (users.isEmpty()) {
                /**
                 * Empty State
                 * View handles presentation of empty state
                 * ViewModel just provides empty list
                 */
                EmptyState()
            } else {
                /**
                 * List Display
                 * Pure presentation - ViewModel provides data, View renders it
                 */
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(
                        items = users,
                        key = { user -> user.id } // Optimization: helps Compose track items
                    ) { user ->
                        UserItem(
                            user = user,
                            onDelete = {
                                /**
                                 * CRITICAL MVVM PRINCIPLE:
                                 * View delegates to ViewModel, doesn't modify data directly
                                 * View: "User wants to delete this"
                                 * ViewModel: "I'll handle the business logic"
                                 */
                                viewModel.deleteUser(user.id)
                            }
                        )
                    }
                }
            }
        }
    }

    /**
     * Add User Dialog
     * Local UI state (dialog visibility, text field) stays in View
     * Business operation (adding user) goes through ViewModel
     */
    if (showDialog) {
        AlertDialog(
            onDismissRequest = { showDialog = false },
            title = { Text("Add New User") },
            text = {
                TextField(
                    value = newUserName,
                    onValueChange = { newUserName = it },
                    label = { Text("Name") },
                    singleLine = true
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        if (newUserName.isNotBlank()) {
                            /**
                             * View → ViewModel Communication
                             * View validates UI concerns (not blank)
                             * ViewModel handles business logic (ID generation, repository)
                             */
                            viewModel.addUser(newUserName)
                            newUserName = ""
                            showDialog = false
                        }
                    }
                ) {
                    Text("Add")
                }
            },
            dismissButton = {
                TextButton(onClick = { showDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }
}

/**
 * User Item Component
 * Reusable UI component - pure presentation
 * No business logic, just rendering and event callbacks
 */
@Composable
fun UserItem(
    user: User,
    onDelete: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = user.name,
                    style = MaterialTheme.typography.titleMedium
                )
                Text(
                    text = "ID: ${user.id}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            IconButton(onClick = onDelete) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = "Delete ${user.name}",
                    tint = MaterialTheme.colorScheme.error
                )
            }
        }
    }
}

@Composable
fun EmptyState(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = "No users yet",
                style = MaterialTheme.typography.titleLarge
            )
            Text(
                text = "Tap + to add your first user",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

/**
 * MVVM IN COMPOSE: Key Takeaways
 * ===============================
 *
 * Data Flow:
 * User Input → View → ViewModel → Repository → ViewModel → View (update)
 *
 * Separation of Concerns:
 * - View: Handles layout, styling, user interaction, lifecycle
 * - ViewModel: Handles business logic, state management, data coordination
 * - Repository: Handles data operations
 *
 * Testing Strategy:
 * - Unit Tests: Test ViewModel logic with mocked repository
 * - UI Tests: Test Composable rendering and user interactions
 * - Integration Tests: Test full flow with real repository
 *
 * Benefits:
 * - View is dumb and simple (easy UI tests)
 * - ViewModel is pure logic (easy unit tests)
 * - Repository is swappable (easy to change data source)
 * - Everything is testable in isolation
 */

