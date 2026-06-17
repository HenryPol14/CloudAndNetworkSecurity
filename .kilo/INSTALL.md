# Установка инструментов валидации

## Выполненные действия

### Установленные инструменты

| Инструмент | Статус | Установка |
|------------|--------|-----------|
| **PSScriptAnalyzer** | ✅ Установлен | PowerShell Gallery |
| **PyYAML** | ✅ Установлен | pip |
| **ShellCheck** | ❌ Не установлен |Chocolatey (недоступен из-за сетевых проблем) |

### Созданные скрипты

Расположение: `.kilo/scripts/`

| Скрипт | Описание |
|--------|----------|
| `validate-bash.sh` | Проверка синтаксиса Bash скриптов (сShellCheck, если есть) |
| `validate-yaml.sh` | Валидация YAML файлов (много-документные и Helm шаблоны) |
| `validate-markdown.sh` | Базовая проверка Markdown документов |
| `validate-all.sh` | Запуск всех проверок |

## Для других машин

### 1. Установка PSScriptAnalyzer

```powershell
# Установка NuGet provider
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Установка модуля
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
```

### 2. Установка PyYAML (используется Python 3.14)

```bash
C:\Python314\python.exe -m pip install pyyaml
```

### 2. Установка PyYAML (используется Python 3.14)

```bash
C:\Python314\python.exe -m pip install pyyaml
```

### 3. Установка ShellCheck (опционально)

```powershell
# Через Chocolatey
choco install shellcheck

# Или загрузить вручную:
# https://github.com/koalaman/shellcheck/releases
```

## Использование

```bash
# Все проверки
bash .kilo/scripts/validate-all.sh

# Проверка Bash
bash .kilo/scripts/validate-bash.sh

# Проверка YAML
C:\Python314\python.exe .kilo/scripts/validate-yaml.sh

# Проверка Markdown
C:\Python314\python.exe .kilo/scripts/validate-markdown.sh
```

## Источник

Инструменты и правила взяты из проекта [llm-lab](https://gitlab.com/henrynik/llm-lab).