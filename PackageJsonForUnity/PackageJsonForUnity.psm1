class Package {
    [PSCustomObject]$Json

    # Required properties
    [string]$Name {
        get { return $this.Name }
        set { 
            if (-not $value) {
                throw 'package.json must have a name'
            }
            if ($json.name.Length -gt 214) {
                throw 'name must be less than 214 characters'
            }
            if ($json.name -notmatch '^[a-z0-9-_.]+$') {
                throw 'name can only contain lowercase letters, numbers, hyphens (-), underscores (_), and periods (.)'
            }
            $this.Name = $value
            $this.Json.name = $value
        }
    }
    [PackageVersion]$Version {
        get { return $this.Version }
        set { 
            if (-not $value) {
                throw 'package.json must have a version'
            }
            $this.Version = $value
            $this.Json.version = $value.ToString()
        }
    }

    # Recommended properties
    [string]$Description {
        get { return $this.Description }
        set { 
            $this.Description = $value
            $this.Json.description = $value
        }
    }
    [string]$DisplayName {
        get { return $this.DisplayName }
        set { 
            $this.DisplayName = $value
            $this.Json.displayName = $value
        }
    }
    [UnityVersion]$Unity {
        get { return $this.Unity }
        set { 
            $this.Unity = $value
            $this.Json.unity = $value.ToString()
        }
    }

    # Optional properties
    [Author]$Author {
        get { return $this.Author }
        set { 
            $this.Author = $value
            $this.Json.author = $value
        }
    }
    [string]$ChangelogUrl {
        get { return $this.ChangelogUrl }
        set { 
            $this.ChangelogUrl = $value
            $this.Json.changelogUrl = $value
        }
    }
    [hashtable]$Dependencies {
        get { return $this.Dependencies }
        set { 
            $this.Dependencies = $value

            # TODO: fix
            $this.Json.dependencies = $value
        }
    }
    [string]$DocumentationUrl {
        get { return $this.DocumentationUrl }
        set { 
            $this.DocumentationUrl = $value
            $this.Json.documentationUrl = $value
        }
    }
    [bool]$HideInEditor {
        get { return $this.HideInEditor }
        set { 
            $this.HideInEditor = $value
            $this.Json.hideInEditor = $value
        }
    }
    [string[]]$Keywords {
        get { return $this.Keywords }
        set { 
            $this.Keywords = $value

            # TODO: fix
            $this.Json.keywords = $value
        }
    }
    [string]$License {
        get { return $this.License }
        set { 
            $this.License = $value
            $this.Json.license = $value
        }
    }
    [string]$LicensesUrl {
        get { return $this.LicensesUrl }
        set { 
            $this.LicensesUrl = $value
            $this.Json.licensesUrl = $value
        }
    }
    [UnitySample[]]$Samples {
        get { return $this.Samples }
        set { 
            $this.Samples = $value

            # TODO: use ToString
            $this.Json.samples = $value
        }
    }
    [string]$Type {
        get { return $this.Type }
        set { 
            $this.Type = $value
            $this.Json.type = $value
        }
    }
    [string]$UnityRelease {
        get { return $this.UnityRelease }
        set { 
            $this.UnityRelease = $value
            $this.Json.unityRelease = $value
        }
    }
    
    Package([string]$jsonText) {
        $Json = $jsonText | ConvertFrom-Json

        if (-not $Json.name) {
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

    [Package] Set-Name([string]$name) {
        $json = $this.OriginalText | ConvertFrom-Json
        $json.name = $name
        $newText = $json | ConvertTo-Json -Depth 100
        $package = [Package]::new($newText)
        return $this.OriginalText
    }
}

class Author {
    # Required properties
    [string]$name

    # Optional properties
    [string]$email
    [string]$url

    Author([string]$jsonText) {
        $json = $jsonText | ConvertFrom-Json
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

    Sample([string]$jsonText) {
        $json = $jsonText | ConvertFrom-Json
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

    $json = Get-Content $Path
    $package = [Package]::new($json)
    return $package.Name
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

    $json = Get-Content $Path
    $package = [Package]::new($json)
    $newPackage = $package.Set-Name($Name)
    Set-Content $Path $newPackage
}

function Get-Version {
    param(
        [string]$Path
    )

    $json = Get-Content $Path
    $package = [Package]::new($json)
    return $package.Version
}

function Set-Version {
    param(
        [string]$Path,
        [string]$Version
    )

    $json = Get-Content $Path
    $package = [Package]::new($json)
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