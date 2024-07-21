<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtEidscaAP07.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID 70c4a5af-95c4-44df-aa7d-c850884ba9ec
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
    Checks if Default Authorization Settings - Guest user access is set to '2af84b1e-32c8-42b7-82bc-daa82404023b'

.DESCRIPTION

    Represents role templateId for the role that should be granted to guest user.

    Queries policies/authorizationPolicy
    and returns the result of
     graph/policies/authorizationPolicy.guestUserRoleId -eq '2af84b1e-32c8-42b7-82bc-daa82404023b'

.EXAMPLE
    Test-MtEidscaAP07

    Returns the result of graph.microsoft.com/beta/policies/authorizationPolicy.guestUserRoleId -eq '2af84b1e-32c8-42b7-82bc-daa82404023b'
#>

Function Test-MtEidscaAP07 {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    

    $result = Invoke-MtGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion beta

    [string]$tenantValue = $result.guestUserRoleId
    $testResult = $tenantValue -eq '2af84b1e-32c8-42b7-82bc-daa82404023b'
    $tenantValueNotSet = $null -eq $tenantValue -and '2af84b1e-32c8-42b7-82bc-daa82404023b' -notlike '*$null*'

    if($testResult){
        $testResultMarkdown = "Well done. The configuration in your tenant and recommended value is **'2af84b1e-32c8-42b7-82bc-daa82404023b'** for **policies/authorizationPolicy**"
    } elseif ($tenantValueNotSet) {
        $testResultMarkdown = "Your tenant is **not configured explicitly**.`n`nThe recommended value is **'2af84b1e-32c8-42b7-82bc-daa82404023b'** for **policies/authorizationPolicy**. It seems that you are using a default value by Microsoft. We recommend to set the setting value explicitly since non set values could change depending on what Microsoft decides the current default should be."
    } else {
        $testResultMarkdown = "Your tenant is configured as **$($tenantValue)**.`n`nThe recommended value is **'2af84b1e-32c8-42b7-82bc-daa82404023b'** for **policies/authorizationPolicy**"
    }
    Add-MtTestResultDetail -Result $testResultMarkdown

    return $tenantValue
}
