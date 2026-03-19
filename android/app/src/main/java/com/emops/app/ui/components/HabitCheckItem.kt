package com.emops.app.ui.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.emops.app.domain.model.Habit
import com.emops.app.ui.theme.*

@Composable
fun HabitCheckItem(
    habit: Habit,
    isCompleted: Boolean,
    onToggle: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clickable { onToggle() }
            .padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Checkbox(
            checked = isCompleted,
            onCheckedChange = { onToggle() },
            colors = CheckboxDefaults.colors(
                checkedColor = EMOps_Secondary,
                uncheckedColor = EMOps_TextSecondary,
                checkmarkColor = EMOps_Background
            )
        )
        Column(modifier = Modifier.weight(1f).padding(start = 4.dp)) {
            Text(
                habit.name,
                color = if (isCompleted) EMOps_Secondary else EMOps_Text,
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium
            )
            if (habit.targetValue != null) {
                Text(
                    "${habit.targetValue} ${habit.targetUnit ?: ""}",
                    color = EMOps_TextSecondary,
                    fontSize = 12.sp
                )
            }
        }
    }
}
