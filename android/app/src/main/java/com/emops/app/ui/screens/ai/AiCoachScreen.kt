package com.emops.app.ui.screens.ai

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.emops.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AiCoachScreen(
    viewModel: AiCoachViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EMOps_Background)
    ) {
        TopAppBar(
            title = { Text("AI Coach", fontWeight = FontWeight.Bold, color = EMOps_Text) },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = EMOps_Background)
        )

        if (uiState.isLoading) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = androidx.compose.ui.Alignment.Center
            ) {
                CircularProgressIndicator(color = EMOps_Primary)
            }
        } else {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Daily Coaching
                InsightCard(
                    title = "Daily Coaching",
                    content = uiState.dailyCoaching.ifEmpty {
                        "Focus on your constraint deep-dive today. Your deep work hours are trending well."
                    },
                    accentColor = EMOps_Primary
                )

                // Trend Insight
                InsightCard(
                    title = "Trend Analysis",
                    content = uiState.trendInsight.ifEmpty {
                        "Your Simplify actions yield 2x more leverage than Automate actions."
                    },
                    accentColor = EMOps_Secondary
                )

                // Habit Insight
                InsightCard(
                    title = "Habit Insight",
                    content = uiState.habitInsight.ifEmpty {
                        "Consider adding a weekly architecture review habit."
                    },
                    accentColor = EMOps_Warning
                )

                // Weekly Summary
                InsightCard(
                    title = "Weekly Summary",
                    content = uiState.weeklyInsight.ifEmpty {
                        "Complete your Friday scorecard to generate the weekly AI summary."
                    },
                    accentColor = DSAA_Simplify
                )

                // Quick Actions
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text("AI Actions", fontWeight = FontWeight.Bold,
                            color = EMOps_Text, fontSize = 16.sp)

                        OutlinedButton(
                            onClick = { viewModel.loadInsights() },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(8.dp)
                        ) { Text("Refresh Insights", color = EMOps_Primary) }

                        OutlinedButton(
                            onClick = { /* constraint analysis */ },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(8.dp)
                        ) { Text("Analyze Constraint", color = EMOps_Primary) }

                        OutlinedButton(
                            onClick = { /* scorecard insight */ },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(8.dp)
                        ) { Text("Scorecard Insight", color = EMOps_Primary) }
                    }
                }

                Spacer(modifier = Modifier.height(80.dp))
            }
        }
    }
}

@Composable
fun InsightCard(
    title: String,
    content: String,
    accentColor: androidx.compose.ui.graphics.Color
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = EMOps_SurfaceVariant)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(title, color = accentColor, fontWeight = FontWeight.Bold, fontSize = 16.sp)
            Spacer(modifier = Modifier.height(8.dp))
            Text(content, color = EMOps_Text, fontSize = 14.sp, lineHeight = 20.sp)
        }
    }
}
