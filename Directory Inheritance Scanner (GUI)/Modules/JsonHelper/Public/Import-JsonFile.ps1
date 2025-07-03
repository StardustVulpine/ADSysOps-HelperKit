Function Import-JsonFile {
    <#
    .SYNOPSIS
        Imports Json file
    .DESCRIPTION
        Imports and returns JSON file
    .PARAMETER Path
        Path to JSON file
    #>
    [CmdletBinding()]
    param (
        [string] $path
    )
    Process {
        if (-not (Test-Path $Path)) {
            throw "File not found: $Path";
        }
        $json = Get-Content -Raw -Path $Path | ConvertFrom-Json;
        return $json;
    }
}