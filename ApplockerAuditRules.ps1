<#.........................................

           Applocker Audit
               HTML CSS

.........................................#>
$font = "Raleway"
$FontTitle_H1 = "175%"
$FontSub_H2 = "130%"
$FontBody_H3 = "105%"
$FontHelps_H4 = "100%"
$titleCol = "#4682B4"

$style = @"
    <Style>
    body
    {
        background-color:#06273A; 
        color:#FFF9EC;
        font-size:$FontBody_H3;
        font-family:$font;
        margin:0,0,10px,0; 
        Word-break:normal; 
        Word-wrap:break-Word
    }
    table
    {   
        border-width: 1px;
        padding: 7px;
        border-style: solid;
        border-color:#FFF9EC;
        border-collapse:collapse;
        width:auto
    }
    h1
    {
        background-color:#06273A; 
        color:#FFF9EC;
        font-size:$FontTitle_H1;
        font-family:$font;
        margin:0,0,10px,0;
        Word-break:normal; 
        Word-wrap:break-Word
    }
    h2
    {
        background-color:#06273A; 
        color:#4682B4;
        font-size:$FontSub_H2;
        font-family:$font;
        margin:0,0,10px,0; 
        Word-break:normal; 
        Word-wrap:break-Word
    }
    h3
    {
        background-color:#06273A; 
        color:#FFF9EC;
        font-size:$FontBody_H3;
        font-family:$font;
        margin:0,0,10px,0; 
        Word-break:normal; 
        Word-wrap:break-Word;
        font-weight: normal;
        width:auto
    }
    h4
    {
        background-color:#06273A; 
        color:#9f9696;
        font-size:$FontHelps_H4;
        font-family:$font;
        margin:0,0,10px,0; 
        Word-break:normal; 
        Word-wrap:break-Word;
        font-weight: normal
    }
    th
    {
        border-width: 1px;
        padding: 7px;
        font-size:$FontBody_H3;
        border-style: solid;
        border-color:#FFF9EC;
        background-color:#06273A
    }
    td
    {
        border-width: 1px;
        padding:7px;
        font-size:$FontBody_H3;
        border-style: solid; 
        border-style: #FFF9EC
    }
    tr:nth-child(odd) 
    {
        background-color:#06273A;
    }
    tr:nth-child(even) 
    {
        background-color:#28425F;
    }

    a:link {
    color:#4682B4;
    font-size:$FontBody_H3;
    background-color: transparent;
    text-decoration: none;
    }

    a:visited {
    color:#ff9933;
    font-size:$FontBody_H3;
    background-color: transparent;
    text-decoration: none;
    }

    a:hover {
    color:#FFF9EC;
    font-size:$FontBody_H3;
    background-color: transparent;
    text-decoration: none;
    }

    a:active {
    color:#D3BAA9;
    font-size:$FontBody_H3;
    background-color: transparent;
    text-decoration: none;
    } 

    </Style>
"@

<#.........................................

           Applocker Audit
               Service

.........................................#>

$fragApplockerSvc=@()
$AppLockerSvc = get-service appidsvc
$newObjApplockerSvc = New-Object -TypeName PSObject
Add-Member -InputObject $newObjApplockerSvc -Type NoteProperty -Name Path $AppLockerSvc.DisplayName
Add-Member -InputObject $newObjApplockerSvc -Type NoteProperty -Name PubExcep $AppLockerSvc.Name
Add-Member -InputObject $newObjApplockerSvc -Type NoteProperty -Name PubPathExcep $AppLockerSvc.StartType
$fragApplockerSvc += $newObjApplockerSvc

$gtAppLRuleCollection = Get-ApplockerPolicy -Effective | select -ExpandProperty RuleCollections 
$gtAppLCollectionTypes = Get-ApplockerPolicy -Effective | select -ExpandProperty RuleCollectionTypes

<#.........................................

           Applocker Audit
          Enforcement Mode

.........................................#>

$fragApplockerEnforcement=@()
$gtApplockerEnforce = (Get-AppLockerPolicy -Effective).rulecollections | Select-Object -Property RuleCollectionType,EnforcementMode,ServiceEnforcementMode,SystemAppAllowMode,Count 

