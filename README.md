# Applocker

Full details of the script and how it works can be found at https://www.tenaka.net/applockergpo

Applocker is going to be put through it's paces with various attacks and mitigations. To this end the configuration will be consistent for the various tests with more or less out of the box policy, approving everything currently installed. Any program not whitelisted is implicitly denied. This page will describe how Applocker is configured. There will be no Deny rules unless stated.

Applocker is available with Windows 7 Ultimate and Enterprise, Windows 8 and 10 Pro Editions and is a application whitelisting service that is meant to keep the system safe from malware executing. It does this via GPO and Publisher, Hash and Path rules for the following file types:


Executables (.exe, .com)
Dll's (.ocx, . dll)
Scripts (.vbs, .js, .ps1, .cmd, .bat)
Windows Installers (.msi, .mst, .msp)
Packaged App (.appx)


There is an undocumented feature of blocking API's when DLL enforcement is enabled, requiring path rules to allow.Applocker will be configured to protect all files on C:\, enforcing Executables, Dll's and Installers by Publisher and falling back to Hash. The default rules wont be added with the exception of DLL and Packaged App Rules. The default rules are too easy to bypass, however approving all DLL's so performance isn't impacted involves too much time and effort for these demo's.

To configure Applocker open Gpedit.msc or Group Policy Management, browse to Computer Configuration > Windows Settings > Security Settings > Application Control Policies > Applocker.
