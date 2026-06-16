Cloud and Network Security Lab 1: Network Security
====

Responsible person/main contact: Asad Hasan, Juuso Herajärvi


>[!CAUTION]
>This platform demands a lot of resources from your host machine! If you have an older machine with 8GB RAM or less this platform will most likely not have enough resources to run optimally. You have the following options in this case: 1. Work as a group 2. Come to laboratory session & use the university's computers 3. Deploy something more lightweight instead of Kali.

Tips for option 3:
1. rename the kali-machine.tf to end with a different extension (such as kali-machine.txt) so that it doesn't get deployed by Terraform
2. find a lightweight VM image
3. deploy the VM manually with virt-manager, install the tools on it, and change its network to internal_network, then reboot 

## Preliminary tasks & prerequisites

* Create a GitHub account if you don't already have one
* Create your answer repository from the [provided link](https://moodle.oulu.fi/course/view.php?id=18795) on Moodle, **as instructed [here](https://github.com/ouspg/CloudAndNetworkSecurity/blob/main/README.md#getting-started)**
* This exercise can be completed on a Linux system or a Windows Linux subsystem (WSL2)
* You can also use the course's Arch Linux virtual machine.
    * Instructions are available [here](https://ouspg.org/resources/laboratories/). You will find the download link from the Moodle workspace.

### Windows Users

**For Windows systems, we recommend using VirtualBox instead of VMware Workstation:**

* 📖 **[README_WINDOWS.md](./README_WINDOWS.md)** — Complete setup guide for Windows + VirtualBox
* 📦 Includes: `install_virtualbox.ps1`, `setup_network_virtualbox.ps1`
* 🔧 Requires: Chocolatey package manager

** alternatives:**
* **WSL2 + Ubuntu** — Best compatibility with original instructions
* **VMware Workstation** — Manual VM setup (no Terraform support)
* **Lightweight Xubuntu** — 4.7 GB alternative for low-spec systems (see [lightweightVM_instead_of_kali.md](misc/lightweightVM_instead_of_kali.md))

> [!NOTE]
> This lab requires at least 8 GB RAM. For older machines, consider using lightweight Xubuntu image or working in a group.


A basic understanding of networking is required. GitHub is required to complete this exercise

Make yourself familiar with the following.

* **hping3** - Intro to [hping3](https://www.kali.org/tools/hping3/)
* **nmap** - Host discovery with [nmap](https://nmap.org/book/man-host-discovery.html) nmap on [Wikipedia](https://en.wikipedia.org/wiki/Nmap)
* **terraform** - Basic tutorial about what is terraform [here](https://k21academy.com/terraform-iac/terraform-beginners-guide/)
* **ICMP** - [ICMP](https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol)
* **pfSense** — Official documentation of pfSense [here](https://docs.netgate.com/pfsense/en/latest/install/assign-interfaces.html)
* **Wireshark** — Covered in pre-requisite courses. Official documentation [here](https://www.wireshark.org/docs/wsug_html/)
* **virsh commands** — Important ones are related to vol-, pool-, net-destroy/undefine/list [libvirt documentation](https://download.libvirt.org/virshcmdref/html-single/)


If you feel like your networking knowledge needs a revision, go through these tutorials:
[Basic tutorial 1](https://www.hackers-arise.com/post/networking-basics-for-hackers-part-1)
[Basic tutorial 2](https://www.hackers-arise.com/post/networking-basics-for-hackers-part-2)

Further reading about [networking concepts](https://docs.netgate.com/pfsense/en/latest/network/index.html)

## Grading

<!-- <details><summary>Details</summary> -->

You are expected to do the assignments **in order**.

Task #|Points|Description|Tools
-----|:---:|-----------|-----
Task 1 | 1 | Install and set up the network | Terraform, libvirt, QEMU, KVM
Task 2 | 1 | Run the virtual network | pfSense, Terraform, Virtual Manager
Task 3 | 1 | Host Discovery in LAN | Nmap
Task 4 | 1 | ICMP Tunneling Attack | hping3, Wireshark, tshark
Task 5 | 1 | Accessing HTTP Server from outside LAN | Open-ended


Total points accumulated by doing the exercises reflect the overall grade. You can acquire up to 5 points from the whole exercise.
<!-- </details> -->

---


## About the lab

* This document contains task descriptions and theory for the network security lab. If there are any differences between the return template and this file, consider this to be the up-to-date document.
* **You are encouraged to use your own computer or virtual machine if you want.** Check the Task 1 "**Setup Installation**" for information on what you need to install. This lab has been made to be completed in a Linux environment and tested to work in Debian, Ubuntu, and the provided Arch Linux virtual machine.
* __Upper scores for this assignment require that all previous tasks in this assignment have been done as well__, so e.g. in order to get the third point you will have to complete tasks 1, 2 & 3.
* Check the deadline from Moodle and __remember that you have to return your name (and possibly people you worked together with) and GitHub repository information to Moodle before the deadline.__


## Background

This week’s theme is network security.
Tasks are designed to be done with the provided network setup using [terraform](https://en.wikipedia.org/wiki/Terraform_(software)), see the [terraform commands tutorial](https://tecadmin.net/terraform-basic-commands/) for instructions on how to run the network using terraform. The firewall (+router) used in this network is [pfSense](https://docs.netgate.com/pfsense/en/latest/general/index.html).
The provided VM's within terraform has all the required tools preinstalled.  Contact course assistants if you require any extra tools, they'll install them in a custom image for you and provide instructions how to use it within the setup. 



## INTRODUCTION TO THE NETWORK SETUP

The virtual test network is based on two networks:
1. WAN
2. LAN

The WAN is your standard computer network. The LAN is the internal network which contains HTTP server (Ubuntu) and probe machine (kali) protected by pfSense firewall which also
acts as the default router for this. By default, WAN is not allowed to communicate or discover the LAN network.

In this lab, we will first explore some techniques to discover hosts within the internal LAN network using [nmap](https://en.wikipedia.org/wiki/Nmap) and [ICMP](https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol) requests. Students will observe traffic packets using pfSense traffic capture tool. Towards the end of lab, students will perform an actual ICMP tunneling attack and transfer a .txt file using modified packets.

The internal LAN network consists of following machines

Kali Linux (attack machine)

 * Ubuntu linux (server)

 * Router & Firewall (pfSense) - to protect the internal LAN network and shield it from outside

**See network diagram below**

![image](https://github.com/ouspg/CloudAndNetworkSecurity/assets/113350302/58f7f99a-a9ac-4f80-9e67-653a677156fb)




Now that we know the basics of virtual network setup, let’s get into the lab task. Task 1 is about setting up the network by installing the required prerequisite software.

> [!Note]
> * **Sharing files between KVM and the host machine** — [Guide to creating a mounting point for file share](https://www.debugpoint.com/share-folder-virt-manager/)


---

## Task 1

### Setup Installation

The network structure in this lab is built upon terraform. Terraform is a tool for deploying infrastructure as a code. Here, it is used to spawn the network infrastructure resources virtually using code configurations in terraform files (which is already done for you). A set of certain software dependencies are required to achieve this such as Libvirt, QEMU and KVM. Therefore, to make the network structure work, you will need to follow the guidelines below. The instruction set has been tested on Ubuntu/Debian Linux as well as Arch Linux. Install guide for Arch Linux can be accessed [here](misc/arch_installation_guide.md).

**NOTE:** If you plan to set up the network within a virtual machine, be mindful of the hard disk space requirements, as the image sizes are large.

For **low-spec systems** (8GB RAM or less), use the lightweight **Xubuntu image** instead of Kali (14.6 GB → 4.7 GB). See: [lightweightVM_instead_of_kali.md](misc/lightweightVM_instead_of_kali.md)


**Install and set up libvirtd and necessary packages for UEFI virtualization:**
```
sudo apt update
sudo apt-get install qemu-kvm libvirt-daemon-system virt-top libguestfs-tools ovmf
sudo adduser $USER libvirt
sudo usermod -aG libvirt $(whoami)
```

Start and enable libvirtd
```
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```

**Install terraform**

Follow specific instructions for your system

https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

**Verify terraform is accessible and the CLI works**
```
which terraform
terraform --version
```


**Install virt-manager for VM accessibility**
```
sudo apt-get install virt-install virt-viewer
sudo apt-get install virt-manager

#if installing on a WSL (windows subsystem for linux) use this single command:
sudo apt install virtinst virt-viewer

#verify installation with
virt-manager
```

**Install qemu and verify the installation:**
https://www.qemu.org/download/#linux
```
qemu-system-x86_64 --version
```

**Download the relevant images and place them in the directory `network_sec_platform/images`.**

Following table summarizes the required images with download links for this lab:

Image name|Image size|Download Link
:-:|:-:|:-:
**Kali Linux 2026.1** | ~5 GB | [Download](https://cdimage.kali.org/kali-2026.1/kali-linux-2026.1-qemu-amd64.7z)
**Xubuntu (lightweight)** | 4.7 GB | [Download](https://a3s.fi/swift/v1/CloudAndNetworkSecurity/Xubuntu.qcow2.tar.gz) *(for low-spec systems)*
**Ubuntu Server 26.04 LTS** | 5.9 GB | [Download](https://ubuntu.com/download/server/thank-you?version=26.04&architecture=amd64&lts=true)
**pfSense 2.8.1** | ~1.2 GB | [Download](https://download.pfsense.org/releases/2.8.1/pfSense-CE-2.8.1-RELEASE-amd64.iso.gz)

The repository for terraform deployment can be cloned using the link below

```shell
git clone https://github.com/ouspg/network_sec_platform.git
```
There are three images that you need to download (links provided above) and place them into directory _network_sec_platform/images_ 

They have the following names:

1) `kali-linux-2023.4-qemu-amd64.qcow2`
2) `router_pfsense.qcow2`
3) `ubuntu_server.qcow2`



**Install mkisofs for ISO image creation:**
```
sudo apt-get install -y mkisofs
```

**Install xsltproc for XML processing:**
```
sudo apt-get install xsltproc
```

**Initialize the default volume storage pool:**

Cd into the cloned directory `network_sec_platform` and initialize the default volume storage pool.

Defining this pool to point to `./volumes` makes it easier to control the resources, and it avoids having to deal with any permission issues. Also, keeping all resources under the "master" directory lets us easily delete all the resources once we are done with the laboratories.

```
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
```

**Configure user permissions for qemu + libvirt with the storage pool:**
```
sudo chown -R $(whoami):libvirt $PWD/volumes
```
Edit `/etc/libvirt/qemu.conf` file, uncomment user, group, and security_driver, and make the following changes:
```
# Some examples of valid values are:
#
#       user = "qemu"   # A user named "qemu"
#       user = "+0"     # Super user (uid=0)
#       user = "100"    # A user named "100" or a user with uid=100
#
user = "<username>"
# The group for QEMU processes run by the system instance. It can be
# specified in a similar way to user.
group = "libvirt"
...
security_driver = "none"
```
```
sudo systemctl restart libvirtd
```


### Provision the platform with Terraform:
```
export TERRAFORM_LIBVIRT_TEST_DOMAIN_TYPE="qemu"
terraform init
terraform apply
```
**Notes:**
- The Ubuntu domain takes about a minute to start due to the nature of cloud images and their preconfigurations.- On many operating systems, SELinux or AppArmor can mess up the permissions for libvirt. Uncomment and change `/etc/libvirt/qemu.conf` user and group. For more information, see: https://ostechnix.com/solved-cannot-access-storage-file-permission-denied-error-in-kvm-libvirt/
- To make sure networks autostart after a shutdown of the host machine, you can run:
```
  virsh net-autostart internal_network && virsh net-autostart external_network && virsh net-autostart demilitarized_zone
```

- Running into errors? Read the troubleshooting section [here](https://github.com/ouspg/network_sec_platform/tree/main?tab=readme-ov-file#troubleshooting)

- Virsh [commands](https://download.libvirt.org/virshcmdref/html-single/) are useful for troubleshooting as well, particularly the net-, pool-, and volume commands (list, destroy, undefine)

---
## Task 2

### Run the virtual network

If you have successfully installed all the required software, you're now set to deploy the network setup from GitHub and initialize it using Terraform.
Following this, you will use Virtual Manager to access the virtual resources spawned by Terraform.

### **A) Go into the repository folder and initialize Terraform and deploy the configuration**

Clone the main branch if you haven't already and place the virtual images in the `network_sec_platform/images` folder. Skip this step if you have already done so.

```shell
git clone https://github.com/ouspg/network_sec_platform.git
```

Useful commands:
```
# To initialize Terraform. It's always the first step in brand new repository.
terraform init

# To validate terraform configuration and look for errors
terraform validate

# To apply terraform and spawn virtual resources
terraform apply

# To destroy resources spawned by Terraform. Usually done when you have finished playing around with the network.
terraform destroy

# Highlights the plan of resources to spawn
terraform plan
```

Note: It can take a few minutes to deploy the network structure, so be patient.
**Deploy your virtual network. Provide the commands used.**

**How many resources does Terraform prompt in the plan to create/add?**

**Provide screenshot.**

**If apply completed successfully, it means your virtual network is up. Provide a successful screenshot of apply.**
If not, go back, diagnose, and fix your errors. A small guide about [managing virtual resources spawned by Terraform](misc/diagnostic_guide.md).

Normally, if terraform deployment fails, using `terraform destroy` is not enough. Some of the virtual resources remain and have to be destroyed or killed manually. Moreover,
terraform state files need to be deleted manually in such cases. They are:

1) `terraform.tfstate`

2) `terraform.tfstate.backup`

3) `terraform.lock.hcl` — File used to initialize Terraform



---

### B) Access Virtual Manager and open virtual machines

```shell
# Command to access Virtual Manager
virt-manager
```

**How many virtual machines do you see? Where do you see the pfSense firewall deployed?**
**Provide screenshot.**

Login credentials for VMs are in the following format: username:password

Kali Linux: kali:kali

Ubuntu Server: ubuntu:linux

---

### **C) Configure the LAN Network Using pfSense CLI and Access the webGUI from Kali Linux**

PfSense boots with the default configuration for the LAN network. Your task is to configure it correctly and build a LAN network valid for the configuration provided below.
If done correctly, you should be able to access the pfSense webGUI from machines on your virtual LAN network (such as Kali and Ubuntu Server).

IMPORTANT: After configuring the LAN network using pfSense CLI, you will need to reboot the virtual machine's network adapter or alternatively reboot (Kali and Ubuntu Linux) for new network configurations to take effect.

```
LAN Network Specifications:

Internal LAN network, which contains Kali Linux, Ubuntu Server, and pfSense acting as a router.
The network operates on subnet mask 255.255.255.0 (/24).
PfSense is assigned the following IP: 10.0.0.1

The IP address range for the network is as follows:
Start address: 10.0.0.11 (/24)
End address: 10.0.0.100 (/24)

DHCP Server: enabled
IPv6: disabled

Protocol for the webGUI: HTTPS

```
![image](https://github.com/ouspg/CloudAndNetworkSecurity/assets/113350302/e32f328b-c8c3-4232-aef5-b95085a61d7f)

To help you get started, select option 1 and assign interfaces as follows:

WAN → vtnet0

LAN → vtnet1

OPT1 → vtnet2

Proceed to option 2 and use the LAN Network Specification guide provided above to build a LAN network.
This process is easy enough and should allow you to correctly set up the LAN network. Useful [guide](https://docs.netgate.com/pfsense/en/latest/install/assign-interfaces.html)

Next, reboot Kali Linux for new network configurations to take effect, or you can also restart the network adapter with:
```shell
sudo ip link set eth0 down  # Replace eth0 with your interface name
sudo ip link set eth0 up
```

**What is the IP address of your Kali Linux? Is it on the correct LAN network? How can you test and confirm?**
**Access the webGUI from your Kali Linux. Provide screenshot.**
Congratulations if you have successfully accessed the pfSense webGUI. With this portal, you can configure firewall rules, utilize diagnostic tools, observe network traffic, and much more.
Use the following default credentials to log in as root:

Username: admin

Password: pfsense

**At this point, the WAN interface should be disabled. Do not configure or enable it from the webGUI.**

**Do a small ping test and observe captured traffic by pfSense using one of its diagnostic packet capture tools available in the webGUI. Ping test can be between any of the router, Kali, or server. Add screenshot.**

---



## Task 3

### Host Discovery

### Discovering Hosts Inside the LAN Network and Accessing the Server's Webservice from LAN

From your network setup, you know that you're on the network 10.0.0.1/24. Use the nmap scan to discover hosts on the network.


### **A) How many hosts are present in the internal LAN network? What are their IP addresses?**
**Provide the commands used.**

**Add screenshot.**

The Linux server is automatically running an HTTP nginx service. It can be accessed using `http://<server_ip_addr>` in any web browser.

---

### **B) Now try running the same command from outside the LAN network? Are you able to discover devices inside the internal LAN network? Explain your answer**

You can do this step from your host-machine which has internet access. Can it access or discover the LAN network somehow?

What about the webservice running at `http://<server_ip_addr>`? Can you access it?

---

### **C) Extracting More Host Info Using Nmap**

Use the `-PE`, `-PM`, and `-PP` flags of Nmap to perform host discovery by sending ICMPv4 echo, timestamp, and subnet mask requests, respectively.

**Provide the command used to do this.**

**What extra information did you gather using this? Paste screenshot.**

### D) Demonstrate Access to the Web Service Using Your Kali Linux

As stated earlier, Ubuntu Server is running nginx at `http://<server_ip_addr>`.

**Access the server from Kali Linux and attach screenshot.**

---

## Task 4

### File Transfer through ICMP Tunneling

In the realm of network adversary tactics, one commonly employed technique is Protocol Tunneling, denoted by MITRE as T1572. This method involves encapsulating data packets within a different protocol, offering a means to obscure malicious traffic and provide encryption for enhanced security and identity protection.

When discovering hosts, ICMP is the easiest and fastest way to do it. ICMP stands for Internet Control Message Protocol and is the protocol used by the typical PING command to send packets to hosts and see if they respond back or not.
You could try to send some ICMP packets and expect responses. The easiest way is just sending an echo request and expecting a response. You can do that using a simple `ping` or using `fping` for ranges.
Moreover, you could also use nmap to send other types of ICMP packets (this will avoid filters to common ICMP echo request-response).

ICMP packets can be modified to include information in their payloads. The data portion of the ICMP (Internet Control Message Protocol) packets, known as the payload, can be altered to include additional information beyond what is typically included in standard ICMP packets. In this task, you will perform ICMP tunneling to transfer a `.txt` file from the server (Ubuntu Linux) to Kali Linux using hping3.

[hping3 tutorial](https://www.zframez.com/articles/testing-tools/introduction-to-hping3)

---

### **A) Send hackers_data.txt file as ICMP packets to Kali Linux**

ICMP packets can be used for tunneling other protocols or data across networks. By encapsulating data within the payload of ICMP packets, it's possible to transmit information between endpoints without directly using the protocols typically associated with those endpoints. This technique is sometimes used for evasion or bypassing network filtering. In this task, you will explicitly use hping3 to send the text file as ICMP packets and observe the received packets through Wireshark.

For converting the file into ICMP packets, you will use hping3 (a packet crafting tool). How does it work? See the diagram below:

![image](https://github.com/ouspg/CloudAndNetworkSecurity/assets/113350302/bab100c8-da80-4954-9696-d82fbe94738b)

Here's what you need to do:
- Log in to the server and locate `hackers_data.txt`- Craft an hping3 command with the correct flags and destination address (Kali Linux) to transfer the file as ICMP packets
- Log in to Kali and open Wireshark (or craft tcpdump commands to dump packets once received)
- Send ICMP packets through the server and simultaneously monitor and capture the packets from Kali Linux using Wireshark.

> [!NOTE]
> Depending on your interface's Maximum Transmission Unit (MTU), each packet has a certain limit of data that it can hold without getting fragmented. Use the `ifconfig` or `ip addr` command to check your interface's Maximum Transmission Unit (MTU). Generally it has a value of 1500 for ethernet. However, the actual usable data is:

Maximum ICMP Data = MTU − Ethernet_Frame_Header − IP_Header − ICMP_Header

Maximum ICMP Data = 1500bytes − 14bytes − 20bytes − 8bytes

Maximum ICMP Data = 1458 bytes

The Maximum Transmission Unit (MTU) is the maximum size of a single data unit that can be transmitted over a network.

You should stop the hping3 command when EOF (end of file) prompt is reached

![image](https://github.com/ouspg/CloudAndNetworkSecurity/assets/113350302/6ecbb36c-7364-4d34-9cc1-041f9a6c04ab)


**Provide the commands used to send modified packets.**

**Add screenshot.**

**Inspect received packets from Wireshark. Do the packets contain text from the file? Attach screenshots as proof.**


Make sure you are inspecting the correct packets in Wireshark. Save your file as `hacker_data.pcap` for use in the next task.

**Inspect the Internet Control Message Protocol packet's Data field (which should be 1458 bytes) to locate the subfield in which attached data is stored.**

![image](https://github.com/ouspg/CloudAndNetworkSecurity/assets/113350302/d2910021-7adb-4468-9a6b-b6573436eb00)


> [!Tip]
> Tcpdump is a command-line packet analyzer tool for monitoring and analyzing network traffic on a Unix or Linux system. It captures packets flowing through a network interface and allows users to inspect them in real-time or save them to a file for later analysis. To use TCPdump, you typically specify the network interface to listen on (e.g., eth0), optionally apply filters to capture specific types of traffic, and specify any desired options or output formats. For example, to capture all traffic on interface eth0 and display it on the terminal, you can use the command `sudo tcpdump -i eth0`.

---

### **B) Extract the `(data.data)` field from the `.pcap` file using tshark**

Use **hacker_data.pcap** acquired in previous task to pull out (data.data) field from the .pcap file and dump it into a hexdump.txt file

Your task is to craft a command that uses tshark to read data packets from the file `hacker_data.pcap`. It should extract the attached data from each packet in hexadecimal format (`data.data`) and save it to the file `hexdump.txt`.

> [!Tip]
> The `-n` flag disables name resolution, `-q` suppresses unnecessary output, and `-T fields` specifies the output format.

For help with tshark, see the [tshark documentation](https://www.wireshark.org/docs/man-pages/tshark.html).

**Provide the command used.**

**Screenshot of `hexdump.txt` file**

Next, copy the contents of the hexdump file and use an online hex to ASCII converter [tool](https://www.rapidtables.com/convert/number/hex-to-ascii.html) to restore contents of the original file.

**Are you able to reconstruct the original `hackers_data.txt` file sent using ICMP packets? What are the contents of the file? Briefly explain your answer and attach a screenshot.**


---

## Task 5

### Accessing HTTP Server from Outside LAN

This is a free-form task where you will play around with the pfSense firewall webGUI or come up with an alternative solution to access the HTTP server (Ubuntu) running in the internal virtual LAN from your host computer.

Here's what you need to understand first:
* Your host machine is on a WAN network (if connected to Wi-Fi) or a different LAN network (if using Ethernet)
* You have configured an internal LAN network using pfSense, which cannot be accessed from outside
* The HTTP server inside the internal LAN behind pfSense is not discoverable by your host machine

Here's what you need to do:
* Establish a communication channel between your host machine (WAN or other LAN) and the HTTP server (internal LAN)
* Access the web service running on the HTTP server from your host machine

![image](https://github.com/ouspg/CloudAndNetworkSecurity/assets/113350302/525722a4-e00f-40ac-b522-4713a4d98820)

Red lines in the diagram above indicate the required objective to be achieved

There are no restrictions on the choice of software or platform for this task. However, using the pfSense webGUI is recommended, as it provides multiple useful options to complete this task, such as:
* Port forwarding
* Firewall rules
* VPN (OpenVPN)

![image](https://github.com/ouspg/CloudAndNetworkSecurity/assets/113350302/fb64c03a-fb78-4eee-806b-55848225f214)


The main idea behind this task is to configure the firewall to allow the host to communicate with the Ubuntu server. **If you decide to do this task, you must research on your own how it could be achieved and then try to implement it.**


**Document your work properly for this task and include necessary screenshots and commands used.**

**You should clearly state your plan and which pathways you took to achieve the objective.**

**Make sure to include testing results to showcase success or failure.**

**In case of partial implementation, write a brief report on the issues and roadblocks encountered. You can still earn some points with partial or failed attempts.**


---

