# Prompt user for path
$basePath = Read-Host "Enter the full path to scan"

# Check if path exists
if (-not (Test-Path $basePath)) {
    Write-Host "Error: The path '$basePath' does not exist." -ForegroundColor Red
    exit
}

# Constants
$maxAllowedLength = 260

# Prompt user for number of additional characters that will lengthen path (for example when copying to new directory)
$extraLength = Read-Host "Enter how many additional characters will be added to path for calculations"

# Function: Recursively collect all items with a progress bar
function Get-AllItemsWithProgress {
    param (
        [string]$Path
    )

    $allItems = @()
    $foldersQueue = [System.Collections.Queue]::new()
    $foldersQueue.Enqueue($Path)

    $totalScanned = 0

    while ($foldersQueue.Count -gt 0) {
        $current = $foldersQueue.Dequeue()
        $totalScanned++

        Write-Progress -Activity "Collecting files and folders..." `
                       -Status "Scanned $totalScanned folders" `
                       -PercentComplete 0

        try {
            $items = Get-ChildItem -Path $current -Force -ErrorAction Stop
            foreach ($item in $items) {
                $allItems += $item
                if ($item.PSIsContainer) {
                    $foldersQueue.Enqueue($item.FullName)
                }
            }
        } catch {
            Write-Warning "Cannot access $current"
        }
    }

    Write-Progress -Activity "Collecting files and folders..." -Completed
    return $allItems
}

# Step 1: Collect all files/folders
$allItems = Get-AllItemsWithProgress -Path $basePath

# Step 2: Check each item and log long paths
$longPaths = @()
$counter = 0
$total = $allItems.Count

foreach ($item in $allItems) {
    $counter++
    Write-Progress -Activity "Checking path lengths..." `
                   -Status "$counter of $total items" `
                   -PercentComplete (($counter / $total) * 100)

    try {
        $fullPath = $item.FullName
        $adjustedLength = $fullPath.Length + $extraLength

        if ($adjustedLength -gt $maxAllowedLength) {
            $longPaths += [PSCustomObject]@{
                Type        = if ($item.PSIsContainer) { "Folder" } else { "File" }
                Path        = $fullPath
                Length      = $fullPath.Length
                Adjusted    = $adjustedLength
                OverBy      = $adjustedLength - $maxAllowedLength
            }
        }
    } catch {
        Write-Host "Warning: Could not process item: $_" -ForegroundColor Yellow
    }
}

Write-Progress -Activity "Checking path lengths..." -Completed

# Step 3: Export to CSV
if ($longPaths.Count -gt 0) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $scriptDir = Split-Path $scriptPath
    $csvPath = Join-Path $scriptDir "longPaths.csv"
    
    $longPaths | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    Write-Host "`nExported results to:" -ForegroundColor Cyan
    Write-Host $csvPath -ForegroundColor Green
} else {
    Write-Host "`nNo paths exceed the limit." -ForegroundColor Green
}
