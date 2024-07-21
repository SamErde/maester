function Get-MtTestVersions {
    # Get the version and status of Maester tests.
    [CmdletBinding()]
    param ()

    # Find all test files.
    $DevWorkingPath = Join-Path -Path $PSScriptRoot -ChildPath "..\"
    Set-Location -Path $DevWorkingPath
    $TestFiles = Get-ChildItem "Test-Mt*.ps1" -Recurse -Exclude "*.Tests.ps1","Test-MtContext.ps1"

    [System.Collections.Generic.List[PSCustomObject]]$Versions = @()

    # Loop through each file to read its version and status, then add to the list.
    foreach ($file in $TestFiles) {
        $Info = Get-PSScriptFileInfo $file

        switch -regex ($info.ScriptMetadataComment.Tags) {
            'Active'     { $Status = 'Active' }
            'Deprecated' { $Status = 'Deprecated' }
            'Retired'    { $Status = 'Retired' }
            'Removed'    { $Status = 'Removed' }
        }

        $Versions.Add(
            [PSCustomObject]@{
                Name = $Info.Name
                Version = $Info.ScriptMetadataComment.Version.OriginalVersion
                Status = $Status
            }
        )
    }
    # Return the list of versions.
    $Versions
}
