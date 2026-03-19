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
fun OutcomesSection(sheet: WeeklySheet?) {
    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Text("Top 3 Outcomes", fontWeight = FontWeight.Bold, color = EMOps_Text, fontSize = 18.sp)

        val outcomes = sheet?.outcomes ?: emptyList()
        for (i in 1..3) {
            val outcome = outcomes.find { it.position == i }
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text("Outcome #$i", color = EMOps_Primary, fontWeight = FontWeight.SemiBold)
                    SectionTextField("What", outcome?.outcomeText ?: "")
                    SectionTextField("Impact", outcome?.impact ?: "")
                    SectionTextField("Definition of Done", outcome?.definitionOfDone ?: "")
                    SectionTextField("Owner", outcome?.owner ?: "")
                    SectionTextField("Risk & Mitigation", outcome?.riskAndMitigation ?: "")

                    // Status chips
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        val statuses = listOf("in_progress", "done", "blocked", "carried_over")
                        statuses.forEach { status ->
                            FilterChip(
                                selected = outcome?.status == status,
                                onClick = { },
                                label = { Text(status.replace("_", " "), fontSize = 11.sp) },
                                colors = FilterChipDefaults.filterChipColors(
                                    selectedContainerColor = when (status) {
                                        "done" -> EMOps_Secondary.copy(alpha = 0.2f)
                                        "blocked" -> EMOps_Error.copy(alpha = 0.2f)
                                        else -> EMOps_Primary.copy(alpha = 0.2f)
                                    },
                                    containerColor = EMOps_SurfaceVariant
                                )
                            )
                        }
                    }
                }
            }
        }

        // Leadership Decisions
        Text("Leadership Decisions (max 3)", fontWeight = FontWeight.Bold,
            color = EMOps_Text, fontSize = 18.sp, modifier = Modifier.padding(top = 8.dp))

        val decisions = sheet?.decisions ?: emptyList()
        for (i in 1..3) {
            val decision = decisions.find { it.position == i }
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text("Decision #$i", color = EMOps_Warning, fontWeight = FontWeight.SemiBold)
                    SectionTextField("Decision", decision?.decisionText ?: "")
                    SectionTextField("By When", decision?.byWhen ?: "")
                    SectionTextField("Inputs Needed", decision?.inputsNeeded ?: "")
                }
            }
        }
    }
}
