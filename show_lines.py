#!/usr/bin/env python3
with open('C:/Users/HenryN/projects/CloudAndNetworkSecurity/1.Network_Security/misc/arch_installation_guide.md', 'r', encoding='utf-8') as f:
    lines = f.readlines()
    for i in range(37, 42):
        print(f"Line {i+1}: {repr(lines[i])}")
