# Update Process for Tests

Here are several concepts for updating Maester tests more precisely. For an update source, they use either GitHub, the PowerShell Gallery, or the module's local install folder as the source for updates.

Updating from the module's local installation location will require the module itself to be updated in order to update the Maester tests. Updating from GitHub or the PowerShell Gallery will allow faster updates of Maester tests without needing to update the entire module.

```mermaid
flowchart TB
  A(["Update-MaesterTests"])
  B{"Update Method<br><i class="fa-solid fa-laptop-code"></i> &nbsp; &nbsp; <i class="fa-solid fa-terminal"></i> &nbsp; &nbsp; <i class="fa-brands fa-github"></i>"}
  A --> B
  subgraph -Online["or"]
        D[["Update user-installed test definitions
    directly from GitHub."]]
        E[["Update user-installed test definitions
    directly from the PowerShell Gallery."]]
  end
  subgraph -Local[" "]
        C[["Update user-installed test definitions
    from the installed module definitions."]]
  end
  B -- -Local</br><i class="fa-solid fa-laptop-code"></i> --> C
  B -- -Online</br><i class="fa-brands fa-github"></i> --> D
  B -- -Online</br><i class="fa-solid fa-terminal"></i> --> E
  style -Online fill:#FFF9C4
  style -Local fill:#C8E6C9
```

## Versioning the Tests

We will track the version of each test in order to know when to update them. We will also track the lifecycle status of each tests in order to know when to disable or remove them. (This approach could potentially be applied to an entire bundle of tests, such as the CISA or EIDSCA tests.)

### Option 1: Track tests in a central location

Test versions and status could be tracked in a single location in the module. This approach could use a list of custom objects in PowerShell or store the details as JSON.

#### Advantages (Option 1)

- One place to track everything
- The data can be stored with the installed module and referenced by update functions

#### Disadvantages (Option 1)

- Could result in test updates still being tied to module updates
- May become error prone and unsustainable to update a central file with every test version change

#### Examples (Option 1)

```powershell
# Create a list of custom objects describing the version and status of each test
[System.Collections.Generic.List[PSCustomObject]]$TestVersions = @()
$TestVersions.Add( [PSCustomObject]@{
  Name = "TestName 1"
  Version = [version]'0.1.1'
  Status = "Active"
} )
$TestVersions.Add( [PSCustomObject]@{
  Name = "TestName 2"
  Version = [version]'0.0.1'
  Status = "Testing"
} )
$TestVersions.Add( [PSCustomObject]@{
  Name = "TestName 3"
  Version = [version]'0.0.2'
  Status = "Deprecated"
} )
$TestVersions.Add( [PSCustomObject]@{
  Name = "TestName 4"
  Version = [version]'0.2.4'
  Status = "Removed"
} )
```

Or potentially as JSON, if that gives the project any added flexibility:

```json
{
  "tests": [
    {
      "Name": "Test Name 1",
      "Version": "0.1.1",
      "Status": "Active"
    },
    {
      "Name": "Test Name 2",
      "Version": "0.0.1",
      "Status": "Testing"
    },
    {
      "Name": "Test Name 3",
      "Version": "0.0.2",
      "Status": "Deprecated"
    },
    {
      "Name": "Test Name 4",
      "Version": "0.2.4",
      "Status": "Removed"
    }
  ]
}
```

### Option 2: Add version and status metadata in every test

The concept below uses PSScriptInfo data to store version, status, and other details directly in each test's PS1 file. This can be templatized and then updated either by a developer or by GitHub actions after changes are made. During the update process, the PSScriptInfo for each test can be compared to the details of the latest tests available online.

> [!NOTE]
> As an aside, each test *could* then be published independently to the PowerShell Gallery as a function, but I do not believe people would like to see dozens or hundreds of individual scripts installed in this manner.

#### Advantages (Option 2)

- Every test can be versioned and updated or retired independently
- An update process for the tests can be separated from updates for the module
- Updates of tests could become very fast if only updating changed/removed tests
- A history of test versions and lifecycle might become easier for users to track
- Additional metadata for each test could become easier to track

#### Disadvantages (Option 2)

- Adds an extra step to the creation of every test
- Test files become slightly larger

#### Examples (Option 2)

Add the test's status, version, and even tags using PSScriptInfo tags.
The related markdown documentation file can also be referenced via .LINKS or .PrivateData.

```powershell
<#PSScriptInfo
.DESCRIPTION Maester Test: Test-MtCisaActivationNotification.ps1
.VERSION 0.0.1
.AUTHOR Maester Team
.TAGS Active, CISA, Entra
.PRIVATEDATA @{ Markdown='Test-MtCisaActivationNotification.md'; Reference='https://domain.com/moreinfo' }
#>

<#
.SYNOPSIS
    Checks for notification on role activation
.DESCRIPTION
    User activation of the Global Administrator role SHALL trigger an alert.
    User activation of other highly privileged roles SHOULD trigger an alert.
#>

function Test-MtCisaActivationNotification {
  # [... shortened for brevity ...] #
}

```

For a complete example, see the test scripts in this branch of the repository. The [build\Add-PSScriptInfo.ps1]([build\Add-PSScriptInfo.ps1](https://github.com/SamErde/maester/blob/Maester-Test-Versioning/build/Add-PSScriptInfo.ps1)) script was used to get started and add PSScriptInfo to existing tests.

...in progress...
