package com.emops.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.emops.app.ui.theme.*

@Composable
fun ErrorBudgetIndicator(
    status: String,
    modifier: Modifier = Modifier
) {
    val color = when (status.lowercase()) {
        "healthy" -> Budget_Healthy
        "burning" -> Budget_Burning
        "exhausted" -> Budget_Exhausted
        else -> EMOps_TextSecondary
    }

    Text(
        text = status.uppercase(),
        color = color,
        fontSize = 12.sp,
        fontWeight = FontWeight.Bold,
        modifier = modifier
            .clip(RoundedCornerShape(4.dp))
            .background(color.copy(alpha = 0.15f))
            .padding(horizontal = 8.dp, vertical = 3.dp)
    )
}
