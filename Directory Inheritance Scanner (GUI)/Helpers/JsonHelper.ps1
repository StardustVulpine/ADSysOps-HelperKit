class JsonHelper {
    static [object] Load([string] $Path) {
        if (-not (Test-Path $Path)) {
            throw "File not found: $Path";
        }
        $json = Get-Content -Raw -Path $Path | ConvertFrom-Json;
        return $json;
    }

    static [void] Export([string] $Path, [object] $Data) {
        $json = $Data | ConvertTo-Json -Depth 10;
        Set-Content -Path $Path -Value $json -Encoding UTF8;
    }
}