$TenantID = "xxxxxxxxxxxxxxxxxxxxxx"
$ClientID = "xxxxxxxxxxxxxxxxxxxxxxxxxxx"
$ClientSecret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$TokenUrl = "https://login.microsoftonline.com/$TenantID/oauth2/V2.0/token"
$Scope = "https://graph.microsoft.com/.default"
$domainname = "domain.com"

$mailbox = "info@domain.com"

# Define the password expiry threshold in days
$PasswordExpiryThreshold = 90
$NotificationThreshold = 14

#######################
# Generate a bearer token
#######################

$TokenUrl = "https://login.microsoftonline.com/$domainname/oauth2/v2.0/token"

$TokenRequestBody = @{
  client_id     = $ClientID
  client_secret = $ClientSecret
  scope         = "https://graph.microsoft.com/.default"
  grant_type    = "client_credentials"
}

$TokenResponse = Invoke-RestMethod -Uri $TokenUrl -Method POST -Body $TokenRequestBody -ContentType "application/x-www-form-urlencoded"



# Store the token properly
$SecretToken = $TokenResponse.access_token
$SecretToken



############################################
# Get all users with their password policies and last password change date
$users = Get-MgUser -All -Property UserPrincipalName, PasswordPolicies, LastPasswordChangeDateTime

# Initialize an array to store users with soon-to-expire passwords
$soonToExpireUsers = @()

# Loop through each user to calculate the password expiration date
foreach ($user in $users) {
    if ($user.PasswordPolicies -notcontains "DisablePasswordExpiration" -and $user.LastPasswordChangeDateTime -ne $null) {
        $passwordExpiryDate = $user.LastPasswordChangeDateTime.AddDays($PasswordExpiryThreshold)
        $remainingDays = ($passwordExpiryDate - (Get-Date)).Days
        if ($remainingDays -le $NotificationThreshold) {
            $soonToExpireUsers += [PSCustomObject]@{
                UserPrincipalName = $user.UserPrincipalName
                PasswordExpiryDate = $passwordExpiryDate
                RemainingDays = $remainingDays
            }
        }
    }
}

# Display the users with soon-to-expire passwords
$soonToExpireUsers | Select-Object UserPrincipalName, PasswordExpiryDate, RemainingDays

# Email users with soon-to-expire passwords
$Headers = @{
    "Authorization" = "Bearer $($secretToken)"
    "Content-type"  = "application/json"
}

foreach ($user in $soonToExpireUsers) {
    $EmailBody = "
        Hello $($user.UserPrincipalName),
        <br/><br/>
        Your Office 365 password will expire in $($user.RemainingDays) days. Please change your password before it expires to avoid any disruption in accessing your account.
        <br/><br/>
        To change your password, follow these steps:<br/>
        <ol>
        <li>Sign in to Office 365 (https://www.office.com)</li>
        <li>Click on your profile picture in the top right corner.</li>
        <li>Select 'View account'.</li>
        <li>Click 'Password'.</li>
        <li>Follow the instructions to change your password.</li>
        </ol>
        <br/>
        Thank you,<br/>
        IT Support Team
    "

    $MailParams = @{
        message = @{
            subject = "Your Office 365 password will expire soon"
            importance = "High"
            body = @{
                contentType = "html"
                content = $EmailBody
            }
            toRecipients = @(@{ emailAddress = @{ address = $user.UserPrincipalName } })
        }
        saveToSentItems = $false
    }

    $apiquery = "https://graph.microsoft.com/v1.0/users/$mailbox/sendMail"
    $emailBodyJson = $MailParams | ConvertTo-Json -Depth 10
    $apicall = Invoke-RestMethod -Uri $apiquery -Method POST -Headers $Headers -Body $emailBodyJson
    Write-output "Emailing $($user.UserPrincipalName)"
}

