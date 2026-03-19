package com.emops.app.ui.screens.weekly

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.emops.app.data.repository.WeeklySheetRepository
import com.emops.app.domain.model.WeeklySheet
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class WeeklySheetUiState(
    val isLoading: Boolean = true,
    val sheet: WeeklySheet? = null,
    val selectedTab: Int = 0,
    val error: String? = null
)

@HiltViewModel
class WeeklySheetViewModel @Inject constructor(
    private val repository: WeeklySheetRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(WeeklySheetUiState())
    val uiState: StateFlow<WeeklySheetUiState> = _uiState.asStateFlow()

    val tabs = listOf("Identity", "Goals", "Constraint", "DSAA", "AI", "Calendar", "Score")

    init {
        loadCurrentSheet()
    }

    fun loadCurrentSheet() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            repository.getCurrentSheet()
                .onSuccess { sheet -> _uiState.update { it.copy(sheet = sheet, isLoading = false) } }
                .onFailure { e -> _uiState.update { it.copy(isLoading = false, error = e.message) } }
        }
    }

    fun selectTab(index: Int) {
        _uiState.update { it.copy(selectedTab = index) }
    }

    fun updateSheet(updates: Map<String, Any>) {
        val sheetId = _uiState.value.sheet?.id ?: return
        viewModelScope.launch {
            repository.updateSheet(sheetId, updates)
                .onSuccess { sheet -> _uiState.update { it.copy(sheet = sheet) } }
        }
    }

    fun completeWeek() {
        val sheetId = _uiState.value.sheet?.id ?: return
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            repository.completeSheet(sheetId)
                .onSuccess { sheet -> _uiState.update { it.copy(sheet = sheet, isLoading = false) } }
                .onFailure { e -> _uiState.update { it.copy(isLoading = false, error = e.message) } }
        }
    }

    fun carryForward() {
        val sheetId = _uiState.value.sheet?.id ?: return
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            repository.carryForward(sheetId)
                .onSuccess { sheet -> _uiState.update { it.copy(sheet = sheet, isLoading = false) } }
                .onFailure { e -> _uiState.update { it.copy(isLoading = false, error = e.message) } }
        }
    }
}
