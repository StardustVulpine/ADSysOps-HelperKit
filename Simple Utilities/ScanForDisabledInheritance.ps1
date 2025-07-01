function Get-FolderInheritanceInformation 
{
    # Scan through all folders in given path, with specified depth and check if folders have disabled inheritance.
    $FoldersNames = @()
    [int]$check = 1
    do{
        Write-host "This script will scan all provided paths and check if any folder has disabled ACL inheritance"
        Write-host "This will be infinite loop for collecting multiple paths to scan"
        Write-host "Type path you want to scan (leave empty and hit enter to proceed to scanning): "
        $Temporary = Read-Host
        if($Temporary -like ""){
            break
        }else{
            $FoldersNames += $Temporary  
        }
    }while($check -eq 1)
    Write-host "Type the location for those folders (ex. Villotta, San Polo, etc):"
    $location = Read-Host
    #-------------------------------------------------------

    foreach($path in $FoldersNames){
        $PermissionInfo = @()
        $listOfFolders = @()

        # Statistics
        $FoldersTotal = 0
        $checkedFoldersCount = 0
        $foldersWithoutInheritence = 0
        $foldersNotExists = 0
        $foldersWithNoAccess = 0
        #$totalErrors = 0

        # Preparing exported file name
        $folderName = $path -replace '\\\\.+\\'
        $scriptPath = $MyInvocation.MyCommand.Path
        $scriptDir = Split-Path $scriptPath
        $DateTime = Get-Date -Format "(dd-MM-yyyy; HH-mm-ss)"
        $exportedFileName = "$location-$folderName-inheritance_check_($DateTime).csv"

        # Check if export path exists, if not, create folder for exports and set true path
        $ExportPath = "$scriptDir\Scan_For_Inheritance_Results\"
        if(!(Test-Path -PathType Container $ExportPath))
        {
            New-Item -ItemType Directory -Path $ExportPath
            Write-Host -ForegroundColor Green "Created directory $ExportPath."
        }
        $ExportPathTrue = Join-Path $ExportPath $exportedFileName;


        if(Test-Path -PathType Container $path)
        {
            # Collect folders from given path
            Get-ChildItem -LiteralPath $path -Directory -Recurse -Force -ErrorAction Ignore | ForEach-Object {
                $listOfFolders += $_.FullName
                $FoldersTotal++
                $DateTime = Get-Date -Format "(dd-MM-yyyy; HH-mm-ss)"
                Write-Host $DateTime " - " $_.FullName
                for($prec = 0; $prec -le 100; $prec += 5)
                {
                    Write-Progress -Activity "Loading folders from $path.." -PercentComplete $prec -Status "Loading folder $_"
                    Start-Sleep -Milliseconds 0.1
                }
            }
            Write-Host "Folders count " $listOfFolders.Count
        }
        else
        {
            Write-Host -ForegroundColor Red "Not found path to scan: $path"
        }

        
        # Start actual scan by iterating over all collected folders
        [string] $DateTime2 = Get-Date -Format "(dd-MM-yyyy; HH-mm-ss)";
        Write-Host -ForegroundColor Yellow "$DateTime2 - Started scanning $FoldersTotal folders"
        ForEach($Folder in $listOfFolders)
        {
            $checkedFoldersCount++
            $prec = [Math]::Round((($checkedFoldersCount/$FoldersTotal)*100), 2); 
            Write-Progress -Activity "Checking folders." -Status "$checkedFoldersCount/$FoldersTotal ($prec%). Cannot access path: $foldersNotExists, Access denied: $foldersWithNoAccess folders, Folders without inheritance: $foldersWithoutInheritence ;   " -PercentComplete $prec -CurrentOperation "Scanning $Folder";

            try {
                # Grab folder's ACL
                $Acl = Get-Acl -LiteralPath $Folder
                
                # Check if permissions inheritance is disabled and write output to console and file.
                if($Acl.AreAccessRulesProtected -eq $true)
                {
                    [string] $DateTime4 = Get-Date -Format "(dd-MM-yyyy; HH-mm-ss)";
                    $foldersWithoutInheritence++
                    Write-Host -ForegroundColor Yellow "$DateTime4 - Disabled inheritance inside folder: $Folder"
                            
                    $Permissions = [PSCustomObject]@{
                        "Folder Name" = $Acl.PSChildName
                        "Path" = $Folder
                        "Issue:" = "Disabled inheritance"
                    }
                    $PermissionInfo += $Permissions
                }
            }
            catch [System.UnauthorizedAccessException] {
                # Catch and report Access Denied
                $foldersWithNoAccess++
                [string] $DateTime5 = Get-Date -Format "(dd-MM-yyyy; HH-mm-ss)";
                Write-Host -ForegroundColor Yellow "$DateTime5 - Access denied to specified path:`n$Folder"
                $folderName = $Folder -split "\";

                $Permissions = [PSCustomObject]@{
                    "Folder Name" =  $folderName[-1]
                    "Path" = $Folder
                    "Issue:" = "Access denied"
                }
                $PermissionInfo += $Permissions
            }
            catch [System.IO.DirectoryNotFoundException] {
                # Catch and report not existing folder
                [string] $DateTime6 = Get-Date -Format "(dd-MM-yyyy; HH-mm-ss)";
                Write-Host -ForegroundColor Yellow "$DateTime6 - The following folder path could not be ressolved:`n$Folder"
                $foldersNotExists++

                $Permissions = [PSCustomObject]@{
                    "Folder Name" = $Acl.PSChildName
                    "Path" = $Folder
                    "Issue:" = "Path could not be resolved"
                }
                $PermissionInfo += $Permissions
            }
            catch {
                if($Error[0].Exception -is [System.UnauthorizedAccessException])
                {
                    $foldersWithNoAccess++
                    [string] $DateTime5 = Get-Date -Format "(dd-MM-yyyy; HH-mm-ss)";
                    Write-Host -ForegroundColor Red "$DateTime5 - Access denied to $pathToFolder"
                    $folderName = $pathToFolder -split "\";

                    $Permissions = [PSCustomObject]@{
                        "Folder Name" =  $folderName[-1]
                        "Path" = $pathToFolder
                        "Issue:" = "Access denied"
                    }
                    $PermissionInfo += $Permissions
                } elseif ($Error[0].Exception -is [System.IO.DirectoryNotFoundException])
                {
                    # Catch and report not existing folder
                    [string] $DateTime6 = Get-Date -Format "(dd-MM-yyyy; HH-mm-ss)";
                    Write-Host -ForegroundColor Yellow "$DateTime6 - The following folder path could not be ressolved:`n$Folder"
                    $foldersNotExists++

                    $Permissions = [PSCustomObject]@{
                        "Folder Name" = $Acl.PSChildName
                        "Path" = $Folder
                        "Issue:" = "Path could not be resolved"
                    }
                    $PermissionInfo += $Permissions
                } else {
                    Write-Host -ForegroundColor Red "Unhandled exeption has occured!";
                    Write-Host "Error details:`n";
                    Write-Host $_;
                }
                
            }
        }
        $PermissionInfo | Export-Csv -Path $ExportPathTrue -Encoding UTF8 -NoTypeInformation
        [string] $DateTime7 = Get-Date -Format "(dd-MM-yyyy; HH-mm-ss)";
        Write-Host -ForegroundColor Green "$DateTime7 - Checked for $checkedFoldersCount/$FoldersTotal folders. Folder Not Found: $foldersNotExists, Access denied: $foldersWithNoAccess folders, Folders without inheritance: $foldersWithoutInheritence."
    }
}
Start-Transcript -Path ".\CheckDirectoryInheritance_LogFile_$DateTime7.txt" -Append
Get-FolderInheritanceInformation
Stop-Transcript