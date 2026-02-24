# Changelog

## [1.0] — Initial Public Release

### Added

- WPF/XAML UI built with PowerShell 5.1 + .NET Framework
- Multi-tenant support via Directory (Tenant) ID and SharePoint prefix inputs
- **Identity & Access** section: M365 Admin, Entra ID, Azure Portal, Lighthouse
- **Messaging & Collaboration** section: Exchange, Teams, SharePoint, OneDrive
- **Security & Compliance** section: Security Center, Compliance, Purview, Defender XDR
- **Device Management** section: Intune, Endpoint Security, Autopilot
- **Apps & Services** section: Power Platform, Power BI, Viva Insights, Viva Learning
- Live search/filter box (top-right) filters buttons by name, category, or description
- Segoe MDL2 Assets glyph icons on every admin center button
- Contextual "Where to find" help dialogs for Tenant ID and SharePoint Prefix fields
- Config persistence: settings saved to `%APPDATA%\M365AdminTool\config.json`
- Reset button: clears fields and deletes saved config with confirmation prompt
- Close-to-tray: optional minimize to system tray with NotifyIcon + context menu
- Rounded-corner button styles with hover/press visual feedback
- Status bar showing last action and tool version
- CI workflow: PSScriptAnalyzer lint on every push/PR
- Code scanning: PSScriptAnalyzer SARIF uploaded to GitHub Security tab
- CodeQL workflow for GitHub Actions workflow files
- Release workflow: auto-builds Windows EXE via PS2EXE on GitHub release creation
