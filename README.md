# Windows Chrome Cookie Info Stealer Malware
## Description
Windows-Chrome-CookieStealer is a Powershell script that steals all cookies from the Chrome browser, including Session Cookies. It does this by briefly opening the Chrome browser in headless debugging mode. The Cookies are retrieved and sent via SMTP to an e-mail address of your choice. The info is deliverd in json-format in the body of the mail. Replace the SMTP settings before use.

## MSI file
The .MSI file can not bypass all AV's, but it is not detected by 85% of them. Only 5 mark it as suspicious on TotalVirus. More can be done to further obfuscate and hide the real intentions of the program.

## Run the powershell command
Powershell 7 is required
```pwsh.exe ChromeWindowsCookieStealer.ps1```
Conversion to .msi is done with PowerShell Studio
