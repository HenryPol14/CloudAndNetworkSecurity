#!/usr/bin/env bash
# Описание: Валидация bash скриптов PROJECT_ROOT/scripts
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

errors=0
warnings=0

echo "=== Валидация Bash скриптов ==="
echo "Project: $PROJECT_ROOT"
echo ""

# Проверка синтаксиса всех .sh файлов
for file in "$PROJECT_ROOT"/*.sh "$PROJECT_ROOT"/**/*.sh; do
    if [[ -f "$file" ]]; then
        if bash -n "$file" 2>&1; then
            echo -e "${GREEN}✓${NC} Синтаксис OK: $(realpath "$file" 2>/dev/null || echo "$file")"
        else
            echo -e "${RED}✗${NC} Синтаксис ОШИБКА: $(realpath "$file" 2>/dev/null || echo "$file")"
            ((errors++))
        fi
    fi
done

# Проверка ShellCheck (если установлен)
if command -v shellcheck >/dev/null 2>&1; then
    echo ""
    echo "=== ShellCheck (статический анализ) ==="
    for file in "$PROJECT_ROOT"/*.sh "$PROJECT_ROOT"/**/*.sh; do
        if [[ -f "$file" ]]; then
            if shellcheck -x "$file" 2>&1; then
                echo -e "${GREEN}✓${NC} ShellCheck OK: $(realpath "$file" 2>/dev/null || echo "$file")"
            else
                echo -e "${RED}✗${NC} ShellCheck ПРЕДУПРЕЖДЕНИЕ: $(realpath "$file" 2>/dev/null || echo "$file")"
                ((warnings++))
            fi
        fi
    done
else
    echo ""
    echo -e "${YELLOW}⚠${NC} ShellCheck не установлен. Пропущен статический анализ."
fi

echo ""
echo "=== Результаты ==="
echo -e "Ошибок синтаксиса: ${RED}$errors${NC}"
echo -e "Предупреждений: ${YELLOW}$warnings${NC}"

if [[ $errors -gt 0 ]]; then
    echo -e "${RED}ОБНАРУЖЕНЫ ОШИБКИ!${NC}"
    exit 1
else
    echo -e "${GREEN}Валидация завершена успешно!${NC}"
    exit 0
fi
