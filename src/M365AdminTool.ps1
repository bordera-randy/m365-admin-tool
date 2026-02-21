#Requires -Version 5.1
<#
.SYNOPSIS
    Microsoft 365 Admin Center Quick Launcher (Multi-Tenant) - WPF/XAML
.DESCRIPTION
    WPF/XAML-based launcher with:
      - Directory (Tenant) ID and SharePoint tenant prefix inputs
      - Clear "Where to find" help + readable tooltips (no overlapping)
      - Search box in top-right
      - Section headers (Tenant Configuration, Admin Centers)
      - Button grid that auto-fills space (dynamic WrapPanel)
      - Iconography on buttons (Segoe MDL2 Assets glyphs)
      - Config persistence to %APPDATA%
      - Reset button clears fields + removes saved config
      - Close-to-tray (optional) with tray icon

.NOTES
    Author: Randy Bordeaux
    GitHub: https://github.com/bordera-randy
    Version: 3.1
    Requirements: Windows PowerShell 5.1+, .NET Framework (WPF assemblies)
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ─── Assemblies ──────────────────────────────────────────────────────────────
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ─── Constants ───────────────────────────────────────────────────────────────
$script:AppName    = 'M365AdminTool'
$script:ConfigDir  = Join-Path $env:APPDATA $script:AppName
$script:ConfigFile = Join-Path $script:ConfigDir 'config.json'
$script:Version    = '3.1'

