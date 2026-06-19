# ============================================
# Auto-setup VirtualBox VMs for Lab 1
# Cloud and Network Security
# ============================================

# Requires: Run as Administrator

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# ── Paths ─────────────────────────────────────────────────────────────────────
$VM_BASE_DIR = "C:\Users\HenryN\projects\CloudAndNetworkSecurity\1.Network_Security\network_sec_platform\images"
$VBOX_MGMT = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

# ── Helper functions ────────────────────────────────────────────────────────

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host "  $Text"
    Write-Host ("=" * 60) -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Text)
    Write-Host "  → $Text" -ForegroundColor Cyan
}

function Write-OK {
    param([string]$Text)
    Write-Host "  ✓ $Text" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Text)
    Write-Host "  ⚠ $Text" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Text)
    Write-Host "  ✗ $Text" -ForegroundColor Red
}

function Convert-Path {
    param([string]$Path)
    # Replace double quotes for VBoxManage compatibility
    return $Path -replace '"', ''
}

function Test-VBoxManage {
    if (-not (Test-Path $VBOX_MGMT)) {
        Write-Fail "VBoxManage not found: $VBOX_MGMT"
        exit 1
    }
    Write-OK "VBoxManage found"
}

# ── Pre-checks ──────────────────────────────────────────────────────────────

Write-Header "Environment check"

Test-VBoxManage

# Create VMs folder
if (-not (Test-Path "$VM_BASE_DIR\vms")) {
    New-Item -ItemType Directory -Path "$VM_BASE_DIR\vms" | Out-Null
}

# Create subfolders for VMs
foreach ($vmName in @('kali', 'ubuntu_server', 'pfSense')) {
    $vmPath = "$VM_BASE_DIR\vms\$vmName"
    if (-not (Test-Path $vmPath)) {
        New-Item -ItemType Directory -Path $vmPath | Out-Null
    }
}

# Network interface name (global)
$interfaceName = $null

# Check images
Write-Step "Checking VM images..."
$images = @(
    @{Name = "kali-linux-2026.1-qemu-amd64.qcow2"; Path = "$VM_BASE_DIR\kali-linux-2026.1-qemu-amd64.qcow2"},
    @{Name = "ubuntu_server_2604_amd64.iso";      Path = "$VM_BASE_DIR\ubuntu_server_2604_amd64.iso"},
    @{Name = "pfsense-2.7.2-release-amd64.iso";   Path = "$VM_BASE_DIR\pfsense-2.7.2-release-amd64.iso"}
)

foreach ($img in $images) {
    if (Test-Path $img.Path) {
        $size = [math]::Round((Get-Item $img.Path).Length / 1GB, 2)
        Write-OK "$($img.Name) (size: ${size} GB)"
    } else {
        Write-Warn "$($img.Name) not found"
    }
}

# Check vboxnet0 network
Write-Step "Checking virtual network..."
$netList = & $VBOX_MGMT list hostonlyifs
$vboxNetName = $null
foreach ($line in $netList) {
    if ($line -match "^Name:\s+(.+)$") {
        $vboxNetName = $matches[1]
        break
    }
}

if ($vboxNetName -and $netList -match [regex]::Escape($vboxNetName)) {
    Write-OK "Network $vboxNetName exists"
    $interfaceName = $vboxNetName
} else {
    Write-Step "Creating network..."
    $createOutput = & $VBOX_MGMT hostonlyif create 2>&1
    Write-Host "$createOutput"
    
    # Extract interface name from output
    $interfaceName = $null
    foreach ($line in $createOutput) {
        if ($line -match "Interface '(.+)' was successfully created") {
            $interfaceName = $matches[1]
            break
        }
    }
    
    if (-not $interfaceName) {
        # Try to get existing interface
        foreach ($line in $netList) {
            if ($line -match "^Name:\s+(.+)$") {
                $interfaceName = $matches[1]
                break
            }
        }
    }
    
    if ($interfaceName) {
        & $VBOX_MGMT hostonlyif ipconfig "$interfaceName" --ip 10.0.0.1 --netmask 255.255.255.0
        Write-OK "Network $interfaceName created and configured (10.0.0.1/24)"
    }
}

