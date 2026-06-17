# Lightweight VM for Network Security Labs

Use this guide if you have a low spec system and want to do lab 1 and 2.

This tutorial guides you to replace the kali linux image (14.6GB) with a lightweight Xubuntu image (4.7GB). Rest of the installation steps stay the same as in the manual.

Download the custom created lightweight Xubuntu VM from [here](https://a3s.fi/swift/v1/CloudAndNetworkSecurity/Xubuntu.qcow2.tar.gz)


Image name|Image size|Download Link
:-:|:-:|:-:
**Xubuntu linux (lightweight)** | 4.7 gb | [Download](https://a3s.fi/swift/v1/CloudAndNetworkSecurity/Xubuntu.qcow2.tar.gz)
**Ubuntu server** | 5.9 gb | [Download](https://ubuntu.com/download/server/thank-you?version=26.04&architecture=amd64&lts=true)
**pfSense** | 1 gb | [Download](https://www.pfsense.org/download/?file=pfsense-2.7.2-release-amd64.iso)

Extract the file with `tar -xvzf Xubuntu.qcow2.tar.gz `

Clone the repository if you haven't already:
```
git clone https://github.com/ouspg/network_sec_platform.git
```



Download all the relevant images & place them in the directory network_sec_platform/images

Rename the `Xubuntu.qcow2` to `kali-linux-2023.4-qemu-amd64.qcow2`

Login credentials for VMs in following format: username:password

Image|Username:Password
:-:|:-:|
Xubuntu linux (4.7 GB) | osboxes:xubuntu
Ubuntu server | ubuntu:linux
pfSense | admin:pfsense (веб-интерфейс)

You are all set to deploy the network with terraform now using this lightweight image. It has the required tools installed for lab 1!