# ─── Admin Center Definitions ────────────────────────────────────────────────
# Url placeholders: {TenantId} and {SPPrefix}
$script:AdminCenters = @(
    # Identity & Access
    [PSCustomObject]@{
        Name     = 'M365 Admin'
        Url      = 'https://admin.microsoft.com'
        Icon     = [char]0xE713
        Category = 'Identity & Access'
        Tooltip  = 'Microsoft 365 Admin Center  - Manage users, licenses, billing, and services'
    }
    [PSCustomObject]@{
        Name     = 'Entra ID'
        Url      = 'https://entra.microsoft.com'
        Icon     = [char]0xE77B
        Category = 'Identity & Access'
        Tooltip  = 'Microsoft Entra ID (Azure Active Directory)  - Identity and access management'
    }
    [PSCustomObject]@{
        Name     = 'Azure Portal'
        Url      = 'https://portal.azure.com/{TenantId}'
        Icon     = [char]0xE753
        Category = 'Identity & Access'
        Tooltip  = 'Azure Portal  - Manage Azure resources. Uses your Tenant ID to scope the session'
    }
    [PSCustomObject]@{
        Name     = 'Lighthouse'
        Url      = 'https://lighthouse.microsoft.com'
        Icon     = [char]0xE753
        Category = 'Identity & Access'
        Tooltip  = 'Microsoft 365 Lighthouse  - Manage and secure multiple customer tenants'
    }

    # Messaging & Collaboration
    [PSCustomObject]@{
        Name     = 'Exchange'
        Url      = 'https://admin.exchange.microsoft.com'
        Icon     = [char]0xE715
        Category = 'Messaging & Collaboration'
        Tooltip  = 'Exchange Online Admin Center  - Manage mailboxes, mail flow, and transport rules'
    }
    [PSCustomObject]@{
        Name     = 'Teams'
        Url      = 'https://admin.teams.microsoft.com'
        Icon     = [char]0xE716
        Category = 'Messaging & Collaboration'
        Tooltip  = 'Microsoft Teams Admin Center  - Manage Teams policies, channels, and calling'
    }
    [PSCustomObject]@{
        Name     = 'SharePoint'
        Url      = 'https://{SPPrefix}-admin.sharepoint.com'
        Icon     = [char]0xE8A0
        Category = 'Messaging & Collaboration'
        Tooltip  = 'SharePoint Admin Center  - Manage SharePoint sites, storage, and settings. Requires SharePoint Prefix'
    }
    [PSCustomObject]@{
        Name     = 'OneDrive'
        Url      = 'https://{SPPrefix}-admin.sharepoint.com/_layouts/15/online/AdminHome.aspx#/oneDriveSettings'
        Icon     = [char]0xE8B7
        Category = 'Messaging & Collaboration'
        Tooltip  = 'OneDrive Admin  - Manage OneDrive storage, sync, and data migration. Requires SharePoint Prefix'
    }

    # Security & Compliance
    [PSCustomObject]@{
        Name     = 'Security'
        Url      = 'https://security.microsoft.com'
        Icon     = [char]0xE72E
        Category = 'Security & Compliance'
        Tooltip  = 'Microsoft Defender Security Center  - Threat protection, incidents, and security analytics'
    }
    [PSCustomObject]@{
        Name     = 'Compliance'
        Url      = 'https://compliance.microsoft.com'
        Icon     = [char]0xE9D9
        Category = 'Security & Compliance'
        Tooltip  = 'Microsoft Purview Compliance Portal  - Data governance, retention, and eDiscovery'
    }
    [PSCustomObject]@{
        Name     = 'Purview'
        Url      = 'https://purview.microsoft.com'
        Icon     = [char]0xEA18
        Category = 'Security & Compliance'
        Tooltip  = 'Microsoft Purview  - Unified data governance, risk, and compliance platform'
    }
    [PSCustomObject]@{
        Name     = 'Defender XDR'
        Url      = 'https://security.microsoft.com'
        Icon     = [char]0xE8D7
        Category = 'Security & Compliance'
        Tooltip  = 'Microsoft Defender XDR  - Extended detection and response across endpoints, identity, and cloud'
    }

    # Device Management
    [PSCustomObject]@{
        Name     = 'Intune'
        Url      = 'https://intune.microsoft.com'
        Icon     = [char]0xE8EA
        Category = 'Device Management'
        Tooltip  = 'Microsoft Intune  - Endpoint management, MDM, and app protection policies'
    }
    [PSCustomObject]@{
        Name     = 'Endpoint Security'
        Url      = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/endpointSecuritySummary'
        Icon     = [char]0xECE4
        Category = 'Device Management'
        Tooltip  = 'Endpoint Security  - Manage antivirus, firewall, disk encryption, and attack surface reduction policies'
    }
    [PSCustomObject]@{
        Name     = 'Autopilot'
        Url      = 'https://intune.microsoft.com/#view/Microsoft_Intune_Enrollment/AutopilotMenuBlade/~/overview'
        Icon     = [char]0xE7C3
        Category = 'Device Management'
        Tooltip  = 'Windows Autopilot  - Automate device setup and deployment for new and reset devices'
    }

    # Apps & Services
    [PSCustomObject]@{
        Name     = 'Power Platform'
        Url      = 'https://admin.powerplatform.microsoft.com'
        Icon     = [char]0xE945
        Category = 'Apps & Services'
        Tooltip  = 'Power Platform Admin Center  - Manage Power Apps, Power Automate, Dataverse, and environments'
    }
    [PSCustomObject]@{
        Name     = 'Power BI'
        Url      = 'https://app.powerbi.com/admin-portal/tenantSettings'
        Icon     = [char]0xE9F9
        Category = 'Apps & Services'
        Tooltip  = 'Power BI Admin Portal  - Manage tenant settings, capacities, and embed codes'
    }
    [PSCustomObject]@{
        Name     = 'Viva Insights'
        Url      = 'https://insights.viva.office.com'
        Icon     = [char]0xECE7
        Category = 'Apps & Services'
        Tooltip  = 'Microsoft Viva Insights  - Workplace analytics and employee wellbeing data'
    }
    [PSCustomObject]@{
        Name     = 'Viva Learning'
        Url      = 'https://admin.microsoft.com/adminportal/home#/vivaLearning'
        Icon     = [char]0xE82D
        Category = 'Apps & Services'
        Tooltip  = 'Viva Learning Admin  - Manage learning content sources and assignments'
    }
)

# ─── Config Functions ─────────────────────────────────────────────────────────
function Get-Config {
    if (Test-Path $script:ConfigFile) {
        try {
            return Get-Content -Path $script:ConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json
        } catch {
            Write-Warning "Could not read config: $($_.Exception.Message)"
            return $null
        }
    }
    return $null
}

function Save-Config {
    param(
        [string]$TenantId,
        [string]$SPPrefix,
        [bool]$CloseToTray
    )
    if (-not (Test-Path $script:ConfigDir)) {
        $null = New-Item -ItemType Directory -Path $script:ConfigDir -Force
    }
    [PSCustomObject]@{
        TenantId    = $TenantId
        SPPrefix    = $SPPrefix
        CloseToTray = $CloseToTray
    } | ConvertTo-Json | Set-Content -Path $script:ConfigFile -Encoding UTF8
}

