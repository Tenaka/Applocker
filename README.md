# Applocker

Full details of the script and how it works can be found at https://www.tenaka.net/applockergpo

Applocker is available with Windows 7 Ultimate and Enterprise, Windows 8 and 10 Enterprise edition and is a application whitelisting service that is meant to keep the system safe from malware executing. It does this via GPO and Publisher, Hash and Path rules for the following file types:

Executables (.exe, .com)
Dll's (.ocx, . dll)
Scripts (.vbs, .js, .ps1, .cmd, .bat)
Windows Installers (.msi, .mst, .msp)
Packaged App (.appx)

There is an undocumented feature of blocking API's when DLL enforcement is enabled, requiring path rules to allow. Applocker will be configured to protect all files on C:\, enforcing Executables, Dll's and Installers by Publisher and falling back to Hash. The default rules wont be added with the exception of DLL and Packaged App Rules. The default rules are too easy to bypass.

