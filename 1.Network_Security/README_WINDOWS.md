# Cloud and Network Security Lab 1
## Установка компонентов для VirtualBox (Windows)

### Обзор

Этот набор скриптов и шаблонов помогает настроить среду для Lab 1 на Windows с VirtualBox вместо VMware Workstation.

**Преимущества VirtualBox:**
- Бесплатно
- Terraform поддерживается через провайдер `terraform-provider-virtualbox`
- Стабильная работа с инструментами Linux

---

### Быстрый старт

#### 1. Установка компонентов

Запустите от имени администратора PowerShell:

```powershell
cd C:\Users\HenryN\projects\CloudAndNetworkSecurity\1.Network_Security
.\install_virtualbox.ps1
```

> [!NOTE]
> Скрипт автоматически проверяет и отключает конфликтующие компоненты Windows (Hyper-V, WSL2, Sandbox, Credential Guard). Требуется перезагрузка.

#### 2. Настройка сетей

Для автоматической настройки сетей запустите:
```powershell
.\setup_network_virtualbox.ps1
```

ИЛИ настройте вручную в VirtualBox:
- **vboxnet0** (LAN): 10.0.0.1/24
- **vboxnet1** (DMZ): 10.3.1.1/24

#### 3. Загрузка образов ВМ

Скачайте образы по инструкции в README.md:
- **Kali Linux** (14.6 GB) или **Xubuntu** (4.7 GB) для слабых систем
- **Ubuntu Server** (1.8 GB)
- **pfSense** (1 GB)

#### 4. Импорт ВМ

1. Откройте VirtualBox
2. File > Import Appliance
3. Выберите .ova/.vmdk файлы

---

### Системные требования

| Компонент | Минимум | Рекомендуется |
|-----------|---------|--------------|
| CPU | 4 ядра | 8 ядер |
| RAM | 8 GB | 16 GB |
| Disk | 50 GB | 100 GB SSD |
| VT-x/AMD-V | Включен в BIOS | — |

> [!NOTE]
> Дляработы VirtualBox требуется включенный VT-x/AMD-V в настройках BIOS/UEFI.

---

### Настройка сетей в VirtualBox

**Хост-только сети:**
```
vboxnet0 (LAN): 10.0.0.1/24
vboxnet1 (DMZ): 10.3.1.1/24
```

**Команды:**
```bash
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 10.0.0.1 --netmask 255.255.255.0
VBoxManage dhcpserver modify --ifname vboxnet0 --ip 10.0.0.1 --netmask 255.255.255.0 --lowerip 10.0.0.100 --upperip 10.0.0.200 --enable
```

---

### IP-адресация

| Сеть | IP | Назначение |
|------|-----|-----------|
| NAT | 10.0.2.0/24 | Внешняя сеть (WAN) |
| vboxnet0 | 10.0.0.0/24 | Внутренняя сеть (LAN) |
| vboxnet1 | 10.3.1.0/24 | DMZ (Lab 2) |

---

### TERRAFORM + VIRTUALBOX

**Установка провайдера:**
```bash
# Скачайте terraform-provider-virtualbox
# Следуйте инструкции: https://github.com/macintoshprime/terraform-provider-virtualbox
```

**Инициализация Terraform:**
```bash
terraform init
terraform apply
```

---

### РЕКОМЕНДАЦИЯ

Для лучшей совместимости используйте **WSL2 + Ubuntu** и следуйте оригинальной инструкции.

**Альтернативы:**
- **VirtualBox + Terraform** — бесплатный, поддерживает IaC
- **VMware Workstation** — ручная настройка
- **WSL2 + Ubuntu** — для нативной поддержки libvirt (требует отключения Hyper-V)

**Скрипты для автоматической установки:**
- `install_virtualbox.ps1` — установка VirtualBox, Terraform, проверка конфликтов
- `setup_network_virtualbox.ps1` — настройка хост-только сетей

---

### Устранение неполадок

**VirtualBox не запускается:**
- Проверьте VT-x/AMD-V в BIOS
- Отключите Hyper-V: `bcdedit /set hypervisorlaunchtype off`

**Нет сети:**
- Проверьте настройки хост-только сетей
- Убедитесь, что адаптеры подключены

**Мало RAM:**
- Уменьшите RAM на ВМ (Kali: 2GB, Ubuntu: 1GB, pfSense: 1GB)

---

**Последнее обновление:** 2026-06-16

**Ссылки для скачивания образов:**
- [Kali Linux](https://a3s.fi/swift/v1/AUTH_d797295bcbc24cec98686c41a8e16ef5/CloudAndNetworkSecurity/kali-linux-2023.4-qemu-amd64.zip)
- [Xubuntu (lightweight)](https://a3s.fi/swift/v1/CloudAndNetworkSecurity/Xubuntu.qcow2.tar.gz)
- [Ubuntu Server](https://a3s.fi/swift/v1/AUTH_d797295bcbc24cec98686c41a8e16ef5/CloudAndNetworkSecurity/ubuntu_server.qcow2)
- [pfSense](https://a3s.fi/swift/v1/AUTH_d797295bcbc24cec98686c41a8e16ef5/CloudAndNetworkSecurity/router_pfsense.qcow2)
