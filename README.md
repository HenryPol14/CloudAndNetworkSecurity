#  IC00AJ73 Cyber Security II: Cloud and Network Security

Exercises for the course IC00AJ73 Cyber Security II: Cloud and Network Security at the University of Oulu.

This course handles key concepts and principles in cloud and network security. Especially in the topics of

    Network security and the use of firewalls
    Network traffic analysis and VPN
    Networking protocols and protocol fuzzing
    Container security
    Cloud security
    Digital forensics & incident response
    Security of internet

The course is organized by Oulu University Secure Programming Group (OUSPG)

## Practicalities

The course has seven laboratory exercises

Lectures are handling topics from a high perspective.

Laboratory exercises are thought of as independent packages: containing theory and exercises and going technologically very deep.

To pass this course with grade 1, you have to attend all lectures, excluding the first lecture. Failing to do so results in a written exam based on the lectures missed.

To get a better grade, you have to do some laboratory exercises. All laboratory tasks are optional and total points from those will determine your grade.

## Grading

As described earlier, you have to attend all lectures to pass the course. You can have higher grades by doing lab work.

You can get up to 5 points in each lab (A total of 35 points). The grade is determined based on those points. For example, with 9 points you get grade 2.

The week 3 has an optional project work available that differs a bit from general grading guideliens.

Total Points|Total Grade
:-:|:-:
9+ | 2
15+ | 3
21+ | 4
27+ | 5

<!-- </details> -->

## Getting started

- **[README_RU.md](1.Network_Security/README_RU.md)** — Русская версия документации
- Enroll in the course
- Find the course's Moodle page from the University's Moodle
- Find a link where you can receive and create a private repository containing all the return template folders. 
You are expected to answer for given templates and store your actual work in this repository.
- Create a GitHub account, if you don't have one already, and create this private repository from the link.
- Complete as many tasks as you wish and update your repository accordingly. 
Check the grading table found in each lab instructions on what you have to complete to earn the grade of your choosing
- Push your changes to your repository before the deadline, and return the link to your repository to the corresponding return box of the lab in Moodle.

## Development

### Validation Scripts

Код включает скрипты валидации, взятые из проекта [llm-lab](https://gitlab.com/henrynik/llm-lab):

| Скрипт | Описание |
|--------|----------|
| `.kilo/scripts/validate-bash.sh` | Проверка синтаксиса Bash скриптов (с ShellCheck) |
| `.kilo/scripts/validate-yaml.sh` | Валидация YAML конфигураций |
| `.kilo/scripts/validate-markdown.sh` | Базовая проверка Markdown документов |
| `.kilo/scripts/validate-all.sh` | Запуск всех проверок |

**Установка зависимостей:**
```bash
# PyYAML для валидации YAML
pip install pyyaml

# ShellCheck для статического анализа Bash (опционально)
# Установка через Chocolatey:
choco install shellcheck
```

**Запуск:**
```bash
# Все проверки
bash .kilo/scripts/validate-all.sh

# Отдельные проверки
bash .kilo/scripts/validate-bash.sh
python .kilo/scripts/validate-yaml.sh
python .kilo/scripts/validate-markdown.sh
```

**Использованные правила из llm-lab:**
- `set -Eeuo pipefail` в Bash скриптах
- ShellCheck-совместимый стиль
- `readonly` константы и `local` переменные
- snake_case именование
