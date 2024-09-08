<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCisaGuestInvitation.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID 35c4a3d4-a6d3-4df6-9b42-f59dccfd0c93
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
    Checks if guest invitiations are restricted to admins

.DESCRIPTION
    Only users with the Guest Inviter role SHOULD be able to invite guest users.

.EXAMPLE
    Test-MtCisaGuestInvitation

    Returns true if guest invitiations are restricted to admins

.LINK
    https://maester.dev/docs/commands/Test-MtCisaGuestInvitation
#>
function Test-MtCisaGuestInvitation {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-MtConnection Graph)){
        Add-MtTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    $result = Invoke-MtGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion v1.0

    $testResult = $result.allowInvitesFrom -eq "adminsAndGuestInviters"

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant restricts who can invite guests:`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant allows anyone to invite guests."
    }
    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}
