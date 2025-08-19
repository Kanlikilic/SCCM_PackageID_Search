# SCCM_PackageID_Search
PowerShell module to find SCCM/ConfigMgr objects by PackageID.

## Installation
Clone the repository or download the module files, then import:
```powershell
Import-Module .\PackageID_Search.psd1 -Force

## Usage
powershell
# Search for a single PackageId
Find-CMObjectByPackageId -PackageId "PKG00012" | Format-List

# Search for multiple PackageIds
Find-CMObjectByPackageId -PackageId "PKG00013","PKG00077" | Format-Table
Note: The PackageId parameter accepts one or more values.

