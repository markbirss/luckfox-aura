#!/bin/bash
# /usr/local/bin/run_initd.sh
# Usage: run_initd.sh start|stop

if [ -z "$1" ]; then
    echo "Usage: $0 {start|stop}"
    exit 1
fi

ACTION="$1"

case "$ACTION" in
    start)
        for i in /etc/init.d/S??*; do
            [ ! -f "$i" ] && continue
            case "$i" in
                *.sh)
                    (trap - INT QUIT TSTP; set start; . "$i")
                    ;;
                *)
                    "$i" start
                    ;;
            esac
        done
        ;;
    stop)
        for i in $(ls -r /etc/init.d/S??*); do
            [ ! -f "$i" ] && continue
            case "$i" in
                *.sh)
                    (trap - INT QUIT TSTP; set stop; . "$i")
                    ;;
                *)
                    "$i" stop
                    ;;
            esac
        done
        ;;
    *)
        echo "Invalid action: $ACTION"
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
