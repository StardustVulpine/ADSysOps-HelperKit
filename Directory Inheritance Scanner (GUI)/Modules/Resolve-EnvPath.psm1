function Resolve-EnvPath {
    param([string]$path)
    $asEnv = $path -replace '\$env:([^\\\/]+)', '%$1%'
    return [Environment]::ExpandEnvironmentVariables($asEnv)
}
Export-ModuleMember -Function *