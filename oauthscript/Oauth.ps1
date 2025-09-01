# ================================
# Step 1: User signs in and grants consent
# ================================
# Replace with your values
$clientId     = "xxxxxxxxxxxxxxx"
$clientSecret = "xxxxxxxxxxxxxxxxxxxxxxx"   # Only needed for confidential apps (web/API)
$redirectUri  = "http://localhost" # Must match a registered redirect URI



# Define the scopes you need
$scopes = "User.Read Mail.Send Calendars.Read Calendars.ReadWrite offline_access"



# Build the authorize URL
$authUrl = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&response_mode=query&scope=$($scopes -replace ' ', '%20')&state=12345"



Write-Host "Open this URL in your browser to sign in and consent:"
Write-Host $authUrl



# ================================
# Step 2: Paste the authorization code from redirect URI
# ================================
$code = Read-Host "Paste the 'code' parameter you received in the redirect URI"



# ================================
# Step 3: Exchange code for tokens
# ================================
$tokenUrl = "https://login.microsoftonline.com/common/oauth2/v2.0/token"



$tokenRequestBody = @{
    client_id     = $clientId
    client_secret = $clientSecret   # Only include if app type is confidential
    grant_type    = "authorization_code"
    code          = $code
    redirect_uri  = $redirectUri
    scope         = $scopes
}



$tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $tokenRequestBody -ContentType "application/x-www-form-urlencoded"



$accessToken  = $tokenResponse.access_token
$refreshToken = $tokenResponse.refresh_token



Write-Host "`nAccess Token:`n$accessToken"
Write-Host "`nRefresh Token:`n$refreshToken"