foreach($appEnforcement in $gtApplockerEnforce)
{

$applockerEnforceColl = $appEnforcement.RuleCollectionType
$applockerEnforceMode = $appEnforcement.EnforcementMode
$applockerEnforceSvc = $appEnforcement.ServiceEnforcementMode
$applockerEnforceSys = $appEnforcement.SystemAppAllowMode
$applockerEnforceCount = $appEnforcement.Count 

    $newObjApplockerEnforce= New-Object -TypeName PSObject
    Add-Member -InputObject $newObjApplockerEnforce -Type NoteProperty -Name CollectionType $applockerEnforceColl
    Add-Member -InputObject $newObjApplockerEnforce -Type NoteProperty -Name EnforceMode $applockerEnforceMode
    Add-Member -InputObject $newObjApplockerEnforce -Type NoteProperty -Name ServiceMode $applockerEnforceSvc 
    Add-Member -InputObject $newObjApplockerEnforce -Type NoteProperty -Name SysAppAllow $applockerEnforceSys
    Add-Member -InputObject $newObjApplockerEnforce -Type NoteProperty -Name NumerofRules $applockerEnforceCount              
    $fragApplockerEnforcement += $newObjApplockerEnforce

}

<#.........................................

           Applocker Audit
             Path Rules

.........................................#>

$fragApplockerPath=@()
foreach ($appLockerRule in $gtAppLCollectionTypes)
{
    $appLockerRuleType = ($gtAppLRuleCollection | where {$_.RuleCollectionType -eq "$appLockerRule"}) | select-object PathConditions,PathExceptions,PublisherExceptions,HashExceptions,action,UserOrGroupSid,id,name
    $appLockerPathAllow = $appLockerRuleType | where {$_.action -eq "allow" -and $_.pathconditions -ne $null}
    $appLockerPathDeny = $appLockerRuleType | where {$_.action -eq "deny" -and $_.pathconditions -ne $null} 

        foreach ($allowitem in $appLockerPathAllow)
            {
                $alPathName = [string]$allowitem.name
                $alPathCon = [string]$allowitem.pathconditions
                $alPublishExcep = [string]$allowitem.PublisherExceptions
                $alPublishPathExcep = [string]$allowitem.PathExceptions
                $alPublishHashExcep = [string]$allowitem.HashExceptions
                $alUserGroup = [string]$allowitem.UserOrGroupSid
                $alAction = [string]$allowitem.action
                $alID = [string]$allowitem.ID
                $alRule = [string]$appLockerRule

                $newObjApplocker = New-Object -TypeName PSObject
                Add-Member -InputObject $newObjApplocker -Type NoteProperty -Name Name $alPathName
                Add-Member -InputObject $newObjApplocker -Type NoteProperty -Name Path $alPathCon
                Add-Member -InputObject $newObjAppLocker -Type NoteProperty -Name PubExcep $alPublishExcep
                Add-Member -InputObject $newObjAppLocker -Type NoteProperty -Name PubPathExcep $alPublishPathExcep
                Add-Member -InputObject $newObjAppLocker -Type NoteProperty -Name PubHashExcep $alPublishHashExcep
                Add-Member -InputObject $newObjApplocker -Type NoteProperty -Name UserorGroup -Value $alUserGroup                 
                Add-Member -InputObject $newObjApplocker -Type NoteProperty -Name Action -Value $alAction 
                Add-Member -InputObject $newObjApplocker -Type NoteProperty -Name Rule -Value $alRule
                #Add-Member -InputObject $newObjApplocker -Type NoteProperty -Name ID -Value $alID
                $fragApplockerPath += $newObjApplocker    

                
            }

        foreach ($denyitem in $appLockerPathDeny)
            {
                $alPathName = [string]$denyitem.name
                $alPathCon = [string]$denyitem.pathconditions
                $alPublishExcep = [string]$denyitem.PublisherExceptions
                $alPublishPathExcep = [string]$denyitem.PathExceptions
                $alPublishHashExcep = [string]$denyitem.HashExceptions
                $alUserGroup = [string]$denyitem.UserOrGroupSid
                $alAction = [string]$denyitem.action
                $alID = [string]$denyitem.ID
                $alRule = [string]$appLockerRule

                $newObjApplocker = New-Object -TypeName PSObject
                Add-Member -InputObject $newObjApplocker -Type NoteProperty -Name Name $alPathName
                Add-Member -InputObject $newObjApplocker -Type NoteProperty -Name Path $alPathCon
                Add-Member -InputObject $newObjAppLocker -Type NoteProperty -Name PubExcep $alPublishExcep
                Add-Member -InputObject $newObjAppLocker -Type NoteProperty -Name PubPathExcep $alPublishPathExcep
                Add-Member -InputObject $newObjAppLocker -Type NoteProperty -Name PubHashExcep $alPublishHashExcep
                Add-Member -InputObject $newObjApplocker -Type NoteProperty -Name UserorGroup -Value $alUserGroup                 
                Add-Member -InputObject $newObjApplocker -Type NoteProperty -Name Action -Value $alAction 
                Add-Member -InputObject $newObjApplocker -Type NoteProperty -Name Rule -Value $alRule
                #Add-Member -InputObject $newObjApplocker -Type NoteProperty -Name ID -Value $alID
                $fragApplockerPath += $newObjApplocker

               
            }
}

