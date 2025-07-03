Function Import-JsonFile {
    <#
    .SYNOPSIS
        Exports Json file
    .DESCRIPTION
        Exports JSON file to specified location
    .PARAMETER Path
        Path to JSON file
    .PARAMETER Data
        PSCustom Object with data to be parsed to JSON
    #>
    [CmdletBinding()]
    param (
        [string] $path,
        [Object] $data
    )
    Process {
        $json = $Data | ConvertTo-Json -Depth 10;
        Set-Content -Path $Path -Value $json -Encoding UTF8;
    }
}