cd C:\GitHub-Repos\m365-admin-tool\src\

Get-Content ".\M365AdminTool.ps1" -Raw |
Invoke-Formatter -Settings "..\PSScriptAnalyzerSettings.psd1" |
Set-Content ".\M365AdminTool.ps1"