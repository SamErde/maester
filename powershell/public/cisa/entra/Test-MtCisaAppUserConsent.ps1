<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCisaAppUserConsent.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID ffe3b06c-9a9a-4089-aa11-a324837a4ae0
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
    Checks if user app consent is prevented

.DESCRIPTION
    Only administrators SHALL be allowed to consent to applications.

.EXAMPLE
    Test-MtCisaAppUserConsent

    Returns true if disabled

.LINK
    https://maester.dev/docs/commands/Test-MtCisaAppUserConsent
#>
function Test-MtCisaAppUserConsent {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-MtConnection Graph)){
        Add-MtTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    $result = Invoke-MtGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion v1.0

    $permissions = $result.defaultUserRolePermissions.permissionGrantPoliciesAssigned | Where-Object {`
        $_ -like "ManagePermissionGrantsForSelf.*" }

    $testResult = ($permissions|Measure-Object).Count -eq 0

    if ($testResult) {
        $testResultMarkdown = "Well done. **[User consent for applications](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/~/UserSettings)** is set to **Do not allow user consent** in your tenant."
    } else {
        $testResultMarkdown = "Your tenant [allows users to consent for applications](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/~/UserSettings). The recommended setting is **Do not allow user consent**."
    }
    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}