function Remove-Config {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if (Test-Path $script:ConfigFile) {
        if ($PSCmdlet.ShouldProcess($script:ConfigFile, 'Remove configuration file')) {
            Remove-Item -Path $script:ConfigFile -Force
        }
    }
}

# ─── URL Builder ─────────────────────────────────────────────────────────────
function Build-Url {
    param(
        [string]$UrlTemplate,
        [string]$TenantId,
        [string]$SPPrefix
    )
    $url = $UrlTemplate
    if ($TenantId) {
        $url = $url -replace '\{TenantId\}', [uri]::EscapeDataString($TenantId)
    } else {
        $url = $url -replace '/\{TenantId\}', ''
        $url = $url -replace '\{TenantId\}', ''
    }
    $url = $url -replace '\{SPPrefix\}', $SPPrefix
    return $url
}

function Open-AdminUrl {
    param([string]$Url, [string]$Name, [string]$SPPrefix)

    if ($Url -match '\{SPPrefix\}' -and [string]::IsNullOrWhiteSpace($SPPrefix)) {
        [System.Windows.MessageBox]::Show(
            "The '$Name' admin center requires a SharePoint Tenant Prefix.`n`nPlease enter your SharePoint prefix in the Tenant Configuration section above and click Save.",
            'SharePoint Prefix Required',
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Warning
        ) | Out-Null
        return
    }
    try {
        Start-Process $Url
    } catch {
        [System.Windows.MessageBox]::Show(
            "Failed to open URL:`n$Url`n`n$($_.Exception.Message)",
            'Error',
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        ) | Out-Null
    }
}

# ─── Tray Icon ────────────────────────────────────────────────────────────────
function New-TrayIcon {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if (-not $PSCmdlet.ShouldProcess('system tray', 'Add notification icon')) { return $null }

    # Create a simple programmatic icon (blue circle with white "M")
    $bitmap = [System.Drawing.Bitmap]::new(32, 32)
    $g = [System.Drawing.Graphics]::FromImage($bitmap)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)
    $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(0, 120, 212))
    $g.FillEllipse($brush, 1, 1, 29, 29)
    $font = [System.Drawing.Font]::new('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
    $textBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $sf = [System.Drawing.StringFormat]::new()
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString('M', $font, $textBrush, [System.Drawing.RectangleF]::new(0, 0, 32, 32), $sf)
    $g.Dispose()
    $font.Dispose()
    $brush.Dispose()
    $textBrush.Dispose()
    $sf.Dispose()

    $hIcon = $bitmap.GetHicon()
    $bitmap.Dispose()
    $icon = [System.Drawing.Icon]::FromHandle($hIcon)

    $trayIcon = [System.Windows.Forms.NotifyIcon]::new()
    $trayIcon.Icon = $icon
    $trayIcon.Text = "M365 Admin Tool v$($script:Version)"
    $trayIcon.Visible = $true

    $contextMenu = [System.Windows.Forms.ContextMenuStrip]::new()
    $showItem    = $contextMenu.Items.Add('Show Window')
    $exitItem    = $contextMenu.Items.Add('Exit')

    $showItem.add_Click({
        $window.Show()
        $window.WindowState = [System.Windows.WindowState]::Normal
        $window.Activate()
    })

    $exitItem.add_Click({
        $trayIcon.Visible = $false
        $trayIcon.Dispose()
        $icon.Dispose()
        $window.Tag = 'ForceClose'
        $window.Close()
    })

    $trayIcon.ContextMenuStrip = $contextMenu

    $trayIcon.add_DoubleClick({
        $window.Show()
        $window.WindowState = [System.Windows.WindowState]::Normal
        $window.Activate()
    })

    return $trayIcon
}

