$TestFiles = gci *.ps1 -Recurse

foreach ($file in $TestFiles) {

    $FilePath = $file.FullName
    $Directory = $file.Directory
    $Description = "Maester Test _____"
    $Author = "Maester Team"
    $Tags = "active CISA $Directory"
    $Version = '0.0.1'

    $Info = @"
<#PSScriptInfo
.DESCRIPTION $Description
.VERSION $Version
.AUTHOR = $Author
.TAGS $Tags
#>

"@

    $FileContent = Get-Content -Path $file
    $StringBuilder = [System.Text.StringBuilder]::new(($FileContent) -join ([system.environment]::NewLine))
    $null = $StringBuilder.Insert(0, $Info)
    $StringBuilder.ToString() | Set-Content -Path $FilePath -Encoding utf8
}
