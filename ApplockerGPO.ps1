
<#
        .DESCRIPTION
        Creates an Applocker policy with known exploits denied, applies and starts the APPID service. 
        Applocker operates in the interactive space of the user, does not apply to Service accounts or Systems and does not protect from RCE's if the Firewall is misconfigured.

        Microsoft recommends combing Applocker with Device Guard. Applocker provides the finess by blocking Living of the Land executables. Device Guard provides the assurance 
        at the kernel level only approved programs will execute.

        Further information can be found @ https://www.tenaka.net/applockervsremoteexploit
   
        #Consideration
        Auto Elevate files - Files of Interest that should be considered for deny list
        https://gist.github.com/TheWover/b5a340b1cac68156306866ff24e5934c
        Get-ChildItem "C:\Windows\System32\*.exe" | Select-String -pattern "<autoElevate>true</autoElevate>"
        Get-ChildItem "C:\Windows\Syswow64\*.exe" | Select-String -pattern "<autoElevate>true</autoElevate>"

        #Dll that should be reviewed for deny list
        https://hijacklibs.net/#

        #Read Oddvar excellent site on Applocker
        https://oddvar.moe/tag/applocker/

        #Microsoft Applocker stuff - caution some contradictions covered here https://www.tenaka.net/applocker-vs-malware
        https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/applocker/applocker-overview
    
        #Support
        https://www.tenaka.net/applockergpo
#>

$GPOName = "DenyTheWorld"
$path = "c:\SecureClient\Applocker"

New-Item -Path $path -ItemType Directory -Force

#Output files
$xmlExe = "$path\Exe.xml"
$xmlScript = "$path\Script.xml"
$xmlMSI = "$path\Msi.xml"
$xmlAppX  = "$path\AppXRules.xml"
$xmlPath = "$path\PathRules.xml"
$xmldnyWin = "$path\dnyWin.xml"
$xmldnyWinNet = "$path\dnyWinNet.xml"
$xmldnyWin32 = "$path\dnyWin32.xml"
$xmldnyWin64 = "$path\dnyWin64.xml"
$xmldnyProg32 = "$path\dnyProg32.xml"
$xmldnyProg64 = "$path\dnyProg64.xml"
$xmldnyWinSxs = "$path\dnyWinSxs.xml"
$xmldnyPS = "$path\dnyPS.xml"

#Block the following files
$dny = 
"gathernetworkInfo.vbs", #system info gather
"installutil.Exe",       #Applocker bypass
"scrobj.dll",
"atbroker.exe",
"sos.dll",
"cipher.Exe",            #Used by malware to permanently delete or encrypt files 
"certutil.exe",          #Used by hackers to download files and encode text, base64
"csc.exe",               #Used in conjunction with InstallUtil.exe to csharp to exe a file
"cmd.exe",               #Creates data streams
"ExtExport.exe",         #Loads and executes dll's from other folders and used as part of Astaroth malware
"cmstp.exe",
"xwizard.exe",
"odbcconf.exe",
"te.exe",
"fodhelper.exe",         #Used in UAC bypass, used to manage optional language features.
"mavinject32.exe",
"msdt.exe",              #Follina
"MpCmdRun.exe",          #remote copy
"fsutil.exe",            #Used to bypass Applocker path rules
"mklink.exe",            #Used to bypass Applocker path rules
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
"wmic.exe" 

$dnyPSExe =
"Powershell.exe",
"Powershell_ise.exe",
"system.management.automation.dll"

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

#To save scanning the entire C:\Windows, named directories are scanned based on the list of denied files
#Dont add WinSXS, System32 or SysWow64

<#
#Pre-check standalone process

