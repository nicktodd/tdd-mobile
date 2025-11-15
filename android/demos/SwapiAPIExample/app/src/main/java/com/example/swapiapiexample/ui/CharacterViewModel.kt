package com.example.swapiapiexample.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.swapiapiexample.data.model.Character
import com.example.swapiapiexample.data.repository.CharacterRepository
import com.example.swapiapiexample.data.repository.Result
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * ViewModel for managing character data and UI state.
 * This class demonstrates the MVVM pattern and provides a clean separation
 * between UI and business logic.
 */
class CharacterViewModel(
    private val repository: CharacterRepository
) : ViewModel() {
    
    // Sealed class to represent different UI states
    sealed class UiState {
        object Idle : UiState()
        object Loading : UiState()
        data class Success(val characters: List<Character>) : UiState()
        data class Error(val message: String) : UiState()
    }
    
    private val _uiState = MutableStateFlow<UiState>(UiState.Idle)
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()
    
    /**
     * Loads characters from the repository.
     * This method handles all state transitions and error cases.
     */
    fun loadCharacters(page: Int = 1) {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            
            when (val result = repository.getCharacters(page)) {
                is Result.Success -> {
                    _uiState.value = UiState.Success(result.data)
                }
                is Result.Error -> {
                    _uiState.value = UiState.Error(
                        result.exception.message ?: "Unknown error occurred"
                    )
                }
            }
        }
    }
    
    /**
     * Retries loading characters after an error
     */
    fun retry() {
        loadCharacters()
    }
}

