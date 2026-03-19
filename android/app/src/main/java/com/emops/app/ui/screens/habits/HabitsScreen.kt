package com.emops.app.ui.screens.habits

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
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
import java.time.LocalDate
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HabitsScreen(
    viewModel: HabitsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val today = LocalDate.now().format(DateTimeFormatter.ofPattern("MMM d"))

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EMOps_Background)
    ) {
        TopAppBar(
            title = { Text("Today's Habits", fontWeight = FontWeight.Bold, color = EMOps_Text) },
            actions = {
                Text(today, color = EMOps_TextSecondary, modifier = Modifier.padding(end = 16.dp))
            },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = EMOps_Background)
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp)
        ) {
            // Progress Bar
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            "Progress: ${uiState.completedCount}/${uiState.totalCount}",
                            color = EMOps_Text,
                            fontWeight = FontWeight.Medium
                        )
                        Text(
                            "Streak: ${uiState.streak} days",
                            color = EMOps_Warning,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    Spacer(modifier = Modifier.height(8.dp))
                    LinearProgressIndicator(
                        progress = { uiState.progressFraction },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(8.dp)
                            .clip(RoundedCornerShape(4.dp)),
                        color = EMOps_Secondary,
                        trackColor = EMOps_SurfaceVariant,
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Habits by Category
            val categoryLabels = mapOf(
                "deep_work" to "DEEP WORK & PRODUCTIVITY",
                "reliability" to "RELIABILITY & SRE",
                "delivery" to "DELIVERY & DORA",
                "security" to "SECURITY",
                "ai_safety" to "AI SAFETY",
                "leadership" to "LEADERSHIP",
                "health" to "HEALTH & SUSTAINABILITY",
                "learning" to "LEARNING"
            )

            uiState.habitsByCategory.forEach { (category, habits) ->
                Text(
                    text = categoryLabels[category] ?: category.uppercase(),
                    color = EMOps_TextSecondary,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp,
                    modifier = Modifier.padding(vertical = 8.dp)
                )

                habits.forEach { habit ->
                    val isCompleted = uiState.isHabitCompleted(habit.id)

                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 2.dp)
                            .clickable { viewModel.toggleHabit(habit.id) },
                        shape = RoundedCornerShape(8.dp),
                        colors = CardDefaults.cardColors(
                            containerColor = if (isCompleted) EMOps_Surface else EMOps_SurfaceVariant
                        )
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(12.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                modifier = Modifier.weight(1f)
                            ) {
                                Checkbox(
                                    checked = isCompleted,
                                    onCheckedChange = { viewModel.toggleHabit(habit.id) },
                                    colors = CheckboxDefaults.colors(
                                        checkedColor = EMOps_Secondary,
                                        uncheckedColor = EMOps_TextSecondary,
                                        checkmarkColor = EMOps_Background
                                    )
                                )
                                Column {
                                    Text(
                                        habit.name,
                                        color = if (isCompleted) EMOps_Secondary else EMOps_Text,
                                        fontSize = 14.sp,
                                        fontWeight = FontWeight.Medium
                                    )
                                    if (habit.targetValue != null && habit.targetUnit != null) {
                                        Text(
                                            "${habit.targetValue}${habit.targetUnit}",
                                            color = EMOps_TextSecondary,
                                            fontSize = 12.sp
                                        )
                                    }
                                }
                            }
                            Text(
                                text = if (isCompleted) "✅" else "⬜",
                                fontSize = 18.sp
                            )
                        }
                    }
                }
            }

            // Add Custom Habit button
            Spacer(modifier = Modifier.height(16.dp))
            OutlinedButton(
                onClick = { /* navigate to add habit */ },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = EMOps_Primary)
            ) {
                Icon(Icons.Default.Add, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text("Add Custom Habit")
            }

            Spacer(modifier = Modifier.height(80.dp))
        }
    }
}
