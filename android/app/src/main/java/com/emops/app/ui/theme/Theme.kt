package com.emops.app.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val EMOpsDarkColorScheme = darkColorScheme(
    primary = EMOps_Primary,
    secondary = EMOps_Secondary,
    tertiary = EMOps_Warning,
    background = EMOps_Background,
    surface = EMOps_Surface,
    surfaceVariant = EMOps_SurfaceVariant,
    error = EMOps_Error,
    onPrimary = EMOps_Text,
    onSecondary = EMOps_Background,
    onTertiary = EMOps_Background,
    onBackground = EMOps_Text,
    onSurface = EMOps_Text,
    onSurfaceVariant = EMOps_TextSecondary,
    onError = EMOps_Text
)

@Composable
fun EMOpsTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = EMOpsDarkColorScheme,
        typography = EMOpsTypography,
        content = content
    )
}