#Query takes the deny files and finds all directories the files are located in.
#The directories are then added to $dynWinNetPaths variable
#
$ardnyWin=@()
$dnyWinFileInf=@()
foreach ($dnyWin in $dny)
    {
   $dnyWinFileInf = Get-ChildItem -Path C:\Windows\ -Recurse -Force -ErrorAction SilentlyContinue | 
   Where {$_.fullName -notmatch "sysWOW64" `
   -and $_.fullName -notmatch "system32" `
   -and $_.fullName -notmatch "winsxs" `
   -and $_.fullName -notmatch "prefetch" `
   -and $_.fullName -notmatch "LCU" `
   -and $_.name -match $dnyWin } 
  
    $dnyWinFileFullname = $dnyWinFileInf.fullname
    $dnyWinFileFullname
    $ardnyWin += $dnyWinFileFullname
}

#>

$dynWinNetPaths = "C:\Windows\Microsoft.NET\"
$ardnyWinNet=@()
foreach ($dynWinNetItem in $dynWinNetPaths)
{ 
    foreach ($dnyWin in $dny)
        {
        $dnyWinNetFileInf = Get-ChildItem -Path $dynWinNetItem -Recurse -Force -ErrorAction SilentlyContinue | 
        Where {$_.name -eq $dnyWin} 
        $dnyWinNetFullname = $dnyWinNetFileInf.FullName
        $dnyWinNetFullname 
        $ardnyWinNet += $dnyWinNetFullname
        }
    sleep 5
    ForEach-Object {$ardnyWinNet} |
    Get-AppLockerFileInformation -ErrorAction SilentlyContinue | 
    New-AppLockerPolicy -RuleType Hash -Xml | 
    Out-File $xmldnyWinNet
}

#Windows root folder only
$ardnyWin=@()
foreach ($dnyWin in $dny)
    {
    $dnyWinFileInf = Get-ChildItem -Path C:\Windows\ -Force -ErrorAction SilentlyContinue | 
    Where {$_.name -eq $dnyWin} 
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

$gcdnyWinNet = get-content $xmldnyWinNet
$gcdnyWinNet.Replace("Allow","Deny").Replace("NotConfigured","Enabled") | 
Out-File $xmldnyWinNet

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

$ccPack = get-content $xmlAppX
$ccPack.Replace("NotConfigured","Enabled") | 
Out-File $xmlAppX

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

Set-AppLockerPolicy -XmlPolicy $xmlExe -Ldap "LDAP://$dom/$cn" #Removes current GPO settings, assists with successful import
sleep 15
Set-AppLockerPolicy -XmlPolicy $xmlScript -Ldap "LDAP://$dom/$cn" -Merge 
sleep 15
Set-AppLockerPolicy -XmlPolicy $xmlMSI -Ldap "LDAP://$dom/$cn" -Merge 
sleep 15
Set-AppLockerPolicy -XmlPolicy $xmlPath -Ldap "LDAP://$dom/$cnPath"
sleep 15
Set-AppLockerPolicy -XmlPolicy $xmlAppX -Ldap "LDAP://$dom/$cn" -Merge 
sleep 150

Set-AppLockerPolicy -XmlPolicy $xmldnyWinNet -Ldap "LDAP://$dom/$cn" -Merge 
sleep 15
Set-AppLockerPolicy -XmlPolicy $xmldnyWin -Ldap "LDAP://$dom/$cn" -Merge 
sleep 15
Set-AppLockerPolicy -XmlPolicy $xmldnyWin32 -Ldap "LDAP://$dom/$cn" -Merge 
sleep 15
Set-AppLockerPolicy -XmlPolicy $xmldnyWin64 -Ldap "LDAP://$dom/$cn" -Merge 
sleep 15
Set-AppLockerPolicy -XmlPolicy $xmldnyWinSxs -Ldap "LDAP://$dom/$cn" -Merge 
sleep 15
Set-AppLockerPolicy -XmlPolicy $xmldnyProg64 -Ldap "LDAP://$dom/$cn" -Merge 
sleep 15
Set-AppLockerPolicy -XmlPolicy $xmldnyProg32 -Ldap "LDAP://$dom/$cn" -Merge 
sleep 15
Set-AppLockerPolicy -XmlPolicy $xmldnyPS -Ldap "LDAP://$dom/$cnAdmin"
sleep 15

