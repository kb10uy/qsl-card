param(
    [Parameter(Position = 0)]
    [ValidateSet("json", "pdf")]
    [string]$Subcommand,
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$Arguments = @()
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

$root = $PSScriptRoot

switch ($Subcommand) {
    "json" {
        $consoleEncoding = [Console]::OutputEncoding
        try {
            [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
            wavelog-tools export @Arguments |
                qso-tools qcgen --lenient codepoints (Join-Path $root "qcgen-single.lua")
        } finally {
            [Console]::OutputEncoding = $consoleEncoding
        }
    }
    "pdf" {
        if ($Arguments.Count -ne 1) {
            throw "Usage: generate.ps1 pdf <JSON_FILE>"
        }
        $jsonFullPath = [IO.Path]::GetFullPath($Arguments[0], (Get-Location).Path)
        $work = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
        New-Item -ItemType Directory $work | Out-Null
        try {
            Copy-Item -Recurse (Join-Path $root "qsl-card.typ"), (Join-Path $root "parts") $work
            Copy-Item -LiteralPath $jsonFullPath (Join-Path $work "data.json")
            typst compile --input "data_json=data.json" (Join-Path $work "qsl-card.typ") "$jsonFullPath.pdf"
        } finally {
            Remove-Item -Recurse -Force $work
        }
    }
    default {
        Write-Host "Usage: generate.ps1 json [wavelog-tools export options...]"
        Write-Host "       generate.ps1 pdf <JSON_FILE>"
        exit 1
    }
}
