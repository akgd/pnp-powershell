# Prepare the CSV file
$time = $((Get-Date).ToString("yyyyMMdd_HHmmss"))
$fileName = "Recycling Bin Report $time.csv"
$filePath = Join-Path -Path $env:TEMP -ChildPath $fileName
$csv = {} | Select ItemType, DirName, LeafName, DeletedByEmail, DeletedDate | Export-CSV $filePath -NoType

# Connect to SharePoint
# Update the url, desired date, and user email below
Connect-PnPOnline -Url "https://[your tenant].sharepoint.com/sites/[your site]" -Interactive -ForceAuthentication
$recycledItems = Get-PnPRecycleBinItem -RowLimit 10000 | Where-Object { $_.DeletedDate -gt "11/04/2022" -and $_.DeletedByEmail -eq "[user email]"}

# Loop through results and output to CSV
foreach ($item in $recycledItems) {
    [PSCustomObject]@{ItemType = $item.ItemType; DirName = $item.DirName; LeafName = $item.LeafName; DeletedByEmail = $item.DeletedByEmail; DeletedDate = $item.DeletedDate } | Export-CSV $filePath -Append -Force -NoType
}
