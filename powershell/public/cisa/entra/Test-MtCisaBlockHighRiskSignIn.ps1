<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCisaBlockHighRiskSignIn.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID 41fdeb49-a45a-4d75-b428-cf3a20e2b42c
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
    Checks if Sign-In Risk Based Policies - MS.AAD.2.3 is set to 'blocked'

.DESCRIPTION
    Sign-ins detected as high risk SHALL be blocked.

.EXAMPLE
    Test-MtCisaBlockHighRiskSignIn

    Returns true if at least one policy is set to block high risk sign-ins.

.LINK
    https://maester.dev/docs/commands/Test-MtCisaBlockHighRiskSignIn
#>
function Test-MtCisaBlockHighRiskSignIn {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-MtConnection Graph)){
        Add-MtTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    $EntraIDPlan = Get-MtLicenseInformation -Product EntraID
    if($EntraIDPlan -ne "P2"){
        Add-MtTestResultDetail -SkippedBecause NotLicensedEntraIDP2
        return $null
    }

    $result = Get-MtConditionalAccessPolicy

    $blockPolicies = $result | Where-Object {`
        $_.state -eq "enabled" -and `
        $_.grantControls.builtInControls -contains "block" -and `
        $_.conditions.applications.includeApplications -contains "all" -and `
        $_.conditions.signInRiskLevels -contains "high" -and `
        $_.conditions.users.includeUsers -contains "All" }

    $testResult = ($blockPolicies|Measure-Object).Count -ge 1

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has one or more policies that block high risk sign-ins:`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant does not have any conditional access policies that block high risk sign-ins."
    }
    Add-MtTestResultDetail -Result $testResultMarkdown -GraphObjectType ConditionalAccess -GraphObjects $blockPolicies

    return $testResult
}