# DHCP server for LAN
Write-Step "Configuring DHCP server..."
& $VBOX_MGMT dhcpserver modify --ifname "$interfaceName" `
    --ip 10.0.0.1 --netmask 255.255.255.0 `
    --lowerip 10.0.0.11 --upperip 10.0.0.100 --enable
Write-OK "DHCP configured (10.0.0.11-100)"

# ── VM Creation ─────────────────────────────────────────────────────────────

Write-Header "Creating virtual machines"

# Function to create VM with check
function New-VM-Safe {
    param(
        [string]$Name,
        [string]$OSType,
        [int]$MemoryMB,
        [int]$CPU,
        [string]$DiskPath,
        [string]$DiskSizeGB = "20",
        [switch]$UseExistingDisk
    )
    
    Write-Step "Creating VM: $Name"
    
    # Check existence
    $vms = & $VBOX_MGMT list vms
    if ($vms -like "*""$Name""*") {
        Write-Warn "VM $Name already exists, skipping..."
        return
    }
    
    # Create new VM
    & $VBOX_MGMT createvm `
        --name "$Name" `
        --ostype "$OSType" `
        --basefolder "$VM_BASE_DIR\vms" `
        --register
    
    if ($LASTEXITCODE -eq 0) {
        Write-OK "VM $Name created"
    } else {
        Write-Fail "Error creating VM $Name"
        return
    }
    
    # Configure memory and CPU
    & $VBOX_MGMT modifyvm "$Name" --memory $MemoryMB --cpus $CPU
    Write-OK "Configured: ${MemoryMB}MB RAM, $CPU CPU"
    
    # Network
    & $VBOX_MGMT modifyvm "$Name" --nic1 hostonly --hostonlyadapter1 "$interfaceName"
    Write-OK "Network configured (Host-only: $interfaceName)"
    
    # Disk
    if ($UseExistingDisk) {
        if (Test-Path $DiskPath) {
            & $VBOX_MGMT modifyvm "$Name" --hdd "$DiskPath"
            Write-OK "Disk attached: $DiskPath"
        } else {
            Write-Warn "Disk file not found: $DiskPath"
        }
    } else {
        # Create new disk
        $vdiPath = "$VM_BASE_DIR\vms\$Name\$Name.vdi"
        & $VBOX_MGMT createmedium disk --filename "$vdiPath" --size $DiskSizeGB
        & $VBOX_MGMT storagectl "$Name" --name "SATA Controller" --add sata
        & $VBOX_MGMT storageattach "$Name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$vdiPath"
        Write-OK "New disk created: ${DiskSizeGB}GB"
    }
}

# ── Kali Linux VM ───────────────────────────────────────────────────────────

# Convert qcow2 to vdi
$KaliQcow2 = "$VM_BASE_DIR\kali-linux-2026.1-qemu-amd64.qcow2"
$KaliVdi = "$VM_BASE_DIR\vms\kali\kali.vdi"

if (-not (Test-Path $KaliVdi)) {
    Write-Step "Converting Kali image (qcow2 → vdi)..."
    & $VBOX_MGMT convertfromraw $KaliQcow2 $KaliVdi --format VDI --variant Standard
    if ($LASTEXITCODE -eq 0) {
        Write-OK "Kali image converted"
    } else {
        Write-Fail "Error converting Kali image"
    }
}

New-VM-Safe -Name "kali" -OSType "Linux26_64" -MemoryMB 2048 -CPU 2 -DiskPath $KaliVdi -UseExistingDisk

# ── Ubuntu Server VM ───────────────────────────────────────────────────────

