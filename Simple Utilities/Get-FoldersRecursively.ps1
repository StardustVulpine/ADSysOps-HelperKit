function Get-Folders {
    param (
        [string]$BasePath,
        [string]$Label
    )


    Write-Host "Getting folders for: $BasePath" -ForegroundColor Cyan;

    $results = @();
    $folders = Get-ChildItem -Path $BasePath -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object{
        Write-Host $_.FullName;
        $temp = [PSCustomObject]@{
            "FolderPath" = $_.FullName
        }
        $results += $temp;
    }

    Write-Host "Finished collecting folders from $BasePath" -ForegroundColor Green;
    return $results;
}

Write-Host "Type path: " -ForegroundColor Cyan -NoNewline; $path = Read-Host;
Write-Host "Type name for exported file: " -ForegroundColor Cyan -NoNewline; $exportFileName = Read-Host;

$tFolders = @();
$tFolders = Get-Folders -BasePath $path;

# Export to CSV
$scriptPath = $MyInvocation.MyCommand.Path;
$scriptDir = Split-Path $scriptPath;
$outputPath = Join-Path $scriptDir "$($exportFileName).csv";
$tFolders | Export-Csv -LiteralPath $outputPath -NoTypeInformation -Encoding UTF8;

Write-Host "Missing folders list exported to: $outputPath" -ForegroundColor Green;
