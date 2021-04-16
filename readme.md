# PnP PowerShell Examples

### Check installed versions
```
Get-Module PnP.PowerShell* -ListAvailable | Select-Object Name,Version | Sort-Object Version
```

### Update Module
Remember to run as administrator
```
Update-Module PnP.PowerShell*
```
