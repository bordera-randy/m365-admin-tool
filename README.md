# Microsoft 365 Admin Tool

[![CI – Lint & Analyse](https://github.com/bordera-randy/m365-admin-tool/actions/workflows/ci.yml/badge.svg)](https://github.com/bordera-randy/m365-admin-tool/actions/workflows/ci.yml)
[![CodeQL](https://github.com/bordera-randy/m365-admin-tool/actions/workflows/codeql.yml/badge.svg)](https://github.com/bordera-randy/m365-admin-tool/actions/workflows/codeql.yml)
[![PowerShell Code Analysis](https://github.com/bordera-randy/m365-admin-tool/actions/workflows/ps-analysis.yml/badge.svg)](https://github.com/bordera-randy/m365-admin-tool/actions/workflows/ps-analysis.yml)

A graphical admin tool that gives you one-click access to every Microsoft 365 admin portal — with full multi-tenant support, live search, config persistence, and an optional system tray.

---

## Features

 | Feature                      | Details                                                                               |
 |------------------------------|---------------------------------------------------------------------------------------|
 | **Multi-tenant**             | Enter your Directory (Tenant) ID and SharePoint prefix once; every button uses them   |
 | **17 admin centers**         | Core, Identity, Messaging, Collaboration, Security, Devices, Power Platform           |
 | **Live search**              | Filter buttons in real-time by name, category, or description                         |
 | **Segoe MDL2 icons**         | Every button displays a crisp native Windows glyph                                    |
 | **Config persistence**       | Settings saved to `%APPDATA%\PowerShell-Utility\M365Launcher\config.json`             |
 | **Reset button**             | Clears fields and deletes the saved config (with confirmation)                        |
 | **Close-to-tray**            | Optional: minimize to system tray with restore/exit context menu                      |
 | **Help dialogs**             | "Where to find" pop-ups for Tenant ID and SharePoint Prefix                           |
 | **Hover / press effects**    | Lift animation and enhanced drop shadow on mouse-over                                 |

---

## Admin Centers

### Core

- **Microsoft 365 Admin Center** — Primary admin portal
- **Users** — User accounts and licensing
- **Licenses** — License and subscription management
- **Billing** — Billing accounts and invoices
- **Domains** — Domain and DNS management

### Messaging & Collaboration

- **Exchange Admin Center** — Exchange Online Admin Center
- **Teams Admin Center** — Microsoft Teams Admin Center
- **SharePoint Admin Center** — SharePoint Admin *(requires SharePoint Prefix)*
- **OneDrive Admin** — OneDrive settings *(requires SharePoint Prefix)*

### Identity & Azure

- **Entra ID Admin Center** — Microsoft Entra ID / Azure AD *(uses Tenant ID when set)*
- **Azure Portal** — Azure Portal

### Security & Compliance

- **Microsoft Defender Portal** — Defender for Endpoint and XDR
- **Microsoft Purview Compliance** — Compliance, eDiscovery, and retention policies
- **Microsoft 365 Defender (legacy)** — Legacy Defender portal

### Device Management

- **Intune / Endpoint Manager** — Microsoft Intune MDM/MAM

### Power Platform

- **Power Platform Admin** — Power Platform Admin Center
- **Power BI Admin** — Power BI Admin Portal

---

## Requirements

| Requirement           | Version                   |
|-----------------------|---------------------------|
| Windows PowerShell    | 5.1 or later              |
| .NET Framework (WPF)  | Included in Windows 10/11 |
| Windows               | 10 or later               |

> **Note:** The tool opens admin portals in your default web browser. No additional PowerShell modules are needed to run it.

---

## Quick Start

### Option A — Download the EXE (recommended)

1. Go to the [Releases](https://github.com/bordera-randy/m365-admin-tool/releases) page.
2. Download `M365AdminTool.exe` from the latest release.
3. Double-click to run — no installation required.

### Option B — Run the script directly

```powershell
# Clone the repository
git clone https://github.com/bordera-randy/m365-admin-tool.git
cd m365-admin-tool

# Run the launcher
powershell -ExecutionPolicy Bypass -File src\M365AdminTool.ps1
```

---

## Configuration

On first launch, fill in the **Tenant Configuration** fields at the top of the window:

| Field | Description | How to find |
|---|---|---|
| **Directory (Tenant) ID** | Your Azure AD / Entra tenant GUID | Azure Portal → Entra ID → Overview |
| **SharePoint Prefix** | Prefix of your SharePoint admin URL | The part before `-admin.sharepoint.com` |

Click **Set Tenant** to persist the values to `%APPDATA%\PowerShell-Utility\M365Launcher\config.json`.  
Click **Reset** to clear all fields and delete the saved config.

> Use the **?** help buttons next to each field for step-by-step guidance.

---

## Project Structure

```
m365-admin-tool/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── custom.md
│   │   └── feature_request.md
│   ├── img/
│   │   └── m365-admin-tool-social-preview.jpg
│   ├── workflows/
│   │   ├── ci.yml              # PSScriptAnalyzer lint on push/PR
│   │   ├── codeql.yml          # CodeQL scanning for workflow files
│   │   ├── ps-analysis.yml     # PSScriptAnalyzer → SARIF upload
│   │   └── release.yml         # Build EXE with PS2EXE on release
│   ├── CODE_OF_CONDUCT.md
│   ├── CONTRIBUTING.md
│   ├── pull_request_template.md
│   ├── RELEASE_TEMPLATE.md
│   └── SECURITY.MD
├── src/
│   └── M365AdminTool.ps1       # Main WPF/XAML PowerShell script
├── .gitignore
├── CHANGELOG.md
├── LICENSE
├── PSScriptAnalyzerSettings.psd1
└── README.md
```

---

## CI/CD Workflows

| Workflow | Trigger | Purpose |
|---|---|---|
| **CI – Lint & Analyse** | push/PR to `main`, manual | PSScriptAnalyzer lint (Error + Warning) — fails the build on issues |
| **PowerShell Code Analysis** | push/PR to `main`, weekly, manual | PSScriptAnalyzer SARIF report uploaded to GitHub Security tab |
| **CodeQL** | push/PR to `main`, weekly, manual | CodeQL analysis of GitHub Actions workflow files |
| **Build and Release EXE** | GitHub release created | Compiles `M365AdminTool.ps1` to a Windows EXE using PS2EXE |

---

## Contributing

1. Fork the repository and create a feature branch.
2. Make your changes in `src/M365AdminTool.ps1`.
3. Run PSScriptAnalyzer locally before submitting a PR:
   ```powershell
   Install-Module PSScriptAnalyzer -Force -Scope CurrentUser
   Invoke-ScriptAnalyzer -Path src\M365AdminTool.ps1 -Settings PSScriptAnalyzerSettings.psd1
   ```
4. Open a Pull Request against `main`.

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for the full contribution guide and testing checklist.

---

## Security

Please review the [Security Policy](.github/SECURITY.MD) before reporting vulnerabilities.  
**Do not open public issues for security bugs** — follow the private disclosure process described in SECURITY.MD.

---

## Author

**Randy Bordeaux** — [github.com/bordera-randy](https://github.com/bordera-randy)

---

## License

MIT License — see [LICENSE](LICENSE) for details.
