package com.emops.app.ui.screens.trends

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.emops.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TrendsScreen(
    viewModel: TrendsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EMOps_Background)
    ) {
        TopAppBar(
            title = { Text("Trends & Analytics", fontWeight = FontWeight.Bold, color = EMOps_Text) },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = EMOps_Background)
        )

        // Period Selector
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            viewModel.periods.forEach { period ->
                FilterChip(
                    selected = uiState.selectedPeriod == period,
                    onClick = { viewModel.selectPeriod(period) },
                    label = { Text(period) },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = EMOps_Primary.copy(alpha = 0.2f),
                        selectedLabelColor = EMOps_Primary,
                        containerColor = EMOps_SurfaceVariant,
                        labelColor = EMOps_TextSecondary
                    )
                )
            }
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Deep Work Hours Chart
            ChartCard(
                title = "Deep Work Hours",
                color = EMOps_Primary,
                values = uiState.trends.map { it.deepWorkHoursTotal.toFloat() },
                targetLine = 7.5f
            )

            // Habit Completion Rate
            ChartCard(
                title = "Habit Completion Rate",
                color = EMOps_Secondary,
                values = uiState.trends.map { it.habitsCompletionRate.toFloat() },
                isPercentage = true
            )

            // DSAA Distribution
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("DSAA Distribution", fontWeight = FontWeight.Bold,
                        color = EMOps_Text, fontSize = 16.sp)
                    Spacer(modifier = Modifier.height(12.dp))

                    // Placeholder pie chart as colored bars
                    val dsaaData = listOf(
                        "Delete" to DSAA_Delete to 25f,
                        "Simplify" to DSAA_Simplify to 35f,
                        "Accelerate" to DSAA_Accelerate to 25f,
                        "Automate" to DSAA_Automate to 15f
                    )

                    dsaaData.forEach { (labelColor, pct) ->
                        val (label, color) = labelColor
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(label, color = color, fontSize = 12.sp,
                                modifier = Modifier.width(80.dp))
                            LinearProgressIndicator(
                                progress = { pct / 100f },
                                modifier = Modifier
                                    .weight(1f)
                                    .height(12.dp),
                                color = color,
                                trackColor = EMOps_SurfaceVariant,
                            )
                            Text("${pct.toInt()}%", color = EMOps_TextSecondary,
                                fontSize = 12.sp, modifier = Modifier.padding(start = 8.dp))
                        }
                    }
                }
            }

            // Outcome Completion
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Outcome Completion", fontWeight = FontWeight.Bold,
                        color = EMOps_Text, fontSize = 16.sp)
                    Spacer(modifier = Modifier.height(12.dp))
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceEvenly
                    ) {
                        uiState.trends.takeLast(3).forEach { trend ->
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text("${trend.outcomesCompleted}/${trend.outcomesTotal}",
                                    color = EMOps_Secondary, fontWeight = FontWeight.Bold)
                                Text(trend.weekStart.takeLast(5),
                                    color = EMOps_TextSecondary, fontSize = 11.sp)
                            }
                        }
                    }
                }
            }

            // AI Trend Insight
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_SurfaceVariant)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("AI Trend Insight", color = EMOps_Primary,
                        fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        uiState.aiInsight ?: "Your Simplify actions are yielding 2x more leverage than Automate. Consider leaning into simplification this quarter.",
                        color = EMOps_Text, fontSize = 14.sp, lineHeight = 20.sp
                    )
                }
            }

            Spacer(modifier = Modifier.height(80.dp))
        }
    }
}

@Composable
fun ChartCard(
    title: String,
    color: Color,
    values: List<Float>,
    targetLine: Float? = null,
    isPercentage: Boolean = false
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(title, fontWeight = FontWeight.Bold, color = EMOps_Text, fontSize = 16.sp)
            Spacer(modifier = Modifier.height(12.dp))

            if (values.isEmpty()) {
                Text("No data available", color = EMOps_TextSecondary, fontSize = 13.sp)
            } else {
                val maxVal = (values.maxOrNull() ?: 1f).coerceAtLeast(targetLine ?: 1f) * 1.2f
                Canvas(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(120.dp)
                ) {
                    val width = size.width
                    val height = size.height
                    val stepX = if (values.size > 1) width / (values.size - 1) else width

                    // Target line
                    targetLine?.let { target ->
                        val y = height - (target / maxVal * height)
                        drawLine(
                            color = EMOps_Warning.copy(alpha = 0.5f),
                            start = Offset(0f, y),
                            end = Offset(width, y),
                            strokeWidth = 2f
                        )
                    }

                    // Data line
                    if (values.size > 1) {
                        val path = Path()
                        values.forEachIndexed { index, value ->
                            val x = index * stepX
                            val y = height - (value / maxVal * height)
                            if (index == 0) path.moveTo(x, y) else path.lineTo(x, y)
                        }
                        drawPath(path, color = color, style = Stroke(width = 3f))

                        // Data points
                        values.forEachIndexed { index, value ->
                            val x = index * stepX
                            val y = height - (value / maxVal * height)
                            drawCircle(color = color, radius = 4f, center = Offset(x, y))
                        }
                    }
                }

                // Legend
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 8.dp),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    val suffix = if (isPercentage) "%" else ""
                    Text(
                        "Min: ${values.minOrNull()?.let { "%.1f$suffix".format(it) } ?: "-"}",
                        color = EMOps_TextSecondary, fontSize = 11.sp
                    )
                    Text(
                        "Avg: ${values.average().let { "%.1f$suffix".format(it) }}",
                        color = EMOps_TextSecondary, fontSize = 11.sp
                    )
                    Text(
                        "Max: ${values.maxOrNull()?.let { "%.1f$suffix".format(it) } ?: "-"}",
                        color = EMOps_TextSecondary, fontSize = 11.sp
                    )
                }
            }
        }
    }
}
