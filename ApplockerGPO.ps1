
#Working Folder on local client

$GPOName = Read-Host "Name of the Applocker GPO....."

$path = "c:\logs\Applocker"

#Output files
$xmlExe = "$path\Exe.xml"
$xmlScript = "$path\Script.xml"
$xmlMSI = "$path\Msi.xml"
$xmlPack = "$path\Appx.xml"
$xmlPath = "$path\PathRules.xml"
$xmldnyWin32 = "$path\dnyWin32.xml"
$xmldnyWin64 = "$path\dnyWin64.xml"
$xmldnyProg32 = "$path\dnyProg32.xml"
$xmldnyProg64 = "$path\dnyProg64.xml"
$xmldnyWinSxs = "$path\dnyWinSxs.xml"
$xmldnyPS = "$path\dnyPS.xml"

#Block the following files
$dny = 
"csc.Exe",
"gathernetworkInf.vbs",
"installutil.Exe",
"msbuild.Exe",
"msdeploy.Exe",
"mshta.Exe",
"Package.dll",
"scrobj.dll",
"sos.dll",
"psr.Exe",
"ftp.Exe",
"cipher.Exe",
"IEExec.Exe"

$dnyPSExe =
'Powershell.exe',
'Powershell_ise.exe',
'system.management.automation.dll'

#Create policy for all Exe's
Get-ChildItem C:\ -Force -Recurse -ErrorAction SilentlyContinue | 
where {$_.Extension -eq ".exe"} | 
ForEach-Object {$_.FullName   } | 
Get-AppLockerFileInformation -ErrorAction SilentlyContinue | 
New-AppLockerPolicy -RuleType Publisher,Hash -Optimize -Xml |
Out-File $xmlExe

#Create policy for all Scripts
Get-ChildItem C:\ -Force -Recurse -ErrorAction SilentlyContinue | 
where {$_.Extension -eq ".ps1" `
 -or $_.Extension -eq ".bat" `
 -or $_.Extension -eq ".cmd" `
 -or $_.Extension -eq ".vbs" `
 -or $_.Extension -eq ".js" } | 
ForEach-Object {$_.FullName} | 
Get-AppLockerFileInformation -ErrorAction SilentlyContinue | 
New-AppLockerPolicy -RuleType Publisher,Hash -Optimize -Xml |
Out-File $xmlScript

#Create policy for all Scripts
Get-ChildItem C:\ -Force -Recurse -ErrorAction SilentlyContinue | 
where {$_.Extension -eq ".msi" -or $_.Extension -eq ".msp*"} | 
ForEach-Object {$_.FullName} | 
Get-AppLockerFileInformation -ErrorAction SilentlyContinue | 
New-AppLockerPolicy -RuleType Publisher,Hash -Optimize -Xml |
Out-File $xmlMsi

#Create policy for All Users and Packages (Appx)
Get-AppxPackage -allusers | 
Get-AppLockerFileInformation | 
New-AppLockerPolicy -RuleType publisher -Optimize -xml -User Users |
Out-File $xmlAppX 

$ardnyWin32=@()
foreach ($dnyWin32 in $dny)
    {
    $dnyWin32FileInf = Get-ChildItem -Path C:\Windows\system32 -Recurse -Force -ErrorAction SilentlyContinue | 
    Where {$_.name -eq "$dnyWin32"} 
    $dnyWin32Fullname = $dnyWin32FileInf.FullName
    $ardnyWin32 += $dnyWin32Fullname
    }
sleep 5
ForEach-Object {$ardnyWin32} |
Get-AppLockerFileInformation -ErrorAction SilentlyContinue | 
New-AppLockerPolicy -RuleType Hash -Xml | 
Out-File $xmldnyWin32

$ardnyWin64=@()
foreach ($dnyWin64 in $dny)
    {
    $dnyWin64FileInf = Get-ChildItem -Path C:\Windows\sysWOW64 -Recurse -Force -ErrorAction SilentlyContinue | 
    Where {$_.name -eq "$dnyWin64"}
    $dnyWin64Fullname = $dnyWin64FileInf.FullName
    $ardnyWin64 += $dnyWin64Fullname
    }
sleep 5
ForEach-Object {$ardnyWin64} |Get-AppLockerFileInformation -ErrorAction SilentlyContinue | 
New-AppLockerPolicy -RuleType Hash -Xml | 
Out-File $xmldnyWin64

$ardnyProg64=@()
foreach ($dnyProg64 in $dny)
    {
    $dnyProg64FileInf = Get-ChildItem -Path "C:\Program Files\" -Recurse -Force -ErrorAction SilentlyContinue | 
    Where {$_.name -eq "$dnyProg64"}
    $dnyProg64Fullname = $dnyProg64FileInf.FullName
    $ardnyProg64 += $dnyProg64Fullname
    }
sleep 5
ForEach-Object {$ardnyProg64} |Get-AppLockerFileInformation -ErrorAction SilentlyContinue | 
New-AppLockerPolicy -RuleType Hash -Xml | 
Out-File $xmldnyProg64

$ardnyProg32=@()
foreach ($dnyProg32 in $dny)
    {
    $dnyProg32FileInf = Get-ChildItem -Path "C:\Program Files (x86)\" -Recurse -Force -ErrorAction SilentlyContinue | 
    Where {$_.name -eq "$dnyProg32"}
    $dnyProg32Fullname = $dnyProg32FileInf.FullName
    $ardnyProg32 += $dnyProg32Fullname
    }
