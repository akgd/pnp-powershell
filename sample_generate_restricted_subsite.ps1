<# This script was used to generate sub-sites in a restricted SharePoint portal.
 IT staff requested sites by subitting a form that created a SharePoint list item.
 The list was periodically checked for new requests. The generated site was secured and
 served as a dropoff point for data, which is why the homepage is set to the documents 
 library and navigation links are removed.
#>
$creds = Get-AutomationPSCredential -Name "YOUR_CREDS"
$siteCollection = "https://YOUR_TENANT.sharepoint.com/sites/YOUR_SITE"
Connect-PnPOnline -Url $siteCollection -Credentials $creds

# Check the list for new requests
# Note that on demand requests are not possible because the 
# admin account can't create multiple sites simultaneously
$listName = "Restricted Site Requests"
$query = "<View><Query><Where><Eq><FieldRef Name='Status' /><Value Type='Text'>New request</Value></Eq></Where><OrderBy><FieldRef Name='Created' Ascending='False' /></OrderBy></Query></View>"
$listItems = Get-PnPListItem -List $listName -Query $query
$requestCount = $listItems.Count

if ($requestCount -gt 0) {
    foreach ($item in $listItems) {
            # Get SP item ID so that we can update the request item
            $itemID = $item["ID"]
            # Update request status to prevent infinite loops when errors occur
            # When a site/permission group creation fails, the easiest solution is to submit a new request
            $requestStatusUpdate = Set-PnPListItem -List $listName -Identity $itemID -Values @{"Status" = "Processing attempted" }
            # Get the requested site title
            $subSiteTitle = $item["Title"]
            # Determine new subsite path using the unique SharePoint item ID
            $newSubsitePath = "Portal-$itemID"
            $newSiteFullPath = "$siteCollection/$newSubsitePath"
            # Prepare unique names for our new SharePoint groups
            $groupNameStart = "Restricted Portal $itemID"
            $ownersGroupName = "$groupNameStart Owners"
            $membersGroupName = "$groupNameStart Members"
            $visitorsGroupName = "$groupNameStart Visitors"
            # Create the groups in the site collection
            $newOwnersGroup = New-PnPGroup -Title $ownersGroupName -Owner $ownersGroupName -ErrorAction SilentlyContinue
            $newMembersGroup = New-PnPGroup -Title $membersGroupName -Owner $ownersGroupName -ErrorAction SilentlyContinue
            $newVisitorsGroup = New-PnPGroup -Title $visitorsGroupName -Owner $ownersGroupName -ErrorAction SilentlyContinue
            # Get the requestor email
            # $requestorEmail = $item["Author"].Email
            # Add the requestor to the owners group
            # Add-PnPUserToGroup -LoginName $requestorEmail -Identity $ownersGroupName
            # Get the requested owners
            $owners = $item["Owners"]
            $ownersCount = $owners.Count
            if ($ownersCount -gt 0) {
                foreach ($account in $owners) {
                    # Get user from the User Information List
                    # Must use lookupid because security groups have no email in the UIL
                    $getUser = Get-PnPUser -Identity $account.LookupId
                    # Add user to the owners group
                    Add-PnPUserToGroup -LoginName $getUser.LoginName -Identity $ownersGroupName
                }
            }
            # Get the requested users
            $users = $item["Users"]
            $userCount = $users.Count
            if ($userCount -gt 0) {
                foreach ($account in $users) {
                    # Get user from the User Information List
                    # Must use lookupid because security groups have no email in the UIL
                    $getUser = Get-PnPUser -Identity $account.LookupId
                    # Add user to the members group
                    Add-PnPUserToGroup -LoginName $getUser.LoginName -Identity $membersGroupName
                }
            }
            # Create a new subsite
            $newSite = New-PnPWeb -Title $subSiteTitle -Url $newSubsitePath -Description "Restricted Site" -Locale 1033 -Template "STS" -BreakInheritance
            Write-Host $newSiteFullPath
            # Connect to new site
            Connect-PnPOnline -Url $newSiteFullPath -Credentials $creds
            # Set homepage to the default document library and remove navigation links
            Set-PnPHomePage -RootFolderRelativeUrl "Shared Documents/Forms/AllItems.aspx"
            $navigationItems = Get-PnPNavigationNode -Location QuickLaunch
            foreach ($node in $navigationItems) {
                if ($node.Title -ne "Documents") {
                    Remove-PnPNavigationNode -Identity $node.Id -Force
                }
            }
            # Set new groups as official owners/members/visitors for this site
            # IMPORTANT: SharePoint team needs to MANUALLY set the access request owner to the Owners group
            Set-PnPGroup -Identity $ownersGroupName -SetAssociatedGroup Owners -AddRole "Full Control"
            Set-PnPGroup -Identity $membersGroupName -SetAssociatedGroup Members -AddRole "Edit"
            Set-PnPGroup -Identity $visitorsGroupName -SetAssociatedGroup Visitors -AddRole "Read" 
            # Reconnect to the root
            Connect-PnPOnline -Url $siteCollection -Credentials $creds
            # Update request status
            $requestStatusUpdate = Set-PnPListItem -List $listName -Identity $itemID -Values @{"Status"="Processing complete";"URL"= $newSiteFullPath}
            # Trigger email workflow (SharePoint 2013 workflow type)
            $workflowName = "Site Request Emails"
            $workflow = Get-PnPWorkflowSubscription -List $listName -Name $workflowName
            Start-PnPWorkflowInstance -Subscription $workflow -ListItem $itemID
    }
}