# ─── XAML ─────────────────────────────────────────────────────────────────────
[xml]$XAML = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Microsoft 365 Admin Tool"
    Width="980" Height="700"
    MinWidth="660" MinHeight="500"
    WindowStartupLocation="CenterScreen"
    UseLayoutRounding="True">

    <Window.Resources>

        <!-- Admin center button style with rounded corners + hover triggers -->
        <Style x:Key="AdminButtonStyle" TargetType="Button">
            <Setter Property="Background"       Value="White"/>
            <Setter Property="BorderBrush"      Value="#E0E0E0"/>
            <Setter Property="BorderThickness"  Value="1"/>
            <Setter Property="Margin"           Value="4"/>
            <Setter Property="Padding"          Value="0"/>
            <Setter Property="Cursor"           Value="Hand"/>
            <Setter Property="Width"            Value="130"/>
            <Setter Property="Height"           Value="80"/>
            <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border
                            x:Name="Bd"
                            Background="{TemplateBinding Background}"
                            BorderBrush="{TemplateBinding BorderBrush}"
                            BorderThickness="{TemplateBinding BorderThickness}"
                            CornerRadius="6"
                            SnapsToDevicePixels="True">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background"   Value="#E8F0FE"/>
                                <Setter TargetName="Bd" Property="BorderBrush"  Value="#0078D4"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Bd" Property="Background"   Value="#D0E4FC"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Action button style (Save / Reset in header) -->
        <Style x:Key="ActionButtonStyle" TargetType="Button">
            <Setter Property="Background"       Value="White"/>
            <Setter Property="Foreground"       Value="#0078D4"/>
            <Setter Property="BorderBrush"      Value="White"/>
            <Setter Property="BorderThickness"  Value="1"/>
            <Setter Property="Padding"          Value="12,0"/>
            <Setter Property="Height"           Value="32"/>
            <Setter Property="Cursor"           Value="Hand"/>
            <Setter Property="FontFamily"       Value="Segoe UI"/>
            <Setter Property="FontSize"         Value="12"/>
            <Setter Property="FontWeight"       Value="SemiBold"/>
            <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border
                            x:Name="Bd"
                            Background="{TemplateBinding Background}"
                            BorderBrush="{TemplateBinding BorderBrush}"
                            BorderThickness="{TemplateBinding BorderThickness}"
                            CornerRadius="4"
                            Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="#E8F0FE"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="#D0E4FC"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Input (TextBox) style with rounded border + focus highlight -->
        <Style x:Key="InputStyle" TargetType="TextBox">
            <Setter Property="Background"              Value="White"/>
            <Setter Property="BorderBrush"             Value="#CCCCCC"/>
            <Setter Property="BorderThickness"         Value="1"/>
            <Setter Property="Padding"                 Value="8,0"/>
            <Setter Property="FontSize"                Value="13"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TextBox">
                        <Border
                            x:Name="Bd"
                            Background="{TemplateBinding Background}"
                            BorderBrush="{TemplateBinding BorderBrush}"
                            BorderThickness="{TemplateBinding BorderThickness}"
                            CornerRadius="4">
                            <ScrollViewer x:Name="PART_ContentHost"
                                          Padding="{TemplateBinding Padding}"
                                          VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsFocused" Value="True">
                                <Setter TargetName="Bd" Property="BorderBrush" Value="#0078D4"/>
                                <Setter TargetName="Bd" Property="BorderThickness" Value="2"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

    </Window.Resources>

    <DockPanel>

        <!-- ═══ HEADER / TENANT CONFIGURATION ════════════════════════════════ -->
        <Border DockPanel.Dock="Top" Background="#0078D4" Padding="16,12,16,14">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <!-- Left: app title + tenant config -->
                <StackPanel Grid.Column="0">

                    <!-- Title row -->
                    <StackPanel Orientation="Horizontal" Margin="0,0,0,12">
                        <TextBlock Text="&#xE713;"
                                   FontFamily="Segoe MDL2 Assets"
                                   FontSize="22"
                                   Foreground="White"
                                   VerticalAlignment="Center"
                                   Margin="0,0,8,0"/>
                        <TextBlock Text="Microsoft 365 Admin Tool"
                                   FontSize="18"
                                   FontWeight="SemiBold"
                                   Foreground="White"
                                   VerticalAlignment="Center"/>
                    </StackPanel>

                    <!-- Section label -->
                    <TextBlock Text="TENANT CONFIGURATION"
                               FontSize="10"
                               FontWeight="Bold"
                               Foreground="#B3D7F5"
                               Margin="0,0,0,8"/>

                    <!-- Config fields row -->
                    <WrapPanel Orientation="Horizontal">

                        <!-- Directory (Tenant) ID -->
                        <StackPanel Margin="0,0,12,0" Width="300">
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,4">
                                <TextBlock Text="Directory (Tenant) ID"
                                           Foreground="#E0F0FF"
                                           FontSize="12"
                                           VerticalAlignment="Center"/>
                                <Button x:Name="TenantIdHelpBtn"
                                        Content="&#xE9CE;"
                                        FontFamily="Segoe MDL2 Assets"
                                        FontSize="12"
                                        Foreground="#B3D7F5"
                                        Background="Transparent"
                                        BorderThickness="0"
                                        Cursor="Hand"
                                        Padding="4,0,0,0"
                                        VerticalAlignment="Center"
                                        FocusVisualStyle="{x:Null}"
                                        ToolTip="Click for help finding your Tenant ID"/>
                            </StackPanel>
                            <TextBox x:Name="TenantIdBox"
                                     Style="{StaticResource InputStyle}"
                                     Height="32"
                                     ToolTip="Enter your Azure AD / Entra Directory (Tenant) ID&#x0a;Format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx&#x0a;Find it in: Azure Portal &#x2192; Entra ID &#x2192; Overview"/>
                        </StackPanel>

                        <!-- SharePoint Prefix -->
                        <StackPanel Margin="0,0,16,0" Width="200">
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,4">
                                <TextBlock Text="SharePoint Prefix"
                                           Foreground="#E0F0FF"
                                           FontSize="12"
                                           VerticalAlignment="Center"/>
                                <Button x:Name="SPPrefixHelpBtn"
                                        Content="&#xE9CE;"
                                        FontFamily="Segoe MDL2 Assets"
                                        FontSize="12"
                                        Foreground="#B3D7F5"
                                        Background="Transparent"
                                        BorderThickness="0"
                                        Cursor="Hand"
                                        Padding="4,0,0,0"
                                        VerticalAlignment="Center"
                                        FocusVisualStyle="{x:Null}"
                                        ToolTip="Click for help finding your SharePoint prefix"/>
                            </StackPanel>
                            <TextBox x:Name="SPPrefixBox"
                                     Style="{StaticResource InputStyle}"
                                     Height="32"
                                     ToolTip="Enter the prefix of your SharePoint admin URL&#x0a;Example: if URL is https://contoso-admin.sharepoint.com, enter: contoso"/>
                        </StackPanel>

                        <!-- Action buttons + checkbox -->
                        <StackPanel Margin="0,20,0,0">
                            <StackPanel Orientation="Horizontal">
                                <Button x:Name="SaveConfigBtn"
                                        Style="{StaticResource ActionButtonStyle}"
                                        Margin="0,0,8,0"
                                        ToolTip="Save tenant configuration to %APPDATA%\M365AdminTool\config.json">
                                    <StackPanel Orientation="Horizontal">
                                        <TextBlock Text="&#xE74E;"
                                                   FontFamily="Segoe MDL2 Assets"
                                                   FontSize="13"
                                                   Foreground="#0078D4"
                                                   VerticalAlignment="Center"
                                                   Margin="0,0,6,0"/>
                                        <TextBlock Text="Save"
                                                   FontFamily="Segoe UI"
                                                   FontSize="12"
                                                   Foreground="#0078D4"
                                                   VerticalAlignment="Center"/>
                                    </StackPanel>
                                </Button>
                                <Button x:Name="ResetConfigBtn"
                                        Style="{StaticResource ActionButtonStyle}"
                                        ToolTip="Clear all fields and remove saved configuration">
                                    <StackPanel Orientation="Horizontal">
                                        <TextBlock Text="&#xE72C;"
                                                   FontFamily="Segoe MDL2 Assets"
                                                   FontSize="13"
                                                   Foreground="#C42B1C"
                                                   VerticalAlignment="Center"
                                                   Margin="0,0,6,0"/>
                                        <TextBlock Text="Reset"
                                                   FontFamily="Segoe UI"
                                                   FontSize="12"
                                                   Foreground="#C42B1C"
                                                   VerticalAlignment="Center"/>
                                    </StackPanel>
                                </Button>
                            </StackPanel>
                            <CheckBox x:Name="CloseToTrayCheck"
                                      Content="Minimize to tray"
                                      Foreground="#E0F0FF"
                                      FontSize="11"
                                      Margin="2,8,0,0"
                                      ToolTip="When enabled, closing the window sends it to the system tray instead of exiting"/>
                        </StackPanel>

                    </WrapPanel>
                </StackPanel>

                <!-- Right: Search -->
                <StackPanel Grid.Column="1" VerticalAlignment="Top" Margin="16,0,0,0" Width="210">
                    <TextBlock Text="SEARCH ADMIN CENTERS"
                               FontSize="10"
                               FontWeight="Bold"
                               Foreground="#B3D7F5"
                               Margin="0,0,0,8"/>
                    <Grid>
                        <TextBox x:Name="SearchBox"
                                 Style="{StaticResource InputStyle}"
                                 Height="32"
                                 ToolTip="Filter admin center buttons by name or category"/>
                        <TextBlock x:Name="SearchPlaceholder"
                                   Text="&#xE711;  Search..."
                                   FontFamily="Segoe MDL2 Assets, Segoe UI"
                                   FontSize="13"
                                   Foreground="#999999"
                                   IsHitTestVisible="False"
                                   VerticalAlignment="Center"
                                   Margin="10,0,0,0"/>
                    </Grid>
                </StackPanel>

            </Grid>
        </Border>

        <!-- ═══ STATUS BAR ════════════════════════════════════════════════════ -->
        <StatusBar DockPanel.Dock="Bottom"
                   Background="White"
                   BorderBrush="#E0E0E0"
                   BorderThickness="0,1,0,0">
            <StatusBarItem>
                <TextBlock x:Name="StatusText"
                           FontSize="11"
                           Foreground="#555555"/>
            </StatusBarItem>
            <StatusBarItem HorizontalAlignment="Right">
                <TextBlock Text="v3.1  |  Randy Bordeaux  |  github.com/bordera-randy"
                           FontSize="10"
                           Foreground="#AAAAAA"/>
            </StatusBarItem>
        </StatusBar>

        <!-- ═══ ADMIN CENTERS (scrollable) ════════════════════════════════════ -->
        <ScrollViewer VerticalScrollBarVisibility="Auto"
                      HorizontalScrollBarVisibility="Disabled"
                      Background="#F3F3F3">
            <StackPanel x:Name="AdminCentersPanel"
                        Margin="8,4,8,8"/>
        </ScrollViewer>

    </DockPanel>