<#.........................................

           Applocker Audit
           Publisher Rules

.........................................#>

$gtAppLRuleCollection = Get-ApplockerPolicy -Effective | select -ExpandProperty RuleCollections 
$gtAppLCollectionTypes = Get-ApplockerPolicy -Effective | select -ExpandProperty RuleCollectionTypes

$fragApplockerPublisher=@()
foreach ($appLockerRule in $gtAppLCollectionTypes)
{
    $appLockerRuleType = ($gtAppLRuleCollection | where {$_.RuleCollectionType -eq "$appLockerRule"}) | select-object PublisherConditions, PublisherExceptions, PathExceptions, HashExceptions, action,UserOrGroupSid,id,name
    $ApplockerPublisherAllow = $appLockerRuleType | where {$_.action -eq "allow" -and $_.PublisherConditions -ne $null}
    $ApplockerPublisherDeny = $appLockerRuleType | where {$_.action -eq "deny" -and $_.PublisherConditions -ne $null} 

        foreach ($allowitem in $ApplockerPublisherAllow)
            {
                $alPublishName = [string]$allowitem.name
                $alPublishCon = [string]$allowitem.PublisherConditions
                $alPublishExcep = [string]$allowitem.PublisherExceptions
                $alPublishPathExcep = [string]$allowitem.PathExceptions
                $alPublishHashExcep = [string]$allowitem.HashExceptions
                $alUserGroup = [string]$allowitem.UserOrGroupSid
                $alAction = [string]$allowitem.action
                $alID = [string]$allowitem.ID
                $alRule = [string]$appLockerRule

                $newObjAppLockPublisher = New-Object -TypeName PSObject
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name PublisherName $alPublishName
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name PublisherConditions $alPublishCon
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name PubExcep $alPublishExcep
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name PubPathExcep $alPublishPathExcep
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name PubHashExcep $alPublishHashExcep
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name UserorGroup -Value $alUserGroup                 
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name Action -Value $alAction 
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name Rule -Value $alRule
                #Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name ID -Value $alID
                $fragApplockerPublisher += $newObjAppLockPublisher    
            }

        foreach ($denyitem in $ApplockerPublisherDeny)
            {
                $alPublishName = [string]$denyitem.name
                $alPublishCon = [string]$denyitem.PublisherConditions
                $alPublishExcep = [string]$denyitem.PublisherExceptions
                $alPublishPathExcep = [string]$denyitem.PathExceptions
                $alPublishHashExcep = [string]$denyitem.HashExceptions
                $alUserGroup = [string]$denyitem.UserOrGroupSid
                $alAction = [string]$denyitem.action
                $alID = [string]$denyitem.ID
                $alRule = [string]$appLockerRule

                $newObjAppLockPublisher = New-Object -TypeName PSObject
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name PublisherName $alPublishName
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name PublisherConditions $alPublishCon
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name PubExcep $alPublishExcep
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name PubPathExcep $alPublishPathExcep
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name PubHashExcep $alPublishHashExcep
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name UserorGroup -Value $alUserGroup                 
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name Action -Value $alAction 
                Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name Rule -Value $alRule
                #Add-Member -InputObject $newObjAppLockPublisher -Type NoteProperty -Name ID -Value $alID
                $fragApplockerPublisher += $newObjAppLockPublisher
            }
}

<#.........................................

           Applocker Audit
             Hash Rules

.........................................#>

$gtAppLRuleCollection = Get-ApplockerPolicy -Effective | select -ExpandProperty RuleCollections 
$gtAppLCollectionTypes = Get-ApplockerPolicy -Effective | select -ExpandProperty RuleCollectionTypes

