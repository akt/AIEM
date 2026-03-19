package com.emops.app.ui.screens.habits

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.emops.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HabitEditScreen(
    onBack: () -> Unit,
    onSave: (String, String, String) -> Unit
) {
    var name by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf("deep_work") }

    val categories = listOf("deep_work", "reliability", "delivery", "security",
        "ai_safety", "leadership", "health", "learning")

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EMOps_Background)
    ) {
        TopAppBar(
            title = { Text("New Habit", color = EMOps_Text) },
            navigationIcon = {
                IconButton(onClick = onBack) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back", tint = EMOps_Text)
                }
            },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = EMOps_Background)
        )

        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("Habit Name") },
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

            OutlinedTextField(
                value = description,
                onValueChange = { description = it },
                label = { Text("Description") },
                modifier = Modifier.fillMaxWidth(),
                minLines = 3,
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

            Text("Category", color = EMOps_TextSecondary, fontWeight = FontWeight.Medium)

            Column {
                categories.forEach { cat ->
                    Row(modifier = Modifier.fillMaxWidth()) {
                        RadioButton(
                            selected = selectedCategory == cat,
                            onClick = { selectedCategory = cat },
                            colors = RadioButtonDefaults.colors(
                                selectedColor = EMOps_Primary,
                                unselectedColor = EMOps_TextSecondary
                            )
                        )
                        Text(
                            cat.replace("_", " ").uppercase(),
                            color = EMOps_Text,
                            modifier = Modifier.padding(start = 4.dp, top = 12.dp)
                        )
                    }
                }
            }

            Button(
                onClick = { onSave(name, description, selectedCategory) },
                modifier = Modifier.fillMaxWidth(),
                enabled = name.isNotBlank(),
                colors = ButtonDefaults.buttonColors(containerColor = EMOps_Primary),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text("Save Habit", fontWeight = FontWeight.SemiBold)
            }
        }
    }
}
