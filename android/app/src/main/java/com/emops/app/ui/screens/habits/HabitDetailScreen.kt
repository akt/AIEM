package com.emops.app.ui.screens.habits

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.emops.app.domain.model.Habit
import com.emops.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HabitDetailScreen(
    habit: Habit,
    onBack: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EMOps_Background)
    ) {
        TopAppBar(
            title = { Text(habit.name, color = EMOps_Text) },
            navigationIcon = {
                IconButton(onClick = onBack) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back", tint = EMOps_Text)
                }
            },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = EMOps_Background)
        )

        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Streak", color = EMOps_TextSecondary, fontSize = 12.sp)
                    Text("${habit.streakCurrent} days", color = EMOps_Warning,
                        fontSize = 28.sp, fontWeight = FontWeight.Bold)
                    Text("Best: ${habit.streakBest} days", color = EMOps_TextSecondary, fontSize = 12.sp)
                }
            }

            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Details", color = EMOps_TextSecondary, fontSize = 12.sp,
                        modifier = Modifier.padding(bottom = 8.dp))
                    Text("Category: ${habit.category}", color = EMOps_Text, fontSize = 14.sp)
                    Text("Frequency: ${habit.frequency}", color = EMOps_Text, fontSize = 14.sp,
                        modifier = Modifier.padding(top = 4.dp))
                    if (habit.description.isNotEmpty()) {
                        Text(habit.description, color = EMOps_TextSecondary, fontSize = 14.sp,
                            modifier = Modifier.padding(top = 8.dp))
                    }
                }
            }
        }
    }
}
