package com.emops.app.ui.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.*
import com.emops.app.ui.screens.ai.AiCoachScreen
import com.emops.app.ui.screens.dashboard.DashboardScreen
import com.emops.app.ui.screens.dsaa.DsaaRitualScreen
import com.emops.app.ui.screens.habits.HabitsScreen
import com.emops.app.ui.screens.settings.SettingsScreen
import com.emops.app.ui.screens.trends.TrendsScreen
import com.emops.app.ui.screens.weekly.WeeklySheetScreen
import com.emops.app.ui.theme.*

sealed class Screen(val route: String, val title: String, val icon: ImageVector, val selectedIcon: ImageVector) {
    data object Home : Screen("home", "Home", Icons.Outlined.Home, Icons.Filled.Home)
    data object Sheet : Screen("sheet", "Sheet", Icons.Outlined.Description, Icons.Filled.Description)
    data object Habits : Screen("habits", "Habits", Icons.Outlined.CheckCircle, Icons.Filled.CheckCircle)
    data object Trends : Screen("trends", "Trends", Icons.Outlined.TrendingUp, Icons.Filled.TrendingUp)
    data object AI : Screen("ai", "AI", Icons.Outlined.Psychology, Icons.Filled.Psychology)
}

sealed class SubScreen(val route: String) {
    data object Settings : SubScreen("settings")
    data object DsaaRitual : SubScreen("dsaa_ritual")
}

@Composable
fun EMOpsNavGraph() {
    val navController = rememberNavController()
    val bottomScreens = listOf(Screen.Home, Screen.Sheet, Screen.Habits, Screen.Trends, Screen.AI)

    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination
    val showBottomBar = bottomScreens.any { it.route == currentDestination?.route }

    Scaffold(
        containerColor = EMOps_Background,
        bottomBar = {
            if (showBottomBar) {
                NavigationBar(
                    containerColor = EMOps_Surface,
                    contentColor = EMOps_Text
                ) {
                    bottomScreens.forEach { screen ->
                        val selected = currentDestination?.hierarchy?.any { it.route == screen.route } == true
                        NavigationBarItem(
                            icon = {
                                Icon(
                                    if (selected) screen.selectedIcon else screen.icon,
                                    contentDescription = screen.title
                                )
                            },
                            label = {
                                Text(
                                    screen.title,
                                    fontSize = 11.sp,
                                    fontWeight = if (selected) FontWeight.Bold else FontWeight.Normal
                                )
                            },
                            selected = selected,
                            onClick = {
                                navController.navigate(screen.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = EMOps_Primary,
                                selectedTextColor = EMOps_Primary,
                                unselectedIconColor = EMOps_TextSecondary,
                                unselectedTextColor = EMOps_TextSecondary,
                                indicatorColor = EMOps_Primary.copy(alpha = 0.1f)
                            )
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Home.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.Home.route) {
                DashboardScreen(
                    onNavigateToSettings = { navController.navigate(SubScreen.Settings.route) }
                )
            }
            composable(Screen.Sheet.route) {
                WeeklySheetScreen()
            }
            composable(Screen.Habits.route) {
                HabitsScreen()
            }
            composable(Screen.Trends.route) {
                TrendsScreen()
            }
            composable(Screen.AI.route) {
                AiCoachScreen()
            }
            composable(SubScreen.Settings.route) {
                SettingsScreen(
                    onBack = { navController.popBackStack() },
                    onLogout = {
                        navController.navigate(Screen.Home.route) {
                            popUpTo(0) { inclusive = true }
                        }
                    }
                )
            }
            composable(SubScreen.DsaaRitual.route) {
                DsaaRitualScreen()
            }
        }
    }
}
