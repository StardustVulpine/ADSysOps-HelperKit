. "$PSScriptRoot\UITools.ps1"



$name = "Inheritence Scanner"
$version = "3.0"
$description =  @"
This program perform scans of all subfolders inside given path or multiple paths and check if there are any folders with disabled ACL entries inheritance.
Additionally catches cases where folder doesn't exist, path is too long or access is denied.
"@

# -------------------------------------------------------- #

#Imports
Add-Type -AssemblyName System;
Add-Type -AssemblyName System.Drawing;
Add-Type -AssemblyName System.Windows.Forms;

#Definitions
$_FORM = [System.Windows.Forms.Form];
$_LABEL = [System.Windows.Forms.Label];
$_BUTTON = [System.Windows.Forms.Button];
$_TEXT_INPUT_BOX = [System.Windows.Forms.RichTextBox];
$_OPEN_FILE_DIALOG = [System.Windows.Forms.OpenFileDialog];
$_FOLDER_BROWSING_DIALOG = [System.Windows.Forms.FolderBrowserDialog];
$_LIST_BOX = [System.Windows.Forms.ListBox];
$_MENU_STRIP = [System.Windows.Forms.MenuStrip];
$_PANEL = [System.Windows.Forms.Panel];
$_MESSAGE_BOX = [System.Windows.Forms.MessageBox];
$_TABLE_LAYOUT_PANEL = [System.Windows.Forms.TableLayoutPanel];
$_GROUP_BOX = [System.Windows.Forms.GroupBox];

#region -------- UI Helper --------
    function New-Window {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)][int] $width,
            [Parameter(Mandatory)][int] $height,
            [Parameter(Mandatory)][string] $title,
            [int] $minWidth = $null,
            [int] $maxWidth = $null,
            [int] $minHeight = $null,
            [int] $maxHeight = $null
        )
        $window = New-Object $_FORM;
        $window.size = New-Object System.Drawing.Size($width, $height);
        $window.Text = $title;

        if($minWidth -ne $null -and $minHeight -ne $null ) {
            $window.MinimumSize = New-Object System.Drawing.Size($minWidth, $minHeight);
        }
        if($maxWidth -ne $null -and $maxHeight -ne $null ) {
            $window.MinimumSize = New-Object System.Drawing.Size($maxWidth, $maxHeight);
        }

        return $window;
    }
    function New-Button {
        [CmdLetBinding()]
        param (
            [int] $width,
            [int] $height,
            [string] $label,
            [int] $positionX,
            [int] $positionY
        )

        $button = New-Object $_BUTTON;
        $button.size = New-Object System.Drawing.Size($width, $height);
        $button.location = New-Object System.Drawing.Point($positionX, $positionY);
        $button.text = $label;
        
        return $button;
    }
    function New-Label {
        [CmdLetBinding()]
        param (
            [Parameter(Mandatory)][int] $width,
            [Parameter(Mandatory)][int] $height,
            [Parameter(Mandatory)][string] $text,
            [Parameter(Mandatory)][int] $positionX,
            [Parameter(Mandatory)][int] $positionY
        )
    
        $Label = New-Object $_LABEL;
        $Label.Width = $width;
        $Label.Height = $height;
        $Label.Text = $text;
        $Label.Location = New-Object System.Drawing.Point($positionX, $positionY);
    
        return $Label;
    }
    function New-TextInput {
        param (
            [int] $width,
            [int] $height,
            [int] $positionX,
            [int] $positionY
        )
        $TextBox = New-Object $_TEXT_INPUT_BOX;
        $TextBox.size = New-Object System.Drawing.Size($width,$height);
        $TextBox.Location = New-Object System.Drawing.Point($positionX,$positionY);
        
        return $TextBox;
    }
    function New-ListBox {
        [CmdLetBinding()]
        param (
            [int] $width,
            [int] $height,
            [int] $positionX,
            [int] $positionY
        )
        $ListBox = New-Object $_LIST_BOX;
        $ListBox.Width = $width;
        $ListBox.Height = $height;
        $ListBox.Location = New-Object System.Drawing.Point($positionX,$positionY);

        return $ListBox;
    }
    function New-TableLayout {
    [CmdLetBinding()]
    param (
        [Parameter(Mandatory)][int] $rows,
        [Parameter(Mandatory)][int] $columns,
        [int[]] $padding = @(0, 0, 0, 0), # Optional default padding
        [bool] $autosize = $false
    )

    $table = New-Object System.Windows.Forms.TableLayoutPanel
    $table.Dock = 'Fill'
    $table.RowCount = $rows
    $table.ColumnCount = $columns
    $table.AutoSize = $autosize

    if ($padding.Count -eq 1) {
        $table.Padding = New-Object System.Windows.Forms.Padding($padding[0])
    } elseif ($padding.Count -eq 4) {
        $table.Padding = New-Object System.Windows.Forms.Padding($padding[0], $padding[1], $padding[2], $padding[3])
    } else {
        throw "Invalid padding array. Must be 1 or 4 integers."
    }

    return $table
}

    function FillCellsWithLabelsAndColorThem([System.Windows.Forms.TableLayoutPanel]$table) {
        for ($row = 0; $row -lt $table.RowCount; $row++) {
            for ($col = 0; $col -lt $table.ColumnCount; $col++) {
                $label = New-Object System.Windows.Forms.Label
                $label.Text = "R$row C$col"
                $label.Dock = 'Fill'
                $label.TextAlign = 'MiddleCenter'
                $label.BackColor = if ($col % 2 -eq 0) { 'LightBlue' } else { 'LightCoral' }
        
                # Optional: set border for clarity
                $label.BorderStyle = 'FixedSingle'
        
                $table.Controls.Add($label, $col, $row)
            }
        }
    }
    function DebugCellLabel([string] $color) {
        $label = New-Object System.Windows.Forms.Label
        $label.Dock = 'Fill'
        $label.BackColor = $color
        $label.BorderStyle = 'FixedSingle'

        return $label;
    }
    
