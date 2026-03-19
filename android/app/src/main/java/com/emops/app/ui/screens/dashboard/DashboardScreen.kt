package com.emops.app.ui.screens.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.emops.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    viewModel: DashboardViewModel = hiltViewModel(),
    onNavigateToSettings: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EMOps_Background)
    ) {
        // Top Bar
        TopAppBar(
            title = {
                Text(
                    "EMOPS",
                    fontWeight = FontWeight.Bold,
                    color = EMOps_Primary
                )
            },
            actions = {
                IconButton(onClick = onNavigateToSettings) {
                    Icon(Icons.Default.Settings, "Settings", tint = EMOps_TextSecondary)
                }
                IconButton(onClick = {}) {
                    Icon(Icons.Default.Person, "Profile", tint = EMOps_TextSecondary)
                }
            },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = EMOps_Background)
        )

        when {
            uiState.isLoading -> {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = EMOps_Primary)
                }
            }
            uiState.error != null -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(24.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(16.dp),
                        colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
                    ) {
                        Column(
                            modifier = Modifier.padding(24.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            Text(
                                "Something went wrong",
                                fontWeight = FontWeight.Bold,
                                color = EMOps_Text,
                                fontSize = 16.sp
                            )
                            Text(
                                uiState.error,
                                color = EMOps_TextSecondary,
                                fontSize = 14.sp
                            )
                            Button(
                                onClick = { viewModel.loadDashboard() },
                                colors = ButtonDefaults.buttonColors(containerColor = EMOps_Primary)
                            ) {
                                Icon(
                                    Icons.Default.Refresh,
                                    contentDescription = null,
                                    modifier = Modifier.size(18.dp)
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text("Retry")
                            }
                        }
                    }
                }
            }
            else -> {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Greeting
            Text(
                text = "Good morning! ${uiState.weekLabel}",
                fontSize = 16.sp,
                color = EMOps_TextSecondary
            )

            // Stats Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text("DSAA Streak: ${uiState.dsaaStreak} days",
                            fontWeight = FontWeight.Bold, color = EMOps_Warning, fontSize = 16.sp)
                    }
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        "Deep Work: ${uiState.deepWorkHours}h / ${uiState.deepWorkTarget}h",
                        color = if (uiState.deepWorkHours >= uiState.deepWorkTarget) EMOps_Secondary else EMOps_Text,
                        fontSize = 14.sp
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        "Habits: ${uiState.habitsCompleted}/${uiState.habitsTotal} today",
                        color = EMOps_Text,
                        fontSize = 14.sp
                    )
                }
            }

            // This Week's Focus
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        "This Week's Focus",
                        fontWeight = FontWeight.Bold,
                        color = EMOps_Text,
                        fontSize = 16.sp,
                        modifier = Modifier.padding(bottom = 8.dp)
                    )
                    Text(
                        "Constraint: ${uiState.constraintStatement.ifEmpty { "Not set" }}",
                        color = EMOps_Text,
                        fontSize = 14.sp
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text("Error Budget:", color = EMOps_TextSecondary, fontSize = 14.sp)
                        val budgetColor = when (uiState.errorBudgetStatus) {
                            "healthy" -> Budget_Healthy
                            "burning" -> Budget_Burning
                            "exhausted" -> Budget_Exhausted
                            else -> EMOps_TextSecondary
                        }
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(4.dp))
                                .background(budgetColor.copy(alpha = 0.2f))
                                .padding(horizontal = 8.dp, vertical = 2.dp)
                        ) {
                            Text(
                                uiState.errorBudgetStatus.uppercase(),
                                color = budgetColor,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        "DSAA Focus: ${uiState.dsaaFocus.ifEmpty { "Not set" }}",
                        color = EMOps_TextSecondary,
                        fontSize = 14.sp
                    )
                }
            }

            // Top 3 Outcomes
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        "Top 3 Outcomes",
                        fontWeight = FontWeight.Bold,
                        color = EMOps_Text,
                        fontSize = 16.sp,
                        modifier = Modifier.padding(bottom = 8.dp)
                    )
                    if (uiState.outcomes.isEmpty()) {
                        Text("No outcomes set for this week", color = EMOps_TextSecondary, fontSize = 14.sp)
                    } else {
                        uiState.outcomes.forEach { outcome ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 4.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                val icon = when (outcome.status) {
                                    "done" -> "✅"
                                    "blocked" -> "🚫"
                                    else -> "🔄"
                                }
                                Text(
                                    "$icon ${outcome.outcomeText}",
                                    color = EMOps_Text,
                                    fontSize = 14.sp
                                )
                            }
                        }
                    }
                }
            }

            // AI Coach Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_SurfaceVariant)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        "AI Coach",
                        fontWeight = FontWeight.Bold,
                        color = EMOps_Primary,
                        fontSize = 16.sp,
                        modifier = Modifier.padding(bottom = 8.dp)
                    )
                    Text(
                        uiState.aiCoachingNote.ifEmpty { "Loading coaching insights..." },
                        color = EMOps_Text,
                        fontSize = 14.sp,
                        lineHeight = 20.sp
                    )
                }
            }

            // Upcoming Reminders
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        "Upcoming",
                        fontWeight = FontWeight.Bold,
                        color = EMOps_Text,
                        fontSize = 16.sp,
                        modifier = Modifier.padding(bottom = 8.dp)
                    )
                    if (uiState.upcomingReminders.isEmpty()) {
                        Text("10:00 Deep Work Block", color = EMOps_Text, fontSize = 14.sp)
                        Text("14:00 Reactive Window", color = EMOps_Text, fontSize = 14.sp,
                            modifier = Modifier.padding(top = 4.dp))
                        Text("16:00 Scorecard Fill (Fri)", color = EMOps_Text, fontSize = 14.sp,
                            modifier = Modifier.padding(top = 4.dp))
                    } else {
                        uiState.upcomingReminders.forEach { reminder ->
                            Text(
                                "${reminder.scheduledTime ?: ""} ${reminder.title}",
                                color = EMOps_Text,
                                fontSize = 14.sp,
                                modifier = Modifier.padding(vertical = 2.dp)
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(80.dp))
        }
            } // end else
        } // end when
    }
}
