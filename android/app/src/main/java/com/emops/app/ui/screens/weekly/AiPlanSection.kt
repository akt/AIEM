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
fun AiPlanSection(sheet: WeeklySheet?) {
    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Text("AI Leverage Plan", fontWeight = FontWeight.Bold, color = EMOps_Text, fontSize = 18.sp)

        // AI Tasks
        val tasks = sheet?.aiTasks ?: emptyList()
        if (tasks.isEmpty()) {
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("No AI tasks configured", color = EMOps_TextSecondary)
                    Spacer(modifier = Modifier.height(8.dp))
                    SectionTextField("Task description", "")
                    SectionTextField("Owner", "")
                }
            }
        } else {
            tasks.forEach { task ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
                ) {
                    Row(modifier = Modifier.padding(16.dp)) {
                        Checkbox(
                            checked = task.enabled,
                            onCheckedChange = { },
                            colors = CheckboxDefaults.colors(
                                checkedColor = EMOps_Primary,
                                uncheckedColor = EMOps_TextSecondary
                            )
                        )
                        Column(modifier = Modifier.padding(start = 8.dp)) {
                            Text(task.task, color = EMOps_Text, fontSize = 14.sp)
                            Text("Owner: ${task.owner}", color = EMOps_TextSecondary, fontSize = 12.sp)
                        }
                    }
                }
            }
        }

        // Guardrails
        Text("AI Guardrails Checked", color = EMOps_TextSecondary, fontWeight = FontWeight.Medium,
            modifier = Modifier.padding(top = 8.dp))
        val guardrails = sheet?.aiGuardrailsChecked ?: emptyList()
        val defaultGuardrails = listOf(
            "No secrets in prompts",
            "Outputs reviewed before merge",
            "Least privilege access",
            "Data classification respected",
            "Human-in-the-loop for critical decisions"
        )

        defaultGuardrails.forEach { guardrail ->
            Row(modifier = Modifier.fillMaxWidth()) {
                Checkbox(
                    checked = guardrails.contains(guardrail),
                    onCheckedChange = { },
                    colors = CheckboxDefaults.colors(
                        checkedColor = EMOps_Secondary,
                        uncheckedColor = EMOps_TextSecondary
                    )
                )
                Text(guardrail, color = EMOps_Text, fontSize = 14.sp,
                    modifier = Modifier.padding(top = 12.dp))
            }
        }

        // ADR Checklist
        Text("ADR / Architecture Review", fontWeight = FontWeight.Bold,
            color = EMOps_Text, fontSize = 18.sp, modifier = Modifier.padding(top = 8.dp))

        val adrItems = listOf(
            "ADR Link Exists" to (sheet?.adrChecklist?.adrLinkExists ?: false),
            "Alternatives Considered" to (sheet?.adrChecklist?.alternativesConsidered ?: false),
            "Rollout/Rollback Plan" to (sheet?.adrChecklist?.rolloutRollbackPlan ?: false),
            "Observability Plan" to (sheet?.adrChecklist?.observabilityPlan ?: false),
            "Data Contracts Checked" to (sheet?.adrChecklist?.dataContractsChecked ?: false)
        )

        adrItems.forEach { (label, checked) ->
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
