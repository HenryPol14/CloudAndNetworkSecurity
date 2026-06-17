#!/usr/bin/env python3
"""Markdown validation and linting script for the CloudAndNetworkSecurity project."""

import re
import sys
from pathlib import Path

FILES_TO_CHECK = [
    "README.md",
    ".kilo/INSTALL.md",
    ".kilo/SCRIPTS.md",
    ".kilo/plans/install-validation-tools.md",
    "1.Network_Security/README.md",
    "1.Network_Security/README_RU.md",
    "1.Network_Security/misc/arch_installation_guide.md",
    "1.Network_Security/misc/diagnostic_guide.md",
    "1.Network_Security/misc/lightweightVM_instead_of_kali.md",
    "1.Network_Security/README_WINDOWS.md",
    "7.Security_of_Internet_The_Big_Picture/bgpy_pkg_install_guide.md",
    "7.Security_of_Internet_The_Big_Picture/README.md",
    "6.Digital_Forensics/README.md",
    "5.Cloud_Security/deployments/wordpress/README.md",
    "5.Cloud_Security/README.md",
    "4.Container_Security/README.md",
    "3.Network_Protocols/README.md",
    "2.Network_Security_2/misc/kali_internet_not_working.md",
    "2.Network_Security_2/README.md",
]

ERRORS_FOUND = False


def check_trailing_whitespace(content: str) -> list[str]:
    """Check for trailing whitespace."""
    errors = []
    for line_num, line in enumerate(content.split("\n"), 1):
        if line.rstrip() != line:
            errors.append(f"Line {line_num}: Trailing whitespace")
    return errors


def check_consecutive_blank_lines(content: str, max_consecutive: int = 1) -> list[str]:
    """Check for more than max_consecutive blank lines."""
    errors = []
    lines = content.split("\n")
    blank_count = 0
    for line_num, line in enumerate(lines, 1):
        if line.strip() == "":
            blank_count += 1
            if blank_count > max_consecutive:
                errors.append(f"Line {line_num}: Too many consecutive blank lines ({blank_count})")
        else:
            blank_count = 0
    return errors


def check_heading_format(content: str) -> list[str]:
    """Check heading format."""
    errors = []
    lines = content.split("\n")
    in_code_block = False
    for line_num, line in enumerate(lines, 1):
        if line.strip().startswith("```"):
            in_code_block = not in_code_block
            continue
        if in_code_block:
            continue
        stripped = line.lstrip()
        if stripped.startswith("#"):
            match = re.match(r"^(#+)(.*?)$", stripped)
            if match:
                hash_count = len(match.group(1))
                text = match.group(2)
                if not text.startswith(" "):
                    errors.append(f"Line {line_num}: Missing space after # in heading")
                elif text.endswith(" "):
                    errors.append(f"Line {line_num}: Trailing space in heading")
    return errors


def check_inline_code_format(content: str) -> list[str]:
    """Check inline code formatting - flag only non-command words that should be in backticks."""
    errors = []
    lines = content.split("\n")
    in_code_block = False
    for line_num, line in enumerate(lines, 1):
        if line.strip().startswith("```"):
            in_code_block = not in_code_block
            continue
        if in_code_block:
            continue
        stripped = line.strip()
        if stripped == "" or stripped.startswith(">"):
            continue
        if stripped.startswith("#"):
            continue
        if stripped.startswith("-") or stripped.startswith("*") or stripped.startswith("+"):
            continue
        if stripped.startswith("<!--"):
            continue
        if re.match(r"^[-:|]+$", stripped):
            continue
        if re.match(r"^[*+-]\s*\*\*", stripped):
            continue

        # Only flag markdown keywords that should have backticks (software names, options)
        # Skip raw URLs and technical descriptions
        if re.search(r"\[([^\]]+)\]\([^)]*\)", line):
            # Line has a link - find text outside links
            line_without_links = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", line)
            # Check for software names that should be in backticks
            if re.search(r"\b(python|bash|powershell|npm|terraform|pip|apt|gem)\b", line_without_links, re.IGNORECASE):
                if not re.search(r"`[^`]+`", line_without_links):
                    errors.append(
                        f"Line {line_num}: Code should be wrapped in backticks (e.g., `command`)"
                    )
        elif re.search(r"\b(python|bash|powershell|npm|terraform|pip|apt|gem)\b", line, re.IGNORECASE):
            # Check if it's just a link, not actual command
            if not re.search(r"\[.*\]\(.*\)", line):
                if not re.search(r"`[^`]+`", line):
                    errors.append(
                        f"Line {line_num}: Code should be wrapped in backticks (e.g., `command`)"
                    )
    return errors


