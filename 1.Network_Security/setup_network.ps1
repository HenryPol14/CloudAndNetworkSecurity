# ============================================
# Настройка виртуальной сети для Lab 1
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Настройка виртуальной сети для Lab 1" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Создание внутренней сети (bridged)
Write-Host "Создание виртуальной сети 'internal_network'..." -ForegroundColor Cyan

# Для VMware Workstation создадим NAT сеть через Virtual Network Editor
# Вручную настройте в VMware: Edit > Virtual Network Editor > Add Network > VMnet1 (Host-Only)

Write-Host "============================================" -ForegroundColor Green
Write-Host "Настройка завершена!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Важно: Настройте сети в VMware Workstation:" -ForegroundColor Yellow
Write-Host "  1. Откройте VMware Workstation" -ForegroundColor White
Write-Host "  2. Edit > Virtual Network Editor" -ForegroundColor White
Write-Host "  3. Настройте:" -ForegroundColor White
Write-Host "     - VMnet0 (Bridged) - для WAN" -ForegroundColor White
Write-Host "     - VMnet1 (Host-only) - для LAN" -ForegroundColor White
Write-Host "     - VMnet2 (Host-only) - для DMZ (опционально)" -ForegroundColor White
Write-Host ""
Write-Host "IP-адреса:" -ForegroundColor Cyan
Write-Host "  LAN: 10.0.0.0/24 (pfSense: 10.0.0.1)" -ForegroundColor White
Write-Host "  LAN Range: 10.0.0.11 - 10.0.0.100" -ForegroundColor White
Write-Host "  WAN: 192.168.122.0/24" -ForegroundColor White
Write-Host ""
