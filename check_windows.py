#!/usr/bin/env python3
with open('C:/Users/HenryN/projects/CloudAndNetworkSecurity/1.Network_Security/README_WINDOWS.md', 'r', encoding='utf-8') as f:
    lines = f.readlines()
    for i in range(1, len(lines)):
        if lines[i-1].strip() == '' and i < len(lines) and lines[i].strip() == '':
            print(f'Consecutive at line {i-1}-{i}: "{repr(lines[i-2])}" -> "{repr(lines[i])}"')
    print("Checking end of file...")
    if lines[-1].strip() == '':
        print(f'Last line {len(lines)} is empty')
