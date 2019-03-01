# Auth - Fill your own values
$SubId = ""
$TenantId = ""
$WsName =""
$RGName=""
$AppId = ""
$AppSecret = ""

# Auth call
$url = "https://login.microsoftonline.com/$TenantId/oauth2/token?api-version=1.0"
$body = @{ 
    'resource'='https://management.azure.com'
    'grant_type'='client_credentials'
    'client_id'=$AppId
    'client_secret'=$AppSecret 
    }
$params = @{
    ContentType='application/x-www-form-urlencoded'
    Headers=@{'accept'='application/json'}
    Body=$body
    Method='Post'
    URI=$url
}
$token = Invoke-RestMethod @params

# Get Workspace
$url="https://management.azure.com/subscriptions/$SubId/resourcegroups/$RGName/providers/Microsoft.OperationalInsights/workspaces/" + $WSName + "?api-version=2015-11-01-preview"
$params = @{
    Headers=@{
        'accept'='application/json'
        'authorization' = 'Bearer ' + $token.access_token
    }
    Method='Get'
    URI=$url
}
$ws = Invoke-RestMethod @params
write-host "Name:" $ws.name
write-host "ID: " $ws.id
write-host "Retention Days:" $ws.properties.retentionInDays

# Get Groups
$url="https://management.azure.com/subscriptions/$SubId/resourceGroups/$RGName/providers/Microsoft.OperationalInsights/workspaces/$WSName/features/serviceMap/machineGroups?api-version=2015-11-01-preview"
$params = @{
    Headers=@{
        'accept'='application/json'
        'authorization' = 'Bearer ' + $token.access_token
    }
    Method='Get'
    URI=$url
}
$groups = Invoke-RestMethod @params
Write-Host $groups.value.Count "VM Groups found:"
foreach ($group in $groups.value) {
    write-host $group.properties.displayName ":" $group.name
}

# Get VMs
$Url="https://management.azure.com/subscriptions/$SubId/resourceGroups/$RGName/providers/Microsoft.OperationalInsights/workspaces/$WSName/features/serviceMap/machines?api-version=2015-11-01-preview"
$params = @{
    Headers=@{
        'accept'='application/json'
        'authorization' = 'Bearer ' + $token.access_token
    }
    Method='Get'
    URI=$url
}
$machines = Invoke-RestMethod @params
Write-Host $machines.value.Count "VMs found:"
foreach ($machine in $machines.value) {
    write-host $machine.name, $machine.properties.displayName, $machine.id
}

# Get VMs in group
$groupname="8f7506d5-3ef8-47a4-af1d-2318a82394c5"
$url = "https://management.azure.com/subscriptions/$SubId/resourceGroups/$RGName/providers/Microsoft.OperationalInsights/workspaces/$WSName/features/serviceMap/machineGroups/" + $groupname + "?api-version=2015-11-01-preview"
$params = @{
    Headers=@{
        'accept'='application/json'
        'authorization' = 'Bearer ' + $token.access_token
    }
    Method='Get'
    URI=$url
}
$group = Invoke-RestMethod @params
$machines = $group.properties.machines
write-host "Group" $group.properties.displayName", ID" $group.name", ETAG" $group.etag
Write-Host $machines.Count "VMs found in group:"
foreach ($machine in $machines) {
    write-host $machine.properties.displayNameHint "-" $machine.properties.osFamilyHint "-" $machine.name
}

# Get VM
$machineid='m-efb5eb17-03a9-4225-997d-90868b6a94ce'
$url="https://management.azure.com/subscriptions/$SubId/resourceGroups/$RGName/providers/Microsoft.OperationalInsights/workspaces/$WSName/features/serviceMap/machines/" + $machineid + "?api-version=2015-11-01-preview"
$params = @{
    Headers=@{
        'accept'='application/json'
        'authorization' = 'Bearer ' + $token.access_token
    }
    Method='Get'
    URI=$url
}
$vm = Invoke-RestMethod @params
write-host "Name:" $vm.name
write-host "ID: " $vm.id


# Add new group
$groupname='CreatedThroughREST2'
$url="https://management.azure.com/subscriptions/$SubId/resourceGroups/$RGName/providers/Microsoft.OperationalInsights/workspaces/$WSName/features/serviceMap/machineGroups?api-version=2015-11-01-preview"
$machineid='m-efb5eb17-03a9-4225-997d-90868b6a94ce'
$machinefullid="/subscriptions/$SubId/resourceGroups/$RGName/providers/Microsoft.OperationalInsights/workspaces/$WSName/machines/$machineid"
$body = @{
    'kind'='machineGroup'
    'properties'=@{
        'displayName'=$groupname
        'machines'=@(
            @{
                'kind'='ref:machinewithhints'
                'id'=$machinefullid
            }
         )
    }
}
$body = $body | ConvertTo-Json -Depth 3
$params = @{
    ContentType='application/json'
    Headers=@{
        'accept'='application/json'
        'authorization' = 'Bearer ' + $token.access_token
    }
    Method='Post'
    Body=$body
    URI=$url
}
$newgroup = Invoke-RestMethod @params

# Add VM to group
$groupname='CreatedThroughREST'
$groupid="8f7506d5-3ef8-47a4-af1d-2318a82394c5"
# Get ETAG
$url = "https://management.azure.com/subscriptions/$SubId/resourceGroups/$RGName/providers/Microsoft.OperationalInsights/workspaces/$WSName/features/serviceMap/machineGroups/" + $groupid + "?api-version=2015-11-01-preview"
$params = @{
    Headers=@{
        'accept'='application/json'
        'authorization' = 'Bearer ' + $token.access_token
    }
    Method='Get'
    URI=$url
}
$group = Invoke-RestMethod @params
$etag=$group.etag
write-host "Using ETAG:" $etag
# Get Machine ID
$machineid='m-efb5eb17-03a9-4225-997d-90868b6a94ce'
$url="https://management.azure.com/subscriptions/$SubId/resourceGroups/$RGName/providers/Microsoft.OperationalInsights/workspaces/$WSName/features/serviceMap/machines/" + $machineid + "?api-version=2015-11-01-preview"
$params = @{
    Headers=@{
        'accept'='application/json'
        'authorization' = 'Bearer ' + $token.access_token
    }
    Method='Get'
    URI=$url
}
$vm = Invoke-RestMethod @params
$machinefullid=$vm.id
write-host "Adding VM" $machinefullid
# Update vm group
$url="https://management.azure.com/subscriptions/$SubId/resourceGroups/$RGName/providers/Microsoft.OperationalInsights/workspaces/$WSName/features/serviceMap/machineGroups/" + $groupid + "?api-version=2015-11-01-preview"
$body = @{
    'etag'=$etag
    'kind'='machineGroup'
    'properties'=@{
        'displayName'=$groupname
        'machines'=@(
            @{
                'kind'='ref:machinewithhints'
                'id'=$machinefullid
            }
         )
    }
}
$body = $body | ConvertTo-Json -Depth 4
$params = @{
    ContentType='application/json'
    Headers=@{
        'accept'='application/json'
        'authorization' = 'Bearer ' + $token.access_token
    }
    Method='Put'
    Body=$body
    URI=$url
}
$newgroup = Invoke-RestMethod @params
