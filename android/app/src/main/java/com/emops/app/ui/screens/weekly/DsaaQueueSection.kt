package com.emops.app.ui.screens.weekly

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.emops.app.domain.model.WeeklySheet
import com.emops.app.ui.theme.*

@Composable
fun DsaaQueueSection(sheet: WeeklySheet?) {
    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Text("DSAA Queue", fontWeight = FontWeight.Bold, color = EMOps_Text, fontSize = 18.sp)

        // Focus this week
        Text("Focus This Week", color = EMOps_TextSecondary, fontWeight = FontWeight.Medium)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            data class FocusOption(val key: String, val label: String, val color: androidx.compose.ui.graphics.Color)
            listOf(
                FocusOption("delete", "Delete", DSAA_Delete),
                FocusOption("simplify", "Simplify", DSAA_Simplify),
                FocusOption("accelerate", "Accelerate", DSAA_Accelerate),
                FocusOption("automate", "Automate", DSAA_Automate)
            ).forEach { option ->
                FilterChip(
                    selected = sheet?.dsaaFocusThisWeek == option.key,
                    onClick = { },
                    label = { Text(option.label, fontSize = 12.sp) },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = option.color.copy(alpha = 0.2f),
                        selectedLabelColor = option.color,
                        containerColor = EMOps_SurfaceVariant,
                        labelColor = EMOps_TextSecondary
                    )
                )
            }
        }

        // Queue items per category
        data class QueueCategory(val key: String, val label: String, val color: androidx.compose.ui.graphics.Color, val items: List<String>)
        val categories = listOf(
            QueueCategory("delete", "Delete", DSAA_Delete, sheet?.dsaaQueue?.delete ?: emptyList()),
            QueueCategory("simplify", "Simplify", DSAA_Simplify, sheet?.dsaaQueue?.simplify ?: emptyList()),
            QueueCategory("accelerate", "Accelerate", DSAA_Accelerate, sheet?.dsaaQueue?.accelerate ?: emptyList()),
            QueueCategory("automate", "Automate", DSAA_Automate, sheet?.dsaaQueue?.automate ?: emptyList())
        )

        categories.forEach { category ->
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(category.label, color = category.color,
                        fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    Spacer(modifier = Modifier.height(8.dp))
                    if (category.items.isEmpty()) {
                        Text("No items", color = EMOps_TextSecondary, fontSize = 13.sp)
                    } else {
                        category.items.forEachIndexed { index, item ->
                            Text("${index + 1}. $item", color = EMOps_Text, fontSize = 14.sp,
                                modifier = Modifier.padding(vertical = 2.dp))
                        }
                    }
                    Spacer(modifier = Modifier.height(8.dp))
                    SectionTextField("Add item", "")
                }
            }
        }
    }
}
