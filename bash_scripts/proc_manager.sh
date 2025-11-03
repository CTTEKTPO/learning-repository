#!/bin/bash

arg1=$1
arg2=${2:-5}


help(){
    echo "Параметры:"
    echo "  list                    - Показать все мои процессы"
    echo "  top-cpu [N]             - Топ N по CPU (по умолчанию 5)"
    echo "  top-mem [N]             - Топ N по памяти"
    echo "  find <процесс>          - Найти процесс по имени"
    echo "  kill <процесс>          - Убить процесс (SIGTERM)"
    echo "  kill-force <процесс>    - Убить процесс (SIGKILL)"
    echo "  info <PID>              - Показать инфо о процессе (ps + дополнительно)"
    echo ""
}

#Проверка ввода
if [ $# -lt 1 ]; then
    help
    exit 1
fi

# Проверка наличия процесса
check_process() {
    case "$1" in
        find|kill|kill-force)
            if ! pgrep -x "$2" > /dev/null; then
                echo "Процесс '$2' не найден."
                exit 1
            fi
            ;;
        info)
            if ! ps -p "$2" > /dev/null; then
                echo "Процесс с PID '$2' не найден."
                exit 1
            fi
            ;;
    esac
}

check_process "$arg1" "$arg2"

case "$arg1" in
    list)
        echo "Все процессы текущего пользователя:"
        ps ux
    ;;
    top-cpu)
        echo "Топ $arg2 процессов по CPU"
        ps -eo pid,user,comm,%cpu --sort=-%cpu | head -n $arg2
    ;;
    top-mem)
        echo "Топ $arg2 процессов по memory"
        ps -eo pid,user,comm,%mem --sort=-%mem | head -n $arg2
    ;;
    find)
        echo "Информация по процессу(ам) с именем $arg2"
        ps u -C $arg2
    ;;
    kill)
        echo "Корректное завершение процесса с именем $arg2"
        pkill -SIGTERM $arg2
    ;;
    kill-force)
        echo "Процесс $arg2 'убит' принудительно"
        pkill -SIGKILL $arg2
    ;;
    info)
        echo "Информация по процессу с PID $arg2"
        ps -p $arg2 -o pid,ppid,user,%cpu,%mem,stat,command,lstart
    ;;
    *)
        help
    ;;    

esac


