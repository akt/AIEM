package com.emops.app.ui.screens.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.emops.app.data.repository.AuthRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SettingsUiState(
    val displayName: String = "",
    val email: String = "",
    val timezone: String = "Indian/Maldives",
    val dsaaTriggerTime: String = "09:00",
    val deepWorkTarget: Double = 1.5,
    val notificationsEnabled: Boolean = true,
    val dailyDsaaReminder: Boolean = true,
    val weeklyFillReminder: Boolean = true,
    val deepWorkAlert: Boolean = true,
    val scorecardReminder: Boolean = true
)

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    fun logout() {
        viewModelScope.launch {
            authRepository.logout()
        }
    }

    fun updateDsaaTriggerTime(time: String) {
        _uiState.update { it.copy(dsaaTriggerTime = time) }
    }

    fun updateDeepWorkTarget(target: Double) {
        _uiState.update { it.copy(deepWorkTarget = target) }
    }

    fun toggleNotification(key: String) {
        _uiState.update {
            when (key) {
                "dailyDsaa" -> it.copy(dailyDsaaReminder = !it.dailyDsaaReminder)
                "weeklyFill" -> it.copy(weeklyFillReminder = !it.weeklyFillReminder)
                "deepWork" -> it.copy(deepWorkAlert = !it.deepWorkAlert)
                "scorecard" -> it.copy(scorecardReminder = !it.scorecardReminder)
                else -> it
            }
        }
    }
}
