package com.emops.app.ui.screens.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.emops.app.ui.theme.*

@Composable
fun LoginScreen(
    viewModel: AuthViewModel = hiltViewModel(),
    onLoginSuccess: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()

    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var displayName by remember { mutableStateOf("") }

    LaunchedEffect(uiState.isLoggedIn) {
        if (uiState.isLoggedIn) onLoginSuccess()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(EMOps_Background),
        contentAlignment = Alignment.Center
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "EMOps",
                fontSize = 36.sp,
                fontWeight = FontWeight.Bold,
                color = EMOps_Primary
            )
            Text(
                text = "Engineering Manager OS",
                fontSize = 14.sp,
                color = EMOps_TextSecondary,
                modifier = Modifier.padding(bottom = 48.dp)
            )

            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EMOps_Surface)
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    Text(
                        text = if (uiState.isLoginMode) "Sign In" else "Create Account",
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold,
                        color = EMOps_Text
                    )

                    if (!uiState.isLoginMode) {
                        OutlinedTextField(
                            value = displayName,
                            onValueChange = { displayName = it },
                            label = { Text("Display Name") },
                            modifier = Modifier.fillMaxWidth(),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = EMOps_Primary,
                                unfocusedBorderColor = EMOps_SurfaceVariant,
                                focusedLabelColor = EMOps_Primary,
                                unfocusedLabelColor = EMOps_TextSecondary,
                                cursorColor = EMOps_Primary,
                                focusedTextColor = EMOps_Text,
                                unfocusedTextColor = EMOps_Text
                            ),
                            singleLine = true
                        )
                    }

                    OutlinedTextField(
                        value = email,
                        onValueChange = { email = it },
                        label = { Text("Email") },
                        modifier = Modifier.fillMaxWidth(),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = EMOps_Primary,
                            unfocusedBorderColor = EMOps_SurfaceVariant,
                            focusedLabelColor = EMOps_Primary,
                            unfocusedLabelColor = EMOps_TextSecondary,
                            cursorColor = EMOps_Primary,
                            focusedTextColor = EMOps_Text,
                            unfocusedTextColor = EMOps_Text
                        ),
                        singleLine = true
                    )

                    OutlinedTextField(
                        value = password,
                        onValueChange = { password = it },
                        label = { Text("Password") },
                        modifier = Modifier.fillMaxWidth(),
                        visualTransformation = PasswordVisualTransformation(),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = EMOps_Primary,
                            unfocusedBorderColor = EMOps_SurfaceVariant,
                            focusedLabelColor = EMOps_Primary,
                            unfocusedLabelColor = EMOps_TextSecondary,
                            cursorColor = EMOps_Primary,
                            focusedTextColor = EMOps_Text,
                            unfocusedTextColor = EMOps_Text
                        ),
                        singleLine = true
                    )

                    uiState.error?.let { error ->
                        Text(
                            text = error,
                            color = EMOps_Error,
                            fontSize = 13.sp
                        )
                    }

                    Button(
                        onClick = {
                            if (uiState.isLoginMode) {
                                viewModel.login(email, password)
                            } else {
                                viewModel.register(email, password, displayName)
                            }
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(50.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = EMOps_Primary),
                        shape = RoundedCornerShape(12.dp),
                        enabled = !uiState.isLoading && email.isNotBlank() && password.isNotBlank()
                    ) {
                        if (uiState.isLoading) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(20.dp),
                                color = EMOps_Text,
                                strokeWidth = 2.dp
                            )
                        } else {
                            Text(
                                text = if (uiState.isLoginMode) "Sign In" else "Create Account",
                                fontWeight = FontWeight.SemiBold
                            )
                        }
                    }

                    TextButton(
                        onClick = { viewModel.toggleMode() },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(
                            text = if (uiState.isLoginMode)
                                "Don't have an account? Sign up"
                            else
                                "Already have an account? Sign in",
                            color = EMOps_Primary
                        )
                    }
                }
            }
        }
    }
}
