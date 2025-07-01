Using Namespace System;
Using Namespace System.Drawing;
Using Namespace System.Windows.Forms;
Using Namespace System.Xml;
Using Namespace System.IO;
Using Namespace System.IO.Directory;

Add-Type -AssemblyName System;
Add-Type -AssemblyName System.Drawing;
Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.Xml;

# Setting root directory of repository
$repositoryRoot;
if ($MyInvocation.MyCommand.Path) {
    $repositoryRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
    #Write-Host "Split-Path -Parent `$MyInvocation.MyCommand.Path: $repositoryRoot" -ForegroundColor Cyan
} else {
    $repositoryRoot = Get-Location
    #Write-Host "Get-Location: $repositoryRoot" -ForegroundColor Cyan
}

# ------------------------------------------------------------------------------------
# Dot-sources
. "$repositoryRoot\Directory Inheritance Scanner (GUI)\classes\json\JsonHelper.psm1"
. "$repositoryRoot\Directory Inheritance Scanner (GUI)\classes\ui\Size.psm1"
. "$repositoryRoot\Directory Inheritance Scanner (GUI)\enums\eDockType.ps1"
. "$repositoryRoot\Directory Inheritance Scanner (GUI)\enums\eBorder.ps1"

# Modules imports
Import-Module "$repositoryRoot\Directory Inheritance Scanner (GUI)\Modules\Resolve-EnvPath.psm1" -Force
Import-Module "$repositoryRoot\Directory Inheritance Scanner (GUI)\classes\json\JsonHelper.psm1" -Force
Import-Module "$repositoryRoot\Directory Inheritance Scanner (GUI)\classes\ui\Size.psm1" -Force
Import-Module "$repositoryRoot\Directory Inheritance Scanner (GUI)\classes\ui\Window.psm1" -Force
Import-Module "$repositoryRoot\Directory Inheritance Scanner (GUI)\classes\ui\Table.psm1" -Force



# Global Variables

[String]  $Global:ProgramName;
[Float]   $Global:ProgramVersion;
[String]  $Global:ProgramIcon;
[String]  $Global:ProgramDesc;
[String]  $Global:GlobalExportPath;
[String]  $Global:LocalExportPath;


#region Impoprt XML configs
Write-Host "Loading configuration files..." -ForegroundColor Cyan
$globalCfgPath = "$repositoryRoot\global.config";
$scannerCfgPath = "$repositoryRoot\Directory Inheritance Scanner (GUI)\.config"
Write-Host "Global Configuration File at: $globalCfgPath" -ForegroundColor Green
Write-Host "Scanner Configuration File at: $scannerCfgPath" -ForegroundColor Green

# Import Global configs:
Write-Host "Loading global configuration..." -ForegroundColor Cyan
[xml] $globalConfig = Get-Content -LiteralPath $globalCfgPath;
$Global:GlobalExportPath = Resolve-EnvPath -path ($globalConfig.config.global.add | Where-Object { $_.Key -eq "GlobalExportPath"} | Select-Object -ExpandProperty value);

Write-Host "Global Config File Loaded with configs:" -ForegroundColor Green
Write-Host "+ Global Export Path variable set to: $Global:GlobalExportPath"

# Import App configs
Write-Host "Loading scanner configuration..." -ForegroundColor Cyan
[xml] $config = Get-Content -LiteralPath $scannerCfgPath;
$Global:ProgramName = $config.config.scanner.add | Where-Object { $_.Key -eq "Name"} | Select-Object -ExpandProperty value;
$Global:ProgramVersion = $config.config.scanner.add | Where-Object { $_.Key -eq "Version"} | Select-Object -ExpandProperty value;
$Global:ProgramIcon = Join-Path $PSScriptRoot ($config.config.scanner.add | Where-Object { $_.Key -eq "Icon"} | Select-Object -ExpandProperty value);
$Global:ProgramDesc = $config.config.scanner.add | Where-Object { $_.Key -eq "Description"} | Select-Object -ExpandProperty value;
$Global:LocalExportPath = Resolve-EnvPath -path ($config.config.scanner.add | Where-Object { $_.Key -eq "ExportPath"} | Select-Object -ExpandProperty value);


Write-Host "Scanner configs loaded:" -ForegroundColor Green
Write-Host "+ Program Name          :   $Global:ProgramName"
Write-Host "+ Program Version       :   $Global:ProgramVersion"
Write-Host "+ Program Icon          :   $Global:ProgramIcon"
Write-Host "+ Program Description   :   $Global:ProgramDesc"
Write-Host "+ Local Export Path     :   $Global:LocalExportPath"

#endregion

#region Program

[UI]::New().Initialize();

#[JsonHelper]::Test("To jest test")


#endregion



#region UI
# Main UI Class for building & designing UI using building classes' objects
class UI
{
    [Window] $WIN;
    [UI_Table] $testTable;

    UI()
    {
        $this.WIN = [Window]::New($Global:ProgramName, [UI_Size]::New(600, 400), [UI_Size]::New(400,300), $Global:ProgramIcon);

        $this.testTable = [UI_Table]::New(1, 1, [eDockType]::Fill, @(10,10,10,10), [eBorder]::ShowBorder);

        try {
            $this.testTable.TABLE.AutoSize = $false;
            $this.testTable.TABLE.Margin = "10,10,10,10";
        } catch {
            Write-Error "Error: $($_.Exception.Message)"
        }
        
        $this.WIN.GetForm().Controls.Add($this.testTable.GetTable());
    }

    [void] Initialize() { 
        $this.WIN.Show();
    }
}
