<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtEidscaControl.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID c8b09971-cf62-4eb6-96dc-cb7b399e80d2
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
    Tests your environment for compliance with the specified EIDSCA control

.DESCRIPTION
    Validates your environment against the specified EIDSCA control by comparing MS Graph result with the recommended value.

.EXAMPLE
    Test-MtEidscaControl -CheckId AP01

    Returns the result of the EIDSCA AP01 control check

.LINK
    https://maester.dev/docs/commands/Test-MtEidscaControl
#>
function Test-MtEidscaControl {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # Id for the EIDSCA control check to test
        [Parameter(Mandatory)]
        [ValidateSet('AP01','AP04','AP05','AP06','AP07','AP08','AP09','AP10','AP14','CP01','CP03','CP04','PR01','PR02','PR03','PR05','PR06','ST08','ST09','AG01','AG02','AG03','AM01','AM02','AM03','AM04','AM06','AM07','AM09','AM10','AF01','AF02','AF03','AF04','AF05','AF06','AT01','AT02','AV01','CR01','CR02','CR03','CR04')]
        [string]
        $CheckId
    )

    Write-Verbose -Message "Invoking EIDSCA control check $CheckId."
    & "Test-MtEidsca$CheckId"
}