$fragApplockerHash=@()
foreach ($appLockerRule in $gtAppLCollectionTypes)
{
    $appLockerRuleType = ($gtAppLRuleCollection | where {$_.RuleCollectionType -eq "$appLockerRule"}) | select-object HashConditions, action, UserOrGroupSid, id, name
    $ApplockerHashAllow = $appLockerRuleType | where {$_.action -eq "allow" -and $_.HashConditions -ne $null}
    $ApplockerHashDeny = $appLockerRuleType | where {$_.action -eq "deny" -and $_.HashConditions -ne $null} 

        foreach ($allowitem in $ApplockerHashAllow)
            {
                $alHashCon = [string]$allowitem.HashConditions #.split(";")[0]
                $alHashCon = [string]$alHashCon.split(";")
                $alUserGroup = [string]$allowitem.UserOrGroupSid
                $alAction = [string]$allowitem.action
                $alName = [string]$allowitem.name
                $alID = [string]$allowitem.ID
                $alRule = [string]$appLockerRule

                $newObjAppLockHash = New-Object -TypeName PSObject
                Add-Member -InputObject $newObjAppLockHash -Type NoteProperty -Name Name $alName
                Add-Member -InputObject $newObjAppLockHash -Type NoteProperty -Name Hash $alHashCon
                Add-Member -InputObject $newObjAppLockHash -Type NoteProperty -Name UserorGroup -Value $alUserGroup                 
                Add-Member -InputObject $newObjAppLockHash -Type NoteProperty -Name Action -Value $alAction 
                Add-Member -InputObject $newObjAppLockHash -Type NoteProperty -Name Rule -Value $alRule
                #Add-Member -InputObject $newObjAppLockHash -Type NoteProperty -Name ID -Value $alID
                $fragApplockerHash += $newObjAppLockHash    
            }

        foreach ($denyitem in $ApplockerHashDeny)
            {
                $alHashCon = [string]$denyitem.HashConditions #.split(";")[0]
                $alHashCon = [string]$alHashCon.split(";")
                $alUserGroup = [string]$denyitem.UserOrGroupSid
                $alAction = [string]$denyitem.action
                $alName = [string]$denyitem.name
                $alID = [string]$denyitem.ID
                $alRule = [string]$appLockerRule

                $newObjAppLockHash = New-Object -TypeName PSObject
                Add-Member -InputObject $newObjAppLockHash -Type NoteProperty -Name Name $alName
                Add-Member -InputObject $newObjAppLockHash -Type NoteProperty -Name Hash $HashCon
                Add-Member -InputObject $newObjAppLockHash -Type NoteProperty -Name UserorGroup -Value $alUserGroup                 
                Add-Member -InputObject $newObjAppLockHash -Type NoteProperty -Name Action -Value $alAction 
                Add-Member -InputObject $newObjAppLockHash -Type NoteProperty -Name Rule -Value $alRule
                #Add-Member -InputObject $newObjAppLockHash -Type NoteProperty -Name ID -Value $alID
                $fragApplockerHash += $newObjAppLockHash
            }
}

<#.........................................

           Applocker Audit
           HTML Formatting

.........................................#>

$nfrag_ApplockerSvc = $fragApplockerSvc | ConvertTo-Html -As table -fragment -PreContent "<h2>Applocker Service Status</span></h2>"  | Out-String      
$nfrag_ApplockerPath = $fragApplockerPath | ConvertTo-Html -As table -fragment -PreContent "<h2>Applocker Path Rules</span></h2>"  | Out-String
$nfrag_ApplockerPublisher = $fragApplockerPublisher | ConvertTo-Html -As table -fragment -PreContent "<h2>Applocker Publisher Rules</span></h2>"  | Out-String
$nfrag_ApplockerHash = $fragApplockerHash | ConvertTo-Html -As table -fragment -PreContent "<h2>Applocker Hash Rules</span></h2>"  | Out-String
$nfrag_ApplockerEnforcement = $fragApplockerEnforcement | ConvertTo-Html -As table -fragment -PreContent "<h2>Applocker Enforcement Rules</span></h2>"  | Out-String  

$repDate = (Get-Date).Date.ToString("yy-MM-dd").Replace(":","_")
    
ConvertTo-Html -Head $style -Body "<h1 align=center style='text-align:center'>$basePNG<h1>",  

$nfrag_ApplockerSvc,
$nfrag_ApplockerEnforcement,
$nfrag_ApplockerPath, 
$nfrag_ApplockerPublisher,
$nfrag_ApplockerHash | out-file "$($env:USERPROFILE)\$($repDate)-$($env:COMPUTERNAME)-Report.htm" -Force

Invoke-Item "$($env:USERPROFILE)\$($repDate)-$($env:COMPUTERNAME)-Report.htm"
