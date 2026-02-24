@{
    # Include all default rules
    IncludeDefaultRules = $true

    # Severity levels to check
    Severity = @('Error', 'Warning', 'Information')

    # Rules to exclude (if any rule causes false positives, add it here)
    ExcludeRules = @(
        # 'PSAvoidUsingWriteHost'   # uncomment if using Write-Host intentionally
    )

    # Custom rule settings
    Rules = @{
        PSUseCompatibleSyntax = @{
            Enable         = $true
            TargetVersions = @('5.1', '7.0', '7.2', '7.4')
        }
        PSUseCompatibleCmdlets = @{
            Compatibility = @('desktop-5.1-windows', 'core-7.4-windows')
        }
        PSAvoidUsingCmdletAliases = @{
            # Allow common aliases like % and ?
            Whitelist = @()
        }
        PSPlaceOpenBrace = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }
        PSPlaceCloseBrace = @{
            Enable             = $true
            NewLineAfter       = $false
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }
        PSUseConsistentIndentation = @{
            Enable              = $true
            IndentationSize     = 4
            PipelineIndentation = 'IncreaseIndentationAfterEveryPipeline'
            Kind                = 'space'
        }
        PSUseConsistentWhitespace = @{
            Enable                                  = $true
            CheckInnerBrace                         = $true
            CheckOpenBrace                          = $true
            CheckOpenParen                          = $true
            CheckOperator                           = $true
            CheckPipe                               = $true
            CheckPipeForRedundantWhitespace         = $true
            CheckSeparator                          = $true
            CheckParameter                          = $false
            IgnoreAssignmentOperatorInsideHashTable = $true
        }
        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $true
        }
    }
}
