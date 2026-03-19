package com.emops.app.ui.screens.habits

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.emops.app.data.repository.HabitRepository
import com.emops.app.domain.model.Habit
import com.emops.app.domain.model.HabitLog
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import javax.inject.Inject

data class HabitsUiState(
    val isLoading: Boolean = true,
    val habits: List<Habit> = emptyList(),
    val logs: List<HabitLog> = emptyList(),
    val selectedDate: String = LocalDate.now().format(DateTimeFormatter.ISO_DATE),
    val streak: Int = 0,
    val error: String? = null
) {
    val completedCount: Int get() = logs.count { it.isCompleted }
    val totalCount: Int get() = habits.size
    val progressFraction: Float get() = if (totalCount > 0) completedCount.toFloat() / totalCount else 0f

    val habitsByCategory: Map<String, List<Habit>> get() = habits.groupBy { it.category }

    fun isHabitCompleted(habitId: String): Boolean = logs.any { it.habitId == habitId && it.isCompleted }
}

@HiltViewModel
class HabitsViewModel @Inject constructor(
    private val habitRepository: HabitRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HabitsUiState())
    val uiState: StateFlow<HabitsUiState> = _uiState.asStateFlow()

    init {
        loadHabits()
    }

    fun loadHabits() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }

            try {
                habitRepository.syncHabits()
                    .onSuccess { habits ->
                        _uiState.update { it.copy(habits = habits) }
                    }

                habitRepository.syncLogs(_uiState.value.selectedDate)
                    .onSuccess { logs ->
                        _uiState.update { it.copy(logs = logs) }
                    }

                _uiState.update { it.copy(isLoading = false) }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = e.message ?: "Failed to load habits") }
            }
        }
    }

    fun toggleHabit(habitId: String) {
        viewModelScope.launch {
            val isCompleted = !_uiState.value.isHabitCompleted(habitId)
            habitRepository.toggleHabit(habitId, _uiState.value.selectedDate, isCompleted)
                .onSuccess { log ->
                    val updatedLogs = _uiState.value.logs
                        .filter { it.habitId != habitId } + log
                    _uiState.update { it.copy(logs = updatedLogs) }
                }
        }
    }

    fun selectDate(date: String) {
        _uiState.update { it.copy(selectedDate = date) }
        loadHabits()
    }
}
