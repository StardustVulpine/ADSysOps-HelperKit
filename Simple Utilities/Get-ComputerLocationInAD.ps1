Import-Module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "Enter Domain Names"
$form.Width = 400
$form.Height = 200
$form.StartPosition = "CenterScreen"

$label1 = New-Object System.Windows.Forms.Label
$label1.Text = "Primary Domain:"
$label1.Top = 20
$label1.Left = 10
$label1.Width = 100

$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Top = 20
$textBox1.Left = 120
$textBox1.Width = 250

$label2 = New-Object System.Windows.Forms.Label
$label2.Text = "Secondary Domain (Optional):"
$label2.Top = 60
$label2.Left = 10
$label2.Width = 100

$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Top = 60
$textBox2.Left = 120
$textBox2.Width = 250

$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Top = 100
$okButton.Left = 150
$okButton.Add_Click({ $form.Close() })

$form.Controls.AddRange(@($label1, $textBox1, $label2, $textBox2, $okButton))
$form.ShowDialog()

$primaryDomain = $textBox1.Text
$secondaryDomain = $textBox2.Text

if (-not $primaryDomain) {
    Write-Host "Primary domain is missing." -ForegroundColor Red
    exit
}

$FileDialog = New-Object System.Windows.Forms.OpenFileDialog
$FileDialog.Filter = "CSV files (*.csv)|*.csv"
$FileDialog.Title = "Select a CSV file with a 'ComputerName' column"
$null = $FileDialog.ShowDialog()

if (-not $FileDialog.FileName) {
    Write-Host "No file selected. Exiting."
    exit
}

$computers = Import-Csv -Path $FileDialog.FileName
$results = @()

function Get-ADComputerFromDomain($computerName, $domain) {
    try {
        return Get-ADComputer -Identity $computerName -Server $domain -Properties DistinguishedName -ErrorAction Stop
    } catch {
        return $null
    }
}

foreach ($comp in $computers) {
    $name = $comp.ComputerName
    $computer = Get-ADComputerFromDomain $name $primaryDomain

    if (-not $computer -and $secondaryDomain -isnot "") {
        $computer = Get-ADComputerFromDomain $name $secondaryDomain
    }

    if ($computer) {
        $dn = $computer.DistinguishedName

        # Create friendly path
        $friendly = $dn -replace '^CN=[^,]+,?', ''         # Remove CN=
        $friendly = $friendly -replace 'OU=|CN=', ''       # Remove OU= and CN=
        $friendly = $friendly -replace 'DC=', ''           # Remove DC=
        $friendly = $friendly -replace ',', '/'            # Replace commas with /
        $friendly = $friendly -replace '/+', '/'           # Clean up slashes

        if ($dn -match 'DC=([^,]+)') {
            $domainPrefix = $matches[1]
        } else {
            $domainPrefix = 'Unknown'
        }

        $friendlyPath = "$domainPrefix.com/$friendly"

        $results += [PSCustomObject]@{
            ComputerName      = $name
            DistinguishedName = $dn
            FriendlyPath      = $friendlyPath
        }
    } else {
        $results += [PSCustomObject]@{
            ComputerName      = $name
            DistinguishedName = "Not Found"
            FriendlyPath      = "Not Found"
        }
    }
}

# Export
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$outputFile = Join-Path $scriptDir "AD_Computer_Paths_$timestamp.csv"

$results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
Write-Host "`nReport saved to: $outputFile" -ForegroundColor Green
