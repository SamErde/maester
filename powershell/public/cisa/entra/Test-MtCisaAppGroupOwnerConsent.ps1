<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCisaAppGroupOwnerConsent.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID d6d872f5-f99c-46a1-851d-8478666b8ebb
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
    Checks if group owners can consent to apps

.DESCRIPTION
    Group owners SHALL NOT be allowed to consent to applications.

.EXAMPLE
    Test-MtCisaAppGroupOwnerConsent

    Returns true if disabled

.LINK
    https://maester.dev/docs/commands/Test-MtCisaAppGroupOwnerConsent
#>
function Test-MtCisaAppGroupOwnerConsent {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    #May need update to https://learn.microsoft.com/en-us/graph/api/resources/teamsappsettings?view=graph-rest-1.0
    $result = Invoke-MtGraphRequest -RelativeUri "settings" -ApiVersion beta

    $testResult = ($result.values | Where-Object {`
        $_.name -eq "EnableGroupSpecificConsent" } | `
        Select-Object -ExpandProperty value) -eq $false

    if ($testResult) {
        $testResultMarkdown = "Well done. Groups owners cannot consent to applications."
    } else {
        $testResultMarkdown = "Your tenant allows group owners to consent to applications."
    }
    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}
