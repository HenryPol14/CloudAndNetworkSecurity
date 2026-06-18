# VirtualBox VM Setup Guide

This guide explains how to set up the lab environment using VirtualBox.

## Prerequisites

- VirtualBox 7.2.8 installed
- PowerShell (with Administrator privileges)
- VM images downloaded to: `network_sec_platform/images/`

## Images Required

| Image | Size | Status |
|-------|------|--------|
| kali-linux-2026.1-qemu-amd64.qcow2 | 14.91 GB | ✓ Downloaded & extracted |
| ubuntu_server_2604_amd64.iso | - | ✓ Downloaded |
| pfsense-2.7.2-release-amd64.iso | - | ✓ Downloaded |

## Manual VM Setup (Step-by-Step)

### Step 1: Create VirtualBox Network (vboxnet0)

1. Open VirtualBox Manager
2. Go to **File > Host Network Manager**
3. Click **Create** to add vboxnet0
4. Verify IP: `10.0.0.1`, Netmask: `255.255.255.0`

### Step 2: Create pfSense VM

1. **New VM** → Name: `pfSense`
2. Type: **BSD**, Version: **FreeBSD (64-bit)**
3. Memory: **1024 MB**
4. Hard Disk: **Create new** → 8 GB dynamic
5. **Settings > Network**:
   - Adapter 1: **NAT** (WAN)
   - Adapter 2: **Host-only Adapter** (vboxnet0, LAN)

### Step 3: Create Ubuntu Server VM

1. **New VM** → Name: `ubuntu_server`
2. Type: **Linux**, Version: **Ubuntu (64-bit)**
3. Memory: **2048 MB**
4. Hard Disk: **Create new** → 20 GB dynamic
5. **Settings > Storage**:
   - Controller: IDE, attach `ubuntu_server_2604_amd64.iso`
6. **Settings > Network**:
   - Adapter 1: **Host-only Adapter** (vboxnet0)

### Step 4: Create Kali VM

1. **New VM** → Name: `kali`
2. Type: **Linux**, Version: **Other Linux (64-bit)**
3. Memory: **2048 MB**
4. **Settings > Storage**:
   - Controller: SATA, attach existing VDI (convert from qcow2 first)
5. **Settings > Network**:
   - Adapter 1: **Host-only Adapter** (vboxnet0)

## PowerShell Script

Run PowerShell **as Administrator**:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup_vbox_vms.ps1
```

This script will:
- Check for VirtualBox installation
- Create vboxnet0 network (10.0.0.1/24)
- Configure DHCP (10.0.0.11-100)
- Convert Kali qcow2 to VDI
- Create all 3 VMs with proper settings

## After VM Creation

1. Launch **pfSense** first - it needs network configuration
2. Configure LAN interface via pfSense CLI
3. Launch **Ubuntu** and **Kali**
4. Verify Kali gets IP in 10.0.0.x range

## Login Credentials

| VM | Username | Password |
|----|----------|----------|
| pfSense | admin | pfsense |
| Ubuntu | ubuntu | linux |
| Kali | kali | kali |
