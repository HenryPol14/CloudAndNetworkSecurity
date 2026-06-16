# ============================================
# Установка компонентов для VirtualBox
# Cloud and Network Security Lab 1
# ============================================

# PowerShell скрипт для установки необходимых компонентов

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Установка компонентов для Cloud and Network Security Lab 1 (VirtualBox)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Проверка прав администратора
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Ошибка: Скрипт должен быть запущен от имени администратора" -ForegroundColor Red
    Write-Host "Запустите PowerShell от имени администратора" -ForegroundColor Yellow
    exit 1
}

# Установка Chocolatey если не установлен
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Устанавливаю Chocolatey..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
    Write-Host "Chocolatey уже установлен" -ForegroundColor Green
}

# Установка компонентов через Chocolatey
$components = @(
    'virtualbox',
    'virtualbox-extension-pack',
    'terraform'
)

foreach ($component in $components) {
    Write-Host "Установка $component..." -ForegroundColor Cyan
    choco install $component -y
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "Установка завершена!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "После установки:" -ForegroundColor Yellow
Write-Host "1. Загрузите образы VM (см. README.md)" -ForegroundColor White
Write-Host "2. Импортируйте VM в VirtualBox" -ForegroundColor White
Write-Host "3. Настройте сети в Network Manager" -ForegroundColor White
Write-Host ""
Write-Host "Логин для VM:" -ForegroundColor Cyan
Write-Host "  Kali Linux: kali:kali" -ForegroundColor White
Write-Host "  Ubuntu Server: ubuntu:linux" -ForegroundColor White
Write-Host "  pfSense: admin:pfsense (веб-интерфейс)" -ForegroundColor White
Write-Host ""

# Проверка установки
Write-Host ""
Write-Host "Проверка установки VirtualBox..." -ForegroundColor Cyan
& "VBoxManage" --version

Write-Host ""
Write-Host "Проверка установки Terraform..." -ForegroundColor Cyan
terraform --version
