<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCisaSmtpAuthentication.ps1
.VERSION 0.0.1
.AUTHOR Maester Team
.TAGS Active, CISA, exchange
#>

<#
.SYNOPSIS
    Checks state of SMTP authentication in Exchange Online.

.DESCRIPTION
    SMTP authentication SHALL be disabled.

.EXAMPLE
    Test-MtCisaSmtpAuthentication

    Returns true if SMTP authentication is disabled in Exchange Online.
#>

Function Test-MtCisaSmtpAuthentication {
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
