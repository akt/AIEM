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
fun TimeBlocksSection(sheet: WeeklySheet?) {
    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Text("Calendar Time Blocks", fontWeight = FontWeight.Bold, color = EMOps_Text, fontSize = 18.sp)

        val days = listOf("mon", "tue", "wed", "thu", "fri")
        val dayLabels = mapOf(
            "mon" to "Monday", "tue" to "Tuesday", "wed" to "Wednesday",
            "thu" to "Thursday", "fri" to "Friday"
        )

        days.forEach { day ->
            val block = sheet?.timeBlocks?.get(day)
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(dayLabels[day] ?: day, color = EMOps_Primary,
                        fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                    Spacer(modifier = Modifier.height(8.dp))
                    SectionTextField("Deep Work", block?.deepWork ?: "")
                    SectionTextField("Free Thinking", block?.freeThinking ?: "")
                    SectionTextField("Reactive Budget", block?.reactiveBudget ?: "")
                    SectionTextField("Key Meeting", block?.keyMeeting ?: "")
                }
            }
        }
    }
}
