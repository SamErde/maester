<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtEidscaAP01.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID 449d5430-af1c-403f-bd17-e3b09055ab13
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
    Checks if Default Authorization Settings - Enabled Self service password reset for administrators is set to 'false'

.DESCRIPTION

    Indicates whether administrators of the tenant can use the Self-Service Password Reset (SSPR). The policy applies to some critical critical roles in Microsoft Entra ID.

    Queries policies/authorizationPolicy
    and returns the result of
     graph/policies/authorizationPolicy.allowedToUseSSPR -eq 'false'

.EXAMPLE
    Test-MtEidscaAP01

    Returns the result of graph.microsoft.com/beta/policies/authorizationPolicy.allowedToUseSSPR -eq 'false'
#>

Function Test-MtEidscaAP01 {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    

    $result = Invoke-MtGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion beta

    [string]$tenantValue = $result.allowedToUseSSPR
    $testResult = $tenantValue -eq 'false'
    $tenantValueNotSet = $null -eq $tenantValue -and 'false' -notlike '*$null*'

    if($testResult){
        $testResultMarkdown = "Well done. The configuration in your tenant and recommended value is **'false'** for **policies/authorizationPolicy**"
    } elseif ($tenantValueNotSet) {
        $testResultMarkdown = "Your tenant is **not configured explicitly**.`n`nThe recommended value is **'false'** for **policies/authorizationPolicy**. It seems that you are using a default value by Microsoft. We recommend to set the setting value explicitly since non set values could change depending on what Microsoft decides the current default should be."
    } else {
        $testResultMarkdown = "Your tenant is configured as **$($tenantValue)**.`n`nThe recommended value is **'false'** for **policies/authorizationPolicy**"
    }
    Add-MtTestResultDetail -Result $testResultMarkdown

    return $tenantValue
}
