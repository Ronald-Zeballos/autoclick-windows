$ErrorActionPreference = 'Stop'
try {
    $installDirectory = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Autoclick'
    $desktopDirectory = [Environment]::GetFolderPath('DesktopDirectory')
    $appFiles = @('Autoclick.ps1', 'Abrir Autoclick.vbs', 'Abrir Autoclick.cmd', 'LEEME.txt', 'README.md')
    foreach ($file in $appFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot $file) -PathType Leaf)) {
            throw "Falta el archivo: $file. Extrae el ZIP completo antes de instalar."
        }
    }
    New-Item -ItemType Directory -Path $installDirectory -Force | Out-Null
    if ([IO.Path]::GetFullPath($PSScriptRoot).TrimEnd('\') -ne [IO.Path]::GetFullPath($installDirectory).TrimEnd('\')) {
        foreach ($file in $appFiles) {
            Copy-Item -LiteralPath (Join-Path $PSScriptRoot $file) -Destination $installDirectory -Force
        }
    }
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut((Join-Path $desktopDirectory 'Autoclick.lnk'))
    $shortcut.TargetPath = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $shortcut.Arguments = '-NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + (Join-Path $installDirectory 'Autoclick.ps1') + '"'
    $shortcut.WorkingDirectory = $installDirectory
    $shortcut.Description = 'Autoclick configurable. Se detiene al mover el mouse.'
    $shortcut.WindowStyle = 7
    $shortcut.Save()
    Write-Host "Instalado en: $installDirectory"
    Write-Host 'Abre el acceso directo Autoclick del escritorio para comenzar.'
} catch {
    Write-Host ('No se pudo completar la instalacion: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