</Window>
'@

# ─── Load XAML Window ─────────────────────────────────────────────────────────
try {
    $reader = [System.Xml.XmlNodeReader]::new($XAML)
    $window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    [System.Windows.MessageBox]::Show(
        "Failed to load UI layout.`n`n$($_.Exception.Message)",
        'M365 Admin Tool  - Fatal Error',
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    ) | Out-Null
    exit 1
}

# ─── Find Named Controls ──────────────────────────────────────────────────────
$TenantIdBox       = $window.FindName('TenantIdBox')
$SPPrefixBox       = $window.FindName('SPPrefixBox')
$SaveConfigBtn     = $window.FindName('SaveConfigBtn')
$ResetConfigBtn    = $window.FindName('ResetConfigBtn')
$CloseToTrayCheck  = $window.FindName('CloseToTrayCheck')
$SearchBox         = $window.FindName('SearchBox')
$SearchPlaceholder = $window.FindName('SearchPlaceholder')
$AdminCentersPanel = $window.FindName('AdminCentersPanel')
$StatusText        = $window.FindName('StatusText')
$TenantIdHelpBtn   = $window.FindName('TenantIdHelpBtn')
$SPPrefixHelpBtn   = $window.FindName('SPPrefixHelpBtn')

$script:TrayIcon   = $null

