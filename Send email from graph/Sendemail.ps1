<#######################
Register an application in your tenant with the following application permissions. Mail.read, mail.readbasic.all.
Create a client secret and store the information in the variables below.
######################>
​
#############################################
# Enter the information below from your environment.
#############################################
​
$TenantID = "xxxxxxxx"
$ClientID = "xxxxxxxxxxxxxxx"
$ClientSecret = xxxxxxxxxxxxxx"
$TokenUrl = "https://login.microsoftonline.com/$TenantID/oauth2/V2.0/token"
$Scope = "https://graph.microsoft.com/.default"
$domainname = "xxxxxxxxxxxxx"
​
​
<######################
This is the graph query we are looking for data from.
The following rest method searches the mail box of usermailbox@domain.com for any messages to fake@domain.com where the subject starts with undeliverable. Default return per page is top 10. The script is set to 100 but can be set up to 1000. 
Depending on the page size and mailbox data, getting #messages from a mailbox can incur multiple requests. The default page size is 10 messages. #Use $top to customize the page size, within the range #of 1 and 1000.
​#######################>
​
$apiquery = 'https://graph.microsoft.com/v1.0/users/usermailbox@domain.com/messages?$search="to:fake@domain.com AND subject:undeliverable*"&$top=100'
​
​#######################
​#Generate a bearer token
​#######################
​
$TokenRequestBody = @{
  client_id = $ClientID
  client_secret = $ClientSecret
  scope = "https://graph.microsoft.com/.default"
  grant_type = "client_credentials"
}
​
$TokenResponse = Invoke-RestMethod -Uri $TokenUrl -Method POST -Body $TokenRequestBody -ContentType "application/x-www-form-urlencoded"
​
$SecretToken = $TokenResponse.access_token
$SecretToken
$AuthUri = "https://login.microsoftonline.com/$domainname/oauth2/v2.0/token"
​
$Body = @{
  Grant_Type = "client_credentials"
  Scope = $Scope
  client_Id = $ClientID
  Client_Secret = $ClientSecret
}
​
$TokenResponse = Invoke-RestMethod -Uri $AuthUri -Method POST -Body $Body
​
$Headers = @{
  "Authorization" = "Bearer $($TokenResponse.access_token)"
  "Content-type"  = "application/json"
}
​
<##########################################
​Invoke rest method to get report of email
​###########################################>
​
$apicall = Invoke-RestMethod -Uri $apiquery -Method get -Headers $Headers 
​
​
​
<###################################
​ This section may need to be edited to meet the output of your query as this is tailored for the output of messages, emails.
​ ###################################>
​
# Prepare the data for CSV export
$Results = @()
​
# Process the initial set of email messages
$Results += $apicall.value | ForEach-Object {
   [PSCustomObject]@{
       Id = $_.id
       Subject = $_.subject
       From = $_.from.emailAddress.address
       Sender = $_.sender.emailAddress.address
       ToRecipients = ($_.toRecipients | ForEach-Object { $_.emailAddress.address }) -join "; "
       ReceivedDateTime = $_.receivedDateTime
   }
}
​
​
<##############################
Handle multiple pages of results and output to csv.
###############################>
​
$Pages = $apicall.'@odata.nextLink'
while ($null -ne $Pages) {
   Write-Warning "Checking Next page and updating report."
   $Additional = Invoke-RestMethod -Headers @{Authorization = "Bearer $($SecretToken)"} -Uri $Pages -Method Get
​
   if ($Additional.'@odata.nextLink') {
       $Pages = $Additional.'@odata.nextLink'
   } else {
       $Pages = $null
   }
​
   $Results += $Additional.value | ForEach-Object {
       [PSCustomObject]@{
           Id = $_.id
           Subject = $_.subject
           From = $_.from.emailAddress.address
           Sender = $_.sender.emailAddress.address
           ToRecipients = ($_.toRecipients | ForEach-Object { $_.emailAddress.address }) -join "; "
           ReceivedDateTime = $_.receivedDateTime
       }
   }
}
​
# Export the processed data to a CSV file
$Results | Export-Csv -Path "C:\temp\file.csv" -NoTypeInformation
