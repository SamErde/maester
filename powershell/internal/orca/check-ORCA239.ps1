# Generated on 04/16/2025 21:38:23 by .\build\orca\Update-OrcaTests.ps1

using module ".\orcaClass.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectComparisonWithNull', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()


<#

ORCA-239

Checks Built-In protection exclusions for Safe Links

#>



class ORCA239 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA239()
    {
        $this.Control=239
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Built-in Protection"
        $this.PassText="No exclusions for the built-in protection policies"
        $this.FailRecommendation="Remove exclusions from the built-in protection policies."
        $this.Importance="Built-in protection policies provide catch-all protection against users not covered by higher order policies. Excluding users from the built-in protection policies may mean these users have reduced protections. It is important not to rely on the 'built-in' policies, as these policies only apply the minimum level of protections and should serve as a catch-all."
        $this.ItemName="Exclusion Type"
        $this.DataType="Exclusion"
        $this.ExpandResults=$True
        $this.ChiValue=[ORCACHI]::High
        $this.Links= @{
            "Microsoft 365 Defender Portal - Safe links"="https://security.microsoft.com/safelinksv2"
            "Recommended settings for EOP and Microsoft Defender for Office 365"="https://aka.ms/orca-atpp-docs-7"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {

        # Used for passing if no exclusion found
        $ExclusionFound = $false

        foreach($Exclusion in $Config["ATPBuiltInProtectionRule"].ExceptIfSentTo)
        {
            $ExclusionFound = $True

            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem="Recipient"
            $ConfigObject.ConfigData=$Exclusion
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            
            $this.AddConfig($ConfigObject)
        }

        foreach($Exclusion in $Config["ATPBuiltInProtectionRule"].ExceptIfSentToMemberOf)
        {
            $ExclusionFound = $True

            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem="Group"
            $ConfigObject.ConfigData=$Exclusion
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            
            $this.AddConfig($ConfigObject)
        }


        foreach($Exclusion in $Config["ATPBuiltInProtectionRule"].ExceptIfRecipientDomainIs)
        {
            $ExclusionFound = $True

            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem="Domain"
            $ConfigObject.ConfigData=$Exclusion
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            
            $this.AddConfig($ConfigObject)
        }

        if(!$ExclusionFound)
        {
            # Check objects
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem="None"
            $ConfigObject.ConfigData="No exclusions from MDO in-built protections"
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
            
            $this.AddConfig($ConfigObject)
        }

    }

}
