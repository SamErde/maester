$BasePath = Join-Path -Path $PSScriptRoot "..\powershell"
Set-Location -Path $BasePath
$TestFiles = Get-ChildItem "Test-Mt*.ps1" -Recurse -Exclude "*.Tests.ps1"

foreach ($file in $TestFiles) {

    $FilePath = "$($file.FullName)"
    $Description = "Maester Test: $($file.Name)"
    $Guid = (New-Guid)
    switch -regex ($FilePath) {
        [eidsca] { $Category = 'EIDSCA'}
        [CISA] { $Category = 'CISA' }
        default { $Category = 'Core' }
    }
    $Status = 'Active'
    $Tags = "`'$Status`', `'$Category`'"

    $Info = @"
<#PSScriptInfo
.DESCRIPTION $Description
.TAGS $Tags
.AUTHOR The Maester Team
.COMPANYNAME The Maester Team
.COPYRIGHT Maester Team. All rights reserved.
.VERSION '0.0.1'
.GUID $Guid
.ICONURI https://maester.dev/img/logo.svg
#>
`n
"@

    $FileContent = Get-Content -Path $file
    $StringBuilder = [System.Text.StringBuilder]::new(($FileContent) -join ([System.Environment]::NewLine))
    $null = $StringBuilder.Insert(0, $Info)
    $StringBuilder.ToString() | Set-Content -Path $FilePath -Encoding utf8
}
