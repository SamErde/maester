<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCisaMfa.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID dd5203fc-59b6-4d97-b5da-04914cc9cb10
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
    Checks if Conditional Access Policy requiring MFA is enabled

.DESCRIPTION
    If phishing-resistant MFA has not been enforced, an alternative MFA method SHALL be enforced for all users

.EXAMPLE
    Test-MtCisaMfa

    Returns true if at least one policy requires MFA

.LINK
    https://maester.dev/docs/commands/Test-MtCisaMfa
#>
function Test-MtCisaMfa {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $result = Get-MtConditionalAccessPolicy

    $policies = $result | Where-Object {`
        $_.state -eq "enabled" -and `
        $_.conditions.applications.includeApplications -contains "All" -and `
        $_.conditions.users.includeUsers -contains "All" -and `
        $_.grantControls.builtInControls -contains "mfa" }

    $testResult = ($policies|Measure-Object).Count -ge 1

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has one or more policies that require MFA:`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant does not have any conditional access policies that require MFA."
    }
    Add-MtTestResultDetail -Result $testResultMarkdown -GraphObjectType ConditionalAccess -GraphObjects $policies

    return $testResult
}
