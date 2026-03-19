package com.emops.app.ui.screens.weekly

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.emops.app.domain.model.WeeklySheet
import com.emops.app.ui.theme.*

@Composable
fun ConstraintSection(sheet: WeeklySheet?) {
    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Text("Constraint Deep-Dive", fontWeight = FontWeight.Bold,
            color = EMOps_Text, fontSize = 18.sp)

        SectionTextField("Constraint Statement", sheet?.constraintStatement ?: "")

        Text("Evidence", color = EMOps_TextSecondary, fontWeight = FontWeight.Medium)
        SectionTextField("SLI Dashboards", sheet?.constraintEvidence?.sliDashboards ?: "")
        SectionTextField("Incident Pattern", sheet?.constraintEvidence?.incidentPattern ?: "")
        SectionTextField("Queue Lag", sheet?.constraintEvidence?.queueLag ?: "")
        SectionTextField("Cost Regression", sheet?.constraintEvidence?.costRegression ?: "")

        SectionTextField("SLO Service", sheet?.constraintSloService ?: "")
        SectionTextField("SLO Targets", sheet?.constraintSloTargets ?: "")

        // Error Budget Status
        Text("Error Budget Status", color = EMOps_TextSecondary, fontWeight = FontWeight.Medium)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            listOf("healthy" to Budget_Healthy, "burning" to Budget_Burning, "exhausted" to Budget_Exhausted).forEach { (status, color) ->
                FilterChip(
                    selected = sheet?.constraintErrorBudgetStatus == status,
                    onClick = { },
                    label = { Text(status.uppercase(), fontSize = 12.sp) },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = color.copy(alpha = 0.2f),
                        selectedLabelColor = color,
                        containerColor = EMOps_SurfaceVariant,
                        labelColor = EMOps_TextSecondary
                    )
                )
            }
        }

        SectionTextField("Exhausted Action", sheet?.constraintExhaustedAction ?: "")

        // Incident Checklist
        Text("Incident / Postmortem Pipeline", fontWeight = FontWeight.Bold,
            color = EMOps_Text, fontSize = 18.sp, modifier = Modifier.padding(top = 8.dp))

        val incidentItems = listOf(
            "P0/P1 Reviewed" to (sheet?.incidentChecklist?.p0p1Reviewed ?: false),
            "Postmortem Scheduled" to (sheet?.incidentChecklist?.postmortemScheduled ?: false),
            "Action Items Owned" to (sheet?.incidentChecklist?.actionItemsOwned ?: false),
            "Runbooks Updated" to (sheet?.incidentChecklist?.runbooksUpdated ?: false),
            "Prevention Bet Chosen" to (sheet?.incidentChecklist?.preventionBetChosen ?: false)
        )

        incidentItems.forEach { (label, checked) ->
            Row(modifier = Modifier.fillMaxWidth()) {
                Checkbox(
                    checked = checked,
                    onCheckedChange = { },
                    colors = CheckboxDefaults.colors(
                        checkedColor = EMOps_Secondary,
                        uncheckedColor = EMOps_TextSecondary
                    )
                )
                Text(label, color = EMOps_Text, modifier = Modifier.padding(top = 12.dp))
            }
        }
    }
}
