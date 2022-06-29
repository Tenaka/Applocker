
#Working Folder on local client

#$GPOName = Read-Host "Name of the Applocker GPO....."

$GPOName = "DenyTheWorld"
$path = "c:\downloads\Applocker"

New-Item -Path $path -ItemType Directory -Force

#Output files
$xmlExe = "$path\Exe.xml"
$xmlScript = "$path\Script.xml"
$xmlMSI = "$path\Msi.xml"
$xmlPack = "$path\PackagedRules.xml"
$xmlPath = "$path\PathRules.xml"
$xmldnyWin = "$path\dnyWin.xml"
$xmldnyWin32 = "$path\dnyWin32.xml"
$xmldnyWin64 = "$path\dnyWin64.xml"
$xmldnyProg32 = "$path\dnyProg32.xml"
$xmldnyProg64 = "$path\dnyProg64.xml"
$xmldnyWinSxs = "$path\dnyWinSxs.xml"
$xmldnyPS = "$path\dnyPS.xml"

#Block the following files
$dny = 
"gathernetworkInfo.vbs", #system info gather
"installutil.Exe", #Applocker bypass
"scrobj.dll",
"sos.dll",
"cipher.Exe", #Used by malware to permanently delete or encrypt files 
"certutil.exe",  #Used by hackers to download files and encode text, base64
"csc.exe",    #Used in conjunction with InstallUtil.exe to csharp to exe a file
"cmd.exe",  #Creates data streams
"ExtExport.exe",  #Loads and executes dll's from other folders and used as part of Astaroth malware
#MS Recommended
"addinprocess.exe",
"addinprocess32.exe",
"addinutil.exe",
"aspnet_compiler.exe",
"bash.exe",
"bginfo.exe",
"cdb.exe",
"csi.exe",
"dbghost.exe",
"dbgsvc.exe",
"dnx.exe",
"dotnet.exe",
"fsi.exe",
"fsiAnyCpu.exe",
"infdefaultinstall.exe",
"kd.exe",
"kill.exe",
"lxssmanager.dll",
"lxrun.exe",
"Microsoft.Build.dll",
"Microsoft.Build.Framework.dll",
"Microsoft.Workflow.Compiler.exe",
"msbuild.exe",
"msbuild.dll",
"mshta.exe",
"ntkd.exe",
"ntsd.exe",
"powershellcustomhost.exe",
"rcsi.exe",
"runscripthelper.exe",
"texttransform.exe",
"visualuiaverifynative.exe",
"wfc.exe",
"windbg.exe",
"wmic.exe",
"msdt.exe" 

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

$ardnyWin=@()
foreach ($dnyWin in $dny)
    {
    $dnyWinFileInf = Get-ChildItem -Path C:\Windows\ -Recurse -Force -ErrorAction SilentlyContinue | 
    Where {$_.DirectoryName -notlike "*sysWOW64*" -and $_.DirectoryName -notlike "*system32*" -and $_.DirectoryName -notlike "*winsxs*" -and $_.name -eq "$dnyWin"} 
    $dnyWinFullname = $dnyWinFileInf.FullName
    $dnyWinFullname 
    $ardnyWin += $dnyWinFullname
    }
sleep 5
ForEach-Object {$ardnyWin} |
Get-AppLockerFileInformation -ErrorAction SilentlyContinue | 
New-AppLockerPolicy -RuleType Hash -Xml | 
Out-File $xmldnyWin

$ardnyWin32=@()
foreach ($dnyWin32 in $dny)
    {
    $dnyWin32FileInf = Get-ChildItem -Path C:\Windows\system32 -Recurse -Force -ErrorAction SilentlyContinue | 
    Where {$_.name -eq "$dnyWin32"} 
    $dnyWin32Fullname = $dnyWin32FileInf.FullName
    $dnyWin32Fullname 
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

$gcdnyWin = get-content $xmldnyWin
$gcdnyWin.Replace("Allow","Deny").Replace("NotConfigured","Enabled") | 
Out-File $xmldnyWin

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

$ccPack = get-content $xmlPack
$ccPack.Replace("NotConfigured","Enabled") | 
Out-File $xmlPack

$ccPath = get-content $xmlPath
$ccPath.Replace("NotConfigured","Enabled") | 
Out-File $xmlPath

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

Set-AppLockerPolicy -XmlPolicy $xmldnyWin -Merge -Ldap "LDAP://$dom/$cn"
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








