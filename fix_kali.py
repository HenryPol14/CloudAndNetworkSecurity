#!/usr/bin/env python3
with open('C:/Users/HenryN/projects/CloudAndNetworkSecurity/2.Network_Security_2/misc/kali_internet_not_working.md', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix consecutive blank lines
content = content.replace('```\n\n\nEnsure correct IP', '```\n\nEnsure correct IP')

with open('C:/Users/HenryN/projects/CloudAndNetworkSecurity/2.Network_Security_2/misc/kali_internet_not_working.md', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed!")