def check_link_format(content: str) -> list[str]:
    """Check link format (should not have trailing spaces)."""
    errors = []
    for line_num, line in enumerate(content.split("\n"), 1):
        if "]" in line and ")" in line:
            match = re.search(r"\[([^\]]+)\]\(([^)]+)\)", line)
            if match:
                link_text = match.group(1)
                url = match.group(2)
                if link_text != link_text.strip():
                    errors.append(f"Line {line_num}: Trailing space in link text")
                if url != url.strip():
                    errors.append(f"Line {line_num}: Trailing space in URL")
    return errors


def check_ordered_list_format(content: str) -> list[str]:
    """Check ordered list format (should be 1. Item, not 1.Item or 1 .Item)."""
    errors = []
    pattern = r"^(\d+)\. +(\S)"
    for line_num, line in enumerate(content.split("\n"), 1):
        match = re.search(pattern, line)
        if match:
            number = match.group(1)
            text = match.group(2)
            if line.strip() == f"{number}.{text}":
                errors.append(f"Line {line_num}: Missing space after . in list item")
    return errors


def check_unordered_list_format(content: str) -> list[str]:
    """Check unordered list format (should be - Item with space, not -Item)."""
    errors = []
    for line_num, line in enumerate(content.split("\n"), 1):
        stripped = line.strip()
        if stripped == "---" or stripped == "**" or stripped == "*":
            continue
        if stripped.startswith("-"):
            if len(stripped) < 3 or stripped[1] != " ":
                errors.append(
                    f"Line {line_num}: Missing space after - in unordered list item"
                )
    return errors


def check_html_tags(content: str) -> list[str]:
    """Check for unused HTML tags like <details> without corresponding </details>."""
    errors = []
    content_no_comments = re.sub(r"<!--[\s\S]*?-->", "", content)
    open_tags = re.findall(r"<(details|summary)[^>]*>", content_no_comments, re.IGNORECASE)
    close_tags = re.findall(r"</(details|summary)>", content_no_comments, re.IGNORECASE)
    if len(open_tags) != len(close_tags):
        errors.append("Mismatched <details> or <summary> tags")
    return errors


def validate_file(filepath: Path) -> list[str]:
    """Validate a markdown file and return list of issues."""
    issues = []

    try:
        content = filepath.read_text(encoding="utf-8")
    except Exception as e:
        return [f"Error reading file: {e}"]

    issues.extend(check_trailing_whitespace(content))
    issues.extend(check_consecutive_blank_lines(content))
    issues.extend(check_heading_format(content))
    issues.extend(check_inline_code_format(content))
    issues.extend(check_link_format(content))
    issues.extend(check_ordered_list_format(content))
    issues.extend(check_unordered_list_format(content))
    issues.extend(check_html_tags(content))

    return issues


def main():
    global ERRORS_FOUND

    project_root = Path(__file__).parent.parent.parent
    files_to_check = [project_root / f for f in FILES_TO_CHECK]

    for filepath in files_to_check:
        if not filepath.exists():
            print(f"File not found: {filepath}")
            ERRORS_FOUND = True
            continue

        print(f"Checking: {filepath}")
        issues = validate_file(filepath)

        if issues:
            ERRORS_FOUND = True
            print(f"  Found {len(issues)} issue(s):")
            for issue in issues[:10]:
                print(f"    - {issue}")
            if len(issues) > 10:
                print(f"    ... and {len(issues) - 10} more issues")
        else:
            print(f"  ✓ OK")

    if ERRORS_FOUND:
        print("\n⚠ Some issues found. Please review and fix manually.")
        return 1
    else:
        print("\n✓ All files passed validation!")
        return 0


if __name__ == "__main__":
    sys.exit(main())