# ─── Build Admin Center Buttons ───────────────────────────────────────────────
function Build-AdminCenterButton {
    param([string]$Filter = '')

    $AdminCentersPanel.Children.Clear()

    $blueColor  = [System.Windows.Media.Color]::FromRgb(0, 120, 212)
    $darkColor  = [System.Windows.Media.Color]::FromRgb(26, 26, 26)
    $catBgColor = [System.Windows.Media.Color]::FromRgb(240, 246, 255)
    $catBdColor = [System.Windows.Media.Color]::FromRgb(204, 224, 245)

    $filtered = $script:AdminCenters | Where-Object {
        $Filter -eq '' -or
        $_.Name     -like "*$Filter*" -or
        $_.Category -like "*$Filter*" -or
        $_.Tooltip  -like "*$Filter*"
    }

    if ($null -eq $filtered -or @($filtered).Count -eq 0) {
        $noResult = [System.Windows.Controls.TextBlock]::new()
        $noResult.Text = "No admin centers match '$Filter'. Try a different search term."
        $noResult.FontSize = 14
        $noResult.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.Color]::FromRgb(102, 102, 102))
        $noResult.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
        $noResult.Margin = [System.Windows.Thickness]::new(0, 48, 0, 0)
        [void]$AdminCentersPanel.Children.Add($noResult)
        return
    }

    $groups = @($filtered) | Group-Object -Property Category

    foreach ($group in $groups) {
        # Category header bar
        $headerBorder = [System.Windows.Controls.Border]::new()
        $headerBorder.Background = [System.Windows.Media.SolidColorBrush]::new($catBgColor)
        $headerBorder.BorderBrush = [System.Windows.Media.SolidColorBrush]::new($catBdColor)
        $headerBorder.BorderThickness = [System.Windows.Thickness]::new(0, 0, 0, 1)
        $headerBorder.Margin = [System.Windows.Thickness]::new(0, 10, 0, 0)
        $headerBorder.Padding = [System.Windows.Thickness]::new(10, 7, 10, 7)
        $headerBorder.CornerRadius = [System.Windows.CornerRadius]::new(4, 4, 0, 0)

        $headerText = [System.Windows.Controls.TextBlock]::new()
        $headerText.Text = $group.Name.ToUpper()
        $headerText.FontSize = 11
        $headerText.FontWeight = [System.Windows.FontWeights]::SemiBold
        $headerText.Foreground = [System.Windows.Media.SolidColorBrush]::new($blueColor)
        $headerBorder.Child = $headerText
        [void]$AdminCentersPanel.Children.Add($headerBorder)

        # Buttons WrapPanel
        $wrapPanel = [System.Windows.Controls.WrapPanel]::new()
        $wrapPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
        $wrapPanel.Margin = [System.Windows.Thickness]::new(0, 4, 0, 4)

        foreach ($center in $group.Group) {
            # Create button
            $btn = [System.Windows.Controls.Button]::new()
            $btn.Style   = $window.Resources['AdminButtonStyle']
            $btn.ToolTip = $center.Tooltip

            # Button content: icon (Segoe MDL2) + label
            $sp = [System.Windows.Controls.StackPanel]::new()
            $sp.Orientation = [System.Windows.Controls.Orientation]::Vertical

            $iconTb = [System.Windows.Controls.TextBlock]::new()
            $iconTb.Text = $center.Icon
            $iconTb.FontFamily = [System.Windows.Media.FontFamily]::new('Segoe MDL2 Assets')
            $iconTb.FontSize = 24
            $iconTb.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
            $iconTb.Foreground = [System.Windows.Media.SolidColorBrush]::new($blueColor)

            $nameTb = [System.Windows.Controls.TextBlock]::new()
            $nameTb.Text = $center.Name
            $nameTb.FontSize = 11
            $nameTb.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
            $nameTb.TextAlignment = [System.Windows.TextAlignment]::Center
            $nameTb.TextWrapping = [System.Windows.TextWrapping]::Wrap
            $nameTb.Margin = [System.Windows.Thickness]::new(4, 4, 4, 0)
            $nameTb.Foreground = [System.Windows.Media.SolidColorBrush]::new($darkColor)

            [void]$sp.Children.Add($iconTb)
            [void]$sp.Children.Add($nameTb)
            $btn.Content = $sp

            # Click handler  - capture loop variables via closure
            $capturedUrl  = $center.Url
            $capturedName = $center.Name
            $btn.add_Click({
                $tid = $TenantIdBox.Text.Trim()
                $spp = $SPPrefixBox.Text.Trim()
                $url = Build-Url -UrlTemplate $capturedUrl -TenantId $tid -SPPrefix $spp
                Open-AdminUrl -Url $url -Name $capturedName -SPPrefix $spp
                $StatusText.Text = "Opened: $capturedName"
            }.GetNewClosure())

            [void]$wrapPanel.Children.Add($btn)
        }

        [void]$AdminCentersPanel.Children.Add($wrapPanel)
    }
}

