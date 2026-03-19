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
fun ScorecardSection(sheet: WeeklySheet?) {
    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Text("Friday Scorecard", fontWeight = FontWeight.Bold, color = EMOps_Text, fontSize = 18.sp)

        // DORA Metrics
        ScorecardGroup("DORA Metrics", listOf(
            "Deploy Frequency" to (sheet?.scorecard?.dora?.deployFreq),
            "Lead Time" to (sheet?.scorecard?.dora?.leadTime),
            "Change Fail Rate" to (sheet?.scorecard?.dora?.changeFailRate),
            "Time to Restore" to (sheet?.scorecard?.dora?.timeToRestore)
        ))

        // SLO
        ScorecardGroup("SLO Compliance", listOf(
            "Compliance" to (sheet?.scorecard?.slo?.compliance),
            "Error Budget Burn" to (sheet?.scorecard?.slo?.errorBudgetBurn)
        ))

        // SPACE
        ScorecardGroup("SPACE-lite", listOf(
            "Deep Work Hours" to (sheet?.scorecard?.space?.deepWorkHours),
            "Friction Pulse" to (sheet?.scorecard?.space?.frictionPulse)
        ))

        // AI Health
        ScorecardGroup("AI Health", listOf(
            "Assisted %" to (sheet?.scorecard?.aiHealth?.assistedPct),
            "Risk Catches" to (sheet?.scorecard?.aiHealth?.riskCatches)
        ))

        // AI Summary
        if (sheet?.aiWeeklySummary != null) {
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_SurfaceVariant)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("AI Weekly Summary", color = EMOps_Primary,
                        fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(sheet.aiWeeklySummary, color = EMOps_Text, fontSize = 14.sp)
                }
            }
        }
    }
}

@Composable
private fun ScorecardGroup(
    title: String,
    metrics: List<Pair<String, com.emops.app.domain.model.MetricEntry?>>
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(title, color = EMOps_Primary, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
            Spacer(modifier = Modifier.height(8.dp))
            metrics.forEach { (name, entry) ->
                Row(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(name, color = EMOps_Text, fontSize = 13.sp,
                        modifier = Modifier.weight(1f))
                    Text(entry?.thisWeek ?: "-", color = EMOps_TextSecondary, fontSize = 13.sp)
                    Text(" / ${entry?.target ?: "-"}", color = EMOps_TextSecondary, fontSize = 13.sp)
                }
            }
        }
    }
}
