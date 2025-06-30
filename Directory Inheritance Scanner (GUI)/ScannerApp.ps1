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
# Modules imports
Import-Module "$PSScriptRoot\Modules\Resolve-EnvPath.psm1"

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


#endregion



#region UI
# Main UI Class for building & designing UI using building classes' objects
class UI
{
    [Window] $WIN;
    [Table] $testTable;

    UI()
    {
        $this.WIN = [Window]::New($Global:ProgramName, [Size]::New(600, 400), [Size]::New(400,300), $Global:ProgramIcon);

        $this.testTable = [Table]::New(1, 1, [eDockType]::Fill, @(10,10,10,10), [eBorder]::ShowBorder);

        try {
            $this.testTable.Padding = System.Windows.Forms.Padding(10,10,10,10);
        } catch {
            Write-Error "Error: $($_.Exception.Message)"
        }
        
        $this.WIN.GetForm().Controls.Add($this.testTable.GetTable());
    }

    [void] Initialize() { 
        $this.WIN.Show();
    }
}

# UI Helper
class Size 
{
    [int] $Width;
    [int] $Height;

    Size([int] $width, [int] $height) {
        $this.Width = $width;
        $this.Height = $height;
    }
    [void] Set([int] $width, [int] $height) {
        $this.Width = $width;
        $this.Height = $height;
    }
    [Object] Get() {
        return New-Object System.Drawing.Size($this.Width, $this.Height);
    }
}

enum eDockType {
    Top
    Bottom
    Left
    Right
    Fill
}

enum eBorder {
    ShowBorder
    NoBorder
}

# UI Buidling Classes
class Window 
{
    [string] $Title;
    [Size] $Size;
    [Size] $MinSize;
    [Size] $MaxSize;
    [string] $Icon;
    [string] $StartPosition;

    [System.Windows.Forms.Form] $FORM

    Window([string]$title, [Size]$size) {
        $this.Title = $title;
        $this.Size = $size;

        $this.CreateWindow();
    }
    Window([string]$title, [Size]$size, [size] $minSize) {
        $this.Title = $title;
        $this.Size = $size;
        $this.minSize = $minSize;

        $this.CreateWindow();
    }
    Window([string]$title, [Size]$size, [size] $minSize, [String] $icon) {
        $this.Title = $title;
        $this.Size = $size;
        $this.minSize = $minSize;
        $this.Icon = $icon;

        $this.CreateWindow();
    }

    [void] CreateWindow(){
        $this.FORM = [System.Windows.Forms.Form]::New();
        $this.FORM.size = $this.Size.Get();
        $this.FORM.Text = $this.Title;

        if($null -ne $this.MinSize) { $this.FORM.MinimumSize = $this.MinSize.Get(); }
        if($null -ne $this.MaxSize) { $this.FORM.MaximumSize = $this.MaxSize.Get(); }
        if($null -ne $this.Icon)    { $this.FORM.Icon = $this.Icon; }
    }

    [System.Windows.Forms.Form] GetForm() { return $this.FORM; }

    [void] Show() { $this.FORM.ShowDialog(); }

    [void] AddComponent([Object] $component)
    {
        if (-not $component) {
            throw "No component provided";
        } elseif (-not $this.FORM) {
            throw "Form was not initialized. Make sure CreateWindow() was called in constructor.";
        } else {
            $this.FORM.Controls.Add($component);
        }
    }

}

class Table
{
    [int] $RowCount;
    [int] $ColCount;
    [eDockType] $DockType;
    [int[]] $Padding = @(0,0,0,0);
    [bool] $AutoSize;
    [eBorder] $ShowBorder;

    [System.Windows.Forms.TableLayoutPanel] $TABLE

    # Table([int]$rowCount, [int]$columnCount, [eDockType]$dockType, [int[]]$padding = @(), [bool]$autoSize, [eBorder]$showBorder) {
    #     $this.RowCount = $rowCount;
    #     $this.ColCount = $columnCount;
    #     $this.DockType = $dockType;
    #     $this.Padding = $padding;
    #     $this.AutoSize = $autoSize;
    #     $this.ShowBorder = $showBorder;

