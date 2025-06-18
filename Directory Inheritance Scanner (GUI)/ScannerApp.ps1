Using Namespace System;
Using Namespace System.Drawing;
Using Namespace System.Windows.Forms;

Add-Type -AssemblyName System;
Add-Type -AssemblyName System.Drawing;
Add-Type -AssemblyName System.Windows.Forms;

[String] $Global:ProgramName    = "Directory Inheritence Scanner";
[Float]  $Global:ProgramVersion = "3.0";
[String]  $Global:ProgramIcon    = "$PSScriptRoot\icon.ico";
[String]  $Global:ProgramDesc    = "This program perform scans of all subfolders inside given path or multiple paths and check if there are any folders with disabled ACL entries inheritance. Additionally catches cases where folder doesn't exist, path is too long or access is denied.";


#region Program

[UI]::New().Initialize();


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

    static [void] Test() {
        Write-Host "JsonHelper is working."
    }
}

#endregion

#region UI
class UI
{
    [Object] $WIN;

    UI()
    {
        $this.WIN = [Window]::New($Global:ProgramName, [Size]::New(800, 600), [Size]::New(300,300), $Global:ProgramIcon).CreateWindow()

    }

    [void] Initialize() { 
        $this.WIN.ShowDialog() 
    }
}

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

class Window 
{
    [string] $Title;
    [Size] $Size;
    [Size] $MinSize;
    [Size] $MaxSize;
    [string] $Icon;
    [string] $StartPosition;

    [Form] $Form

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


    [Object] CreateWindow(){
        $this.Form = [Form]::New();
        $this.Form.size = $this.Size.Get();
        $this.Form.Text = $this.Title;

        if($null -ne $this.MinSize) {
            $this.Form.MinimumSize = $this.MinSize.Get();
        }
        if($null -ne $this.MaxSize) {
            $this.Form.MaximumSize = $this.MaxSize.Get();
        }
        if($null -ne $this.Icon) {
            $this.Form.Icon = $this.Icon;
        }

        return $this.Form;
    }


}
#endregion