# Generated on 03/11/2025 11:45:03 by .\build\orca\Update-OrcaTests.ps1

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
param()

Function Get-ORCACollection
{
    Param (
        [Boolean]$SCC
    )

    $Collection = @{}

    [ORCAService]$Collection["Services"] = [ORCAService]::EOP

    # Determine if MDO is available by checking for presence of an MDO command
    if($(Get-command Get-AtpPolicyForO365 -ErrorAction:SilentlyContinue))
    {
        $Collection["Services"] += [ORCAService]::MDO
    }

    If(!$Collection["Services"] -band [ORCAService]::MDO)
    {
        Write-Verbose "$(Get-Date) Microsoft Defender for Office 365 is not detected - these checks will be skipped!" -ForegroundColor Red
    }

    Write-Verbose "$(Get-Date) Getting Anti-Spam Settings"
    $Collection["HostedConnectionFilterPolicy"] = Get-MtExo -Request HostedConnectionFilterPolicy
    $Collection["HostedContentFilterPolicy"] = Get-MtExo -Request HostedContentFilterPolicy
    $Collection["HostedContentFilterRule"] = Get-MtExo -Request HostedContentFilterRule
    $Collection["HostedOutboundSpamFilterPolicy"] = Get-MtExo -Request HostedOutboundSpamFilterPolicy
    $Collection["HostedOutboundSpamFilterRule"] = Get-MtExo -Request HostedOutboundSpamFilterRule

    If($Collection["Services"] -band [ORCAService]::MDO)
    {
        Write-Verbose "$(Get-Date) Getting MDO Preset Policy Settings"
        $Collection["ATPProtectionPolicyRule"] = Get-MtExo -Request ATPProtectionPolicyRule
        $Collection["ATPBuiltInProtectionRule"] = Get-MtExo -Request ATPBuiltInProtectionRule
    }

    if($SCC -and $Collection["Services"] -band [ORCAService]::MDO)
    {
        Write-Verbose "$(Get-Date) Getting Protection Alerts"
        $Collection["ProtectionAlert"] = Get-ProtectionAlert | Where-Object {$_.IsSystemRule}
    }

    Write-Verbose "$(Get-Date) Getting EOP Preset Policy Settings"
    $Collection["EOPProtectionPolicyRule"] = Get-MtExo -Request EOPProtectionPolicyRule

    Write-Verbose "$(Get-Date) Getting Quarantine Policy Settings"
    $Collection["QuarantinePolicy"] =  Get-MtExo -Request QuarantinePolicy
    $Collection["QuarantinePolicyGlobal"]  = Get-QuarantinePolicy -QuarantinePolicyType GlobalQuarantinePolicy

    If($Collection["Services"] -band [ORCAService]::MDO)
    {
        Write-Verbose "$(Get-Date) Getting Anti Phish Settings"
        $Collection["AntiPhishPolicy"] = Get-MtExo -Request AntiphishPolicy
        $Collection["AntiPhishRules"] = Get-MtExo -Request AntiPhishRule
    }

    Write-Verbose "$(Get-Date) Getting Anti-Malware Settings"
    $Collection["MalwareFilterPolicy"] = Get-MtExo -Request MalwareFilterPolicy
    $Collection["MalwareFilterRule"] = Get-MtExo -Request MalwareFilterRule

    Write-Verbose "$(Get-Date) Getting Transport Rules"
    $Collection["TransportRules"] = Get-MtExo -Request TransportRule

    If($Collection["Services"] -band [ORCAService]::MDO)
    {
        Write-Verbose "$(Get-Date) Getting MDO Policies"
        $Collection["SafeAttachmentsPolicy"] = Get-MtExo -Request SafeAttachmentPolicy
        $Collection["SafeAttachmentsRules"] = Get-MtExo -Request SafeAttachmentRule
        $Collection["SafeLinksPolicy"] = Get-MtExo -Request SafeLinksPolicy
        $Collection["SafeLinksRules"] = Get-MtExo -Request SafeLinksRule
        $Collection["AtpPolicy"] = Get-MtExo -Request AtpPolicyForO365
    }

    Write-Verbose "$(Get-Date) Getting Accepted Domains"
    $Collection["AcceptedDomains"] = Get-MtExo -Request AcceptedDomain

    Write-Verbose "$(Get-Date) Getting DKIM Configuration"
    $Collection["DkimSigningConfig"] = Get-MtExo -Request DkimSigningConfig

    Write-Verbose "$(Get-Date) Getting Connectors"
    $Collection["InboundConnector"] = Get-MtExo -Request InboundConnector

    Write-Verbose "$(Get-Date) Getting Outlook External Settings"
    $Collection["ExternalInOutlook"] = Get-MtExo -Request ExternalInOutlook

    # Required for Enhanced Filtering checks
    Write-Verbose "$(Get-Date) Getting MX Reports for all domains"
    $Collection["MXReports"] = @()
    ForEach($d in $Collection["AcceptedDomains"])
    {
        Try
        {
            $Collection["MXReports"] += Get-MxRecordReport -Domain $($d.DomainName) -ErrorAction:SilentlyContinue
        }
        Catch
        {
            Write-Verbose "$(Get-Date) Failed to get MX report for domain $($d.DomainName)"
        }

    }

    # ARC Settings
    Write-Verbose "$(Get-Date) Getting ARC Config"
    $Collection["ARCConfig"] = Get-MtExo -Request ArcConfig

    # Determine policy states
    Write-Verbose "$(Get-Date) Determining applied policy states"

    $Collection["PolicyStates"] = Get-PolicyStates -AntiphishPolicies $Collection["AntiPhishPolicy"] -AntiphishRules $Collection["AntiPhishRules"] -AntimalwarePolicies $Collection["MalwareFilterPolicy"] -AntimalwareRules $Collection["MalwareFilterRule"] -AntispamPolicies $Collection["HostedContentFilterPolicy"] -AntispamRules $Collection["HostedContentFilterRule"] -SafeLinksPolicies $Collection["SafeLinksPolicy"] -SafeLinksRules $Collection["SafeLinksRules"] -SafeAttachmentsPolicies $Collection["SafeAttachmentsPolicy"] -SafeAttachmentRules $Collection["SafeAttachmentsRules"] -ProtectionPolicyRulesATP $Collection["ATPProtectionPolicyRule"] -ProtectionPolicyRulesEOP $Collection["EOPProtectionPolicyRule"] -OutboundSpamPolicies $Collection["HostedOutboundSpamFilterPolicy"] -OutboundSpamRules $Collection["HostedOutboundSpamFilterRule"] -BuiltInProtectionRule $Collection["ATPBuiltInProtectionRule"]
    $Collection["AnyPolicyState"] = Get-AnyPolicyState -PolicyStates $Collection["PolicyStates"]

    # Add IsPreset properties for Preset policies (where applicable)
    Add-IsPresetValue -CollectionEntity $Collection["HostedContentFilterPolicy"]
    Add-IsPresetValue -CollectionEntity $Collection["EOPProtectionPolicyRule"]

    If($Collection["Services"] -band [ORCAService]::MDO)
    {
        Add-IsPresetValue -CollectionEntity $Collection["ATPProtectionPolicyRule"]
        Add-IsPresetValue -CollectionEntity $Collection["AntiPhishPolicy"]
        Add-IsPresetValue -CollectionEntity $Collection["SafeAttachmentsPolicy"]
        Add-IsPresetValue -CollectionEntity $Collection["SafeLinksPolicy"]
    }

    Return $Collection
}
