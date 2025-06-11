Add-Type -AssemblyName System;
Add-Type -AssemblyName System.Drawing;
Add-Type -AssemblyName System.Windows.Forms;

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

class Size {
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

    [int] Get() {
        return @($this.Width, $this.Height);
    }
}

class Window {
    [string] $Title;
    [Size] $Size;
    [Size] $MinSize;
    [Size] $MaxSize;
    [string] $Icon;
    [string] $StartPosition;

    Window([string]$title, [Size]$size, [hashtable]$options = @{}) {
        $this.Title = $title
        $this.Size = $size

        if ($options.ContainsKey("MinSize")) { $this.MinSize = $options["MinSize"] }
        if ($options.ContainsKey("MaxSize")) { $this.MaxSize = $options["MaxSize"] }
        if ($options.ContainsKey("Icon")) { $this.Icon = $options["Icon"] }
        if ($options.ContainsKey("StartPosition")) { $this.StartPosition = $options["StartPosition"] }
    }
}

$window = [Window]::New("Test Window", [Size]::New(800, 600), @(
    MinSize =
    MaxSize =
    
))