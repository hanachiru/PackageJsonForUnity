class Package {
    # Required properties
    [string]$Name
    [PackageVersion]$Version

    # Recommended properties
    [string]$Description
    [string]$DisplayName
    [UnityVersion]$Unity

    # Optional properties
    [Author]$Author
    [string]$ChangelogUrl
    [hashtable]$Dependencies
    [string]$DocumentationUrl
    [bool]$HideInEditor
    [string[]]$Keywords
    [string]$License
    [string]$LicensesUrl
    [UnitySample]$Samples
    [string]$Type
    [string]$UnityRelease
    

    Package([string]$json) {
        if (-not $json.name) {
            throw 'package.json must have a name'
        }
        if (-not $json.version) {
            throw 'package.json must have a version'
        }

        $this.Name = $json.name
        $this.Version = [PackageVersion]::new($json.version)
        $this.Description = $json.description
        $this.DisplayName = $json.displayName

        if ($json.unity) {
            $this.Unity = [UnityVersion]::new($json.unity)
        }

        if ($json.author) {
            $this.Author = [Author]::new($json.author)
        }

        $this.ChangelogUrl = $json.changelogUrl
        $this.Dependencies = $json.dependencies
        $this.DocumentationUrl = $json.documentationUrl
        $this.HideInEditor = $json.hideInEditor
        $this.Keywords = $json.keywords
        $this.License = $json.license
        $this.LicensesUrl = $json.licensesUrl
        $this.Samples = @()
        foreach ($sample in $json.samples) {
            $this.Samples += [UnitySample]::new($sample)
        }
        $this.Type = $json.type
        $this.UnityRelease = $json.unityRelease
    }
}

class Author {
    # Required properties
    [string]$name

    # Optional properties
    [string]$email
    [string]$url

    Author([string]$json) {
        if (-not $json.name) {
            throw 'Author must have a name'
        }

        $this.name = $json.name
        $this.email = $json.email
        $this.url = $json.url
    }
    
    Author([string]$name, [string]$email, [string]$url) {
        $this.name = $name
        $this.email = $email
        $this.url = $url
    }
}

class PackageVersion : System.IComparable {
    [int] $Major;
    [int] $Minor;
    [int] $Patch;

    [string] ToString() {
        return "$($this.Major).$($this.Minor).$($this.Patch)"
    }

    PackageVersion([string] $version) {
        $parts = $version.Split('\.')

        if ($parts.Length -ne 3) {
            throw 'Version must be in the format of major.minor.patch'
        }

        $this.Major = [int]$parts[0]
        $this.Minor = [int]$parts[1]
        $this.Patch = [int]$parts[2]
    }

    PackageVersion([int]$major, [int]$minor, [int]$patch) {
        $this.Major = $major
        $this.Minor = $minor
        $this.Patch = $patch
    }

    [int] CompareTo([object] $obj) {
        if ($null -eq $obj) {
            return 1
        }

        $other = $obj -as [PackageVersion]
        if ($null -eq $other) {
            throw 'Object is not a PackageVersion'
        }

        return [PackageVersion]::Compare($this, $other)
    }

    static [int] Compare([PackageVersion] $a, [PackageVersion] $b) {
        if ($a.Major -lt $b.Major) { return -1 }
        if ($a.Major -gt $b.Major) { return 1 }

        if ($a.Minor -lt $b.Minor) { return -1 }
        if ($a.Minor -gt $b.Minor) { return 1 }

        if ($a.Patch -lt $b.Patch) { return -1 }
        if ($a.Patch -gt $b.Patch) { return 1 }

        return 0
    }
}

class UnityVersion : System.IComparable {
    [int] $Major;
    [int] $Minor;

    [string] ToString() {
        return "$($this.Major).$($this.Minor)"
    }

    UnityVersion([string] $version) {
        $parts = $version.Split('\.')

        if ($parts.Length -ne 2) {
            throw 'Version must be in the format of major.minor'
        }

        $this.Major = [int]$parts[0]
        $this.Minor = [int]$parts[1]
    }

