#!/usr/bin/env python3
import subprocess
import sys

result = subprocess.run([sys.executable, '.kilo/scripts/validate-markdown.py'], capture_output=True, text=True)
output = result.stdout

passed = []
failed = []

lines = output.split('\n')
current_file = None
for line in lines:
    if 'Checking:' in line:
        current_file = line.replace('Checking: ', '').strip()
    elif '✓ OK' in line and current_file:
        passed.append(current_file)
    elif 'Found' in line and current_file:
        failed.append(current_file)

print("Files passed validation:")
for f in passed:
    print(f"  ✓ {f}")
print("\nFiles with issues:")
for f in failed:
    print(f"  ⚠ {f}")