    #     $this.CreateTable();
    # }
    Table([int]$rowCount, [int]$columnCount, [eDockType]$dockType, [int[]]$padding = @(), [bool]$autoSize) {
        $this.RowCount = $rowCount;
        $this.ColCount = $columnCount;
        $this.DockType = $dockType;
        $this.Padding = $padding;
        $this.AutoSize = $autoSize;

        $this.CreateTable();
    }
    Table([int]$rowCount, [int]$columnCount, [eDockType]$dockType, [int[]]$padding = @(), [eBorder]$showBorder) {
        $this.RowCount = $rowCount;
        $this.ColCount = $columnCount;
        $this.DockType = $dockType;
        $this.Padding = $padding;
        $this.ShowBorder = $showBorder;

        $this.CreateTable();
    }
    # Table([int]$rowCount, [int]$columnCount, [eDockType]$dockType, [bool]$autoSize) {
    #     $this.RowCount = $rowCount;
    #     $this.ColCount = $columnCount;
    #     $this.DockType = $dockType;
    #     $this.AutoSize = $autoSize;
    # }
    Table([int]$rowCount, [int]$columnCount, [eDockType]$dockType, [eBorder]$showBorder) {
        $this.RowCount = $rowCount;
        $this.ColCount = $columnCount;
        $this.DockType = $dockType;
        $this.ShowBorder = $showBorder;

        $this.CreateTable();
    }

    [Table] Get() {return $this }

    [void]  CreateTable()
    {
        $this.TABLE = [System.Windows.Forms.TableLayoutPanel]::New();
        if($null -ne $this.RowCount) { $this.TABLE.RowCount = $this.RowCount}
        if($null -ne $this.ColCount) { $this.TABLE.ColumnCount = $this.ColCount}
        if($null -ne $this.DockType) 
        {
            switch ($this.DockType) {
                Top { $this.TABLE.Dock = "Top"; }
                Bottom { $this.TABLE.Dock = "Bottom"; }
                Left { $this.TABLE.Dock = "Left"; }
                Right { $this.TABLE.Dock = "Right"; }
                Fill { $this.TABLE.Dock = "Fill"; }
                Default { $this.TABLE.Dock = "Fill"; }
            }
        }
        if($null -ne $this.AutoSize) { $this.TABLE.AutoSize = $this.AutoSize}
        if($null -ne $this.Padding) {
            Write-Host $this.Padding.Count;
            <#if($this.Padding.Count -eq 4) {
                if ($this.TABLE.Dock -eq "Fill") {
                    $this.TABLE.Margin = New-Object System.Windows.Forms.Padding($this.Padding[0], $this.Padding[1], $this.Padding[2], $this.Padding[3])
                } else {
                    $this.TABLE.Padding = New-Object System.Windows.Forms.Padding($this.Padding[0], $this.Padding[1], $this.Padding[2], $this.Padding[3])
                }
                
            } elseif ($this.Padding.Count -eq 1) {
                if ($this.TABLE.Dock -eq "Fill") {
                    $this.TABLE.Margin = New-Object System.Windows.Forms.Padding($this.Padding[0])
                } else {
                    $this.TABLE.Padding = New-Object System.Windows.Forms.Padding($this.Padding[0])
                }
            }#>
            try {
                $this.TABLE.Padding = System.Windows.Forms.Padding(10,10,10,10);
            } catch {
                Write-Error "Error: $($_.Exception.Message)"
            }

            #$this.TABLE.Padding = System.Windows.Forms.Padding(10,10,10,10);
        }
        if($null -ne $this.ShowBorder) { 
            $this.TABLE.BackColor = 'Cyan';
            $this.TABLE.BorderStyle = 'FixedSingle';
        }
    }

    [System.Windows.Forms.TableLayoutPanel] GetTable() { return $this.Table; }

}

#endregion

#region Utilities
class JsonHelper {
    static [object] Load([string] $Path) {
        if (-not (Test-Path $Path)) {
            throw "File not found: $Path";
        }
        $json = Get-Content -Raw -Path $Path | ConvertFrom-Json;
        return $json;
    }

    static [void] Export([string] $Path, [object] $Data) {
        $json = $Data | ConvertTo-Json -Depth 10;
        Set-Content -Path $Path -Value $json -Encoding UTF8;
    }
}

class Utilities {
    static [string] GetrepositoryRoot() {
        if ($MyInvocation.MyCommand.Path) {
            return Split-Path -Parent $MyInvocation.MyCommand.Path
        } else {
            return Get-Location
        }
    }
}





#endregion