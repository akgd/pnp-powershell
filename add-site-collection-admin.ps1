$siteURL = "https://[YOUR TENANT].sharepoint.com/sites/[YOUR SITE]"
Connect-PnPOnline -Url $siteURL -Interactive -ForceAuthentication
Set-PnPTenantSite -Identity $siteURL -Owners "[USER EMAIL]"
