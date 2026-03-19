package com.emops.app.ui.screens.onboarding

import androidx.compose.animation.AnimatedContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OnboardingScreen(
    onComplete: (OnboardingConfig) -> Unit
) {
    var currentStep by remember { mutableIntStateOf(0) }
    var timezone by remember { mutableStateOf("Indian/Maldives") }
    var selectedSurfaces by remember { mutableStateOf(setOf("Web3/DEX", "Exchange")) }
    var dsaaTriggerTime by remember { mutableStateOf("09:00") }
    var notifyDailyDsaa by remember { mutableStateOf(true) }
    var notifyWeeklyFill by remember { mutableStateOf(true) }
    var notifyDeepWork by remember { mutableStateOf(true) }
    var notifyScorecard by remember { mutableStateOf(true) }

    val totalSteps = 4
    val allSurfaces = listOf("Web3/DEX", "Exchange", "Fiat On/Off Ramp", "Crypto Pay", "AI Platform/Agents")

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Setup EMOps") },
                actions = {
                    if (currentStep > 0) {
                        TextButton(onClick = {
                            onComplete(OnboardingConfig(timezone, selectedSurfaces, dsaaTriggerTime,
                                notifyDailyDsaa, notifyWeeklyFill, notifyDeepWork, notifyScorecard))
                        }) {
                            Text("Skip")
                        }
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Progress indicator
            LinearProgressIndicator(
                progress = { (currentStep + 1).toFloat() / totalSteps },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 16.dp)
            )

            Text(
                "Step ${currentStep + 1} of $totalSteps",
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(modifier = Modifier.height(24.dp))

            AnimatedContent(targetState = currentStep, label = "onboarding") { step ->
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f)
                        .verticalScroll(rememberScrollState()),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    when (step) {
                        0 -> WelcomeStep()
                        1 -> TimezoneStep(timezone) { timezone = it }
                        2 -> SurfacesStep(allSurfaces, selectedSurfaces) { selectedSurfaces = it }
                        3 -> NotificationsStep(
                            dsaaTriggerTime, notifyDailyDsaa, notifyWeeklyFill, notifyDeepWork, notifyScorecard,
                            onTimeChange = { dsaaTriggerTime = it },
                            onDsaaToggle = { notifyDailyDsaa = it },
                            onWeeklyToggle = { notifyWeeklyFill = it },
                            onDeepWorkToggle = { notifyDeepWork = it },
                            onScorecardToggle = { notifyScorecard = it }
                        )
                    }
                }
            }

            // Navigation buttons
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 24.dp),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                if (currentStep > 0) {
                    OutlinedButton(onClick = { currentStep-- }) {
                        Text("Back")
                    }
                } else {
                    Spacer(modifier = Modifier.width(1.dp))
                }

                Button(
                    onClick = {
                        if (currentStep < totalSteps - 1) {
                            currentStep++
                        } else {
                            onComplete(OnboardingConfig(timezone, selectedSurfaces, dsaaTriggerTime,
                                notifyDailyDsaa, notifyWeeklyFill, notifyDeepWork, notifyScorecard))
                        }
                    }
                ) {
                    Text(if (currentStep == totalSteps - 1) "Get Started" else "Next")
                }
            }
        }
    }
}

