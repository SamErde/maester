<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCisaSmtpAuthentication.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID 40961fa8-a050-4447-bd2d-bb38e0ed814a
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
    Checks state of SMTP authentication in Exchange Online.

.DESCRIPTION
    SMTP authentication SHALL be disabled.

.EXAMPLE
    Test-MtCisaSmtpAuthentication

    Returns true if SMTP authentication is disabled in Exchange Online.

.LINK
    https://maester.dev/docs/commands/Test-MtCisaSmtpAuthentication
#>
function Test-MtCisaSmtpAuthentication {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-MtConnection ExchangeOnline)){
        Add-MtTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    $config = Get-TransportConfig

    $testResult = $config.SmtpClientAuthenticationDisabled

    $portalLink = "https://admin.exchange.microsoft.com/#/settings"
    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has [SMTP Authentication]($portalLink) disabled."
    } else {
        $testResultMarkdown = "Your tenant has [SMTP Authentication]($portalLink) enabled."
    }

    Add-MtTestResultDetail -Result $testResultMarkdown

    return $testResult
}
