package com.emops.app.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.emops.app.ui.theme.*

@Composable
fun ScorecardChart(
    values: List<Pair<String, Float>>,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier) {
        values.forEach { (label, value) ->
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp)
            ) {
                Text(label, color = EMOps_TextSecondary, fontSize = 12.sp,
                    modifier = Modifier.width(100.dp))
                Canvas(
                    modifier = Modifier
                        .weight(1f)
                        .height(16.dp)
                ) {
                    drawRect(
                        color = EMOps_SurfaceVariant,
                        size = Size(size.width, size.height)
                    )
                    drawRect(
                        color = EMOps_Primary,
                        size = Size(size.width * value.coerceIn(0f, 1f), size.height)
                    )
                }
            }
        }
    }
}