sleep 5
ForEach-Object {$ardnyProg32} |Get-AppLockerFileInformation -ErrorAction SilentlyContinue | 
New-AppLockerPolicy -RuleType Hash -Xml | 
Out-File $xmldnyProg32

$ardnyWinSxs=@()
foreach ($dnyWinSxs in $dny)
    {
    $dnyWinSxsFileInf = Get-ChildItem -Path C:\Windows\winSxs -Recurse -Force -ErrorAction SilentlyContinue | 
    Where {$_.name -eq "$dnyWinSxs"}
    $dnyWinSxsFullname = $dnyWinSxsFileInf.FullName
    $ardnyWinSxs += $dnyWinSxsFullname
    }
sleep 5
ForEach-Object {$ardnyWinSxs} |Get-AppLockerFileInformation -ErrorAction SilentlyContinue | 
New-AppLockerPolicy -RuleType Hash -Xml | 
Out-File $xmldnyWinSxs

$ardnyPS=@()
foreach ($dnyPS in $dnyPSExe)
    {
    $dnyPSFileInf = Get-ChildItem -Path C:\ -Recurse -Force -ErrorAction SilentlyContinue | 
    Where {$_.name -eq "$dnyPS"} 
    $dnyPSFullname = $dnyPSFileInf.FullName
    $ardnyPS += $dnyPSFullname
    }
sleep 5
ForEach-Object {$ardnyPS} |
Get-AppLockerFileInformation -ErrorAction SilentlyContinue | 
New-AppLockerPolicy -RuleType Hash -Xml | 
Out-File $xmldnyPS

#Update XML Output from Not Configured to Enabled and Allow to Deny for block list
$gcXmlExe = get-content $xmlExe
$gcXmlExe.Replace("NotConfigured","Enabled") | 
Out-File $xmlExe

$gcXmlMSI = get-content $xmlMSI
$gcXmlMSI.Replace("NotConfigured","Enabled") | 
Out-File $xmlMSI

$gcXmlScript = get-content $xmlScript
$gcXmlScript.Replace("NotConfigured","Enabled") | 
Out-File $xmlScript

$gcPack = get-content $xmlPack
$gcPack.Replace("NotConfigured","Enabled") | 
Out-File $xmlPack

$gcPath = get-content $xmlPath
$gcPath.Replace("NotConfigured","Enabled") | 
Out-File $xmlPath

$gcdnyWin32 = get-content $xmldnyWin32
$gcdnyWin32.Replace("Allow","Deny").Replace("NotConfigured","Enabled") | 
Out-File $xmldnyWin32

$gcdnyWin64 = get-content $xmldnyWin64
$gcdnyWin64.Replace("Allow","Deny").Replace("NotConfigured","Enabled") | 
Out-File $xmldnyWin64

$gcdnyWinSxs = get-content $xmldnyWinSxs
$gcdnyWinSxs.Replace("Allow","Deny").Replace("NotConfigured","Enabled") | 
Out-File $xmldnyWinSxs

$gcdnyProg64 = get-content $xmldnyProg64
$gcdnyProg64.Replace("Allow","Deny").Replace("NotConfigured","Enabled") | 
Out-File $xmldnyProg64

$gcdnyProg32 = get-content $xmldnyProg32
$gcdnyProg32.Replace("Allow","Deny").Replace("NotConfigured","Enabled") | 
Out-File $xmldnyProg32

$gcdnyPS = get-content $xmldnyPS
$gcdnyPS.Replace("Allow","Deny").Replace("NotConfigured","Enabled") | 
Out-File $xmldnyPS

#New GPO
$GPOAdmin = $GPOName + "_PS"
$GPOPath = $GPOName + "_Path"

new-GPO -Name $GPOName
new-GPO -Name $GPOAdmin
New-GPO -Name $GPOPath

$cn = (Get-GPO -Name $GPOName).path
$cnAdmin = (Get-GPO -Name $GPOAdmin).path
$cnPath = (Get-GPO -Name $GPOPath).path

$dom=(Get-ADDomainController).hostname

Set-AppLockerPolicy -XmlPolicy $xmlExe -Merge -Ldap "LDAP://$dom/$cn"
sleep 5
Set-AppLockerPolicy -XmlPolicy $xmlScript -Merge -Ldap "LDAP://$dom/$cn"
sleep 5
Set-AppLockerPolicy -XmlPolicy $xmlMSI -Merge -Ldap "LDAP://$dom/$cn"
sleep 5
Set-AppLockerPolicy -XmlPolicy $xmlPath -Merge -Ldap "LDAP://$dom/$cnPath"
sleep 5
Set-AppLockerPolicy -XmlPolicy $xmlPack -Merge -Ldap "LDAP://$dom/$cn"
sleep 5

Set-AppLockerPolicy -XmlPolicy $xmldnyWin32 -Merge -Ldap "LDAP://$dom/$cn"
sleep 5
Set-AppLockerPolicy -XmlPolicy $xmldnyWin64 -Merge -Ldap "LDAP://$dom/$cn"
sleep 5
Set-AppLockerPolicy -XmlPolicy $xmldnyWinSxs -Merge -Ldap "LDAP://$dom/$cn"
sleep 5
Set-AppLockerPolicy -XmlPolicy $xmldnyProg64 -Merge -Ldap "LDAP://$dom/$cn"
sleep 5
Set-AppLockerPolicy -XmlPolicy $xmldnyProg32 -Merge -Ldap "LDAP://$dom/$cn"
sleep 5
Set-AppLockerPolicy -XmlPolicy $xmldnyPS -merge -Ldap "LDAP://$dom/$cnAdmin"
sleep 5








