#!/bin/bash

send_requests_to_most_recent_container() {
    while true; do
        # Get the most recently created container that is running
        most_recent_container=$(docker ps --format '{{.Names}} {{.CreatedAt}}' | sort -rk2 | head -n 1 | awk '{print $1}')
        if [ -n "$most_recent_container" ]; then
            case "$most_recent_container" in
                srv1)
                    port=8081
                    ;;
                srv2)
                    port=8082
                    ;;
                srv3)
                    port=8083
                    ;;
                srv4)
                    port=8084
                    ;;
                *)
                    port=""
                    ;;
            esac

            if [ -n "$port" ]; then
                echo "Active container: $most_recent_container, Sending requests to port: $port"
                curl -s "http://localhost:$port/sort?size=1000000" > /dev/null &
            else
                echo "No valid port found for container: $most_recent_container"
            fi
        else
            echo "No active containers detected."
        fi
        sleep $((RANDOM % 6 + 5))
    done
}

send_requests_to_most_recent_container

