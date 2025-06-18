Using Namespace System;
Using Namespace System.Drawing;
Using Namespace System.Windows.Forms;
Using Namespace System.IO;
Using Namespace System.Text.Json;
Using Namespace System.Text.Json.Serialization;
Using Namespace Utilities;

[String] $Global:ProgramName    = "Directory Inheritence Scanner";
[Float]  $Global:ProgramVersion = "3.0";
[String]  $Global:ProgramIcon    = "$PSScriptRoot\icon.ico";
[String]  $Global:ProgramDesc    = "This program perform scans of all subfolders inside given path or multiple paths and check if there are any folders with disabled ACL entries inheritance. Additionally catches cases where folder doesn't exist, path is too long or access is denied.";

Add-Type -AssemblyName System;
Add-Type -AssemblyName System.Drawing;
Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.IO;
Add-Type -AssemblyName System.Text.Json;
Add-Type -AssemblyName System.Text.Json.Serialization;
#Add-Type -Path ".\Directory Inheritance Scanner (GUI)\Utilities\JsonHelper.cs" -Language CSharp

#$csPath = Resolve-Path ".\Directory Inheritance Scanner (GUI)\Utilities\JsonHelper.cs"
#Write-Host "CS Path: "$csPath
$TypeDefinition = @"
using System;
using System.IO;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Utilities
{
    public class JsonHelper
    {
        public static object Load(string path)
        {
            var content = File.ReadAllText(path);
            var doc = JsonDocument.Parse(content);
            return doc.RootElement.Clone();
        }

        public static void Export(string path, object data)
        {
            var options = new JsonSerializerOptions
            {
                WriteIndented = true
            };
            var json = JsonSerializer.Serialize(data, options);
            File.WriteAllText(path, json);
        }

        public static void Test()
        {
            Console.WriteLine("nanananana");
        }
    }
}
"@
Add-Type -TypeDefinition $TypeDefinition


#region Program
    [Utilities.JsonHelper]::Test()

    #Write-Host "Main function run";
    #$json = [Utilities.JsonHelper]::Load("$PSScriptRoot\config.json")
    #Write-Host $json.ExportPath

    #[UIBuilder]::New()
#endregion

#region Utilities
class Utilities {
   
}

#endregion

#region UI
class UIBuilder 
{
    UIBuilder()
    {
        $_window = [Window]::New($Global:ProgramName, [Size]::New(800, 600), [Size]::New(300,300), $Global:ProgramIcon).CreateWindow()
        $_window.ShowDialog()
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