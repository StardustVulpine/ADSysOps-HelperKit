# === Configuration ===
$groupPrefixes = @("GRP_",
                   "ACL_")

$groupSuffixes = @("_RW", 
                   "_RO")

$forbiddenGroups = @("Everyone",
                     "BUILTIN\Users")

# === Get only top-level folders ===
$basePath = Read-Host "Type path" -ForegroundColor Cyan
$folders = Get-ChildItem -Path $basePath -Directory -ErrorAction Stop

foreach ($folder in $folders) {
    $folderName = $folder.Name
    $folderPath = $folder.FullName

    # Build all expected group names for this folder
    $expectedGroups = @()
    foreach ($prefix in $groupPrefixes) {
        foreach ($suffix in $groupSuffixes) {
            $expectedGroups += "$prefix$folderName$suffix"
        }
    }

    try {
        $acl = Get-Acl -Path $folderPath -ErrorAction Stop

        $matchedGroups    = @()
        $forbiddenMatches = @()

        foreach ($entry in $acl.Access) {
            $identity = $entry.IdentityReference.Value

            # Match against expected combinations
            if ($expectedGroups -contains $identity) {
                $matchedGroups += $identity
            }

            # Match against forbidden groups
            foreach ($forbidden in $forbiddenGroups) {
                if ($identity -like $forbidden) {
                    $forbiddenMatches += $identity
                }
            }
        }

        # Report if any matches found
        Write-Host "`n Folder: $folderPath" -ForegroundColor Cyan
        if ($matchedGroups.Count -gt 0) {
            Write-Host "Matching groups: `n" -ForegroundColor Green
            foreach ($group in $matchedGroups) {
                Write-Host "$group `n"
            }
        }

        if ($forbiddenMatches.Count -gt 0) {
            Write-Host "`n Forbidden groups found: `n"
            foreach ($group in $forbiddenGroups) {
                Write-Host "$group `n"
            }
        }

    } catch {
        Write-Host "Failed to get ACL for $folderPath `n $($_.Exception.Message)" -ForegroundColor Red
    }
}
