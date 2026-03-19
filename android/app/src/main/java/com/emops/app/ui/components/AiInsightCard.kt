package com.emops.app.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.emops.app.ui.theme.*

@Composable
fun AiInsightCard(
    title: String,
    content: String,
    accentColor: Color = EMOps_Primary,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = EMOps_SurfaceVariant)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(title, color = accentColor, fontWeight = FontWeight.Bold, fontSize = 16.sp)
            Spacer(modifier = Modifier.height(8.dp))
            Text(content, color = EMOps_Text, fontSize = 14.sp, lineHeight = 20.sp)
        }
    }
}
