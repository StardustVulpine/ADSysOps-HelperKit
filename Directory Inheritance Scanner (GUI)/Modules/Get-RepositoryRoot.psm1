function Get-RepositoryRoot {
    if ($MyInvocation.MyCommand.Path) {
        return Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
        Write-Host "Split-Path -Parent `$MyInvocation.MyCommand.Path: $repositoryRoot" -ForegroundColor Cyan
    } else {
        return Get-Location
        Write-Host "Get-Location: $repositoryRoot" -ForegroundColor Cyan
    }
}
Export-ModuleMember -Function *