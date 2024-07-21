<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCaApplicationEnforcedRestriction.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID 09a8643b-b820-40a9-bde3-b3f65075db70
.ICONURI https://maester.dev/img/logo.svg
#>

<#
 .Synopsis
  Checks if the tenant has at least one conditional access policy is configured to enable application enforced restrictions

 .Description
    Application enforced restrictions conditional access policy can be helpful to minimize the risk of data leakage from a shared device.

  Learn more:
  https://aka.ms/CATemplatesAppRestrictions

 .Example
  Test-MtCaApplicationEnforcedRestriction

.LINK
    https://maester.dev/docs/commands/Test-MtCaApplicationEnforcedRestriction
#>
function Test-MtCaApplicationEnforcedRestriction {
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    if ( ( Get-MtLicenseInformation EntraID ) -eq "Free" ) {
        Add-MtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return $null
    }

    $policies = Get-MtConditionalAccessPolicy | Where-Object { $_.state -eq "enabled" }

    $result = $false
    foreach ($policy in $policies) {
        if ( $policy.conditions.users.includeUsers -eq "All" `
                -and $policy.conditions.clientAppTypes -eq "All" `
                -and $policy.sessionControls.applicationEnforcedRestrictions.isEnabled -eq $true `
                -and "Office365" -in $policy.conditions.applications.includeApplications `
        ) {
            $result = $true
            $currentresult = $true
        } else {
            $currentresult = $false
        }
        Write-Verbose "$($policy.displayName) - $currentresult"
    }

    return $result
}
