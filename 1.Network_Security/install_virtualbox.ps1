# ============================================
# Установка компонентов для VirtualBox
# Cloud and Network Security Lab 1
# ============================================

#Requires -RunAsAdministrator

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Вспомогательные функции ─────────────────────────────────────────────────

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host ("=" * 48) -ForegroundColor Cyan
    Write-Host "  $Text"
    Write-Host ("=" * 48) -ForegroundColor Cyan
}

function Write-Step   { param([string]$Text) Write-Host "  » $Text" -ForegroundColor Cyan  }
function Write-OK     { param([string]$Text) Write-Host "  ✔ $Text" -ForegroundColor Green  }
function Write-Warn   { param([string]$Text) Write-Host "  ⚠ $Text" -ForegroundColor Yellow }
function Write-Fail   { param([string]$Text) Write-Host "  ✘ $Text" -ForegroundColor Red    }

# ── Проверка конфликтующих компонентов Windows ──────────────────────────────

function Test-ConflictingWindowsFeatures {
    Write-Header "Проверка конфликтующих компонентов Windows"

    # Компоненты, мешающие VirtualBox (особенно 64-bit гостям и Hyper-V стек)
    $conflictingFeatures = @{
        'Microsoft-Hyper-V'                          = 'Hyper-V (гипервизор — главный конфликт с VirtualBox)'
        'Microsoft-Hyper-V-All'                      = 'Hyper-V (полный пакет)'
        'Microsoft-Hyper-V-Management-Clients'       = 'Средства управления Hyper-V'
        'HypervisorPlatform'                         = 'Платформа гипервизора Windows (WHvP)'
        'VirtualMachinePlatform'                     = 'Платформа виртуальной машины (WSL2 / Sandbox)'
        'Windows-Sandbox'                            = 'Windows Sandbox'
        'Containers-DisposableClientVM'              = 'Windows Sandbox (альтернативное имя)'
        'Microsoft-Windows-Subsystem-Linux'          = 'WSL (при использовании WSL2 активирует гипервизор)'
        'DeviceGuard'                                = 'Device Guard / Credential Guard (блокирует VT-x)'
    }

    $found = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($featureName in $conflictingFeatures.Keys) {
        try {
            $feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName -ErrorAction SilentlyContinue
            if ($feature -and $feature.State -eq 'Enabled') {
                $found.Add([PSCustomObject]@{
                    Name        = $featureName
                    Description = $conflictingFeatures[$featureName]
                })
            }
        } catch {
            # Компонент не существует в данной редакции Windows — пропускаем
        }
    }

    # Проверяем Credential Guard через реестр (не отображается как OptionalFeature)
    $cgPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard'
    if (Test-Path $cgPath) {
        $cgValue = (Get-ItemProperty $cgPath -Name 'EnableVirtualizationBasedSecurity' -ErrorAction SilentlyContinue).EnableVirtualizationBasedSecurity
        if ($cgValue -eq 1) {
            $found.Add([PSCustomObject]@{
                Name        = 'CredentialGuard (реестр)'
                Description = 'Credential Guard / VBS — блокирует доступ VirtualBox к VT-x/AMD-V'
            })
        }
    }

    if ($found.Count -eq 0) {
        Write-OK "Конфликтующих компонентов не обнаружено — VirtualBox должен работать корректно"
        return $true
    }

    Write-Warn "Обнаружены компоненты, мешающие работе VirtualBox:"
    $found | ForEach-Object { Write-Fail "  $($_.Description) [$($_.Name)]" }
    Write-Host ""
    Write-Warn "Эти компоненты конкурируют за VT-x/AMD-V и могут не давать"
    Write-Warn "VirtualBox запускать 64-битные ВМ или вызывать ошибку VERR_NEM_*."
    Write-Host ""

    $disable = Read-Host "  Отключить конфликтующие компоненты автоматически? [Y/N]"
    if ($disable -notmatch '^[Yy]') {
        Write-Warn "Компоненты оставлены включёнными. VirtualBox может работать нестабильно."
        return $false
    }

    foreach ($item in $found) {
        if ($item.Name -match 'реестр') {
            Write-Step "Отключаю Credential Guard через реестр..."
            Set-ItemProperty -Path $cgPath -Name 'EnableVirtualizationBasedSecurity' -Value 0
            Write-OK "Credential Guard отключён"
        } else {
            Write-Step "Отключаю: $($item.Description)..."
            try {
                Disable-WindowsOptionalFeature -Online -FeatureName $item.Name -NoRestart -ErrorAction Stop | Out-Null
                Write-OK "Отключено: $($item.Name)"
            } catch {
                Write-Warn "Не удалось отключить $($item.Name): $_"
            }
        }
    }

    Write-Warn "Требуется перезагрузка для применения изменений."
    $reboot = Read-Host "  Перезагрузить сейчас? [Y/N]"
    if ($reboot -match '^[Yy]') {
        Restart-Computer -Force
        exit 0
    }

    Write-Warn "Продолжаем без перезагрузки. Установите VirtualBox ПОСЛЕ перезагрузки."
    return $false
}

# ── Chocolatey ───────────────────────────────────────────────────────────────

function Install-Chocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-OK "Chocolatey уже установлен ($(choco --version))"
        return
    }

    Write-Step "Устанавливаю Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    # Обновляем PATH в текущем сеансе
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')

    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-OK "Chocolatey установлен успешно"
    } else {
        Write-Fail "Не удалось установить Chocolatey"
        exit 1
    }
}

# ── Установка пакетов ────────────────────────────────────────────────────────

function Install-Packages {
    param([string[]]$Packages)

    foreach ($pkg in $Packages) {
        Write-Step "Устанавливаю $pkg..."
        $result = choco install $pkg -y --no-progress 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-OK "$pkg установлен"
        } else {
            Write-Warn "$pkg — возможны ошибки (код: $LASTEXITCODE)"
            Write-Host ($result | Select-Object -Last 5 | Out-String) -ForegroundColor DarkGray
        }
    }
}

# ── Проверка результатов ─────────────────────────────────────────────────────

function Test-Installation {
    Write-Header "Проверка установки"

    $checks = @(
        @{ Label = 'VirtualBox'; Cmd = { & VBoxManage --version 2>&1 } },
        @{ Label = 'Terraform';  Cmd = { terraform version 2>&1 | Select-Object -First 1 } }
    )

    foreach ($chk in $checks) {
        try {
            $ver = & $chk.Cmd
            Write-OK "$($chk.Label): $ver"
        } catch {
            Write-Fail "$($chk.Label): не найден или не запускается"
        }
    }
}

# ── Итоговая справка ─────────────────────────────────────────────────────────

function Show-PostInstall {
    Write-Header "Готово!"
    Write-Host @"

  После установки:
    1. Загрузите образы VM (см. README.md)
    2. Импортируйте VM в VirtualBox
    3. Настройте сети в Network Manager

  Учётные данные VM:
    Kali Linux  — kali : kali
    Ubuntu      — ubuntu : linux
    pfSense     — admin : pfsense  (веб-интерфейс)

"@ -ForegroundColor White
}

# ── Точка входа ──────────────────────────────────────────────────────────────

Write-Header "Cloud and Network Security Lab 1 — Setup"

$noConflicts = Test-ConflictingWindowsFeatures

if (-not $noConflicts) {
    Write-Warn "Установка продолжится, но VirtualBox может работать нестабильно до перезагрузки."
}

Write-Header "Установка зависимостей"
Install-Chocolatey

Install-Packages @(
    'virtualbox',
    'virtualbox-extension-pack',
    'terraform'
)

Test-Installation
Show-PostInstall