function Update-MtRoleInfo {
    <#
.SYNOPSIS
Updates the list of directory admin roles from Entra ID.

.DESCRIPTION
Update-MtRoleInfo updates the list of directory admin roles from Entra ID, making the display name, description, and template ID available to the rest of the Maester module's functions.

.NOTES
Related "to do" items from the Get-MtRoleInfo Script:

    - Auto generate on each build. Manual process for now is to run the following command and copy the output to the switch statement.

        $RoleTemplateIDs = Invoke-MtGraphRequest -RelativeUri 'directoryRoleTemplates' | Select-Object id, displayName | Sort-Object displayName | ForEach-Object { "`"$($($_.displayName) -replace ' ')`" { '$($_.id)'}" }

    - Also use the below to generate the ValidateSet for this parameter in Get-MtRoleMember whenever this is updated

        $RoleValidateSet = (Invoke-MtGraphRequest -RelativeUri 'directoryRoleTemplates' | Select-Object id, displayName | Sort-Object displayName | ForEach-Object { "'$($($_.displayName) -replace ' ')'" }) -join ', '
#>
    [CmdletBinding()]
    [OutputType('MtDirectoryRoleTemplate')]
    param()

    process {
        # Get all directory role templates from the Microsoft Graph API and sort them by displayName.
        try {
            $DirectoryRoleTemplates = Invoke-MtGraphRequest -RelativeUri 'directoryRoleTemplates' | Sort-Object -Property displayName
        } catch {
            throw "Failed to retrieve directory role templates: $_"
        }

        # Create a list and add each role template to it.
        $Roles = New-Object 'System.Collections.Generic.List[MtDirectoryRoleTemplate]'
        $DirectoryRoleTemplates | ForEach-Object {
            $Roles.Add(
                [MtDirectoryRoleTemplate]::new(
                    $_.displayName,
                    $_.id,
                    $_.description
                )
            )
        }
    }

    begin {
        # Check if connected to the Microsoft Graph API.
        if (-not (Get-MgContext)) {
            throw 'Not connected to Microsoft Graph API. Please connect first by using Connect-MgGraph or Connect-Maester.'
        }

        # Define the MtDirectoryRoleTemplate class to hold role information.
        class MtDirectoryRoleTemplate {
            [string]$Name
            [guid]  $TemplateId
            [string]$Description

            # Constructor that initializes the object with default values.
            MtDirectoryRoleTemplate ( ) { $this.Init(@{}) }

            # Constructor that takes a hashtable of properties.
            MtDirectoryRoleTemplate ( [hashtable]$Properties ) { $this.Init($Properties) }

            # Constructor that takes individual properties (requires all).
            MtDirectoryRoleTemplate ( [string]$Name, [guid]$TemplateId, [string]$Description ) {
                if ([string]::IsNullOrWhiteSpace($Name)) { throw 'A name is required.' }
                if (-not $TemplateId) { throw 'A TemplateId (GUID) is required.' }
                if ([string]::IsNullOrWhiteSpace($Description)) { throw 'A description is required.' }

                $this.Name = $Name
                $this.TemplateId = $TemplateId
                $this.Description = $Description
            }

            # Shared initialization method from a hash table.
            [void] Init ( [hashtable]$Properties ) {
                foreach ($Property in $Properties.Keys) {
                    $this.$Property = $Properties[$Property]
                }
            }

            [string] ToString () {
                return "$($this.Name) ($($this.TemplateId))`n$($this.Description)"
            }

        }
    } # end begin block

    end {
        $Roles
    } # end end block

} # end function
