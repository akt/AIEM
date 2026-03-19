package com.emops.app.ui.screens.dashboard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.emops.app.data.repository.AuthRepository
import com.emops.app.data.repository.HabitRepository
import com.emops.app.data.repository.WeeklySheetRepository
import com.emops.app.domain.model.Outcome
import com.emops.app.domain.model.Reminder
import com.emops.app.data.repository.ReminderRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.time.temporal.WeekFields
import javax.inject.Inject

data class DashboardUiState(
    val isLoading: Boolean = true,
    val weekLabel: String = "",
    val dsaaStreak: Int = 0,
    val deepWorkHours: Double = 0.0,
    val deepWorkTarget: Double = 1.5,
    val habitsCompleted: Int = 0,
    val habitsTotal: Int = 0,
    val constraintStatement: String = "",
    val errorBudgetStatus: String = "healthy",
    val dsaaFocus: String = "",
    val outcomes: List<Outcome> = emptyList(),
    val aiCoachingNote: String = "",
    val upcomingReminders: List<Reminder> = emptyList(),
    val error: String? = null
)

@HiltViewModel
class DashboardViewModel @Inject constructor(
    private val weeklySheetRepository: WeeklySheetRepository,
    private val habitRepository: HabitRepository,
    private val reminderRepository: ReminderRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(DashboardUiState())
    val uiState: StateFlow<DashboardUiState> = _uiState.asStateFlow()

    init {
        loadDashboard()
    }

    fun loadDashboard() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }

            try {
                val today = LocalDate.now()
                val weekNum = today.get(WeekFields.ISO.weekOfWeekBasedYear())
                val year = today.year
                val weekLabel = "Week $weekNum, $year"

                _uiState.update { it.copy(weekLabel = weekLabel) }

                // Load current sheet
                weeklySheetRepository.getCurrentSheet()
                    .onSuccess { sheet ->
                        _uiState.update {
                            it.copy(
                                constraintStatement = sheet.constraintStatement,
                                errorBudgetStatus = sheet.constraintErrorBudgetStatus,
                                dsaaFocus = sheet.dsaaFocusThisWeek,
                                outcomes = sheet.outcomes,
                                aiCoachingNote = sheet.aiCoachingNotes ?: "Start your day with the DSAA ritual. Focus on simplifying one process today.",
                                dsaaStreak = 14 // placeholder - would come from stats endpoint
                            )
                        }
                    }
                    .onFailure { e ->
                        _uiState.update {
                            it.copy(
                                aiCoachingNote = "Start your day with the DSAA ritual. Focus on simplifying one process today.",
                                dsaaStreak = 0
                            )
                        }
                    }

                // Load reminders
                reminderRepository.getReminders()
                    .onSuccess { reminders ->
                        _uiState.update { it.copy(upcomingReminders = reminders.take(3)) }
                    }

                _uiState.update { it.copy(isLoading = false) }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = e.message ?: "Failed to load dashboard") }
            }
        }
    }

    fun logout() {
        viewModelScope.launch {
            authRepository.logout()
        }
    }
}
