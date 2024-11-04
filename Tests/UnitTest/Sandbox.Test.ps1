# Sandbox.Test.ps1

# BeforeAllはテストスイート(Describeブロック)の前に一度だけ実行されるPesterの関数
BeforeAll {
    # $PSScriptRootはスクリプトファイルのディレクトリを表す自動変数
    . $PSScriptRoot/Sandbox.ps1
    Import-Module "$PSScriptRoot\..\..\PackageJsonForUnity\PackageJsonForUnity.psd1" -Force
}

# Describeはテストスイート(関連するテストケースをグループ化したもの)を定義するPesterの関数
Describe 'Get-AddNum' {
    # Itはテストケースを定義するPesterの関数
    # 複数のケースを描きたい場合はItを複数記述します
    It '1 + 2 = 3' {
        $actual = Get-AddNum -x 1 -y 2

        # ShouldはPesterの検証関数(3であることを検証)
        $actual | Should -Be 3
    }

    It '-5 + 5 = 0' {
        $actual = Get-AddNum -x -5 -y 5
        $actual | Should -Be 0
    }

    It '(-1) + (-2) = 3' {
        $actual = Get-AddNum -x -1 -y -2
        $actual | Should -Be -3
    }
}