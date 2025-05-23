# Generated on 04/16/2025 21:38:23 by .\build\orca\Update-OrcaTests.ps1

using module ".\orcaClass.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectComparisonWithNull', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()




class ORCA100 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA100()
    {
        $this.Control = "ORCA-100"
        $this.Area = "Anti-Spam Policies"
        $this.Name="Bulk Complaint Level"
        $this.PassText="Bulk Complaint Level threshold is between 4 and 6"
        $this.FailRecommendation="Set the Bulk Complaint Level threshold to be 6"
        $this.Importance="The differentiation between bulk and spam can sometimes be subjective. The bulk complaint level is based on the number of complaints from the sender. Decreasing the threshold can decrease the amount of perceived spam received, however, too low may be considered too strict."
        $this.ExpandResults=$True
        $this.ItemName="Anti-Spam Policy"
        $this.DataType="Bulk Complaint Level Threshold"
        $this.Links= @{
            "Bulk Complaint Level values"="https://aka.ms/orca-antispam-docs-1"
            "Recommended settings for EOP and Microsoft Defender for Office 365 security"="https://aka.ms/orca-atpp-docs-6"
            "Microsoft 365 Defender Portal - Anti-spam settings"="https://security.microsoft.com/antispam"
        }
    
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {
        ForEach($Policy in $Config["HostedContentFilterPolicy"])
        {
            $BulkThreshold = $($Policy.BulkThreshold)

            # Check objects
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem=$Config["PolicyStates"][$Policy.Guid.ToString()].Name
            $ConfigObject.ConfigData=$BulkThreshold
            $ConfigObject.ConfigDisabled = $Config["PolicyStates"][$Policy.Guid.ToString()].Disabled
            $ConfigObject.ConfigWontApply = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $ConfigObject.ConfigReadonly = $Policy.IsPreset
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

            # Standard check - between 4 and 6
            If($BulkThreshold -ge 4 -and $BulkThreshold -le 6)
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,[ORCAResult]::Pass)
            }
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,[ORCAResult]::Fail)
            }

            # Strict check - is 4
            If($BulkThreshold -eq 4)
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Strict,[ORCAResult]::Pass)
            }
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Strict,[ORCAResult]::Fail)
            }

            # Add config to check
            $this.AddConfig($ConfigObject)
    
        }

    }

}
