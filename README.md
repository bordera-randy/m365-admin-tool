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
 | **20 admin centers**         | Identity, Messaging, Security, Devices, Apps & Services — all covered                 |
 | **Live search**              | Filter buttons in real-time by name, category, or description                         |
 | **Segoe MDL2 icons**         | Every button displays a crisp native Windows glyph                                    |
 | **Config persistence**       | Settings saved to `%APPDATA%\M365AdminTool\config.json`                               |
 | **Reset button**             | Clears fields and deletes the saved config (with confirmation)                        |
 | **Close-to-tray**            | Optional: minimize to system tray with restore/exit context menu                      |
 | **Help dialogs**             | "Where to find" pop-ups for Tenant ID and SharePoint Prefix                           |
 | **Hover / press effects**    | Blue border + light-blue background on mouse-over                                     |

---

## Admin Centers

### Identity & Access

- **M365 Admin** — Microsoft 365 Admin Center
- **Entra ID** — Microsoft Entra ID (Azure Active Directory)
- **Azure Portal** — Azure Portal (scoped to your tenant)
- **Lighthouse** — Microsoft 365 Lighthouse (multi-tenant management)

### Messaging & Collaboration

- **Exchange** — Exchange Online Admin Center
- **Teams** — Microsoft Teams Admin Center
- **SharePoint** — SharePoint Admin Center *(requires SharePoint Prefix)*
- **OneDrive** — OneDrive Admin *(requires SharePoint Prefix)*

### Security & Compliance

- **Security** — Microsoft Defender Security Center
- **Compliance** — Microsoft Purview Compliance Portal
- **Purview** — Microsoft Purview unified governance
- **Defender XDR** — Microsoft Defender Extended Detection & Response

### Device Management

- **Intune** — Microsoft Intune (Endpoint Manager)
- **Endpoint Security** — Intune Endpoint Security policies
- **Autopilot** — Windows Autopilot

### Apps & Services

- **Power Platform** — Power Platform Admin Center
- **Power BI** — Power BI Admin Portal
- **Viva Insights** — Microsoft Viva Insights
- **Viva Learning** — Viva Learning Admin

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

Click **Save** to persist the values to `%APPDATA%\M365AdminTool\config.json`.  
Click **Reset** to clear all fields and delete the saved config.

> Use the **ⓘ** help buttons next to each field for step-by-step guidance.

---

## Project Structure

```
m365-admin-tool/
├── .github/
│   └── workflows/
│       ├── ci.yml              # Lint on push/PR
│       ├── codeql.yml          # CodeQL scanning
│       ├── ps-analysis.yml     # PSScriptAnalyzer → SARIF
│       └── release.yml         # Build EXE on release
├── src/
│   └── M365AdminTool.ps1       # Main WPF/XAML PowerShell script
├── .gitignore
├── CHANGELOG.md
├── PSScriptAnalyzerSettings.psd1
└── README.md
```

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

---

## Author

**Randy Bordeaux** — [github.com/bordera-randy](https://github.com/bordera-randy)

---

## License

This project is licensed under the [MIT License](LICENSE).
