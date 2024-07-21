<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCisaCalendarSharing.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID e85f8a91-4371-4f2d-bf1b-ed4cb5327919
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
    Checks state of sharing policies

.DESCRIPTION
    Calendar details SHALL NOT be shared with all domains.

.EXAMPLE
    Test-MtCisaCalendarSharing

    Returns true if no sharing policies allow uncontrolled calendar sharing.

.LINK
    https://maester.dev/docs/commands/Test-MtCisaCalendarSharing
#>
function Test-MtCisaCalendarSharing {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-MtConnection ExchangeOnline)){
        Add-MtTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    $policies = Get-SharingPolicy

    $resultPolicies = $policies | Where-Object {`
        $_.Enabled -and `
        ($_.Domains -like "`*:*CalendarSharing*" -or `
         $_.Domains -like "Anonymous:*CalendarSharing*")
    }

    $testResult = ($resultPolicies|Measure-Object).Count -eq 0

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant does not allow uncontrolled calendar sharing.`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant allows uncontrolled calendar sharing.`n`n%TestResult%"
    }

    $result = "| Policy Name | Test Result |`n"
    $result += "| --- | --- |`n"
    foreach ($item in $policies | Sort-Object -Property Name) {
        $portalLink = "https://admin.exchange.microsoft.com/#/individualsharing/:/individualsharingdetails/$($item.ExchangeObjectId)/managedomain"
        $itemResult = "✅ Pass"
        if ($item.ExchangeObjectId -in $resultPolicies.ExchangeObjectId) {
            $itemResult = "❌ Fail"
        }
        $result += "| [$($item.Name)]($portalLink) | $($itemResult) |`n"
    }
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-MtTestResultDetail -Result $testResultMarkdown

    return $testResult
}
