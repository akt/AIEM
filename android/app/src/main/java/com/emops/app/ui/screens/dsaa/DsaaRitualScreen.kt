package com.emops.app.ui.screens.dsaa

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.emops.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DsaaRitualScreen(
    viewModel: DsaaViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    var frictionPoint by remember { mutableStateOf("") }
    var selectedAction by remember { mutableStateOf("") }
    var microArtifact by remember { mutableStateOf("") }
    var expectedLeverage by remember { mutableStateOf("") }
    var acceptedSuggestion by remember { mutableStateOf(false) }

    val minutes = uiState.timerSeconds / 60
    val seconds = uiState.timerSeconds % 60
    val timerText = "%02d:%02d".format(minutes, seconds)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EMOps_Background)
    ) {
        TopAppBar(
            title = { Text("DSAA Ritual", fontWeight = FontWeight.Bold, color = EMOps_Text) },
            actions = {
                if (uiState.timerRunning) {
                    Text(timerText, color = EMOps_Warning, fontWeight = FontWeight.Bold,
                        fontSize = 18.sp, modifier = Modifier.padding(end = 16.dp))
                }
            },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = EMOps_Background)
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Already completed today
            if (uiState.todayLog != null) {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text("Today's Ritual Complete!", color = EMOps_Secondary,
                            fontWeight = FontWeight.Bold, fontSize = 18.sp)
                        Spacer(modifier = Modifier.height(8.dp))
                        Text("Action: ${uiState.todayLog!!.dsaaAction.uppercase()}",
                            color = EMOps_Text)
                        Text("Friction: ${uiState.todayLog!!.frictionPoint}",
                            color = EMOps_TextSecondary, modifier = Modifier.padding(top = 4.dp))
                    }
                }
                return@Column
            }

            // AI Suggestion Card
            uiState.suggestion?.let { suggestion ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = EMOps_SurfaceVariant)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text("AI Suggestion", color = EMOps_Primary,
                            fontWeight = FontWeight.Bold, fontSize = 16.sp)
                        Spacer(modifier = Modifier.height(8.dp))

                        val actionColor = when (suggestion.dsaaAction.lowercase()) {
                            "delete" -> DSAA_Delete
                            "simplify" -> DSAA_Simplify
                            "accelerate" -> DSAA_Accelerate
                            "automate" -> DSAA_Automate
                            else -> EMOps_Primary
                        }

                        Text("${suggestion.dsaaAction.uppercase()}: ${suggestion.actionDescription}",
                            color = actionColor, fontSize = 14.sp, fontWeight = FontWeight.Medium)
                        Spacer(modifier = Modifier.height(4.dp))
                        Text("Artifact: ${suggestion.microArtifact}",
                            color = EMOps_TextSecondary, fontSize = 13.sp)
                        Spacer(modifier = Modifier.height(12.dp))
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            Button(
                                onClick = {
                                    acceptedSuggestion = true
                                    frictionPoint = suggestion.actionDescription
                                    selectedAction = suggestion.dsaaAction.lowercase()
                                    microArtifact = suggestion.microArtifact
                                    expectedLeverage = suggestion.expectedLeverage
                                },
                                colors = ButtonDefaults.buttonColors(containerColor = EMOps_Secondary),
                                shape = RoundedCornerShape(8.dp)
                            ) { Text("Accept") }
                            OutlinedButton(
                                onClick = { /* modify */ },
                                shape = RoundedCornerShape(8.dp)
                            ) { Text("Modify", color = EMOps_TextSecondary) }
                            OutlinedButton(
                                onClick = { viewModel.loadSuggestion() },
                                shape = RoundedCornerShape(8.dp)
                            ) { Text("Skip", color = EMOps_TextSecondary) }
                        }
                    }
                }
            }

            // Divider
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                HorizontalDivider(modifier = Modifier.weight(1f), color = EMOps_SurfaceVariant)
                Text(" OR CHOOSE YOUR OWN ", color = EMOps_TextSecondary, fontSize = 12.sp)
                HorizontalDivider(modifier = Modifier.weight(1f), color = EMOps_SurfaceVariant)
            }

            // Friction Point
            OutlinedTextField(
                value = frictionPoint,
                onValueChange = { frictionPoint = it },
                label = { Text("Friction Point") },
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = EMOps_Primary,
                    unfocusedBorderColor = EMOps_SurfaceVariant,
                    focusedLabelColor = EMOps_Primary,
                    unfocusedLabelColor = EMOps_TextSecondary,
                    cursorColor = EMOps_Primary,
                    focusedTextColor = EMOps_Text,
                    unfocusedTextColor = EMOps_Text
                )
            )

            // DSAA Action Selection
            Text("DSAA Action:", color = EMOps_TextSecondary, fontWeight = FontWeight.Medium)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                data class DsaaOption(val key: String, val label: String, val color: androidx.compose.ui.graphics.Color)
                val options = listOf(
                    DsaaOption("delete", "Delete", DSAA_Delete),
                    DsaaOption("simplify", "Simplify", DSAA_Simplify),
                    DsaaOption("accelerate", "Accel", DSAA_Accelerate),
                    DsaaOption("automate", "Auto", DSAA_Automate)
                )
                options.forEach { option ->
                    FilterChip(
                        selected = selectedAction == option.key,
                        onClick = { selectedAction = option.key },
                        label = { Text(option.label, fontSize = 12.sp) },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = option.color.copy(alpha = 0.2f),
                            selectedLabelColor = option.color,
                            containerColor = EMOps_SurfaceVariant,
                            labelColor = EMOps_TextSecondary
                        ),
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            // Micro-Artifact
            OutlinedTextField(
                value = microArtifact,
                onValueChange = { microArtifact = it },
                label = { Text("Micro-Artifact") },
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = EMOps_Primary,
                    unfocusedBorderColor = EMOps_SurfaceVariant,
                    focusedLabelColor = EMOps_Primary,
                    unfocusedLabelColor = EMOps_TextSecondary,
                    cursorColor = EMOps_Primary,
                    focusedTextColor = EMOps_Text,
                    unfocusedTextColor = EMOps_Text
                )
            )

            // Expected Leverage
            OutlinedTextField(
                value = expectedLeverage,
                onValueChange = { expectedLeverage = it },
                label = { Text("Expected Leverage") },
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = EMOps_Primary,
                    unfocusedBorderColor = EMOps_SurfaceVariant,
                    focusedLabelColor = EMOps_Primary,
                    unfocusedLabelColor = EMOps_TextSecondary,
                    cursorColor = EMOps_Primary,
                    focusedTextColor = EMOps_Text,
                    unfocusedTextColor = EMOps_Text
                )
            )

            // Timer Button
            Button(
                onClick = {
                    if (uiState.timerRunning) viewModel.stopTimer() else viewModel.startTimer()
                },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (uiState.timerRunning) EMOps_Warning else EMOps_Primary
                ),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text(
                    if (uiState.timerRunning) "Stop Timer ($timerText)" else "Start 15-Min Timer",
                    fontWeight = FontWeight.SemiBold
                )
            }

            // Save Button
            Button(
                onClick = {
                    viewModel.logRitual(
                        frictionPoint = frictionPoint,
                        dsaaAction = selectedAction,
                        microArtifactType = null,
                        microArtifactDescription = microArtifact,
                        expectedLeverage = expectedLeverage,
                        aiSuggestionAccepted = acceptedSuggestion
                    )
                },
                modifier = Modifier.fillMaxWidth(),
                enabled = frictionPoint.isNotBlank() && selectedAction.isNotBlank(),
                colors = ButtonDefaults.buttonColors(containerColor = EMOps_Secondary),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text("Save & Complete Ritual", fontWeight = FontWeight.SemiBold,
                    color = EMOps_Background)
            }

            Spacer(modifier = Modifier.height(80.dp))
        }
    }
}
