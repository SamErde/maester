function Connect-Maester {
   <#
   .SYNOPSIS
      Connect to Microsoft Graph and, optionally, Azure, Exchange Online (and Security & Compliance), and Microsoft Teams.

   .DESCRIPTION
      Use this cmdlet to connect to Microsoft Graph and the Microsoft 365 services that Maester can assess.
      By default, it connects only to Microsoft Graph (Service = 'Graph'). Specify `-Service All` or provide a list
      (for example, `-Service Graph,Azure,ExchangeOnline`) to connect to additional services.

      This command is optional if you are already connected to Microsoft Graph (Connect-MgGraph) and other services
      with the required scopes.

   .PARAMETER Service
      One or more services to connect to. Default is 'Graph'.
      Valid values: All, Azure, ExchangeOnline, Graph, SecurityCompliance, Teams.
      Note: Security & Compliance requires Exchange Online; include both ExchangeOnline and SecurityCompliance or use -Service All.

   .PARAMETER Environment
      Microsoft Graph cloud environment. Default is 'Global'.
      Valid values: China, Germany, Global, USGov, USGovDoD.
      See Get-MgEnvironment for the list of environments available on your system.

   .PARAMETER AzureEnvironment
      Azure cloud environment. Default is 'AzureCloud'.
      Valid values: AzureChinaCloud, AzureCloud, AzureUSGovernment.

   .PARAMETER ExchangeEnvironmentName
      Exchange Online environment. Default is 'O365Default'.
      Valid values: O365China, O365Default, O365GermanyCloud, O365USGovDoD, O365USGovGCCHigh.

   .PARAMETER TeamsEnvironmentName
      Microsoft Teams environment. Optional; not set by default.
      Valid values: TeamsChina, TeamsGCCH, TeamsDOD.

   .PARAMETER TenantId
      The tenant ID to connect to. If not specified, the signed-in user's default tenant is used when applicable.

   .PARAMETER GraphClientId
      A custom application (client) ID to use with Connect-MgGraph for delegated access.
      Use this to isolate consent for Microsoft Graph PowerShell sessions.

   .PARAMETER UserPrincipalName
      The user principal name (UPN) to use when connecting (alias: UPN).
      Used where applicable (for example, Exchange Online UserPrincipalName, Azure AccountId, Teams AccountId).

   .PARAMETER UseDeviceCode
      Use device code flow for authentication to Microsoft online services (where supported). This will open a browser
      window to prompt for authentication.

      Notes:
      - Exchange Online in Windows PowerShell (Desktop) does not support device code flow.
      - Security & Compliance (Connect-IPPSSession) does not support device code flow.

   .PARAMETER SendMail
      Include the Microsoft Graph 'Mail.Send' scope.

   .PARAMETER SendTeamsMessage
      Include the Microsoft Graph 'ChannelMessage.Send' scope.

   .PARAMETER Privileged
      Include additional Microsoft Graph privileged scopes (for example, RoleEligibilitySchedule.ReadWrite.Directory)
      required for certain Privileged Identity Management queries.

   .INPUTS
      None. This cmdlet does not accept pipeline input.

   .OUTPUTS
      None. This cmdlet does not emit objects. It establishes authenticated connections and writes verbose/host output.

   .EXAMPLE
      Connect-Maester

      Connects to Microsoft Graph with the required scopes.

   .EXAMPLE
      Connect-Maester -Service All

      Connects to all supported services: Microsoft Graph, Azure, Exchange Online, Security & Compliance, and Microsoft Teams.

   .EXAMPLE
      Connect-Maester -Service Graph,Teams

      Connects to Microsoft Graph and Microsoft Teams.

   .EXAMPLE
      Connect-Maester -Service Azure,Graph

      Connects to Microsoft Graph and Azure.

   .EXAMPLE
      Connect-Maester -Service Graph,Azure -UseDeviceCode

      Connects to Microsoft Graph and Azure using the device code flow. This opens a browser window to prompt for authentication.

   .EXAMPLE
      Connect-Maester -SendMail

      Connects to Microsoft Graph with the Mail.Send scope.

   .EXAMPLE
      Connect-Maester -SendTeamsMessage

      Connects to Microsoft Graph with the ChannelMessage.Send scope.

   .EXAMPLE
      Connect-Maester -Privileged

      Connects to Microsoft Graph with additional privileged scopes such as **RoleEligibilitySchedule.ReadWrite.Directory** that are required for querying global admin roles in Privileged Identity Management.

   .EXAMPLE
      Connect-Maester -Service Graph,Azure,ExchangeOnline -Environment USGov -AzureEnvironment AzureUSGovernment -ExchangeEnvironmentName O365USGovGCCHigh

      Connects to US Government environments for Microsoft Graph, Azure, and Exchange Online.

   .EXAMPLE
      Connect-Maester -Service Graph,Azure,ExchangeOnline -Environment USGovDoD -AzureEnvironment AzureUSGovernment -ExchangeEnvironmentName O365USGovDoD

      Connects to US Department of Defense (DoD) environments for Microsoft Graph, Azure, and Exchange Online.

   .EXAMPLE
      Connect-Maester -Service Graph,Azure,ExchangeOnline -Environment China -AzureEnvironment AzureChinaCloud -ExchangeEnvironmentName O365China

      Connects to China environments for Microsoft Graph, Azure, and Exchange Online.

   .EXAMPLE
      Connect-Maester -GraphClientId 'f45ec3ad-32f0-4c06-8b69-47682afe0216'

      Connects using a custom application with client ID f45ec3ad-32f0-4c06-8b69-47682afe0216

   .EXAMPLE
      Connect-Maester -Service Teams -TeamsEnvironmentName TeamsGCCH

      Connects to Microsoft Teams in the GCC High environment.

   .EXAMPLE
      Connect-Maester -Service ExchangeOnline,SecurityCompliance

      Connects to Exchange Online and Security & Compliance. Note: Device code flow is not supported for Security & Compliance.

   .EXAMPLE
      Connect-Maester -Service All -TenantId 'contoso.onmicrosoft.com' -UserPrincipalName 'User@contoso.onmicrosoft.com'

      Connects to all supported services: Microsoft Graph, Azure, Exchange Online, Security & Compliance, and Microsoft Teams for the specified tenant and user principal name.

   .LINK
      https://maester.dev/docs/commands/Connect-Maester
#>
   [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
   [Alias('Connect-MtGraph', 'Connect-MtMaester')]
   [CmdletBinding()]
   param(
      # If specified, the cmdlet will include the scope to send email (Mail.Send).
      [switch] $SendMail,

      # If specified, the cmdlet will include the scope to send a channel message in Teams (ChannelMessage.Send).
      [switch] $SendTeamsMessage,

      # If specified, the cmdlet will include the scopes for read write API endpoints. This is currently required for querying global admin roles in PIM.
      [switch] $Privileged,

      # If specified, the cmdlet will use the device code flow to authenticate to Graph and Azure.
      # This will open a browser window to prompt for authentication and is useful for non-interactive sessions and on Windows when SSO is not desired.
      [switch] $UseDeviceCode,

      # The environment to connect to. Default is Global. Supported values include China, Germany, Global, USGov, USGovDoD.
      [ValidateSet('China', 'Germany', 'Global', 'USGov', 'USGovDoD')]
      [string]$Environment = 'Global',

      # The Azure environment to connect to. Default is AzureCloud. Supported values include AzureChinaCloud, AzureCloud, AzureUSGovernment.
      [ValidateSet('AzureChinaCloud', 'AzureCloud', 'AzureUSGovernment')]
      [string]$AzureEnvironment = 'AzureCloud',

      # The Exchange environment to connect to. Default is O365Default. Supported values include O365China, O365Default, O365GermanyCloud, O365USGovDoD, O365USGovGCCHigh.
      [ValidateSet('O365China', 'O365Default', 'O365GermanyCloud', 'O365USGovDoD', 'O365USGovGCCHigh')]
      [string]$ExchangeEnvironmentName = 'O365Default',

      # The Teams environment to connect to. Default is O365Default.
      [ValidateSet('TeamsChina', 'TeamsGCCH', 'TeamsDOD')]
      [string]$TeamsEnvironmentName = $null, #ToValidate: Don't use this parameter, this is the default.

      # The services to connect to such as Azure and EXO. Default is Graph.
      [ValidateSet('All', 'Azure', 'ExchangeOnline', 'Graph', 'SecurityCompliance', 'Teams')]
      [string[]]$Service = 'Graph',

      # The Tenant ID to connect to, if not specified the sign-in user's default tenant is used.
      [string]$TenantId,

      # The Client ID of the app to connect to for Graph. If not specified, the default Graph PowerShell CLI enterprise app will be used. Reference on how to create an enterprise app: https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands?view=graph-powershell-1.0#use-delegated-access-with-a-custom-application-for-microsoft-graph-powershell
      [string]$GraphClientId,

      # The user principal name (UPN) to connect to for Graph. If not specified, the currently signed in user's UPN will be used.
      [Parameter()]
      [Alias('UPN')]
      [string]$UserPrincipalName
   )

   $__MtSession.Connections = $Service

   $OrderedImport = Get-ModuleImportOrder -Name @('Az.Accounts', 'ExchangeOnlineManagement', 'Microsoft.Graph.Authentication', 'MicrosoftTeams')
   switch ($OrderedImport.Name) {

      'Az.Accounts' {
         if ($Service -contains 'Azure' -or $Service -contains 'All') {
            Write-Verbose 'Connecting to Microsoft Azure'

            # Prepare parameters for Connect-AzAccount and automatically add optional parameters if specified by user.
            $AzureConnectSplat = @{
               SkipContextPopulation   = $true
               UseDeviceAuthentication = $UseDeviceCode
               Environment             = $AzureEnvironment
            }
            if ($TenantId) {
               $AzureConnectSplat['TenantId'] = $TenantId
            }
            if ($UserPrincipalName) {
               $AzureConnectSplat['AccountId'] = $UserPrincipalName
            }

            try {
               $azWarning = @()
               Connect-AzAccount @AzureConnectSplat -WarningAction SilentlyContinue -WarningVariable azWarning
               if ($azWarning.Count -gt 0) {
                  foreach ($warning in $azWarning) {
                     Write-Verbose $warning.Message
                  }
               }
            } catch [Management.Automation.CommandNotFoundException] {
               Write-Host "`n⛔ The Az.Accounts PowerShell module is not installed. Please install the module using the following command. For more information see https://learn.microsoft.com/powershell/azure/install-azure-powershell" -ForegroundColor Red
               Write-Host "  `Install-Module Az.Accounts -Scope CurrentUser`n" -ForegroundColor Yellow
            }
         }
      }

      'ExchangeOnlineManagement' {
         if ($Service -contains 'ExchangeOnline' -or $Service -contains 'All') {
            Write-Verbose 'Connecting to Microsoft Exchange Online'
            $ExchangeModuleNotInstalledWarningShown = $false

            # Prepare parameters for Connect-ExchangeOnline and automatically add optional parameters if specified by user.
            $ExchangeConnectSplat = @{
               ExchangeEnvironmentName = $ExchangeEnvironmentName
               Device                  = $UseDeviceCode
               ShowBanner              = $false
            }
            if ($UserPrincipalName) {
               $ExchangeConnectSplat['UserPrincipalName'] = $UserPrincipalName
            }

            try {
               if ($UseDeviceCode -and $PSVersionTable.PSEdition -eq 'Desktop') {
                  Write-Host 'The Exchange Online module in Windows PowerShell does not support device code flow authentication.' -ForegroundColor Red
                  Write-Host '💡Please use the Exchange Online module in PowerShell Core.' -ForegroundColor Yellow
               } else {
                  Connect-ExchangeOnline @ExchangeConnectSplat
               }
            } catch [Management.Automation.CommandNotFoundException] {
               Write-Host "`nThe Exchange Online module is not installed. Please install the module using the following command.`nFor more information see https://learn.microsoft.com/powershell/exchange/exchange-online-powershell-v2" -ForegroundColor Red
               Write-Host "`nInstall-Module ExchangeOnlineManagement -Scope CurrentUser`n" -ForegroundColor Yellow
               $ExchangeModuleNotInstalledWarningShown = $true
            }
         }

         if ($Service -contains 'SecurityCompliance' -or $Service -contains 'All') {
            Write-Verbose 'Connecting to Microsoft Security & Compliance via Exchange Online'

            # Cache the connection information to avoid multiple calls to Get-ConnectionInformation. See https://github.com/maester365/maester/pull/1207
            $ExchangeConnectionInformation = Get-MtExo -Request ConnectionInformation

            # Define environment URIs
            $Environments = @{
               'O365China'        = @{
                  ConnectionUri    = 'https://ps.compliance.protection.partner.outlook.cn/powershell-liveid'
                  AuthZEndpointUri = 'https://login.chinacloudapi.cn/common'
               }
               'O365GermanyCloud' = @{
                  ConnectionUri    = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
                  AuthZEndpointUri = 'https://login.microsoftonline.com/common'
               }
               'O365Default'      = @{
                  ConnectionUri    = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
                  AuthZEndpointUri = 'https://login.microsoftonline.com/common'
               }
               'O365USGovGCCHigh' = @{
                  ConnectionUri    = 'https://ps.compliance.protection.office365.us/powershell-liveid/'
                  AuthZEndpointUri = 'https://login.microsoftonline.us/common'
               }
               'O365USGovDoD'     = @{
                  ConnectionUri    = 'https://l5.ps.compliance.protection.office365.us/powershell-liveid/'
                  AuthZEndpointUri = 'https://login.microsoftonline.us/common'
               }
               Default            = @{
                  ConnectionUri    = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
                  AuthZEndpointUri = 'https://login.microsoftonline.com/common'
               }
            }

            # Prepare parameters for Connect-IPPSSession and automatically add optional parameters if specified by user.
            $ExoIpPsSessionSplat = @{
               ConnectionUri                   = $Environments[$ExchangeEnvironmentName].ConnectionUri
               AzureADAuthorizationEndpointUri = $Environments[$ExchangeEnvironmentName].AuthZEndpointUri
               ShowBanner                      = $false
               BypassMailboxAnchoring          = $true
            }
            if ($UserPrincipalName) {
               $ExoIpPsSessionSplat['UserPrincipalName'] = $UserPrincipalName
            }

            if ($Service -notcontains 'ExchangeOnline' -and $Service -notcontains 'All') {
               Write-Host "`n⛔ The Security & Compliance module is dependent on the Exchange Online module. Please include ExchangeOnline when specifying the services.`nFor more information see https://learn.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell" -ForegroundColor Red
            } else {
               if ($UseDeviceCode) {
                  Write-Host "`n⛔ The Security & Compliance module does not support device code flow authentication." -ForegroundColor Red
               } else {
                  try {
                     Connect-IPPSSession @ExoIpPsSessionSplat
                  } catch [Management.Automation.CommandNotFoundException] {
                     if (-not $ExchangeModuleNotInstalledWarningShown) {
                        Write-Host "`n⛔ The Exchange Online module is not installed. Please install the module using the following command.`nFor more information see https://learn.microsoft.com/powershell/exchange/exchange-online-powershell-v2" -ForegroundColor Red
                        Write-Host "`n  Install-Module ExchangeOnlineManagement -Scope CurrentUser`n" -ForegroundColor Yellow
                     }
                  } catch {
                     $ExoUPN = $ExchangeConnectionInformation | Select-Object -ExpandProperty UserPrincipalName -First 1 -ErrorAction SilentlyContinue
                     if ($ExoUPN) {
                        Write-Host "`nAttempting to connect to the Security & Compliance PowerShell using UPN '$ExoUPN' derived from the ExchangeOnline connection." -ForegroundColor Yellow
                        Connect-IPPSSession -UserPrincipalName $ExoUPN -ShowBanner:$false -BypassMailboxAnchoring
                     } else {
                        Write-Host "`n⛔ Failed to connect to the Security & Compliance PowerShell. Please ensure you are connected to Exchange Online first." -ForegroundColor Red
                     }
                  }
               }
            }

            <# Fix for Get-AdminAuditLogConfig (#1045)
               Connect-IPPSSession imports a temporary PSSession module that breaks Get-AdminAuditLogConfig. This script
               block removes the broken function and re-imports the temporary PSSession module for EXO, which restores
               the working Get-AdminAuditLogConfig function.
            #>
            if ($ExchangeConnectionInformation | Where-Object { $_.IsEopSession -eq $true -and $_.State -eq 'Connected' }) {
               try {
                  # Remove the broken cmdlet and re-import the working EXO one.
                  Remove-Item -Path 'Function:\Get-AdminAuditLogConfig' -Force -ErrorAction SilentlyContinue
                  $ExchangeConnectionInformation | Where-Object { $_.IsEopSession -ne $true -and $_.State -eq 'Connected' } |
                     Select-Object -ExpandProperty ModuleName |
                        Import-Module -Function 'Get-AdminAuditLogConfig' > $null
               } catch {
                  Write-Error "Failed to restore Get-AdminAuditLogConfig cmdlet: $($_.Exception.Message)"
               }
            }
         }
      }

      'Microsoft.Graph.Authentication' {
         if ($Service -contains 'Graph' -or $Service -contains 'All') {
            Write-Verbose 'Setting up Microsoft Graph connection.'
            try {


               # Prepare parameters for Connect-MgGraph and automatically add optional parameters if specified by user.
               $scopes = Get-MtGraphScope -SendMail:$SendMail -SendTeamsMessage:$SendTeamsMessage -Privileged:$Privileged
               $MgGraphConnectParams = @{
                  Scopes        = $scopes
                  UseDeviceCode = $UseDeviceCode
                  Environment   = $Environment
                  NoWelcome     = $true
               }

               if ($GraphClientId) {
                  $MgGraphConnectParams['ClientId'] = $GraphClientId
               }
               if ($TenantId) {
                  $MgGraphConnectParams['TenantId'] = $TenantId
               }

               Write-Verbose '🦒 Connecting to Microsoft Graph with parameters:'
               Write-Verbose ($MgGraphConnectParams | ConvertTo-Json -Depth 5)
               Connect-MgGraph @MgGraphConnectParams

               # Ensure the TenantId is saved in the Maester session state for later use.
               if (-not $TenantId) {
                  $TenantId = (Get-MgContext).TenantId
               }

            } catch [Management.Automation.CommandNotFoundException] {
               Write-Host "`n⛔ The Graph PowerShell module is not installed. Please install the module using the following command. For more information see https://learn.microsoft.com/powershell/microsoftgraph/installation" -ForegroundColor Red
               Write-Host "`  Install-Module Microsoft.Graph.Authentication -Scope CurrentUser`n" -ForegroundColor Yellow
            }
         }
      }

      'MicrosoftTeams' {
         if ($Service -contains 'Teams' -or $Service -contains 'All') {
            Write-Verbose 'Connecting to Microsoft Teams'

            # Prepare parameters for Connect-MicrosoftTeams and automatically add optional parameters if specified by user.
            $TeamsConnectParams = @{
               UseDeviceAuthentication = $UseDeviceCode
            }

            # Add optional parameters if specified by user.
            if ($UserPrincipalName) {
               $TeamsConnectParams['AccountId'] = $UserPrincipalName
            }
            if ($TenantId) {
               $TeamsConnectParams['TenantId'] = $TenantId
            }
            if ($TeamsEnvironmentName) {
               $TeamsConnectParams['TeamsEnvironmentName'] = $TeamsEnvironmentName
            }

            try {
               Connect-MicrosoftTeams @TeamsConnectParams > $null
            } catch [Management.Automation.CommandNotFoundException] {
               Write-Host "`n⛔ The Teams PowerShell module is not installed. Please install the module using the following command. For more information see https://learn.microsoft.com/en-us/microsoftteams/teams-powershell-install" -ForegroundColor Red
               Write-Host "`  Install-Module MicrosoftTeams -Scope CurrentUser`n" -ForegroundColor Yellow
            }
         }
      }
   } # end switch OrderedImport

} # end function Connect-Maester