@Composable
private fun WelcomeStep() {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Icon(
            Icons.Default.Rocket,
            contentDescription = null,
            modifier = Modifier.size(80.dp),
            tint = MaterialTheme.colorScheme.primary
        )
        Spacer(modifier = Modifier.height(24.dp))
        Text(
            "Welcome to EMOps",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            "Your Engineering Manager Weekly Operating System.\nLet's set up your workspace.",
            style = MaterialTheme.typography.bodyLarge,
            textAlign = TextAlign.Center,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun TimezoneStep(timezone: String, onTimezoneChange: (String) -> Unit) {
    val timezones = listOf(
        "Indian/Maldives" to "Maldives (UTC+5)",
        "Asia/Kolkata" to "India (UTC+5:30)",
        "America/New_York" to "US Eastern (UTC-5)",
        "America/Los_Angeles" to "US Pacific (UTC-8)",
        "Europe/London" to "UK (UTC+0)",
        "Asia/Singapore" to "Singapore (UTC+8)",
        "Asia/Dubai" to "Dubai (UTC+4)"
    )

    Column {
        Text("Select Your Timezone", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(8.dp))
        Text("This determines when your reminders and DSAA ritual fire.", style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(modifier = Modifier.height(16.dp))

        timezones.forEach { (tz, label) ->
            Card(
                onClick = { onTimezoneChange(tz) },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp),
                colors = CardDefaults.cardColors(
                    containerColor = if (timezone == tz) MaterialTheme.colorScheme.primaryContainer
                    else MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    RadioButton(selected = timezone == tz, onClick = { onTimezoneChange(tz) })
                    Spacer(modifier = Modifier.width(12.dp))
                    Text(label, style = MaterialTheme.typography.bodyLarge)
                }
            }
        }
    }
}

@Composable
private fun SurfacesStep(
    allSurfaces: List<String>,
    selectedSurfaces: Set<String>,
    onSurfacesChange: (Set<String>) -> Unit
) {
    Column {
        Text("Your Product Surfaces", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(8.dp))
        Text("Select the surfaces you own or contribute to.", style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(modifier = Modifier.height(16.dp))

        allSurfaces.forEach { surface ->
            val isSelected = surface in selectedSurfaces
            Card(
                onClick = {
                    onSurfacesChange(
                        if (isSelected) selectedSurfaces - surface else selectedSurfaces + surface
                    )
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp),
                colors = CardDefaults.cardColors(
                    containerColor = if (isSelected) MaterialTheme.colorScheme.primaryContainer
                    else MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(checked = isSelected, onCheckedChange = {
                        onSurfacesChange(
                            if (isSelected) selectedSurfaces - surface else selectedSurfaces + surface
                        )
                    })
                    Spacer(modifier = Modifier.width(12.dp))
                    Text(surface, style = MaterialTheme.typography.bodyLarge)
                }
            }
        }
    }
}

@Composable
private fun NotificationsStep(
    dsaaTriggerTime: String,
    notifyDailyDsaa: Boolean,
    notifyWeeklyFill: Boolean,
    notifyDeepWork: Boolean,
    notifyScorecard: Boolean,
    onTimeChange: (String) -> Unit,
    onDsaaToggle: (Boolean) -> Unit,
    onWeeklyToggle: (Boolean) -> Unit,
    onDeepWorkToggle: (Boolean) -> Unit,
    onScorecardToggle: (Boolean) -> Unit
) {
    Column {
        Text("Notifications & DSAA", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(8.dp))
        Text("Configure your daily DSAA ritual time and notification preferences.", style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(modifier = Modifier.height(16.dp))

        OutlinedCard(modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("DSAA Trigger Time", style = MaterialTheme.typography.titleSmall)
                Spacer(modifier = Modifier.height(8.dp))
                OutlinedTextField(
                    value = dsaaTriggerTime,
                    onValueChange = onTimeChange,
                    label = { Text("Time (HH:MM)") },
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedCard(modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("Notifications", style = MaterialTheme.typography.titleSmall)
                Spacer(modifier = Modifier.height(8.dp))

                NotificationToggle("Daily DSAA Reminder", notifyDailyDsaa, onDsaaToggle)
                NotificationToggle("Weekly Sheet Fill Reminder", notifyWeeklyFill, onWeeklyToggle)
                NotificationToggle("Deep Work Start Alert", notifyDeepWork, onDeepWorkToggle)
                NotificationToggle("Friday Scorecard Reminder", notifyScorecard, onScorecardToggle)
            }
        }
    }
}

@Composable
private fun NotificationToggle(label: String, checked: Boolean, onToggle: (Boolean) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(label, style = MaterialTheme.typography.bodyMedium)
        Switch(checked = checked, onCheckedChange = onToggle)
    }
}

data class OnboardingConfig(
    val timezone: String,
    val selectedSurfaces: Set<String>,
    val dsaaTriggerTime: String,
    val notifyDailyDsaa: Boolean,
    val notifyWeeklyFill: Boolean,
    val notifyDeepWork: Boolean,
    val notifyScorecard: Boolean
)
