# Generated on 04/16/2025 21:38:23 by .\build\orca\Update-OrcaTests.ps1

using module ".\orcaClass.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectComparisonWithNull', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()




class ORCA242 : ORCACheck
{
    <#

        Check for first contact safety tip

    #>

    ORCA242()
    {
        $this.Control=242
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Alerts"
        $this.Name="Protection Alerts"
        $this.PassText="Important protection alerts responsible for AIR activities are enabled"
        $this.FailRecommendation="Enable important protection alerts that are responsible for AIR activities."
        $this.Importance="Automated Incident Response (AIR) triggers off certain alerts that fire in the environment. AIR is responsible for detecting further anomalies and providing automated remediation actions designed to mitigate threats/attacks. It is important that these alerts are enabled so that AIR can function correctly."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Protection Alert"
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.ChiValue=[ORCACHI]::Critical
        $this.Links= @{
            "Automated investigation and response in Microsoft 365 Defender"="https://learn.microsoft.com/en-us/microsoft-365/security/defender/m365d-autoir"
        }
    }

    <#

        RESULTS

    #>

    GetResults($Config)
    {

        $ImportantAlerts = @(
            "A potentially malicious URL click was detected",
            "Teams message reported by user as security risk",
            "Email messages containing phish URLs removed after delivery",
            "Suspicious Email Forwarding Activity",
            "Malware not zapped because ZAP is disabled",
            "Phish delivered due to an ETR override",
            "Email messages containing malicious file removed after delivery",
            "Email reported by user as malware or phish",
            "Email messages containing malicious URL removed after delivery",
            "Email messages containing malware removed after delivery",
            "A user clicked through to a potentially malicious URL",
            "Email messages from a campaign removed after delivery",
            "Email messages removed after delivery",
            "Suspicious email sending patterns detected"
        )

        if($Config.ContainsKey('ProtectionAlert'))
        {
            ForEach ($ImportantAlert in $ImportantAlerts)
            {
                $FoundAlert = $Config["ProtectionAlert"] | Where-Object {$_.Name -eq $ImportantAlert}

                # These alerts cannot be removed, so if it's $null, then the alert isn't deployed to this tenant, so we don't want
                # to flag them at all.

                if($null -ne $FoundAlert)
                {
                    $ConfigObject = [ORCACheckConfig]::new()
                    $ConfigObject.Object=$ImportantAlert
                    $ConfigObject.ConfigItem="Disabled"
                    $ConfigObject.ConfigData=$FoundAlert.Disabled

                    if($FoundAlert.Disabled)
                    {
                        $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
                    }
                    else
                    {
                        $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
                    }

                    $this.AddConfig($ConfigObject)
                }
            }

        }

    }

}
