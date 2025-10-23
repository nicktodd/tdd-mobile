package com.example.mvvmexample

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.mvvmexample.data.InMemoryUserRepository
import com.example.mvvmexample.data.User
import com.example.mvvmexample.ui.UserListScreen
import com.example.mvvmexample.ui.UserViewModel
import com.example.mvvmexample.ui.theme.MVVMExampleTheme

/**
 * MainActivity - Application Entry Point
 *
 * DEPENDENCY INJECTION IN MVVM:
 * =============================
 * In a real app, you'd use a DI framework like Hilt or Koin.
 * For this demo, we manually inject dependencies to keep it simple and educational.
 *
 * The flow:
 * 1. Create Repository instance (data layer)
 * 2. Pass repository to ViewModel (business layer)
 * 3. Pass ViewModel to View (UI layer)
 *
 * Why This Matters:
 * - Each layer only knows about the layer below it
 * - Dependencies flow in one direction: UI → ViewModel → Repository
 * - Easy to swap implementations (e.g., replace InMemoryRepository with DatabaseRepository)
 * - Testable: In tests, we inject mocks instead of real implementations
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        /**
         * Repository Creation
         * In production, this would come from your DI container (Hilt, Koin)
         * Here we seed it with sample data for demonstration
         */
        val repository = InMemoryUserRepository(
            initialUsers = listOf(
                User(1L, "Alice Anderson"),
                User(2L, "Bob Builder"),
                User(3L, "Charlie Chen")
            )
        )

        setContent {
            MVVMExampleTheme {
                /**
                 * ViewModel Creation with Factory
                 *
                 * Since ViewModel needs constructor parameters (repository),
                 * we provide a factory to create it.
                 *
                 * In production with Hilt:
                 * @HiltViewModel would handle this automatically
                 * val viewModel: UserViewModel = hiltViewModel()
                 */
                val viewModel: UserViewModel = viewModel(
                    factory = UserViewModelFactory(repository)
                )

                /**
                 * View Layer
                 * The Composable receives the ViewModel and observes its state
                 * No direct repository access - respects MVVM architecture
                 */
                UserListScreen(viewModel = viewModel)
            }
        }
    }
}

/**
 * ViewModel Factory
 *
 * ViewModels with constructor parameters need a factory to be created.
 * This factory knows how to instantiate our ViewModel with its dependencies.
 *
 * Why needed:
 * - Android's ViewModelProvider doesn't know about our custom constructor
 * - Factory pattern allows us to inject dependencies
 * - In production, Hilt/Koin would generate this for you
 */
class UserViewModelFactory(
    private val repository: com.example.mvvmexample.data.UserRepository
) : androidx.lifecycle.ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : androidx.lifecycle.ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(UserViewModel::class.java)) {
            return UserViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}