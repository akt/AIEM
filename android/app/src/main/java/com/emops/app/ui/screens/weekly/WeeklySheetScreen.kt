package com.emops.app.ui.screens.weekly

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
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
fun WeeklySheetScreen(
    viewModel: WeeklySheetViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EMOps_Background)
    ) {
        TopAppBar(
            title = {
                Column {
                    Text("Weekly Sheet", fontWeight = FontWeight.Bold, color = EMOps_Text)
                    Text(
                        uiState.sheet?.weekLabel ?: "",
                        color = EMOps_TextSecondary,
                        fontSize = 12.sp
                    )
                }
            },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = EMOps_Background)
        )

        // Tab Row
        ScrollableTabRow(
            selectedTabIndex = uiState.selectedTab,
            containerColor = EMOps_Background,
            contentColor = EMOps_Primary,
            edgePadding = 8.dp,
            indicator = { tabPositions ->
                if (uiState.selectedTab < tabPositions.size) {
                    TabRowDefaults.SecondaryIndicator(
                        Modifier.tabIndicatorOffset(tabPositions[uiState.selectedTab]),
                        color = EMOps_Primary
                    )
                }
            }
        ) {
            viewModel.tabs.forEachIndexed { index, title ->
                Tab(
                    selected = uiState.selectedTab == index,
                    onClick = { viewModel.selectTab(index) },
                    text = {
                        Text(
                            title,
                            color = if (uiState.selectedTab == index) EMOps_Primary else EMOps_TextSecondary,
                            fontSize = 13.sp
                        )
                    }
                )
            }
        }

        // Content
        if (uiState.isLoading) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = androidx.compose.ui.Alignment.Center
            ) {
                CircularProgressIndicator(color = EMOps_Primary)
            }
        } else {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(16.dp)
            ) {
                when (uiState.selectedTab) {
                    0 -> IdentitySection(uiState.sheet)
                    1 -> OutcomesSection(uiState.sheet)
                    2 -> ConstraintSection(uiState.sheet)
                    3 -> DsaaQueueSection(uiState.sheet)
                    4 -> AiPlanSection(uiState.sheet)
                    5 -> TimeBlocksSection(uiState.sheet)
                    6 -> ScorecardSection(uiState.sheet)
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Quick Actions
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text("Quick Actions", fontWeight = FontWeight.Bold,
                            color = EMOps_Text, fontSize = 16.sp)
                        OutlinedButton(
                            onClick = { viewModel.carryForward() },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(8.dp)
                        ) { Text("Carry forward items", color = EMOps_Primary) }
                        OutlinedButton(
                            onClick = { /* trigger AI summary */ },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(8.dp)
                        ) { Text("Generate AI summary", color = EMOps_Primary) }
                        Button(
                            onClick = { viewModel.completeWeek() },
                            modifier = Modifier.fillMaxWidth(),
                            colors = ButtonDefaults.buttonColors(containerColor = EMOps_Secondary),
                            shape = RoundedCornerShape(8.dp)
                        ) { Text("Complete this week", color = EMOps_Background) }
                    }
                }

                Spacer(modifier = Modifier.height(80.dp))
            }
        }
    }
}
