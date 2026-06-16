# ============================================
# Настройка сетей для VirtualBox
# Cloud and Network Security Lab 1
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Настройка сетей для VirtualBox" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Проверка наличия VBoxManage
Write-Host "Проверка VirtualBox установки..." -ForegroundColor Cyan
if (-not (Get-Command VBoxManage -ErrorAction SilentlyContinue)) {
    Write-Host "Ошибка: VirtualBox не найден. Установите VirtualBox." -ForegroundColor Red
    exit 1
}

Write-Host "VirtualBox найден" -ForegroundColor Green
Write-Host ""

# Создание хост-только сети (для LAN)
Write-Host "Создание хост-только сети 'vboxnet0' (LAN)..." -ForegroundColor Cyan

# Проверка существующих сетей
VBoxManage list hostonlyifs

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "Настройки сетей для Lab 1:" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Сеть LAN (vboxnet0):" -ForegroundColor Cyan
Write-Host "  IP: 10.0.0.1" -ForegroundColor White
Write-Host "  Netmask: 255.255.255.0" -ForegroundColor White
Write-Host "  DHCP: 10.0.0.100 - 10.0.0.200" -ForegroundColor White
Write-Host ""
Write-Host "Сеть WAN: Используйте NAT или Bridge" -ForegroundColor Cyan
Write-Host ""
Write-Host "Команды для настройки вручную:" -ForegroundColor Yellow
Write-Host "  VBoxManage hostonlyif create" -ForegroundColor Cyan
Write-Host "  VBoxManage hostonlyif ipconfig vboxnet0 --ip 10.0.0.1 --netmask 255.255.255.0" -ForegroundColor Cyan
Write-Host "  VBoxManage dhcpserver modify --ifname vboxnet0 --ip 10.0.0.1 --netmask 255.255.255.0 --lowerip 10.0.0.100 --upperip 10.0.0.200 --enable" -ForegroundColor Cyan
Write-Host ""

Write-Host "============================================" -ForegroundColor Green
Write-Host "Настройка выполнена!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Инструкции:" -ForegroundColor Yellow
Write-Host "1. Откройте VirtualBox" -ForegroundColor White
Write-Host "2. File > Import Appliance" -ForegroundColor White
Write-Host "3. Импортируйте образы VM" -ForegroundColor White
Write-Host "4. Настройте сети для каждой ВМ" -ForegroundColor White
Write-Host "5. Запустите pfSense, затем Kali и Ubuntu" -ForegroundColor White
Write-Host ""
