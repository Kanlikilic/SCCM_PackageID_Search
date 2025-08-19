@{
    RootModule        = 'PackageID_Search.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '31d1279f-27fa-4732-a76c-9676484b111d'
    Author            = 'Mert Efe Kanlikilic'
    Description       = 'PowerShell module to find SCCM/ConfigMgr objects by PackageID.'
    PowerShellVersion = '5.1'

    FunctionsToExport = @('Find-CMObjectByPackageId')
    CmdletsToExport   = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags       = @('PowerShell','SCCM','ConfigMgr','Automation')
            ProjectUri = 'https://github.com/Kanlikilic/SCCM_PackageID_Search'
        }
    }
}
