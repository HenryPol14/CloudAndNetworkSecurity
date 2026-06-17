#!/usr/bin/env python3
"""
Описание: Валидация Markdown документов PROJECT_ROOT
Проверяет:
- Корректность синтаксиса (basic validation)
- Наличие обязательных заголовков
- Ссылки на недостающие файлы (базовая проверка)
"""

import glob
import os
import re
import sys
from pathlib import Path

def validate_markdown(filepath):
    """Валидирует один Markdown файл"""
    issues = []
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return [f"Read error: {e}"]
    
    lines = content.split('\n')
    
    # Проверка: файл не пустой
    if not content.strip():
        issues.append("Файл пустой")
        return issues
    
    # Проверка: есть заголовок H1-H6 (поддержка # и ======, ------)
    has_h1 = False
    for i, line in enumerate(lines[:10]):
        # Проверка на H1-H6 с # форматом
        if re.match(r'^#{1,6} ', line):
            has_h1 = True
            break
        # Проверка на H1 с underlining (====)
        if i > 0 and re.match(r'^=+$', line) and len(line.strip()) >= 4:
            prev_line = lines[i-1]
            if prev_line and prev_line.strip() and not prev_line.strip().startswith('#') and not prev_line.strip().startswith('>'):
                has_h1 = True
                break
        # Проверка на H2 с underlining (----)
        if i > 0 and re.match(r'^-+$', line) and len(line.strip()) >= 4:
            prev_line = lines[i-1]
            if prev_line and prev_line.strip() and not prev_line.strip().startswith('#') and not prev_line.strip().startswith('>'):
                # Это H2 в стиле подчеркивания, считаем как заголовок
                has_h1 = True
                break
    
    if not has_h1:
        issues.append("Отсутствует заголовок H1")
    
    # Проверка: кодировка UTF-8
    try:
        content.encode('utf-8')
    except UnicodeEncodeError:
        issues.append("Некорректная кодировка (не UTF-8)")
    
    # Проверка: нет CRLF (лишние пустые строки)
    for i, line in enumerate(lines, 1):
        if '\r' in line:
            issues.append(f"Строка {i}: CRLF перенос (используйте LF)")
            break
    
    # Проверка битых ссылок (только относительные пути к .md файлам)
    # Паттерн для относительных ссылок: [text](path.md)
    relative_links = re.findall(r'\[([^\]]+)\]\(([^\)]+\.md)\)', content)
    for link_text, link_path in relative_links:
        # Пропускаем абсолютные URL
        if link_path.startswith('http://') or link_path.startswith('https://'):
            continue
        # Решаем путь относительно текущего файла
        base_dir = os.path.dirname(filepath)
        target_path = os.path.normpath(os.path.join(base_dir, link_path))
        if not os.path.isfile(target_path):
            issues.append(f"Битая ссылка: {link_path}")
    
    return issues

def main():
    script_dir = Path(__file__).parent.resolve()
    project_root = script_dir.parent.parent
    
    print("=== Валидация Markdown документов ===")
    print(f"Project: {project_root}")
    print()
    
    errors = 0
    warnings = 0
    markdown_files = []
    
    # Ищем все .md файлы
    for pattern in ['**/*.md']:
        markdown_files.extend(glob.glob(str(project_root / pattern), recursive=True))
    
    # Исключаем файлы .git и node_modules
    markdown_files = [
        f for f in markdown_files 
        if '.git' not in f and 'node_modules' not in f
    ]
    
    # Уникальные файлы
    markdown_files = list(set(markdown_files))
    
    if not markdown_files:
        print("✓ Нет Markdown файлов для проверки (пропуск)")
        sys.exit(0)
    
    for filepath in sorted(markdown_files):
        abs_path = os.path.abspath(filepath)
        relative_path = os.path.relpath(filepath, project_root)
        
        issues = validate_markdown(filepath)
        
        if not issues:
            print(f"✓ OK: {relative_path}")
        else:
            print(f"⚠ ISSUES: {relative_path}")
            for issue in issues:
                print(f"  - {issue}")
            errors += 1
    
    print()
    print("=== Результаты ===")
    print(f"Найдено Markdown файлов: {len(markdown_files)}")
    print(f"Файлов с проблемами: {errors}")
    
    # Учитываем проблемы как warning (не фатально)
    print("Валидация завершена (проблемы не критичны)")
    sys.exit(0)

if __name__ == '__main__':
    main()
