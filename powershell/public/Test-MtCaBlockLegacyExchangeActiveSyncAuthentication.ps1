<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCaBlockLegacyExchangeActiveSyncAuthentication.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID eb446cdf-c3cd-4ec0-8e20-f169605a386e
.ICONURI https://maester.dev/img/logo.svg
#>

<#
 .Synopsis
  Checks if the tenant has at least one conditional access policy that blocks legacy authentication for Exchange Active Sync authentication.

 .Description
    Legacy authentication is an unsecure method to authenticate. This function checks if the tenant has at least one
    conditional access policy that blocks legacy authentication.

  Learn more:
  https://learn.microsoft.com/entra/identity/conditional-access/howto-conditional-access-policy-block-legacy

 .Example
  Test-MtCaBlockLegacyExchangeActiveSyncAuthentication

.LINK
    https://maester.dev/docs/commands/Test-MtCaBlockLegacyExchangeActiveSyncAuthentication
#>
function Test-MtCaBlockLegacyExchangeActiveSyncAuthentication {
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    if ( ( Get-MtLicenseInformation EntraID ) -eq "Free" ) {
        Add-MtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return $null
    }

    $policies = Get-MtConditionalAccessPolicy | Where-Object { $_.state -eq "enabled" }

    $testDescription = "
Legacy authentication is an unsecure method to authenticate. This function checks if the tenant has at least one
conditional access policy that blocks legacy authentication.

See [Block legacy authentication - Microsoft Learn](https://learn.microsoft.com/entra/identity/conditional-access/howto-conditional-access-policy-block-legacy)"
    $testResult = "These conditional access policies block legacy authentication for Exchange Active Sync:`n`n"


    $result = $false
    foreach ($policy in $policies) {
        if ( $policy.grantcontrols.builtincontrols -contains 'block' `
                -and "exchangeActiveSync" -in $policy.conditions.clientAppTypes `
                -and ( `
                    $policy.conditions.applications.includeApplications -eq "00000002-0000-0ff1-ce00-000000000000" `
                    -or $policy.conditions.applications.includeApplications -eq "all" `
            ) `
                -and $policy.conditions.users.includeUsers -eq "All" `
        ) {
            $result = $true
            $currentresult = $true
            $testResult += "  - [$($policy.displayname)](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($($policy.id))?%23view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies?=)`n"
        } else {
            $currentresult = $false
        }
        Write-Verbose "$($policy.displayName) - $currentresult"
    }

    if ($result -eq $false) {
        $testResult = "There was no conditional access policy blocking legacy authentication for Exchange Active Sync."
    }
    Add-MtTestResultDetail -Description $testDescription -Result $testResult

    return $result
}
