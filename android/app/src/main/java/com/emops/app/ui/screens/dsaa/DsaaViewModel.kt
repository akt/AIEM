package com.emops.app.ui.screens.dsaa

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.emops.app.data.remote.dto.CreateDsaaLogRequest
import com.emops.app.data.repository.DsaaRepository
import com.emops.app.domain.model.DsaaLog
import com.emops.app.domain.model.DsaaSuggestion
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class DsaaUiState(
    val isLoading: Boolean = false,
    val todayLog: DsaaLog? = null,
    val suggestion: DsaaSuggestion? = null,
    val history: List<DsaaLog> = emptyList(),
    val timerSeconds: Int = 900, // 15 minutes
    val timerRunning: Boolean = false,
    val error: String? = null
)

@HiltViewModel
class DsaaViewModel @Inject constructor(
    private val dsaaRepository: DsaaRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(DsaaUiState())
    val uiState: StateFlow<DsaaUiState> = _uiState.asStateFlow()
    private var timerJob: Job? = null

    init {
        loadToday()
        loadSuggestion()
    }

    fun loadToday() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            dsaaRepository.getToday()
                .onSuccess { log -> _uiState.update { it.copy(todayLog = log, isLoading = false) } }
                .onFailure { _uiState.update { it.copy(isLoading = false) } }
        }
    }

    fun loadSuggestion() {
        viewModelScope.launch {
            dsaaRepository.getAiSuggestion()
                .onSuccess { suggestion -> _uiState.update { it.copy(suggestion = suggestion) } }
        }
    }

    fun loadHistory() {
        viewModelScope.launch {
            dsaaRepository.getHistory()
                .onSuccess { history -> _uiState.update { it.copy(history = history) } }
        }
    }

    fun logRitual(
        frictionPoint: String,
        dsaaAction: String,
        microArtifactType: String?,
        microArtifactDescription: String?,
        expectedLeverage: String?,
        aiSuggestionAccepted: Boolean = false
    ) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val elapsed = 900 - _uiState.value.timerSeconds
            dsaaRepository.logRitual(
                CreateDsaaLogRequest(
                    frictionPoint = frictionPoint,
                    dsaaAction = dsaaAction,
                    microArtifactType = microArtifactType,
                    microArtifactDescription = microArtifactDescription,
                    expectedLeverage = expectedLeverage,
                    durationMinutes = if (elapsed > 0) elapsed / 60 else null,
                    aiSuggestionAccepted = aiSuggestionAccepted
                )
            ).onSuccess { log ->
                _uiState.update { it.copy(todayLog = log, isLoading = false) }
                stopTimer()
            }.onFailure { e ->
                _uiState.update { it.copy(isLoading = false, error = e.message) }
            }
        }
    }

    fun startTimer() {
        timerJob?.cancel()
        _uiState.update { it.copy(timerRunning = true, timerSeconds = 900) }
        timerJob = viewModelScope.launch {
            while (_uiState.value.timerSeconds > 0 && _uiState.value.timerRunning) {
                delay(1000)
                _uiState.update { it.copy(timerSeconds = it.timerSeconds - 1) }
            }
            _uiState.update { it.copy(timerRunning = false) }
        }
    }

    fun stopTimer() {
        timerJob?.cancel()
        _uiState.update { it.copy(timerRunning = false) }
    }

    override fun onCleared() {
        super.onCleared()
        timerJob?.cancel()
    }
}
