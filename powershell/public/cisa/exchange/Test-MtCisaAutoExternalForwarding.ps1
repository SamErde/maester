<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCisaAutoExternalForwarding.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID e0085d6f-977e-4e4c-b1e1-8e653bbcf637
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
    Checks ...

.DESCRIPTION
    Automatic forwarding to external domains SHALL be disabled.

.EXAMPLE
    Test-MtCisaAutoExternalForwarding

    Returns true if no domain is enabled for auto forwarding

.LINK
    https://maester.dev/docs/commands/Test-MtCisaAutoExternalForwarding
#>
function Test-MtCisaAutoExternalForwarding {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-MtConnection ExchangeOnline)){
        Add-MtTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    $domains = Get-MtExo -Request RemoteDomain

    $forwardingDomains = $domains | Where-Object { `
        $_.AutoForwardEnabled
    } | Select-Object -Property DomainName

    $testResult = ($forwardingDomains | Measure-Object).Count -eq 0

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has [automatic forwarding](https://admin.exchange.microsoft.com/#/remotedomains) disabled for all domains.`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant does not have [automatic forwarding](https://admin.exchange.microsoft.com/#/remotedomains) disabled for all domains.`n`n%TestResult%"
    }

    # Remote domain does not support deep link
    $portalLink = "https://admin.exchange.microsoft.com/#/remotedomains"
    $result = "| Name | Domain | Automatic forwarding | Test Result |`n"
    $result += "| --- | --- | --- | --- |`n"
    foreach ($item in $domains | Sort-Object -Property Name) {
        $itemResult = "✅ Pass"
        $itemState = "Not allow automatic forwarding"
        if ($item.AutoForwardEnabled) {
            $itemResult = "❌ Fail"
            $itemState = "Allow automatic forwarding"
        }
        $result += "| [$($item.Name)]($portalLink) | $($item.DomainName) | $($itemState) | $($itemResult) |`n"
    }
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-MtTestResultDetail -Result $testResultMarkdown


    return $testResult
}
