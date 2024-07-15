$TestFiles = gci *.ps1 -Recurse

foreach ($file in $TestFiles) {

    $FilePath = $file.FullName
    $DirectoryName = $($file.DirectoryName).Split('\')[-1]
    $Description = "Maester Test: $($file.Name)"
    $Author = "Maester Team"
    switch -regex ($FilePath) {
        [eidsca] { $Category = 'EIDSCA'}
        [CISA] { $Category = 'CISA' }
        default { $Category = 'Core' }
    }
    $Status = 'Active'
    $TagSort = @("$Category, $DirectoryName") | Sort-Object -Unique
    $Tags = "$Status, $($TagSort.ToString())"
    $Version = '0.0.1'

    $Info = @"
<#PSScriptInfo
.DESCRIPTION $Description
.VERSION $Version
.AUTHOR $Author
.TAGS $Tags
#>
`n
"@

    $FileContent = Get-Content -Path $file
    $StringBuilder = [System.Text.StringBuilder]::new(($FileContent) -join ([system.environment]::NewLine))
    $null = $StringBuilder.Insert(0, $Info)
    $StringBuilder.ToString() | Set-Content -Path $FilePath -Encoding utf8
}
