<#############################################
Enter the information below from your environment.
#############################################>
​
$TenantID = "xxxxxxxx"
$ClientID = "xxxxxxxxxxxxxxx"
$ClientSecret = xxxxxxxxxxxxxx"
$TokenUrl = "https://login.microsoftonline.com/$TenantID/oauth2/V2.0/token"
$Scope = "https://graph.microsoft.com/.default"

$mailbox = "mailbox@domain.com"​​

<#######################
Generate a bearer token
#######################>
​
$TokenUrl = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"
​
$TokenRequestBody = @{
  client_id     = $ClientID
  client_secret = $ClientSecret
  scope         = "https://graph.microsoft.com/.default"
  grant_type    = "client_credentials"
}
​
$TokenResponse = Invoke-RestMethod -Uri $TokenUrl -Method POST -Body $TokenRequestBody -ContentType "application/x-www-form-urlencoded"
​
$SecretToken = $TokenResponse.access_token
$SecretToken
​
<#######################
API Call to send email via Microsoft Graph
#######################>
​
$apiquery = "https://graph.microsoft.com/v1.0/users/$mailbox/sendMail"
​
<#########################
Email content. Edit the Subject and Content.
#########################>

$emailBody = @{
    message = @{
        subject = "Meet for lunch?"
        body = @{
            contentType = "Text"
            content = "The new cafeteria is open."
        }
        toRecipients = @(@{ emailAddress = @{ address = "user1@email.local" } })
        ccRecipients = @(@{ emailAddress = @{ address = "user2@email.local" } })
    }
    saveToSentItems = $false
}
​
<###############################
Convert the email body to JSON
################################>
$emailBodyJson = $emailBody | ConvertTo-Json -Depth 10
​

<###############################
Define headers
################################>
$Headers = @{
  "Authorization" = "Bearer $($SecretToken)"
  "Content-type"  = "application/json"
}
​
<###############################
Send the email
################################>
$apicall = Invoke-RestMethod -Uri $apiquery -Method POST -Headers $Headers -Body $emailBodyJson
