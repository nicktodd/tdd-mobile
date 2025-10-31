//  Simulate timeout
coEvery { mockSwapiService.getCharacters(any()) } throws SocketTimeoutException("Connection timed out")

//  Simulate no internet
coEvery { mockSwapiService.getCharacters(any()) } throws UnknownHostException("Unable to resolve host")

//  Simulate network error
coEvery { mockSwapiService.getCharacters(any()) } throws IOException("Network connection lost")

//  Simulate 404 error
val mockResponse = mockk<Response<CharacterResponse>>()
coEvery { mockResponse.code() } returns 404
coEvery { mockResponse.message() } returns "Not Found"

//  Simulate 500 error
val mockResponse = mockk<Response<CharacterResponse>>()
coEvery { mockResponse.code() } returns 500
coEvery { mockResponse.message() } returns "Internal Server Error"

//  Simulate malformed JSON
coEvery { mockSwapiService.getCharacters(any()) } throws com.google.gson.JsonSyntaxException("Malformed JSON")


try {
    val user = api.getUser()
    showUser(user)
} catch (e: UserNotFoundException) {
    showError("User not found")
}

// ✅ Prefer
val result = api.getUser()
when (result) {
    is Result.Success -> showUser(result.value)
    is Result.Failure -> showError(result.error.message)
}
sealed class LoginResult {
    data class Success(val user: User) : LoginResult()
    data class InvalidCredentials(val message: String) : LoginResult()
    object NetworkError : LoginResult()
}

val result = login("wrongUser", "wrongPass")
assertTrue(result is LoginResult.InvalidCredentials)

fun login(username: String, password: String): String {
    return if (username == "admin" && password == "1234") {
        "SUCCESS"
    } else {
        "ERROR"
    }
}

when (val result = login("admin", "wrongpass")) {
    is LoginResult.Success -> showWelcome(result.user)
    is LoginResult.InvalidCredentials -> showError("Invalid login")
    is LoginResult.NetworkError -> showError("Please check your connection")
}