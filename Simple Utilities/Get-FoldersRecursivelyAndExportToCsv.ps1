Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-InputDialog {
    param (
        [string]$Message,
        [string]$Title
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size(400,150)
    $form.StartPosition = 'CenterScreen'

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Message
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(10,20)
    $form.Controls.Add($label)

    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Size = New-Object System.Drawing.Size(360,20)
    $textbox.Location = New-Object System.Drawing.Point(10,50)
    $form.Controls.Add($textbox)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $okButton.Location = New-Object System.Drawing.Point(290,80)
    $form.Controls.Add($okButton)

    $form.AcceptButton = $okButton

    if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $textbox.Text
    } else {
        return $null
    }
}

function Get-Folders {
    param (
        [string]$BasePath,
        [string]$Label
    )


    Write-Host "Getting folders for: $BasePath" -ForegroundColor Cyan

    $results = @()
    $folders = Get-ChildItem -Path $BasePath -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object{
        Write-Host $_.FullName
        $temp = [PSCustomObject]@{
            "FolderPath" = $_.FullName
        }
        $results += $temp;
    }

    Write-Host "Finished collecting folders from $BasePath" -ForegroundColor Green
    return $results
}
$path = Show-InputDialog -Message "Provide path to scan" -Title "Path"
$exportFileName = Show-InputDialog -Message "Type name for exported file" -Title "Export filename"

$tFolders = @()
$tFolders = Get-Folders -BasePath $path

# Export to CSV
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path $scriptPath
$outputPath = Join-Path $scriptDir "$($exportFileName).csv"
$tFolders | Export-Csv -LiteralPath $outputPath -NoTypeInformation -Encoding UTF8

Write-Host "Missing folders list exported to: $outputPath" -ForegroundColor Green
