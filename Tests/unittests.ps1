#!/usr/bin/env pwsh
#Requires -Version 7.4

#Requires -Modules @{ModuleName = 'Pester'; ModuleVersion = '5.6.1'}

$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = "Stop"

Invoke-Pester -Path "$PSScriptRoot/UnitTest/*.Test.ps1"