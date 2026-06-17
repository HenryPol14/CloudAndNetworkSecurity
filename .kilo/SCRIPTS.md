# YAML Validation Script

## Описание
Скрипт проверяет корректность YAML файлов в проекте.

### Особенности
- Парсит много-документные YAML файлы (с `---` разделителями)
- Пропускает Helm шаблоны (содержащие `{{ ... }}`)
- Проверяет синтаксис через PyYAML

### Установка
```bash
pip install pyyaml
```

### Использование
```bash
python validate-yaml.sh
```

### Пример вывода
```
=== Валидация YAML конфигураций ===
Project: C:\Users\HenryN\projects\CloudAndNetworkSecurity

✓ OK: file1.yaml
- SKIP: template-file.yaml (Helm template (skipped))
✓ OK: file2.yaml

=== Результаты ===
Найдено YAML файлов: 3
Ошибок: 0
Валидация завершена успешно!
```

## Из проекта llm-lab
Используются те же принципы:
- Строгий режим (`set -Eeuo pipefail`)
- Ясные сообщения об ошибках
- Не фатальные предупреждения
