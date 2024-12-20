# Send an email using MS Graph
This guide will give steps to email from a mailbox using MSGraph

## DISCLAIMER:
 
This code-sample is provided "AS IS" without warranty of any kind, either expressed or implied,
including but not limited to the implied warranties of merchantability and/or fitness for a
particular purpose.

The author further disclaims all implied warranties including, without limitation, any implied
warranties of merchantability or of fitness for a particular purpose.
 
The entire risk arising out of the use or performance of the sample and documentation remains with
you.
 
In no event shall the authors, or anyone else involved in the creation, production, or
delivery of the script be liable for any damages whatsoever (including, without limitation, damages
for loss of business profits, business interruption, loss of business information, or other
pecuniary loss) arising out of the use of or inability to use the sample or documentation, even if the author
has been advised of the possibility of such damages.

<br />

## Step 1 - Register your application in Azure.
* Register an application in your tenant with the following application permissions.
  - Mail.read
  - mail.readbasic.all
* Create a client secret and save the Value. This value only appears once when created.  !! Not the Secret ID !!
  <br /> ![image](https://github.com/user-attachments/assets/a80d142e-1e5a-4725-bcd0-42ec29304fdc)
* Take note of the application id also
<br />

## Step 2 - Give the application permission to send from a mailbox.
* Copy the script from ExchangePermissions.ps1 powershell ISE and enter your AppID and mailbox we are sending from.
 <br />  ![image](https://github.com/user-attachments/assets/c348adf2-7849-4ecc-817c-ecf80b320736)
<br />

## Step 3 - Update the script and send.
* Enter the email address of the mailbox from which the email will be sent, the primary recipient's email address, the CC recipient's email address, the subject of the email, and the body content of the email
  <br />  ![image](https://github.com/user-attachments/assets/dc9b98fd-c329-4d4b-addb-98565b6a5108)


