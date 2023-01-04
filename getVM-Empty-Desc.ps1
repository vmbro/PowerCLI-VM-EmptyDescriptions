$vcenter = "vCenterFQDN" # Your vCenter name -  vcenter.domain.local
$user = "username" # Your vCenter username - administrator@vsphere.local or domain\username
$password = "password" # Your vCenter password
$location = "Location_Name" # Change this location variable according to yourself
$uriSlack = "https://..." # Your Slack URI
$jiraProjectKey = "Project_Key" # JIRA project key
$jiraUsername = "username" # JIRA username 
$jiraToken = "token" # JIRA token
$jiraURL = 'jira_url' # JIRA URL

try {
    Disconnect-VIServer -server * -confirm:$false
}
catch {
    #"Could not find any of the servers specified by name."
}

$slackText = ""
$vmList = ""
$emoji = ':warning:'
$issueTitle = $emoji + " *Virtual Machines with empty notes!*`n"
$action = " *Action: * Please fill the VM Notes section.`n"
    
function sendSlack {
    param([string]$vmNames)
    Write-Host $vmName
    $locationText = "*Location:* " + $location + "`n";
    $vcenterURLText = "*vCenter URL*: https://" + $vcenter + "`n"
    $slackText += $locationText + $vcenterURLText + '```' + $vmNames + '```'
    $slackBody = ConvertTo-Json @{
        text = $issueTitle + $slackText + $action
    }
    Invoke-RestMethod -uri $uriSlack -Method Post -body $slackBody -ContentType 'application/json' | Out-Null
    write-host "You can check your Slack"
    & "$PSScriptRoot\noDescriptionVMs.py" $location, $vmNames, $jiraProjectKey, $jiraUsername, $jiraToken, $jiraURL
}

Connect-VIServer -Server $vcenter -User $user -Password $password | out-null
$noDescVMs = Get-VM
foreach ($vm in $noDescVMs) {
    if ([string]::IsNullOrEmpty($vm.Notes)) {
        $vmList += $vm.Name + "`n"
    }
}

if (![string]::IsNullOrEmpty($vmList)) {
    sendSlack $vmList
}
else {
    Write-Host "Everything is OK."
}

Disconnect-VIServer -server * -confirm:$false
