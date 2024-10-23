function Get-Version {
    param(
        [string]$Path
    )

    $json = Get-Content $Path | ConvertFrom-Json
    $json.version
}

function Set-Version {
    param(
        [string]$Path,
        [string]$Version
    )

    $json = Get-Content $Path | ConvertFrom-Json
    $json.version = $Version
    $json | ConvertTo-Json -Depth 100 | Set-Content $Path
}

function Update-Version {
    param(
        [string]$Path,
        [VersionType]$Type
    )

    $json = Get-Content $Path | ConvertFrom-Json
    $version = $json.version -split '\.'
    $major = [int]$version[0]
    $minor = [int]$version[1]
    $patch = [int]$version[2]

    switch ($Type) {
        Major {
            $major++
            $minor = 0
            $patch = 0
        }
        Minor {
            $minor++
            $patch = 0
        }
        Patch {
            $patch++
        }
    }

    $json.version = "$major.$minor.$patch"
    $json | ConvertTo-Json -Depth 100 | Set-Content $Path
}

enum VersionType {
    Major
    Minor
    Patch
}

Export-ModuleMember -Function Update-Version