<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtConnection.ps1
.TAGS Active, CISA
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION 0.0.1
.GUID 12470ff3-b959-4dcb-8607-0b8cb4c56e9f
.ICONURI https://maester.dev/img/logo.svg
#>

<#
.SYNOPSIS
   Checks if the current session is connected to the specified service. Use -Verbose to see the connection status for each service.

.DESCRIPTION
    Tests the connection for each service and returns $true if the session is connected to the specified service.

.EXAMPLE
    Test-MtConnection

    Checks if the current session is connected to Microsoft Graph.

.EXAMPLE
    Test-MtConnection -Service All

    Checks if the current session is connected to all services including Azure, Exchange and Microsoft Graph.

.LINK
    https://maester.dev/docs/commands/Test-MtConnection
#>
function Test-MtConnection {
    [CmdletBinding()]
    param(
        # Checks if the current session is connected to the specified service
        [ValidateSet("All", "Azure", "ExchangeOnline", "Graph", "SecurityCompliance")]
        [Parameter(Position = 0, Mandatory = $false)]
        [string[]]$Service = "Graph"
    )

    $connectionState = $true

    if ($Service -contains "Azure" -or $Service -contains "All") {
        $isConnected = $false
        try {
            $isConnected = $null -ne (Get-AzContext -ErrorAction SilentlyContinue)
        } catch {
            Write-Debug "Azure: $false"
        }
        Write-Verbose "Azure: $isConnected"
        if (!$isConnected) { $connectionState = $false }
    }

    if ($Service -contains "ExchangeOnline" -or $Service -contains "All") {
        $isConnected = $false
        try {
            $isConnected = $null -ne ((Get-ConnectionInformation | Where-Object { $_.Name -match 'ExchangeOnline' -and $_.state -eq 'Connected' }))
        } catch {
            Write-Debug "Exchange Online: $false"
        }
        Write-Verbose "Exchange Online: $isConnected"
        if (!$isConnected) { $connectionState = $false }
    }

    if ($Service -contains "Graph" -or $Service -contains "All") {
        $isConnected = $false
        try {
            $isConnected = $null -ne (Get-MgContext -ErrorAction SilentlyContinue)
        } catch {
            Write-Debug "Graph: $false"
        }
        Write-Verbose "Graph: $isConnected"
        if (!$isConnected) { $connectionState = $false }
    }

    if ($Service -contains "SecurityCompliance" -or $Service -contains "All") {
        $isConnected = $false
        try {
            $isConnected = $null -ne ((Get-ConnectionInformation | Where-Object { $_.Name -match 'ExchangeOnline' -and $_.state -eq 'Connected' -and $_.IsEopSession }))
        } catch {
            Write-Debug "Security & Compliance: $false"
        }
        Write-Verbose "Security & Compliance: $isConnected"
        if (!$isConnected) { $connectionState = $false }
    }

    Write-Output $connectionState
}
