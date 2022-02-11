Connect-PnPOnline -Url "https://[your_tenant].sharepoint.com/sites/[your_site]" -Interactive -ForceAuthentication
Get-PnPRecycleBinItem -RowLimit 10000 | Where-Object{($_.DeletedDate -gt "1/30/2022") -and ($_.DeletedByEmail -eq "person@example.com") -and ($_.Title -match "Engineering")}
