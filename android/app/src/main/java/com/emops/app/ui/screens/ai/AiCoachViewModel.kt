package com.emops.app.ui.screens.ai

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.emops.app.data.remote.ApiService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class AiCoachUiState(
    val isLoading: Boolean = false,
    val dailyCoaching: String = "",
    val weeklyInsight: String = "",
    val habitInsight: String = "",
    val trendInsight: String = "",
    val error: String? = null
)

@HiltViewModel
class AiCoachViewModel @Inject constructor(
    private val apiService: ApiService
) : ViewModel() {

    private val _uiState = MutableStateFlow(AiCoachUiState())
    val uiState: StateFlow<AiCoachUiState> = _uiState.asStateFlow()

    init {
        loadInsights()
    }

    fun loadInsights() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }

            try {
                val coaching = apiService.getDailyCoaching()
                if (coaching.isSuccessful) {
                    coaching.body()?.let { insight ->
                        _uiState.update {
                            it.copy(dailyCoaching = insight.coachingNote ?: insight.suggestion ?: "")
                        }
                    }
                }
            } catch (_: Exception) {
                _uiState.update {
                    it.copy(dailyCoaching = "Focus on your constraint deep-dive today. Your deep work hours are trending well - maintain the momentum.")
                }
            }

            try {
                val trends = apiService.getTrendInsight()
                if (trends.isSuccessful) {
                    trends.body()?.let { insight ->
                        _uiState.update {
                            it.copy(
                                trendInsight = insight.positiveTrend ?: "",
                                habitInsight = insight.suggestion ?: ""
                            )
                        }
                    }
                }
            } catch (_: Exception) {
                _uiState.update {
                    it.copy(
                        trendInsight = "Your Simplify actions yield 2x more leverage than Automate actions.",
                        habitInsight = "Consider adding a weekly architecture review habit to complement your DSAA practice."
                    )
                }
            }

            _uiState.update { it.copy(isLoading = false) }
        }
    }
}
