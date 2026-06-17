# План: Установка инструментов валидации скриптов и документов

## Цель
Поставить инструменты для проверки скриптов (Bash, PowerShell) и документов (Markdown).

## Шаг 1: Инструменты для Bash скриптов
- **ShellCheck** - статический анализатор bash скриптов
- Установка via Chocolatey: `choco install shellcheck`

## Шаг 2: Инструменты для PowerShell скриптов
- **PSScriptAnalyzer** - модуль PowerShell для линтинга
- Установка: `Install-Module -Name PSScriptAnalyzer -Scope CurrentUser`

## Шаг 3: Инструменты для Markdown документов
- **markdownlint** - линтер Markdown
- Установка via npm: `npm install -g markdownlint-cli`
- Либо via Chocolatey: `choco install markdownlint`

## Шаг 4: Инструменты для YAML (если есть конфиги)
- **Yamllint** - линтер YAML
- Установка via pip: `pip install yamllint`

## Приоритет установки
1. PSScriptAnalyzer (PowerShell - есть в проекте)
2. ShellCheck (Bash - есть в проекте)
3. markdownlint (Markdown документы)

## Команды для проверки установки
```powershell
powershell -c "Get-Module -ListAvailable PSScriptAnalyzer"
shellcheck --version
markdownlint --version
```
