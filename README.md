# DisplayConfig

This PowerShell module allows you to manage various display settings like: Resolution, scaling, desktop positions and more.
It's built on top of the CCD (Connecting and Configuring Display) APIs. For more details, see: <https://learn.microsoft.com/en-us/windows-hardware/drivers/display/ccd-apis>

## Fork Notes

This is a fork of [MartinGC94/DisplayConfig](https://github.com/MartinGC94/DisplayConfig). The reason for this fork is to add a CI/CD (including code scanning, dependency alerts) and allow PC's to install straight from Github, instead of from PowerShellGallery via NuGet.

I intend to keep the base code sync'd with the above project as much as practical.

## Installation

### Option A: install via the included installer script (version-pinned)

1. Pick a released version from the Releases page.
2. Run the below commands in Powershell:

- `-Version`: The release version from step 1.

- `-PC`: Use 'localhost' or specify a remote computer.

    ```PowerShell
    & ([ScriptBlock]::Create((Invoke-RestMethod 'https://raw.githubusercontent.com/mefranklin6/DisplayConfig/main/install.ps1'))) -PC 'localhost' -Version '5.2.2'
    ```

### Option B: manual install (download + unzip)

1. Download the release asset named `DisplayConfig-<version>.zip`.
2. Unzip it into one of these module locations:

- Current user: `$HOME\Documents\WindowsPowerShell\Modules\`
- All users: `$env:ProgramFiles\WindowsPowerShell\Modules\`

After unzipping, you should end up with:

`...\Modules\DisplayConfig\DisplayConfig.psd1`

Then you can:

```PowerShell
Import-Module DisplayConfig
Get-Command -Module DisplayConfig
```

## Donation

The original author has a donation link here. [MartinGC94/DisplayConfig](https://github.com/MartinGC94/DisplayConfig). I have donated.

No donations will be accepted for this fork.
