function Find-CMObjectByPackageId {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$PackageId
    )

    begin {
        $prov = Get-CimInstance -Namespace root\sms -ClassName SMS_ProviderLocation |
               Where-Object ProviderForLocalSite -eq $true
        if (-not $prov) { throw "SMS Provider not found. The ConfigMgr console/provider may not be installed on this machine." }
        $ns = "root\sms\site_{0}" -f $prov.SiteCode

        $typeMap = @{
            'SMS_Package'                       = 'Legacy Package'
            'SMS_DriverPackage'                 = 'Driver Package'
            'SMS_BootImagePackage'              = 'Boot Image'
            'SMS_ImagePackage'                  = 'OS Image'
            'SMS_OperatingSystemInstallPackage' = 'OS Upgrade Package'
            'SMS_SoftwareUpdatesPackage'        = 'Software Updates Deployment Package'
            'SMS_TaskSequencePackage'           = 'Task Sequence'
        }

        $results = @()
    }

    process {
        foreach ($id in $PackageId) {
            $idEsc = $id -replace "'", "''"

            $res = Get-CimInstance -Namespace $ns `
                   -Query "SELECT PackageID,Name,Version,PkgSourcePath,SourceDate,Manufacturer,__CLASS FROM SMS_PackageBaseClass WHERE PackageID = '$idEsc'" `
                   -ErrorAction SilentlyContinue

            if ($res) {
                $cls  = $res.__CLASS
                $type = if ($typeMap.ContainsKey($cls)) { $typeMap[$cls] } else { $cls }

                $results += [pscustomobject]@{
                    PackageID     = $res.PackageID
                    Type          = $type
                    DisplayName   = $res.Name
                    Version       = $res.Version
                    SourcePath    = $res.PkgSourcePath
                    Manufacturer  = $res.Manufacturer
                    SourceDate    = $res.SourceDate
                    Detail        = $null
                }
                continue
            }

            $cp = Get-CimInstance -Namespace $ns -ClassName SMS_ContentPackage `
                  -Filter "PackageID='$idEsc'" -ErrorAction SilentlyContinue

            if ($cp) {
                $links = Get-CimInstance -Namespace $ns -ClassName SMS_CIToContent `
                         -Filter "ContentID=$($cp.ContentID)" -ErrorAction SilentlyContinue

                if ($links) {
                    foreach ($lnk in $links) {
                        $dt  = Get-CimInstance -Namespace $ns -ClassName SMS_DeploymentType `
                               -Filter "CI_ID=$($lnk.CI_ID)" -ErrorAction SilentlyContinue
                        if ($dt) {
                            $app = Get-CimInstance -Namespace $ns -ClassName SMS_ApplicationLatest `
                                   -Filter "CI_ID=$($dt.ApplicationCIID)" -ErrorAction SilentlyContinue

                            $results += [pscustomobject]@{
                                PackageID          = $id
                                Type               = 'Application content'
                                DisplayName        = $app.LocalizedDisplayName
                                DeploymentTypeName = $dt.LocalizedDisplayName
                                ApplicationCI_ID   = $app.CI_ID
                                DeploymentTypeCI_ID= $dt.CI_ID
                                ContentID          = $cp.ContentID
                                Detail             = $null
                            }
                        }
                        else {
                            $results += [pscustomobject]@{
                                PackageID   = $id
                                Type        = 'Application content (yetim)'
                                DisplayName = $cp.Name
                                ContentID   = $cp.ContentID
                                Detail      = $null
                            }
                        }
                    }
                    continue
                }
                else {
                    $results += [pscustomobject]@{
                        PackageID   = $id
                        Type        = 'Content package'
                        DisplayName = $cp.Name
                        ContentID   = $cp.ContentID
                        Detail      = $null
                    }
                    continue
                }
            }

            $results += [pscustomobject]@{
                PackageID   = $id
                Type        = 'Not found'
                DisplayName = $null
                Detail      = $null
            }
        }
    }

    end {
        # You can change the sorting logic here as you like
        # Example: Alphabetically by DisplayName:

        $results | Sort-Object DisplayName
    }
}
