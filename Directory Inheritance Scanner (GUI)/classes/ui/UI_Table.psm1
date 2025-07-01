Using Namespace System;
Using Namespace System.Drawing;
Using Namespace System.Windows.Forms;
Using Namespace System.Xml;
Using Namespace System.IO;
Using Namespace System.IO.Directory;

. "..\enums\eDockType.ps1"
. "..\enums\eBorder.ps1"

class UI_Table
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
            #Write-Host $this.Padding.Count;
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
            # try {
            #     $this.TABLE.Padding = System.Windows.Forms.Padding(10,10,10,10);
            # } catch {
            #     Write-Error "Error: $($_.Exception.Message)"
            # }

            #$this.TABLE.Padding = System.Windows.Forms.Padding(10,10,10,10);
        }
        if($null -ne $this.ShowBorder) { 
            $this.TABLE.BackColor = 'Cyan';
            $this.TABLE.BorderStyle = 'FixedSingle';
        }
    }

    [System.Windows.Forms.TableLayoutPanel] GetTable() { return $this.Table; }

}