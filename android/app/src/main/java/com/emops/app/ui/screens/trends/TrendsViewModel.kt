package com.emops.app.ui.screens.trends

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.emops.app.data.repository.TrendsRepository
import com.emops.app.domain.model.TrendData
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class TrendsUiState(
    val isLoading: Boolean = true,
    val selectedPeriod: String = "Week",
    val trends: List<TrendData> = emptyList(),
    val aiInsight: String? = null,
    val error: String? = null
)

@HiltViewModel
class TrendsViewModel @Inject constructor(
    private val trendsRepository: TrendsRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(TrendsUiState())
    val uiState: StateFlow<TrendsUiState> = _uiState.asStateFlow()

    val periods = listOf("Week", "Month", "Quarter")

    init {
        loadTrends()
    }

    fun loadTrends() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val weeks = when (_uiState.value.selectedPeriod) {
                "Week" -> 4
                "Month" -> 12
                "Quarter" -> 26
                else -> 12
            }
            trendsRepository.getWeeklyTrends(weeks)
                .onSuccess { trends ->
                    _uiState.update { it.copy(
                        trends = trends,
                        aiInsight = trends.lastOrNull()?.aiTrendInsight,
                        isLoading = false
                    )}
                }
                .onFailure { e ->
                    _uiState.update { it.copy(isLoading = false, error = e.message) }
                }
        }
    }

    fun selectPeriod(period: String) {
        _uiState.update { it.copy(selectedPeriod = period) }
        loadTrends()
    }
}
