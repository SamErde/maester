<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCaWIFBlockLegacyAuthentication.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID 595a8c67-6ebe-4290-ae22-7e2f366f6032
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
  Checks if the user is blocked from using legacy authentication

.DESCRIPTION
    Checks if the user is blocked from using legacy authentication using the Conditional Access WhatIf Graph API endpoint.

.PARAMETER UserId
    The UserId to test the Conditional Acccess policie with

.EXAMPLE
    Test-MtCaWIFBlockLegacyAuthentication -UserId "e7417ac7-0485-4014-9100-33163bd6211f"

.LINK
    https://maester.dev/docs/commands/Test-MtCaWIFBlockLegacyAuthentication
#>
function Test-MtCaWIFBlockLegacyAuthentication {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        # The UserId to test the Conditional Acccess policie with
        [Parameter(Mandatory)]
        [string]$UserId
    )

    if ( ( Get-MtLicenseInformation EntraID ) -eq "Free" ) {
        Add-MtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return $null
    }

    $policiesResult = Test-MtConditionalAccessWhatIf -UserId $UserId -IncludeApplications "00000002-0000-0ff1-ce00-000000000000" -ClientAppType exchangeActiveSync

    if ( $null -ne $policiesResult ) {
        $testResult = "Well done. The following conditional access policies are currently blocking legacy authentication.`n`n%TestResult%"
        $Result = $true
    } else {
        $testResult = "No conditional access policy found that blocks legacy authentication."
        $Result = $false
    }
    Add-MtTestResultDetail -Result $testResult -GraphObjects $policiesResult -GraphObjectType ConditionalAccess
    Write-Verbose "Checking if the user $UserId is blocked from using legacy authentication"
    return $Result
}
