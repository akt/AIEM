package com.emops.app.data.repository

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import com.emops.app.data.remote.ApiService
import com.emops.app.data.remote.AuthInterceptor
import com.emops.app.data.remote.dto.*
import com.emops.app.domain.model.AuthResponse
import com.emops.app.domain.model.User
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthRepository @Inject constructor(
    private val apiService: ApiService,
    private val dataStore: DataStore<Preferences>
) {
    companion object {
        val USER_ID_KEY = stringPreferencesKey("user_id")
        val USER_EMAIL_KEY = stringPreferencesKey("user_email")
        val USER_NAME_KEY = stringPreferencesKey("user_name")
        val REFRESH_TOKEN_KEY = stringPreferencesKey("refresh_token")
    }

    val isLoggedIn: Flow<Boolean> = dataStore.data.map { prefs ->
        prefs[AuthInterceptor.TOKEN_KEY] != null
    }

    val currentUserId: Flow<String?> = dataStore.data.map { prefs ->
        prefs[USER_ID_KEY]
    }

    suspend fun login(email: String, password: String): Result<AuthResponse> {
        return try {
            val response = apiService.login(LoginRequest(email, password))
            if (response.isSuccessful) {
                val body = response.body()!!
                saveAuth(body)
                Result.success(body.toDomain())
            } else {
                Result.failure(Exception("Login failed: ${response.code()}"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun register(email: String, password: String, displayName: String): Result<AuthResponse> {
        return try {
            val response = apiService.register(RegisterRequest(email, password, displayName))
            if (response.isSuccessful) {
                val body = response.body()!!
                saveAuth(body)
                Result.success(body.toDomain())
            } else {
                Result.failure(Exception("Registration failed: ${response.code()}"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun logout() {
        dataStore.edit { it.clear() }
    }

    suspend fun updatePushToken(token: String) {
        try {
            apiService.updatePushToken(PushTokenRequest(token))
        } catch (_: Exception) {}
    }

    private suspend fun saveAuth(auth: AuthResponseDto) {
        dataStore.edit { prefs ->
            prefs[AuthInterceptor.TOKEN_KEY] = auth.token
            prefs[REFRESH_TOKEN_KEY] = auth.refreshToken
            prefs[USER_ID_KEY] = auth.user.id
            prefs[USER_EMAIL_KEY] = auth.user.email
            prefs[USER_NAME_KEY] = auth.user.displayName
        }
    }

    private fun AuthResponseDto.toDomain() = AuthResponse(
        token = token,
        refreshToken = refreshToken,
        user = user.toDomain()
    )

    private fun UserDto.toDomain() = User(
        id = id,
        email = email,
        displayName = displayName,
        timezone = timezone,
        role = role,
        surfaces = surfaces,
        dsaaTriggerTime = dsaaTriggerTime ?: "09:00",
        dsaaTriggerEvent = dsaaTriggerEvent ?: "morning standup",
        deepWorkHoursTarget = deepWorkHoursTarget ?: 1.5
    )
}
