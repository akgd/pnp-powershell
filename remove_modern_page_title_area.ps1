$creds = Get-AutomationPSCredential -Name "YOUR_CREDS"
$site = "https://YOUR-TENANT.sharepoint.com/sites/YOUR_SITE"
Connect-PnPOnline -Url $site -Credentials $creds
Set-PnPPage -Identity "YOUR-PAGE.aspx" -LayoutType Home