#endregion

#region Helper Functions
    function Remove-AllPanelsFromWindow($form) {
        foreach ($control in $form.Controls) {
            if ($control -is [System.Windows.Forms.Panel]) {
                $form.Controls.Remove($control)
                #$control.Dispose()
            }
        }
    }
#endregion

#region -------- App.UI --------
    #region Window
        $Window_Main = New-Window -width 500 -height 350 -title "$name v$version";
        $Window_Main.ShowIcon = $true;
        $Window_Main.Icon = New-Object System.Drawing.Icon "$PSScriptRoot\icon.ico";
        
        $Window_Main.StartPosition = "CenterScreen";
        $Window_Main.MinimumSize = New-Object System.Drawing.Size(300,300);
    #endregion

    #region -------- Window Content --------
        $mainTable = New-TableLayout -rows 2 -columns 1 -autosize $true;
        $mainTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle("Percent", 100)));
        $mainTable.RowStyles.Add((New-Object System.Windows.Forms.RowStyle("Absolute", 20)));
        $mainTable.RowStyles.Add((New-Object System.Windows.Forms.RowStyle("Percent", 100)));


        #region -------- Menu Bar --------
            $menuStrip = New-Object $_MENU_STRIP;
            

            $fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem "File";
            $exitItem = New-Object System.Windows.Forms.ToolStripMenuItem "Exit";
            $exitItem.Add_Click({ $Window_Main.Close() });
            $fileMenu.DropDownItems.Add($exitItem);

            $debugMenu = New-Object System.Windows.Forms.ToolStripMenuItem "Debug";
            $debugShowHomePanel = New-Object System.Windows.Forms.ToolStripMenuItem "Show Home Panel";
            $debugShowHomePanel.Add_Click({
                Remove-AllPanelsFromWindow($Window_Main)
                $Window_Main.Controls.Add($panelHome);
            });
            $debugShowSummaryPanel = New-Object System.Windows.Forms.ToolStripMenuItem "Show Summary Panel";
            $debugShowSummaryPanel.Add_Click({
                Remove-AllPanelsFromWindow($Window_Main);
                $Window_Main.Controls.Add($panelSummary);
            });
            $debugMenu.DropDownItems.AddRange(@($debugShowHomePanel,$debugShowSummaryPanel));
            
            
            $helpMenu = New-Object System.Windows.Forms.ToolStripMenuItem "Help";
            $aboutItem = New-Object System.Windows.Forms.ToolStripMenuItem "About";
            $aboutItem.Add_Click({ $_MESSAGE_BOX::Show($description, "About") });
            $helpMenu.DropDownItems.Add($aboutItem);

            $menuStrip.Items.AddRange(@($fileMenu, $debugMenu, $helpMenu));
            $menuStrip.Dock = 'Top';

            $Window_Main.Controls.Add($menuStrip)
            $Window_Main.MainMenuStrip = $menuStrip
            
        #endregion

        #region -------- Panel 1: Scanner Setup Screen --------
            $panelHome = New-Object $_PANEL;
            $panelHome.Dock = "Fill";
            $panelHome.Margin.Top = 200;

            # Home panel table:
            $homePanelTable = New-TableLayout -rows 3 -columns 1 -padding @(10,10,10,10) -autosize $true;
            $homePanelTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle("Percent", 100)));
            $homePanelTable.RowStyles.Add((New-Object System.Windows.Forms.RowStyle("Absolute", 50)));
            $homePanelTable.RowStyles.Add((New-Object System.Windows.Forms.RowStyle("Percent", 100)));
            $homePanelTable.RowStyles.Add((New-Object System.Windows.Forms.RowStyle("Absolute", 35)));
            #$homePanelTable.Padding = 10
            #$homePanelTable.CellBorderStyle = "Single"

            #-------- HOME TABLE CONTENT --------
                # Row 1 of Table:
                    #Group box for path input
                    $groupBox_PathInput = New-Object $_GROUP_BOX;
                    $groupBox_PathInput.Text = "Type path you want to include in scan";
                    $groupBox_PathInput.Dock = 'Fill'
                    
                    # Group box table
                    $inputBoxTable = New-TableLayout -rows 1 -columns 2 -autosize $true
                    $inputBoxTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle("Percent", 100)));
                    $inputBoxTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle("Absolute", 50)));
                    $inputBoxTable.RowStyles.Add((New-Object System.Windows.Forms.RowStyle("Percent", 100)));

                    # Group box text input
                    $InputBox_Path = New-TextInput;
                    $InputBox_Path.Dock = 'Fill';
                    
                    # Group box button
                    $btn_AddPath = New-Button -label "Add";
                    $btn_AddPath.Dock = 'Fill';
                    
                $inputBoxTable.Controls.Add($InputBox_Path, 0, 0);
                $inputBoxTable.Controls.Add($btn_AddPath, 1, 0);
                $groupBox_PathInput.Controls.AddRange($inputBoxTable);
                $homePanelTable.Controls.Add($groupBox_PathInput, 0, 0);
                
                # Row 2 of Table:
                    #List with paths added by user
                    $ListBox_pathsToScan = New-ListBox;
                    $ListBox_pathsToScan.Dock = 'Fill';
                    $ListBox_pathsToScan.Padding = "0,0,-10,0"

                $homePanelTable.Controls.Add($ListBox_pathsToScan, 0, 1)

                # Row 3 of Table:
                    # Table to organize buttons
                    $homeButtonsTableOrganizer = New-TableLayout -rows 1 -columns 3 -autosize $true
                    $homeButtonsTableOrganizer.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle("Absolute", 120)));
                    $homeButtonsTableOrganizer.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle("Percent", 100)));
                    $homeButtonsTableOrganizer.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle("Absolute", 100)));
                    $homeButtonsTableOrganizer.RowStyles.Add((New-Object System.Windows.Forms.RowStyle("Percent", 100)));

                    # Remove selected path button:
                    $btn_RemoveSelected = New-Button -label "Remove selected";
                    $btn_RemoveSelected.Dock = 'Fill';

                    # Next button
                    $btn_NextPage = New-Button -label "Next ->";
                    $btn_NextPage.Dock = 'Fill';

                $homeButtonsTableOrganizer.Controls.Add($btn_RemoveSelected, 0, 0)
                $homeButtonsTableOrganizer.Controls.Add($btn_NextPage, 2, 0)
                $homePanelTable.Controls.Add($homeButtonsTableOrganizer, 0, 2)
            
            $panelHome.Controls.Add($homePanelTable);

        #endregion

        #$mainTable.Controls.Add($panelHome, 0, 0);
        #$mainTable.Controls.Add($panelHome, 1, 0);

        $debugLabelBlue = DebugCellLabel("Blue");

        #region -------- Panel 2: Summary Screen --------
            $panelSummary = New-Object $_PANEL;
            $panelSummary.Dock = "Fill";
            $panelSummary.Margin.Top = 200;

            # Summary panel table:
            $summaryPanelTable = New-TableLayout -rows 2 -columns 1 -padding "10,10,10,10" -autosize $true;
            $summaryPanelTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle("Percent", 100)));
            $summaryPanelTable.RowStyles.Add((New-Object System.Windows.Forms.RowStyle("Percent", 100)));
            $summaryPanelTable.RowStyles.Add((New-Object System.Windows.Forms.RowStyle("Absolute", 35)));
            #$summaryPanelTable.Padding = 10
            $summaryPanelTable.CellBorderStyle = "Single"

                $groupBox_PathInput = New-Object $_GROUP_BOX;
                $groupBox_PathInput.Text = "Type path you want to include in scan";
                $groupBox_PathInput.Dock = 'Fill'


            $panelSummary.Controls.Add($debugLabelBlue);

        #endregion

            $pathsToBeScanned = @()
            $pathsToBeScanned = $ListBox_pathsToScan.Items;
    #endregion
            
    #region -------- UI Logic --------
        # Logic for button adding path to list of all paths to scan
        # Main Window Logic
            $btn_AddPath.Add_Click({
                if($InputBox_Path.Text -like "")
                {
                    $_MESSAGE_BOX::Show("Path input cannot be empty!","Error!")
                    
                }
                else {
                    $ListBox_pathsToScan.Items.Add($InputBox_Path.Text);
                    $InputBox_Path.Text = "";
                }
            });
            $btn_RemoveSelected.Add_Click({
                if ($ListBox_pathsToScan.SelectedItem) {
                    Write-Host $ListBox_pathsToScan.SelectedItem;
                    $ListBox_pathsToScan.Items.Remove($ListBox_pathsToScan.SelectedItem);
                }
                else {
                    Write-Host "No item selected";
                }
            });
            $btn_NextPage.Add_Click({
                $Window_Main.Controls.Remove($panelHome);
                $Window_Main.Controls.Add($panelSummary);
            });


    #endregion

    #region Initiate UI
        $Window_Main.Controls.Add($panelHome)
        $Window_Main.ShowDialog()
    #endregion
#endregion

#region App.Core



#endregion
