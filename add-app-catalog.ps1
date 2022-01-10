# Adds app catalog to site collection
# Note that you must have created the app catalog for your tenant in advance

Connect-PnPOnline -Url "https://[your tenant]-admin.sharepoint.com" -Interactive -ForceAuthentication
Add-PnPSiteCollectionAppCatalog -Site "https://[your tenant].sharepoint.com/sites/[your site]"
