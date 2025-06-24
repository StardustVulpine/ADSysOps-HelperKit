Using Namespace System;
Using Namespace System.Drawing;
Using Namespace System.Windows.Forms;

Add-Type -AssemblyName System;
Add-Type -AssemblyName System.Drawing;
Add-Type -AssemblyName System.Windows.Forms;

[String]  $Global:ProgramName    = "Directory Inheritence Scanner";
[Float]   $Global:ProgramVersion = "3.0";
[String]  $Global:ProgramIcon    = "$PSScriptRoot\icon.ico";
[String]  $Global:ProgramDesc    = "This program perform scans of all subfolders inside given path or multiple paths and check if there are any folders with disabled ACL entries inheritance. Additionally catches cases where folder doesn't exist, path is too long or access is denied.";


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
            $this.TABLE.Padding = System.Windows.Forms.Padding(10,10,10,10);
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
            throw "File not found: $Path"
        }
        $json = Get-Content -Raw -Path $Path | ConvertFrom-Json
        return $json
    }

    static [void] Export([string] $Path, [object] $Data) {
        $json = $Data | ConvertTo-Json -Depth 10
        Set-Content -Path $Path -Value $json -Encoding UTF8
    }
}

#endregion