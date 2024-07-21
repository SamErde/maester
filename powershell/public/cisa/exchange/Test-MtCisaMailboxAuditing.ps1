<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCisaMailboxAuditing.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID d51afa01-940e-4ce9-bfd4-01102ead9d1b
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
    Checks state of mailbox auditing

.DESCRIPTION
    Mailbox auditing SHALL be enabled.

.EXAMPLE
    Test-MtCisaMailboxAuditing

    Returns true if mailbox auditing is enabled.

.LINK
    https://maester.dev/docs/commands/Test-MtCisaMailboxAuditing
#>
function Test-MtCisaMailboxAuditing {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-MtConnection ExchangeOnline)){
        Add-MtTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    $config = Get-OrganizationConfig

    $testResult = (-not $config.AuditDisabled)

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has mailbox auditing enabled.`n`n%TestResult%"
        $result = "✅ Pass"
    } else {
        $testResultMarkdown = "Your tenant does not have mailbox auditing enabled.`n`n%TestResult%"
        $result = "❌ Fail"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-MtTestResultDetail -Result $testResultMarkdown

    return $testResult
}
