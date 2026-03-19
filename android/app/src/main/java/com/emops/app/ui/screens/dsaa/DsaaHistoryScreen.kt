package com.emops.app.ui.screens.dsaa

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.emops.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DsaaHistoryScreen(
    viewModel: DsaaViewModel = hiltViewModel(),
    onBack: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(Unit) { viewModel.loadHistory() }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EMOps_Background)
    ) {
        TopAppBar(
            title = { Text("DSAA History", color = EMOps_Text) },
            navigationIcon = {
                IconButton(onClick = onBack) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back", tint = EMOps_Text)
                }
            },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = EMOps_Background)
        )

        LazyColumn(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(uiState.history) { log ->
                val actionColor = when (log.dsaaAction) {
                    "delete" -> DSAA_Delete
                    "simplify" -> DSAA_Simplify
                    "accelerate" -> DSAA_Accelerate
                    "automate" -> DSAA_Automate
                    else -> EMOps_Primary
                }
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
                ) {
                    Column(modifier = Modifier.padding(12.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(log.dsaaAction.uppercase(), color = actionColor,
                                fontWeight = FontWeight.Bold, fontSize = 14.sp)
                            Text(log.logDate, color = EMOps_TextSecondary, fontSize = 12.sp)
                        }
                        Text(log.frictionPoint, color = EMOps_Text, fontSize = 14.sp,
                            modifier = Modifier.padding(top = 4.dp))
                        log.microArtifactDescription?.let {
                            Text("Artifact: $it", color = EMOps_TextSecondary, fontSize = 12.sp,
                                modifier = Modifier.padding(top = 4.dp))
                        }
                    }
                }
            }
        }
    }
}
