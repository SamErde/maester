Describe "CISA SCuBA" -Tag "MS.EXO", "MS.EXO.9.3", "CISA", "Security", "All" {
    It "MS.EXO.09.3: Disallowed file types SHALL be determined and enforced." {

        $result = Test-MtCisaAttachmentFileType

        if ($null -ne $result) {
            $result | Should -Be $true -Because "preset policies are enabled."
        }
    }
}