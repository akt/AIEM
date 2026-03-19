package com.emops.app.ui.screens.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
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
fun SettingsScreen(
    viewModel: SettingsViewModel = hiltViewModel(),
    onBack: () -> Unit = {},
    onLogout: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EMOps_Background)
    ) {
        TopAppBar(
            title = { Text("Settings", fontWeight = FontWeight.Bold, color = EMOps_Text) },
            navigationIcon = {
                IconButton(onClick = onBack) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back", tint = EMOps_Text)
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
            // Profile Section
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Profile", fontWeight = FontWeight.Bold, color = EMOps_Text, fontSize = 16.sp)
                    Spacer(modifier = Modifier.height(12.dp))
                    SettingsRow("Display Name", uiState.displayName.ifEmpty { "Engineering Manager" })
                    SettingsRow("Email", uiState.email.ifEmpty { "em@example.com" })
                    SettingsRow("Timezone", uiState.timezone)
                    SettingsRow("Role", "Engineering Manager")
                }
            }

            // DSAA Settings
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("DSAA Ritual", fontWeight = FontWeight.Bold, color = EMOps_Text, fontSize = 16.sp)
                    Spacer(modifier = Modifier.height(12.dp))
                    SettingsRow("Trigger Time", uiState.dsaaTriggerTime)
                    SettingsRow("Trigger Event", "Morning standup")
                    SettingsRow("Deep Work Target", "${uiState.deepWorkTarget}h/day")
                }
            }

            // Notification Settings
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Notifications", fontWeight = FontWeight.Bold, color = EMOps_Text, fontSize = 16.sp)
                    Spacer(modifier = Modifier.height(12.dp))
                    SettingsToggle("Daily DSAA Reminder", uiState.dailyDsaaReminder) {
                        viewModel.toggleNotification("dailyDsaa")
                    }
                    SettingsToggle("Weekly Fill Reminder", uiState.weeklyFillReminder) {
                        viewModel.toggleNotification("weeklyFill")
                    }
                    SettingsToggle("Deep Work Alert", uiState.deepWorkAlert) {
                        viewModel.toggleNotification("deepWork")
                    }
                    SettingsToggle("Scorecard Reminder", uiState.scorecardReminder) {
                        viewModel.toggleNotification("scorecard")
                    }
                }
            }

            // About
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("About", fontWeight = FontWeight.Bold, color = EMOps_Text, fontSize = 16.sp)
                    Spacer(modifier = Modifier.height(8.dp))
                    SettingsRow("Version", "1.0.0")
                    SettingsRow("Build", "EMOps Engineering Manager OS")
                }
            }

            // Logout
            Button(
                onClick = {
                    viewModel.logout()
                    onLogout()
                },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = EMOps_Error),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text("Sign Out", fontWeight = FontWeight.SemiBold)
            }

            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@Composable
fun SettingsRow(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(label, color = EMOps_TextSecondary, fontSize = 14.sp)
        Text(value, color = EMOps_Text, fontSize = 14.sp)
    }
}

@Composable
fun SettingsToggle(label: String, checked: Boolean, onToggle: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(label, color = EMOps_Text, fontSize = 14.sp)
        Switch(
            checked = checked,
            onCheckedChange = { onToggle() },
            colors = SwitchDefaults.colors(
                checkedThumbColor = EMOps_Primary,
                checkedTrackColor = EMOps_Primary.copy(alpha = 0.3f),
                uncheckedThumbColor = EMOps_TextSecondary,
                uncheckedTrackColor = EMOps_SurfaceVariant
            )
        )
    }
}
