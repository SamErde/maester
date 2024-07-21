$BasePath = Join-Path -Path $PSScriptRoot "..\powershell"
Set-Location -Path $BasePath
$TestFiles = Get-ChildItem "Test-Mt*.ps1" -Recurse -Exclude "*.Tests.ps1"

foreach ($file in $TestFiles) {
    Remove-PSScriptInfo -FilePath $($file.FullName) -ErrorAction Continue
}
