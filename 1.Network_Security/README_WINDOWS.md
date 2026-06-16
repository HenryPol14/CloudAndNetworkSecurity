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

#### 2. Настройка сетей

```powershell
.\setup_network_virtualbox.ps1
```

#### 3. Загрузка образов ВМ

Скачайте образы по инструкции в README.md:
- **Kali Linux** (14.6 GB)
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
- **WSL2 + libvirt** — нативная поддержка

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
