### Send an email using MS Graph

## Step 1 - Register your application in Azure.
* Register an application in your tenant with the following application permissions.
  - Mail.read
  - mail.readbasic.all
* Create a client secret and save the Value. This value only appears once when created.  !! Not the Secret ID !!
* ![image](https://github.com/user-attachments/assets/a80d142e-1e5a-4725-bcd0-42ec29304fdc)
* Take note of the application id also
<br />

## Step 2 - Give the application permission to send from a mailbox.
* Copy the script from ExchangePermissions.ps1 powershell ISE and enter your AppID and mailbox we are sending from.
* ![image](https://github.com/user-attachments/assets/c348adf2-7849-4ecc-817c-ecf80b320736)
<br />

** Step 3 - Update the script and send.

