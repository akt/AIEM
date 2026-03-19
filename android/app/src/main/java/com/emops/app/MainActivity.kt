package com.emops.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.*
import androidx.hilt.navigation.compose.hiltViewModel
import com.emops.app.ui.navigation.EMOpsNavGraph
import com.emops.app.ui.screens.auth.AuthViewModel
import com.emops.app.ui.screens.auth.LoginScreen
import com.emops.app.ui.theme.EMOpsTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            EMOpsTheme {
                val authViewModel: AuthViewModel = hiltViewModel()
                val authState by authViewModel.uiState.collectAsState()

                if (authState.isLoggedIn) {
                    EMOpsNavGraph()
                } else {
                    LoginScreen(
                        viewModel = authViewModel,
                        onLoginSuccess = { /* state updates automatically */ }
                    )
                }
            }
        }
    }
}
