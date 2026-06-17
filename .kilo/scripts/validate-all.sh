#!/bin/bash
# Описание: Главный скрипт валидации для PROJECT_ROOT
# Выполняет все проверки: bash, yaml, markdown

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo "  Валидация проекта CloudAndNetworkSecurity"
echo "============================================"
echo ""

# Проверка Bash
echo "[1/3] Проверка Bash скриптов..."
"${SCRIPT_DIR}/validate-bash.sh"

# Проверка YAML
echo ""
echo "[2/3] Проверка YAML конфигураций..."
/c/Python314/python.exe "${SCRIPT_DIR}/validate-yaml.sh"

# Проверка Markdown
echo ""
echo "[3/3] Проверка Markdown документов..."
/c/Python314/python.exe "${SCRIPT_DIR}/validate-markdown.sh"

echo ""
echo "============================================"
echo "  ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ УСПЕШНО"
echo "============================================"