New-VM-Safe -Name "ubuntu_server" -OSType "Ubuntu24_LTS_64" -MemoryMB 2048 -CPU 2 -DiskSizeGB 20
Write-Step "Connecting Ubuntu ISO..."
& $VBOX_MGMT storagectl "ubuntu_server" --name "IDE Controller" --add ide
& $VBOX_MGMT storageattach "ubuntu_server" --storagectl "IDE Controller" `
    --port 0 --device 0 --type dvddrive --medium "$VM_BASE_DIR\ubuntu_server_2604_amd64.iso"
Write-OK "Ubuntu ISO connected"

# ── pfSense VM ──────────────────────────────────────────────────────────────

# Check if VM exists
$vms = & $VBOX_MGMT list vms
if (-not ($vms -like "*""pfSense""*")) {
    Write-Step "Creating pfSense VM..."
    
    & $VBOX_MGMT createvm `
        --name "pfSense" `
        --ostype "FreeBSD_64" `
        --basefolder "$VM_BASE_DIR\vms" `
        --register
    
    & $VBOX_MGMT modifyvm "pfSense" --memory 1024 --cpus 2
    
    # Network interfaces for pfSense
    # NIC1: NAT (WAN)
    & $VBOX_MGMT modifyvm "pfSense" --nic1 nat
    Write-OK "pfSense NIC1 configured (NAT - WAN)"
    
    # NIC2: Host-only (LAN)
    & $VBOX_MGMT modifyvm "pfSense" --nic2 hostonly --hostonlyadapter2 "$interfaceName"
    Write-OK "pfSense NIC2 configured (Host-only - $interfaceName)"
    
    # Create disk
    $PfSenseVdi = "$VM_BASE_DIR\vms\pfSense\pfSense.vdi"
    & $VBOX_MGMT createmedium disk --filename $PfSenseVdi --size 8192
    & $VBOX_MGMT storagectl "pfSense" --name "SATA Controller" --add sata
    & $VBOX_MGMT storageattach "pfSense" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $PfSenseVdi
    
    # Attach ISO
    & $VBOX_MGMT storagectl "pfSense" --name "IDE Controller" --add ide
    & $VBOX_MGMT storageattach "pfSense" --storagectl "IDE Controller" `
        --port 0 --device 0 --type dvddrive --medium "$VM_BASE_DIR\pfsense-2.7.2-release-amd64.iso"
    
    # Boot order
    & $VBOX_MGMT modifyvm "pfSense" --boot1 dvd --boot2 disk --boot3 none --boot4 none
    
    Write-OK "pfSense VM created"
} else {
    Write-Warn "pfSense VM already exists"
}

# ── Summary ────────────────────────────────────────────────────────────────

Write-Header "Done! Instructions for launching"
Write-Host @"

  Virtual machines created:

  1. **pfSense** (router/firewall)
     - 2 network interfaces: NAT (WAN) + Host-only (LAN)
     - Launch first to configure network
     - Login: admin / pfsense

  2. **ubuntu_server**
     - 1 network adapter (LAN)
     - Boots from Ubuntu ISO
     - Login: ubuntu / linux

  3. **kali** (attacker)
     - 1 network adapter (LAN)
     - Ready-to-use image with tools
     - Login: kali / kali

  IP addresses (LAN):
    - pfSense: 10.0.0.1
    - DHCP:    10.0.0.11 - 10.0.0.100

"@ -ForegroundColor White

Write-Host "Actions:" -ForegroundColor Yellow
Write-Host "  1. Open VirtualBox Manager" -ForegroundColor White
Write-Host "  2. Launch pfSense first" -ForegroundColor White
Write-Host "  3. Configure LAN in pfSense CLI (option 1 → interfaces)" -ForegroundColor White
Write-Host "  4. Then launch Ubuntu and Kali" -ForegroundColor White
Write-Host "  5. In Kali, verify IP is in 10.0.0.x range" -ForegroundColor White
Write-Host ""

Write-OK "Script completed successfully"
Write-Host ""