# ─── Load Saved Config ────────────────────────────────────────────────────────
$savedConfig = Get-Config
if ($savedConfig) {
    $TenantIdBox.Text = if ($null -ne $savedConfig.TenantId) { $savedConfig.TenantId } else { '' }
    $SPPrefixBox.Text = if ($null -ne $savedConfig.SPPrefix)  { $savedConfig.SPPrefix }  else { '' }
    $CloseToTrayCheck.IsChecked = [bool]($savedConfig.CloseToTray)
    $StatusText.Text = 'Configuration loaded from saved settings.'
} else {
    $StatusText.Text = "Welcome to M365 Admin Tool v$($script:Version)  - Enter your tenant details above to get started."
}

# ─── Search: placeholder + live filter ───────────────────────────────────────
$SearchBox.add_TextChanged({
    $SearchPlaceholder.Visibility =
        if ($SearchBox.Text.Length -eq 0) { [System.Windows.Visibility]::Visible }
        else                              { [System.Windows.Visibility]::Collapsed }
    Build-AdminCenterButton -Filter $SearchBox.Text.Trim()
})

# ─── Save Config ──────────────────────────────────────────────────────────────
$SaveConfigBtn.add_Click({
    $tid  = $TenantIdBox.Text.Trim()
    $spp  = $SPPrefixBox.Text.Trim()
    $tray = $CloseToTrayCheck.IsChecked -eq $true
    try {
        Save-Config -TenantId $tid -SPPrefix $spp -CloseToTray $tray
        $StatusText.Text = "Configuration saved  [$script:ConfigFile]"
    } catch {
        [System.Windows.MessageBox]::Show(
            "Failed to save configuration:`n$($_.Exception.Message)",
            'Save Error',
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Warning
        ) | Out-Null
    }
})

