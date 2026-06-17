#!/usr/bin/env python3
"""
Описание: Валидация YAML конфигураций PROJECT_ROOT/config
Использует PyYAML для синтаксического анализа
"""

import glob
import os
import sys
import yaml
from pathlib import Path

def validate_yaml_file(filepath):
    """Валидирует один YAML файл"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Пропускаем файлы без расширения .yaml или с шаблонами Helm
        if filepath.endswith('.yaml') or filepath.endswith('.yml'):
            # Проверяем на наличие шаблонов Helm ({{ ... }})
            if '{{' in content:
                return None, "Helm template (skipped)"  # Возвращаем None для пропуска
            
            # Парсим все документы в потоке
            list(yaml.safe_load_all(content))
        return True, None
    except yaml.YAMLError as e:
        return False, str(e)
    except Exception as e:
        return False, str(e)

def main():
    script_dir = Path(__file__).parent.resolve()
    project_root = script_dir.parent.parent
    
    print("=== Валидация YAML конфигураций ===")
    print(f"Project: {project_root}")
    print()
    
    errors = 0
    warnings = 0
    yaml_files = []
    
    # Ищем все .yaml и .yml файлы
    for pattern in ['config/**/*.yaml', 'config/**/*.yml', '**/*.yaml', '**/*.yml']:
        yaml_files.extend(glob.glob(str(project_root / pattern), recursive=True))
    
    # Уникальные файлы
    yaml_files = list(set(yaml_files))
    
    if not yaml_files:
        print("✓ Нет YAML файлов для проверки (пропуск)")
        sys.exit(0)
    
    for filepath in sorted(yaml_files):
        abs_path = os.path.abspath(filepath)
        relative_path = os.path.relpath(filepath, project_root)
        
        success, error = validate_yaml_file(filepath)
        
        if success is None:
            # Пропущен (Helm template)
            print(f"- SKIP: {relative_path} ({error})")
        elif success:
            print(f"✓ OK: {relative_path}")
        else:
            print(f"✗ ERROR: {relative_path}")
            print(f"  {error}")
            errors += 1
    
    print()
    print("=== Результаты ===")
    print(f"Найдено YAML файлов: {len(yaml_files)}")
    print(f"Ошибок: {errors}")
    
    if errors > 0:
        print("ОБНАРУЖЕНЫ ОШИБКИ!")
        sys.exit(1)
    else:
        print("Валидация завершена успешно!")
        sys.exit(0)

if __name__ == '__main__':
    main()
