#############################################
# Enter the information below from your environment.
#############################################
$TenantID = "<tenantID>"
$ClientID = "<clientID>"
$ClientSecret = "<ClientSecret>"
$TokenUrl = "https://login.microsoftonline.com/$TenantID/oauth2/V2.0/token"
$Scope = "https://graph.microsoft.com/.default"

$StorageAccountName = "<StorageAccountName>"
$StorageAccountKey = "<accountKey>"
$ContainerName = "<containername>"

#######################
#Generate a bearer token
#######################
$TokenRequestBody = @{
   client_id = $ClientID
   client_secret = $ClientSecret
   scope = "https://graph.microsoft.com/.default"
   grant_type = "client_credentials"
}

$TokenResponse = Invoke-RestMethod -Uri $TokenUrl -Method POST -Body $TokenRequestBody -ContentType "application/x-www-form-urlencoded"

$SecretToken = $TokenResponse.access_token

$AuthUri = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"

$Body = @{
   Grant_Type = "client_credentials"
   Scope = $Scope
   client_Id = $ClientID
   Client_Secret = $ClientSecret
}

$TokenResponse = Invoke-RestMethod -Uri $AuthUri -Method POST -Body $Body

$Headers = @{
   "Authorization" = "Bearer $($TokenResponse.access_token)"
   "Content-type"  = "application/json"
}

#####################################
# Invoke rest method to get report of devices. also includes data from the odata nextlink ( more than 1000 results)
#####################################

$IntuneDevices = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" -Method get -Headers $Headers

$Results = @()
$Results += $IntuneDevices.value | Select-Object -Property deviceName, deviceType, operatingSystem, model, managedDeviceOwnerType, enrolledDateTime, lastSyncDateTime

$Pages = $IntuneDevices.'@odata.nextLink'
while($null -ne $Pages) {

Write-Warning "Checking Next page and updating report."
$Addtional = Invoke-RestMethod -Headers @{Authorization = "Bearer $($SecretToken)" } -Uri $Pages -Method Get

if ($Pages){
$Pages = $Addtional."@odata.nextLink"
}
$Results += $Addtional.value
}

#$Path = "c:\temp\"
$Date = Get-Date -UFormat "%m-%d-%Y"
$ReportName = $Date + "_report.csv"

$results | Export-Csv -Path $ReportName -NoTypeInformation
 
###########################################

# This function uploads the file to your storage blob.

###########################################

function Upload-FileToAzureStorageContainer {
   param(
       $StorageAccountName,
       $StorageAccountKey,
       $ContainerName,
       $SourceFilePath
   )

  $StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
   $Container = Get-AzStorageContainer -Name $ContainerName -Context $StorageContext

  $TargetBlobName = (Split-Path -Path $SourceFilePath -Leaf)
   $TargetBlobPath =  $TargetBlobName

  Set-AzStorageBlobContent -File $SourceFilePath -Container $Container.Name -Blob $TargetBlobPath -Context $StorageContext -Force
}

Upload-FileToAzureStorageContainer -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -ContainerName $ContainerName -SourceFilePath $ReportName


 
