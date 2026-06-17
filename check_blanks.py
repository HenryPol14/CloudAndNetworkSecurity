#!/usr/bin/env python3
content = open('C:/Users/HenryN/projects/CloudAndNetworkSecurity/1.Network_Security/misc/arch_installation_guide.md', 'r', encoding='utf-8').read()
lines = content.split('\n')
for i in range(1, len(lines)):
    if lines[i-1].strip() == '' and i < len(lines) and lines[i].strip() == '':
        print(f'Consecutive at line {i-1}-{i}')
