Using Namespace System;
Using Namespace System.Drawing;
Using Namespace System.Windows.Forms;
class Window 
{
    [string] $Title;
    [UI_Size] $Size;
    [UI_Size] $MinSize;
    [UI_Size] $MaxSize;
    [string] $Icon;
    [string] $StartPosition;

    [System.Windows.Forms.Form] $FORM

    Window([string]$title, [UI_Size]$size) {
        $this.Title = $title;
        $this.Size = $size;

        $this.CreateWindow();
    }
    Window([string]$title, [UI_Size]$size, [UI_Size] $minSize) {
        $this.Title = $title;
        $this.Size = $size;
        $this.minSize = $minSize;

        $this.CreateWindow();
    }
    Window([string]$title, [UI_Size]$size, [UI_Size] $minSize, [String] $icon) {
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