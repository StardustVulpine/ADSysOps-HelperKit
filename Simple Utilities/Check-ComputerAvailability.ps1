Add-Type -AssemblyName System.Windows.Forms

$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "CSV files (*.csv)|*.csv"
$openFileDialog.Title = "Select CSV Input File with 'ComputerName' column"

if ($openFileDialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "No file selected. Exiting..." -ForegroundColor Yellow
    exit
}

$CsvPath = $openFileDialog.FileName

if (-Not (Test-Path $CsvPath)) {
    Write-Host "CSV file not found: $CsvPath" -ForegroundColor Red
    exit 1
}

$computers = Import-Csv -Path $CsvPath

foreach ($entry in $computers) {
    $name = $entry.ComputerName

    if ([string]::IsNullOrWhiteSpace($name)) {
        continue
    }

    $ping = Test-Connection -ComputerName $name -Count 1 -Quiet -ErrorAction SilentlyContinue

    if ($ping) {
        Write-Host "$name is responding." -ForegroundColor Green
    } else {
        Write-Host "$name is NOT responding." -ForegroundColor Red
    }
}
