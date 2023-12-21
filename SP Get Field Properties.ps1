# https://pnp.github.io/powershell/cmdlets/Get-PnPField.html

$siteURL = "https://YOURTENANT.sharepoint.com/sites/YOURSITE"
$listName = "Documentation"
$fieldName = "Status"

Connect-PnPOnline -Url $siteURL -Interactive -ForceAuthentication
Get-PnPField -List $listName -Identity $fieldName | Select-Object *
