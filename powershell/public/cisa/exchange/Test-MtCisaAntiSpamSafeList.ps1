<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCisaAntiSpamSafeList.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID 25681297-1cc6-4f73-9c87-22df565488c1
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
    Checks state of anti-spam policies

.DESCRIPTION
    Safe lists SHOULD NOT be enabled.

.EXAMPLE
    Test-MtCisaAntiSpamSafeList

    Returns true if Safe List is disabled in anti-spam policy

.LINK
    https://maester.dev/docs/commands/Test-MtCisaAntiSpamSafeList
#>
function Test-MtCisaAntiSpamSafeList {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-MtConnection ExchangeOnline)){
        Add-MtTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    $policy = Get-MtExo -Request HostedConnectionFilterPolicy

    $resultPolicy = $policy | Where-Object {`
        -not $_.EnableSafeList
    }

    $testResult = ($resultPolicy|Measure-Object).Count -eq 1

    $portalLink = "https://security.microsoft.com/antispam"

    if ($testResult) {
        $testResultMarkdown = "Well done. [Safe List]($portalLink) is disabled in your tenant."
    } else {
        $testResultMarkdown = "[Safe List]($portalLink) is enabled in your tenant."
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-MtTestResultDetail -Result $testResultMarkdown

    return $testResult
}