# ─── Reset Config ─────────────────────────────────────────────────────────────
$ResetConfigBtn.add_Click({
    $confirm = [System.Windows.MessageBox]::Show(
        'This will clear all fields and delete the saved configuration file. Continue?',
        'Reset Configuration',
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Question
    )
    if ($confirm -eq [System.Windows.MessageBoxResult]::Yes) {
        $TenantIdBox.Text = ''
        $SPPrefixBox.Text = ''
        $CloseToTrayCheck.IsChecked = $false
        Remove-Config
        $StatusText.Text = 'Configuration reset.'
    }
})

# ─── Help: Tenant ID ──────────────────────────────────────────────────────────
$TenantIdHelpBtn.add_Click({
    [System.Windows.MessageBox]::Show(
        "Where to find your Directory (Tenant) ID:`n`n" +
        "Option 1  - Azure Portal / Entra ID`n" +
        "  1. Open https://portal.azure.com`n" +
        "  2. Search for 'Microsoft Entra ID'`n" +
        "  3. On the Overview page, copy the Tenant ID`n`n" +
        "Option 2  - Microsoft 365 Admin Center`n" +
        "  1. Open https://admin.microsoft.com`n" +
        "  2. Settings > Org settings > Organization profile`n" +
        "  3. Locate the Tenant ID in the details`n`n" +
        "Format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        'Where to Find Your Tenant ID',
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Information
    ) | Out-Null
})

# ─── Help: SharePoint Prefix ──────────────────────────────────────────────────
$SPPrefixHelpBtn.add_Click({
    [System.Windows.MessageBox]::Show(
        "Where to find your SharePoint Tenant Prefix:`n`n" +
        "Your SharePoint admin URL follows this pattern:`n" +
        "  https://[PREFIX]-admin.sharepoint.com`n`n" +
        "Example:`n" +
        "  Full URL : https://contoso-admin.sharepoint.com`n" +
        "  Prefix   : contoso`n`n" +
        "How to find it:`n" +
        "  1. Go to https://admin.microsoft.com`n" +
        "  2. Click 'Show all' in the left navigation`n" +
        "  3. Click SharePoint`n" +
        "  4. Copy the part of the URL before '-admin.sharepoint.com'",
        'Where to Find Your SharePoint Prefix',
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Information
    ) | Out-Null
})

# ─── Close-to-Tray ────────────────────────────────────────────────────────────
$window.add_Closing({
    param($s, $e)
    # Tag = 'ForceClose' means exit from tray menu
    if ($s.Tag -eq 'ForceClose') { return }

    if ($CloseToTrayCheck.IsChecked -eq $true) {
        $e.Cancel = $true
        $window.Hide()
        if ($null -eq $script:TrayIcon) {
            $script:TrayIcon = New-TrayIcon
            $script:TrayIcon.ShowBalloonTip(
                2000,
                'M365 Admin Tool',
                'Running in the system tray. Double-click to restore.',
                [System.Windows.Forms.ToolTipIcon]::Info
            )
        }
    } else {
        if ($null -ne $script:TrayIcon) {
            $script:TrayIcon.Visible = $false
            $script:TrayIcon.Dispose()
            $script:TrayIcon = $null
        }
    }
})

# ─── Initial Render ───────────────────────────────────────────────────────────
Build-AdminCenterButton

# ─── Show Window ──────────────────────────────────────────────────────────────
[void]$window.ShowDialog()

# ─── Cleanup ──────────────────────────────────────────────────────────────────
if ($null -ne $script:TrayIcon) {
    $script:TrayIcon.Visible = $false
    $script:TrayIcon.Dispose()
    $script:TrayIcon = $null
}
