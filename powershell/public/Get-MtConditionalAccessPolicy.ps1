﻿<#
 .Synopsis
  Returns all the conditional access policies in the tenant.

 .Description
  Returns all the conditional access policies in the tenant.

 .Example
  Get-MtConditionalAccessPolicy

.LINK
    https://maester.dev/docs/commands/Get-MtConditionalAccessPolicy
#>
function Get-MtConditionalAccessPolicy {
  [CmdletBinding()]
  param(
    # Specify if this request should skip cache and go directly to Graph.
    [Parameter(Mandatory = $false)]
    [Switch]$DisableCache
  )

  Write-Verbose -Message "Getting conditional access policies."

  return Invoke-MtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion beta -DisableCache:$DisableCache

}