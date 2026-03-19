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
fun IdentitySection(sheet: WeeklySheet?) {
    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Text("Week Identity", fontWeight = FontWeight.Bold, color = EMOps_Text, fontSize = 18.sp)

        SectionTextField("Surfaces in Scope", sheet?.surfacesInScope?.joinToString(", ") ?: "")
        SectionTextField("On-Call Ownership", sheet?.oncallOwnership ?: "")
        SectionTextField("Key Dependencies", sheet?.keyDependencies ?: "")
        SectionTextField("Non-Negotiable Constraints", sheet?.nonNegotiableConstraints ?: "")
    }
}

@Composable
fun SectionTextField(label: String, initialValue: String) {
    var value by remember(initialValue) { mutableStateOf(initialValue) }

    OutlinedTextField(
        value = value,
        onValueChange = { value = it },
        label = { Text(label) },
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
}
