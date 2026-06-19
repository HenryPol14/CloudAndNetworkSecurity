# План реализации Lab 1: Network Security

## Обзор
Лабораторная работа по сетевой безопасности с использованием VirtualBox на Windows.

---

## Предварительные шаги

### 1. Проверка установки Chocolatey
```powershell
choco --version
```

### 2. Установка VirtualBox и Terraform
```powershell
.\install_virtualbox.ps1
```
Этот скрипт:
- Проверит конфликтующие компоненты Windows (Hyper-V, WSL2 и т.д.)
- Установит VirtualBox и Terraform

---

## Установка и настройка VM

### 3. Загрузка образов VM

**Список образов:**
| Образ | Размер | Ссылка |
|-------|--------|--------|
| Kali Linux 2026.1 | 14.91 GB | `network_sec_platform/images/kali-linux-2026.1-qemu-amd64.7z` |
| Ubuntu Server 26.04 LTS | ISO | `network_sec_platform/images/ubuntu_server_2604_amd64.iso` |
| pfSense 2.7.2 | ISO | `network_sec_platform/images/pfsense-2.7.2-release-amd64.iso` |

**Примечание:** Kali Linux уже распакован (расширение .7z → .qcow2)

### 4. Автоматическая установка VM

Запустить скрипт от имени администратора:
```powershell
.\setup_vbox_vms.ps1
```

Скрипт выполнит:
- Создание сети vboxnet0 (10.0.0.1/24)
- Настройка DHCP (10.0.0.11-100)
- Конвертацию Kali qcow2 → vdi
- Создание 3 VM: pfSense, ubuntu_server, kali

### 5. Ручная установка VM (альтернатива)

**Если скрипт не сработает:**

1. Создать VM через VirtualBox Manager:
   - **pfSense**: FreeBSD (64-bit), 1024 MB RAM, 8 GB disk
     - NIC1: NAT (WAN)
     - NIC2: Host-only (vboxnet0, LAN)
   - **ubuntu_server**: Ubuntu (64-bit), 2048 MB RAM, 20 GB disk
     - Attach: ubuntu_server_2604_amd64.iso
     - NIC1: Host-only (vboxnet0)
   - **kali**: Other Linux (64-bit), 2048 MB RAM
     - Attach: kali.vdi (converted from qcow2)
     - NIC1: Host-only (vboxnet0)

---

## Задания лабораторной

### Task 1: Установка сети

✅ Включена в скрипт `setup_vbox_vms.ps1`

**Чеклист:**
- [ ] Terraform установлен (`terraform --version`)
- [ ] VirtualBox установлен
- [ ] Сеть vboxnet0 создана (10.0.0.1/24)
- [ ] DHCP настроен (10.0.0.11-100)

---

### Task 2: Запуск виртуальной сети

**Шаги:**

1. Запустить pfSense → сконфигурировать LAN через CLI:
   - Option 1: Assign interfaces
     - WAN → vtnet0
     - LAN → vtnet1
     - OPT1 → vtnet2
   - Option 2: Configure LAN network
     - IP: 10.0.0.1
     - Netmask: 255.255.255.0
     - DHCP: 10.0.0.11 - 10.0.0.100

2. Запустить Kali и Ubuntu

3. Проверить IP в Kali:
```bash
ip addr show
# Должен получить IP в диапазоне 10.0.0.x
```

4. Доступ к pfSense webGUI:
```
https://10.0.0.1
Login: admin / pfsense
```

---

### Task 3: Обнаружение хостов

**Команды nmap:**
```bash
# A) Discover hosts in LAN
nmap -sn 10.0.0.0/24

# C) More detailed discovery
nmap -PE -PM -PP 10.0.0.0/24

# D) Access web service
firefox http://<ubuntu_ip>
# или
curl http://<ubuntu_ip>
```

---

### Task 4: ICMP Tunneling

**На Ubuntu (сервер):**
```bash
# Отправить файл как ICMP пакеты
hping3 --icmp --file hackers_data.txt 10.0.0.x
# где x - IP Kali
```

**На Kali (приемник):**
```bash
# Захватить пакеты
sudo tshark -i eth0 icmp -w hacker_data.pcap

# Или через Wireshark GUI
wireshark
```

**Извлечь данные:**
```bash
tshark -r hacker_data.pcap -T fields -e data.data > hexdump.txt
```

---

### Task 5: Доступ к серверу извне LAN

**Решения:**

1. **Port Forwarding в pfSense:**
   - Firewall → NAT → Port Forward
   - Forward external port 80 → Ubuntu internal IP:80

2. **Firewall Rules:**
   - Firewall → Rules → WAN
   - Разрешить HTTP (port 80) трафик

3. **VPN (OpenVPN):**
   -VPN → OpenVPN → Server
   - Подключиться извне через VPN

---

## Требуемые инструменты для заданий

| Инструмент | Назначение | Установка |
|------------|------------|-----------|
| hping3 | ICMP tunneling | `sudo apt install hping3` |
| nmap | Host discovery | `sudo apt install nmap` |
| Wireshark | Packet capture | `sudo apt install wireshark` |
| tshark | Packet extraction | `sudo apt install tshark` |

**Примечание:** Kali Linux уже содержит все эти инструменты.

---

## Проблемы и решения

### Проблема: VirtualBox не запускается
**Решение:**
- Отключить Hyper-V: `bcdedit /set hypervisorlaunchtype off`
- Перезагрузка обязательна

### Проблема: Мало RAM (8 GB)
**Решение:**
- Использовать Xubuntu вместо Kali
- Уменьшить RAM на VM (Kali: 2GB, Ubuntu: 1GB, pfSense: 1GB)

### Проблема: Terraform не работает
**Решение:**
- Для VirtualBox нужен провайдер `terraform-provider-virtualbox`
- Или использовать WSL2 + KVM для нативной поддержки Terraform

---

## Итоговый чеклист сдачи

- [ ] Скриншот сети vboxnet0
- [ ] Скриншот `terraform apply` (Task 2)
- [ ] Скриншот доступа к pfSense GUI (Task 2C)
- [ ] Скриншот nmap scan (Task 3A)
- [ ] Скриншот доступа к HTTP серверу (Task 3D)
- [ ] Скриншот захваченных ICMP пакетов (Task 4A)
- [ ] Скриншот конвертированных данных (Task 4B)
- [ ] Документация Task 5
