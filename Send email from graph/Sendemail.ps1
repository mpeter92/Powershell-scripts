<#############################################
Enter the information below from your environment.
#############################################>
​
$TenantID = "xxxxxxxx"
$ClientID = "xxxxxxxxxxxxxxx"
$ClientSecret = "xxxxxxxxxxxxxx"
$TokenUrl = "https://login.microsoftonline.com/$TenantID/oauth2/V2.0/token"
$Scope = "https://graph.microsoft.com/.default"

<#####################################
Enter the email address of the mailbox from which the email will be sent, 
the primary recipient's email address, 
the CC recipient's email address, 
the subject of the email, 
and the body content of the email.
#####################################>

$mailbox = "mailbox@domain.com"
$recipients = "user@domain.com"
$CCrecipients = "user@domain.com"
$emailsubject = " RE: Email subject"
$emailbodycontent = " This is the email body content "

<#######################
Generate a bearer token
#######################>

$TokenRequestBody = @{
  client_id     = $ClientID
  client_secret = $ClientSecret
  scope         = "https://graph.microsoft.com/.default"
  grant_type    = "client_credentials"
}

$TokenResponse = Invoke-RestMethod -Uri $TokenUrl -Method POST -Body $TokenRequestBody -ContentType "application/x-www-form-urlencoded"

$SecretToken = $TokenResponse.access_token

<#######################
API Call to send email via Microsoft Graph
#######################>

$apiquery = "https://graph.microsoft.com/v1.0/users/$mailbox/sendMail"

<#########################
Email content. Edit the Subject and Content
#########################>

$emailBody = @{
    message = @{
        subject = $emailsubject
        body = @{
            contentType = "Text"
            content = $emailbodycontent
        }
        toRecipients = @(@{ emailAddress = @{ address = $recipients } })
        ccRecipients = @(@{ emailAddress = @{ address = $CCrecipients } })
    }
    saveToSentItems = $false
}

<###############################
Convert the email body to JSON
################################>
$emailBodyJson = $emailBody | ConvertTo-Json -Depth 10

<###############################
Define headers
################################>
$Headers = @{
  "Authorization" = "Bearer $($SecretToken)"
  "Content-type"  = "application/json"
}

<###############################
Send the email
################################>
$apicall = Invoke-RestMethod -Uri $apiquery -Method POST -Headers $Headers -Body $emailBodyJson