    UnityVersion([int]$major, [int]$minor) {
        $this.Major = $major
        $this.Minor = $minor
    }

    [int] CompareTo([object] $obj) {
        if ($null -eq $obj) {
            return 1
        }

        $other = $obj -as [UnityVersion]
        if ($null -eq $other) {
            throw 'Object is not a UnityVersion'
        }

        return [UnityVersion]::Compare($this, $other)
    }

    static [int] Compare([UnityVersion] $a, [UnityVersion] $b) {
        if ($a.Major -lt $b.Major) { return -1 }
        if ($a.Major -gt $b.Major) { return 1 }

        if ($a.Minor -lt $b.Minor) { return -1 }
        if ($a.Minor -gt $b.Minor) { return 1 }

        return 0
    }
}

class UnitySample {
    [string]$DisplayName
    [string]$Description
    [string]$Path

    Sample([string]$json) {
        $this.DisplayName = $json.displayName
        $this.Description = $json.description
        $this.Path = $json.path
    }

    Sample([string]$displayName, [string]$description, [string]$path) {
        $this.DisplayName = $displayName
        $this.Description = $description
        $this.Path = $path
    }
}

enum VersionType {
    Major
    Minor
    Patch
}

<#
.Synopsis
    Get the name in package.json.
.PARAMETER Path
    Path of a package.json
.OUTPUTS
    Get-Name returns [string]
.EXAMPLE
    Get-Name -Path 'package.json'
#>
function Get-Name {
    param(
        [string]$Path
    )

    $json = Get-Content $Path | ConvertFrom-Json
    $json.name
}

<#
.Synopsis
    Set the name in package.json
.DESCRIPTION
    Set the name in package.json
.OUTPUTS
    Get-Name returns [void]
.EXAMPLE
    Get-Name -Path 'package.json'
#>
function Set-Name {
    param(
        [string]$Path,
        [string]$Name
    )

    if ($Name -notmatch '^[a-z0-9-_.]+$') {
        throw 'Name must be lowercase, numbers, hyphens (-), underscores (_), and periods (.) only.'
    } 

    $json = Get-Content $Path | ConvertFrom-Json
    $json.name = $Name
    $json | ConvertTo-Json -Depth 100 | Set-Content $Path
}

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

function Get-DisplayName {
    param(
        [string]$Path
    )

    $json = Get-Content $Path | ConvertFrom-Json
    $json.displayName
}

function Set-DisplayName {
    param(
        [string]$Path,
        [string]$DisplayName
    )

    $json = Get-Content $Path | ConvertFrom-Json
    $json.displayName = $DisplayName
    $json | ConvertTo-Json -Depth 100 | Set-Content $Path
}

function Get-Packages {
    param(
        [string]$Path
    )

    return Get-ChildItem -Path $Path -Filter 'package.json' -Recurse
}

function Get-Description {
    param(
        [string]$Path
    )

    $json = Get-Content $Path | ConvertFrom-Json
    $json.description
}

function Set-Description {
    param(
        [string]$Path,
        [string]$Description
    )

    $json = Get-Content $Path | ConvertFrom-Json
    $json.description = $Description
    $json | ConvertTo-Json -Depth 100 | Set-Content $Path
}

function Get-Unity {
    param(
        [string]$Path
    )

    $json = Get-Content $Path | ConvertFrom-Json
    $json.unity
}

function Set-Unity {
    param(
        [string]$Path,
        [string]$Unity
    )

    $json = Get-Content $Path | ConvertFrom-Json
    $json.unity = $Unity
    $json | ConvertTo-Json -Depth 100 | Set-Content $Path
}



Export-ModuleMember -Function Get-Version
Export-ModuleMember -Function Set-Version
Export-ModuleMember -Function Update-Version
Export-ModuleMember -Function Get-Packages