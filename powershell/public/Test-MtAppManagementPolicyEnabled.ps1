<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtAppManagementPolicyEnabled.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID 79e62d97-8012-4ad8-96c4-ac26b60f5b45
.ICONURI https://maester.dev/img/logo.svg
#>

<#
 .Synopsis
  Checks if the default app management policy is enabled.

 .Description
  GET /policies/defaultAppManagementPolicy

 .Example
  Test-MtAppManagementPolicyEnabled

.LINK
    https://maester.dev/docs/commands/Test-MtAppManagementPolicyEnabled
#>
function Test-MtAppManagementPolicyEnabled {
  [CmdletBinding()]
  [OutputType([bool])]
  param()

  if (!(Get-MtLicenseInformation EntraWorkloadID)) {
    Add-MtTestResultDetail -SkippedBecause NotLicensedEntraWorkloadID
    return $null
  }

  $defaultAppManagementPolicy = Invoke-MtGraphRequest -RelativeUri "policies/defaultAppManagementPolicy"
  Write-Verbose -Message "Default App Management Policy: $($result.isEnabled)"
  $result = $defaultAppManagementPolicy.isEnabled -eq 'True'

  if ($result) {
    $resultMarkdown = "Well done. Your tenant has an app management policy enabled."
  } else {
    $resultMarkdown = "Your tenant does not have an app management policy defined."
  }

  Add-MtTestResultDetail -Result $resultMarkdown

  return $result
}
