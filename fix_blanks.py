#!/usr/bin/env python3
with open('C:/Users/HenryN/projects/CloudAndNetworkSecurity/1.Network_Security/misc/arch_installation_guide.md', 'r', encoding='utf-8') as f:
    content = f.read()
    
# Fix consecutive blank lines after code block
content = content.replace('```\n\n\n### install virt-manager for VM accessibility', '```\n\n### install virt-manager for VM accessibility')

with open('C:/Users/HenryN/projects/CloudAndNetworkSecurity/1.Network_Security/misc/arch_installation_guide.md', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed!")
